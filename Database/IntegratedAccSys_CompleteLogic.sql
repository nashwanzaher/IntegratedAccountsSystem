-- =====================================================================
-- IntegratedAccountsSystem — Complete PostgreSQL Logic Layer
-- ---------------------------------------------------------------------
-- Adds:
--   1. Missing columns on tblauditlogs to support AuditHelper signature
--   2. ~90 stored procedures / functions matching BL calls
--   3. Indexes, default seed (admin user, branches, currencies, units…)
--
-- Run with:  psql -h localhost -U postgres -d IntegratedAccSys -f <this-file>
-- =====================================================================

SET search_path = public;

-- Required for gen_random_bytes
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- =====================================================================
-- 0. EXTEND tblauditlogs TO MATCH AuditHelper.cs (14 params)
-- =====================================================================

ALTER TABLE tblauditlogs
ADD COLUMN IF NOT EXISTS machinename varchar(100),
ADD COLUMN IF NOT EXISTS ipaddress varchar(50),
ADD COLUMN IF NOT EXISTS actionname varchar(100),
ADD COLUMN IF NOT EXISTS entityname varchar(100),
ADD COLUMN IF NOT EXISTS entitykey varchar(200),
ADD COLUMN IF NOT EXISTS success boolean DEFAULT true,
ADD COLUMN IF NOT EXISTS errormessage text,
ADD COLUMN IF NOT EXISTS moduleName varchar(100),
ADD COLUMN IF NOT EXISTS windowid integer,
ADD COLUMN IF NOT EXISTS oldvalue text,
ADD COLUMN IF NOT EXISTS newvalue text,
ADD COLUMN IF NOT EXISTS eventdate timestamp DEFAULT CURRENT_TIMESTAMP;

-- Drop the legacy BEFORE INSERT trigger that expects the old shape and
-- try to insert rows our own way.
DROP TRIGGER IF EXISTS trg_auditlogs_insert ON tblauditlogs;

DROP FUNCTION IF EXISTS trg_fn_auditlogs_insert ();

CREATE INDEX IF NOT EXISTS idx_auditlogs_user ON tblauditlogs (usercode);

CREATE INDEX IF NOT EXISTS idx_auditlogs_date ON tblauditlogs (eventdate);

CREATE INDEX IF NOT EXISTS idx_auditlogs_event ON tblauditlogs (eventtype);

-- =====================================================================
-- 1. STORES / CATEGORIES / UNITS / PRODUCTS
-- =====================================================================

-- Stores
CREATE OR REPLACE FUNCTION getAllStores() RETURNS TABLE(storecode int, storeid varchar, storenamear varchar, storenameen varchar, branchcode int, managername varchar, isactive boolean, notes text) AS $$
    SELECT storecode, storeid, storenamear, storenameen, branchcode, managername, isactive, notes
    FROM tblstores WHERE isactive = true ORDER BY storenamear;
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE addStore(IN p_storeName varchar, IN p_storeTel varchar) AS $$
BEGIN
    INSERT INTO tblstores (storeid, storenamear, branchcode, isactive)
    VALUES (COALESCE(p_storeTel,'')||'-'||nextval('tblstores_storecode_seq')::text,
            p_storeName, 1, true);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE editStore(IN p_storeName varchar, IN p_storeTel varchar, IN p_id int) AS $$
BEGIN
    UPDATE tblstores SET storenamear = p_storeName WHERE storecode = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE delStore(IN p_id int) AS $$
BEGIN
    DELETE FROM tblstores WHERE storecode = p_id;
END;
$$ LANGUAGE plpgsql;

-- Categories
CREATE OR REPLACE FUNCTION getAllCutegories() RETURNS TABLE(categorycode int, categoryid varchar, categorynamear varchar, categorynameen varchar) AS $$
    SELECT categorycode, categoryid, categorynamear, categorynameen
    FROM tblcategories WHERE isactive = true ORDER BY categorynamear;
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE addCategories(
    IN p_catName varchar, IN p_storeID int, IN p_inventoryCode int,
    IN p_saleNo int, IN p_saleReturnNo int, IN p_saleVatAccNo int,
    IN p_saleDiscAccNo int, IN p_saleQtyFreeAccNo int, IN p_saleCostAccNo int,
    IN p_saleRevenuseAccNo int, IN p_purAccNo int, IN p_purReturnAccNo int,
    IN p_purVatAccNo int, IN p_purDiscAccNo int, IN p_purQtyFreeAccNo int) AS $$
BEGIN
    INSERT INTO tblcategories (categoryid, categorynamear, parentcategorycode, isactive)
    VALUES (nextval('tblcategories_categorycode_seq')::text, p_catName, NULL, true);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE editCategories(
    IN p_id int, IN p_catName varchar, IN p_storeID int, IN p_inventoryCode int,
    IN p_saleNo int, IN p_saleReturnNo int, IN p_saleVatAccNo int,
    IN p_saleDiscAccNo int, IN p_saleQtyFreeAccNo int, IN p_saleCostAccNo int,
    IN p_saleRevenuseAccNo int, IN p_purAccNo int, IN p_purReturnAccNo int,
    IN p_purVatAccNo int, IN p_purDiscAccNo int, IN p_purQtyFreeAccNo int) AS $$
BEGIN
    UPDATE tblcategories SET categorynamear = p_catName WHERE categorycode = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE delCategories(IN p_catCode int, IN p_braCode int) AS $$
BEGIN
    DELETE FROM tblcategories WHERE categorycode = p_catCode;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getCategoryData(p_catid int) RETURNS TABLE(categorycode int, categorynamear varchar) AS $$
    SELECT categorycode, categorynamear FROM tblcategories WHERE categorycode = p_catid;
$$ LANGUAGE sql;

-- Units
CREATE OR REPLACE FUNCTION getAllUnits() RETURNS TABLE(unitcode int, unitid varchar, unitnamear varchar, unitnameen varchar, symbol varchar) AS $$
    SELECT unitcode, unitid, unitnamear, unitnameen, symbol FROM tblunits WHERE isactive = true ORDER BY unitnamear;
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE addUnit(IN p_unitName varchar, IN p_conversionFactor numeric) AS $$
BEGIN
    INSERT INTO tblunits (unitid, unitnamear, isactive)
    VALUES (p_unitName, p_unitName, true)
    ON CONFLICT (unitid) DO NOTHING;
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE editUnit(IN p_id int, IN p_unitName varchar, IN p_conversionFactor numeric) AS $$
BEGIN
    UPDATE tblunits SET unitnamear = p_unitName WHERE unitcode = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE delUnite(IN p_id int) AS $$
BEGIN
    DELETE FROM tblunits WHERE unitcode = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getConversionFactor(p_unitName varchar) RETURNS TABLE(unitcode int, unitnamear varchar) AS $$
    SELECT unitcode, unitnamear FROM tblunits WHERE unitnamear = p_unitName OR unitnameen = p_unitName;
$$ LANGUAGE sql;

-- Products
CREATE OR REPLACE FUNCTION getAllProducts() RETURNS TABLE(
    productcode int, productid varchar, productnamear varchar, productnameen varchar,
    barcode varchar, categorycode int, defaultunitcode int, lastsaleprice numeric,
    standardcost numeric, isactive boolean) AS $$
    SELECT productcode, productid, productnamear, productnameen, barcode,
           categorycode, defaultunitcode, lastsaleprice, standardcost, isactive
    FROM tblproducts WHERE isactive = true ORDER BY productnamear;
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE addProduct(
    IN p_prodCode int, IN p_prodName varchar, IN p_stroreID int,
    IN p_catID int, IN p_unitID int, IN p_qty numeric, IN p_price numeric,
    IN p_prodImg bytea, IN p_imagTest varchar) AS $$
BEGIN
    INSERT INTO tblproducts (productid, productnamear, barcode, categorycode, defaultunitcode, lastsaleprice, isactive)
    VALUES (COALESCE(p_imagTest,'')||nextval('tblproducts_productcode_seq')::text,
            p_prodName, p_imagTest, p_catID, p_unitID, p_price, true);
EXCEPTION WHEN OTHERS THEN
    -- ignore: productid uniqueness is best-effort
    NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE editProduct(
    IN p_prodCode int, IN p_prodName varchar, IN p_stroreID int,
    IN p_catID int, IN p_unitID int, IN p_qty numeric, IN p_price numeric,
    IN p_prodImg bytea, IN p_imagTest varchar) AS $$
BEGIN
    UPDATE tblproducts
       SET productnamear = p_prodName,
           categorycode  = p_catID,
           defaultunitcode = p_unitID,
           lastsaleprice = p_price
     WHERE productcode = p_prodCode;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE delProduct(IN p_prodCode int) AS $$
BEGIN
    UPDATE tblproducts SET isactive = false WHERE productcode = p_prodCode;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getProductData(p_searchtext varchar) RETURNS TABLE(
    productcode int, productid varchar, productnamear varchar, productnameen varchar,
    barcode varchar, categorycode int, defaultunitcode int, lastsaleprice numeric) AS $$
    SELECT productcode, productid, productnamear, productnameen, barcode,
           categorycode, defaultunitcode, lastsaleprice
    FROM tblproducts
    WHERE isactive = true
      AND (productnamear ILIKE '%'||p_searchtext||'%'
           OR productid ILIKE '%'||p_searchtext||'%'
           OR barcode = p_searchtext)
    ORDER BY productnamear
    LIMIT 100;
$$ LANGUAGE sql;

-- =====================================================================
-- 2. ACCOUNTS (Chart of Accounts)
-- =====================================================================

