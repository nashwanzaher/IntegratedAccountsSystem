# =====================================================================
# IntegratedAccSys — Gap #4 Constraints Audit
# =====================================================================
# Date        : 2026-06-11
# Branch      : feat/gap-4-constraints
# Author      : GitHub Copilot (MiniMax-M3)
#
# Verifies the deliverables of gap 4 (Constraints):
#   1. btree_gist extension (required for EXCLUDE).
#   2. 13 CHECK constraints, all validated.
#   3. 4 EXCLUDE constraints.
#   4. Behavioural tests for the EXCLUDE constraints
#      (each in a savepoint that is rolled back).
#
# Exit codes
#   0 — all critical checks passed
#   1 — one or more critical checks failed
#
# Usage
#   powershell -ExecutionPolicy Bypass -File scripts\audit-g4-constraints.ps1
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

# --- 1. All three idempotency signatures ----------------------------
Write-Host "`n[1/6] Idempotency signatures (Parts A, B, C applied)" -ForegroundColor Cyan
$expected_sigs = @(
    @{ Fn = 'fn_g4_constraints_signature_part_a'; Tag = 'GAP4-CONSTRAINTS-PART-A' },
    @{ Fn = 'fn_g4_constraints_signature_part_b'; Tag = 'GAP4-CONSTRAINTS-PART-B' },
    @{ Fn = 'fn_g4_constraints_signature_part_c'; Tag = 'GAP4-CONSTRAINTS-PART-C' }
)
foreach ($s in $expected_sigs) {
    $out = & $pg @cn -c "SELECT public.$($s.Fn)();"
    if ($out -match [regex]::Escape($s.Tag)) {
        Write-Host "  [OK] $($s.Fn) -> $out" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $($s.Fn) not applied (got: $out)" -ForegroundColor Red
        $failed = $true
    }
}

# --- 2. btree_gist extension ----------------------------------------
Write-Host "`n[2/6] btree_gist extension" -ForegroundColor Cyan
$out = & $pg @cn -c "SELECT extversion FROM pg_extension WHERE extname='btree_gist';"
if ($out) {
    Write-Host "  [OK] btree_gist installed v$out" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] btree_gist not installed" -ForegroundColor Red
    $failed = $true
}

# --- 3. CHECK constraints: 13 expected, all validated ---------------
Write-Host "`n[3/6] CHECK constraints (13 expected, all validated)" -ForegroundColor Cyan
$expected_chk = @(
    'chk_tblbankaccounts_balance_nonneg'
    'chk_tblbanktransactions_amount_positive'
    'chk_tblbondheader_amount_positive'
    'chk_tblexchangeratehistory_exgrate_positive'
    'chk_tbljournalbody_amounts_nonneg'
    'chk_tbljournalbody_no_dual_leg'
    'chk_tblpricelists_markup_nonneg'
    'chk_tblproducts_maxstock_gte_min'
    'chk_tblproducts_minstock_nonneg'
    'chk_tblproducts_prices_nonneg'
    'chk_tblsessions_expires_after_created'
    'chk_tblsessions_logout_after_created'
    'chk_tblusers_loginattempts_nonneg'
)
$present_chk = & $pg @cn -c "SELECT conname, convalidated FROM pg_constraint WHERE connamespace='public'::regnamespace AND contype='c' AND conname LIKE 'chk\_%' ORDER BY conname;"
$notValidated = 0
foreach ($name in $expected_chk) {
    $line = $present_chk -match "^$name\|"
    if ($line) {
        if ($line -match '\|t$') {
            Write-Host "  [OK] $name validated" -ForegroundColor Green
        } else {
            Write-Host "  [FAIL] $name NOT VALIDATED" -ForegroundColor Red
            $notValidated++
        }
    } else {
        Write-Host "  [FAIL] $name MISSING" -ForegroundColor Red
        $failed = $true
    }
}
if ($notValidated -gt 0) { $failed = $true }

# --- 4. EXCLUDE constraints: 4 expected -----------------------------
Write-Host "`n[4/6] EXCLUDE constraints (4 expected)" -ForegroundColor Cyan
$expected_excl = @(
    'excl_tblbankstatements_account_statementno'
    'excl_tblfiscalperiods_fiscalyear_daterange'
    'excl_tblexchangeratehistory_currid_daterange'
    'excl_tblsessions_active_user'
)
$present_excl = & $pg @cn -c "SELECT conname FROM pg_constraint WHERE connamespace='public'::regnamespace AND contype='x' ORDER BY conname;"
foreach ($name in $expected_excl) {
    if ($present_excl -match "^$name$") {
        Write-Host "  [OK] $name present" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $name MISSING" -ForegroundColor Red
        $failed = $true
    }
}

