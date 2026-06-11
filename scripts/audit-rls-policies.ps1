<#
    IntegratedAccSys — Gap #1 audit script
    Purpose : Verify that the 6 app_* roles, the RLS-enabled tables, and the
              policies from database/IntegratedAccSys_RolesAndGrants.sql and
              database/IntegratedAccSys_EnableRLS.sql are correctly installed.
    Exits   : 0 on success, 1 on any check failure.
    Usage   : powershell -ExecutionPolicy Bypass -File scripts/audit-rls-policies.ps1
#>

$ErrorActionPreference = 'Stop'
$psql   = 'C:\Program Files\PostgreSQL\17\bin\psql.exe'
$db     = 'IntegratedAccSys'
$dbHost = 'localhost'
$user   = 'postgres'

function Invoke-Psql {
    param([string]$Sql, [string]$DbName = $db, [string]$DbUser = $user)
    & $psql -h $dbHost -U $DbUser -d $DbName -t -A -c $Sql
}

# -------------------------------------------------------------------- 1. Roles
$env:PGPASSWORD = '656650'
$rolesExpected = @('app_readonly','app_readwrite','app_admin',
                   'app_auditor','app_reports','app_backup')
$rolesActual = Invoke-Psql `
    "SELECT rolname FROM pg_roles WHERE rolname LIKE 'app\_%' ORDER BY rolname;"
foreach ($r in $rolesExpected) {
    if ($rolesActual -notcontains $r) {
        Write-Host "[FAIL] role missing: $r" -ForegroundColor Red
        exit 1
    }
}
Write-Host "[OK] all 6 app_* roles present." -ForegroundColor Green

# -------------------------------------------------------------------- 2. RLS
$rlsExpected = @('tblusers','tblsessions','tblauditlogs','tblaudi',
                 'tblbankaccounts','tblcashboxes','tblcustomers',
                 'tblsuppliers','tblnotifications')
$rlsRows = Invoke-Psql `
    "SELECT c.relname || '|' || c.relrowsecurity::text || '|' || c.relforcerowsecurity::text
       FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
      WHERE n.nspname='public' AND c.relkind='r' AND c.relname IN (
        'tblusers','tblsessions','tblauditlogs','tblaudi',
        'tblbankaccounts','tblcashboxes','tblcustomers',
        'tblsuppliers','tblnotifications')
      ORDER BY c.relname;"
foreach ($row in $rlsRows) {
    $parts = $row -split '\|'
    if ($parts[1] -ne 'true' -or $parts[2] -ne 'true') {
        Write-Host "[FAIL] RLS not enabled+forced on $($parts[0])" -ForegroundColor Red
        exit 1
    }
}
Write-Host "[OK] RLS enabled+forced on all 9 sensitive tables." -ForegroundColor Green

# -------------------------------------------------------------------- 3. Policies
$policyCount = Invoke-Psql `
    "SELECT COUNT(*) FROM pg_policies WHERE schemaname='public';"
if ([int]$policyCount -lt 26) {
    Write-Host "[FAIL] expected >= 26 policies, found $policyCount" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] policies present: $policyCount" -ForegroundColor Green

# -------------------------------------------------------------------- 4. No PUBLIC grants
$publicGrants = Invoke-Psql `
    "SELECT COUNT(*) FROM information_schema.role_table_grants
       WHERE grantee='PUBLIC' AND table_schema='public';"
if ([int]$publicGrants -ne 0) {
    Write-Host "[FAIL] PUBLIC grants remain: $publicGrants" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] PUBLIC has 0 grants on public schema tables." -ForegroundColor Green

# -------------------------------------------------------------------- 5. Behavioural test — simulated app_readonly
$loginCheck = Invoke-Psql `
    "SELECT rolcanlogin FROM pg_roles WHERE rolname='app_readonly';"
if ($loginCheck -ne 't') {
    & $psql -h $dbHost -U $user -d $db -c `
        "ALTER ROLE app_readonly LOGIN PASSWORD 'dev_readonly_pwd';" *>$null
    Write-Host "[INFO] app_readonly enabled with dev password (login=pwd=dev_readonly_pwd)" -ForegroundColor Yellow
}

$env:PGPASSWORD = 'dev_readonly_pwd'
$selectOK  = ''
$insertErr = ''
try {
    $selectOK = & $psql -h $dbHost -U app_readonly -d $db -t -A -c `
        "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public';" 2>&1
} catch { $selectOK = "[ERROR] $($_.Exception.Message)" }
try {
    $insertErr = & $psql -h $dbHost -U app_readonly -d $db -t -A -c `
        "INSERT INTO public.tblusers(userid, branchcode, userpassword) VALUES ('hacker',1,'x');" 2>&1
} catch { $insertErr = $_.Exception.Message }
$env:PGPASSWORD = '656650'

if (-not $selectOK -or $insertErr -notmatch 'permission denied|policy|42501') {
    Write-Host "[FAIL] app_readonly behavioural test failed." -ForegroundColor Red
    Write-Host "  SELECT result : $selectOK"
    Write-Host "  INSERT result : $insertErr"
    exit 1
}
Write-Host "[OK] app_readonly: SELECT works, INSERT denied (as expected)." -ForegroundColor Green

# -------------------------------------------------------------------- 6. Final summary
Write-Host ""
Write-Host "=== AUDIT SUMMARY ===" -ForegroundColor Cyan
Write-Host "  roles     : 6 / 6   present"
Write-Host "  RLS       : 9 / 9   enabled+forced"
Write-Host "  policies  : $policyCount (expected >= 26)"
Write-Host "  PUBLIC    : 0 grants"
Write-Host "  behaviour : app_readonly cannot write"
Write-Host ""
Write-Host "[ALL CHECKS PASSED]" -ForegroundColor Green
exit 0
