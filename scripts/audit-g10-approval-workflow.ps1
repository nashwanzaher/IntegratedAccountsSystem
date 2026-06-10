# =====================================================================
# IntegratedAccSys — Gap #10 Approval Workflow Audit
# =====================================================================
# Date        : 2026-06-11
# Branch      : feat/gap-10-approval-workflow
# Author      : GitHub Copilot (MiniMax-M3)
#
# Verifies the deliverables of gap 10 (Approval Workflows):
#   1. Three idempotency signatures (Part A + B + C)
#   2. Two helper functions (valid_transition, compute_status)
#   3. Two triggers (action_audit, request_status_update) present
#      AND enabled (tgenabled = 'O')
#   4. Dashboard view present
#   5. Smoke test: state-machine transition logic on a controlled
#      sequence (no DB side-effects thanks to ROLLBACK)
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
Write-Host "`n[1/5] Idempotency signatures (Part A + B + C applied)" -ForegroundColor Cyan
$expected = @(
    @{ Fn = 'fn_g10_approval_signature_part_a';   Tag = 'GAP10-APPROVAL-PART-A' },
    @{ Fn = 'fn_g10_approval_signature_part_b';   Tag = 'GAP10-APPROVAL-PART-B' },
    @{ Fn = 'fn_g10_approval_signature_part_c';   Tag = 'GAP10-APPROVAL-PART-C' }
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

# --- 2. Helper functions --------------------------------------------
Write-Host "`n[2/5] 2 helper functions (present)" -ForegroundColor Cyan
$expected_fns = @('fn_g10_approval_valid_transition', 'fn_g10_approval_compute_status')
foreach ($fn in $expected_fns) {
    $r = & $pg @cn -c "SELECT 1 FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='public' AND p.proname='$fn';"
    if ($r) {
        Write-Host "  [OK] $fn present" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $fn MISSING" -ForegroundColor Red
        $failed = $true
    }
}

# --- 3. Triggers present and enabled -------------------------------
Write-Host "`n[3/5] 2 triggers (present + enabled)" -ForegroundColor Cyan
$expected_trgs = @('trg_g10_approval_action_audit', 'trg_g10_approval_request_status_update')
$rows = & $pg @cn -c "SELECT t.tgname, t.tgenabled FROM pg_trigger t WHERE t.tgname IN ('trg_g10_approval_action_audit','trg_g10_approval_request_status_update') ORDER BY t.tgname;"
foreach ($name in $expected_trgs) {
    $line = $rows -match "^$name\|"
    if ($line -and $line -match '\|O$') {
        Write-Host "  [OK] $name present and enabled" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $name missing or not enabled" -ForegroundColor Red
        $failed = $true
    }
}

# --- 4. Dashboard view present -------------------------------------
Write-Host "`n[4/5] Dashboard view (vw_approval_workflow_dashboard)" -ForegroundColor Cyan
$out = & $pg @cn -c "SELECT 1 FROM pg_views WHERE schemaname='public' AND viewname='vw_approval_workflow_dashboard';"
if ($out) {
    Write-Host "  [OK] vw_approval_workflow_dashboard present" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] view MISSING" -ForegroundColor Red
    $failed = $true
}

# --- 5. Smoke test: state-machine transition logic (no DB writes) ---
Write-Host "`n[5/5] State machine smoke test (no DB writes)" -ForegroundColor Cyan
$testSql = @'
SELECT
    fn_g10_approval_valid_transition('PENDING','IN_REVIEW')   AS t1_pending_to_review,
    fn_g10_approval_valid_transition('IN_REVIEW','APPROVED') AS t2_review_to_approved,
    fn_g10_approval_valid_transition('IN_REVIEW','REJECTED') AS t3_review_to_rejected,
    fn_g10_approval_valid_transition('APPROVED','PENDING')  AS t4_approved_to_pending_should_be_false,
    fn_g10_approval_valid_transition('IN_REVIEW','PENDING')  AS t5_review_back_to_pending,
    fn_g10_approval_valid_transition('APPROVED','APPROVED') AS t6_approved_to_approved_noop;
'@
$out = & $pg @cn -c $testSql
$out = ($out -join "`n").Trim()
# Expected: t,t,t,f,t,t (t1=t2=t3=t5=t6=true, t4=false)
if ($out -match '^t\|t\|t\|f\|t\|t$') {
    Write-Host "  [OK] all 6 transition cases match expected: t,t,t,f,t,t" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] unexpected transition matrix: $out" -ForegroundColor Red
    $failed = $true
}

# --- Summary --------------------------------------------------------
Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
if ($failed) {
    Write-Host "Critical checks  : FAIL" -ForegroundColor Red
    exit 1
} else {
    Write-Host "Critical checks  : PASS" -ForegroundColor Green
    Write-Host "All Gap #10 deliverables have been applied and verified." -ForegroundColor Green
    exit 0
}
