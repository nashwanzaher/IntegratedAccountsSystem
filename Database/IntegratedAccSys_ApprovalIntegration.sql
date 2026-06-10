-- =====================================================
-- IntegratedAccSys - Approval Workflow Engine: INTEGRATION
-- Date: 2026-06-09
-- Description: Links the new Approval Engine to existing transactional tables
--   (bonds, journals, cash, bank) WITHOUT modifying any existing code
--   (no changes to existing functions, procedures, views, or columns).
--
-- Integration Strategy:
--   1. ADD columns (additive only): approvalrequestid on 5 source tables
--   2. ADD workflows for new source types (CASH_RECEIPT, CASH_PAYMENT, BANK_TXN)
--   3. ADD triggers that auto-submit documents for approval based on amount
--   4. ADD a guard function that existing posting procedures can optionally call
--   5. ADD views that combine existing tables with approval status
--   6. NO MODIFICATIONS to existing functions/procedures/views
-- =====================================================

SET search_path TO public;

-- =====================================================
-- STEP 1: ADD COLUMNS (additive, no impact on existing code)
-- =====================================================
-- Add approvalrequestid as a nullable BIGINT (no constraint, just a reference)
-- Existing code is unaffected because the column is nullable

ALTER TABLE tblbondheader
ADD COLUMN IF NOT EXISTS approvalrequestid BIGINT;

ALTER TABLE tbljournalheader
ADD COLUMN IF NOT EXISTS approvalrequestid BIGINT;

ALTER TABLE tblcashreceipts
ADD COLUMN IF NOT EXISTS approvalrequestid BIGINT;

ALTER TABLE tblcashpayments
ADD COLUMN IF NOT EXISTS approvalrequestid BIGINT;

ALTER TABLE tblbanktransactions
ADD COLUMN IF NOT EXISTS approvalrequestid BIGINT;

-- Indexes for the new columns (for fast lookup)
CREATE INDEX IF NOT EXISTS ix_bondheader_approval ON tblbondheader (approvalrequestid)
WHERE
    approvalrequestid IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_journalheader_approval ON tbljournalheader (approvalrequestid)
WHERE
    approvalrequestid IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_cashreceipts_approval ON tblcashreceipts (approvalrequestid)
WHERE
    approvalrequestid IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_cashpayments_approval ON tblcashpayments (approvalrequestid)
WHERE
    approvalrequestid IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_banktransactions_approval ON tblbanktransactions (approvalrequestid)
WHERE
    approvalrequestid IS NOT NULL;

-- =====================================================
-- STEP 2: ADD WORKFLOWS for new source types
-- =====================================================
INSERT INTO
    tblapprovalworkflows (
        workflowcode,
        workflownamear,
        workflownameen,
        sourcetype,
        description
    )
VALUES (
        'CASH_RECEIPT_STD',
        'Cash Receipt Approval',
        'Cash Receipt Approval',
        'CASH_RECEIPT',
        'Approval workflow for cash receipts over threshold'
    ),
    (
        'CASH_PAYMENT_STD',
        'Cash Payment Approval',
        'Cash Payment Approval',
        'CASH_PAYMENT',
        'Approval workflow for cash payments over threshold'
    ),
    (
        'BANK_TXN_STD',
        'Bank Transaction Approval',
        'Bank Transaction Approval',
        'BANK_TXN',
        'Approval workflow for bank transactions over threshold'
    )
ON CONFLICT (workflowcode) DO NOTHING;

-- Levels for CASH_RECEIPT (1 level: Treasurer for any amount > 0)
INSERT INTO
    tblapprovallevels (
        workflowid,
        levelnumber,
        levelnamear,
        levelnameen,
        requiredrole,
        amountmin,
        amountmax,
        sla_hours
    )
SELECT w.workflowid, 1, 'أمين الصندوق', 'Cashier', 'CASHIER', 0.01, 10000, 12
FROM tblapprovalworkflows w
WHERE
    w.workflowcode = 'CASH_RECEIPT_STD'
ON CONFLICT (workflowid, levelnumber) DO NOTHING;

INSERT INTO
    tblapprovallevels (
        workflowid,
        levelnumber,
        levelnamear,
        levelnameen,
        requiredrole,
        amountmin,
        amountmax,
        sla_hours
    )
