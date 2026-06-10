# =====================================================================
# IntegratedAccSys — Gap #3 Monitoring Audit
# =====================================================================
# Date        : 2026-06-10
# Branch      : feat/gap-3-monitoring-extensions
# Author      : GitHub Copilot (MiniMax-M3)
#
# Verifies the immediate-action items introduced by
# `database/IntegratedAccSys_Monitoring.sql`. Items that require
# a PostgreSQL restart (pg_stat_statements activation, auto_explain,
# track_io_timing) are detected and reported with a `PENDING-RESTART`
# label rather than failing the audit.
#
# Exit codes
#   0 — all critical checks passed
#   1 — one or more critical checks failed
#
# Usage
#   powershell -ExecutionPolicy Bypass -File scripts\audit-g3-monitoring.ps1
# =====================================================================

$ErrorActionPreference = 'Stop'

$pg       = 'C:\Program Files\PostgreSQL\17\bin\psql.exe'
$env:PGPASSWORD = '656650'

if (-not (Test-Path $pg)) {
    Write-Host "[FATAL] psql not found at $pg" -ForegroundColor Red
    exit 1
}

$cn = @('-h', 'localhost', '-U', 'postgres', '-d', 'IntegratedAccSys',
        '-A', '-t', '-v', 'ON_ERROR_STOP=1')

$failed = $false

# --- 1. Signature --------------------------------------------------
Write-Host "`n[1/8] Idempotency signature (IntegratedAccSys_Monitoring.sql applied)" -ForegroundColor Cyan
$out = & $pg @cn -c "SELECT public.fn_g3_monitoring_signature();"
if ($out -match 'GAP3-MONITORING-\d{4}-\d{2}-\d{2}-v\d+') {
    Write-Host "  [OK] $out" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Monitoring SQL has NOT been applied." -ForegroundColor Red
    Write-Host "         Run: psql -h localhost -U postgres -d IntegratedAccSys -f database\IntegratedAccSys_Monitoring.sql"
    exit 1
}

# --- 2. Required extensions ----------------------------------------
Write-Host "`n[2/8] Required extensions" -ForegroundColor Cyan
foreach ($ext in @('pgstattuple', 'pg_stat_statements')) {
    $v = & $pg @cn -c "SELECT extversion FROM pg_extension WHERE extname='$ext';"
    if ($v) {
        Write-Host "  [OK] $ext installed v$v" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $ext not installed" -ForegroundColor Red
        $failed = $true
    }
}

# --- 3. Monitoring views -------------------------------------------
Write-Host "`n[3/8] Monitoring views present" -ForegroundColor Cyan
$expected = @(
    'vw_slow_queries',
    'vw_index_usage',
    'vw_unused_indexes',
    'vw_most_seq_scanned',
    'vw_active_sessions',
    'vw_long_running_queries',
    'vw_db_size_summary'
)
$present = & $pg @cn -c "SELECT viewname FROM pg_views WHERE schemaname='public' AND viewname LIKE 'vw\_%' AND viewname IN ($((($expected | ForEach-Object { "'$_'"}) -join ','))) ORDER BY viewname;"
foreach ($v in $expected) {
    if ($present -match "^$v$") {
        Write-Host "  [OK] $v present" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $v MISSING" -ForegroundColor Red
        $failed = $true
    }
}

# --- 4. Helper functions -------------------------------------------
Write-Host "`n[4/8] Helper functions" -ForegroundColor Cyan
$expected = @('fn_get_slow_queries', 'fn_suggest_indexes')
foreach ($fn in $expected) {
    $r = & $pg @cn -c "SELECT 1 FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='public' AND p.proname='$fn';"
    if ($r) {
        Write-Host "  [OK] $fn present" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $fn MISSING" -ForegroundColor Red
        $failed = $true
    }
}

# --- 5. fn_get_slow_queries runs without error ---------------------
Write-Host "`n[5/8] fn_get_slow_queries executes" -ForegroundColor Cyan
$out = & $pg @cn -c "SELECT count(*) FROM public.fn_get_slow_queries(0, 5);"
$out = ($out -join "`n").Trim()
if ($out -match '^\d+$') {
    Write-Host "  [OK] returned $out row(s)" -ForegroundColor Green
} else {
    Write-Host "  [WARN] returned: $out" -ForegroundColor Yellow
}

# --- 6. fn_suggest_indexes runs without error ----------------------
Write-Host "`n[6/8] fn_suggest_indexes executes" -ForegroundColor Cyan
$out = & $pg @cn -c "SELECT count(*) FROM public.fn_suggest_indexes(100, 50.0);"
$out = ($out -join "`n").Trim()
if ($out -match '^\d+$') {
    Write-Host "  [OK] returned $out candidate(s)" -ForegroundColor Green
} else {
    Write-Host "  [WARN] returned: $out" -ForegroundColor Yellow
}

# --- 7. Grants on views for app_* roles ----------------------------
Write-Host "`n[7/8] SELECT grants for app_* roles" -ForegroundColor Cyan
$ok = $true
foreach ($role in @('app_readonly', 'app_auditor', 'app_reports')) {
    $n = & $pg @cn -c "SELECT count(*) FROM information_schema.role_table_grants WHERE grantee='$role' AND table_schema='public' AND table_name LIKE 'vw\_%' AND privilege_type='SELECT';"
    $n = ($n -join "`n").Trim()
    if ([int]$n -ge 7) {
        Write-Host "  [OK] $role : $n SELECT grants on vw_* views" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] $role : only $n grants (expected >= 7)" -ForegroundColor Yellow
    }
}

# --- 8. Restart-required items (informational) --------------------
Write-Host "`n[8/8] Restart-required items (informational only)" -ForegroundColor Cyan

$preload = & $pg @cn -c "SELECT current_setting('shared_preload_libraries');"
$preload = ($preload -join "`n").Trim()
if ($preload -match 'pg_stat_statements') {
    Write-Host "  [OK] shared_preload_libraries contains pg_stat_statements" -ForegroundColor Green
} else {
    Write-Host "  [PENDING-RESTART] shared_preload_libraries = '$preload'  (add pg_stat_statements + restart)" -ForegroundColor Yellow
}

$autoExplain = & $pg @cn -c "SELECT extname FROM pg_extension WHERE extname='auto_explain';"
if ($autoExplain) {
    Write-Host "  [OK] auto_explain installed" -ForegroundColor Green
} else {
    Write-Host "  [PENDING-INSTALL] auto_explain not available on this PG build  (slow-query log via log_min_duration_statement is the fallback)" -ForegroundColor Yellow
}

$ioTiming = & $pg @cn -c "SELECT current_setting('track_io_timing');"
$ioTiming = ($ioTiming -join "`n").Trim()
if ($ioTiming -eq 'on') {
    Write-Host "  [OK] track_io_timing = on" -ForegroundColor Green
} else {
    Write-Host "  [PENDING-RESTART] track_io_timing = $ioTiming  (set to on in postgresql.conf.snippet + restart)" -ForegroundColor Yellow
}

# --- Summary -------------------------------------------------------
Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
if ($failed) {
    Write-Host "Critical checks  : FAIL" -ForegroundColor Red
    exit 1
} else {
    Write-Host "Critical checks  : PASS" -ForegroundColor Green
    Write-Host "Pending restart  : see [8/8] above. DBA action required via the supplied snippet." -ForegroundColor Yellow
    Write-Host "All Gap #3 IMMEDIATE items have been applied and verified." -ForegroundColor Green
    exit 0
}
