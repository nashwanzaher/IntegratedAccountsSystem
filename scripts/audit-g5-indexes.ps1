# =====================================================================
# IntegratedAccSys — Gap #5 Indexes Audit
# =====================================================================
# Date        : 2026-06-11
# Branch      : feat/gap-5-indexes-optimization
# Author      : GitHub Copilot (MiniMax-M3)
#
# Verifies the deliverables of gap 5 (Indexes):
#   1. Both idempotency signatures (Part A + B).
#   2. All 6 composite indexes are present and valid.
#   3. Both partial indexes are present and valid.
#   4. No INVALID indexes from failed CONCURRENTLY builds.
#   5. After/after counts vs baseline.
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
    @{ Fn = 'fn_g5_indexes_signature_part_a'; Tag = 'GAP5-INDEXES-PART-A' },
    @{ Fn = 'fn_g5_indexes_signature_part_b'; Tag = 'GAP5-INDEXES-PART-B' }
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

# --- 2. All 6 composite indexes are valid -----------------------------
Write-Host "`n[2/5] 6 composite indexes (present + valid)" -ForegroundColor Cyan
$expected_composite = @(
    'idx_tbljournalbody_journal_account',
    'idx_tblbondbody_bond_account',
    'idx_tblsessions_user_active_expires',
    'idx_tblaudi_table_record_date',
    'idx_tblcashreceipts_date_cashbox_status',
    'idx_tblcashpayments_date_cashbox_status'
)
$rows = & $pg @cn -c "SELECT c.relname, i.indisvalid FROM pg_class c JOIN pg_index i ON i.indexrelid = c.oid WHERE c.relname = ANY(ARRAY[$((($expected_composite | ForEach-Object { "'$_'"}) -join ','))]) ORDER BY c.relname;"
foreach ($name in $expected_composite) {
    $line = $rows -match "^$name\|"
    if ($line) {
        if ($line -match '\|t$') {
            Write-Host "  [OK] $name valid" -ForegroundColor Green
        } else {
            Write-Host "  [FAIL] $name INVALID" -ForegroundColor Red
            $failed = $true
        }
    } else {
        Write-Host "  [FAIL] $name MISSING" -ForegroundColor Red
        $failed = $true
    }
}

# --- 3. Both partial indexes are valid -------------------------------
Write-Host "`n[3/5] 2 partial indexes (present + valid)" -ForegroundColor Cyan
$expected_partial = @('idx_tblusers_active', 'idx_tblproducts_inventory')
$rows = & $pg @cn -c "SELECT c.relname, i.indisvalid FROM pg_class c JOIN pg_index i ON i.indexrelid = c.oid WHERE c.relname IN ('idx_tblusers_active','idx_tblproducts_inventory') ORDER BY c.relname;"
foreach ($name in $expected_partial) {
    $line = $rows -match "^$name\|"
    if ($line) {
        if ($line -match '\|t$') {
            Write-Host "  [OK] $name valid" -ForegroundColor Green
        } else {
            Write-Host "  [FAIL] $name INVALID" -ForegroundColor Red
            $failed = $true
        }
    } else {
        Write-Host "  [FAIL] $name MISSING" -ForegroundColor Red
        $failed = $true
    }
}

# --- 4. No INVALID indexes on the gap-5 names ------------------------
Write-Host "`n[4/5] No INVALID leftover indexes" -ForegroundColor Cyan
$allNames = $expected_composite + $expected_partial
$bad = & $pg @cn -c "SELECT count(*) FROM pg_class c JOIN pg_index i ON i.indexrelid = c.oid WHERE c.relname = ANY(ARRAY[$((($allNames | ForEach-Object { "'$_'"}) -join ','))]) AND NOT i.indisvalid;"
$bad = ($bad -join "`n").Trim()
if ($bad -eq '0') {
    Write-Host "  [OK] no invalid indexes on gap-5 names" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] $bad invalid index(es)" -ForegroundColor Red
    $failed = $true
}

# --- 5. After/before counts ----------------------------------------
Write-Host "`n[5/5] Index count summary (after vs baseline)" -ForegroundColor Cyan
$counts = & $pg @cn -c "SELECT 'total_user_indexes=' || count(*) FROM pg_stat_user_indexes; SELECT 'composite_indexes=' || count(*) FROM pg_indexes WHERE schemaname='public' AND indexdef LIKE '%(%' AND indexdef LIKE '%,%'; SELECT 'partial_indexes=' || count(*) FROM pg_indexes WHERE schemaname='public' AND indexdef ILIKE '%where%';"
foreach ($line in $counts) {
    $t = $line.Trim()
    if ($t) { Write-Host "  $t" -ForegroundColor Cyan }
}
Write-Host "  (baseline: total=229, composite=33, partial=8)" -ForegroundColor DarkGray

# --- Summary --------------------------------------------------------
Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
if ($failed) {
    Write-Host "Critical checks  : FAIL" -ForegroundColor Red
    exit 1
} else {
    Write-Host "Critical checks  : PASS" -ForegroundColor Green
    Write-Host "All Gap #5 deliverables have been applied and verified." -ForegroundColor Green
    exit 0
}