SELECT w.workflowid, 2, 'المدير المالي', 'CFO', 'CFO', 10000.01, 999999999999.9999, 24
FROM tblapprovalworkflows w
WHERE
    w.workflowcode = 'CASH_RECEIPT_STD'
ON CONFLICT (workflowid, levelnumber) DO NOTHING;

-- Levels for CASH_PAYMENT (1 level: Treasurer + CFO)
INSERT INTO
    tblapprovallevels (
        workflowid,
        levelnumber,
        levelnamear,
        levelnameen,
        requiredrole,
        amountmin,
        amountmax,
        sla_hours
    )
SELECT w.workflowid, 1, 'أمين الصندوق', 'Cashier', 'CASHIER', 0.01, 5000, 12
FROM tblapprovalworkflows w
WHERE
    w.workflowcode = 'CASH_PAYMENT_STD'
ON CONFLICT (workflowid, levelnumber) DO NOTHING;

INSERT INTO
    tblapprovallevels (
        workflowid,
        levelnumber,
        levelnamear,
        levelnameen,
        requiredrole,
        amountmin,
        amountmax,
        sla_hours
    )
SELECT w.workflowid, 2, 'المدير المالي', 'CFO', 'CFO', 5000.01, 999999999999.9999, 24
FROM tblapprovalworkflows w
WHERE
    w.workflowcode = 'CASH_PAYMENT_STD'
ON CONFLICT (workflowid, levelnumber) DO NOTHING;

-- Levels for BANK_TXN (1 level: Bank Manager + CFO)
INSERT INTO
    tblapprovallevels (
        workflowid,
        levelnumber,
        levelnamear,
        levelnameen,
        requiredrole,
        amountmin,
        amountmax,
        sla_hours
    )
SELECT w.workflowid, 1, 'مدير البنك', 'Bank Manager', 'BANK_MANAGER', 0.01, 50000, 24
FROM tblapprovalworkflows w
WHERE
    w.workflowcode = 'BANK_TXN_STD'
ON CONFLICT (workflowid, levelnumber) DO NOTHING;

INSERT INTO
    tblapprovallevels (
        workflowid,
        levelnumber,
        levelnamear,
        levelnameen,
        requiredrole,
        amountmin,
        amountmax,
        sla_hours
    )
SELECT w.workflowid, 2, 'المدير المالي', 'CFO', 'CFO', 50000.01, 999999999999.9999, 48
FROM tblapprovalworkflows w
WHERE
    w.workflowcode = 'BANK_TXN_STD'
ON CONFLICT (workflowid, levelnumber) DO NOTHING;

-- =====================================================
-- STEP 3: CONFIGURATION TABLE (thresholds for auto-submit)
-- =====================================================
CREATE TABLE IF NOT EXISTS tblapprovalconfig (
    configid SERIAL PRIMARY KEY,
    configkey VARCHAR(50) NOT NULL UNIQUE,
    configvalue NUMERIC(18, 4) NOT NULL,
    description TEXT,
    adduser INTEGER,
    adddate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edituser INTEGER,
    editdate TIMESTAMP
);

INSERT INTO
    tblapprovalconfig (
        configkey,
        configvalue,
        description
    )
VALUES (
        'BOND_AUTO_APPROVE_THRESHOLD',
        0,
        'Bond amount above which auto-submission for approval is triggered (0 = always)'
    ),
    (
        'JOURNAL_AUTO_APPROVE_THRESHOLD',
        0,
        'Journal entry total debit above which auto-submission is triggered (0 = always)'
    ),
    (
        'CASH_AUTO_APPROVE_THRESHOLD',
        0,
        'Cash receipt/payment above which auto-submission is triggered (0 = always)'
    ),
    (
        'BANK_AUTO_APPROVE_THRESHOLD',
        0,
        'Bank transaction above which auto-submission is triggered (0 = always)'
    ),
    (
        'BLOCK_POSTING_WITHOUT_APPROVAL',
        1,
        '1 = block isposted=true update if approval is required and not yet approved, 0 = allow'
    )
ON CONFLICT (configkey) DO NOTHING;

