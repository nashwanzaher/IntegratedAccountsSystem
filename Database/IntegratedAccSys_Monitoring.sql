-- =====================================================================
-- IntegratedAccSys — Monitoring Baseline (Gap #3)
-- =====================================================================
-- Date        : 2026-06-10
-- Branch      : feat/gap-3-monitoring-extensions
-- Author      : GitHub Copilot (MiniMax-M3)
--
-- Closes the IMMEDIATE-ACTION items of ENTERPRISE_GAP_ANALYSIS §2.7
-- (Monitoring) that do NOT require a PostgreSQL service restart.
-- Restart-required items (activation of pg_stat_statements tracking,
-- auto_explain, track_io_timing) are appended to
-- `database/postgresql.conf.snippet` and applied by the DBA separately.
--
-- Deliverables in this file:
--   1. pgstattuple extension (table/index bloat analysis).
--   2. 7 monitoring views:
--        vw_slow_queries        — top slow queries (pg_stat_statements)
--        vw_index_usage         — seq_scan vs idx_scan per table
--        vw_unused_indexes      — indexes with idx_scan = 0
--        vw_most_seq_scanned    — tables with high seq_scan ratio
--        vw_active_sessions     — current activity with duration
--        vw_long_running_queries — sessions running > 30s
--        vw_db_size_summary     — DB + top-10 table sizes
--   3. 2 helper functions:
--        fn_get_slow_queries(min_ms, max_rows)
--        fn_suggest_indexes() — quick win index recommendations
--   4. Grants for the 6 app_* roles (read-only on all views).
--   5. Idempotency fingerprint fn_g3_monitoring_signature().
--
-- Out of scope (requires postgresql.conf + restart, see snippet):
--   - pg_stat_statements active tracking (shared_preload_libraries)
--   - auto_explain extension (NOT available on this PG build)
--   - pg_cron extension (NOT available on this PG build)
--   - track_io_timing = on (I/O timing accuracy)
-- =====================================================================

-- IMPORTANT: this file does NOT use BEGIN/COMMIT because some
-- statements (e.g. CREATE EXTENSION when privileged, ALTER SYSTEM
-- in updates) cannot run inside a transaction block. The file is
-- idempotent — re-running is safe.

-- ---------------------------------------------------------------------
-- 1. pgstattuple — table/index bloat analysis
-- ---------------------------------------------------------------------
-- Lets us measure dead-tuple ratio and average row length for any
-- table/index. Critical for vacuum scheduling.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pgstattuple') THEN
        CREATE EXTENSION pgstattuple;
        RAISE NOTICE '[OK] pgstattuple installed.';
    ELSE
        RAISE NOTICE '[..] pgstattuple already installed.';
    END IF;
END
$$;

-- ---------------------------------------------------------------------
-- 2. Monitoring views
-- ---------------------------------------------------------------------

-- 2.1 vw_slow_queries
--     Top slow queries (mean_time > min_ms) from pg_stat_statements.
--     pg_stat_statements must be in shared_preload_libraries AND
--     the database restarted for this view to be useful. The view
--     itself can be created now (no restart needed for the view).
--     Note: pg_stat_statements has no `dbname` column; JOIN with
--     pg_database via dbid to resolve it.
CREATE OR REPLACE VIEW public.vw_slow_queries AS
SELECT
    substring(s.query, 1, 200)                                 AS query_snippet,
    s.calls                                                    AS call_count,
    round((s.total_exec_time / 1000.0)::numeric, 2)            AS total_time_s,
    round((s.mean_exec_time)::numeric, 2)                      AS mean_time_ms,
    round((s.max_exec_time)::numeric, 2)                       AS max_time_ms,
    s.rows                                                     AS total_rows,
    s.shared_blks_hit + s.shared_blks_read                     AS total_blocks,
    d.datname                                                  AS database
FROM pg_stat_statements s
LEFT JOIN pg_database d ON d.oid = s.dbid
WHERE s.calls > 0
ORDER BY s.mean_exec_time DESC;

-- 2.2 vw_index_usage
--     Per-table index usage ratio. A high seq_scan count on a
--     large table = missing index candidate.
CREATE OR REPLACE VIEW public.vw_index_usage AS
SELECT
    s.schemaname || '.' || s.relname                           AS table_name,
    s.seq_scan                                                 AS sequential_scans,
    s.seq_tup_read                                              AS rows_from_seq_scan,
    s.idx_scan                                                  AS index_scans,
    s.idx_tup_fetch                                             AS rows_from_idx_scan,
    CASE
        WHEN s.seq_scan + s.idx_scan = 0 THEN NULL
        ELSE round((s.idx_scan::numeric /
                   NULLIF(s.seq_scan + s.idx_scan, 0)) * 100, 2)
    END                                                        AS index_scan_pct,
    pg_size_pretty(pg_relation_size(s.relid))                  AS table_size
FROM pg_stat_user_tables s
ORDER BY s.seq_scan DESC;

-- 2.3 vw_unused_indexes
--     Indexes that have never been used (idx_scan = 0).
--     Candidates for DROP INDEX (saves write overhead + space).
CREATE OR REPLACE VIEW public.vw_unused_indexes AS
SELECT
    s.schemaname || '.' || s.relname                           AS table_name,
    s.indexrelname                                              AS index_name,
    s.idx_scan                                                  AS total_scans,
    pg_size_pretty(pg_relation_size(s.indexrelid))             AS index_size,
    pg_relation_size(s.indexrelid)                             AS index_size_bytes
FROM pg_stat_user_indexes s
WHERE s.idx_scan = 0
  AND s.indexrelname NOT LIKE '%_pkey'  -- keep PKs always
ORDER BY pg_relation_size(s.indexrelid) DESC;

-- 2.4 vw_most_seq_scanned
--     Tables with the highest absolute seq_scan count.
--     These are the strongest candidates for new indexes.
CREATE OR REPLACE VIEW public.vw_most_seq_scanned AS
SELECT
    s.schemaname || '.' || s.relname                           AS table_name,
    s.seq_scan                                                 AS seq_scan_count,
    s.idx_scan                                                  AS idx_scan_count,
    CASE
        WHEN s.seq_scan + s.idx_scan = 0 THEN 0
        ELSE round((s.seq_scan::numeric /
                   NULLIF(s.seq_scan + s.idx_scan, 0)) * 100, 2)
    END                                                        AS seq_scan_pct,
    s.n_live_tup                                               AS approx_row_count,
    pg_size_pretty(pg_relation_size(s.relid))                  AS table_size
FROM pg_stat_user_tables s
WHERE s.seq_scan > 100   -- ignore low-traffic tables
ORDER BY s.seq_scan DESC
LIMIT 50;

-- 2.5 vw_active_sessions
--     Current activity with human-readable duration and statement snippet.
CREATE OR REPLACE VIEW public.vw_active_sessions AS
SELECT
    pid                                                        AS session_id,
    usename                                                    AS db_user,
    application_name                                           AS app,
    client_addr                                                AS client_ip,
    state                                                      AS session_state,
    wait_event_type || COALESCE(':' || wait_event, '')         AS waiting_on,
    substring(query, 1, 200)                                   AS current_query,
    EXTRACT(EPOCH FROM (now() - query_start))::int             AS query_duration_s,
    EXTRACT(EPOCH FROM (now() - xact_start))::int              AS txn_duration_s,
    backend_start                                              AS connected_at
FROM pg_stat_activity
WHERE backend_type = 'client backend'
  AND pid <> pg_backend_pid()    -- exclude self
ORDER BY query_start NULLS LAST;

-- 2.6 vw_long_running_queries
--     Sessions whose current query has been running > 30 seconds.
--     Useful for catching runaway queries / missing indexes.
CREATE OR REPLACE VIEW public.vw_long_running_queries AS
SELECT
    pid                                                        AS session_id,
    usename                                                    AS db_user,
    application_name                                           AS app,
    client_addr                                                AS client_ip,
    substring(query, 1, 300)                                   AS current_query,
    EXTRACT(EPOCH FROM (now() - query_start))::int             AS duration_s,
    state                                                      AS session_state
FROM pg_stat_activity
WHERE backend_type = 'client backend'
  AND state = 'active'
  AND query_start IS NOT NULL
  AND now() - query_start > interval '30 seconds'
  AND pid <> pg_backend_pid()
ORDER BY query_start ASC;

-- 2.7 vw_db_size_summary
--     Top-10 largest tables in the public schema.
CREATE OR REPLACE VIEW public.vw_db_size_summary AS
SELECT
    schemaname || '.' || tablename                             AS table_name,
    pg_total_relation_size(schemaname || '.' || tablename)     AS total_bytes,
    pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename))
                                                              AS total_size,
    pg_relation_size(schemaname || '.' || tablename)          AS table_bytes,
    pg_size_pretty(pg_relation_size(schemaname || '.' || tablename))
                                                              AS table_size,
    pg_total_relation_size(schemaname || '.' || tablename)
        - pg_relation_size(schemaname || '.' || tablename)    AS index_bytes,
    pg_size_pretty(
        pg_total_relation_size(schemaname || '.' || tablename)
        - pg_relation_size(schemaname || '.' || tablename))    AS index_size,
    (SELECT n_live_tup FROM pg_stat_user_tables
       WHERE schemaname = t.schemaname AND relname = t.tablename)
                                                              AS approx_row_count
