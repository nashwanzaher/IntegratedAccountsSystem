$file = "d:\source\IntegratedAccountsSystem\database\IntegratedAccSys_Dimensions_Phase4.sql"
$content = Get-Content $file -Raw
# Fix all userno → usercode (any alias)
$content = $content -replace 'u\.userno', 'u.usercode'
# Fix username (doesn't exist) → usernamear
$content = $content -replace 'u\.username', 'u.usernamear'
# Fix managerusername → managerusernamear in RETURN clause
$content = $content -replace 'managerusername VARCHAR', 'managerusernamear VARCHAR'
Set-Content -Path $file -Value $content -NoNewline
Write-Host "Fixes applied."
$patterns = @('u\.userno', 'u\.username[^a]')
foreach ($p in $patterns) {
    $c = ([regex]::Matches((Get-Content $file -Raw), $p)).Count
    Write-Host "Pattern '$p' remaining: $c"
}