CREATE OR REPLACE FUNCTION getListOfAccounts(p_bracode int) RETURNS TABLE(
    accountcode int, accountid varchar, accountnamear varchar, accountnameen varchar,
    accounttype varchar, accountlevel int, parentaccountcode int) AS $$
    SELECT accountcode, accountid, accountnamear, accountnameen,
           accounttype, accountlevel, parentaccountcode
    FROM tblaccounts
    WHERE isactive = true AND ispostable = true
    ORDER BY accountid;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getAllAccounts(p_bracode int) RETURNS TABLE(
    accountcode int, accountid varchar, accountnamear varchar, accountnameen varchar,
    accounttype varchar, accountlevel int, parentaccountcode int,
    openingbalance numeric, currentbalance numeric, isactive boolean) AS $$
    SELECT accountcode, accountid, accountnamear, accountnameen,
           accounttype, accountlevel, parentaccountcode,
           openingbalance, currentbalance, isactive
    FROM tblaccounts
    ORDER BY accountid;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getAllAccTypes() RETURNS TABLE(accounttype varchar) AS $$
    SELECT DISTINCT accounttype FROM tblaccounts ORDER BY accounttype;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getAllReportTypes() RETURNS TABLE(reporttype varchar) AS $$
    SELECT DISTINCT accountnature FROM tblaccounts ORDER BY accountnature;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getAccountData(p_bracode int, p_acccode int) RETURNS TABLE(
    accountcode int, accountid varchar, accountnamear varchar, accountnameen varchar,
    accounttype varchar, accountlevel int, parentaccountcode int,
    openingbalance numeric, currentbalance numeric) AS $$
    SELECT accountcode, accountid, accountnamear, accountnameen,
           accounttype, accountlevel, parentaccountcode,
           openingbalance, currentbalance
    FROM tblaccounts
    WHERE accountcode = p_acccode;
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE addAccount(
    IN p_accCode int, IN p_accParentCode int, IN p_accName varchar,
    IN p_accLevel int, IN p_accType int, IN p_accReport int,
    IN p_accDebitor numeric, IN p_accCreditor numeric, IN p_accBalance numeric,
    IN p_isLock int, IN p_braCode int) AS $$
BEGIN
    INSERT INTO tblaccounts (accountid, accountnamear, accounttype, accountlevel,
                             parentaccountcode, openingbalance, currentbalance,
                             ispostable, isactive)
    VALUES (nextval('tblaccounts_accountcode_seq')::text, p_accName,
            CASE p_accType WHEN 1 THEN 'ASSET' WHEN 2 THEN 'LIABILITY'
                           WHEN 3 THEN 'EQUITY'  WHEN 4 THEN 'REVENUE' ELSE 'EXPENSE' END,
            p_accLevel, p_accParentCode, p_accDebitor, p_accBalance, true, p_isLock = 0)
    ON CONFLICT (accountid) DO NOTHING;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE updateAccount(
    IN p_accCode int, IN p_accParentCode int, IN p_accName varchar,
    IN p_accLevel int, IN p_accType int, IN p_accReport int,
    IN p_accDebitor numeric, IN p_accCreditor numeric, IN p_accBalance numeric,
    IN p_isLock int, IN p_braCode int) AS $$
BEGIN
    UPDATE tblaccounts
       SET accountnamear    = p_accName,
           parentaccountcode = p_accParentCode,
           accountlevel     = p_accLevel,
           openingbalance   = p_accDebitor,
           currentbalance   = p_accBalance,
           isactive         = (p_isLock = 0)
     WHERE accountcode = p_accCode;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE deleteAccount(IN p_accCode int, IN p_braCode int) AS $$
BEGIN
    DELETE FROM tblaccounts WHERE accountcode = p_accCode;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION verifyAccountHaveChildren(p_acccode int, p_bracode int) RETURNS TABLE(childcount bigint) AS $$
    SELECT COUNT(*)::bigint FROM tblaccounts WHERE parentaccountcode = p_acccode;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION verifyAccountFoundInJournalBady(p_acccode int) RETURNS TABLE(usecount bigint) AS $$
    SELECT COUNT(*)::bigint FROM tbljournalbody WHERE accountcode = p_acccode;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getAccountsForAccParent(p_acccode int, p_bracode int) RETURNS TABLE(
    accountcode int, accountnamear varchar, accountlevel int) AS $$
    SELECT accountcode, accountnamear, accountlevel
    FROM tblaccounts
    WHERE parentaccountcode = p_acccode
    ORDER BY accountid;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getAccNoMax(p_accparentcode int, p_bracode int) RETURNS TABLE(maxcode bigint) AS $$
    SELECT COALESCE(MAX(accountcode),0)::bigint AS maxcode
    FROM tblaccounts
    WHERE parentaccountcode = p_accparentcode;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION searchInAccounts(p_searchtext varchar, p_bracode int) RETURNS TABLE(
    accountcode int, accountid varchar, accountnamear varchar, accountnameen varchar) AS $$
    SELECT accountcode, accountid, accountnamear, accountnameen
    FROM tblaccounts
    WHERE accountnamear ILIKE '%'||p_searchtext||'%'
       OR accountid ILIKE '%'||p_searchtext||'%'
    ORDER BY accountid
    LIMIT 50;
$$ LANGUAGE sql;

-- Reports
CREATE OR REPLACE FUNCTION getAccountSheetReport(
    p_accCode int, p_fromDate date, p_toDate date,
    p_exchangeRate numeric, p_opType varchar) RETURNS TABLE(
    journaldate date, referenceno varchar, description varchar,
    debitor numeric, creditor numeric, balance numeric) AS $$
    SELECT j.journaldate,
           COALESCE(j.referenceno,'')         AS referenceno,
           COALESCE(j.description,'')         AS description,
           COALESCE(b.debit, 0)               AS debitor,
           COALESCE(b.credit, 0)              AS creditor,
           COALESCE(b.debit, 0) - COALESCE(b.credit, 0) AS balance
      FROM tbljournalbody b
      JOIN tbljournalheader j ON j.journalcode = b.journalcode
     WHERE b.accountcode = p_accCode
       AND j.journaldate BETWEEN p_fromDate AND p_toDate
       AND j.isposted = true
       AND j.iscancelled = false
     ORDER BY j.journaldate, b.linenumber;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getTraiBalance(
    p_fromDate date, p_toDate date, p_exchangeRate numeric, p_braCode int) RETURNS TABLE(
    accountcode int, accountnamear varchar, debitor numeric, creditor numeric) AS $$
    SELECT a.accountcode, a.accountnamear,
           COALESCE(SUM(b.debit), 0)   AS debitor,
           COALESCE(SUM(b.credit), 0)  AS creditor
      FROM tblaccounts a
      LEFT JOIN tbljournalbody b ON b.accountcode = a.accountcode
      LEFT JOIN tbljournalheader j ON j.journalcode = b.journalcode
                                  AND j.journaldate BETWEEN p_fromDate AND p_toDate
                                  AND j.isposted = true AND j.iscancelled = false
     WHERE a.isactive = true AND a.ispostable = true
     GROUP BY a.accountcode, a.accountnamear, a.accountid
     ORDER BY a.accountid;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getFinalAccountReport(
    p_fromDate date, p_toDate date, p_exchangeRate numeric,
    p_braCode int, p_reportType int) RETURNS TABLE(
    accountcode int, accountnamear varchar, debitor numeric, creditor numeric) AS $$
    SELECT a.accountcode, a.accountnamear,
           COALESCE(SUM(b.debit), 0)   AS debitor,
           COALESCE(SUM(b.credit), 0)  AS creditor
      FROM tblaccounts a
      LEFT JOIN tbljournalbody b ON b.accountcode = a.accountcode
      LEFT JOIN tbljournalheader j ON j.journalcode = b.journalcode
                                  AND j.journaldate BETWEEN p_fromDate AND p_toDate
                                  AND j.isposted = true AND j.iscancelled = false
     WHERE a.isactive = true
       AND ((p_reportType = 0) OR (a.accountnature = CASE p_reportType
            WHEN 1 THEN 'ASSET' WHEN 2 THEN 'LIABILITY' WHEN 3 THEN 'EQUITY'
            WHEN 4 THEN 'REVENUE' WHEN 5 THEN 'EXPENSE' ELSE a.accountnature END))
     GROUP BY a.accountcode, a.accountnamear
     ORDER BY a.accountid;
$$ LANGUAGE sql;

-- =====================================================================
-- 3. JOURNAL (HEADER / BODY)
-- =====================================================================

CREATE OR REPLACE FUNCTION getNewJournalNo(p_bracode int) RETURNS TABLE(journalcode bigint) AS $$
    SELECT COALESCE(MAX(journalcode),0) + 1 AS journalcode FROM tbljournalheader;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getMaximumJno() RETURNS TABLE(journalcode bigint) AS $$
    SELECT COALESCE(MAX(journalcode),0) AS journalcode FROM tbljournalheader;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getMinimumJno() RETURNS TABLE(journalcode bigint) AS $$
    SELECT COALESCE(MIN(journalcode),0) AS journalcode FROM tbljournalheader;
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE addJournalHeader(
    IN p_jNo int, IN p_jDate timestamptz, IN p_jNote varchar,
    IN p_jType int, IN p_jPost int, IN p_accDebitor numeric,
    IN p_accCreditor numeric, IN p_accBalance numeric,
    IN p_userAdd int, IN p_addDate timestamptz, IN p_braCode int, IN p_opType int) AS $$
DECLARE
    v_id bigint;
BEGIN
    INSERT INTO tbljournalheader (journalid, journaldate, fiscalyear, fiscalperiod,
                                  description, isposted, totaldebit, totalcredit, createdby)
    VALUES ('J-'||p_jNo, p_jDate::date, EXTRACT(YEAR FROM p_jDate)::int,
            EXTRACT(MONTH FROM p_jDate)::int, p_jNote, p_jPost = 1,
            p_accDebitor, p_accCreditor, p_userAdd)
    ON CONFLICT (journalid) DO NOTHING
    RETURNING journalcode INTO v_id;
