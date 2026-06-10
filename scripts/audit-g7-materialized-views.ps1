# =====================================================================
# IntegratedAccSys — Gap #7 Materialized Views Audit
# =====================================================================
# Date        : 2026-06-11
# Branch      : feat/gap-7-materialized-views
# Author      : GitHub Copilot (MiniMax-M3)
#
# Verifies the deliverables of gap 7 (Materialized Views):
#   1. Both idempotency signatures (Part A + B)
#   2. All 5 new MVs present in pg_matviews
#   3. Each new MV has a UNIQUE INDEX (required for REFRESH CONCURRENTLY)
#   4. All 5 new MVs are REFRESHable (smoke test on a non-empty MV)
#   5. Before/after counts vs existing 5 accounting MVs
#
# Exit codes
#   0 — all critical checks passed
#   1 — one or more critical checks failed
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

# --- 1. Idempotency signatures ---------------------------------------
Write-Host "`n[1/5] Idempotency signatures (Part A + B applied)" -ForegroundColor Cyan
$expected = @(
    @{ Fn = 'fn_g7_mv_signature_part_a'; Tag = 'GAP7-MV-PART-A' },
    @{ Fn = 'fn_g7_mv_signature_part_b'; Tag = 'GAP7-MV-PART-B' }
)
foreach ($s in $expected) {
    $out = & $pg @cn -c "SELECT public.$($s.Fn)();"
    if ($out -match [regex]::Escape($s.Tag)) {
        Write-Host "  [OK] $($s.Fn) -> $out" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $($s.Fn) not applied (got: $out)" -ForegroundColor Red
        $failed = $true
    }
}

# --- 2. All 5 new MVs present in pg_matviews --------------------------
Write-Host "`n[2/5] 5 new materialized views (present)" -ForegroundColor Cyan
$expected_mvs = @(
    'mv_daily_sales_summary',
    'mv_customer_outstanding_balance',
    'mv_treasury_position',
    'mv_monthly_inventory_snapshot',
    'mv_budget_vs_actual_summary'
)
$present = & $pg @cn -c "SELECT matviewname FROM pg_matviews WHERE schemaname='public' AND matviewname IN ($((($expected_mvs | ForEach-Object { "'$_'"}) -join ','))) ORDER BY matviewname;"
foreach ($name in $expected_mvs) {
    if ($present -match "^$name$") {
        Write-Host "  [OK] $name present" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $name MISSING" -ForegroundColor Red
        $failed = $true
    }
}

# --- 3. Each MV has a UNIQUE INDEX -----------------------------------
Write-Host "`n[3/5] Each MV has a UNIQUE INDEX (REFRESH CONCURRENTLY requirement)" -ForegroundColor Cyan
# relkind='m' = materialized view. Join on indrelid (the MV's oid)
# which is the relid the index is built on, not the index's own oid.
$rows = & $pg @cn -c "SELECT t.relname, i.indisunique FROM pg_class t JOIN pg_index i ON i.indrelid = t.oid WHERE t.relkind = 'm' AND t.relname IN ($((($expected_mvs | ForEach-Object { "'$_'"}) -join ','))) ORDER BY t.relname;"
foreach ($name in $expected_mvs) {
    $line = $rows -match "^$name\|"
    if ($line -and $line -match '\|t$') {
        Write-Host "  [OK] $name has UNIQUE index" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $name missing UNIQUE index" -ForegroundColor Red
        $failed = $true
    }
}

# --- 4. All MVs are REFRESHable (smoke test on empty MVs) ------------
Write-Host "`n[4/5] All MVs are REFRESHable (smoke test)" -ForegroundColor Cyan
foreach ($name in $expected_mvs) {
    $out = & $pg @cn -c "REFRESH MATERIALIZED VIEW public.$name;"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] REFRESH MATERIALIZED VIEW $name succeeded" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] REFRESH failed for $name" -ForegroundColor Red
        $failed = $true
    }
}

# --- 5. Before/after counts ------------------------------------------
Write-Host "`n[5/5] MV count summary (after vs baseline)" -ForegroundColor Cyan
$counts = & $pg @cn -c "SELECT 'total_mvs=' || count(*) FROM pg_matviews WHERE schemaname='public'; SELECT 'populated_mvs=' || count(*) FROM pg_matviews WHERE schemaname='public' AND ispopulated;"
foreach ($line in $counts) {
    $t = $line.Trim()
    if ($t) { Write-Host "  $t" -ForegroundColor Cyan }
}
Write-Host "  (baseline: 5 accounting MVs, 0 of the 5 new ones)" -ForegroundColor DarkGray

# --- Summary --------------------------------------------------------
Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
if ($failed) {
    Write-Host "Critical checks  : FAIL" -ForegroundColor Red
    exit 1
} else {
    Write-Host "Critical checks  : PASS" -ForegroundColor Green
    Write-Host "All Gap #7 deliverables have been applied and verified." -ForegroundColor Green
    exit 0
}
