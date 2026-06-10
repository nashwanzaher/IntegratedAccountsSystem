$base = 'D:\source\IntegratedAccountsSystem\src\IntegratedAccSys'

Write-Host "=== PL FORMS ===" -ForegroundColor Green
$forms = Get-ChildItem -Path "$base.PL" -Recurse -Filter 'frm*.cs' -ErrorAction SilentlyContinue | Where-Object { $_.Name -notlike '*.Designer.cs' } | Select-Object -ExpandProperty BaseName -Unique | Sort-Object
$forms | ForEach-Object { Write-Host "  $_" }
Write-Host "Total: $($forms.Count)" -ForegroundColor Yellow

Write-Host ""
Write-Host "=== BL CLASSES ===" -ForegroundColor Green
$blClasses = Get-ChildItem -Path "$base.BL" -Recurse -Filter '*.cs' -ErrorAction SilentlyContinue | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    [regex]::Matches($content, '(?ms)public\s+(static\s+)?class\s+(\w+)') | ForEach-Object { $_.Groups[2].Value }
} | Sort-Object -Unique
$blClasses | ForEach-Object { Write-Host "  $_" }
Write-Host "Total: $($blClasses.Count)" -ForegroundColor Yellow

Write-Host ""
Write-Host "=== DAL CLASSES ===" -ForegroundColor Green
$dalClasses = Get-ChildItem -Path "$base.DAL" -Recurse -Filter '*.cs' -ErrorAction SilentlyContinue | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    [regex]::Matches($content, '(?ms)public\s+(static\s+)?class\s+(\w+)') | ForEach-Object { $_.Groups[2].Value }
} | Sort-Object -Unique
$dalClasses | ForEach-Object { Write-Host "  $_" }
Write-Host "Total: $($dalClasses.Count)" -ForegroundColor Yellow

Write-Host ""
Write-Host "=== BL DB CALLS (sample 30) ===" -ForegroundColor Green
$blCalls = @{}
Get-ChildItem -Path "$base.BL" -Recurse -Filter '*.cs' -ErrorAction SilentlyContinue | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    [regex]::Matches($content, 'cn\.(SelectData|ExecuteCmd)\s*\(\s*"([a-zA-Z_][a-zA-Z0-9_]*)"') | ForEach-Object { $_.Groups[2].Value }
} | ForEach-Object {
    if ($blCalls.ContainsKey($_)) { $blCalls[$_]++ } else { $blCalls[$_] = 1 }
}
$blCalls.GetEnumerator() | Sort-Object Name | Select-Object -First 30 | ForEach-Object {
    Write-Host ("  {0,-40} {1,4} calls" -f $_.Key, $_.Value)
}
Write-Host "Total: $($blCalls.Count)" -ForegroundColor Yellow