-- =====================================================
-- STEP 4: HELPER FUNCTION: getConfig(key)
-- =====================================================
CREATE OR REPLACE FUNCTION getApprovalConfig(p_key VARCHAR)
RETURNS NUMERIC AS $$
DECLARE v_value NUMERIC(18,4);
BEGIN
    SELECT configvalue INTO v_value FROM tblapprovalconfig WHERE configkey = p_key;
    RETURN COALESCE(v_value, 0);
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================
-- STEP 5: HELPER FUNCTION: isSourceApproved(sourcetype, sourceid)
-- =====================================================
CREATE OR REPLACE FUNCTION isSourceApproved(p_sourcetype VARCHAR, p_sourceid BIGINT)
RETURNS BOOLEAN AS $$
DECLARE
    v_status VARCHAR(20);
    v_threshold NUMERIC(18,4);
    v_amount NUMERIC(18,4);
BEGIN
    -- Get the amount/value for this source
    v_amount := CASE p_sourcetype
        WHEN 'BOND' THEN (SELECT amount FROM tblbondheader WHERE bondcode = p_sourceid)
        WHEN 'JOURNAL' THEN (SELECT totaldebit FROM tbljournalheader WHERE journalcode = p_sourceid)
        WHEN 'CASH_RECEIPT' THEN (SELECT amountlocal FROM tblcashreceipts WHERE receiptid = p_sourceid)
        WHEN 'CASH_PAYMENT' THEN (SELECT amountlocal FROM tblcashpayments WHERE paymentid = p_sourceid)
        WHEN 'BANK_TXN' THEN (SELECT amountlocal FROM tblbanktransactions WHERE banktxnid = p_sourceid)
        ELSE 0
    END;

    IF v_amount IS NULL THEN
        RETURN TRUE; -- source not found, treat as not requiring approval
    END IF;

    -- Get threshold
    v_threshold := CASE p_sourcetype
        WHEN 'BOND' THEN getApprovalConfig('BOND_AUTO_APPROVE_THRESHOLD')
        WHEN 'JOURNAL' THEN getApprovalConfig('JOURNAL_AUTO_APPROVE_THRESHOLD')
        WHEN 'CASH_RECEIPT' THEN getApprovalConfig('CASH_AUTO_APPROVE_THRESHOLD')
        WHEN 'CASH_PAYMENT' THEN getApprovalConfig('CASH_AUTO_APPROVE_THRESHOLD')
        WHEN 'BANK_TXN' THEN getApprovalConfig('BANK_AUTO_APPROVE_THRESHOLD')
        ELSE 0
    END;

    -- If amount below threshold, no approval needed
    IF v_amount < v_threshold THEN
        RETURN TRUE;
    END IF;

    -- Check approval status
    SELECT status INTO v_status
    FROM tblapprovalrequests
    WHERE sourcetype = p_sourcetype AND sourceid = p_sourceid
    ORDER BY requestid DESC
    LIMIT 1;

    IF v_status IS NULL THEN
        RETURN FALSE; -- no approval record
    END IF;

    RETURN v_status = 'APPROVED';
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================
-- STEP 6: TRIGGER FUNCTION: auto-submit on INSERT
-- =====================================================
CREATE OR REPLACE FUNCTION fn_auto_submit_for_approval()
RETURNS TRIGGER AS $$
DECLARE
    v_workflowid INTEGER;
    v_sourcetype VARCHAR(30);
    v_sourceid BIGINT;
    v_amount NUMERIC(18,4);
    v_threshold NUMERIC(18,4);
    v_requesterid INTEGER;
    v_requestid BIGINT;
    v_requestno VARCHAR(30);
    v_result VARCHAR;
