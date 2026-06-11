-- =====================================================================
-- IntegratedAccSys — Materialized Views (Gap #7) — Part B
-- =====================================================================
-- Date        : 2026-06-11
-- Branch      : feat/gap-7-materialized-views
-- Author      : GitHub Copilot (MiniMax-M3)
-- Plan        : docs/audits/GAP_7_MATERIALIZED_VIEWS_PLAN.md
--
-- Adds 2 more MVs (inventory snapshot + budget vs actual) to complete
-- the gap 7 deliverable of 5 new MVs (Part A added 3).
--
-- Conventions (same as Part A)
--  - IF NOT EXISTS, WITH NO DATA, UNIQUE INDEX, no BEGIN/COMMIT
-- =====================================================================

-- ---------------------------------------------------------------------
-- 4. mv_monthly_inventory_snapshot
--    Per (product, store) inventory snapshot: qty on hand, avg cost,
--    total value. Intended to be REFRESHed nightly.
-- ---------------------------------------------------------------------
CREATE MATERIALIZED VIEW IF NOT EXISTS public.mv_monthly_inventory_snapshot AS
SELECT
    productcode                                          AS product_code,
    storecode                                            AS store_code,
    SUM(qtyonhand)                                        AS qty_on_hand,
    SUM(qtyreserved)                                      AS qty_reserved,
    SUM(qtyonhand - qtyreserved)                          AS qty_available,
    AVG(avgcost)                                          AS avg_cost,
    SUM(qtyonhand * COALESCE(avgcost, 0))                 AS total_value,
    COUNT(*)             FILTER (WHERE isactive)           AS active_batches,
    now()                                                  AS refreshed_at
FROM public.tblstoreproducts
WHERE isactive = true
GROUP BY productcode, storecode
WITH NO DATA;

-- Unique index
CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_monthly_inventory_snapshot_pk
    ON public.mv_monthly_inventory_snapshot (product_code, store_code);

-- ---------------------------------------------------------------------
-- 5. mv_budget_vs_actual_summary
--    Per (period, account) budget vs actual: budget_amount, actual,
--    variance (absolute + percentage). Intended to be REFRESHed daily.
-- ---------------------------------------------------------------------
CREATE MATERIALIZED VIEW IF NOT EXISTS public.mv_budget_vs_actual_summary AS
SELECT
    periodid                                             AS period_id,
    accountid                                            AS account_id,
    branchid                                             AS branch_id,
    costcenterid                                         AS cost_center_id,
    SUM(budgetamount)                                    AS budget_amount,
    SUM(actualamount)                                    AS actual_amount,
    SUM(varianceamount)                                  AS variance_amount,
    CASE
        WHEN SUM(budgetamount) = 0 THEN NULL
        ELSE round(
            (SUM(varianceamount)::numeric / NULLIF(SUM(budgetamount), 0)::numeric) * 100,
            2)
    END                                                  AS variance_pct,
    COUNT(*)                                             AS budget_line_count,
    now()                                                AS refreshed_at
FROM public.tblbudgets
GROUP BY periodid, accountid, branchid, costcenterid
WITH NO DATA;

-- Unique index (composite PK: period + account + branch + cost-center)
CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_budget_vs_actual_summary_pk
    ON public.mv_budget_vs_actual_summary (period_id, account_id, branch_id, cost_center_id);

-- ---------------------------------------------------------------------
-- Idempotency signature (Part B)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_g7_mv_signature_part_b()
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$ SELECT 'GAP7-MV-PART-B-2026-06-11-v1'::text $$;

GRANT EXECUTE ON FUNCTION public.fn_g7_mv_signature_part_b() TO PUBLIC;

-- =====================================================================
-- End of IntegratedAccSys_MVs_b.sql (Part B)
-- Next commit will add the audit script and refresh function.
-- =====================================================================
