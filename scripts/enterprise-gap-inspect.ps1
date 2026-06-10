# enterprise-gap-inspect.ps1 - Inspect live DB for enterprise-grade gaps
$env:PGPASSWORD = '656650'
$Psql = 'C:\Program Files\PostgreSQL\17\bin\psql.exe'
$Db = 'IntegratedAccSys'

function Q([string]$Sql, [string]$Label) {
    Write-Host "--- $Label ---" -ForegroundColor Cyan
    & $Psql -h localhost -U postgres -d $Db -t -A -c $Sql 2>&1
    Write-Host ""
}

Write-Host "============================================" -ForegroundColor Yellow
Write-Host "  ENTERPRISE-GRADE GAP INSPECTION" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Yellow
Write-Host ""

# ============================================
# 1. ROLES AND PERMISSIONS
# ============================================
Write-Host "=== 1. ROLES AND PERMISSIONS ===" -ForegroundColor Green
Q "SELECT rolname, rolcanlogin, rolsuper, rolcreatedb FROM pg_roles WHERE rolname NOT LIKE 'pg_%' ORDER BY rolname;" "1.1 Custom Roles"
Q "SELECT COUNT(*) AS table_privileges FROM information_schema.role_table_grants WHERE grantee = 'PUBLIC';" "1.2 PUBLIC Privileges Count"
Q "SELECT table_schema, table_name, privilege_type FROM information_schema.role_table_grants WHERE grantee <> 'postgres' AND grantee <> 'PUBLIC' LIMIT 20;" "1.3 Non-default Privileges"
Q "SELECT COUNT(DISTINCT grantee) AS users_with_grants FROM information_schema.role_table_grants;" "1.4 Distinct Grantees"
Q "SELECT tablename, COUNT(*) AS policy_count FROM pg_policies WHERE schemaname = 'public' GROUP BY tablename;" "1.5 RLS Policies"

# ============================================
# 2. SECURITY
# ============================================
Write-Host "=== 2. SECURITY ===" -ForegroundColor Green
Q "SELECT extname, extversion FROM pg_extension WHERE extname IN ('pgaudit', 'pgsodium', 'pgcrypto', 'row_level_security', 'supabase_vault');" "2.1 Security Extensions"
Q "SELECT proname FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid WHERE n.nspname = 'public' AND proname ILIKE '%encrypt%' OR proname ILIKE '%decrypt%' OR proname ILIKE '%hash%' LIMIT 20;" "2.2 Encryption Functions"
Q "SELECT count(*) AS rls_enabled_tables FROM pg_tables t JOIN pg_class c ON c.relname = t.tablename WHERE t.schemaname = 'public' AND c.relrowsecurity = true;" "2.3 RLS-Enabled Tables"
Q "SELECT typname FROM pg_type WHERE typname IN ('pgcrypto.encrypt', 'pgcrypto.decrypt', 'pgcrypto.digest');" "2.4 pgcrypto Types"
Q "SELECT 'https_enabled:' || setting FROM pg_settings WHERE name = 'ssl';" "2.5 SSL Setting"

# ============================================
# 3. CONSTRAINTS
# ============================================
Write-Host "=== 3. CONSTRAINTS ===" -ForegroundColor Green
Q "SELECT conrelid::regclass AS tablename, contype, COUNT(*) AS cnt FROM pg_constraint c JOIN pg_namespace n ON c.connamespace = n.oid WHERE n.nspname = 'public' GROUP BY conrelid, contype ORDER BY conrelid, contype;" "3.1 Constraints by Type"
Q "SELECT conname, conrelid::regclass AS tablename FROM pg_constraint c JOIN pg_namespace n ON c.connamespace = n.oid WHERE n.nspname = 'public' AND contype = 'c' ORDER BY tablename;" "3.2 Check Constraints"
Q "SELECT conname, conrelid::regclass AS tablename, pg_get_triggerdef(c.oid) FROM pg_constraint c JOIN pg_namespace n ON c.connamespace = n.oid WHERE n.nspname = 'public' AND contype = 't' ORDER BY tablename;" "3.3 Triggers (FK/Check)"
Q "SELECT conname, conrelid::regclass AS tablename FROM pg_constraint c JOIN pg_namespace n ON c.connamespace = n.oid WHERE n.nspname = 'public' AND contype = 'x' ORDER BY tablename;" "3.4 Exclusion Constraints"
Q "SELECT COUNT(*) AS unique_constraints FROM pg_constraint c JOIN pg_namespace n ON c.connamespace = n.oid WHERE n.nspname = 'public' AND contype = 'u';" "3.5 Unique Constraints Count"
Q "SELECT COUNT(*) AS fk_constraints FROM pg_constraint c JOIN pg_namespace n ON c.connamespace = n.oid WHERE n.nspname = 'public' AND contype = 'f';" "3.6 FK Constraints Count"

