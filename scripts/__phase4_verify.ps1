$env:PGPASSWORD = "656650"
$psql = "C:\Program Files\PostgreSQL\17\bin\psql.exe"
$db = "IntegratedAccSys"

Write-Host "=== COUNTS BEFORE/AFTER PHASE 4 ==="
Write-Host "Tables:" (& $psql -h localhost -U postgres -d $db -t -A -c "SELECT count(*) FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE';")
Write-Host "Views:" (& $psql -h localhost -U postgres -d $db -t -A -c "SELECT count(*) FROM information_schema.views WHERE table_schema='public';")
Write-Host "Functions:" (& $psql -h localhost -U postgres -d $db -t -A -c "SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='public' AND p.prokind='f';")
Write-Host "Procedures:" (& $psql -h localhost -U postgres -d $db -t -A -c "SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='public' AND p.prokind='p';")
Write-Host "Triggers:" (& $psql -h localhost -U postgres -d $db -t -A -c "SELECT count(*) FROM information_schema.triggers WHERE trigger_schema='public';")

Write-Host "`n=== PHASE 4 NEW DIM TABLES ==="
& $psql -h localhost -U postgres -d $db -t -A -c "SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE' AND table_name LIKE 'tbldim_%' ORDER BY table_name;"

Write-Host "`n=== PHASE 4 NEW TRIGGERS (trg_dim_*) ==="
& $psql -h localhost -U postgres -d $db -t -A -c "SELECT trigger_name||' on '||event_object_table||' ('||action_timing||' '||event_manipulation||')' FROM information_schema.triggers WHERE trigger_schema='public' AND trigger_name LIKE 'trg_dim_%' ORDER BY trigger_name;"

Write-Host "`n=== PHASE 4 NEW VIEWS ==="
& $psql -h localhost -U postgres -d $db -t -A -c "SELECT table_name FROM information_schema.views WHERE table_schema='public' AND (table_name LIKE 'vw_%dim%' OR table_name IN ('vw_journalbody_with_dimensions','vw_bond_with_dimensions','vw_treasury_with_dimensions','vw_budgetvsactual_by_dimension','vw_costcenter_hierarchy','vw_dimensions_summary','vw_dimension_usage')) ORDER BY table_name;"

Write-Host "`n=== APPROVAL WORKFLOW FOR DIMENSIONS ==="
& $psql -h localhost -U postgres -d $db -t -A -c "SELECT workflowid||'|'||workflowcode||'|'||sourcetype||'|'||isactive FROM tblapprovalworkflows WHERE workflowcode='DIMENSION_MASTER_CHANGE';"

Write-Host "`n=== APPROVAL LEVELS FOR DIMENSION_MASTER_CHANGE ==="
& $psql -h localhost -U postgres -d $db -t -A -c "SELECT l.levelnumber||'|'||l.levelnameen||'|'||l.requiredrole||'|'||l.amountmin||'-'||l.amountmax FROM tblapprovallevels l JOIN tblapprovalworkflows w ON w.workflowid=l.workflowid WHERE w.workflowcode='DIMENSION_MASTER_CHANGE' ORDER BY l.levelnumber;"

Write-Host "`n=== NEW CONFIG KEYS ==="
& $psql -h localhost -U postgres -d $db -t -A -c "SELECT configkey||' = '||configvalue FROM tblapprovalconfig WHERE configkey LIKE '%DIM%';"

Write-Host "`n=== COLUMNS ADDED ON EXISTING TABLES ==="
& $psql -h localhost -U postgres -d $db -t -A -c "SELECT table_name||'.'||column_name FROM information_schema.columns WHERE table_schema='public' AND column_name IN ('departmentcode','projectcode','businessunitcode','segmentcode','profitcentercode') ORDER BY table_name, column_name;"

Write-Host "`n=== SUMMARY DIMENSION FUNCTIONS CREATED ==="
$count = (& $psql -h localhost -U postgres -d $db -t -A -c "SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='public' AND p.prokind='f' AND (proname LIKE 'get%Department%' OR proname LIKE 'get%Project%' OR proname LIKE 'get%BusinessUnit%' OR proname LIKE 'get%Segment%' OR proname LIKE 'get%ProfitCenter%' OR proname LIKE 'add%Department' OR proname LIKE 'add%Project' OR proname LIKE 'add%BusinessUnit' OR proname LIKE 'add%Segment' OR proname LIKE 'add%ProfitCenter' OR proname LIKE 'update%Department' OR proname LIKE 'update%Project' OR proname LIKE 'update%BusinessUnit' OR proname LIKE 'update%Segment' OR proname LIKE 'update%ProfitCenter' OR proname LIKE 'delete%Department' OR proname LIKE 'delete%Project' OR proname LIKE 'delete%BusinessUnit' OR proname LIKE 'delete%Segment' OR proname LIKE 'delete%ProfitCenter' OR proname='validateDimension' OR proname='validateAllDimensions' OR proname='getDimensionActual' OR proname='getDimensionBudget' OR proname='getDimensionVariance' OR proname='getDimensionFullPath' OR proname='addDimensionHierarchy' OR proname='getAllDimensionHierarchies' OR proname='deleteDimensionHierarchy');")
Write-Host "Phase 4 functions: $count"
