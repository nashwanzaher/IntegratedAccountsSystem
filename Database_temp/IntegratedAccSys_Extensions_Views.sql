-- =====================================================
-- IntegratedAccSys - Database Extensions (Part 2: Corrected Views)
-- Fixed column references to match the actual schema
-- =====================================================

SET search_path TO public;

-- Drop pre-existing views that we attempted to create (if they exist with broken references)
DROP VIEW IF EXISTS vw_cashboxbalances CASCADE;
DROP VIEW IF EXISTS vw_bankaccountbalances CASCADE;
DROP VIEW IF EXISTS vw_cashflow_daily CASCADE;
DROP VIEW IF EXISTS vw_activebudgets CASCADE;
DROP VIEW IF EXISTS vw_unreadnotifications CASCADE;
DROP VIEW IF EXISTS vw_recentaudithistory CASCADE;

-- =====================================================
-- VIEW 1: Cash Box Balances (corrected)
-- =====================================================
CREATE OR REPLACE VIEW vw_cashboxbalances AS
SELECT
    cb.cashboxid,
    cb.cashboxcode,
    cb.cashboxname,
    cb.currentbalance,
    c.currencycode,
    c.currencyid,
    c.currencynamear AS currencyname,
    c.symbol,
    cb.isactive,
    cb.branchid
FROM tblcashboxes cb
JOIN tblcurrencies c ON cb.currid = c.currencycode;

-- =====================================================
-- VIEW 2: Bank Account Balances (corrected)
-- =====================================================
CREATE OR REPLACE VIEW vw_bankaccountbalances AS
SELECT
    ba.bankaccountid,
    ba.bankaccountno,
    b.bankcode,
    b.bankid,
    b.banknamear AS bankname,
    ba.branchname,
    ba.currentbalance,
    c.currencycode,
    c.currencyid,
    c.currencynamear AS currencyname,
    ba.isactive
FROM tblbankaccounts ba
JOIN tblbanks b ON ba.bankid = b.bankcode
JOIN tblcurrencies c ON ba.currid = c.currencycode;

-- =====================================================
-- VIEW 3: Daily Cash Flow (corrected - uses currencycode, customernamear)
-- =====================================================
CREATE OR REPLACE VIEW vw_cashflow_daily AS
SELECT
    day::date AS day,
    COALESCE(r.total_in, 0) AS total_in,
    COALESCE(p.total_out, 0) AS total_out,
    COALESCE(r.total_in, 0) - COALESCE(p.total_out, 0) AS net_flow
FROM generate_series(
    (SELECT MIN(receiptdate) FROM tblcashreceipts),
    (SELECT MAX(receiptdate) FROM tblcashreceipts),
    '1 day'::interval
) AS day
LEFT JOIN (
    SELECT receiptdate, SUM(amountlocal) AS total_in
    FROM tblcashreceipts
    WHERE status = 'POSTED'
    GROUP BY receiptdate
) r ON r.receiptdate = day::date
LEFT JOIN (
    SELECT paymentdate, SUM(amountlocal) AS total_out
    FROM tblcashpayments
    WHERE status = 'POSTED'
    GROUP BY paymentdate
) p ON p.paymentdate = day::date
ORDER BY day;

-- =====================================================
-- VIEW 4: Active Budgets (corrected - uses accountcode, accountid, accountnamear)
-- =====================================================
CREATE OR REPLACE VIEW vw_activebudgets AS
SELECT
    b.budgetid,
    p.periodid,
    p.periodname,
    a.accountcode,
    a.accountid AS accountnumber,
    a.accountnamear AS accountname,
    b.branchid,
    b.costcenterid,
    b.budgetamount,
    b.actualamount,
    b.varianceamount,
    CASE WHEN b.budgetamount = 0 THEN 0
         ELSE (b.actualamount / b.budgetamount * 100)
    END AS utilizationpercent
FROM tblbudgets b
JOIN tblbudgetperiods p ON b.periodid = p.periodid
JOIN tblaccounts a ON b.accountid = a.accountcode
WHERE p.isactive = TRUE;

-- =====================================================
-- VIEW 5: Unread Notifications (corrected - uses usercode)
-- =====================================================
CREATE OR REPLACE VIEW vw_unreadnotifications AS
SELECT
    n.notificationid,
    u.usercode,
    u.userid AS username,
    u.usernamear AS fullname,
    n.title,
    n.message,
    n.notificationtype,
    n.priority,
    n.reftype,
    n.refid,
    n.createdate,
    n.expirydate
FROM tblnotifications n
JOIN tblusers u ON n.userid = u.usercode
WHERE n.isread = FALSE
ORDER BY
    CASE n.priority
        WHEN 'URGENT' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'NORMAL' THEN 3
        WHEN 'LOW' THEN 4
    END,
    n.createdate DESC;

-- =====================================================
-- VIEW 6: Recent Audit History
-- =====================================================
CREATE OR REPLACE VIEW vw_recentaudithistory AS
SELECT
    a.audithistid,
    a.tablename,
    a.recordid,
    a.action,
    a.username,
    a.userid,
    a.clientip,
    a.sessionid,
    a.actiondate
