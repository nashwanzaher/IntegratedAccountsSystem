# connect-db.ps1 - PostgreSQL connection helper for IntegratedAccSys
# Usage:
#   .\connect-db.ps1                 - Open interactive psql session
#   .\connect-db.ps1 -Query "..."    - Run a single query and exit
#   .\connect-db.ps1 -Command "..."  - Run a psql meta-command (e.g., \dt)
#   .\connect-db.ps1 -ListTables     - Quick alias to list all tables
#   .\connect-db.ps1 -ListFunctions  - Quick alias to list all functions
#   .\connect-db.ps1 -ListProcedures - Quick alias to list all procedures
#   .\connect-db.ps1 -Info           - Show DB version + object counts

param(
    [string]$Query = "",
    [string]$Command = "",
    [switch]$ListTables,
    [switch]$ListFunctions,
    [switch]$ListProcedures,
    [switch]$ListViews,
    [switch]$Info,
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

# Connection parameters (matching DalSettings)
$Server   = 'localhost'
$Port     = 5432
$Database = 'IntegratedAccSys'
$User     = 'postgres'
$Password = '656650'
$PsqlPath = 'C:\Program Files\PostgreSQL\17\bin\psql.exe'

# Verify psql exists
if (-not (Test-Path $PsqlPath)) {
    Write-Host "[ERROR] psql.exe not found at: $PsqlPath" -ForegroundColor Red
    Write-Host "Please install PostgreSQL 17 or update \$PsqlPath in this script." -ForegroundColor Yellow
    exit 1
}

# Set password via env var (avoids command-line password exposure)
$env:PGPASSWORD = $Password

function Show-Help {
    Write-Host ""
    Write-Host "=== connect-db.ps1 - PostgreSQL Connection Helper ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\connect-db.ps1 [options]"
    Write-Host ""
    Write-Host "OPTIONS:" -ForegroundColor Yellow
    Write-Host "  -Query <sql>        Run a SQL query and print results"
    Write-Host "  -Command <psql>     Run a psql meta-command (e.g., \dt, \df)"
    Write-Host "  -ListTables         List all public tables"
    Write-Host "  -ListFunctions      List all public functions"
    Write-Host "  -ListProcedures     List all public procedures"
    Write-Host "  -ListViews          List all public views"
    Write-Host "  -Info               Show DB version + object counts"
    Write-Host "  -Help               Show this help"
    Write-Host ""
    Write-Host "CONNECTION:" -ForegroundColor Yellow
    Write-Host "  Server   : $Server"
    Write-Host "  Port     : $Port"
    Write-Host "  Database : $Database"
    Write-Host "  User     : $User"
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  .\connect-db.ps1 -Info"
    Write-Host "  .\connect-db.ps1 -ListTables"
    Write-Host "  .\connect-db.ps1 -Command '\dt'"
    Write-Host "  .\connect-db.ps1 -Query 'SELECT COUNT(*) FROM tblUsers'"
    Write-Host "  .\connect-db.ps1                    (interactive session)"
    Write-Host ""
}

if ($Help) { Show-Help; exit 0 }

# Banner
Write-Host ""
Write-Host "=== PostgreSQL: ${Database}@${Server}:${Port} as ${User} ===" -ForegroundColor Green
Write-Host ""

$argsList = @('-h', $Server, '-p', $Port, '-U', $User, '-d', $Database)

if ($ListTables) {
    & $PsqlPath @argsList -c '\dt'
}
elseif ($ListFunctions) {
    & $PsqlPath @argsList -c '\df'
}
elseif ($ListProcedures) {
    & $PsqlPath @argsList -c "SELECT proname FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid WHERE n.nspname = 'public' AND p.prokind = 'p' ORDER BY proname;"
}
elseif ($ListViews) {
    & $PsqlPath @argsList -c '\dv'
}
elseif ($Info) {
    & $PsqlPath @argsList -c 'SELECT version();'
    & $PsqlPath @argsList -c "SELECT 'tables' AS object_type, COUNT(*) AS count FROM information_schema.tables WHERE table_schema = 'public' UNION ALL SELECT 'functions', COUNT(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid WHERE n.nspname = 'public' AND p.prokind = 'f' UNION ALL SELECT 'procedures', COUNT(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid WHERE n.nspname = 'public' AND p.prokind = 'p' UNION ALL SELECT 'views', COUNT(*) FROM information_schema.views WHERE table_schema = 'public' UNION ALL SELECT 'triggers', COUNT(*) FROM information_schema.triggers WHERE trigger_schema = 'public' ORDER BY object_type;"
}
elseif ($Query) {
    & $PsqlPath @argsList -c $Query
}
elseif ($Command) {
    & $PsqlPath @argsList -c $Command
}
else {
    # Interactive session
    Write-Host "Opening interactive psql session..." -ForegroundColor Cyan
    Write-Host "Type '\q' to exit, '\dt' for tables, '\df' for functions." -ForegroundColor Yellow
    Write-Host ""
    & $PsqlPath @argsList
}
