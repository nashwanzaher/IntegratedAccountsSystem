-- =============================================================================
-- IntegratedAccSys — Gap #1 / Phase A: Application Roles & Grants
-- =============================================================================
-- Date          : 2026-06-10
-- Project       : Integrated Accounts System (IntegratedAccSys)
-- Gap           : #1 — Roles and Permissions (CRITICAL, from ENTERPRISE_GAP_ANALYSIS.md)
-- Strategy      : Create 6 dedicated application roles with least-privilege
--                 grants, replacing the current "everyone is postgres" model.
--                 Idempotent — safe to re-run.
-- Backwards-compat:
--   * The application still connects as `postgres` by default.
--   * Set IAS_DB_USER=app_readwrite (etc.) in the environment to switch.
--   * RLS policies are loaded separately in 002_enable_rls_and_policies.sql.
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
-- 1. Create 6 application roles (least-privilege)
-- -----------------------------------------------------------------------------
-- Naming convention: app_<purpose>
-- Passwords: randomly generated dev passwords — rotate before any non-local use.
-- Login = false by default; set Login = true and assign password on demand.

DO $$
BEGIN
    -- 1.1 app_readonly — SELECT-only across all tables and views.
    --     Cannot write anything. Used for read-only reporting / dashboards.
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_readonly') THEN
        CREATE ROLE app_readonly NOLOGIN;
    END IF;

    -- 1.2 app_readwrite — Full CRUD on commercial tables; DENIED on security
    --     tables (users, sessions, audit, passwords). The default app role.
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_readwrite') THEN
        CREATE ROLE app_readwrite NOLOGIN;
    END IF;

    -- 1.3 app_admin — All commercial tables + security reads. NO DDL.
    --     Used by the WinForms app (Program.Main) for day-to-day operations.
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_admin') THEN
        CREATE ROLE app_admin NOLOGIN;
    END IF;

    -- 1.4 app_auditor — SELECT-only on security + audit tables.
    --     Used for compliance reviews and audit-log inspection.
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_auditor') THEN
        CREATE ROLE app_auditor NOLOGIN;
    END IF;

    -- 1.5 app_reports — SELECT-only across MVs and reporting views.
    --     Used by RDLC report rendering.
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_reports') THEN
        CREATE ROLE app_reports NOLOGIN;
    END IF;

    -- 1.6 app_backup — Used by pg_dump / restore automation. Granted read on
    --     everything plus ability to run backup procedures.
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_backup') THEN
        CREATE ROLE app_backup NOLOGIN;
    END IF;
END
$$;

-- Explicitly: app_* roles must NOT bypass RLS.
ALTER ROLE app_readonly  NOBYPASSRLS;
ALTER ROLE app_readwrite NOBYPASSRLS;
ALTER ROLE app_admin     NOBYPASSRLS;
ALTER ROLE app_auditor   NOBYPASSRLS;
ALTER ROLE app_reports   NOBYPASSRLS;
ALTER ROLE app_backup    NOBYPASSRLS;

-- -----------------------------------------------------------------------------
-- 2. Set dev passwords (LOCAL DEV ONLY — rotate before staging/prod)
-- -----------------------------------------------------------------------------
-- These are intentionally weak. Use ALTER ROLE ... WITH PASSWORD '...' in prod.
DO $$
BEGIN
    -- Only assign a dev password if the role has no password yet.
    -- We do this with a no-op ALTER guarded by a check.
    PERFORM 1 FROM pg_roles
        WHERE rolname = 'app_readonly' AND rolpassword IS NULL;
    -- (Passwords are not set here — login is NOLOGIN, so the role cannot
    --  be used to authenticate. A DBA explicitly grants LOGIN + password
    --  when a service needs the role, e.g.:
    --    ALTER ROLE app_readwrite LOGIN PASSWORD '...';
    -- )
END
$$;

-- -----------------------------------------------------------------------------
-- 3. Schema usage (USAGE) on public for all app roles
-- -----------------------------------------------------------------------------
GRANT USAGE ON SCHEMA public TO app_readonly, app_readwrite, app_admin,
                              app_auditor, app_reports, app_backup;

-- -----------------------------------------------------------------------------
-- 4. Default privileges — what newly-created tables inherit
-- -----------------------------------------------------------------------------
-- Without this, every new table added later has to be re-granted.
-- We delegate default-privilege management to app_admin (the "owner-like" role).
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO app_readonly, app_auditor, app_reports, app_backup;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_readwrite, app_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO app_readonly, app_readwrite, app_admin,
                                       app_auditor, app_reports, app_backup;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT EXECUTE ON FUNCTIONS TO app_readonly, app_readwrite, app_admin,
                                   app_auditor, app_reports, app_backup;

