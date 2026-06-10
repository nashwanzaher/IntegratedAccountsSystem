# Build complete BL → DAL → PostgreSQL mapping matrix
# This script:
#   1. Extracts all SPs/Functions called from BL
#   2. Extracts all DB objects defined in database/ scripts
#   3. Produces a matrix: Referenced vs Existing vs Missing
#   4. Categorizes the gap

$blRoot = "d:\source\IntegratedAccountsSystem\src\IntegratedAccSys.BL"
$dbRoot = "d:\source\IntegratedAccountsSystem\database"
$testsRoot = "d:\source\IntegratedAccountsSystem\tests"

# ============================================
# STEP 1: Extract BL → SP/Function calls
# ============================================
Write-Host "=== STEP 1: EXTRACTING BL DATABASE CALLS ===" -ForegroundColor Cyan
$blCalls = @()
Get-ChildItem -Path $blRoot -Recurse -Filter "*.cs" | ForEach-Object {
    $file = $_.FullName
    $rel = $file.Substring($blRoot.Length + 1)
    $content = Get-Content $file -Raw -ErrorAction SilentlyContinue
    if (-not $content) { return }

    # Match: cn.SelectData("name",...)  cn.ExecuteCmd("name",...)  ctx.SelectData / Execute / ExecuteScalar
    $patterns = @(
        'cn\.(SelectData|ExecuteCmd)\s*\(\s*["\x27]([^"\x27]+)["\x27]',
        'ctx\.(SelectData|Execute|ExecuteScalar|ExecuteRawSql)\s*\(\s*["\x27]([^"\x27]+)["\x27]'
    )
    foreach ($pat in $patterns) {
        $matches = [regex]::Matches($content, $pat)
        foreach ($m in $matches) {
            $op = $m.Groups[1].Value
            $obj = $m.Groups[2].Value
            $blCalls += [PSCustomObject]@{
                Layer  = "BL"
                Class  = ($rel -replace '\\[^\\]+$', '')
                File   = $rel
                Op     = $op
                Object = $obj
            }
        }
    }
}
$uniqueCalled = ($blCalls | Select-Object -ExpandProperty Object -Unique) | Sort-Object
Write-Host "Total unique DB objects called from BL: $($uniqueCalled.Count)" -ForegroundColor Yellow
$blCalls | Group-Object Object | Sort-Object Name | ForEach-Object {
    Write-Host ("  {0,-35} called {1}x" -f $_.Name, $_.Count)
}

# ============================================
# STEP 2: Extract DB objects from scripts
# ============================================
Write-Host ""
Write-Host "=== STEP 2: EXTRACTING EXISTING POSTGRESQL OBJECTS ===" -ForegroundColor Cyan

$dbObjects = @()
$dbFiles = @("IntegratedAccSys_PostgreSQL_Logic.sql", "IntegratedAccSys_pg_dump.sql", "IntegratedAccSys_Full.sql", "IntegratedAccSys_CompleteLogic.sql")
foreach ($dbFile in $dbFiles) {
    $path = Join-Path $dbRoot $dbFile
    if (-not (Test-Path $path)) { continue }
    $content = Get-Content $path -Raw -ErrorAction SilentlyContinue
    if (-not $content) { continue }

    # Functions
    $funcMatches = [regex]::Matches($content, 'CREATE\s+(?:OR\s+REPLACE\s+)?FUNCTION\s+(?:public\.)?([a-zA-Z_][a-zA-Z0-9_]*)\s*\(')
    foreach ($m in $funcMatches) {
        $dbObjects += [PSCustomObject]@{
            Type   = "FUNCTION"
            Name   = $m.Groups[1].Value
            Source = $dbFile
        }
    }
    # Procedures
    $procMatches = [regex]::Matches($content, 'CREATE\s+(?:OR\s+REPLACE\s+)?PROCEDURE\s+(?:public\.)?([a-zA-Z_][a-zA-Z0-9_]*)\s*\(')
    foreach ($m in $procMatches) {
        $dbObjects += [PSCustomObject]@{
            Type   = "PROCEDURE"
            Name   = $m.Groups[1].Value
            Source = $dbFile
        }
    }
    # Views
    $viewMatches = [regex]::Matches($content, 'CREATE\s+(?:OR\s+REPLACE\s+)?VIEW\s+(?:public\.)?([a-zA-Z_][a-zA-Z0-9_]*)\s')
    foreach ($m in $viewMatches) {
        $dbObjects += [PSCustomObject]@{
            Type   = "VIEW"
            Name   = $m.Groups[1].Value
            Source = $dbFile
        }
    }
    # Triggers
    $trigMatches = [regex]::Matches($content, 'CREATE\s+(?:OR\s+REPLACE\s+)?TRIGGER\s+(?:public\.)?([a-zA-Z_][a-zA-Z0-9_]*)\s+')
    foreach ($m in $trigMatches) {
        $dbObjects += [PSCustomObject]@{
            Type   = "TRIGGER"
            Name   = $m.Groups[1].Value
            Source = $dbFile
        }
    }
}
$dbObjects = $dbObjects | Sort-Object -Property Type, Name -Unique
Write-Host "Total DB objects defined: $($dbObjects.Count)" -ForegroundColor Yellow
$dbObjects | Group-Object Type | ForEach-Object {
    Write-Host ("  {0}: {1}" -f $_.Name, $_.Count)
}
$dbObjectNames = $dbObjects | Select-Object -ExpandProperty Name -Unique

# ============================================
# STEP 3: Build the mapping matrix
# ============================================
Write-Host ""
Write-Host "=== STEP 3: BL → DB MAPPING MATRIX ===" -ForegroundColor Cyan

$existing = $uniqueCalled | Where-Object { $_ -in $dbObjectNames }
$missing = $uniqueCalled | Where-Object { $_ -notin $dbObjectNames }

Write-Host ""
Write-Host ("[EXISTING]  {0} called objects ARE defined in DB" -f $existing.Count) -ForegroundColor Green
$existing | ForEach-Object { Write-Host "  [OK]  $_" }

Write-Host ""
Write-Host ("[MISSING]   {0} called objects are NOT defined in DB" -f $missing.Count) -ForegroundColor Red
$missing | ForEach-Object { Write-Host "  [!!]  $_" }

# ============================================
# STEP 4: Write JSON for downstream tooling
# ============================================
$matrix = @{
    GeneratedAt  = (Get-Date -Format "o")
    Project      = "IntegratedAccSys"
    TotalBLCalls = $uniqueCalled.Count
    TotalDBObjs  = $dbObjectNames.Count
    Existing     = @($existing)
    Missing      = @($missing)
}

$matrixPath = "d:\source\IntegratedAccountsSystem\scripts\mapping-matrix.json"
$matrix | ConvertTo-Json -Depth 5 | Set-Content $matrixPath
Write-Host ""
Write-Host "Matrix saved to: $matrixPath" -ForegroundColor Green
