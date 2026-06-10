# security-discovery.ps1 - Read-only Security Architecture Discovery
$env:PGPASSWORD = '656650'
$Psql = 'C:\Program Files\PostgreSQL\17\bin\psql.exe'
$Db = 'IntegratedAccSys'

function Q([string]$Sql, [string]$Label) {
    Write-Host "--- $Label ---" -ForegroundColor Cyan
    & $Psql -h localhost -U postgres -d $Db -t -A -c $Sql 2>&1
    Write-Host ""
}

Write-Host "=============================================" -ForegroundColor Yellow
Write-Host "  SECURITY ARCHITECTURE DISCOVERY" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Yellow
Write-Host ""

# ============================================
# 1. POSTGRESQL ROLES & ATTRIBUTES
# ============================================
Write-Host "=== 1. POSTGRESQL ROLES ===" -ForegroundColor Green
Q "SELECT rolname, rolcanlogin, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin, rolreplication, rolbypassrls FROM pg_roles ORDER BY rolname;" "1.1 All Roles with Attributes"
Q "SELECT rolname, rolconfig FROM pg_roles WHERE rolconfig IS NOT NULL;" "1.2 Role-Specific Configurations"

# ============================================
# 2. APPLICATION USERS (from tblusers)
# ============================================
Write-Host "=== 2. APPLICATION USERS ===" -ForegroundColor Green
Q "SELECT COUNT(*) AS total_app_users FROM tblusers;" "2.1 User Count"
Q "SELECT usercode, userid, usernamear, email, isactive, isadmin, branchcode, createdat, lastloginat, loginattempts, lockeduntil, mustchangepassword FROM tblusers ORDER BY usercode;" "2.2 All Users (no passwords)"
Q "SELECT isactive, COUNT(*) FROM tblusers GROUP BY isactive;" "2.3 Active vs Inactive Users"
Q "SELECT isadmin, COUNT(*) FROM tblusers GROUP BY isadmin;" "2.4 Admin vs Regular Users"
Q "SELECT branchcode, COUNT(*) FROM tblusers GROUP BY branchcode ORDER BY branchcode;" "2.5 Users per Branch"
Q "SELECT data_type, character_maximum_length FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'tblusers' AND column_name IN ('userpassword', 'salt', 'passwordhistory1', 'passwordhistory2');" "2.6 Password Storage Schema"

# ============================================
# 3. ACTIVE SESSIONS
# ============================================
Write-Host "=== 3. ACTIVE SESSIONS ===" -ForegroundColor Green
Q "SELECT COUNT(*) AS active_sessions FROM tblsessions WHERE isactive = TRUE AND expiresat > NOW();" "3.1 Active Session Count"
Q "SELECT sessionid, usercode, ipaddress, useragent, isactive, createdat, lastactivityat, expiresat FROM tblsessions ORDER BY createdat DESC LIMIT 20;" "3.2 Recent Sessions"

# ============================================
# 4. ROLES & PRIVILEGES (BL-level)
# ============================================
Write-Host "=== 4. APPLICATION ROLES ===" -ForegroundColor Green
Q "SELECT COUNT(*) AS total_roles FROM tbluserroles;" "4.1 Total Roles"
Q "SELECT rolecode, roleid, rolenamear, rolenameen, description, isactive FROM tbluserroles ORDER BY rolecode;" "4.2 All Roles"
Q "SELECT userroleid, usercode, rolecode, isactive, startdate, enddate FROM tbluserroleassignments ORDER BY usercode LIMIT 30;" "4.3 Role Assignments (top 30)"

# ============================================
# 5. PRIVILEGES (Window-level)
# ============================================
Write-Host "=== 5. PRIVILEGES (Windows) ===" -ForegroundColor Green
Q "SELECT COUNT(*) AS total_privileges FROM tblprivileges;" "5.1 Total Privileges"
Q "SELECT p.privilegeid, p.usercode, p.windowid, w.windownamear, w.windowtype, p.canview, p.canadd, p.canedit, p.candelete, p.canapprove, p.canprint, p.isactive, p.effectiveto FROM tblprivileges p JOIN tblwindows w ON p.windowid = w.windowid ORDER BY p.usercode, p.windowid LIMIT 20;" "5.2 Sample Privileges"
Q "SELECT windowid, windownamear, windowtype, isactive FROM tblwindows ORDER BY windowid;" "5.3 All Windows"

# ============================================
# 6. SENSITIVE TABLES (data classification)
# ============================================
Write-Host "=== 6. SENSITIVE TABLES ===" -ForegroundColor Green
Q "SELECT tablename, column_name, data_type, is_nullable FROM information_schema.columns WHERE table_schema = 'public' AND (column_name ILIKE '%password%' OR column_name ILIKE '%token%' OR column_name ILIKE '%secret%' OR column_name ILIKE '%salary%' OR column_name ILIKE '%balance%' OR column_name ILIKE '%amount%' OR column_name ILIKE '%taxnumber%' OR column_name ILIKE '%iban%' OR column_name ILIKE '%swift%' OR column_name ILIKE '%accountnumber%') ORDER BY tablename, column_name LIMIT 50;" "6.1 Columns Containing Sensitive Keywords"
Q "SELECT table_name, column_name, data_type FROM information_schema.columns WHERE table_schema = 'public' AND data_type = 'bytea' ORDER BY table_name, column_name;" "6.2 Binary Columns (BYTEA)"

