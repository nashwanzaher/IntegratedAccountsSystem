# Extract all stored procedures, functions, triggers, and views from database scripts

$dbRoot = "d:\source\IntegratedAccountsSystem\database"
$results = @()

# 1. Parse PostgreSQL Logic file (contains SPs, functions, triggers, views)
$logicFile = Join-Path $dbRoot "IntegratedAccSys_PostgreSQL_Logic.sql"
if (Test-Path $logicFile) {
    $content = Get-Content $logicFile -Raw -ErrorAction SilentlyContinue

    # Functions: CREATE OR REPLACE FUNCTION name(...)
    $funcPattern = 'CREATE\s+OR\s+REPLACE\s+FUNCTION\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\('
    $funcMatches = [regex]::Matches($content, $funcPattern)
    foreach ($m in $funcMatches) {
        $results += [PSCustomObject]@{
            Type = "FUNCTION"
            Name = $m.Groups[1].Value
        }
    }

    # Procedures: CREATE OR REPLACE PROCEDURE name(...)
    $procPattern = 'CREATE\s+OR\s+REPLACE\s+PROCEDURE\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\('
    $procMatches = [regex]::Matches($content, $procPattern)
    foreach ($m in $procMatches) {
        $results += [PSCustomObject]@{
            Type = "PROCEDURE"
            Name = $m.Groups[1].Value
        }
    }

    # Triggers: CREATE TRIGGER name ...
    $trigPattern = 'CREATE\s+(?:OR\s+REPLACE\s+)?TRIGGER\s+([a-zA-Z_][a-zA-Z0-9_]*)\s+'
    $trigMatches = [regex]::Matches($content, $trigPattern)
    foreach ($m in $trigMatches) {
        $results += [PSCustomObject]@{
            Type = "TRIGGER"
            Name = $m.Groups[1].Value
        }
    }

    # Views: CREATE OR REPLACE VIEW name ...
    $viewPattern = 'CREATE\s+OR\s+REPLACE\s+VIEW\s+([a-zA-Z_][a-zA-Z0-9_]*)\s+'
    $viewMatches = [regex]::Matches($content, $viewPattern)
    foreach ($m in $viewMatches) {
        $results += [PSCustomObject]@{
            Type = "VIEW"
            Name = $m.Groups[1].Value
        }
    }
}

# 2. Parse the pg_dump file for completeness
$dumpFile = Join-Path $dbRoot "IntegratedAccSys_pg_dump.sql"
if (Test-Path $dumpFile) {
    $dumpContent = Get-Content $dumpFile -Raw -ErrorAction SilentlyContinue

    # CREATE FUNCTION name()
    $funcPattern = 'CREATE\s+FUNCTION\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\('
    $funcMatches = [regex]::Matches($dumpContent, $funcPattern)
    foreach ($m in $funcMatches) {
        $results += [PSCustomObject]@{
            Type = "FUNCTION"
            Name = $m.Groups[1].Value
        }
    }

    # CREATE PROCEDURE name()
    $procPattern = 'CREATE\s+PROCEDURE\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\('
    $procMatches = [regex]::Matches($dumpContent, $procPattern)
    foreach ($m in $procMatches) {
        $results += [PSCustomObject]@{
            Type = "PROCEDURE"
            Name = $m.Groups[1].Value
        }
    }
}

# Deduplicate
$results = $results | Sort-Object -Property Type, Name -Unique

Write-Host "=== DATABASE OBJECTS (Functions / Procedures / Triggers / Views) ===" -ForegroundColor Cyan
$results | Group-Object Type | ForEach-Object {
    Write-Host ""
    Write-Host "$($_.Name): $($_.Count)" -ForegroundColor Yellow
    $_.Group | Select-Object -ExpandProperty Name | Sort-Object | ForEach-Object { Write-Host "  $_" }
}
