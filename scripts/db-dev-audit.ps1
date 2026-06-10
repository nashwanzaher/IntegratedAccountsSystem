# db-dev-audit.ps1 - Comprehensive database development audit
# Identifies: missing objects, unused objects, schema issues, parameter mismatches

$ErrorActionPreference = 'Stop'
$env:PGPASSWORD = '656650'
$PsqlPath = 'C:\Program Files\PostgreSQL\17\bin\psql.exe'
$DbName = 'IntegratedAccSys'

function Run-Psql([string]$Sql) {
    & $PsqlPath -h localhost -U postgres -d $DbName -t -A -c $Sql 2>&1
}

Write-Host "=== PHASE 1: LIVE DATABASE SNAPSHOT ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Object counts:" -ForegroundColor Yellow
$counts = Run-Psql "SELECT 'tables', COUNT(*) FROM information_schema.tables WHERE table_schema='public' UNION ALL SELECT 'functions', COUNT(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='public' AND p.prokind='f' UNION ALL SELECT 'procedures', COUNT(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='public' AND p.prokind='p' UNION ALL SELECT 'views', COUNT(*) FROM information_schema.views WHERE table_schema='public' UNION ALL SELECT 'triggers', COUNT(*) FROM information_schema.triggers WHERE trigger_schema='public' ORDER BY 1;"
$counts | ForEach-Object { Write-Host "  $_" }

Write-Host ""
Write-Host "=== PHASE 2: LIST ALL TABLES ===" -ForegroundColor Cyan
$tblList = Run-Psql "SELECT table_name FROM information_schema.tables WHERE table_schema='public' ORDER BY table_name"
$tblList | ForEach-Object { Write-Host "  $_" }

Write-Host ""
Write-Host "=== PHASE 3: BL CODE -> DB OBJECT CALLS ===" -ForegroundColor Cyan
$blCalls = @()
Get-ChildItem -Path 'src\IntegratedAccSys.BL' -Recurse -Filter '*.cs' | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $matches = [regex]::Matches($content, 'cn\.(SelectData|ExecuteCmd)\s*\(\s*"([^"]+)"')
    foreach ($m in $matches) {
        $blCalls += [PSCustomObject]@{
            Object = $m.Groups[2].Value
            Op = $m.Groups[1].Value
            File = $_.Name
        }
    }
}
$unique = $blCalls | Select-Object -ExpandProperty Object -Unique | Sort-Object
Write-Host ("Total unique BL calls: " + $unique.Count) -ForegroundColor Yellow
$blCalls | Group-Object Object | Sort-Object Count -Descending | ForEach-Object {
    Write-Host ("  {0,-40} {1} calls" -f $_.Name, $_.Count)
}

Write-Host ""
Write-Host "=== PHASE 4: MISSING DB OBJECTS (called by BL but not in DB) ===" -ForegroundColor Cyan
$existing = Run-Psql "SELECT proname FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='public'"
$existingArr = @($existing)
$missing = $unique | Where-Object { $_ -notin $existingArr }
Write-Host ("Missing: " + $missing.Count) -ForegroundColor Yellow
$missing | ForEach-Object { Write-Host "  $_" }

Write-Host ""
Write-Host "=== PHASE 5: PARAMETER COUNTS FOR BL CALLED FUNCTIONS ===" -ForegroundColor Cyan
foreach ($obj in $unique) {
    $info = Run-Psql "SELECT proname || ' | kind=' || prokind || ' | args=' || pronargs FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='public' AND proname='$obj' LIMIT 1"
    if ($info) {
        Write-Host "  $info"
    }
}

Write-Host ""
Write-Host "=== PHASE 6: UNUSED PROCEDURES (in DB but never called by BL) ===" -ForegroundColor Cyan
$procedures = Run-Psql "SELECT proname FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='public' AND p.prokind='p' ORDER BY proname"
$procArr = @($procedures)
$calledProcs = $blCalls | Where-Object { $_.Op -eq 'ExecuteCmd' } | Select-Object -ExpandProperty Object -Unique
$unusedProcs = $procArr | Where-Object { $_ -notin $calledProcs }
Write-Host ("Unused procedures: " + $unusedProcs.Count) -ForegroundColor Yellow
$unusedProcs | ForEach-Object { Write-Host "  $_" }

Write-Host ""
Write-Host "=== PHASE 7: UNUSED FUNCTIONS (in DB but never called by BL) ===" -ForegroundColor Cyan
$functions = Run-Psql "SELECT proname FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='public' AND p.prokind='f' ORDER BY proname"
$funcArr = @($functions)
$calledFuncs = $blCalls | Where-Object { $_.Op -eq 'SelectData' } | Select-Object -ExpandProperty Object -Unique
$unusedFuncs = $funcArr | Where-Object { $_ -notin $calledFuncs }
Write-Host ("Unused functions: " + $unusedFuncs.Count) -ForegroundColor Yellow
$unusedFuncs | Select-Object -First 50 | ForEach-Object { Write-Host "  $_" }
if ($unusedFuncs.Count -gt 50) {
    Write-Host "  ... and $($unusedFuncs.Count - 50) more"
}
