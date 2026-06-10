# Inventory live PostgreSQL procedures and functions

$output = @()
$env:PGPASSWORD = "656650"
$psqlPath = "C:\Program Files\PostgreSQL\17\bin\psql.exe"

# Get all procedures
$procList = & $psqlPath -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT proname FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid WHERE n.nspname = 'public' AND p.prokind = 'p' ORDER BY proname"
$procList | Where-Object { $_ } | ForEach-Object { $output += "PROCEDURE:$_" }

# Get all functions
$funcList = & $psqlPath -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT proname FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid WHERE n.nspname = 'public' AND p.prokind = 'f' ORDER BY proname"
$funcList | Where-Object { $_ } | ForEach-Object { $output += "FUNCTION:$_" }

$output | ForEach-Object { $_ }
"---SUMMARY---"
"Procedures: $(($procList | Where-Object { $_ }).Count)"
"Functions: $(($funcList | Where-Object { $_ }).Count)"
