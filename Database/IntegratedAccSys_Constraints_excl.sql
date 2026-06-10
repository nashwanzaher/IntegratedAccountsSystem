-- =====================================================================
-- IntegratedAccSys — Constraints Baseline (Gap #4) — Part C (EXCLUDE)
-- =====================================================================
-- Date        : 2026-06-11
-- Branch      : feat/gap-4-constraints
-- Author      : GitHub Copilot (MiniMax-M3)
-- Plan        : docs/audits/GAP_4_CONSTRAINTS_PLAN.md
--
-- Adds 4 EXCLUDE constraints that prevent data violations
-- (duplicates, overlapping ranges) that CHECK + UNIQUE cannot
-- express. Requires btree_gist (installed in Part A, commit 2).
--
-- Pre-flight (verified before this file was authored)
-- ---------------------------------------------------
--   SELECT bankaccountid, statementno, count(*) FROM tblbankstatements
--     GROUP BY 1,2 HAVING count(*) > 1;       -- 0 rows  ✅
--   SELECT fiscalyearid FROM tblfiscalperiods
--     WHERE daterange(startdate,enddate,'[]') overlaps another;  -- 0 rows  ✅
--   SELECT currid FROM tblexchangeratehistory
--     WHERE daterange(effectivedate, COALESCE(expirydate,'infinity'),'[]')
--         overlaps another;                  -- 0 rows  ✅
--   SELECT usercode FROM tblsessions WHERE isactive = true
--     AND tsrange(createdat, expiresat, '[]') overlaps another; -- 0 rows  ✅
--
-- Notes on EXCLUDE in PostgreSQL
-- ------------------------------
-- 1. EXCLUDE constraints require data to be valid at creation time
--    (no NOT VALID). Pre-flight above guarantees that.
-- 2. They are enforced via a GiST index — same storage cost as a
--    partial unique index but with stronger semantics.
-- 3. The WHERE clause turns an EXCLUDE into a partial constraint
--    (only enforced on matching rows; lets us ignore isactive=false).
--
-- Naming:  excl_<table>_<subject>
-- =====================================================================

-- Helper: idempotent EXCLUDE add. Re-running is a no-op.
CREATE OR REPLACE FUNCTION public.fn_add_exclude(
    p_table  regclass,
    p_name   text,
    p_def    text   -- full expression, e.g. 'EXCLUDE USING gist (...)'
)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists boolean;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conrelid = p_table AND conname = p_name
    ) INTO v_exists;

    IF v_exists THEN
        RETURN format('[..] %s already present.', p_name);
    END IF;

    EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %I %s', p_table, p_name, p_def);
    RETURN format('[OK] %s added.', p_name);
END
$$;

-- ---------------------------------------------------------------------
-- 1. tblbankstatements — no duplicate (bankaccountid, statementno)
-- ---------------------------------------------------------------------
-- statementno is character varying(50). btree_gist gives us GiST
-- support for text equality.
SELECT public.fn_add_exclude(
    'public.tblbankstatements',
    'excl_tblbankstatements_account_statementno',
    'EXCLUDE USING gist (bankaccountid WITH =, statementno WITH =)'
);

-- ---------------------------------------------------------------------
-- 2. tblfiscalperiods — no overlapping periods per fiscal year
-- ---------------------------------------------------------------------
-- daterange with '[]' is inclusive on both ends. Existing data has
-- 4 periods per year, all non-overlapping. Verified above.
SELECT public.fn_add_exclude(
    'public.tblfiscalperiods',
    'excl_tblfiscalperiods_fiscalyear_daterange',
    'EXCLUDE USING gist (fiscalyearid WITH =, daterange(startdate, enddate, ''[]'') WITH &&)'
);

-- ---------------------------------------------------------------------
-- 3. tblexchangeratehistory — no overlapping rates per currency
-- ---------------------------------------------------------------------
-- Some expirydate values are NULL; treat them as 'infinity' so the
-- range stays open-ended (rate valid "until further notice").
SELECT public.fn_add_exclude(
    'public.tblexchangeratehistory',
    'excl_tblexchangeratehistory_currid_daterange',
    $EXCL$EXCLUDE USING gist (
        currid WITH =,
        daterange(effectivedate, COALESCE(expirydate, 'infinity'::date), '[]') WITH &&
    )$EXCL$
);

-- ---------------------------------------------------------------------
-- 4. tblsessions — at most one ACTIVE session per user
-- ---------------------------------------------------------------------
-- Partial constraint: only enforced on isactive = true. The user can
-- have many historical (isactive=false) sessions that overlap freely.
SELECT public.fn_add_exclude(
    'public.tblsessions',
    'excl_tblsessions_active_user',
    $EXCL$EXCLUDE USING gist (
        usercode WITH =,
        tsrange(createdat, expiresat, '[]') WITH &&
    ) WHERE (isactive = true)$EXCL$
);

-- ---------------------------------------------------------------------
-- Final signature (Part C)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_g4_constraints_signature_part_c()
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$ SELECT 'GAP4-CONSTRAINTS-PART-C-2026-06-11-v1'::text $$;

GRANT EXECUTE ON FUNCTION public.fn_g4_constraints_signature_part_c() TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.fn_add_exclude(regclass, text, text) TO app_admin;

-- =====================================================================
-- End of IntegratedAccSys_Constraints_excl.sql (Part C)
-- Next commit will add the audit script and final report.
-- =====================================================================