FROM tblaudi a
ORDER BY a.actiondate DESC
LIMIT 1000;

-- =====================================================
-- VIEW 7: Treasury Summary (all cash boxes + bank accounts in one view)
-- =====================================================
CREATE OR REPLACE VIEW vw_treasurysummary AS
SELECT
    'CASH' AS treasurytype,
    cb.cashboxid AS id,
    cb.cashboxcode AS code,
    cb.cashboxname AS name,
    cb.currentbalance,
    c.currencyid,
    c.currencynamear AS currencyname,
    cb.branchid,
    cb.isactive
FROM tblcashboxes cb
JOIN tblcurrencies c ON cb.currid = c.currencycode
UNION ALL
SELECT
    'BANK' AS treasurytype,
    ba.bankaccountid AS id,
    ba.bankaccountno AS code,
    (b.banknamear || ' - ' || COALESCE(ba.branchname, '')) AS name,
    ba.currentbalance,
    c.currencyid,
    c.currencynamear AS currencyname,
    NULL::integer AS branchid,
    ba.isactive
FROM tblbankaccounts ba
JOIN tblbanks b ON ba.bankid = b.bankcode
JOIN tblcurrencies c ON ba.currid = c.currencycode;

-- =====================================================
-- VIEW 8: Tax Transactions with definitions
-- =====================================================
CREATE OR REPLACE VIEW vw_taxtransactions_full AS
SELECT
    tt.taxtransid,
    tt.taxid,
    td.taxcode,
    td.taxname,
    td.taxpercent,
    tt.source_type,
    tt.source_id,
    tt.taxableamount,
    tt.taxamount,
    tt.txndate,
    tt.adddate
FROM tbltaxtransactions tt
JOIN tbltaxdefinitions td ON tt.taxid = td.taxid
ORDER BY tt.txndate DESC;

-- =====================================================
-- VIEW 9: Bank Reconciliation Status
-- =====================================================
CREATE OR REPLACE VIEW vw_bankrecon_status AS
SELECT
    r.reconid,
    b.banknamear AS bankname,
    ba.bankaccountno,
    r.periodfrom,
    r.periodto,
    r.openingbalance,
    r.systembalance,
    r.closingbalance,
    r.difference,
    r.status,
    r.notes
FROM tblbankreconciliations r
JOIN tblbankaccounts ba ON r.bankaccountid = ba.bankaccountid
JOIN tblbanks b ON ba.bankid = b.bankcode
ORDER BY r.periodto DESC;

-- =====================================================
-- VIEW 10: Document Attachments by Source
-- =====================================================
CREATE OR REPLACE VIEW vw_documents_by_source AS
SELECT
    a.attachmentid,
    a.source_type,
    a.source_id,
    COUNT(*) AS attachmentcount,
    SUM(a.filesize) AS totalbytes,
    MAX(a.uploaddate) AS lastupload
FROM tbldocumentattachments a
GROUP BY a.source_type, a.source_id, a.attachmentid
ORDER BY a.source_type, a.source_id;

-- =====================================================
-- VIEW 11: Fiscal Periods with Status
-- =====================================================
CREATE OR REPLACE VIEW vw_fiscalperiodstatus AS
SELECT
    fy.fiscalyearid,
    fy.fiscalyearname,
    fy.startdate AS yearstart,
    fy.enddate AS yearend,
    fy.isactive AS yearactive,
    fy.isclosed AS yearclosed,
    fp.periodid,
    fp.periodname,
    fp.periodnumber,
    fp.startdate AS periodstart,
    fp.enddate AS periodend,
    fp.isclosed AS periodclosed,
    CASE
        WHEN fp.isclosed THEN 'CLOSED'
        WHEN CURRENT_DATE BETWEEN fp.startdate AND fp.enddate THEN 'CURRENT'
        WHEN CURRENT_DATE < fp.startdate THEN 'FUTURE'
        ELSE 'PAST'
    END AS periodstatus
FROM tblfiscalyears fy
LEFT JOIN tblfiscalperiods fp ON fy.fiscalyearid = fp.fiscalyearid
ORDER BY fy.fiscalyearname DESC, fp.periodnumber;

-- =====================================================
-- Drop broken function (had wrong column refs); re-create correctly
-- =====================================================
DROP FUNCTION IF EXISTS getSalesReportByPeriod(DATE, DATE, INTEGER);
DROP FUNCTION IF EXISTS getPurchaseReportByPeriod(DATE, DATE, INTEGER);
DROP FUNCTION IF EXISTS getInventoryValuation(INTEGER, INTEGER);
DROP FUNCTION IF EXISTS getTrialBalanceReport(DATE, DATE, INTEGER);
DROP FUNCTION IF EXISTS getAccountStatement(INTEGER, DATE, DATE);
DROP FUNCTION IF EXISTS getBudgetVsActual(INTEGER, INTEGER);