# ============================================
# 7. FOREIGN KEY RELATIONSHIPS
# ============================================
Write-Host "=== 7. FOREIGN KEY RELATIONSHIPS ===" -ForegroundColor Green
Q "SELECT tc.table_name AS from_table, kcu.column_name AS from_column, ccu.table_name AS to_table, ccu.column_name AS to_column, tc.constraint_name FROM information_schema.table_constraints tc JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name WHERE tc.constraint_type = 'foreign key' AND tc.table_schema = 'public' ORDER BY tc.table_name, kcu.column_name;" "7.1 All Foreign Keys"

# ============================================
# 8. EXISTING GRANTS (table-level)
# ============================================
Write-Host "=== 8. EXISTING GRANTS ===" -ForegroundColor Green
Q "SELECT grantee, table_schema, COUNT(*) AS table_count, SUM(CASE WHEN privilege_type = 'SELECT' THEN 1 ELSE 0 END) AS select_count, SUM(CASE WHEN privilege_type = 'INSERT' THEN 1 ELSE 0 END) AS insert_count, SUM(CASE WHEN privilege_type = 'UPDATE' THEN 1 ELSE 0 END) AS update_count, SUM(CASE WHEN privilege_type = 'DELETE' THEN 1 ELSE 0 END) AS delete_count FROM information_schema.role_table_grants WHERE table_schema = 'public' GROUP BY grantee, table_schema ORDER BY grantee;" "8.1 Grants by Grantee"
Q "SELECT grantee, table_name, privilege_type FROM information_schema.role_table_grants WHERE grantee <> 'postgres' AND grantee <> 'PUBLIC' ORDER BY grantee, table_name LIMIT 30;" "8.2 Non-Postgres Grants (sample)"

# ============================================
# 9. SCHEMA-LEVEL PRIVILEGES
# ============================================
Write-Host "=== 9. SCHEMA-LEVEL PRIVILEGES ===" -ForegroundColor Green
Q "SELECT nspname, nspacl FROM pg_namespace WHERE nspname = 'public';" "9.1 Schema ACL"
Q "SELECT has_schema_privilege('postgres', 'public', 'USAGE') AS usage, has_schema_privilege('postgres', 'public', 'CREATE') AS create_priv;" "9.2 Current User Schema Privileges"

# ============================================
# 10. DATABASE-LEVEL PROPERTIES
# ============================================
Write-Host "=== 10. DATABASE PROPERTIES ===" -ForegroundColor Green
Q "SELECT datname, datdba, datistemplate, datallowconn, datconnlimit, datlastsysoid, datfrozenxid, datminmxid, dattablespace, datcollate, datctype, datlocale, daticulocale, datlocprovider FROM pg_database WHERE datname = 'IntegratedAccSys';" "10.1 Database Configuration"
Q "SELECT name, setting, unit, context FROM pg_settings WHERE name IN ('listen_addresses', 'port', 'max_connections', 'ssl', 'ssl_cert_file', 'shared_buffers', 'work_mem', 'password_encryption', 'log_connections', 'log_min_duration_statement') ORDER BY name;" "10.2 Key Server Settings"

# ============================================
# 11. TABLES WITHOUT AUDIT (potential gaps)
# ============================================
Write-Host "=== 11. AUDIT COVERAGE ===" -ForegroundColor Green
Q "SELECT t.tablename, (t.tablename = 'tblauditlogs' OR t.tablename = 'tblaudi') AS has_audit FROM pg_tables t WHERE t.schemaname = 'public' AND t.tablename IN ('tblusers', 'tblsessions', 'tblbankaccounts', 'tblbanktransactions', 'tblcashboxes', 'tblcashreceipts', 'tblcashpayments', 'tblcustomers', 'tblsuppliers', 'tblproducts', 'tblprices', 'tbljournalheader', 'tblbondheader', 'tbluserroles', 'tbluserroleassignments', 'tblprivileges') ORDER BY t.tablename;" "11.1 Tables Needing Audit"

# ============================================
# 12. AUDIT LOG STRUCTURE
# ============================================
Write-Host "=== 12. AUDIT LOG STRUCTURE ===" -ForegroundColor Green
Q "SELECT column_name, data_type FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'tblaudi' ORDER BY ordinal_position;" "12.1 Audit Columns"
Q "SELECT column_name, data_type FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'tblauditlogs' ORDER BY ordinal_position;" "12.2 AuditLogs Columns"
Q "SELECT COUNT(*) AS audit_count FROM tblauditlogs;" "12.3 AuditLogs Count"
Q "SELECT COUNT(*) AS audithist_count FROM tblaudi;" "12.4 AuditHist Count"
