# Trace Form usage and detect dead Forms / hidden dependencies in PL

$plRoot = "d:\source\IntegratedAccountsSystem\src\IntegratedAccSys.PL"
$forms = Get-ChildItem -Path $plRoot -Recurse -Filter "frm*.cs" | Where-Object { $_.Name -notlike "*.Designer.cs" -and $_.Name -notlike "*.resx" }

$formData = @()
foreach ($form in $forms) {
    $name = $form.BaseName
    $file = $form.FullName.Substring($plRoot.Length + 1)

    # Count PrivilegeApplier.Apply() calls
    $content = Get-Content $form.FullName -Raw
    $privilegeCalls = ([regex]::Matches($content, 'PrivilegeApplier\.Apply\(')).Count

    # Detect BL class instantiation
    $blClasses = @()
    $blPattern = 'BL\.[A-Za-z]+\.cls[A-Za-z]+\b'
    $blMatches = [regex]::Matches($content, $blPattern)
    foreach ($m in $blMatches) { $blClasses += $m.Groups[0].Value }
    $blClasses = $blClasses | Sort-Object -Unique

    # Detect other forms opened
    $otherForms = @()
    $formPattern = 'new\s+PL\.[A-Za-z]+\.frm[A-Za-z]+\s*\('
    $fMatches = [regex]::Matches($content, $formPattern)
    foreach ($m in $fMatches) {
        $otherForms += ($m.Groups[0].Value -replace 'new\s+', '' -replace '\s*\(', '').Trim()
    }
    $otherForms = $otherForms | Sort-Object -Unique

    $formData += [PSCustomObject]@{
        Form                 = $name
        File                 = $file
        PrivilegeApply_Calls = $privilegeCalls
        BL_Classes_Used      = ($blClasses -join ", ")
        Other_Forms_Opened   = ($otherForms -join ", ")
    }
}

Write-Host "=== FORMS IN PRESENTATION LAYER (PL) ===" -ForegroundColor Cyan
Write-Host "Total forms: $($formData.Count)" -ForegroundColor Yellow
Write-Host ""

$formData | Format-Table -AutoSize -Wrap

# Check which Forms are OPENED by other Forms (i.e., reachable)
$openedForms = $formData | ForEach-Object { $_.Other_Forms_Opened -split ", " } | ForEach-Object { $_.Trim() } | Where-Object { $_ } | ForEach-Object { $_ -replace 'PL\.[A-Za-z]+\.', '' } | Sort-Object -Unique
$formNames = $formData | ForEach-Object { $_.Form }

Write-Host ""
Write-Host "=== FORM REACHABILITY (Forms opened by other Forms) ===" -ForegroundColor Cyan

# Check orphan forms (defined but not opened)
$orphanForms = $formNames | Where-Object { $_ -notin $openedForms -and $_ -ne "frmLogin" -and $_ -ne "frmMainWindow" }
Write-Host ""
Write-Host "Possibly orphan forms (not opened by others):" -ForegroundColor Yellow
$orphanForms | ForEach-Object { Write-Host "  $_" }

Write-Host ""
Write-Host "Entry point forms (frmLogin, frmMainWindow):" -ForegroundColor Green
"frmLogin", "frmMainWindow" | ForEach-Object { Write-Host "  $_" }
