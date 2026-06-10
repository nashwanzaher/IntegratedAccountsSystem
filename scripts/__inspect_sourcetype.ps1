$env:PGPASSWORD = "656650"
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT conname||'|'||pg_get_constraintdef(oid) FROM pg_constraint WHERE conrelid='tblapprovalworkflows'::regclass AND contype='c';"
Write-Host "---"
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT DISTINCT sourcetype FROM tblapprovalworkflows;"
