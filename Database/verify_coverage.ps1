# C# Routine Coverage Verification
# Parses every cn.SelectData/ExecuteCmd call site, extracts routine name + NpgsqlParameter array size
# in the enclosing method, and matches against DB signatures (sigs.txt).

$csRoot = "D:\source\IntegratedAccountsSystem"
$sigsFile = Join-Path $csRoot "Database\sigs.txt"
$outFile = Join-Path $csRoot "Database\coverage_report.txt"

# 1. Load DB signatures into hashtable: name -> array of {Count, Kind, Oid}
$dbSigs = @{}
Get-Content $sigsFile -Encoding UTF8 | ForEach-Object {
    $line = $_.Trim()
    if ($line -match '^([\w]+)\|(PROCEDURE|FUNCTION)\|(.*?)\|(\d+)(?:\|(\d+))?$') {
        $name = $Matches[1].ToLower()
        $count = [int]$Matches[4]
        $kind = $Matches[2]
        $oid = if ($Matches[5]) { [int]$Matches[5] } else { 0 }
        if (-not $dbSigs.ContainsKey($name)) { $dbSigs[$name] = New-Object System.Collections.Generic.List[object] }
        $dbSigs[$name].Add([pscustomobject]@{ Count = $count; Kind = $kind; Oid = $oid })
    }
}

$totalOverloads = ($dbSigs.Values | Measure-Object).Count
Write-Host ("DB routines loaded: {0} (with {1} total overloads)" -f $dbSigs.Count, $totalOverloads) -ForegroundColor Cyan

# 2. Walk every .cs file, extract SelectData / ExecuteCmd call sites
$csFiles = Get-ChildItem -Path $csRoot -Recurse -Filter *.cs -ErrorAction SilentlyContinue |
Where-Object { $_.FullName -notmatch '\\(obj|bin)\\' }

# Pattern: cn.SelectData("name", X)  or  cn.ExecuteCmd("name", X)
# We'll walk the file with a balanced-paren helper to capture X exactly,
# then determine if X is 'null' or a NpgsqlParameter[] variable, then count
# NpgsqlParameter[N] declarations + assignments in the enclosing method.

$report = New-Object System.Collections.Generic.List[object]
$seen = @{}  # dedupe per (name, file, line)

foreach ($f in $csFiles) {
    $content = Get-Content $f.FullName -Raw -Encoding UTF8
    $lines = $content -split "`r?`n"

    # Find every cn.SelectData/ExecuteCmd( occurrence with index in flat text
    $rxHead = [regex]'(?s)cn\.(SelectData|ExecuteCmd)\s*\(\s*"([^"]+)"\s*,'
    $heads = $rxHead.Matches($content)

    foreach ($h in $heads) {
        $routine = $h.Groups[2].Value
        $openIdx = $h.Index + $h.Length  # index right after the second ","
        # Walk to find the matching closing paren
        $depth = 1
        $i = $openIdx
        while ($i -lt $content.Length -and $depth -gt 0) {
            $ch = $content[$i]
            if ($ch -eq '(') { $depth++ }
            elseif ($ch -eq ')') { $depth--; if ($depth -eq 0) { break } }
            $i++
        }
        $argBlock = $content.Substring($openIdx, $i - $openIdx).Trim()

        # Compute call site line number
        $lineNo = ($content.Substring(0, $h.Index) -split "`n").Count
        $lineText = $lines[$lineNo - 1]

        # Determine the array variable name (or null)
        $csCount = 0
        if ($argBlock -ieq 'null' -or $argBlock -eq '') {
            $csCount = 0
        }
        else {
            # Capture the variable name — first identifier after stripping decorations
            $varName = ''
            if ($argBlock -match '^\s*([A-Za-z_]\w*)') { $varName = $Matches[1] }
            if ($varName -eq '') { $csCount = -1 }
            else {
                # Walk backwards from the call line to find the enclosing method's `{` line.
                # Track brace depth; stop at depth == 0 going backwards.
                $depth = 0
                $scopeStart = 0
                for ($li = $lineNo - 1; $li -ge 0; $li--) {
                    $ln = $lines[$li]
                    for ($ci = $ln.Length - 1; $ci -ge 0; $ci--) {
                        $ch = $ln[$ci]
                        if ($ch -eq '}') { $depth++ }
                        elseif ($ch -eq '{') {
                            if ($depth -eq 0) {
                                $scopeStart = $li
                                break
                            }
                            else {
                                $depth--
                            }
                        }
                    }
                    if ($scopeStart -gt 0) { break }
                }
                $scopeText = ($lines[$scopeStart..($lineNo - 1)] -join "`n")

                # Count NpgsqlParameter constructors in the scope, scoped to our variable name.
                # Patterns supported:
                #   1) NpgsqlParameter[] para = new NpgsqlParameter[N]   -> size N
                #   2) NpgsqlParameter[] para = new NpgsqlParameter[] { new NpgsqlParameter(...), ... }
                #      -> count of `new NpgsqlParameter (` inside the {...}
                #   3) NpgsqlParameter[] para = new NpgsqlParameter[N] { ... } -> size N OR count, take max
                # Also: para[0] = new NpgsqlParameter(...); ...

                $csCount = 0

                # Pattern 1: explicit numeric size
                $sizeRx = [regex]('new\s+NpgsqlParameter\[(\d+)\]')
                $sizeMatches = $sizeRx.Matches($scopeText)
                $explicitSize = 0
                foreach ($sm in $sizeMatches) {
                    $n = [int]$sm.Groups[1].Value
                    if ($n -gt $explicitSize) { $explicitSize = $n }
                }

                # Pattern 2: count of `new NpgsqlParameter (` constructor calls in scope
                $ctorRx = [regex]'new\s+NpgsqlParameter\s*\('
                $ctorCount = $ctorRx.Matches($scopeText).Count

                # Pattern 3: count of `varName[i] = ...` assignments
                $assignRx = [regex](("\b{0}\[\d+\]\s*=") -f [regex]::Escape($varName))
                $assignCount = $assignRx.Matches($scopeText).Count

                # Combine: take the maximum of the three heuristics (any one is reliable)
                $csCount = [Math]::Max($explicitSize, [Math]::Max($ctorCount, $assignCount))
            }
        }

        $key = "{0}|{1}|{2}" -f $routine.ToLower(), $f.Name, $lineNo
        if ($seen.ContainsKey($key)) { continue }
        $seen[$key] = $true

        $db = $dbSigs[$routine.ToLower()]
        $status = 'MISSING'
        $dbCount = '-'
        $dbKind = '-'
        if ($db -and $db.Count -gt 0) {
            # Multiple overloads possible. Find any overload with matching count.
            $matched = $db | Where-Object { $_.Count -eq $csCount } | Select-Object -First 1
            if ($matched) {
                $dbCount = $matched.Count
                $dbKind = $matched.Kind
                $status = 'OK'
            }
            else {
                # No overload matches. Show first overload's count + the closest we could match.
                $first = $db | Select-Object -First 1
                $dbCount = $first.Count
                $dbKind = $first.Kind
                $status = 'MISMATCH'
            }
        }
        elseif ($db) {
            $first = $db | Select-Object -First 1
            $dbCount = $first.Count
            $dbKind = $first.Kind
            if ($csCount -eq $dbCount) { $status = 'OK' } else { $status = 'MISMATCH' }
        }
        if ($csCount -lt 0) { $status = 'PARSE_FAIL' }

        $report.Add([pscustomobject]@{
                Routine = $routine
                CsArgs  = $csCount
                DbArgs  = $dbCount
                DbKind  = $dbKind
                Status  = $status
                File    = $f.Name
                Line    = $lineNo
            })
    }
}