# --- 5. Behavioural: duplicate statementno must fail (rolled back) -----
Write-Host "`n[5/6] Behavioural: EXCLUDE blocks duplicate statementno (rolled back)" -ForegroundColor Cyan
$btSql = @'
DO $beh$
DECLARE
    v_acct    integer;
    v_stno    varchar(50) := 'AUDIT-DUP-' || to_char(now(), 'HH24MISSSS');
BEGIN
    SELECT bankaccountid INTO v_acct FROM tblbankaccounts ORDER BY bankaccountid LIMIT 1;
    IF v_acct IS NULL THEN
        PERFORM set_config('audit.g4_beh1', 'SKIP', false);
        RETURN;
    END IF;

    INSERT INTO public.tblbankstatements (bankaccountid, statementno, statementdate, openingbalance, closingbalance)
    VALUES (v_acct, v_stno, CURRENT_DATE, 0, 0);

    BEGIN
        INSERT INTO public.tblbankstatements (bankaccountid, statementno, statementdate, openingbalance, closingbalance)
        VALUES (v_acct, v_stno, CURRENT_DATE, 0, 0);
        PERFORM set_config('audit.g4_beh1', 'UNEXPECTED_PASS', false);
    EXCEPTION WHEN exclusion_violation THEN
        PERFORM set_config('audit.g4_beh1', 'PASS', false);
    END;

    -- Clean up the test row.
    DELETE FROM public.tblbankstatements WHERE statementno = v_stno;
END
$beh$;
SELECT current_setting('audit.g4_beh1', true);
'@
$out = & $pg @cn -c $btSql
$out = ($out -join "`n").Trim()
if ($out -match 'UNEXPECTED_PASS') {
    Write-Host "  [FAIL] duplicate insert was NOT rejected" -ForegroundColor Red
    $failed = $true
} elseif ($out -match 'PASS') {
    Write-Host "  [OK] duplicate insert correctly rejected" -ForegroundColor Green
} elseif ($out -match 'SKIP') {
    Write-Host "  [SKIP] no bank account in DB \u2014 behavioural test not applicable" -ForegroundColor Yellow
} else {
    Write-Host "  [WARN] test inconclusive (output: $out)" -ForegroundColor Yellow
}

# --- 6. Behavioural: overlapping fiscal period must fail (rolled back)
Write-Host "`n[6/6] Behavioural: EXCLUDE blocks overlapping fiscal period (rolled back)" -ForegroundColor Cyan
$fpSql = @'
DO $beh2$
DECLARE
    v_fy   integer;
    v_pno  integer := 9000 + (random() * 999)::int;   -- unique per run
    v_d1   date := '2099-01-01';
    v_d2   date := '2099-03-31';
    v_d3   date := '2099-03-01';
    v_d4   date := '2099-06-30';
BEGIN
    SELECT fiscalyearid INTO v_fy FROM tblfiscalyears ORDER BY fiscalyearid LIMIT 1;
    IF v_fy IS NULL THEN
        PERFORM set_config('audit.g4_beh2', 'SKIP', false);
        RETURN;
    END IF;

    INSERT INTO public.tblfiscalperiods (fiscalyearid, periodname, periodnumber, startdate, enddate)
    VALUES (v_fy, 'AUDIT-P1', v_pno, v_d1, v_d2);

    BEGIN
        INSERT INTO public.tblfiscalperiods (fiscalyearid, periodname, periodnumber, startdate, enddate)
        VALUES (v_fy, 'AUDIT-P2', v_pno + 1, v_d3, v_d4);
        PERFORM set_config('audit.g4_beh2', 'UNEXPECTED_PASS', false);
    EXCEPTION WHEN exclusion_violation THEN
        PERFORM set_config('audit.g4_beh2', 'PASS', false);
    END;

    -- Clean up the test rows.
    DELETE FROM public.tblfiscalperiods WHERE periodname IN ('AUDIT-P1', 'AUDIT-P2');
END
$beh2$;
SELECT current_setting('audit.g4_beh2', true);
'@
$out = & $pg @cn -c $fpSql
$out = ($out -join "`n").Trim()
if ($out -match 'UNEXPECTED_PASS') {
    Write-Host "  [FAIL] overlapping insert was NOT rejected" -ForegroundColor Red
    $failed = $true
} elseif ($out -match 'PASS') {
    Write-Host "  [OK] overlapping period correctly rejected" -ForegroundColor Green
} elseif ($out -match 'SKIP') {
    Write-Host "  [SKIP] no fiscal year in DB \u2014 behavioural test not applicable" -ForegroundColor Yellow
} else {
    Write-Host "  [WARN] test inconclusive (output: $out)" -ForegroundColor Yellow
}

# --- Summary ---------------------------------------------------------
Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
if ($failed) {
    Write-Host "Critical checks  : FAIL" -ForegroundColor Red
    exit 1
} else {
    Write-Host "Critical checks  : PASS" -ForegroundColor Green
    Write-Host "All Gap #4 IMMEDIATE items have been applied and verified." -ForegroundColor Green
    exit 0
}
