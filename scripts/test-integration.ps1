# test-integration.ps1 - End-to-end integration test
$env:PGPASSWORD = '656650'
$psql = 'C:\Program Files\PostgreSQL\17\bin\psql.exe'
$db = 'IntegratedAccSys'

function Q([string]$Sql, [string]$Label) {
    Write-Host "--- $Label ---" -ForegroundColor Cyan
    & $psql -h localhost -U postgres -d $db -c $Sql 2>&1
    Write-Host ""
}

# 1. Get procedure signatures
Q "SELECT proname, pg_get_function_arguments(oid) FROM pg_proc WHERE proname ILIKE '%bond%' ORDER BY proname;" "1. Bond Procedures"

# 2. Test direct INSERT (bypasses procedure parameter signature)
Write-Host "--- 2. Insert bond directly into tblbondheader (trigger should fire) ---" -ForegroundColor Cyan
& $psql -h localhost -U postgres -d $db -c "INSERT INTO tblbondheader (bondid, bondtype, bonddate, fiscalyear, fiscalperiod, amount, currencycode, exchangerate, customercode, description, createdby) VALUES ('BND-INT-1', 'SALE', '2026-06-09', 2026, 6, 5000, 1, 1.0, 1, 'Integration test bond', 1) RETURNING bondcode, approvalrequestid;" 2>&1

# 3. Verify auto-submit
Write-Host "--- 3. Verify auto-submit created approval request ---" -ForegroundColor Cyan
& $psql -h localhost -U postgres -d $db -c "SELECT b.bondcode, b.bondid, b.amount, b.approvalrequestid, ar.requestno, ar.status, ar.currentlevel, ar.totallevels FROM tblbondheader b LEFT JOIN tblapprovalrequests ar ON b.approvalrequestid = ar.requestid WHERE b.bondid = 'BND-INT-1';" 2>&1

# 4. Get the requestid
$rid = & $psql -h localhost -U postgres -d $db -t -A -c "SELECT approvalrequestid FROM tblbondheader WHERE bondid='BND-INT-1';" 2>&1
Write-Host "Request ID: $rid" -ForegroundColor Yellow

# 5. Try to POST bond without approval (should FAIL)
Write-Host "--- 4. Try to POST bond without approval (should FAIL) ---" -ForegroundColor Cyan
& $psql -h localhost -U postgres -d $db -c "UPDATE tblbondheader SET isposted = TRUE WHERE bondid = 'BND-INT-1';" 2>&1

# 6. Approve through all levels
if ($rid -match '^\d+$') {
    Write-Host "--- 5. Approving through 3 levels (Sales workflow) ---" -ForegroundColor Cyan
    for ($i = 1; $i -le 3; $i++) {
        & $psql -h localhost -U postgres -d $db -c "CALL approveRequest($rid, 1, 'Approved level $i', '127.0.0.1', 'Test', NULL);" 2>&1
    }
}

# 7. Try POST again (should now SUCCEED)
Write-Host "--- 6. POST bond (should now SUCCEED) ---" -ForegroundColor Cyan
& $psql -h localhost -U postgres -d $db -c "UPDATE tblbondheader SET isposted = TRUE, postedby = 1 WHERE bondid = 'BND-INT-1' RETURNING bondcode, isposted, postedat, postedby;" 2>&1

# 8. View the integrated view
Write-Host "--- 7. View vw_bonds_with_approval ---" -ForegroundColor Cyan
& $psql -h localhost -U postgres -d $db -c "SELECT bondid, amount, approvalstatus, currentlevel, totallevels, isapproved, isoverdue FROM vw_bonds_with_approval WHERE bondid = 'BND-INT-1';" 2>&1

# 9. Test journal entry auto-submit
Write-Host "--- 8. Insert journal entry (trigger should fire) ---" -ForegroundColor Cyan
& $psql -h localhost -U postgres -d $db -c "INSERT INTO tbljournalheader (journalid, journaldate, fiscalyear, fiscalperiod, description, totaldebit, totalcredit, createdby) VALUES ('JV-INT-1', '2026-06-09', 2026, 6, 'Integration test journal', 5000, 5000, 1) RETURNING journalcode, approvalrequestid;" 2>&1

# 10. View vw_unposted_pending_approval
Write-Host "--- 9. View vw_unposted_pending_approval ---" -ForegroundColor Cyan
& $psql -h localhost -U postgres -d $db -c "SELECT sourcetype, sourceid, docno, amount, status, currentlevel, totallevels, timeliness FROM vw_unposted_pending_approval ORDER BY docdate DESC LIMIT 10;" 2>&1

# 11. View vw_approvalmetrics
Write-Host "--- 10. View vw_approvalmetrics ---" -ForegroundColor Cyan
& $psql -h localhost -U postgres -d $db -c "SELECT * FROM vw_approvalmetrics;" 2>&1

# 12. View vw_workflowsummary
Write-Host "--- 11. View vw_workflowsummary ---" -ForegroundColor Cyan
& $psql -h localhost -U postgres -d $db -c "SELECT * FROM vw_workflowsummary;" 2>&1
