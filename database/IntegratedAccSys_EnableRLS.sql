-- =============================================================================
-- IntegratedAccSys — Gap #1 / Phase B: Enable RLS + Policies
-- =============================================================================
-- Date          : 2026-06-10
-- Project       : Integrated Accounts System (IntegratedAccSys)
-- Gap           : #1 — Roles and Permissions (CRITICAL)
-- Depends on    : IntegratedAccSys_RolesAndGrants.sql (must run first)
-- Strategy      : Enable Row-Level Security on 9 sensitive tables and
--                 attach explicit per-role policies. Idempotent.
--
-- Important:
--   * The application still connects as `postgres` (table owner) by default,
--     which BYPASSES RLS. To exercise the policies, set:
--         IAS_DB_USER=app_readwrite    (or app_admin, app_auditor, ...)
--     in the environment and restart the app.
--   * RLS affects only non-superuser, non-owner, non-BYPASSRLS roles — i.e.
--     the new app_* roles. Postgres superuser keeps full access (intentional,
--     for migrations and DBA work).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 0. Pre-flight safety
-- -----------------------------------------------------------------------------
DO $$
BEGIN
    IF current_user <> 'postgres' THEN
        RAISE EXCEPTION 'This script must be run as the postgres superuser. Current user: %', current_user;
    END IF;
END
$$;

-- -----------------------------------------------------------------------------
-- 1. Helper: drop ALL existing policies on a table (idempotent re-runs)
-- -----------------------------------------------------------------------------
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT schemaname, tablename, policyname
        FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename IN (
              'tblusers','tblsessions','tblauditlogs','tblaudi',
              'tblbankaccounts','tblcashboxes','tblcustomers',
              'tblsuppliers','tblnotifications'
          )
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I',
                       r.policyname, r.schemaname, r.tablename);
    END LOOP;
END
$$;

-- -----------------------------------------------------------------------------
-- 2. ENABLE Row-Level Security on the 9 sensitive tables
-- -----------------------------------------------------------------------------
ALTER TABLE public.tblusers          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tblsessions       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tblauditlogs      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tblaudi           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tblbankaccounts   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tblcashboxes      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tblcustomers      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tblsuppliers      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tblnotifications  ENABLE ROW LEVEL SECURITY;

-- Force RLS even for the table owner (defense in depth).
-- This affects postgres only if it loses superuser — still good practice.
ALTER TABLE public.tblusers          FORCE ROW LEVEL SECURITY;
ALTER TABLE public.tblsessions       FORCE ROW LEVEL SECURITY;
ALTER TABLE public.tblauditlogs      FORCE ROW LEVEL SECURITY;
ALTER TABLE public.tblaudi           FORCE ROW LEVEL SECURITY;
ALTER TABLE public.tblbankaccounts   FORCE ROW LEVEL SECURITY;
ALTER TABLE public.tblcashboxes      FORCE ROW LEVEL SECURITY;
ALTER TABLE public.tblcustomers      FORCE ROW LEVEL SECURITY;
ALTER TABLE public.tblsuppliers      FORCE ROW LEVEL SECURITY;
ALTER TABLE public.tblnotifications  FORCE ROW LEVEL SECURITY;

-- -----------------------------------------------------------------------------
-- 3. Policies for tblusers (credentials)
-- -----------------------------------------------------------------------------
-- app_admin: full DML
CREATE POLICY pol_users_admin_all
    ON public.tblusers
    FOR ALL
    TO app_admin
    USING (true)
    WITH CHECK (true);

-- app_auditor: SELECT only (compliance / user-list review)
CREATE POLICY pol_users_auditor_select
    ON public.tblusers
    FOR SELECT
    TO app_auditor
    USING (true);

-- No policy for app_readwrite / app_readonly → all writes/reads are DENIED.
-- Combined with the REVOKE in the previous script, app_readwrite CANNOT
-- touch tblusers at all.

-- -----------------------------------------------------------------------------
-- 4. Policies for tblsessions (active session tokens)
-- -----------------------------------------------------------------------------
CREATE POLICY pol_sessions_admin_all
    ON public.tblsessions
    FOR ALL
    TO app_admin
    USING (true)
    WITH CHECK (true);

CREATE POLICY pol_sessions_auditor_select
    ON public.tblsessions
    FOR SELECT
    TO app_auditor
    USING (true);

-- -----------------------------------------------------------------------------
-- 5. Policies for tblauditlogs and tblaudi (immutable append-only logs)
-- -----------------------------------------------------------------------------
-- Even app_admin cannot UPDATE/DELETE these tables — only INSERT/SELECT.
-- This is enforced at the policy level (separate policies per command).
CREATE POLICY pol_auditlogs_admin_select
    ON public.tblauditlogs
    FOR SELECT
    TO app_admin
    USING (true);

