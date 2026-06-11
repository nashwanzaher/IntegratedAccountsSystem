-- =====================================================================
-- IntegratedAccSys — Indexes Optimization (Gap #5) — Part B (Partial)
-- =====================================================================
-- Date        : 2026-06-11
-- Branch      : feat/gap-5-indexes-optimization
-- Author      : GitHub Copilot (MiniMax-M3)
-- Plan        : docs/audits/GAP_5_INDEXES_PLAN.md
--
-- Adds 2 partial indexes for the most common filtered lookups
-- (isactive = true). These complement the existing partials already
-- in the DB (approval status filters, etc.).
--
-- Skipped (already covered by existing indexes)
-- ---------------------------------------------
--  - idx_tblsessions_active_now: redundant with
--    `excl_tblsessions_active_user` (gap-4 EXCLUDE covers the active
--    case on the leading column).
--  - idx_approvalrequests_pending: redundant with
--    `ix_approvalrequests_due` which already filters on
--    (PENDING, IN_REVIEW).
--
-- Naming
-- ------
-- idx_<table>_<subject>_active
-- idx_<table>_<subject>_partial
-- =====================================================================

-- Pre-flight: drop any INVALID leftovers
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
               'idx_tblusers_active',
               'idx_tblproducts_inventory'
           )
    LOOP
        EXECUTE format('DROP INDEX IF EXISTS public.%I', r.idx_name);
        v_dropped := v_dropped + 1;
    END LOOP;
    IF v_dropped > 0 THEN
        RAISE NOTICE '[OK] dropped % invalid index(es)', v_dropped;
    ELSE
        RAISE NOTICE '[..] no invalid leftovers to clean';
    END IF;
END
$$;

-- ---------------------------------------------------------------------
-- 1. tblusers WHERE isactive = true
-- ---------------------------------------------------------------------
-- Most "look up an active user by id" queries filter on
-- isactive = true. A partial index is much smaller than a full one.
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tblusers_active
    ON public.tblusers (usercode)
    WHERE isactive = true;

-- ---------------------------------------------------------------------
-- 2. tblproducts WHERE isinventoryitem = true AND isactive = true
-- ---------------------------------------------------------------------
-- Most "show me active sellable inventory items" queries need both
-- filters. A partial index serves them without touching the long
-- tail of inactive or non-inventory rows.
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tblproducts_inventory
    ON public.tblproducts (productcode)
    WHERE isinventoryitem = true AND isactive = true;

-- ---------------------------------------------------------------------
-- Idempotency signature (Part B)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_g5_indexes_signature_part_b()
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$ SELECT 'GAP5-INDEXES-PART-B-2026-06-11-v1'::text $$;

GRANT EXECUTE ON FUNCTION public.fn_g5_indexes_signature_part_b() TO PUBLIC;

-- =====================================================================
-- End of IntegratedAccSys_Indexes_partial.sql (Part B)
-- =====================================================================