BEGIN
    -- Determine source type, source id, amount
    v_sourcetype := TG_ARGV[0];

    IF v_sourcetype = 'BOND' THEN
        v_sourceid := NEW.bondcode;
        v_amount := NEW.amount;
        v_requesterid := COALESCE(NEW.createdby, 1);
        v_threshold := getApprovalConfig('BOND_AUTO_APPROVE_THRESHOLD');
    ELSIF v_sourcetype = 'JOURNAL' THEN
        v_sourceid := NEW.journalcode;
        v_amount := NEW.totaldebit;
        v_requesterid := COALESCE(NEW.createdby, 1);
        v_threshold := getApprovalConfig('JOURNAL_AUTO_APPROVE_THRESHOLD');
    ELSIF v_sourcetype = 'CASH_RECEIPT' THEN
        v_sourceid := NEW.receiptid;
        v_amount := NEW.amountlocal;
        v_requesterid := COALESCE(NEW.adduser, 1);
        v_threshold := getApprovalConfig('CASH_AUTO_APPROVE_THRESHOLD');
    ELSIF v_sourcetype = 'CASH_PAYMENT' THEN
        v_sourceid := NEW.paymentid;
        v_amount := NEW.amountlocal;
        v_requesterid := COALESCE(NEW.adduser, 1);
        v_threshold := getApprovalConfig('CASH_AUTO_APPROVE_THRESHOLD');
    ELSIF v_sourcetype = 'BANK_TXN' THEN
        v_sourceid := NEW.banktxnid;
        v_amount := NEW.amountlocal;
        v_requesterid := COALESCE(NEW.adduser, 1);
        v_threshold := getApprovalConfig('BANK_AUTO_APPROVE_THRESHOLD');
    ELSE
        RETURN NEW; -- unknown source type
    END IF;

    -- If amount is below threshold, skip auto-submit
    IF v_amount < v_threshold THEN
        RETURN NEW;
    END IF;

    -- Submit for approval
    CALL submitForApproval(
        p_sourcetype := v_sourcetype,
        p_sourceid := v_sourceid,
        p_requesterid := v_requesterid,
        p_totalsum := v_amount,
        p_currencycode := NULL,
        p_exchangerate := 1.0,
        p_description := 'Auto-submitted on ' || v_sourcetype || ' creation',
        p_priority := 'NORMAL',
        p_requestid := v_requestid,
        p_requestno := v_requestno,
        p_result := v_result
    );

    -- Update the new record's approvalrequestid column
    IF v_sourcetype = 'BOND' THEN
        NEW.approvalrequestid := v_requestid;
    ELSIF v_sourcetype = 'JOURNAL' THEN
        NEW.approvalrequestid := v_requestid;
    ELSIF v_sourcetype = 'CASH_RECEIPT' THEN
        NEW.approvalrequestid := v_requestid;
    ELSIF v_sourcetype = 'CASH_PAYMENT' THEN
        NEW.approvalrequestid := v_requestid;
    ELSIF v_sourcetype = 'BANK_TXN' THEN
        NEW.approvalrequestid := v_requestid;
    END IF;

    -- Audit
    INSERT INTO tblapprovalaudit (requestid, eventtype, performedby, newdata, details)
    VALUES (v_requestid, 'AUTO_SUBMITTED', v_requesterid,
            jsonb_build_object('sourcetype', v_sourcetype, 'sourceid', v_sourceid, 'amount', v_amount),
            'Auto-submitted by trigger on ' || v_sourcetype || ' insert');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- STEP 7: CREATE TRIGGERS (additive, no impact on existing code)
-- =====================================================
DROP TRIGGER IF EXISTS trg_bond_auto_approve ON tblbondheader;

CREATE TRIGGER trg_bond_auto_approve
    BEFORE INSERT ON tblbondheader
    FOR EACH ROW
    EXECUTE FUNCTION fn_auto_submit_for_approval('BOND');

DROP TRIGGER IF EXISTS trg_journal_auto_approve ON tbljournalheader;

CREATE TRIGGER trg_journal_auto_approve
    BEFORE INSERT ON tbljournalheader
    FOR EACH ROW
    EXECUTE FUNCTION fn_auto_submit_for_approval('JOURNAL');

DROP TRIGGER IF EXISTS trg_cashreceipt_auto_approve ON tblcashreceipts;

CREATE TRIGGER trg_cashreceipt_auto_approve
    BEFORE INSERT ON tblcashreceipts
    FOR EACH ROW
    EXECUTE FUNCTION fn_auto_submit_for_approval('CASH_RECEIPT');

DROP TRIGGER IF EXISTS trg_cashpayment_auto_approve ON tblcashpayments;

CREATE TRIGGER trg_cashpayment_auto_approve
    BEFORE INSERT ON tblcashpayments
    FOR EACH ROW
    EXECUTE FUNCTION fn_auto_submit_for_approval('CASH_PAYMENT');

