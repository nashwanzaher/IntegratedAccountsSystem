# Trace all stored procedure / function calls from BL to DAL

$blRoot = "d:\source\IntegratedAccountsSystem\src\IntegratedAccSys.BL"
$results = @()

Get-ChildItem -Path $blRoot -Recurse -Filter "*.cs" | ForEach-Object {
    $file = $_.FullName
    $rel = $file.Substring($blRoot.Length + 1)
    $content = Get-Content $file -Raw -ErrorAction SilentlyContinue
    if (-not $content) { return }

    # Find calls: cn.SelectData("name", ...), cn.ExecuteCmd("name", ...), etc.
    $pattern = 'cn\.(SelectData|ExecuteCmd)\s*\(\s*["\x27]([^"\x27]+)["\x27]'
    $matches = [regex]::Matches($content, $pattern)
    foreach ($m in $matches) {
        $results += [PSCustomObject]@{
            Layer   = "BL"
            File    = $rel
            Class   = ($rel -replace '\\.*$', '')
            Method  = $m.Groups[1].Value
            SP_Name = $m.Groups[2].Value
        }
    }
}

# Sort by SP name
$results | Sort-Object -Property SP_Name, File | Format-Table -AutoSize -Wrap
Write-Host ""
Write-Host "=== UNIQUE SPs CALLED FROM BL ===" -ForegroundColor Cyan
$results | Sort-Object -Property SP_Name | Select-Object -ExpandProperty SP_Name -Unique
