-- =====================================================================
-- IntegratedAccSys — Indexes Optimization (Gap #5) — Part A (Composite)
-- =====================================================================
-- Date        : 2026-06-11
-- Branch      : feat/gap-5-indexes-optimization
-- Author      : GitHub Copilot (MiniMax-M3)
-- Plan        : docs/audits/GAP_5_INDEXES_PLAN.md
--
-- Adds 6 composite indexes for high-traffic read patterns identified
-- in ENTERPRISE_GAP_ANALYSIS §2.4. Each index is built CONCURRENTLY
-- so the table is NOT locked against writes during construction.
--
-- Why direct statements (not a helper function)
-- ----------------------------------------------
-- PostgreSQL forbids `CREATE INDEX CONCURRENTLY` from inside a function
-- (functions run inside a transaction; CONCURRENTLY cannot). The
-- standard pattern is to issue CONCURRENTLY statements at the top
-- level. Idempotency is provided by `IF NOT EXISTS`.
--
-- IMPORTANT
-- ---------
-- This file does NOT use BEGIN/COMMIT because
-- CREATE INDEX CONCURRENTLY cannot run inside a transaction block.
-- This matches the convention in gap 2/3/4 SQL files.
--
-- Rollback of a failed build
-- --------------------------
-- If a CREATE INDEX CONCURRENTLY is interrupted (server crash, etc.)
-- the index may be left INVALID. The pre-flight block at the top
-- drops any such invalid index before re-attempting the build.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Pre-flight: drop any INVALID leftovers from previous failed builds
-- ---------------------------------------------------------------------
DO $$
DECLARE
    r       record;
    v_dropped int := 0;
BEGIN
    FOR r IN
        SELECT c.relname AS idx_name
          FROM pg_class c
          JOIN pg_index i ON i.indexrelid = c.oid
         WHERE c.relkind = 'i'
           AND i.indisvalid = false
           AND c.relname IN (
               'idx_tbljournalbody_journal_account',
               'idx_tblbondbody_bond_account',
               'idx_tblsessions_user_active_expires',
               'idx_tblaudi_table_record_date',
               'idx_tblcashreceipts_date_cashbox_status',
               'idx_tblcashpayments_date_cashbox_status'
           )
    LOOP
        EXECUTE format('DROP INDEX IF EXISTS public.%I', r.idx_name);
        v_dropped := v_dropped + 1;
    END LOOP;
    IF v_dropped > 0 THEN
        RAISE NOTICE '[OK] dropped % invalid index(es) from previous failed builds', v_dropped;
    ELSE
        RAISE NOTICE '[..] no invalid leftovers to clean';
    END IF;
END
$$;

-- ---------------------------------------------------------------------
-- 1. tbljournalbody (journalcode, accountcode)
-- ---------------------------------------------------------------------
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tbljournalbody_journal_account
    ON public.tbljournalbody (journalcode, accountcode);

-- ---------------------------------------------------------------------
-- 2. tblbondbody (bondcode, accountcode)
-- ---------------------------------------------------------------------
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tblbondbody_bond_account
    ON public.tblbondbody (bondcode, accountcode);

-- ---------------------------------------------------------------------
-- 3. tblsessions (userid, isactive, expiresat)
-- ---------------------------------------------------------------------
-- Complements the gap-4 EXCLUDE `excl_tblsessions_active_user` which
-- covers the (usercode, time-range) overlap case. This index covers
-- the "find all active sessions for a user" look-up (ORDER BY expiresat).
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tblsessions_user_active_expires
    ON public.tblsessions (userid, isactive, expiresat);

-- ---------------------------------------------------------------------
-- 4. tblaudi (tablename, recordid, actiondate DESC)
-- ---------------------------------------------------------------------
-- The existing `ix_audithist_table_record` covers
-- (tablename, recordid) for equality lookups. This new index adds
-- the date dimension so "give me the audit history of this record,
-- newest first" is served from the index without a sort.
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tblaudi_table_record_date
    ON public.tblaudi (tablename, recordid, actiondate DESC);

-- ---------------------------------------------------------------------
-- 5. tblcashreceipts (receiptdate, cashboxid, status)
-- ---------------------------------------------------------------------
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tblcashreceipts_date_cashbox_status
    ON public.tblcashreceipts (receiptdate, cashboxid, status);

-- ---------------------------------------------------------------------
-- 6. tblcashpayments (paymentdate, cashboxid, status)
-- ---------------------------------------------------------------------
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tblcashpayments_date_cashbox_status
    ON public.tblcashpayments (paymentdate, cashboxid, status);

-- ---------------------------------------------------------------------
-- Idempotency signature (Part A)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_g5_indexes_signature_part_a()
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$ SELECT 'GAP5-INDEXES-PART-A-2026-06-11-v1'::text $$;

GRANT EXECUTE ON FUNCTION public.fn_g5_indexes_signature_part_a() TO PUBLIC;

-- =====================================================================
-- End of IntegratedAccSys_Indexes.sql (Part A)
-- Next commit (Part B) will add partial indexes.
-- =====================================================================