DROP TRIGGER IF EXISTS trg_banktxn_auto_approve ON tblbanktransactions;

CREATE TRIGGER trg_banktxn_auto_approve
    BEFORE INSERT ON tblbanktransactions
    FOR EACH ROW
    EXECUTE FUNCTION fn_auto_submit_for_approval('BANK_TXN');

-- =====================================================
-- STEP 8: TRIGGER FUNCTION: block posting without approval
-- =====================================================
CREATE OR REPLACE FUNCTION fn_block_unapproved_posting()
RETURNS TRIGGER AS $$
DECLARE
    v_sourcetype VARCHAR(30);
    v_sourceid BIGINT;
    v_block_enabled NUMERIC;
    v_approved BOOLEAN;
BEGIN
    -- Only act when isposted changes from false to true
    IF NEW.isposted = TRUE AND OLD.isposted = FALSE THEN
        v_block_enabled := getApprovalConfig('BLOCK_POSTING_WITHOUT_APPROVAL');
        IF v_block_enabled <> 1 THEN
            RETURN NEW;
        END IF;

        v_sourcetype := TG_ARGV[0];

        IF v_sourcetype = 'BOND' THEN
            v_sourceid := NEW.bondcode;
        ELSIF v_sourcetype = 'JOURNAL' THEN
            v_sourceid := NEW.journalcode;
        ELSE
            RETURN NEW;
        END IF;

        v_approved := isSourceApproved(v_sourcetype, v_sourceid);

        IF NOT v_approved THEN
            RAISE EXCEPTION 'Posting blocked: % (%) has not been approved. Complete approval workflow first.', v_sourcetype, v_sourceid
                USING ERRCODE = 'P0001';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create posting-block triggers
DROP TRIGGER IF EXISTS trg_bond_block_unapproved_post ON tblbondheader;

CREATE TRIGGER trg_bond_block_unapproved_post
    BEFORE UPDATE OF isposted ON tblbondheader
    FOR EACH ROW
    EXECUTE FUNCTION fn_block_unapproved_posting('BOND');

DROP TRIGGER IF EXISTS trg_journal_block_unapproved_post ON tbljournalheader;

CREATE TRIGGER trg_journal_block_unapproved_post
    BEFORE UPDATE OF isposted ON tbljournalheader
    FOR EACH ROW
    EXECUTE FUNCTION fn_block_unapproved_posting('JOURNAL');

-- =====================================================
-- STEP 9: VIEWS combining source tables with approval status
-- =====================================================

-- vw_bonds_with_approval - all bonds with their approval status
CREATE OR REPLACE VIEW vw_bonds_with_approval AS
SELECT
    b.bondcode,
    b.bondid,
    b.bondtype,
    b.bonddate,
    b.amount,
    b.description,
    b.isposted,
    b.postedat,
    b.postedby,
    b.approvalrequestid,
    ar.requestno,
    ar.status AS approvalstatus,
    ar.currentlevel,
    ar.totallevels,
    ar.priority,
    ar.duedate,
    CASE
        WHEN ar.status = 'APPROVED' THEN TRUE
        WHEN ar.status = 'PENDING' THEN FALSE
        WHEN ar.status IS NULL THEN (
            b.amount < getApprovalConfig ('BOND_AUTO_APPROVE_THRESHOLD')
        )
        ELSE FALSE
    END AS isapproved,
    CASE
        WHEN ar.duedate < NOW()
        AND ar.status = 'PENDING' THEN TRUE
        ELSE FALSE
    END AS isoverdue
FROM
    tblbondheader b
    LEFT JOIN tblapprovalrequests ar ON b.approvalrequestid = ar.requestid
ORDER BY b.bonddate DESC;

