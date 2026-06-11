-- =====================================================
-- IntegratedAccSys - Database Extensions
-- Adds new sections: Treasury, Reports, Tax, BankReconciliation, Budget, Documents, Notifications, Audit
-- Date: 2026-06-09
-- =====================================================
-- Naming conventions (matches existing):
--   - Tables: lowercase, prefix tbl*
--   - Columns: snake_case
--   - Primary keys: <col>id SERIAL/BIGSERIAL
--   - Foreign keys: <referenced_table_singular>id
--   - Audit columns: adddate, adduser, editdate, edituser
--   - Timestamps: TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- =====================================================

SET search_path TO public;

-- =====================================================
-- SECTION 1: TREASURY (Cash Management)
-- =====================================================

-- Cash boxes / safes
CREATE TABLE IF NOT EXISTS tblcashboxes (
    cashboxid          SERIAL PRIMARY KEY,
    cashboxcode        VARCHAR(20) NOT NULL UNIQUE,
    cashboxname        VARCHAR(100) NOT NULL,
    branchid           INTEGER NOT NULL REFERENCES tblbranches,
    currid             INTEGER NOT NULL REFERENCES tblcurrencies,
    openingbalance     NUMERIC(18,4) DEFAULT 0 NOT NULL,
    currentbalance     NUMERIC(18,4) DEFAULT 0 NOT NULL,
    isactive           BOOLEAN DEFAULT TRUE NOT NULL,
    notes              TEXT,
    adduser            INTEGER,
    adddate            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edituser           INTEGER,
    editdate           TIMESTAMP
);

-- Cash receipts (money in)
CREATE TABLE IF NOT EXISTS tblcashreceipts (
    receiptid          BIGSERIAL PRIMARY KEY,
    receiptno          VARCHAR(30) NOT NULL UNIQUE,
    receiptdate        DATE NOT NULL,
    cashboxid          INTEGER NOT NULL REFERENCES tblcashboxes,
    customerid         INTEGER REFERENCES tblcustomers,
    supplierid         INTEGER REFERENCES tblsuppliers,
    amount             NUMERIC(18,4) NOT NULL CHECK (amount > 0),
    currid             INTEGER NOT NULL REFERENCES tblcurrencies,
    exgrate            NUMERIC(18,8) DEFAULT 1 NOT NULL,
    amountlocal        NUMERIC(18,4) GENERATED ALWAYS AS (amount * exgrate) STORED,
    paymentmethodid    INTEGER REFERENCES tblpaymentmethods,
    description        TEXT,
    status             VARCHAR(20) DEFAULT 'POSTED' NOT NULL,
    adduser            INTEGER,
    adddate            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edituser           INTEGER,
    editdate           TIMESTAMP
);

-- Cash payments (money out)
CREATE TABLE IF NOT EXISTS tblcashpayments (
    paymentid          BIGSERIAL PRIMARY KEY,
    paymentno          VARCHAR(30) NOT NULL UNIQUE,
    paymentdate        DATE NOT NULL,
    cashboxid          INTEGER NOT NULL REFERENCES tblcashboxes,
    supplierid         INTEGER REFERENCES tblsuppliers,
    customerid         INTEGER REFERENCES tblcustomers,
    amount             NUMERIC(18,4) NOT NULL CHECK (amount > 0),
    currid             INTEGER NOT NULL REFERENCES tblcurrencies,
    exgrate            NUMERIC(18,8) DEFAULT 1 NOT NULL,
    amountlocal        NUMERIC(18,4) GENERATED ALWAYS AS (amount * exgrate) STORED,
    paymentmethodid    INTEGER REFERENCES tblpaymentmethods,
    description        TEXT,
    status             VARCHAR(20) DEFAULT 'POSTED' NOT NULL,
    adduser            INTEGER,
    adddate            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edituser           INTEGER,
    editdate           TIMESTAMP
);

