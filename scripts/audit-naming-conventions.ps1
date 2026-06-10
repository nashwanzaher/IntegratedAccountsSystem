# Naming Conventions Audit Script
# Scans src/ and tests/ for Microsoft .NET naming convention violations.
# Produces a comprehensive violation list only.
# NO modifications, NO renames, NO code generation.

# Microsoft .NET Naming Conventions:
#   PascalCase: Classes, Methods, Properties, Events, Namespaces, Enums, Public fields
#   camelCase:  Parameters, Local variables
#   _camelCase: Private fields (some style guides) OR plain camelCase
#   IPascalCase: Interfaces (I prefix)
#   Allowed:   Generic Type Parameters T, TKey, TValue

$ErrorActionPreference = 'SilentlyContinue'
$results = @()

# Define known typos and Hungarian prefixes
$hungarianPrefixes = @{
    'cls' = 'Hungarian cls prefix (legacy VB6 style) - use plain PascalCase'
    'frm' = 'Hungarian frm prefix (legacy VB6 style) - use plain PascalCase'
    'txt' = 'Hungarian txt prefix (WinForms control naming) - use descriptive name'
    'btn' = 'Hungarian btn prefix (WinForms control naming) - use descriptive name'
    'lbl' = 'Hungarian lbl prefix (WinForms control naming) - use descriptive name'
    'dgv' = 'Hungarian dgv prefix (WinForms control naming) - use descriptive name'
    'cb'  = 'Hungarian cb prefix (ComboBox) - use descriptive name'
    'pb'  = 'Hungarian pb prefix (PictureBox) - use descriptive name'
    'tab' = 'Hungarian tab prefix (TabPage) - use descriptive name'
    'grp' = 'Hungarian grp prefix (GroupBox) - use descriptive name'
    'txtInvCode' = 'Non-PascalCase field (txtInvCode) - should be TxtInvCode or removed'
}

# Known typos (deliberate or unintentional)
$knownTypos = @{
    'Suppleirs' = 'Suppliers'
    'Suppleir'  = 'Supplier'
    'Invventroy' = 'Inventory'
    'Cusromer'  = 'Customer'
    'Privillages' = 'Privileges'
    'TrailBalance' = 'TrialBalance'
    'Jst' = 'Just'
    'Persistance' = 'Persistence'
}

# Unusual abbreviations
$abbreviationPatterns = @{
    'Pur' = 'Should be "Purchases" or "Purchase" (current: "Pur" is unclear)'
    'jNo' = 'Could be "JournalNumber" for clarity'
    'jDate' = 'Could be "JournalDate" for clarity'
    'jNote' = 'Could be "JournalNote" for clarity'
    'jType' = 'Could be "JournalType" for clarity'
    'jPost' = 'Could be "JournalPosted" for clarity'
    'braCode' = 'Could be "BranchCode" for clarity (Hungarian abbreviation)'
    'custCode' = 'Could be "CustomerCode" for clarity'
    'suppCode' = 'Could be "SupplierCode" for clarity'
    'suppName' = 'Could be "SupplierName" for clarity'
    'suppAccCode' = 'Could be "SupplierAccountCode" for clarity'
    'accCode' = 'Could be "AccountCode" for clarity'
    'currID' = 'Could be "CurrencyId" (mixed case - violates camelCase)'
    'currVal' = 'Could be "CurrencyValue" for clarity'
    'accDebitor' = 'Could be "AccountDebit" (typo: Debitor should be Debit)'
    'accCreditor' = 'Could be "AccountCredit" for clarity'
    'accBalance' = 'Could be "AccountBalance" for clarity'
    'userAdd' = 'Could be "UserAdded" for clarity'
    'userEdit' = 'Could be "UserEdited" for clarity'
    'addDate' = 'Could be "AddedDate" for clarity'
    'editDate' = 'Could be "EditedDate" for clarity'
    'addSuppleir' = 'Should be "AddSupplier" (typo + capitalization)'
    'editSuppleir' = 'Should be "EditSupplier" (typo + capitalization)'
    'delSupplier' = 'Should be "DeleteSupplier" (use full word)'
    'delCustomer' = 'Should be "DeleteCustomer" (use full word)'
    'opType' = 'Could be "OperationType" for clarity'
    'bondPost' = 'Could be "BondPosted" for clarity'
    'postStatus' = 'Could be "PostedStatus" for clarity'
    'fromDate' = 'Could be "FromDate" for clarity'
    'toDate' = 'Could be "ToDate" for clarity'
    'testImage' = 'Should be "TestImage" - but field name is odd (purpose unclear)'
}