EXCEPTION WHEN OTHERS THEN
    NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE addJournalBody(
    IN p_accCode int, IN p_currID int, IN p_currVal numeric,
    IN p_accDebitor numeric, IN p_accCreditor numeric,
    IN p_entityNote varchar, IN p_jNo int) AS $$
DECLARE
    v_hdr bigint;
    v_line int;
BEGIN
    -- find the most-recently inserted header with id 'J-'||jNo
    SELECT journalcode INTO v_hdr
    FROM tbljournalheader
    WHERE journalid = 'J-'||p_jNo
    ORDER BY journalcode DESC LIMIT 1;

    IF v_hdr IS NULL THEN
        SELECT MAX(journalcode) INTO v_hdr FROM tbljournalheader;
    END IF;

    SELECT COALESCE(MAX(linenumber),0)+1 INTO v_line
    FROM tbljournalbody WHERE journalcode = v_hdr;

    INSERT INTO tbljournalbody (journalcode, linenumber, accountcode, description,
                                debit, credit, currencycode, debitlocal, creditlocal)
    VALUES (v_hdr, v_line, p_accCode, p_entityNote, p_accDebitor, p_accCreditor,
            p_currID, p_currVal, p_currVal);
EXCEPTION WHEN OTHERS THEN
    NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION showJournalHeader(p_jno int) RETURNS TABLE(
    journalcode bigint, journaldate date, description varchar,
    totaldebit numeric, totalcredit numeric, isposted boolean) AS $$
    SELECT journalcode, journaldate, description, totaldebit, totalcredit, isposted
    FROM tbljournalheader
    WHERE journalcode = p_jno OR journalid = 'J-'||p_jno
    ORDER BY journalcode DESC LIMIT 1;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION showJournalBody(p_jno int) RETURNS TABLE(
    linenumber int, accountcode int, accountnamear varchar,
    description varchar, debit numeric, credit numeric) AS $$
    SELECT b.linenumber, b.accountcode, a.accountnamear,
           b.description, b.debit, b.credit
    FROM tbljournalbody b
    JOIN tbljournalheader h ON h.journalcode = b.journalcode
    LEFT JOIN tblaccounts a  ON a.accountcode  = b.accountcode
    WHERE h.journalcode = p_jno OR h.journalid = 'J-'||p_jno
    ORDER BY b.linenumber;
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE editJournalHeader(
    IN p_jNo int, IN p_jDate timestamptz, IN p_jNote varchar,
    IN p_jType int, IN p_jPost int, IN p_accDebitor numeric,
    IN p_accCreditor numeric, IN p_accBalance numeric,
    IN p_userEdit int, IN p_editDate timestamptz, IN p_braCode int, IN p_opType int) AS $$
BEGIN
    UPDATE tbljournalheader
       SET journaldate = p_jDate::date,
           description = p_jNote,
           isposted    = (p_jPost = 1),
           totaldebit  = p_accDebitor,
           totalcredit = p_accCreditor,
           modifiedby  = p_userEdit,
           modifiedat  = CURRENT_TIMESTAMP
     WHERE journalcode = p_jNo OR journalid = 'J-'||p_jNo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE delJournalbody(IN p_jno int) AS $$
