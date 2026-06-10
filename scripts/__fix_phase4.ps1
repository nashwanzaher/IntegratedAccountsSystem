$file = "d:\source\IntegratedAccountsSystem\database\IntegratedAccSys_Dimensions_Phase4.sql"
$content = Get-Content $file -Raw
$content = $content -replace 'tblusers\(userno\)', 'tblusers(usercode)'
Set-Content -Path $file -Value $content -NoNewline
Write-Host "Fixed: replaced tblusers(userno) with tblusers(usercode)"
$count = ([regex]::Matches((Get-Content $file -Raw), 'tblusers\(userno\)')).Count
Write-Host "Remaining userno refs: $count"
$count2 = ([regex]::Matches((Get-Content $file -Raw), 'tblusers\(usercode\)')).Count
Write-Host "usercode refs now: $count2"
