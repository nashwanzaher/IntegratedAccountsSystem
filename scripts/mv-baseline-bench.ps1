# mv-baseline-bench.ps1 - Simpler benchmark
$env:PGPASSWORD = '656650'
$psql = 'C:\Program Files\PostgreSQL\17\bin\psql.exe'
$db = 'IntegratedAccSys'

function RunSqlFile([string]$Path, [string]$Label) {
    Write-Host "--- $Label ---" -ForegroundColor Cyan
    & $psql -h localhost -U postgres -d $db -f $Path 2>&1 | Select-String -Pattern 'NOTICE|ERROR|INSERT' | Select-Object -First 10
    Write-Host ""
}

function RunSql([string]$Sql, [string]$Label) {
    Write-Host "--- $Label ---" -ForegroundColor Cyan
    & $psql -h localhost -U postgres -d $db -c $Sql 2>&1
    Write-Host ""
}

# 1. Initial counts
RunSql "SELECT 'bonds' AS entity, COUNT(*) AS total FROM tblbondheader UNION ALL SELECT 'journals', COUNT(*) FROM tbljournalheader UNION ALL SELECT 'journal_body', COUNT(*) FROM tbljournalbody UNION ALL SELECT 'bond_body', COUNT(*) FROM tblbondbody UNION ALL SELECT 'customers', COUNT(*) FROM tblcustomers UNION ALL SELECT 'products', COUNT(*) FROM tblproducts ORDER BY entity;" "1. Initial Row Counts"