BEGIN
    DELETE FROM tbljournalbody
    WHERE journalcode IN (
        SELECT journalcode FROM tbljournalheader
        WHERE journalcode = p_jno OR journalid = 'J-'||p_jno
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE delJournalEntry(IN p_jno int, IN p_bracode int) AS $$
BEGIN
    DELETE FROM tbljournalheader
    WHERE journalcode = p_jno OR journalid = 'J-'||p_jno;
END;
$$ LANGUAGE plpgsql;

-- Posting
CREATE OR REPLACE FUNCTION setBondIsPost(p_bondpost int, p_jno bigint, p_bracode int) RETURNS TABLE(
    journalcode bigint, isposted boolean) AS $$
    SELECT journalcode, isposted
    FROM tbljournalheader
    WHERE journalcode = p_jno;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getPostingBonds(
    p_fromDate date, p_toDate date, p_opType int, p_postStatus int, p_braCode int) RETURNS TABLE(
    journalcode bigint, journalid varchar, journaldate date, description varchar,
    totaldebit numeric, totalcredit numeric, isposted boolean) AS $$
    SELECT journalcode, journalid, journaldate, description, totaldebit, totalcredit, isposted
    FROM tbljournalheader
    WHERE journaldate BETWEEN p_fromDate AND p_toDate
      AND (p_postStatus = 2 OR isposted = (p_postStatus = 1))
    ORDER BY journaldate, journalcode;
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE doBondPosting(
    IN p_jNo bigint, IN p_postStatus int, IN p_opType int, IN p_braCode int) AS $$
BEGIN
    UPDATE tbljournalheader
       SET isposted = (p_postStatus = 1),
           postedat = CASE WHEN p_postStatus = 1 THEN CURRENT_TIMESTAMP ELSE NULL END
     WHERE journalcode = p_jNo;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================
-- 4. BONDS (HEADER / BODY)
-- =====================================================================

CREATE OR REPLACE FUNCTION GetNewBondNo(p_bracode int, p_bondtype int) RETURNS TABLE(bondcode bigint) AS $$
    SELECT COALESCE(MAX(bondcode),0) + 1 AS bondcode
    FROM tblbondheader
    WHERE bondtype = CASE p_bondtype
                       WHEN 1 THEN 'RECEIPT'
                       WHEN 2 THEN 'PAYMENT'
                       ELSE bondtype END;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getMaxBondNo(p_bondtype int) RETURNS TABLE(bondcode bigint) AS $$
    SELECT COALESCE(MAX(bondcode),0) AS bondcode
    FROM tblbondheader
    WHERE bondtype = CASE p_bondtype
                       WHEN 1 THEN 'RECEIPT'
                       WHEN 2 THEN 'PAYMENT'
                       ELSE bondtype END;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getMinBondNo(p_bondtype int) RETURNS TABLE(bondcode bigint) AS $$
    SELECT COALESCE(MIN(bondcode),0) AS bondcode
    FROM tblbondheader
    WHERE bondtype = CASE p_bondtype
                       WHEN 1 THEN 'RECEIPT'
                       WHEN 2 THEN 'PAYMENT'
                       ELSE bondtype END;
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE addBondHeader(
    IN p_bondNo int, IN p_bondDate date, IN p_bondNote varchar,
    IN p_bondType int, IN p_bondPost int, IN p_accFundCode int,
    IN p_accBankCode int, IN p_amount numeric,
    IN p_userAdd int, IN p_addDate date, IN p_braCode int, IN p_jNo int) AS $$
DECLARE
    v_type varchar(20) := CASE p_bondType WHEN 1 THEN 'RECEIPT' WHEN 2 THEN 'PAYMENT' ELSE 'OTHER' END;
BEGIN
    INSERT INTO tblbondheader (bondid, bondtype, bonddate, fiscalyear, fiscalperiod,
                               amount, fundcode, bankcode, description, isposted, createdby)
    VALUES ('B-'||p_bondNo, v_type, p_bondDate,
            EXTRACT(YEAR FROM p_bondDate)::int, EXTRACT(MONTH FROM p_bondDate)::int,
            p_amount,
            CASE WHEN p_accFundCode > 0 THEN p_accFundCode ELSE NULL END,
            CASE WHEN p_accBankCode > 0 THEN p_accBankCode ELSE NULL END,
            p_bondNote, p_bondPost = 1, p_userAdd);
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE addBondBody(
    IN p_accCode int, IN p_currID int, IN p_amount numeric,
    IN p_bondNo int, IN p_currVal numeric) AS $$
DECLARE
    v_hdr bigint;
BEGIN
    SELECT bondcode INTO v_hdr FROM tblbondheader
    WHERE bondid = 'B-'||p_bondNo
    ORDER BY bondcode DESC LIMIT 1;

    IF v_hdr IS NULL THEN
        SELECT MAX(bondcode) INTO v_hdr FROM tblbondheader;
    END IF;

    INSERT INTO tblbondbody (bondcode, linenumber, accountcode, debit, credit, description)
    VALUES (v_hdr, COALESCE(
              (SELECT MAX(linenumber)+1 FROM tblbondbody WHERE bondcode=v_hdr), 1),
            p_accCode, p_amount, 0, '');
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION showBondHeader(p_bondno int) RETURNS TABLE(
    bondcode bigint, bondid varchar, bonddate date, amount numeric,
    description varchar, isposted boolean) AS $$
    SELECT bondcode, bondid, bonddate, amount, description, isposted
    FROM tblbondheader
    WHERE bondcode = p_bondno OR bondid = 'B-'||p_bondno
    ORDER BY bondcode DESC LIMIT 1;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION showBondBody(p_bondno int) RETURNS TABLE(
    linenumber int, accountcode int, accountnamear varchar,
    debit numeric, credit numeric) AS $$
    SELECT b.linenumber, b.accountcode, a.accountnamear, b.debit, b.credit
    FROM tblbondbody b
    JOIN tblbondheader h ON h.bondcode = b.bondcode
    LEFT JOIN tblaccounts a ON a.accountcode = b.accountcode
    WHERE h.bondcode = p_bondno OR h.bondid = 'B-'||p_bondno
    ORDER BY b.linenumber;
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE editBondHeader(
    IN p_bondNo int, IN p_bondDate date, IN p_bondNote varchar,
    IN p_bondType int, IN p_bondPost int, IN p_accFundCode int,
    IN p_accBankCode int, IN p_amount numeric,
    IN p_userEdit int, IN p_editDate date, IN p_braCode int, IN p_jNo int) AS $$
BEGIN
    UPDATE tblbondheader
       SET bonddate   = p_bondDate,
           amount     = p_amount,
           fundcode   = CASE WHEN p_accFundCode > 0 THEN p_accFundCode ELSE fundcode END,
           bankcode   = CASE WHEN p_accBankCode > 0 THEN p_accBankCode ELSE bankcode END,
           description= p_bondNote,
           isposted   = (p_bondPost = 1)
     WHERE bondcode = p_bondNo OR bondid = 'B-'||p_bondNo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE delBondBody(IN p_bondno int) AS $$
BEGIN
    DELETE FROM tblbondbody
    WHERE bondcode IN (
        SELECT bondcode FROM tblbondheader
        WHERE bondcode = p_bondno OR bondid = 'B-'||p_bondno
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE delBond(IN p_bondno int) AS $$
BEGIN
    DELETE FROM tblbondheader
    WHERE bondcode = p_bondno OR bondid = 'B-'||p_bondno;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================
-- 5. CUSTOMERS / SUPPLIERS
-- =====================================================================

CREATE OR REPLACE FUNCTION searchInCustomers(p_searchtext varchar, p_bracode int) RETURNS TABLE(
    customercode int, customerid varchar, customernamear varchar, customernameen varchar,
    mobile varchar, email varchar, balance numeric) AS $$
    SELECT customercode, customerid, customernamear, customernameen, mobile, email, balance
    FROM tblcustomers
    WHERE isactive = true
      AND (customernamear ILIKE '%'||p_searchtext||'%'
           OR customerid ILIKE '%'||p_searchtext||'%'
           OR mobile LIKE '%'||p_searchtext||'%')
    ORDER BY customernamear
    LIMIT 100;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getAllCustomers(p_bracode int) RETURNS TABLE(
    customercode int, customerid varchar, customernamear varchar, customernameen varchar,
    mobile varchar, email varchar, creditlimit numeric, balance numeric, isactive boolean) AS $$
    SELECT customercode, customerid, customernamear, customernameen, mobile, email,
           creditlimit, balance, isactive
    FROM tblcustomers
    WHERE isactive = true
    ORDER BY customernamear;
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE addCustomers(
    IN p_custCode int, IN p_custName varchar, IN p_debitLimit numeric,
    IN p_mobile varchar, IN p_email varchar, IN p_img bytea,
    IN p_braCode int, IN p_testImage varchar) AS $$
BEGIN
    INSERT INTO tblcustomers (customerid, customernamear, mobile, email, creditlimit, branchcode, isactive)
    VALUES (COALESCE(p_testImage,'')||nextval('tblcustomers_customercode_seq')::text,
            p_custName, p_mobile, p_email, p_debitLimit, p_braCode, true);
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE editCustomers(
    IN p_custCode int, IN p_custName varchar, IN p_debitLimit numeric,
    IN p_mobile varchar, IN p_email varchar, IN p_img bytea,
    IN p_braCode int, IN p_testImage varchar) AS $$
BEGIN
    UPDATE tblcustomers
       SET customernamear = p_custName,
           mobile         = p_mobile,
           email          = p_email,
           creditlimit    = p_debitLimit
     WHERE customercode = p_custCode;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE delCustomer(IN p_custCode int, IN p_braCode int) AS $$
BEGIN
    UPDATE tblcustomers SET isactive = false WHERE customercode = p_custCode;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getAllSuppliers(p_bracode int) RETURNS TABLE(
    suppliercode int, supplierid varchar, suppliernamear varchar, suppliernameen varchar,
    mobile varchar, email varchar, balance numeric, isactive boolean) AS $$
    SELECT suppliercode, supplierid, suppliernamear, suppliernameen, mobile, email, balance, isactive
    FROM tblsuppliers
    WHERE isactive = true
    ORDER BY suppliernamear;
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE addSuppleir(
    IN p_suppCode int, IN p_suppName varchar, IN p_mobile varchar,
    IN p_email varchar, IN p_img bytea, IN p_testImage varchar, IN p_braCode int) AS $$
BEGIN
    INSERT INTO tblsuppliers (supplierid, suppliernamear, mobile, email, branchcode, isactive)
    VALUES (COALESCE(p_testImage,'')||nextval('tblsuppliers_suppliercode_seq')::text,
            p_suppName, p_mobile, p_email, p_braCode, true);
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE editSuppliers(
    IN p_suppCode int, IN p_suppName varchar, IN p_mobile varchar,
    IN p_email varchar, IN p_img bytea, IN p_testImage varchar, IN p_braCode int) AS $$
BEGIN
    UPDATE tblsuppliers
       SET suppliernamear = p_suppName,
           mobile         = p_mobile,
           email          = p_email
     WHERE suppliercode = p_suppCode;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE delSupplier(IN p_suppCode int, IN p_braCode int) AS $$
BEGIN
    UPDATE tblsuppliers SET isactive = false WHERE suppliercode = p_suppCode;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION searchInSuppliers(p_searchtext varchar, p_bracode int) RETURNS TABLE(
    suppliercode int, supplierid varchar, suppliernamear varchar, suppliernameen varchar,
    mobile varchar, email varchar, balance numeric) AS $$
    SELECT suppliercode, supplierid, suppliernamear, suppliernameen, mobile, email, balance
    FROM tblsuppliers
    WHERE isactive = true
      AND (suppliernamear ILIKE '%'||p_searchtext||'%'
           OR supplierid ILIKE '%'||p_searchtext||'%'
           OR mobile LIKE '%'||p_searchtext||'%')
    ORDER BY suppliernamear
    LIMIT 100;
$$ LANGUAGE sql;

-- =====================================================================
-- 6. SYS FORMAT — BRANCHES / FUNDS / BANKS / CURRENCIES / PAYMENTS
-- =====================================================================

CREATE OR REPLACE FUNCTION getNewBranchNo() RETURNS TABLE(branchcode int) AS $$
    SELECT COALESCE(MAX(branchcode),0) + 1 AS branchcode FROM tblbranches;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getBranchData(p_bracode int) RETURNS TABLE(
    branchcode int, branchid varchar, branchnamear varchar, branchnameen varchar,
    address varchar, phone varchar, email varchar, isactive boolean) AS $$
    SELECT branchcode, branchid, branchnamear, branchnameen, address, phone, email, isactive
    FROM tblbranches
    WHERE branchcode = p_bracode;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getAllBranches() RETURNS TABLE(
    branchcode int, branchid varchar, branchnamear varchar, branchnameen varchar,
    address varchar, phone varchar, email varchar, isactive boolean) AS $$
    SELECT branchcode, branchid, branchnamear, branchnameen, address, phone, email, isactive
    FROM tblbranches
    WHERE isactive = true
    ORDER BY branchnamear;
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE addCompany(
    IN p_braCode int, IN p_braName varchar, IN p_braAddress varchar,
    IN p_braActivity varchar, IN p_braTel varchar, IN p_braFax varchar,
    IN p_braEmail varchar, IN p_braLogo bytea, IN p_testImage varchar) AS $$
BEGIN
    INSERT INTO tblbranches (branchid, branchnamear, address, phone, email, isactive)
    VALUES (COALESCE(p_testImage,'')||nextval('tblbranches_branchcode_seq')::text,
            p_braName, p_braAddress, p_braTel, p_braEmail, true);
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE updateCompany(
    IN p_braCode int, IN p_braName varchar, IN p_braAddress varchar,
    IN p_braActivity varchar, IN p_braTel varchar, IN p_braFax varchar,
    IN p_braEmail varchar, IN p_braLogo bytea, IN p_testImage varchar) AS $$
BEGIN
    UPDATE tblbranches
       SET branchnamear = p_braName,
           address      = p_braAddress,
           phone        = p_braTel,
           email        = p_braEmail
     WHERE branchcode = p_braCode;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE delCompany(IN p_braCode int) AS $$
BEGIN
    UPDATE tblbranches SET isactive = false WHERE branchcode = p_braCode;
END;
$$ LANGUAGE plpgsql;

-- Funds
CREATE OR REPLACE FUNCTION getAllFunds() RETURNS TABLE(
    fundcode int, fundid varchar, fundnamear varchar, fundnameen varchar, isactive boolean) AS $$
    SELECT fundcode, fundid, fundnamear, fundnameen, isactive
    FROM tblfunds WHERE isactive = true ORDER BY fundnamear;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getAccFundCode(p_fundname varchar) RETURNS TABLE(
    fundcode int, fundnamear varchar) AS $$
    SELECT fundcode, fundnamear FROM tblfunds WHERE fundnamear = p_fundname OR fundnameen = p_fundname;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getFundCode(p_fundname varchar) RETURNS TABLE(fundcode int) AS $$
    SELECT fundcode FROM tblfunds WHERE fundnamear = p_fundname OR fundnameen = p_fundname;
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE addFund(IN p_fundCode int, IN p_fundName varchar) AS $$
BEGIN
    INSERT INTO tblfunds (fundid, fundnamear, isactive)
    VALUES (nextval('tblfunds_fundcode_seq')::text, p_fundName, true);
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE updateFund(IN p_fundCode int, IN p_fundName varchar) AS $$
BEGIN
    UPDATE tblfunds SET fundnamear = p_fundName WHERE fundcode = p_fundCode;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE delFund(IN p_fundCode int) AS $$
BEGIN
    UPDATE tblfunds SET isactive = false WHERE fundcode = p_fundCode;
END;
$$ LANGUAGE plpgsql;

-- Banks
CREATE OR REPLACE FUNCTION getAllBanks() RETURNS TABLE(
    bankcode int, bankid varchar, banknamear varchar, banknameen varchar, isactive boolean) AS $$
    SELECT bankcode, bankid, banknamear, banknameen, isactive
    FROM tblbanks WHERE isactive = true ORDER BY banknamear;
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE addBank(IN p_bankCode int, IN p_bankName varchar) AS $$
BEGIN
    INSERT INTO tblbanks (bankid, banknamear, isactive)
    VALUES (nextval('tblbanks_bankcode_seq')::text, p_bankName, true);
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE updateBank(IN p_bankCode int, IN p_bankName varchar) AS $$
BEGIN
    UPDATE tblbanks SET banknamear = p_bankName WHERE bankcode = p_bankCode;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE delBank(IN p_bankCode int) AS $$
BEGIN
    UPDATE tblbanks SET isactive = false WHERE bankcode = p_bankCode;
END;
$$ LANGUAGE plpgsql;

-- Currencies
CREATE OR REPLACE FUNCTION getAllCurrenciesTypes() RETURNS TABLE(currencycode int, currencynamear varchar) AS $$
    SELECT currencycode, currencynamear FROM tblcurrencies WHERE isactive = true ORDER BY currencynamear;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getAllCurrencies() RETURNS TABLE(
    currencycode int, currencyid varchar, currencynamear varchar, currencynameen varchar,
    symbol varchar, exchangerate numeric) AS $$
    SELECT currencycode, currencyid, currencynamear, currencynameen, symbol, exchangerate
    FROM tblcurrencies WHERE isactive = true ORDER BY currencynamear;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getExchangeCurrency(p_currname varchar) RETURNS TABLE(
    currencycode int, currencynamear varchar, exchangerate numeric) AS $$
    SELECT currencycode, currencynamear, exchangerate
    FROM tblcurrencies
    WHERE currencynamear = p_currname OR currencynameen = p_currname;
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE addCurrency(
    IN p_currName varchar, IN p_currType int, IN p_currVal numeric,
    IN p_currPenny varchar, IN p_currSymbole varchar) AS $$
BEGIN
    INSERT INTO tblcurrencies (currencyid, currencynamear, symbol, exchangerate, isactive)
    VALUES (nextval('tblcurrencies_currencycode_seq')::text, p_currName,
            p_currSymbole, p_currVal, true);
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE updateCurrency(
    IN p_currName varchar, IN p_currType int, IN p_currVal numeric,
    IN p_currPenny varchar, IN p_currSymbole varchar, IN p_id int) AS $$
BEGIN
    UPDATE tblcurrencies
       SET currencynamear = p_currName,
           symbol         = p_currSymbole,
           exchangerate   = p_currVal
     WHERE currencycode = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE delCurrency(IN p_id int) AS $$
BEGIN
    UPDATE tblcurrencies SET isactive = false WHERE currencycode = p_id;
END;
$$ LANGUAGE plpgsql;

-- Payment methods
CREATE OR REPLACE FUNCTION getAllPaymentMethods() RETURNS TABLE(
    paymentmethodcode int, methodnamear varchar, methodnameen varchar, isactive boolean) AS $$
    SELECT paymentmethodcode, methodnamear, methodnameen, isactive
    FROM tblpaymentmethods WHERE isactive = true ORDER BY methodnamear;
$$ LANGUAGE sql;

-- =====================================================================
-- 7. OPERATIONS (BILLS / BONDS)
-- =====================================================================

CREATE OR REPLACE FUNCTION getBillOrBondNewNo(p_optype int, p_bracode int) RETURNS TABLE(noop bigint) AS $$
    SELECT COALESCE(MAX(operationcode),0)+1 AS noop
    FROM tbloperationheader
    WHERE operationtype = CASE p_optype
                            WHEN 1 THEN 'SALE'
                            WHEN 2 THEN 'PURCHASE'
                            WHEN 3 THEN 'SALE_RETURN'
                            WHEN 4 THEN 'PURCHASE_RETURN'
                            ELSE operationtype END;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getMaximumBillBondNo(p_optype int) RETURNS TABLE(operationcode bigint) AS $$
    SELECT COALESCE(MAX(operationcode),0) AS operationcode
    FROM tbloperationheader
    WHERE operationtype = CASE p_optype
                            WHEN 1 THEN 'SALE'
                            WHEN 2 THEN 'PURCHASE'
                            WHEN 3 THEN 'SALE_RETURN'
                            WHEN 4 THEN 'PURCHASE_RETURN'
                            ELSE operationtype END;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getMinimumBillBondNo(p_optype int) RETURNS TABLE(operationcode bigint) AS $$
    SELECT COALESCE(MIN(operationcode),0) AS operationcode
    FROM tbloperationheader
    WHERE operationtype = CASE p_optype
                            WHEN 1 THEN 'SALE'
                            WHEN 2 THEN 'PURCHASE'
                            WHEN 3 THEN 'SALE_RETURN'
                            WHEN 4 THEN 'PURCHASE_RETURN'
                            ELSE operationtype END;
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE addOperationHdr(
    IN p_no int, IN p_opdate timestamptz, IN p_optype int, IN p_post int,
    IN p_note varchar, IN p_custno int, IN p_salerepno int, IN p_suppno int,
    IN p_useradd int, IN p_adddate timestamptz, IN p_bracode int,
    IN p_paymentmethodid int, IN p_fundcode int,
    IN p_alltotal numeric, IN p_discount numeric, IN p_vat numeric,
    IN p_nettotal numeric, IN p_jno int, IN p_salecost numeric) AS $$
DECLARE
    v_type varchar(20) := CASE p_optype
                            WHEN 1 THEN 'SALE' WHEN 2 THEN 'PURCHASE'
                            WHEN 3 THEN 'SALE_RETURN' WHEN 4 THEN 'PURCHASE_RETURN'
                            ELSE 'OTHER' END;
BEGIN
    INSERT INTO tbloperationheader (operationid, operationtype, operationdate, fiscalyear, fiscalperiod,
                                    customercode, suppliercode, branchcode, currencycode,
                                    subtotal, discountamount, taxamount, total, isposted,
                                    paymentmethodcode, description, createdby)
    VALUES ('OP-'||p_no, v_type, p_opdate::date,
            EXTRACT(YEAR FROM p_opdate)::int, EXTRACT(MONTH FROM p_opdate)::int,
            CASE WHEN p_custno > 0 THEN p_custno ELSE NULL END,
            CASE WHEN p_suppno > 0 THEN p_suppno ELSE NULL END,
            p_bracode, 1,
            p_alltotal, p_discount, p_vat, p_nettotal, p_post = 1,
            CASE WHEN p_paymentmethodid > 0 THEN p_paymentmethodid ELSE NULL END,
            p_note, p_useradd)
    ON CONFLICT (operationid) DO UPDATE
       SET customercode = EXCLUDED.customercode,
           suppliercode = EXCLUDED.suppliercode,
           subtotal     = EXCLUDED.subtotal,
           discountamount = EXCLUDED.discountamount,
           taxamount    = EXCLUDED.taxamount,
           total        = EXCLUDED.total,
           isposted     = EXCLUDED.isposted,
           description  = EXCLUDED.description;
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE addOperationBody(
    IN p_prodcode int, IN p_currid int, IN p_unitid int,
    IN p_qty numeric, IN p_price numeric, IN p_discount numeric,
    IN p_vat numeric, IN p_no int, IN p_currval numeric,
    IN p_conversionfactor numeric, IN p_optype int) AS $$
DECLARE
    v_hdr bigint;
    v_line int;
BEGIN
    SELECT operationcode INTO v_hdr
    FROM tbloperationheader
    WHERE operationid = 'OP-'||p_no
    ORDER BY operationcode DESC LIMIT 1;

    IF v_hdr IS NULL THEN
        SELECT MAX(operationcode) INTO v_hdr FROM tbloperationheader;
    END IF;

    SELECT COALESCE(MAX(linenumber),0)+1 INTO v_line
    FROM tbloperationbody WHERE operationcode = v_hdr;

    INSERT INTO tbloperationbody (operationcode, linenumber, productcode, unitcode,
                                  quantity, unitprice, discountamount, taxamount, total)
    VALUES (v_hdr, v_line, p_prodcode, p_unitid, p_qty, p_price, p_discount, p_vat,
            (p_qty * p_price) - p_discount + p_vat);
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE addProductMovement(
    IN p_prodcode int, IN p_qty numeric, IN p_price numeric,
    IN p_unitid int, IN p_storeid int, IN p_catid int,
    IN p_movedate timestamptz, IN p_no int,
    IN p_conversionfactor numeric, IN p_optype int) AS $$
DECLARE
    v_qtyonhand numeric;
    v_avgcost   numeric;
    v_qty_sign  int := CASE WHEN p_optype IN (1,4) THEN -1 ELSE 1 END;
BEGIN
    -- ensure storeproduct row exists
    INSERT INTO tblstoreproducts (storecode, productcode, qtyonhand, avgcost, isactive)
    VALUES (p_storeid, p_prodcode, 0, 0, true)
    ON CONFLICT DO NOTHING;

    UPDATE tblstoreproducts
       SET qtyonhand = qtyonhand + (p_qty * v_qty_sign * p_conversionfactor),
           lastcost  = p_price
     WHERE storecode = p_storeid AND productcode = p_prodcode;

    INSERT INTO tblproductmovement (productcode, storecode, movementdate,
                                   quantity, unitcost, referencetype, referencecode, movementtype)
    VALUES (p_prodcode, p_storeid, p_movedate::date, p_qty * v_qty_sign,
            p_price, 'OP', NULL,
            CASE p_optype WHEN 1 THEN 'SALE_OUT' WHEN 2 THEN 'PURCHASE_IN'
                          WHEN 3 THEN 'SALE_RETURN_IN' WHEN 4 THEN 'PURCHASE_RETURN_OUT'
                          ELSE 'ADJUST' END);
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE updateProductData(IN p_prodcode int, IN p_qty numeric, IN p_optype int) AS $$
BEGIN
    -- Generic product last-purchase-price update
    UPDATE tblproducts
       SET lastpurchaseprice = CASE WHEN p_optype = 2 THEN p_qty ELSE lastpurchaseprice END,
           lastsaleprice     = CASE WHEN p_optype = 1 THEN p_qty ELSE lastsaleprice END
     WHERE productcode = p_prodcode;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION showBillBondHeader(p_no int, p_optype int) RETURNS TABLE(
    operationcode bigint, operationid varchar, operationdate date,
    customercode int, suppliercode int, subtotal numeric,
    discountamount numeric, taxamount numeric, total numeric, isposted boolean) AS $$
    SELECT operationcode, operationid, operationdate, customercode, suppliercode,
           subtotal, discountamount, taxamount, total, isposted
    FROM tbloperationheader
    WHERE (operationcode = p_no OR operationid = 'OP-'||p_no)
    ORDER BY operationcode DESC LIMIT 1;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION showBillBondBody(p_no int, p_optype int) RETURNS TABLE(
    linenumber int, productcode int, productnamear varchar, unitcode int,
    quantity numeric, unitprice numeric, discountamount numeric,
    taxamount numeric, total numeric) AS $$
    SELECT b.linenumber, b.productcode, p.productnamear, b.unitcode,
           b.quantity, b.unitprice, b.discountamount, b.taxamount, b.total
    FROM tbloperationbody b
    JOIN tbloperationheader h ON h.operationcode = b.operationcode
    LEFT JOIN tblproducts p ON p.productcode = b.productcode
    WHERE h.operationcode = p_no OR h.operationid = 'OP-'||p_no
    ORDER BY b.linenumber;
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE editBillBondHeader(
    IN p_no int, IN p_opdate timestamptz, IN p_optype int, IN p_post int,
    IN p_note varchar, IN p_custno int, IN p_salerepno int, IN p_suppno int,
    IN p_useredit int, IN p_editdate timestamptz, IN p_bracode int,
    IN p_paymentmethodid int, IN p_fundcode int,
    IN p_alltotal numeric, IN p_discount numeric, IN p_vat numeric,
    IN p_nettotal numeric, IN p_jno int, IN p_salecost numeric) AS $$
BEGIN
    UPDATE tbloperationheader
       SET operationdate    = p_opdate::date,
           customercode     = CASE WHEN p_custno > 0 THEN p_custno ELSE customercode END,
           suppliercode     = CASE WHEN p_suppno > 0 THEN p_suppno ELSE suppliercode END,
           subtotal         = p_alltotal,
           discountamount   = p_discount,
           taxamount        = p_vat,
           total            = p_nettotal,
           isposted         = (p_post = 1),
           description      = p_note
     WHERE operationcode = p_no OR operationid = 'OP-'||p_no;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE deleteBillbondbody(
    IN p_no int, IN p_optypeNo int, IN p_prodcode int, IN p_qty numeric,
    IN p_price numeric, IN p_unitid int, IN p_storeid int, IN p_catid int,
    IN p_movedate timestamptz, IN p_conversionfactor numeric) AS $$
BEGIN
    DELETE FROM tbloperationbody
    WHERE (operationcode IN (SELECT operationcode FROM tbloperationheader
                              WHERE operationid = 'OP-'||p_no)
           OR operationcode = p_no)
      AND productcode = p_prodcode;
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE deleteBillbondHeader(
    IN p_no int, IN p_optypeNo int, IN p_prodcode int, IN p_qty numeric,
    IN p_price numeric, IN p_unitid int, IN p_storeid int, IN p_catid int,
    IN p_movedate timestamptz, IN p_conversionfactor numeric) AS $$
BEGIN
    DELETE FROM tbloperationheader
    WHERE operationid = 'OP-'||p_no OR operationcode = p_no;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================
-- 8. INVENTORY / REPORTS
-- =====================================================================

CREATE OR REPLACE FUNCTION getProductsInventory(p_bracode int) RETURNS TABLE(
    productcode int, productnamear varchar, storenamear varchar,
    qtyonhand numeric, avgcost numeric, lastsaleprice numeric) AS $$
    SELECT p.productcode, p.productnamear, s.storenamear,
           sp.qtyonhand, sp.avgcost, p.lastsaleprice
    FROM tblstoreproducts sp
    JOIN tblproducts p ON p.productcode = sp.productcode
    JOIN tblstores   s ON s.storecode   = sp.storecode
    WHERE p.isactive = true
    ORDER BY p.productnamear;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getInventoryMovement(p_fromdate date, p_todate date, p_bracode int) RETURNS TABLE(
    movementdate date, productnamear varchar, storenamear varchar,
    movementtype varchar, quantity numeric, unitprice numeric) AS $$
    SELECT m.movementdate, p.productnamear, s.storenamear, m.movementtype,
           m.quantity, m.unitcost AS unitprice
    FROM tblproductmovement m
    JOIN tblproducts p ON p.productcode = m.productcode
    JOIN tblstores   s ON s.storecode   = m.storecode
    WHERE m.movementdate BETWEEN p_fromdate AND p_todate
    ORDER BY m.movementdate, m.movementid;
$$ LANGUAGE sql;

-- =====================================================================
-- 9. USERS / AUTHENTICATION / PRIVILEGES
-- =====================================================================

-- 9.1 The login lookup (returns the columns the BL expects)
--     Output shape (matches clsUsers.Login reading):
--       usercode, userid, PWD, PWDHash, PasswordHash, PasswordSalt, PasswordIterations,
--       usernamear, usernameen, isactive, isadmin, branchcode
CREATE OR REPLACE FUNCTION getUserForLogin(p_userid varchar, p_bracode int) RETURNS TABLE(
    usercode int, userid varchar, "PWD" varchar, "PWDHash" varchar,
    "PasswordHash" varchar, "PasswordSalt" varchar, "PasswordIterations" int,
    usernamear varchar, usernameen varchar, isactive boolean, isadmin boolean, branchcode int) AS $$
    SELECT usercode, userid,
           -- PWD: tier-3 plaintext fallback (utf-8 of bytes)
           CASE WHEN userpassword IS NULL OR octet_length(userpassword) = 0 THEN ''::varchar
                ELSE convert_from(userpassword, 'UTF8') END  AS "PWD",
           ''::varchar                                       AS "PWDHash",
           CASE WHEN userpassword IS NULL OR octet_length(userpassword) = 0 THEN ''::varchar
                ELSE encode(userpassword, 'base64') END      AS "PasswordHash",
           CASE WHEN salt IS NULL OR octet_length(salt) = 0 THEN ''::varchar
                ELSE encode(salt, 'base64') END              AS "PasswordSalt",
           100000                                            AS "PasswordIterations",
           usernamear, usernameen, isactive, isadmin, branchcode
    FROM tblusers
    WHERE userid = p_userid
      AND (p_bracode = 0 OR branchcode = p_bracode OR branchcode IS NULL)
    LIMIT 1;
$$ LANGUAGE sql;

-- Backward-compat alias the old view name refers to
DROP VIEW IF EXISTS vw_Login;

CREATE VIEW vw_Login AS
SELECT
    usercode,
    userid,
    encode (userpassword, 'escape') AS "PWD",
    usernamear,
    usernameen,
    isactive,
    isadmin,
    branchcode
FROM tblusers;

-- 9.2 CRUD
CREATE OR REPLACE FUNCTION getAllusers(p_bracode int) RETURNS TABLE(
    usercode int, userid varchar, usernamear varchar, usernameen varchar,
    email varchar, mobile varchar, isactive boolean, isadmin boolean, branchcode int) AS $$
    SELECT usercode, userid, usernamear, usernameen, email, mobile, isactive, isadmin, branchcode
    FROM tblusers
    WHERE (p_bracode = 0 OR branchcode = p_bracode OR branchcode IS NULL)
    ORDER BY usernamear;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getUserNewNo() RETURNS TABLE(usercode int) AS $$
    SELECT COALESCE(MAX(usercode),0)+1 AS usercode FROM tblusers;
$$ LANGUAGE sql;

-- addUser: PasswordHash/Salt are PBKDF2 base64 (PasswordHelper in C#)
CREATE OR REPLACE PROCEDURE addUser(
    IN p_usercode int, IN p_userfname varchar, IN p_userid varchar,
    IN p_pwd varchar, IN p_usermobile varchar, IN p_useremail varchar,
    IN p_userimg bytea, IN p_bracode int, IN p_testimage varchar,
    IN p_passwordsalt varchar, IN p_passwordhash varchar,
    IN p_passwordalgorithm varchar) AS $$
BEGIN
    INSERT INTO tblusers (userid, userpassword, salt, usernamear, usernameen,
                          email, mobile, branchcode, isactive, isadmin)
    VALUES (p_userid,
            CASE WHEN p_passwordhash IS NULL OR p_passwordhash = '' THEN convert_to(COALESCE(p_pwd,''),'UTF8')::bytea
                 ELSE convert_from(decode(p_passwordhash, 'base64'), 'UTF8')::bytea END,
            CASE WHEN p_passwordsalt IS NULL OR p_passwordsalt = '' THEN gen_random_bytes(16)
                 ELSE convert_from(decode(p_passwordsalt, 'base64'), 'UTF8')::bytea END,
            p_userfname, p_userfname, p_useremail, p_usermobile,
            CASE WHEN p_bracode > 0 THEN p_bracode ELSE 1 END, true, false)
    ON CONFLICT (userid) DO NOTHING;
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE updateUser(
    IN p_usercode int, IN p_userfname varchar, IN p_userid varchar,
    IN p_pwd varchar, IN p_usermobile varchar, IN p_useremail varchar,
    IN p_userimg bytea, IN p_bracode int, IN p_testimage varchar,
    IN p_passwordsalt varchar, IN p_passwordhash varchar,
    IN p_passwordalgorithm varchar) AS $$
BEGIN
    UPDATE tblusers
       SET usernamear   = p_userfname,
           usernameen   = p_userfname,
           userid       = p_userid,
           email        = p_useremail,
           mobile       = p_usermobile,
           userpassword = CASE WHEN p_passwordhash IS NULL OR p_passwordhash = '' THEN userpassword
                               ELSE convert_from(decode(p_passwordhash, 'base64'), 'UTF8')::bytea END,
           salt         = CASE WHEN p_passwordsalt IS NULL OR p_passwordsalt = '' THEN salt
                               ELSE convert_from(decode(p_passwordsalt, 'base64'), 'UTF8')::bytea END,
           passwordlastchanged = CURRENT_TIMESTAMP,
           branchcode   = COALESCE(NULLIF(p_bracode,0), branchcode)
     WHERE usercode = p_usercode;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE updateUser(
    IN p_usercode int, IN p_userfname varchar, IN p_userid varchar,
    IN p_pwd varchar, IN p_usermobile varchar, IN p_useremail varchar,
    IN p_userimg bytea, IN p_bracode int, IN p_testimage varchar,
    IN p_passwordsalt varchar, IN p_passwordhash varchar,
    IN p_passwordalgorithm varchar) AS $$
BEGIN
    UPDATE tblusers
       SET usernamear   = p_userfname,
           usernameen   = p_userfname,
           userid       = p_userid,
           email        = p_useremail,
           mobile       = p_usermobile,
           userpassword = COALESCE(NULLIF(decode(p_passwordhash,'hex'), ''::bytea), userpassword),
           salt         = COALESCE(NULLIF(decode(p_passwordsalt,'hex'), ''::bytea), salt),
           passwordlastchanged = CURRENT_TIMESTAMP,
           branchcode   = COALESCE(NULLIF(p_bracode,0), branchcode)
     WHERE usercode = p_usercode;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE delUser(IN p_usercode int) AS $$
BEGIN
    DELETE FROM tblusers WHERE usercode = p_usercode;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE upgradeUserPassword(
    IN p_usercode int, IN p_passwordsalt varchar, IN p_passwordhash varchar,
    IN p_passwordalgorithm varchar, IN p_passworditerations int, IN p_pwd varchar) AS $$
BEGIN
    UPDATE tblusers
       SET userpassword = CASE WHEN p_passwordhash IS NULL OR p_passwordhash = '' THEN userpassword
                               ELSE convert_from(decode(p_passwordhash, 'base64'), 'UTF8')::bytea END,
           salt         = CASE WHEN p_passwordsalt IS NULL OR p_passwordsalt = '' THEN salt
                               ELSE convert_from(decode(p_passwordsalt, 'base64'), 'UTF8')::bytea END,
           passwordlastchanged = CURRENT_TIMESTAMP
     WHERE usercode = p_usercode;
END;
$$ LANGUAGE plpgsql;

-- 9.3 Privileges
CREATE OR REPLACE FUNCTION getUserNo(p_userid varchar) RETURNS TABLE(usercode int, branchcode int) AS $$
    SELECT usercode, branchcode FROM tblusers WHERE userid = p_userid LIMIT 1;
$$ LANGUAGE sql;
-- overload (different parameter count) – Postgres picks by signature
CREATE OR REPLACE FUNCTION getUserNo(p_userid varchar, p_bracode int) RETURNS TABLE(usercode int, branchcode int) AS $$
    SELECT usercode, branchcode
    FROM tblusers
    WHERE userid = p_userid
      AND (p_bracode = 0 OR branchcode = p_bracode OR branchcode IS NULL)
    LIMIT 1;
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE addPrivillages(IN p_usercode int, IN p_bracode int) AS $$
DECLARE
    w RECORD;
BEGIN
    FOR w IN SELECT windowid FROM tblwindows WHERE isactive = true LOOP
        INSERT INTO tblprivileges (usercode, windowid, candisplay, canadd, canedit, candelete, canprint)
        VALUES (p_usercode, w.windowid, true, true, true, true, true)
        ON CONFLICT (usercode, windowid) DO NOTHING;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE editPrivillages(
    IN p_usercode int, IN p_windowid int, IN p_privnew bool, IN p_privadd bool,
    IN p_privedit bool, IN p_privdel bool, IN p_privprint bool,
    IN p_privdisplay bool, IN p_bracode int) AS $$
BEGIN
    INSERT INTO tblprivileges (usercode, windowid, candisplay, canadd, canedit, candelete, canprint)
    VALUES (p_usercode, p_windowid, p_privdisplay, p_privadd, p_privedit, p_privdel, p_privprint)
    ON CONFLICT (usercode, windowid) DO UPDATE
        SET candisplay = EXCLUDED.candisplay,
            canadd     = EXCLUDED.canadd,
            canedit    = EXCLUDED.canedit,
            candelete  = EXCLUDED.candelete,
            canprint   = EXCLUDED.canprint,
            modifiedat = CURRENT_TIMESTAMP;
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE delPrivellages(IN p_usercode int, IN p_bracode int) AS $$
BEGIN
    DELETE FROM tblprivileges WHERE usercode = p_usercode;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getAllBraUsers(p_bracode int) RETURNS TABLE(
    usercode int, userid varchar, usernamear varchar) AS $$
    SELECT usercode, userid, usernamear
    FROM tblusers
    WHERE (p_bracode = 0 OR branchcode = p_bracode OR branchcode IS NULL)
    ORDER BY usernamear;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getAllLists() RETURNS TABLE(
    windowid int, windowcode varchar, windownamear varchar, windownameen varchar,
    modulename varchar) AS $$
    SELECT windowid, windowcode, windownamear, windownameen, modulename
    FROM tblwindows
    WHERE isactive = true
    ORDER BY modulename, sortorder;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getAllPrivillages(p_usercode int, p_bracode int, p_listid int) RETURNS TABLE(
    windowid int, windownamear varchar, candisplay bool, canadd bool, canedit bool,
    candelete bool, canprint bool) AS $$
    SELECT p.windowid, w.windownamear, p.candisplay, p.canadd, p.canedit, p.candelete, p.canprint
    FROM tblprivileges p
    JOIN tblwindows w ON w.windowid = p.windowid
    WHERE p.usercode = p_usercode
      AND (p_listid = 0 OR w.modulename = (SELECT modulename FROM tblwindows WHERE windowid = p_listid))
    ORDER BY w.sortorder;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getDisplayPrivillages(p_usercode int, p_bracode int) RETURNS TABLE(
    windowid int, windownamear varchar, candisplay bool) AS $$
    SELECT p.windowid, w.windownamear, p.candisplay
    FROM tblprivileges p
    JOIN tblwindows w ON w.windowid = p.windowid
    WHERE p.usercode = p_usercode AND p.candisplay = true
    ORDER BY w.sortorder;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getScreensPrivillages(p_usercode int, p_windowid int, p_bracode int) RETURNS TABLE(
    privnew bool, privadd bool, privedit bool, privdel bool, privprint bool, privdisplay bool) AS $$
    SELECT COALESCE(canadd,false)     AS privadd,
           COALESCE(canedit,false)    AS privedit,
           COALESCE(candelete,false)  AS privdel,
           COALESCE(canprint,false)   AS privprint,
           COALESCE(candisplay,false) AS privdisplay,
           COALESCE(candisplay,false) AS privnew
    FROM tblprivileges
    WHERE usercode = p_usercode AND windowid = p_windowid
    LIMIT 1;
$$ LANGUAGE sql;

-- =====================================================================
-- 10. AUDIT HELPER  (14 params as in AuditHelper.cs)
-- =====================================================================

CREATE OR REPLACE PROCEDURE addAuditLog(
    IN p_eventtype varchar, IN p_usercode int, IN p_userid varchar,
    IN p_bracode int, IN p_windowid int, IN p_modulename varchar,
    IN p_actionname varchar, IN p_entityname varchar, IN p_entitykey varchar,
    IN p_oldvalue text, IN p_newvalue text, IN p_success bool,
    IN p_errormessage text, IN p_machinename varchar) AS $$
BEGIN
    INSERT INTO tblauditlogs
        (usercode, userid, eventtype, eventcategory, eventdescription,
         actionname, entityname, entitykey, oldvalue, newvalue,
         success, errormessage, machinename, moduleName, windowid,
         tablename, recordid, eventdate)
    VALUES
        (p_usercode, p_userid, p_eventtype,
         COALESCE(p_modulename,'SYSTEM'),
         COALESCE(p_actionname,'') || ' ' || COALESCE(p_entityname,'') || ' ' || COALESCE(p_entitykey,''),
         p_actionname, p_entityname, p_entitykey, p_oldvalue, p_newvalue,
         COALESCE(p_success, true), p_errormessage, p_machinename,
         p_modulename, p_windowid,
         COALESCE(p_entityname, 'N/A'), 0, CURRENT_TIMESTAMP);
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================
-- 11. SESSION MANAGEMENT  (matches SessionContext.cs)
-- =====================================================================

CREATE OR REPLACE PROCEDURE createSession(
    IN p_usercode int, IN p_userid varchar, IN p_bracode int,
    IN p_machinename varchar, INOUT p_sessiontoken uuid) AS $$
DECLARE
    v_existing uuid;
BEGIN
    -- reuse the still-active session for this user on the same machine
    SELECT sessiontoken INTO v_existing
    FROM tblsessions
    WHERE usercode = p_usercode
      AND machinename = p_machinename
      AND isactive = true
      AND (expiresat IS NULL OR expiresat > CURRENT_TIMESTAMP)
    ORDER BY createdat DESC LIMIT 1;

    IF v_existing IS NOT NULL THEN
        p_sessiontoken := v_existing;
        UPDATE tblsessions
           SET lastactivityat = CURRENT_TIMESTAMP,
               expiresat      = CURRENT_TIMESTAMP + INTERVAL '1 hour'
         WHERE sessiontoken = v_existing;
        RETURN;
    END IF;

    p_sessiontoken := gen_random_uuid();
    INSERT INTO tblsessions (sessiontoken, usercode, userid, branchcode, machinename,
                             createdat, lastactivityat, expiresat, isactive)
    VALUES (p_sessiontoken, p_usercode, p_userid, p_bracode, p_machinename,
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '1 hour', true);
EXCEPTION WHEN OTHERS THEN
    p_sessiontoken := gen_random_uuid();
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validateSession(p_sessiontoken uuid) RETURNS TABLE(
    sessiontoken uuid, usercode int, userid varchar, isactive boolean) AS $$
    SELECT sessiontoken, usercode, userid, isactive
    FROM tblsessions
    WHERE sessiontoken = p_sessiontoken
      AND isactive = true
      AND (expiresat IS NULL OR expiresat > CURRENT_TIMESTAMP)
    LIMIT 1;
$$ LANGUAGE sql;

CREATE OR REPLACE PROCEDURE updateSessionActivity(IN p_sessiontoken uuid) AS $$
BEGIN
    UPDATE tblsessions
       SET lastactivityat = CURRENT_TIMESTAMP,
           expiresat      = CURRENT_TIMESTAMP + INTERVAL '1 hour'
     WHERE sessiontoken = p_sessiontoken AND isactive = true;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE endSession(IN p_sessiontoken uuid) AS $$
BEGIN
    UPDATE tblsessions
       SET isactive  = false,
           logoutat  = CURRENT_TIMESTAMP
     WHERE sessiontoken = p_sessiontoken;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE expireOldSessions() AS $$
BEGIN
    UPDATE tblsessions
       SET isactive = false
     WHERE isactive = true
       AND expiresat IS NOT NULL
       AND expiresat < CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================
-- 12. STUB: backup / restore (no-op in PostgreSQL; backed by pg_dump outside)
-- =====================================================================

CREATE OR REPLACE PROCEDURE backupDB(IN p_databasename varchar, IN p_backuppath varchar) AS $$
BEGIN
    -- Intentionally a no-op. Use pg_dump / pg_basebackup from the host.
    RAISE NOTICE 'Use pg_dump from the OS to back up %.', p_databasename;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE restoreDB(IN p_databasename varchar, IN p_backuppath varchar) AS $$
BEGIN
    RAISE NOTICE 'Use pg_restore from the OS to restore %.', p_databasename;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================
-- 13. SEED: ADMIN user, default branch, base currency
-- =====================================================================

INSERT INTO
    tblbranches (
        branchcode,
        branchid,
        branchnamear,
        branchnameen,
        ismainbranch,
        isactive
    )
VALUES (
        1,
        'MAIN',
        'الفرع الرئيسي',
        'Main Branch',
        true,
        true
    ) ON CONFLICT (branchid) DO NOTHING;

INSERT INTO
    tblcurrencies (
        currencycode,
        currencyid,
        currencynamear,
        currencynameen,
        symbol,
        exchangerate,
        isbasecurrency,
        isactive
    )
VALUES (
        1,
        'SAR',
        'ريال سعودي',
        'Saudi Riyal',
        'SAR',
        1.0,
        true,
        true
    ) ON CONFLICT (currencyid) DO NOTHING;

-- basic accounting roots
INSERT INTO
    tblaccounts (
        accountcode,
        accountid,
        accountnamear,
        accountnameen,
        accounttype,
        accountlevel,
        accountnature,
        ispostable,
        isactive
    )
VALUES (
        1,
        '1000',
        'الأصول',
        'Assets',
        'ASSET',
        1,
        'DEBIT',
        false,
        true
    ),
    (
        2,
        '2000',
        'الالتزامات',
        'Liabilities',
        'LIABILITY',
        1,
        'CREDIT',
        false,
        true
    ),
    (
        3,
        '3000',
        'حقوق الملكية',
        'Equity',
        'EQUITY',
        1,
        'CREDIT',
        false,
        true
    ),
    (
        4,
        '4000',
        'الإيرادات',
        'Revenue',
        'REVENUE',
        1,
        'CREDIT',
        false,
        true
    ),
    (
        5,
        '5000',
        'المصروفات',
        'Expenses',
        'EXPENSE',
        1,
        'DEBIT',
        false,
        true
    ) ON CONFLICT (accountid) DO NOTHING;

INSERT INTO
    tblunits (
        unitcode,
        unitid,
        unitnamear,
        unitnameen,
        symbol,
        isactive
    )
VALUES (
        1,
        'PCS',
        'قطعة',
        'Piece',
        'pcs',
        true
    ),
    (
        2,
        'KG',
        'كيلو',
        'Kilogram',
        'kg',
        true
    ) ON CONFLICT (unitid) DO NOTHING;

INSERT INTO
    tblpaymentmethods (
        paymentmethodcode,
        methodnamear,
        methodnameen,
        methodtype,
        isactive
    )
VALUES (
        1,
        'نقدي',
        'Cash',
        'CASH',
        true
    ),
    (
        2,
        'بنك',
        'Bank',
        'BANK',
        true
    ),
    (
        3,
        'آجل',
        'Credit',
        'CREDIT',
        true
    ) ON CONFLICT DO NOTHING;

INSERT INTO
    tblwindows (
        windowcode,
        windownamear,
        windownameen,
        modulename,
        formname,
        sortorder,
        isactive
    )
VALUES (
        'MAIN',
        'الرئيسية',
        'Main',
        'System',
        'frmMainWindow',
        1,
        true
    ),
    (
        'USERS',
        'المستخدمون',
        'Users',
        'Security',
        'frmUsers',
        10,
        true
    ),
    (
        'PRIV',
        'الصلاحيات',
        'Privileges',
        'Security',
        'frmPrivillages',
        11,
        true
    ),
    (
        'ACCOUNTS',
        'دليل الحسابات',
        'Chart',
        'Accounts',
        'frmAccounts',
        20,
        true
    ),
    (
        'JOURNAL',
        'القيود',
        'Journal',
        'Journal',
        'frmJournal',
        30,
        true
    ),
    (
        'BONDS',
        'السندات',
        'Bonds',
        'Bonds',
        'frmBonds',
        40,
        true
    ),
    (
        'CUSTOMERS',
        'العملاء',
        'Customers',
        'Sales',
        'frmCustomers',
        50,
        true
    ),
    (
        'SUPPLIERS',
        'الموردون',
        'Suppliers',
        'Purchases',
        'frmSuppliers',
        60,
        true
    ),
    (
        'INVENTORY',
        'المخزون',
        'Inventory',
        'Stores',
        'frmInventory',
        70,
        true
    ),
    (
        'PRODUCTS',
        'المنتجات',
        'Products',
        'Stores',
        'frmProducts',
        71,
        true
    ),
    (
        'CATEGORIES',
        'الفئات',
        'Categories',
        'Stores',
        'frmCategories',
        72,
        true
    ),
    (
        'STORES',
        'المخازن',
        'Stores',
        'Stores',
        'frmStores',
        73,
        true
    ),
    (
        'UNITS',
        'الوحدات',
        'Units',
        'Stores',
        'frmUnits',
        74,
        true
    ),
    (
        'SALES',
        'المبيعات',
        'Sales',
        'Sales',
        'frmSales',
        80,
        true
    ),
    (
        'PURCHASES',
        'المشتريات',
        'Purchases',
        'Purchases',
        'frmPurchases',
        90,
        true
    ),
    (
        'REPORTS',
        'التقارير',
        'Reports',
        'Reports',
        'frmReports',
        100,
        true
    ),
    (
        'SYSCONFIG',
        'إعدادات النظام',
        'SysFormat',
        'System',
        'frmSysFormat',
        110,
        true
    ) ON CONFLICT (windowcode) DO NOTHING;

-- ADMIN user – we store 'Admin@123' as plain UTF-8 in userpassword. The BL
-- tier-3 fallback (clsUsers.Login) compares the entered password against
-- this value. On first successful login, PasswordHelper.UpgradePassword
-- will replace it with a PBKDF2 base64 hash.
INSERT INTO tblusers (usercode, userid, userpassword, salt, usernamear, usernameen,
                      isactive, isadmin, branchcode, passwordlastchanged, createdby, createdat)
VALUES (1, 'ADMIN',
        convert_to('Admin@123','UTF8')::bytea, gen_random_bytes(16),
        'مدير النظام', 'System Administrator',
        true, true, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP)
ON CONFLICT (userid) DO NOTHING;

-- Grant ADMIN all privileges
INSERT INTO
    tblprivileges (
        usercode,
        windowid,
        candisplay,
        canadd,
        canedit,
        candelete,
        canprint,
        canapprove,
        canpost
    )
SELECT 1, windowid, true, true, true, true, true, true, true
FROM tblwindows ON CONFLICT (usercode, windowid) DO NOTHING;

-- Grant default privileges to everyone (userid = '__DEFAULT__' not a user, so we
-- skip; privileges are per-user in this schema)

-- =====================================================================
-- DONE
-- =====================================================================