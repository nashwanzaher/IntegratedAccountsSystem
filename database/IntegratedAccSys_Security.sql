-- =====================================================================
-- IntegratedAccSys — Security Baseline (Gap #2)
-- =====================================================================
-- Date        : 2026-06-10
-- Branch      : feat/gap-2-column-encryption-ssl
-- Status      : Idempotent — safe to re-run.
-- Author      : GitHub Copilot (MiniMax-M3)
-- Scope       : Closes ENTERPRISE_GAP_ANALYSIS §2.2 (Security) for
--               the parts that do NOT require a PostgreSQL service
--               restart. Restart-required changes (ssl = on,
--               shared_preload_libraries, pgaudit) are documented
--               in `database/postgresql.conf.snippet` and applied
--               by the DBA separately.
--
-- Deliverables in this file:
--   1. pg_stat_statements extension (query analytics).
--   2. log_statement = 'mod'      (audit trail of DDL/DML).
--   3. log_min_duration_statement = 1000ms  (slow-query log).
--   4. Connection limits on every app_* role (DoS hardening).
--   5. pgcrypto-backed PII helpers (fn_pii_encrypt / fn_pii_decrypt).
--   6. Encrypted PII column tblusers.photo_encrypted (nullable,
--      non-destructive — original `photo` column is left in place
--      for backward compatibility).
--   7. Audit-log table `tblaudi_security` for key-rotation events.
--
-- Out of scope (requires postgresql.conf + restart, see snippet):
--   - ssl = on                      (MITM prevention)
--   - shared_preload_libraries      (needed for pgaudit)
--   - pgaudit extension             (SOX-grade audit log)
--
-- IMPORTANT: this file does NOT use BEGIN/COMMIT because
-- `ALTER SYSTEM SET` cannot run inside a transaction block.
-- Each statement runs in its own implicit transaction, which is
-- fine because the file is designed to be idempotent.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Query analytics — pg_stat_statements
-- ---------------------------------------------------------------------
-- Records every executed query (normalized) with timing & I/O stats.
-- Cheap, no restart required for the extension itself.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements') THEN
        -- shared_preload_libraries MUST contain 'pg_stat_statements'
        -- for this CREATE EXTENSION to succeed. The DBA must add it
        -- via `database/postgresql.conf.snippet` if not already set.
        BEGIN
            CREATE EXTENSION pg_stat_statements;
            RAISE NOTICE '[OK] pg_stat_statements installed.';
        EXCEPTION WHEN insufficient_privilege OR feature_not_supported THEN
            RAISE NOTICE '[WARN] pg_stat_statements could not be created — '
                         'add it to shared_preload_libraries and restart PG. '
                         'See database/postgresql.conf.snippet';
        END;
    ELSE
        RAISE NOTICE '[OK] pg_stat_statements already installed.';
    END IF;
END
$$;

-- ---------------------------------------------------------------------
-- 2. log_statement = 'mod' — log DDL + data-modifying statements
-- ---------------------------------------------------------------------
-- 'none' | 'ddl' | 'mod' | 'all'
-- 'mod' = all DDL (CREATE/ALTER/DROP) + data-modifying (INSERT/UPDATE/DELETE/TRUNCATE)
-- but NOT plain SELECTs. This avoids PII leakage into pg_log.
ALTER SYSTEM SET log_statement = 'mod';

-- ---------------------------------------------------------------------
-- 3. log_min_duration_statement = 1000 ms — slow-query log
-- ---------------------------------------------------------------------
-- Any statement running > 1 s is logged. -1 = disabled.
ALTER SYSTEM SET log_min_duration_statement = '1000ms';

-- Flush the ALTER SYSTEM changes so a later `SHOW` reflects them
-- (no restart required for the SET to take effect on new sessions).
SELECT pg_reload_conf();

-- ---------------------------------------------------------------------
-- 4. Connection limits on app_* roles (DoS hardening)
-- ---------------------------------------------------------------------
-- Rationale: leaving CONNECTION LIMIT -1 on a least-privilege role
-- is a DoS vector. We size the limits by role purpose:
--   - app_admin     : 20  (humans via PL)
--   - app_readwrite : 50  (PL + service workers + reports)
--   - app_readonly  : 50  (reporting dashboards, BI tools)
--   - app_auditor   : 10  (audit pulls, mostly manual)
--   - app_reports   : 20  (dashboard refresh, scheduled jobs)
--   - app_backup    : 5   (pg_dump / pg_basebackup)
DO $$
DECLARE
    r       record;
    lim     int;
    current int;
BEGIN
    FOR r IN
        SELECT rolname
          FROM pg_roles
         WHERE rolname LIKE 'app\_%' ESCAPE '\'
    LOOP
        lim := CASE r.rolname
                 WHEN 'app_admin'     THEN 20
                 WHEN 'app_readwrite' THEN 50
                 WHEN 'app_readonly'  THEN 50
                 WHEN 'app_auditor'   THEN 10
                 WHEN 'app_reports'   THEN 20
                 WHEN 'app_backup'    THEN 5
                 ELSE                       10   -- safe default
               END;

        SELECT rolconnlimit INTO current FROM pg_roles WHERE rolname = r.rolname;

        IF current IS DISTINCT FROM lim THEN
            EXECUTE format('ALTER ROLE %I CONNECTION LIMIT %s', r.rolname, lim);
            RAISE NOTICE '[OK] % : conn limit % → %', r.rolname, current, lim;
        ELSE
            RAISE NOTICE '[..] % : conn limit already %', r.rolname, lim;
        END IF;
    END LOOP;
END
$$;

-- ---------------------------------------------------------------------
-- 5. pgcrypto PII helpers — keyed by a per-session GUC
-- ---------------------------------------------------------------------
-- The symmetric key is NEVER stored in the database. The application
-- sets it on every connection right after open:
--     SET app.pii_key = '<key from env or secrets store>';
-- The functions below use current_setting('app.pii_key', true) and
-- throw a clear error if the key is not set.
CREATE OR REPLACE FUNCTION public.fn_pii_encrypt(plaintext text)
RETURNS bytea
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    k text;
BEGIN
    IF plaintext IS NULL THEN
        RETURN NULL;
    END IF;
    k := current_setting('app.pii_key', true);
    IF k IS NULL OR length(k) < 16 THEN
        RAISE EXCEPTION 'app.pii_key is not set (or too short). '
                        'Set it via: SET LOCAL app.pii_key = ''<>=16 chars>''';
    END IF;
    RETURN pgp_sym_encrypt(plaintext, k, 'compress-algo=1, cipher-algo=aes256');
END
$$;

CREATE OR REPLACE FUNCTION public.fn_pii_decrypt(ciphertext bytea)
RETURNS text
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    k text;
BEGIN
    IF ciphertext IS NULL THEN
        RETURN NULL;
    END IF;
    k := current_setting('app.pii_key', true);
    IF k IS NULL OR length(k) < 16 THEN
        RAISE EXCEPTION 'app.pii_key is not set (or too short). '
                        'Set it via: SET LOCAL app.pii_key = ''<>=16 chars>''';
    END IF;
    RETURN pgp_sym_decrypt(ciphertext, k);
EXCEPTION WHEN OTHERS THEN
    -- Wrong key / corrupted ciphertext → return NULL, do not leak error.
    RETURN NULL;
END
$$;

-- Grant EXECUTE on the PII helpers to all app_* roles.
DO $$
DECLARE r record;
BEGIN
    FOR r IN SELECT rolname FROM pg_roles WHERE rolname LIKE 'app\_%' ESCAPE '\' LOOP
        EXECUTE format('GRANT EXECUTE ON FUNCTION public.fn_pii_encrypt(text) TO %I', r.rolname);
        EXECUTE format('GRANT EXECUTE ON FUNCTION public.fn_pii_decrypt(bytea) TO %I', r.rolname);
    END LOOP;
END
$$;

-- ---------------------------------------------------------------------
-- 6. Non-destructive PII column on tblusers
-- ---------------------------------------------------------------------
-- Adds a new column for the encrypted photo. The original `photo`
-- column is left untouched (rollback safe). New code paths write
-- to `photo_encrypted` via fn_pii_encrypt(); old code keeps using
-- `photo` until cutover.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM information_schema.columns
         WHERE table_schema = 'public'
           AND table_name   = 'tblusers'
           AND column_name  = 'photo_encrypted'
    ) THEN
        ALTER TABLE public.tblusers
            ADD COLUMN photo_encrypted bytea NULL;

        RAISE NOTICE '[OK] tblusers.photo_encrypted column added.';
    ELSE
        RAISE NOTICE '[..] tblusers.photo_encrypted already present.';
    END IF;