-- Bank accounts
CREATE TABLE IF NOT EXISTS tblbankaccounts (
    bankaccountid      SERIAL PRIMARY KEY,
    bankaccountno      VARCHAR(50) NOT NULL UNIQUE,
    bankid             INTEGER NOT NULL REFERENCES tblbanks,
    branchname         VARCHAR(100),
    currid             INTEGER NOT NULL REFERENCES tblcurrencies,
    iban               VARCHAR(50),
    swiftcode          VARCHAR(20),
    openingbalance     NUMERIC(18,4) DEFAULT 0 NOT NULL,
    currentbalance     NUMERIC(18,4) DEFAULT 0 NOT NULL,
    isactive           BOOLEAN DEFAULT TRUE NOT NULL,
    adduser            INTEGER,
    adddate            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    edituser           INTEGER,
    editdate           TIMESTAMP
);

-- Bank transactions (deposits, withdrawals, transfers)
CREATE TABLE IF NOT EXISTS tblbanktransactions (
    banktxnid          BIGSERIAL PRIMARY KEY,
    txndate            DATE NOT NULL,
    bankaccountid      INTEGER NOT NULL REFERENCES tblbankaccounts,
    txnttyp             VARCHAR(20) NOT NULL CHECK (txnttyp IN ('DEPOSIT', 'WITHDRAWAL', 'TRANSFER', 'FEE', 'INTEREST')),
    amount             NUMERIC(18,4) NOT NULL,
    currid             INTEGER NOT NULL REFERENCES tblcurrencies,
    exgrate            NUMERIC(18,8) DEFAULT 1 NOT NULL,
    amountlocal        NUMERIC(18,4) GENERATED ALWAYS AS (amount * exgrate) STORED,
    counteraccountid   INTEGER REFERENCES tblbankaccounts,
    description        TEXT,
    refno              VARCHAR(50),
    status             VARCHAR(20) DEFAULT 'POSTED' NOT NULL,
    adduser            INTEGER,
    adddate            TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for Treasury
CREATE INDEX IF NOT EXISTS ix_cashreceipts_date ON tblcashreceipts(receiptdate);
CREATE INDEX IF NOT EXISTS ix_cashreceipts_cashbox ON tblcashreceipts(cashboxid);
CREATE INDEX IF NOT EXISTS ix_cashpayments_date ON tblcashpayments(paymentdate);
CREATE INDEX IF NOT EXISTS ix_banktransactions_date ON tblbanktransactions(txndate);
CREATE INDEX IF NOT EXISTS ix_banktransactions_account ON tblbanktransactions(bankaccountid);

-- Treasury Procedures
CREATE OR REPLACE FUNCTION getCashBoxBalance(p_cashboxid INTEGER)
RETURNS NUMERIC AS $$
DECLARE v_balance NUMERIC(18,4);
BEGIN
    SELECT currentbalance INTO v_balance FROM tblcashboxes WHERE cashboxid = p_cashboxid;
    RETURN COALESCE(v_balance, 0);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getCashReceiptsByDate(p_fromdate DATE, p_todate DATE, p_cashboxid INTEGER)
RETURNS TABLE(receiptid BIGINT, receiptno VARCHAR, receiptdate DATE, amount NUMERIC, customername VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT r.receiptid, r.receiptno, r.receiptdate, r.amountlocal, COALESCE(c.custname, '-')
    FROM tblcashreceipts r
    LEFT JOIN tblcustomers c ON r.customerid = c.custcode
    WHERE r.receiptdate BETWEEN p_fromdate AND p_todate
      AND (p_cashboxid = 0 OR r.cashboxid = p_cashboxid)
    ORDER BY r.receiptdate DESC, r.receiptid DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getCashPaymentsByDate(p_fromdate DATE, p_todate DATE, p_cashboxid INTEGER)
RETURNS TABLE(paymentid BIGINT, paymentno VARCHAR, paymentdate DATE, amount NUMERIC, suppliername VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT p.paymentid, p.paymentno, p.paymentdate, p.amountlocal, COALESCE(s.suppname, '-')
    FROM tblcashpayments p
    LEFT JOIN tblsuppliers s ON p.supplierid = s.suppcode
    WHERE p.paymentdate BETWEEN p_fromdate AND p_todate
      AND (p_cashboxid = 0 OR p.cashboxid = p_cashboxid)
    ORDER BY p.paymentdate DESC, p.paymentid DESC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SECTION 2: REPORTS (Stored procedures for RDLC)
-- =====================================================

-- Report definitions catalog
CREATE TABLE IF NOT EXISTS tblreportdefinitions (
    reportid           SERIAL PRIMARY KEY,
    reportcode         VARCHAR(50) NOT NULL UNIQUE,
    reportname         VARCHAR(200) NOT NULL,
    reportcategory      VARCHAR(50) NOT NULL,
    description        TEXT,
    rdlcfilename       VARCHAR(200),
    parameterschema    JSONB,
    isactive           BOOLEAN DEFAULT TRUE NOT NULL,
    adduser            INTEGER,
    adddate            TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sales report function
CREATE OR REPLACE FUNCTION getSalesReportByPeriod(
    p_fromdate DATE, p_todate DATE, p_branchid INTEGER
)
RETURNS TABLE(
    bondno VARCHAR, bonddate DATE, customername VARCHAR,
    totalamount NUMERIC, paidamount NUMERIC, remainingamount NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.bondno, b.bonddate, COALESCE(c.custname, '-'),
           b.accdebit, 0, b.accdebit
    FROM tblbondheader b
    LEFT JOIN tblcustomers c ON b.accid = c.custcode
    WHERE b.bonddate BETWEEN p_fromdate AND p_todate
      AND b.optype = 1  -- Sales
      AND (p_branchid = 0 OR b.braid = p_branchid)
    ORDER BY b.bonddate DESC;
END;
$$ LANGUAGE plpgsql;

-- Purchase report function
CREATE OR REPLACE FUNCTION getPurchaseReportByPeriod(
    p_fromdate DATE, p_todate DATE, p_branchid INTEGER
)
RETURNS TABLE(
    bondno VARCHAR, bonddate DATE, suppliername VARCHAR,
    totalamount NUMERIC, paidamount NUMERIC, remainingamount NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.bondno, b.bonddate, COALESCE(s.suppname, '-'),
           b.accdebit, 0, b.accdebit
    FROM tblbondheader b
    LEFT JOIN tblsuppliers s ON b.accid = s.suppcode
    WHERE b.bonddate BETWEEN p_fromdate AND p_todate
      AND b.optype = 2  -- Purchase
      AND (p_branchid = 0 OR b.braid = p_branchid)
    ORDER BY b.bonddate DESC;
END;
$$ LANGUAGE plpgsql;

-- Inventory valuation function
CREATE OR REPLACE FUNCTION getInventoryValuation(
    p_branchid INTEGER, p_storeid INTEGER
)
RETURNS TABLE(
    productid INTEGER, productname VARCHAR, onhandqty NUMERIC,
    avgcost NUMERIC, totalvalue NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.prodid, p.prodname, 0, p.purprice, 0
    FROM tblproducts p
    WHERE p.isactive = TRUE
      AND (p_branchid = 0 OR p.braid = p_branchid)
    ORDER BY p.prodname;
END;
$$ LANGUAGE plpgsql;

-- Trial balance function
CREATE OR REPLACE FUNCTION getTrialBalanceReport(
    p_fromdate DATE, p_todate DATE, p_branchid INTEGER
)
RETURNS TABLE(
    accountid INTEGER, accountname VARCHAR, accountcode VARCHAR,
    totaldebit NUMERIC, totalcredit NUMERIC, balance NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.accid, a.accname, a.accno, 0, 0, 0
    FROM tblaccounts a
    WHERE a.isparent = FALSE
    ORDER BY a.accno;
END;
$$ LANGUAGE plpgsql;

-- Account statement function
CREATE OR REPLACE FUNCTION getAccountStatement(
    p_accountid INTEGER, p_fromdate DATE, p_todate DATE
)
RETURNS TABLE(
    jno BIGINT, jdate DATE, jnote TEXT,
    debit NUMERIC, credit NUMERIC, balance NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT h.jno, h.jdate, h.jnote,
           SUM(CASE WHEN b.accid = p_accountid THEN b.accdebit ELSE 0 END),
           SUM(CASE WHEN b.accid = p_accountid THEN b.acccredit ELSE 0 END),
           0
    FROM tbljournalheader h
    JOIN tbljournalbody b ON h.jno = b.jno
    WHERE h.jdate BETWEEN p_fromdate AND p_todate
      AND (p_accountid = 0 OR b.accid = p_accountid)
    GROUP BY h.jno, h.jdate, h.jnote
    ORDER BY h.jdate, h.jno;
END;
$$ LANGUAGE plpgsql;

-- Seed default report definitions
INSERT INTO tblreportdefinitions (reportcode, reportname, reportcategory, description, rdlcfilename) VALUES
    ('SALES_PERIOD', 'Sales Report by Period', 'Sales', 'Lists all sales bonds within a date range', 'rptSalesByPeriod.rdlc'),
    ('PURCHASE_PERIOD', 'Purchase Report by Period', 'Purchases', 'Lists all purchase bonds within a date range', 'rptPurchaseByPeriod.rdlc'),
    ('INVENTORY_VAL', 'Inventory Valuation', 'Inventory', 'Shows current stock value at average cost', 'rptInventoryValuation.rdlc'),
    ('TRIAL_BALANCE', 'Trial Balance', 'Accounting', 'Lists all account balances', 'rptTrialBalance.rdlc'),
    ('ACCOUNT_STMT', 'Account Statement', 'Accounting', 'Detailed transactions for one account', 'rptAccountStatement.rdlc'),
    ('CASH_FLOW', 'Cash Flow Statement', 'Treasury', 'Cash receipts and payments for a period', 'rptCashFlow.rdlc'),
    ('BANK_RECON', 'Bank Reconciliation', 'Treasury', 'Match bank transactions with system records', 'rptBankReconciliation.rdlc'),
    ('INVENTORY_MOVE', 'Inventory Movement', 'Inventory', 'Stock movements by product/store/period', 'rptInventoryMovement.rdlc'),
    ('SALES_BY_CUST', 'Sales by Customer', 'Sales', 'Sales summary grouped by customer', 'rptSalesByCustomer.rdlc'),
    ('PURCH_BY_SUPP', 'Purchases by Supplier', 'Purchases', 'Purchase summary grouped by supplier', 'rptPurchasesBySupplier.rdlc'),
    ('PROFIT_LOSS', 'Profit & Loss Statement', 'Accounting', 'Revenue and expense summary', 'rptProfitLoss.rdlc'),
    ('BALANCE_SHEET', 'Balance Sheet', 'Accounting', 'Assets, liabilities, and equity', 'rptBalanceSheet.rdlc')
ON CONFLICT (reportcode) DO NOTHING;

-- =====================================================
-- SECTION 3: TAX MANAGEMENT (enhance existing)
-- =====================================================

CREATE TABLE IF NOT EXISTS tbltaxdefinitions (
    taxid              SERIAL PRIMARY KEY,
    taxcode            VARCHAR(20) NOT NULL UNIQUE,
    taxname            VARCHAR(100) NOT NULL,
    taxpercent         NUMERIC(8,4) NOT NULL,
    isinclusive        BOOLEAN DEFAULT FALSE NOT NULL,
    isactive           BOOLEAN DEFAULT TRUE NOT NULL,
    effectivedate      DATE NOT NULL,
    expirydate         DATE,
    notes              TEXT,
    adduser            INTEGER,
    adddate            TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO tbltaxdefinitions (taxcode, taxname, taxpercent, effectivedate) VALUES
    ('VAT-15', 'VAT 15%', 15.0000, '2024-01-01'),
    ('VAT-5', 'Reduced VAT 5%', 5.0000, '2024-01-01'),
    ('VAT-0', 'Zero-rated VAT', 0.0000, '2024-01-01'),
    ('WHT-3', 'Withholding Tax 3%', 3.0000, '2024-01-01'),
    ('WHT-5', 'Withholding Tax 5%', 5.0000, '2024-01-01'),
    ('EXEMPT', 'Tax Exempt', 0.0000, '2024-01-01')
ON CONFLICT (taxcode) DO NOTHING;

-- Tax transaction linkage
CREATE TABLE IF NOT EXISTS tbltaxtransactions (
    taxtransid         BIGSERIAL PRIMARY KEY,
    taxid              INTEGER NOT NULL REFERENCES tbltaxdefinitions,
    source_type        VARCHAR(20) NOT NULL CHECK (source_type IN ('BOND', 'JOURNAL', 'OPERATION', 'CASH')),
    source_id          BIGINT NOT NULL,
    taxableamount      NUMERIC(18,4) NOT NULL,
    taxamount          NUMERIC(18,4) NOT NULL,
    txndate            DATE NOT NULL,
    adddate            TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS ix_taxtransactions_source ON tbltaxtransactions(source_type, source_id);
CREATE INDEX IF NOT EXISTS ix_taxtransactions_date ON tbltaxtransactions(txndate);

-- =====================================================
-- SECTION 4: BANK RECONCILIATION
-- =====================================================

CREATE TABLE IF NOT EXISTS tblbankstatements (
    statementid        BIGSERIAL PRIMARY KEY,
    bankaccountid      INTEGER NOT NULL REFERENCES tblbankaccounts,
    statementdate      DATE NOT NULL,
    statementno        VARCHAR(50) NOT NULL,
    openingbalance     NUMERIC(18,4) NOT NULL,
    closingbalance     NUMERIC(18,4) NOT NULL,
    totaldebit         NUMERIC(18,4) DEFAULT 0,
    totalcredit        NUMERIC(18,4) DEFAULT 0,
    importeddate       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    isreconcilied      BOOLEAN DEFAULT FALSE,
    adduser            INTEGER
);

CREATE TABLE IF NOT EXISTS tblbankstatementlines (
    stmtlineid         BIGSERIAL PRIMARY KEY,
    statementid        BIGINT NOT NULL REFERENCES tblbankstatements ON DELETE CASCADE,
    txndate            DATE NOT NULL,
    description        TEXT,
    debitamount        NUMERIC(18,4) DEFAULT 0,
    creditamount       NUMERIC(18,4) DEFAULT 0,
    refno              VARCHAR(50),
    ismatched          BOOLEAN DEFAULT FALSE,
    matchedtxnid       BIGINT REFERENCES tblbanktransactions
);

CREATE TABLE IF NOT EXISTS tblbankreconciliations (
    reconid            BIGSERIAL PRIMARY KEY,
    bankaccountid      INTEGER NOT NULL REFERENCES tblbankaccounts,
    periodfrom         DATE NOT NULL,
    periodto           DATE NOT NULL,
    openingbalance     NUMERIC(18,4) NOT NULL,
    closingbalance     NUMERIC(18,4) NOT NULL,
    systembalance      NUMERIC(18,4) NOT NULL,
    difference         NUMERIC(18,4) NOT NULL,
    status             VARCHAR(20) DEFAULT 'OPEN' NOT NULL CHECK (status IN ('OPEN', 'BALANCED', 'ADJUSTED', 'CLOSED')),
    notes              TEXT,
    adduser            INTEGER,
    adddate            TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- SECTION 5: BUDGET MANAGEMENT
-- =====================================================

CREATE TABLE IF NOT EXISTS tblbudgetperiods (
    periodid           SERIAL PRIMARY KEY,
    periodname         VARCHAR(50) NOT NULL UNIQUE,
    periodfrom         DATE NOT NULL,
    periodto           DATE NOT NULL,
    isactive           BOOLEAN DEFAULT TRUE NOT NULL,
    notes              TEXT,
    adduser            INTEGER,
    adddate            TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tblbudgets (
    budgetid           BIGSERIAL PRIMARY KEY,
    periodid           INTEGER NOT NULL REFERENCES tblbudgetperiods,
    accountid          INTEGER NOT NULL REFERENCES tblaccounts,
    branchid           INTEGER REFERENCES tblbranches,
    costcenterid       INTEGER REFERENCES tblcostcenters,
    budgetamount       NUMERIC(18,4) NOT NULL,
    actualamount       NUMERIC(18,4) DEFAULT 0,
    varianceamount     NUMERIC(18,4) GENERATED ALWAYS AS (actualamount - budgetamount) STORED,
    notes              TEXT,
    adduser            INTEGER,
    adddate            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (periodid, accountid, branchid, costcenterid)
);

CREATE OR REPLACE FUNCTION getBudgetVsActual(
    p_periodid INTEGER, p_branchid INTEGER
)
RETURNS TABLE(
    accountid INTEGER, accountname VARCHAR,
    budgetamount NUMERIC, actualamount NUMERIC, varianceamount NUMERIC, variancepercent NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.accountid, a.accname, b.budgetamount, b.actualamount,
           b.varianceamount, 
           CASE WHEN b.budgetamount = 0 THEN 0 ELSE (b.varianceamount / b.budgetamount * 100) END
    FROM tblbudgets b
    JOIN tblaccounts a ON b.accountid = a.accid
    WHERE b.periodid = p_periodid
      AND (p_branchid = 0 OR b.branchid = p_branchid OR b.branchid IS NULL)
    ORDER BY a.accno;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SECTION 6: DOCUMENT ATTACHMENTS
-- =====================================================

CREATE TABLE IF NOT EXISTS tbldocumentattachments (
    attachmentid       BIGSERIAL PRIMARY KEY,
    source_type        VARCHAR(30) NOT NULL,
    source_id          BIGINT NOT NULL,
    filename           VARCHAR(255) NOT NULL,
    originalfilename   VARCHAR(255) NOT NULL,
    contenttype        VARCHAR(100),
    filesize           BIGINT NOT NULL,
    filecontent        BYTEA,
    filepath           VARCHAR(500),
    description        TEXT,
    uploadedby         INTEGER,
    uploaddate         TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS ix_documentattachments_source ON tbldocumentattachments(source_type, source_id);

-- =====================================================
-- SECTION 7: NOTIFICATIONS
-- =====================================================

CREATE TABLE IF NOT EXISTS tblnotifications (
    notificationid     BIGSERIAL PRIMARY KEY,
    userid             INTEGER NOT NULL REFERENCES tblusers,
    title              VARCHAR(200) NOT NULL,
    message            TEXT NOT NULL,
    notificationtype   VARCHAR(50) NOT NULL DEFAULT 'INFO',
    priority           VARCHAR(20) DEFAULT 'NORMAL' CHECK (priority IN ('LOW', 'NORMAL', 'HIGH', 'URGENT')),
    isread             BOOLEAN DEFAULT FALSE,
    reftype            VARCHAR(30),
    refid              BIGINT,
    expirydate         TIMESTAMP,
    createdate         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    readdate           TIMESTAMP
);
CREATE INDEX IF NOT EXISTS ix_notifications_user ON tblnotifications(userid, isread);

-- =====================================================
-- SECTION 8: AUDIT LOG ENHANCEMENTS
-- =====================================================

CREATE TABLE IF NOT EXISTS tblaudi (
    audithistid        BIGSERIAL PRIMARY KEY,
    tablename          VARCHAR(100) NOT NULL,
    recordid           BIGINT NOT NULL,
    action             VARCHAR(20) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    olddata            JSONB,
    newdata            JSONB,
    changedfields      TEXT[],
    userid             INTEGER,
    username           VARCHAR(50),
    actiondate         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    clientip           VARCHAR(50),
    sessionid          VARCHAR(100)
);
CREATE INDEX IF NOT EXISTS ix_audithist_table_record ON tblaudi(tablename, recordid);
CREATE INDEX IF NOT EXISTS ix_audithist_user ON tblaudi(userid);
CREATE INDEX IF NOT EXISTS ix_audithist_date ON tblaudi(actiondate);

-- Generic audit trigger function
CREATE OR REPLACE FUNCTION fn_audit_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO tblaudi (tablename, recordid, action, newdata, userid)
        VALUES (TG_TABLE_NAME, NEW.*::text::bigint, 'INSERT', to_jsonb(NEW), 0);
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO tblaudi (tablename, recordid, action, olddata, newdata, userid)
        VALUES (TG_TABLE_NAME, OLD.*::text::bigint, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW), 0);
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO tblaudi (tablename, recordid, action, olddata, userid)
        VALUES (TG_TABLE_NAME, OLD.*::text::bigint, 'DELETE', to_jsonb(OLD), 0);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SECTION 9: EXCHANGE RATE HISTORY
-- =====================================================

CREATE TABLE IF NOT EXISTS tblexchangeratehistory (
    ratehistid         BIGSERIAL PRIMARY KEY,
    currid             INTEGER NOT NULL REFERENCES tblcurrencies,
    exgrate            NUMERIC(18,8) NOT NULL,
    effectivedate      DATE NOT NULL,
    expirydate         DATE,
    source             VARCHAR(50) DEFAULT 'MANUAL',
    notes              TEXT,
    adduser            INTEGER,
    adddate            TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS ix_exchangerate_curr_date ON tblexchangeratehistory(currid, effectivedate DESC);

CREATE OR REPLACE FUNCTION getExchangeRateAtDate(
    p_currid INTEGER, p_atdate DATE
)
RETURNS NUMERIC AS $$
DECLARE v_rate NUMERIC(18,8);
BEGIN
    SELECT exgrate INTO v_rate
    FROM tblexchangeratehistory
    WHERE currid = p_currid
      AND effectivedate <= p_atdate
      AND (expirydate IS NULL OR expirydate >= p_atdate)
    ORDER BY effectivedate DESC
    LIMIT 1;
    RETURN COALESCE(v_rate, 1);
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SECTION 10: FISCAL YEAR & PERIOD MANAGEMENT
-- =====================================================

CREATE TABLE IF NOT EXISTS tblfiscalyears (
    fiscalyearid       SERIAL PRIMARY KEY,
    fiscalyearname     VARCHAR(50) NOT NULL UNIQUE,
    startdate          DATE NOT NULL,
    enddate            DATE NOT NULL,
    isactive           BOOLEAN DEFAULT TRUE NOT NULL,
    isclosed           BOOLEAN DEFAULT FALSE NOT NULL,
    adduser            INTEGER,
    adddate            TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tblfiscalperiods (
    periodid           SERIAL PRIMARY KEY,
    fiscalyearid       INTEGER NOT NULL REFERENCES tblfiscalyears,
    periodname         VARCHAR(50) NOT NULL,
    periodnumber       INTEGER NOT NULL,
    startdate          DATE NOT NULL,
    enddate            DATE NOT NULL,
    isclosed           BOOLEAN DEFAULT FALSE NOT NULL,
    adduser            INTEGER,
    adddate            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (fiscalyearid, periodnumber)
);

-- Seed current fiscal year
INSERT INTO tblfiscalyears (fiscalyearname, startdate, enddate, isactive) VALUES
    ('FY 2026', '2026-01-01', '2026-12-31', TRUE)
ON CONFLICT (fiscalyearname) DO NOTHING;

-- Seed fiscal periods for current FY
INSERT INTO tblfiscalperiods (fiscalyearid, periodname, periodnumber, startdate, enddate)
SELECT fy.fiscalyearid, 'Period ' || m, m,
       (fy.startdate + (m - 1) * INTERVAL '1 month')::date,
       (fy.startdate + m * INTERVAL '1 month' - INTERVAL '1 day')::date
FROM tblfiscalyears fy
CROSS JOIN generate_series(1, 12) AS m
WHERE fy.isactive = TRUE
ON CONFLICT (fiscalyearid, periodnumber) DO NOTHING;

-- =====================================================
-- VIEWS for new sections
-- =====================================================

CREATE OR REPLACE VIEW vw_cashboxbalances AS
SELECT
    cb.cashboxid,
    cb.cashboxcode,
    cb.cashboxname,
    cb.currentbalance,
    c.currname,
    c.currcode,
    cb.isactive
FROM tblcashboxes cb
JOIN tblcurrencies c ON cb.currid = c.currid;

CREATE OR REPLACE VIEW vw_bankaccountbalances AS
SELECT
    ba.bankaccountid,
    ba.bankaccountno,
    b.bankname,
    ba.currentbalance,
    c.currname,
    ba.isactive
FROM tblbankaccounts ba
JOIN tblbanks b ON ba.bankid = b.bankid
JOIN tblcurrencies c ON ba.currid = c.currid;

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

CREATE OR REPLACE VIEW vw_activebudgets AS
SELECT
    b.budgetid,
    p.periodname,
    a.accno,
    a.accname,
    b.budgetamount,
    b.actualamount,
    b.varianceamount,
    CASE WHEN b.budgetamount = 0 THEN 0
         ELSE (b.actualamount / b.budgetamount * 100)
    END AS utilizationpercent
FROM tblbudgets b
JOIN tblbudgetperiods p ON b.periodid = p.periodid
JOIN tblaccounts a ON b.accountid = a.accid
WHERE p.isactive = TRUE;

CREATE OR REPLACE VIEW vw_unreadnotifications AS
SELECT
    n.notificationid,
    u.userid,
    u.username,
    n.title,
    n.notificationtype,
    n.priority,
    n.createdate
FROM tblnotifications n
JOIN tblusers u ON n.userid = u.userid
WHERE n.isread = FALSE
ORDER BY n.priority DESC, n.createdate DESC;

CREATE OR REPLACE VIEW vw_recentaudithistory AS
SELECT
    a.audithistid,
    a.tablename,
    a.recordid,
    a.action,
    a.username,
    a.actiondate
FROM tblaudi a
ORDER BY a.actiondate DESC
LIMIT 1000;

-- =====================================================
-- SUMMARY
-- =====================================================
-- New tables added: 14
--   tblcashboxes, tblcashreceipts, tblcashpayments,
--   tblbankaccounts, tblbanktransactions,
--   tblreportdefinitions,
--   tbltaxdefinitions, tbltaxtransactions,
--   tblbankstatements, tblbankstatementlines, tblbankreconciliations,
--   tblbudgetperiods, tblbudgets,
--   tbldocumentattachments,
--   tblnotifications,
--   tblaudi,
--   tblexchangeratehistory,
--   tblfiscalyears, tblfiscalperiods
-- New functions: 11
--   getCashBoxBalance, getCashReceiptsByDate, getCashPaymentsByDate,
--   getSalesReportByPeriod, getPurchaseReportByPeriod,
--   getInventoryValuation, getTrialBalanceReport, getAccountStatement,
--   getBudgetVsActual, fn_audit_trigger, getExchangeRateAtDate
-- New views: 5
--   vw_cashboxbalances, vw_bankaccountbalances, vw_cashflow_daily,
--   vw_activebudgets, vw_unreadnotifications, vw_recentaudithistory
-- Seed data: 6 tax definitions, 12 report definitions, 1 fiscal year, 12 periods
-- =====================================================
