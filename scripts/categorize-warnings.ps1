$w = Select-String -Path 'build.log' -Pattern 'warning CS\d+:'
$counts = @{}
foreach ($line in $w) {
    $code = ($line -split 'warning CS')[1] -split ':' | Select-Object -First 1
    if (-not $counts.ContainsKey($code)) { $counts[$code] = 0 }
    $counts[$code]++
}
$counts.GetEnumerator() | Sort-Object Value -Descending | Format-Table -AutoSize
