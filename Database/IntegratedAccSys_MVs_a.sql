-- =====================================================================
-- IntegratedAccSys — Materialized Views (Gap #7) — Part A
-- =====================================================================
-- Date        : 2026-06-11
-- Branch      : feat/gap-7-materialized-views
-- Author      : GitHub Copilot (MiniMax-M3)
-- Plan        : docs/audits/GAP_7_MATERIALIZED_VIEWS_PLAN.md
--
-- Adds 3 MVs (sales / customer AR / treasury) for the most common
-- dashboard queries. All created WITH NO DATA so the initial CREATE
-- is fast and never fails on empty tables. Each MV has a UNIQUE INDEX
-- so it can be REFRESHed with REFRESH MATERIALIZED VIEW CONCURRENTLY.
--
-- Conventions (same as gap 2/3/4/5)
-- ----------------------------------
--  - IF NOT EXISTS      (idempotent)
--  - WITH NO DATA       (no expensive initial build)
--  - UNIQUE INDEX       (required for REFRESH CONCURRENTLY)
--  - No BEGIN/COMMIT    (no MV-related DDL is transactional-safe)
--  - Naming mv_<subject>
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. mv_daily_sales_summary
--    Daily sales rollup (date, branch, tx count, total amount).
-- ---------------------------------------------------------------------
CREATE MATERIALIZED VIEW IF NOT EXISTS public.mv_daily_sales_summary AS
SELECT
    operationdate                                        AS sale_date,
    branchcode                                           AS branch_code,
    COUNT(*)                                             AS tx_count,
    SUM(total)                                           AS total_amount,
    SUM(paidamount)                                      AS total_paid,
    SUM(remainingamount)                                 AS total_outstanding,
    MAX(operationdate)                                    AS refreshed_at
FROM public.tbloperationheader
WHERE operationtype = 'SALE'
  AND NOT iscancelled
GROUP BY operationdate, branchcode
WITH NO DATA;

-- Unique index (required for REFRESH CONCURRENTLY)
CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_daily_sales_summary_pk
    ON public.mv_daily_sales_summary (sale_date, branch_code);

-- ---------------------------------------------------------------------
-- 2. mv_customer_outstanding_balance
--    Per-customer AR balance: total credit (sales), total debit
--    (paid), and outstanding balance.
-- ---------------------------------------------------------------------
CREATE MATERIALIZED VIEW IF NOT EXISTS public.mv_customer_outstanding_balance AS
SELECT
    customercode                                         AS customer_code,
    COALESCE(SUM(total)         FILTER (WHERE NOT iscancelled), 0) AS total_credit,
    COALESCE(SUM(paidamount)    FILTER (WHERE NOT iscancelled), 0) AS total_debit,
    COALESCE(SUM(remainingamount) FILTER (WHERE NOT iscancelled), 0) AS balance,
    COUNT(*)             FILTER (WHERE NOT iscancelled)         AS open_invoices,
    MAX(operationdate)                                       AS last_invoice_date,
    now()                                                    AS refreshed_at
FROM public.tbloperationheader
WHERE customercode IS NOT NULL
GROUP BY customercode
WITH NO DATA;

-- Unique index
CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_customer_outstanding_balance_pk
    ON public.mv_customer_outstanding_balance (customer_code);

-- ---------------------------------------------------------------------
-- 3. mv_treasury_position
--    Cash + bank balances per entity. Combines cashboxes + bank accounts
--    into a single view for the treasury dashboard.
-- ---------------------------------------------------------------------
CREATE MATERIALIZED VIEW IF NOT EXISTS public.mv_treasury_position AS
-- Cashboxes
SELECT
    'CASH'::text        AS entity_type,
    cashboxid            AS entity_id,
    cashboxname          AS entity_name,
    currentbalance       AS balance,
    branchid             AS branch_code,
    isactive             AS is_active,
    now()                AS refreshed_at
FROM public.tblcashboxes
WHERE cashboxid IS NOT NULL
UNION ALL
-- Bank accounts (no branchcode column; branchname is a free-text label)
SELECT
    'BANK'::text         AS entity_type,
    bankaccountid        AS entity_id,
    bankaccountno        AS entity_name,
    currentbalance       AS balance,
    NULL::integer        AS branch_code,
    isactive             AS is_active,
    now()                AS refreshed_at
FROM public.tblbankaccounts
WHERE bankaccountid IS NOT NULL
WITH NO DATA;

-- Note: this MV has no single unique column (entity_id alone is not
-- unique across CASH/BANK). For REFRESH CONCURRENTLY, the PK must be
-- (entity_type, entity_id). Use a surrogate.
CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_treasury_position_pk
    ON public.mv_treasury_position (entity_type, entity_id);

-- ---------------------------------------------------------------------
-- Idempotency signature (Part A)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_g7_mv_signature_part_a()
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$ SELECT 'GAP7-MV-PART-A-2026-06-11-v1'::text $$;

GRANT EXECUTE ON FUNCTION public.fn_g7_mv_signature_part_a() TO PUBLIC;

-- =====================================================================
-- End of IntegratedAccSys_MVs_a.sql (Part A)
-- Next commit (Part B) will add 2 more MVs (inventory + budget).
-- =====================================================================
