# Live DB full inventory - read-only
$ErrorActionPreference = "Stop"
$psql = "C:\Program Files\PostgreSQL\17\bin\psql.exe"
$env:PGPASSWORD = "656650"

Write-Host "=== FUNCTIONS LIST ==="
& $psql -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT proname FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='public' AND p.prokind='f' ORDER BY proname;"

Write-Host "`n=== PROCEDURES LIST ==="
& $psql -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT proname FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='public' AND p.prokind='p' ORDER BY proname;"

Write-Host "`n=== VIEWS LIST ==="
& $psql -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT table_name FROM information_schema.views WHERE table_schema='public' ORDER BY table_name;"

Write-Host "`n=== TRIGGERS LIST ==="
& $psql -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT trigger_name, event_object_table, action_timing, event_manipulation FROM information_schema.triggers WHERE trigger_schema='public' ORDER BY trigger_name;"

Write-Host "`n=== USER, VERSION, EXTENSIONS ==="
& $psql -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT current_user||'|'||version()||'|'||(SELECT string_agg(extname,',') FROM pg_extension);"
