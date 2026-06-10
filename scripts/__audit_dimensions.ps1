# Phase 4 - Inspect existing Cost Centers & Dimensions
$ErrorActionPreference = "Stop"
$psql = "C:\Program Files\PostgreSQL\17\bin\psql.exe"
$env:PGPASSWORD = "656650"

Write-Host "=== TABLES MATCHING (dept|project|segment|profit|dim|hier|cost|bu|business) ==="
& $psql -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE' AND (lower(table_name) ~ '(dept|project|segment|profit|dim|hier|cost|center|business|bu_)') ORDER BY table_name;"

Write-Host "`n=== EXISTING tblcostcenters SCHEMA ==="
& $psql -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT column_name||'|'||data_type||'|'||is_nullable||'|'||COALESCE(column_default,'') FROM information_schema.columns WHERE table_schema='public' AND table_name='tblcostcenters' ORDER BY ordinal_position;"

Write-Host "`n=== FUNCTIONS MATCHING (dept|project|segment|profit|dim|hier|cost|center) ==="
& $psql -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT proname FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='public' AND p.prokind='f' AND (lower(proname) ~ '(dept|project|segment|profit|dim|hier|cost|center)') ORDER BY proname;"

Write-Host "`n=== PROCEDURES MATCHING (dept|project|segment|profit|dim|hier|cost|center) ==="
& $psql -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT proname FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='public' AND p.prokind='p' AND (lower(proname) ~ '(dept|project|segment|profit|dim|hier|cost|center)') ORDER BY proname;"

Write-Host "`n=== VIEWS MATCHING (dept|project|segment|profit|dim|hier|cost|center) ==="
& $psql -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT table_name FROM information_schema.views WHERE table_schema='public' AND (lower(table_name) ~ '(dept|project|segment|profit|dim|hier|cost|center)') ORDER BY table_name;"

Write-Host "`n=== EXISTING tblcostcenters ROW COUNT + SAMPLE ==="
& $psql -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT 'rows:'||count(*) FROM tblcostcenters;"
& $psql -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT * FROM tblcostcenters LIMIT 5;" 2>&1

Write-Host "`n=== JOURNAL HEADER SCHEMA (target for dimension integration) ==="
& $psql -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT column_name||'|'||data_type||'|'||is_nullable FROM information_schema.columns WHERE table_schema='public' AND table_name='tbljournalheader' ORDER BY ordinal_position;"

Write-Host "`n=== JOURNAL BODY SCHEMA ==="
& $psql -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT column_name||'|'||data_type||'|'||is_nullable FROM information_schema.columns WHERE table_schema='public' AND table_name='tbljournalbody' ORDER BY ordinal_position;"

Write-Host "`n=== BOND HEADER SCHEMA ==="
& $psql -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT column_name||'|'||data_type||'|'||is_nullable FROM information_schema.columns WHERE table_schema='public' AND table_name='tblbondheader' ORDER BY ordinal_position;"

Write-Host "`n=== CASH RECEIPTS / PAYMENTS SCHEMAS ==="
& $psql -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT table_name||'.'||column_name||'|'||data_type||'|'||is_nullable FROM information_schema.columns WHERE table_schema='public' AND table_name IN ('tblcashreceipts','tblcashpayments','tblbanktransactions') ORDER BY table_name, ordinal_position;"

Write-Host "`n=== BUDGETS SCHEMA ==="
& $psql -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT column_name||'|'||data_type||'|'||is_nullable FROM information_schema.columns WHERE table_schema='public' AND table_name='tblbudgets' ORDER BY ordinal_position;"

Write-Host "`n=== BUDGET PERIODS SCHEMA ==="
& $psql -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT column_name||'|'||data_type||'|'||is_nullable FROM information_schema.columns WHERE table_schema='public' AND table_name='tblbudgetperiods' ORDER BY ordinal_position;"

Write-Host "`n=== APPROVAL WORKFLOWS (to see approvalconfig keys) ==="
& $psql -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT * FROM tblapprovalconfig;"
