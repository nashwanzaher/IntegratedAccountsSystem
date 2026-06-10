# Live DB inventory - read-only
$ErrorActionPreference = "Stop"
$psql = "C:\Program Files\PostgreSQL\17\bin\psql.exe"
$env:PGPASSWORD = "656650"
$db = "IntegratedAccSys"
$server = "localhost"
$port = "5432"
$user = "postgres"

Write-Host "=== CONNECTION ==="
& $psql -h $server -p $port -U $user -d $db -t -A -c "SELECT current_database()||'|'||current_user||'|'||version();"

Write-Host "`n=== COUNTS ==="
& $psql -h $server -p $port -U $user -d $db -t -A -c @"
SELECT 'tables:'||count(*) FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE'
UNION ALL SELECT 'views:'||count(*) FROM information_schema.views WHERE table_schema='public'
UNION ALL SELECT 'funcs:'||count(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='public' AND p.prokind='f'
UNION ALL SELECT 'procs:'||count(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='public' AND p.prokind='p'
UNION ALL SELECT 'triggers:'||count(*) FROM information_schema.triggers WHERE trigger_schema='public';
"@

Write-Host "`n=== TABLES LIST ==="
& $psql -h $server -p $port -U $user -d $db -t -A -c "SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE' ORDER BY table_name;"