# ============================================
# 4. INDEXES
# ============================================
Write-Host "=== 4. INDEXES ===" -ForegroundColor Green
Q "SELECT COUNT(*) AS total_indexes FROM pg_indexes WHERE schemaname = 'public';" "4.1 Total Indexes"
Q "SELECT t.tablename, COUNT(i.indexname) AS idx_count FROM pg_tables t LEFT JOIN pg_indexes i ON t.tablename = i.tablename AND t.schemaname = i.schemaname WHERE t.schemaname = 'public' GROUP BY t.tablename ORDER BY idx_count DESC LIMIT 20;" "4.2 Indexes per Table (top 20)"
Q "SELECT tablename, indexname, indexdef FROM pg_indexes WHERE schemaname = 'public' AND indexname NOT LIKE '%_pkey' AND indexname NOT LIKE '%_key' AND indexname NOT LIKE '%_fkey' ORDER BY tablename LIMIT 20;" "4.3 Non-PK/Unique/FK Indexes"
Q "SELECT COUNT(*) AS partial_indexes FROM pg_indexes i JOIN pg_class c ON c.relname = i.indexname WHERE i.schemaname = 'public' AND c.relpages > 0;" "4.4 Used Indexes"
Q "SELECT indexrelname, idx_scan, idx_tup_read, idx_tup_fetch FROM pg_stat_user_indexes WHERE schemaname = 'public' AND idx_scan = 0 ORDER BY indexrelname LIMIT 20;" "4.5 Unused Indexes"
Q "SELECT COUNT(*) AS composite_indexes FROM pg_indexes WHERE schemaname = 'public' AND indexdef LIKE '%(% ,%';" "4.6 Composite Indexes (approx)"

# ============================================
# 5. MATERIALIZED VIEWS
# ============================================
Write-Host "=== 5. MATERIALIZED VIEWS ===" -ForegroundColor Green
Q "SELECT matviewname, ispopulated FROM pg_matviews WHERE schemaname = 'public';" "5.1 Materialized Views"

# ============================================
# 6. PARTITIONING
# ============================================
Write-Host "=== 6. PARTITIONING ===" -ForegroundColor Green
Q "SELECT inhrelid::regclass AS partition FROM pg_inherits i JOIN pg_class c ON c.oid = i.inhparent WHERE c.relkind = 'r' AND c.relnamespace = 'public'::regnamespace LIMIT 20;" "6.1 Partitioned Tables"
Q "SELECT partstrat, COUNT(*) FROM pg_partitioned_table GROUP BY partstrat;" "6.2 Partition Strategies"

# ============================================
# 7. MONITORING
# ============================================
Write-Host "=== 7. MONITORING ===" -ForegroundColor Green
Q "SELECT extname FROM pg_extension WHERE extname IN ('pg_stat_statements', 'auto_explain', 'pg_stat_monitor', 'pgaudit');" "7.1 Monitoring Extensions"
Q "SELECT relname, seq_scan, seq_tup_read, idx_scan, idx_tup_fetch, n_live_tup, n_dead_tup FROM pg_stat_user_tables WHERE schemaname = 'public' ORDER BY n_live_tup DESC LIMIT 20;" "7.2 Table Statistics (top 20)"
Q "SELECT COUNT(*) AS monitored_tables FROM pg_stat_user_tables WHERE schemaname = 'public';" "7.3 Tables with Statistics"
Q "SELECT 'autovacuum:' || setting FROM pg_settings WHERE name = 'autovacuum';" "7.4 Autovacuum Setting"
Q "SELECT 'log_min_duration:' || setting FROM pg_settings WHERE name = 'log_min_duration_statement';" "7.5 Slow Query Log Setting"

# ============================================
# 8. MAINTENANCE
# ============================================
Write-Host "=== 8. MAINTENANCE ===" -ForegroundColor Green
Q "SELECT jobname, schedule FROM cron.job;" "8.1 Scheduled Jobs (pg_cron)"
Q "SELECT 'autovacuum_vacuum_scale_factor:' || setting FROM pg_settings WHERE name = 'autovacuum_vacuum_scale_factor';" "8.2 Autovacuum Scale Factor"
Q "SELECT 'autovacuum_analyze_scale_factor:' || setting FROM pg_settings WHERE name = 'autovacuum_analyze_scale_factor';" "8.3 Autovacuum Analyze Scale"
Q "SELECT relname, last_vacuum, last_autovacuum, last_analyze, last_autoanalyze FROM pg_stat_user_tables WHERE schemaname = 'public' AND (last_vacuum IS NULL OR last_vacuum < NOW() - INTERVAL '30 days') ORDER BY last_vacuum NULLS FIRST LIMIT 20;" "8.4 Tables Not Vacuumed Recently"

# ============================================
# 9. ARCHIVING
# ============================================
Write-Host "=== 9. ARCHIVING ===" -ForegroundColor Green
Q "SELECT schemaname, tablename, size, size_pretty FROM (SELECT n.nspname AS schemaname, c.relname AS tablename, pg_total_relation_size(c.oid) AS size, pg_size_pretty(pg_total_relation_size(c.oid)) AS size_pretty FROM pg_class c JOIN pg_namespace n ON c.relnamespace = n.oid WHERE n.nspname = 'public' AND c.relkind = 'r') sub ORDER BY size DESC LIMIT 20;" "9.1 Largest Tables (archiving candidates)"
Q "SELECT tablename, attname FROM pg_stats WHERE schemaname = 'public' AND null_frac > 0.5 ORDER BY null_frac DESC LIMIT 10;" "9.2 Columns with >50% NULLs (archival candidates)"
Q "SELECT 'pg_partman:' || extversion FROM pg_extension WHERE extname = 'pg_partman';" "9.3 pg_partman Extension"
Q "SELECT 'pg_cron:' || extversion FROM pg_extension WHERE extname = 'pg_cron';" "9.4 pg_cron Extension"