# Common abbreviations that are acceptable in .NET (do NOT flag)
$acceptableAbbreviations = @{
    'Id' = $true; 'Db' = $true; 'UI' = $true; 'BL' = $true;
    'PL' = $true; 'DAL' = $true; 'SQL' = $true; 'JSON' = $true;
    'API' = $true; 'URL' = $true; 'URI' = $true; 'PDF' = $true; 'CSV' = $true;
    'XSL' = $true; 'XSLT' = $true; 'HTML' = $true; 'CSS' = $true;
    'OK' = $true; 'GUID' = $true; 'SKU' = $true; 'VAT' = $true
}

# ============================================
# SCAN ALL C# FILES
# ============================================
$csFiles = Get-ChildItem -Path 'src','tests' -Recurse -Filter '*.cs' |
    Where-Object { $_.FullName -notmatch '\\(bin|obj)\\' -and $_.FullName -notmatch 'Designer' }

Write-Host "Scanning $($csFiles.Count) .cs files..." -ForegroundColor Cyan
Write-Host ""

# Initialize result collection
$violations = @()

# Build reference count for cross-checking
$refCounts = @{}
foreach ($f in $csFiles) {
    $content = Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue
    if (-not $content) { continue }
    # Find all identifier-like words
    $tokens = [regex]::Matches($content, '[A-Za-z_][A-Za-z0-9_]{2,}')
    foreach ($t in $tokens) {
        $w = $t.Value
        if (-not $refCounts.ContainsKey($w)) { $refCounts[$w] = 0 }
        $refCounts[$w]++
    }
}

# ============================================
# Helper: Determine if identifier violates
# ============================================
function Get-NamingViolationKind {
    param([string]$Identifier, [string]$Context)
    $id = $Identifier
    $firstChar = $id[0]

    # 1. All-lowercase: definitely wrong
    if ($id -cnotmatch '[A-Z]' -and $id -cmatch '[a-z]') {
        return @('CRITICAL', 'All lowercase identifier', 'Identifier starts with lowercase and contains no uppercase letters. Violates PascalCase/camelCase.')
    }
    # 2. Hungarian prefix
    foreach ($p in @('cls','frm','txt','btn','lbl','dgv','cb','pb','tab','grp')) {
        if ($id -cmatch "^$p[A-Z]" -and $id.Length -gt $p.Length) {
            $next = $id.Substring($p.Length, 1)
            if ($next -cnotmatch '^[A-Z]') { continue }  # only if next is uppercase
            if ($id.Substring($p.Length) -cnotmatch '^[A-Z]') { continue }
            return @('HIGH', "Hungarian prefix '$p'", "Legacy VB6-style prefix '$p' is non-conformant to .NET naming guidelines.")
        }
    }
    return $null
}

