$env:PGPASSWORD = "656650"
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" -h localhost -U postgres -d IntegratedAccSys -t -A -c "SELECT column_name||'|'||data_type||'|'||is_nullable FROM information_schema.columns WHERE table_schema='public' AND table_name='tblusers' ORDER BY ordinal_position;"