# ============================================
# 10. NUMBERING CONTROLS
# ============================================
Write-Host "=== 10. NUMBERING CONTROLS ===" -ForegroundColor Green
Q "SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND (tablename LIKE '%sequence%' OR tablename LIKE '%number%' OR tablename LIKE '%counter%' OR tablename LIKE '%serial%');" "10.1 Sequence Tables"
Q "SELECT sequence_name, last_value, increment_by FROM information_schema.sequences WHERE sequence_schema = 'public' ORDER BY sequence_name LIMIT 20;" "10.2 Sequence Catalog"
Q "SELECT 'nextval_funcs:' || COUNT(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid WHERE n.nspname = 'public' AND proname ILIKE '%nextval%' OR proname ILIKE '%getno%' OR proname ILIKE '%newno%';" "10.3 Next-Number Functions"
Q "SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND (tablename LIKE '%no%' OR tablename LIKE '%numbering%');" "10.4 Numbering Tables"

# ============================================
# 11. APPROVAL WORKFLOWS
# ============================================
Write-Host "=== 11. APPROVAL WORKFLOWS ===" -ForegroundColor Green
Q "SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND (tablename LIKE '%approval%' OR tablename LIKE '%workflow%' OR tablename LIKE '%request%');" "11.1 Approval Tables"
Q "SELECT column_name, data_type FROM information_schema.columns WHERE table_schema = 'public' AND (column_name LIKE '%approv%' OR column_name LIKE '%workflow%' OR column_name LIKE '%review%');" "11.2 Approval Columns"
Q "SELECT 'isapproved' AS col_pattern, COUNT(*) FROM information_schema.columns WHERE table_schema = 'public' AND column_name ILIKE '%approved%' UNION ALL SELECT 'isposted', COUNT(*) FROM information_schema.columns WHERE table_schema = 'public' AND column_name ILIKE '%posted%';" "11.3 Approval Field Counts"

# ============================================
# 12. COST CENTERS AND DIMENSIONS
# ============================================
Write-Host "=== 12. COST CENTERS AND DIMENSIONS ===" -ForegroundColor Green
Q "SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND (tablename LIKE '%costcenter%' OR tablename LIKE '%cost_center%' OR tablename LIKE '%dimension%' OR tablename LIKE '%segment%');" "12.1 Cost Center Tables"
Q "SELECT column_name, table_name FROM information_schema.columns WHERE table_schema = 'public' AND column_name ILIKE '%costcenter%' OR column_name ILIKE '%dimension%';" "12.2 Cost Center Columns"
Q "SELECT tablename, column_name, data_type FROM information_schema.columns WHERE table_schema = 'public' AND column_name IN ('costcenterid', 'department', 'projectcode', 'segmentcode') ORDER BY tablename;" "12.3 Cost-Dimension Columns"

# ============================================
# 13. CLOSING CONTROLS
# ============================================
Write-Host "=== 13. CLOSING CONTROLS ===" -ForegroundColor Green
Q "SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND (tablename LIKE '%closing%' OR tablename LIKE '%period%' OR tablename LIKE '%fiscal%' OR tablename LIKE '%year%');" "13.1 Closing Tables"
Q "SELECT column_name, table_name, data_type FROM information_schema.columns WHERE table_schema = 'public' AND (column_name ILIKE '%isclosed%' OR column_name ILIKE '%closedat%' OR column_name ILIKE '%closedby%' OR column_name ILIKE '%iscancelled%' OR column_name ILIKE '%postedat%' OR column_name ILIKE '%postedby%') ORDER BY table_name;" "13.2 Closing/Posting Columns"
Q "SELECT 'isclosed_count:' || COUNT(*) FROM information_schema.columns WHERE table_schema = 'public' AND column_name = 'isclosed';" "13.3 isclosed Field Count"

# ============================================
# 14. DATABASE GOVERNANCE
# ============================================
Write-Host "=== 14. DATABASE GOVERNANCE ===" -ForegroundColor Green
Q "SELECT 'current_user:' || current_user;" "14.1 Current User"
Q "SELECT 'current_database:' || current_database();" "14.2 Current Database"
Q "SELECT 'version:' || version();" "14.3 Version"
Q "SELECT 'search_path:' || current_setting('search_path');" "14.4 Search Path"
Q "SELECT 'timezone:' || current_setting('TIMEZONE');" "14.5 Timezone"
Q "SELECT 'lc_collate:' || datcollate, 'lc_ctype:' || datctype FROM pg_database WHERE datname = current_database();" "14.6 Locale"
Q "SELECT extname, extversion FROM pg_extension ORDER BY extname;" "14.7 Installed Extensions"
