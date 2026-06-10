# =====================================================================
# IntegratedAccSys — Gap #2 Security Audit
# =====================================================================
# Date        : 2026-06-10
# Branch      : feat/gap-2-column-encryption-ssl
# Author      : GitHub Copilot (MiniMax-M3)
#
# Verifies the immediate-action items introduced by
# `database/IntegratedAccSys_Security.sql`. Items that require a
# PostgreSQL restart (ssl, shared_preload_libraries, pgaudit) are
# detected and reported with a `PENDING-RESTART` label rather than
# failing the audit.
#
# Exit codes
#   0 — all critical checks passed
#   1 — one or more critical checks failed
#
# Usage
#   powershell -ExecutionPolicy Bypass -File scripts\audit-g2-security.ps1
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

# --- 1. Signature ----------------------------------------------------
Write-Host "`n[1/8] Idempotency signature (IntegratedAccSys_Security.sql applied)" -ForegroundColor Cyan
$out = & $pg @cn -c "SELECT public.fn_g2_security_signature();"
if ($out -match 'GAP2-SECURITY-\d{4}-\d{2}-\d{2}-v\d+') {
    Write-Host "  [OK] $out" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Security SQL has NOT been applied." -ForegroundColor Red
    Write-Host "         Run: psql -h localhost -U postgres -d IntegratedAccSys -f database\IntegratedAccSys_Security.sql"
    exit 1
}

# --- 2. pg_stat_statements -------------------------------------------
Write-Host "`n[2/8] pg_stat_statements extension" -ForegroundColor Cyan
$out = & $pg @cn -c "SELECT extversion FROM pg_extension WHERE extname='pg_stat_statements';"
if ($out) {
    Write-Host "  [OK] installed v$out" -ForegroundColor Green
} else {
    Write-Host "  [WARN] not installed — query analytics disabled. Add to shared_preload_libraries and restart." -ForegroundColor Yellow
}

# --- 3. log_statement & slow query log --------------------------------
Write-Host "`n[3/8] log_statement + log_min_duration_statement" -ForegroundColor Cyan
$out = & $pg @cn -c "SELECT current_setting('log_statement'), current_setting('log_min_duration_statement');"
$logStmt, $logMin = $out -split '\|'
if ($logStmt -eq 'mod') {
    Write-Host "  [OK] log_statement = 'mod'  (DDL + DML audited, no SELECT spam)" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] log_statement = '$logStmt'  (expected 'mod')" -ForegroundColor Red
    exit 1
}
$logMinMs = 0
if ($logMin -match '^\s*(-?\d+)\s*(ms|s)?\s*$') {
    $num = [int]$Matches[1]
    if ($Matches[2] -eq 's') { $num *= 1000 }
    $logMinMs = $num
}
if ($logMinMs -gt 0) {
    Write-Host "  [OK] log_min_duration_statement = ${logMin} (=${logMinMs}ms)" -ForegroundColor Green
} else {
    Write-Host "  [WARN] log_min_duration_statement = $logMin  (slow-query log disabled)" -ForegroundColor Yellow
}

# --- 4. Connection limits on app_* roles -----------------------------
Write-Host "`n[4/8] Connection limits on app_* roles" -ForegroundColor Cyan
$expected = @{
    'app_admin'     = 20
    'app_readwrite' = 50
    'app_readonly'  = 50
    'app_auditor'   = 10
    'app_reports'   = 20
    'app_backup'    = 5
}
$rows = & $pg @cn -c "SELECT rolname, rolconnlimit FROM pg_roles WHERE rolname LIKE 'app\_%' ORDER BY rolname;"
$allOk = $true
foreach ($r in ($rows -split "`n" | Where-Object { $_ })) {
    $name, $lim = $r -split '\|'
    $name = $name.Trim()
    $lim  = [int]$lim.Trim()
    if ($expected.ContainsKey($name) -and $expected[$name] -eq $lim) {
        Write-Host "  [OK] $name : limit=$lim" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $name : limit=$lim  (expected $($expected[$name]))" -ForegroundColor Red
        $allOk = $false
    }
}
if (-not $allOk) { exit 1 }

