$file = "d:\source\IntegratedAccountsSystem\database\IntegratedAccSys_Dimensions_Phase4.sql"
$content = Get-Content $file -Raw

# Fix sourcetype: DIMENSION -> OTHER (since 'DIMENSION' not in CHECK constraint)
$content = $content.Replace("'DIMENSION',", "'OTHER',")
$content = $content.Replace("sourcetype='DIMENSION'", "sourcetype='OTHER'")

Set-Content -Path $file -Value $content -NoNewline
Write-Host "Fixed sourcetype: DIMENSION -> OTHER"
$count = ([regex]::Matches((Get-Content $file -Raw), "'DIMENSION'")).Count
Write-Host "'DIMENSION' remaining: $count"