FROM pg_tables t
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname || '.' || tablename) DESC
LIMIT 20;

-- ---------------------------------------------------------------------
-- 3. Helper functions
-- ---------------------------------------------------------------------

-- 3.1 fn_get_slow_queries
--     Parameterised slow-query lookup. Returns rows where
--     mean_exec_time > min_ms, ordered by mean time desc.
CREATE OR REPLACE FUNCTION public.fn_get_slow_queries(
    min_ms    int  DEFAULT 1000,
    max_rows  int  DEFAULT 50
)
RETURNS TABLE (
    query_snippet  text,
    call_count     bigint,
    mean_time_ms   numeric,
    max_time_ms    numeric,
    total_time_s   numeric,
    total_rows     bigint
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        substring(s.query, 1, 200)                                  AS query_snippet,
        s.calls                                                     AS call_count,
        round(s.mean_exec_time::numeric, 2)                         AS mean_time_ms,
        round(s.max_exec_time::numeric, 2)                          AS max_time_ms,
        round((s.total_exec_time / 1000.0)::numeric, 2)             AS total_time_s,
        s.rows                                                      AS total_rows
    FROM pg_stat_statements s
    WHERE s.calls > 0
      AND s.mean_exec_time >= min_ms
    ORDER BY s.mean_exec_time DESC
    LIMIT max_rows;
$$;

-- 3.2 fn_suggest_indexes
--     Returns a quick-win list: tables with > 1000 seq_scans that
--     have < 50% index_scan ratio. These are the strongest
--     candidates for new composite / partial indexes.
CREATE OR REPLACE FUNCTION public.fn_suggest_indexes(
    min_seq_scans   bigint DEFAULT 1000,
    max_idx_pct     numeric DEFAULT 50.0
)
RETURNS TABLE (
    table_name             text,
    seq_scan_count         bigint,
    idx_scan_count         bigint,
    index_scan_pct         numeric,
    approx_row_count       bigint,
    table_size             text,
    recommendation         text
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        s.schemaname || '.' || s.relname,
        s.seq_scan,
        s.idx_scan,
        CASE
            WHEN s.seq_scan + s.idx_scan = 0 THEN 0
            ELSE round((s.idx_scan::numeric /
                       NULLIF(s.seq_scan + s.idx_scan, 0)) * 100, 2)
        END,
        s.n_live_tup,
        pg_size_pretty(pg_relation_size(s.relid)),
        'Consider adding a composite or partial index on the most-filtered columns'
    FROM pg_stat_user_tables s
    WHERE s.seq_scan >= min_seq_scans
      AND (
            s.seq_scan + s.idx_scan = 0
            OR (s.idx_scan::numeric / NULLIF(s.seq_scan + s.idx_scan, 0)) * 100 < max_idx_pct
          )
    ORDER BY s.seq_scan DESC
    LIMIT 30;
$$;

-- ---------------------------------------------------------------------
-- 4. Grants for app_* roles (read-only on the views)
-- ---------------------------------------------------------------------
DO $$
DECLARE r record;
BEGIN
    FOR r IN
        SELECT rolname FROM pg_roles WHERE rolname LIKE 'app\_%' ESCAPE '\'
    LOOP
        EXECUTE format('GRANT SELECT ON public.vw_slow_queries       TO %I', r.rolname);
        EXECUTE format('GRANT SELECT ON public.vw_index_usage        TO %I', r.rolname);
        EXECUTE format('GRANT SELECT ON public.vw_unused_indexes     TO %I', r.rolname);
        EXECUTE format('GRANT SELECT ON public.vw_most_seq_scanned   TO %I', r.rolname);
        EXECUTE format('GRANT SELECT ON public.vw_active_sessions    TO %I', r.rolname);
        EXECUTE format('GRANT SELECT ON public.vw_long_running_queries TO %I', r.rolname);
        EXECUTE format('GRANT SELECT ON public.vw_db_size_summary    TO %I', r.rolname);
        EXECUTE format('GRANT EXECUTE ON FUNCTION public.fn_get_slow_queries(int, int) TO %I', r.rolname);
        EXECUTE format('GRANT EXECUTE ON FUNCTION public.fn_suggest_indexes(bigint, numeric) TO %I', r.rolname);
    END LOOP;
END
$$;

-- ---------------------------------------------------------------------
-- 5. Idempotency signature (for audit-g3-monitoring.ps1)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_g3_monitoring_signature()
RETURNS text
LANGUAGE sql
IMMUTABLE
AS $$ SELECT 'GAP3-MONITORING-2026-06-10-v1'::text $$;

GRANT EXECUTE ON FUNCTION public.fn_g3_monitoring_signature() TO PUBLIC;

-- =====================================================================
-- End of IntegratedAccSys_Monitoring.sql
-- =====================================================================