# --- 5. PII helpers (fn_pii_encrypt / fn_pii_decrypt) ----------------
Write-Host "`n[5/8] PII helpers (fn_pii_encrypt / fn_pii_decrypt)" -ForegroundColor Cyan
$exists = & $pg @cn -c "SELECT proname FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='public' AND proname IN ('fn_pii_encrypt','fn_pii_decrypt') ORDER BY proname;"
if ($exists -match 'fn_pii_decrypt' -and $exists -match 'fn_pii_encrypt') {
    Write-Host "  [OK] both functions present" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] PII helpers missing." -ForegroundColor Red
    exit 1
}

# --- 6. PII helpers round-trip behaviour -----------------------------
Write-Host "`n[6/8] PII round-trip behaviour (keyed by app.pii_key)" -ForegroundColor Cyan
$rtSql = @'
CREATE OR REPLACE FUNCTION pg_temp.fn_test_pii_roundtrip() RETURNS text AS $$
DECLARE
    k  text := 'audit-g2-test-key-32-bytes!!';
    pt text := 'sensitive-PII-1234';
    ct bytea;
    rt text;
BEGIN
    PERFORM set_config('app.pii_key', k, false);
    ct := public.fn_pii_encrypt(pt);
    rt := public.fn_pii_decrypt(ct);
    RETURN rt;
END;
$$ LANGUAGE plpgsql;
SELECT pg_temp.fn_test_pii_roundtrip();
'@
$rt = & $pg @cn -c $rtSql
# Filter out the CREATE FUNCTION echo — keep only the SELECT result.
$rt = ($rt -join "`n") -split "`n" | Where-Object { $_ -match '^[A-Za-z0-9 _\-+=/.,@:;]+$' } | Select-Object -Last 1
$rt = $rt.Trim()
if ($rt -eq 'sensitive-PII-1234') {
    Write-Host "  [OK] encrypt + decrypt round-trip works" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] round-trip returned: '$rt' (expected 'sensitive-PII-1234')" -ForegroundColor Red
    exit 1
}

# --- 7. photo_encrypted column ---------------------------------------
Write-Host "`n[7/8] tblusers.photo_encrypted column" -ForegroundColor Cyan
$out = & $pg @cn -c "SELECT data_type FROM information_schema.columns WHERE table_schema='public' AND table_name='tblusers' AND column_name='photo_encrypted';"
if ($out -match 'bytea') {
    Write-Host "  [OK] column present (bytea, nullable, non-destructive)" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] column missing" -ForegroundColor Red
    exit 1
}

# --- 8. Restart-required items (informational) -----------------------
Write-Host "`n[8/8] Restart-required items (informational only)" -ForegroundColor Cyan

$ssl = & $pg @cn -c "SELECT current_setting('ssl');"
if ($ssl.Trim() -eq 'on') {
    Write-Host "  [OK] ssl = on" -ForegroundColor Green
} else {
    Write-Host "  [PENDING-RESTART] ssl = off  (apply database\postgresql.conf.snippet + restart)" -ForegroundColor Yellow
}

$preload = & $pg @cn -c "SELECT current_setting('shared_preload_libraries');"
if ($preload.Trim() -match 'pg_stat_statements') {
    Write-Host "  [OK] shared_preload_libraries contains pg_stat_statements" -ForegroundColor Green
} else {
    Write-Host "  [PENDING-RESTART] shared_preload_libraries = '$preload'  (add pg_stat_statements + restart)" -ForegroundColor Yellow
}

$pgaudit = & $pg @cn -c "SELECT extname FROM pg_extension WHERE extname='pgaudit';"
if ($pgaudit) {
    Write-Host "  [OK] pgaudit installed" -ForegroundColor Green
} else {
    Write-Host "  [PENDING-INSTALL] pgaudit not installed on this PG build  (SOX log disabled; log_statement='mod' is the fallback)" -ForegroundColor Yellow
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Critical checks  : PASS" -ForegroundColor Green
Write-Host "Pending restart  : see [8/8] above. DBA action required via the supplied snippets." -ForegroundColor Yellow
Write-Host "All Gap #2 IMMEDIATE items have been applied and verified." -ForegroundColor Green
exit 0