CREATE POLICY pol_auditlogs_admin_insert
    ON public.tblauditlogs
    FOR INSERT
    TO app_admin
    WITH CHECK (true);

CREATE POLICY pol_auditlogs_auditor_select
    ON public.tblauditlogs
    FOR SELECT
    TO app_auditor
    USING (true);

CREATE POLICY pol_audi_admin_select
    ON public.tblaudi
    FOR SELECT
    TO app_admin
    USING (true);

CREATE POLICY pol_audi_admin_insert
    ON public.tblaudi
    FOR INSERT
    TO app_admin
    WITH CHECK (true);

CREATE POLICY pol_audi_auditor_select
    ON public.tblaudi
    FOR SELECT
    TO app_auditor
    USING (true);

-- -----------------------------------------------------------------------------
-- 6. Policies for tblbankaccounts and tblcashboxes (treasury)
-- -----------------------------------------------------------------------------
CREATE POLICY pol_bankaccounts_admin_all
    ON public.tblbankaccounts
    FOR ALL
    TO app_admin
    USING (true)
    WITH CHECK (true);

CREATE POLICY pol_bankaccounts_readwrite_all
    ON public.tblbankaccounts
    FOR ALL
    TO app_readwrite
    USING (true)
    WITH CHECK (true);

CREATE POLICY pol_bankaccounts_auditor_select
    ON public.tblbankaccounts
    FOR SELECT
    TO app_auditor
    USING (true);

CREATE POLICY pol_cashboxes_admin_all
    ON public.tblcashboxes
    FOR ALL
    TO app_admin
    USING (true)
    WITH CHECK (true);

CREATE POLICY pol_cashboxes_readwrite_all
    ON public.tblcashboxes
    FOR ALL
    TO app_readwrite
    USING (true)
    WITH CHECK (true);

CREATE POLICY pol_cashboxes_auditor_select
    ON public.tblcashboxes
    FOR SELECT
    TO app_auditor
    USING (true);

-- -----------------------------------------------------------------------------
-- 7. Policies for tblcustomers and tblsuppliers (commercial)
-- -----------------------------------------------------------------------------
CREATE POLICY pol_customers_admin_all
    ON public.tblcustomers
    FOR ALL
    TO app_admin
    USING (true)
    WITH CHECK (true);

CREATE POLICY pol_customers_readwrite_all
    ON public.tblcustomers
    FOR ALL
    TO app_readwrite
    USING (true)
    WITH CHECK (true);

CREATE POLICY pol_customers_auditor_select
    ON public.tblcustomers
    FOR SELECT
    TO app_auditor
    USING (true);

CREATE POLICY pol_suppliers_admin_all
    ON public.tblsuppliers
    FOR ALL
    TO app_admin
    USING (true)
    WITH CHECK (true);

CREATE POLICY pol_suppliers_readwrite_all
    ON public.tblsuppliers
    FOR ALL
    TO app_readwrite
    USING (true)
    WITH CHECK (true);

CREATE POLICY pol_suppliers_auditor_select
    ON public.tblsuppliers
    FOR SELECT
    TO app_auditor
    USING (true);

-- -----------------------------------------------------------------------------
-- 8. Policies for tblnotifications (per-user messages)
-- -----------------------------------------------------------------------------
-- app_admin: full access (e.g. send broadcast)
CREATE POLICY pol_notifications_admin_all
    ON public.tblnotifications
    FOR ALL
    TO app_admin
    USING (true)
    WITH CHECK (true);

-- app_readwrite: SELECT + INSERT only (employees can read & acknowledge)
CREATE POLICY pol_notifications_readwrite_select
    ON public.tblnotifications
    FOR SELECT
    TO app_readwrite
    USING (true);

CREATE POLICY pol_notifications_readwrite_insert
    ON public.tblnotifications
    FOR INSERT
    TO app_readwrite
    WITH CHECK (true);

-- app_auditor: SELECT for compliance review
CREATE POLICY pol_notifications_auditor_select
    ON public.tblnotifications
    FOR SELECT
    TO app_auditor
    USING (true);

-- -----------------------------------------------------------------------------
-- 9. Verifier — print RLS state
-- -----------------------------------------------------------------------------
SELECT
    c.relname                                   AS table_name,
    c.relrowsecurity                            AS rls_enabled,
    c.relforcerowsecurity                       AS rls_forced,
    (SELECT count(*) FROM pg_policies p
       WHERE p.schemaname = 'public'
         AND p.tablename = c.relname)::text     AS policy_count
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND c.relkind = 'r'
  AND c.relname IN (
      'tblusers','tblsessions','tblauditlogs','tblaudi',
      'tblbankaccounts','tblcashboxes','tblcustomers',
      'tblsuppliers','tblnotifications'
  )
ORDER BY c.relname;

-- =============================================================================
-- End of file. Test with scripts/audit-rls-policies.ps1 next.
-- =============================================================================