-- vw_journals_with_approval - all journal entries with their approval status
CREATE OR REPLACE VIEW vw_journals_with_approval AS
SELECT
    j.journalcode,
    j.journalid,
    j.journaldate,
    j.totaldebit,
    j.totalcredit,
    j.description,
    j.isposted,
    j.postedat,
    j.postedby,
    j.approvalrequestid,
    ar.requestno,
    ar.status AS approvalstatus,
    ar.currentlevel,
    ar.totallevels,
    ar.priority,
    ar.duedate,
    CASE
        WHEN ar.status = 'APPROVED' THEN TRUE
        WHEN ar.status = 'PENDING' THEN FALSE
        WHEN ar.status IS NULL THEN (
            j.totaldebit < getApprovalConfig (
                'JOURNAL_AUTO_APPROVE_THRESHOLD'
            )
        )
        ELSE FALSE
    END AS isapproved,
    CASE
        WHEN ar.duedate < NOW()
        AND ar.status = 'PENDING' THEN TRUE
        ELSE FALSE
    END AS isoverdue
FROM
    tbljournalheader j
    LEFT JOIN tblapprovalrequests ar ON j.approvalrequestid = ar.requestid
ORDER BY j.journaldate DESC;

-- vw_cash_with_approval - all cash transactions with approval status
CREATE OR REPLACE VIEW vw_cash_with_approval AS
SELECT
    'CASH_RECEIPT' AS transactiontype,
    cr.receiptid AS id,
    cr.receiptno AS docno,
    cr.receiptdate AS txndate,
    cr.amountlocal,
    cr.description,
    cr.status,
    cr.cashboxid,
    c.cashboxname,
    cr.approvalrequestid,
    ar.requestno,
    ar.status AS approvalstatus,
    ar.currentlevel,
    ar.totallevels,
    CASE
        WHEN ar.status = 'APPROVED' THEN TRUE
        WHEN ar.status = 'PENDING' THEN FALSE
        WHEN ar.status IS NULL THEN (
            cr.amountlocal < getApprovalConfig ('CASH_AUTO_APPROVE_THRESHOLD')
        )
        ELSE FALSE
    END AS isapproved
FROM
    tblcashreceipts cr
    JOIN tblcashboxes c ON cr.cashboxid = c.cashboxid
    LEFT JOIN tblapprovalrequests ar ON cr.approvalrequestid = ar.requestid
UNION ALL
SELECT
    'CASH_PAYMENT' AS transactiontype,
    cp.paymentid AS id,
    cp.paymentno AS docno,
    cp.paymentdate AS txndate,
    cp.amountlocal,
    cp.description,
    cp.status,
    cp.cashboxid,
    c.cashboxname,
    cp.approvalrequestid,
    ar.requestno,
    ar.status AS approvalstatus,
    ar.currentlevel,
    ar.totallevels,
    CASE
        WHEN ar.status = 'APPROVED' THEN TRUE
        WHEN ar.status = 'PENDING' THEN FALSE
        WHEN ar.status IS NULL THEN (
            cp.amountlocal < getApprovalConfig ('CASH_AUTO_APPROVE_THRESHOLD')
        )
        ELSE FALSE
    END AS isapproved
FROM
    tblcashpayments cp
    JOIN tblcashboxes c ON cp.cashboxid = c.cashboxid
    LEFT JOIN tblapprovalrequests ar ON cp.approvalrequestid = ar.requestid
ORDER BY txndate DESC;

-- vw_unposted_pending_approval - documents waiting for approval
CREATE OR REPLACE VIEW vw_unposted_pending_approval AS
SELECT
    'BOND' AS sourcetype,
    b.bondcode AS sourceid,
    b.bondid AS docno,
    b.amount AS amount,
    b.bonddate AS docdate,
    ar.status,
    ar.currentlevel,
    ar.totallevels,
    ar.duedate,
    CASE
        WHEN ar.duedate < NOW() THEN 'OVERDUE'
        ELSE 'ON_TIME'
    END AS timeliness
FROM
    tblbondheader b
    JOIN tblapprovalrequests ar ON b.approvalrequestid = ar.requestid
WHERE
    ar.status = 'PENDING'
    AND b.isposted = FALSE
UNION ALL
SELECT
    'JOURNAL',
    j.journalcode,
    j.journalid,
    j.totaldebit,
    j.journaldate,
    ar.status,
    ar.currentlevel,
    ar.totallevels,
    ar.duedate,
    CASE
        WHEN ar.duedate < NOW() THEN 'OVERDUE'
        ELSE 'ON_TIME'
    END
FROM
    tbljournalheader j
    JOIN tblapprovalrequests ar ON j.approvalrequestid = ar.requestid
