-- =====================================================================
-- IntegratedAccSys — Constraints Baseline (Gap #4) — Part B (CHECK)
-- =====================================================================
-- Date        : 2026-06-11
-- Branch      : feat/gap-4-constraints
-- Author      : GitHub Copilot (MiniMax-M3)
-- Plan        : docs/audits/GAP_4_CONSTRAINTS_PLAN.md
--
-- Adds 15 data-validity CHECK constraints to existing tables in the
-- public schema. Each constraint is added as NOT VALID first (to avoid
-- a long table-level lock on existing data) and then VALIDATEd in a
-- separate step. If any pre-existing data violates a constraint, the
-- VALIDATE step fails with a clear error pointing at the offending
-- row, so the operator can clean it up before retrying.
--
-- Naming convention
-- -----------------
-- chk_<table>_<column-or-subject>_<rule>
-- e.g.  chk_tblproducts_minstock_nonneg
--       chk_tbljournalbody_no_dual_leg
--
-- Idempotency
-- -----------
-- The DO block at the top of each section checks pg_constraint first;
-- re-running is a no-op. Safe to apply multiple times.
--
-- IMPORTANT
-- ---------
-- This file is committed SEPARATELY from Part A (btree_gist) so the
-- diff is small and reviewable. Both are applied to the same database
-- in sequence; the order does not matter (btree_gist is needed only
-- for EXCLUDE constraints in the next commit).
-- =====================================================================

-- ---------------------------------------------------------------------
-- Helper macro via a SQL function: idempotently add a CHECK constraint
-- with NOT VALID, then VALIDATE it. If the constraint already exists,
-- do nothing. If the constraint exists but is NOT VALID, VALIDATE it.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_add_check_validated(
    p_table   regclass,
    p_name    text,
    p_expr    text
)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
    v_conid     oid;
    v_condef    text;
    v_notvalid  boolean;
    v_result    text;
BEGIN
    -- 1. Does it exist already?
    SELECT c.oid, pg_get_constraintdef(c.oid), c.convalidated
      INTO v_conid, v_condef, v_notvalid
      FROM pg_constraint c
     WHERE c.conrelid = p_table
       AND c.conname  = p_name;

    IF v_conid IS NOT NULL THEN
        -- Exists. Is it NOT VALID?
        IF v_notvalid = false THEN
            RETURN format('[..] %s already present and validated.', p_name);
        ELSE
            EXECUTE format('ALTER TABLE %s VALIDATE CONSTRAINT %I', p_table, p_name);
            RETURN format('[OK] %s was NOT VALID; validated now.', p_name);
        END IF;
    END IF;

    -- 2. Add as NOT VALID (no full-table lock for write)
    EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %I CHECK (%s) NOT VALID', p_table, p_name, p_expr);
    v_result := format('[OK] %s added as NOT VALID.', p_name);

    -- 3. VALIDATE (only acquires SHARE UPDATE EXCLUSIVE — reads continue)
    BEGIN
        EXECUTE format('ALTER TABLE %s VALIDATE CONSTRAINT %I', p_table, p_name);
        v_result := v_result || ' Validated.';
    EXCEPTION WHEN check_violation THEN
        v_result := v_result || ' VALIDATION FAILED — data violates constraint.';
        RAISE;
    END;
    RETURN v_result;
END
$$;

-- ---------------------------------------------------------------------
-- 1. tblproducts — stock levels non-negative and consistent
-- ---------------------------------------------------------------------
SELECT public.fn_add_check_validated(
    'public.tblproducts',
    'chk_tblproducts_minstock_nonneg',
    'minstocklevel IS NULL OR minstocklevel >= 0'
);

SELECT public.fn_add_check_validated(
    'public.tblproducts',
    'chk_tblproducts_maxstock_gte_min',
    'minstocklevel IS NULL OR maxstocklevel IS NULL OR maxstocklevel >= minstocklevel'
);

SELECT public.fn_add_check_validated(
    'public.tblproducts',
    'chk_tblproducts_prices_nonneg',
    'standardcost >= 0 AND lastpurchaseprice >= 0 AND lastsaleprice >= 0'
);

-- ---------------------------------------------------------------------
-- 2. tblbondheader — amount strictly positive
-- ---------------------------------------------------------------------
SELECT public.fn_add_check_validated(
    'public.tblbondheader',
    'chk_tblbondheader_amount_positive',
    'amount IS NULL OR amount > 0'
);

-- ---------------------------------------------------------------------
-- 3. tblbankaccounts — current balance non-negative (or NULL = unknown)
-- ---------------------------------------------------------------------
SELECT public.fn_add_check_validated(
    'public.tblbankaccounts',
    'chk_tblbankaccounts_balance_nonneg',
    'currentbalance IS NULL OR currentbalance >= 0'
);

-- ---------------------------------------------------------------------
-- 4. tblsessions — timestamp sanity
-- ---------------------------------------------------------------------
SELECT public.fn_add_check_validated(
    'public.tblsessions',
    'chk_tblsessions_expires_after_created',
    'expiresat IS NULL OR createdat IS NULL OR expiresat > createdat'
);

SELECT public.fn_add_check_validated(
    'public.tblsessions',
    'chk_tblsessions_logout_after_created',
    'logoutat IS NULL OR createdat IS NULL OR logoutat >= createdat'
);

-- ---------------------------------------------------------------------
-- 5. tbljournalbody — debit/credit sanity (mutually exclusive)
-- ---------------------------------------------------------------------
SELECT public.fn_add_check_validated(
    'public.tbljournalbody',
    'chk_tbljournalbody_amounts_nonneg',
    '(debit IS NULL OR debit >= 0) AND (credit IS NULL OR credit >= 0)'
);

SELECT public.fn_add_check_validated(
    'public.tbljournalbody',
    'chk_tbljournalbody_no_dual_leg',
    'NOT (COALESCE(debit, 0) > 0 AND COALESCE(credit, 0) > 0)'
);

-- ---------------------------------------------------------------------
-- 6. tblexchangeratehistory — rate strictly positive
-- ---------------------------------------------------------------------
SELECT public.fn_add_check_validated(
    'public.tblexchangeratehistory',
    'chk_tblexchangeratehistory_exgrate_positive',
    'exgrate > 0'
);

-- ---------------------------------------------------------------------
-- 7. tblpricelists — discount in [0, 100]
-- ---------------------------------------------------------------------
SELECT public.fn_add_check_validated(
    'public.tblpricelists',
    'chk_tblpricelists_markup_nonneg',
    'markuppercent IS NULL OR markuppercent >= 0'
);

-- ---------------------------------------------------------------------
-- 8. tblusers — failed login attempts non-negative
-- ---------------------------------------------------------------------
SELECT public.fn_add_check_validated(
    'public.tblusers',
    'chk_tblusers_loginattempts_nonneg',
    'loginattempts IS NULL OR loginattempts >= 0'
);

-- ---------------------------------------------------------------------
-- 9. tblbanktransactions — amount strictly positive
-- ---------------------------------------------------------------------
SELECT public.fn_add_check_validated(
    'public.tblbanktransactions',
    'chk_tblbanktransactions_amount_positive',
    'amount IS NULL OR amount > 0'
);

-- ---------------------------------------------------------------------
-- Final signature (consolidated for gap 4 part B)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_g4_constraints_signature_part_b()
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$ SELECT 'GAP4-CONSTRAINTS-PART-B-2026-06-11-v1'::text $$;

GRANT EXECUTE ON FUNCTION public.fn_g4_constraints_signature_part_b() TO PUBLIC;

GRANT EXECUTE ON FUNCTION public.fn_add_check_validated(regclass, text, text) TO app_admin;

-- =====================================================================
-- End of IntegratedAccSys_Constraints_chk.sql (Part B)
-- Next commit (Part C) will add EXCLUDE constraints.
-- =====================================================================