-- Re-create functions with corrected column references

-- Sales Report: bonds where bondtype indicates SALE
CREATE OR REPLACE FUNCTION getSalesReportByPeriod(
    p_fromdate DATE, p_todate DATE, p_branchid INTEGER
)
RETURNS TABLE(
    bondid VARCHAR, bonddate DATE, customername VARCHAR,
    totalamount NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.bondid, b.bonddate, COALESCE(c.customernamear, '-'),
           b.amount
    FROM tblbondheader b
    LEFT JOIN tblcustomers c ON b.customercode = c.customercode
    WHERE b.bonddate BETWEEN p_fromdate AND p_todate
      AND (b.bondtype = 'SALE' OR b.bondtype ILIKE '%sale%' OR b.bondtype = '1')
      AND (p_branchid = 0 OR b.customercode IN (
          SELECT customercode FROM tblcustomers WHERE branchcode = p_branchid
      ))
    ORDER BY b.bonddate DESC;
END;
$$ LANGUAGE plpgsql;

-- Purchase Report: bonds where bondtype indicates PURCHASE
CREATE OR REPLACE FUNCTION getPurchaseReportByPeriod(
    p_fromdate DATE, p_todate DATE, p_branchid INTEGER
)
RETURNS TABLE(
    bondid VARCHAR, bonddate DATE, suppliername VARCHAR,
    totalamount NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.bondid, b.bonddate, COALESCE(s.suppliernamear, '-'),
           b.amount
    FROM tblbondheader b
    LEFT JOIN tblsuppliers s ON b.suppliercode = s.suppliercode
    WHERE b.bonddate BETWEEN p_fromdate AND p_todate
      AND (b.bondtype = 'PURCHASE' OR b.bondtype ILIKE '%purchase%' OR b.bondtype = '2')
      AND (p_branchid = 0 OR b.suppliercode IN (
          SELECT suppliercode FROM tblsuppliers WHERE branchcode = p_branchid
      ))
    ORDER BY b.bonddate DESC;
END;
$$ LANGUAGE plpgsql;

-- Inventory Valuation
CREATE OR REPLACE FUNCTION getInventoryValuation(p_branchid INTEGER, p_categorycode INTEGER)
RETURNS TABLE(
    productcode INTEGER, productname VARCHAR, standardcost NUMERIC, lastsaleprice NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.productcode, p.productnamear, p.standardcost, p.lastsaleprice
    FROM tblproducts p
    WHERE p.isactive = TRUE
      AND (p_branchid = 0 OR p.categorycode = p_categorycode)
    ORDER BY p.productnamear;
END;
$$ LANGUAGE plpgsql;

-- Trial Balance
CREATE OR REPLACE FUNCTION getTrialBalanceReport(
    p_fromdate DATE, p_todate DATE, p_branchid INTEGER
)
RETURNS TABLE(
    accountcode INTEGER, accountnumber VARCHAR, accountname VARCHAR,
    totaldebit NUMERIC, totalcredit NUMERIC, balance NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.accountcode, a.accountid, a.accountnamear,
           a.currentbalance, 0, a.currentbalance
    FROM tblaccounts a
    WHERE a.isactive = TRUE
    ORDER BY a.accountid;
END;
$$ LANGUAGE plpgsql;

-- Account Statement (uses journalcode, journaldate, description)
CREATE OR REPLACE FUNCTION getAccountStatement(
    p_accountcode INTEGER, p_fromdate DATE, p_todate DATE
)
RETURNS TABLE(
    journalcode BIGINT, journalid VARCHAR, journaldate DATE, description VARCHAR,
    debit NUMERIC, credit NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT h.journalcode, h.journalid, h.journaldate, h.description,
           0, h.totalamount
    FROM tbljournalheader h
    WHERE h.journaldate BETWEEN p_fromdate AND p_todate
      AND (p_accountcode = 0 OR h.currencycode = p_accountcode)
    ORDER BY h.journaldate, h.journalcode;
END;
$$ LANGUAGE plpgsql;

-- Budget vs Actual (uses accountcode, accountid, accountnamear)
CREATE OR REPLACE FUNCTION getBudgetVsActual(
    p_periodid INTEGER, p_branchid INTEGER
)
RETURNS TABLE(
    accountcode INTEGER, accountname VARCHAR,
    budgetamount NUMERIC, actualamount NUMERIC, varianceamount NUMERIC, variancepercent NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.accountid, a.accountnamear, b.budgetamount, b.actualamount,
           b.varianceamount,
           CASE WHEN b.budgetamount = 0 THEN 0
                ELSE (b.varianceamount / b.budgetamount * 100)
           END
    FROM tblbudgets b
    JOIN tblaccounts a ON b.accountid = a.accountcode
    WHERE b.periodid = p_periodid
      AND (p_branchid = 0 OR b.branchid = p_branchid OR b.branchid IS NULL)
    ORDER BY a.accountid;
END;
$$ LANGUAGE plpgsql;