# ============================================
# Scan 1: CLASS NAMES
# ============================================
Write-Host "[1/7] Scanning class declarations..." -ForegroundColor Yellow
$classPattern = '\b(?:public|internal|private|protected)?\s*(?:static\s+|abstract\s+|sealed\s+|partial\s+)*class\s+([A-Za-z_][A-Za-z0-9_]*)'
foreach ($f in $csFiles) {
    $content = Get-Content $f.FullName -Raw
    $matches = [regex]::Matches($content, $classPattern)
    foreach ($m in $matches) {
        $name = $m.Groups[1].Value
        $line = ($content.Substring(0, $m.Groups[1].Index) -split "`n").Count
        $kind = Get-NamingViolationKind -Identifier $name -Context "class"
        if ($kind) {
            $violations += [PSCustomObject]@{
                Severity     = $kind[0]
                Kind         = "Class"
                Identifier   = $name
                File         = $f.FullName -replace [regex]::Escape((Get-Location).Path + '\'), ''
                Line         = $line
                Issue        = $kind[1]
                Impact       = $kind[2]
                RefCount     = $refCounts[$name]
            }
        }
    }
}

# ============================================
# Scan 2: METHOD NAMES
# ============================================
Write-Host "[2/7] Scanning method declarations..." -ForegroundColor Yellow
$methodPattern = '\b(?:public|internal|private|protected|static|virtual|override|abstract|sealed|async|extern|partial|new|readonly|unsafe)\s*[\w<>,\[\]\?\s]*\s+([A-Za-z_][A-Za-z0-9_]*)\s*\('
foreach ($f in $csFiles) {
    $content = Get-Content $f.FullName -Raw
    $matches = [regex]::Matches($content, $methodPattern)
    foreach ($m in $matches) {
        $name = $m.Groups[1].Value
        # Skip well-known non-method names
        if ($name -in @('if','for','while','switch','catch','return','typeof','sizeof','new','throw','using','lock')) { continue }
        $line = ($content.Substring(0, $m.Groups[1].Index) -split "`n").Count
        $kind = Get-NamingViolationKind -Identifier $name -Context "method"
        if ($kind) {
            $violations += [PSCustomObject]@{
                Severity     = $kind[0]
                Kind         = "Method"
                Identifier   = $name
                File         = $f.FullName -replace [regex]::Escape((Get-Location).Path + '\'), ''
                Line         = $line
                Issue        = $kind[1]
                Impact       = $kind[2]
                RefCount     = $refCounts[$name]
            }
        }
    }
}

# ============================================
# Scan 3: PROPERTY NAMES (public/internal)
# ============================================
Write-Host "[3/7] Scanning property declarations..." -ForegroundColor Yellow
$propPattern = '\b(?:public|internal|protected)\s+(?:static\s+|virtual\s+|override\s+|abstract\s+|sealed\s+|readonly\s+)*([A-Za-z_][\w<>\?,\s\[\]]*?)\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{'
foreach ($f in $csFiles) {
    $content = Get-Content $f.FullName -Raw
    $matches = [regex]::Matches($content, $propPattern)
    foreach ($m in $matches) {
        $name = $m.Groups[2].Value
        $line = ($content.Substring(0, $m.Groups[2].Index) -split "`n").Count
        $kind = Get-NamingViolationKind -Identifier $name -Context "property"
        if ($kind) {
            $violations += [PSCustomObject]@{
                Severity     = $kind[0]
                Kind         = "Property"
                Identifier   = $name
                File         = $f.FullName -replace [regex]::Escape((Get-Location).Path + '\'), ''
                Line         = $line
                Issue        = $kind[1]
                Impact       = $kind[2]
                RefCount     = $refCounts[$name]
            }
        }
    }
}

# ============================================
# Scan 4: PUBLIC FIELDS
# ============================================
Write-Host "[4/7] Scanning public field declarations..." -ForegroundColor Yellow
$fieldPattern = '\b(?:public|internal|protected)\s+(?:static\s+|readonly\s+|const\s+|volatile\s+)*([A-Za-z_][\w<>\?,\s\[\]]*?)\s+([A-Za-z_][A-Za-z0-9_]*)\s*[;={]'
foreach ($f in $csFiles) {
    $content = Get-Content $f.FullName -Raw
    $matches = [regex]::Matches($content, $fieldPattern)
    foreach ($m in $matches) {
        $name = $m.Groups[2].Value
        $line = ($content.Substring(0, $m.Groups[2].Index) -split "`n").Count
        # Exclude properties (have { and getter/setter nearby)
        $surrounding = $content.Substring([Math]::Max(0, $m.Index - 50), [Math]::Min(200, $content.Length - $m.Index + 50))
        if ($surrounding -match '\{[^}]*(?:get|set)') { continue }
        $kind = Get-NamingViolationKind -Identifier $name -Context "field"
        if ($kind) {
            $violations += [PSCustomObject]@{
                Severity     = $kind[0]
                Kind         = "Field"
                Identifier   = $name
                File         = $f.FullName -replace [regex]::Escape((Get-Location).Path + '\'), ''
                Line         = $line
                Issue        = $kind[1]
                Impact       = $kind[2]
                RefCount     = $refCounts[$name]
            }
        }
    }
}

# ============================================
# Scan 5: NAMESPACES
# ============================================
Write-Host "[5/7] Scanning namespace declarations..." -ForegroundColor Yellow
$nsPattern = '^\s*namespace\s+([\w\.]+)'
foreach ($f in $csFiles) {
    $content = Get-Content $f.FullName -Raw
    $matches = [regex]::Matches($content, $nsPattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)
    foreach ($m in $matches) {
        $ns = $m.Groups[1].Value
        $segments = $ns -split '\.'
        $line = ($content.Substring(0, $m.Groups[1].Index) -split "`n").Count
        foreach ($seg in $segments) {
            if ($seg -cnotmatch '^[A-Z]') {
                $violations += [PSCustomObject]@{
                    Severity     = 'HIGH'
                    Kind         = "Namespace"
                    Identifier   = $ns
                    File         = $f.FullName -replace [regex]::Escape((Get-Location).Path + '\'), ''
                    Line         = $line
                    Issue        = "Namespace segment '$seg' starts with lowercase"
                    Impact       = "Namespace segments should be PascalCase. This is non-conformant to Microsoft guidelines (CAP-7, NA-1)."
                    RefCount     = $refCounts[$ns]
                }
            }
        }
    }
}

# ============================================
# Scan 6: INTERFACES
# ============================================
Write-Host "[6/7] Scanning interface declarations..." -ForegroundColor Yellow
$ifacePattern = '\b(?:public|internal|private|protected)?\s*(?:partial\s+)*interface\s+([A-Za-z_][A-Za-z0-9_]*)'
foreach ($f in $csFiles) {
    $content = Get-Content $f.FullName -Raw
    $matches = [regex]::Matches($content, $ifacePattern)
    foreach ($m in $matches) {
        $name = $m.Groups[1].Value
        $line = ($content.Substring(0, $m.Groups[1].Index) -split "`n").Count
        if ($name -cnotmatch '^I[A-Z]') {
            $violations += [PSCustomObject]@{
                Severity     = 'HIGH'
                Kind         = "Interface"
                Identifier   = $name
                File         = $f.FullName -replace [regex]::Escape((Get-Location).Path + '\'), ''
                Line         = $line
                Issue        = "Interface name should start with capital 'I' (e.g., I$name)"
                Impact       = "Microsoft .NET convention requires interface names to use 'I' prefix (e.g., IDisposable, IEnumerable)."
                RefCount     = $refCounts[$name]
            }
        }
    }
}

# ============================================
# Scan 7: ENUMS
# ============================================
Write-Host "[7/7] Scanning enum declarations..." -ForegroundColor Yellow
$enumPattern = '\b(?:public|internal|private|protected)?\s*enum\s+([A-Za-z_][A-Za-z0-9_]*)'
foreach ($f in $csFiles) {
    $content = Get-Content $f.FullName -Raw
    $matches = [regex]::Matches($content, $enumPattern)
    foreach ($m in $matches) {
        $name = $m.Groups[1].Value
        $line = ($content.Substring(0, $m.Groups[1].Index) -split "`n").Count
        $kind = Get-NamingViolationKind -Identifier $name -Context "enum"
        if ($kind) {
            $violations += [PSCustomObject]@{
                Severity     = $kind[0]
                Kind         = "Enum"
                Identifier   = $name
                File         = $f.FullName -replace [regex]::Escape((Get-Location).Path + '\'), ''
                Line         = $line
                Issue        = $kind[1]
                Impact       = $kind[2]
                RefCount     = $refCounts[$name]
            }
        }
    }
}

# ============================================
# Output the report
# ============================================
Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "NAMING CONVENTIONS AUDIT REPORT" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "Total violations found: $($violations.Count)" -ForegroundColor Yellow
Write-Host ""

# Group by severity
$bySeverity = $violations | Group-Object Severity | Sort-Object Name
Write-Host "=== BY SEVERITY ===" -ForegroundColor Green
$bySeverity | ForEach-Object { Write-Host ("  {0,-12} : {1}" -f $_.Name, $_.Count) }
Write-Host ""

# Group by kind
$byKind = $violations | Group-Object Kind | Sort-Object Name
Write-Host "=== BY KIND ===" -ForegroundColor Green
$byKind | ForEach-Object { Write-Host ("  {0,-12} : {1}" -f $_.Name, $_.Count) }
Write-Host ""

# Detailed listing
Write-Host "=== DETAILED VIOLATIONS ===" -ForegroundColor Green
$violations | Sort-Object Severity, Kind, Identifier | Format-Table -AutoSize -Wrap

# Save to JSON for downstream analysis
$violations | ConvertTo-Json -Depth 3 | Set-Content 'scripts\naming-violations.json'
Write-Host "JSON saved to: scripts\naming-violations.json" -ForegroundColor Green
