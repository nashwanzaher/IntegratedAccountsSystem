$pkg = Get-Content "$env:USERPROFILE\.vscode\extensions\cweijan.vscode-postgresql-client2-8.5.0\package.json" -Raw | ConvertFrom-Json
$props = $pkg.contributes.configuration.properties
Write-Host '=== ALL PROPERTIES ==='
$props.PSObject.Properties | ForEach-Object {
    $name = $_.Name
    $val = $_.Value
    $desc = if ($val.description) { $val.description } else { '' }
    $type = if ($val.type) { $val.type } else { '' }
    Write-Host ('  [' + $type + '] ' + $name)
    if ($desc) { Write-Host ('    Description: ' + $desc.Substring(0, [Math]::Min(200, $desc.Length))) }
}