# 3. Summarize
$ok = ($report | Where-Object Status -eq 'OK').Count
$miss = ($report | Where-Object Status -eq 'MISSING').Count
$mismatch = ($report | Where-Object Status -eq 'MISMATCH').Count
$parse = ($report | Where-Object Status -eq 'PARSE_FAIL').Count

Write-Host ("OK: {0}  MISMATCH: {1}  MISSING: {2}  PARSE_FAIL: {3}  TOTAL: {4}" -f `
        $ok, $mismatch, $miss, $parse, $report.Count) `
    -ForegroundColor $(if ($miss -eq 0 -and $mismatch -eq 0 -and $parse -eq 0) { 'Green' } else { 'Yellow' })

# 4. Emit report (group by status, sort MISMATCH/MISSING first)
$sorted = @($report | Sort-Object Status, Routine)
$out = New-Object System.Collections.Generic.List[string]
$out.Add(('Coverage report generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')))
$out.Add(('Total unique C# call sites: {0}' -f $report.Count))
$out.Add(('OK: {0}  |  MISMATCH: {1}  |  MISSING: {2}  |  PARSE_FAIL: {3}' -f $ok, $mismatch, $miss, $parse))
$out.Add('')
$out.Add(('-' * 110))
$out.Add(('  {0,-30} {1,5} {2,5} {3,-10} {4,-12} {5,-32} {6}' -f `
            'Routine', 'CsArg', 'DbArg', 'DbKind', 'Status', 'File', 'Line'))
$out.Add(('-' * 110))
foreach ($r in $sorted) {
    $tag = switch ($r.Status) {
        'OK' { 'OK' }
        'MISMATCH' { '!!' }
        'MISSING' { 'XX' }
        'PARSE_FAIL' { '??' }
    }
    $out.Add(('  {0,-30} {1,5} {2,5} {3,-10} {4,-12} {5,-32} {6}' -f `
                $r.Routine, $r.CsArgs, $r.DbArgs, $r.DbKind, $tag, $r.File, $r.Line))
}
$out -join "`n" | Set-Content -Path $outFile -Encoding UTF8

# Also dump just the problem rows for quick view
$problems = $report | Where-Object { $_.Status -ne 'OK' } | Sort-Object Status, Routine
if ($problems.Count -gt 0) {
    Write-Host "`n--- PROBLEMS ---" -ForegroundColor Yellow
    $problems | Format-Table -AutoSize
}
else {
    Write-Host "`nAll C# call sites match DB signatures." -ForegroundColor Green
}

Write-Host "`nFull report: $outFile"
