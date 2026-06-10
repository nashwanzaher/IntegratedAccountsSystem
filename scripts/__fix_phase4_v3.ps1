$file = "d:\source\IntegratedAccountsSystem\database\IntegratedAccSys_Dimensions_Phase4.sql"
$content = Get-Content $file -Raw

# Fix 1: workflow INSERT to use actual columns
$old1 = @"
-- 8.2 New approval workflow: DIMENSION_MASTER_CHANGE ----------------
INSERT INTO tblapprovalworkflows (workflowname, description, sourcetype, isactive, adduser)
SELECT 'DIMENSION_MASTER_CHANGE',
       'Approval required for adding/editing critical dimension master codes (Departments/Projects/BUs/PCs)',
       'DIMENSION', TRUE, 0
WHERE NOT EXISTS (SELECT 1 FROM tblapprovalworkflows WHERE workflowname='DIMENSION_MASTER_CHANGE');

-- 8.3 Default 2-level chain for the new workflow --------------------
DO `$`$
DECLARE
    v_wf BIGINT;
    v_lvl INTEGER;
BEGIN
    SELECT workflowid INTO v_wf FROM tblapprovalworkflows WHERE workflowname='DIMENSION_MASTER_CHANGE';
    IF v_wf IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM tblapprovallevels WHERE workflowid=v_wf AND levelnumber=1) THEN
            INSERT INTO tblapprovallevels(workflowid,levelnumber,rolename,adduser)
            VALUES (v_wf,1,'FINANCE_MANAGER',0);
        END IF;
        IF NOT EXISTS (SELECT 1 FROM tblapprovallevels WHERE workflowid=v_wf AND levelnumber=2) THEN
            INSERT INTO tblapprovallevels(workflowid,levelnumber,rolename,adduser)
            VALUES (v_wf,2,'CFO',0);
        END IF;
    END IF;
END`$`$;
"@

$new1 = @"
-- 8.2 New approval workflow: DIMENSION_MASTER_CHANGE ----------------
INSERT INTO tblapprovalworkflows (workflowcode, workflownamear, workflownameen, sourcetype, description, isactive, adduser)
SELECT 'DIMENSION_MASTER_CHANGE',
       'تغيير بيانات الأبعاد الرئيسية',
       'Dimension Master Change',
       'DIMENSION',
       'Approval required for adding/editing critical dimension master codes (Departments/Projects/BUs/PCs)',
       TRUE, 0
WHERE NOT EXISTS (SELECT 1 FROM tblapprovalworkflows WHERE workflowcode='DIMENSION_MASTER_CHANGE');

-- 8.3 Default 2-level chain for the new workflow --------------------
DO `$`$
DECLARE
    v_wf INTEGER;
BEGIN
    SELECT workflowid INTO v_wf FROM tblapprovalworkflows WHERE workflowcode='DIMENSION_MASTER_CHANGE';
    IF v_wf IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM tblapprovallevels WHERE workflowid=v_wf AND levelnumber=1) THEN
            INSERT INTO tblapprovallevels(workflowid, levelnumber, levelnamear, levelnameen, requiredrole, amountmin, amountmax, ismandatory, isactive)
            VALUES (v_wf, 1, 'المستوى الأول - المدير المالي', 'Level 1 - Finance Manager', 'FINANCE_MANAGER', 0, 999999999, TRUE, TRUE);
        END IF;
        IF NOT EXISTS (SELECT 1 FROM tblapprovallevels WHERE workflowid=v_wf AND levelnumber=2) THEN
            INSERT INTO tblapprovallevels(workflowid, levelnumber, levelnamear, levelnameen, requiredrole, amountmin, amountmax, ismandatory, isactive)
            VALUES (v_wf, 2, 'المستوى الثاني - المدير التنفيذي', 'Level 2 - CFO', 'CFO', 0, 999999999, TRUE, TRUE);
        END IF;
    END IF;
END`$`$;
"@

if ($content.Contains($old1)) {
    $content = $content.Replace($old1, $new1)
    Write-Host "Section 8 replaced successfully"
} else {
    Write-Host "Section 8 NOT found - already fixed?"
}

Set-Content -Path $file -Value $content -NoNewline
Write-Host "File saved"
$count = ([regex]::Matches((Get-Content $file -Raw), 'workflowname,' )).Count
Write-Host "workflowname, refs remaining: $count"
$count2 = ([regex]::Matches((Get-Content $file -Raw), 'rolename' )).Count
Write-Host "rolename refs remaining: $count2"