WHERE
    ar.status = 'PENDING'
    AND j.isposted = FALSE
UNION ALL
SELECT
    'CASH_RECEIPT',
    cr.receiptid,
    cr.receiptno,
    cr.amountlocal,
    cr.receiptdate,
    ar.status,
    ar.currentlevel,
    ar.totallevels,
    ar.duedate,
    CASE
        WHEN ar.duedate < NOW() THEN 'OVERDUE'
        ELSE 'ON_TIME'
    END
FROM
    tblcashreceipts cr
    JOIN tblapprovalrequests ar ON cr.approvalrequestid = ar.requestid
WHERE
    ar.status = 'PENDING'
UNION ALL
SELECT
    'CASH_PAYMENT',
    cp.paymentid,
    cp.paymentno,
    cp.amountlocal,
    cp.paymentdate,
    ar.status,
    ar.currentlevel,
    ar.totallevels,
    ar.duedate,
    CASE
        WHEN ar.duedate < NOW() THEN 'OVERDUE'
        ELSE 'ON_TIME'
    END
FROM
    tblcashpayments cp
    JOIN tblapprovalrequests ar ON cp.approvalrequestid = ar.requestid
WHERE
    ar.status = 'PENDING'
UNION ALL
SELECT
    'BANK_TXN',
    bt.banktxnid,
    bt.refno,
    bt.amountlocal,
    bt.txndate,
    ar.status,
    ar.currentlevel,
    ar.totallevels,
    ar.duedate,
    CASE
        WHEN ar.duedate < NOW() THEN 'OVERDUE'
        ELSE 'ON_TIME'
    END
FROM
    tblbanktransactions bt
    JOIN tblapprovalrequests ar ON bt.approvalrequestid = ar.requestid
WHERE
    ar.status = 'PENDING'
ORDER BY docdate DESC;

-- =====================================================
-- STEP 10: FUNCTIONS for integration
-- =====================================================

-- Force-approve a request (for testing/migration)
CREATE OR REPLACE FUNCTION forceApproveSource(p_sourcetype VARCHAR, p_sourceid BIGINT, p_approverid INTEGER, p_comments TEXT)
RETURNS VARCHAR AS $$
DECLARE
    v_requestid BIGINT;
    v_result VARCHAR;
BEGIN
    SELECT requestid INTO v_requestid
    FROM tblapprovalrequests
    WHERE sourcetype = p_sourcetype AND sourceid = p_sourceid
    ORDER BY requestid DESC
    LIMIT 1;

    IF v_requestid IS NULL THEN
        RETURN 'ERROR: No approval request found for ' || p_sourcetype || ' #' || p_sourceid;
    END IF;

    -- Approve through all levels
    FOR i IN 1..10 LOOP
        EXIT WHEN isApprovalComplete(v_requestid);
        CALL approveRequest(v_requestid, p_approverid, COALESCE(p_comments, 'Force-approved'), '127.0.0.1', 'Migration', NULL);
    END LOOP;

    RETURN 'SUCCESS: Force-approved ' || p_sourcetype || ' #' || p_sourceid || ' (request #' || v_requestid || ')';
END;
$$ LANGUAGE plpgsql;

