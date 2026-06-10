$pkg = Get-Content "$env:USERPROFILE\.vscode\extensions\cweijan.vscode-postgresql-client2-8.5.0\package.json" -Raw | ConvertFrom-Json
$conns = $pkg.contributes | Where-Object { $_.command -match 'connection' -or $_.command -match 'connect' }
foreach ($c in $conns) {
    Write-Host ('  ' + $c.command + '  --  ' + $c.title)
}
Write-Host ''
Write-Host '=== Configuration Properties ==='
$config = $pkg.contributes.configuration
if ($config) {
    $config.properties.PSObject.Properties | ForEach-Object {
        $name = $_.Name
        $val = $_.Value
        Write-Host ('  ' + $name + '  --  ' + $val.description)
    }
}
