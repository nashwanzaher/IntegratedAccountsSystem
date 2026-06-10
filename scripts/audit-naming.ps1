# Find all class names in src/ that contain 'cls' prefix or have lowercase naming
$results = @()
Get-ChildItem -Path 'src' -Recurse -Filter '*.cs' | ForEach-Object {
    $content = Get-Content $_.FullName
    $lineNum = 0
    foreach ($line in $content) {
        $lineNum++
        # Match class declarations
        if ($line -match '\bclass\s+([a-zA-Z_][a-zA-Z0-9_]*)') {
            $className = $Matches[1]
            $isLowercase = $className -cmatch '^[a-z]'
            $hasOldPrefix = $className -cmatch '^cls' -or $className -cmatch '^frm'
            if ($isLowercase -or $hasOldPrefix) {
                $results += [PSCustomObject]@{
                    File = $_.FullName -replace [regex]::Escape((Get-Location).Path + '\'), ''
                    Line = $lineNum
                    ClassName = $className
                    Issue = if ($isLowercase) { 'Lowercase class name' } else { 'Old cls/frm prefix' }
                }
            }
        }
    }
}
$results | Format-Table -AutoSize