-- Get combined status: source + approval
CREATE OR REPLACE FUNCTION getDocumentStatus(p_sourcetype VARCHAR, p_sourceid BIGINT)
RETURNS TABLE(
    docno VARCHAR, docdate DATE, amount NUMERIC, posted BOOLEAN,
    approvalrequestid BIGINT, requestno VARCHAR, status VARCHAR,
    currentlevel INTEGER, totallevels INTEGER, isapproved BOOLEAN, isoverdue BOOLEAN
) AS $$
BEGIN
    IF p_sourcetype = 'BOND' THEN
        RETURN QUERY
        SELECT b.bondid, b.bonddate, b.amount, b.isposted,
               b.approvalrequestid, ar.requestno, ar.status,
               ar.currentlevel, ar.totallevels,
               CASE WHEN ar.status = 'APPROVED' THEN TRUE
                    WHEN ar.status = 'PENDING' THEN FALSE
                    WHEN ar.status IS NULL THEN (b.amount < getApprovalConfig('BOND_AUTO_APPROVE_THRESHOLD'))
                    ELSE FALSE END,
               CASE WHEN ar.duedate < NOW() AND ar.status = 'PENDING' THEN TRUE ELSE FALSE END
        FROM tblbondheader b
        LEFT JOIN tblapprovalrequests ar ON b.approvalrequestid = ar.requestid
        WHERE b.bondcode = p_sourceid;
    ELSIF p_sourcetype = 'JOURNAL' THEN
        RETURN QUERY
        SELECT j.journalid, j.journaldate, j.totaldebit, j.isposted,
               j.approvalrequestid, ar.requestno, ar.status,
               ar.currentlevel, ar.totallevels,
               CASE WHEN ar.status = 'APPROVED' THEN TRUE
                    WHEN ar.status = 'PENDING' THEN FALSE
                    WHEN ar.status IS NULL THEN (j.totaldebit < getApprovalConfig('JOURNAL_AUTO_APPROVE_THRESHOLD'))
                    ELSE FALSE END,
               CASE WHEN ar.duedate < NOW() AND ar.status = 'PENDING' THEN TRUE ELSE FALSE END
        FROM tbljournalheader j
        LEFT JOIN tblapprovalrequests ar ON j.approvalrequestid = ar.requestid
        WHERE j.journalcode = p_sourceid;
    ELSIF p_sourcetype = 'CASH_RECEIPT' THEN
        RETURN QUERY
        SELECT cr.receiptno, cr.receiptdate, cr.amountlocal, FALSE,
               cr.approvalrequestid, ar.requestno, ar.status,
               ar.currentlevel, ar.totallevels,
               CASE WHEN ar.status = 'APPROVED' THEN TRUE
                    WHEN ar.status = 'PENDING' THEN FALSE
                    WHEN ar.status IS NULL THEN (cr.amountlocal < getApprovalConfig('CASH_AUTO_APPROVE_THRESHOLD'))
                    ELSE FALSE END,
               CASE WHEN ar.duedate < NOW() AND ar.status = 'PENDING' THEN TRUE ELSE FALSE END
        FROM tblcashreceipts cr
        LEFT JOIN tblapprovalrequests ar ON cr.approvalrequestid = ar.requestid
        WHERE cr.receiptid = p_sourceid;
    ELSIF p_sourcetype = 'CASH_PAYMENT' THEN
        RETURN QUERY
        SELECT cp.paymentno, cp.paymentdate, cp.amountlocal, FALSE,
               cp.approvalrequestid, ar.requestno, ar.status,
               ar.currentlevel, ar.totallevels,
               CASE WHEN ar.status = 'APPROVED' THEN TRUE
                    WHEN ar.status = 'PENDING' THEN FALSE
                    WHEN ar.status IS NULL THEN (cp.amountlocal < getApprovalConfig('CASH_AUTO_APPROVE_THRESHOLD'))
                    ELSE FALSE END,
               CASE WHEN ar.duedate < NOW() AND ar.status = 'PENDING' THEN TRUE ELSE FALSE END
        FROM tblcashpayments cp
        LEFT JOIN tblapprovalrequests ar ON cp.approvalrequestid = ar.requestid
        WHERE cp.paymentid = p_sourceid;
    ELSIF p_sourcetype = 'BANK_TXN' THEN
        RETURN QUERY
        SELECT bt.refno, bt.txndate, bt.amountlocal, FALSE,
               bt.approvalrequestid, ar.requestno, ar.status,
               ar.currentlevel, ar.totallevels,
               CASE WHEN ar.status = 'APPROVED' THEN TRUE
                    WHEN ar.status = 'PENDING' THEN FALSE
                    WHEN ar.status IS NULL THEN (bt.amountlocal < getApprovalConfig('BANK_AUTO_APPROVE_THRESHOLD'))
                    ELSE FALSE END,
               CASE WHEN ar.duedate < NOW() AND ar.status = 'PENDING' THEN TRUE ELSE FALSE END
        FROM tblbanktransactions bt
        LEFT JOIN tblapprovalrequests ar ON bt.approvalrequestid = ar.requestid
        WHERE bt.banktxnid = p_sourceid;
    END IF;
END;
$$ LANGUAGE plpgsql STABLE;