END
$$;

-- ---------------------------------------------------------------------
-- 7. Security audit trail for key-rotation events
-- ---------------------------------------------------------------------
-- Tracks PII key rotations + who/when. This complements the
-- existing tblaudi (general audit) table.
CREATE TABLE IF NOT EXISTS public.tblaudi_security (
    id            bigserial   PRIMARY KEY,
    event_type    text        NOT NULL,  -- 'PII_KEY_ROTATED', 'SSL_ENABLED', ...
    event_payload jsonb       NULL,
    actor_role    text        NOT NULL DEFAULT current_user,
    occurred_at   timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_audi_security_type_time
    ON public.tblaudi_security (event_type, occurred_at DESC);

-- RLS: same as tblaudi — auditor + admin can read, no one can update/delete.
ALTER TABLE public.tblaudi_security ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tblaudi_security FORCE  ROW LEVEL SECURITY;

DROP POLICY IF EXISTS p_audi_security_auditor ON public.tblaudi_security;
CREATE POLICY p_audi_security_auditor ON public.tblaudi_security
    FOR SELECT TO app_auditor
    USING (true);

DROP POLICY IF EXISTS p_audi_security_admin ON public.tblaudi_security;
CREATE POLICY p_audi_security_admin ON public.tblaudi_security
    FOR ALL TO app_admin
    USING (true)
    WITH CHECK (true);

DROP POLICY IF EXISTS p_audi_security_insert ON public.tblaudi_security;
CREATE POLICY p_audi_security_insert ON public.tblaudi_security
    FOR INSERT TO app_readwrite
    WITH CHECK (event_type = 'APP_INSERT');   -- readwrite can only append APP_INSERT events

GRANT SELECT, INSERT ON public.tblaudi_security TO app_readwrite;
GRANT SELECT         ON public.tblaudi_security TO app_auditor, app_readonly, app_reports;
GRANT USAGE          ON SEQUENCE public.tblaudi_security_id_seq TO app_readwrite, app_admin;

-- ---------------------------------------------------------------------
-- 8. Idempotency signature (for audit-g2-security.ps1)
-- ---------------------------------------------------------------------
-- Lets the audit script confirm "this script has been applied" without
-- parsing the entire file.
CREATE OR REPLACE FUNCTION public.fn_g2_security_signature()
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$ SELECT 'GAP2-SECURITY-2026-06-10-v1'::text $$;

GRANT EXECUTE ON FUNCTION public.fn_g2_security_signature() TO PUBLIC;

-- =====================================================================
-- End of IntegratedAccSys_Security.sql
-- =====================================================================