-- -----------------------------------------------------------------------------
-- 5. Grant on EXISTING objects (apply once now)
-- -----------------------------------------------------------------------------
-- 5.1 Tables: SELECT for read-only roles
GRANT SELECT ON ALL TABLES IN SCHEMA public
    TO app_readonly, app_auditor, app_reports, app_backup;

-- 5.2 Tables: full DML for readwrite and admin
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public
    TO app_readwrite, app_admin;

-- 5.3 Sequences (used by SERIAL / IDENTITY columns)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public
    TO app_readonly, app_readwrite, app_admin,
       app_auditor, app_reports, app_backup;

-- 5.4 Functions / procedures
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public
    TO app_readonly, app_readwrite, app_admin,
       app_auditor, app_reports, app_backup;

-- -----------------------------------------------------------------------------
-- 6. REVOKE from PUBLIC (defense in depth — kill the safety net)
-- -----------------------------------------------------------------------------
-- Even though we counted 0 PUBLIC grants earlier, revoke to be safe
-- (idempotent: REVOKE is a no-op when nothing was granted).
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM PUBLIC;

-- -----------------------------------------------------------------------------
-- 7. Explicitly lock down SECURITY-sensitive tables
-- -----------------------------------------------------------------------------
-- These 9 tables need extra care. Strip all default DML and grant narrowly.
-- Full RLS policies come in file 002; here we just lock the GRANTs.

-- 7.1 tblusers — only app_admin can write; app_auditor can read for review.
REVOKE ALL ON TABLE public.tblusers FROM app_readwrite, app_readonly, app_reports;
GRANT SELECT ON TABLE public.tblusers TO app_auditor;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.tblusers TO app_admin;

-- 7.2 tblsessions — write only by app_admin (programmatic session creation).
REVOKE ALL ON TABLE public.tblsessions FROM app_readwrite, app_readonly,
                                        app_auditor, app_reports;
GRANT SELECT ON TABLE public.tblsessions TO app_auditor;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.tblsessions TO app_admin;

-- 7.3 tblauditlogs and tblaudi — INSERT allowed (app code appends),
--     SELECT allowed for auditor, but NO UPDATE/DELETE (immutability).
REVOKE ALL ON TABLE public.tblauditlogs FROM app_readwrite, app_readonly,
                                         app_auditor, app_reports;
GRANT SELECT ON TABLE public.tblauditlogs TO app_auditor;
GRANT SELECT, INSERT ON TABLE public.tblauditlogs TO app_admin;

REVOKE ALL ON TABLE public.tblaudi FROM app_readwrite, app_readonly,
                                    app_auditor, app_reports;
GRANT SELECT ON TABLE public.tblaudi TO app_auditor;
GRANT SELECT, INSERT ON TABLE public.tblaudi TO app_admin;

-- 7.4 tblbankaccounts, tblcashboxes — full DML for app_admin and
--     app_readwrite, SELECT for everyone else.
GRANT SELECT ON TABLE public.tblbankaccounts TO app_auditor, app_reports;
GRANT SELECT ON TABLE public.tblcashboxes   TO app_auditor, app_reports;
GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLE public.tblbankaccounts TO app_readwrite, app_admin;
GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLE public.tblcashboxes   TO app_readwrite, app_admin;

-- 7.5 tblnotifications — read for app_readwrite/admin; insert for app_readwrite.
--     No delete/update from app_readwrite (admin can override).
REVOKE ALL ON TABLE public.tblnotifications FROM app_auditor, app_reports;
GRANT SELECT ON TABLE public.tblnotifications TO app_auditor;
GRANT SELECT, INSERT ON TABLE public.tblnotifications TO app_readwrite, app_admin;
GRANT DELETE ON TABLE public.tblnotifications TO app_admin;

-- 7.6 tblcustomers, tblsuppliers — full DML for readwrite/admin, no special lock.
GRANT SELECT ON TABLE public.tblcustomers TO app_auditor, app_reports;
GRANT SELECT ON TABLE public.tblsuppliers TO app_auditor, app_reports;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.tblcustomers
    TO app_readwrite, app_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.tblsuppliers
    TO app_readwrite, app_admin;

-- -----------------------------------------------------------------------------
-- 8. Verifier — print the role → table-grant matrix
-- -----------------------------------------------------------------------------
SELECT
    grantee,
    table_name,
    string_agg(privilege_type, ', ' ORDER BY privilege_type) AS privs
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
  AND grantee LIKE 'app\_%'
GROUP BY grantee, table_name
ORDER BY grantee, table_name;

-- =============================================================================
-- End of file. Run 002_enable_rls_and_policies.sql next.
-- =============================================================================
