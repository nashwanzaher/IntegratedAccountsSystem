$v = Get-Content 'scripts\naming-violations.json' -Raw | ConvertFrom-Json
Write-Host ('Total: ' + $v.Count)
Write-Host ''
Write-Host 'By Severity:'
$v | Group-Object Severity | ForEach-Object { Write-Host ('  ' + $_.Name + ': ' + $_.Count) }
Write-Host ''
Write-Host 'By Kind:'
$v | Group-Object Kind | ForEach-Object { Write-Host ('  ' + $_.Name + ': ' + $_.Count) }
Write-Host ''
Write-Host 'Top 20 most-referenced violations:'
$v | Sort-Object RefCount -Descending | Select-Object -First 20 Identifier, Kind, RefCount, File, Line | Format-Table -AutoSize
Write-Host ''
Write-Host 'By file (top 10):'
$v | Group-Object File | Sort-Object Count -Descending | Select-Object -First 10 Count, Name | Format-Table -AutoSize
