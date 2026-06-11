-- ============================================================================
-- Migration: Drop 3 legacy auth procedures (duplicates of modern equivalents)
-- Date     : 2026-06-11
-- Auditor  : DEEP_ARCHITECTURE_DATABASE_AUDIT.md §7.2
-- Rationale:
--   * sp_login           -> duplicate of getUserForLogin()   (C# uses modern)
--   * sp_logout          -> duplicate of endSession()        (C# uses modern)
--   * sp_validatesession -> duplicate of validateSession()   (C# uses modern)
--   * 0 dependencies in DB (pg_depend verified)
--   * 0 calls from C# (grep across src/ verified)
--   * Live audit found them in the "orphan procedures" list
-- Pre-backup: database/migrations/pre_cleanup_<TS>.sql
-- ============================================================================

BEGIN;

\echo '=== 1) Pre-drop verification ==='
SELECT proname FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid
WHERE n.nspname='public' AND p.proname IN ('sp_login','sp_logout','sp_validatesession')
ORDER BY proname;

\echo
\echo '=== 2) Drop sp_login ==='
DROP PROCEDURE IF EXISTS public.sp_login(IN p_user_id character varying, IN p_password character varying, IN p_computer_name character varying, IN p_ip_address character varying);

\echo
\echo '=== 3) Drop sp_logout ==='
DROP PROCEDURE IF EXISTS public.sp_logout(IN p_token uuid);

\echo
\echo '=== 4) Drop sp_validatesession ==='
DROP PROCEDURE IF EXISTS public.sp_validatesession(IN p_token uuid, OUT o_is_valid boolean, OUT o_user_code integer, OUT o_user_name character varying, OUT o_is_admin boolean);

\echo
\echo '=== 5) Post-drop verification (should be empty) ==='
SELECT proname FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid
WHERE n.nspname='public' AND p.proname IN ('sp_login','sp_logout','sp_validatesession')
ORDER BY proname;

\echo
\echo '=== 6) Confirm modern equivalents still exist ==='
SELECT proname FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid
WHERE n.nspname='public' AND p.proname IN ('getuserforlogin','endsession','validatesession')
ORDER BY proname;

COMMIT;

\echo
\echo '=== Migration complete: 3 legacy procedures dropped. ==='
