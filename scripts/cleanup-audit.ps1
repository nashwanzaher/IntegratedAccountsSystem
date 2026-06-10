# cleanup-audit.ps1 - Phase 1: Pre-cleanup audit
$base = 'D:\source\IntegratedAccountsSystem'
$stamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')

Write-Host "============================================" -ForegroundColor Yellow
Write-Host "  CLEANUP AUDIT - PHASE 0 (BASELINE)" -ForegroundColor Yellow
Write-Host "  $stamp" -ForegroundColor Gray
Write-Host "============================================" -ForegroundColor Yellow
Write-Host ""

# 1. Root files inventory
Write-Host "--- 1. Root directory files (excluding dirs) ---" -ForegroundColor Cyan
Get-ChildItem -Path $base -File -Force | ForEach-Object {
    $size = "{0:N0}" -f $_.Length
    Write-Host ("  {0,-50} {1,12} bytes  {2}" -f $_.Name, $size, $_.LastWriteTime.ToString('yyyy-MM-dd'))
} | Format-Table -AutoSize

# 2. Find log/txt files at root
Write-Host "--- 2. Loose log/txt files at root (CANDIDATES FOR DELETION) ---" -ForegroundColor Cyan
Get-ChildItem -Path $base -File -Force -Include *.log, *.txt, *.sql, *.bak, *.tmp | ForEach-Object {
    $size = "{0:N0}" -f $_.Length
    Write-Host ("  X  {0,-50} {1,12} bytes" -f $_.Name, $size) -ForegroundColor Red
}

# 3. Hidden/temp directories
Write-Host "--- 3. Hidden / temp directories ---" -ForegroundColor Cyan
Get-ChildItem -Path $base -Directory -Force | Where-Object { $_.Attributes -band [System.IO.FileAttributes]::Hidden } | ForEach-Object {
    Write-Host ("  H  {0,-50} Hidden" -f $_.Name) -ForegroundColor Yellow
}
Get-ChildItem -Path $base -Directory -Force | Where-Object { $_.Name -like ".*backup*" -or $_.Name -like "*.tmp" -or $_.Name -like ".continue*" } | ForEach-Object {
    Write-Host ("  B  {0,-50} {1} items" -f $_.Name, (Get-ChildItem $_.FullName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object).Count) -ForegroundColor Yellow
}

# 4. bin/obj directories
Write-Host "--- 4. Build artifact directories (bin/obj) ---" -ForegroundColor Cyan
Get-ChildItem -Path $base -Directory -Recurse -Force -Include bin, obj -ErrorAction SilentlyContinue | ForEach-Object {
    $items = (Get-ChildItem $_.FullName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object).Count
    Write-Host ("  B  {0,-80} {1} items" -f $_.FullName.Substring($base.Length+1), $items)
}

# 5. Solution structure
Write-Host "--- 5. Solution structure (projects) ---" -ForegroundColor Cyan
Get-Content "$base\IntegratedAccSys.sln" | Select-String "Project\(" | ForEach-Object {
    Write-Host ("  " + $_.Line.Trim()) -ForegroundColor Green
}

# 6. Database folder inventory
Write-Host "--- 6. database/ folder inventory ---" -ForegroundColor Cyan
Get-ChildItem -Path "$base\database" -File | ForEach-Object {
    $size = "{0:N0}" -f $_.Length
    Write-Host ("  {0,-50} {1,12} bytes" -f $_.Name, $size)
}

# 7. Scripts folder - count and identify obsolete
Write-Host "--- 7. scripts/ folder inventory ---" -ForegroundColor Cyan
$count = (Get-ChildItem -Path "$base\scripts" -File).Count
Write-Host "  Total: $count files"
Get-ChildItem -Path "$base\scripts" -File | ForEach-Object {
    $size = "{0:N0}" -f $_.Length
    Write-Host ("  {0,-50} {1,12} bytes  {2}" -f $_.Name, $size, $_.LastWriteTime.ToString('yyyy-MM-dd'))
}

# 8. Project structure verification
Write-Host "--- 8. Project structure verification ---" -ForegroundColor Cyan
$projects = @("DAL", "BL", "PL")
foreach ($p in $projects) {
    $dir = "$base\src\IntegratedAccSys.$p"
    $cs = (Get-ChildItem -Path $dir -Filter "*.cs" -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
    $csproj = Test-Path "$dir\IntegratedAccSys.$p.csproj"
    Write-Host ("  IntegratedAccSys.$p : {0} .cs files, csproj exists: {1}" -f $cs, $csproj)
}

# 9. Build verification
Write-Host "--- 9. Build verification ---" -ForegroundColor Cyan
$buildOutput = dotnet build "$base\IntegratedAccSys.sln" -c Release 2>&1 | Out-String
if ($buildOutput -match "Build succeeded") {
    $errors = ($buildOutput | Select-String "Error\(s\)" | ForEach-Object { $_.Line })
    $warnings = ($buildOutput | Select-String "Warning\(s\)" | ForEach-Object { $_.Line })
    Write-Host "  Build: OK" -ForegroundColor Green
    Write-Host "  $($errors -join '; ')"
    Write-Host "  $($warnings -join '; ')"
} else {
    Write-Host "  Build: FAILED" -ForegroundColor Red
    Write-Host $buildOutput
}

# 10. DbTest verification
Write-Host "--- 10. DbTest verification ---" -ForegroundColor Cyan
$dbtest = dotnet run --project "$base\tests\IntegratedAccSys.DAL.DbTest\IntegratedAccSys.DAL.DbTest.csproj" -c Release --no-build 2>&1 | Out-String
$summary = ($dbtest | Select-String "SUMMARY" | ForEach-Object { $_.Line })
Write-Host "  $summary"

# 11. .gitignore coverage
Write-Host "--- 11. .gitignore coverage check ---" -ForegroundColor Cyan
$gi = Get-Content "$base\.gitignore"
$patterns = @('*.bak', '*.log', 'bin/', 'obj/', '.vs/', '.idea/', '*.tmp', '.opencode/')
foreach ($p in $patterns) {
    $covered = $gi | Where-Object { $_ -like "*$p*" }
    if ($covered) {
        Write-Host "  [OK]   $p" -ForegroundColor Green
    } else {
        Write-Host "  [GAP]  $p - NOT IN .gitignore" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Yellow
Write-Host "  AUDIT COMPLETE" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Yellow
