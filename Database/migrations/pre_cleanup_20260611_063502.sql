--
-- PostgreSQL database dump
--

\restrict OPFzC5FAhXSudeUBJo1wlo6QRYGKzOBnvbwfExgfkz7I4uEehMfHqLNStEuGSUx

-- Dumped from database version 17.10
-- Dumped by pg_dump version 17.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: pgstattuple; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgstattuple WITH SCHEMA public;


--
-- Name: EXTENSION pgstattuple; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgstattuple IS 'show tuple-level statistics';


--
-- Name: addaccount(integer, integer, character varying, integer, integer, integer, numeric, numeric, numeric, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.addaccount(IN p_acccode integer, IN p_accparentcode integer, IN p_accname character varying, IN p_acclevel integer, IN p_acctype integer, IN p_accreport integer, IN p_accdebitor numeric, IN p_acccreditor numeric, IN p_accbalance numeric, IN p_islock integer, IN p_bracode integer)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.addaccount(IN p_acccode integer, IN p_accparentcode integer, IN p_accname character varying, IN p_acclevel integer, IN p_acctype integer, IN p_accreport integer, IN p_accdebitor numeric, IN p_acccreditor numeric, IN p_accbalance numeric, IN p_islock integer, IN p_bracode integer) OWNER TO postgres;

--
-- Name: addauditlog(character varying, integer, character varying, integer, integer, character varying, character varying, character varying, character varying, text, text, boolean, text, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.addauditlog(IN p_eventtype character varying, IN p_usercode integer, IN p_userid character varying, IN p_bracode integer, IN p_windowid integer, IN p_modulename character varying, IN p_actionname character varying, IN p_entityname character varying, IN p_entitykey character varying, IN p_oldvalue text, IN p_newvalue text, IN p_success boolean, IN p_errormessage text, IN p_machinename character varying)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.addauditlog(IN p_eventtype character varying, IN p_usercode integer, IN p_userid character varying, IN p_bracode integer, IN p_windowid integer, IN p_modulename character varying, IN p_actionname character varying, IN p_entityname character varying, IN p_entitykey character varying, IN p_oldvalue text, IN p_newvalue text, IN p_success boolean, IN p_errormessage text, IN p_machinename character varying) OWNER TO postgres;

--
-- Name: addbank(integer, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.addbank(IN p_bankcode integer, IN p_bankname character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO tblbanks (bankid, banknamear, isactive)
    VALUES (nextval('tblbanks_bankcode_seq')::text, p_bankName, true);
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$;


ALTER PROCEDURE public.addbank(IN p_bankcode integer, IN p_bankname character varying) OWNER TO postgres;

--
-- Name: addbondbody(integer, integer, numeric, integer, numeric); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.addbondbody(IN p_acccode integer, IN p_currid integer, IN p_amount numeric, IN p_bondno integer, IN p_currval numeric)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.addbondbody(IN p_acccode integer, IN p_currid integer, IN p_amount numeric, IN p_bondno integer, IN p_currval numeric) OWNER TO postgres;

--
-- Name: addbondheader(integer, date, character varying, integer, integer, integer, integer, numeric, integer, date, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.addbondheader(IN p_bondno integer, IN p_bonddate date, IN p_bondnote character varying, IN p_bondtype integer, IN p_bondpost integer, IN p_accfundcode integer, IN p_accbankcode integer, IN p_amount numeric, IN p_useradd integer, IN p_adddate date, IN p_bracode integer, IN p_jno integer)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.addbondheader(IN p_bondno integer, IN p_bonddate date, IN p_bondnote character varying, IN p_bondtype integer, IN p_bondpost integer, IN p_accfundcode integer, IN p_accbankcode integer, IN p_amount numeric, IN p_useradd integer, IN p_adddate date, IN p_bracode integer, IN p_jno integer) OWNER TO postgres;

--
-- Name: addbusinessunit(character varying, character varying, character varying, integer, boolean, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addbusinessunit(p_businessunitid character varying, p_namear character varying, p_nameen character varying, p_parentbusinessunitcode integer, p_isactive boolean, p_notes text, p_adduser integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE v INTEGER;
BEGIN
    INSERT INTO tbldim_businessunits(businessunitid,namear,nameen,parentbusinessunitcode,isactive,notes,adduser)
    VALUES (p_businessunitid,p_namear,p_nameen,p_parentbusinessunitcode,COALESCE(p_isactive,TRUE),p_notes,p_adduser)
    RETURNING businessunitcode INTO v; RETURN v;
END$$;


ALTER FUNCTION public.addbusinessunit(p_businessunitid character varying, p_namear character varying, p_nameen character varying, p_parentbusinessunitcode integer, p_isactive boolean, p_notes text, p_adduser integer) OWNER TO postgres;

--
-- Name: addcategories(character varying, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.addcategories(IN p_catname character varying, IN p_storeid integer, IN p_inventorycode integer, IN p_saleno integer, IN p_salereturnno integer, IN p_salevataccno integer, IN p_salediscaccno integer, IN p_saleqtyfreeaccno integer, IN p_salecostaccno integer, IN p_salerevenuseaccno integer, IN p_puraccno integer, IN p_purreturnaccno integer, IN p_purvataccno integer, IN p_purdiscaccno integer, IN p_purqtyfreeaccno integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO tblcategories (categoryid, categorynamear, parentcategorycode, isactive)
    VALUES (nextval('tblcategories_categorycode_seq')::text, p_catName, NULL, true);
END;
$$;


ALTER PROCEDURE public.addcategories(IN p_catname character varying, IN p_storeid integer, IN p_inventorycode integer, IN p_saleno integer, IN p_salereturnno integer, IN p_salevataccno integer, IN p_salediscaccno integer, IN p_saleqtyfreeaccno integer, IN p_salecostaccno integer, IN p_salerevenuseaccno integer, IN p_puraccno integer, IN p_purreturnaccno integer, IN p_purvataccno integer, IN p_purdiscaccno integer, IN p_purqtyfreeaccno integer) OWNER TO postgres;

--
-- Name: addcompany(integer, character varying, character varying, character varying, character varying, character varying, character varying, bytea, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.addcompany(IN p_bracode integer, IN p_braname character varying, IN p_braaddress character varying, IN p_braactivity character varying, IN p_bratel character varying, IN p_brafax character varying, IN p_braemail character varying, IN p_bralogo bytea, IN p_testimage character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO tblbranches (branchid, branchnamear, address, phone, email, isactive)
    VALUES (COALESCE(p_testImage,'')||nextval('tblbranches_branchcode_seq')::text,
            p_braName, p_braAddress, p_braTel, p_braEmail, true);
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$;


ALTER PROCEDURE public.addcompany(IN p_bracode integer, IN p_braname character varying, IN p_braaddress character varying, IN p_braactivity character varying, IN p_bratel character varying, IN p_brafax character varying, IN p_braemail character varying, IN p_bralogo bytea, IN p_testimage character varying) OWNER TO postgres;

--
-- Name: addcurrency(character varying, integer, numeric, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.addcurrency(IN p_currname character varying, IN p_currtype integer, IN p_currval numeric, IN p_currpenny character varying, IN p_currsymbole character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO tblcurrencies (currencyid, currencynamear, symbol, exchangerate, isactive)
    VALUES (nextval('tblcurrencies_currencycode_seq')::text, p_currName,
            p_currSymbole, p_currVal, true);
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$;


ALTER PROCEDURE public.addcurrency(IN p_currname character varying, IN p_currtype integer, IN p_currval numeric, IN p_currpenny character varying, IN p_currsymbole character varying) OWNER TO postgres;

--
-- Name: addcustomers(integer, character varying, numeric, character varying, character varying, bytea, integer, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.addcustomers(IN p_custcode integer, IN p_custname character varying, IN p_debitlimit numeric, IN p_mobile character varying, IN p_email character varying, IN p_img bytea, IN p_bracode integer, IN p_testimage character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO tblcustomers (customerid, customernamear, mobile, email, creditlimit, branchcode, isactive)
    VALUES (COALESCE(p_testImage,'')||nextval('tblcustomers_customercode_seq')::text,
            p_custName, p_mobile, p_email, p_debitLimit, p_braCode, true);
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$;


ALTER PROCEDURE public.addcustomers(IN p_custcode integer, IN p_custname character varying, IN p_debitlimit numeric, IN p_mobile character varying, IN p_email character varying, IN p_img bytea, IN p_bracode integer, IN p_testimage character varying) OWNER TO postgres;

--
-- Name: adddepartment(character varying, character varying, character varying, integer, integer, boolean, date, date, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.adddepartment(p_departmentid character varying, p_namear character varying, p_nameen character varying, p_parentdepartmentcode integer, p_managerusercode integer, p_isactive boolean, p_effectivedate date, p_enddate date, p_notes text, p_adduser integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_newcode INTEGER;
BEGIN
    INSERT INTO tbldim_departments(
        departmentid, namear, nameen, parentdepartmentcode, managerusercode,
        isactive, effectivedate, enddate, notes, adduser)
    VALUES (p_departmentid, p_namear, p_nameen, p_parentdepartmentcode, p_managerusercode,
            COALESCE(p_isactive, TRUE), COALESCE(p_effectivedate, CURRENT_DATE), p_enddate, p_notes, p_adduser)
    RETURNING departmentcode INTO v_newcode;
    RETURN v_newcode;
END$$;


ALTER FUNCTION public.adddepartment(p_departmentid character varying, p_namear character varying, p_nameen character varying, p_parentdepartmentcode integer, p_managerusercode integer, p_isactive boolean, p_effectivedate date, p_enddate date, p_notes text, p_adduser integer) OWNER TO postgres;

--
-- Name: adddimensionhierarchy(character varying, character varying, integer, character varying, integer, date, date, boolean, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.adddimensionhierarchy(p_hierarchytype character varying, p_parentdimtype character varying, p_parentdimcode integer, p_childdimtype character varying, p_childdimcode integer, p_validfrom date, p_validto date, p_isactive boolean, p_notes text, p_adduser integer) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE v BIGINT;
BEGIN
    INSERT INTO tbldim_hierarchies(hierarchytype,parentdimtype,parentdimcode,childdimtype,childdimcode,
                                    validfrom,validto,isactive,notes,adduser)
    VALUES (p_hierarchytype,p_parentdimtype,p_parentdimcode,p_childdimtype,p_childdimcode,
            COALESCE(p_validfrom,CURRENT_DATE),p_validto,COALESCE(p_isactive,TRUE),p_notes,p_adduser)
    RETURNING hierarchyid INTO v; RETURN v;
EXCEPTION
    WHEN unique_violation THEN RETURN -1; -- duplicate
END$$;


ALTER FUNCTION public.adddimensionhierarchy(p_hierarchytype character varying, p_parentdimtype character varying, p_parentdimcode integer, p_childdimtype character varying, p_childdimcode integer, p_validfrom date, p_validto date, p_isactive boolean, p_notes text, p_adduser integer) OWNER TO postgres;

--
-- Name: addfund(integer, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.addfund(IN p_fundcode integer, IN p_fundname character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO tblfunds (fundid, fundnamear, isactive)
    VALUES (nextval('tblfunds_fundcode_seq')::text, p_fundName, true);
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$;


ALTER PROCEDURE public.addfund(IN p_fundcode integer, IN p_fundname character varying) OWNER TO postgres;

--
-- Name: addjournalbody(integer, integer, numeric, numeric, numeric, character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.addjournalbody(IN p_acccode integer, IN p_currid integer, IN p_currval numeric, IN p_accdebitor numeric, IN p_acccreditor numeric, IN p_entitynote character varying, IN p_jno integer)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.addjournalbody(IN p_acccode integer, IN p_currid integer, IN p_currval numeric, IN p_accdebitor numeric, IN p_acccreditor numeric, IN p_entitynote character varying, IN p_jno integer) OWNER TO postgres;

--
-- Name: addjournalheader(integer, timestamp with time zone, character varying, integer, integer, numeric, numeric, numeric, integer, timestamp with time zone, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.addjournalheader(IN p_jno integer, IN p_jdate timestamp with time zone, IN p_jnote character varying, IN p_jtype integer, IN p_jpost integer, IN p_accdebitor numeric, IN p_acccreditor numeric, IN p_accbalance numeric, IN p_useradd integer, IN p_adddate timestamp with time zone, IN p_bracode integer, IN p_optype integer)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.addjournalheader(IN p_jno integer, IN p_jdate timestamp with time zone, IN p_jnote character varying, IN p_jtype integer, IN p_jpost integer, IN p_accdebitor numeric, IN p_acccreditor numeric, IN p_accbalance numeric, IN p_useradd integer, IN p_adddate timestamp with time zone, IN p_bracode integer, IN p_optype integer) OWNER TO postgres;

--
-- Name: addoperationbody(integer, integer, integer, numeric, numeric, numeric, numeric, integer, numeric, numeric, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.addoperationbody(IN p_prodcode integer, IN p_currid integer, IN p_unitid integer, IN p_qty numeric, IN p_price numeric, IN p_discount numeric, IN p_vat numeric, IN p_no integer, IN p_currval numeric, IN p_conversionfactor numeric, IN p_optype integer)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.addoperationbody(IN p_prodcode integer, IN p_currid integer, IN p_unitid integer, IN p_qty numeric, IN p_price numeric, IN p_discount numeric, IN p_vat numeric, IN p_no integer, IN p_currval numeric, IN p_conversionfactor numeric, IN p_optype integer) OWNER TO postgres;

--
-- Name: addoperationhdr(integer, timestamp with time zone, integer, integer, character varying, integer, integer, integer, integer, timestamp with time zone, integer, integer, integer, numeric, numeric, numeric, numeric, integer, numeric); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.addoperationhdr(IN p_no integer, IN p_opdate timestamp with time zone, IN p_optype integer, IN p_post integer, IN p_note character varying, IN p_custno integer, IN p_salerepno integer, IN p_suppno integer, IN p_useradd integer, IN p_adddate timestamp with time zone, IN p_bracode integer, IN p_paymentmethodid integer, IN p_fundcode integer, IN p_alltotal numeric, IN p_discount numeric, IN p_vat numeric, IN p_nettotal numeric, IN p_jno integer, IN p_salecost numeric)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.addoperationhdr(IN p_no integer, IN p_opdate timestamp with time zone, IN p_optype integer, IN p_post integer, IN p_note character varying, IN p_custno integer, IN p_salerepno integer, IN p_suppno integer, IN p_useradd integer, IN p_adddate timestamp with time zone, IN p_bracode integer, IN p_paymentmethodid integer, IN p_fundcode integer, IN p_alltotal numeric, IN p_discount numeric, IN p_vat numeric, IN p_nettotal numeric, IN p_jno integer, IN p_salecost numeric) OWNER TO postgres;

--
-- Name: addprivillages(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.addprivillages(IN p_usercode integer, IN p_bracode integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    w RECORD;
BEGIN
    FOR w IN SELECT windowid FROM tblwindows WHERE isactive = true LOOP
        INSERT INTO tblprivileges (usercode, windowid, candisplay, canadd, canedit, candelete, canprint)
        VALUES (p_usercode, w.windowid, true, true, true, true, true)
        ON CONFLICT (usercode, windowid) DO NOTHING;
    END LOOP;
END;
$$;


ALTER PROCEDURE public.addprivillages(IN p_usercode integer, IN p_bracode integer) OWNER TO postgres;

--
-- Name: addproduct(integer, character varying, integer, integer, integer, numeric, numeric, bytea, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.addproduct(IN p_prodcode integer, IN p_prodname character varying, IN p_stroreid integer, IN p_catid integer, IN p_unitid integer, IN p_qty numeric, IN p_price numeric, IN p_prodimg bytea, IN p_imagtest character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO tblproducts (productid, productnamear, barcode, categorycode, defaultunitcode, lastsaleprice, isactive)
    VALUES (COALESCE(p_imagTest,'')||nextval('tblproducts_productcode_seq')::text,
            p_prodName, p_imagTest, p_catID, p_unitID, p_price, true);
EXCEPTION WHEN OTHERS THEN
    -- ignore: productid uniqueness is best-effort
    NULL;
END;
$$;


ALTER PROCEDURE public.addproduct(IN p_prodcode integer, IN p_prodname character varying, IN p_stroreid integer, IN p_catid integer, IN p_unitid integer, IN p_qty numeric, IN p_price numeric, IN p_prodimg bytea, IN p_imagtest character varying) OWNER TO postgres;

--
-- Name: addproductmovement(integer, numeric, numeric, integer, integer, integer, timestamp with time zone, integer, numeric, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.addproductmovement(IN p_prodcode integer, IN p_qty numeric, IN p_price numeric, IN p_unitid integer, IN p_storeid integer, IN p_catid integer, IN p_movedate timestamp with time zone, IN p_no integer, IN p_conversionfactor numeric, IN p_optype integer)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.addproductmovement(IN p_prodcode integer, IN p_qty numeric, IN p_price numeric, IN p_unitid integer, IN p_storeid integer, IN p_catid integer, IN p_movedate timestamp with time zone, IN p_no integer, IN p_conversionfactor numeric, IN p_optype integer) OWNER TO postgres;

--
-- Name: addprofitcenter(character varying, character varying, character varying, integer, boolean, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addprofitcenter(p_profitcenterid character varying, p_namear character varying, p_nameen character varying, p_parentprofitcentercode integer, p_isactive boolean, p_notes text, p_adduser integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE v INTEGER;
BEGIN
    INSERT INTO tbldim_profitcenters(profitcenterid,namear,nameen,parentprofitcentercode,isactive,notes,adduser)
    VALUES (p_profitcenterid,p_namear,p_nameen,p_parentprofitcentercode,COALESCE(p_isactive,TRUE),p_notes,p_adduser)
    RETURNING profitcentercode INTO v; RETURN v;
END$$;


ALTER FUNCTION public.addprofitcenter(p_profitcenterid character varying, p_namear character varying, p_nameen character varying, p_parentprofitcentercode integer, p_isactive boolean, p_notes text, p_adduser integer) OWNER TO postgres;

--
-- Name: addproject(character varying, character varying, character varying, integer, character varying, date, date, numeric, character varying, boolean, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addproject(p_projectid character varying, p_namear character varying, p_nameen character varying, p_parentprojectcode integer, p_projecttype character varying, p_startdate date, p_enddate date, p_budgetamount numeric, p_projectstatus character varying, p_isactive boolean, p_notes text, p_adduser integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE v_newcode INTEGER;
BEGIN
    INSERT INTO tbldim_projects(
        projectid, namear, nameen, parentprojectcode, projecttype,
        startdate, enddate, budgetamount, projectstatus,
        isactive, notes, adduser)
    VALUES (p_projectid, p_namear, p_nameen, p_parentprojectcode,
            COALESCE(p_projecttype,'INTERNAL'),
            p_startdate, p_enddate, COALESCE(p_budgetamount,0),
            COALESCE(p_projectstatus,'ACTIVE'),
            COALESCE(p_isactive, TRUE), p_notes, p_adduser)
    RETURNING projectcode INTO v_newcode;
    RETURN v_newcode;
END$$;


ALTER FUNCTION public.addproject(p_projectid character varying, p_namear character varying, p_nameen character varying, p_parentprojectcode integer, p_projecttype character varying, p_startdate date, p_enddate date, p_budgetamount numeric, p_projectstatus character varying, p_isactive boolean, p_notes text, p_adduser integer) OWNER TO postgres;

--
-- Name: addsegment(character varying, character varying, character varying, character varying, integer, boolean, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addsegment(p_segmentid character varying, p_namear character varying, p_nameen character varying, p_segmenttype character varying, p_parentsegmentcode integer, p_isactive boolean, p_notes text, p_adduser integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE v INTEGER;
BEGIN
    INSERT INTO tbldim_segments(segmentid,namear,nameen,segmenttype,parentsegmentcode,isactive,notes,adduser)
    VALUES (p_segmentid,p_namear,p_nameen,COALESCE(p_segmenttype,'GEOGRAPHIC'),p_parentsegmentcode,COALESCE(p_isactive,TRUE),p_notes,p_adduser)
    RETURNING segmentcode INTO v; RETURN v;
END$$;


ALTER FUNCTION public.addsegment(p_segmentid character varying, p_namear character varying, p_nameen character varying, p_segmenttype character varying, p_parentsegmentcode integer, p_isactive boolean, p_notes text, p_adduser integer) OWNER TO postgres;

--
-- Name: addstore(character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.addstore(IN p_storename character varying, IN p_storetel character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO tblstores (storeid, storenamear, branchcode, isactive)
    VALUES (COALESCE(p_storeTel,'')||'-'||nextval('tblstores_storecode_seq')::text,
            p_storeName, 1, true);
END;
$$;


ALTER PROCEDURE public.addstore(IN p_storename character varying, IN p_storetel character varying) OWNER TO postgres;

--
-- Name: addsuppleir(integer, character varying, character varying, character varying, bytea, character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.addsuppleir(IN p_suppcode integer, IN p_suppname character varying, IN p_mobile character varying, IN p_email character varying, IN p_img bytea, IN p_testimage character varying, IN p_bracode integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO tblsuppliers (supplierid, suppliernamear, mobile, email, branchcode, isactive)
    VALUES (COALESCE(p_testImage,'')||nextval('tblsuppliers_suppliercode_seq')::text,
            p_suppName, p_mobile, p_email, p_braCode, true);
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$;


ALTER PROCEDURE public.addsuppleir(IN p_suppcode integer, IN p_suppname character varying, IN p_mobile character varying, IN p_email character varying, IN p_img bytea, IN p_testimage character varying, IN p_bracode integer) OWNER TO postgres;

--
-- Name: addunit(character varying, numeric); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.addunit(IN p_unitname character varying, IN p_conversionfactor numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO tblunits (unitid, unitnamear, isactive)
    VALUES (p_unitName, p_unitName, true)
    ON CONFLICT (unitid) DO NOTHING;
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$;


ALTER PROCEDURE public.addunit(IN p_unitname character varying, IN p_conversionfactor numeric) OWNER TO postgres;

--
-- Name: adduser(integer, character varying, character varying, character varying, character varying, character varying, bytea, integer, character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.adduser(IN p_usercode integer, IN p_userfname character varying, IN p_userid character varying, IN p_pwd character varying, IN p_usermobile character varying, IN p_useremail character varying, IN p_userimg bytea, IN p_bracode integer, IN p_testimage character varying, IN p_passwordsalt character varying, IN p_passwordhash character varying, IN p_passwordalgorithm character varying)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.adduser(IN p_usercode integer, IN p_userfname character varying, IN p_userid character varying, IN p_pwd character varying, IN p_usermobile character varying, IN p_useremail character varying, IN p_userimg bytea, IN p_bracode integer, IN p_testimage character varying, IN p_passwordsalt character varying, IN p_passwordhash character varying, IN p_passwordalgorithm character varying) OWNER TO postgres;

--
-- Name: approverequest(bigint, integer, text, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.approverequest(IN p_requestid bigint, IN p_approverid integer, IN p_comments text, IN p_ipaddress character varying, IN p_useragent character varying, OUT p_result character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_status VARCHAR(20);
    v_currentlevel INTEGER;
    v_totallevels INTEGER;
    v_workflowid INTEGER;
    v_levelid INTEGER;
    v_effectiveapprover INTEGER;
    v_nextlevel INTEGER;
BEGIN
    -- Get current state
    SELECT status, currentlevel, totallevels, workflowid
    INTO v_status, v_currentlevel, v_totallevels, v_workflowid
    FROM tblapprovalrequests
    WHERE requestid = p_requestid;

    IF NOT FOUND THEN
        p_result := 'ERROR: Request not found';
        RETURN;
    END IF;

    IF v_status <> 'PENDING' THEN
        p_result := 'ERROR: Request is not pending (status: ' || v_status || ')';
        RETURN;
    END IF;

    -- Get level id
    SELECT levelid INTO v_levelid
    FROM tblapprovallevels
    WHERE workflowid = v_workflowid AND levelnumber = v_currentlevel;

    -- Check delegation
    v_effectiveapprover := getEffectiveApprover(p_approverid, v_workflowid);

    -- Log approval
    INSERT INTO tblapprovalactions
        (requestid, levelid, approverid, actiontype, oldstatus, newstatus, fromlevel, tolevel, comments, ipaddress, useragent, delegatedto)
    VALUES
        (p_requestid, v_levelid, p_approverid, 'APPROVED', 'PENDING', 'PENDING', v_currentlevel, v_currentlevel, p_comments, p_ipaddress, p_useragent,
         CASE WHEN v_effectiveapprover <> p_approverid THEN v_effectiveapprover ELSE NULL END);

    -- Advance to next level or complete
    v_nextlevel := v_currentlevel + 1;

    IF v_nextlevel > v_totallevels THEN
        -- All levels approved
        UPDATE tblapprovalrequests
        SET status = 'APPROVED', currentlevel = v_nextlevel, completedate = NOW(), completedby = p_approverid
        WHERE requestid = p_requestid;

        -- Log final approval
        INSERT INTO tblapprovalactions
            (requestid, levelid, approverid, actiontype, oldstatus, newstatus, fromlevel, tolevel, comments)
        VALUES
            (p_requestid, v_levelid, p_approverid, 'APPROVED', 'PENDING', 'APPROVED', v_currentlevel, v_nextlevel, 'Final approval - all levels complete');

        -- Send notification to requester
        INSERT INTO tblnotifications (userid, title, message, notificationtype, priority, reftype, refid)
        SELECT r.requesterid, 'Request ' || r.requestno || ' APPROVED', 'Your request ' || r.requestno || ' has been fully approved.', 'APPROVAL', 'NORMAL', 'APPROVAL_REQUEST', r.requestid
        FROM tblapprovalrequests r WHERE r.requestid = p_requestid;

        p_result := 'SUCCESS: Request fully APPROVED';
    ELSE
        -- Move to next level
        UPDATE tblapprovalrequests
        SET currentlevel = v_nextlevel
        WHERE requestid = p_requestid;

        p_result := 'SUCCESS: Level ' || v_currentlevel || ' approved, moving to level ' || v_nextlevel;

        -- Notify next level approvers
        INSERT INTO tblnotifications (userid, title, message, notificationtype, priority, reftype, refid)
        SELECT
            u.usercode,
            'Approval needed: ' || r.requestno,
            'Request ' || r.requestno || ' needs your approval (level ' || r.currentlevel || ')',
            'APPROVAL', COALESCE(r.priority, 'NORMAL'),
            'APPROVAL_REQUEST', r.requestid
        FROM tblapprovalrequests r
        JOIN tblusers u ON u.isactive = TRUE AND u.isadmin = TRUE
        WHERE r.requestid = p_requestid
          AND r.currentlevel = v_nextlevel;
    END IF;

    -- Audit log
    INSERT INTO tblapprovalaudit (requestid, eventtype, performedby, ipaddress, useragent, olddata, newdata)
    VALUES (p_requestid, 'APPROVED', p_approverid, p_ipaddress, p_useragent,
            jsonb_build_object('status', 'PENDING', 'level', v_currentlevel),
            jsonb_build_object('status', CASE WHEN v_nextlevel > v_totallevels THEN 'APPROVED' ELSE 'PENDING' END, 'level', v_nextlevel, 'comments', p_comments));
END;
$$;


ALTER PROCEDURE public.approverequest(IN p_requestid bigint, IN p_approverid integer, IN p_comments text, IN p_ipaddress character varying, IN p_useragent character varying, OUT p_result character varying) OWNER TO postgres;

--
-- Name: backupdb(character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.backupdb(IN p_databasename character varying, IN p_backuppath character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Intentionally a no-op. Use pg_dump / pg_basebackup from the host.
    RAISE NOTICE 'Use pg_dump from the OS to back up %.', p_databasename;
END;
$$;


ALTER PROCEDURE public.backupdb(IN p_databasename character varying, IN p_backuppath character varying) OWNER TO postgres;

--
-- Name: cancelrequest(bigint, integer, text, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.cancelrequest(IN p_requestid bigint, IN p_requesterid integer, IN p_reason text, IN p_ipaddress character varying, IN p_useragent character varying, OUT p_result character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_status VARCHAR(20);
    v_requesterid INTEGER;
    v_currentlevel INTEGER;
    v_workflowid INTEGER;
    v_levelid INTEGER;
BEGIN
    SELECT status, requesterid, currentlevel, workflowid
    INTO v_status, v_requesterid, v_currentlevel, v_workflowid
    FROM tblapprovalrequests WHERE requestid = p_requestid;

    IF NOT FOUND THEN
        p_result := 'ERROR: Request not found';
        RETURN;
    END IF;

    IF v_requesterid <> p_requesterid THEN
        p_result := 'ERROR: Only the requester can cancel the request';
        RETURN;
    END IF;

    IF v_status <> 'PENDING' THEN
        p_result := 'ERROR: Only pending requests can be cancelled (current: ' || v_status || ')';
        RETURN;
    END IF;

    SELECT levelid INTO v_levelid FROM tblapprovallevels WHERE workflowid = v_workflowid AND levelnumber = v_currentlevel;

    INSERT INTO tblapprovalactions
        (requestid, levelid, approverid, actiontype, oldstatus, newstatus, fromlevel, tolevel, comments, ipaddress, useragent)
    VALUES (p_requestid, v_levelid, p_requesterid, 'CANCELLED', 'PENDING', 'CANCELLED', v_currentlevel, v_currentlevel, p_reason, p_ipaddress, p_useragent);

    UPDATE tblapprovalrequests
    SET status = 'CANCELLED', completedate = NOW(), completedby = p_requesterid
    WHERE requestid = p_requestid;

    INSERT INTO tblapprovalaudit (requestid, eventtype, performedby, ipaddress, useragent, newdata)
    VALUES (p_requestid, 'CANCELLED', p_requesterid, p_ipaddress, p_useragent,
            jsonb_build_object('status', 'CANCELLED', 'reason', p_reason));

    p_result := 'SUCCESS: Request CANCELLED';
END;
$$;


ALTER PROCEDURE public.cancelrequest(IN p_requestid bigint, IN p_requesterid integer, IN p_reason text, IN p_ipaddress character varying, IN p_useragent character varying, OUT p_result character varying) OWNER TO postgres;

--
-- Name: createsession(integer, character varying, integer, character varying, uuid); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.createsession(IN p_usercode integer, IN p_userid character varying, IN p_bracode integer, IN p_machinename character varying, INOUT p_sessiontoken uuid)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.createsession(IN p_usercode integer, IN p_userid character varying, IN p_bracode integer, IN p_machinename character varying, INOUT p_sessiontoken uuid) OWNER TO postgres;

--
-- Name: delbank(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delbank(IN p_bankcode integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tblbanks SET isactive = false WHERE bankcode = p_bankCode;
END;
$$;


ALTER PROCEDURE public.delbank(IN p_bankcode integer) OWNER TO postgres;

--
-- Name: delbond(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delbond(IN p_bondno integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM tblbondheader
    WHERE bondcode = p_bondno OR bondid = 'B-'||p_bondno;
END;
$$;


ALTER PROCEDURE public.delbond(IN p_bondno integer) OWNER TO postgres;

--
-- Name: delbondbody(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delbondbody(IN p_bondno integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM tblbondbody
    WHERE bondcode IN (
        SELECT bondcode FROM tblbondheader
        WHERE bondcode = p_bondno OR bondid = 'B-'||p_bondno
    );
END;
$$;


ALTER PROCEDURE public.delbondbody(IN p_bondno integer) OWNER TO postgres;

--
-- Name: delcategories(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delcategories(IN p_catcode integer, IN p_bracode integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM tblcategories WHERE categorycode = p_catCode;
END;
$$;


ALTER PROCEDURE public.delcategories(IN p_catcode integer, IN p_bracode integer) OWNER TO postgres;

--
-- Name: delcompany(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delcompany(IN p_bracode integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tblbranches SET isactive = false WHERE branchcode = p_braCode;
END;
$$;


ALTER PROCEDURE public.delcompany(IN p_bracode integer) OWNER TO postgres;

--
-- Name: delcurrency(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delcurrency(IN p_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tblcurrencies SET isactive = false WHERE currencycode = p_id;
END;
$$;


ALTER PROCEDURE public.delcurrency(IN p_id integer) OWNER TO postgres;

--
-- Name: delcustomer(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delcustomer(IN p_custcode integer, IN p_bracode integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tblcustomers SET isactive = false WHERE customercode = p_custCode;
END;
$$;


ALTER PROCEDURE public.delcustomer(IN p_custcode integer, IN p_bracode integer) OWNER TO postgres;

--
-- Name: delegateapproval(bigint, integer, integer, text, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delegateapproval(IN p_requestid bigint, IN p_fromuserid integer, IN p_touserid integer, IN p_reason text, IN p_ipaddress character varying, IN p_useragent character varying, OUT p_result character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_currentlevel INTEGER;
    v_workflowid INTEGER;
    v_levelid INTEGER;
BEGIN
    SELECT currentlevel, workflowid INTO v_currentlevel, v_workflowid
    FROM tblapprovalrequests WHERE requestid = p_requestid AND status = 'PENDING';

    IF NOT FOUND THEN
        p_result := 'ERROR: Pending request not found';
        RETURN;
    END IF;

    SELECT levelid INTO v_levelid FROM tblapprovallevels WHERE workflowid = v_workflowid AND levelnumber = v_currentlevel;

    INSERT INTO tblapprovalactions
        (requestid, levelid, approverid, actiontype, oldstatus, newstatus, fromlevel, tolevel, delegatedto, comments, ipaddress, useragent)
    VALUES (p_requestid, v_levelid, p_fromuserid, 'DELEGATED', 'PENDING', 'PENDING', v_currentlevel, v_currentlevel, p_touserid, p_reason, p_ipaddress, p_useragent);

    -- Notify the delegate
    INSERT INTO tblnotifications (userid, title, message, notificationtype, priority, reftype, refid)
    SELECT p_touserid, 'Delegated approval: ' || r.requestno,
           'Approval for request ' || r.requestno || ' has been delegated to you. Reason: ' || COALESCE(p_reason, 'N/A'),
           'APPROVAL', 'NORMAL', 'APPROVAL_REQUEST', r.requestid
    FROM tblapprovalrequests r WHERE r.requestid = p_requestid;

    p_result := 'SUCCESS: Approval delegated from user ' || p_fromuserid || ' to user ' || p_touserid;
END;
$$;


ALTER PROCEDURE public.delegateapproval(IN p_requestid bigint, IN p_fromuserid integer, IN p_touserid integer, IN p_reason text, IN p_ipaddress character varying, IN p_useragent character varying, OUT p_result character varying) OWNER TO postgres;

--
-- Name: deleteaccount(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.deleteaccount(IN p_acccode integer, IN p_bracode integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM tblaccounts WHERE accountcode = p_accCode;
END;
$$;


ALTER PROCEDURE public.deleteaccount(IN p_acccode integer, IN p_bracode integer) OWNER TO postgres;

--
-- Name: deletebillbondbody(integer, integer, integer, numeric, numeric, integer, integer, integer, timestamp with time zone, numeric); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.deletebillbondbody(IN p_no integer, IN p_optypeno integer, IN p_prodcode integer, IN p_qty numeric, IN p_price numeric, IN p_unitid integer, IN p_storeid integer, IN p_catid integer, IN p_movedate timestamp with time zone, IN p_conversionfactor numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM tbloperationbody
    WHERE (operationcode IN (SELECT operationcode FROM tbloperationheader
                              WHERE operationid = 'OP-'||p_no)
           OR operationcode = p_no)
      AND productcode = p_prodcode;
EXCEPTION WHEN OTHERS THEN NULL;
END;
$$;


ALTER PROCEDURE public.deletebillbondbody(IN p_no integer, IN p_optypeno integer, IN p_prodcode integer, IN p_qty numeric, IN p_price numeric, IN p_unitid integer, IN p_storeid integer, IN p_catid integer, IN p_movedate timestamp with time zone, IN p_conversionfactor numeric) OWNER TO postgres;

--
-- Name: deletebillbondheader(integer, integer, integer, numeric, numeric, integer, integer, integer, timestamp with time zone, numeric); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.deletebillbondheader(IN p_no integer, IN p_optypeno integer, IN p_prodcode integer, IN p_qty numeric, IN p_price numeric, IN p_unitid integer, IN p_storeid integer, IN p_catid integer, IN p_movedate timestamp with time zone, IN p_conversionfactor numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM tbloperationheader
    WHERE operationid = 'OP-'||p_no OR operationcode = p_no;
END;
$$;


ALTER PROCEDURE public.deletebillbondheader(IN p_no integer, IN p_optypeno integer, IN p_prodcode integer, IN p_qty numeric, IN p_price numeric, IN p_unitid integer, IN p_storeid integer, IN p_catid integer, IN p_movedate timestamp with time zone, IN p_conversionfactor numeric) OWNER TO postgres;

--
-- Name: deletebusinessunit(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deletebusinessunit(p_businessunitcode integer, p_edituser integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN UPDATE tbldim_businessunits SET isactive=FALSE, edituser=p_edituser, editdate=CURRENT_TIMESTAMP
 WHERE businessunitcode=p_businessunitcode; END$$;


ALTER FUNCTION public.deletebusinessunit(p_businessunitcode integer, p_edituser integer) OWNER TO postgres;

--
-- Name: deletedepartment(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deletedepartment(p_departmentcode integer, p_edituser integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tbldim_departments
       SET isactive = FALSE, edituser = p_edituser, editdate = CURRENT_TIMESTAMP
     WHERE departmentcode = p_departmentcode;
END$$;


ALTER FUNCTION public.deletedepartment(p_departmentcode integer, p_edituser integer) OWNER TO postgres;

--
-- Name: deletedimensionhierarchy(bigint, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deletedimensionhierarchy(p_hierarchyid bigint, p_edituser integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN UPDATE tbldim_hierarchies
       SET isactive=FALSE, edituser=p_edituser, editdate=CURRENT_TIMESTAMP
     WHERE hierarchyid=p_hierarchyid; END$$;


ALTER FUNCTION public.deletedimensionhierarchy(p_hierarchyid bigint, p_edituser integer) OWNER TO postgres;

--
-- Name: deleteprofitcenter(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deleteprofitcenter(p_profitcentercode integer, p_edituser integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN UPDATE tbldim_profitcenters SET isactive=FALSE, edituser=p_edituser, editdate=CURRENT_TIMESTAMP
 WHERE profitcentercode=p_profitcentercode; END$$;


ALTER FUNCTION public.deleteprofitcenter(p_profitcentercode integer, p_edituser integer) OWNER TO postgres;

--
-- Name: deleteproject(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deleteproject(p_projectcode integer, p_edituser integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN UPDATE tbldim_projects SET isactive=FALSE, edituser=p_edituser, editdate=CURRENT_TIMESTAMP
 WHERE projectcode=p_projectcode; END$$;


ALTER FUNCTION public.deleteproject(p_projectcode integer, p_edituser integer) OWNER TO postgres;

--
-- Name: deletesegment(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deletesegment(p_segmentcode integer, p_edituser integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN UPDATE tbldim_segments SET isactive=FALSE, edituser=p_edituser, editdate=CURRENT_TIMESTAMP
 WHERE segmentcode=p_segmentcode; END$$;


ALTER FUNCTION public.deletesegment(p_segmentcode integer, p_edituser integer) OWNER TO postgres;

--
-- Name: delfund(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delfund(IN p_fundcode integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tblfunds SET isactive = false WHERE fundcode = p_fundCode;
END;
$$;


ALTER PROCEDURE public.delfund(IN p_fundcode integer) OWNER TO postgres;

--
-- Name: deljournalbody(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.deljournalbody(IN p_jno integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM tbljournalbody
    WHERE journalcode IN (
        SELECT journalcode FROM tbljournalheader
        WHERE journalcode = p_jno OR journalid = 'J-'||p_jno
    );
END;
$$;


ALTER PROCEDURE public.deljournalbody(IN p_jno integer) OWNER TO postgres;

--
-- Name: deljournalentry(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.deljournalentry(IN p_jno integer, IN p_bracode integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM tbljournalheader
    WHERE journalcode = p_jno OR journalid = 'J-'||p_jno;
END;
$$;


ALTER PROCEDURE public.deljournalentry(IN p_jno integer, IN p_bracode integer) OWNER TO postgres;

--
-- Name: delprivellages(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delprivellages(IN p_usercode integer, IN p_bracode integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM tblprivileges WHERE usercode = p_usercode;
END;
$$;


ALTER PROCEDURE public.delprivellages(IN p_usercode integer, IN p_bracode integer) OWNER TO postgres;

--
-- Name: delproduct(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delproduct(IN p_prodcode integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tblproducts SET isactive = false WHERE productcode = p_prodCode;
END;
$$;


ALTER PROCEDURE public.delproduct(IN p_prodcode integer) OWNER TO postgres;

--
-- Name: delstore(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delstore(IN p_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM tblstores WHERE storecode = p_id;
END;
$$;


ALTER PROCEDURE public.delstore(IN p_id integer) OWNER TO postgres;

--
-- Name: delsupplier(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delsupplier(IN p_suppcode integer, IN p_bracode integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tblsuppliers SET isactive = false WHERE suppliercode = p_suppCode;
END;
$$;


ALTER PROCEDURE public.delsupplier(IN p_suppcode integer, IN p_bracode integer) OWNER TO postgres;

--
-- Name: delunite(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delunite(IN p_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM tblunits WHERE unitcode = p_id;
END;
$$;


ALTER PROCEDURE public.delunite(IN p_id integer) OWNER TO postgres;

--
-- Name: deluser(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.deluser(IN p_usercode integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM tblusers WHERE usercode = p_usercode;
END;
$$;


ALTER PROCEDURE public.deluser(IN p_usercode integer) OWNER TO postgres;

--
-- Name: dobondposting(bigint, integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.dobondposting(IN p_jno bigint, IN p_poststatus integer, IN p_optype integer, IN p_bracode integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tbljournalheader
       SET isposted = (p_postStatus = 1),
           postedat = CASE WHEN p_postStatus = 1 THEN CURRENT_TIMESTAMP ELSE NULL END
     WHERE journalcode = p_jNo;
END;
$$;


ALTER PROCEDURE public.dobondposting(IN p_jno bigint, IN p_poststatus integer, IN p_optype integer, IN p_bracode integer) OWNER TO postgres;

--
-- Name: editbillbondheader(integer, timestamp with time zone, integer, integer, character varying, integer, integer, integer, integer, timestamp with time zone, integer, integer, integer, numeric, numeric, numeric, numeric, integer, numeric); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.editbillbondheader(IN p_no integer, IN p_opdate timestamp with time zone, IN p_optype integer, IN p_post integer, IN p_note character varying, IN p_custno integer, IN p_salerepno integer, IN p_suppno integer, IN p_useredit integer, IN p_editdate timestamp with time zone, IN p_bracode integer, IN p_paymentmethodid integer, IN p_fundcode integer, IN p_alltotal numeric, IN p_discount numeric, IN p_vat numeric, IN p_nettotal numeric, IN p_jno integer, IN p_salecost numeric)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.editbillbondheader(IN p_no integer, IN p_opdate timestamp with time zone, IN p_optype integer, IN p_post integer, IN p_note character varying, IN p_custno integer, IN p_salerepno integer, IN p_suppno integer, IN p_useredit integer, IN p_editdate timestamp with time zone, IN p_bracode integer, IN p_paymentmethodid integer, IN p_fundcode integer, IN p_alltotal numeric, IN p_discount numeric, IN p_vat numeric, IN p_nettotal numeric, IN p_jno integer, IN p_salecost numeric) OWNER TO postgres;

--
-- Name: editbondheader(integer, date, character varying, integer, integer, integer, integer, numeric, integer, date, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.editbondheader(IN p_bondno integer, IN p_bonddate date, IN p_bondnote character varying, IN p_bondtype integer, IN p_bondpost integer, IN p_accfundcode integer, IN p_accbankcode integer, IN p_amount numeric, IN p_useredit integer, IN p_editdate date, IN p_bracode integer, IN p_jno integer)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.editbondheader(IN p_bondno integer, IN p_bonddate date, IN p_bondnote character varying, IN p_bondtype integer, IN p_bondpost integer, IN p_accfundcode integer, IN p_accbankcode integer, IN p_amount numeric, IN p_useredit integer, IN p_editdate date, IN p_bracode integer, IN p_jno integer) OWNER TO postgres;

--
-- Name: editcategories(integer, character varying, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.editcategories(IN p_id integer, IN p_catname character varying, IN p_storeid integer, IN p_inventorycode integer, IN p_saleno integer, IN p_salereturnno integer, IN p_salevataccno integer, IN p_salediscaccno integer, IN p_saleqtyfreeaccno integer, IN p_salecostaccno integer, IN p_salerevenuseaccno integer, IN p_puraccno integer, IN p_purreturnaccno integer, IN p_purvataccno integer, IN p_purdiscaccno integer, IN p_purqtyfreeaccno integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tblcategories SET categorynamear = p_catName WHERE categorycode = p_id;
END;
$$;


ALTER PROCEDURE public.editcategories(IN p_id integer, IN p_catname character varying, IN p_storeid integer, IN p_inventorycode integer, IN p_saleno integer, IN p_salereturnno integer, IN p_salevataccno integer, IN p_salediscaccno integer, IN p_saleqtyfreeaccno integer, IN p_salecostaccno integer, IN p_salerevenuseaccno integer, IN p_puraccno integer, IN p_purreturnaccno integer, IN p_purvataccno integer, IN p_purdiscaccno integer, IN p_purqtyfreeaccno integer) OWNER TO postgres;

--
-- Name: editcustomers(integer, character varying, numeric, character varying, character varying, bytea, integer, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.editcustomers(IN p_custcode integer, IN p_custname character varying, IN p_debitlimit numeric, IN p_mobile character varying, IN p_email character varying, IN p_img bytea, IN p_bracode integer, IN p_testimage character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tblcustomers
       SET customernamear = p_custName,
           mobile         = p_mobile,
           email          = p_email,
           creditlimit    = p_debitLimit
     WHERE customercode = p_custCode;
END;
$$;


ALTER PROCEDURE public.editcustomers(IN p_custcode integer, IN p_custname character varying, IN p_debitlimit numeric, IN p_mobile character varying, IN p_email character varying, IN p_img bytea, IN p_bracode integer, IN p_testimage character varying) OWNER TO postgres;

--
-- Name: editjournalheader(integer, timestamp with time zone, character varying, integer, integer, numeric, numeric, numeric, integer, timestamp with time zone, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.editjournalheader(IN p_jno integer, IN p_jdate timestamp with time zone, IN p_jnote character varying, IN p_jtype integer, IN p_jpost integer, IN p_accdebitor numeric, IN p_acccreditor numeric, IN p_accbalance numeric, IN p_useredit integer, IN p_editdate timestamp with time zone, IN p_bracode integer, IN p_optype integer)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.editjournalheader(IN p_jno integer, IN p_jdate timestamp with time zone, IN p_jnote character varying, IN p_jtype integer, IN p_jpost integer, IN p_accdebitor numeric, IN p_acccreditor numeric, IN p_accbalance numeric, IN p_useredit integer, IN p_editdate timestamp with time zone, IN p_bracode integer, IN p_optype integer) OWNER TO postgres;

--
-- Name: editprivillages(integer, integer, boolean, boolean, boolean, boolean, boolean, boolean, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.editprivillages(IN p_usercode integer, IN p_windowid integer, IN p_privnew boolean, IN p_privadd boolean, IN p_privedit boolean, IN p_privdel boolean, IN p_privprint boolean, IN p_privdisplay boolean, IN p_bracode integer)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.editprivillages(IN p_usercode integer, IN p_windowid integer, IN p_privnew boolean, IN p_privadd boolean, IN p_privedit boolean, IN p_privdel boolean, IN p_privprint boolean, IN p_privdisplay boolean, IN p_bracode integer) OWNER TO postgres;

--
-- Name: editproduct(integer, character varying, integer, integer, integer, numeric, numeric, bytea, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.editproduct(IN p_prodcode integer, IN p_prodname character varying, IN p_stroreid integer, IN p_catid integer, IN p_unitid integer, IN p_qty numeric, IN p_price numeric, IN p_prodimg bytea, IN p_imagtest character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tblproducts
       SET productnamear = p_prodName,
           categorycode  = p_catID,
           defaultunitcode = p_unitID,
           lastsaleprice = p_price
     WHERE productcode = p_prodCode;
END;
$$;


ALTER PROCEDURE public.editproduct(IN p_prodcode integer, IN p_prodname character varying, IN p_stroreid integer, IN p_catid integer, IN p_unitid integer, IN p_qty numeric, IN p_price numeric, IN p_prodimg bytea, IN p_imagtest character varying) OWNER TO postgres;

--
-- Name: editstore(character varying, character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.editstore(IN p_storename character varying, IN p_storetel character varying, IN p_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tblstores SET storenamear = p_storeName WHERE storecode = p_id;
END;
$$;


ALTER PROCEDURE public.editstore(IN p_storename character varying, IN p_storetel character varying, IN p_id integer) OWNER TO postgres;

--
-- Name: editsuppliers(integer, character varying, character varying, character varying, bytea, character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.editsuppliers(IN p_suppcode integer, IN p_suppname character varying, IN p_mobile character varying, IN p_email character varying, IN p_img bytea, IN p_testimage character varying, IN p_bracode integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tblsuppliers
       SET suppliernamear = p_suppName,
           mobile         = p_mobile,
           email          = p_email
     WHERE suppliercode = p_suppCode;
END;
$$;


ALTER PROCEDURE public.editsuppliers(IN p_suppcode integer, IN p_suppname character varying, IN p_mobile character varying, IN p_email character varying, IN p_img bytea, IN p_testimage character varying, IN p_bracode integer) OWNER TO postgres;

--
-- Name: editunit(integer, character varying, numeric); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.editunit(IN p_id integer, IN p_unitname character varying, IN p_conversionfactor numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tblunits SET unitnamear = p_unitName WHERE unitcode = p_id;
END;
$$;


ALTER PROCEDURE public.editunit(IN p_id integer, IN p_unitname character varying, IN p_conversionfactor numeric) OWNER TO postgres;

--
-- Name: endsession(uuid); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.endsession(IN p_sessiontoken uuid)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tblsessions
       SET isactive  = false,
           logoutat  = CURRENT_TIMESTAMP
     WHERE sessiontoken = p_sessiontoken;
END;
$$;


ALTER PROCEDURE public.endsession(IN p_sessiontoken uuid) OWNER TO postgres;

--
-- Name: expireoldsessions(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.expireoldsessions()
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tblsessions
       SET isactive = false
     WHERE isactive = true
       AND expiresat IS NOT NULL
       AND expiresat < CURRENT_TIMESTAMP;
END;
$$;


ALTER PROCEDURE public.expireoldsessions() OWNER TO postgres;

--
-- Name: fn_add_check_validated(regclass, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_add_check_validated(p_table regclass, p_name text, p_expr text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_conid     oid;
    v_condef    text;
    v_notvalid  boolean;
    v_result    text;
BEGIN
    -- 1. Does it exist already?
    SELECT c.oid, pg_get_constraintdef(c.oid), c.convalidated
      INTO v_conid, v_condef, v_notvalid
      FROM pg_constraint c
     WHERE c.conrelid = p_table
       AND c.conname  = p_name;

    IF v_conid IS NOT NULL THEN
        -- Exists. Is it NOT VALID?
        IF v_notvalid = false THEN
            RETURN format('[..] %s already present and validated.', p_name);
        ELSE
            EXECUTE format('ALTER TABLE %s VALIDATE CONSTRAINT %I', p_table, p_name);
            RETURN format('[OK] %s was NOT VALID; validated now.', p_name);
        END IF;
    END IF;

    -- 2. Add as NOT VALID (no full-table lock for write)
    EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %I CHECK (%s) NOT VALID', p_table, p_name, p_expr);
    v_result := format('[OK] %s added as NOT VALID.', p_name);

    -- 3. VALIDATE (only acquires SHARE UPDATE EXCLUSIVE — reads continue)
    BEGIN
        EXECUTE format('ALTER TABLE %s VALIDATE CONSTRAINT %I', p_table, p_name);
        v_result := v_result || ' Validated.';
    EXCEPTION WHEN check_violation THEN
        v_result := v_result || ' VALIDATION FAILED — data violates constraint.';
        RAISE;
    END;
    RETURN v_result;
END
$$;


ALTER FUNCTION public.fn_add_check_validated(p_table regclass, p_name text, p_expr text) OWNER TO postgres;

--
-- Name: fn_add_exclude(regclass, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_add_exclude(p_table regclass, p_name text, p_def text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_exists boolean;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM pg_constraint
         WHERE conrelid = p_table AND conname = p_name
    ) INTO v_exists;

    IF v_exists THEN
        RETURN format('[..] %s already present.', p_name);
    END IF;

    EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %I %s', p_table, p_name, p_def);
    RETURN format('[OK] %s added.', p_name);
END
$$;


ALTER FUNCTION public.fn_add_exclude(p_table regclass, p_name text, p_def text) OWNER TO postgres;

--
-- Name: fn_add_index_concurrent(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_add_index_concurrent(p_index_name text, p_index_def text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_exists   boolean;
    v_valid    boolean;
    v_result   text;
BEGIN
    -- 1. Does it exist?
    SELECT EXISTS (
        SELECT 1 FROM pg_class c
         WHERE c.relkind = 'i' AND c.relname = p_index_name
    ) INTO v_exists;

    IF v_exists THEN
        SELECT c.relisvalid INTO v_valid
          FROM pg_class c WHERE c.relname = p_index_name;
        IF v_valid THEN
            RETURN format('[..] %s already exists and is valid.', p_index_name);
        ELSE
            EXECUTE format('DROP INDEX IF EXISTS public.%I', p_index_name);
            v_result := format('[OK] %s was invalid; dropped before rebuild.', p_index_name);
        END IF;
    ELSE
        v_result := format('[OK] %s created.', p_index_name);
    END IF;

    -- 2. Create concurrently
    EXECUTE p_index_def;
    RETURN v_result;
END
$$;


ALTER FUNCTION public.fn_add_index_concurrent(p_index_name text, p_index_def text) OWNER TO postgres;

--
-- Name: fn_audit_trigger(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_audit_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.fn_audit_trigger() OWNER TO postgres;

--
-- Name: fn_auto_submit_for_approval(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_auto_submit_for_approval() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.fn_auto_submit_for_approval() OWNER TO postgres;

--
-- Name: fn_block_unapproved_posting(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_block_unapproved_posting() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.fn_block_unapproved_posting() OWNER TO postgres;

--
-- Name: fn_calculatevat(numeric, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_calculatevat(p_amount numeric, p_vat_percent numeric DEFAULT 15) RETURNS numeric
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    RETURN ROUND(p_amount * p_vat_percent / 100, 4);
END;
$$;


ALTER FUNCTION public.fn_calculatevat(p_amount numeric, p_vat_percent numeric) OWNER TO postgres;

--
-- Name: fn_dim_updateprojectactual(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_dim_updateprojectactual() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.projectcode IS NOT NULL THEN
        UPDATE tbldim_projects
           SET actualamount = COALESCE(actualamount,0)
                             + COALESCE(NEW.debitlocal, NEW.debit, 0)
                             - COALESCE(NEW.creditlocal, NEW.credit, 0),
               editdate = CURRENT_TIMESTAMP
         WHERE projectcode = NEW.projectcode;
    END IF;
    RETURN NEW;
END$$;


ALTER FUNCTION public.fn_dim_updateprojectactual() OWNER TO postgres;

--
-- Name: fn_dim_validateondimcolumns(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_dim_validateondimcolumns() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE v_bad TEXT;
BEGIN
    v_bad := validateAllDimensions(NEW.departmentcode, NEW.projectcode,
                                   NEW.businessunitcode, NEW.segmentcode,
                                   NEW.profitcentercode, NEW.costcentercode);
    IF v_bad IS NOT NULL THEN
        RAISE EXCEPTION 'Invalid or inactive dimension(s) referenced: %', v_bad
            USING ERRCODE = '23514';
    END IF;
    RETURN NEW;
END$$;


ALTER FUNCTION public.fn_dim_validateondimcolumns() OWNER TO postgres;

--
-- Name: fn_g10_approval_action_audit_fn(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_g10_approval_action_audit_fn() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    INSERT INTO public.tblaudi_security (event_type, event_payload, actor_role)
    VALUES (
        'APPROVAL_ACTION',
        jsonb_build_object(
            'actionid',      NEW.actionid,
            'requestid',     NEW.requestid,
            'levelid',       NEW.levelid,
            'approverid',    NEW.approverid,
            'actiontype',    NEW.actiontype,
            'oldstatus',     NEW.oldstatus,
            'newstatus',     NEW.newstatus,
            'fromlevel',     NEW.fromlevel,
            'tolevel',       NEW.tolevel,
            'delegatedto',   NEW.delegatedto,
            'ipaddress',     NEW.ipaddress
        ),
        current_user
    );
    RETURN NEW;
EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'trg_g10_approval_action_audit failed for actionid=%: %',
                 NEW.actionid, SQLERRM;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_g10_approval_action_audit_fn() OWNER TO postgres;

--
-- Name: fn_g10_approval_compute_status(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_g10_approval_compute_status(p_requestid bigint) RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_current_status   varchar(20);
    v_latest_action    varchar(20);
    v_rejected_count   int;
    v_approved_count   int;
    v_total_levels     int;
    v_required_approved int;
    v_approval_complete boolean;
BEGIN
    -- 1. Defensive: read current status (always present on the row)
    SELECT status, totallevels
      INTO v_current_status, v_total_levels
      FROM public.tblapprovalrequests
     WHERE requestid = p_requestid;

    IF v_current_status IS NULL THEN
        RETURN NULL;
    END IF;

    -- 2. Terminal states: never recompute
    IF v_current_status IN ('APPROVED', 'REJECTED', 'CANCELLED', 'EXPIRED') THEN
        RETURN v_current_status;
    END IF;

    -- 3. Most recent action
    SELECT actiontype INTO v_latest_action
      FROM public.tblapprovalactions
     WHERE requestid = p_requestid
     ORDER BY actiondate DESC
     LIMIT 1;

    -- 4. Counts
    SELECT
        count(*) FILTER (WHERE actiontype = 'APPROVED'),
        count(*) FILTER (WHERE actiontype = 'REJECTED')
      INTO v_approved_count, v_rejected_count
      FROM public.tblapprovalactions
     WHERE requestid = p_requestid;

    -- 5. Use the existing function to check completion
    v_approval_complete := public.isapprovalcomplete(p_requestid);

    -- 6. Compute
    IF v_rejected_count > 0 THEN
        RETURN 'REJECTED';
    END IF;

    IF v_approval_complete THEN
        RETURN 'APPROVED';
    END IF;

    -- From PENDING, any action moves to IN_REVIEW
    IF v_current_status = 'PENDING' AND v_latest_action IS NOT NULL THEN
        RETURN 'IN_REVIEW';
    END IF;

    -- Default: keep current status
    RETURN v_current_status;
END;
$$;


ALTER FUNCTION public.fn_g10_approval_compute_status(p_requestid bigint) OWNER TO postgres;

--
-- Name: fn_g10_approval_request_status_update_fn(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_g10_approval_request_status_update_fn() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_current_status  varchar(20);
    v_new_status      varchar(20);
    v_completedate    timestamp;
BEGIN
    SELECT status INTO v_current_status
      FROM public.tblapprovalrequests
     WHERE requestid = NEW.requestid;

    IF v_current_status IS NULL THEN
        RETURN NEW;
    END IF;

    v_new_status := public.fn_g10_approval_compute_status(NEW.requestid);

    IF v_new_status IS NULL OR v_new_status = v_current_status THEN
        RETURN NEW;
    END IF;

    IF NOT public.fn_g10_approval_valid_transition(v_current_status, v_new_status) THEN
        RAISE WARNING 'trg_g10_approval_request_status_update: invalid transition %->% for requestid=%',
                     v_current_status, v_new_status, NEW.requestid;
        RETURN NEW;
    END IF;

    IF v_new_status IN ('APPROVED', 'REJECTED', 'CANCELLED', 'EXPIRED') THEN
        v_completedate := now();
    ELSE
        v_completedate := NULL;
    END IF;

    UPDATE public.tblapprovalrequests
       SET status       = v_new_status,
           completedate = COALESCE(completedate, v_completedate),
           completedby  = CASE
                               WHEN v_new_status IN ('APPROVED', 'REJECTED', 'CANCELLED', 'EXPIRED')
                                   THEN NEW.approverid
                               ELSE completedby
                           END
     WHERE requestid = NEW.requestid;

    RETURN NEW;
EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'trg_g10_approval_request_status_update failed for requestid=%: %',
                 NEW.requestid, SQLERRM;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_g10_approval_request_status_update_fn() OWNER TO postgres;

--
-- Name: fn_g10_approval_signature_part_a(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_g10_approval_signature_part_a() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$ SELECT 'GAP10-APPROVAL-PART-A-2026-06-11-v1'::text $$;


ALTER FUNCTION public.fn_g10_approval_signature_part_a() OWNER TO postgres;

--
-- Name: fn_g10_approval_signature_part_b(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_g10_approval_signature_part_b() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$ SELECT 'GAP10-APPROVAL-PART-B-2026-06-11-v1'::text $$;


ALTER FUNCTION public.fn_g10_approval_signature_part_b() OWNER TO postgres;

--
-- Name: fn_g10_approval_signature_part_c(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_g10_approval_signature_part_c() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$ SELECT 'GAP10-APPROVAL-PART-C-2026-06-11-v1'::text $$;


ALTER FUNCTION public.fn_g10_approval_signature_part_c() OWNER TO postgres;

--
-- Name: fn_g10_approval_valid_transition(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_g10_approval_valid_transition(p_old_status text, p_new_status text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    -- Identity: no-op transitions are always valid (trigger may fire on no-op)
    IF p_old_status = p_new_status THEN
        RETURN true;
    END IF;

    -- Allow NULL -> X (initial set) for any valid X
    IF p_old_status IS NULL THEN
        RETURN p_new_status IN ('PENDING', 'IN_REVIEW');
    END IF;

    -- From PENDING
    IF p_old_status = 'PENDING' THEN
        RETURN p_new_status IN ('IN_REVIEW', 'CANCELLED', 'EXPIRED');
    END IF;

    -- From IN_REVIEW (the active state machine)
    IF p_old_status = 'IN_REVIEW' THEN
        RETURN p_new_status IN ('APPROVED', 'REJECTED', 'CANCELLED', 'EXPIRED', 'PENDING');
        -- 'PENDING' is reachable from IN_REVIEW via RETURNED action
    END IF;

    -- Terminal states: nothing else is allowed
    IF p_old_status IN ('APPROVED', 'REJECTED', 'CANCELLED', 'EXPIRED') THEN
        RETURN false;
    END IF;

    -- Unknown old status
    RETURN false;
END;
$$;


ALTER FUNCTION public.fn_g10_approval_valid_transition(p_old_status text, p_new_status text) OWNER TO postgres;

--
-- Name: fn_g2_security_signature(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_g2_security_signature() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$ SELECT 'GAP2-SECURITY-2026-06-10-v1'::text $$;


ALTER FUNCTION public.fn_g2_security_signature() OWNER TO postgres;

--
-- Name: fn_g3_monitoring_signature(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_g3_monitoring_signature() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$ SELECT 'GAP3-MONITORING-2026-06-10-v1'::text $$;


ALTER FUNCTION public.fn_g3_monitoring_signature() OWNER TO postgres;

--
-- Name: fn_g4_constraints_signature_part_a(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_g4_constraints_signature_part_a() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$ SELECT 'GAP4-CONSTRAINTS-PART-A-2026-06-11-v1'::text $$;


ALTER FUNCTION public.fn_g4_constraints_signature_part_a() OWNER TO postgres;

--
-- Name: fn_g4_constraints_signature_part_b(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_g4_constraints_signature_part_b() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$ SELECT 'GAP4-CONSTRAINTS-PART-B-2026-06-11-v1'::text $$;


ALTER FUNCTION public.fn_g4_constraints_signature_part_b() OWNER TO postgres;

--
-- Name: fn_g4_constraints_signature_part_c(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_g4_constraints_signature_part_c() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$ SELECT 'GAP4-CONSTRAINTS-PART-C-2026-06-11-v1'::text $$;


ALTER FUNCTION public.fn_g4_constraints_signature_part_c() OWNER TO postgres;

--
-- Name: fn_g5_indexes_signature_part_a(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_g5_indexes_signature_part_a() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$ SELECT 'GAP5-INDEXES-PART-A-2026-06-11-v1'::text $$;


ALTER FUNCTION public.fn_g5_indexes_signature_part_a() OWNER TO postgres;

--
-- Name: fn_g5_indexes_signature_part_b(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_g5_indexes_signature_part_b() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$ SELECT 'GAP5-INDEXES-PART-B-2026-06-11-v1'::text $$;


ALTER FUNCTION public.fn_g5_indexes_signature_part_b() OWNER TO postgres;

--
-- Name: fn_g7_mv_signature_part_a(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_g7_mv_signature_part_a() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$ SELECT 'GAP7-MV-PART-A-2026-06-11-v1'::text $$;


ALTER FUNCTION public.fn_g7_mv_signature_part_a() OWNER TO postgres;

--
-- Name: fn_g7_mv_signature_part_b(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_g7_mv_signature_part_b() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$ SELECT 'GAP7-MV-PART-B-2026-06-11-v1'::text $$;


ALTER FUNCTION public.fn_g7_mv_signature_part_b() OWNER TO postgres;

--
-- Name: fn_generateoperationno(character varying, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_generateoperationno(p_operation_type character varying, p_operation_code bigint) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    v_prefix VARCHAR(15);
BEGIN
    v_prefix := CASE p_operation_type
        WHEN 'SALE'           THEN 'INV'
        WHEN 'PURCHASE'       THEN 'PINV'
        WHEN 'SALE_RETURN'    THEN 'SRTN'
        WHEN 'PURCHASE_RETURN' THEN 'PRTN'
        ELSE 'DOC'
    END || '-' || TO_CHAR(CURRENT_TIMESTAMP, 'YYMM') || '-';

    RETURN v_prefix || LPAD(p_operation_code::TEXT, 5, '0');
END;
$$;


ALTER FUNCTION public.fn_generateoperationno(p_operation_type character varying, p_operation_code bigint) OWNER TO postgres;

--
-- Name: fn_get_slow_queries(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_get_slow_queries(min_ms integer DEFAULT 1000, max_rows integer DEFAULT 50) RETURNS TABLE(query_snippet text, call_count bigint, mean_time_ms numeric, max_time_ms numeric, total_time_s numeric, total_rows bigint)
    LANGUAGE sql STABLE
    AS $$
    SELECT
        substring(s.query, 1, 200)                                  AS query_snippet,
        s.calls                                                     AS call_count,
        round(s.mean_exec_time::numeric, 2)                         AS mean_time_ms,
        round(s.max_exec_time::numeric, 2)                          AS max_time_ms,
        round((s.total_exec_time / 1000.0)::numeric, 2)             AS total_time_s,
        s.rows                                                      AS total_rows
    FROM pg_stat_statements s
    WHERE s.calls > 0
      AND s.mean_exec_time >= min_ms
    ORDER BY s.mean_exec_time DESC
    LIMIT max_rows;
$$;


ALTER FUNCTION public.fn_get_slow_queries(min_ms integer, max_rows integer) OWNER TO postgres;

--
-- Name: fn_getaccountbalance(integer, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_getaccountbalance(p_account_code integer, p_as_of_date timestamp without time zone DEFAULT NULL::timestamp without time zone) RETURNS numeric
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_debit  NUMERIC(18,4) := 0;
    v_credit NUMERIC(18,4) := 0;
    v_date   TIMESTAMP;
BEGIN
    v_date := COALESCE(p_as_of_date, CURRENT_TIMESTAMP);

    -- Sum from Journal (uses Debit/Credit columns as defined in DDL)
    SELECT COALESCE(SUM(jb.Debit), 0), COALESCE(SUM(jb.Credit), 0)
      INTO v_debit, v_credit
      FROM public.tblJournalBody jb
      JOIN public.tblJournalHeader jh ON jb.JournalCode = jh.JournalCode
     WHERE jb.AccountCode = p_account_code
       AND jh.OperationDate <= v_date
       AND jh.IsPosted = TRUE;

    -- Sum from Bond
    SELECT v_debit  + COALESCE(SUM(bb.Debit),  0),
           v_credit + COALESCE(SUM(bb.Credit), 0)
      INTO v_debit, v_credit
      FROM public.tblBondBody bb
      JOIN public.tblBondHeader bh ON bb.BondCode = bh.BondCode
     WHERE bb.AccountCode = p_account_code
       AND bh.BondDate <= v_date
       AND bh.IsPosted = TRUE;

    RETURN v_debit - v_credit;
END;
$$;


ALTER FUNCTION public.fn_getaccountbalance(p_account_code integer, p_as_of_date timestamp without time zone) OWNER TO postgres;

--
-- Name: fn_getaccountfullpath(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_getaccountfullpath(p_account_code integer) RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_path TEXT := '';
    v_current_code INT := p_account_code;
    v_account_name VARCHAR(400);
BEGIN
    WHILE v_current_code IS NOT NULL LOOP
        SELECT AccountNameAr, ParentAccountCode
          INTO v_account_name, v_current_code
          FROM public.tblAccounts
         WHERE AccountCode = v_current_code;

        IF v_path = '' THEN
            v_path := v_account_name;
        ELSE
            v_path := v_account_name || ' > ' || v_path;
        END IF;
    END LOOP;

    RETURN v_path;
END;
$$;


ALTER FUNCTION public.fn_getaccountfullpath(p_account_code integer) OWNER TO postgres;

--
-- Name: fn_getcategoryfullpath(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_getcategoryfullpath(p_category_code integer) RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_path TEXT := '';
    v_current_code INT := p_category_code;
    v_category_name VARCHAR(200);
BEGIN
    WHILE v_current_code IS NOT NULL LOOP
        SELECT CategoryNameAr, ParentCategoryCode
          INTO v_category_name, v_current_code
          FROM public.tblCategories
         WHERE CategoryCode = v_current_code;

        IF v_path = '' THEN
            v_path := v_category_name;
        ELSE
            v_path := v_category_name || ' > ' || v_path;
        END IF;
    END LOOP;

    RETURN v_path;
END;
$$;


ALTER FUNCTION public.fn_getcategoryfullpath(p_category_code integer) OWNER TO postgres;

--
-- Name: fn_getcustomerbalance(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_getcustomerbalance(p_customer_code integer) RETURNS numeric
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_balance NUMERIC(18,4) := 0;
BEGIN
    SELECT COALESCE(Balance, 0) INTO v_balance
      FROM public.tblCustomers
     WHERE CustomerCode = p_customer_code;
    RETURN v_balance;
END;
$$;


ALTER FUNCTION public.fn_getcustomerbalance(p_customer_code integer) OWNER TO postgres;

--
-- Name: fn_getproductstock(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_getproductstock(p_product_code integer, p_store_code integer DEFAULT NULL::integer) RETURNS numeric
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_stock NUMERIC(18,4) := 0;
BEGIN
    IF p_store_code IS NULL THEN
        SELECT COALESCE(SUM(QtyOnHand), 0) INTO v_stock
          FROM public.tblStoreProducts
         WHERE ProductCode = p_product_code AND IsActive = TRUE;
    ELSE
        SELECT COALESCE(SUM(QtyOnHand), 0) INTO v_stock
          FROM public.tblStoreProducts
         WHERE ProductCode = p_product_code
           AND StoreCode   = p_store_code
           AND IsActive    = TRUE;
    END IF;

    RETURN v_stock;
END;
$$;


ALTER FUNCTION public.fn_getproductstock(p_product_code integer, p_store_code integer) OWNER TO postgres;

--
-- Name: fn_getsupplierbalance(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_getsupplierbalance(p_supplier_code integer) RETURNS numeric
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_balance NUMERIC(18,4) := 0;
BEGIN
    SELECT COALESCE(Balance, 0) INTO v_balance
      FROM public.tblSuppliers
     WHERE SupplierCode = p_supplier_code;
    RETURN v_balance;
END;
$$;


ALTER FUNCTION public.fn_getsupplierbalance(p_supplier_code integer) OWNER TO postgres;

--
-- Name: fn_isuserhasprivilege(integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_isuserhasprivilege(p_user_code integer, p_window_code character varying, p_privilege_type character varying) RETURNS boolean
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_has BOOLEAN := FALSE;
BEGIN
    -- Admin users have all privileges
    IF EXISTS (SELECT 1 FROM public.tblUsers WHERE UserCode = p_user_code AND IsAdmin = TRUE) THEN
        RETURN TRUE;
    END IF;

    -- Check direct privilege via UserRole -> Privileges
    SELECT CASE p_privilege_type
              WHEN 'CanDisplay' THEN p.CanDisplay
              WHEN 'CanAdd'     THEN p.CanAdd
              WHEN 'CanEdit'    THEN p.CanEdit
              WHEN 'CanDelete'  THEN p.CanDelete
              WHEN 'CanPrint'   THEN p.CanPrint
              WHEN 'CanExport'  THEN p.CanExport
              WHEN 'CanApprove' THEN p.CanApprove
              WHEN 'CanPost'    THEN p.CanPost
              ELSE FALSE
           END
      INTO v_has
      FROM public.tblPrivileges p
      JOIN public.tblWindows w              ON p.WindowID = w.WindowID
      JOIN public.tblUserRoleAssignments ura ON p.UserCode = ura.UserCode
     WHERE ura.UserCode = p_user_code
       AND w.WindowCode = p_window_code
     LIMIT 1;

    RETURN COALESCE(v_has, FALSE);
END;
$$;


ALTER FUNCTION public.fn_isuserhasprivilege(p_user_code integer, p_window_code character varying, p_privilege_type character varying) OWNER TO postgres;

--
-- Name: fn_pii_decrypt(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_pii_decrypt(ciphertext bytea) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    k text;
BEGIN
    IF ciphertext IS NULL THEN
        RETURN NULL;
    END IF;
    k := current_setting('app.pii_key', true);
    IF k IS NULL OR length(k) < 16 THEN
        RAISE EXCEPTION 'app.pii_key is not set (or too short). '
                        'Set it via: SET LOCAL app.pii_key = ''<>=16 chars>''';
    END IF;
    RETURN pgp_sym_decrypt(ciphertext, k);
EXCEPTION WHEN OTHERS THEN
    -- Wrong key / corrupted ciphertext → return NULL, do not leak error.
    RETURN NULL;
END
$$;


ALTER FUNCTION public.fn_pii_decrypt(ciphertext bytea) OWNER TO postgres;

--
-- Name: fn_pii_encrypt(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_pii_encrypt(plaintext text) RETURNS bytea
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    k text;
BEGIN
    IF plaintext IS NULL THEN
        RETURN NULL;
    END IF;
    k := current_setting('app.pii_key', true);
    IF k IS NULL OR length(k) < 16 THEN
        RAISE EXCEPTION 'app.pii_key is not set (or too short). '
                        'Set it via: SET LOCAL app.pii_key = ''<>=16 chars>''';
    END IF;
    RETURN pgp_sym_encrypt(plaintext, k, 'compress-algo=1, cipher-algo=aes256');
END
$$;


ALTER FUNCTION public.fn_pii_encrypt(plaintext text) OWNER TO postgres;

--
-- Name: fn_suggest_indexes(bigint, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_suggest_indexes(min_seq_scans bigint DEFAULT 1000, max_idx_pct numeric DEFAULT 50.0) RETURNS TABLE(table_name text, seq_scan_count bigint, idx_scan_count bigint, index_scan_pct numeric, approx_row_count bigint, table_size text, recommendation text)
    LANGUAGE sql STABLE
    AS $$
    SELECT
        s.schemaname || '.' || s.relname,
        s.seq_scan,
        s.idx_scan,
        CASE
            WHEN s.seq_scan + s.idx_scan = 0 THEN 0
            ELSE round((s.idx_scan::numeric /
                       NULLIF(s.seq_scan + s.idx_scan, 0)) * 100, 2)
        END,
        s.n_live_tup,
        pg_size_pretty(pg_relation_size(s.relid)),
        'Consider adding a composite or partial index on the most-filtered columns'
    FROM pg_stat_user_tables s
    WHERE s.seq_scan >= min_seq_scans
      AND (
            s.seq_scan + s.idx_scan = 0
            OR (s.idx_scan::numeric / NULLIF(s.seq_scan + s.idx_scan, 0)) * 100 < max_idx_pct
          )
    ORDER BY s.seq_scan DESC
    LIMIT 30;
$$;


ALTER FUNCTION public.fn_suggest_indexes(min_seq_scans bigint, max_idx_pct numeric) OWNER TO postgres;

--
-- Name: forceapprovesource(character varying, bigint, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.forceapprovesource(p_sourcetype character varying, p_sourceid bigint, p_approverid integer, p_comments text) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.forceapprovesource(p_sourcetype character varying, p_sourceid bigint, p_approverid integer, p_comments text) OWNER TO postgres;

--
-- Name: getaccfundcode(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getaccfundcode(p_fundname character varying) RETURNS TABLE(fundcode integer, fundnamear character varying)
    LANGUAGE sql
    AS $$
    SELECT fundcode, fundnamear FROM tblfunds WHERE fundnamear = p_fundname OR fundnameen = p_fundname;
$$;


ALTER FUNCTION public.getaccfundcode(p_fundname character varying) OWNER TO postgres;

--
-- Name: getaccnomax(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getaccnomax(p_accparentcode integer, p_bracode integer) RETURNS TABLE(maxcode bigint)
    LANGUAGE sql
    AS $$
    SELECT COALESCE(MAX(accountcode),0)::bigint AS maxcode
    FROM tblaccounts
    WHERE parentaccountcode = p_accparentcode;
$$;


ALTER FUNCTION public.getaccnomax(p_accparentcode integer, p_bracode integer) OWNER TO postgres;

--
-- Name: getaccountdata(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getaccountdata(p_bracode integer, p_acccode integer) RETURNS TABLE(accountcode integer, accountid character varying, accountnamear character varying, accountnameen character varying, accounttype character varying, accountlevel integer, parentaccountcode integer, openingbalance numeric, currentbalance numeric)
    LANGUAGE sql
    AS $$
    SELECT accountcode, accountid, accountnamear, accountnameen,
           accounttype, accountlevel, parentaccountcode,
           openingbalance, currentbalance
    FROM tblaccounts
    WHERE accountcode = p_acccode;
$$;


ALTER FUNCTION public.getaccountdata(p_bracode integer, p_acccode integer) OWNER TO postgres;

--
-- Name: getaccountsforaccparent(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getaccountsforaccparent(p_acccode integer, p_bracode integer) RETURNS TABLE(accountcode integer, accountnamear character varying, accountlevel integer)
    LANGUAGE sql
    AS $$
    SELECT accountcode, accountnamear, accountlevel
    FROM tblaccounts
    WHERE parentaccountcode = p_acccode
    ORDER BY accountid;
$$;


ALTER FUNCTION public.getaccountsforaccparent(p_acccode integer, p_bracode integer) OWNER TO postgres;

--
-- Name: getaccountsheetreport(integer, date, date, numeric, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getaccountsheetreport(p_acccode integer, p_fromdate date, p_todate date, p_exchangerate numeric, p_optype character varying) RETURNS TABLE(journaldate date, referenceno character varying, description character varying, debitor numeric, creditor numeric, balance numeric)
    LANGUAGE sql
    AS $$
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
$$;


ALTER FUNCTION public.getaccountsheetreport(p_acccode integer, p_fromdate date, p_todate date, p_exchangerate numeric, p_optype character varying) OWNER TO postgres;

--
-- Name: getaccountstatement(integer, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getaccountstatement(p_accountcode integer, p_fromdate date, p_todate date) RETURNS TABLE(journalcode bigint, journalid character varying, journaldate date, description character varying, debit numeric, credit numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT h.journalcode, h.journalid, h.journaldate, h.description,
           0, h.totalamount
    FROM tbljournalheader h
    WHERE h.journaldate BETWEEN p_fromdate AND p_todate
      AND (p_accountcode = 0 OR h.currencycode = p_accountcode)
    ORDER BY h.journaldate, h.journalcode;
END;
$$;


ALTER FUNCTION public.getaccountstatement(p_accountcode integer, p_fromdate date, p_todate date) OWNER TO postgres;

--
-- Name: getallaccounts(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallaccounts(p_bracode integer) RETURNS TABLE(accountcode integer, accountid character varying, accountnamear character varying, accountnameen character varying, accounttype character varying, accountlevel integer, parentaccountcode integer, openingbalance numeric, currentbalance numeric, isactive boolean)
    LANGUAGE sql
    AS $$
    SELECT accountcode, accountid, accountnamear, accountnameen,
           accounttype, accountlevel, parentaccountcode,
           openingbalance, currentbalance, isactive
    FROM tblaccounts
    ORDER BY accountid;
$$;


ALTER FUNCTION public.getallaccounts(p_bracode integer) OWNER TO postgres;

--
-- Name: getallacctypes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallacctypes() RETURNS TABLE(accounttype character varying)
    LANGUAGE sql
    AS $$
    SELECT DISTINCT accounttype FROM tblaccounts ORDER BY accounttype;
$$;


ALTER FUNCTION public.getallacctypes() OWNER TO postgres;

--
-- Name: getallbanks(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallbanks() RETURNS TABLE(bankcode integer, bankid character varying, banknamear character varying, banknameen character varying, isactive boolean)
    LANGUAGE sql
    AS $$
    SELECT bankcode, bankid, banknamear, banknameen, isactive
    FROM tblbanks WHERE isactive = true ORDER BY banknamear;
$$;


ALTER FUNCTION public.getallbanks() OWNER TO postgres;

--
-- Name: getallbranches(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallbranches() RETURNS TABLE(branchcode integer, branchid character varying, branchnamear character varying, branchnameen character varying, address character varying, phone character varying, email character varying, isactive boolean)
    LANGUAGE sql
    AS $$
    SELECT branchcode, branchid, branchnamear, branchnameen, address, phone, email, isactive
    FROM tblbranches
    WHERE isactive = true
    ORDER BY branchnamear;
$$;


ALTER FUNCTION public.getallbranches() OWNER TO postgres;

--
-- Name: getallbrausers(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallbrausers(p_bracode integer) RETURNS TABLE(usercode integer, userid character varying, usernamear character varying)
    LANGUAGE sql
    AS $$
    SELECT usercode, userid, usernamear
    FROM tblusers
    WHERE (p_bracode = 0 OR branchcode = p_bracode OR branchcode IS NULL)
    ORDER BY usernamear;
$$;


ALTER FUNCTION public.getallbrausers(p_bracode integer) OWNER TO postgres;

--
-- Name: getallbusinessunits(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallbusinessunits() RETURNS TABLE(businessunitcode integer, businessunitid character varying, namear character varying, nameen character varying, parentbusinessunitcode integer, parentname character varying, isactive boolean, notes text)
    LANGUAGE sql STABLE
    AS $$
    SELECT b.businessunitcode, b.businessunitid, b.namear, b.nameen,
           b.parentbusinessunitcode, p.namear, b.isactive, b.notes
      FROM tbldim_businessunits b
      LEFT JOIN tbldim_businessunits p ON p.businessunitcode=b.parentbusinessunitcode
     ORDER BY b.businessunitcode;
$$;


ALTER FUNCTION public.getallbusinessunits() OWNER TO postgres;

--
-- Name: getallcurrencies(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallcurrencies() RETURNS TABLE(currencycode integer, currencyid character varying, currencynamear character varying, currencynameen character varying, symbol character varying, exchangerate numeric)
    LANGUAGE sql
    AS $$
    SELECT currencycode, currencyid, currencynamear, currencynameen, symbol, exchangerate
    FROM tblcurrencies WHERE isactive = true ORDER BY currencynamear;
$$;


ALTER FUNCTION public.getallcurrencies() OWNER TO postgres;

--
-- Name: getallcurrenciestypes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallcurrenciestypes() RETURNS TABLE(currencycode integer, currencynamear character varying)
    LANGUAGE sql
    AS $$
    SELECT currencycode, currencynamear FROM tblcurrencies WHERE isactive = true ORDER BY currencynamear;
$$;


ALTER FUNCTION public.getallcurrenciestypes() OWNER TO postgres;

--
-- Name: getallcustomers(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallcustomers(p_bracode integer) RETURNS TABLE(customercode integer, customerid character varying, customernamear character varying, customernameen character varying, mobile character varying, email character varying, creditlimit numeric, balance numeric, isactive boolean)
    LANGUAGE sql
    AS $$
    SELECT customercode, customerid, customernamear, customernameen, mobile, email,
           creditlimit, balance, isactive
    FROM tblcustomers
    WHERE isactive = true
    ORDER BY customernamear;
$$;


ALTER FUNCTION public.getallcustomers(p_bracode integer) OWNER TO postgres;

--
-- Name: getallcutegories(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallcutegories() RETURNS TABLE(categorycode integer, categoryid character varying, categorynamear character varying, categorynameen character varying)
    LANGUAGE sql
    AS $$
    SELECT categorycode, categoryid, categorynamear, categorynameen
    FROM tblcategories WHERE isactive = true ORDER BY categorynamear;
$$;


ALTER FUNCTION public.getallcutegories() OWNER TO postgres;

--
-- Name: getalldepartments(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getalldepartments() RETURNS TABLE(departmentcode integer, departmentid character varying, namear character varying, nameen character varying, parentdepartmentcode integer, parentname character varying, managerusercode integer, managerusernamear character varying, isactive boolean, effectivedate date, enddate date, notes text, adduser integer, adddate timestamp without time zone, edituser integer, editdate timestamp without time zone)
    LANGUAGE sql STABLE
    AS $$
    SELECT d.departmentcode, d.departmentid, d.namear, d.nameen,
           d.parentdepartmentcode, p.namear,
           d.managerusercode, u.usernamear,
           d.isactive, d.effectivedate, d.enddate, d.notes,
           d.adduser, d.adddate, d.edituser, d.editdate
      FROM tbldim_departments d
      LEFT JOIN tbldim_departments p ON p.departmentcode = d.parentdepartmentcode
      LEFT JOIN tblusers u ON u.usercode = d.managerusercode
     ORDER BY d.departmentcode;
$$;


ALTER FUNCTION public.getalldepartments() OWNER TO postgres;

--
-- Name: getalldimensionhierarchies(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getalldimensionhierarchies() RETURNS TABLE(hierarchyid bigint, hierarchytype character varying, parentdimtype character varying, parentdimcode integer, parentname character varying, childdimtype character varying, childdimcode integer, childname character varying, validfrom date, validto date, isactive boolean)
    LANGUAGE sql STABLE
    AS $$
    SELECT h.hierarchyid, h.hierarchytype,
           h.parentdimtype, h.parentdimcode, h_parent.namear,
           h.childdimtype, h.childdimcode, h_child.namear,
           h.validfrom, h.validto, h.isactive
      FROM tbldim_hierarchies h
      LEFT JOIN (SELECT 'DEPARTMENT' AS t, departmentcode AS c, namear FROM tbldim_departments
                 UNION ALL SELECT 'PROJECT', projectcode, namear FROM tbldim_projects
                 UNION ALL SELECT 'BUSINESSUNIT', businessunitcode, namear FROM tbldim_businessunits
                 UNION ALL SELECT 'SEGMENT', segmentcode, namear FROM tbldim_segments
                 UNION ALL SELECT 'PROFITCENTER', profitcentercode, namear FROM tbldim_profitcenters
                 UNION ALL SELECT 'COSTCENTER', costcentercode, costcenternamear FROM tblcostcenters
                ) h_parent ON h_parent.t=h.parentdimtype AND h_parent.c=h.parentdimcode
      LEFT JOIN (SELECT 'DEPARTMENT' AS t, departmentcode AS c, namear FROM tbldim_departments
                 UNION ALL SELECT 'PROJECT', projectcode, namear FROM tbldim_projects
                 UNION ALL SELECT 'BUSINESSUNIT', businessunitcode, namear FROM tbldim_businessunits
                 UNION ALL SELECT 'SEGMENT', segmentcode, namear FROM tbldim_segments
                 UNION ALL SELECT 'PROFITCENTER', profitcentercode, namear FROM tbldim_profitcenters
                 UNION ALL SELECT 'COSTCENTER', costcentercode, costcenternamear FROM tblcostcenters
                ) h_child ON h_child.t=h.childdimtype AND h_child.c=h.childdimcode
     ORDER BY h.hierarchytype, h.parentdimcode, h.childdimcode;
$$;


ALTER FUNCTION public.getalldimensionhierarchies() OWNER TO postgres;

--
-- Name: getallfunds(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallfunds() RETURNS TABLE(fundcode integer, fundid character varying, fundnamear character varying, fundnameen character varying, isactive boolean)
    LANGUAGE sql
    AS $$
    SELECT fundcode, fundid, fundnamear, fundnameen, isactive
    FROM tblfunds WHERE isactive = true ORDER BY fundnamear;
$$;


ALTER FUNCTION public.getallfunds() OWNER TO postgres;

--
-- Name: getalllists(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getalllists() RETURNS TABLE(windowid integer, windowcode character varying, windownamear character varying, windownameen character varying, modulename character varying)
    LANGUAGE sql
    AS $$
    SELECT windowid, windowcode, windownamear, windownameen, modulename
    FROM tblwindows
    WHERE isactive = true
    ORDER BY modulename, sortorder;
$$;


ALTER FUNCTION public.getalllists() OWNER TO postgres;

--
-- Name: getallpaymentmethods(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallpaymentmethods() RETURNS TABLE(paymentmethodcode integer, methodnamear character varying, methodnameen character varying, isactive boolean)
    LANGUAGE sql
    AS $$
    SELECT paymentmethodcode, methodnamear, methodnameen, isactive
    FROM tblpaymentmethods WHERE isactive = true ORDER BY methodnamear;
$$;


ALTER FUNCTION public.getallpaymentmethods() OWNER TO postgres;

--
-- Name: getallprivillages(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallprivillages(p_usercode integer, p_bracode integer, p_listid integer) RETURNS TABLE(windowid integer, windownamear character varying, candisplay boolean, canadd boolean, canedit boolean, candelete boolean, canprint boolean)
    LANGUAGE sql
    AS $$
    SELECT p.windowid, w.windownamear, p.candisplay, p.canadd, p.canedit, p.candelete, p.canprint
    FROM tblprivileges p
    JOIN tblwindows w ON w.windowid = p.windowid
    WHERE p.usercode = p_usercode
      AND (p_listid = 0 OR w.modulename = (SELECT modulename FROM tblwindows WHERE windowid = p_listid))
    ORDER BY w.sortorder;
$$;


ALTER FUNCTION public.getallprivillages(p_usercode integer, p_bracode integer, p_listid integer) OWNER TO postgres;

--
-- Name: getallproducts(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallproducts() RETURNS TABLE(productcode integer, productid character varying, productnamear character varying, productnameen character varying, barcode character varying, categorycode integer, defaultunitcode integer, lastsaleprice numeric, standardcost numeric, isactive boolean)
    LANGUAGE sql
    AS $$
    SELECT productcode, productid, productnamear, productnameen, barcode,
           categorycode, defaultunitcode, lastsaleprice, standardcost, isactive
    FROM tblproducts WHERE isactive = true ORDER BY productnamear;
$$;


ALTER FUNCTION public.getallproducts() OWNER TO postgres;

--
-- Name: getallprofitcenters(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallprofitcenters() RETURNS TABLE(profitcentercode integer, profitcenterid character varying, namear character varying, nameen character varying, parentprofitcentercode integer, parentname character varying, isactive boolean, notes text)
    LANGUAGE sql STABLE
    AS $$
    SELECT pc.profitcentercode, pc.profitcenterid, pc.namear, pc.nameen,
           pc.parentprofitcentercode, pa.namear, pc.isactive, pc.notes
      FROM tbldim_profitcenters pc
      LEFT JOIN tbldim_profitcenters pa ON pa.profitcentercode=pc.parentprofitcentercode
     ORDER BY pc.profitcentercode;
$$;


ALTER FUNCTION public.getallprofitcenters() OWNER TO postgres;

--
-- Name: getallprojects(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallprojects() RETURNS TABLE(projectcode integer, projectid character varying, namear character varying, nameen character varying, parentprojectcode integer, parentname character varying, projecttype character varying, startdate date, enddate date, budgetamount numeric, actualamount numeric, projectstatus character varying, isactive boolean, notes text)
    LANGUAGE sql STABLE
    AS $$
    SELECT pr.projectcode, pr.projectid, pr.namear, pr.nameen,
           pr.parentprojectcode, pa.namear,
           pr.projecttype, pr.startdate, pr.enddate,
           pr.budgetamount, pr.actualamount, pr.projectstatus,
           pr.isactive, pr.notes
      FROM tbldim_projects pr
      LEFT JOIN tbldim_projects pa ON pa.projectcode = pr.parentprojectcode
     ORDER BY pr.projectcode;
$$;


ALTER FUNCTION public.getallprojects() OWNER TO postgres;

--
-- Name: getallreporttypes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallreporttypes() RETURNS TABLE(reporttype character varying)
    LANGUAGE sql
    AS $$
    SELECT DISTINCT accountnature FROM tblaccounts ORDER BY accountnature;
$$;


ALTER FUNCTION public.getallreporttypes() OWNER TO postgres;

--
-- Name: getallsegments(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallsegments() RETURNS TABLE(segmentcode integer, segmentid character varying, namear character varying, nameen character varying, segmenttype character varying, parentsegmentcode integer, parentname character varying, isactive boolean, notes text)
    LANGUAGE sql STABLE
    AS $$
    SELECT s.segmentcode, s.segmentid, s.namear, s.nameen, s.segmenttype,
           s.parentsegmentcode, p.namear, s.isactive, s.notes
      FROM tbldim_segments s
      LEFT JOIN tbldim_segments p ON p.segmentcode=s.parentsegmentcode
     ORDER BY s.segmentcode;
$$;


ALTER FUNCTION public.getallsegments() OWNER TO postgres;

--
-- Name: getallstores(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallstores() RETURNS TABLE(storecode integer, storeid character varying, storenamear character varying, storenameen character varying, branchcode integer, managername character varying, isactive boolean, notes text)
    LANGUAGE sql
    AS $$
    SELECT storecode, storeid, storenamear, storenameen, branchcode, managername, isactive, notes
    FROM tblstores WHERE isactive = true ORDER BY storenamear;
$$;


ALTER FUNCTION public.getallstores() OWNER TO postgres;

--
-- Name: getallsuppliers(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallsuppliers(p_bracode integer) RETURNS TABLE(suppliercode integer, supplierid character varying, suppliernamear character varying, suppliernameen character varying, mobile character varying, email character varying, balance numeric, isactive boolean)
    LANGUAGE sql
    AS $$
    SELECT suppliercode, supplierid, suppliernamear, suppliernameen, mobile, email, balance, isactive
    FROM tblsuppliers
    WHERE isactive = true
    ORDER BY suppliernamear;
$$;


ALTER FUNCTION public.getallsuppliers(p_bracode integer) OWNER TO postgres;

--
-- Name: getallunits(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallunits() RETURNS TABLE(unitcode integer, unitid character varying, unitnamear character varying, unitnameen character varying, symbol character varying)
    LANGUAGE sql
    AS $$
    SELECT unitcode, unitid, unitnamear, unitnameen, symbol FROM tblunits WHERE isactive = true ORDER BY unitnamear;
$$;


ALTER FUNCTION public.getallunits() OWNER TO postgres;

--
-- Name: getallusers(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getallusers(p_bracode integer) RETURNS TABLE(usercode integer, userid character varying, usernamear character varying, usernameen character varying, email character varying, mobile character varying, isactive boolean, isadmin boolean, branchcode integer)
    LANGUAGE sql
    AS $$
    SELECT usercode, userid, usernamear, usernameen, email, mobile, isactive, isadmin, branchcode
    FROM tblusers
    WHERE (p_bracode = 0 OR branchcode = p_bracode OR branchcode IS NULL)
    ORDER BY usernamear;
$$;


ALTER FUNCTION public.getallusers(p_bracode integer) OWNER TO postgres;

--
-- Name: getapprovalconfig(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getapprovalconfig(p_key character varying) RETURNS numeric
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE v_value NUMERIC(18,4);
BEGIN
    SELECT configvalue INTO v_value FROM tblapprovalconfig WHERE configkey = p_key;
    RETURN COALESCE(v_value, 0);
END;
$$;


ALTER FUNCTION public.getapprovalconfig(p_key character varying) OWNER TO postgres;

--
-- Name: getapprovalstatus(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getapprovalstatus(p_requestid bigint) RETURNS TABLE(requestno character varying, workflowcode character varying, sourcetype character varying, sourceid bigint, requesteruserid character varying, status character varying, currentlevel integer, totallevels integer, totalsum numeric, progresspercent numeric, duedate timestamp without time zone, hourselapsed numeric, lastactiontype character varying, lastactionby character varying, lastactiondate timestamp without time zone)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.requestno, w.workflowcode, r.sourcetype, r.sourceid,
        u.userid, r.status, r.currentlevel, r.totallevels, r.totalsum,
        CASE WHEN r.totallevels = 0 THEN 0
             ELSE ((r.currentlevel - 1)::NUMERIC / r.totallevels) * 100
        END,
        r.duedate,
        EXTRACT(EPOCH FROM (NOW() - r.adddate)) / 3600.0,
        a_last.actiontype, u_last.userid, a_last.actiondate
    FROM tblapprovalrequests r
    JOIN tblapprovalworkflows w ON r.workflowid = w.workflowid
    JOIN tblusers u ON r.requesterid = u.usercode
    LEFT JOIN LATERAL (
        SELECT actiontype, approverid, actiondate
        FROM tblapprovalactions
        WHERE requestid = p_requestid
        ORDER BY actiondate DESC
        LIMIT 1
    ) a_last ON TRUE
    LEFT JOIN tblusers u_last ON a_last.approverid = u_last.usercode
    WHERE r.requestid = p_requestid;
END;
$$;


ALTER FUNCTION public.getapprovalstatus(p_requestid bigint) OWNER TO postgres;

--
-- Name: getbillorbondnewno(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getbillorbondnewno(p_optype integer, p_bracode integer) RETURNS TABLE(noop bigint)
    LANGUAGE sql
    AS $$
    SELECT COALESCE(MAX(operationcode),0)+1 AS noop
    FROM tbloperationheader
    WHERE operationtype = CASE p_optype
                            WHEN 1 THEN 'SALE'
                            WHEN 2 THEN 'PURCHASE'
                            WHEN 3 THEN 'SALE_RETURN'
                            WHEN 4 THEN 'PURCHASE_RETURN'
                            ELSE operationtype END;
$$;


ALTER FUNCTION public.getbillorbondnewno(p_optype integer, p_bracode integer) OWNER TO postgres;

--
-- Name: getbranchdata(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getbranchdata(p_bracode integer) RETURNS TABLE(branchcode integer, branchid character varying, branchnamear character varying, branchnameen character varying, address character varying, phone character varying, email character varying, isactive boolean)
    LANGUAGE sql
    AS $$
    SELECT branchcode, branchid, branchnamear, branchnameen, address, phone, email, isactive
    FROM tblbranches
    WHERE branchcode = p_bracode;
$$;


ALTER FUNCTION public.getbranchdata(p_bracode integer) OWNER TO postgres;

--
-- Name: getbudgetvsactual(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getbudgetvsactual(p_periodid integer, p_branchid integer) RETURNS TABLE(accountcode integer, accountname character varying, budgetamount numeric, actualamount numeric, varianceamount numeric, variancepercent numeric)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.getbudgetvsactual(p_periodid integer, p_branchid integer) OWNER TO postgres;

--
-- Name: getbusinessunitdata(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getbusinessunitdata(p_businessunitcode integer) RETURNS TABLE(businessunitcode integer, businessunitid character varying, namear character varying, nameen character varying, parentbusinessunitcode integer, isactive boolean, notes text)
    LANGUAGE sql STABLE
    AS $$
    SELECT businessunitcode, businessunitid, namear, nameen, parentbusinessunitcode, isactive, notes
      FROM tbldim_businessunits WHERE businessunitcode=p_businessunitcode;
$$;


ALTER FUNCTION public.getbusinessunitdata(p_businessunitcode integer) OWNER TO postgres;

--
-- Name: getbusinessunittree(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getbusinessunittree() RETURNS TABLE(businessunitcode integer, businessunitid character varying, namear character varying, level integer, fullpath character varying)
    LANGUAGE sql STABLE
    AS $$
    WITH RECURSIVE t AS (
        SELECT businessunitcode, businessunitid, namear, 0 AS level, namear::TEXT AS fullpath, parentbusinessunitcode
          FROM tbldim_businessunits WHERE parentbusinessunitcode IS NULL
        UNION ALL
        SELECT b.businessunitcode, b.businessunitid, b.namear, t.level+1,
               (t.fullpath||' / '||b.namear)::TEXT, b.parentbusinessunitcode
          FROM tbldim_businessunits b JOIN t ON b.parentbusinessunitcode=t.businessunitcode
    )
    SELECT businessunitcode, businessunitid, namear, level, fullpath FROM t ORDER BY fullpath;
$$;


ALTER FUNCTION public.getbusinessunittree() OWNER TO postgres;

--
-- Name: getcashboxbalance(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getcashboxbalance(p_cashboxid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE v_balance NUMERIC(18,4);
BEGIN
    SELECT currentbalance INTO v_balance FROM tblcashboxes WHERE cashboxid = p_cashboxid;
    RETURN COALESCE(v_balance, 0);
END;
$$;


ALTER FUNCTION public.getcashboxbalance(p_cashboxid integer) OWNER TO postgres;

--
-- Name: getcashpaymentsbydate(date, date, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getcashpaymentsbydate(p_fromdate date, p_todate date, p_cashboxid integer) RETURNS TABLE(paymentid bigint, paymentno character varying, paymentdate date, amount numeric, suppliername character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT p.paymentid, p.paymentno, p.paymentdate, p.amountlocal, COALESCE(s.suppname, '-')
    FROM tblcashpayments p
    LEFT JOIN tblsuppliers s ON p.supplierid = s.suppcode
    WHERE p.paymentdate BETWEEN p_fromdate AND p_todate
      AND (p_cashboxid = 0 OR p.cashboxid = p_cashboxid)
    ORDER BY p.paymentdate DESC, p.paymentid DESC;
END;
$$;


ALTER FUNCTION public.getcashpaymentsbydate(p_fromdate date, p_todate date, p_cashboxid integer) OWNER TO postgres;

--
-- Name: getcashreceiptsbydate(date, date, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getcashreceiptsbydate(p_fromdate date, p_todate date, p_cashboxid integer) RETURNS TABLE(receiptid bigint, receiptno character varying, receiptdate date, amount numeric, customername character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT r.receiptid, r.receiptno, r.receiptdate, r.amountlocal, COALESCE(c.custname, '-')
    FROM tblcashreceipts r
    LEFT JOIN tblcustomers c ON r.customerid = c.custcode
    WHERE r.receiptdate BETWEEN p_fromdate AND p_todate
      AND (p_cashboxid = 0 OR r.cashboxid = p_cashboxid)
    ORDER BY r.receiptdate DESC, r.receiptid DESC;
END;
$$;


ALTER FUNCTION public.getcashreceiptsbydate(p_fromdate date, p_todate date, p_cashboxid integer) OWNER TO postgres;

--
-- Name: getcategorydata(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getcategorydata(p_catid integer) RETURNS TABLE(categorycode integer, categorynamear character varying)
    LANGUAGE sql
    AS $$
    SELECT categorycode, categorynamear FROM tblcategories WHERE categorycode = p_catid;
$$;


ALTER FUNCTION public.getcategorydata(p_catid integer) OWNER TO postgres;

--
-- Name: getconversionfactor(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getconversionfactor(p_unitname character varying) RETURNS TABLE(unitcode integer, unitnamear character varying)
    LANGUAGE sql
    AS $$
    SELECT unitcode, unitnamear FROM tblunits WHERE unitnamear = p_unitName OR unitnameen = p_unitName;
$$;


ALTER FUNCTION public.getconversionfactor(p_unitname character varying) OWNER TO postgres;

--
-- Name: getcurrentapprover(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getcurrentapprover(p_requestid bigint) RETURNS TABLE(approverid integer, approveruserid character varying, approvername character varying, levelnumber integer, levelname character varying, sla_hours integer, hours_waiting numeric)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_workflowid INTEGER;
    v_currentlevel INTEGER;
    v_requiredrole VARCHAR(50);
    v_levelid INTEGER;
    v_sla_hours INTEGER;
    v_requestdate TIMESTAMP;
    v_delegatedto INTEGER;
BEGIN
    SELECT workflowid, currentlevel, adddate
    INTO v_workflowid, v_currentlevel, v_requestdate
    FROM tblapprovalrequests
    WHERE requestid = p_requestid AND status = 'PENDING';

    IF NOT FOUND THEN
        RETURN;
    END IF;

    SELECT levelid, requiredrole, sla_hours
    INTO v_levelid, v_requiredrole, v_sla_hours
    FROM tblapprovallevels
    WHERE workflowid = v_workflowid AND levelnumber = v_currentlevel;

    -- Find actual approvers with the required role (approximate via userid pattern)
    -- In production, you'd join with tbluserroleassignments + tbluserroles
    RETURN QUERY
    SELECT
        u.usercode, u.userid, u.usernamear, v_currentlevel, l.levelnamear,
        v_sla_hours,
        EXTRACT(EPOCH FROM (NOW() - v_requestdate)) / 3600.0
    FROM tblusers u
    CROSS JOIN tblapprovallevels l
    WHERE l.levelid = v_levelid
      AND u.isactive = TRUE
      AND u.isadmin = TRUE  -- Simplification: admins can approve all levels
    LIMIT 10;
END;
$$;


ALTER FUNCTION public.getcurrentapprover(p_requestid bigint) OWNER TO postgres;

--
-- Name: getdepartmentdata(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getdepartmentdata(p_departmentcode integer) RETURNS TABLE(departmentcode integer, departmentid character varying, namear character varying, nameen character varying, parentdepartmentcode integer, managerusercode integer, isactive boolean, effectivedate date, enddate date, notes text)
    LANGUAGE sql STABLE
    AS $$
    SELECT departmentcode, departmentid, namear, nameen, parentdepartmentcode,
           managerusercode, isactive, effectivedate, enddate, notes
      FROM tbldim_departments
     WHERE departmentcode = p_departmentcode;
$$;


ALTER FUNCTION public.getdepartmentdata(p_departmentcode integer) OWNER TO postgres;

--
-- Name: getdepartmenttree(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getdepartmenttree() RETURNS TABLE(departmentcode integer, departmentid character varying, namear character varying, level integer, fullpath character varying)
    LANGUAGE sql STABLE
    AS $$
    WITH RECURSIVE t AS (
        SELECT departmentcode, departmentid, namear, 0 AS level,
               namear::TEXT AS fullpath, parentdepartmentcode
          FROM tbldim_departments
         WHERE parentdepartmentcode IS NULL
        UNION ALL
        SELECT d.departmentcode, d.departmentid, d.namear, t.level + 1,
               (t.fullpath || ' / ' || d.namear)::TEXT, d.parentdepartmentcode
          FROM tbldim_departments d JOIN t ON d.parentdepartmentcode = t.departmentcode
    )
    SELECT departmentcode, departmentid, namear, level, fullpath FROM t ORDER BY fullpath;
$$;


ALTER FUNCTION public.getdepartmenttree() OWNER TO postgres;

--
-- Name: getdimensionactual(character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getdimensionactual(p_dimtype character varying, p_dimcode integer, p_periodid integer) RETURNS numeric
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE v_actual NUMERIC(19,4) := 0;
BEGIN
    IF p_dimcode IS NULL THEN RETURN 0; END IF;
    SELECT COALESCE(SUM(GREATEST(jb.debit, jb.credit)), 0)
      INTO v_actual
      FROM tbljournalbody jb
      JOIN tbljournalheader jh ON jh.journalcode=jb.journalcode
     WHERE jh.isposted=TRUE
       AND jh.iscancelled=FALSE
       AND (p_periodid IS NULL OR jh.fiscalperiod=p_periodid)
       AND (
            (p_dimtype='DEPARTMENT'   AND jb.departmentcode=p_dimcode)    OR
            (p_dimtype='PROJECT'     AND jb.projectcode=p_dimcode)        OR
            (p_dimtype='BUSINESSUNIT' AND jb.businessunitcode=p_dimcode)  OR
            (p_dimtype='SEGMENT'     AND jb.segmentcode=p_dimcode)        OR
            (p_dimtype='PROFITCENTER' AND jb.profitcentercode=p_dimcode)  OR
            (p_dimtype='COSTCENTER'  AND jb.costcentercode=p_dimcode)
       );
    RETURN COALESCE(v_actual,0);
END$$;


ALTER FUNCTION public.getdimensionactual(p_dimtype character varying, p_dimcode integer, p_periodid integer) OWNER TO postgres;

--
-- Name: getdimensionbudget(character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getdimensionbudget(p_dimtype character varying, p_dimcode integer, p_periodid integer) RETURNS numeric
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE v_budget NUMERIC(19,4) := 0;
BEGIN
    IF p_dimcode IS NULL THEN RETURN 0; END IF;
    SELECT COALESCE(SUM(b.budgetamount), 0)
      INTO v_budget
      FROM tblbudgets b
     WHERE (p_periodid IS NULL OR b.periodid=p_periodid)
       AND (
            (p_dimtype='DEPARTMENT'   AND b.departmentcode=p_dimcode)    OR
            (p_dimtype='PROJECT'     AND b.projectcode=p_dimcode)        OR
            (p_dimtype='BUSINESSUNIT' AND b.businessunitcode=p_dimcode)  OR
            (p_dimtype='SEGMENT'     AND b.segmentcode=p_dimcode)        OR
            (p_dimtype='PROFITCENTER' AND b.profitcentercode=p_dimcode)  OR
            (p_dimtype='COSTCENTER'  AND b.costcenterid=p_dimcode)
       );
    RETURN COALESCE(v_budget,0);
END$$;


ALTER FUNCTION public.getdimensionbudget(p_dimtype character varying, p_dimcode integer, p_periodid integer) OWNER TO postgres;

--
-- Name: getdimensionfullpath(character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getdimensionfullpath(p_dimtype character varying, p_dimcode integer) RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE v_path TEXT;
BEGIN
    IF p_dimcode IS NULL THEN RETURN NULL; END IF;
    IF p_dimtype='DEPARTMENT' THEN
        WITH RECURSIVE t AS (
            SELECT departmentcode, namear, 0 AS lvl, namear::TEXT AS path, parentdepartmentcode
              FROM tbldim_departments WHERE departmentcode=p_dimcode
            UNION ALL
            SELECT d.departmentcode, d.namear, t.lvl+1, (d.namear||' / '||t.path)::TEXT, d.parentdepartmentcode
              FROM tbldim_departments d JOIN t ON d.departmentcode=t.parentdepartmentcode
        )
        SELECT path INTO v_path FROM t WHERE lvl=(SELECT MAX(lvl) FROM t);
    ELSIF p_dimtype='PROJECT' THEN
        WITH RECURSIVE t AS (
            SELECT projectcode, namear, 0 AS lvl, namear::TEXT AS path, parentprojectcode
              FROM tbldim_projects WHERE projectcode=p_dimcode
            UNION ALL
            SELECT p.projectcode, p.namear, t.lvl+1, (p.namear||' / '||t.path)::TEXT, p.parentprojectcode
              FROM tbldim_projects p JOIN t ON p.projectcode=t.parentprojectcode
        )
        SELECT path INTO v_path FROM t WHERE lvl=(SELECT MAX(lvl) FROM t);
    ELSIF p_dimtype='COSTCENTER' THEN
        WITH RECURSIVE t AS (
            SELECT costcentercode, costcenternamear, 0 AS lvl, costcenternamear::TEXT AS path, parentcostcentercode
              FROM tblcostcenters WHERE costcentercode=p_dimcode
            UNION ALL
            SELECT c.costcentercode, c.costcenternamear, t.lvl+1, (c.costcenternamear||' / '||t.path)::TEXT, c.parentcostcentercode
              FROM tblcostcenters c JOIN t ON c.costcentercode=t.parentcostcentercode
        )
        SELECT path INTO v_path FROM t WHERE lvl=(SELECT MAX(lvl) FROM t);
    ELSE
        SELECT namear INTO v_path FROM tbldim_businessunits WHERE businessunitcode=p_dimcode AND p_dimtype='BUSINESSUNIT';
        IF v_path IS NULL THEN
            SELECT namear INTO v_path FROM tbldim_segments WHERE segmentcode=p_dimcode AND p_dimtype='SEGMENT';
        END IF;
        IF v_path IS NULL THEN
            SELECT namear INTO v_path FROM tbldim_profitcenters WHERE profitcentercode=p_dimcode AND p_dimtype='PROFITCENTER';
        END IF;
    END IF;
    RETURN v_path;
END$$;


ALTER FUNCTION public.getdimensionfullpath(p_dimtype character varying, p_dimcode integer) OWNER TO postgres;

--
-- Name: getdimensionvariance(character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getdimensionvariance(p_dimtype character varying, p_dimcode integer, p_periodid integer) RETURNS numeric
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN getDimensionBudget(p_dimtype, p_dimcode, p_periodid)
         - getDimensionActual(p_dimtype, p_dimcode, p_periodid);
END$$;


ALTER FUNCTION public.getdimensionvariance(p_dimtype character varying, p_dimcode integer, p_periodid integer) OWNER TO postgres;

--
-- Name: getdisplayprivillages(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getdisplayprivillages(p_usercode integer, p_bracode integer) RETURNS TABLE(windowid integer, windownamear character varying, candisplay boolean)
    LANGUAGE sql
    AS $$
    SELECT p.windowid, w.windownamear, p.candisplay
    FROM tblprivileges p
    JOIN tblwindows w ON w.windowid = p.windowid
    WHERE p.usercode = p_usercode AND p.candisplay = true
    ORDER BY w.sortorder;
$$;


ALTER FUNCTION public.getdisplayprivillages(p_usercode integer, p_bracode integer) OWNER TO postgres;

--
-- Name: getdocumentstatus(character varying, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getdocumentstatus(p_sourcetype character varying, p_sourceid bigint) RETURNS TABLE(docno character varying, docdate date, amount numeric, posted boolean, approvalrequestid bigint, requestno character varying, status character varying, currentlevel integer, totallevels integer, isapproved boolean, isoverdue boolean)
    LANGUAGE plpgsql STABLE
    AS $$
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
$$;


ALTER FUNCTION public.getdocumentstatus(p_sourcetype character varying, p_sourceid bigint) OWNER TO postgres;

--
-- Name: geteffectiveapprover(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.geteffectiveapprover(p_userid integer, p_workflowid integer) RETURNS integer
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_delegatedto INTEGER;
BEGIN
    -- Check if user has an active delegation for this workflow (or any workflow if NULL)
    SELECT touserid INTO v_delegatedto
    FROM tblapprovaldelegations
    WHERE fromuserid = p_userid
      AND isactive = TRUE
      AND CURRENT_DATE BETWEEN fromdate AND todate
      AND (workflowid = p_workflowid OR workflowid IS NULL)
    ORDER BY workflowid NULLS LAST
    LIMIT 1;

    RETURN COALESCE(v_delegatedto, p_userid);
END;
$$;


ALTER FUNCTION public.geteffectiveapprover(p_userid integer, p_workflowid integer) OWNER TO postgres;

--
-- Name: getexchangecurrency(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getexchangecurrency(p_currname character varying) RETURNS TABLE(currencycode integer, currencynamear character varying, exchangerate numeric)
    LANGUAGE sql
    AS $$
    SELECT currencycode, currencynamear, exchangerate
    FROM tblcurrencies
    WHERE currencynamear = p_currname OR currencynameen = p_currname;
$$;


ALTER FUNCTION public.getexchangecurrency(p_currname character varying) OWNER TO postgres;

--
-- Name: getexchangerateatdate(integer, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getexchangerateatdate(p_currid integer, p_atdate date) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.getexchangerateatdate(p_currid integer, p_atdate date) OWNER TO postgres;

--
-- Name: getfinalaccountreport(date, date, numeric, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getfinalaccountreport(p_fromdate date, p_todate date, p_exchangerate numeric, p_bracode integer, p_reporttype integer) RETURNS TABLE(accountcode integer, accountnamear character varying, debitor numeric, creditor numeric)
    LANGUAGE sql
    AS $$
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
$$;


ALTER FUNCTION public.getfinalaccountreport(p_fromdate date, p_todate date, p_exchangerate numeric, p_bracode integer, p_reporttype integer) OWNER TO postgres;

--
-- Name: getfundcode(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getfundcode(p_fundname character varying) RETURNS TABLE(fundcode integer)
    LANGUAGE sql
    AS $$
    SELECT fundcode FROM tblfunds WHERE fundnamear = p_fundname OR fundnameen = p_fundname;
$$;


ALTER FUNCTION public.getfundcode(p_fundname character varying) OWNER TO postgres;

--
-- Name: getinventorymovement(date, date, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getinventorymovement(p_fromdate date, p_todate date, p_bracode integer) RETURNS TABLE(movementdate date, productnamear character varying, storenamear character varying, movementtype character varying, quantity numeric, unitprice numeric)
    LANGUAGE sql
    AS $$
    SELECT m.movementdate, p.productnamear, s.storenamear, m.movementtype,
           m.quantity, m.unitcost AS unitprice
    FROM tblproductmovement m
    JOIN tblproducts p ON p.productcode = m.productcode
    JOIN tblstores   s ON s.storecode   = m.storecode
    WHERE m.movementdate BETWEEN p_fromdate AND p_todate
    ORDER BY m.movementdate, m.movementid;
$$;


ALTER FUNCTION public.getinventorymovement(p_fromdate date, p_todate date, p_bracode integer) OWNER TO postgres;

--
-- Name: getinventoryvaluation(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getinventoryvaluation(p_branchid integer, p_categorycode integer) RETURNS TABLE(productcode integer, productname character varying, standardcost numeric, lastsaleprice numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT p.productcode, p.productnamear, p.standardcost, p.lastsaleprice
    FROM tblproducts p
    WHERE p.isactive = TRUE
      AND (p_branchid = 0 OR p.categorycode = p_categorycode)
    ORDER BY p.productnamear;
END;
$$;


ALTER FUNCTION public.getinventoryvaluation(p_branchid integer, p_categorycode integer) OWNER TO postgres;

--
-- Name: getlistofaccounts(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getlistofaccounts(p_bracode integer) RETURNS TABLE(accountcode integer, accountid character varying, accountnamear character varying, accountnameen character varying, accounttype character varying, accountlevel integer, parentaccountcode integer)
    LANGUAGE sql
    AS $$
    SELECT accountcode, accountid, accountnamear, accountnameen,
           accounttype, accountlevel, parentaccountcode
    FROM tblaccounts
    WHERE isactive = true AND ispostable = true
    ORDER BY accountid;
$$;


ALTER FUNCTION public.getlistofaccounts(p_bracode integer) OWNER TO postgres;

--
-- Name: getmaxbondno(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getmaxbondno(p_bondtype integer) RETURNS TABLE(bondcode bigint)
    LANGUAGE sql
    AS $$
    SELECT COALESCE(MAX(bondcode),0) AS bondcode
    FROM tblbondheader
    WHERE bondtype = CASE p_bondtype
                       WHEN 1 THEN 'RECEIPT'
                       WHEN 2 THEN 'PAYMENT'
                       ELSE bondtype END;
$$;


ALTER FUNCTION public.getmaxbondno(p_bondtype integer) OWNER TO postgres;

--
-- Name: getmaximumbillbondno(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getmaximumbillbondno(p_optype integer) RETURNS TABLE(operationcode bigint)
    LANGUAGE sql
    AS $$
    SELECT COALESCE(MAX(operationcode),0) AS operationcode
    FROM tbloperationheader
    WHERE operationtype = CASE p_optype
                            WHEN 1 THEN 'SALE'
                            WHEN 2 THEN 'PURCHASE'
                            WHEN 3 THEN 'SALE_RETURN'
                            WHEN 4 THEN 'PURCHASE_RETURN'
                            ELSE operationtype END;
$$;


ALTER FUNCTION public.getmaximumbillbondno(p_optype integer) OWNER TO postgres;

--
-- Name: getmaximumjno(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getmaximumjno() RETURNS TABLE(journalcode bigint)
    LANGUAGE sql
    AS $$
    SELECT COALESCE(MAX(journalcode),0) AS journalcode FROM tbljournalheader;
$$;


ALTER FUNCTION public.getmaximumjno() OWNER TO postgres;

--
-- Name: getminbondno(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getminbondno(p_bondtype integer) RETURNS TABLE(bondcode bigint)
    LANGUAGE sql
    AS $$
    SELECT COALESCE(MIN(bondcode),0) AS bondcode
    FROM tblbondheader
    WHERE bondtype = CASE p_bondtype
                       WHEN 1 THEN 'RECEIPT'
                       WHEN 2 THEN 'PAYMENT'
                       ELSE bondtype END;
$$;


ALTER FUNCTION public.getminbondno(p_bondtype integer) OWNER TO postgres;

--
-- Name: getminimumbillbondno(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getminimumbillbondno(p_optype integer) RETURNS TABLE(operationcode bigint)
    LANGUAGE sql
    AS $$
    SELECT COALESCE(MIN(operationcode),0) AS operationcode
    FROM tbloperationheader
    WHERE operationtype = CASE p_optype
                            WHEN 1 THEN 'SALE'
                            WHEN 2 THEN 'PURCHASE'
                            WHEN 3 THEN 'SALE_RETURN'
                            WHEN 4 THEN 'PURCHASE_RETURN'
                            ELSE operationtype END;
$$;


ALTER FUNCTION public.getminimumbillbondno(p_optype integer) OWNER TO postgres;

--
-- Name: getminimumjno(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getminimumjno() RETURNS TABLE(journalcode bigint)
    LANGUAGE sql
    AS $$
    SELECT COALESCE(MIN(journalcode),0) AS journalcode FROM tbljournalheader;
$$;


ALTER FUNCTION public.getminimumjno() OWNER TO postgres;

--
-- Name: getnewbondno(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getnewbondno(p_bracode integer, p_bondtype integer) RETURNS TABLE(bondcode bigint)
    LANGUAGE sql
    AS $$
    SELECT COALESCE(MAX(bondcode),0) + 1 AS bondcode
    FROM tblbondheader
    WHERE bondtype = CASE p_bondtype
                       WHEN 1 THEN 'RECEIPT'
                       WHEN 2 THEN 'PAYMENT'
                       ELSE bondtype END;
$$;


ALTER FUNCTION public.getnewbondno(p_bracode integer, p_bondtype integer) OWNER TO postgres;

--
-- Name: getnewbranchno(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getnewbranchno() RETURNS TABLE(branchcode integer)
    LANGUAGE sql
    AS $$
    SELECT COALESCE(MAX(branchcode),0) + 1 AS branchcode FROM tblbranches;
$$;


ALTER FUNCTION public.getnewbranchno() OWNER TO postgres;

--
-- Name: getnewjournalno(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getnewjournalno(p_bracode integer) RETURNS TABLE(journalcode bigint)
    LANGUAGE sql
    AS $$
    SELECT COALESCE(MAX(journalcode),0) + 1 AS journalcode FROM tbljournalheader;
$$;


ALTER FUNCTION public.getnewjournalno(p_bracode integer) OWNER TO postgres;

--
-- Name: getnextapprovallevel(integer, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getnextapprovallevel(p_workflowid integer, p_amount numeric) RETURNS integer
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_level INTEGER;
BEGIN
    SELECT levelnumber INTO v_level
    FROM tblapprovallevels
    WHERE workflowid = p_workflowid
      AND isactive = TRUE
      AND p_amount BETWEEN amountmin AND amountmax
    ORDER BY levelnumber
    LIMIT 1;

    RETURN COALESCE(v_level, 0);
END;
$$;


ALTER FUNCTION public.getnextapprovallevel(p_workflowid integer, p_amount numeric) OWNER TO postgres;

--
-- Name: getpendingapprovals(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getpendingapprovals(p_userid integer) RETURNS TABLE(requestid bigint, requestno character varying, sourcetype character varying, sourceid bigint, workflowcode character varying, currentlevel integer, totalsum numeric, requester character varying, duedate timestamp without time zone, hourselapsed numeric)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.requestid, r.requestno, r.sourcetype, r.sourceid,
        w.workflowcode, r.currentlevel, r.totalsum,
        u.usernamear, r.duedate,
        EXTRACT(EPOCH FROM (NOW() - r.adddate)) / 3600.0
    FROM tblapprovalrequests r
    JOIN tblapprovalworkflows w ON r.workflowid = w.workflowid
    JOIN tblusers u ON r.requesterid = u.usercode
    WHERE r.status = 'PENDING'
      AND EXISTS (
          SELECT 1 FROM tblapprovallevels l
          WHERE l.workflowid = r.workflowid AND l.levelnumber = r.currentlevel
      )
    ORDER BY r.duedate NULLS LAST, r.adddate;
END;
$$;


ALTER FUNCTION public.getpendingapprovals(p_userid integer) OWNER TO postgres;

--
-- Name: getpostingbonds(date, date, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getpostingbonds(p_fromdate date, p_todate date, p_optype integer, p_poststatus integer, p_bracode integer) RETURNS TABLE(journalcode bigint, journalid character varying, journaldate date, description character varying, totaldebit numeric, totalcredit numeric, isposted boolean)
    LANGUAGE sql
    AS $$
    SELECT journalcode, journalid, journaldate, description, totaldebit, totalcredit, isposted
    FROM tbljournalheader
    WHERE journaldate BETWEEN p_fromDate AND p_toDate
      AND (p_postStatus = 2 OR isposted = (p_postStatus = 1))
    ORDER BY journaldate, journalcode;
$$;


ALTER FUNCTION public.getpostingbonds(p_fromdate date, p_todate date, p_optype integer, p_poststatus integer, p_bracode integer) OWNER TO postgres;

--
-- Name: getproductdata(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getproductdata(p_searchtext character varying) RETURNS TABLE(productcode integer, productid character varying, productnamear character varying, productnameen character varying, barcode character varying, categorycode integer, defaultunitcode integer, lastsaleprice numeric)
    LANGUAGE sql
    AS $$
    SELECT productcode, productid, productnamear, productnameen, barcode,
           categorycode, defaultunitcode, lastsaleprice
    FROM tblproducts
    WHERE isactive = true
      AND (productnamear ILIKE '%'||p_searchtext||'%'
           OR productid ILIKE '%'||p_searchtext||'%'
           OR barcode = p_searchtext)
    ORDER BY productnamear
    LIMIT 100;
$$;


ALTER FUNCTION public.getproductdata(p_searchtext character varying) OWNER TO postgres;

--
-- Name: getproductsinventory(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getproductsinventory(p_bracode integer) RETURNS TABLE(productcode integer, productnamear character varying, storenamear character varying, qtyonhand numeric, avgcost numeric, lastsaleprice numeric)
    LANGUAGE sql
    AS $$
    SELECT p.productcode, p.productnamear, s.storenamear,
           sp.qtyonhand, sp.avgcost, p.lastsaleprice
    FROM tblstoreproducts sp
    JOIN tblproducts p ON p.productcode = sp.productcode
    JOIN tblstores   s ON s.storecode   = sp.storecode
    WHERE p.isactive = true
    ORDER BY p.productnamear;
$$;


ALTER FUNCTION public.getproductsinventory(p_bracode integer) OWNER TO postgres;

--
-- Name: getprofitcenterdata(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getprofitcenterdata(p_profitcentercode integer) RETURNS TABLE(profitcentercode integer, profitcenterid character varying, namear character varying, nameen character varying, parentprofitcentercode integer, isactive boolean, notes text)
    LANGUAGE sql STABLE
    AS $$
    SELECT profitcentercode, profitcenterid, namear, nameen, parentprofitcentercode, isactive, notes
      FROM tbldim_profitcenters WHERE profitcentercode=p_profitcentercode;
$$;


ALTER FUNCTION public.getprofitcenterdata(p_profitcentercode integer) OWNER TO postgres;

--
-- Name: getprofitcentertree(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getprofitcentertree() RETURNS TABLE(profitcentercode integer, profitcenterid character varying, namear character varying, level integer, fullpath character varying)
    LANGUAGE sql STABLE
    AS $$
    WITH RECURSIVE t AS (
        SELECT profitcentercode, profitcenterid, namear, 0 AS level, namear::TEXT AS fullpath, parentprofitcentercode
          FROM tbldim_profitcenters WHERE parentprofitcentercode IS NULL
        UNION ALL
        SELECT pc.profitcentercode, pc.profitcenterid, pc.namear, t.level+1,
               (t.fullpath||' / '||pc.namear)::TEXT, pc.parentprofitcentercode
          FROM tbldim_profitcenters pc JOIN t ON pc.parentprofitcentercode=t.profitcentercode
    )
    SELECT profitcentercode, profitcenterid, namear, level, fullpath FROM t ORDER BY fullpath;
$$;


ALTER FUNCTION public.getprofitcentertree() OWNER TO postgres;

--
-- Name: getprojectdata(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getprojectdata(p_projectcode integer) RETURNS TABLE(projectcode integer, projectid character varying, namear character varying, nameen character varying, parentprojectcode integer, projecttype character varying, startdate date, enddate date, budgetamount numeric, actualamount numeric, projectstatus character varying, isactive boolean, notes text)
    LANGUAGE sql STABLE
    AS $$
    SELECT projectcode, projectid, namear, nameen, parentprojectcode, projecttype,
           startdate, enddate, budgetamount, actualamount, projectstatus, isactive, notes
      FROM tbldim_projects WHERE projectcode=p_projectcode;
$$;


ALTER FUNCTION public.getprojectdata(p_projectcode integer) OWNER TO postgres;

--
-- Name: getprojecttree(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getprojecttree() RETURNS TABLE(projectcode integer, projectid character varying, namear character varying, level integer, fullpath character varying)
    LANGUAGE sql STABLE
    AS $$
    WITH RECURSIVE t AS (
        SELECT projectcode, projectid, namear, 0 AS level, namear::TEXT AS fullpath, parentprojectcode
          FROM tbldim_projects WHERE parentprojectcode IS NULL
        UNION ALL
        SELECT p.projectcode, p.projectid, p.namear, t.level+1,
               (t.fullpath||' / '||p.namear)::TEXT, p.parentprojectcode
          FROM tbldim_projects p JOIN t ON p.parentprojectcode=t.projectcode
    )
    SELECT projectcode, projectid, namear, level, fullpath FROM t ORDER BY fullpath;
$$;


ALTER FUNCTION public.getprojecttree() OWNER TO postgres;

--
-- Name: getpurchasereportbyperiod(date, date, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getpurchasereportbyperiod(p_fromdate date, p_todate date, p_branchid integer) RETURNS TABLE(bondid character varying, bonddate date, suppliername character varying, totalamount numeric)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.getpurchasereportbyperiod(p_fromdate date, p_todate date, p_branchid integer) OWNER TO postgres;

--
-- Name: getsalesreportbyperiod(date, date, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getsalesreportbyperiod(p_fromdate date, p_todate date, p_branchid integer) RETURNS TABLE(bondid character varying, bonddate date, customername character varying, totalamount numeric)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.getsalesreportbyperiod(p_fromdate date, p_todate date, p_branchid integer) OWNER TO postgres;

--
-- Name: getscreensprivillages(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getscreensprivillages(p_usercode integer, p_windowid integer, p_bracode integer) RETURNS TABLE(privnew boolean, privadd boolean, privedit boolean, privdel boolean, privprint boolean, privdisplay boolean)
    LANGUAGE sql
    AS $$
    SELECT COALESCE(canadd,false)     AS privadd,
           COALESCE(canedit,false)    AS privedit,
           COALESCE(candelete,false)  AS privdel,
           COALESCE(canprint,false)   AS privprint,
           COALESCE(candisplay,false) AS privdisplay,
           COALESCE(candisplay,false) AS privnew
    FROM tblprivileges
    WHERE usercode = p_usercode AND windowid = p_windowid
    LIMIT 1;
$$;


ALTER FUNCTION public.getscreensprivillages(p_usercode integer, p_windowid integer, p_bracode integer) OWNER TO postgres;

--
-- Name: getsegmentdata(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getsegmentdata(p_segmentcode integer) RETURNS TABLE(segmentcode integer, segmentid character varying, namear character varying, nameen character varying, segmenttype character varying, parentsegmentcode integer, isactive boolean, notes text)
    LANGUAGE sql STABLE
    AS $$
    SELECT segmentcode, segmentid, namear, nameen, segmenttype, parentsegmentcode, isactive, notes
      FROM tbldim_segments WHERE segmentcode=p_segmentcode;
$$;


ALTER FUNCTION public.getsegmentdata(p_segmentcode integer) OWNER TO postgres;

--
-- Name: getsegmenttree(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getsegmenttree() RETURNS TABLE(segmentcode integer, segmentid character varying, namear character varying, level integer, fullpath character varying)
    LANGUAGE sql STABLE
    AS $$
    WITH RECURSIVE t AS (
        SELECT segmentcode, segmentid, namear, 0 AS level, namear::TEXT AS fullpath, parentsegmentcode
          FROM tbldim_segments WHERE parentsegmentcode IS NULL
        UNION ALL
        SELECT s.segmentcode, s.segmentid, s.namear, t.level+1,
               (t.fullpath||' / '||s.namear)::TEXT, s.parentsegmentcode
          FROM tbldim_segments s JOIN t ON s.parentsegmentcode=t.segmentcode
    )
    SELECT segmentcode, segmentid, namear, level, fullpath FROM t ORDER BY fullpath;
$$;


ALTER FUNCTION public.getsegmenttree() OWNER TO postgres;

--
-- Name: gettraibalance(date, date, numeric, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gettraibalance(p_fromdate date, p_todate date, p_exchangerate numeric, p_bracode integer) RETURNS TABLE(accountcode integer, accountnamear character varying, debitor numeric, creditor numeric)
    LANGUAGE sql
    AS $$
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
$$;


ALTER FUNCTION public.gettraibalance(p_fromdate date, p_todate date, p_exchangerate numeric, p_bracode integer) OWNER TO postgres;

--
-- Name: gettrialbalancereport(date, date, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gettrialbalancereport(p_fromdate date, p_todate date, p_branchid integer) RETURNS TABLE(accountcode integer, accountnumber character varying, accountname character varying, totaldebit numeric, totalcredit numeric, balance numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT a.accountcode, a.accountid, a.accountnamear,
           a.currentbalance, 0, a.currentbalance
    FROM tblaccounts a
    WHERE a.isactive = TRUE
    ORDER BY a.accountid;
END;
$$;


ALTER FUNCTION public.gettrialbalancereport(p_fromdate date, p_todate date, p_branchid integer) OWNER TO postgres;

--
-- Name: getuserforlogin(character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getuserforlogin(p_userid character varying, p_bracode integer) RETURNS TABLE(usercode integer, userid character varying, "PWD" character varying, "PWDHash" character varying, "PasswordHash" character varying, "PasswordSalt" character varying, "PasswordIterations" integer, usernamear character varying, usernameen character varying, isactive boolean, isadmin boolean, branchcode integer)
    LANGUAGE sql
    AS $$
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
$$;


ALTER FUNCTION public.getuserforlogin(p_userid character varying, p_bracode integer) OWNER TO postgres;

--
-- Name: getusernewno(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getusernewno() RETURNS TABLE(usercode integer)
    LANGUAGE sql
    AS $$
    SELECT COALESCE(MAX(usercode),0)+1 AS usercode FROM tblusers;
$$;


ALTER FUNCTION public.getusernewno() OWNER TO postgres;

--
-- Name: getuserno(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getuserno(p_userid character varying) RETURNS TABLE(usercode integer, branchcode integer)
    LANGUAGE sql
    AS $$
    SELECT usercode, branchcode FROM tblusers WHERE userid = p_userid LIMIT 1;
$$;


ALTER FUNCTION public.getuserno(p_userid character varying) OWNER TO postgres;

--
-- Name: getuserno(character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getuserno(p_userid character varying, p_bracode integer) RETURNS TABLE(usercode integer, branchcode integer)
    LANGUAGE sql
    AS $$
    SELECT usercode, branchcode
    FROM tblusers
    WHERE userid = p_userid
      AND (p_bracode = 0 OR branchcode = p_bracode OR branchcode IS NULL)
    LIMIT 1;
$$;


ALTER FUNCTION public.getuserno(p_userid character varying, p_bracode integer) OWNER TO postgres;

--
-- Name: isapprovalcomplete(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.isapprovalcomplete(p_requestid bigint) RETURNS boolean
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_status VARCHAR(20);
    v_currentlevel INTEGER;
    v_totallevels INTEGER;
BEGIN
    SELECT status, currentlevel, totallevels
    INTO v_status, v_currentlevel, v_totallevels
    FROM tblapprovalrequests
    WHERE requestid = p_requestid;

    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    RETURN v_status IN ('APPROVED', 'REJECTED', 'CANCELLED', 'EXPIRED')
           OR (v_status = 'PENDING' AND v_currentlevel > v_totallevels);
END;
$$;


ALTER FUNCTION public.isapprovalcomplete(p_requestid bigint) OWNER TO postgres;

--
-- Name: issourceapproved(character varying, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.issourceapproved(p_sourcetype character varying, p_sourceid bigint) RETURNS boolean
    LANGUAGE plpgsql STABLE
    AS $$
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
$$;


ALTER FUNCTION public.issourceapproved(p_sourcetype character varying, p_sourceid bigint) OWNER TO postgres;

--
-- Name: processexpiredrequests(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.processexpiredrequests(OUT p_expired_count integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_rec RECORD;
    v_count INTEGER := 0;
BEGIN
    FOR v_rec IN
        SELECT requestid FROM tblapprovalrequests
        WHERE status = 'PENDING'
          AND duedate IS NOT NULL
          AND duedate < NOW()
    LOOP
        UPDATE tblapprovalrequests
        SET status = 'EXPIRED', completedate = NOW()
        WHERE requestid = v_rec.requestid;
        v_count := v_count + 1;
    END LOOP;

    p_expired_count := v_count;
END;
$$;


ALTER PROCEDURE public.processexpiredrequests(OUT p_expired_count integer) OWNER TO postgres;

--
-- Name: reassignpendingapprovals(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.reassignpendingapprovals(IN p_fromuserid integer, IN p_touserid integer, OUT p_reassigned_count integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_rec RECORD;
    v_count INTEGER := 0;
BEGIN
    FOR v_rec IN
        SELECT a.actionid, a.requestid, a.levelid
        FROM tblapprovalactions a
        JOIN tblapprovalrequests r ON a.requestid = r.requestid
        WHERE r.status = 'PENDING'
          AND a.approverid = p_fromuserid
          AND a.actiontype = 'SUBMITTED'  -- the SUBMITTED entry
    LOOP
        INSERT INTO tblapprovalactions
            (requestid, levelid, approverid, actiontype, oldstatus, newstatus, fromlevel, tolevel, delegatedto, comments)
        VALUES (v_rec.requestid, v_rec.levelid, p_fromuserid, 'DELEGATED', 'PENDING', 'PENDING',
                0, 0, p_touserid, 'Bulk reassignment from user ' || p_fromuserid || ' to user ' || p_touserid);

        INSERT INTO tblnotifications (userid, title, message, notificationtype, priority, reftype, refid)
        SELECT p_touserid, 'Reassigned approval: ' || r.requestno,
               'Approval reassigned to you from user ' || p_fromuserid,
               'APPROVAL', 'NORMAL', 'APPROVAL_REQUEST', r.requestid
        FROM tblapprovalrequests r WHERE r.requestid = v_rec.requestid;
        v_count := v_count + 1;
    END LOOP;

    p_reassigned_count := v_count;
END;
$$;


ALTER PROCEDURE public.reassignpendingapprovals(IN p_fromuserid integer, IN p_touserid integer, OUT p_reassigned_count integer) OWNER TO postgres;

--
-- Name: refresh_critical_mvs(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.refresh_critical_mvs() RETURNS TABLE(mv_name text, refresh_seconds numeric, row_count bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    start_time TIMESTAMP;
    end_time   TIMESTAMP;
    elapsed    NUMERIC;
    cnt        BIGINT;
BEGIN
    -- 1. mv_account_balances (no deps)
    start_time := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY public.mv_account_balances;
    end_time := clock_timestamp();
    elapsed := EXTRACT(EPOCH FROM (end_time - start_time));
    SELECT COUNT(*) INTO cnt FROM public.mv_account_balances;
    mv_name := 'mv_account_balances'; refresh_seconds := elapsed; row_count := cnt;
    RETURN NEXT;

    -- 2. mv_chart_of_accounts (no deps)
    start_time := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY public.mv_chart_of_accounts;
    end_time := clock_timestamp();
    elapsed := EXTRACT(EPOCH FROM (end_time - start_time));
    SELECT COUNT(*) INTO cnt FROM public.mv_chart_of_accounts;
    mv_name := 'mv_chart_of_accounts'; refresh_seconds := elapsed; row_count := cnt;
    RETURN NEXT;

    -- 3. mv_trial_balance (depends on accounts)
    start_time := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY public.mv_trial_balance;
    end_time := clock_timestamp();
    elapsed := EXTRACT(EPOCH FROM (end_time - start_time));
    SELECT COUNT(*) INTO cnt FROM public.mv_trial_balance;
    mv_name := 'mv_trial_balance'; refresh_seconds := elapsed; row_count := cnt;
    RETURN NEXT;

    -- 4. mv_final_accounts (depends on accounts)
    start_time := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY public.mv_final_accounts;
    end_time := clock_timestamp();
    elapsed := EXTRACT(EPOCH FROM (end_time - start_time));
    SELECT COUNT(*) INTO cnt FROM public.mv_final_accounts;
    mv_name := 'mv_final_accounts'; refresh_seconds := elapsed; row_count := cnt;
    RETURN NEXT;

    -- 5. mv_journal_summary (depends on journal header)
    start_time := clock_timestamp();
    REFRESH MATERIALIZED VIEW CONCURRENTLY public.mv_journal_summary;
    end_time := clock_timestamp();
    elapsed := EXTRACT(EPOCH FROM (end_time - start_time));
    SELECT COUNT(*) INTO cnt FROM public.mv_journal_summary;
    mv_name := 'mv_journal_summary'; refresh_seconds := elapsed; row_count := cnt;
    RETURN NEXT;
END;
$$;


ALTER FUNCTION public.refresh_critical_mvs() OWNER TO postgres;

--
-- Name: FUNCTION refresh_critical_mvs(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.refresh_critical_mvs() IS 'Refreshes all 5 critical materialized views in dependency order. Returns (mv_name, refresh_seconds, row_count).';


--
-- Name: rejectrequest(bigint, integer, text, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.rejectrequest(IN p_requestid bigint, IN p_approverid integer, IN p_reason text, IN p_ipaddress character varying, IN p_useragent character varying, OUT p_result character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_status VARCHAR(20);
    v_currentlevel INTEGER;
    v_workflowid INTEGER;
    v_levelid INTEGER;
BEGIN
    SELECT status, currentlevel, workflowid
    INTO v_status, v_currentlevel, v_workflowid
    FROM tblapprovalrequests WHERE requestid = p_requestid;

    IF NOT FOUND THEN
        p_result := 'ERROR: Request not found';
        RETURN;
    END IF;

    IF v_status <> 'PENDING' THEN
        p_result := 'ERROR: Request is not pending (status: ' || v_status || ')';
        RETURN;
    END IF;

    SELECT levelid INTO v_levelid
    FROM tblapprovallevels WHERE workflowid = v_workflowid AND levelnumber = v_currentlevel;

    -- Log rejection
    INSERT INTO tblapprovalactions
        (requestid, levelid, approverid, actiontype, oldstatus, newstatus, fromlevel, tolevel, comments, ipaddress, useragent)
    VALUES (p_requestid, v_levelid, p_approverid, 'REJECTED', 'PENDING', 'REJECTED', v_currentlevel, v_currentlevel, p_reason, p_ipaddress, p_useragent);

    -- Update request
    UPDATE tblapprovalrequests
    SET status = 'REJECTED', completedate = NOW(), completedby = p_approverid
    WHERE requestid = p_requestid;

    -- Audit
    INSERT INTO tblapprovalaudit (requestid, eventtype, performedby, ipaddress, useragent, newdata)
    VALUES (p_requestid, 'REJECTED', p_approverid, p_ipaddress, p_useragent,
            jsonb_build_object('status', 'REJECTED', 'reason', p_reason));

    -- Notify requester
    INSERT INTO tblnotifications (userid, title, message, notificationtype, priority, reftype, refid)
    SELECT r.requesterid, 'Request ' || r.requestno || ' REJECTED',
           'Your request ' || r.requestno || ' was rejected. Reason: ' || COALESCE(p_reason, '(no reason provided)'),
           'APPROVAL', 'HIGH', 'APPROVAL_REQUEST', r.requestid
    FROM tblapprovalrequests r WHERE r.requestid = p_requestid;

    p_result := 'SUCCESS: Request REJECTED';
END;
$$;


ALTER PROCEDURE public.rejectrequest(IN p_requestid bigint, IN p_approverid integer, IN p_reason text, IN p_ipaddress character varying, IN p_useragent character varying, OUT p_result character varying) OWNER TO postgres;

--
-- Name: restoredb(character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.restoredb(IN p_databasename character varying, IN p_backuppath character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RAISE NOTICE 'Use pg_restore from the OS to restore %.', p_databasename;
END;
$$;


ALTER PROCEDURE public.restoredb(IN p_databasename character varying, IN p_backuppath character varying) OWNER TO postgres;

--
-- Name: searchinaccounts(character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.searchinaccounts(p_searchtext character varying, p_bracode integer) RETURNS TABLE(accountcode integer, accountid character varying, accountnamear character varying, accountnameen character varying)
    LANGUAGE sql
    AS $$
    SELECT accountcode, accountid, accountnamear, accountnameen
    FROM tblaccounts
    WHERE accountnamear ILIKE '%'||p_searchtext||'%'
       OR accountid ILIKE '%'||p_searchtext||'%'
    ORDER BY accountid
    LIMIT 50;
$$;


ALTER FUNCTION public.searchinaccounts(p_searchtext character varying, p_bracode integer) OWNER TO postgres;

--
-- Name: searchincustomers(character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.searchincustomers(p_searchtext character varying, p_bracode integer) RETURNS TABLE(customercode integer, customerid character varying, customernamear character varying, customernameen character varying, mobile character varying, email character varying, balance numeric)
    LANGUAGE sql
    AS $$
    SELECT customercode, customerid, customernamear, customernameen, mobile, email, balance
    FROM tblcustomers
    WHERE isactive = true
      AND (customernamear ILIKE '%'||p_searchtext||'%'
           OR customerid ILIKE '%'||p_searchtext||'%'
           OR mobile LIKE '%'||p_searchtext||'%')
    ORDER BY customernamear
    LIMIT 100;
$$;


ALTER FUNCTION public.searchincustomers(p_searchtext character varying, p_bracode integer) OWNER TO postgres;

--
-- Name: searchinsuppliers(character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.searchinsuppliers(p_searchtext character varying, p_bracode integer) RETURNS TABLE(suppliercode integer, supplierid character varying, suppliernamear character varying, suppliernameen character varying, mobile character varying, email character varying, balance numeric)
    LANGUAGE sql
    AS $$
    SELECT suppliercode, supplierid, suppliernamear, suppliernameen, mobile, email, balance
    FROM tblsuppliers
    WHERE isactive = true
      AND (suppliernamear ILIKE '%'||p_searchtext||'%'
           OR supplierid ILIKE '%'||p_searchtext||'%'
           OR mobile LIKE '%'||p_searchtext||'%')
    ORDER BY suppliernamear
    LIMIT 100;
$$;


ALTER FUNCTION public.searchinsuppliers(p_searchtext character varying, p_bracode integer) OWNER TO postgres;

--
-- Name: setbondispost(integer, bigint, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.setbondispost(p_bondpost integer, p_jno bigint, p_bracode integer) RETURNS TABLE(journalcode bigint, isposted boolean)
    LANGUAGE sql
    AS $$
    SELECT journalcode, isposted
    FROM tbljournalheader
    WHERE journalcode = p_jno;
$$;


ALTER FUNCTION public.setbondispost(p_bondpost integer, p_jno bigint, p_bracode integer) OWNER TO postgres;

--
-- Name: showbillbondbody(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.showbillbondbody(p_no integer, p_optype integer) RETURNS TABLE(linenumber integer, productcode integer, productnamear character varying, unitcode integer, quantity numeric, unitprice numeric, discountamount numeric, taxamount numeric, total numeric)
    LANGUAGE sql
    AS $$
    SELECT b.linenumber, b.productcode, p.productnamear, b.unitcode,
           b.quantity, b.unitprice, b.discountamount, b.taxamount, b.total
    FROM tbloperationbody b
    JOIN tbloperationheader h ON h.operationcode = b.operationcode
    LEFT JOIN tblproducts p ON p.productcode = b.productcode
    WHERE h.operationcode = p_no OR h.operationid = 'OP-'||p_no
    ORDER BY b.linenumber;
$$;


ALTER FUNCTION public.showbillbondbody(p_no integer, p_optype integer) OWNER TO postgres;

--
-- Name: showbillbondheader(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.showbillbondheader(p_no integer, p_optype integer) RETURNS TABLE(operationcode bigint, operationid character varying, operationdate date, customercode integer, suppliercode integer, subtotal numeric, discountamount numeric, taxamount numeric, total numeric, isposted boolean)
    LANGUAGE sql
    AS $$
    SELECT operationcode, operationid, operationdate, customercode, suppliercode,
           subtotal, discountamount, taxamount, total, isposted
    FROM tbloperationheader
    WHERE (operationcode = p_no OR operationid = 'OP-'||p_no)
    ORDER BY operationcode DESC LIMIT 1;
$$;


ALTER FUNCTION public.showbillbondheader(p_no integer, p_optype integer) OWNER TO postgres;

--
-- Name: showbondbody(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.showbondbody(p_bondno integer) RETURNS TABLE(linenumber integer, accountcode integer, accountnamear character varying, debit numeric, credit numeric)
    LANGUAGE sql
    AS $$
    SELECT b.linenumber, b.accountcode, a.accountnamear, b.debit, b.credit
    FROM tblbondbody b
    JOIN tblbondheader h ON h.bondcode = b.bondcode
    LEFT JOIN tblaccounts a ON a.accountcode = b.accountcode
    WHERE h.bondcode = p_bondno OR h.bondid = 'B-'||p_bondno
    ORDER BY b.linenumber;
$$;


ALTER FUNCTION public.showbondbody(p_bondno integer) OWNER TO postgres;

--
-- Name: showbondheader(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.showbondheader(p_bondno integer) RETURNS TABLE(bondcode bigint, bondid character varying, bonddate date, amount numeric, description character varying, isposted boolean)
    LANGUAGE sql
    AS $$
    SELECT bondcode, bondid, bonddate, amount, description, isposted
    FROM tblbondheader
    WHERE bondcode = p_bondno OR bondid = 'B-'||p_bondno
    ORDER BY bondcode DESC LIMIT 1;
$$;


ALTER FUNCTION public.showbondheader(p_bondno integer) OWNER TO postgres;

--
-- Name: showjournalbody(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.showjournalbody(p_jno integer) RETURNS TABLE(linenumber integer, accountcode integer, accountnamear character varying, description character varying, debit numeric, credit numeric)
    LANGUAGE sql
    AS $$
    SELECT b.linenumber, b.accountcode, a.accountnamear,
           b.description, b.debit, b.credit
    FROM tbljournalbody b
    JOIN tbljournalheader h ON h.journalcode = b.journalcode
    LEFT JOIN tblaccounts a  ON a.accountcode  = b.accountcode
    WHERE h.journalcode = p_jno OR h.journalid = 'J-'||p_jno
    ORDER BY b.linenumber;
$$;


ALTER FUNCTION public.showjournalbody(p_jno integer) OWNER TO postgres;

--
-- Name: showjournalheader(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.showjournalheader(p_jno integer) RETURNS TABLE(journalcode bigint, journaldate date, description character varying, totaldebit numeric, totalcredit numeric, isposted boolean)
    LANGUAGE sql
    AS $$
    SELECT journalcode, journaldate, description, totaldebit, totalcredit, isposted
    FROM tbljournalheader
    WHERE journalcode = p_jno OR journalid = 'J-'||p_jno
    ORDER BY journalcode DESC LIMIT 1;
$$;


ALTER FUNCTION public.showjournalheader(p_jno integer) OWNER TO postgres;

--
-- Name: sp_expireoldsessions(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_expireoldsessions()
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE public.tblSessions
       SET IsActive = FALSE,
           LogoutAt = CURRENT_TIMESTAMP
     WHERE IsActive = TRUE
       AND ExpiresAt < CURRENT_TIMESTAMP;

    UPDATE public.tblUsers
       SET IsOnline = FALSE
     WHERE UserCode IN (
         SELECT UserCode FROM public.tblSessions
          WHERE IsActive = FALSE AND LogoutAt > CURRENT_TIMESTAMP - INTERVAL '1 minute'
     )
       AND IsOnline = TRUE;
END;
$$;


ALTER PROCEDURE public.sp_expireoldsessions() OWNER TO postgres;

--
-- Name: sp_getlowstockproducts(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_getlowstockproducts(p_store_code integer DEFAULT NULL::integer) RETURNS TABLE(productcode integer, productid character varying, productnamear character varying, storecode integer, storenamear character varying, qtyonhand numeric, qtyreserved numeric, minstocklevel numeric, reorderlevel numeric, shortage numeric)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN QUERY
    SELECT p."ProductCode", p."ProductID", p."ProductNameAr",
           st."StoreCode", st."StoreNameAr",
           COALESCE(sp."QtyOnHand", 0),
           COALESCE(sp."QtyReserved", 0),
           p."MinStockLevel", p."ReorderLevel",
           p."MinStockLevel" - COALESCE(sp."QtyOnHand", 0)
      FROM public."tblProducts" p
      CROSS JOIN public."tblStores" st
      LEFT JOIN public."tblStoreProducts" sp
             ON p."ProductCode" = sp."ProductCode"
            AND st."StoreCode"  = sp."StoreCode"
            AND sp."IsActive"   = TRUE
     WHERE p."IsActive"        = TRUE
       AND p."IsInventoryItem" = TRUE
       AND (p_store_code IS NULL OR st."StoreCode" = p_store_code)
       AND COALESCE(sp."QtyOnHand", 0) <= COALESCE(p."MinStockLevel", 0)
     ORDER BY (COALESCE(sp."QtyOnHand", 0) - p."MinStockLevel") ASC;
END;
$$;


ALTER FUNCTION public.sp_getlowstockproducts(p_store_code integer) OWNER TO postgres;

--
-- Name: sp_getproductstock(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_getproductstock(p_product_code integer, p_store_code integer DEFAULT NULL::integer) RETURNS TABLE(productcode integer, productid character varying, productnamear character varying, storecode integer, storenamear character varying, qtyonhand numeric, qtyreserved numeric, qtyavailable numeric, avgcost numeric, batchid integer, batchno character varying, expirydate date)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    IF p_store_code IS NULL THEN
        RETURN QUERY
        SELECT p."ProductCode", p."ProductID", p."ProductNameAr",
               st."StoreCode", st."StoreNameAr",
               COALESCE(sp."QtyOnHand", 0),
               COALESCE(sp."QtyReserved", 0),
               COALESCE(sp."QtyOnHand", 0) - COALESCE(sp."QtyReserved", 0),
               COALESCE(sp."AvgCost", 0),
               NULL::INT, NULL::VARCHAR, NULL::DATE
          FROM public."tblProducts" p
          CROSS JOIN public."tblStores" st
          LEFT JOIN public."tblStoreProducts" sp
                 ON p."ProductCode" = sp."ProductCode"
                AND st."StoreCode"  = sp."StoreCode"
                AND sp."IsActive"   = TRUE
         WHERE p."ProductCode" = p_product_code
           AND st."IsActive"   = TRUE
         ORDER BY st."StoreNameAr";
    ELSE
        RETURN QUERY
        SELECT p."ProductCode", p."ProductID", p."ProductNameAr",
               st."StoreCode", st."StoreNameAr",
               COALESCE(sp."QtyOnHand", 0),
               COALESCE(sp."QtyReserved", 0),
               COALESCE(sp."QtyOnHand", 0) - COALESCE(sp."QtyReserved", 0),
               COALESCE(sp."AvgCost", 0),
               sp."BatchID", b."BatchNo", b."ExpiryDate"
          FROM public."tblProducts" p
          INNER JOIN public."tblStores" st ON st."StoreCode" = p_store_code
          LEFT JOIN public."tblStoreProducts" sp
                 ON p."ProductCode" = sp."ProductCode"
                AND st."StoreCode"  = sp."StoreCode"
                AND sp."IsActive"   = TRUE
          LEFT JOIN public."tblProductBatches" b ON sp."BatchID" = b."BatchID"
         WHERE p."ProductCode" = p_product_code;
    END IF;
END;
$$;


ALTER FUNCTION public.sp_getproductstock(p_product_code integer, p_store_code integer) OWNER TO postgres;

--
-- Name: sp_login(character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_login(IN p_user_id character varying, IN p_password character varying, IN p_computer_name character varying, IN p_ip_address character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_password_hash BYTEA;
    v_salt          BYTEA;
    v_locked_until  TIMESTAMP;
    v_user_code     INT;
    v_token         UUID;
BEGIN
    -- Get user credentials
    SELECT "UserPassword", "Salt", "LockedUntil"
      INTO v_password_hash, v_salt, v_locked_until
      FROM public."tblUsers"
     WHERE "UserID"  = p_user_id
       AND "IsActive" = TRUE;

    IF NOT FOUND THEN
        RAISE NOTICE 'sp_Login: user not found or inactive';
        RETURN;
    END IF;

    -- Check lock status
    IF v_locked_until IS NOT NULL AND v_locked_until > CURRENT_TIMESTAMP THEN
        RAISE NOTICE 'sp_Login: account locked';
        RETURN;
    END IF;

    -- For the demo, password comparison is plain text (real app uses PBKDF2).
    IF convert_from(v_password_hash, 'UTF8') = p_password THEN
        v_token := gen_random_uuid();
        v_user_code := (SELECT "UserCode" FROM public."tblUsers" WHERE "UserID" = p_user_id);

        -- Create session
        INSERT INTO public."tblSessions" (
            "SessionToken", "UserCode", "UserID", "BranchCode", "MachineName", "IPAddress",
            "CreatedAt", "LastActivityAt", "ExpiresAt", "IsActive")
        SELECT v_token, "UserCode", "UserID", "BranchCode", p_computer_name, p_ip_address,
               CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '8 hours', TRUE
          FROM public."tblUsers" WHERE "UserID" = p_user_id;

        -- Update login info
        UPDATE public."tblUsers"
           SET "LastLoginAt"   = CURRENT_TIMESTAMP,
               "LoginAttempts" = 0,
               "IsOnline"      = TRUE
         WHERE "UserID" = p_user_id;
    ELSE
        -- Increment failed attempts
        UPDATE public."tblUsers"
           SET "LoginAttempts" = "LoginAttempts" + 1,
               "LockedUntil"   = CASE WHEN "LoginAttempts" >= 4
                                    THEN CURRENT_TIMESTAMP + INTERVAL '30 minutes'
                                    ELSE NULL END
         WHERE "UserID" = p_user_id;
    END IF;
END;
$$;


ALTER PROCEDURE public.sp_login(IN p_user_id character varying, IN p_password character varying, IN p_computer_name character varying, IN p_ip_address character varying) OWNER TO postgres;

--
-- Name: sp_logout(uuid); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_logout(IN p_token uuid)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_user_code INT;
BEGIN
    SELECT UserCode INTO v_user_code
      FROM public.tblSessions
     WHERE SessionToken = p_token AND IsActive = TRUE;

    UPDATE public.tblSessions
       SET IsActive = FALSE,
           LogoutAt = CURRENT_TIMESTAMP
     WHERE SessionToken = p_token;

    IF v_user_code IS NOT NULL THEN
        UPDATE public.tblUsers SET IsOnline = FALSE WHERE UserCode = v_user_code;
    END IF;
END;
$$;


ALTER PROCEDURE public.sp_logout(IN p_token uuid) OWNER TO postgres;

--
-- Name: sp_validatesession(uuid); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_validatesession(IN p_token uuid, OUT o_is_valid boolean, OUT o_user_code integer, OUT o_user_name character varying, OUT o_is_admin boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    SELECT TRUE, s.UserCode, u.UserNameAr, u.IsAdmin
      INTO o_is_valid, o_user_code, o_user_name, o_is_admin
      FROM public.tblSessions s
      JOIN public.tblUsers u ON s.UserCode = u.UserCode
     WHERE s.SessionToken = p_token
       AND s.IsActive     = TRUE
       AND s.ExpiresAt    > CURRENT_TIMESTAMP;

    IF o_is_valid THEN
        UPDATE public.tblSessions
           SET ExpiresAt = CURRENT_TIMESTAMP + INTERVAL '8 hours',
               LastActivityAt = CURRENT_TIMESTAMP
         WHERE SessionToken = p_token;
    ELSE
        o_is_valid := FALSE; o_user_code := NULL; o_user_name := NULL; o_is_admin := FALSE;
    END IF;
END;
$$;


ALTER PROCEDURE public.sp_validatesession(IN p_token uuid, OUT o_is_valid boolean, OUT o_user_code integer, OUT o_user_name character varying, OUT o_is_admin boolean) OWNER TO postgres;

--
-- Name: submitforapproval(character varying, bigint, integer, numeric, integer, numeric, text, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.submitforapproval(IN p_sourcetype character varying, IN p_sourceid bigint, IN p_requesterid integer, IN p_totalsum numeric, IN p_currencycode integer, IN p_exchangerate numeric, IN p_description text, IN p_priority character varying, OUT p_requestid bigint, OUT p_requestno character varying, OUT p_result character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_workflowid INTEGER;
    v_levelid INTEGER;
    v_levelnumber INTEGER;
    v_totallevels INTEGER;
    v_max_level INTEGER;
    v_max_level_id INTEGER;
    v_max_required_role VARCHAR(50);
    v_request_count INTEGER;
BEGIN
    -- Find the active workflow for this source type
    SELECT workflowid INTO v_workflowid
    FROM tblapprovalworkflows
    WHERE sourcetype = p_sourcetype AND isactive = TRUE
    ORDER BY workflowid
    LIMIT 1;

    IF v_workflowid IS NULL THEN
        p_result := 'ERROR: No active workflow defined for source type ' || p_sourcetype;
        RETURN;
    END IF;

    -- Count total levels
    SELECT COUNT(*) INTO v_totallevels
    FROM tblapprovallevels
    WHERE workflowid = v_workflowid AND isactive = TRUE;

    IF v_totallevels = 0 THEN
        p_result := 'ERROR: Workflow has no active levels';
        RETURN;
    END IF;

    -- Generate request number
    v_request_count := (SELECT COUNT(*) FROM tblapprovalrequests WHERE requesterid = p_requesterid) + 1;
    p_requestno := 'AR-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || p_requesterid || '-' || v_request_count;

    -- Insert the request
    INSERT INTO tblapprovalrequests
        (requestno, workflowid, sourcetype, sourceid, requesterid, totalsum, currencycode, exchangerate, description, status, currentlevel, totallevels, priority, duedate)
    VALUES
        (p_requestno, v_workflowid, p_sourcetype, p_sourceid, p_requesterid, p_totalsum, p_currencycode, COALESCE(p_exchangerate, 1), p_description, 'PENDING', 1, v_totallevels, COALESCE(p_priority, 'NORMAL'), NOW() + INTERVAL '48 hours')
    RETURNING requestid INTO p_requestid;

    -- Log SUBMITTED action
    INSERT INTO tblapprovalactions
        (requestid, levelid, approverid, actiontype, oldstatus, newstatus, fromlevel, tolevel, comments)
    SELECT p_requestid, levelid, p_requesterid, 'SUBMITTED', NULL, 'PENDING', 0, 1, 'Request submitted for approval'
    FROM tblapprovallevels
    WHERE workflowid = v_workflowid AND levelnumber = 1;

    p_result := 'SUCCESS: Request ' || p_requestno || ' submitted (ID: ' || p_requestid || ')';
END;
$$;


ALTER PROCEDURE public.submitforapproval(IN p_sourcetype character varying, IN p_sourceid bigint, IN p_requesterid integer, IN p_totalsum numeric, IN p_currencycode integer, IN p_exchangerate numeric, IN p_description text, IN p_priority character varying, OUT p_requestid bigint, OUT p_requestno character varying, OUT p_result character varying) OWNER TO postgres;

--
-- Name: trg_fn_storeproducts_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_fn_storeproducts_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.qtyreserved > NEW.qtyonhand THEN
        RAISE EXCEPTION 'الكمية المحجوزة (%) تتجاوز المتاحة (%)', NEW.qtyreserved, NEW.qtyonhand;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_fn_storeproducts_update() OWNER TO postgres;

--
-- Name: trg_fn_users_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_fn_users_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF OLD.userpassword IS DISTINCT FROM NEW.userpassword THEN
        NEW.passwordhistory2   := OLD.passwordhistory1;
        NEW.passwordhistory1   := OLD.userpassword;
        NEW.passwordlastchanged := CURRENT_TIMESTAMP;
        NEW.mustchangepassword := FALSE;
        NEW.loginattempts      := 0;
        NEW.lockeduntil        := NULL;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_fn_users_update() OWNER TO postgres;

--
-- Name: updateaccount(integer, integer, character varying, integer, integer, integer, numeric, numeric, numeric, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.updateaccount(IN p_acccode integer, IN p_accparentcode integer, IN p_accname character varying, IN p_acclevel integer, IN p_acctype integer, IN p_accreport integer, IN p_accdebitor numeric, IN p_acccreditor numeric, IN p_accbalance numeric, IN p_islock integer, IN p_bracode integer)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.updateaccount(IN p_acccode integer, IN p_accparentcode integer, IN p_accname character varying, IN p_acclevel integer, IN p_acctype integer, IN p_accreport integer, IN p_accdebitor numeric, IN p_acccreditor numeric, IN p_accbalance numeric, IN p_islock integer, IN p_bracode integer) OWNER TO postgres;

--
-- Name: updatebank(integer, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.updatebank(IN p_bankcode integer, IN p_bankname character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tblbanks SET banknamear = p_bankName WHERE bankcode = p_bankCode;
END;
$$;


ALTER PROCEDURE public.updatebank(IN p_bankcode integer, IN p_bankname character varying) OWNER TO postgres;

--
-- Name: updatebusinessunit(integer, character varying, character varying, character varying, integer, boolean, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updatebusinessunit(p_businessunitcode integer, p_businessunitid character varying, p_namear character varying, p_nameen character varying, p_parentbusinessunitcode integer, p_isactive boolean, p_notes text, p_edituser integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tbldim_businessunits SET
        businessunitid=p_businessunitid, namear=p_namear, nameen=p_nameen,
        parentbusinessunitcode=p_parentbusinessunitcode,
        isactive=COALESCE(p_isactive,isactive), notes=p_notes,
        edituser=p_edituser, editdate=CURRENT_TIMESTAMP
    WHERE businessunitcode=p_businessunitcode;
END$$;


ALTER FUNCTION public.updatebusinessunit(p_businessunitcode integer, p_businessunitid character varying, p_namear character varying, p_nameen character varying, p_parentbusinessunitcode integer, p_isactive boolean, p_notes text, p_edituser integer) OWNER TO postgres;

--
-- Name: updatecompany(integer, character varying, character varying, character varying, character varying, character varying, character varying, bytea, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.updatecompany(IN p_bracode integer, IN p_braname character varying, IN p_braaddress character varying, IN p_braactivity character varying, IN p_bratel character varying, IN p_brafax character varying, IN p_braemail character varying, IN p_bralogo bytea, IN p_testimage character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tblbranches
       SET branchnamear = p_braName,
           address      = p_braAddress,
           phone        = p_braTel,
           email        = p_braEmail
     WHERE branchcode = p_braCode;
END;
$$;


ALTER PROCEDURE public.updatecompany(IN p_bracode integer, IN p_braname character varying, IN p_braaddress character varying, IN p_braactivity character varying, IN p_bratel character varying, IN p_brafax character varying, IN p_braemail character varying, IN p_bralogo bytea, IN p_testimage character varying) OWNER TO postgres;

--
-- Name: updatecurrency(character varying, integer, numeric, character varying, character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.updatecurrency(IN p_currname character varying, IN p_currtype integer, IN p_currval numeric, IN p_currpenny character varying, IN p_currsymbole character varying, IN p_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tblcurrencies
       SET currencynamear = p_currName,
           symbol         = p_currSymbole,
           exchangerate   = p_currVal
     WHERE currencycode = p_id;
END;
$$;


ALTER PROCEDURE public.updatecurrency(IN p_currname character varying, IN p_currtype integer, IN p_currval numeric, IN p_currpenny character varying, IN p_currsymbole character varying, IN p_id integer) OWNER TO postgres;

--
-- Name: updatedepartment(integer, character varying, character varying, character varying, integer, integer, boolean, date, date, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updatedepartment(p_departmentcode integer, p_departmentid character varying, p_namear character varying, p_nameen character varying, p_parentdepartmentcode integer, p_managerusercode integer, p_isactive boolean, p_effectivedate date, p_enddate date, p_notes text, p_edituser integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tbldim_departments SET
        departmentid = p_departmentid,
        namear = p_namear,
        nameen = p_nameen,
        parentdepartmentcode = p_parentdepartmentcode,
        managerusercode = p_managerusercode,
        isactive = COALESCE(p_isactive, isactive),
        effectivedate = COALESCE(p_effectivedate, effectivedate),
        enddate = p_enddate,
        notes = p_notes,
        edituser = p_edituser,
        editdate = CURRENT_TIMESTAMP
    WHERE departmentcode = p_departmentcode;
END$$;


ALTER FUNCTION public.updatedepartment(p_departmentcode integer, p_departmentid character varying, p_namear character varying, p_nameen character varying, p_parentdepartmentcode integer, p_managerusercode integer, p_isactive boolean, p_effectivedate date, p_enddate date, p_notes text, p_edituser integer) OWNER TO postgres;

--
-- Name: updatefund(integer, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.updatefund(IN p_fundcode integer, IN p_fundname character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tblfunds SET fundnamear = p_fundName WHERE fundcode = p_fundCode;
END;
$$;


ALTER PROCEDURE public.updatefund(IN p_fundcode integer, IN p_fundname character varying) OWNER TO postgres;

--
-- Name: updateproductdata(integer, numeric, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.updateproductdata(IN p_prodcode integer, IN p_qty numeric, IN p_optype integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Generic product last-purchase-price update
    UPDATE tblproducts
       SET lastpurchaseprice = CASE WHEN p_optype = 2 THEN p_qty ELSE lastpurchaseprice END,
           lastsaleprice     = CASE WHEN p_optype = 1 THEN p_qty ELSE lastsaleprice END
     WHERE productcode = p_prodcode;
END;
$$;


ALTER PROCEDURE public.updateproductdata(IN p_prodcode integer, IN p_qty numeric, IN p_optype integer) OWNER TO postgres;

--
-- Name: updateprofitcenter(integer, character varying, character varying, character varying, integer, boolean, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updateprofitcenter(p_profitcentercode integer, p_profitcenterid character varying, p_namear character varying, p_nameen character varying, p_parentprofitcentercode integer, p_isactive boolean, p_notes text, p_edituser integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tbldim_profitcenters SET
        profitcenterid=p_profitcenterid, namear=p_namear, nameen=p_nameen,
        parentprofitcentercode=p_parentprofitcentercode,
        isactive=COALESCE(p_isactive,isactive), notes=p_notes,
        edituser=p_edituser, editdate=CURRENT_TIMESTAMP
    WHERE profitcentercode=p_profitcentercode;
END$$;


ALTER FUNCTION public.updateprofitcenter(p_profitcentercode integer, p_profitcenterid character varying, p_namear character varying, p_nameen character varying, p_parentprofitcentercode integer, p_isactive boolean, p_notes text, p_edituser integer) OWNER TO postgres;

--
-- Name: updateproject(integer, character varying, character varying, character varying, integer, character varying, date, date, numeric, numeric, character varying, boolean, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updateproject(p_projectcode integer, p_projectid character varying, p_namear character varying, p_nameen character varying, p_parentprojectcode integer, p_projecttype character varying, p_startdate date, p_enddate date, p_budgetamount numeric, p_actualamount numeric, p_projectstatus character varying, p_isactive boolean, p_notes text, p_edituser integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tbldim_projects SET
        projectid=p_projectid, namear=p_namear, nameen=p_nameen,
        parentprojectcode=p_parentprojectcode, projecttype=p_projecttype,
        startdate=p_startdate, enddate=p_enddate,
        budgetamount=COALESCE(p_budgetamount,budgetamount),
        actualamount=COALESCE(p_actualamount,actualamount),
        projectstatus=COALESCE(p_projectstatus,projectstatus),
        isactive=COALESCE(p_isactive,isactive),
        notes=p_notes, edituser=p_edituser, editdate=CURRENT_TIMESTAMP
    WHERE projectcode=p_projectcode;
END$$;


ALTER FUNCTION public.updateproject(p_projectcode integer, p_projectid character varying, p_namear character varying, p_nameen character varying, p_parentprojectcode integer, p_projecttype character varying, p_startdate date, p_enddate date, p_budgetamount numeric, p_actualamount numeric, p_projectstatus character varying, p_isactive boolean, p_notes text, p_edituser integer) OWNER TO postgres;

--
-- Name: updatesegment(integer, character varying, character varying, character varying, character varying, integer, boolean, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updatesegment(p_segmentcode integer, p_segmentid character varying, p_namear character varying, p_nameen character varying, p_segmenttype character varying, p_parentsegmentcode integer, p_isactive boolean, p_notes text, p_edituser integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tbldim_segments SET
        segmentid=p_segmentid, namear=p_namear, nameen=p_nameen,
        segmenttype=COALESCE(p_segmenttype,segmenttype),
        parentsegmentcode=p_parentsegmentcode,
        isactive=COALESCE(p_isactive,isactive), notes=p_notes,
        edituser=p_edituser, editdate=CURRENT_TIMESTAMP
    WHERE segmentcode=p_segmentcode;
END$$;


ALTER FUNCTION public.updatesegment(p_segmentcode integer, p_segmentid character varying, p_namear character varying, p_nameen character varying, p_segmenttype character varying, p_parentsegmentcode integer, p_isactive boolean, p_notes text, p_edituser integer) OWNER TO postgres;

--
-- Name: updatesessionactivity(uuid); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.updatesessionactivity(IN p_sessiontoken uuid)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tblsessions
       SET lastactivityat = CURRENT_TIMESTAMP,
           expiresat      = CURRENT_TIMESTAMP + INTERVAL '1 hour'
     WHERE sessiontoken = p_sessiontoken AND isactive = true;
END;
$$;


ALTER PROCEDURE public.updatesessionactivity(IN p_sessiontoken uuid) OWNER TO postgres;

--
-- Name: updateuser(integer, character varying, character varying, character varying, character varying, character varying, bytea, integer, character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.updateuser(IN p_usercode integer, IN p_userfname character varying, IN p_userid character varying, IN p_pwd character varying, IN p_usermobile character varying, IN p_useremail character varying, IN p_userimg bytea, IN p_bracode integer, IN p_testimage character varying, IN p_passwordsalt character varying, IN p_passwordhash character varying, IN p_passwordalgorithm character varying)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE public.updateuser(IN p_usercode integer, IN p_userfname character varying, IN p_userid character varying, IN p_pwd character varying, IN p_usermobile character varying, IN p_useremail character varying, IN p_userimg bytea, IN p_bracode integer, IN p_testimage character varying, IN p_passwordsalt character varying, IN p_passwordhash character varying, IN p_passwordalgorithm character varying) OWNER TO postgres;

--
-- Name: upgradeuserpassword(integer, character varying, character varying, character varying, integer, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.upgradeuserpassword(IN p_usercode integer, IN p_passwordsalt character varying, IN p_passwordhash character varying, IN p_passwordalgorithm character varying, IN p_passworditerations integer, IN p_pwd character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE tblusers
       SET userpassword = CASE WHEN p_passwordhash IS NULL OR p_passwordhash = '' THEN userpassword
                               ELSE convert_from(decode(p_passwordhash, 'base64'), 'UTF8')::bytea END,
           salt         = CASE WHEN p_passwordsalt IS NULL OR p_passwordsalt = '' THEN salt
                               ELSE convert_from(decode(p_passwordsalt, 'base64'), 'UTF8')::bytea END,
           passwordlastchanged = CURRENT_TIMESTAMP
     WHERE usercode = p_usercode;
END;
$$;


ALTER PROCEDURE public.upgradeuserpassword(IN p_usercode integer, IN p_passwordsalt character varying, IN p_passwordhash character varying, IN p_passwordalgorithm character varying, IN p_passworditerations integer, IN p_pwd character varying) OWNER TO postgres;

--
-- Name: validatealldimensions(integer, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validatealldimensions(p_departmentcode integer, p_projectcode integer, p_businessunitcode integer, p_segmentcode integer, p_profitcentercode integer, p_costcentercode integer) RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE v_bad TEXT := '';
BEGIN
    IF NOT validateDimension('DEPARTMENT',p_departmentcode)   THEN v_bad := v_bad || 'DEPT,'; END IF;
    IF NOT validateDimension('PROJECT',p_projectcode)         THEN v_bad := v_bad || 'PROJ,'; END IF;
    IF NOT validateDimension('BUSINESSUNIT',p_businessunitcode) THEN v_bad := v_bad || 'BU,';  END IF;
    IF NOT validateDimension('SEGMENT',p_segmentcode)         THEN v_bad := v_bad || 'SEG,'; END IF;
    IF NOT validateDimension('PROFITCENTER',p_profitcentercode) THEN v_bad := v_bad || 'PC,';  END IF;
    IF NOT validateDimension('COSTCENTER',p_costcentercode)   THEN v_bad := v_bad || 'CC,';  END IF;
    IF v_bad = '' THEN RETURN NULL; END IF;
    RETURN substring(v_bad FROM 1 FOR length(v_bad)-1);
END$$;


ALTER FUNCTION public.validatealldimensions(p_departmentcode integer, p_projectcode integer, p_businessunitcode integer, p_segmentcode integer, p_profitcentercode integer, p_costcentercode integer) OWNER TO postgres;

--
-- Name: validatedimension(character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validatedimension(p_dimtype character varying, p_dimcode integer) RETURNS boolean
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE v_ok BOOLEAN := FALSE;
BEGIN
    IF p_dimcode IS NULL THEN RETURN TRUE; END IF;
    IF p_dimtype='DEPARTMENT' THEN
        SELECT isactive AND (enddate IS NULL OR enddate >= CURRENT_DATE)
          INTO v_ok FROM tbldim_departments WHERE departmentcode=p_dimcode;
    ELSIF p_dimtype='PROJECT' THEN
        SELECT isactive AND projectstatus='ACTIVE'
          INTO v_ok FROM tbldim_projects WHERE projectcode=p_dimcode;
    ELSIF p_dimtype='BUSINESSUNIT' THEN
        SELECT isactive INTO v_ok FROM tbldim_businessunits WHERE businessunitcode=p_dimcode;
    ELSIF p_dimtype='SEGMENT' THEN
        SELECT isactive INTO v_ok FROM tbldim_segments WHERE segmentcode=p_dimcode;
    ELSIF p_dimtype='PROFITCENTER' THEN
        SELECT isactive INTO v_ok FROM tbldim_profitcenters WHERE profitcentercode=p_dimcode;
    ELSIF p_dimtype='COSTCENTER' THEN
        SELECT isactive INTO v_ok FROM tblcostcenters WHERE costcentercode=p_dimcode;
    END IF;
    RETURN COALESCE(v_ok, FALSE);
END$$;


ALTER FUNCTION public.validatedimension(p_dimtype character varying, p_dimcode integer) OWNER TO postgres;

--
-- Name: validatesession(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validatesession(p_sessiontoken uuid) RETURNS TABLE(sessiontoken uuid, usercode integer, userid character varying, isactive boolean)
    LANGUAGE sql
    AS $$
    SELECT sessiontoken, usercode, userid, isactive
    FROM tblsessions
    WHERE sessiontoken = p_sessiontoken
      AND isactive = true
      AND (expiresat IS NULL OR expiresat > CURRENT_TIMESTAMP)
    LIMIT 1;
$$;


ALTER FUNCTION public.validatesession(p_sessiontoken uuid) OWNER TO postgres;

--
-- Name: verifyaccountfoundinjournalbady(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.verifyaccountfoundinjournalbady(p_acccode integer) RETURNS TABLE(usecount bigint)
    LANGUAGE sql
    AS $$
    SELECT COUNT(*)::bigint FROM tbljournalbody WHERE accountcode = p_acccode;
$$;


ALTER FUNCTION public.verifyaccountfoundinjournalbady(p_acccode integer) OWNER TO postgres;

--
-- Name: verifyaccounthavechildren(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.verifyaccounthavechildren(p_acccode integer, p_bracode integer) RETURNS TABLE(childcount bigint)
    LANGUAGE sql
    AS $$
    SELECT COUNT(*)::bigint FROM tblaccounts WHERE parentaccountcode = p_acccode;
$$;


ALTER FUNCTION public.verifyaccounthavechildren(p_acccode integer, p_bracode integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: tblaccounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblaccounts (
    accountcode integer NOT NULL,
    accountid character varying(50) NOT NULL,
    accountnamear character varying(200) NOT NULL,
    accountnameen character varying(200),
    accounttype character varying(50) NOT NULL,
    parentaccountcode integer,
    accountlevel integer DEFAULT 0,
    accountnature character varying(20) NOT NULL,
    ismainaccount boolean DEFAULT false,
    ispostable boolean DEFAULT true,
    openingbalance numeric(18,4) DEFAULT 0,
    currentbalance numeric(18,4) DEFAULT 0,
    isactive boolean DEFAULT true,
    notes text
);


ALTER TABLE public.tblaccounts OWNER TO postgres;

--
-- Name: mv_account_balances; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.mv_account_balances AS
 SELECT accountcode,
    accountid AS accountnumber,
    accountnamear AS accountname,
    parentaccountcode,
    accountlevel AS acclevel,
    accounttype AS accttype,
    currentbalance AS balance,
    ispostable AS islock,
    isactive,
    now() AS refreshed_at
   FROM public.tblaccounts a
  ORDER BY accountid
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mv_account_balances OWNER TO postgres;

--
-- Name: MATERIALIZED VIEW mv_account_balances; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON MATERIALIZED VIEW public.mv_account_balances IS 'Materialized view for account sheet and balance inquiries. Refresh hourly.';


--
-- Name: tblbudgets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblbudgets (
    budgetid bigint NOT NULL,
    periodid integer NOT NULL,
    accountid integer NOT NULL,
    branchid integer,
    costcenterid integer,
    budgetamount numeric(18,4) NOT NULL,
    actualamount numeric(18,4) DEFAULT 0,
    varianceamount numeric(18,4) GENERATED ALWAYS AS ((actualamount - budgetamount)) STORED,
    notes text,
    adduser integer,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    departmentcode integer,
    projectcode integer,
    businessunitcode integer,
    segmentcode integer,
    profitcentercode integer
);


ALTER TABLE public.tblbudgets OWNER TO postgres;

--
-- Name: mv_budget_vs_actual_summary; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.mv_budget_vs_actual_summary AS
 SELECT periodid AS period_id,
    accountid AS account_id,
    branchid AS branch_id,
    costcenterid AS cost_center_id,
    sum(budgetamount) AS budget_amount,
    sum(actualamount) AS actual_amount,
    sum(varianceamount) AS variance_amount,
        CASE
            WHEN (sum(budgetamount) = (0)::numeric) THEN NULL::numeric
            ELSE round(((sum(varianceamount) / NULLIF(sum(budgetamount), (0)::numeric)) * (100)::numeric), 2)
        END AS variance_pct,
    count(*) AS budget_line_count,
    now() AS refreshed_at
   FROM public.tblbudgets
  GROUP BY periodid, accountid, branchid, costcenterid
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mv_budget_vs_actual_summary OWNER TO postgres;

--
-- Name: mv_chart_of_accounts; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.mv_chart_of_accounts AS
 SELECT accountcode,
    accountid AS accountnumber,
    accountnamear AS accountname,
    parentaccountcode,
    accountlevel AS acclevel,
    accounttype AS acctype,
    accountnature AS accnature,
    isactive,
    ispostable AS islock,
    now() AS refreshed_at
   FROM public.tblaccounts a
  ORDER BY accountid
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mv_chart_of_accounts OWNER TO postgres;

--
-- Name: MATERIALIZED VIEW mv_chart_of_accounts; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON MATERIALIZED VIEW public.mv_chart_of_accounts IS 'Materialized view for chart of accounts tree (rptChartOfAccounts.rdlc). Refresh on schema change.';


--
-- Name: tbloperationheader; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbloperationheader (
    operationcode bigint NOT NULL,
    operationid character varying(30) NOT NULL,
    operationtype character varying(20) NOT NULL,
    operationdate date NOT NULL,
    fiscalyear integer NOT NULL,
    fiscalperiod integer NOT NULL,
    customercode integer,
    suppliercode integer,
    branchcode integer,
    storecode integer,
    currencycode integer,
    exchangerate numeric(18,8) DEFAULT 1.0,
    subtotal numeric(18,4) DEFAULT 0,
    discountpercent numeric(8,3) DEFAULT 0,
    discountamount numeric(18,4) DEFAULT 0,
    taxamount numeric(18,4) DEFAULT 0,
    additionalcharges numeric(18,4) DEFAULT 0,
    total numeric(18,4) DEFAULT 0,
    paidamount numeric(18,4) DEFAULT 0,
    remainingamount numeric(18,4) DEFAULT 0,
    paymentmethodcode integer,
    referenceno character varying(100),
    description character varying(500),
    isposted boolean DEFAULT false,
    postedat timestamp without time zone,
    postedby integer,
    iscancelled boolean DEFAULT false,
    createdby integer,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    notes text
);


ALTER TABLE public.tbloperationheader OWNER TO postgres;

--
-- Name: mv_customer_outstanding_balance; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.mv_customer_outstanding_balance AS
 SELECT customercode AS customer_code,
    COALESCE(sum(total) FILTER (WHERE (NOT iscancelled)), (0)::numeric) AS total_credit,
    COALESCE(sum(paidamount) FILTER (WHERE (NOT iscancelled)), (0)::numeric) AS total_debit,
    COALESCE(sum(remainingamount) FILTER (WHERE (NOT iscancelled)), (0)::numeric) AS balance,
    count(*) FILTER (WHERE (NOT iscancelled)) AS open_invoices,
    max(operationdate) AS last_invoice_date,
    now() AS refreshed_at
   FROM public.tbloperationheader
  WHERE (customercode IS NOT NULL)
  GROUP BY customercode
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mv_customer_outstanding_balance OWNER TO postgres;

--
-- Name: mv_daily_sales_summary; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.mv_daily_sales_summary AS
 SELECT operationdate AS sale_date,
    branchcode AS branch_code,
    count(*) AS tx_count,
    sum(total) AS total_amount,
    sum(paidamount) AS total_paid,
    sum(remainingamount) AS total_outstanding,
    max(operationdate) AS refreshed_at
   FROM public.tbloperationheader
  WHERE (((operationtype)::text = 'SALE'::text) AND (NOT iscancelled))
  GROUP BY operationdate, branchcode
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mv_daily_sales_summary OWNER TO postgres;

--
-- Name: mv_final_accounts; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.mv_final_accounts AS
 SELECT accountcode,
    accountid AS accountnumber,
    accountnamear AS accountname,
    accounttype AS accttype,
    accountnature AS acctnature,
    currentbalance AS balance,
    isactive,
    now() AS refreshed_at
   FROM public.tblaccounts a
  WHERE (isactive = true)
  ORDER BY accountid
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mv_final_accounts OWNER TO postgres;

--
-- Name: MATERIALIZED VIEW mv_final_accounts; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON MATERIALIZED VIEW public.mv_final_accounts IS 'Materialized view for final accounts (balance sheet, P&L) report. Refresh daily.';


--
-- Name: tbljournalheader; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbljournalheader (
    journalcode bigint NOT NULL,
    journalid character varying(30) NOT NULL,
    journaldate date NOT NULL,
    fiscalyear integer NOT NULL,
    fiscalperiod integer NOT NULL,
    description character varying(500),
    referenceno character varying(100),
    sourcetype character varying(50),
    sourcecode bigint,
    currencycode integer,
    exchangerate numeric(18,8) DEFAULT 1.0,
    totaldebit numeric(18,4) DEFAULT 0,
    totalcredit numeric(18,4) DEFAULT 0,
    isposted boolean DEFAULT false,
    postedat timestamp without time zone,
    postedby integer,
    approvedby integer,
    approvedat timestamp without time zone,
    iscancelled boolean DEFAULT false,
    cancelledat timestamp without time zone,
    cancelledby integer,
    cancellationreason text,
    createdby integer,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    modifiedby integer,
    modifiedat timestamp without time zone,
    notes text,
    approvalrequestid bigint,
    departmentcode integer,
    projectcode integer,
    businessunitcode integer,
    segmentcode integer,
    profitcentercode integer
);


ALTER TABLE public.tbljournalheader OWNER TO postgres;

--
-- Name: mv_journal_summary; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.mv_journal_summary AS
 SELECT journaldate AS journal_date,
    sourcetype AS source_type,
    fiscalyear AS fy,
    fiscalperiod AS fp,
    count(*) AS entry_count,
    sum(totaldebit) AS total_debit,
    sum(totalcredit) AS total_credit,
    now() AS refreshed_at
   FROM public.tbljournalheader j
  WHERE ((isposted = true) AND (iscancelled = false))
  GROUP BY journaldate, sourcetype, fiscalyear, fiscalperiod
  ORDER BY journaldate DESC, sourcetype
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mv_journal_summary OWNER TO postgres;

--
-- Name: MATERIALIZED VIEW mv_journal_summary; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON MATERIALIZED VIEW public.mv_journal_summary IS 'Materialized view for journal entry summary (rptJournalEntery.rdlc). Refresh hourly.';


--
-- Name: tblstoreproducts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblstoreproducts (
    storeproductid integer NOT NULL,
    storecode integer NOT NULL,
    productcode integer NOT NULL,
    batchid integer,
    qtyonhand numeric(18,4) DEFAULT 0,
    qtyreserved numeric(18,4) DEFAULT 0,
    avgcost numeric(18,4) DEFAULT 0,
    lastcost numeric(18,4) DEFAULT 0,
    locationinstore character varying(50),
    isactive boolean DEFAULT true
);


ALTER TABLE public.tblstoreproducts OWNER TO postgres;

--
-- Name: mv_monthly_inventory_snapshot; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.mv_monthly_inventory_snapshot AS
 SELECT productcode AS product_code,
    storecode AS store_code,
    sum(qtyonhand) AS qty_on_hand,
    sum(qtyreserved) AS qty_reserved,
    sum((qtyonhand - qtyreserved)) AS qty_available,
    avg(avgcost) AS avg_cost,
    sum((qtyonhand * COALESCE(avgcost, (0)::numeric))) AS total_value,
    count(*) FILTER (WHERE isactive) AS active_batches,
    now() AS refreshed_at
   FROM public.tblstoreproducts
  WHERE (isactive = true)
  GROUP BY productcode, storecode
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mv_monthly_inventory_snapshot OWNER TO postgres;

--
-- Name: tblbankaccounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblbankaccounts (
    bankaccountid integer NOT NULL,
    bankaccountno character varying(50) NOT NULL,
    bankid integer NOT NULL,
    branchname character varying(100),
    currid integer NOT NULL,
    iban character varying(50),
    swiftcode character varying(20),
    openingbalance numeric(18,4) DEFAULT 0 NOT NULL,
    currentbalance numeric(18,4) DEFAULT 0 NOT NULL,
    isactive boolean DEFAULT true NOT NULL,
    adduser integer,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    edituser integer,
    editdate timestamp without time zone,
    CONSTRAINT chk_tblbankaccounts_balance_nonneg CHECK (((currentbalance IS NULL) OR (currentbalance >= (0)::numeric)))
);

ALTER TABLE ONLY public.tblbankaccounts FORCE ROW LEVEL SECURITY;


ALTER TABLE public.tblbankaccounts OWNER TO postgres;

--
-- Name: tblcashboxes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblcashboxes (
    cashboxid integer NOT NULL,
    cashboxcode character varying(20) NOT NULL,
    cashboxname character varying(100) NOT NULL,
    branchid integer NOT NULL,
    currid integer NOT NULL,
    openingbalance numeric(18,4) DEFAULT 0 NOT NULL,
    currentbalance numeric(18,4) DEFAULT 0 NOT NULL,
    isactive boolean DEFAULT true NOT NULL,
    notes text,
    adduser integer,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    edituser integer,
    editdate timestamp without time zone
);

ALTER TABLE ONLY public.tblcashboxes FORCE ROW LEVEL SECURITY;


ALTER TABLE public.tblcashboxes OWNER TO postgres;

--
-- Name: mv_treasury_position; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.mv_treasury_position AS
 SELECT 'CASH'::text AS entity_type,
    tblcashboxes.cashboxid AS entity_id,
    tblcashboxes.cashboxname AS entity_name,
    tblcashboxes.currentbalance AS balance,
    tblcashboxes.branchid AS branch_code,
    tblcashboxes.isactive AS is_active,
    now() AS refreshed_at
   FROM public.tblcashboxes
  WHERE (tblcashboxes.cashboxid IS NOT NULL)
UNION ALL
 SELECT 'BANK'::text AS entity_type,
    tblbankaccounts.bankaccountid AS entity_id,
    tblbankaccounts.bankaccountno AS entity_name,
    tblbankaccounts.currentbalance AS balance,
    NULL::integer AS branch_code,
    tblbankaccounts.isactive AS is_active,
    now() AS refreshed_at
   FROM public.tblbankaccounts
  WHERE (tblbankaccounts.bankaccountid IS NOT NULL)
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mv_treasury_position OWNER TO postgres;

--
-- Name: mv_trial_balance; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.mv_trial_balance AS
 SELECT accountcode,
    accountid AS accountnumber,
    accountnamear AS accountname,
    currentbalance AS totaldebit,
    (0)::numeric AS totalcredit,
    currentbalance AS balance,
    accounttype AS accttype,
    isactive,
    now() AS refreshed_at
   FROM public.tblaccounts a
  WHERE (isactive = true)
  ORDER BY accountid
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mv_trial_balance OWNER TO postgres;

--
-- Name: MATERIALIZED VIEW mv_trial_balance; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON MATERIALIZED VIEW public.mv_trial_balance IS 'Materialized view for trial balance report (rptTrailBalance.rdlc). Refresh daily via refresh_critical_mvs().';


--
-- Name: tblaccounts_accountcode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblaccounts ALTER COLUMN accountcode ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblaccounts_accountcode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblapprovalactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblapprovalactions (
    actionid bigint NOT NULL,
    requestid bigint NOT NULL,
    levelid integer NOT NULL,
    approverid integer NOT NULL,
    actiontype character varying(20) NOT NULL,
    actiondate timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    oldstatus character varying(20),
    newstatus character varying(20) NOT NULL,
    fromlevel integer,
    tolevel integer,
    delegatedto integer,
    comments text,
    ipaddress character varying(50),
    useragent character varying(500),
    CONSTRAINT tblapprovalactions_actiontype_check CHECK (((actiontype)::text = ANY ((ARRAY['SUBMITTED'::character varying, 'APPROVED'::character varying, 'REJECTED'::character varying, 'DELEGATED'::character varying, 'RETURNED'::character varying, 'EXPIRED'::character varying, 'CANCELLED'::character varying])::text[])))
);


ALTER TABLE public.tblapprovalactions OWNER TO postgres;

--
-- Name: tblapprovalactions_actionid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblapprovalactions_actionid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblapprovalactions_actionid_seq OWNER TO postgres;

--
-- Name: tblapprovalactions_actionid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblapprovalactions_actionid_seq OWNED BY public.tblapprovalactions.actionid;


--
-- Name: tblapprovalaudit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblapprovalaudit (
    auditid bigint NOT NULL,
    requestid bigint NOT NULL,
    actionid bigint,
    eventtype character varying(30) NOT NULL,
    performedby integer,
    performedat timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ipaddress character varying(50),
    useragent character varying(500),
    olddata jsonb,
    newdata jsonb,
    details text
);


ALTER TABLE public.tblapprovalaudit OWNER TO postgres;

--
-- Name: tblapprovalaudit_auditid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblapprovalaudit_auditid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblapprovalaudit_auditid_seq OWNER TO postgres;

--
-- Name: tblapprovalaudit_auditid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblapprovalaudit_auditid_seq OWNED BY public.tblapprovalaudit.auditid;


--
-- Name: tblapprovalconfig; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblapprovalconfig (
    configid integer NOT NULL,
    configkey character varying(50) NOT NULL,
    configvalue numeric(18,4) NOT NULL,
    description text,
    adduser integer,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    edituser integer,
    editdate timestamp without time zone
);


ALTER TABLE public.tblapprovalconfig OWNER TO postgres;

--
-- Name: tblapprovalconfig_configid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblapprovalconfig_configid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblapprovalconfig_configid_seq OWNER TO postgres;

--
-- Name: tblapprovalconfig_configid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblapprovalconfig_configid_seq OWNED BY public.tblapprovalconfig.configid;


--
-- Name: tblapprovaldelegations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblapprovaldelegations (
    delegationid integer NOT NULL,
    fromuserid integer NOT NULL,
    touserid integer NOT NULL,
    workflowid integer,
    fromdate date NOT NULL,
    todate date NOT NULL,
    reason text,
    isactive boolean DEFAULT true NOT NULL,
    adduser integer,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT tblapprovaldelegations_check CHECK ((fromuserid <> touserid)),
    CONSTRAINT tblapprovaldelegations_check1 CHECK ((todate >= fromdate))
);


ALTER TABLE public.tblapprovaldelegations OWNER TO postgres;

--
-- Name: tblapprovaldelegations_delegationid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblapprovaldelegations_delegationid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblapprovaldelegations_delegationid_seq OWNER TO postgres;

--
-- Name: tblapprovaldelegations_delegationid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblapprovaldelegations_delegationid_seq OWNED BY public.tblapprovaldelegations.delegationid;


--
-- Name: tblapprovallevels; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblapprovallevels (
    levelid integer NOT NULL,
    workflowid integer NOT NULL,
    levelnumber integer NOT NULL,
    levelnamear character varying(100) NOT NULL,
    levelnameen character varying(100),
    requiredrole character varying(50) NOT NULL,
    amountmin numeric(18,4) DEFAULT 0 NOT NULL,
    amountmax numeric(18,4) DEFAULT 999999999999.9999 NOT NULL,
    ismandatory boolean DEFAULT true NOT NULL,
    sla_hours integer DEFAULT 48,
    isactive boolean DEFAULT true NOT NULL,
    CONSTRAINT tblapprovallevels_levelnumber_check CHECK (((levelnumber >= 1) AND (levelnumber <= 10)))
);


ALTER TABLE public.tblapprovallevels OWNER TO postgres;

--
-- Name: tblapprovallevels_levelid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblapprovallevels_levelid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblapprovallevels_levelid_seq OWNER TO postgres;

--
-- Name: tblapprovallevels_levelid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblapprovallevels_levelid_seq OWNED BY public.tblapprovallevels.levelid;


--
-- Name: tblapprovalrequests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblapprovalrequests (
    requestid bigint NOT NULL,
    requestno character varying(30) NOT NULL,
    workflowid integer NOT NULL,
    sourcetype character varying(30) NOT NULL,
    sourceid bigint NOT NULL,
    requesterid integer NOT NULL,
    totalsum numeric(18,4) NOT NULL,
    currencycode integer,
    exchangerate numeric(18,8) DEFAULT 1,
    description text,
    status character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,
    currentlevel integer DEFAULT 1 NOT NULL,
    totallevels integer NOT NULL,
    priority character varying(10) DEFAULT 'NORMAL'::character varying,
    duedate timestamp without time zone,
    completedate timestamp without time zone,
    completedby integer,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT tblapprovalrequests_priority_check CHECK (((priority)::text = ANY ((ARRAY['LOW'::character varying, 'NORMAL'::character varying, 'HIGH'::character varying, 'URGENT'::character varying])::text[]))),
    CONSTRAINT tblapprovalrequests_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'IN_REVIEW'::character varying, 'APPROVED'::character varying, 'REJECTED'::character varying, 'CANCELLED'::character varying, 'EXPIRED'::character varying])::text[]))),
    CONSTRAINT tblapprovalrequests_totalsum_check CHECK ((totalsum >= (0)::numeric))
);


ALTER TABLE public.tblapprovalrequests OWNER TO postgres;

--
-- Name: tblapprovalrequests_requestid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblapprovalrequests_requestid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblapprovalrequests_requestid_seq OWNER TO postgres;

--
-- Name: tblapprovalrequests_requestid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblapprovalrequests_requestid_seq OWNED BY public.tblapprovalrequests.requestid;


--
-- Name: tblapprovalworkflows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblapprovalworkflows (
    workflowid integer NOT NULL,
    workflowcode character varying(30) NOT NULL,
    workflownamear character varying(100) NOT NULL,
    workflownameen character varying(100),
    sourcetype character varying(30) NOT NULL,
    description text,
    isactive boolean DEFAULT true NOT NULL,
    adduser integer,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    edituser integer,
    editdate timestamp without time zone,
    CONSTRAINT tblapprovalworkflows_sourcetype_check CHECK (((sourcetype)::text = ANY ((ARRAY['BOND'::character varying, 'JOURNAL'::character varying, 'OPERATION'::character varying, 'CASH_RECEIPT'::character varying, 'CASH_PAYMENT'::character varying, 'BANK_TXN'::character varying, 'BUDGET'::character varying, 'OTHER'::character varying])::text[])))
);


ALTER TABLE public.tblapprovalworkflows OWNER TO postgres;

--
-- Name: tblapprovalworkflows_workflowid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblapprovalworkflows_workflowid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblapprovalworkflows_workflowid_seq OWNER TO postgres;

--
-- Name: tblapprovalworkflows_workflowid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblapprovalworkflows_workflowid_seq OWNED BY public.tblapprovalworkflows.workflowid;


--
-- Name: tblaudi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblaudi (
    audithistid bigint NOT NULL,
    tablename character varying(100) NOT NULL,
    recordid bigint NOT NULL,
    action character varying(20) NOT NULL,
    olddata jsonb,
    newdata jsonb,
    changedfields text[],
    userid integer,
    username character varying(50),
    actiondate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    clientip character varying(50),
    sessionid character varying(100),
    CONSTRAINT tblaudi_action_check CHECK (((action)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);

ALTER TABLE ONLY public.tblaudi FORCE ROW LEVEL SECURITY;


ALTER TABLE public.tblaudi OWNER TO postgres;

--
-- Name: tblaudi_audithistid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblaudi_audithistid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblaudi_audithistid_seq OWNER TO postgres;

--
-- Name: tblaudi_audithistid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblaudi_audithistid_seq OWNED BY public.tblaudi.audithistid;


--
-- Name: tblaudi_security; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblaudi_security (
    id bigint NOT NULL,
    event_type text NOT NULL,
    event_payload jsonb,
    actor_role text DEFAULT CURRENT_USER NOT NULL,
    occurred_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY public.tblaudi_security FORCE ROW LEVEL SECURITY;


ALTER TABLE public.tblaudi_security OWNER TO postgres;

--
-- Name: tblaudi_security_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblaudi_security_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblaudi_security_id_seq OWNER TO postgres;

--
-- Name: tblaudi_security_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblaudi_security_id_seq OWNED BY public.tblaudi_security.id;


--
-- Name: tblauditlogs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblauditlogs (
    auditid bigint NOT NULL,
    usercode integer,
    userid character varying(15),
    eventtype character varying(50) NOT NULL,
    eventcategory character varying(50) NOT NULL,
    eventdescription character varying(1000) NOT NULL,
    tablename character varying(100),
    recordid integer,
    oldvalues text,
    newvalues text,
    sqlcommand text,
    machinename character varying(100),
    ipaddress character varying(50),
    actionname character varying(100),
    entityname character varying(100),
    entitykey character varying(200),
    success boolean DEFAULT true,
    errormessage text,
    modulename character varying(100),
    windowid integer,
    oldvalue text,
    newvalue text,
    eventdate timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE ONLY public.tblauditlogs FORCE ROW LEVEL SECURITY;


ALTER TABLE public.tblauditlogs OWNER TO postgres;

--
-- Name: tblauditlogs_auditid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblauditlogs ALTER COLUMN auditid ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblauditlogs_auditid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblbankaccounts_bankaccountid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblbankaccounts_bankaccountid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblbankaccounts_bankaccountid_seq OWNER TO postgres;

--
-- Name: tblbankaccounts_bankaccountid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblbankaccounts_bankaccountid_seq OWNED BY public.tblbankaccounts.bankaccountid;


--
-- Name: tblbankreconciliations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblbankreconciliations (
    reconid bigint NOT NULL,
    bankaccountid integer NOT NULL,
    periodfrom date NOT NULL,
    periodto date NOT NULL,
    openingbalance numeric(18,4) NOT NULL,
    closingbalance numeric(18,4) NOT NULL,
    systembalance numeric(18,4) NOT NULL,
    difference numeric(18,4) NOT NULL,
    status character varying(20) DEFAULT 'OPEN'::character varying NOT NULL,
    notes text,
    adduser integer,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT tblbankreconciliations_status_check CHECK (((status)::text = ANY ((ARRAY['OPEN'::character varying, 'BALANCED'::character varying, 'ADJUSTED'::character varying, 'CLOSED'::character varying])::text[])))
);


ALTER TABLE public.tblbankreconciliations OWNER TO postgres;

--
-- Name: tblbankreconciliations_reconid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblbankreconciliations_reconid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblbankreconciliations_reconid_seq OWNER TO postgres;

--
-- Name: tblbankreconciliations_reconid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblbankreconciliations_reconid_seq OWNED BY public.tblbankreconciliations.reconid;


--
-- Name: tblbanks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblbanks (
    bankcode integer NOT NULL,
    bankid character varying(15) NOT NULL,
    banknamear character varying(200) NOT NULL,
    banknameen character varying(200),
    accountnumber character varying(50),
    iban character varying(50),
    swiftcode character varying(20),
    branchname character varying(200),
    currencycode integer,
    openingbalance numeric(18,4) DEFAULT 0,
    currentbalance numeric(18,4) DEFAULT 0,
    isactive boolean DEFAULT true,
    notes text
);


ALTER TABLE public.tblbanks OWNER TO postgres;

--
-- Name: tblbanks_bankcode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblbanks ALTER COLUMN bankcode ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblbanks_bankcode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblbankstatementlines; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblbankstatementlines (
    stmtlineid bigint NOT NULL,
    statementid bigint NOT NULL,
    txndate date NOT NULL,
    description text,
    debitamount numeric(18,4) DEFAULT 0,
    creditamount numeric(18,4) DEFAULT 0,
    refno character varying(50),
    ismatched boolean DEFAULT false,
    matchedtxnid bigint
);


ALTER TABLE public.tblbankstatementlines OWNER TO postgres;

--
-- Name: tblbankstatementlines_stmtlineid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblbankstatementlines_stmtlineid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblbankstatementlines_stmtlineid_seq OWNER TO postgres;

--
-- Name: tblbankstatementlines_stmtlineid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblbankstatementlines_stmtlineid_seq OWNED BY public.tblbankstatementlines.stmtlineid;


--
-- Name: tblbankstatements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblbankstatements (
    statementid bigint NOT NULL,
    bankaccountid integer NOT NULL,
    statementdate date NOT NULL,
    statementno character varying(50) NOT NULL,
    openingbalance numeric(18,4) NOT NULL,
    closingbalance numeric(18,4) NOT NULL,
    totaldebit numeric(18,4) DEFAULT 0,
    totalcredit numeric(18,4) DEFAULT 0,
    importeddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    isreconcilied boolean DEFAULT false,
    adduser integer
);


ALTER TABLE public.tblbankstatements OWNER TO postgres;

--
-- Name: tblbankstatements_statementid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblbankstatements_statementid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblbankstatements_statementid_seq OWNER TO postgres;

--
-- Name: tblbankstatements_statementid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblbankstatements_statementid_seq OWNED BY public.tblbankstatements.statementid;


--
-- Name: tblbanktransactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblbanktransactions (
    banktxnid bigint NOT NULL,
    txndate date NOT NULL,
    bankaccountid integer NOT NULL,
    txnttyp character varying(20) NOT NULL,
    amount numeric(18,4) NOT NULL,
    currid integer NOT NULL,
    exgrate numeric(18,8) DEFAULT 1 NOT NULL,
    amountlocal numeric(18,4) GENERATED ALWAYS AS ((amount * exgrate)) STORED,
    counteraccountid integer,
    description text,
    refno character varying(50),
    status character varying(20) DEFAULT 'POSTED'::character varying NOT NULL,
    adduser integer,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    approvalrequestid bigint,
    departmentcode integer,
    projectcode integer,
    businessunitcode integer,
    segmentcode integer,
    profitcentercode integer,
    CONSTRAINT chk_tblbanktransactions_amount_positive CHECK (((amount IS NULL) OR (amount > (0)::numeric))),
    CONSTRAINT tblbanktransactions_txnttyp_check CHECK (((txnttyp)::text = ANY ((ARRAY['DEPOSIT'::character varying, 'WITHDRAWAL'::character varying, 'TRANSFER'::character varying, 'FEE'::character varying, 'INTEREST'::character varying])::text[])))
);


ALTER TABLE public.tblbanktransactions OWNER TO postgres;

--
-- Name: tblbanktransactions_banktxnid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblbanktransactions_banktxnid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblbanktransactions_banktxnid_seq OWNER TO postgres;

--
-- Name: tblbanktransactions_banktxnid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblbanktransactions_banktxnid_seq OWNED BY public.tblbanktransactions.banktxnid;


--
-- Name: tblbondbody; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblbondbody (
    bonddetailid bigint NOT NULL,
    bondcode bigint NOT NULL,
    linenumber integer NOT NULL,
    accountcode integer NOT NULL,
    costcentercode integer,
    description character varying(500),
    debit numeric(18,4) DEFAULT 0,
    credit numeric(18,4) DEFAULT 0
);


ALTER TABLE public.tblbondbody OWNER TO postgres;

--
-- Name: tblbondbody_bonddetailid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblbondbody ALTER COLUMN bonddetailid ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblbondbody_bonddetailid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblbondheader; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblbondheader (
    bondcode bigint NOT NULL,
    bondid character varying(30) NOT NULL,
    bondtype character varying(20) NOT NULL,
    bonddate date NOT NULL,
    fiscalyear integer NOT NULL,
    fiscalperiod integer NOT NULL,
    amount numeric(18,4) NOT NULL,
    currencycode integer,
    exchangerate numeric(18,8) DEFAULT 1.0,
    paymentmethodcode integer,
    bankcode integer,
    fundcode integer,
    customercode integer,
    suppliercode integer,
    accountcode integer,
    description character varying(500),
    referenceno character varying(100),
    isposted boolean DEFAULT false,
    postedat timestamp without time zone,
    postedby integer,
    createdby integer,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    notes text,
    approvalrequestid bigint,
    departmentcode integer,
    projectcode integer,
    businessunitcode integer,
    segmentcode integer,
    profitcentercode integer,
    CONSTRAINT chk_tblbondheader_amount_positive CHECK (((amount IS NULL) OR (amount > (0)::numeric)))
);


ALTER TABLE public.tblbondheader OWNER TO postgres;

--
-- Name: tblbondheader_bondcode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblbondheader ALTER COLUMN bondcode ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblbondheader_bondcode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblbranches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblbranches (
    branchcode integer NOT NULL,
    branchid character varying(15) NOT NULL,
    branchnamear character varying(200) NOT NULL,
    branchnameen character varying(200),
    address character varying(500),
    city character varying(100),
    country character varying(100) DEFAULT 'SA'::character varying,
    phone character varying(50),
    email character varying(100),
    managername character varying(200),
    ismainbranch boolean DEFAULT false,
    isactive boolean DEFAULT true,
    openedat date,
    notes text
);


ALTER TABLE public.tblbranches OWNER TO postgres;

--
-- Name: tblbranches_branchcode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblbranches ALTER COLUMN branchcode ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblbranches_branchcode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblbudgetperiods; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblbudgetperiods (
    periodid integer NOT NULL,
    periodname character varying(50) NOT NULL,
    periodfrom date NOT NULL,
    periodto date NOT NULL,
    isactive boolean DEFAULT true NOT NULL,
    notes text,
    adduser integer,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tblbudgetperiods OWNER TO postgres;

--
-- Name: tblbudgetperiods_periodid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblbudgetperiods_periodid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblbudgetperiods_periodid_seq OWNER TO postgres;

--
-- Name: tblbudgetperiods_periodid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblbudgetperiods_periodid_seq OWNED BY public.tblbudgetperiods.periodid;


--
-- Name: tblbudgets_budgetid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblbudgets_budgetid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblbudgets_budgetid_seq OWNER TO postgres;

--
-- Name: tblbudgets_budgetid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblbudgets_budgetid_seq OWNED BY public.tblbudgets.budgetid;


--
-- Name: tblcashboxes_cashboxid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblcashboxes_cashboxid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblcashboxes_cashboxid_seq OWNER TO postgres;

--
-- Name: tblcashboxes_cashboxid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblcashboxes_cashboxid_seq OWNED BY public.tblcashboxes.cashboxid;


--
-- Name: tblcashpayments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblcashpayments (
    paymentid bigint NOT NULL,
    paymentno character varying(30) NOT NULL,
    paymentdate date NOT NULL,
    cashboxid integer NOT NULL,
    supplierid integer,
    customerid integer,
    amount numeric(18,4) NOT NULL,
    currid integer NOT NULL,
    exgrate numeric(18,8) DEFAULT 1 NOT NULL,
    amountlocal numeric(18,4) GENERATED ALWAYS AS ((amount * exgrate)) STORED,
    paymentmethodid integer,
    description text,
    status character varying(20) DEFAULT 'POSTED'::character varying NOT NULL,
    adduser integer,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    edituser integer,
    editdate timestamp without time zone,
    approvalrequestid bigint,
    departmentcode integer,
    projectcode integer,
    businessunitcode integer,
    segmentcode integer,
    profitcentercode integer,
    CONSTRAINT tblcashpayments_amount_check CHECK ((amount > (0)::numeric))
);


ALTER TABLE public.tblcashpayments OWNER TO postgres;

--
-- Name: tblcashpayments_paymentid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblcashpayments_paymentid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblcashpayments_paymentid_seq OWNER TO postgres;

--
-- Name: tblcashpayments_paymentid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblcashpayments_paymentid_seq OWNED BY public.tblcashpayments.paymentid;


--
-- Name: tblcashreceipts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblcashreceipts (
    receiptid bigint NOT NULL,
    receiptno character varying(30) NOT NULL,
    receiptdate date NOT NULL,
    cashboxid integer NOT NULL,
    customerid integer,
    supplierid integer,
    amount numeric(18,4) NOT NULL,
    currid integer NOT NULL,
    exgrate numeric(18,8) DEFAULT 1 NOT NULL,
    amountlocal numeric(18,4) GENERATED ALWAYS AS ((amount * exgrate)) STORED,
    paymentmethodid integer,
    description text,
    status character varying(20) DEFAULT 'POSTED'::character varying NOT NULL,
    adduser integer,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    edituser integer,
    editdate timestamp without time zone,
    approvalrequestid bigint,
    departmentcode integer,
    projectcode integer,
    businessunitcode integer,
    segmentcode integer,
    profitcentercode integer,
    CONSTRAINT tblcashreceipts_amount_check CHECK ((amount > (0)::numeric))
);


ALTER TABLE public.tblcashreceipts OWNER TO postgres;

--
-- Name: tblcashreceipts_receiptid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblcashreceipts_receiptid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblcashreceipts_receiptid_seq OWNER TO postgres;

--
-- Name: tblcashreceipts_receiptid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblcashreceipts_receiptid_seq OWNED BY public.tblcashreceipts.receiptid;


--
-- Name: tblcategories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblcategories (
    categorycode integer NOT NULL,
    categoryid character varying(15) NOT NULL,
    categorynamear character varying(200) NOT NULL,
    categorynameen character varying(200),
    parentcategorycode integer,
    isactive boolean DEFAULT true,
    notes text
);


ALTER TABLE public.tblcategories OWNER TO postgres;

--
-- Name: tblcategories_categorycode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblcategories ALTER COLUMN categorycode ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblcategories_categorycode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblcompanies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblcompanies (
    companycode integer NOT NULL,
    companynamear character varying(200) NOT NULL,
    companynameen character varying(200),
    taxnumber character varying(50),
    vatnumber character varying(50),
    address character varying(500),
    city character varying(100),
    country character varying(100) DEFAULT 'SA'::character varying,
    phone character varying(50),
    email character varying(100),
    website character varying(200),
    logo bytea,
    currencycode integer,
    fiscalyearstart date,
    isactive boolean DEFAULT true,
    notes text
);


ALTER TABLE public.tblcompanies OWNER TO postgres;

--
-- Name: tblcompanies_companycode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblcompanies ALTER COLUMN companycode ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblcompanies_companycode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblcostcenters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblcostcenters (
    costcentercode integer NOT NULL,
    costcenterid character varying(15) NOT NULL,
    costcenternamear character varying(200) NOT NULL,
    costcenternameen character varying(200),
    parentcostcentercode integer,
    isactive boolean DEFAULT true,
    notes text
);


ALTER TABLE public.tblcostcenters OWNER TO postgres;

--
-- Name: tblcostcenters_costcentercode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblcostcenters ALTER COLUMN costcentercode ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblcostcenters_costcentercode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblcurrencies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblcurrencies (
    currencycode integer NOT NULL,
    currencyid character varying(10) NOT NULL,
    currencynamear character varying(100) NOT NULL,
    currencynameen character varying(100),
    symbol character varying(10),
    exchangerate numeric(18,8) DEFAULT 1.0,
    isbasecurrency boolean DEFAULT false,
    isactive boolean DEFAULT true,
    lastupdatedat timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tblcurrencies OWNER TO postgres;

--
-- Name: tblcurrencies_currencycode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblcurrencies ALTER COLUMN currencycode ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblcurrencies_currencycode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblcustomercontacts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblcustomercontacts (
    contactid integer NOT NULL,
    customercode integer NOT NULL,
    contactname character varying(200),
    jobtitle character varying(100),
    phone character varying(50),
    mobile character varying(50),
    email character varying(100),
    isprimary boolean DEFAULT false
);


ALTER TABLE public.tblcustomercontacts OWNER TO postgres;

--
-- Name: tblcustomercontacts_contactid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblcustomercontacts ALTER COLUMN contactid ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblcustomercontacts_contactid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblcustomers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblcustomers (
    customercode integer NOT NULL,
    customerid character varying(15) NOT NULL,
    customernamear character varying(200) NOT NULL,
    customernameen character varying(200),
    customertype character varying(50) DEFAULT 'INDIVIDUAL'::character varying,
    taxnumber character varying(50),
    vatnumber character varying(50),
    address character varying(500),
    city character varying(100),
    country character varying(100) DEFAULT 'SA'::character varying,
    phone character varying(50),
    mobile character varying(50),
    email character varying(100),
    branchcode integer,
    pricelistcode integer,
    paymenttermcode integer,
    creditlimit numeric(18,4) DEFAULT 0,
    currentcredit numeric(18,4) DEFAULT 0,
    availablecredit numeric(18,4) GENERATED ALWAYS AS ((creditlimit - currentcredit)) STORED,
    paymentdays integer DEFAULT 0,
    balance numeric(18,4) DEFAULT 0,
    totalsales numeric(18,4) DEFAULT 0,
    lastsaledate date,
    customersince date,
    isactive boolean DEFAULT true,
    isblocked boolean DEFAULT false,
    notes text
);

ALTER TABLE ONLY public.tblcustomers FORCE ROW LEVEL SECURITY;


ALTER TABLE public.tblcustomers OWNER TO postgres;

--
-- Name: tblcustomers_customercode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblcustomers ALTER COLUMN customercode ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblcustomers_customercode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tbldim_businessunits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbldim_businessunits (
    businessunitcode integer NOT NULL,
    businessunitid character varying(30) NOT NULL,
    namear character varying(100) NOT NULL,
    nameen character varying(100),
    parentbusinessunitcode integer,
    isactive boolean DEFAULT true NOT NULL,
    notes text,
    adduser integer,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    edituser integer,
    editdate timestamp without time zone
);


ALTER TABLE public.tbldim_businessunits OWNER TO postgres;

--
-- Name: TABLE tbldim_businessunits; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.tbldim_businessunits IS 'PHASE 4 — Business Units dimension (strategic / legal entity subdivisions)';


--
-- Name: tbldim_businessunits_businessunitcode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tbldim_businessunits ALTER COLUMN businessunitcode ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbldim_businessunits_businessunitcode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tbldim_departments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbldim_departments (
    departmentcode integer NOT NULL,
    departmentid character varying(30) NOT NULL,
    namear character varying(100) NOT NULL,
    nameen character varying(100),
    parentdepartmentcode integer,
    managerusercode integer,
    isactive boolean DEFAULT true NOT NULL,
    effectivedate date DEFAULT CURRENT_DATE NOT NULL,
    enddate date,
    notes text,
    adduser integer,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    edituser integer,
    editdate timestamp without time zone
);


ALTER TABLE public.tbldim_departments OWNER TO postgres;

--
-- Name: TABLE tbldim_departments; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.tbldim_departments IS 'PHASE 4 — Departments dimension (organizational units / business functions)';


--
-- Name: tbldim_departments_departmentcode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tbldim_departments ALTER COLUMN departmentcode ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbldim_departments_departmentcode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tbldim_hierarchies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbldim_hierarchies (
    hierarchyid bigint NOT NULL,
    hierarchytype character varying(30) NOT NULL,
    parentdimtype character varying(20) NOT NULL,
    parentdimcode integer NOT NULL,
    childdimtype character varying(20) NOT NULL,
    childdimcode integer NOT NULL,
    validfrom date DEFAULT CURRENT_DATE NOT NULL,
    validto date,
    isactive boolean DEFAULT true NOT NULL,
    notes text,
    adduser integer,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    edituser integer,
    editdate timestamp without time zone
);


ALTER TABLE public.tbldim_hierarchies OWNER TO postgres;

--
-- Name: TABLE tbldim_hierarchies; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.tbldim_hierarchies IS 'PHASE 4 — Cross-dimension parent/child relationships (valid as of validfrom..validto)';


--
-- Name: tbldim_hierarchies_hierarchyid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tbldim_hierarchies ALTER COLUMN hierarchyid ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbldim_hierarchies_hierarchyid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tbldim_profitcenters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbldim_profitcenters (
    profitcentercode integer NOT NULL,
    profitcenterid character varying(30) NOT NULL,
    namear character varying(100) NOT NULL,
    nameen character varying(100),
    parentprofitcentercode integer,
    isactive boolean DEFAULT true NOT NULL,
    notes text,
    adduser integer,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    edituser integer,
    editdate timestamp without time zone
);


ALTER TABLE public.tbldim_profitcenters OWNER TO postgres;

--
-- Name: TABLE tbldim_profitcenters; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.tbldim_profitcenters IS 'PHASE 4 — Profit Centers dimension (P&L responsibility centers)';


--
-- Name: tbldim_profitcenters_profitcentercode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tbldim_profitcenters ALTER COLUMN profitcentercode ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbldim_profitcenters_profitcentercode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tbldim_projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbldim_projects (
    projectcode integer NOT NULL,
    projectid character varying(30) NOT NULL,
    namear character varying(100) NOT NULL,
    nameen character varying(100),
    parentprojectcode integer,
    projecttype character varying(30) DEFAULT 'INTERNAL'::character varying NOT NULL,
    startdate date,
    enddate date,
    budgetamount numeric(19,4) DEFAULT 0 NOT NULL,
    actualamount numeric(19,4) DEFAULT 0 NOT NULL,
    projectstatus character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    isactive boolean DEFAULT true NOT NULL,
    notes text,
    adduser integer,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    edituser integer,
    editdate timestamp without time zone
);


ALTER TABLE public.tbldim_projects OWNER TO postgres;

--
-- Name: TABLE tbldim_projects; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.tbldim_projects IS 'PHASE 4 — Projects dimension (capital, internal, client projects)';


--
-- Name: tbldim_projects_projectcode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tbldim_projects ALTER COLUMN projectcode ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbldim_projects_projectcode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tbldim_segments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbldim_segments (
    segmentcode integer NOT NULL,
    segmentid character varying(30) NOT NULL,
    namear character varying(100) NOT NULL,
    nameen character varying(100),
    segmenttype character varying(30) DEFAULT 'GEOGRAPHIC'::character varying NOT NULL,
    parentsegmentcode integer,
    isactive boolean DEFAULT true NOT NULL,
    notes text,
    adduser integer,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    edituser integer,
    editdate timestamp without time zone
);


ALTER TABLE public.tbldim_segments OWNER TO postgres;

--
-- Name: TABLE tbldim_segments; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.tbldim_segments IS 'PHASE 4 — Segments dimension (market / industry / channel segmentation)';


--
-- Name: tbldim_segments_segmentcode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tbldim_segments ALTER COLUMN segmentcode ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.tbldim_segments_segmentcode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tbldocumentattachments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbldocumentattachments (
    attachmentid bigint NOT NULL,
    source_type character varying(30) NOT NULL,
    source_id bigint NOT NULL,
    filename character varying(255) NOT NULL,
    originalfilename character varying(255) NOT NULL,
    contenttype character varying(100),
    filesize bigint NOT NULL,
    filecontent bytea,
    filepath character varying(500),
    description text,
    uploadedby integer,
    uploaddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tbldocumentattachments OWNER TO postgres;

--
-- Name: tbldocumentattachments_attachmentid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbldocumentattachments_attachmentid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tbldocumentattachments_attachmentid_seq OWNER TO postgres;

--
-- Name: tbldocumentattachments_attachmentid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbldocumentattachments_attachmentid_seq OWNED BY public.tbldocumentattachments.attachmentid;


--
-- Name: tblexchangeratehistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblexchangeratehistory (
    ratehistid bigint NOT NULL,
    currid integer NOT NULL,
    exgrate numeric(18,8) NOT NULL,
    effectivedate date NOT NULL,
    expirydate date,
    source character varying(50) DEFAULT 'MANUAL'::character varying,
    notes text,
    adduser integer,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_tblexchangeratehistory_exgrate_positive CHECK ((exgrate > (0)::numeric))
);


ALTER TABLE public.tblexchangeratehistory OWNER TO postgres;

--
-- Name: tblexchangeratehistory_ratehistid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblexchangeratehistory_ratehistid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblexchangeratehistory_ratehistid_seq OWNER TO postgres;

--
-- Name: tblexchangeratehistory_ratehistid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblexchangeratehistory_ratehistid_seq OWNED BY public.tblexchangeratehistory.ratehistid;


--
-- Name: tblfiscalperiods; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblfiscalperiods (
    periodid integer NOT NULL,
    fiscalyearid integer NOT NULL,
    periodname character varying(50) NOT NULL,
    periodnumber integer NOT NULL,
    startdate date NOT NULL,
    enddate date NOT NULL,
    isclosed boolean DEFAULT false NOT NULL,
    adduser integer,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tblfiscalperiods OWNER TO postgres;

--
-- Name: tblfiscalperiods_periodid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblfiscalperiods_periodid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblfiscalperiods_periodid_seq OWNER TO postgres;

--
-- Name: tblfiscalperiods_periodid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblfiscalperiods_periodid_seq OWNED BY public.tblfiscalperiods.periodid;


--
-- Name: tblfiscalyears; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblfiscalyears (
    fiscalyearid integer NOT NULL,
    fiscalyearname character varying(50) NOT NULL,
    startdate date NOT NULL,
    enddate date NOT NULL,
    isactive boolean DEFAULT true NOT NULL,
    isclosed boolean DEFAULT false NOT NULL,
    adduser integer,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tblfiscalyears OWNER TO postgres;

--
-- Name: tblfiscalyears_fiscalyearid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblfiscalyears_fiscalyearid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblfiscalyears_fiscalyearid_seq OWNER TO postgres;

--
-- Name: tblfiscalyears_fiscalyearid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblfiscalyears_fiscalyearid_seq OWNED BY public.tblfiscalyears.fiscalyearid;


--
-- Name: tblfunds; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblfunds (
    fundcode integer NOT NULL,
    fundid character varying(15) NOT NULL,
    fundnamear character varying(200) NOT NULL,
    fundnameen character varying(200),
    fundtype character varying(50),
    currencycode integer,
    openingbalance numeric(18,4) DEFAULT 0,
    currentbalance numeric(18,4) DEFAULT 0,
    isactive boolean DEFAULT true,
    notes text
);


ALTER TABLE public.tblfunds OWNER TO postgres;

--
-- Name: tblfunds_fundcode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblfunds ALTER COLUMN fundcode ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblfunds_fundcode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tbljournalbody; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbljournalbody (
    journaldetailid bigint NOT NULL,
    journalcode bigint NOT NULL,
    linenumber integer NOT NULL,
    accountcode integer NOT NULL,
    costcentercode integer,
    description character varying(500),
    debit numeric(18,4) DEFAULT 0,
    credit numeric(18,4) DEFAULT 0,
    currencycode integer,
    debitlocal numeric(18,4) DEFAULT 0,
    creditlocal numeric(18,4) DEFAULT 0,
    departmentcode integer,
    projectcode integer,
    businessunitcode integer,
    segmentcode integer,
    profitcentercode integer,
    CONSTRAINT chk_tbljournalbody_amounts_nonneg CHECK ((((debit IS NULL) OR (debit >= (0)::numeric)) AND ((credit IS NULL) OR (credit >= (0)::numeric)))),
    CONSTRAINT chk_tbljournalbody_no_dual_leg CHECK ((NOT ((COALESCE(debit, (0)::numeric) > (0)::numeric) AND (COALESCE(credit, (0)::numeric) > (0)::numeric))))
);


ALTER TABLE public.tbljournalbody OWNER TO postgres;

--
-- Name: tbljournalbody_journaldetailid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tbljournalbody ALTER COLUMN journaldetailid ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tbljournalbody_journaldetailid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tbljournalheader_journalcode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tbljournalheader ALTER COLUMN journalcode ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tbljournalheader_journalcode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblnotifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblnotifications (
    notificationid bigint NOT NULL,
    userid integer NOT NULL,
    title character varying(200) NOT NULL,
    message text NOT NULL,
    notificationtype character varying(50) DEFAULT 'INFO'::character varying NOT NULL,
    priority character varying(20) DEFAULT 'NORMAL'::character varying,
    isread boolean DEFAULT false,
    reftype character varying(30),
    refid bigint,
    expirydate timestamp without time zone,
    createdate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    readdate timestamp without time zone,
    CONSTRAINT tblnotifications_priority_check CHECK (((priority)::text = ANY ((ARRAY['LOW'::character varying, 'NORMAL'::character varying, 'HIGH'::character varying, 'URGENT'::character varying])::text[])))
);

ALTER TABLE ONLY public.tblnotifications FORCE ROW LEVEL SECURITY;


ALTER TABLE public.tblnotifications OWNER TO postgres;

--
-- Name: tblnotifications_notificationid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblnotifications_notificationid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblnotifications_notificationid_seq OWNER TO postgres;

--
-- Name: tblnotifications_notificationid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblnotifications_notificationid_seq OWNED BY public.tblnotifications.notificationid;


--
-- Name: tbloperationbody; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbloperationbody (
    operationdetailid bigint NOT NULL,
    operationcode bigint NOT NULL,
    linenumber integer NOT NULL,
    productcode integer NOT NULL,
    unitcode integer,
    batchid integer,
    quantity numeric(18,4) DEFAULT 0,
    unitprice numeric(18,4) DEFAULT 0,
    cost numeric(18,4) DEFAULT 0,
    discountpercent numeric(8,3) DEFAULT 0,
    discountamount numeric(18,4) DEFAULT 0,
    taxpercent numeric(8,3) DEFAULT 0,
    taxamount numeric(18,4) DEFAULT 0,
    total numeric(18,4) DEFAULT 0,
    storecode integer,
    description character varying(500)
);


ALTER TABLE public.tbloperationbody OWNER TO postgres;

--
-- Name: tbloperationbody_operationdetailid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tbloperationbody ALTER COLUMN operationdetailid ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tbloperationbody_operationdetailid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tbloperationheader_operationcode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tbloperationheader ALTER COLUMN operationcode ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tbloperationheader_operationcode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tbloperationtaxes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbloperationtaxes (
    operationtaxid bigint NOT NULL,
    operationcode bigint NOT NULL,
    taxtype character varying(50),
    taxpercent numeric(8,3) DEFAULT 0,
    taxamount numeric(18,4) DEFAULT 0
);


ALTER TABLE public.tbloperationtaxes OWNER TO postgres;

--
-- Name: tbloperationtaxes_operationtaxid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tbloperationtaxes ALTER COLUMN operationtaxid ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tbloperationtaxes_operationtaxid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblpaymentmethods; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblpaymentmethods (
    paymentmethodcode integer NOT NULL,
    methodnamear character varying(100) NOT NULL,
    methodnameen character varying(100),
    methodtype character varying(50),
    isactive boolean DEFAULT true,
    notes text
);


ALTER TABLE public.tblpaymentmethods OWNER TO postgres;

--
-- Name: tblpaymentmethods_paymentmethodcode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblpaymentmethods ALTER COLUMN paymentmethodcode ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblpaymentmethods_paymentmethodcode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblpaymentterms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblpaymentterms (
    paymenttermcode integer NOT NULL,
    termnamear character varying(100) NOT NULL,
    termnameen character varying(100),
    dayscount integer DEFAULT 0,
    isactive boolean DEFAULT true,
    notes text
);


ALTER TABLE public.tblpaymentterms OWNER TO postgres;

--
-- Name: tblpaymentterms_paymenttermcode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblpaymentterms ALTER COLUMN paymenttermcode ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblpaymentterms_paymenttermcode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblpricelists; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblpricelists (
    pricelistcode integer NOT NULL,
    pricelistnamear character varying(200) NOT NULL,
    pricelistnameen character varying(200),
    currencycode integer,
    markuppercent numeric(8,3) DEFAULT 0,
    validfrom date,
    validto date,
    isactive boolean DEFAULT true,
    notes text,
    CONSTRAINT chk_tblpricelists_markup_nonneg CHECK (((markuppercent IS NULL) OR (markuppercent >= (0)::numeric)))
);


ALTER TABLE public.tblpricelists OWNER TO postgres;

--
-- Name: tblpricelists_pricelistcode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblpricelists ALTER COLUMN pricelistcode ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblpricelists_pricelistcode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblprivileges; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblprivileges (
    privilegeid integer NOT NULL,
    usercode integer NOT NULL,
    windowid integer NOT NULL,
    candisplay boolean DEFAULT true,
    canadd boolean DEFAULT true,
    canedit boolean DEFAULT true,
    candelete boolean DEFAULT true,
    canprint boolean DEFAULT false,
    canexport boolean DEFAULT false,
    canapprove boolean DEFAULT false,
    canpost boolean DEFAULT false,
    custompermissions text,
    effectivefrom timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    effectiveto timestamp without time zone,
    createdby integer,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    modifiedby integer,
    modifiedat timestamp without time zone
);


ALTER TABLE public.tblprivileges OWNER TO postgres;

--
-- Name: tblprivileges_privilegeid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblprivileges ALTER COLUMN privilegeid ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblprivileges_privilegeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblproductbatches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblproductbatches (
    batchid integer NOT NULL,
    productcode integer NOT NULL,
    batchno character varying(50) NOT NULL,
    expirydate date,
    manufacturedate date
);


ALTER TABLE public.tblproductbatches OWNER TO postgres;

--
-- Name: tblproductbatches_batchid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblproductbatches ALTER COLUMN batchid ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblproductbatches_batchid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblproductimages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblproductimages (
    imageid integer NOT NULL,
    productcode integer NOT NULL,
    imagedata bytea,
    caption character varying(200),
    isprimary boolean DEFAULT false,
    sortorder integer DEFAULT 0
);


ALTER TABLE public.tblproductimages OWNER TO postgres;

--
-- Name: tblproductimages_imageid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblproductimages ALTER COLUMN imageid ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblproductimages_imageid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblproductmovement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblproductmovement (
    movementid bigint NOT NULL,
    productcode integer NOT NULL,
    storecode integer NOT NULL,
    movementtype character varying(20) NOT NULL,
    movementdate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    quantity numeric(18,4) NOT NULL,
    unitcost numeric(18,4) DEFAULT 0,
    referencetype character varying(50),
    referencecode bigint,
    batchid integer,
    notes text
);


ALTER TABLE public.tblproductmovement OWNER TO postgres;

--
-- Name: tblproductmovement_movementid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblproductmovement ALTER COLUMN movementid ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblproductmovement_movementid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblproductpricing; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblproductpricing (
    pricingid integer NOT NULL,
    productcode integer NOT NULL,
    pricelistcode integer NOT NULL,
    unitcode integer NOT NULL,
    price numeric(18,4) NOT NULL,
    minquantity numeric(18,4) DEFAULT 1,
    validfrom date,
    validto date
);


ALTER TABLE public.tblproductpricing OWNER TO postgres;

--
-- Name: tblproductpricing_pricingid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblproductpricing ALTER COLUMN pricingid ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblproductpricing_pricingid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblproducts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblproducts (
    productcode integer NOT NULL,
    productid character varying(50) NOT NULL,
    productnamear character varying(200) NOT NULL,
    productnameen character varying(200),
    barcode character varying(50),
    categorycode integer,
    defaultunitcode integer,
    isinventoryitem boolean DEFAULT true,
    standardcost numeric(18,4) DEFAULT 0,
    lastpurchaseprice numeric(18,4) DEFAULT 0,
    lastsaleprice numeric(18,4) DEFAULT 0,
    minstocklevel numeric(18,4) DEFAULT 0,
    maxstocklevel numeric(18,4) DEFAULT 0,
    reorderlevel numeric(18,4) DEFAULT 0,
    isactive boolean DEFAULT true,
    createdby integer,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    notes text,
    CONSTRAINT chk_tblproducts_maxstock_gte_min CHECK (((minstocklevel IS NULL) OR (maxstocklevel IS NULL) OR (maxstocklevel >= minstocklevel))),
    CONSTRAINT chk_tblproducts_minstock_nonneg CHECK (((minstocklevel IS NULL) OR (minstocklevel >= (0)::numeric))),
    CONSTRAINT chk_tblproducts_prices_nonneg CHECK (((standardcost >= (0)::numeric) AND (lastpurchaseprice >= (0)::numeric) AND (lastsaleprice >= (0)::numeric)))
);


ALTER TABLE public.tblproducts OWNER TO postgres;

--
-- Name: tblproducts_productcode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblproducts ALTER COLUMN productcode ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblproducts_productcode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblreportdefinitions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblreportdefinitions (
    reportid integer NOT NULL,
    reportcode character varying(50) NOT NULL,
    reportname character varying(200) NOT NULL,
    reportcategory character varying(50) NOT NULL,
    description text,
    rdlcfilename character varying(200),
    parameterschema jsonb,
    isactive boolean DEFAULT true NOT NULL,
    adduser integer,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tblreportdefinitions OWNER TO postgres;

--
-- Name: tblreportdefinitions_reportid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tblreportdefinitions_reportid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tblreportdefinitions_reportid_seq OWNER TO postgres;

--
-- Name: tblreportdefinitions_reportid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tblreportdefinitions_reportid_seq OWNED BY public.tblreportdefinitions.reportid;


--
-- Name: tblsessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblsessions (
    sessionid integer NOT NULL,
    sessiontoken uuid DEFAULT gen_random_uuid() NOT NULL,
    usercode integer NOT NULL,
    userid character varying(15) NOT NULL,
    branchcode integer,
    machinename character varying(100),
    ipaddress character varying(50),
    macaddress character varying(50),
    browserinfo character varying(500),
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    lastactivityat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    expiresat timestamp without time zone,
    logoutat timestamp without time zone,
    isactive boolean DEFAULT true,
    sessiondata text,
    CONSTRAINT chk_tblsessions_expires_after_created CHECK (((expiresat IS NULL) OR (createdat IS NULL) OR (expiresat > createdat))),
    CONSTRAINT chk_tblsessions_logout_after_created CHECK (((logoutat IS NULL) OR (createdat IS NULL) OR (logoutat >= createdat)))
);

ALTER TABLE ONLY public.tblsessions FORCE ROW LEVEL SECURITY;


ALTER TABLE public.tblsessions OWNER TO postgres;

--
-- Name: tblsessions_sessionid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblsessions ALTER COLUMN sessionid ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblsessions_sessionid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblstoreproducts_storeproductid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblstoreproducts ALTER COLUMN storeproductid ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblstoreproducts_storeproductid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblstores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblstores (
    storecode integer NOT NULL,
    storeid character varying(15) NOT NULL,
    storenamear character varying(200) NOT NULL,
    storenameen character varying(200),
    branchcode integer,
    managername character varying(200),
    isactive boolean DEFAULT true,
    notes text
);


ALTER TABLE public.tblstores OWNER TO postgres;

--
-- Name: tblstores_storecode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblstores ALTER COLUMN storecode ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblstores_storecode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblsuppliercontacts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblsuppliercontacts (
    contactid integer NOT NULL,
    suppliercode integer NOT NULL,
    contactname character varying(200),
    jobtitle character varying(100),
    phone character varying(50),
    mobile character varying(50),
    email character varying(100),
    isprimary boolean DEFAULT false
);


ALTER TABLE public.tblsuppliercontacts OWNER TO postgres;

--
-- Name: tblsuppliercontacts_contactid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblsuppliercontacts ALTER COLUMN contactid ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblsuppliercontacts_contactid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblsuppliers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblsuppliers (
    suppliercode integer NOT NULL,
    supplierid character varying(15) NOT NULL,
    suppliernamear character varying(200) NOT NULL,
    suppliernameen character varying(200),
    suppliertype character varying(50) DEFAULT 'INDIVIDUAL'::character varying,
    taxnumber character varying(50),
    vatnumber character varying(50),
    address character varying(500),
    city character varying(100),
    country character varying(100) DEFAULT 'SA'::character varying,
    phone character varying(50),
    mobile character varying(50),
    email character varying(100),
    branchcode integer,
    paymenttermcode integer,
    bankname character varying(200),
    accountnumber character varying(50),
    iban character varying(50),
    swiftcode character varying(20),
    creditlimit numeric(18,4) DEFAULT 0,
    currentcredit numeric(18,4) DEFAULT 0,
    availablecredit numeric(18,4) GENERATED ALWAYS AS ((creditlimit - currentcredit)) STORED,
    paymentdays integer DEFAULT 0,
    balance numeric(18,4) DEFAULT 0,
    totalpurchases numeric(18,4) DEFAULT 0,
    lastpurchasedate date,
    suppliersince date,
    isactive boolean DEFAULT true,
    isblocked boolean DEFAULT false,
    notes text
);

ALTER TABLE ONLY public.tblsuppliers FORCE ROW LEVEL SECURITY;


ALTER TABLE public.tblsuppliers OWNER TO postgres;

--
-- Name: tblsuppliers_suppliercode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblsuppliers ALTER COLUMN suppliercode ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblsuppliers_suppliercode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tbltaxdefinitions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbltaxdefinitions (
    taxid integer NOT NULL,
    taxcode character varying(20) NOT NULL,
    taxname character varying(100) NOT NULL,
    taxpercent numeric(8,4) NOT NULL,
    isinclusive boolean DEFAULT false NOT NULL,
    isactive boolean DEFAULT true NOT NULL,
    effectivedate date NOT NULL,
    expirydate date,
    notes text,
    adduser integer,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tbltaxdefinitions OWNER TO postgres;

--
-- Name: tbltaxdefinitions_taxid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbltaxdefinitions_taxid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tbltaxdefinitions_taxid_seq OWNER TO postgres;

--
-- Name: tbltaxdefinitions_taxid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbltaxdefinitions_taxid_seq OWNED BY public.tbltaxdefinitions.taxid;


--
-- Name: tbltaxtransactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbltaxtransactions (
    taxtransid bigint NOT NULL,
    taxid integer NOT NULL,
    source_type character varying(20) NOT NULL,
    source_id bigint NOT NULL,
    taxableamount numeric(18,4) NOT NULL,
    taxamount numeric(18,4) NOT NULL,
    txndate date NOT NULL,
    adddate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT tbltaxtransactions_source_type_check CHECK (((source_type)::text = ANY ((ARRAY['BOND'::character varying, 'JOURNAL'::character varying, 'OPERATION'::character varying, 'CASH'::character varying])::text[])))
);


ALTER TABLE public.tbltaxtransactions OWNER TO postgres;

--
-- Name: tbltaxtransactions_taxtransid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbltaxtransactions_taxtransid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tbltaxtransactions_taxtransid_seq OWNER TO postgres;

--
-- Name: tbltaxtransactions_taxtransid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbltaxtransactions_taxtransid_seq OWNED BY public.tbltaxtransactions.taxtransid;


--
-- Name: tblunits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblunits (
    unitcode integer NOT NULL,
    unitid character varying(15) NOT NULL,
    unitnamear character varying(100) NOT NULL,
    unitnameen character varying(100),
    symbol character varying(20),
    isactive boolean DEFAULT true
);


ALTER TABLE public.tblunits OWNER TO postgres;

--
-- Name: tblunits_unitcode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblunits ALTER COLUMN unitcode ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblunits_unitcode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tbluserroleassignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbluserroleassignments (
    assignmentid integer NOT NULL,
    usercode integer NOT NULL,
    roleid integer NOT NULL,
    assignedby integer,
    assignedat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    expiresat timestamp without time zone,
    isactive boolean DEFAULT true
);


ALTER TABLE public.tbluserroleassignments OWNER TO postgres;

--
-- Name: tbluserroleassignments_assignmentid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tbluserroleassignments ALTER COLUMN assignmentid ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tbluserroleassignments_assignmentid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tbluserroles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbluserroles (
    roleid integer NOT NULL,
    rolename character varying(50) NOT NULL,
    rolenamear character varying(100) NOT NULL,
    rolenameen character varying(100),
    description character varying(500),
    isactive boolean DEFAULT true,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    notes text
);


ALTER TABLE public.tbluserroles OWNER TO postgres;

--
-- Name: tbluserroles_roleid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tbluserroles ALTER COLUMN roleid ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tbluserroles_roleid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblusers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblusers (
    usercode integer NOT NULL,
    userid character varying(15) NOT NULL,
    userpassword bytea NOT NULL,
    salt bytea NOT NULL,
    usernamear character varying(200),
    usernameen character varying(200),
    email character varying(100),
    phone character varying(50),
    mobile character varying(50),
    isactive boolean DEFAULT true,
    isadmin boolean DEFAULT false,
    passwordlastchanged timestamp without time zone,
    passwordhistory1 bytea,
    passwordhistory2 bytea,
    lastloginat timestamp without time zone,
    loginattempts integer DEFAULT 0,
    lockeduntil timestamp without time zone,
    mustchangepassword boolean DEFAULT false,
    branchcode integer,
    department character varying(100),
    jobtitle character varying(100),
    photo bytea,
    isonline boolean DEFAULT false,
    createdby integer,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    modifiedby integer,
    modifiedat timestamp without time zone,
    notes text,
    photo_encrypted bytea,
    CONSTRAINT chk_tblusers_loginattempts_nonneg CHECK (((loginattempts IS NULL) OR (loginattempts >= 0)))
);

ALTER TABLE ONLY public.tblusers FORCE ROW LEVEL SECURITY;


ALTER TABLE public.tblusers OWNER TO postgres;

--
-- Name: tblusers_usercode_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblusers ALTER COLUMN usercode ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblusers_usercode_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tblwindows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tblwindows (
    windowid integer NOT NULL,
    windowcode character varying(50) NOT NULL,
    windownamear character varying(200) NOT NULL,
    windownameen character varying(200),
    modulename character varying(100) NOT NULL,
    formname character varying(200),
    isactive boolean DEFAULT true,
    sortorder integer DEFAULT 0,
    iconname character varying(100),
    parentwindowid integer,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    modifiedat timestamp without time zone,
    notes text
);


ALTER TABLE public.tblwindows OWNER TO postgres;

--
-- Name: tblwindows_windowid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.tblwindows ALTER COLUMN windowid ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblwindows_windowid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: vw_accounthierarchy; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_accounthierarchy AS
 SELECT a.accountcode,
    a.accountid,
    a.accountnamear,
    a.accountnameen,
    a.accounttype,
    a.parentaccountcode,
    p.accountnamear AS parentaccountname,
    a.accountlevel,
    public.fn_getaccountfullpath(a.accountcode) AS fullpath,
    a.isactive,
    a.ismainaccount,
    a.ispostable,
    a.accountnature,
        CASE
            WHEN ((a.accountnature)::text = 'Debit'::text) THEN public.fn_getaccountbalance(a.accountcode)
            ELSE (- public.fn_getaccountbalance(a.accountcode))
        END AS balance
   FROM (public.tblaccounts a
     LEFT JOIN public.tblaccounts p ON ((a.parentaccountcode = p.accountcode)));


ALTER VIEW public.vw_accounthierarchy OWNER TO postgres;

--
-- Name: vw_active_sessions; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_active_sessions AS
 SELECT pid AS session_id,
    usename AS db_user,
    application_name AS app,
    client_addr AS client_ip,
    state AS session_state,
    (wait_event_type || COALESCE((':'::text || wait_event), ''::text)) AS waiting_on,
    "substring"(query, 1, 200) AS current_query,
    (EXTRACT(epoch FROM (now() - query_start)))::integer AS query_duration_s,
    (EXTRACT(epoch FROM (now() - xact_start)))::integer AS txn_duration_s,
    backend_start AS connected_at
   FROM pg_stat_activity
  WHERE ((backend_type = 'client backend'::text) AND (pid <> pg_backend_pid()))
  ORDER BY query_start;


ALTER VIEW public.vw_active_sessions OWNER TO postgres;

--
-- Name: vw_activebudgets; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_activebudgets AS
 SELECT b.budgetid,
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
        CASE
            WHEN (b.budgetamount = (0)::numeric) THEN (0)::numeric
            ELSE ((b.actualamount / b.budgetamount) * (100)::numeric)
        END AS utilizationpercent
   FROM ((public.tblbudgets b
     JOIN public.tblbudgetperiods p ON ((b.periodid = p.periodid)))
     JOIN public.tblaccounts a ON ((b.accountid = a.accountcode)))
  WHERE (p.isactive = true);


ALTER VIEW public.vw_activebudgets OWNER TO postgres;

--
-- Name: vw_activeusers; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_activeusers AS
 SELECT u.usercode,
    u.userid,
    u.usernamear,
    u.usernameen,
    u.email,
    u.phone,
    u.mobile,
    u.isadmin,
    u.isactive,
    u.branchcode,
    b.branchnamear AS branchname,
    u.department,
    u.jobtitle,
    u.lastloginat,
    u.createdat
   FROM (public.tblusers u
     LEFT JOIN public.tblbranches b ON ((u.branchcode = b.branchcode)))
  WHERE (u.isactive = true);


ALTER VIEW public.vw_activeusers OWNER TO postgres;

--
-- Name: vw_approval_workflow_dashboard; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_approval_workflow_dashboard AS
 SELECT r.requestid,
    r.requestno,
    w.workflowcode,
    w.workflownamear,
    w.workflownameen,
    w.sourcetype,
    r.sourceid,
    r.requesterid,
    r.totalsum,
    r.currencycode,
    r.exchangerate,
    r.description,
    r.status,
    r.currentlevel,
    r.totallevels,
    r.priority,
    r.duedate,
    r.completedate,
    r.completedby,
    r.adddate,
    la.actiontype AS last_action_type,
    la.actiondate AS last_action_date,
    la.approverid AS last_approver_id,
    la.oldstatus AS last_old_status,
    la.newstatus AS last_new_status,
    la.fromlevel AS last_from_level,
    la.tolevel AS last_to_level,
    la.comments AS last_comments,
    ((r.status)::text = ANY ((ARRAY['PENDING'::character varying, 'IN_REVIEW'::character varying])::text[])) AS is_open,
    (((r.status)::text = 'IN_REVIEW'::text) AND (r.duedate IS NOT NULL) AND (r.duedate < now())) AS is_overdue,
    ((r.status)::text = ANY ((ARRAY['APPROVED'::character varying, 'REJECTED'::character varying, 'CANCELLED'::character varying, 'EXPIRED'::character varying])::text[])) AS is_terminal
   FROM ((public.tblapprovalrequests r
     JOIN public.tblapprovalworkflows w ON ((w.workflowid = r.workflowid)))
     LEFT JOIN LATERAL ( SELECT a.actiontype,
            a.actiondate,
            a.approverid,
            a.oldstatus,
            a.newstatus,
            a.fromlevel,
            a.tolevel,
            a.comments
           FROM public.tblapprovalactions a
          WHERE (a.requestid = r.requestid)
          ORDER BY a.actiondate DESC
         LIMIT 1) la ON (true));


ALTER VIEW public.vw_approval_workflow_dashboard OWNER TO postgres;

--
-- Name: vw_approvalhistory; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_approvalhistory AS
 SELECT a.actionid,
    a.requestid,
    r.requestno,
    r.sourcetype,
    r.sourceid,
    a.actiontype,
    a.oldstatus,
    a.newstatus,
    a.fromlevel,
    a.tolevel,
    a.delegatedto,
    a.comments,
    a.actiondate,
    a.ipaddress,
    u_approver.usercode AS approverid,
    u_approver.usernamear AS approver,
    u_delegated.usernamear AS delegatedtoname
   FROM (((public.tblapprovalactions a
     JOIN public.tblapprovalrequests r ON ((a.requestid = r.requestid)))
     JOIN public.tblusers u_approver ON ((a.approverid = u_approver.usercode)))
     LEFT JOIN public.tblusers u_delegated ON ((a.delegatedto = u_delegated.usercode)))
  ORDER BY a.actiondate DESC;


ALTER VIEW public.vw_approvalhistory OWNER TO postgres;

--
-- Name: vw_approvalmetrics; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_approvalmetrics AS
 SELECT w.workflowcode,
    w.workflownamear,
    count(*) AS total_requests,
    count(*) FILTER (WHERE ((r.status)::text = 'APPROVED'::text)) AS approved,
    count(*) FILTER (WHERE ((r.status)::text = 'REJECTED'::text)) AS rejected,
    count(*) FILTER (WHERE ((r.status)::text = 'CANCELLED'::text)) AS cancelled,
    count(*) FILTER (WHERE ((r.status)::text = 'EXPIRED'::text)) AS expired,
    count(*) FILTER (WHERE ((r.status)::text = 'PENDING'::text)) AS still_pending,
        CASE
            WHEN (count(*) FILTER (WHERE ((r.status)::text = ANY ((ARRAY['APPROVED'::character varying, 'REJECTED'::character varying])::text[]))) > 0) THEN round((((count(*) FILTER (WHERE ((r.status)::text = 'APPROVED'::text)))::numeric / (count(*) FILTER (WHERE ((r.status)::text = ANY ((ARRAY['APPROVED'::character varying, 'REJECTED'::character varying])::text[]))))::numeric) * (100)::numeric), 2)
            ELSE (0)::numeric
        END AS approvalrate_percent,
    round(avg((EXTRACT(epoch FROM (r.completedate - r.adddate)) / 3600.0)) FILTER (WHERE (r.completedate IS NOT NULL)), 2) AS avg_completion_hours
   FROM (public.tblapprovalrequests r
     JOIN public.tblapprovalworkflows w ON ((r.workflowid = w.workflowid)))
  GROUP BY w.workflowcode, w.workflownamear;


ALTER VIEW public.vw_approvalmetrics OWNER TO postgres;

--
-- Name: vw_bankaccountbalances; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_bankaccountbalances AS
 SELECT ba.bankaccountid,
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
   FROM ((public.tblbankaccounts ba
     JOIN public.tblbanks b ON ((ba.bankid = b.bankcode)))
     JOIN public.tblcurrencies c ON ((ba.currid = c.currencycode)));


ALTER VIEW public.vw_bankaccountbalances OWNER TO postgres;

--
-- Name: vw_bankrecon_status; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_bankrecon_status AS
 SELECT r.reconid,
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
   FROM ((public.tblbankreconciliations r
     JOIN public.tblbankaccounts ba ON ((r.bankaccountid = ba.bankaccountid)))
     JOIN public.tblbanks b ON ((ba.bankid = b.bankcode)))
  ORDER BY r.periodto DESC;


ALTER VIEW public.vw_bankrecon_status OWNER TO postgres;

--
-- Name: vw_bond_with_dimensions; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_bond_with_dimensions AS
 SELECT bh.bondcode,
    bh.bondid,
    bh.bondtype,
    bh.bonddate,
    bh.fiscalyear,
    bh.fiscalperiod,
    bh.amount,
    bh.currencycode,
    bh.exchangerate,
    bh.paymentmethodcode,
    bh.bankcode,
    bh.fundcode,
    bh.customercode,
    bh.suppliercode,
    bh.accountcode,
    d.departmentcode,
    d.namear AS departmentname,
    p.projectcode,
    p.namear AS projectname,
    bu.businessunitcode,
    bu.namear AS businessunitname,
    s.segmentcode,
    s.namear AS segmentname,
    pc.profitcentercode,
    pc.namear AS profitcentername,
    cc.costcentercode,
    cc.costcenternamear AS costcentername,
    bh.isposted,
    bh.approvalrequestid,
    bh.notes
   FROM ((((((public.tblbondheader bh
     LEFT JOIN public.tbldim_departments d ON ((d.departmentcode = bh.departmentcode)))
     LEFT JOIN public.tbldim_projects p ON ((p.projectcode = bh.projectcode)))
     LEFT JOIN public.tbldim_businessunits bu ON ((bu.businessunitcode = bh.businessunitcode)))
     LEFT JOIN public.tbldim_segments s ON ((s.segmentcode = bh.segmentcode)))
     LEFT JOIN public.tbldim_profitcenters pc ON ((pc.profitcentercode = bh.profitcentercode)))
     LEFT JOIN public.tblcostcenters cc ON (((cc.costcentercode = bh.accountcode) AND false)));


ALTER VIEW public.vw_bond_with_dimensions OWNER TO postgres;

--
-- Name: vw_bonds_with_approval; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_bonds_with_approval AS
 SELECT b.bondcode,
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
            WHEN ((ar.status)::text = 'APPROVED'::text) THEN true
            WHEN ((ar.status)::text = 'PENDING'::text) THEN false
            WHEN (ar.status IS NULL) THEN (b.amount < public.getapprovalconfig('BOND_AUTO_APPROVE_THRESHOLD'::character varying))
            ELSE false
        END AS isapproved,
        CASE
            WHEN ((ar.duedate < now()) AND ((ar.status)::text = 'PENDING'::text)) THEN true
            ELSE false
        END AS isoverdue
   FROM (public.tblbondheader b
     LEFT JOIN public.tblapprovalrequests ar ON ((b.approvalrequestid = ar.requestid)))
  ORDER BY b.bonddate DESC;


ALTER VIEW public.vw_bonds_with_approval OWNER TO postgres;

--
-- Name: vw_budgetvsactual_by_dimension; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_budgetvsactual_by_dimension AS
 SELECT 'DEPARTMENT'::text AS dimtype,
    (b.departmentcode)::text AS dimcode,
    NULL::text AS dimname,
    b.periodid,
    b.accountid,
    b.branchid,
    b.budgetamount,
    COALESCE(sum(GREATEST(jb.debit, jb.credit)), (0)::numeric) AS actualamount,
    (b.budgetamount - COALESCE(sum(GREATEST(jb.debit, jb.credit)), (0)::numeric)) AS varianceamount
   FROM ((public.tblbudgets b
     LEFT JOIN public.tbljournalbody jb ON ((jb.departmentcode = b.departmentcode)))
     LEFT JOIN public.tbljournalheader jh ON (((jh.journalcode = jb.journalcode) AND (jh.isposted = true) AND (jh.iscancelled = false))))
  WHERE (b.departmentcode IS NOT NULL)
  GROUP BY b.departmentcode, b.periodid, b.accountid, b.branchid, b.budgetamount
UNION ALL
 SELECT 'PROJECT'::text AS dimtype,
    (b.projectcode)::text AS dimcode,
    NULL::text AS dimname,
    b.periodid,
    b.accountid,
    b.branchid,
    b.budgetamount,
    COALESCE(sum(GREATEST(jb.debit, jb.credit)), (0)::numeric) AS actualamount,
    (b.budgetamount - COALESCE(sum(GREATEST(jb.debit, jb.credit)), (0)::numeric)) AS varianceamount
   FROM ((public.tblbudgets b
     LEFT JOIN public.tbljournalbody jb ON ((jb.projectcode = b.projectcode)))
     LEFT JOIN public.tbljournalheader jh ON (((jh.journalcode = jb.journalcode) AND (jh.isposted = true) AND (jh.iscancelled = false))))
  WHERE (b.projectcode IS NOT NULL)
  GROUP BY b.projectcode, b.periodid, b.accountid, b.branchid, b.budgetamount
UNION ALL
 SELECT 'BUSINESSUNIT'::text AS dimtype,
    (b.businessunitcode)::text AS dimcode,
    NULL::text AS dimname,
    b.periodid,
    b.accountid,
    b.branchid,
    b.budgetamount,
    COALESCE(sum(GREATEST(jb.debit, jb.credit)), (0)::numeric) AS actualamount,
    (b.budgetamount - COALESCE(sum(GREATEST(jb.debit, jb.credit)), (0)::numeric)) AS varianceamount
   FROM ((public.tblbudgets b
     LEFT JOIN public.tbljournalbody jb ON ((jb.businessunitcode = b.businessunitcode)))
     LEFT JOIN public.tbljournalheader jh ON (((jh.journalcode = jb.journalcode) AND (jh.isposted = true) AND (jh.iscancelled = false))))
  WHERE (b.businessunitcode IS NOT NULL)
  GROUP BY b.businessunitcode, b.periodid, b.accountid, b.branchid, b.budgetamount
UNION ALL
 SELECT 'COSTCENTER'::text AS dimtype,
    (b.costcenterid)::text AS dimcode,
    cc.costcenternamear AS dimname,
    b.periodid,
    b.accountid,
    b.branchid,
    b.budgetamount,
    COALESCE(sum(GREATEST(jb.debit, jb.credit)), (0)::numeric) AS actualamount,
    (b.budgetamount - COALESCE(sum(GREATEST(jb.debit, jb.credit)), (0)::numeric)) AS varianceamount
   FROM (((public.tblbudgets b
     LEFT JOIN public.tblcostcenters cc ON ((cc.costcentercode = b.costcenterid)))
     LEFT JOIN public.tbljournalbody jb ON ((jb.costcentercode = b.costcenterid)))
     LEFT JOIN public.tbljournalheader jh ON (((jh.journalcode = jb.journalcode) AND (jh.isposted = true) AND (jh.iscancelled = false))))
  WHERE (b.costcenterid IS NOT NULL)
  GROUP BY b.costcenterid, cc.costcenternamear, b.periodid, b.accountid, b.branchid, b.budgetamount;


ALTER VIEW public.vw_budgetvsactual_by_dimension OWNER TO postgres;

--
-- Name: vw_cash_with_approval; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_cash_with_approval AS
 SELECT 'CASH_RECEIPT'::text AS transactiontype,
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
            WHEN ((ar.status)::text = 'APPROVED'::text) THEN true
            WHEN ((ar.status)::text = 'PENDING'::text) THEN false
            WHEN (ar.status IS NULL) THEN (cr.amountlocal < public.getapprovalconfig('CASH_AUTO_APPROVE_THRESHOLD'::character varying))
            ELSE false
        END AS isapproved
   FROM ((public.tblcashreceipts cr
     JOIN public.tblcashboxes c ON ((cr.cashboxid = c.cashboxid)))
     LEFT JOIN public.tblapprovalrequests ar ON ((cr.approvalrequestid = ar.requestid)))
UNION ALL
 SELECT 'CASH_PAYMENT'::text AS transactiontype,
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
            WHEN ((ar.status)::text = 'APPROVED'::text) THEN true
            WHEN ((ar.status)::text = 'PENDING'::text) THEN false
            WHEN (ar.status IS NULL) THEN (cp.amountlocal < public.getapprovalconfig('CASH_AUTO_APPROVE_THRESHOLD'::character varying))
            ELSE false
        END AS isapproved
   FROM ((public.tblcashpayments cp
     JOIN public.tblcashboxes c ON ((cp.cashboxid = c.cashboxid)))
     LEFT JOIN public.tblapprovalrequests ar ON ((cp.approvalrequestid = ar.requestid)))
  ORDER BY 4 DESC;


ALTER VIEW public.vw_cash_with_approval OWNER TO postgres;

--
-- Name: vw_cashboxbalances; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_cashboxbalances AS
 SELECT cb.cashboxid,
    cb.cashboxcode,
    cb.cashboxname,
    cb.currentbalance,
    c.currencycode,
    c.currencyid,
    c.currencynamear AS currencyname,
    c.symbol,
    cb.isactive,
    cb.branchid
   FROM (public.tblcashboxes cb
     JOIN public.tblcurrencies c ON ((cb.currid = c.currencycode)));


ALTER VIEW public.vw_cashboxbalances OWNER TO postgres;

--
-- Name: vw_cashflow_daily; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_cashflow_daily AS
 SELECT (day.day)::date AS day,
    COALESCE(r.total_in, (0)::numeric) AS total_in,
    COALESCE(p.total_out, (0)::numeric) AS total_out,
    (COALESCE(r.total_in, (0)::numeric) - COALESCE(p.total_out, (0)::numeric)) AS net_flow
   FROM ((generate_series((( SELECT min(tblcashreceipts.receiptdate) AS min
           FROM public.tblcashreceipts))::timestamp with time zone, (( SELECT max(tblcashreceipts.receiptdate) AS max
           FROM public.tblcashreceipts))::timestamp with time zone, '1 day'::interval) day(day)
     LEFT JOIN ( SELECT tblcashreceipts.receiptdate,
            sum(tblcashreceipts.amountlocal) AS total_in
           FROM public.tblcashreceipts
          WHERE ((tblcashreceipts.status)::text = 'POSTED'::text)
          GROUP BY tblcashreceipts.receiptdate) r ON ((r.receiptdate = (day.day)::date)))
     LEFT JOIN ( SELECT tblcashpayments.paymentdate,
            sum(tblcashpayments.amountlocal) AS total_out
           FROM public.tblcashpayments
          WHERE ((tblcashpayments.status)::text = 'POSTED'::text)
          GROUP BY tblcashpayments.paymentdate) p ON ((p.paymentdate = (day.day)::date)))
  ORDER BY ((day.day)::date);


ALTER VIEW public.vw_cashflow_daily OWNER TO postgres;

--
-- Name: vw_costcenter_hierarchy; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_costcenter_hierarchy AS
 WITH RECURSIVE t AS (
         SELECT tblcostcenters.costcentercode,
            tblcostcenters.costcenterid,
            tblcostcenters.costcenternamear,
            tblcostcenters.costcenternameen,
            0 AS level,
            (tblcostcenters.costcenternamear)::text AS fullpath,
            tblcostcenters.parentcostcentercode,
            tblcostcenters.isactive
           FROM public.tblcostcenters
          WHERE (tblcostcenters.parentcostcentercode IS NULL)
        UNION ALL
         SELECT c.costcentercode,
            c.costcenterid,
            c.costcenternamear,
            c.costcenternameen,
            (t_1.level + 1),
            ((t_1.fullpath || ' / '::text) || (c.costcenternamear)::text) AS text,
            c.parentcostcentercode,
            c.isactive
           FROM (public.tblcostcenters c
             JOIN t t_1 ON ((c.parentcostcentercode = t_1.costcentercode)))
        )
 SELECT costcentercode,
    costcenterid,
    costcenternamear,
    costcenternameen,
    level,
    fullpath,
    parentcostcentercode,
    isactive
   FROM t
  ORDER BY fullpath;


ALTER VIEW public.vw_costcenter_hierarchy OWNER TO postgres;

--
-- Name: vw_customerlist; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_customerlist AS
 SELECT c.customercode,
    c.customerid,
    c.customernamear,
    c.customernameen,
    c.customertype,
    c.email,
    c.mobile,
    c.phone,
    c.city,
    c.country,
    c.branchcode,
    b.branchnamear AS branchname,
    c.pricelistcode,
    c.paymenttermcode,
    c.creditlimit,
    c.currentcredit,
    c.availablecredit,
    c.paymentdays,
    c.isactive,
    c.isblocked,
    c.customersince,
    c.lastsaledate,
    c.totalsales,
    c.balance,
    c.taxnumber,
    c.vatnumber
   FROM (public.tblcustomers c
     LEFT JOIN public.tblbranches b ON ((c.branchcode = b.branchcode)));


ALTER VIEW public.vw_customerlist OWNER TO postgres;

--
-- Name: vw_db_size_summary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_db_size_summary AS
 SELECT (((schemaname)::text || '.'::text) || (tablename)::text) AS table_name,
    pg_total_relation_size(((((schemaname)::text || '.'::text) || (tablename)::text))::regclass) AS total_bytes,
    pg_size_pretty(pg_total_relation_size(((((schemaname)::text || '.'::text) || (tablename)::text))::regclass)) AS total_size,
    pg_relation_size(((((schemaname)::text || '.'::text) || (tablename)::text))::regclass) AS table_bytes,
    pg_size_pretty(pg_relation_size(((((schemaname)::text || '.'::text) || (tablename)::text))::regclass)) AS table_size,
    (pg_total_relation_size(((((schemaname)::text || '.'::text) || (tablename)::text))::regclass) - pg_relation_size(((((schemaname)::text || '.'::text) || (tablename)::text))::regclass)) AS index_bytes,
    pg_size_pretty((pg_total_relation_size(((((schemaname)::text || '.'::text) || (tablename)::text))::regclass) - pg_relation_size(((((schemaname)::text || '.'::text) || (tablename)::text))::regclass))) AS index_size,
    ( SELECT pg_stat_user_tables.n_live_tup
           FROM pg_stat_user_tables
          WHERE ((pg_stat_user_tables.schemaname = t.schemaname) AND (pg_stat_user_tables.relname = t.tablename))) AS approx_row_count
   FROM pg_tables t
  WHERE (schemaname = 'public'::name)
  ORDER BY (pg_total_relation_size(((((schemaname)::text || '.'::text) || (tablename)::text))::regclass)) DESC
 LIMIT 20;


ALTER VIEW public.vw_db_size_summary OWNER TO postgres;

--
-- Name: vw_dimension_usage; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_dimension_usage AS
 SELECT 'BOND'::text AS source,
    'DEPARTMENT'::text AS dimtype,
    count(*) AS usage_count
   FROM public.tblbondheader
  WHERE (tblbondheader.departmentcode IS NOT NULL)
UNION ALL
 SELECT 'BOND'::text AS source,
    'PROJECT'::text AS dimtype,
    count(*) AS usage_count
   FROM public.tblbondheader
  WHERE (tblbondheader.projectcode IS NOT NULL)
UNION ALL
 SELECT 'BOND'::text AS source,
    'BUSINESSUNIT'::text AS dimtype,
    count(*) AS usage_count
   FROM public.tblbondheader
  WHERE (tblbondheader.businessunitcode IS NOT NULL)
UNION ALL
 SELECT 'BOND'::text AS source,
    'SEGMENT'::text AS dimtype,
    count(*) AS usage_count
   FROM public.tblbondheader
  WHERE (tblbondheader.segmentcode IS NOT NULL)
UNION ALL
 SELECT 'BOND'::text AS source,
    'PROFITCENTER'::text AS dimtype,
    count(*) AS usage_count
   FROM public.tblbondheader
  WHERE (tblbondheader.profitcentercode IS NOT NULL)
UNION ALL
 SELECT 'JOURNAL_BODY'::text AS source,
    'DEPARTMENT'::text AS dimtype,
    count(*) AS usage_count
   FROM public.tbljournalbody
  WHERE (tbljournalbody.departmentcode IS NOT NULL)
UNION ALL
 SELECT 'JOURNAL_BODY'::text AS source,
    'PROJECT'::text AS dimtype,
    count(*) AS usage_count
   FROM public.tbljournalbody
  WHERE (tbljournalbody.projectcode IS NOT NULL)
UNION ALL
 SELECT 'CASH_RECEIPT'::text AS source,
    'DEPARTMENT'::text AS dimtype,
    count(*) AS usage_count
   FROM public.tblcashreceipts
  WHERE (tblcashreceipts.departmentcode IS NOT NULL)
UNION ALL
 SELECT 'CASH_RECEIPT'::text AS source,
    'PROJECT'::text AS dimtype,
    count(*) AS usage_count
   FROM public.tblcashreceipts
  WHERE (tblcashreceipts.projectcode IS NOT NULL)
UNION ALL
 SELECT 'CASH_PAYMENT'::text AS source,
    'DEPARTMENT'::text AS dimtype,
    count(*) AS usage_count
   FROM public.tblcashpayments
  WHERE (tblcashpayments.departmentcode IS NOT NULL)
UNION ALL
 SELECT 'BANK_TXN'::text AS source,
    'DEPARTMENT'::text AS dimtype,
    count(*) AS usage_count
   FROM public.tblbanktransactions
  WHERE (tblbanktransactions.departmentcode IS NOT NULL)
UNION ALL
 SELECT 'BUDGET'::text AS source,
    'DEPARTMENT'::text AS dimtype,
    count(*) AS usage_count
   FROM public.tblbudgets
  WHERE (tblbudgets.departmentcode IS NOT NULL)
UNION ALL
 SELECT 'BUDGET'::text AS source,
    'PROJECT'::text AS dimtype,
    count(*) AS usage_count
   FROM public.tblbudgets
  WHERE (tblbudgets.projectcode IS NOT NULL);


ALTER VIEW public.vw_dimension_usage OWNER TO postgres;

--
-- Name: vw_dimensions_summary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_dimensions_summary AS
 SELECT 'DEPARTMENT'::text AS dimtype,
    count(*) AS total,
    sum(
        CASE
            WHEN tbldim_departments.isactive THEN 1
            ELSE 0
        END) AS active
   FROM public.tbldim_departments
UNION ALL
 SELECT 'PROJECT'::text AS dimtype,
    count(*) AS total,
    sum(
        CASE
            WHEN tbldim_projects.isactive THEN 1
            ELSE 0
        END) AS active
   FROM public.tbldim_projects
UNION ALL
 SELECT 'BUSINESSUNIT'::text AS dimtype,
    count(*) AS total,
    sum(
        CASE
            WHEN tbldim_businessunits.isactive THEN 1
            ELSE 0
        END) AS active
   FROM public.tbldim_businessunits
UNION ALL
 SELECT 'SEGMENT'::text AS dimtype,
    count(*) AS total,
    sum(
        CASE
            WHEN tbldim_segments.isactive THEN 1
            ELSE 0
        END) AS active
   FROM public.tbldim_segments
UNION ALL
 SELECT 'PROFITCENTER'::text AS dimtype,
    count(*) AS total,
    sum(
        CASE
            WHEN tbldim_profitcenters.isactive THEN 1
            ELSE 0
        END) AS active
   FROM public.tbldim_profitcenters
UNION ALL
 SELECT 'COSTCENTER'::text AS dimtype,
    count(*) AS total,
    sum(
        CASE
            WHEN tblcostcenters.isactive THEN 1
            ELSE 0
        END) AS active
   FROM public.tblcostcenters;


ALTER VIEW public.vw_dimensions_summary OWNER TO postgres;

--
-- Name: vw_documents_by_source; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_documents_by_source AS
 SELECT attachmentid,
    source_type,
    source_id,
    count(*) AS attachmentcount,
    sum(filesize) AS totalbytes,
    max(uploaddate) AS lastupload
   FROM public.tbldocumentattachments a
  GROUP BY source_type, source_id, attachmentid
  ORDER BY source_type, source_id;


ALTER VIEW public.vw_documents_by_source OWNER TO postgres;

--
-- Name: vw_fiscalperiodstatus; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_fiscalperiodstatus AS
 SELECT fy.fiscalyearid,
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
            WHEN fp.isclosed THEN 'CLOSED'::text
            WHEN ((CURRENT_DATE >= fp.startdate) AND (CURRENT_DATE <= fp.enddate)) THEN 'CURRENT'::text
            WHEN (CURRENT_DATE < fp.startdate) THEN 'FUTURE'::text
            ELSE 'PAST'::text
        END AS periodstatus
   FROM (public.tblfiscalyears fy
     LEFT JOIN public.tblfiscalperiods fp ON ((fy.fiscalyearid = fp.fiscalyearid)))
  ORDER BY fy.fiscalyearname DESC, fp.periodnumber;


ALTER VIEW public.vw_fiscalperiodstatus OWNER TO postgres;

--
-- Name: vw_index_usage; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_index_usage AS
 SELECT (((schemaname)::text || '.'::text) || (relname)::text) AS table_name,
    seq_scan AS sequential_scans,
    seq_tup_read AS rows_from_seq_scan,
    idx_scan AS index_scans,
    idx_tup_fetch AS rows_from_idx_scan,
        CASE
            WHEN ((seq_scan + idx_scan) = 0) THEN NULL::numeric
            ELSE round((((idx_scan)::numeric / (NULLIF((seq_scan + idx_scan), 0))::numeric) * (100)::numeric), 2)
        END AS index_scan_pct,
    pg_size_pretty(pg_relation_size((relid)::regclass)) AS table_size
   FROM pg_stat_user_tables s
  ORDER BY seq_scan DESC;


ALTER VIEW public.vw_index_usage OWNER TO postgres;

--
-- Name: vw_journalbody_with_dimensions; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_journalbody_with_dimensions AS
 SELECT jb.journaldetailid,
    jb.journalcode,
    jb.linenumber,
    jb.accountcode,
    cc.costcentercode,
    cc.costcenternamear AS costcentername,
    d.departmentcode,
    d.namear AS departmentname,
    p.projectcode,
    p.namear AS projectname,
    bu.businessunitcode,
    bu.namear AS businessunitname,
    s.segmentcode,
    s.namear AS segmentname,
    pc.profitcentercode,
    pc.namear AS profitcentername,
    jb.description,
    jb.debit,
    jb.credit,
    jb.currencycode,
    jb.debitlocal,
    jb.creditlocal
   FROM ((((((public.tbljournalbody jb
     LEFT JOIN public.tblcostcenters cc ON ((cc.costcentercode = jb.costcentercode)))
     LEFT JOIN public.tbldim_departments d ON ((d.departmentcode = jb.departmentcode)))
     LEFT JOIN public.tbldim_projects p ON ((p.projectcode = jb.projectcode)))
     LEFT JOIN public.tbldim_businessunits bu ON ((bu.businessunitcode = jb.businessunitcode)))
     LEFT JOIN public.tbldim_segments s ON ((s.segmentcode = jb.segmentcode)))
     LEFT JOIN public.tbldim_profitcenters pc ON ((pc.profitcentercode = jb.profitcentercode)));


ALTER VIEW public.vw_journalbody_with_dimensions OWNER TO postgres;

--
-- Name: vw_journals_with_approval; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_journals_with_approval AS
 SELECT j.journalcode,
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
            WHEN ((ar.status)::text = 'APPROVED'::text) THEN true
            WHEN ((ar.status)::text = 'PENDING'::text) THEN false
            WHEN (ar.status IS NULL) THEN (j.totaldebit < public.getapprovalconfig('JOURNAL_AUTO_APPROVE_THRESHOLD'::character varying))
            ELSE false
        END AS isapproved,
        CASE
            WHEN ((ar.duedate < now()) AND ((ar.status)::text = 'PENDING'::text)) THEN true
            ELSE false
        END AS isoverdue
   FROM (public.tbljournalheader j
     LEFT JOIN public.tblapprovalrequests ar ON ((j.approvalrequestid = ar.requestid)))
  ORDER BY j.journaldate DESC;


ALTER VIEW public.vw_journals_with_approval OWNER TO postgres;

--
-- Name: vw_login; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_login AS
 SELECT usercode,
    userid,
    encode(userpassword, 'escape'::text) AS "PWD",
    usernamear,
    usernameen,
    isactive,
    isadmin,
    branchcode
   FROM public.tblusers;


ALTER VIEW public.vw_login OWNER TO postgres;

--
-- Name: vw_long_running_queries; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_long_running_queries AS
 SELECT pid AS session_id,
    usename AS db_user,
    application_name AS app,
    client_addr AS client_ip,
    "substring"(query, 1, 300) AS current_query,
    (EXTRACT(epoch FROM (now() - query_start)))::integer AS duration_s,
    state AS session_state
   FROM pg_stat_activity
  WHERE ((backend_type = 'client backend'::text) AND (state = 'active'::text) AND (query_start IS NOT NULL) AND ((now() - query_start) > '00:00:30'::interval) AND (pid <> pg_backend_pid()))
  ORDER BY query_start;


ALTER VIEW public.vw_long_running_queries OWNER TO postgres;

--
-- Name: vw_most_seq_scanned; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_most_seq_scanned AS
 SELECT (((schemaname)::text || '.'::text) || (relname)::text) AS table_name,
    seq_scan AS seq_scan_count,
    idx_scan AS idx_scan_count,
        CASE
            WHEN ((seq_scan + idx_scan) = 0) THEN (0)::numeric
            ELSE round((((seq_scan)::numeric / (NULLIF((seq_scan + idx_scan), 0))::numeric) * (100)::numeric), 2)
        END AS seq_scan_pct,
    n_live_tup AS approx_row_count,
    pg_size_pretty(pg_relation_size((relid)::regclass)) AS table_size
   FROM pg_stat_user_tables s
  WHERE (seq_scan > 100)
  ORDER BY seq_scan DESC
 LIMIT 50;


ALTER VIEW public.vw_most_seq_scanned OWNER TO postgres;

--
-- Name: vw_pendingapprovals; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_pendingapprovals AS
 SELECT r.requestid,
    r.requestno,
    r.sourcetype,
    r.sourceid,
    w.workflowcode,
    w.workflownamear,
    l.levelnumber,
    l.levelnamear,
    r.totalsum,
    c.currencynamear AS currencyname,
    u_requester.usercode AS requesterid,
    u_requester.usernamear AS requester,
    r.duedate,
    r.priority,
    r.adddate,
    (EXTRACT(epoch FROM (now() - (r.adddate)::timestamp with time zone)) / 3600.0) AS hourswaiting,
        CASE
            WHEN (r.duedate < now()) THEN 'OVERDUE'::text
            ELSE 'ON_TIME'::text
        END AS timeliness
   FROM ((((public.tblapprovalrequests r
     JOIN public.tblapprovalworkflows w ON ((r.workflowid = w.workflowid)))
     JOIN public.tblapprovallevels l ON (((r.workflowid = l.workflowid) AND (l.levelnumber = r.currentlevel))))
     JOIN public.tblusers u_requester ON ((r.requesterid = u_requester.usercode)))
     LEFT JOIN public.tblcurrencies c ON ((r.currencycode = c.currencycode)))
  WHERE ((r.status)::text = 'PENDING'::text)
  ORDER BY
        CASE r.priority
            WHEN 'URGENT'::text THEN 1
            WHEN 'HIGH'::text THEN 2
            WHEN 'NORMAL'::text THEN 3
            WHEN 'LOW'::text THEN 4
            ELSE NULL::integer
        END, r.duedate, r.adddate;


ALTER VIEW public.vw_pendingapprovals OWNER TO postgres;

--
-- Name: vw_productmovementsummary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_productmovementsummary AS
 SELECT pm.movementid,
    pm.movementtype,
    pm.movementdate,
    p.productid,
    p.productnamear,
    st.storenamear AS storename,
    pm.quantity AS qty,
    pm.unitcost,
    pm.referencetype,
    pm.referencecode,
    pm.notes,
        CASE
            WHEN (pm.quantity > (0)::numeric) THEN 'IN'::text
            ELSE 'OUT'::text
        END AS direction
   FROM ((public.tblproductmovement pm
     JOIN public.tblproducts p ON ((pm.productcode = p.productcode)))
     JOIN public.tblstores st ON ((pm.storecode = st.storecode)));


ALTER VIEW public.vw_productmovementsummary OWNER TO postgres;

--
-- Name: vw_productstocksummary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_productstocksummary AS
 SELECT p.productcode,
    p.productid,
    p.productnamear,
    p.productnameen,
    p.categorycode,
    c.categorynamear AS categoryname,
    p.defaultunitcode,
    u.unitnamear AS unitname,
    p.standardcost,
    p.lastpurchaseprice,
    p.lastsaleprice,
    COALESCE(sp.qtyonhand, (0)::numeric) AS totalqtyonhand,
    COALESCE(sp.qtyreserved, (0)::numeric) AS totalqtyreserved,
    (COALESCE(sp.qtyonhand, (0)::numeric) - COALESCE(sp.qtyreserved, (0)::numeric)) AS qtyavailable,
    COALESCE(sp.avgcost, (0)::numeric) AS avgcost,
    p.minstocklevel,
    p.maxstocklevel,
        CASE
            WHEN (COALESCE(sp.qtyonhand, (0)::numeric) <= p.minstocklevel) THEN 'LOW_STOCK'::text
            WHEN (COALESCE(sp.qtyonhand, (0)::numeric) >= p.maxstocklevel) THEN 'OVER_STOCK'::text
            ELSE 'NORMAL'::text
        END AS stockstatus
   FROM (((public.tblproducts p
     LEFT JOIN public.tblcategories c ON ((p.categorycode = c.categorycode)))
     LEFT JOIN public.tblunits u ON ((p.defaultunitcode = u.unitcode)))
     LEFT JOIN ( SELECT tblstoreproducts.productcode,
            sum(tblstoreproducts.qtyonhand) AS qtyonhand,
            sum(tblstoreproducts.qtyreserved) AS qtyreserved,
            avg(tblstoreproducts.avgcost) AS avgcost
           FROM public.tblstoreproducts
          WHERE (tblstoreproducts.isactive = true)
          GROUP BY tblstoreproducts.productcode) sp ON ((p.productcode = sp.productcode)))
  WHERE ((p.isactive = true) AND (p.isinventoryitem = true));


ALTER VIEW public.vw_productstocksummary OWNER TO postgres;

--
-- Name: vw_purchasesummary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_purchasesummary AS
 SELECT oh.operationcode AS operationid,
    oh.operationid AS operationno,
    oh.operationtype,
    oh.operationdate,
    oh.suppliercode,
    s.suppliernamear AS suppliername,
    s.supplierid AS suppliercodeid,
    oh.branchcode,
    b.branchnamear AS branchname,
    oh.storecode,
    st.storenamear AS storename,
    oh.currencycode,
    oh.subtotal,
    oh.discountamount,
    oh.taxamount,
    oh.total,
    oh.paidamount,
    oh.remainingamount,
    oh.createdby AS usercode,
    u.usernamear AS createdbyname,
    oh.createdat
   FROM ((((public.tbloperationheader oh
     LEFT JOIN public.tblsuppliers s ON ((oh.suppliercode = s.suppliercode)))
     LEFT JOIN public.tblbranches b ON ((oh.branchcode = b.branchcode)))
     LEFT JOIN public.tblstores st ON ((oh.storecode = st.storecode)))
     LEFT JOIN public.tblusers u ON ((oh.createdby = u.usercode)))
  WHERE ((oh.operationtype)::text = ANY ((ARRAY['PURCHASE'::character varying, 'PURCHASE_RETURN'::character varying])::text[]));


ALTER VIEW public.vw_purchasesummary OWNER TO postgres;

--
-- Name: vw_recentaudithistory; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_recentaudithistory AS
 SELECT audithistid,
    tablename,
    recordid,
    action,
    username,
    userid,
    clientip,
    sessionid,
    actiondate
   FROM public.tblaudi a
  ORDER BY actiondate DESC
 LIMIT 1000;


ALTER VIEW public.vw_recentaudithistory OWNER TO postgres;

--
-- Name: vw_salessummary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_salessummary AS
 SELECT oh.operationcode AS operationid,
    oh.operationid AS operationno,
    oh.operationtype,
    oh.operationdate,
    oh.customercode,
    c.customernamear AS customername,
    c.customerid AS customercodeid,
    oh.branchcode,
    b.branchnamear AS branchname,
    oh.storecode,
    st.storenamear AS storename,
    oh.currencycode,
    oh.subtotal,
    oh.discountamount,
    oh.taxamount,
    oh.total,
    oh.paidamount,
    oh.remainingamount,
    oh.createdby AS usercode,
    u.usernamear AS createdbyname,
    oh.createdat
   FROM ((((public.tbloperationheader oh
     LEFT JOIN public.tblcustomers c ON ((oh.customercode = c.customercode)))
     LEFT JOIN public.tblbranches b ON ((oh.branchcode = b.branchcode)))
     LEFT JOIN public.tblstores st ON ((oh.storecode = st.storecode)))
     LEFT JOIN public.tblusers u ON ((oh.createdby = u.usercode)))
  WHERE ((oh.operationtype)::text = ANY ((ARRAY['SALE'::character varying, 'SALE_RETURN'::character varying])::text[]));


ALTER VIEW public.vw_salessummary OWNER TO postgres;

--
-- Name: vw_slow_queries; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_slow_queries AS
 SELECT "substring"(s.query, 1, 200) AS query_snippet,
    s.calls AS call_count,
    round(((s.total_exec_time / (1000.0)::double precision))::numeric, 2) AS total_time_s,
    round((s.mean_exec_time)::numeric, 2) AS mean_time_ms,
    round((s.max_exec_time)::numeric, 2) AS max_time_ms,
    s.rows AS total_rows,
    (s.shared_blks_hit + s.shared_blks_read) AS total_blocks,
    d.datname AS database
   FROM (public.pg_stat_statements s
     LEFT JOIN pg_database d ON ((d.oid = s.dbid)))
  WHERE (s.calls > 0)
  ORDER BY s.mean_exec_time DESC;


ALTER VIEW public.vw_slow_queries OWNER TO postgres;

--
-- Name: vw_supplierlist; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_supplierlist AS
 SELECT s.suppliercode,
    s.supplierid,
    s.suppliernamear,
    s.suppliernameen,
    s.suppliertype,
    s.email,
    s.mobile,
    s.phone,
    s.city,
    s.country,
    s.branchcode,
    b.branchnamear AS branchname,
    s.paymenttermcode,
    s.creditlimit,
    s.currentcredit,
    s.availablecredit,
    s.paymentdays,
    s.isactive,
    s.isblocked,
    s.suppliersince,
    s.lastpurchasedate,
    s.totalpurchases,
    s.balance,
    s.taxnumber,
    s.vatnumber,
    s.bankname,
    s.iban
   FROM (public.tblsuppliers s
     LEFT JOIN public.tblbranches b ON ((s.branchcode = b.branchcode)));


ALTER VIEW public.vw_supplierlist OWNER TO postgres;

--
-- Name: vw_taxtransactions_full; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_taxtransactions_full AS
 SELECT tt.taxtransid,
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
   FROM (public.tbltaxtransactions tt
     JOIN public.tbltaxdefinitions td ON ((tt.taxid = td.taxid)))
  ORDER BY tt.txndate DESC;


ALTER VIEW public.vw_taxtransactions_full OWNER TO postgres;

--
-- Name: vw_treasury_with_dimensions; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_treasury_with_dimensions AS
 SELECT 'CASH_RECEIPT'::text AS txntype,
    (r.receiptid)::text AS txnid,
    r.receiptno AS txnno,
    r.receiptdate AS txndate,
    r.amount,
    r.currid,
    r.exgrate,
    r.amountlocal,
    r.customerid,
    r.supplierid,
    r.status,
    r.approvalrequestid,
    r.departmentcode,
    d.namear AS departmentname,
    r.projectcode,
    p.namear AS projectname,
    r.businessunitcode,
    bu.namear AS businessunitname,
    r.segmentcode,
    s.namear AS segmentname,
    r.profitcentercode,
    pc.namear AS profitcentername
   FROM (((((public.tblcashreceipts r
     LEFT JOIN public.tbldim_departments d ON ((d.departmentcode = r.departmentcode)))
     LEFT JOIN public.tbldim_projects p ON ((p.projectcode = r.projectcode)))
     LEFT JOIN public.tbldim_businessunits bu ON ((bu.businessunitcode = r.businessunitcode)))
     LEFT JOIN public.tbldim_segments s ON ((s.segmentcode = r.segmentcode)))
     LEFT JOIN public.tbldim_profitcenters pc ON ((pc.profitcentercode = r.profitcentercode)))
UNION ALL
 SELECT 'CASH_PAYMENT'::text AS txntype,
    (p.paymentid)::text AS txnid,
    p.paymentno AS txnno,
    p.paymentdate AS txndate,
    p.amount,
    p.currid,
    p.exgrate,
    p.amountlocal,
    p.customerid,
    p.supplierid,
    p.status,
    p.approvalrequestid,
    p.departmentcode,
    d.namear AS departmentname,
    p.projectcode,
    pr.namear AS projectname,
    p.businessunitcode,
    bu.namear AS businessunitname,
    p.segmentcode,
    s.namear AS segmentname,
    p.profitcentercode,
    pc.namear AS profitcentername
   FROM (((((public.tblcashpayments p
     LEFT JOIN public.tbldim_departments d ON ((d.departmentcode = p.departmentcode)))
     LEFT JOIN public.tbldim_projects pr ON ((pr.projectcode = p.projectcode)))
     LEFT JOIN public.tbldim_businessunits bu ON ((bu.businessunitcode = p.businessunitcode)))
     LEFT JOIN public.tbldim_segments s ON ((s.segmentcode = p.segmentcode)))
     LEFT JOIN public.tbldim_profitcenters pc ON ((pc.profitcentercode = p.profitcentercode)))
UNION ALL
 SELECT 'BANK_TXN'::text AS txntype,
    (b.banktxnid)::text AS txnid,
    b.refno AS txnno,
    b.txndate,
    b.amount,
    b.currid,
    b.exgrate,
    b.amountlocal,
    NULL::integer AS customerid,
    NULL::integer AS supplierid,
    b.status,
    b.approvalrequestid,
    b.departmentcode,
    d.namear AS departmentname,
    b.projectcode,
    pr.namear AS projectname,
    b.businessunitcode,
    bu.namear AS businessunitname,
    b.segmentcode,
    s.namear AS segmentname,
    b.profitcentercode,
    pc.namear AS profitcentername
   FROM (((((public.tblbanktransactions b
     LEFT JOIN public.tbldim_departments d ON ((d.departmentcode = b.departmentcode)))
     LEFT JOIN public.tbldim_projects pr ON ((pr.projectcode = b.projectcode)))
     LEFT JOIN public.tbldim_businessunits bu ON ((bu.businessunitcode = b.businessunitcode)))
     LEFT JOIN public.tbldim_segments s ON ((s.segmentcode = b.segmentcode)))
     LEFT JOIN public.tbldim_profitcenters pc ON ((pc.profitcentercode = b.profitcentercode)));


ALTER VIEW public.vw_treasury_with_dimensions OWNER TO postgres;

--
-- Name: vw_treasurysummary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_treasurysummary AS
 SELECT 'CASH'::text AS treasurytype,
    cb.cashboxid AS id,
    cb.cashboxcode AS code,
    cb.cashboxname AS name,
    cb.currentbalance,
    c.currencyid,
    c.currencynamear AS currencyname,
    cb.branchid,
    cb.isactive
   FROM (public.tblcashboxes cb
     JOIN public.tblcurrencies c ON ((cb.currid = c.currencycode)))
UNION ALL
 SELECT 'BANK'::text AS treasurytype,
    ba.bankaccountid AS id,
    ba.bankaccountno AS code,
    (((b.banknamear)::text || ' - '::text) || (COALESCE(ba.branchname, ''::character varying))::text) AS name,
    ba.currentbalance,
    c.currencyid,
    c.currencynamear AS currencyname,
    NULL::integer AS branchid,
    ba.isactive
   FROM ((public.tblbankaccounts ba
     JOIN public.tblbanks b ON ((ba.bankid = b.bankcode)))
     JOIN public.tblcurrencies c ON ((ba.currid = c.currencycode)));


ALTER VIEW public.vw_treasurysummary OWNER TO postgres;

--
-- Name: vw_unposted_pending_approval; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_unposted_pending_approval AS
 SELECT 'BOND'::text AS sourcetype,
    b.bondcode AS sourceid,
    b.bondid AS docno,
    b.amount,
    b.bonddate AS docdate,
    ar.status,
    ar.currentlevel,
    ar.totallevels,
    ar.duedate,
        CASE
            WHEN (ar.duedate < now()) THEN 'OVERDUE'::text
            ELSE 'ON_TIME'::text
        END AS timeliness
   FROM (public.tblbondheader b
     JOIN public.tblapprovalrequests ar ON ((b.approvalrequestid = ar.requestid)))
  WHERE (((ar.status)::text = 'PENDING'::text) AND (b.isposted = false))
UNION ALL
 SELECT 'JOURNAL'::text AS sourcetype,
    j.journalcode AS sourceid,
    j.journalid AS docno,
    j.totaldebit AS amount,
    j.journaldate AS docdate,
    ar.status,
    ar.currentlevel,
    ar.totallevels,
    ar.duedate,
        CASE
            WHEN (ar.duedate < now()) THEN 'OVERDUE'::text
            ELSE 'ON_TIME'::text
        END AS timeliness
   FROM (public.tbljournalheader j
     JOIN public.tblapprovalrequests ar ON ((j.approvalrequestid = ar.requestid)))
  WHERE (((ar.status)::text = 'PENDING'::text) AND (j.isposted = false))
UNION ALL
 SELECT 'CASH_RECEIPT'::text AS sourcetype,
    cr.receiptid AS sourceid,
    cr.receiptno AS docno,
    cr.amountlocal AS amount,
    cr.receiptdate AS docdate,
    ar.status,
    ar.currentlevel,
    ar.totallevels,
    ar.duedate,
        CASE
            WHEN (ar.duedate < now()) THEN 'OVERDUE'::text
            ELSE 'ON_TIME'::text
        END AS timeliness
   FROM (public.tblcashreceipts cr
     JOIN public.tblapprovalrequests ar ON ((cr.approvalrequestid = ar.requestid)))
  WHERE ((ar.status)::text = 'PENDING'::text)
UNION ALL
 SELECT 'CASH_PAYMENT'::text AS sourcetype,
    cp.paymentid AS sourceid,
    cp.paymentno AS docno,
    cp.amountlocal AS amount,
    cp.paymentdate AS docdate,
    ar.status,
    ar.currentlevel,
    ar.totallevels,
    ar.duedate,
        CASE
            WHEN (ar.duedate < now()) THEN 'OVERDUE'::text
            ELSE 'ON_TIME'::text
        END AS timeliness
   FROM (public.tblcashpayments cp
     JOIN public.tblapprovalrequests ar ON ((cp.approvalrequestid = ar.requestid)))
  WHERE ((ar.status)::text = 'PENDING'::text)
UNION ALL
 SELECT 'BANK_TXN'::text AS sourcetype,
    bt.banktxnid AS sourceid,
    bt.refno AS docno,
    bt.amountlocal AS amount,
    bt.txndate AS docdate,
    ar.status,
    ar.currentlevel,
    ar.totallevels,
    ar.duedate,
        CASE
            WHEN (ar.duedate < now()) THEN 'OVERDUE'::text
            ELSE 'ON_TIME'::text
        END AS timeliness
   FROM (public.tblbanktransactions bt
     JOIN public.tblapprovalrequests ar ON ((bt.approvalrequestid = ar.requestid)))
  WHERE ((ar.status)::text = 'PENDING'::text)
  ORDER BY 5 DESC;


ALTER VIEW public.vw_unposted_pending_approval OWNER TO postgres;

--
-- Name: vw_unreadnotifications; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_unreadnotifications AS
 SELECT n.notificationid,
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
   FROM (public.tblnotifications n
     JOIN public.tblusers u ON ((n.userid = u.usercode)))
  WHERE (n.isread = false)
  ORDER BY
        CASE n.priority
            WHEN 'URGENT'::text THEN 1
            WHEN 'HIGH'::text THEN 2
            WHEN 'NORMAL'::text THEN 3
            WHEN 'LOW'::text THEN 4
            ELSE NULL::integer
        END, n.createdate DESC;


ALTER VIEW public.vw_unreadnotifications OWNER TO postgres;

--
-- Name: vw_unused_indexes; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_unused_indexes AS
 SELECT (((schemaname)::text || '.'::text) || (relname)::text) AS table_name,
    indexrelname AS index_name,
    idx_scan AS total_scans,
    pg_size_pretty(pg_relation_size((indexrelid)::regclass)) AS index_size,
    pg_relation_size((indexrelid)::regclass) AS index_size_bytes
   FROM pg_stat_user_indexes s
  WHERE ((idx_scan = 0) AND (indexrelname !~~ '%_pkey'::text))
  ORDER BY (pg_relation_size((indexrelid)::regclass)) DESC;


ALTER VIEW public.vw_unused_indexes OWNER TO postgres;

--
-- Name: vw_userdelegations; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_userdelegations AS
 SELECT d.delegationid,
    d.fromuserid,
    u_from.usernamear AS fromuser,
    u_from.userid AS fromuserlogin,
    d.touserid,
    u_to.usernamear AS touser,
    u_to.userid AS touserlogin,
    d.workflowid,
    w.workflowcode,
    d.fromdate,
    d.todate,
    d.reason,
    d.isactive,
        CASE
            WHEN (NOT d.isactive) THEN 'INACTIVE'::text
            WHEN (CURRENT_DATE < d.fromdate) THEN 'PENDING'::text
            WHEN (CURRENT_DATE > d.todate) THEN 'EXPIRED'::text
            ELSE 'ACTIVE'::text
        END AS delegationstatus
   FROM (((public.tblapprovaldelegations d
     JOIN public.tblusers u_from ON ((d.fromuserid = u_from.usercode)))
     JOIN public.tblusers u_to ON ((d.touserid = u_to.usercode)))
     LEFT JOIN public.tblapprovalworkflows w ON ((d.workflowid = w.workflowid)));


ALTER VIEW public.vw_userdelegations OWNER TO postgres;

--
-- Name: vw_workflowsummary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_workflowsummary AS
 SELECT w.workflowid,
    w.workflowcode,
    w.workflownamear,
    w.sourcetype,
    w.isactive,
    count(l.levelid) AS level_count,
    string_agg((l.levelnamear)::text, ' → '::text ORDER BY l.levelnumber) AS level_path,
    min(l.amountmin) AS min_amount,
    max(l.amountmax) AS max_amount
   FROM (public.tblapprovalworkflows w
     LEFT JOIN public.tblapprovallevels l ON (((w.workflowid = l.workflowid) AND (l.isactive = true))))
  GROUP BY w.workflowid, w.workflowcode, w.workflownamear, w.sourcetype, w.isactive
  ORDER BY w.workflowcode;


ALTER VIEW public.vw_workflowsummary OWNER TO postgres;

--
-- Name: tblapprovalactions actionid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovalactions ALTER COLUMN actionid SET DEFAULT nextval('public.tblapprovalactions_actionid_seq'::regclass);


--
-- Name: tblapprovalaudit auditid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovalaudit ALTER COLUMN auditid SET DEFAULT nextval('public.tblapprovalaudit_auditid_seq'::regclass);


--
-- Name: tblapprovalconfig configid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovalconfig ALTER COLUMN configid SET DEFAULT nextval('public.tblapprovalconfig_configid_seq'::regclass);


--
-- Name: tblapprovaldelegations delegationid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovaldelegations ALTER COLUMN delegationid SET DEFAULT nextval('public.tblapprovaldelegations_delegationid_seq'::regclass);


--
-- Name: tblapprovallevels levelid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovallevels ALTER COLUMN levelid SET DEFAULT nextval('public.tblapprovallevels_levelid_seq'::regclass);


--
-- Name: tblapprovalrequests requestid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovalrequests ALTER COLUMN requestid SET DEFAULT nextval('public.tblapprovalrequests_requestid_seq'::regclass);


--
-- Name: tblapprovalworkflows workflowid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovalworkflows ALTER COLUMN workflowid SET DEFAULT nextval('public.tblapprovalworkflows_workflowid_seq'::regclass);


--
-- Name: tblaudi audithistid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblaudi ALTER COLUMN audithistid SET DEFAULT nextval('public.tblaudi_audithistid_seq'::regclass);


--
-- Name: tblaudi_security id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblaudi_security ALTER COLUMN id SET DEFAULT nextval('public.tblaudi_security_id_seq'::regclass);


--
-- Name: tblbankaccounts bankaccountid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbankaccounts ALTER COLUMN bankaccountid SET DEFAULT nextval('public.tblbankaccounts_bankaccountid_seq'::regclass);


--
-- Name: tblbankreconciliations reconid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbankreconciliations ALTER COLUMN reconid SET DEFAULT nextval('public.tblbankreconciliations_reconid_seq'::regclass);


--
-- Name: tblbankstatementlines stmtlineid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbankstatementlines ALTER COLUMN stmtlineid SET DEFAULT nextval('public.tblbankstatementlines_stmtlineid_seq'::regclass);


--
-- Name: tblbankstatements statementid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbankstatements ALTER COLUMN statementid SET DEFAULT nextval('public.tblbankstatements_statementid_seq'::regclass);


--
-- Name: tblbanktransactions banktxnid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbanktransactions ALTER COLUMN banktxnid SET DEFAULT nextval('public.tblbanktransactions_banktxnid_seq'::regclass);


--
-- Name: tblbudgetperiods periodid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbudgetperiods ALTER COLUMN periodid SET DEFAULT nextval('public.tblbudgetperiods_periodid_seq'::regclass);


--
-- Name: tblbudgets budgetid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbudgets ALTER COLUMN budgetid SET DEFAULT nextval('public.tblbudgets_budgetid_seq'::regclass);


--
-- Name: tblcashboxes cashboxid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashboxes ALTER COLUMN cashboxid SET DEFAULT nextval('public.tblcashboxes_cashboxid_seq'::regclass);


--
-- Name: tblcashpayments paymentid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashpayments ALTER COLUMN paymentid SET DEFAULT nextval('public.tblcashpayments_paymentid_seq'::regclass);


--
-- Name: tblcashreceipts receiptid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashreceipts ALTER COLUMN receiptid SET DEFAULT nextval('public.tblcashreceipts_receiptid_seq'::regclass);


--
-- Name: tbldocumentattachments attachmentid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldocumentattachments ALTER COLUMN attachmentid SET DEFAULT nextval('public.tbldocumentattachments_attachmentid_seq'::regclass);


--
-- Name: tblexchangeratehistory ratehistid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblexchangeratehistory ALTER COLUMN ratehistid SET DEFAULT nextval('public.tblexchangeratehistory_ratehistid_seq'::regclass);


--
-- Name: tblfiscalperiods periodid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblfiscalperiods ALTER COLUMN periodid SET DEFAULT nextval('public.tblfiscalperiods_periodid_seq'::regclass);


--
-- Name: tblfiscalyears fiscalyearid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblfiscalyears ALTER COLUMN fiscalyearid SET DEFAULT nextval('public.tblfiscalyears_fiscalyearid_seq'::regclass);


--
-- Name: tblnotifications notificationid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblnotifications ALTER COLUMN notificationid SET DEFAULT nextval('public.tblnotifications_notificationid_seq'::regclass);


--
-- Name: tblreportdefinitions reportid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblreportdefinitions ALTER COLUMN reportid SET DEFAULT nextval('public.tblreportdefinitions_reportid_seq'::regclass);


--
-- Name: tbltaxdefinitions taxid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbltaxdefinitions ALTER COLUMN taxid SET DEFAULT nextval('public.tbltaxdefinitions_taxid_seq'::regclass);


--
-- Name: tbltaxtransactions taxtransid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbltaxtransactions ALTER COLUMN taxtransid SET DEFAULT nextval('public.tbltaxtransactions_taxtransid_seq'::regclass);


--
-- Data for Name: tblaccounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblaccounts (accountcode, accountid, accountnamear, accountnameen, accounttype, parentaccountcode, accountlevel, accountnature, ismainaccount, ispostable, openingbalance, currentbalance, isactive, notes) FROM stdin;
1	1000	الأصول	Assets	ASSET	\N	1	DEBIT	f	f	0.0000	0.0000	t	\N
2	2000	الالتزامات	Liabilities	LIABILITY	\N	1	CREDIT	f	f	0.0000	0.0000	t	\N
3	3000	حقوق الملكية	Equity	EQUITY	\N	1	CREDIT	f	f	0.0000	0.0000	t	\N
4	4000	الإيرادات	Revenue	REVENUE	\N	1	CREDIT	f	f	0.0000	0.0000	t	\N
5	5000	المصروفات	Expenses	EXPENSE	\N	1	DEBIT	f	f	0.0000	0.0000	t	\N
\.


--
-- Data for Name: tblapprovalactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblapprovalactions (actionid, requestid, levelid, approverid, actiontype, actiondate, oldstatus, newstatus, fromlevel, tolevel, delegatedto, comments, ipaddress, useragent) FROM stdin;
1	1	1	2	SUBMITTED	2026-06-09 04:55:14.482503	\N	PENDING	0	1	\N	Request submitted for approval	\N	\N
2	2	1	2	SUBMITTED	2026-06-09 04:55:15.824128	\N	PENDING	0	1	\N	Request submitted for approval	\N	\N
3	1	1	1	APPROVED	2026-06-09 04:55:43.740993	PENDING	PENDING	1	1	2	LGTM	127.0.0.1	Test Browser
4	1	2	1	APPROVED	2026-06-09 04:55:44.890042	PENDING	PENDING	2	2	2	Approved CFO	127.0.0.1	Test Browser
5	1	2	1	APPROVED	2026-06-09 04:55:44.890042	PENDING	APPROVED	2	3	\N	Final approval - all levels complete	\N	\N
6	2	1	1	REJECTED	2026-06-09 04:56:32.561139	PENDING	REJECTED	1	1	\N	Insufficient documentation	127.0.0.1	Test
7	3	3	1	SUBMITTED	2026-06-09 05:15:18.782274	\N	PENDING	0	1	\N	Request submitted for approval	\N	\N
8	3	3	1	APPROVED	2026-06-09 05:15:19.701377	PENDING	PENDING	1	1	2	Approved level 1	127.0.0.1	Test
9	3	4	1	APPROVED	2026-06-09 05:15:19.814889	PENDING	PENDING	2	2	2	Approved level 2	127.0.0.1	Test
10	3	5	1	APPROVED	2026-06-09 05:15:19.927373	PENDING	PENDING	3	3	2	Approved level 3	127.0.0.1	Test
11	3	5	1	APPROVED	2026-06-09 05:15:19.927373	PENDING	APPROVED	3	4	\N	Final approval - all levels complete	\N	\N
12	4	1	1	SUBMITTED	2026-06-09 05:15:20.380251	\N	PENDING	0	1	\N	Request submitted for approval	\N	\N
\.


--
-- Data for Name: tblapprovalaudit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblapprovalaudit (auditid, requestid, actionid, eventtype, performedby, performedat, ipaddress, useragent, olddata, newdata, details) FROM stdin;
1	1	\N	APPROVED	1	2026-06-09 04:55:43.740993	127.0.0.1	Test Browser	{"level": 1, "status": "PENDING"}	{"level": 2, "status": "PENDING", "comments": "LGTM"}	\N
2	1	\N	APPROVED	1	2026-06-09 04:55:44.890042	127.0.0.1	Test Browser	{"level": 2, "status": "PENDING"}	{"level": 3, "status": "APPROVED", "comments": "Approved CFO"}	\N
3	2	\N	REJECTED	1	2026-06-09 04:56:32.561139	127.0.0.1	Test	\N	{"reason": "Insufficient documentation", "status": "REJECTED"}	\N
4	3	\N	AUTO_SUBMITTED	1	2026-06-09 05:15:18.782274	\N	\N	\N	{"amount": 5000.0000, "sourceid": 4, "sourcetype": "BOND"}	Auto-submitted by trigger on BOND insert
5	3	\N	APPROVED	1	2026-06-09 05:15:19.701377	127.0.0.1	Test	{"level": 1, "status": "PENDING"}	{"level": 2, "status": "PENDING", "comments": "Approved level 1"}	\N
6	3	\N	APPROVED	1	2026-06-09 05:15:19.814889	127.0.0.1	Test	{"level": 2, "status": "PENDING"}	{"level": 3, "status": "PENDING", "comments": "Approved level 2"}	\N
7	3	\N	APPROVED	1	2026-06-09 05:15:19.927373	127.0.0.1	Test	{"level": 3, "status": "PENDING"}	{"level": 4, "status": "APPROVED", "comments": "Approved level 3"}	\N
8	4	\N	AUTO_SUBMITTED	1	2026-06-09 05:15:20.380251	\N	\N	\N	{"amount": 5000.0000, "sourceid": 4, "sourcetype": "JOURNAL"}	Auto-submitted by trigger on JOURNAL insert
\.


--
-- Data for Name: tblapprovalconfig; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblapprovalconfig (configid, configkey, configvalue, description, adduser, adddate, edituser, editdate) FROM stdin;
1	BOND_AUTO_APPROVE_THRESHOLD	0.0000	Bond amount above which auto-submission for approval is triggered (0 = always)	\N	2026-06-09 05:12:34.138576	\N	\N
2	JOURNAL_AUTO_APPROVE_THRESHOLD	0.0000	Journal entry total debit above which auto-submission is triggered (0 = always)	\N	2026-06-09 05:12:34.138576	\N	\N
3	CASH_AUTO_APPROVE_THRESHOLD	0.0000	Cash receipt/payment above which auto-submission is triggered (0 = always)	\N	2026-06-09 05:12:34.138576	\N	\N
4	BANK_AUTO_APPROVE_THRESHOLD	0.0000	Bank transaction above which auto-submission is triggered (0 = always)	\N	2026-06-09 05:12:34.138576	\N	\N
5	BLOCK_POSTING_WITHOUT_APPROVAL	1.0000	1 = block isposted=true update if approval is required and not yet approved, 0 = allow	\N	2026-06-09 05:12:34.138576	\N	\N
6	DIMENSION_AUTO_APPROVE_THRESHOLD	0.0000	Threshold above which a transaction with dimension override is auto-submitted (0=always)	0	2026-06-09 22:43:34.021557	\N	\N
\.


--
-- Data for Name: tblapprovaldelegations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblapprovaldelegations (delegationid, fromuserid, touserid, workflowid, fromdate, todate, reason, isactive, adduser, adddate) FROM stdin;
1	1	2	\N	2026-06-09	2026-07-09	Vacation coverage	t	\N	2026-06-09 04:53:43.869763
\.


--
-- Data for Name: tblapprovallevels; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblapprovallevels (levelid, workflowid, levelnumber, levelnamear, levelnameen, requiredrole, amountmin, amountmax, ismandatory, sla_hours, isactive) FROM stdin;
1	1	1	مدير القسم	Department Manager	MANAGER	0.0000	50000.0000	t	24	t
2	1	2	المدير المالي	CFO	CFO	50000.0100	999999999999.9999	t	48	t
3	2	1	مدير المبيعات	Sales Manager	SALES_MANAGER	0.0000	10000.0000	t	24	t
4	2	2	المدير العام	General Manager	GM	10000.0100	100000.0000	t	48	t
5	2	3	المدير المالي	CFO	CFO	100000.0100	999999999999.9999	t	72	t
6	3	1	مدير المشتريات	Purchasing Manager	PURCH_MANAGER	0.0000	100000.0000	t	48	t
7	3	2	المدير المالي	CFO	CFO	100000.0100	999999999999.9999	t	72	t
8	4	1	أمين الصندوق	Cashier	CASHIER	0.0100	10000.0000	t	12	t
9	4	2	المدير المالي	CFO	CFO	10000.0100	999999999999.9999	t	24	t
10	5	1	أمين الصندوق	Cashier	CASHIER	0.0100	5000.0000	t	12	t
11	5	2	المدير المالي	CFO	CFO	5000.0100	999999999999.9999	t	24	t
12	6	1	مدير البنك	Bank Manager	BANK_MANAGER	0.0100	50000.0000	t	24	t
13	6	2	المدير المالي	CFO	CFO	50000.0100	999999999999.9999	t	48	t
14	8	1	المستوى الأول - المدير المالي	Level 1 - Finance Manager	FINANCE_MANAGER	0.0000	999999999.0000	t	48	t
15	8	2	المستوى الثاني - المدير التنفيذي	Level 2 - CFO	CFO	0.0000	999999999.0000	t	48	t
\.


--
-- Data for Name: tblapprovalrequests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblapprovalrequests (requestid, requestno, workflowid, sourcetype, sourceid, requesterid, totalsum, currencycode, exchangerate, description, status, currentlevel, totallevels, priority, duedate, completedate, completedby, adddate) FROM stdin;
1	AR-20260609-2-1	1	JOURNAL	1	2	25000.0000	1	1.00000000	Test journal entry approval	APPROVED	3	2	NORMAL	2026-06-11 04:55:14.482503	2026-06-09 04:55:44.890042	1	2026-06-09 04:55:14.482503
2	AR-20260609-2-2	1	JOURNAL	1	2	25000.0000	1	1.00000000	Test journal entry approval	REJECTED	1	2	NORMAL	2026-06-11 04:55:15.824128	2026-06-09 04:56:32.561139	1	2026-06-09 04:55:15.824128
3	AR-20260609-1-1	2	BOND	4	1	5000.0000	\N	1.00000000	Auto-submitted on BOND creation	APPROVED	4	3	NORMAL	2026-06-11 05:15:18.782274	2026-06-09 05:15:19.927373	1	2026-06-09 05:15:18.782274
4	AR-20260609-1-2	1	JOURNAL	4	1	5000.0000	\N	1.00000000	Auto-submitted on JOURNAL creation	PENDING	1	2	NORMAL	2026-06-11 05:15:20.380251	\N	\N	2026-06-09 05:15:20.380251
\.


--
-- Data for Name: tblapprovalworkflows; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblapprovalworkflows (workflowid, workflowcode, workflownamear, workflownameen, sourcetype, description, isactive, adduser, adddate, edituser, editdate) FROM stdin;
1	JOURNAL_STD	Journal Entry Standard Approval	Journal Entry Standard Approval	JOURNAL	Standard approval workflow for accounting journal entries	t	\N	2026-06-09 04:53:43.858659	\N	\N
2	BOND_SALES	Sales Bond Approval	Sales Bond Approval	BOND	Approval workflow for sales bonds (invoices)	t	\N	2026-06-09 04:53:43.858659	\N	\N
3	BOND_PURCHASE	Purchase Bond Approval	Purchase Bond Approval	BOND	Approval workflow for purchase bonds (bills)	t	\N	2026-06-09 04:53:43.858659	\N	\N
4	CASH_RECEIPT_STD	Cash Receipt Approval	Cash Receipt Approval	CASH_RECEIPT	Approval workflow for cash receipts over threshold	t	\N	2026-06-09 05:12:34.09431	\N	\N
5	CASH_PAYMENT_STD	Cash Payment Approval	Cash Payment Approval	CASH_PAYMENT	Approval workflow for cash payments over threshold	t	\N	2026-06-09 05:12:34.09431	\N	\N
6	BANK_TXN_STD	Bank Transaction Approval	Bank Transaction Approval	BANK_TXN	Approval workflow for bank transactions over threshold	t	\N	2026-06-09 05:12:34.09431	\N	\N
8	DIMENSION_MASTER_CHANGE	تغيير بيانات الأبعاد الرئيسية	Dimension Master Change	OTHER	Approval required for adding/editing critical dimension master codes (Departments/Projects/BUs/PCs)	t	0	2026-06-09 22:47:03.97218	\N	\N
\.


--
-- Data for Name: tblaudi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblaudi (audithistid, tablename, recordid, action, olddata, newdata, changedfields, userid, username, actiondate, clientip, sessionid) FROM stdin;
\.


--
-- Data for Name: tblaudi_security; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblaudi_security (id, event_type, event_payload, actor_role, occurred_at) FROM stdin;
\.


--
-- Data for Name: tblauditlogs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblauditlogs (auditid, usercode, userid, eventtype, eventcategory, eventdescription, tablename, recordid, oldvalues, newvalues, sqlcommand, machinename, ipaddress, actionname, entityname, entitykey, success, errormessage, modulename, windowid, oldvalue, newvalue, eventdate) FROM stdin;
1	1	ADMIN	TEST_EVENT	TestModule	TestAction TestEntity key1	TestEntity	0	\N	\N	\N	PC-01	\N	TestAction	TestEntity	key1	t		TestModule	1	old	new	2026-06-08 18:45:57.530009
2	1	ADMIN	TEST_EVENT	TestModule	TestAction TestEntity key1	TestEntity	0	\N	\N	\N	PC-01	\N	TestAction	TestEntity	key1	t		TestModule	1	old	new	2026-06-08 18:46:12.782408
3	1	ADMIN	TEST_EVENT	TestModule	TestAction TestEntity key1	TestEntity	0	\N	\N	\N	PC-01	\N	TestAction	TestEntity	key1	t		TestModule	1	old	new	2026-06-08 19:14:53.148227
\.


--
-- Data for Name: tblbankaccounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblbankaccounts (bankaccountid, bankaccountno, bankid, branchname, currid, iban, swiftcode, openingbalance, currentbalance, isactive, adduser, adddate, edituser, editdate) FROM stdin;
\.


--
-- Data for Name: tblbankreconciliations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblbankreconciliations (reconid, bankaccountid, periodfrom, periodto, openingbalance, closingbalance, systembalance, difference, status, notes, adduser, adddate) FROM stdin;
\.


--
-- Data for Name: tblbanks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblbanks (bankcode, bankid, banknamear, banknameen, accountnumber, iban, swiftcode, branchname, currencycode, openingbalance, currentbalance, isactive, notes) FROM stdin;
\.


--
-- Data for Name: tblbankstatementlines; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblbankstatementlines (stmtlineid, statementid, txndate, description, debitamount, creditamount, refno, ismatched, matchedtxnid) FROM stdin;
\.


--
-- Data for Name: tblbankstatements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblbankstatements (statementid, bankaccountid, statementdate, statementno, openingbalance, closingbalance, totaldebit, totalcredit, importeddate, isreconcilied, adduser) FROM stdin;
\.


--
-- Data for Name: tblbanktransactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblbanktransactions (banktxnid, txndate, bankaccountid, txnttyp, amount, currid, exgrate, counteraccountid, description, refno, status, adduser, adddate, approvalrequestid, departmentcode, projectcode, businessunitcode, segmentcode, profitcentercode) FROM stdin;
\.


--
-- Data for Name: tblbondbody; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblbondbody (bonddetailid, bondcode, linenumber, accountcode, costcentercode, description, debit, credit) FROM stdin;
1	1	1	1	\N		5000.0000	0.0000
2	1	2	1	\N		5000.0000	0.0000
3	1	3	1	\N		5000.0000	0.0000
\.


--
-- Data for Name: tblbondheader; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblbondheader (bondcode, bondid, bondtype, bonddate, fiscalyear, fiscalperiod, amount, currencycode, exchangerate, paymentmethodcode, bankcode, fundcode, customercode, suppliercode, accountcode, description, referenceno, isposted, postedat, postedby, createdby, createdat, notes, approvalrequestid, departmentcode, projectcode, businessunitcode, segmentcode, profitcentercode) FROM stdin;
1	B-1	RECEIPT	2026-06-08	2026	6	5000.0000	\N	1.00000000	\N	\N	1	\N	\N	\N	سند قبض	\N	t	\N	\N	1	2026-06-08 18:45:57.524699	\N	\N	\N	\N	\N	\N	\N
4	BND-INT-1	SALE	2026-06-09	2026	6	5000.0000	1	1.00000000	\N	\N	\N	1	\N	\N	Integration test bond	\N	t	\N	1	1	2026-06-09 05:15:18.782274	\N	3	\N	\N	\N	\N	\N
\.


--
-- Data for Name: tblbranches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblbranches (branchcode, branchid, branchnamear, branchnameen, address, city, country, phone, email, managername, ismainbranch, isactive, openedat, notes) FROM stdin;
1	MAIN	الفرع الرئيسي	Main Branch	\N	\N	SA	\N	\N	\N	t	t	\N	\N
3	JD4	فرع جدة	\N	جدة، السعودية	\N	SA	0551234567	jeddah@x.com	\N	f	t	\N	\N
5	JD6	فرع جدة	\N	جدة، السعودية	\N	SA	0551234567	jeddah@x.com	\N	f	t	\N	\N
\.


--
-- Data for Name: tblbudgetperiods; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblbudgetperiods (periodid, periodname, periodfrom, periodto, isactive, notes, adduser, adddate) FROM stdin;
\.


--
-- Data for Name: tblbudgets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblbudgets (budgetid, periodid, accountid, branchid, costcenterid, budgetamount, actualamount, notes, adduser, adddate, departmentcode, projectcode, businessunitcode, segmentcode, profitcentercode) FROM stdin;
\.


--
-- Data for Name: tblcashboxes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblcashboxes (cashboxid, cashboxcode, cashboxname, branchid, currid, openingbalance, currentbalance, isactive, notes, adduser, adddate, edituser, editdate) FROM stdin;
\.


--
-- Data for Name: tblcashpayments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblcashpayments (paymentid, paymentno, paymentdate, cashboxid, supplierid, customerid, amount, currid, exgrate, paymentmethodid, description, status, adduser, adddate, edituser, editdate, approvalrequestid, departmentcode, projectcode, businessunitcode, segmentcode, profitcentercode) FROM stdin;
\.


--
-- Data for Name: tblcashreceipts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblcashreceipts (receiptid, receiptno, receiptdate, cashboxid, customerid, supplierid, amount, currid, exgrate, paymentmethodid, description, status, adduser, adddate, edituser, editdate, approvalrequestid, departmentcode, projectcode, businessunitcode, segmentcode, profitcentercode) FROM stdin;
\.


--
-- Data for Name: tblcategories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblcategories (categorycode, categoryid, categorynamear, categorynameen, parentcategorycode, isactive, notes) FROM stdin;
1	2	إلكترونيات	\N	\N	t	\N
3	4	إلكترونيات	\N	\N	t	\N
5	6	إلكترونيات	\N	\N	t	\N
\.


--
-- Data for Name: tblcompanies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblcompanies (companycode, companynamear, companynameen, taxnumber, vatnumber, address, city, country, phone, email, website, logo, currencycode, fiscalyearstart, isactive, notes) FROM stdin;
\.


--
-- Data for Name: tblcostcenters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblcostcenters (costcentercode, costcenterid, costcenternamear, costcenternameen, parentcostcentercode, isactive, notes) FROM stdin;
\.


--
-- Data for Name: tblcurrencies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblcurrencies (currencycode, currencyid, currencynamear, currencynameen, symbol, exchangerate, isbasecurrency, isactive, lastupdatedat) FROM stdin;
1	SAR	ريال سعودي	Saudi Riyal	SAR	1.00000000	t	t	2026-06-08 18:45:44.491812
3	4	درهم إماراتي	\N	AED	1.02000000	f	t	2026-06-08 18:46:12.757842
5	6	درهم إماراتي	\N	AED	1.02000000	f	t	2026-06-08 19:14:53.133058
\.


--
-- Data for Name: tblcustomercontacts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblcustomercontacts (contactid, customercode, contactname, jobtitle, phone, mobile, email, isprimary) FROM stdin;
\.


--
-- Data for Name: tblcustomers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblcustomers (customercode, customerid, customernamear, customernameen, customertype, taxnumber, vatnumber, address, city, country, phone, mobile, email, branchcode, pricelistcode, paymenttermcode, creditlimit, currentcredit, paymentdays, balance, totalsales, lastsaledate, customersince, isactive, isblocked, notes) FROM stdin;
1	CUST1002	محمد علي	\N	INDIVIDUAL	\N	\N	\N	\N	SA	\N	0501111111	m@x.com	1	\N	\N	5000.0000	0.0000	0	0.0000	0.0000	\N	\N	t	f	\N
3	CUST1004	محمد علي	\N	INDIVIDUAL	\N	\N	\N	\N	SA	\N	0501111111	m@x.com	1	\N	\N	5000.0000	0.0000	0	0.0000	0.0000	\N	\N	t	f	\N
5	CUST1006	محمد علي	\N	INDIVIDUAL	\N	\N	\N	\N	SA	\N	0501111111	m@x.com	1	\N	\N	5000.0000	0.0000	0	0.0000	0.0000	\N	\N	t	f	\N
\.


--
-- Data for Name: tbldim_businessunits; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbldim_businessunits (businessunitcode, businessunitid, namear, nameen, parentbusinessunitcode, isactive, notes, adduser, adddate, edituser, editdate) FROM stdin;
1	BU-TEST-00144347	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-09 23:20:50.0158	\N	2026-06-09 23:20:50.024153
18	BU-TEST-41460439	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 00:30:54.146418	\N	2026-06-11 00:30:54.148328
2	BU-TEST-05833960	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-09 23:23:30.584416	\N	2026-06-09 23:23:30.590081
3	BU-TEST-28276654	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 00:32:02.828011	\N	2026-06-10 00:32:02.830157
4	BU-TEST-64123819	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 03:45:56.413636	\N	2026-06-10 03:45:56.419034
19	BU-TEST-70729266	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 00:33:37.07374	\N	2026-06-11 00:33:37.07685
5	BU-TEST-31665312	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 06:01:43.168505	\N	2026-06-10 06:01:43.179477
6	BU-TEST-66594172	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 06:14:06.660281	\N	2026-06-10 06:14:06.66412
29	BU-TEST-19632170	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 01:18:11.96362	\N	2026-06-11 01:18:11.965623
7	BU-TEST-44730135	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 06:16:34.473898	\N	2026-06-10 06:16:34.479055
20	BU-TEST-79549486	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 00:36:57.955498	\N	2026-06-11 00:36:57.958613
8	BU-TEST-37840997	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 06:18:43.786528	\N	2026-06-10 06:18:43.79899
9	BU-TEST-47551892	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 06:26:24.756094	\N	2026-06-10 06:26:24.761756
10	BU-TEST-97156639	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 06:28:49.717462	\N	2026-06-10 06:28:49.726884
21	BU-TEST-49607923	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 00:40:04.961156	\N	2026-06-11 00:40:04.963634
11	BU-TEST-10543994	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 06:36:11.055296	\N	2026-06-10 06:36:11.062311
12	BU-TEST-57610315	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 06:41:45.761928	\N	2026-06-10 06:41:45.766387
42	BU-TEST-28629383	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 02:35:22.864176	\N	2026-06-11 02:35:22.867965
13	BU-TEST-48052526	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 06:57:34.80698	\N	2026-06-10 06:57:34.814788
22	BU-TEST-40063287	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 00:41:34.006695	\N	2026-06-11 00:41:34.008885
14	BU-TEST-29766433	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 07:18:42.977887	\N	2026-06-10 07:18:42.987425
15	BU-TEST-86446703	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 07:22:38.645645	\N	2026-06-10 07:22:38.651005
30	BU-TEST-88052653	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 01:22:08.805733	\N	2026-06-11 01:22:08.808179
16	BU-TEST-51670317	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 08:36:35.167766	\N	2026-06-10 08:36:35.171899
23	BU-TEST-33694893	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 00:50:43.369809	\N	2026-06-11 00:50:43.371715
17	BU-TEST-62105055	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 00:30:36.212874	\N	2026-06-11 00:30:36.224996
24	BU-TEST-29458840	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 00:52:52.946191	\N	2026-06-11 00:52:52.948143
36	BU-TEST-53277376	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 02:12:55.328134	\N	2026-06-11 02:12:55.330229
25	BU-TEST-61794000	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 01:11:46.179849	\N	2026-06-11 01:11:46.182325
31	BU-TEST-13592324	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 01:33:11.35969	\N	2026-06-11 01:33:11.362501
26	BU-TEST-70234905	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 01:11:47.023847	\N	2026-06-11 01:11:47.025842
27	BU-TEST-14869291	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 01:12:21.487349	\N	2026-06-11 01:12:21.489595
28	BU-TEST-91446288	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 01:15:29.144957	\N	2026-06-11 01:15:29.146894
32	BU-TEST-05057133	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 01:37:20.506102	\N	2026-06-11 01:37:20.508406
40	BU-TEST-81668421	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 02:28:48.167168	\N	2026-06-11 02:28:48.169114
33	BU-TEST-68726972	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 01:48:46.87334	\N	2026-06-11 01:48:46.876093
37	BU-TEST-28658826	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 02:13:02.866268	\N	2026-06-11 02:13:02.868249
34	BU-TEST-98845667	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 01:49:39.884951	\N	2026-06-11 01:49:39.887175
35	BU-TEST-55041409	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 01:56:05.504542	\N	2026-06-11 01:56:05.507083
38	BU-TEST-58969875	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 02:13:35.897332	\N	2026-06-11 02:13:35.899766
39	BU-TEST-23698788	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 02:27:52.370334	\N	2026-06-11 02:27:52.372604
41	BU-TEST-32348128	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 02:34:23.235327	\N	2026-06-11 02:34:23.240573
44	BU-TEST-25862874	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 02:49:42.586643	\N	2026-06-11 02:49:42.58868
43	BU-TEST-06059986	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 02:48:40.606612	\N	2026-06-11 02:48:40.610944
45	BU-TEST-33376263	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 03:09:03.338797	\N	2026-06-11 03:09:03.343485
46	BU-TEST-37806065	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 03:09:13.781046	\N	2026-06-11 03:09:13.783685
47	BU-TEST-14713336	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 04:03:31.471746	\N	2026-06-11 04:03:31.474289
48	BU-TEST-52878927	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 04:03:35.28835	\N	2026-06-11 04:03:35.290862
49	BU-TEST-76801484	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 05:13:07.680528	\N	2026-06-11 05:13:07.682731
50	BU-TEST-35792943	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 05:28:23.582803	\N	2026-06-11 05:28:23.602007
51	BU-TEST-43055847	وحدة اختبار (معدّل)	Test BU (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 05:28:44.306396	\N	2026-06-11 05:28:44.313854
\.


--
-- Data for Name: tbldim_departments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbldim_departments (departmentcode, departmentid, namear, nameen, parentdepartmentcode, managerusercode, isactive, effectivedate, enddate, notes, adduser, adddate, edituser, editdate) FROM stdin;
1	D-TEST-99749517	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-09	\N	Phase 4 test updated	\N	2026-06-09 23:20:49.98093	\N	2026-06-09 23:20:50.000148
18	D-TEST-41285078	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 00:30:54.131272	\N	2026-06-11 00:30:54.139858
2	D-TEST-05527756	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-09	\N	Phase 4 test updated	\N	2026-06-09 23:23:30.558744	\N	2026-06-09 23:23:30.572545
3	D-TEST-28147184	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-10	\N	Phase 4 test updated	\N	2026-06-10 00:32:02.816693	\N	2026-06-10 00:32:02.822683
4	D-TEST-63865205	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-10	\N	Phase 4 test updated	\N	2026-06-10 03:45:56.390225	\N	2026-06-10 03:45:56.401731
19	D-TEST-70548373	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 00:33:37.057228	\N	2026-06-11 00:33:37.066853
5	D-TEST-30986949	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-10	\N	Phase 4 test updated	\N	2026-06-10 06:01:43.109285	\N	2026-06-10 06:01:43.146325
6	D-TEST-66338625	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-10	\N	Phase 4 test updated	\N	2026-06-10 06:14:06.637717	\N	2026-06-10 06:14:06.649553
29	D-TEST-19501852	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 01:18:11.952498	\N	2026-06-11 01:18:11.958928
7	D-TEST-44478489	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-10	\N	Phase 4 test updated	\N	2026-06-10 06:16:34.451521	\N	2026-06-10 06:16:34.463964
20	D-TEST-79408133	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 00:36:57.943608	\N	2026-06-11 00:36:57.949828
8	D-TEST-37119364	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-10	\N	Phase 4 test updated	\N	2026-06-10 06:18:43.718952	\N	2026-06-10 06:18:43.755766
9	D-TEST-47277934	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-10	\N	Phase 4 test updated	\N	2026-06-10 06:26:24.731915	\N	2026-06-10 06:26:24.744151
10	D-TEST-96713826	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-10	\N	Phase 4 test updated	\N	2026-06-10 06:28:49.677937	\N	2026-06-10 06:28:49.697878
21	D-TEST-49464475	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 00:40:04.949355	\N	2026-06-11 00:40:04.956057
11	D-TEST-10305533	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-10	\N	Phase 4 test updated	\N	2026-06-10 06:36:11.034412	\N	2026-06-10 06:36:11.044689
12	D-TEST-57320350	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-10	\N	Phase 4 test updated	\N	2026-06-10 06:41:45.736184	\N	2026-06-10 06:41:45.748581
42	D-TEST-28467183	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 02:35:22.849935	\N	2026-06-11 02:35:22.857084
13	D-TEST-47518757	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-10	\N	Phase 4 test updated	\N	2026-06-10 06:57:34.762778	\N	2026-06-10 06:57:34.785039
22	D-TEST-39892432	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 00:41:33.991276	\N	2026-06-11 00:41:33.999563
14	D-TEST-29403097	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-10	\N	Phase 4 test updated	\N	2026-06-10 07:18:42.944745	\N	2026-06-10 07:18:42.95909
15	D-TEST-86142760	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-10	\N	Phase 4 test updated	\N	2026-06-10 07:22:38.619086	\N	2026-06-10 07:22:38.632542
30	D-TEST-87915533	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 01:22:08.793636	\N	2026-06-11 01:22:08.799914
16	D-TEST-51413743	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-10	\N	Phase 4 test updated	\N	2026-06-10 08:36:35.144445	\N	2026-06-10 08:36:35.158008
23	D-TEST-33543875	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 00:50:43.356391	\N	2026-06-11 00:50:43.365001
17	D-TEST-61255802	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 00:30:36.143417	\N	2026-06-11 00:30:36.181642
24	D-TEST-29317010	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 00:52:52.933684	\N	2026-06-11 00:52:52.940845
36	D-TEST-53129524	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 02:12:55.315088	\N	2026-06-11 02:12:55.321543
25	D-TEST-61679402	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 01:11:46.169977	\N	2026-06-11 01:11:46.17506
31	D-TEST-13446829	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 01:33:11.346926	\N	2026-06-11 01:33:11.354103
26	D-TEST-70094896	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 01:11:47.011465	\N	2026-06-11 01:11:47.019156
27	D-TEST-14707700	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 01:12:21.472956	\N	2026-06-11 01:12:21.481212
28	D-TEST-91311276	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 01:15:29.133188	\N	2026-06-11 01:15:29.139042
32	D-TEST-04907439	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 01:37:20.492981	\N	2026-06-11 01:37:20.499989
40	D-TEST-81531148	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 02:28:48.155046	\N	2026-06-11 02:28:48.162182
33	D-TEST-68562908	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 01:48:46.858845	\N	2026-06-11 01:48:46.866878
37	D-TEST-28530914	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 02:13:02.856142	\N	2026-06-11 02:13:02.861331
34	D-TEST-98674176	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 01:49:39.869508	\N	2026-06-11 01:49:39.878477
35	D-TEST-54894432	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 01:56:05.491685	\N	2026-06-11 01:56:05.497898
38	D-TEST-58829231	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 02:13:35.884942	\N	2026-06-11 02:13:35.892354
39	D-TEST-23526436	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 02:27:52.354822	\N	2026-06-11 02:27:52.364044
41	D-TEST-32144997	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 02:34:23.218241	\N	2026-06-11 02:34:23.227581
44	D-TEST-25700906	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 02:49:42.572384	\N	2026-06-11 02:49:42.578649
43	D-TEST-05655285	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 02:48:40.571882	\N	2026-06-11 02:48:40.585907
45	D-TEST-32939324	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 03:09:03.302611	\N	2026-06-11 03:09:03.32544
46	D-TEST-37553858	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 03:09:13.759215	\N	2026-06-11 03:09:13.771973
47	D-TEST-14542510	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 04:03:31.456711	\N	2026-06-11 04:03:31.4638
48	D-TEST-52674492	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 04:03:35.270847	\N	2026-06-11 04:03:35.279298
49	D-TEST-76633403	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 05:13:07.665408	\N	2026-06-11 05:13:07.673868
50	D-TEST-34808017	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 05:28:23.501068	\N	2026-06-11 05:28:23.541416
51	D-TEST-42744093	قسم اختبار (معدّل)	Test Dept (modified)	\N	\N	f	2026-06-11	\N	Phase 4 test updated	\N	2026-06-11 05:28:44.279855	\N	2026-06-11 05:28:44.295997
\.


--
-- Data for Name: tbldim_hierarchies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbldim_hierarchies (hierarchyid, hierarchytype, parentdimtype, parentdimcode, childdimtype, childdimcode, validfrom, validto, isactive, notes, adduser, adddate, edituser, editdate) FROM stdin;
1	PROJECT_TO_DEPARTMENT	DEPARTMENT	1	PROJECT	1	2026-06-09	\N	t	Phase 4 test hierarchy	\N	2026-06-09 23:20:50.044875	\N	\N
2	PROJECT_TO_DEPARTMENT	DEPARTMENT	2	PROJECT	2	2026-06-09	\N	t	Phase 4 test hierarchy	\N	2026-06-09 23:23:30.604575	\N	\N
3	PROJECT_TO_DEPARTMENT	DEPARTMENT	3	PROJECT	3	2026-06-10	\N	t	Phase 4 test hierarchy	\N	2026-06-10 00:32:02.835931	\N	\N
4	PROJECT_TO_DEPARTMENT	DEPARTMENT	4	PROJECT	4	2026-06-10	\N	t	Phase 4 test hierarchy	\N	2026-06-10 03:45:56.435633	\N	\N
5	PROJECT_TO_DEPARTMENT	DEPARTMENT	5	PROJECT	5	2026-06-10	\N	t	Phase 4 test hierarchy	\N	2026-06-10 06:01:43.208984	\N	\N
6	PROJECT_TO_DEPARTMENT	DEPARTMENT	6	PROJECT	6	2026-06-10	\N	t	Phase 4 test hierarchy	\N	2026-06-10 06:14:06.676817	\N	\N
7	PROJECT_TO_DEPARTMENT	DEPARTMENT	7	PROJECT	7	2026-06-10	\N	t	Phase 4 test hierarchy	\N	2026-06-10 06:16:34.492662	\N	\N
8	PROJECT_TO_DEPARTMENT	DEPARTMENT	8	PROJECT	8	2026-06-10	\N	t	Phase 4 test hierarchy	\N	2026-06-10 06:18:43.820885	\N	\N
9	PROJECT_TO_DEPARTMENT	DEPARTMENT	9	PROJECT	9	2026-06-10	\N	t	Phase 4 test hierarchy	\N	2026-06-10 06:26:24.778617	\N	\N
10	PROJECT_TO_DEPARTMENT	DEPARTMENT	10	PROJECT	10	2026-06-10	\N	t	Phase 4 test hierarchy	\N	2026-06-10 06:28:49.750307	\N	\N
11	PROJECT_TO_DEPARTMENT	DEPARTMENT	11	PROJECT	11	2026-06-10	\N	t	Phase 4 test hierarchy	\N	2026-06-10 06:36:11.077364	\N	\N
12	PROJECT_TO_DEPARTMENT	DEPARTMENT	12	PROJECT	12	2026-06-10	\N	t	Phase 4 test hierarchy	\N	2026-06-10 06:41:45.780403	\N	\N
13	PROJECT_TO_DEPARTMENT	DEPARTMENT	13	PROJECT	13	2026-06-10	\N	t	Phase 4 test hierarchy	\N	2026-06-10 06:57:34.841078	\N	\N
14	PROJECT_TO_DEPARTMENT	DEPARTMENT	14	PROJECT	14	2026-06-10	\N	t	Phase 4 test hierarchy	\N	2026-06-10 07:18:43.013889	\N	\N
15	PROJECT_TO_DEPARTMENT	DEPARTMENT	15	PROJECT	15	2026-06-10	\N	t	Phase 4 test hierarchy	\N	2026-06-10 07:22:38.667075	\N	\N
16	PROJECT_TO_DEPARTMENT	DEPARTMENT	16	PROJECT	16	2026-06-10	\N	t	Phase 4 test hierarchy	\N	2026-06-10 08:36:35.183194	\N	\N
17	PROJECT_TO_DEPARTMENT	DEPARTMENT	17	PROJECT	17	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 00:30:36.264229	\N	\N
18	PROJECT_TO_DEPARTMENT	DEPARTMENT	18	PROJECT	18	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 00:30:54.156232	\N	\N
19	PROJECT_TO_DEPARTMENT	DEPARTMENT	19	PROJECT	19	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 00:33:37.086401	\N	\N
20	PROJECT_TO_DEPARTMENT	DEPARTMENT	20	PROJECT	20	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 00:36:57.96474	\N	\N
21	PROJECT_TO_DEPARTMENT	DEPARTMENT	21	PROJECT	21	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 00:40:04.971499	\N	\N
22	PROJECT_TO_DEPARTMENT	DEPARTMENT	22	PROJECT	22	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 00:41:34.016577	\N	\N
23	PROJECT_TO_DEPARTMENT	DEPARTMENT	23	PROJECT	23	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 00:50:43.377679	\N	\N
24	PROJECT_TO_DEPARTMENT	DEPARTMENT	24	PROJECT	24	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 00:52:52.953741	\N	\N
25	PROJECT_TO_DEPARTMENT	DEPARTMENT	25	PROJECT	25	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 01:11:46.188157	\N	\N
26	PROJECT_TO_DEPARTMENT	DEPARTMENT	26	PROJECT	26	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 01:11:47.031962	\N	\N
27	PROJECT_TO_DEPARTMENT	DEPARTMENT	27	PROJECT	27	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 01:12:21.496166	\N	\N
28	PROJECT_TO_DEPARTMENT	DEPARTMENT	28	PROJECT	28	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 01:15:29.152761	\N	\N
29	PROJECT_TO_DEPARTMENT	DEPARTMENT	29	PROJECT	29	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 01:18:11.971903	\N	\N
30	PROJECT_TO_DEPARTMENT	DEPARTMENT	30	PROJECT	30	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 01:22:08.814419	\N	\N
31	PROJECT_TO_DEPARTMENT	DEPARTMENT	31	PROJECT	31	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 01:33:11.368487	\N	\N
32	PROJECT_TO_DEPARTMENT	DEPARTMENT	32	PROJECT	32	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 01:37:20.514416	\N	\N
33	PROJECT_TO_DEPARTMENT	DEPARTMENT	33	PROJECT	33	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 01:48:46.885691	\N	\N
34	PROJECT_TO_DEPARTMENT	DEPARTMENT	34	PROJECT	34	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 01:49:39.894815	\N	\N
35	PROJECT_TO_DEPARTMENT	DEPARTMENT	35	PROJECT	35	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 01:56:05.513165	\N	\N
36	PROJECT_TO_DEPARTMENT	DEPARTMENT	36	PROJECT	36	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 02:12:55.336522	\N	\N
37	PROJECT_TO_DEPARTMENT	DEPARTMENT	37	PROJECT	37	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 02:13:02.875571	\N	\N
38	PROJECT_TO_DEPARTMENT	DEPARTMENT	38	PROJECT	38	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 02:13:35.908344	\N	\N
39	PROJECT_TO_DEPARTMENT	DEPARTMENT	39	PROJECT	39	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 02:27:52.380685	\N	\N
40	PROJECT_TO_DEPARTMENT	DEPARTMENT	40	PROJECT	40	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 02:28:48.177092	\N	\N
41	PROJECT_TO_DEPARTMENT	DEPARTMENT	41	PROJECT	41	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 02:34:23.251033	\N	\N
42	PROJECT_TO_DEPARTMENT	DEPARTMENT	42	PROJECT	42	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 02:35:22.874195	\N	\N
43	PROJECT_TO_DEPARTMENT	DEPARTMENT	43	PROJECT	43	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 02:48:40.628871	\N	\N
44	PROJECT_TO_DEPARTMENT	DEPARTMENT	44	PROJECT	44	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 02:49:42.595203	\N	\N
45	PROJECT_TO_DEPARTMENT	DEPARTMENT	45	PROJECT	45	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 03:09:03.364943	\N	\N
46	PROJECT_TO_DEPARTMENT	DEPARTMENT	46	PROJECT	46	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 03:09:13.790134	\N	\N
47	PROJECT_TO_DEPARTMENT	DEPARTMENT	47	PROJECT	47	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 04:03:31.483704	\N	\N
48	PROJECT_TO_DEPARTMENT	DEPARTMENT	48	PROJECT	48	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 04:03:35.301282	\N	\N
49	PROJECT_TO_DEPARTMENT	DEPARTMENT	49	PROJECT	49	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 05:13:07.690447	\N	\N
50	PROJECT_TO_DEPARTMENT	DEPARTMENT	50	PROJECT	50	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 05:28:23.659699	\N	\N
51	PROJECT_TO_DEPARTMENT	DEPARTMENT	51	PROJECT	51	2026-06-11	\N	t	Phase 4 test hierarchy	\N	2026-06-11 05:28:44.330329	\N	\N
\.


--
-- Data for Name: tbldim_profitcenters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbldim_profitcenters (profitcentercode, profitcenterid, namear, nameen, parentprofitcentercode, isactive, notes, adduser, adddate, edituser, editdate) FROM stdin;
1	PC-TEST-00343071	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-09 23:20:50.035211	\N	2026-06-09 23:20:50.042988
18	PC-TEST-41526600	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 00:30:54.153272	\N	2026-06-11 00:30:54.155549
2	PC-TEST-05965126	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-09 23:23:30.597391	\N	2026-06-09 23:23:30.602896
3	PC-TEST-28329690	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 00:32:02.833307	\N	2026-06-10 00:32:02.835298
4	PC-TEST-64278033	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 03:45:56.428914	\N	2026-06-10 03:45:56.43405
19	PC-TEST-70827696	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 00:33:37.083276	\N	2026-06-11 00:33:37.085677
5	PC-TEST-31946013	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 06:01:43.196743	\N	2026-06-10 06:01:43.206097
6	PC-TEST-66696915	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 06:14:06.670369	\N	2026-06-10 06:14:06.675321
29	PC-TEST-19688166	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 01:18:11.969266	\N	2026-06-11 01:18:11.97131
7	PC-TEST-44849729	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 06:16:34.485747	\N	2026-06-10 06:16:34.490742
20	PC-TEST-79616117	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 00:36:57.96193	\N	2026-06-11 00:36:57.964044
8	PC-TEST-38099420	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 06:18:43.811586	\N	2026-06-10 06:18:43.817795
9	PC-TEST-47691408	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 06:26:24.770261	\N	2026-06-10 06:26:24.776071
10	PC-TEST-97391750	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 06:28:49.740578	\N	2026-06-10 06:28:49.747492
21	PC-TEST-49680397	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 00:40:04.968438	\N	2026-06-11 00:40:04.970844
11	PC-TEST-10691962	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 06:36:11.070177	\N	2026-06-10 06:36:11.075481
12	PC-TEST-57730358	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 06:41:45.774224	\N	2026-06-10 06:41:45.778938
42	PC-TEST-28712639	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 02:35:22.871576	\N	2026-06-11 02:35:22.87352
13	PC-TEST-48276086	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 06:57:34.829162	\N	2026-06-10 06:57:34.837425
22	PC-TEST-40125780	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 00:41:34.013226	\N	2026-06-11 00:41:34.015873
14	PC-TEST-30003462	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 07:18:43.002189	\N	2026-06-10 07:18:43.011128
15	PC-TEST-86590180	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 07:22:38.66024	\N	2026-06-10 07:22:38.665628
30	PC-TEST-88113808	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 01:22:08.811728	\N	2026-06-11 01:22:08.813791
16	PC-TEST-51764601	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-10 08:36:35.17691	\N	2026-06-10 08:36:35.181855
23	PC-TEST-33744274	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 00:50:43.374728	\N	2026-06-11 00:50:43.376783
17	PC-TEST-62451515	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 00:30:36.247703	\N	2026-06-11 00:30:36.260715
24	PC-TEST-29509988	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 00:52:52.951313	\N	2026-06-11 00:52:52.953146
36	PC-TEST-53334725	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 02:12:55.333822	\N	2026-06-11 02:12:55.335839
25	PC-TEST-61853000	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 01:11:46.185647	\N	2026-06-11 01:11:46.187554
31	PC-TEST-13656078	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 01:33:11.365943	\N	2026-06-11 01:33:11.367892
26	PC-TEST-70284861	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 01:11:47.028819	\N	2026-06-11 01:11:47.031158
27	PC-TEST-14930893	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 01:12:21.493456	\N	2026-06-11 01:12:21.495396
28	PC-TEST-91499630	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 01:15:29.150321	\N	2026-06-11 01:15:29.152159
32	PC-TEST-05114974	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 01:37:20.511861	\N	2026-06-11 01:37:20.513733
40	PC-TEST-81718265	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 02:28:48.17212	\N	2026-06-11 02:28:48.176094
33	PC-TEST-68808484	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 01:48:46.881436	\N	2026-06-11 01:48:46.884861
37	PC-TEST-28721073	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 02:13:02.87266	\N	2026-06-11 02:13:02.874834
34	PC-TEST-98905071	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 01:49:39.890952	\N	2026-06-11 01:49:39.893486
35	PC-TEST-55101290	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 01:56:05.510516	\N	2026-06-11 01:56:05.512464
38	PC-TEST-59034813	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 02:13:35.904307	\N	2026-06-11 02:13:35.90756
39	PC-TEST-23757809	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 02:27:52.376478	\N	2026-06-11 02:27:52.37989
41	PC-TEST-32454563	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 02:34:23.246044	\N	2026-06-11 02:34:23.249796
44	PC-TEST-25915986	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 02:49:42.591952	\N	2026-06-11 02:49:42.593945
43	PC-TEST-06196748	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 02:48:40.621278	\N	2026-06-11 02:48:40.626854
45	PC-TEST-33578301	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 03:09:03.358688	\N	2026-06-11 03:09:03.363617
46	PC-TEST-37869055	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 03:09:13.787258	\N	2026-06-11 03:09:13.789492
47	PC-TEST-14781285	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 04:03:31.478529	\N	2026-06-11 04:03:31.481824
48	PC-TEST-52953839	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 04:03:35.295849	\N	2026-06-11 04:03:35.299381
49	PC-TEST-76858905	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 05:13:07.686328	\N	2026-06-11 05:13:07.689425
50	PC-TEST-36278789	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 05:28:23.631279	\N	2026-06-11 05:28:23.652659
51	PC-TEST-43207541	مركز ربح اختبار (معدّل)	Test PC (modified)	\N	f	Phase 4 test updated	\N	2026-06-11 05:28:44.321642	\N	2026-06-11 05:28:44.327761
\.


--
-- Data for Name: tbldim_projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbldim_projects (projectcode, projectid, namear, nameen, parentprojectcode, projecttype, startdate, enddate, budgetamount, actualamount, projectstatus, isactive, notes, adduser, adddate, edituser, editdate) FROM stdin;
1	P-TEST-00012254	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-09	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-09 23:20:50.005322	\N	2026-06-09 23:20:50.013634
15	P-TEST-86333066	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-10	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-10 07:22:38.637561	\N	2026-06-10 07:22:38.644055
2	P-TEST-05735413	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-09	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-09 23:23:30.577365	\N	2026-06-09 23:23:30.58255
3	P-TEST-28229814	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-10	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-10 00:32:02.824624	\N	2026-06-10 00:32:02.827391
29	P-TEST-19592811	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 01:18:11.960742	\N	2026-06-11 01:18:11.9629
4	P-TEST-64023692	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-10	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-10 03:45:56.404978	\N	2026-06-10 03:45:56.411268
16	P-TEST-51584702	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-10	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-10 08:36:35.160397	\N	2026-06-10 08:36:35.166527
5	P-TEST-31475312	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-10	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-10 06:01:43.15499	\N	2026-06-10 06:01:43.16556
6	P-TEST-66501751	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-10	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-10 06:14:06.653086	\N	2026-06-10 06:14:06.658585
24	P-TEST-29413382	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 00:52:52.943112	\N	2026-06-11 00:52:52.945553
7	P-TEST-44646297	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-10	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-10 06:16:34.467377	\N	2026-06-10 06:16:34.472227
17	P-TEST-61832175	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 00:30:36.194069	\N	2026-06-11 00:30:36.207941
8	P-TEST-37594633	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-10	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-10 06:18:43.769656	\N	2026-06-10 06:18:43.782112
9	P-TEST-47449988	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-10	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-10 06:26:24.748222	\N	2026-06-10 06:26:24.754351
10	P-TEST-96992067	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-10	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-10 06:28:49.704385	\N	2026-06-10 06:28:49.714206
18	P-TEST-41404028	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 00:30:54.142413	\N	2026-06-11 00:30:54.14571
11	P-TEST-10452675	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-10	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-10 06:36:11.048484	\N	2026-06-10 06:36:11.053609
12	P-TEST-57493059	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-10	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-10 06:41:45.753383	\N	2026-06-10 06:41:45.76026
13	P-TEST-47860539	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-10	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-10 06:57:34.794333	\N	2026-06-10 06:57:34.803766
19	P-TEST-70673526	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 00:33:37.069369	\N	2026-06-11 00:33:37.072547
14	P-TEST-29602556	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-10	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-10 07:18:42.965791	\N	2026-06-10 07:18:42.975447
25	P-TEST-61753492	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 01:11:46.176798	\N	2026-06-11 01:11:46.179082
20	P-TEST-79501565	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 00:36:57.951626	\N	2026-06-11 00:36:57.954419
21	P-TEST-49563907	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 00:40:04.957927	\N	2026-06-11 00:40:04.960479
35	P-TEST-54982543	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 01:56:05.500098	\N	2026-06-11 01:56:05.503801
22	P-TEST-40000145	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 00:41:34.002058	\N	2026-06-11 00:41:34.005958
26	P-TEST-70194591	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 01:11:47.020905	\N	2026-06-11 01:11:47.02319
23	P-TEST-33653636	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 00:50:43.366904	\N	2026-06-11 00:50:43.369182
30	P-TEST-88002923	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 01:22:08.801751	\N	2026-06-11 01:22:08.804861
27	P-TEST-14816802	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 01:12:21.483787	\N	2026-06-11 01:12:21.486569
28	P-TEST-91394019	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 01:15:29.141467	\N	2026-06-11 01:15:29.144285
33	P-TEST-68674808	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 01:48:46.869465	\N	2026-06-11 01:48:46.872356
31	P-TEST-13544298	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 01:33:11.355994	\N	2026-06-11 01:33:11.358798
32	P-TEST-05004670	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 01:37:20.502415	\N	2026-06-11 01:37:20.505265
34	P-TEST-98791036	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 01:49:39.881292	\N	2026-06-11 01:49:39.884245
36	P-TEST-53220403	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 02:12:55.324144	\N	2026-06-11 02:12:55.327417
37	P-TEST-28616670	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 02:13:02.863172	\N	2026-06-11 02:13:02.865564
38	P-TEST-58927414	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 02:13:35.894281	\N	2026-06-11 02:13:35.896687
39	P-TEST-23645061	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 02:27:52.366395	\N	2026-06-11 02:27:52.369501
40	P-TEST-81625514	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 02:28:48.164079	\N	2026-06-11 02:28:48.166551
41	P-TEST-32281123	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 02:34:23.230567	\N	2026-06-11 02:34:23.234361
42	P-TEST-28574026	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 02:35:22.858877	\N	2026-06-11 02:35:22.862212
50	P-TEST-35437675	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 05:28:23.556256	\N	2026-06-11 05:28:23.576094
43	P-TEST-05868313	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 02:48:40.592518	\N	2026-06-11 02:48:40.605539
51	P-TEST-42969743	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 05:28:44.300144	\N	2026-06-11 05:28:44.304926
44	P-TEST-25793359	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 02:49:42.582709	\N	2026-06-11 02:49:42.585954
45	P-TEST-33262253	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 03:09:03.332617	\N	2026-06-11 03:09:03.337243
46	P-TEST-37725982	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 03:09:13.774718	\N	2026-06-11 03:09:13.780178
47	P-TEST-14642820	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 04:03:31.46662	\N	2026-06-11 04:03:31.470954
48	P-TEST-52797417	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 04:03:35.282501	\N	2026-06-11 04:03:35.287443
49	P-TEST-76744733	مشروع اختبار (معدّل)	Test Project (modified)	\N	INTERNAL	2026-06-11	\N	20000.0000	0.0000	ACTIVE	f	Phase 4 test updated	\N	2026-06-11 05:13:07.676307	\N	2026-06-11 05:13:07.679834
\.


--
-- Data for Name: tbldim_segments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbldim_segments (segmentcode, segmentid, namear, nameen, segmenttype, parentsegmentcode, isactive, notes, adduser, adddate, edituser, editdate) FROM stdin;
27	S-TEST-14902248	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 01:12:21.4906	\N	2026-06-11 01:12:21.492755
1	S-TEST-00251822	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-09 23:20:50.026562	\N	2026-06-09 23:20:50.03361
17	S-TEST-62274332	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 00:30:36.230415	\N	2026-06-11 00:30:36.24327
2	S-TEST-05907008	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-09 23:23:30.591454	\N	2026-06-09 23:23:30.595933
3	S-TEST-28304227	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-10 00:32:02.830768	\N	2026-06-10 00:32:02.8327
4	S-TEST-64196755	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-10 03:45:56.420689	\N	2026-06-10 03:45:56.426708
18	S-TEST-41485871	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 00:30:54.148947	\N	2026-06-11 00:30:54.152018
5	S-TEST-31812775	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-10 06:01:43.183444	\N	2026-06-10 06:01:43.193578
6	S-TEST-66645867	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-10 06:14:06.665315	\N	2026-06-10 06:14:06.66916
7	S-TEST-44796762	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-10 06:16:34.480429	\N	2026-06-10 06:16:34.484441
19	S-TEST-70774745	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 00:33:37.078099	\N	2026-06-11 00:33:37.082265
8	S-TEST-38004561	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-10 06:18:43.801883	\N	2026-06-10 06:18:43.808985
9	S-TEST-47624931	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-10 06:26:24.76343	\N	2026-06-10 06:26:24.768344
28	S-TEST-91471823	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 01:15:29.147484	\N	2026-06-11 01:15:29.149656
10	S-TEST-97284021	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-10 06:28:49.730048	\N	2026-06-10 06:28:49.738305
20	S-TEST-79589091	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 00:36:57.959311	\N	2026-06-11 00:36:57.961352
11	S-TEST-10630264	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-10 06:36:11.064043	\N	2026-06-10 06:36:11.068636
12	S-TEST-57669580	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-10 06:41:45.767732	\N	2026-06-10 06:41:45.772265
13	S-TEST-48156619	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-10 06:57:34.817169	\N	2026-06-10 06:57:34.82678
21	S-TEST-49640910	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 00:40:04.964751	\N	2026-06-11 00:40:04.967688
14	S-TEST-29886950	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-10 07:18:42.990236	\N	2026-06-10 07:18:42.998856
15	S-TEST-86515379	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-10 07:22:38.652411	\N	2026-06-10 07:22:38.658197
16	S-TEST-51722840	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-10 08:36:35.172676	\N	2026-06-10 08:36:35.176068
22	S-TEST-40091805	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 00:41:34.009594	\N	2026-06-11 00:41:34.012139
29	S-TEST-19659207	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 01:18:11.966274	\N	2026-06-11 01:18:11.968419
23	S-TEST-33719681	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 00:50:43.37227	\N	2026-06-11 00:50:43.374177
24	S-TEST-29484299	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 00:52:52.94876	\N	2026-06-11 00:52:52.950719
34	S-TEST-98874810	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 01:49:39.887914	\N	2026-06-11 01:49:39.890202
25	S-TEST-61826647	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 01:11:46.183064	\N	2026-06-11 01:11:46.185032
30	S-TEST-88085154	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 01:22:08.80893	\N	2026-06-11 01:22:08.811087
26	S-TEST-70261247	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 01:11:47.026478	\N	2026-06-11 01:11:47.028236
40	S-TEST-81693754	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 02:28:48.169676	\N	2026-06-11 02:28:48.171525
31	S-TEST-13627884	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 01:33:11.363165	\N	2026-06-11 01:33:11.365304
35	S-TEST-55074098	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 01:56:05.507746	\N	2026-06-11 01:56:05.509835
32	S-TEST-05087712	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 01:37:20.509146	\N	2026-06-11 01:37:20.511192
33	S-TEST-68765368	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 01:48:46.877017	\N	2026-06-11 01:48:46.880269
38	S-TEST-59000733	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 02:13:35.90039	\N	2026-06-11 02:13:35.9027
36	S-TEST-53305377	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 02:12:55.330912	\N	2026-06-11 02:12:55.333162
37	S-TEST-28685743	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 02:13:02.868968	\N	2026-06-11 02:13:02.871763
39	S-TEST-23728787	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 02:27:52.3732	\N	2026-06-11 02:27:52.375245
42	S-TEST-28683717	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 02:35:22.868756	\N	2026-06-11 02:35:22.870985
41	S-TEST-32410529	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 02:34:23.241651	\N	2026-06-11 02:34:23.245018
43	S-TEST-06114564	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 02:48:40.612645	\N	2026-06-11 02:48:40.619027
44	S-TEST-25889486	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 02:49:42.589291	\N	2026-06-11 02:49:42.591316
45	S-TEST-33456253	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 03:09:03.347864	\N	2026-06-11 03:09:03.357245
46	S-TEST-37840053	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 03:09:13.784475	\N	2026-06-11 03:09:13.786622
47	S-TEST-14748273	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 04:03:31.475328	\N	2026-06-11 04:03:31.477754
48	S-TEST-52912433	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 04:03:35.291717	\N	2026-06-11 04:03:35.294964
49	S-TEST-76830429	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 05:13:07.683368	\N	2026-06-11 05:13:07.685506
50	S-TEST-36044342	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 05:28:23.607994	\N	2026-06-11 05:28:23.625425
51	S-TEST-43145569	قطاع اختبار (معدّل)	Test Segment (modified)	GEOGRAPHIC	\N	f	Phase 4 test updated	\N	2026-06-11 05:28:44.315396	\N	2026-06-11 05:28:44.320019
\.


--
-- Data for Name: tbldocumentattachments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbldocumentattachments (attachmentid, source_type, source_id, filename, originalfilename, contenttype, filesize, filecontent, filepath, description, uploadedby, uploaddate) FROM stdin;
\.


--
-- Data for Name: tblexchangeratehistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblexchangeratehistory (ratehistid, currid, exgrate, effectivedate, expirydate, source, notes, adduser, adddate) FROM stdin;
\.


--
-- Data for Name: tblfiscalperiods; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblfiscalperiods (periodid, fiscalyearid, periodname, periodnumber, startdate, enddate, isclosed, adduser, adddate) FROM stdin;
1	1	Period 1	1	2026-01-01	2026-01-31	f	\N	2026-06-09 03:57:37.024846
2	1	Period 2	2	2026-02-01	2026-02-28	f	\N	2026-06-09 03:57:37.024846
3	1	Period 3	3	2026-03-01	2026-03-31	f	\N	2026-06-09 03:57:37.024846
4	1	Period 4	4	2026-04-01	2026-04-30	f	\N	2026-06-09 03:57:37.024846
5	1	Period 5	5	2026-05-01	2026-05-31	f	\N	2026-06-09 03:57:37.024846
6	1	Period 6	6	2026-06-01	2026-06-30	f	\N	2026-06-09 03:57:37.024846
7	1	Period 7	7	2026-07-01	2026-07-31	f	\N	2026-06-09 03:57:37.024846
8	1	Period 8	8	2026-08-01	2026-08-31	f	\N	2026-06-09 03:57:37.024846
9	1	Period 9	9	2026-09-01	2026-09-30	f	\N	2026-06-09 03:57:37.024846
10	1	Period 10	10	2026-10-01	2026-10-31	f	\N	2026-06-09 03:57:37.024846
11	1	Period 11	11	2026-11-01	2026-11-30	f	\N	2026-06-09 03:57:37.024846
12	1	Period 12	12	2026-12-01	2026-12-31	f	\N	2026-06-09 03:57:37.024846
\.


--
-- Data for Name: tblfiscalyears; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblfiscalyears (fiscalyearid, fiscalyearname, startdate, enddate, isactive, isclosed, adduser, adddate) FROM stdin;
1	FY 2026	2026-01-01	2026-12-31	t	f	\N	2026-06-09 03:57:37.023891
\.


--
-- Data for Name: tblfunds; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblfunds (fundcode, fundid, fundnamear, fundnameen, fundtype, currencycode, openingbalance, currentbalance, isactive, notes) FROM stdin;
1	2	الصندوق الرئيسي	\N	\N	\N	0.0000	0.0000	t	\N
3	4	الصندوق الرئيسي	\N	\N	\N	0.0000	0.0000	t	\N
5	6	الصندوق الرئيسي	\N	\N	\N	0.0000	0.0000	t	\N
\.


--
-- Data for Name: tbljournalbody; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbljournalbody (journaldetailid, journalcode, linenumber, accountcode, costcentercode, description, debit, credit, currencycode, debitlocal, creditlocal, departmentcode, projectcode, businessunitcode, segmentcode, profitcentercode) FROM stdin;
1	1	1	1	\N	مدين الصندوق	1000.0000	0.0000	1	1.0000	1.0000	\N	\N	\N	\N	\N
2	1	2	1	\N	مدين الصندوق	1000.0000	0.0000	1	1.0000	1.0000	\N	\N	\N	\N	\N
3	1	3	1	\N	مدين الصندوق	1000.0000	0.0000	1	1.0000	1.0000	\N	\N	\N	\N	\N
\.


--
-- Data for Name: tbljournalheader; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbljournalheader (journalcode, journalid, journaldate, fiscalyear, fiscalperiod, description, referenceno, sourcetype, sourcecode, currencycode, exchangerate, totaldebit, totalcredit, isposted, postedat, postedby, approvedby, approvedat, iscancelled, cancelledat, cancelledby, cancellationreason, createdby, createdat, modifiedby, modifiedat, notes, approvalrequestid, departmentcode, projectcode, businessunitcode, segmentcode, profitcentercode) FROM stdin;
1	J-1	2026-06-08	2026	6	قيد افتتاحي	\N	\N	\N	\N	1.00000000	1000.0000	1000.0000	t	\N	\N	\N	\N	f	\N	\N	\N	1	2026-06-08 18:45:57.519203	\N	\N	\N	\N	\N	\N	\N	\N	\N
4	JV-INT-1	2026-06-09	2026	6	Integration test journal	\N	\N	\N	\N	1.00000000	5000.0000	5000.0000	f	\N	\N	\N	\N	f	\N	\N	\N	1	2026-06-09 05:15:20.380251	\N	\N	\N	4	\N	\N	\N	\N	\N
\.


--
-- Data for Name: tblnotifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblnotifications (notificationid, userid, title, message, notificationtype, priority, isread, reftype, refid, expirydate, createdate, readdate) FROM stdin;
1	1	Approval needed: AR-20260609-2-1	Request AR-20260609-2-1 needs your approval (level 2)	APPROVAL	NORMAL	f	APPROVAL_REQUEST	1	\N	2026-06-09 04:55:43.740993	\N
2	2	Request AR-20260609-2-1 APPROVED	Your request AR-20260609-2-1 has been fully approved.	APPROVAL	NORMAL	f	APPROVAL_REQUEST	1	\N	2026-06-09 04:55:44.890042	\N
3	2	Request AR-20260609-2-2 REJECTED	Your request AR-20260609-2-2 was rejected. Reason: Insufficient documentation	APPROVAL	HIGH	f	APPROVAL_REQUEST	2	\N	2026-06-09 04:56:32.561139	\N
4	1	Approval needed: AR-20260609-1-1	Request AR-20260609-1-1 needs your approval (level 2)	APPROVAL	NORMAL	f	APPROVAL_REQUEST	3	\N	2026-06-09 05:15:19.701377	\N
5	1	Approval needed: AR-20260609-1-1	Request AR-20260609-1-1 needs your approval (level 3)	APPROVAL	NORMAL	f	APPROVAL_REQUEST	3	\N	2026-06-09 05:15:19.814889	\N
6	1	Request AR-20260609-1-1 APPROVED	Your request AR-20260609-1-1 has been fully approved.	APPROVAL	NORMAL	f	APPROVAL_REQUEST	3	\N	2026-06-09 05:15:19.927373	\N
\.


--
-- Data for Name: tbloperationbody; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbloperationbody (operationdetailid, operationcode, linenumber, productcode, unitcode, batchid, quantity, unitprice, cost, discountpercent, discountamount, taxpercent, taxamount, total, storecode, description) FROM stdin;
\.


--
-- Data for Name: tbloperationheader; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbloperationheader (operationcode, operationid, operationtype, operationdate, fiscalyear, fiscalperiod, customercode, suppliercode, branchcode, storecode, currencycode, exchangerate, subtotal, discountpercent, discountamount, taxamount, additionalcharges, total, paidamount, remainingamount, paymentmethodcode, referenceno, description, isposted, postedat, postedby, iscancelled, createdby, createdat, notes) FROM stdin;
\.


--
-- Data for Name: tbloperationtaxes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbloperationtaxes (operationtaxid, operationcode, taxtype, taxpercent, taxamount) FROM stdin;
\.


--
-- Data for Name: tblpaymentmethods; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblpaymentmethods (paymentmethodcode, methodnamear, methodnameen, methodtype, isactive, notes) FROM stdin;
1	نقدي	Cash	CASH	t	\N
2	بنك	Bank	BANK	t	\N
3	آجل	Credit	CREDIT	t	\N
\.


--
-- Data for Name: tblpaymentterms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblpaymentterms (paymenttermcode, termnamear, termnameen, dayscount, isactive, notes) FROM stdin;
\.


--
-- Data for Name: tblpricelists; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblpricelists (pricelistcode, pricelistnamear, pricelistnameen, currencycode, markuppercent, validfrom, validto, isactive, notes) FROM stdin;
\.


--
-- Data for Name: tblprivileges; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblprivileges (privilegeid, usercode, windowid, candisplay, canadd, canedit, candelete, canprint, canexport, canapprove, canpost, custompermissions, effectivefrom, effectiveto, createdby, createdat, modifiedby, modifiedat) FROM stdin;
1	1	1	t	t	t	t	t	f	t	t	\N	2026-06-08 18:45:44.506722	\N	\N	2026-06-08 18:45:44.506722	\N	\N
2	1	2	t	t	t	t	t	f	t	t	\N	2026-06-08 18:45:44.506722	\N	\N	2026-06-08 18:45:44.506722	\N	\N
3	1	3	t	t	t	t	t	f	t	t	\N	2026-06-08 18:45:44.506722	\N	\N	2026-06-08 18:45:44.506722	\N	\N
4	1	4	t	t	t	t	t	f	t	t	\N	2026-06-08 18:45:44.506722	\N	\N	2026-06-08 18:45:44.506722	\N	\N
5	1	5	t	t	t	t	t	f	t	t	\N	2026-06-08 18:45:44.506722	\N	\N	2026-06-08 18:45:44.506722	\N	\N
6	1	6	t	t	t	t	t	f	t	t	\N	2026-06-08 18:45:44.506722	\N	\N	2026-06-08 18:45:44.506722	\N	\N
7	1	7	t	t	t	t	t	f	t	t	\N	2026-06-08 18:45:44.506722	\N	\N	2026-06-08 18:45:44.506722	\N	\N
8	1	8	t	t	t	t	t	f	t	t	\N	2026-06-08 18:45:44.506722	\N	\N	2026-06-08 18:45:44.506722	\N	\N
9	1	9	t	t	t	t	t	f	t	t	\N	2026-06-08 18:45:44.506722	\N	\N	2026-06-08 18:45:44.506722	\N	\N
10	1	10	t	t	t	t	t	f	t	t	\N	2026-06-08 18:45:44.506722	\N	\N	2026-06-08 18:45:44.506722	\N	\N
11	1	11	t	t	t	t	t	f	t	t	\N	2026-06-08 18:45:44.506722	\N	\N	2026-06-08 18:45:44.506722	\N	\N
12	1	12	t	t	t	t	t	f	t	t	\N	2026-06-08 18:45:44.506722	\N	\N	2026-06-08 18:45:44.506722	\N	\N
13	1	13	t	t	t	t	t	f	t	t	\N	2026-06-08 18:45:44.506722	\N	\N	2026-06-08 18:45:44.506722	\N	\N
14	1	14	t	t	t	t	t	f	t	t	\N	2026-06-08 18:45:44.506722	\N	\N	2026-06-08 18:45:44.506722	\N	\N
15	1	15	t	t	t	t	t	f	t	t	\N	2026-06-08 18:45:44.506722	\N	\N	2026-06-08 18:45:44.506722	\N	\N
16	1	16	t	t	t	t	t	f	t	t	\N	2026-06-08 18:45:44.506722	\N	\N	2026-06-08 18:45:44.506722	\N	\N
17	1	17	t	t	t	t	t	f	t	t	\N	2026-06-08 18:45:44.506722	\N	\N	2026-06-08 18:45:44.506722	\N	\N
\.


--
-- Data for Name: tblproductbatches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblproductbatches (batchid, productcode, batchno, expirydate, manufacturedate) FROM stdin;
\.


--
-- Data for Name: tblproductimages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblproductimages (imageid, productcode, imagedata, caption, isprimary, sortorder) FROM stdin;
\.


--
-- Data for Name: tblproductmovement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblproductmovement (movementid, productcode, storecode, movementtype, movementdate, quantity, unitcost, referencetype, referencecode, batchid, notes) FROM stdin;
\.


--
-- Data for Name: tblproductpricing; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblproductpricing (pricingid, productcode, pricelistcode, unitcode, price, minquantity, validfrom, validto) FROM stdin;
\.


--
-- Data for Name: tblproducts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblproducts (productcode, productid, productnamear, productnameen, barcode, categorycode, defaultunitcode, isinventoryitem, standardcost, lastpurchaseprice, lastsaleprice, minstocklevel, maxstocklevel, reorderlevel, isactive, createdby, createdat, notes) FROM stdin;
1	PROD3002	لابتوب Dell	\N	PROD300	1	1	t	0.0000	0.0000	4500.0000	0.0000	0.0000	0.0000	t	\N	2026-06-08 18:45:57.506231	\N
3	PROD3004	لابتوب Dell	\N	PROD300	1	1	t	0.0000	0.0000	4500.0000	0.0000	0.0000	0.0000	t	\N	2026-06-08 18:46:12.75474	\N
5	PROD3006	لابتوب Dell	\N	PROD300	1	1	t	0.0000	0.0000	4500.0000	0.0000	0.0000	0.0000	t	\N	2026-06-08 19:14:53.130416	\N
\.


--
-- Data for Name: tblreportdefinitions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblreportdefinitions (reportid, reportcode, reportname, reportcategory, description, rdlcfilename, parameterschema, isactive, adduser, adddate) FROM stdin;
1	SALES_PERIOD	Sales Report by Period	Sales	Lists all sales bonds within a date range	rptSalesByPeriod.rdlc	\N	t	\N	2026-06-09 03:57:36.978775
2	PURCHASE_PERIOD	Purchase Report by Period	Purchases	Lists all purchase bonds within a date range	rptPurchaseByPeriod.rdlc	\N	t	\N	2026-06-09 03:57:36.978775
3	INVENTORY_VAL	Inventory Valuation	Inventory	Shows current stock value at average cost	rptInventoryValuation.rdlc	\N	t	\N	2026-06-09 03:57:36.978775
4	TRIAL_BALANCE	Trial Balance	Accounting	Lists all account balances	rptTrialBalance.rdlc	\N	t	\N	2026-06-09 03:57:36.978775
5	ACCOUNT_STMT	Account Statement	Accounting	Detailed transactions for one account	rptAccountStatement.rdlc	\N	t	\N	2026-06-09 03:57:36.978775
6	CASH_FLOW	Cash Flow Statement	Treasury	Cash receipts and payments for a period	rptCashFlow.rdlc	\N	t	\N	2026-06-09 03:57:36.978775
7	BANK_RECON	Bank Reconciliation	Treasury	Match bank transactions with system records	rptBankReconciliation.rdlc	\N	t	\N	2026-06-09 03:57:36.978775
8	INVENTORY_MOVE	Inventory Movement	Inventory	Stock movements by product/store/period	rptInventoryMovement.rdlc	\N	t	\N	2026-06-09 03:57:36.978775
9	SALES_BY_CUST	Sales by Customer	Sales	Sales summary grouped by customer	rptSalesByCustomer.rdlc	\N	t	\N	2026-06-09 03:57:36.978775
10	PURCH_BY_SUPP	Purchases by Supplier	Purchases	Purchase summary grouped by supplier	rptPurchasesBySupplier.rdlc	\N	t	\N	2026-06-09 03:57:36.978775
11	PROFIT_LOSS	Profit & Loss Statement	Accounting	Revenue and expense summary	rptProfitLoss.rdlc	\N	t	\N	2026-06-09 03:57:36.978775
12	BALANCE_SHEET	Balance Sheet	Accounting	Assets, liabilities, and equity	rptBalanceSheet.rdlc	\N	t	\N	2026-06-09 03:57:36.978775
\.


--
-- Data for Name: tblsessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblsessions (sessionid, sessiontoken, usercode, userid, branchcode, machinename, ipaddress, macaddress, browserinfo, createdat, lastactivityat, expiresat, logoutat, isactive, sessiondata) FROM stdin;
1	506eadb4-1a07-46ee-9029-511722e2b3df	1	ADMIN	1	PC-TEST	\N	\N	\N	2026-06-08 18:45:57.532669	2026-06-08 18:45:57.532669	2026-06-08 19:45:57.532669	2026-06-08 18:45:57.532669	f	\N
2	2880b7e0-0da1-4148-a586-7b3b915868c7	1	ADMIN	1	PC-TEST	\N	\N	\N	2026-06-08 18:46:12.784671	2026-06-08 18:46:12.784671	2026-06-08 19:46:12.784671	2026-06-08 18:46:12.784671	f	\N
3	dee40712-9fb1-4d5d-a856-96b4cbb20b66	1	ADMIN	1	PC-TEST	\N	\N	\N	2026-06-08 19:14:53.148968	2026-06-08 19:14:53.148968	2026-06-08 20:14:53.148968	2026-06-08 19:14:53.148968	f	\N
\.


--
-- Data for Name: tblstoreproducts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblstoreproducts (storeproductid, storecode, productcode, batchid, qtyonhand, qtyreserved, avgcost, lastcost, locationinstore, isactive) FROM stdin;
4	1	1	\N	10.0000	0.0000	0.0000	0.0000	\N	t
\.


--
-- Data for Name: tblstores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblstores (storecode, storeid, storenamear, storenameen, branchcode, managername, isactive, notes) FROM stdin;
1	MAIN-S	المخزن الرئيسي	\N	\N	\N	t	\N
\.


--
-- Data for Name: tblsuppliercontacts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblsuppliercontacts (contactid, suppliercode, contactname, jobtitle, phone, mobile, email, isprimary) FROM stdin;
\.


--
-- Data for Name: tblsuppliers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblsuppliers (suppliercode, supplierid, suppliernamear, suppliernameen, suppliertype, taxnumber, vatnumber, address, city, country, phone, mobile, email, branchcode, paymenttermcode, bankname, accountnumber, iban, swiftcode, creditlimit, currentcredit, paymentdays, balance, totalpurchases, lastpurchasedate, suppliersince, isactive, isblocked, notes) FROM stdin;
1	SUPP2002	شركة النور	\N	INDIVIDUAL	\N	\N	\N	\N	SA	\N	0502222222	s@x.com	1	\N	\N	\N	\N	\N	0.0000	0.0000	0	0.0000	0.0000	\N	\N	t	f	\N
3	SUPP2004	شركة النور	\N	INDIVIDUAL	\N	\N	\N	\N	SA	\N	0502222222	s@x.com	1	\N	\N	\N	\N	\N	0.0000	0.0000	0	0.0000	0.0000	\N	\N	t	f	\N
5	SUPP2006	شركة النور	\N	INDIVIDUAL	\N	\N	\N	\N	SA	\N	0502222222	s@x.com	1	\N	\N	\N	\N	\N	0.0000	0.0000	0	0.0000	0.0000	\N	\N	t	f	\N
\.


--
-- Data for Name: tbltaxdefinitions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbltaxdefinitions (taxid, taxcode, taxname, taxpercent, isinclusive, isactive, effectivedate, expirydate, notes, adduser, adddate) FROM stdin;
1	VAT-15	VAT 15%	15.0000	f	t	2024-01-01	\N	\N	\N	2026-06-09 03:57:36.983357
2	VAT-5	Reduced VAT 5%	5.0000	f	t	2024-01-01	\N	\N	\N	2026-06-09 03:57:36.983357
3	VAT-0	Zero-rated VAT	0.0000	f	t	2024-01-01	\N	\N	\N	2026-06-09 03:57:36.983357
4	WHT-3	Withholding Tax 3%	3.0000	f	t	2024-01-01	\N	\N	\N	2026-06-09 03:57:36.983357
5	WHT-5	Withholding Tax 5%	5.0000	f	t	2024-01-01	\N	\N	\N	2026-06-09 03:57:36.983357
6	EXEMPT	Tax Exempt	0.0000	f	t	2024-01-01	\N	\N	\N	2026-06-09 03:57:36.983357
\.


--
-- Data for Name: tbltaxtransactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbltaxtransactions (taxtransid, taxid, source_type, source_id, taxableamount, taxamount, txndate, adddate) FROM stdin;
\.


--
-- Data for Name: tblunits; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblunits (unitcode, unitid, unitnamear, unitnameen, symbol, isactive) FROM stdin;
1	PCS	قطعة	Piece	pcs	t
2	KG	كيلو	Kilogram	kg	t
3	صندوق	صندوق	\N	\N	t
\.


--
-- Data for Name: tbluserroleassignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbluserroleassignments (assignmentid, usercode, roleid, assignedby, assignedat, expiresat, isactive) FROM stdin;
\.


--
-- Data for Name: tbluserroles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbluserroles (roleid, rolename, rolenamear, rolenameen, description, isactive, createdat, notes) FROM stdin;
\.


--
-- Data for Name: tblusers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblusers (usercode, userid, userpassword, salt, usernamear, usernameen, email, phone, mobile, isactive, isadmin, passwordlastchanged, passwordhistory1, passwordhistory2, lastloginat, loginattempts, lockeduntil, mustchangepassword, branchcode, department, jobtitle, photo, isonline, createdby, createdat, modifiedby, modifiedat, notes, photo_encrypted) FROM stdin;
2	testuser	\\x5465737440313233	\\x2bf469c32345c3ecb2d628eae052f91f	Test User	Test User	t@x.com	\N	0500000000	t	f	\N	\N	\N	\N	0	\N	f	1	\N	\N	\N	f	\N	2026-06-08 18:46:12.779621	\N	\N	\N	\N
1	ADMIN	\\x4e6577506173734032303234	\\x84dc78ae9d598dbcdba6d6e5d9b4019c	مدير النظام	System Administrator	\N	\N	\N	t	t	2026-06-08 18:53:40.824738	\\x41646d696e40313233	\N	\N	0	\N	f	1	\N	\N	\N	f	1	2026-06-08 18:45:44.503256	\N	\N	\N	\N
\.


--
-- Data for Name: tblwindows; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tblwindows (windowid, windowcode, windownamear, windownameen, modulename, formname, isactive, sortorder, iconname, parentwindowid, createdat, modifiedat, notes) FROM stdin;
1	MAIN	الرئيسية	Main	System	frmMainWindow	t	1	\N	\N	2026-06-08 18:45:44.500332	\N	\N
2	USERS	المستخدمون	Users	Security	frmUsers	t	10	\N	\N	2026-06-08 18:45:44.500332	\N	\N
3	PRIV	الصلاحيات	Privileges	Security	frmPrivillages	t	11	\N	\N	2026-06-08 18:45:44.500332	\N	\N
4	ACCOUNTS	دليل الحسابات	Chart	Accounts	frmAccounts	t	20	\N	\N	2026-06-08 18:45:44.500332	\N	\N
5	JOURNAL	القيود	Journal	Journal	frmJournal	t	30	\N	\N	2026-06-08 18:45:44.500332	\N	\N
6	BONDS	السندات	Bonds	Bonds	frmBonds	t	40	\N	\N	2026-06-08 18:45:44.500332	\N	\N
7	CUSTOMERS	العملاء	Customers	Sales	frmCustomers	t	50	\N	\N	2026-06-08 18:45:44.500332	\N	\N
8	SUPPLIERS	الموردون	Suppliers	Purchases	frmSuppliers	t	60	\N	\N	2026-06-08 18:45:44.500332	\N	\N
9	INVENTORY	المخزون	Inventory	Stores	frmInventory	t	70	\N	\N	2026-06-08 18:45:44.500332	\N	\N
10	PRODUCTS	المنتجات	Products	Stores	frmProducts	t	71	\N	\N	2026-06-08 18:45:44.500332	\N	\N
11	CATEGORIES	الفئات	Categories	Stores	frmCategories	t	72	\N	\N	2026-06-08 18:45:44.500332	\N	\N
12	STORES	المخازن	Stores	Stores	frmStores	t	73	\N	\N	2026-06-08 18:45:44.500332	\N	\N
13	UNITS	الوحدات	Units	Stores	frmUnits	t	74	\N	\N	2026-06-08 18:45:44.500332	\N	\N
14	SALES	المبيعات	Sales	Sales	frmSales	t	80	\N	\N	2026-06-08 18:45:44.500332	\N	\N
15	PURCHASES	المشتريات	Purchases	Purchases	frmPurchases	t	90	\N	\N	2026-06-08 18:45:44.500332	\N	\N
16	REPORTS	التقارير	Reports	Reports	frmReports	t	100	\N	\N	2026-06-08 18:45:44.500332	\N	\N
17	SYSCONFIG	إعدادات النظام	SysFormat	System	frmSysFormat	t	110	\N	\N	2026-06-08 18:45:44.500332	\N	\N
\.


--
-- Name: tblaccounts_accountcode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblaccounts_accountcode_seq', 1, false);


--
-- Name: tblapprovalactions_actionid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblapprovalactions_actionid_seq', 97325, true);


--
-- Name: tblapprovalaudit_auditid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblapprovalaudit_auditid_seq', 97321, true);


--
-- Name: tblapprovalconfig_configid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblapprovalconfig_configid_seq', 6, true);


--
-- Name: tblapprovaldelegations_delegationid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblapprovaldelegations_delegationid_seq', 1, true);


--
-- Name: tblapprovallevels_levelid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblapprovallevels_levelid_seq', 15, true);


--
-- Name: tblapprovalrequests_requestid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblapprovalrequests_requestid_seq', 97319, true);


--
-- Name: tblapprovalworkflows_workflowid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblapprovalworkflows_workflowid_seq', 8, true);


--
-- Name: tblaudi_audithistid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblaudi_audithistid_seq', 1, false);


--
-- Name: tblaudi_security_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblaudi_security_id_seq', 1, false);


--
-- Name: tblauditlogs_auditid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblauditlogs_auditid_seq', 3, true);


--
-- Name: tblbankaccounts_bankaccountid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblbankaccounts_bankaccountid_seq', 1, true);


--
-- Name: tblbankreconciliations_reconid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblbankreconciliations_reconid_seq', 1, false);


--
-- Name: tblbanks_bankcode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblbanks_bankcode_seq', 1, false);


--
-- Name: tblbankstatementlines_stmtlineid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblbankstatementlines_stmtlineid_seq', 1, false);


--
-- Name: tblbankstatements_statementid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblbankstatements_statementid_seq', 1, false);


--
-- Name: tblbanktransactions_banktxnid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblbanktransactions_banktxnid_seq', 1, false);


--
-- Name: tblbondbody_bonddetailid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblbondbody_bonddetailid_seq', 3, true);


--
-- Name: tblbondheader_bondcode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblbondheader_bondcode_seq', 97320, true);


--
-- Name: tblbranches_branchcode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblbranches_branchcode_seq', 6, true);


--
-- Name: tblbudgetperiods_periodid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblbudgetperiods_periodid_seq', 1, false);


--
-- Name: tblbudgets_budgetid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblbudgets_budgetid_seq', 1, false);


--
-- Name: tblcashboxes_cashboxid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblcashboxes_cashboxid_seq', 1, false);


--
-- Name: tblcashpayments_paymentid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblcashpayments_paymentid_seq', 1, false);


--
-- Name: tblcashreceipts_receiptid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblcashreceipts_receiptid_seq', 1, false);


--
-- Name: tblcategories_categorycode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblcategories_categorycode_seq', 6, true);


--
-- Name: tblcompanies_companycode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblcompanies_companycode_seq', 1, false);


--
-- Name: tblcostcenters_costcentercode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblcostcenters_costcentercode_seq', 1, false);


--
-- Name: tblcurrencies_currencycode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblcurrencies_currencycode_seq', 6, true);


--
-- Name: tblcustomercontacts_contactid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblcustomercontacts_contactid_seq', 1, false);


--
-- Name: tblcustomers_customercode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblcustomers_customercode_seq', 6, true);


--
-- Name: tbldim_businessunits_businessunitcode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbldim_businessunits_businessunitcode_seq', 51, true);


--
-- Name: tbldim_departments_departmentcode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbldim_departments_departmentcode_seq', 51, true);


--
-- Name: tbldim_hierarchies_hierarchyid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbldim_hierarchies_hierarchyid_seq', 51, true);


--
-- Name: tbldim_profitcenters_profitcentercode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbldim_profitcenters_profitcentercode_seq', 51, true);


--
-- Name: tbldim_projects_projectcode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbldim_projects_projectcode_seq', 51, true);


--
-- Name: tbldim_segments_segmentcode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbldim_segments_segmentcode_seq', 51, true);


--
-- Name: tbldocumentattachments_attachmentid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbldocumentattachments_attachmentid_seq', 1, false);


--
-- Name: tblexchangeratehistory_ratehistid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblexchangeratehistory_ratehistid_seq', 1, false);


--
-- Name: tblfiscalperiods_periodid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblfiscalperiods_periodid_seq', 42, true);


--
-- Name: tblfiscalyears_fiscalyearid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblfiscalyears_fiscalyearid_seq', 1, true);


--
-- Name: tblfunds_fundcode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblfunds_fundcode_seq', 6, true);


--
-- Name: tbljournalbody_journaldetailid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbljournalbody_journaldetailid_seq', 3, true);


--
-- Name: tbljournalheader_journalcode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbljournalheader_journalcode_seq', 4, true);


--
-- Name: tblnotifications_notificationid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblnotifications_notificationid_seq', 6, true);


--
-- Name: tbloperationbody_operationdetailid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbloperationbody_operationdetailid_seq', 3, true);


--
-- Name: tbloperationheader_operationcode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbloperationheader_operationcode_seq', 3, true);


--
-- Name: tbloperationtaxes_operationtaxid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbloperationtaxes_operationtaxid_seq', 1, false);


--
-- Name: tblpaymentmethods_paymentmethodcode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblpaymentmethods_paymentmethodcode_seq', 1, false);


--
-- Name: tblpaymentterms_paymenttermcode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblpaymentterms_paymenttermcode_seq', 1, false);


--
-- Name: tblpricelists_pricelistcode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblpricelists_pricelistcode_seq', 1, false);


--
-- Name: tblprivileges_privilegeid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblprivileges_privilegeid_seq', 17, true);


--
-- Name: tblproductbatches_batchid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblproductbatches_batchid_seq', 1, false);


--
-- Name: tblproductimages_imageid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblproductimages_imageid_seq', 1, false);


--
-- Name: tblproductmovement_movementid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblproductmovement_movementid_seq', 1, false);


--
-- Name: tblproductpricing_pricingid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblproductpricing_pricingid_seq', 1, false);


--
-- Name: tblproducts_productcode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblproducts_productcode_seq', 6, true);


--
-- Name: tblreportdefinitions_reportid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblreportdefinitions_reportid_seq', 12, true);


--
-- Name: tblsessions_sessionid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblsessions_sessionid_seq', 3, true);


--
-- Name: tblstoreproducts_storeproductid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblstoreproducts_storeproductid_seq', 5, true);


--
-- Name: tblstores_storecode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblstores_storecode_seq', 1, false);


--
-- Name: tblsuppliercontacts_contactid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblsuppliercontacts_contactid_seq', 1, false);


--
-- Name: tblsuppliers_suppliercode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblsuppliers_suppliercode_seq', 6, true);


--
-- Name: tbltaxdefinitions_taxid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbltaxdefinitions_taxid_seq', 6, true);


--
-- Name: tbltaxtransactions_taxtransid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbltaxtransactions_taxtransid_seq', 1, false);


--
-- Name: tblunits_unitcode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblunits_unitcode_seq', 3, true);


--
-- Name: tbluserroleassignments_assignmentid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbluserroleassignments_assignmentid_seq', 1, false);


--
-- Name: tbluserroles_roleid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbluserroles_roleid_seq', 1, false);


--
-- Name: tblusers_usercode_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblusers_usercode_seq', 3, true);


--
-- Name: tblwindows_windowid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tblwindows_windowid_seq', 17, true);


--
-- Name: tblbankstatements excl_tblbankstatements_account_statementno; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbankstatements
    ADD CONSTRAINT excl_tblbankstatements_account_statementno EXCLUDE USING gist (bankaccountid WITH =, statementno WITH =);


--
-- Name: tblexchangeratehistory excl_tblexchangeratehistory_currid_daterange; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblexchangeratehistory
    ADD CONSTRAINT excl_tblexchangeratehistory_currid_daterange EXCLUDE USING gist (currid WITH =, daterange(effectivedate, COALESCE(expirydate, 'infinity'::date), '[]'::text) WITH &&);


--
-- Name: tblfiscalperiods excl_tblfiscalperiods_fiscalyear_daterange; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblfiscalperiods
    ADD CONSTRAINT excl_tblfiscalperiods_fiscalyear_daterange EXCLUDE USING gist (fiscalyearid WITH =, daterange(startdate, enddate, '[]'::text) WITH &&);


--
-- Name: tblsessions excl_tblsessions_active_user; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblsessions
    ADD CONSTRAINT excl_tblsessions_active_user EXCLUDE USING gist (usercode WITH =, tsrange(createdat, expiresat, '[]'::text) WITH &&) WHERE ((isactive = true));


--
-- Name: tblaccounts tblaccounts_accountid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblaccounts
    ADD CONSTRAINT tblaccounts_accountid_key UNIQUE (accountid);


--
-- Name: tblaccounts tblaccounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblaccounts
    ADD CONSTRAINT tblaccounts_pkey PRIMARY KEY (accountcode);


--
-- Name: tblapprovalactions tblapprovalactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovalactions
    ADD CONSTRAINT tblapprovalactions_pkey PRIMARY KEY (actionid);


--
-- Name: tblapprovalaudit tblapprovalaudit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovalaudit
    ADD CONSTRAINT tblapprovalaudit_pkey PRIMARY KEY (auditid);


--
-- Name: tblapprovalconfig tblapprovalconfig_configkey_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovalconfig
    ADD CONSTRAINT tblapprovalconfig_configkey_key UNIQUE (configkey);


--
-- Name: tblapprovalconfig tblapprovalconfig_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovalconfig
    ADD CONSTRAINT tblapprovalconfig_pkey PRIMARY KEY (configid);


--
-- Name: tblapprovaldelegations tblapprovaldelegations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovaldelegations
    ADD CONSTRAINT tblapprovaldelegations_pkey PRIMARY KEY (delegationid);


--
-- Name: tblapprovallevels tblapprovallevels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovallevels
    ADD CONSTRAINT tblapprovallevels_pkey PRIMARY KEY (levelid);


--
-- Name: tblapprovallevels tblapprovallevels_workflowid_levelnumber_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovallevels
    ADD CONSTRAINT tblapprovallevels_workflowid_levelnumber_key UNIQUE (workflowid, levelnumber);


--
-- Name: tblapprovalrequests tblapprovalrequests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovalrequests
    ADD CONSTRAINT tblapprovalrequests_pkey PRIMARY KEY (requestid);


--
-- Name: tblapprovalrequests tblapprovalrequests_requestno_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovalrequests
    ADD CONSTRAINT tblapprovalrequests_requestno_key UNIQUE (requestno);


--
-- Name: tblapprovalrequests tblapprovalrequests_sourcetype_sourceid_requesterid_adddate_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovalrequests
    ADD CONSTRAINT tblapprovalrequests_sourcetype_sourceid_requesterid_adddate_key UNIQUE (sourcetype, sourceid, requesterid, adddate);


--
-- Name: tblapprovalworkflows tblapprovalworkflows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovalworkflows
    ADD CONSTRAINT tblapprovalworkflows_pkey PRIMARY KEY (workflowid);


--
-- Name: tblapprovalworkflows tblapprovalworkflows_workflowcode_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovalworkflows
    ADD CONSTRAINT tblapprovalworkflows_workflowcode_key UNIQUE (workflowcode);


--
-- Name: tblaudi tblaudi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblaudi
    ADD CONSTRAINT tblaudi_pkey PRIMARY KEY (audithistid);


--
-- Name: tblaudi_security tblaudi_security_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblaudi_security
    ADD CONSTRAINT tblaudi_security_pkey PRIMARY KEY (id);


--
-- Name: tblauditlogs tblauditlogs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblauditlogs
    ADD CONSTRAINT tblauditlogs_pkey PRIMARY KEY (auditid);


--
-- Name: tblbankaccounts tblbankaccounts_bankaccountno_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbankaccounts
    ADD CONSTRAINT tblbankaccounts_bankaccountno_key UNIQUE (bankaccountno);


--
-- Name: tblbankaccounts tblbankaccounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbankaccounts
    ADD CONSTRAINT tblbankaccounts_pkey PRIMARY KEY (bankaccountid);


--
-- Name: tblbankreconciliations tblbankreconciliations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbankreconciliations
    ADD CONSTRAINT tblbankreconciliations_pkey PRIMARY KEY (reconid);


--
-- Name: tblbanks tblbanks_bankid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbanks
    ADD CONSTRAINT tblbanks_bankid_key UNIQUE (bankid);


--
-- Name: tblbanks tblbanks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbanks
    ADD CONSTRAINT tblbanks_pkey PRIMARY KEY (bankcode);


--
-- Name: tblbankstatementlines tblbankstatementlines_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbankstatementlines
    ADD CONSTRAINT tblbankstatementlines_pkey PRIMARY KEY (stmtlineid);


--
-- Name: tblbankstatements tblbankstatements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbankstatements
    ADD CONSTRAINT tblbankstatements_pkey PRIMARY KEY (statementid);


--
-- Name: tblbanktransactions tblbanktransactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbanktransactions
    ADD CONSTRAINT tblbanktransactions_pkey PRIMARY KEY (banktxnid);


--
-- Name: tblbondbody tblbondbody_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbondbody
    ADD CONSTRAINT tblbondbody_pkey PRIMARY KEY (bonddetailid);


--
-- Name: tblbondheader tblbondheader_bondid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbondheader
    ADD CONSTRAINT tblbondheader_bondid_key UNIQUE (bondid);


--
-- Name: tblbondheader tblbondheader_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbondheader
    ADD CONSTRAINT tblbondheader_pkey PRIMARY KEY (bondcode);


--
-- Name: tblbranches tblbranches_branchid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbranches
    ADD CONSTRAINT tblbranches_branchid_key UNIQUE (branchid);


--
-- Name: tblbranches tblbranches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbranches
    ADD CONSTRAINT tblbranches_pkey PRIMARY KEY (branchcode);


--
-- Name: tblbudgetperiods tblbudgetperiods_periodname_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbudgetperiods
    ADD CONSTRAINT tblbudgetperiods_periodname_key UNIQUE (periodname);


--
-- Name: tblbudgetperiods tblbudgetperiods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbudgetperiods
    ADD CONSTRAINT tblbudgetperiods_pkey PRIMARY KEY (periodid);


--
-- Name: tblbudgets tblbudgets_periodid_accountid_branchid_costcenterid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbudgets
    ADD CONSTRAINT tblbudgets_periodid_accountid_branchid_costcenterid_key UNIQUE (periodid, accountid, branchid, costcenterid);


--
-- Name: tblbudgets tblbudgets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbudgets
    ADD CONSTRAINT tblbudgets_pkey PRIMARY KEY (budgetid);


--
-- Name: tblcashboxes tblcashboxes_cashboxcode_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashboxes
    ADD CONSTRAINT tblcashboxes_cashboxcode_key UNIQUE (cashboxcode);


--
-- Name: tblcashboxes tblcashboxes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashboxes
    ADD CONSTRAINT tblcashboxes_pkey PRIMARY KEY (cashboxid);


--
-- Name: tblcashpayments tblcashpayments_paymentno_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashpayments
    ADD CONSTRAINT tblcashpayments_paymentno_key UNIQUE (paymentno);


--
-- Name: tblcashpayments tblcashpayments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashpayments
    ADD CONSTRAINT tblcashpayments_pkey PRIMARY KEY (paymentid);


--
-- Name: tblcashreceipts tblcashreceipts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashreceipts
    ADD CONSTRAINT tblcashreceipts_pkey PRIMARY KEY (receiptid);


--
-- Name: tblcashreceipts tblcashreceipts_receiptno_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashreceipts
    ADD CONSTRAINT tblcashreceipts_receiptno_key UNIQUE (receiptno);


--
-- Name: tblcategories tblcategories_categoryid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcategories
    ADD CONSTRAINT tblcategories_categoryid_key UNIQUE (categoryid);


--
-- Name: tblcategories tblcategories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcategories
    ADD CONSTRAINT tblcategories_pkey PRIMARY KEY (categorycode);


--
-- Name: tblcompanies tblcompanies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcompanies
    ADD CONSTRAINT tblcompanies_pkey PRIMARY KEY (companycode);


--
-- Name: tblcostcenters tblcostcenters_costcenterid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcostcenters
    ADD CONSTRAINT tblcostcenters_costcenterid_key UNIQUE (costcenterid);


--
-- Name: tblcostcenters tblcostcenters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcostcenters
    ADD CONSTRAINT tblcostcenters_pkey PRIMARY KEY (costcentercode);


--
-- Name: tblcurrencies tblcurrencies_currencyid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcurrencies
    ADD CONSTRAINT tblcurrencies_currencyid_key UNIQUE (currencyid);


--
-- Name: tblcurrencies tblcurrencies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcurrencies
    ADD CONSTRAINT tblcurrencies_pkey PRIMARY KEY (currencycode);


--
-- Name: tblcustomercontacts tblcustomercontacts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcustomercontacts
    ADD CONSTRAINT tblcustomercontacts_pkey PRIMARY KEY (contactid);


--
-- Name: tblcustomers tblcustomers_customerid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcustomers
    ADD CONSTRAINT tblcustomers_customerid_key UNIQUE (customerid);


--
-- Name: tblcustomers tblcustomers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcustomers
    ADD CONSTRAINT tblcustomers_pkey PRIMARY KEY (customercode);


--
-- Name: tbldim_businessunits tbldim_businessunits_businessunitid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_businessunits
    ADD CONSTRAINT tbldim_businessunits_businessunitid_key UNIQUE (businessunitid);


--
-- Name: tbldim_businessunits tbldim_businessunits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_businessunits
    ADD CONSTRAINT tbldim_businessunits_pkey PRIMARY KEY (businessunitcode);


--
-- Name: tbldim_departments tbldim_departments_departmentid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_departments
    ADD CONSTRAINT tbldim_departments_departmentid_key UNIQUE (departmentid);


--
-- Name: tbldim_departments tbldim_departments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_departments
    ADD CONSTRAINT tbldim_departments_pkey PRIMARY KEY (departmentcode);


--
-- Name: tbldim_hierarchies tbldim_hierarchies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_hierarchies
    ADD CONSTRAINT tbldim_hierarchies_pkey PRIMARY KEY (hierarchyid);


--
-- Name: tbldim_profitcenters tbldim_profitcenters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_profitcenters
    ADD CONSTRAINT tbldim_profitcenters_pkey PRIMARY KEY (profitcentercode);


--
-- Name: tbldim_profitcenters tbldim_profitcenters_profitcenterid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_profitcenters
    ADD CONSTRAINT tbldim_profitcenters_profitcenterid_key UNIQUE (profitcenterid);


--
-- Name: tbldim_projects tbldim_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_projects
    ADD CONSTRAINT tbldim_projects_pkey PRIMARY KEY (projectcode);


--
-- Name: tbldim_projects tbldim_projects_projectid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_projects
    ADD CONSTRAINT tbldim_projects_projectid_key UNIQUE (projectid);


--
-- Name: tbldim_segments tbldim_segments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_segments
    ADD CONSTRAINT tbldim_segments_pkey PRIMARY KEY (segmentcode);


--
-- Name: tbldim_segments tbldim_segments_segmentid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_segments
    ADD CONSTRAINT tbldim_segments_segmentid_key UNIQUE (segmentid);


--
-- Name: tbldocumentattachments tbldocumentattachments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldocumentattachments
    ADD CONSTRAINT tbldocumentattachments_pkey PRIMARY KEY (attachmentid);


--
-- Name: tblexchangeratehistory tblexchangeratehistory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblexchangeratehistory
    ADD CONSTRAINT tblexchangeratehistory_pkey PRIMARY KEY (ratehistid);


--
-- Name: tblfiscalperiods tblfiscalperiods_fiscalyearid_periodnumber_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblfiscalperiods
    ADD CONSTRAINT tblfiscalperiods_fiscalyearid_periodnumber_key UNIQUE (fiscalyearid, periodnumber);


--
-- Name: tblfiscalperiods tblfiscalperiods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblfiscalperiods
    ADD CONSTRAINT tblfiscalperiods_pkey PRIMARY KEY (periodid);


--
-- Name: tblfiscalyears tblfiscalyears_fiscalyearname_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblfiscalyears
    ADD CONSTRAINT tblfiscalyears_fiscalyearname_key UNIQUE (fiscalyearname);


--
-- Name: tblfiscalyears tblfiscalyears_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblfiscalyears
    ADD CONSTRAINT tblfiscalyears_pkey PRIMARY KEY (fiscalyearid);


--
-- Name: tblfunds tblfunds_fundid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblfunds
    ADD CONSTRAINT tblfunds_fundid_key UNIQUE (fundid);


--
-- Name: tblfunds tblfunds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblfunds
    ADD CONSTRAINT tblfunds_pkey PRIMARY KEY (fundcode);


--
-- Name: tbljournalbody tbljournalbody_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbljournalbody
    ADD CONSTRAINT tbljournalbody_pkey PRIMARY KEY (journaldetailid);


--
-- Name: tbljournalheader tbljournalheader_journalid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbljournalheader
    ADD CONSTRAINT tbljournalheader_journalid_key UNIQUE (journalid);


--
-- Name: tbljournalheader tbljournalheader_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbljournalheader
    ADD CONSTRAINT tbljournalheader_pkey PRIMARY KEY (journalcode);


--
-- Name: tblnotifications tblnotifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblnotifications
    ADD CONSTRAINT tblnotifications_pkey PRIMARY KEY (notificationid);


--
-- Name: tbloperationbody tbloperationbody_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbloperationbody
    ADD CONSTRAINT tbloperationbody_pkey PRIMARY KEY (operationdetailid);


--
-- Name: tbloperationheader tbloperationheader_operationid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbloperationheader
    ADD CONSTRAINT tbloperationheader_operationid_key UNIQUE (operationid);


--
-- Name: tbloperationheader tbloperationheader_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbloperationheader
    ADD CONSTRAINT tbloperationheader_pkey PRIMARY KEY (operationcode);


--
-- Name: tbloperationtaxes tbloperationtaxes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbloperationtaxes
    ADD CONSTRAINT tbloperationtaxes_pkey PRIMARY KEY (operationtaxid);


--
-- Name: tblpaymentmethods tblpaymentmethods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblpaymentmethods
    ADD CONSTRAINT tblpaymentmethods_pkey PRIMARY KEY (paymentmethodcode);


--
-- Name: tblpaymentterms tblpaymentterms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblpaymentterms
    ADD CONSTRAINT tblpaymentterms_pkey PRIMARY KEY (paymenttermcode);


--
-- Name: tblpricelists tblpricelists_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblpricelists
    ADD CONSTRAINT tblpricelists_pkey PRIMARY KEY (pricelistcode);


--
-- Name: tblprivileges tblprivileges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblprivileges
    ADD CONSTRAINT tblprivileges_pkey PRIMARY KEY (privilegeid);


--
-- Name: tblproductbatches tblproductbatches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblproductbatches
    ADD CONSTRAINT tblproductbatches_pkey PRIMARY KEY (batchid);


--
-- Name: tblproductimages tblproductimages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblproductimages
    ADD CONSTRAINT tblproductimages_pkey PRIMARY KEY (imageid);


--
-- Name: tblproductmovement tblproductmovement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblproductmovement
    ADD CONSTRAINT tblproductmovement_pkey PRIMARY KEY (movementid);


--
-- Name: tblproductpricing tblproductpricing_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblproductpricing
    ADD CONSTRAINT tblproductpricing_pkey PRIMARY KEY (pricingid);


--
-- Name: tblproducts tblproducts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblproducts
    ADD CONSTRAINT tblproducts_pkey PRIMARY KEY (productcode);


--
-- Name: tblproducts tblproducts_productid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblproducts
    ADD CONSTRAINT tblproducts_productid_key UNIQUE (productid);


--
-- Name: tblreportdefinitions tblreportdefinitions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblreportdefinitions
    ADD CONSTRAINT tblreportdefinitions_pkey PRIMARY KEY (reportid);


--
-- Name: tblreportdefinitions tblreportdefinitions_reportcode_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblreportdefinitions
    ADD CONSTRAINT tblreportdefinitions_reportcode_key UNIQUE (reportcode);


--
-- Name: tblsessions tblsessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblsessions
    ADD CONSTRAINT tblsessions_pkey PRIMARY KEY (sessionid);


--
-- Name: tblsessions tblsessions_sessiontoken_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblsessions
    ADD CONSTRAINT tblsessions_sessiontoken_key UNIQUE (sessiontoken);


--
-- Name: tblstoreproducts tblstoreproducts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblstoreproducts
    ADD CONSTRAINT tblstoreproducts_pkey PRIMARY KEY (storeproductid);


--
-- Name: tblstores tblstores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblstores
    ADD CONSTRAINT tblstores_pkey PRIMARY KEY (storecode);


--
-- Name: tblstores tblstores_storeid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblstores
    ADD CONSTRAINT tblstores_storeid_key UNIQUE (storeid);


--
-- Name: tblsuppliercontacts tblsuppliercontacts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblsuppliercontacts
    ADD CONSTRAINT tblsuppliercontacts_pkey PRIMARY KEY (contactid);


--
-- Name: tblsuppliers tblsuppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblsuppliers
    ADD CONSTRAINT tblsuppliers_pkey PRIMARY KEY (suppliercode);


--
-- Name: tblsuppliers tblsuppliers_supplierid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblsuppliers
    ADD CONSTRAINT tblsuppliers_supplierid_key UNIQUE (supplierid);


--
-- Name: tbltaxdefinitions tbltaxdefinitions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbltaxdefinitions
    ADD CONSTRAINT tbltaxdefinitions_pkey PRIMARY KEY (taxid);


--
-- Name: tbltaxdefinitions tbltaxdefinitions_taxcode_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbltaxdefinitions
    ADD CONSTRAINT tbltaxdefinitions_taxcode_key UNIQUE (taxcode);


--
-- Name: tbltaxtransactions tbltaxtransactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbltaxtransactions
    ADD CONSTRAINT tbltaxtransactions_pkey PRIMARY KEY (taxtransid);


--
-- Name: tblunits tblunits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblunits
    ADD CONSTRAINT tblunits_pkey PRIMARY KEY (unitcode);


--
-- Name: tblunits tblunits_unitid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblunits
    ADD CONSTRAINT tblunits_unitid_key UNIQUE (unitid);


--
-- Name: tbluserroleassignments tbluserroleassignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbluserroleassignments
    ADD CONSTRAINT tbluserroleassignments_pkey PRIMARY KEY (assignmentid);


--
-- Name: tbluserroles tbluserroles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbluserroles
    ADD CONSTRAINT tbluserroles_pkey PRIMARY KEY (roleid);


--
-- Name: tbluserroles tbluserroles_rolename_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbluserroles
    ADD CONSTRAINT tbluserroles_rolename_key UNIQUE (rolename);


--
-- Name: tblusers tblusers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblusers
    ADD CONSTRAINT tblusers_pkey PRIMARY KEY (usercode);


--
-- Name: tblusers tblusers_userid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblusers
    ADD CONSTRAINT tblusers_userid_key UNIQUE (userid);


--
-- Name: tblwindows tblwindows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblwindows
    ADD CONSTRAINT tblwindows_pkey PRIMARY KEY (windowid);


--
-- Name: tblwindows tblwindows_windowcode_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblwindows
    ADD CONSTRAINT tblwindows_windowcode_key UNIQUE (windowcode);


--
-- Name: tbldim_hierarchies uq_dim_hier; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_hierarchies
    ADD CONSTRAINT uq_dim_hier UNIQUE (hierarchytype, parentdimtype, parentdimcode, childdimtype, childdimcode);


--
-- Name: tblstoreproducts uq_storeproduct_batch; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblstoreproducts
    ADD CONSTRAINT uq_storeproduct_batch UNIQUE (storecode, productcode, batchid);


--
-- Name: tbluserroleassignments uq_userrole_assignment; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbluserroleassignments
    ADD CONSTRAINT uq_userrole_assignment UNIQUE (usercode, roleid);


--
-- Name: tblprivileges uq_userwindow; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblprivileges
    ADD CONSTRAINT uq_userwindow UNIQUE (usercode, windowid);


--
-- Name: idx_audi_security_type_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audi_security_type_time ON public.tblaudi_security USING btree (event_type, occurred_at DESC);


--
-- Name: idx_auditlogs_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_auditlogs_date ON public.tblauditlogs USING btree (eventdate);


--
-- Name: idx_auditlogs_event; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_auditlogs_event ON public.tblauditlogs USING btree (eventtype);


--
-- Name: idx_auditlogs_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_auditlogs_user ON public.tblauditlogs USING btree (usercode);


--
-- Name: idx_journalbody_account; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_journalbody_account ON public.tbljournalbody USING btree (accountcode);


--
-- Name: idx_journalbody_journal; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_journalbody_journal ON public.tbljournalbody USING btree (journalcode);


--
-- Name: idx_mv_account_balances_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mv_account_balances_parent ON public.mv_account_balances USING btree (parentaccountcode);


--
-- Name: idx_mv_account_balances_pk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_mv_account_balances_pk ON public.mv_account_balances USING btree (accountcode);


--
-- Name: idx_mv_budget_vs_actual_summary_pk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_mv_budget_vs_actual_summary_pk ON public.mv_budget_vs_actual_summary USING btree (period_id, account_id, branch_id, cost_center_id);


--
-- Name: idx_mv_chart_of_accounts_level; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mv_chart_of_accounts_level ON public.mv_chart_of_accounts USING btree (acclevel);


--
-- Name: idx_mv_chart_of_accounts_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mv_chart_of_accounts_parent ON public.mv_chart_of_accounts USING btree (parentaccountcode);


--
-- Name: idx_mv_chart_of_accounts_pk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_mv_chart_of_accounts_pk ON public.mv_chart_of_accounts USING btree (accountcode);


--
-- Name: idx_mv_customer_outstanding_balance_pk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_mv_customer_outstanding_balance_pk ON public.mv_customer_outstanding_balance USING btree (customer_code);


--
-- Name: idx_mv_daily_sales_summary_pk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_mv_daily_sales_summary_pk ON public.mv_daily_sales_summary USING btree (sale_date, branch_code);


--
-- Name: idx_mv_final_accounts_nature; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mv_final_accounts_nature ON public.mv_final_accounts USING btree (acctnature);


--
-- Name: idx_mv_final_accounts_pk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_mv_final_accounts_pk ON public.mv_final_accounts USING btree (accountcode);


--
-- Name: idx_mv_journal_summary_pk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_mv_journal_summary_pk ON public.mv_journal_summary USING btree (journal_date, source_type, fy, fp);


--
-- Name: idx_mv_monthly_inventory_snapshot_pk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_mv_monthly_inventory_snapshot_pk ON public.mv_monthly_inventory_snapshot USING btree (product_code, store_code);


--
-- Name: idx_mv_treasury_position_pk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_mv_treasury_position_pk ON public.mv_treasury_position USING btree (entity_type, entity_id);


--
-- Name: idx_mv_trial_balance_account; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mv_trial_balance_account ON public.mv_trial_balance USING btree (accountnumber);


--
-- Name: idx_mv_trial_balance_pk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_mv_trial_balance_pk ON public.mv_trial_balance USING btree (accountcode);


--
-- Name: idx_privileges_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_privileges_user ON public.tblprivileges USING btree (usercode);


--
-- Name: idx_privileges_window; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_privileges_window ON public.tblprivileges USING btree (windowid);


--
-- Name: idx_sessions_expires; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sessions_expires ON public.tblsessions USING btree (expiresat);


--
-- Name: idx_sessions_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sessions_token ON public.tblsessions USING btree (sessiontoken);


--
-- Name: idx_sessions_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sessions_user ON public.tblsessions USING btree (usercode);


--
-- Name: idx_tblaccounts_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tblaccounts_active ON public.tblaccounts USING btree (isactive);


--
-- Name: idx_tblaccounts_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tblaccounts_parent ON public.tblaccounts USING btree (parentaccountcode);


--
-- Name: idx_tblaccounts_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tblaccounts_type ON public.tblaccounts USING btree (accounttype);


--
-- Name: idx_tblaudi_table_record_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tblaudi_table_record_date ON public.tblaudi USING btree (tablename, recordid, actiondate DESC);


--
-- Name: idx_tblbondbody_bond_account; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tblbondbody_bond_account ON public.tblbondbody USING btree (bondcode, accountcode);


--
-- Name: idx_tblcashpayments_date_cashbox_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tblcashpayments_date_cashbox_status ON public.tblcashpayments USING btree (paymentdate, cashboxid, status);


--
-- Name: idx_tblcashreceipts_date_cashbox_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tblcashreceipts_date_cashbox_status ON public.tblcashreceipts USING btree (receiptdate, cashboxid, status);


--
-- Name: idx_tbljournalbody_journal_account; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tbljournalbody_journal_account ON public.tbljournalbody USING btree (journalcode, accountcode);


--
-- Name: idx_tblproducts_inventory; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tblproducts_inventory ON public.tblproducts USING btree (productcode) WHERE ((isinventoryitem = true) AND (isactive = true));


--
-- Name: idx_tblsessions_user_active_expires; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tblsessions_user_active_expires ON public.tblsessions USING btree (userid, isactive, expiresat);


--
-- Name: idx_tblusers_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tblusers_active ON public.tblusers USING btree (usercode) WHERE (isactive = true);


--
-- Name: idx_tblusers_branch; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tblusers_branch ON public.tblusers USING btree (branchcode);


--
-- Name: idx_tblusers_isactive; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tblusers_isactive ON public.tblusers USING btree (isactive);


--
-- Name: idx_tblusers_userid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tblusers_userid ON public.tblusers USING btree (userid);


--
-- Name: idx_tblwindows_module; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tblwindows_module ON public.tblwindows USING btree (modulename);


--
-- Name: idx_tblwindows_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tblwindows_parent ON public.tblwindows USING btree (parentwindowid);


--
-- Name: ix_approvalactions_approver; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_approvalactions_approver ON public.tblapprovalactions USING btree (approverid, actiondate);


--
-- Name: ix_approvalactions_request; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_approvalactions_request ON public.tblapprovalactions USING btree (requestid, actiondate);


--
-- Name: ix_approvalactions_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_approvalactions_type ON public.tblapprovalactions USING btree (actiontype, actiondate);


--
-- Name: ix_approvalaudit_event; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_approvalaudit_event ON public.tblapprovalaudit USING btree (eventtype, performedat);


--
-- Name: ix_approvalaudit_request; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_approvalaudit_request ON public.tblapprovalaudit USING btree (requestid, performedat);


--
-- Name: ix_approvaldelegations_from; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_approvaldelegations_from ON public.tblapprovaldelegations USING btree (fromuserid, isactive, fromdate, todate);


--
-- Name: ix_approvaldelegations_to; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_approvaldelegations_to ON public.tblapprovaldelegations USING btree (touserid, isactive, fromdate, todate);


--
-- Name: ix_approvallevels_workflow; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_approvallevels_workflow ON public.tblapprovallevels USING btree (workflowid, isactive);


--
-- Name: ix_approvalrequests_due; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_approvalrequests_due ON public.tblapprovalrequests USING btree (duedate) WHERE ((status)::text = ANY ((ARRAY['PENDING'::character varying, 'IN_REVIEW'::character varying])::text[]));


--
-- Name: ix_approvalrequests_requester; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_approvalrequests_requester ON public.tblapprovalrequests USING btree (requesterid, status);


--
-- Name: ix_approvalrequests_source; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_approvalrequests_source ON public.tblapprovalrequests USING btree (sourcetype, sourceid);


--
-- Name: ix_approvalrequests_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_approvalrequests_status ON public.tblapprovalrequests USING btree (status, currentlevel);


--
-- Name: ix_approvalworkflows_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_approvalworkflows_type ON public.tblapprovalworkflows USING btree (sourcetype) WHERE (isactive = true);


--
-- Name: ix_audithist_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_audithist_date ON public.tblaudi USING btree (actiondate);


--
-- Name: ix_audithist_table_record; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_audithist_table_record ON public.tblaudi USING btree (tablename, recordid);


--
-- Name: ix_audithist_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_audithist_user ON public.tblaudi USING btree (userid);


--
-- Name: ix_banktransactions_account; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_banktransactions_account ON public.tblbanktransactions USING btree (bankaccountid);


--
-- Name: ix_banktransactions_approval; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_banktransactions_approval ON public.tblbanktransactions USING btree (approvalrequestid) WHERE (approvalrequestid IS NOT NULL);


--
-- Name: ix_banktransactions_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_banktransactions_date ON public.tblbanktransactions USING btree (txndate);


--
-- Name: ix_bondheader_approval; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_bondheader_approval ON public.tblbondheader USING btree (approvalrequestid) WHERE (approvalrequestid IS NOT NULL);


--
-- Name: ix_cashpayments_approval; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_cashpayments_approval ON public.tblcashpayments USING btree (approvalrequestid) WHERE (approvalrequestid IS NOT NULL);


--
-- Name: ix_cashpayments_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_cashpayments_date ON public.tblcashpayments USING btree (paymentdate);


--
-- Name: ix_cashreceipts_approval; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_cashreceipts_approval ON public.tblcashreceipts USING btree (approvalrequestid) WHERE (approvalrequestid IS NOT NULL);


--
-- Name: ix_cashreceipts_cashbox; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_cashreceipts_cashbox ON public.tblcashreceipts USING btree (cashboxid);


--
-- Name: ix_cashreceipts_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_cashreceipts_date ON public.tblcashreceipts USING btree (receiptdate);


--
-- Name: ix_documentattachments_source; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_documentattachments_source ON public.tbldocumentattachments USING btree (source_type, source_id);


--
-- Name: ix_exchangerate_curr_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_exchangerate_curr_date ON public.tblexchangeratehistory USING btree (currid, effectivedate DESC);


--
-- Name: ix_journalheader_approval; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_journalheader_approval ON public.tbljournalheader USING btree (approvalrequestid) WHERE (approvalrequestid IS NOT NULL);


--
-- Name: ix_notifications_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_notifications_user ON public.tblnotifications USING btree (userid, isread);


--
-- Name: ix_taxtransactions_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_taxtransactions_date ON public.tbltaxtransactions USING btree (txndate);


--
-- Name: ix_taxtransactions_source; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_taxtransactions_source ON public.tbltaxtransactions USING btree (source_type, source_id);


--
-- Name: ix_tblbanktransactions_bu; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblbanktransactions_bu ON public.tblbanktransactions USING btree (businessunitcode);


--
-- Name: ix_tblbanktransactions_dept; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblbanktransactions_dept ON public.tblbanktransactions USING btree (departmentcode);


--
-- Name: ix_tblbanktransactions_pc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblbanktransactions_pc ON public.tblbanktransactions USING btree (profitcentercode);


--
-- Name: ix_tblbanktransactions_proj; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblbanktransactions_proj ON public.tblbanktransactions USING btree (projectcode);


--
-- Name: ix_tblbanktransactions_seg; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblbanktransactions_seg ON public.tblbanktransactions USING btree (segmentcode);


--
-- Name: ix_tblbondheader_bu; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblbondheader_bu ON public.tblbondheader USING btree (businessunitcode);


--
-- Name: ix_tblbondheader_dept; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblbondheader_dept ON public.tblbondheader USING btree (departmentcode);


--
-- Name: ix_tblbondheader_pc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblbondheader_pc ON public.tblbondheader USING btree (profitcentercode);


--
-- Name: ix_tblbondheader_proj; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblbondheader_proj ON public.tblbondheader USING btree (projectcode);


--
-- Name: ix_tblbondheader_seg; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblbondheader_seg ON public.tblbondheader USING btree (segmentcode);


--
-- Name: ix_tblbudgets_bu; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblbudgets_bu ON public.tblbudgets USING btree (businessunitcode);


--
-- Name: ix_tblbudgets_dept; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblbudgets_dept ON public.tblbudgets USING btree (departmentcode);


--
-- Name: ix_tblbudgets_pc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblbudgets_pc ON public.tblbudgets USING btree (profitcentercode);


--
-- Name: ix_tblbudgets_proj; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblbudgets_proj ON public.tblbudgets USING btree (projectcode);


--
-- Name: ix_tblbudgets_seg; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblbudgets_seg ON public.tblbudgets USING btree (segmentcode);


--
-- Name: ix_tblcashpayments_bu; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblcashpayments_bu ON public.tblcashpayments USING btree (businessunitcode);


--
-- Name: ix_tblcashpayments_dept; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblcashpayments_dept ON public.tblcashpayments USING btree (departmentcode);


--
-- Name: ix_tblcashpayments_pc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblcashpayments_pc ON public.tblcashpayments USING btree (profitcentercode);


--
-- Name: ix_tblcashpayments_proj; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblcashpayments_proj ON public.tblcashpayments USING btree (projectcode);


--
-- Name: ix_tblcashpayments_seg; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblcashpayments_seg ON public.tblcashpayments USING btree (segmentcode);


--
-- Name: ix_tblcashreceipts_bu; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblcashreceipts_bu ON public.tblcashreceipts USING btree (businessunitcode);


--
-- Name: ix_tblcashreceipts_dept; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblcashreceipts_dept ON public.tblcashreceipts USING btree (departmentcode);


--
-- Name: ix_tblcashreceipts_pc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblcashreceipts_pc ON public.tblcashreceipts USING btree (profitcentercode);


--
-- Name: ix_tblcashreceipts_proj; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblcashreceipts_proj ON public.tblcashreceipts USING btree (projectcode);


--
-- Name: ix_tblcashreceipts_seg; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tblcashreceipts_seg ON public.tblcashreceipts USING btree (segmentcode);


--
-- Name: ix_tbldim_bu_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbldim_bu_active ON public.tbldim_businessunits USING btree (isactive);


--
-- Name: ix_tbldim_bu_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbldim_bu_parent ON public.tbldim_businessunits USING btree (parentbusinessunitcode);


--
-- Name: ix_tbldim_departments_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbldim_departments_active ON public.tbldim_departments USING btree (isactive);


--
-- Name: ix_tbldim_departments_manager; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbldim_departments_manager ON public.tbldim_departments USING btree (managerusercode);


--
-- Name: ix_tbldim_departments_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbldim_departments_parent ON public.tbldim_departments USING btree (parentdepartmentcode);


--
-- Name: ix_tbldim_hier_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbldim_hier_active ON public.tbldim_hierarchies USING btree (isactive);


--
-- Name: ix_tbldim_hier_child; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbldim_hier_child ON public.tbldim_hierarchies USING btree (childdimtype, childdimcode);


--
-- Name: ix_tbldim_hier_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbldim_hier_parent ON public.tbldim_hierarchies USING btree (parentdimtype, parentdimcode);


--
-- Name: ix_tbldim_hier_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbldim_hier_type ON public.tbldim_hierarchies USING btree (hierarchytype);


--
-- Name: ix_tbldim_pc_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbldim_pc_active ON public.tbldim_profitcenters USING btree (isactive);


--
-- Name: ix_tbldim_pc_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbldim_pc_parent ON public.tbldim_profitcenters USING btree (parentprofitcentercode);


--
-- Name: ix_tbldim_projects_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbldim_projects_active ON public.tbldim_projects USING btree (isactive);


--
-- Name: ix_tbldim_projects_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbldim_projects_parent ON public.tbldim_projects USING btree (parentprojectcode);


--
-- Name: ix_tbldim_projects_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbldim_projects_status ON public.tbldim_projects USING btree (projectstatus);


--
-- Name: ix_tbldim_segments_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbldim_segments_active ON public.tbldim_segments USING btree (isactive);


--
-- Name: ix_tbldim_segments_parent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbldim_segments_parent ON public.tbldim_segments USING btree (parentsegmentcode);


--
-- Name: ix_tbldim_segments_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbldim_segments_type ON public.tbldim_segments USING btree (segmenttype);


--
-- Name: ix_tbljournalbody_bu; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbljournalbody_bu ON public.tbljournalbody USING btree (businessunitcode);


--
-- Name: ix_tbljournalbody_dept; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbljournalbody_dept ON public.tbljournalbody USING btree (departmentcode);


--
-- Name: ix_tbljournalbody_pc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbljournalbody_pc ON public.tbljournalbody USING btree (profitcentercode);


--
-- Name: ix_tbljournalbody_proj; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbljournalbody_proj ON public.tbljournalbody USING btree (projectcode);


--
-- Name: ix_tbljournalbody_seg; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbljournalbody_seg ON public.tbljournalbody USING btree (segmentcode);


--
-- Name: ix_tbljournalheader_bu; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbljournalheader_bu ON public.tbljournalheader USING btree (businessunitcode);


--
-- Name: ix_tbljournalheader_dept; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbljournalheader_dept ON public.tbljournalheader USING btree (departmentcode);


--
-- Name: ix_tbljournalheader_pc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbljournalheader_pc ON public.tbljournalheader USING btree (profitcentercode);


--
-- Name: ix_tbljournalheader_proj; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbljournalheader_proj ON public.tbljournalheader USING btree (projectcode);


--
-- Name: ix_tbljournalheader_seg; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tbljournalheader_seg ON public.tbljournalheader USING btree (segmentcode);


--
-- Name: tblbanktransactions trg_banktxn_auto_approve; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_banktxn_auto_approve BEFORE INSERT ON public.tblbanktransactions FOR EACH ROW EXECUTE FUNCTION public.fn_auto_submit_for_approval('BANK_TXN');


--
-- Name: tblbondheader trg_bond_auto_approve; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_bond_auto_approve BEFORE INSERT ON public.tblbondheader FOR EACH ROW EXECUTE FUNCTION public.fn_auto_submit_for_approval('BOND');


--
-- Name: tblbondheader trg_bond_block_unapproved_post; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_bond_block_unapproved_post BEFORE UPDATE OF isposted ON public.tblbondheader FOR EACH ROW EXECUTE FUNCTION public.fn_block_unapproved_posting('BOND');


--
-- Name: tblcashpayments trg_cashpayment_auto_approve; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_cashpayment_auto_approve BEFORE INSERT ON public.tblcashpayments FOR EACH ROW EXECUTE FUNCTION public.fn_auto_submit_for_approval('CASH_PAYMENT');


--
-- Name: tblcashreceipts trg_cashreceipt_auto_approve; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_cashreceipt_auto_approve BEFORE INSERT ON public.tblcashreceipts FOR EACH ROW EXECUTE FUNCTION public.fn_auto_submit_for_approval('CASH_RECEIPT');


--
-- Name: tblbondheader trg_dim_bondheader_validate; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_dim_bondheader_validate BEFORE INSERT OR UPDATE ON public.tblbondheader FOR EACH ROW EXECUTE FUNCTION public.fn_dim_validateondimcolumns();


--
-- Name: tbljournalbody trg_dim_journalbody_updateprojectactual; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_dim_journalbody_updateprojectactual AFTER INSERT ON public.tbljournalbody FOR EACH ROW EXECUTE FUNCTION public.fn_dim_updateprojectactual();


--
-- Name: tbljournalbody trg_dim_journalbody_validate; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_dim_journalbody_validate BEFORE INSERT OR UPDATE ON public.tbljournalbody FOR EACH ROW EXECUTE FUNCTION public.fn_dim_validateondimcolumns();


--
-- Name: tblapprovalactions trg_g10_approval_action_audit; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_g10_approval_action_audit AFTER INSERT ON public.tblapprovalactions FOR EACH ROW WHEN ((new.actionid IS NOT NULL)) EXECUTE FUNCTION public.fn_g10_approval_action_audit_fn();


--
-- Name: tblapprovalactions trg_g10_approval_request_status_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_g10_approval_request_status_update AFTER INSERT ON public.tblapprovalactions FOR EACH ROW WHEN ((new.requestid IS NOT NULL)) EXECUTE FUNCTION public.fn_g10_approval_request_status_update_fn();


--
-- Name: tbljournalheader trg_journal_auto_approve; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_journal_auto_approve BEFORE INSERT ON public.tbljournalheader FOR EACH ROW EXECUTE FUNCTION public.fn_auto_submit_for_approval('JOURNAL');


--
-- Name: tbljournalheader trg_journal_block_unapproved_post; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_journal_block_unapproved_post BEFORE UPDATE OF isposted ON public.tbljournalheader FOR EACH ROW EXECUTE FUNCTION public.fn_block_unapproved_posting('JOURNAL');


--
-- Name: tblstoreproducts trg_storeproducts_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_storeproducts_update BEFORE INSERT OR UPDATE ON public.tblstoreproducts FOR EACH ROW EXECUTE FUNCTION public.trg_fn_storeproducts_update();


--
-- Name: tblusers trg_users_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_users_update BEFORE UPDATE ON public.tblusers FOR EACH ROW EXECUTE FUNCTION public.trg_fn_users_update();


--
-- Name: tblaccounts fk_accounts_parent; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblaccounts
    ADD CONSTRAINT fk_accounts_parent FOREIGN KEY (parentaccountcode) REFERENCES public.tblaccounts(accountcode);


--
-- Name: tblproductbatches fk_batches_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblproductbatches
    ADD CONSTRAINT fk_batches_product FOREIGN KEY (productcode) REFERENCES public.tblproducts(productcode);


--
-- Name: tblbondbody fk_bondbody_account; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbondbody
    ADD CONSTRAINT fk_bondbody_account FOREIGN KEY (accountcode) REFERENCES public.tblaccounts(accountcode);


--
-- Name: tblbondbody fk_bondbody_header; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbondbody
    ADD CONSTRAINT fk_bondbody_header FOREIGN KEY (bondcode) REFERENCES public.tblbondheader(bondcode) ON DELETE CASCADE;


--
-- Name: tblcategories fk_categories_parent; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcategories
    ADD CONSTRAINT fk_categories_parent FOREIGN KEY (parentcategorycode) REFERENCES public.tblcategories(categorycode);


--
-- Name: tblcustomercontacts fk_customercontacts_customer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcustomercontacts
    ADD CONSTRAINT fk_customercontacts_customer FOREIGN KEY (customercode) REFERENCES public.tblcustomers(customercode) ON DELETE CASCADE;


--
-- Name: tblcustomers fk_customers_branch; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcustomers
    ADD CONSTRAINT fk_customers_branch FOREIGN KEY (branchcode) REFERENCES public.tblbranches(branchcode);


--
-- Name: tblcustomers fk_customers_paymentterm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcustomers
    ADD CONSTRAINT fk_customers_paymentterm FOREIGN KEY (paymenttermcode) REFERENCES public.tblpaymentterms(paymenttermcode);


--
-- Name: tblcustomers fk_customers_pricelist; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcustomers
    ADD CONSTRAINT fk_customers_pricelist FOREIGN KEY (pricelistcode) REFERENCES public.tblpricelists(pricelistcode);


--
-- Name: tblproductimages fk_images_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblproductimages
    ADD CONSTRAINT fk_images_product FOREIGN KEY (productcode) REFERENCES public.tblproducts(productcode) ON DELETE CASCADE;


--
-- Name: tbljournalbody fk_journalbody_account; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbljournalbody
    ADD CONSTRAINT fk_journalbody_account FOREIGN KEY (accountcode) REFERENCES public.tblaccounts(accountcode);


--
-- Name: tbljournalbody fk_journalbody_header; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbljournalbody
    ADD CONSTRAINT fk_journalbody_header FOREIGN KEY (journalcode) REFERENCES public.tbljournalheader(journalcode) ON DELETE CASCADE;


--
-- Name: tblproductmovement fk_movement_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblproductmovement
    ADD CONSTRAINT fk_movement_product FOREIGN KEY (productcode) REFERENCES public.tblproducts(productcode);


--
-- Name: tblproductmovement fk_movement_store; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblproductmovement
    ADD CONSTRAINT fk_movement_store FOREIGN KEY (storecode) REFERENCES public.tblstores(storecode);


--
-- Name: tbloperationbody fk_opbody_batch; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbloperationbody
    ADD CONSTRAINT fk_opbody_batch FOREIGN KEY (batchid) REFERENCES public.tblproductbatches(batchid);


--
-- Name: tbloperationbody fk_opbody_header; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbloperationbody
    ADD CONSTRAINT fk_opbody_header FOREIGN KEY (operationcode) REFERENCES public.tbloperationheader(operationcode) ON DELETE CASCADE;


--
-- Name: tbloperationbody fk_opbody_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbloperationbody
    ADD CONSTRAINT fk_opbody_product FOREIGN KEY (productcode) REFERENCES public.tblproducts(productcode);


--
-- Name: tbloperationbody fk_opbody_unit; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbloperationbody
    ADD CONSTRAINT fk_opbody_unit FOREIGN KEY (unitcode) REFERENCES public.tblunits(unitcode);


--
-- Name: tbloperationheader fk_opheader_branch; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbloperationheader
    ADD CONSTRAINT fk_opheader_branch FOREIGN KEY (branchcode) REFERENCES public.tblbranches(branchcode);


--
-- Name: tbloperationheader fk_opheader_currency; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbloperationheader
    ADD CONSTRAINT fk_opheader_currency FOREIGN KEY (currencycode) REFERENCES public.tblcurrencies(currencycode);


--
-- Name: tbloperationheader fk_opheader_customer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbloperationheader
    ADD CONSTRAINT fk_opheader_customer FOREIGN KEY (customercode) REFERENCES public.tblcustomers(customercode);


--
-- Name: tbloperationheader fk_opheader_paymentmethod; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbloperationheader
    ADD CONSTRAINT fk_opheader_paymentmethod FOREIGN KEY (paymentmethodcode) REFERENCES public.tblpaymentmethods(paymentmethodcode);


--
-- Name: tbloperationheader fk_opheader_store; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbloperationheader
    ADD CONSTRAINT fk_opheader_store FOREIGN KEY (storecode) REFERENCES public.tblstores(storecode);


--
-- Name: tbloperationheader fk_opheader_supplier; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbloperationheader
    ADD CONSTRAINT fk_opheader_supplier FOREIGN KEY (suppliercode) REFERENCES public.tblsuppliers(suppliercode);


--
-- Name: tbloperationtaxes fk_optaxes_header; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbloperationtaxes
    ADD CONSTRAINT fk_optaxes_header FOREIGN KEY (operationcode) REFERENCES public.tbloperationheader(operationcode) ON DELETE CASCADE;


--
-- Name: tblproductpricing fk_pricing_pricelist; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblproductpricing
    ADD CONSTRAINT fk_pricing_pricelist FOREIGN KEY (pricelistcode) REFERENCES public.tblpricelists(pricelistcode);


--
-- Name: tblproductpricing fk_pricing_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblproductpricing
    ADD CONSTRAINT fk_pricing_product FOREIGN KEY (productcode) REFERENCES public.tblproducts(productcode);


--
-- Name: tblproductpricing fk_pricing_unit; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblproductpricing
    ADD CONSTRAINT fk_pricing_unit FOREIGN KEY (unitcode) REFERENCES public.tblunits(unitcode);


--
-- Name: tblprivileges fk_privileges_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblprivileges
    ADD CONSTRAINT fk_privileges_user FOREIGN KEY (usercode) REFERENCES public.tblusers(usercode);


--
-- Name: tblprivileges fk_privileges_window; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblprivileges
    ADD CONSTRAINT fk_privileges_window FOREIGN KEY (windowid) REFERENCES public.tblwindows(windowid);


--
-- Name: tblproducts fk_products_category; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblproducts
    ADD CONSTRAINT fk_products_category FOREIGN KEY (categorycode) REFERENCES public.tblcategories(categorycode);


--
-- Name: tblproducts fk_products_unit; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblproducts
    ADD CONSTRAINT fk_products_unit FOREIGN KEY (defaultunitcode) REFERENCES public.tblunits(unitcode);


--
-- Name: tblsessions fk_sessions_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblsessions
    ADD CONSTRAINT fk_sessions_user FOREIGN KEY (usercode) REFERENCES public.tblusers(usercode);


--
-- Name: tblstoreproducts fk_storeproducts_batch; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblstoreproducts
    ADD CONSTRAINT fk_storeproducts_batch FOREIGN KEY (batchid) REFERENCES public.tblproductbatches(batchid);


--
-- Name: tblstoreproducts fk_storeproducts_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblstoreproducts
    ADD CONSTRAINT fk_storeproducts_product FOREIGN KEY (productcode) REFERENCES public.tblproducts(productcode);


--
-- Name: tblstoreproducts fk_storeproducts_store; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblstoreproducts
    ADD CONSTRAINT fk_storeproducts_store FOREIGN KEY (storecode) REFERENCES public.tblstores(storecode);


--
-- Name: tblstores fk_stores_branch; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblstores
    ADD CONSTRAINT fk_stores_branch FOREIGN KEY (branchcode) REFERENCES public.tblbranches(branchcode);


--
-- Name: tblsuppliercontacts fk_suppliercontacts_supplier; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblsuppliercontacts
    ADD CONSTRAINT fk_suppliercontacts_supplier FOREIGN KEY (suppliercode) REFERENCES public.tblsuppliers(suppliercode) ON DELETE CASCADE;


--
-- Name: tblsuppliers fk_suppliers_branch; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblsuppliers
    ADD CONSTRAINT fk_suppliers_branch FOREIGN KEY (branchcode) REFERENCES public.tblbranches(branchcode);


--
-- Name: tblsuppliers fk_suppliers_paymentterm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblsuppliers
    ADD CONSTRAINT fk_suppliers_paymentterm FOREIGN KEY (paymenttermcode) REFERENCES public.tblpaymentterms(paymenttermcode);


--
-- Name: tblwindows fk_tblwindows_parent; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblwindows
    ADD CONSTRAINT fk_tblwindows_parent FOREIGN KEY (parentwindowid) REFERENCES public.tblwindows(windowid);


--
-- Name: tbluserroleassignments fk_userrole_role; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbluserroleassignments
    ADD CONSTRAINT fk_userrole_role FOREIGN KEY (roleid) REFERENCES public.tbluserroles(roleid);


--
-- Name: tbluserroleassignments fk_userrole_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbluserroleassignments
    ADD CONSTRAINT fk_userrole_user FOREIGN KEY (usercode) REFERENCES public.tblusers(usercode);


--
-- Name: tblapprovalactions tblapprovalactions_approverid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovalactions
    ADD CONSTRAINT tblapprovalactions_approverid_fkey FOREIGN KEY (approverid) REFERENCES public.tblusers(usercode);


--
-- Name: tblapprovalactions tblapprovalactions_delegatedto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovalactions
    ADD CONSTRAINT tblapprovalactions_delegatedto_fkey FOREIGN KEY (delegatedto) REFERENCES public.tblusers(usercode);


--
-- Name: tblapprovalactions tblapprovalactions_levelid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovalactions
    ADD CONSTRAINT tblapprovalactions_levelid_fkey FOREIGN KEY (levelid) REFERENCES public.tblapprovallevels(levelid);


--
-- Name: tblapprovalactions tblapprovalactions_requestid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovalactions
    ADD CONSTRAINT tblapprovalactions_requestid_fkey FOREIGN KEY (requestid) REFERENCES public.tblapprovalrequests(requestid) ON DELETE CASCADE;


--
-- Name: tblapprovalaudit tblapprovalaudit_performedby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovalaudit
    ADD CONSTRAINT tblapprovalaudit_performedby_fkey FOREIGN KEY (performedby) REFERENCES public.tblusers(usercode);


--
-- Name: tblapprovaldelegations tblapprovaldelegations_fromuserid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovaldelegations
    ADD CONSTRAINT tblapprovaldelegations_fromuserid_fkey FOREIGN KEY (fromuserid) REFERENCES public.tblusers(usercode);


--
-- Name: tblapprovaldelegations tblapprovaldelegations_touserid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovaldelegations
    ADD CONSTRAINT tblapprovaldelegations_touserid_fkey FOREIGN KEY (touserid) REFERENCES public.tblusers(usercode);


--
-- Name: tblapprovaldelegations tblapprovaldelegations_workflowid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovaldelegations
    ADD CONSTRAINT tblapprovaldelegations_workflowid_fkey FOREIGN KEY (workflowid) REFERENCES public.tblapprovalworkflows(workflowid);


--
-- Name: tblapprovallevels tblapprovallevels_workflowid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovallevels
    ADD CONSTRAINT tblapprovallevels_workflowid_fkey FOREIGN KEY (workflowid) REFERENCES public.tblapprovalworkflows(workflowid) ON DELETE CASCADE;


--
-- Name: tblapprovalrequests tblapprovalrequests_completedby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovalrequests
    ADD CONSTRAINT tblapprovalrequests_completedby_fkey FOREIGN KEY (completedby) REFERENCES public.tblusers(usercode);


--
-- Name: tblapprovalrequests tblapprovalrequests_requesterid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovalrequests
    ADD CONSTRAINT tblapprovalrequests_requesterid_fkey FOREIGN KEY (requesterid) REFERENCES public.tblusers(usercode);


--
-- Name: tblapprovalrequests tblapprovalrequests_workflowid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblapprovalrequests
    ADD CONSTRAINT tblapprovalrequests_workflowid_fkey FOREIGN KEY (workflowid) REFERENCES public.tblapprovalworkflows(workflowid);


--
-- Name: tblbankaccounts tblbankaccounts_bankid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbankaccounts
    ADD CONSTRAINT tblbankaccounts_bankid_fkey FOREIGN KEY (bankid) REFERENCES public.tblbanks(bankcode);


--
-- Name: tblbankaccounts tblbankaccounts_currid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbankaccounts
    ADD CONSTRAINT tblbankaccounts_currid_fkey FOREIGN KEY (currid) REFERENCES public.tblcurrencies(currencycode);


--
-- Name: tblbankreconciliations tblbankreconciliations_bankaccountid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbankreconciliations
    ADD CONSTRAINT tblbankreconciliations_bankaccountid_fkey FOREIGN KEY (bankaccountid) REFERENCES public.tblbankaccounts(bankaccountid);


--
-- Name: tblbankstatementlines tblbankstatementlines_matchedtxnid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbankstatementlines
    ADD CONSTRAINT tblbankstatementlines_matchedtxnid_fkey FOREIGN KEY (matchedtxnid) REFERENCES public.tblbanktransactions(banktxnid);


--
-- Name: tblbankstatementlines tblbankstatementlines_statementid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbankstatementlines
    ADD CONSTRAINT tblbankstatementlines_statementid_fkey FOREIGN KEY (statementid) REFERENCES public.tblbankstatements(statementid) ON DELETE CASCADE;


--
-- Name: tblbankstatements tblbankstatements_bankaccountid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbankstatements
    ADD CONSTRAINT tblbankstatements_bankaccountid_fkey FOREIGN KEY (bankaccountid) REFERENCES public.tblbankaccounts(bankaccountid);


--
-- Name: tblbanktransactions tblbanktransactions_bankaccountid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbanktransactions
    ADD CONSTRAINT tblbanktransactions_bankaccountid_fkey FOREIGN KEY (bankaccountid) REFERENCES public.tblbankaccounts(bankaccountid);


--
-- Name: tblbanktransactions tblbanktransactions_businessunitcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbanktransactions
    ADD CONSTRAINT tblbanktransactions_businessunitcode_fkey FOREIGN KEY (businessunitcode) REFERENCES public.tbldim_businessunits(businessunitcode) ON DELETE SET NULL;


--
-- Name: tblbanktransactions tblbanktransactions_counteraccountid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbanktransactions
    ADD CONSTRAINT tblbanktransactions_counteraccountid_fkey FOREIGN KEY (counteraccountid) REFERENCES public.tblbankaccounts(bankaccountid);


--
-- Name: tblbanktransactions tblbanktransactions_currid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbanktransactions
    ADD CONSTRAINT tblbanktransactions_currid_fkey FOREIGN KEY (currid) REFERENCES public.tblcurrencies(currencycode);


--
-- Name: tblbanktransactions tblbanktransactions_departmentcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbanktransactions
    ADD CONSTRAINT tblbanktransactions_departmentcode_fkey FOREIGN KEY (departmentcode) REFERENCES public.tbldim_departments(departmentcode) ON DELETE SET NULL;


--
-- Name: tblbanktransactions tblbanktransactions_profitcentercode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbanktransactions
    ADD CONSTRAINT tblbanktransactions_profitcentercode_fkey FOREIGN KEY (profitcentercode) REFERENCES public.tbldim_profitcenters(profitcentercode) ON DELETE SET NULL;


--
-- Name: tblbanktransactions tblbanktransactions_projectcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbanktransactions
    ADD CONSTRAINT tblbanktransactions_projectcode_fkey FOREIGN KEY (projectcode) REFERENCES public.tbldim_projects(projectcode) ON DELETE SET NULL;


--
-- Name: tblbanktransactions tblbanktransactions_segmentcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbanktransactions
    ADD CONSTRAINT tblbanktransactions_segmentcode_fkey FOREIGN KEY (segmentcode) REFERENCES public.tbldim_segments(segmentcode) ON DELETE SET NULL;


--
-- Name: tblbondheader tblbondheader_businessunitcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbondheader
    ADD CONSTRAINT tblbondheader_businessunitcode_fkey FOREIGN KEY (businessunitcode) REFERENCES public.tbldim_businessunits(businessunitcode) ON DELETE SET NULL;


--
-- Name: tblbondheader tblbondheader_departmentcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbondheader
    ADD CONSTRAINT tblbondheader_departmentcode_fkey FOREIGN KEY (departmentcode) REFERENCES public.tbldim_departments(departmentcode) ON DELETE SET NULL;


--
-- Name: tblbondheader tblbondheader_profitcentercode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbondheader
    ADD CONSTRAINT tblbondheader_profitcentercode_fkey FOREIGN KEY (profitcentercode) REFERENCES public.tbldim_profitcenters(profitcentercode) ON DELETE SET NULL;


--
-- Name: tblbondheader tblbondheader_projectcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbondheader
    ADD CONSTRAINT tblbondheader_projectcode_fkey FOREIGN KEY (projectcode) REFERENCES public.tbldim_projects(projectcode) ON DELETE SET NULL;


--
-- Name: tblbondheader tblbondheader_segmentcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbondheader
    ADD CONSTRAINT tblbondheader_segmentcode_fkey FOREIGN KEY (segmentcode) REFERENCES public.tbldim_segments(segmentcode) ON DELETE SET NULL;


--
-- Name: tblbudgets tblbudgets_accountid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbudgets
    ADD CONSTRAINT tblbudgets_accountid_fkey FOREIGN KEY (accountid) REFERENCES public.tblaccounts(accountcode);


--
-- Name: tblbudgets tblbudgets_branchid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbudgets
    ADD CONSTRAINT tblbudgets_branchid_fkey FOREIGN KEY (branchid) REFERENCES public.tblbranches(branchcode);


--
-- Name: tblbudgets tblbudgets_businessunitcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbudgets
    ADD CONSTRAINT tblbudgets_businessunitcode_fkey FOREIGN KEY (businessunitcode) REFERENCES public.tbldim_businessunits(businessunitcode) ON DELETE SET NULL;


--
-- Name: tblbudgets tblbudgets_costcenterid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbudgets
    ADD CONSTRAINT tblbudgets_costcenterid_fkey FOREIGN KEY (costcenterid) REFERENCES public.tblcostcenters(costcentercode);


--
-- Name: tblbudgets tblbudgets_departmentcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbudgets
    ADD CONSTRAINT tblbudgets_departmentcode_fkey FOREIGN KEY (departmentcode) REFERENCES public.tbldim_departments(departmentcode) ON DELETE SET NULL;


--
-- Name: tblbudgets tblbudgets_periodid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbudgets
    ADD CONSTRAINT tblbudgets_periodid_fkey FOREIGN KEY (periodid) REFERENCES public.tblbudgetperiods(periodid);


--
-- Name: tblbudgets tblbudgets_profitcentercode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbudgets
    ADD CONSTRAINT tblbudgets_profitcentercode_fkey FOREIGN KEY (profitcentercode) REFERENCES public.tbldim_profitcenters(profitcentercode) ON DELETE SET NULL;


--
-- Name: tblbudgets tblbudgets_projectcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbudgets
    ADD CONSTRAINT tblbudgets_projectcode_fkey FOREIGN KEY (projectcode) REFERENCES public.tbldim_projects(projectcode) ON DELETE SET NULL;


--
-- Name: tblbudgets tblbudgets_segmentcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblbudgets
    ADD CONSTRAINT tblbudgets_segmentcode_fkey FOREIGN KEY (segmentcode) REFERENCES public.tbldim_segments(segmentcode) ON DELETE SET NULL;


--
-- Name: tblcashboxes tblcashboxes_branchid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashboxes
    ADD CONSTRAINT tblcashboxes_branchid_fkey FOREIGN KEY (branchid) REFERENCES public.tblbranches(branchcode);


--
-- Name: tblcashboxes tblcashboxes_currid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashboxes
    ADD CONSTRAINT tblcashboxes_currid_fkey FOREIGN KEY (currid) REFERENCES public.tblcurrencies(currencycode);


--
-- Name: tblcashpayments tblcashpayments_businessunitcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashpayments
    ADD CONSTRAINT tblcashpayments_businessunitcode_fkey FOREIGN KEY (businessunitcode) REFERENCES public.tbldim_businessunits(businessunitcode) ON DELETE SET NULL;


--
-- Name: tblcashpayments tblcashpayments_cashboxid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashpayments
    ADD CONSTRAINT tblcashpayments_cashboxid_fkey FOREIGN KEY (cashboxid) REFERENCES public.tblcashboxes(cashboxid);


--
-- Name: tblcashpayments tblcashpayments_currid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashpayments
    ADD CONSTRAINT tblcashpayments_currid_fkey FOREIGN KEY (currid) REFERENCES public.tblcurrencies(currencycode);


--
-- Name: tblcashpayments tblcashpayments_customerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashpayments
    ADD CONSTRAINT tblcashpayments_customerid_fkey FOREIGN KEY (customerid) REFERENCES public.tblcustomers(customercode);


--
-- Name: tblcashpayments tblcashpayments_departmentcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashpayments
    ADD CONSTRAINT tblcashpayments_departmentcode_fkey FOREIGN KEY (departmentcode) REFERENCES public.tbldim_departments(departmentcode) ON DELETE SET NULL;


--
-- Name: tblcashpayments tblcashpayments_paymentmethodid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashpayments
    ADD CONSTRAINT tblcashpayments_paymentmethodid_fkey FOREIGN KEY (paymentmethodid) REFERENCES public.tblpaymentmethods(paymentmethodcode);


--
-- Name: tblcashpayments tblcashpayments_profitcentercode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashpayments
    ADD CONSTRAINT tblcashpayments_profitcentercode_fkey FOREIGN KEY (profitcentercode) REFERENCES public.tbldim_profitcenters(profitcentercode) ON DELETE SET NULL;


--
-- Name: tblcashpayments tblcashpayments_projectcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashpayments
    ADD CONSTRAINT tblcashpayments_projectcode_fkey FOREIGN KEY (projectcode) REFERENCES public.tbldim_projects(projectcode) ON DELETE SET NULL;


--
-- Name: tblcashpayments tblcashpayments_segmentcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashpayments
    ADD CONSTRAINT tblcashpayments_segmentcode_fkey FOREIGN KEY (segmentcode) REFERENCES public.tbldim_segments(segmentcode) ON DELETE SET NULL;


--
-- Name: tblcashpayments tblcashpayments_supplierid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashpayments
    ADD CONSTRAINT tblcashpayments_supplierid_fkey FOREIGN KEY (supplierid) REFERENCES public.tblsuppliers(suppliercode);


--
-- Name: tblcashreceipts tblcashreceipts_businessunitcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashreceipts
    ADD CONSTRAINT tblcashreceipts_businessunitcode_fkey FOREIGN KEY (businessunitcode) REFERENCES public.tbldim_businessunits(businessunitcode) ON DELETE SET NULL;


--
-- Name: tblcashreceipts tblcashreceipts_cashboxid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashreceipts
    ADD CONSTRAINT tblcashreceipts_cashboxid_fkey FOREIGN KEY (cashboxid) REFERENCES public.tblcashboxes(cashboxid);


--
-- Name: tblcashreceipts tblcashreceipts_currid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashreceipts
    ADD CONSTRAINT tblcashreceipts_currid_fkey FOREIGN KEY (currid) REFERENCES public.tblcurrencies(currencycode);


--
-- Name: tblcashreceipts tblcashreceipts_customerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashreceipts
    ADD CONSTRAINT tblcashreceipts_customerid_fkey FOREIGN KEY (customerid) REFERENCES public.tblcustomers(customercode);


--
-- Name: tblcashreceipts tblcashreceipts_departmentcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashreceipts
    ADD CONSTRAINT tblcashreceipts_departmentcode_fkey FOREIGN KEY (departmentcode) REFERENCES public.tbldim_departments(departmentcode) ON DELETE SET NULL;


--
-- Name: tblcashreceipts tblcashreceipts_paymentmethodid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashreceipts
    ADD CONSTRAINT tblcashreceipts_paymentmethodid_fkey FOREIGN KEY (paymentmethodid) REFERENCES public.tblpaymentmethods(paymentmethodcode);


--
-- Name: tblcashreceipts tblcashreceipts_profitcentercode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashreceipts
    ADD CONSTRAINT tblcashreceipts_profitcentercode_fkey FOREIGN KEY (profitcentercode) REFERENCES public.tbldim_profitcenters(profitcentercode) ON DELETE SET NULL;


--
-- Name: tblcashreceipts tblcashreceipts_projectcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashreceipts
    ADD CONSTRAINT tblcashreceipts_projectcode_fkey FOREIGN KEY (projectcode) REFERENCES public.tbldim_projects(projectcode) ON DELETE SET NULL;


--
-- Name: tblcashreceipts tblcashreceipts_segmentcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashreceipts
    ADD CONSTRAINT tblcashreceipts_segmentcode_fkey FOREIGN KEY (segmentcode) REFERENCES public.tbldim_segments(segmentcode) ON DELETE SET NULL;


--
-- Name: tblcashreceipts tblcashreceipts_supplierid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblcashreceipts
    ADD CONSTRAINT tblcashreceipts_supplierid_fkey FOREIGN KEY (supplierid) REFERENCES public.tblsuppliers(suppliercode);


--
-- Name: tbldim_businessunits tbldim_businessunits_adduser_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_businessunits
    ADD CONSTRAINT tbldim_businessunits_adduser_fkey FOREIGN KEY (adduser) REFERENCES public.tblusers(usercode);


--
-- Name: tbldim_businessunits tbldim_businessunits_edituser_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_businessunits
    ADD CONSTRAINT tbldim_businessunits_edituser_fkey FOREIGN KEY (edituser) REFERENCES public.tblusers(usercode);


--
-- Name: tbldim_businessunits tbldim_businessunits_parentbusinessunitcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_businessunits
    ADD CONSTRAINT tbldim_businessunits_parentbusinessunitcode_fkey FOREIGN KEY (parentbusinessunitcode) REFERENCES public.tbldim_businessunits(businessunitcode) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: tbldim_departments tbldim_departments_adduser_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_departments
    ADD CONSTRAINT tbldim_departments_adduser_fkey FOREIGN KEY (adduser) REFERENCES public.tblusers(usercode);


--
-- Name: tbldim_departments tbldim_departments_edituser_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_departments
    ADD CONSTRAINT tbldim_departments_edituser_fkey FOREIGN KEY (edituser) REFERENCES public.tblusers(usercode);


--
-- Name: tbldim_departments tbldim_departments_managerusercode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_departments
    ADD CONSTRAINT tbldim_departments_managerusercode_fkey FOREIGN KEY (managerusercode) REFERENCES public.tblusers(usercode) ON DELETE SET NULL;


--
-- Name: tbldim_departments tbldim_departments_parentdepartmentcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_departments
    ADD CONSTRAINT tbldim_departments_parentdepartmentcode_fkey FOREIGN KEY (parentdepartmentcode) REFERENCES public.tbldim_departments(departmentcode) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: tbldim_hierarchies tbldim_hierarchies_adduser_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_hierarchies
    ADD CONSTRAINT tbldim_hierarchies_adduser_fkey FOREIGN KEY (adduser) REFERENCES public.tblusers(usercode);


--
-- Name: tbldim_hierarchies tbldim_hierarchies_edituser_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_hierarchies
    ADD CONSTRAINT tbldim_hierarchies_edituser_fkey FOREIGN KEY (edituser) REFERENCES public.tblusers(usercode);


--
-- Name: tbldim_profitcenters tbldim_profitcenters_adduser_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_profitcenters
    ADD CONSTRAINT tbldim_profitcenters_adduser_fkey FOREIGN KEY (adduser) REFERENCES public.tblusers(usercode);


--
-- Name: tbldim_profitcenters tbldim_profitcenters_edituser_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_profitcenters
    ADD CONSTRAINT tbldim_profitcenters_edituser_fkey FOREIGN KEY (edituser) REFERENCES public.tblusers(usercode);


--
-- Name: tbldim_profitcenters tbldim_profitcenters_parentprofitcentercode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_profitcenters
    ADD CONSTRAINT tbldim_profitcenters_parentprofitcentercode_fkey FOREIGN KEY (parentprofitcentercode) REFERENCES public.tbldim_profitcenters(profitcentercode) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: tbldim_projects tbldim_projects_adduser_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_projects
    ADD CONSTRAINT tbldim_projects_adduser_fkey FOREIGN KEY (adduser) REFERENCES public.tblusers(usercode);


--
-- Name: tbldim_projects tbldim_projects_edituser_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_projects
    ADD CONSTRAINT tbldim_projects_edituser_fkey FOREIGN KEY (edituser) REFERENCES public.tblusers(usercode);


--
-- Name: tbldim_projects tbldim_projects_parentprojectcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_projects
    ADD CONSTRAINT tbldim_projects_parentprojectcode_fkey FOREIGN KEY (parentprojectcode) REFERENCES public.tbldim_projects(projectcode) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: tbldim_segments tbldim_segments_adduser_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_segments
    ADD CONSTRAINT tbldim_segments_adduser_fkey FOREIGN KEY (adduser) REFERENCES public.tblusers(usercode);


--
-- Name: tbldim_segments tbldim_segments_edituser_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_segments
    ADD CONSTRAINT tbldim_segments_edituser_fkey FOREIGN KEY (edituser) REFERENCES public.tblusers(usercode);


--
-- Name: tbldim_segments tbldim_segments_parentsegmentcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbldim_segments
    ADD CONSTRAINT tbldim_segments_parentsegmentcode_fkey FOREIGN KEY (parentsegmentcode) REFERENCES public.tbldim_segments(segmentcode) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: tblexchangeratehistory tblexchangeratehistory_currid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblexchangeratehistory
    ADD CONSTRAINT tblexchangeratehistory_currid_fkey FOREIGN KEY (currid) REFERENCES public.tblcurrencies(currencycode);


--
-- Name: tblfiscalperiods tblfiscalperiods_fiscalyearid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblfiscalperiods
    ADD CONSTRAINT tblfiscalperiods_fiscalyearid_fkey FOREIGN KEY (fiscalyearid) REFERENCES public.tblfiscalyears(fiscalyearid);


--
-- Name: tbljournalbody tbljournalbody_businessunitcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbljournalbody
    ADD CONSTRAINT tbljournalbody_businessunitcode_fkey FOREIGN KEY (businessunitcode) REFERENCES public.tbldim_businessunits(businessunitcode) ON DELETE SET NULL;


--
-- Name: tbljournalbody tbljournalbody_departmentcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbljournalbody
    ADD CONSTRAINT tbljournalbody_departmentcode_fkey FOREIGN KEY (departmentcode) REFERENCES public.tbldim_departments(departmentcode) ON DELETE SET NULL;


--
-- Name: tbljournalbody tbljournalbody_profitcentercode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbljournalbody
    ADD CONSTRAINT tbljournalbody_profitcentercode_fkey FOREIGN KEY (profitcentercode) REFERENCES public.tbldim_profitcenters(profitcentercode) ON DELETE SET NULL;


--
-- Name: tbljournalbody tbljournalbody_projectcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbljournalbody
    ADD CONSTRAINT tbljournalbody_projectcode_fkey FOREIGN KEY (projectcode) REFERENCES public.tbldim_projects(projectcode) ON DELETE SET NULL;


--
-- Name: tbljournalbody tbljournalbody_segmentcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbljournalbody
    ADD CONSTRAINT tbljournalbody_segmentcode_fkey FOREIGN KEY (segmentcode) REFERENCES public.tbldim_segments(segmentcode) ON DELETE SET NULL;


--
-- Name: tbljournalheader tbljournalheader_businessunitcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbljournalheader
    ADD CONSTRAINT tbljournalheader_businessunitcode_fkey FOREIGN KEY (businessunitcode) REFERENCES public.tbldim_businessunits(businessunitcode) ON DELETE SET NULL;


--
-- Name: tbljournalheader tbljournalheader_departmentcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbljournalheader
    ADD CONSTRAINT tbljournalheader_departmentcode_fkey FOREIGN KEY (departmentcode) REFERENCES public.tbldim_departments(departmentcode) ON DELETE SET NULL;


--
-- Name: tbljournalheader tbljournalheader_profitcentercode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbljournalheader
    ADD CONSTRAINT tbljournalheader_profitcentercode_fkey FOREIGN KEY (profitcentercode) REFERENCES public.tbldim_profitcenters(profitcentercode) ON DELETE SET NULL;


--
-- Name: tbljournalheader tbljournalheader_projectcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbljournalheader
    ADD CONSTRAINT tbljournalheader_projectcode_fkey FOREIGN KEY (projectcode) REFERENCES public.tbldim_projects(projectcode) ON DELETE SET NULL;


--
-- Name: tbljournalheader tbljournalheader_segmentcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbljournalheader
    ADD CONSTRAINT tbljournalheader_segmentcode_fkey FOREIGN KEY (segmentcode) REFERENCES public.tbldim_segments(segmentcode) ON DELETE SET NULL;


--
-- Name: tblnotifications tblnotifications_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tblnotifications
    ADD CONSTRAINT tblnotifications_userid_fkey FOREIGN KEY (userid) REFERENCES public.tblusers(usercode);


--
-- Name: tbltaxtransactions tbltaxtransactions_taxid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbltaxtransactions
    ADD CONSTRAINT tbltaxtransactions_taxid_fkey FOREIGN KEY (taxid) REFERENCES public.tbltaxdefinitions(taxid);


--
-- Name: tblaudi_security p_audi_security_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY p_audi_security_admin ON public.tblaudi_security TO app_admin USING (true) WITH CHECK (true);


--
-- Name: tblaudi_security p_audi_security_auditor; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY p_audi_security_auditor ON public.tblaudi_security FOR SELECT TO app_auditor USING (true);


--
-- Name: tblaudi_security p_audi_security_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY p_audi_security_insert ON public.tblaudi_security FOR INSERT TO app_readwrite WITH CHECK ((event_type = 'APP_INSERT'::text));


--
-- Name: tblaudi pol_audi_admin_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_audi_admin_insert ON public.tblaudi FOR INSERT TO app_admin WITH CHECK (true);


--
-- Name: tblaudi pol_audi_admin_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_audi_admin_select ON public.tblaudi FOR SELECT TO app_admin USING (true);


--
-- Name: tblaudi pol_audi_auditor_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_audi_auditor_select ON public.tblaudi FOR SELECT TO app_auditor USING (true);


--
-- Name: tblauditlogs pol_auditlogs_admin_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_auditlogs_admin_insert ON public.tblauditlogs FOR INSERT TO app_admin WITH CHECK (true);


--
-- Name: tblauditlogs pol_auditlogs_admin_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_auditlogs_admin_select ON public.tblauditlogs FOR SELECT TO app_admin USING (true);


--
-- Name: tblauditlogs pol_auditlogs_auditor_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_auditlogs_auditor_select ON public.tblauditlogs FOR SELECT TO app_auditor USING (true);


--
-- Name: tblbankaccounts pol_bankaccounts_admin_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_bankaccounts_admin_all ON public.tblbankaccounts TO app_admin USING (true) WITH CHECK (true);


--
-- Name: tblbankaccounts pol_bankaccounts_auditor_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_bankaccounts_auditor_select ON public.tblbankaccounts FOR SELECT TO app_auditor USING (true);


--
-- Name: tblbankaccounts pol_bankaccounts_readwrite_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_bankaccounts_readwrite_all ON public.tblbankaccounts TO app_readwrite USING (true) WITH CHECK (true);


--
-- Name: tblcashboxes pol_cashboxes_admin_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_cashboxes_admin_all ON public.tblcashboxes TO app_admin USING (true) WITH CHECK (true);


--
-- Name: tblcashboxes pol_cashboxes_auditor_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_cashboxes_auditor_select ON public.tblcashboxes FOR SELECT TO app_auditor USING (true);


--
-- Name: tblcashboxes pol_cashboxes_readwrite_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_cashboxes_readwrite_all ON public.tblcashboxes TO app_readwrite USING (true) WITH CHECK (true);


--
-- Name: tblcustomers pol_customers_admin_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_customers_admin_all ON public.tblcustomers TO app_admin USING (true) WITH CHECK (true);


--
-- Name: tblcustomers pol_customers_auditor_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_customers_auditor_select ON public.tblcustomers FOR SELECT TO app_auditor USING (true);


--
-- Name: tblcustomers pol_customers_readwrite_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_customers_readwrite_all ON public.tblcustomers TO app_readwrite USING (true) WITH CHECK (true);


--
-- Name: tblnotifications pol_notifications_admin_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_notifications_admin_all ON public.tblnotifications TO app_admin USING (true) WITH CHECK (true);


--
-- Name: tblnotifications pol_notifications_auditor_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_notifications_auditor_select ON public.tblnotifications FOR SELECT TO app_auditor USING (true);


--
-- Name: tblnotifications pol_notifications_readwrite_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_notifications_readwrite_insert ON public.tblnotifications FOR INSERT TO app_readwrite WITH CHECK (true);


--
-- Name: tblnotifications pol_notifications_readwrite_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_notifications_readwrite_select ON public.tblnotifications FOR SELECT TO app_readwrite USING (true);


--
-- Name: tblsessions pol_sessions_admin_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_sessions_admin_all ON public.tblsessions TO app_admin USING (true) WITH CHECK (true);


--
-- Name: tblsessions pol_sessions_auditor_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_sessions_auditor_select ON public.tblsessions FOR SELECT TO app_auditor USING (true);


--
-- Name: tblsuppliers pol_suppliers_admin_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_suppliers_admin_all ON public.tblsuppliers TO app_admin USING (true) WITH CHECK (true);


--
-- Name: tblsuppliers pol_suppliers_auditor_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_suppliers_auditor_select ON public.tblsuppliers FOR SELECT TO app_auditor USING (true);


--
-- Name: tblsuppliers pol_suppliers_readwrite_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_suppliers_readwrite_all ON public.tblsuppliers TO app_readwrite USING (true) WITH CHECK (true);


--
-- Name: tblusers pol_users_admin_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_users_admin_all ON public.tblusers TO app_admin USING (true) WITH CHECK (true);


--
-- Name: tblusers pol_users_auditor_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pol_users_auditor_select ON public.tblusers FOR SELECT TO app_auditor USING (true);


--
-- Name: tblaudi; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.tblaudi ENABLE ROW LEVEL SECURITY;

--
-- Name: tblaudi_security; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.tblaudi_security ENABLE ROW LEVEL SECURITY;

--
-- Name: tblauditlogs; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.tblauditlogs ENABLE ROW LEVEL SECURITY;

--
-- Name: tblbankaccounts; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.tblbankaccounts ENABLE ROW LEVEL SECURITY;

--
-- Name: tblcashboxes; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.tblcashboxes ENABLE ROW LEVEL SECURITY;

--
-- Name: tblcustomers; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.tblcustomers ENABLE ROW LEVEL SECURITY;

--
-- Name: tblnotifications; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.tblnotifications ENABLE ROW LEVEL SECURITY;

--
-- Name: tblsessions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.tblsessions ENABLE ROW LEVEL SECURITY;

--
-- Name: tblsuppliers; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.tblsuppliers ENABLE ROW LEVEL SECURITY;

--
-- Name: tblusers; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.tblusers ENABLE ROW LEVEL SECURITY;

--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO app_readonly;
GRANT USAGE ON SCHEMA public TO app_readwrite;
GRANT USAGE ON SCHEMA public TO app_admin;
GRANT USAGE ON SCHEMA public TO app_auditor;
GRANT USAGE ON SCHEMA public TO app_reports;
GRANT USAGE ON SCHEMA public TO app_backup;


--
-- Name: FUNCTION gbtreekey16_in(cstring); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbtreekey16_in(cstring) TO app_readonly;
GRANT ALL ON FUNCTION public.gbtreekey16_in(cstring) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbtreekey16_in(cstring) TO app_admin;
GRANT ALL ON FUNCTION public.gbtreekey16_in(cstring) TO app_auditor;
GRANT ALL ON FUNCTION public.gbtreekey16_in(cstring) TO app_reports;
GRANT ALL ON FUNCTION public.gbtreekey16_in(cstring) TO app_backup;


--
-- Name: FUNCTION gbtreekey16_out(public.gbtreekey16); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbtreekey16_out(public.gbtreekey16) TO app_readonly;
GRANT ALL ON FUNCTION public.gbtreekey16_out(public.gbtreekey16) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbtreekey16_out(public.gbtreekey16) TO app_admin;
GRANT ALL ON FUNCTION public.gbtreekey16_out(public.gbtreekey16) TO app_auditor;
GRANT ALL ON FUNCTION public.gbtreekey16_out(public.gbtreekey16) TO app_reports;
GRANT ALL ON FUNCTION public.gbtreekey16_out(public.gbtreekey16) TO app_backup;


--
-- Name: FUNCTION gbtreekey2_in(cstring); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbtreekey2_in(cstring) TO app_readonly;
GRANT ALL ON FUNCTION public.gbtreekey2_in(cstring) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbtreekey2_in(cstring) TO app_admin;
GRANT ALL ON FUNCTION public.gbtreekey2_in(cstring) TO app_auditor;
GRANT ALL ON FUNCTION public.gbtreekey2_in(cstring) TO app_reports;
GRANT ALL ON FUNCTION public.gbtreekey2_in(cstring) TO app_backup;


--
-- Name: FUNCTION gbtreekey2_out(public.gbtreekey2); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbtreekey2_out(public.gbtreekey2) TO app_readonly;
GRANT ALL ON FUNCTION public.gbtreekey2_out(public.gbtreekey2) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbtreekey2_out(public.gbtreekey2) TO app_admin;
GRANT ALL ON FUNCTION public.gbtreekey2_out(public.gbtreekey2) TO app_auditor;
GRANT ALL ON FUNCTION public.gbtreekey2_out(public.gbtreekey2) TO app_reports;
GRANT ALL ON FUNCTION public.gbtreekey2_out(public.gbtreekey2) TO app_backup;


--
-- Name: FUNCTION gbtreekey32_in(cstring); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbtreekey32_in(cstring) TO app_readonly;
GRANT ALL ON FUNCTION public.gbtreekey32_in(cstring) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbtreekey32_in(cstring) TO app_admin;
GRANT ALL ON FUNCTION public.gbtreekey32_in(cstring) TO app_auditor;
GRANT ALL ON FUNCTION public.gbtreekey32_in(cstring) TO app_reports;
GRANT ALL ON FUNCTION public.gbtreekey32_in(cstring) TO app_backup;


--
-- Name: FUNCTION gbtreekey32_out(public.gbtreekey32); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbtreekey32_out(public.gbtreekey32) TO app_readonly;
GRANT ALL ON FUNCTION public.gbtreekey32_out(public.gbtreekey32) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbtreekey32_out(public.gbtreekey32) TO app_admin;
GRANT ALL ON FUNCTION public.gbtreekey32_out(public.gbtreekey32) TO app_auditor;
GRANT ALL ON FUNCTION public.gbtreekey32_out(public.gbtreekey32) TO app_reports;
GRANT ALL ON FUNCTION public.gbtreekey32_out(public.gbtreekey32) TO app_backup;


--
-- Name: FUNCTION gbtreekey4_in(cstring); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbtreekey4_in(cstring) TO app_readonly;
GRANT ALL ON FUNCTION public.gbtreekey4_in(cstring) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbtreekey4_in(cstring) TO app_admin;
GRANT ALL ON FUNCTION public.gbtreekey4_in(cstring) TO app_auditor;
GRANT ALL ON FUNCTION public.gbtreekey4_in(cstring) TO app_reports;
GRANT ALL ON FUNCTION public.gbtreekey4_in(cstring) TO app_backup;


--
-- Name: FUNCTION gbtreekey4_out(public.gbtreekey4); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbtreekey4_out(public.gbtreekey4) TO app_readonly;
GRANT ALL ON FUNCTION public.gbtreekey4_out(public.gbtreekey4) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbtreekey4_out(public.gbtreekey4) TO app_admin;
GRANT ALL ON FUNCTION public.gbtreekey4_out(public.gbtreekey4) TO app_auditor;
GRANT ALL ON FUNCTION public.gbtreekey4_out(public.gbtreekey4) TO app_reports;
GRANT ALL ON FUNCTION public.gbtreekey4_out(public.gbtreekey4) TO app_backup;


--
-- Name: FUNCTION gbtreekey8_in(cstring); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbtreekey8_in(cstring) TO app_readonly;
GRANT ALL ON FUNCTION public.gbtreekey8_in(cstring) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbtreekey8_in(cstring) TO app_admin;
GRANT ALL ON FUNCTION public.gbtreekey8_in(cstring) TO app_auditor;
GRANT ALL ON FUNCTION public.gbtreekey8_in(cstring) TO app_reports;
GRANT ALL ON FUNCTION public.gbtreekey8_in(cstring) TO app_backup;


--
-- Name: FUNCTION gbtreekey8_out(public.gbtreekey8); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbtreekey8_out(public.gbtreekey8) TO app_readonly;
GRANT ALL ON FUNCTION public.gbtreekey8_out(public.gbtreekey8) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbtreekey8_out(public.gbtreekey8) TO app_admin;
GRANT ALL ON FUNCTION public.gbtreekey8_out(public.gbtreekey8) TO app_auditor;
GRANT ALL ON FUNCTION public.gbtreekey8_out(public.gbtreekey8) TO app_reports;
GRANT ALL ON FUNCTION public.gbtreekey8_out(public.gbtreekey8) TO app_backup;


--
-- Name: FUNCTION gbtreekey_var_in(cstring); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbtreekey_var_in(cstring) TO app_readonly;
GRANT ALL ON FUNCTION public.gbtreekey_var_in(cstring) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbtreekey_var_in(cstring) TO app_admin;
GRANT ALL ON FUNCTION public.gbtreekey_var_in(cstring) TO app_auditor;
GRANT ALL ON FUNCTION public.gbtreekey_var_in(cstring) TO app_reports;
GRANT ALL ON FUNCTION public.gbtreekey_var_in(cstring) TO app_backup;


--
-- Name: FUNCTION gbtreekey_var_out(public.gbtreekey_var); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbtreekey_var_out(public.gbtreekey_var) TO app_readonly;
GRANT ALL ON FUNCTION public.gbtreekey_var_out(public.gbtreekey_var) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbtreekey_var_out(public.gbtreekey_var) TO app_admin;
GRANT ALL ON FUNCTION public.gbtreekey_var_out(public.gbtreekey_var) TO app_auditor;
GRANT ALL ON FUNCTION public.gbtreekey_var_out(public.gbtreekey_var) TO app_reports;
GRANT ALL ON FUNCTION public.gbtreekey_var_out(public.gbtreekey_var) TO app_backup;


--
-- Name: FUNCTION addbusinessunit(p_businessunitid character varying, p_namear character varying, p_nameen character varying, p_parentbusinessunitcode integer, p_isactive boolean, p_notes text, p_adduser integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.addbusinessunit(p_businessunitid character varying, p_namear character varying, p_nameen character varying, p_parentbusinessunitcode integer, p_isactive boolean, p_notes text, p_adduser integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.addbusinessunit(p_businessunitid character varying, p_namear character varying, p_nameen character varying, p_parentbusinessunitcode integer, p_isactive boolean, p_notes text, p_adduser integer) TO app_readonly;
GRANT ALL ON FUNCTION public.addbusinessunit(p_businessunitid character varying, p_namear character varying, p_nameen character varying, p_parentbusinessunitcode integer, p_isactive boolean, p_notes text, p_adduser integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.addbusinessunit(p_businessunitid character varying, p_namear character varying, p_nameen character varying, p_parentbusinessunitcode integer, p_isactive boolean, p_notes text, p_adduser integer) TO app_admin;
GRANT ALL ON FUNCTION public.addbusinessunit(p_businessunitid character varying, p_namear character varying, p_nameen character varying, p_parentbusinessunitcode integer, p_isactive boolean, p_notes text, p_adduser integer) TO app_auditor;
GRANT ALL ON FUNCTION public.addbusinessunit(p_businessunitid character varying, p_namear character varying, p_nameen character varying, p_parentbusinessunitcode integer, p_isactive boolean, p_notes text, p_adduser integer) TO app_reports;
GRANT ALL ON FUNCTION public.addbusinessunit(p_businessunitid character varying, p_namear character varying, p_nameen character varying, p_parentbusinessunitcode integer, p_isactive boolean, p_notes text, p_adduser integer) TO app_backup;


--
-- Name: FUNCTION adddepartment(p_departmentid character varying, p_namear character varying, p_nameen character varying, p_parentdepartmentcode integer, p_managerusercode integer, p_isactive boolean, p_effectivedate date, p_enddate date, p_notes text, p_adduser integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.adddepartment(p_departmentid character varying, p_namear character varying, p_nameen character varying, p_parentdepartmentcode integer, p_managerusercode integer, p_isactive boolean, p_effectivedate date, p_enddate date, p_notes text, p_adduser integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.adddepartment(p_departmentid character varying, p_namear character varying, p_nameen character varying, p_parentdepartmentcode integer, p_managerusercode integer, p_isactive boolean, p_effectivedate date, p_enddate date, p_notes text, p_adduser integer) TO app_readonly;
GRANT ALL ON FUNCTION public.adddepartment(p_departmentid character varying, p_namear character varying, p_nameen character varying, p_parentdepartmentcode integer, p_managerusercode integer, p_isactive boolean, p_effectivedate date, p_enddate date, p_notes text, p_adduser integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.adddepartment(p_departmentid character varying, p_namear character varying, p_nameen character varying, p_parentdepartmentcode integer, p_managerusercode integer, p_isactive boolean, p_effectivedate date, p_enddate date, p_notes text, p_adduser integer) TO app_admin;
GRANT ALL ON FUNCTION public.adddepartment(p_departmentid character varying, p_namear character varying, p_nameen character varying, p_parentdepartmentcode integer, p_managerusercode integer, p_isactive boolean, p_effectivedate date, p_enddate date, p_notes text, p_adduser integer) TO app_auditor;
GRANT ALL ON FUNCTION public.adddepartment(p_departmentid character varying, p_namear character varying, p_nameen character varying, p_parentdepartmentcode integer, p_managerusercode integer, p_isactive boolean, p_effectivedate date, p_enddate date, p_notes text, p_adduser integer) TO app_reports;
GRANT ALL ON FUNCTION public.adddepartment(p_departmentid character varying, p_namear character varying, p_nameen character varying, p_parentdepartmentcode integer, p_managerusercode integer, p_isactive boolean, p_effectivedate date, p_enddate date, p_notes text, p_adduser integer) TO app_backup;


--
-- Name: FUNCTION adddimensionhierarchy(p_hierarchytype character varying, p_parentdimtype character varying, p_parentdimcode integer, p_childdimtype character varying, p_childdimcode integer, p_validfrom date, p_validto date, p_isactive boolean, p_notes text, p_adduser integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.adddimensionhierarchy(p_hierarchytype character varying, p_parentdimtype character varying, p_parentdimcode integer, p_childdimtype character varying, p_childdimcode integer, p_validfrom date, p_validto date, p_isactive boolean, p_notes text, p_adduser integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.adddimensionhierarchy(p_hierarchytype character varying, p_parentdimtype character varying, p_parentdimcode integer, p_childdimtype character varying, p_childdimcode integer, p_validfrom date, p_validto date, p_isactive boolean, p_notes text, p_adduser integer) TO app_readonly;
GRANT ALL ON FUNCTION public.adddimensionhierarchy(p_hierarchytype character varying, p_parentdimtype character varying, p_parentdimcode integer, p_childdimtype character varying, p_childdimcode integer, p_validfrom date, p_validto date, p_isactive boolean, p_notes text, p_adduser integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.adddimensionhierarchy(p_hierarchytype character varying, p_parentdimtype character varying, p_parentdimcode integer, p_childdimtype character varying, p_childdimcode integer, p_validfrom date, p_validto date, p_isactive boolean, p_notes text, p_adduser integer) TO app_admin;
GRANT ALL ON FUNCTION public.adddimensionhierarchy(p_hierarchytype character varying, p_parentdimtype character varying, p_parentdimcode integer, p_childdimtype character varying, p_childdimcode integer, p_validfrom date, p_validto date, p_isactive boolean, p_notes text, p_adduser integer) TO app_auditor;
GRANT ALL ON FUNCTION public.adddimensionhierarchy(p_hierarchytype character varying, p_parentdimtype character varying, p_parentdimcode integer, p_childdimtype character varying, p_childdimcode integer, p_validfrom date, p_validto date, p_isactive boolean, p_notes text, p_adduser integer) TO app_reports;
GRANT ALL ON FUNCTION public.adddimensionhierarchy(p_hierarchytype character varying, p_parentdimtype character varying, p_parentdimcode integer, p_childdimtype character varying, p_childdimcode integer, p_validfrom date, p_validto date, p_isactive boolean, p_notes text, p_adduser integer) TO app_backup;


--
-- Name: FUNCTION addprofitcenter(p_profitcenterid character varying, p_namear character varying, p_nameen character varying, p_parentprofitcentercode integer, p_isactive boolean, p_notes text, p_adduser integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.addprofitcenter(p_profitcenterid character varying, p_namear character varying, p_nameen character varying, p_parentprofitcentercode integer, p_isactive boolean, p_notes text, p_adduser integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.addprofitcenter(p_profitcenterid character varying, p_namear character varying, p_nameen character varying, p_parentprofitcentercode integer, p_isactive boolean, p_notes text, p_adduser integer) TO app_readonly;
GRANT ALL ON FUNCTION public.addprofitcenter(p_profitcenterid character varying, p_namear character varying, p_nameen character varying, p_parentprofitcentercode integer, p_isactive boolean, p_notes text, p_adduser integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.addprofitcenter(p_profitcenterid character varying, p_namear character varying, p_nameen character varying, p_parentprofitcentercode integer, p_isactive boolean, p_notes text, p_adduser integer) TO app_admin;
GRANT ALL ON FUNCTION public.addprofitcenter(p_profitcenterid character varying, p_namear character varying, p_nameen character varying, p_parentprofitcentercode integer, p_isactive boolean, p_notes text, p_adduser integer) TO app_auditor;
GRANT ALL ON FUNCTION public.addprofitcenter(p_profitcenterid character varying, p_namear character varying, p_nameen character varying, p_parentprofitcentercode integer, p_isactive boolean, p_notes text, p_adduser integer) TO app_reports;
GRANT ALL ON FUNCTION public.addprofitcenter(p_profitcenterid character varying, p_namear character varying, p_nameen character varying, p_parentprofitcentercode integer, p_isactive boolean, p_notes text, p_adduser integer) TO app_backup;


--
-- Name: FUNCTION addproject(p_projectid character varying, p_namear character varying, p_nameen character varying, p_parentprojectcode integer, p_projecttype character varying, p_startdate date, p_enddate date, p_budgetamount numeric, p_projectstatus character varying, p_isactive boolean, p_notes text, p_adduser integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.addproject(p_projectid character varying, p_namear character varying, p_nameen character varying, p_parentprojectcode integer, p_projecttype character varying, p_startdate date, p_enddate date, p_budgetamount numeric, p_projectstatus character varying, p_isactive boolean, p_notes text, p_adduser integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.addproject(p_projectid character varying, p_namear character varying, p_nameen character varying, p_parentprojectcode integer, p_projecttype character varying, p_startdate date, p_enddate date, p_budgetamount numeric, p_projectstatus character varying, p_isactive boolean, p_notes text, p_adduser integer) TO app_readonly;
GRANT ALL ON FUNCTION public.addproject(p_projectid character varying, p_namear character varying, p_nameen character varying, p_parentprojectcode integer, p_projecttype character varying, p_startdate date, p_enddate date, p_budgetamount numeric, p_projectstatus character varying, p_isactive boolean, p_notes text, p_adduser integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.addproject(p_projectid character varying, p_namear character varying, p_nameen character varying, p_parentprojectcode integer, p_projecttype character varying, p_startdate date, p_enddate date, p_budgetamount numeric, p_projectstatus character varying, p_isactive boolean, p_notes text, p_adduser integer) TO app_admin;
GRANT ALL ON FUNCTION public.addproject(p_projectid character varying, p_namear character varying, p_nameen character varying, p_parentprojectcode integer, p_projecttype character varying, p_startdate date, p_enddate date, p_budgetamount numeric, p_projectstatus character varying, p_isactive boolean, p_notes text, p_adduser integer) TO app_auditor;
GRANT ALL ON FUNCTION public.addproject(p_projectid character varying, p_namear character varying, p_nameen character varying, p_parentprojectcode integer, p_projecttype character varying, p_startdate date, p_enddate date, p_budgetamount numeric, p_projectstatus character varying, p_isactive boolean, p_notes text, p_adduser integer) TO app_reports;
GRANT ALL ON FUNCTION public.addproject(p_projectid character varying, p_namear character varying, p_nameen character varying, p_parentprojectcode integer, p_projecttype character varying, p_startdate date, p_enddate date, p_budgetamount numeric, p_projectstatus character varying, p_isactive boolean, p_notes text, p_adduser integer) TO app_backup;


--
-- Name: FUNCTION addsegment(p_segmentid character varying, p_namear character varying, p_nameen character varying, p_segmenttype character varying, p_parentsegmentcode integer, p_isactive boolean, p_notes text, p_adduser integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.addsegment(p_segmentid character varying, p_namear character varying, p_nameen character varying, p_segmenttype character varying, p_parentsegmentcode integer, p_isactive boolean, p_notes text, p_adduser integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.addsegment(p_segmentid character varying, p_namear character varying, p_nameen character varying, p_segmenttype character varying, p_parentsegmentcode integer, p_isactive boolean, p_notes text, p_adduser integer) TO app_readonly;
GRANT ALL ON FUNCTION public.addsegment(p_segmentid character varying, p_namear character varying, p_nameen character varying, p_segmenttype character varying, p_parentsegmentcode integer, p_isactive boolean, p_notes text, p_adduser integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.addsegment(p_segmentid character varying, p_namear character varying, p_nameen character varying, p_segmenttype character varying, p_parentsegmentcode integer, p_isactive boolean, p_notes text, p_adduser integer) TO app_admin;
GRANT ALL ON FUNCTION public.addsegment(p_segmentid character varying, p_namear character varying, p_nameen character varying, p_segmenttype character varying, p_parentsegmentcode integer, p_isactive boolean, p_notes text, p_adduser integer) TO app_auditor;
GRANT ALL ON FUNCTION public.addsegment(p_segmentid character varying, p_namear character varying, p_nameen character varying, p_segmenttype character varying, p_parentsegmentcode integer, p_isactive boolean, p_notes text, p_adduser integer) TO app_reports;
GRANT ALL ON FUNCTION public.addsegment(p_segmentid character varying, p_namear character varying, p_nameen character varying, p_segmenttype character varying, p_parentsegmentcode integer, p_isactive boolean, p_notes text, p_adduser integer) TO app_backup;


--
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.armor(bytea) FROM PUBLIC;
GRANT ALL ON FUNCTION public.armor(bytea) TO app_readonly;
GRANT ALL ON FUNCTION public.armor(bytea) TO app_readwrite;
GRANT ALL ON FUNCTION public.armor(bytea) TO app_admin;
GRANT ALL ON FUNCTION public.armor(bytea) TO app_auditor;
GRANT ALL ON FUNCTION public.armor(bytea) TO app_reports;
GRANT ALL ON FUNCTION public.armor(bytea) TO app_backup;


--
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.armor(bytea, text[], text[]) FROM PUBLIC;
GRANT ALL ON FUNCTION public.armor(bytea, text[], text[]) TO app_readonly;
GRANT ALL ON FUNCTION public.armor(bytea, text[], text[]) TO app_readwrite;
GRANT ALL ON FUNCTION public.armor(bytea, text[], text[]) TO app_admin;
GRANT ALL ON FUNCTION public.armor(bytea, text[], text[]) TO app_auditor;
GRANT ALL ON FUNCTION public.armor(bytea, text[], text[]) TO app_reports;
GRANT ALL ON FUNCTION public.armor(bytea, text[], text[]) TO app_backup;


--
-- Name: FUNCTION cash_dist(money, money); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.cash_dist(money, money) TO app_readonly;
GRANT ALL ON FUNCTION public.cash_dist(money, money) TO app_readwrite;
GRANT ALL ON FUNCTION public.cash_dist(money, money) TO app_admin;
GRANT ALL ON FUNCTION public.cash_dist(money, money) TO app_auditor;
GRANT ALL ON FUNCTION public.cash_dist(money, money) TO app_reports;
GRANT ALL ON FUNCTION public.cash_dist(money, money) TO app_backup;


--
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.crypt(text, text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.crypt(text, text) TO app_readonly;
GRANT ALL ON FUNCTION public.crypt(text, text) TO app_readwrite;
GRANT ALL ON FUNCTION public.crypt(text, text) TO app_admin;
GRANT ALL ON FUNCTION public.crypt(text, text) TO app_auditor;
GRANT ALL ON FUNCTION public.crypt(text, text) TO app_reports;
GRANT ALL ON FUNCTION public.crypt(text, text) TO app_backup;


--
-- Name: FUNCTION date_dist(date, date); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.date_dist(date, date) TO app_readonly;
GRANT ALL ON FUNCTION public.date_dist(date, date) TO app_readwrite;
GRANT ALL ON FUNCTION public.date_dist(date, date) TO app_admin;
GRANT ALL ON FUNCTION public.date_dist(date, date) TO app_auditor;
GRANT ALL ON FUNCTION public.date_dist(date, date) TO app_reports;
GRANT ALL ON FUNCTION public.date_dist(date, date) TO app_backup;


--
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.dearmor(text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.dearmor(text) TO app_readonly;
GRANT ALL ON FUNCTION public.dearmor(text) TO app_readwrite;
GRANT ALL ON FUNCTION public.dearmor(text) TO app_admin;
GRANT ALL ON FUNCTION public.dearmor(text) TO app_auditor;
GRANT ALL ON FUNCTION public.dearmor(text) TO app_reports;
GRANT ALL ON FUNCTION public.dearmor(text) TO app_backup;


--
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.decrypt(bytea, bytea, text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.decrypt(bytea, bytea, text) TO app_readonly;
GRANT ALL ON FUNCTION public.decrypt(bytea, bytea, text) TO app_readwrite;
GRANT ALL ON FUNCTION public.decrypt(bytea, bytea, text) TO app_admin;
GRANT ALL ON FUNCTION public.decrypt(bytea, bytea, text) TO app_auditor;
GRANT ALL ON FUNCTION public.decrypt(bytea, bytea, text) TO app_reports;
GRANT ALL ON FUNCTION public.decrypt(bytea, bytea, text) TO app_backup;


--
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) TO app_readonly;
GRANT ALL ON FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) TO app_readwrite;
GRANT ALL ON FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) TO app_admin;
GRANT ALL ON FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) TO app_auditor;
GRANT ALL ON FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) TO app_reports;
GRANT ALL ON FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) TO app_backup;


--
-- Name: FUNCTION deletebusinessunit(p_businessunitcode integer, p_edituser integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.deletebusinessunit(p_businessunitcode integer, p_edituser integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.deletebusinessunit(p_businessunitcode integer, p_edituser integer) TO app_readonly;
GRANT ALL ON FUNCTION public.deletebusinessunit(p_businessunitcode integer, p_edituser integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.deletebusinessunit(p_businessunitcode integer, p_edituser integer) TO app_admin;
GRANT ALL ON FUNCTION public.deletebusinessunit(p_businessunitcode integer, p_edituser integer) TO app_auditor;
GRANT ALL ON FUNCTION public.deletebusinessunit(p_businessunitcode integer, p_edituser integer) TO app_reports;
GRANT ALL ON FUNCTION public.deletebusinessunit(p_businessunitcode integer, p_edituser integer) TO app_backup;


--
-- Name: FUNCTION deletedepartment(p_departmentcode integer, p_edituser integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.deletedepartment(p_departmentcode integer, p_edituser integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.deletedepartment(p_departmentcode integer, p_edituser integer) TO app_readonly;
GRANT ALL ON FUNCTION public.deletedepartment(p_departmentcode integer, p_edituser integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.deletedepartment(p_departmentcode integer, p_edituser integer) TO app_admin;
GRANT ALL ON FUNCTION public.deletedepartment(p_departmentcode integer, p_edituser integer) TO app_auditor;
GRANT ALL ON FUNCTION public.deletedepartment(p_departmentcode integer, p_edituser integer) TO app_reports;
GRANT ALL ON FUNCTION public.deletedepartment(p_departmentcode integer, p_edituser integer) TO app_backup;


--
-- Name: FUNCTION deletedimensionhierarchy(p_hierarchyid bigint, p_edituser integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.deletedimensionhierarchy(p_hierarchyid bigint, p_edituser integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.deletedimensionhierarchy(p_hierarchyid bigint, p_edituser integer) TO app_readonly;
GRANT ALL ON FUNCTION public.deletedimensionhierarchy(p_hierarchyid bigint, p_edituser integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.deletedimensionhierarchy(p_hierarchyid bigint, p_edituser integer) TO app_admin;
GRANT ALL ON FUNCTION public.deletedimensionhierarchy(p_hierarchyid bigint, p_edituser integer) TO app_auditor;
GRANT ALL ON FUNCTION public.deletedimensionhierarchy(p_hierarchyid bigint, p_edituser integer) TO app_reports;
GRANT ALL ON FUNCTION public.deletedimensionhierarchy(p_hierarchyid bigint, p_edituser integer) TO app_backup;


--
-- Name: FUNCTION deleteprofitcenter(p_profitcentercode integer, p_edituser integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.deleteprofitcenter(p_profitcentercode integer, p_edituser integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.deleteprofitcenter(p_profitcentercode integer, p_edituser integer) TO app_readonly;
GRANT ALL ON FUNCTION public.deleteprofitcenter(p_profitcentercode integer, p_edituser integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.deleteprofitcenter(p_profitcentercode integer, p_edituser integer) TO app_admin;
GRANT ALL ON FUNCTION public.deleteprofitcenter(p_profitcentercode integer, p_edituser integer) TO app_auditor;
GRANT ALL ON FUNCTION public.deleteprofitcenter(p_profitcentercode integer, p_edituser integer) TO app_reports;
GRANT ALL ON FUNCTION public.deleteprofitcenter(p_profitcentercode integer, p_edituser integer) TO app_backup;


--
-- Name: FUNCTION deleteproject(p_projectcode integer, p_edituser integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.deleteproject(p_projectcode integer, p_edituser integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.deleteproject(p_projectcode integer, p_edituser integer) TO app_readonly;
GRANT ALL ON FUNCTION public.deleteproject(p_projectcode integer, p_edituser integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.deleteproject(p_projectcode integer, p_edituser integer) TO app_admin;
GRANT ALL ON FUNCTION public.deleteproject(p_projectcode integer, p_edituser integer) TO app_auditor;
GRANT ALL ON FUNCTION public.deleteproject(p_projectcode integer, p_edituser integer) TO app_reports;
GRANT ALL ON FUNCTION public.deleteproject(p_projectcode integer, p_edituser integer) TO app_backup;


--
-- Name: FUNCTION deletesegment(p_segmentcode integer, p_edituser integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.deletesegment(p_segmentcode integer, p_edituser integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.deletesegment(p_segmentcode integer, p_edituser integer) TO app_readonly;
GRANT ALL ON FUNCTION public.deletesegment(p_segmentcode integer, p_edituser integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.deletesegment(p_segmentcode integer, p_edituser integer) TO app_admin;
GRANT ALL ON FUNCTION public.deletesegment(p_segmentcode integer, p_edituser integer) TO app_auditor;
GRANT ALL ON FUNCTION public.deletesegment(p_segmentcode integer, p_edituser integer) TO app_reports;
GRANT ALL ON FUNCTION public.deletesegment(p_segmentcode integer, p_edituser integer) TO app_backup;


--
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.digest(bytea, text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.digest(bytea, text) TO app_readonly;
GRANT ALL ON FUNCTION public.digest(bytea, text) TO app_readwrite;
GRANT ALL ON FUNCTION public.digest(bytea, text) TO app_admin;
GRANT ALL ON FUNCTION public.digest(bytea, text) TO app_auditor;
GRANT ALL ON FUNCTION public.digest(bytea, text) TO app_reports;
GRANT ALL ON FUNCTION public.digest(bytea, text) TO app_backup;


--
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.digest(text, text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.digest(text, text) TO app_readonly;
GRANT ALL ON FUNCTION public.digest(text, text) TO app_readwrite;
GRANT ALL ON FUNCTION public.digest(text, text) TO app_admin;
GRANT ALL ON FUNCTION public.digest(text, text) TO app_auditor;
GRANT ALL ON FUNCTION public.digest(text, text) TO app_reports;
GRANT ALL ON FUNCTION public.digest(text, text) TO app_backup;


--
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.encrypt(bytea, bytea, text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.encrypt(bytea, bytea, text) TO app_readonly;
GRANT ALL ON FUNCTION public.encrypt(bytea, bytea, text) TO app_readwrite;
GRANT ALL ON FUNCTION public.encrypt(bytea, bytea, text) TO app_admin;
GRANT ALL ON FUNCTION public.encrypt(bytea, bytea, text) TO app_auditor;
GRANT ALL ON FUNCTION public.encrypt(bytea, bytea, text) TO app_reports;
GRANT ALL ON FUNCTION public.encrypt(bytea, bytea, text) TO app_backup;


--
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) TO app_readonly;
GRANT ALL ON FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) TO app_readwrite;
GRANT ALL ON FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) TO app_admin;
GRANT ALL ON FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) TO app_auditor;
GRANT ALL ON FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) TO app_reports;
GRANT ALL ON FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) TO app_backup;


--
-- Name: FUNCTION float4_dist(real, real); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.float4_dist(real, real) TO app_readonly;
GRANT ALL ON FUNCTION public.float4_dist(real, real) TO app_readwrite;
GRANT ALL ON FUNCTION public.float4_dist(real, real) TO app_admin;
GRANT ALL ON FUNCTION public.float4_dist(real, real) TO app_auditor;
GRANT ALL ON FUNCTION public.float4_dist(real, real) TO app_reports;
GRANT ALL ON FUNCTION public.float4_dist(real, real) TO app_backup;


--
-- Name: FUNCTION float8_dist(double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.float8_dist(double precision, double precision) TO app_readonly;
GRANT ALL ON FUNCTION public.float8_dist(double precision, double precision) TO app_readwrite;
GRANT ALL ON FUNCTION public.float8_dist(double precision, double precision) TO app_admin;
GRANT ALL ON FUNCTION public.float8_dist(double precision, double precision) TO app_auditor;
GRANT ALL ON FUNCTION public.float8_dist(double precision, double precision) TO app_reports;
GRANT ALL ON FUNCTION public.float8_dist(double precision, double precision) TO app_backup;


--
-- Name: FUNCTION fn_add_check_validated(p_table regclass, p_name text, p_expr text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_add_check_validated(p_table regclass, p_name text, p_expr text) TO app_readonly;
GRANT ALL ON FUNCTION public.fn_add_check_validated(p_table regclass, p_name text, p_expr text) TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_add_check_validated(p_table regclass, p_name text, p_expr text) TO app_admin;
GRANT ALL ON FUNCTION public.fn_add_check_validated(p_table regclass, p_name text, p_expr text) TO app_auditor;
GRANT ALL ON FUNCTION public.fn_add_check_validated(p_table regclass, p_name text, p_expr text) TO app_reports;
GRANT ALL ON FUNCTION public.fn_add_check_validated(p_table regclass, p_name text, p_expr text) TO app_backup;


--
-- Name: FUNCTION fn_add_exclude(p_table regclass, p_name text, p_def text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_add_exclude(p_table regclass, p_name text, p_def text) TO app_readonly;
GRANT ALL ON FUNCTION public.fn_add_exclude(p_table regclass, p_name text, p_def text) TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_add_exclude(p_table regclass, p_name text, p_def text) TO app_admin;
GRANT ALL ON FUNCTION public.fn_add_exclude(p_table regclass, p_name text, p_def text) TO app_auditor;
GRANT ALL ON FUNCTION public.fn_add_exclude(p_table regclass, p_name text, p_def text) TO app_reports;
GRANT ALL ON FUNCTION public.fn_add_exclude(p_table regclass, p_name text, p_def text) TO app_backup;


--
-- Name: FUNCTION fn_add_index_concurrent(p_index_name text, p_index_def text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_add_index_concurrent(p_index_name text, p_index_def text) TO app_readonly;
GRANT ALL ON FUNCTION public.fn_add_index_concurrent(p_index_name text, p_index_def text) TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_add_index_concurrent(p_index_name text, p_index_def text) TO app_admin;
GRANT ALL ON FUNCTION public.fn_add_index_concurrent(p_index_name text, p_index_def text) TO app_auditor;
GRANT ALL ON FUNCTION public.fn_add_index_concurrent(p_index_name text, p_index_def text) TO app_reports;
GRANT ALL ON FUNCTION public.fn_add_index_concurrent(p_index_name text, p_index_def text) TO app_backup;


--
-- Name: FUNCTION fn_audit_trigger(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.fn_audit_trigger() FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_audit_trigger() TO app_readonly;
GRANT ALL ON FUNCTION public.fn_audit_trigger() TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_audit_trigger() TO app_admin;
GRANT ALL ON FUNCTION public.fn_audit_trigger() TO app_auditor;
GRANT ALL ON FUNCTION public.fn_audit_trigger() TO app_reports;
GRANT ALL ON FUNCTION public.fn_audit_trigger() TO app_backup;


--
-- Name: FUNCTION fn_auto_submit_for_approval(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.fn_auto_submit_for_approval() FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_auto_submit_for_approval() TO app_readonly;
GRANT ALL ON FUNCTION public.fn_auto_submit_for_approval() TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_auto_submit_for_approval() TO app_admin;
GRANT ALL ON FUNCTION public.fn_auto_submit_for_approval() TO app_auditor;
GRANT ALL ON FUNCTION public.fn_auto_submit_for_approval() TO app_reports;
GRANT ALL ON FUNCTION public.fn_auto_submit_for_approval() TO app_backup;


--
-- Name: FUNCTION fn_block_unapproved_posting(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.fn_block_unapproved_posting() FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_block_unapproved_posting() TO app_readonly;
GRANT ALL ON FUNCTION public.fn_block_unapproved_posting() TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_block_unapproved_posting() TO app_admin;
GRANT ALL ON FUNCTION public.fn_block_unapproved_posting() TO app_auditor;
GRANT ALL ON FUNCTION public.fn_block_unapproved_posting() TO app_reports;
GRANT ALL ON FUNCTION public.fn_block_unapproved_posting() TO app_backup;


--
-- Name: FUNCTION fn_calculatevat(p_amount numeric, p_vat_percent numeric); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.fn_calculatevat(p_amount numeric, p_vat_percent numeric) FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_calculatevat(p_amount numeric, p_vat_percent numeric) TO app_readonly;
GRANT ALL ON FUNCTION public.fn_calculatevat(p_amount numeric, p_vat_percent numeric) TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_calculatevat(p_amount numeric, p_vat_percent numeric) TO app_admin;
GRANT ALL ON FUNCTION public.fn_calculatevat(p_amount numeric, p_vat_percent numeric) TO app_auditor;
GRANT ALL ON FUNCTION public.fn_calculatevat(p_amount numeric, p_vat_percent numeric) TO app_reports;
GRANT ALL ON FUNCTION public.fn_calculatevat(p_amount numeric, p_vat_percent numeric) TO app_backup;


--
-- Name: FUNCTION fn_dim_updateprojectactual(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.fn_dim_updateprojectactual() FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_dim_updateprojectactual() TO app_readonly;
GRANT ALL ON FUNCTION public.fn_dim_updateprojectactual() TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_dim_updateprojectactual() TO app_admin;
GRANT ALL ON FUNCTION public.fn_dim_updateprojectactual() TO app_auditor;
GRANT ALL ON FUNCTION public.fn_dim_updateprojectactual() TO app_reports;
GRANT ALL ON FUNCTION public.fn_dim_updateprojectactual() TO app_backup;


--
-- Name: FUNCTION fn_dim_validateondimcolumns(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.fn_dim_validateondimcolumns() FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_dim_validateondimcolumns() TO app_readonly;
GRANT ALL ON FUNCTION public.fn_dim_validateondimcolumns() TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_dim_validateondimcolumns() TO app_admin;
GRANT ALL ON FUNCTION public.fn_dim_validateondimcolumns() TO app_auditor;
GRANT ALL ON FUNCTION public.fn_dim_validateondimcolumns() TO app_reports;
GRANT ALL ON FUNCTION public.fn_dim_validateondimcolumns() TO app_backup;


--
-- Name: FUNCTION fn_g10_approval_action_audit_fn(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_g10_approval_action_audit_fn() TO app_readonly;
GRANT ALL ON FUNCTION public.fn_g10_approval_action_audit_fn() TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_g10_approval_action_audit_fn() TO app_admin;
GRANT ALL ON FUNCTION public.fn_g10_approval_action_audit_fn() TO app_auditor;
GRANT ALL ON FUNCTION public.fn_g10_approval_action_audit_fn() TO app_reports;
GRANT ALL ON FUNCTION public.fn_g10_approval_action_audit_fn() TO app_backup;


--
-- Name: FUNCTION fn_g10_approval_compute_status(p_requestid bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_g10_approval_compute_status(p_requestid bigint) TO app_readonly;
GRANT ALL ON FUNCTION public.fn_g10_approval_compute_status(p_requestid bigint) TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_g10_approval_compute_status(p_requestid bigint) TO app_admin;
GRANT ALL ON FUNCTION public.fn_g10_approval_compute_status(p_requestid bigint) TO app_auditor;
GRANT ALL ON FUNCTION public.fn_g10_approval_compute_status(p_requestid bigint) TO app_reports;
GRANT ALL ON FUNCTION public.fn_g10_approval_compute_status(p_requestid bigint) TO app_backup;


--
-- Name: FUNCTION fn_g10_approval_request_status_update_fn(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_g10_approval_request_status_update_fn() TO app_readonly;
GRANT ALL ON FUNCTION public.fn_g10_approval_request_status_update_fn() TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_g10_approval_request_status_update_fn() TO app_admin;
GRANT ALL ON FUNCTION public.fn_g10_approval_request_status_update_fn() TO app_auditor;
GRANT ALL ON FUNCTION public.fn_g10_approval_request_status_update_fn() TO app_reports;
GRANT ALL ON FUNCTION public.fn_g10_approval_request_status_update_fn() TO app_backup;


--
-- Name: FUNCTION fn_g10_approval_signature_part_a(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_g10_approval_signature_part_a() TO app_readonly;
GRANT ALL ON FUNCTION public.fn_g10_approval_signature_part_a() TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_g10_approval_signature_part_a() TO app_admin;
GRANT ALL ON FUNCTION public.fn_g10_approval_signature_part_a() TO app_auditor;
GRANT ALL ON FUNCTION public.fn_g10_approval_signature_part_a() TO app_reports;
GRANT ALL ON FUNCTION public.fn_g10_approval_signature_part_a() TO app_backup;


--
-- Name: FUNCTION fn_g10_approval_signature_part_b(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_g10_approval_signature_part_b() TO app_readonly;
GRANT ALL ON FUNCTION public.fn_g10_approval_signature_part_b() TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_g10_approval_signature_part_b() TO app_admin;
GRANT ALL ON FUNCTION public.fn_g10_approval_signature_part_b() TO app_auditor;
GRANT ALL ON FUNCTION public.fn_g10_approval_signature_part_b() TO app_reports;
GRANT ALL ON FUNCTION public.fn_g10_approval_signature_part_b() TO app_backup;


--
-- Name: FUNCTION fn_g10_approval_signature_part_c(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_g10_approval_signature_part_c() TO app_readonly;
GRANT ALL ON FUNCTION public.fn_g10_approval_signature_part_c() TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_g10_approval_signature_part_c() TO app_admin;
GRANT ALL ON FUNCTION public.fn_g10_approval_signature_part_c() TO app_auditor;
GRANT ALL ON FUNCTION public.fn_g10_approval_signature_part_c() TO app_reports;
GRANT ALL ON FUNCTION public.fn_g10_approval_signature_part_c() TO app_backup;


--
-- Name: FUNCTION fn_g10_approval_valid_transition(p_old_status text, p_new_status text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_g10_approval_valid_transition(p_old_status text, p_new_status text) TO app_readonly;
GRANT ALL ON FUNCTION public.fn_g10_approval_valid_transition(p_old_status text, p_new_status text) TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_g10_approval_valid_transition(p_old_status text, p_new_status text) TO app_admin;
GRANT ALL ON FUNCTION public.fn_g10_approval_valid_transition(p_old_status text, p_new_status text) TO app_auditor;
GRANT ALL ON FUNCTION public.fn_g10_approval_valid_transition(p_old_status text, p_new_status text) TO app_reports;
GRANT ALL ON FUNCTION public.fn_g10_approval_valid_transition(p_old_status text, p_new_status text) TO app_backup;


--
-- Name: FUNCTION fn_g2_security_signature(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_g2_security_signature() TO app_readonly;
GRANT ALL ON FUNCTION public.fn_g2_security_signature() TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_g2_security_signature() TO app_admin;
GRANT ALL ON FUNCTION public.fn_g2_security_signature() TO app_auditor;
GRANT ALL ON FUNCTION public.fn_g2_security_signature() TO app_reports;
GRANT ALL ON FUNCTION public.fn_g2_security_signature() TO app_backup;


--
-- Name: FUNCTION fn_g3_monitoring_signature(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_g3_monitoring_signature() TO app_readonly;
GRANT ALL ON FUNCTION public.fn_g3_monitoring_signature() TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_g3_monitoring_signature() TO app_admin;
GRANT ALL ON FUNCTION public.fn_g3_monitoring_signature() TO app_auditor;
GRANT ALL ON FUNCTION public.fn_g3_monitoring_signature() TO app_reports;
GRANT ALL ON FUNCTION public.fn_g3_monitoring_signature() TO app_backup;


--
-- Name: FUNCTION fn_g4_constraints_signature_part_a(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_g4_constraints_signature_part_a() TO app_readonly;
GRANT ALL ON FUNCTION public.fn_g4_constraints_signature_part_a() TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_g4_constraints_signature_part_a() TO app_admin;
GRANT ALL ON FUNCTION public.fn_g4_constraints_signature_part_a() TO app_auditor;
GRANT ALL ON FUNCTION public.fn_g4_constraints_signature_part_a() TO app_reports;
GRANT ALL ON FUNCTION public.fn_g4_constraints_signature_part_a() TO app_backup;


--
-- Name: FUNCTION fn_g4_constraints_signature_part_b(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_g4_constraints_signature_part_b() TO app_readonly;
GRANT ALL ON FUNCTION public.fn_g4_constraints_signature_part_b() TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_g4_constraints_signature_part_b() TO app_admin;
GRANT ALL ON FUNCTION public.fn_g4_constraints_signature_part_b() TO app_auditor;
GRANT ALL ON FUNCTION public.fn_g4_constraints_signature_part_b() TO app_reports;
GRANT ALL ON FUNCTION public.fn_g4_constraints_signature_part_b() TO app_backup;


--
-- Name: FUNCTION fn_g4_constraints_signature_part_c(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_g4_constraints_signature_part_c() TO app_readonly;
GRANT ALL ON FUNCTION public.fn_g4_constraints_signature_part_c() TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_g4_constraints_signature_part_c() TO app_admin;
GRANT ALL ON FUNCTION public.fn_g4_constraints_signature_part_c() TO app_auditor;
GRANT ALL ON FUNCTION public.fn_g4_constraints_signature_part_c() TO app_reports;
GRANT ALL ON FUNCTION public.fn_g4_constraints_signature_part_c() TO app_backup;


--
-- Name: FUNCTION fn_g5_indexes_signature_part_a(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_g5_indexes_signature_part_a() TO app_readonly;
GRANT ALL ON FUNCTION public.fn_g5_indexes_signature_part_a() TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_g5_indexes_signature_part_a() TO app_admin;
GRANT ALL ON FUNCTION public.fn_g5_indexes_signature_part_a() TO app_auditor;
GRANT ALL ON FUNCTION public.fn_g5_indexes_signature_part_a() TO app_reports;
GRANT ALL ON FUNCTION public.fn_g5_indexes_signature_part_a() TO app_backup;


--
-- Name: FUNCTION fn_g5_indexes_signature_part_b(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_g5_indexes_signature_part_b() TO app_readonly;
GRANT ALL ON FUNCTION public.fn_g5_indexes_signature_part_b() TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_g5_indexes_signature_part_b() TO app_admin;
GRANT ALL ON FUNCTION public.fn_g5_indexes_signature_part_b() TO app_auditor;
GRANT ALL ON FUNCTION public.fn_g5_indexes_signature_part_b() TO app_reports;
GRANT ALL ON FUNCTION public.fn_g5_indexes_signature_part_b() TO app_backup;


--
-- Name: FUNCTION fn_g7_mv_signature_part_a(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_g7_mv_signature_part_a() TO app_readonly;
GRANT ALL ON FUNCTION public.fn_g7_mv_signature_part_a() TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_g7_mv_signature_part_a() TO app_admin;
GRANT ALL ON FUNCTION public.fn_g7_mv_signature_part_a() TO app_auditor;
GRANT ALL ON FUNCTION public.fn_g7_mv_signature_part_a() TO app_reports;
GRANT ALL ON FUNCTION public.fn_g7_mv_signature_part_a() TO app_backup;


--
-- Name: FUNCTION fn_g7_mv_signature_part_b(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_g7_mv_signature_part_b() TO app_readonly;
GRANT ALL ON FUNCTION public.fn_g7_mv_signature_part_b() TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_g7_mv_signature_part_b() TO app_admin;
GRANT ALL ON FUNCTION public.fn_g7_mv_signature_part_b() TO app_auditor;
GRANT ALL ON FUNCTION public.fn_g7_mv_signature_part_b() TO app_reports;
GRANT ALL ON FUNCTION public.fn_g7_mv_signature_part_b() TO app_backup;


--
-- Name: FUNCTION fn_generateoperationno(p_operation_type character varying, p_operation_code bigint); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.fn_generateoperationno(p_operation_type character varying, p_operation_code bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_generateoperationno(p_operation_type character varying, p_operation_code bigint) TO app_readonly;
GRANT ALL ON FUNCTION public.fn_generateoperationno(p_operation_type character varying, p_operation_code bigint) TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_generateoperationno(p_operation_type character varying, p_operation_code bigint) TO app_admin;
GRANT ALL ON FUNCTION public.fn_generateoperationno(p_operation_type character varying, p_operation_code bigint) TO app_auditor;
GRANT ALL ON FUNCTION public.fn_generateoperationno(p_operation_type character varying, p_operation_code bigint) TO app_reports;
GRANT ALL ON FUNCTION public.fn_generateoperationno(p_operation_type character varying, p_operation_code bigint) TO app_backup;


--
-- Name: FUNCTION fn_get_slow_queries(min_ms integer, max_rows integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_get_slow_queries(min_ms integer, max_rows integer) TO app_readonly;
GRANT ALL ON FUNCTION public.fn_get_slow_queries(min_ms integer, max_rows integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_get_slow_queries(min_ms integer, max_rows integer) TO app_admin;
GRANT ALL ON FUNCTION public.fn_get_slow_queries(min_ms integer, max_rows integer) TO app_auditor;
GRANT ALL ON FUNCTION public.fn_get_slow_queries(min_ms integer, max_rows integer) TO app_reports;
GRANT ALL ON FUNCTION public.fn_get_slow_queries(min_ms integer, max_rows integer) TO app_backup;


--
-- Name: FUNCTION fn_getaccountbalance(p_account_code integer, p_as_of_date timestamp without time zone); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.fn_getaccountbalance(p_account_code integer, p_as_of_date timestamp without time zone) FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_getaccountbalance(p_account_code integer, p_as_of_date timestamp without time zone) TO app_readonly;
GRANT ALL ON FUNCTION public.fn_getaccountbalance(p_account_code integer, p_as_of_date timestamp without time zone) TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_getaccountbalance(p_account_code integer, p_as_of_date timestamp without time zone) TO app_admin;
GRANT ALL ON FUNCTION public.fn_getaccountbalance(p_account_code integer, p_as_of_date timestamp without time zone) TO app_auditor;
GRANT ALL ON FUNCTION public.fn_getaccountbalance(p_account_code integer, p_as_of_date timestamp without time zone) TO app_reports;
GRANT ALL ON FUNCTION public.fn_getaccountbalance(p_account_code integer, p_as_of_date timestamp without time zone) TO app_backup;


--
-- Name: FUNCTION fn_getaccountfullpath(p_account_code integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.fn_getaccountfullpath(p_account_code integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_getaccountfullpath(p_account_code integer) TO app_readonly;
GRANT ALL ON FUNCTION public.fn_getaccountfullpath(p_account_code integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_getaccountfullpath(p_account_code integer) TO app_admin;
GRANT ALL ON FUNCTION public.fn_getaccountfullpath(p_account_code integer) TO app_auditor;
GRANT ALL ON FUNCTION public.fn_getaccountfullpath(p_account_code integer) TO app_reports;
GRANT ALL ON FUNCTION public.fn_getaccountfullpath(p_account_code integer) TO app_backup;


--
-- Name: FUNCTION fn_getcategoryfullpath(p_category_code integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.fn_getcategoryfullpath(p_category_code integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_getcategoryfullpath(p_category_code integer) TO app_readonly;
GRANT ALL ON FUNCTION public.fn_getcategoryfullpath(p_category_code integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_getcategoryfullpath(p_category_code integer) TO app_admin;
GRANT ALL ON FUNCTION public.fn_getcategoryfullpath(p_category_code integer) TO app_auditor;
GRANT ALL ON FUNCTION public.fn_getcategoryfullpath(p_category_code integer) TO app_reports;
GRANT ALL ON FUNCTION public.fn_getcategoryfullpath(p_category_code integer) TO app_backup;


--
-- Name: FUNCTION fn_getcustomerbalance(p_customer_code integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.fn_getcustomerbalance(p_customer_code integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_getcustomerbalance(p_customer_code integer) TO app_readonly;
GRANT ALL ON FUNCTION public.fn_getcustomerbalance(p_customer_code integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_getcustomerbalance(p_customer_code integer) TO app_admin;
GRANT ALL ON FUNCTION public.fn_getcustomerbalance(p_customer_code integer) TO app_auditor;
GRANT ALL ON FUNCTION public.fn_getcustomerbalance(p_customer_code integer) TO app_reports;
GRANT ALL ON FUNCTION public.fn_getcustomerbalance(p_customer_code integer) TO app_backup;


--
-- Name: FUNCTION fn_getproductstock(p_product_code integer, p_store_code integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.fn_getproductstock(p_product_code integer, p_store_code integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_getproductstock(p_product_code integer, p_store_code integer) TO app_readonly;
GRANT ALL ON FUNCTION public.fn_getproductstock(p_product_code integer, p_store_code integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_getproductstock(p_product_code integer, p_store_code integer) TO app_admin;
GRANT ALL ON FUNCTION public.fn_getproductstock(p_product_code integer, p_store_code integer) TO app_auditor;
GRANT ALL ON FUNCTION public.fn_getproductstock(p_product_code integer, p_store_code integer) TO app_reports;
GRANT ALL ON FUNCTION public.fn_getproductstock(p_product_code integer, p_store_code integer) TO app_backup;


--
-- Name: FUNCTION fn_getsupplierbalance(p_supplier_code integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.fn_getsupplierbalance(p_supplier_code integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_getsupplierbalance(p_supplier_code integer) TO app_readonly;
GRANT ALL ON FUNCTION public.fn_getsupplierbalance(p_supplier_code integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_getsupplierbalance(p_supplier_code integer) TO app_admin;
GRANT ALL ON FUNCTION public.fn_getsupplierbalance(p_supplier_code integer) TO app_auditor;
GRANT ALL ON FUNCTION public.fn_getsupplierbalance(p_supplier_code integer) TO app_reports;
GRANT ALL ON FUNCTION public.fn_getsupplierbalance(p_supplier_code integer) TO app_backup;


--
-- Name: FUNCTION fn_isuserhasprivilege(p_user_code integer, p_window_code character varying, p_privilege_type character varying); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.fn_isuserhasprivilege(p_user_code integer, p_window_code character varying, p_privilege_type character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION public.fn_isuserhasprivilege(p_user_code integer, p_window_code character varying, p_privilege_type character varying) TO app_readonly;
GRANT ALL ON FUNCTION public.fn_isuserhasprivilege(p_user_code integer, p_window_code character varying, p_privilege_type character varying) TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_isuserhasprivilege(p_user_code integer, p_window_code character varying, p_privilege_type character varying) TO app_admin;
GRANT ALL ON FUNCTION public.fn_isuserhasprivilege(p_user_code integer, p_window_code character varying, p_privilege_type character varying) TO app_auditor;
GRANT ALL ON FUNCTION public.fn_isuserhasprivilege(p_user_code integer, p_window_code character varying, p_privilege_type character varying) TO app_reports;
GRANT ALL ON FUNCTION public.fn_isuserhasprivilege(p_user_code integer, p_window_code character varying, p_privilege_type character varying) TO app_backup;


--
-- Name: FUNCTION fn_pii_decrypt(ciphertext bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_pii_decrypt(ciphertext bytea) TO app_readonly;
GRANT ALL ON FUNCTION public.fn_pii_decrypt(ciphertext bytea) TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_pii_decrypt(ciphertext bytea) TO app_admin;
GRANT ALL ON FUNCTION public.fn_pii_decrypt(ciphertext bytea) TO app_auditor;
GRANT ALL ON FUNCTION public.fn_pii_decrypt(ciphertext bytea) TO app_reports;
GRANT ALL ON FUNCTION public.fn_pii_decrypt(ciphertext bytea) TO app_backup;


--
-- Name: FUNCTION fn_pii_encrypt(plaintext text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_pii_encrypt(plaintext text) TO app_readonly;
GRANT ALL ON FUNCTION public.fn_pii_encrypt(plaintext text) TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_pii_encrypt(plaintext text) TO app_admin;
GRANT ALL ON FUNCTION public.fn_pii_encrypt(plaintext text) TO app_auditor;
GRANT ALL ON FUNCTION public.fn_pii_encrypt(plaintext text) TO app_reports;
GRANT ALL ON FUNCTION public.fn_pii_encrypt(plaintext text) TO app_backup;


--
-- Name: FUNCTION fn_suggest_indexes(min_seq_scans bigint, max_idx_pct numeric); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fn_suggest_indexes(min_seq_scans bigint, max_idx_pct numeric) TO app_readonly;
GRANT ALL ON FUNCTION public.fn_suggest_indexes(min_seq_scans bigint, max_idx_pct numeric) TO app_readwrite;
GRANT ALL ON FUNCTION public.fn_suggest_indexes(min_seq_scans bigint, max_idx_pct numeric) TO app_admin;
GRANT ALL ON FUNCTION public.fn_suggest_indexes(min_seq_scans bigint, max_idx_pct numeric) TO app_auditor;
GRANT ALL ON FUNCTION public.fn_suggest_indexes(min_seq_scans bigint, max_idx_pct numeric) TO app_reports;
GRANT ALL ON FUNCTION public.fn_suggest_indexes(min_seq_scans bigint, max_idx_pct numeric) TO app_backup;


--
-- Name: FUNCTION forceapprovesource(p_sourcetype character varying, p_sourceid bigint, p_approverid integer, p_comments text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.forceapprovesource(p_sourcetype character varying, p_sourceid bigint, p_approverid integer, p_comments text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.forceapprovesource(p_sourcetype character varying, p_sourceid bigint, p_approverid integer, p_comments text) TO app_readonly;
GRANT ALL ON FUNCTION public.forceapprovesource(p_sourcetype character varying, p_sourceid bigint, p_approverid integer, p_comments text) TO app_readwrite;
GRANT ALL ON FUNCTION public.forceapprovesource(p_sourcetype character varying, p_sourceid bigint, p_approverid integer, p_comments text) TO app_admin;
GRANT ALL ON FUNCTION public.forceapprovesource(p_sourcetype character varying, p_sourceid bigint, p_approverid integer, p_comments text) TO app_auditor;
GRANT ALL ON FUNCTION public.forceapprovesource(p_sourcetype character varying, p_sourceid bigint, p_approverid integer, p_comments text) TO app_reports;
GRANT ALL ON FUNCTION public.forceapprovesource(p_sourcetype character varying, p_sourceid bigint, p_approverid integer, p_comments text) TO app_backup;


--
-- Name: FUNCTION gbt_bit_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_bit_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_bit_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_bit_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_bit_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_bit_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_bit_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_bit_consistent(internal, bit, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_bit_consistent(internal, bit, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_bit_consistent(internal, bit, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_bit_consistent(internal, bit, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_bit_consistent(internal, bit, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_bit_consistent(internal, bit, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_bit_consistent(internal, bit, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_bit_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_bit_penalty(internal, internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_bit_penalty(internal, internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_bit_penalty(internal, internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_bit_penalty(internal, internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_bit_penalty(internal, internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_bit_penalty(internal, internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_bit_picksplit(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_bit_picksplit(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_bit_picksplit(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_bit_picksplit(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_bit_picksplit(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_bit_picksplit(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_bit_picksplit(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_bit_same(public.gbtreekey_var, public.gbtreekey_var, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_bit_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_bit_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_bit_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_bit_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_bit_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_bit_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_backup;


--
-- Name: FUNCTION gbt_bit_union(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_bit_union(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_bit_union(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_bit_union(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_bit_union(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_bit_union(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_bit_union(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_bool_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_bool_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_bool_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_bool_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_bool_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_bool_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_bool_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_bool_consistent(internal, boolean, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_bool_consistent(internal, boolean, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_bool_consistent(internal, boolean, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_bool_consistent(internal, boolean, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_bool_consistent(internal, boolean, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_bool_consistent(internal, boolean, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_bool_consistent(internal, boolean, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_bool_fetch(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_bool_fetch(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_bool_fetch(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_bool_fetch(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_bool_fetch(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_bool_fetch(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_bool_fetch(internal) TO app_backup;


--
-- Name: FUNCTION gbt_bool_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_bool_penalty(internal, internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_bool_penalty(internal, internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_bool_penalty(internal, internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_bool_penalty(internal, internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_bool_penalty(internal, internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_bool_penalty(internal, internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_bool_picksplit(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_bool_picksplit(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_bool_picksplit(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_bool_picksplit(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_bool_picksplit(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_bool_picksplit(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_bool_picksplit(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_bool_same(public.gbtreekey2, public.gbtreekey2, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_bool_same(public.gbtreekey2, public.gbtreekey2, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_bool_same(public.gbtreekey2, public.gbtreekey2, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_bool_same(public.gbtreekey2, public.gbtreekey2, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_bool_same(public.gbtreekey2, public.gbtreekey2, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_bool_same(public.gbtreekey2, public.gbtreekey2, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_bool_same(public.gbtreekey2, public.gbtreekey2, internal) TO app_backup;


--
-- Name: FUNCTION gbt_bool_union(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_bool_union(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_bool_union(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_bool_union(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_bool_union(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_bool_union(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_bool_union(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_bpchar_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_bpchar_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_bpchar_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_bpchar_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_bpchar_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_bpchar_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_bpchar_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_bpchar_consistent(internal, character, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_bpchar_consistent(internal, character, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_bpchar_consistent(internal, character, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_bpchar_consistent(internal, character, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_bpchar_consistent(internal, character, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_bpchar_consistent(internal, character, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_bpchar_consistent(internal, character, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_bytea_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_bytea_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_bytea_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_bytea_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_bytea_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_bytea_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_bytea_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_bytea_consistent(internal, bytea, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_bytea_consistent(internal, bytea, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_bytea_consistent(internal, bytea, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_bytea_consistent(internal, bytea, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_bytea_consistent(internal, bytea, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_bytea_consistent(internal, bytea, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_bytea_consistent(internal, bytea, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_bytea_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_bytea_penalty(internal, internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_bytea_penalty(internal, internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_bytea_penalty(internal, internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_bytea_penalty(internal, internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_bytea_penalty(internal, internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_bytea_penalty(internal, internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_bytea_picksplit(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_bytea_picksplit(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_bytea_picksplit(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_bytea_picksplit(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_bytea_picksplit(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_bytea_picksplit(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_bytea_picksplit(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_bytea_same(public.gbtreekey_var, public.gbtreekey_var, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_bytea_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_bytea_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_bytea_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_bytea_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_bytea_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_bytea_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_backup;


--
-- Name: FUNCTION gbt_bytea_union(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_bytea_union(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_bytea_union(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_bytea_union(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_bytea_union(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_bytea_union(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_bytea_union(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_cash_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_cash_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_cash_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_cash_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_cash_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_cash_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_cash_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_cash_consistent(internal, money, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_cash_consistent(internal, money, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_cash_consistent(internal, money, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_cash_consistent(internal, money, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_cash_consistent(internal, money, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_cash_consistent(internal, money, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_cash_consistent(internal, money, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_cash_distance(internal, money, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_cash_distance(internal, money, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_cash_distance(internal, money, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_cash_distance(internal, money, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_cash_distance(internal, money, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_cash_distance(internal, money, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_cash_distance(internal, money, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_cash_fetch(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_cash_fetch(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_cash_fetch(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_cash_fetch(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_cash_fetch(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_cash_fetch(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_cash_fetch(internal) TO app_backup;


--
-- Name: FUNCTION gbt_cash_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_cash_penalty(internal, internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_cash_penalty(internal, internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_cash_penalty(internal, internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_cash_penalty(internal, internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_cash_penalty(internal, internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_cash_penalty(internal, internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_cash_picksplit(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_cash_picksplit(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_cash_picksplit(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_cash_picksplit(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_cash_picksplit(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_cash_picksplit(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_cash_picksplit(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_cash_same(public.gbtreekey16, public.gbtreekey16, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_cash_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_cash_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_cash_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_cash_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_cash_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_cash_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_backup;


--
-- Name: FUNCTION gbt_cash_union(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_cash_union(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_cash_union(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_cash_union(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_cash_union(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_cash_union(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_cash_union(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_date_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_date_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_date_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_date_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_date_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_date_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_date_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_date_consistent(internal, date, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_date_consistent(internal, date, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_date_consistent(internal, date, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_date_consistent(internal, date, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_date_consistent(internal, date, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_date_consistent(internal, date, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_date_consistent(internal, date, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_date_distance(internal, date, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_date_distance(internal, date, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_date_distance(internal, date, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_date_distance(internal, date, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_date_distance(internal, date, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_date_distance(internal, date, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_date_distance(internal, date, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_date_fetch(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_date_fetch(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_date_fetch(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_date_fetch(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_date_fetch(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_date_fetch(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_date_fetch(internal) TO app_backup;


--
-- Name: FUNCTION gbt_date_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_date_penalty(internal, internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_date_penalty(internal, internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_date_penalty(internal, internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_date_penalty(internal, internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_date_penalty(internal, internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_date_penalty(internal, internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_date_picksplit(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_date_picksplit(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_date_picksplit(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_date_picksplit(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_date_picksplit(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_date_picksplit(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_date_picksplit(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_date_same(public.gbtreekey8, public.gbtreekey8, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_date_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_date_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_date_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_date_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_date_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_date_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_backup;


--
-- Name: FUNCTION gbt_date_union(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_date_union(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_date_union(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_date_union(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_date_union(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_date_union(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_date_union(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_decompress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_decompress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_decompress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_decompress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_decompress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_decompress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_decompress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_enum_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_enum_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_enum_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_enum_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_enum_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_enum_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_enum_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_enum_consistent(internal, anyenum, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_enum_consistent(internal, anyenum, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_enum_consistent(internal, anyenum, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_enum_consistent(internal, anyenum, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_enum_consistent(internal, anyenum, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_enum_consistent(internal, anyenum, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_enum_consistent(internal, anyenum, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_enum_fetch(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_enum_fetch(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_enum_fetch(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_enum_fetch(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_enum_fetch(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_enum_fetch(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_enum_fetch(internal) TO app_backup;


--
-- Name: FUNCTION gbt_enum_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_enum_penalty(internal, internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_enum_penalty(internal, internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_enum_penalty(internal, internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_enum_penalty(internal, internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_enum_penalty(internal, internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_enum_penalty(internal, internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_enum_picksplit(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_enum_picksplit(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_enum_picksplit(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_enum_picksplit(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_enum_picksplit(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_enum_picksplit(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_enum_picksplit(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_enum_same(public.gbtreekey8, public.gbtreekey8, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_enum_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_enum_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_enum_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_enum_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_enum_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_enum_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_backup;


--
-- Name: FUNCTION gbt_enum_union(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_enum_union(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_enum_union(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_enum_union(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_enum_union(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_enum_union(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_enum_union(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_float4_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_float4_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_float4_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_float4_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_float4_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_float4_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_float4_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_float4_consistent(internal, real, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_float4_consistent(internal, real, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_float4_consistent(internal, real, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_float4_consistent(internal, real, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_float4_consistent(internal, real, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_float4_consistent(internal, real, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_float4_consistent(internal, real, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_float4_distance(internal, real, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_float4_distance(internal, real, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_float4_distance(internal, real, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_float4_distance(internal, real, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_float4_distance(internal, real, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_float4_distance(internal, real, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_float4_distance(internal, real, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_float4_fetch(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_float4_fetch(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_float4_fetch(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_float4_fetch(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_float4_fetch(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_float4_fetch(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_float4_fetch(internal) TO app_backup;


--
-- Name: FUNCTION gbt_float4_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_float4_penalty(internal, internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_float4_penalty(internal, internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_float4_penalty(internal, internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_float4_penalty(internal, internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_float4_penalty(internal, internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_float4_penalty(internal, internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_float4_picksplit(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_float4_picksplit(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_float4_picksplit(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_float4_picksplit(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_float4_picksplit(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_float4_picksplit(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_float4_picksplit(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_float4_same(public.gbtreekey8, public.gbtreekey8, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_float4_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_float4_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_float4_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_float4_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_float4_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_float4_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_backup;


--
-- Name: FUNCTION gbt_float4_union(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_float4_union(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_float4_union(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_float4_union(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_float4_union(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_float4_union(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_float4_union(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_float8_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_float8_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_float8_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_float8_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_float8_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_float8_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_float8_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_float8_consistent(internal, double precision, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_float8_consistent(internal, double precision, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_float8_consistent(internal, double precision, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_float8_consistent(internal, double precision, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_float8_consistent(internal, double precision, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_float8_consistent(internal, double precision, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_float8_consistent(internal, double precision, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_float8_distance(internal, double precision, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_float8_distance(internal, double precision, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_float8_distance(internal, double precision, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_float8_distance(internal, double precision, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_float8_distance(internal, double precision, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_float8_distance(internal, double precision, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_float8_distance(internal, double precision, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_float8_fetch(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_float8_fetch(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_float8_fetch(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_float8_fetch(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_float8_fetch(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_float8_fetch(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_float8_fetch(internal) TO app_backup;


--
-- Name: FUNCTION gbt_float8_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_float8_penalty(internal, internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_float8_penalty(internal, internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_float8_penalty(internal, internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_float8_penalty(internal, internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_float8_penalty(internal, internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_float8_penalty(internal, internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_float8_picksplit(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_float8_picksplit(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_float8_picksplit(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_float8_picksplit(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_float8_picksplit(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_float8_picksplit(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_float8_picksplit(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_float8_same(public.gbtreekey16, public.gbtreekey16, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_float8_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_float8_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_float8_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_float8_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_float8_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_float8_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_backup;


--
-- Name: FUNCTION gbt_float8_union(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_float8_union(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_float8_union(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_float8_union(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_float8_union(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_float8_union(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_float8_union(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_inet_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_inet_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_inet_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_inet_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_inet_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_inet_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_inet_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_inet_consistent(internal, inet, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_inet_consistent(internal, inet, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_inet_consistent(internal, inet, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_inet_consistent(internal, inet, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_inet_consistent(internal, inet, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_inet_consistent(internal, inet, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_inet_consistent(internal, inet, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_inet_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_inet_penalty(internal, internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_inet_penalty(internal, internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_inet_penalty(internal, internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_inet_penalty(internal, internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_inet_penalty(internal, internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_inet_penalty(internal, internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_inet_picksplit(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_inet_picksplit(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_inet_picksplit(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_inet_picksplit(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_inet_picksplit(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_inet_picksplit(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_inet_picksplit(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_inet_same(public.gbtreekey16, public.gbtreekey16, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_inet_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_inet_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_inet_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_inet_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_inet_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_inet_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_backup;


--
-- Name: FUNCTION gbt_inet_union(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_inet_union(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_inet_union(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_inet_union(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_inet_union(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_inet_union(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_inet_union(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_int2_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int2_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int2_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int2_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int2_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int2_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int2_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_int2_consistent(internal, smallint, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int2_consistent(internal, smallint, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int2_consistent(internal, smallint, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int2_consistent(internal, smallint, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int2_consistent(internal, smallint, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int2_consistent(internal, smallint, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int2_consistent(internal, smallint, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_int2_distance(internal, smallint, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int2_distance(internal, smallint, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int2_distance(internal, smallint, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int2_distance(internal, smallint, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int2_distance(internal, smallint, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int2_distance(internal, smallint, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int2_distance(internal, smallint, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_int2_fetch(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int2_fetch(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int2_fetch(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int2_fetch(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int2_fetch(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int2_fetch(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int2_fetch(internal) TO app_backup;


--
-- Name: FUNCTION gbt_int2_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int2_penalty(internal, internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int2_penalty(internal, internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int2_penalty(internal, internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int2_penalty(internal, internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int2_penalty(internal, internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int2_penalty(internal, internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_int2_picksplit(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int2_picksplit(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int2_picksplit(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int2_picksplit(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int2_picksplit(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int2_picksplit(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int2_picksplit(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_int2_same(public.gbtreekey4, public.gbtreekey4, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int2_same(public.gbtreekey4, public.gbtreekey4, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int2_same(public.gbtreekey4, public.gbtreekey4, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int2_same(public.gbtreekey4, public.gbtreekey4, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int2_same(public.gbtreekey4, public.gbtreekey4, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int2_same(public.gbtreekey4, public.gbtreekey4, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int2_same(public.gbtreekey4, public.gbtreekey4, internal) TO app_backup;


--
-- Name: FUNCTION gbt_int2_union(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int2_union(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int2_union(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int2_union(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int2_union(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int2_union(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int2_union(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_int4_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int4_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int4_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int4_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int4_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int4_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int4_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_int4_consistent(internal, integer, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int4_consistent(internal, integer, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int4_consistent(internal, integer, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int4_consistent(internal, integer, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int4_consistent(internal, integer, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int4_consistent(internal, integer, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int4_consistent(internal, integer, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_int4_distance(internal, integer, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int4_distance(internal, integer, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int4_distance(internal, integer, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int4_distance(internal, integer, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int4_distance(internal, integer, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int4_distance(internal, integer, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int4_distance(internal, integer, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_int4_fetch(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int4_fetch(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int4_fetch(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int4_fetch(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int4_fetch(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int4_fetch(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int4_fetch(internal) TO app_backup;


--
-- Name: FUNCTION gbt_int4_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int4_penalty(internal, internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int4_penalty(internal, internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int4_penalty(internal, internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int4_penalty(internal, internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int4_penalty(internal, internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int4_penalty(internal, internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_int4_picksplit(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int4_picksplit(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int4_picksplit(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int4_picksplit(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int4_picksplit(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int4_picksplit(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int4_picksplit(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_int4_same(public.gbtreekey8, public.gbtreekey8, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int4_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int4_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int4_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int4_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int4_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int4_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_backup;


--
-- Name: FUNCTION gbt_int4_union(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int4_union(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int4_union(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int4_union(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int4_union(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int4_union(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int4_union(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_int8_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int8_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int8_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int8_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int8_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int8_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int8_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_int8_consistent(internal, bigint, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int8_consistent(internal, bigint, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int8_consistent(internal, bigint, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int8_consistent(internal, bigint, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int8_consistent(internal, bigint, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int8_consistent(internal, bigint, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int8_consistent(internal, bigint, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_int8_distance(internal, bigint, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int8_distance(internal, bigint, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int8_distance(internal, bigint, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int8_distance(internal, bigint, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int8_distance(internal, bigint, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int8_distance(internal, bigint, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int8_distance(internal, bigint, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_int8_fetch(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int8_fetch(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int8_fetch(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int8_fetch(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int8_fetch(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int8_fetch(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int8_fetch(internal) TO app_backup;


--
-- Name: FUNCTION gbt_int8_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int8_penalty(internal, internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int8_penalty(internal, internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int8_penalty(internal, internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int8_penalty(internal, internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int8_penalty(internal, internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int8_penalty(internal, internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_int8_picksplit(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int8_picksplit(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int8_picksplit(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int8_picksplit(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int8_picksplit(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int8_picksplit(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int8_picksplit(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_int8_same(public.gbtreekey16, public.gbtreekey16, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int8_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int8_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int8_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int8_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int8_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int8_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_backup;


--
-- Name: FUNCTION gbt_int8_union(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_int8_union(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_int8_union(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_int8_union(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_int8_union(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_int8_union(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_int8_union(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_intv_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_intv_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_intv_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_intv_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_intv_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_intv_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_intv_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_intv_consistent(internal, interval, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_intv_consistent(internal, interval, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_intv_consistent(internal, interval, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_intv_consistent(internal, interval, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_intv_consistent(internal, interval, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_intv_consistent(internal, interval, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_intv_consistent(internal, interval, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_intv_decompress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_intv_decompress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_intv_decompress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_intv_decompress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_intv_decompress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_intv_decompress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_intv_decompress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_intv_distance(internal, interval, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_intv_distance(internal, interval, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_intv_distance(internal, interval, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_intv_distance(internal, interval, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_intv_distance(internal, interval, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_intv_distance(internal, interval, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_intv_distance(internal, interval, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_intv_fetch(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_intv_fetch(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_intv_fetch(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_intv_fetch(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_intv_fetch(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_intv_fetch(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_intv_fetch(internal) TO app_backup;


--
-- Name: FUNCTION gbt_intv_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_intv_penalty(internal, internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_intv_penalty(internal, internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_intv_penalty(internal, internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_intv_penalty(internal, internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_intv_penalty(internal, internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_intv_penalty(internal, internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_intv_picksplit(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_intv_picksplit(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_intv_picksplit(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_intv_picksplit(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_intv_picksplit(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_intv_picksplit(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_intv_picksplit(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_intv_same(public.gbtreekey32, public.gbtreekey32, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_intv_same(public.gbtreekey32, public.gbtreekey32, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_intv_same(public.gbtreekey32, public.gbtreekey32, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_intv_same(public.gbtreekey32, public.gbtreekey32, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_intv_same(public.gbtreekey32, public.gbtreekey32, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_intv_same(public.gbtreekey32, public.gbtreekey32, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_intv_same(public.gbtreekey32, public.gbtreekey32, internal) TO app_backup;


--
-- Name: FUNCTION gbt_intv_union(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_intv_union(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_intv_union(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_intv_union(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_intv_union(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_intv_union(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_intv_union(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_macad8_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_macad8_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_macad8_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_macad8_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_macad8_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_macad8_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_macad8_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_macad8_consistent(internal, macaddr8, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_macad8_consistent(internal, macaddr8, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_macad8_consistent(internal, macaddr8, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_macad8_consistent(internal, macaddr8, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_macad8_consistent(internal, macaddr8, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_macad8_consistent(internal, macaddr8, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_macad8_consistent(internal, macaddr8, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_macad8_fetch(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_macad8_fetch(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_macad8_fetch(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_macad8_fetch(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_macad8_fetch(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_macad8_fetch(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_macad8_fetch(internal) TO app_backup;


--
-- Name: FUNCTION gbt_macad8_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_macad8_penalty(internal, internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_macad8_penalty(internal, internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_macad8_penalty(internal, internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_macad8_penalty(internal, internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_macad8_penalty(internal, internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_macad8_penalty(internal, internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_macad8_picksplit(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_macad8_picksplit(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_macad8_picksplit(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_macad8_picksplit(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_macad8_picksplit(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_macad8_picksplit(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_macad8_picksplit(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_macad8_same(public.gbtreekey16, public.gbtreekey16, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_macad8_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_macad8_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_macad8_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_macad8_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_macad8_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_macad8_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_backup;


--
-- Name: FUNCTION gbt_macad8_union(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_macad8_union(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_macad8_union(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_macad8_union(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_macad8_union(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_macad8_union(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_macad8_union(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_macad_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_macad_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_macad_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_macad_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_macad_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_macad_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_macad_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_macad_consistent(internal, macaddr, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_macad_consistent(internal, macaddr, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_macad_consistent(internal, macaddr, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_macad_consistent(internal, macaddr, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_macad_consistent(internal, macaddr, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_macad_consistent(internal, macaddr, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_macad_consistent(internal, macaddr, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_macad_fetch(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_macad_fetch(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_macad_fetch(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_macad_fetch(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_macad_fetch(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_macad_fetch(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_macad_fetch(internal) TO app_backup;


--
-- Name: FUNCTION gbt_macad_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_macad_penalty(internal, internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_macad_penalty(internal, internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_macad_penalty(internal, internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_macad_penalty(internal, internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_macad_penalty(internal, internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_macad_penalty(internal, internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_macad_picksplit(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_macad_picksplit(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_macad_picksplit(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_macad_picksplit(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_macad_picksplit(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_macad_picksplit(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_macad_picksplit(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_macad_same(public.gbtreekey16, public.gbtreekey16, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_macad_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_macad_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_macad_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_macad_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_macad_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_macad_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_backup;


--
-- Name: FUNCTION gbt_macad_union(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_macad_union(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_macad_union(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_macad_union(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_macad_union(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_macad_union(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_macad_union(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_numeric_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_numeric_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_numeric_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_numeric_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_numeric_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_numeric_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_numeric_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_numeric_consistent(internal, numeric, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_numeric_consistent(internal, numeric, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_numeric_consistent(internal, numeric, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_numeric_consistent(internal, numeric, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_numeric_consistent(internal, numeric, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_numeric_consistent(internal, numeric, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_numeric_consistent(internal, numeric, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_numeric_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_numeric_penalty(internal, internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_numeric_penalty(internal, internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_numeric_penalty(internal, internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_numeric_penalty(internal, internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_numeric_penalty(internal, internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_numeric_penalty(internal, internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_numeric_picksplit(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_numeric_picksplit(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_numeric_picksplit(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_numeric_picksplit(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_numeric_picksplit(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_numeric_picksplit(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_numeric_picksplit(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_numeric_same(public.gbtreekey_var, public.gbtreekey_var, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_numeric_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_numeric_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_numeric_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_numeric_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_numeric_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_numeric_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_backup;


--
-- Name: FUNCTION gbt_numeric_union(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_numeric_union(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_numeric_union(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_numeric_union(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_numeric_union(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_numeric_union(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_numeric_union(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_oid_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_oid_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_oid_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_oid_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_oid_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_oid_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_oid_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_oid_consistent(internal, oid, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_oid_consistent(internal, oid, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_oid_consistent(internal, oid, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_oid_consistent(internal, oid, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_oid_consistent(internal, oid, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_oid_consistent(internal, oid, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_oid_consistent(internal, oid, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_oid_distance(internal, oid, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_oid_distance(internal, oid, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_oid_distance(internal, oid, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_oid_distance(internal, oid, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_oid_distance(internal, oid, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_oid_distance(internal, oid, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_oid_distance(internal, oid, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_oid_fetch(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_oid_fetch(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_oid_fetch(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_oid_fetch(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_oid_fetch(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_oid_fetch(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_oid_fetch(internal) TO app_backup;


--
-- Name: FUNCTION gbt_oid_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_oid_penalty(internal, internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_oid_penalty(internal, internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_oid_penalty(internal, internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_oid_penalty(internal, internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_oid_penalty(internal, internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_oid_penalty(internal, internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_oid_picksplit(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_oid_picksplit(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_oid_picksplit(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_oid_picksplit(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_oid_picksplit(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_oid_picksplit(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_oid_picksplit(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_oid_same(public.gbtreekey8, public.gbtreekey8, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_oid_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_oid_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_oid_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_oid_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_oid_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_oid_same(public.gbtreekey8, public.gbtreekey8, internal) TO app_backup;


--
-- Name: FUNCTION gbt_oid_union(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_oid_union(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_oid_union(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_oid_union(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_oid_union(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_oid_union(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_oid_union(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_text_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_text_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_text_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_text_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_text_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_text_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_text_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_text_consistent(internal, text, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_text_consistent(internal, text, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_text_consistent(internal, text, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_text_consistent(internal, text, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_text_consistent(internal, text, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_text_consistent(internal, text, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_text_consistent(internal, text, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_text_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_text_penalty(internal, internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_text_penalty(internal, internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_text_penalty(internal, internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_text_penalty(internal, internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_text_penalty(internal, internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_text_penalty(internal, internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_text_picksplit(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_text_picksplit(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_text_picksplit(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_text_picksplit(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_text_picksplit(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_text_picksplit(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_text_picksplit(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_text_same(public.gbtreekey_var, public.gbtreekey_var, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_text_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_text_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_text_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_text_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_text_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_text_same(public.gbtreekey_var, public.gbtreekey_var, internal) TO app_backup;


--
-- Name: FUNCTION gbt_text_union(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_text_union(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_text_union(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_text_union(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_text_union(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_text_union(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_text_union(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_time_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_time_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_time_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_time_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_time_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_time_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_time_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_time_consistent(internal, time without time zone, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_time_consistent(internal, time without time zone, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_time_consistent(internal, time without time zone, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_time_consistent(internal, time without time zone, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_time_consistent(internal, time without time zone, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_time_consistent(internal, time without time zone, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_time_consistent(internal, time without time zone, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_time_distance(internal, time without time zone, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_time_distance(internal, time without time zone, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_time_distance(internal, time without time zone, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_time_distance(internal, time without time zone, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_time_distance(internal, time without time zone, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_time_distance(internal, time without time zone, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_time_distance(internal, time without time zone, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_time_fetch(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_time_fetch(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_time_fetch(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_time_fetch(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_time_fetch(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_time_fetch(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_time_fetch(internal) TO app_backup;


--
-- Name: FUNCTION gbt_time_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_time_penalty(internal, internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_time_penalty(internal, internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_time_penalty(internal, internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_time_penalty(internal, internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_time_penalty(internal, internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_time_penalty(internal, internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_time_picksplit(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_time_picksplit(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_time_picksplit(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_time_picksplit(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_time_picksplit(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_time_picksplit(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_time_picksplit(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_time_same(public.gbtreekey16, public.gbtreekey16, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_time_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_time_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_time_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_time_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_time_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_time_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_backup;


--
-- Name: FUNCTION gbt_time_union(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_time_union(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_time_union(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_time_union(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_time_union(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_time_union(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_time_union(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_timetz_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_timetz_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_timetz_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_timetz_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_timetz_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_timetz_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_timetz_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_timetz_consistent(internal, time with time zone, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_timetz_consistent(internal, time with time zone, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_timetz_consistent(internal, time with time zone, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_timetz_consistent(internal, time with time zone, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_timetz_consistent(internal, time with time zone, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_timetz_consistent(internal, time with time zone, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_timetz_consistent(internal, time with time zone, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_ts_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_ts_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_ts_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_ts_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_ts_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_ts_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_ts_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_ts_consistent(internal, timestamp without time zone, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_ts_consistent(internal, timestamp without time zone, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_ts_consistent(internal, timestamp without time zone, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_ts_consistent(internal, timestamp without time zone, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_ts_consistent(internal, timestamp without time zone, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_ts_consistent(internal, timestamp without time zone, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_ts_consistent(internal, timestamp without time zone, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_ts_distance(internal, timestamp without time zone, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_ts_distance(internal, timestamp without time zone, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_ts_distance(internal, timestamp without time zone, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_ts_distance(internal, timestamp without time zone, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_ts_distance(internal, timestamp without time zone, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_ts_distance(internal, timestamp without time zone, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_ts_distance(internal, timestamp without time zone, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_ts_fetch(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_ts_fetch(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_ts_fetch(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_ts_fetch(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_ts_fetch(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_ts_fetch(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_ts_fetch(internal) TO app_backup;


--
-- Name: FUNCTION gbt_ts_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_ts_penalty(internal, internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_ts_penalty(internal, internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_ts_penalty(internal, internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_ts_penalty(internal, internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_ts_penalty(internal, internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_ts_penalty(internal, internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_ts_picksplit(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_ts_picksplit(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_ts_picksplit(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_ts_picksplit(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_ts_picksplit(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_ts_picksplit(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_ts_picksplit(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_ts_same(public.gbtreekey16, public.gbtreekey16, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_ts_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_ts_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_ts_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_ts_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_ts_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_ts_same(public.gbtreekey16, public.gbtreekey16, internal) TO app_backup;


--
-- Name: FUNCTION gbt_ts_union(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_ts_union(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_ts_union(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_ts_union(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_ts_union(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_ts_union(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_ts_union(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_tstz_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_tstz_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_tstz_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_tstz_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_tstz_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_tstz_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_tstz_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_tstz_consistent(internal, timestamp with time zone, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_tstz_consistent(internal, timestamp with time zone, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_tstz_consistent(internal, timestamp with time zone, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_tstz_consistent(internal, timestamp with time zone, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_tstz_consistent(internal, timestamp with time zone, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_tstz_consistent(internal, timestamp with time zone, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_tstz_consistent(internal, timestamp with time zone, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_tstz_distance(internal, timestamp with time zone, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_tstz_distance(internal, timestamp with time zone, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_tstz_distance(internal, timestamp with time zone, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_tstz_distance(internal, timestamp with time zone, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_tstz_distance(internal, timestamp with time zone, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_tstz_distance(internal, timestamp with time zone, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_tstz_distance(internal, timestamp with time zone, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_uuid_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_uuid_compress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_uuid_compress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_uuid_compress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_uuid_compress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_uuid_compress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_uuid_compress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_uuid_consistent(internal, uuid, smallint, oid, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_uuid_consistent(internal, uuid, smallint, oid, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_uuid_consistent(internal, uuid, smallint, oid, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_uuid_consistent(internal, uuid, smallint, oid, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_uuid_consistent(internal, uuid, smallint, oid, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_uuid_consistent(internal, uuid, smallint, oid, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_uuid_consistent(internal, uuid, smallint, oid, internal) TO app_backup;


--
-- Name: FUNCTION gbt_uuid_fetch(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_uuid_fetch(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_uuid_fetch(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_uuid_fetch(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_uuid_fetch(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_uuid_fetch(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_uuid_fetch(internal) TO app_backup;


--
-- Name: FUNCTION gbt_uuid_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_uuid_penalty(internal, internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_uuid_penalty(internal, internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_uuid_penalty(internal, internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_uuid_penalty(internal, internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_uuid_penalty(internal, internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_uuid_penalty(internal, internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_uuid_picksplit(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_uuid_picksplit(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_uuid_picksplit(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_uuid_picksplit(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_uuid_picksplit(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_uuid_picksplit(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_uuid_picksplit(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_uuid_same(public.gbtreekey32, public.gbtreekey32, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_uuid_same(public.gbtreekey32, public.gbtreekey32, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_uuid_same(public.gbtreekey32, public.gbtreekey32, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_uuid_same(public.gbtreekey32, public.gbtreekey32, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_uuid_same(public.gbtreekey32, public.gbtreekey32, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_uuid_same(public.gbtreekey32, public.gbtreekey32, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_uuid_same(public.gbtreekey32, public.gbtreekey32, internal) TO app_backup;


--
-- Name: FUNCTION gbt_uuid_union(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_uuid_union(internal, internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_uuid_union(internal, internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_uuid_union(internal, internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_uuid_union(internal, internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_uuid_union(internal, internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_uuid_union(internal, internal) TO app_backup;


--
-- Name: FUNCTION gbt_var_decompress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_var_decompress(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_var_decompress(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_var_decompress(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_var_decompress(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_var_decompress(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_var_decompress(internal) TO app_backup;


--
-- Name: FUNCTION gbt_var_fetch(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gbt_var_fetch(internal) TO app_readonly;
GRANT ALL ON FUNCTION public.gbt_var_fetch(internal) TO app_readwrite;
GRANT ALL ON FUNCTION public.gbt_var_fetch(internal) TO app_admin;
GRANT ALL ON FUNCTION public.gbt_var_fetch(internal) TO app_auditor;
GRANT ALL ON FUNCTION public.gbt_var_fetch(internal) TO app_reports;
GRANT ALL ON FUNCTION public.gbt_var_fetch(internal) TO app_backup;


--
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.gen_random_bytes(integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.gen_random_bytes(integer) TO app_readonly;
GRANT ALL ON FUNCTION public.gen_random_bytes(integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.gen_random_bytes(integer) TO app_admin;
GRANT ALL ON FUNCTION public.gen_random_bytes(integer) TO app_auditor;
GRANT ALL ON FUNCTION public.gen_random_bytes(integer) TO app_reports;
GRANT ALL ON FUNCTION public.gen_random_bytes(integer) TO app_backup;


--
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.gen_random_uuid() FROM PUBLIC;
GRANT ALL ON FUNCTION public.gen_random_uuid() TO app_readonly;
GRANT ALL ON FUNCTION public.gen_random_uuid() TO app_readwrite;
GRANT ALL ON FUNCTION public.gen_random_uuid() TO app_admin;
GRANT ALL ON FUNCTION public.gen_random_uuid() TO app_auditor;
GRANT ALL ON FUNCTION public.gen_random_uuid() TO app_reports;
GRANT ALL ON FUNCTION public.gen_random_uuid() TO app_backup;


--
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.gen_salt(text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.gen_salt(text) TO app_readonly;
GRANT ALL ON FUNCTION public.gen_salt(text) TO app_readwrite;
GRANT ALL ON FUNCTION public.gen_salt(text) TO app_admin;
GRANT ALL ON FUNCTION public.gen_salt(text) TO app_auditor;
GRANT ALL ON FUNCTION public.gen_salt(text) TO app_reports;
GRANT ALL ON FUNCTION public.gen_salt(text) TO app_backup;


--
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.gen_salt(text, integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.gen_salt(text, integer) TO app_readonly;
GRANT ALL ON FUNCTION public.gen_salt(text, integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.gen_salt(text, integer) TO app_admin;
GRANT ALL ON FUNCTION public.gen_salt(text, integer) TO app_auditor;
GRANT ALL ON FUNCTION public.gen_salt(text, integer) TO app_reports;
GRANT ALL ON FUNCTION public.gen_salt(text, integer) TO app_backup;


--
-- Name: FUNCTION getaccfundcode(p_fundname character varying); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getaccfundcode(p_fundname character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getaccfundcode(p_fundname character varying) TO app_readonly;
GRANT ALL ON FUNCTION public.getaccfundcode(p_fundname character varying) TO app_readwrite;
GRANT ALL ON FUNCTION public.getaccfundcode(p_fundname character varying) TO app_admin;
GRANT ALL ON FUNCTION public.getaccfundcode(p_fundname character varying) TO app_auditor;
GRANT ALL ON FUNCTION public.getaccfundcode(p_fundname character varying) TO app_reports;
GRANT ALL ON FUNCTION public.getaccfundcode(p_fundname character varying) TO app_backup;


--
-- Name: FUNCTION getaccnomax(p_accparentcode integer, p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getaccnomax(p_accparentcode integer, p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getaccnomax(p_accparentcode integer, p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getaccnomax(p_accparentcode integer, p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getaccnomax(p_accparentcode integer, p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getaccnomax(p_accparentcode integer, p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getaccnomax(p_accparentcode integer, p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getaccnomax(p_accparentcode integer, p_bracode integer) TO app_backup;


--
-- Name: FUNCTION getaccountdata(p_bracode integer, p_acccode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getaccountdata(p_bracode integer, p_acccode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getaccountdata(p_bracode integer, p_acccode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getaccountdata(p_bracode integer, p_acccode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getaccountdata(p_bracode integer, p_acccode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getaccountdata(p_bracode integer, p_acccode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getaccountdata(p_bracode integer, p_acccode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getaccountdata(p_bracode integer, p_acccode integer) TO app_backup;


--
-- Name: FUNCTION getaccountsforaccparent(p_acccode integer, p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getaccountsforaccparent(p_acccode integer, p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getaccountsforaccparent(p_acccode integer, p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getaccountsforaccparent(p_acccode integer, p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getaccountsforaccparent(p_acccode integer, p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getaccountsforaccparent(p_acccode integer, p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getaccountsforaccparent(p_acccode integer, p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getaccountsforaccparent(p_acccode integer, p_bracode integer) TO app_backup;


--
-- Name: FUNCTION getaccountsheetreport(p_acccode integer, p_fromdate date, p_todate date, p_exchangerate numeric, p_optype character varying); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getaccountsheetreport(p_acccode integer, p_fromdate date, p_todate date, p_exchangerate numeric, p_optype character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getaccountsheetreport(p_acccode integer, p_fromdate date, p_todate date, p_exchangerate numeric, p_optype character varying) TO app_readonly;
GRANT ALL ON FUNCTION public.getaccountsheetreport(p_acccode integer, p_fromdate date, p_todate date, p_exchangerate numeric, p_optype character varying) TO app_readwrite;
GRANT ALL ON FUNCTION public.getaccountsheetreport(p_acccode integer, p_fromdate date, p_todate date, p_exchangerate numeric, p_optype character varying) TO app_admin;
GRANT ALL ON FUNCTION public.getaccountsheetreport(p_acccode integer, p_fromdate date, p_todate date, p_exchangerate numeric, p_optype character varying) TO app_auditor;
GRANT ALL ON FUNCTION public.getaccountsheetreport(p_acccode integer, p_fromdate date, p_todate date, p_exchangerate numeric, p_optype character varying) TO app_reports;
GRANT ALL ON FUNCTION public.getaccountsheetreport(p_acccode integer, p_fromdate date, p_todate date, p_exchangerate numeric, p_optype character varying) TO app_backup;


--
-- Name: FUNCTION getaccountstatement(p_accountcode integer, p_fromdate date, p_todate date); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getaccountstatement(p_accountcode integer, p_fromdate date, p_todate date) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getaccountstatement(p_accountcode integer, p_fromdate date, p_todate date) TO app_readonly;
GRANT ALL ON FUNCTION public.getaccountstatement(p_accountcode integer, p_fromdate date, p_todate date) TO app_readwrite;
GRANT ALL ON FUNCTION public.getaccountstatement(p_accountcode integer, p_fromdate date, p_todate date) TO app_admin;
GRANT ALL ON FUNCTION public.getaccountstatement(p_accountcode integer, p_fromdate date, p_todate date) TO app_auditor;
GRANT ALL ON FUNCTION public.getaccountstatement(p_accountcode integer, p_fromdate date, p_todate date) TO app_reports;
GRANT ALL ON FUNCTION public.getaccountstatement(p_accountcode integer, p_fromdate date, p_todate date) TO app_backup;


--
-- Name: FUNCTION getallaccounts(p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getallaccounts(p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getallaccounts(p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getallaccounts(p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getallaccounts(p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getallaccounts(p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getallaccounts(p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getallaccounts(p_bracode integer) TO app_backup;


--
-- Name: FUNCTION getallacctypes(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getallacctypes() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getallacctypes() TO app_readonly;
GRANT ALL ON FUNCTION public.getallacctypes() TO app_readwrite;
GRANT ALL ON FUNCTION public.getallacctypes() TO app_admin;
GRANT ALL ON FUNCTION public.getallacctypes() TO app_auditor;
GRANT ALL ON FUNCTION public.getallacctypes() TO app_reports;
GRANT ALL ON FUNCTION public.getallacctypes() TO app_backup;


--
-- Name: FUNCTION getallbanks(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getallbanks() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getallbanks() TO app_readonly;
GRANT ALL ON FUNCTION public.getallbanks() TO app_readwrite;
GRANT ALL ON FUNCTION public.getallbanks() TO app_admin;
GRANT ALL ON FUNCTION public.getallbanks() TO app_auditor;
GRANT ALL ON FUNCTION public.getallbanks() TO app_reports;
GRANT ALL ON FUNCTION public.getallbanks() TO app_backup;


--
-- Name: FUNCTION getallbranches(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getallbranches() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getallbranches() TO app_readonly;
GRANT ALL ON FUNCTION public.getallbranches() TO app_readwrite;
GRANT ALL ON FUNCTION public.getallbranches() TO app_admin;
GRANT ALL ON FUNCTION public.getallbranches() TO app_auditor;
GRANT ALL ON FUNCTION public.getallbranches() TO app_reports;
GRANT ALL ON FUNCTION public.getallbranches() TO app_backup;


--
-- Name: FUNCTION getallbrausers(p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getallbrausers(p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getallbrausers(p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getallbrausers(p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getallbrausers(p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getallbrausers(p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getallbrausers(p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getallbrausers(p_bracode integer) TO app_backup;


--
-- Name: FUNCTION getallbusinessunits(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getallbusinessunits() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getallbusinessunits() TO app_readonly;
GRANT ALL ON FUNCTION public.getallbusinessunits() TO app_readwrite;
GRANT ALL ON FUNCTION public.getallbusinessunits() TO app_admin;
GRANT ALL ON FUNCTION public.getallbusinessunits() TO app_auditor;
GRANT ALL ON FUNCTION public.getallbusinessunits() TO app_reports;
GRANT ALL ON FUNCTION public.getallbusinessunits() TO app_backup;


--
-- Name: FUNCTION getallcurrencies(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getallcurrencies() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getallcurrencies() TO app_readonly;
GRANT ALL ON FUNCTION public.getallcurrencies() TO app_readwrite;
GRANT ALL ON FUNCTION public.getallcurrencies() TO app_admin;
GRANT ALL ON FUNCTION public.getallcurrencies() TO app_auditor;
GRANT ALL ON FUNCTION public.getallcurrencies() TO app_reports;
GRANT ALL ON FUNCTION public.getallcurrencies() TO app_backup;


--
-- Name: FUNCTION getallcurrenciestypes(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getallcurrenciestypes() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getallcurrenciestypes() TO app_readonly;
GRANT ALL ON FUNCTION public.getallcurrenciestypes() TO app_readwrite;
GRANT ALL ON FUNCTION public.getallcurrenciestypes() TO app_admin;
GRANT ALL ON FUNCTION public.getallcurrenciestypes() TO app_auditor;
GRANT ALL ON FUNCTION public.getallcurrenciestypes() TO app_reports;
GRANT ALL ON FUNCTION public.getallcurrenciestypes() TO app_backup;


--
-- Name: FUNCTION getallcustomers(p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getallcustomers(p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getallcustomers(p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getallcustomers(p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getallcustomers(p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getallcustomers(p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getallcustomers(p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getallcustomers(p_bracode integer) TO app_backup;


--
-- Name: FUNCTION getallcutegories(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getallcutegories() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getallcutegories() TO app_readonly;
GRANT ALL ON FUNCTION public.getallcutegories() TO app_readwrite;
GRANT ALL ON FUNCTION public.getallcutegories() TO app_admin;
GRANT ALL ON FUNCTION public.getallcutegories() TO app_auditor;
GRANT ALL ON FUNCTION public.getallcutegories() TO app_reports;
GRANT ALL ON FUNCTION public.getallcutegories() TO app_backup;


--
-- Name: FUNCTION getalldepartments(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getalldepartments() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getalldepartments() TO app_readonly;
GRANT ALL ON FUNCTION public.getalldepartments() TO app_readwrite;
GRANT ALL ON FUNCTION public.getalldepartments() TO app_admin;
GRANT ALL ON FUNCTION public.getalldepartments() TO app_auditor;
GRANT ALL ON FUNCTION public.getalldepartments() TO app_reports;
GRANT ALL ON FUNCTION public.getalldepartments() TO app_backup;


--
-- Name: FUNCTION getalldimensionhierarchies(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getalldimensionhierarchies() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getalldimensionhierarchies() TO app_readonly;
GRANT ALL ON FUNCTION public.getalldimensionhierarchies() TO app_readwrite;
GRANT ALL ON FUNCTION public.getalldimensionhierarchies() TO app_admin;
GRANT ALL ON FUNCTION public.getalldimensionhierarchies() TO app_auditor;
GRANT ALL ON FUNCTION public.getalldimensionhierarchies() TO app_reports;
GRANT ALL ON FUNCTION public.getalldimensionhierarchies() TO app_backup;


--
-- Name: FUNCTION getallfunds(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getallfunds() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getallfunds() TO app_readonly;
GRANT ALL ON FUNCTION public.getallfunds() TO app_readwrite;
GRANT ALL ON FUNCTION public.getallfunds() TO app_admin;
GRANT ALL ON FUNCTION public.getallfunds() TO app_auditor;
GRANT ALL ON FUNCTION public.getallfunds() TO app_reports;
GRANT ALL ON FUNCTION public.getallfunds() TO app_backup;


--
-- Name: FUNCTION getalllists(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getalllists() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getalllists() TO app_readonly;
GRANT ALL ON FUNCTION public.getalllists() TO app_readwrite;
GRANT ALL ON FUNCTION public.getalllists() TO app_admin;
GRANT ALL ON FUNCTION public.getalllists() TO app_auditor;
GRANT ALL ON FUNCTION public.getalllists() TO app_reports;
GRANT ALL ON FUNCTION public.getalllists() TO app_backup;


--
-- Name: FUNCTION getallpaymentmethods(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getallpaymentmethods() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getallpaymentmethods() TO app_readonly;
GRANT ALL ON FUNCTION public.getallpaymentmethods() TO app_readwrite;
GRANT ALL ON FUNCTION public.getallpaymentmethods() TO app_admin;
GRANT ALL ON FUNCTION public.getallpaymentmethods() TO app_auditor;
GRANT ALL ON FUNCTION public.getallpaymentmethods() TO app_reports;
GRANT ALL ON FUNCTION public.getallpaymentmethods() TO app_backup;


--
-- Name: FUNCTION getallprivillages(p_usercode integer, p_bracode integer, p_listid integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getallprivillages(p_usercode integer, p_bracode integer, p_listid integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getallprivillages(p_usercode integer, p_bracode integer, p_listid integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getallprivillages(p_usercode integer, p_bracode integer, p_listid integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getallprivillages(p_usercode integer, p_bracode integer, p_listid integer) TO app_admin;
GRANT ALL ON FUNCTION public.getallprivillages(p_usercode integer, p_bracode integer, p_listid integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getallprivillages(p_usercode integer, p_bracode integer, p_listid integer) TO app_reports;
GRANT ALL ON FUNCTION public.getallprivillages(p_usercode integer, p_bracode integer, p_listid integer) TO app_backup;


--
-- Name: FUNCTION getallproducts(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getallproducts() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getallproducts() TO app_readonly;
GRANT ALL ON FUNCTION public.getallproducts() TO app_readwrite;
GRANT ALL ON FUNCTION public.getallproducts() TO app_admin;
GRANT ALL ON FUNCTION public.getallproducts() TO app_auditor;
GRANT ALL ON FUNCTION public.getallproducts() TO app_reports;
GRANT ALL ON FUNCTION public.getallproducts() TO app_backup;


--
-- Name: FUNCTION getallprofitcenters(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getallprofitcenters() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getallprofitcenters() TO app_readonly;
GRANT ALL ON FUNCTION public.getallprofitcenters() TO app_readwrite;
GRANT ALL ON FUNCTION public.getallprofitcenters() TO app_admin;
GRANT ALL ON FUNCTION public.getallprofitcenters() TO app_auditor;
GRANT ALL ON FUNCTION public.getallprofitcenters() TO app_reports;
GRANT ALL ON FUNCTION public.getallprofitcenters() TO app_backup;


--
-- Name: FUNCTION getallprojects(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getallprojects() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getallprojects() TO app_readonly;
GRANT ALL ON FUNCTION public.getallprojects() TO app_readwrite;
GRANT ALL ON FUNCTION public.getallprojects() TO app_admin;
GRANT ALL ON FUNCTION public.getallprojects() TO app_auditor;
GRANT ALL ON FUNCTION public.getallprojects() TO app_reports;
GRANT ALL ON FUNCTION public.getallprojects() TO app_backup;


--
-- Name: FUNCTION getallreporttypes(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getallreporttypes() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getallreporttypes() TO app_readonly;
GRANT ALL ON FUNCTION public.getallreporttypes() TO app_readwrite;
GRANT ALL ON FUNCTION public.getallreporttypes() TO app_admin;
GRANT ALL ON FUNCTION public.getallreporttypes() TO app_auditor;
GRANT ALL ON FUNCTION public.getallreporttypes() TO app_reports;
GRANT ALL ON FUNCTION public.getallreporttypes() TO app_backup;


--
-- Name: FUNCTION getallsegments(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getallsegments() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getallsegments() TO app_readonly;
GRANT ALL ON FUNCTION public.getallsegments() TO app_readwrite;
GRANT ALL ON FUNCTION public.getallsegments() TO app_admin;
GRANT ALL ON FUNCTION public.getallsegments() TO app_auditor;
GRANT ALL ON FUNCTION public.getallsegments() TO app_reports;
GRANT ALL ON FUNCTION public.getallsegments() TO app_backup;


--
-- Name: FUNCTION getallstores(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getallstores() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getallstores() TO app_readonly;
GRANT ALL ON FUNCTION public.getallstores() TO app_readwrite;
GRANT ALL ON FUNCTION public.getallstores() TO app_admin;
GRANT ALL ON FUNCTION public.getallstores() TO app_auditor;
GRANT ALL ON FUNCTION public.getallstores() TO app_reports;
GRANT ALL ON FUNCTION public.getallstores() TO app_backup;


--
-- Name: FUNCTION getallsuppliers(p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getallsuppliers(p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getallsuppliers(p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getallsuppliers(p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getallsuppliers(p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getallsuppliers(p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getallsuppliers(p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getallsuppliers(p_bracode integer) TO app_backup;


--
-- Name: FUNCTION getallunits(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getallunits() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getallunits() TO app_readonly;
GRANT ALL ON FUNCTION public.getallunits() TO app_readwrite;
GRANT ALL ON FUNCTION public.getallunits() TO app_admin;
GRANT ALL ON FUNCTION public.getallunits() TO app_auditor;
GRANT ALL ON FUNCTION public.getallunits() TO app_reports;
GRANT ALL ON FUNCTION public.getallunits() TO app_backup;


--
-- Name: FUNCTION getallusers(p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getallusers(p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getallusers(p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getallusers(p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getallusers(p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getallusers(p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getallusers(p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getallusers(p_bracode integer) TO app_backup;


--
-- Name: FUNCTION getapprovalconfig(p_key character varying); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getapprovalconfig(p_key character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getapprovalconfig(p_key character varying) TO app_readonly;
GRANT ALL ON FUNCTION public.getapprovalconfig(p_key character varying) TO app_readwrite;
GRANT ALL ON FUNCTION public.getapprovalconfig(p_key character varying) TO app_admin;
GRANT ALL ON FUNCTION public.getapprovalconfig(p_key character varying) TO app_auditor;
GRANT ALL ON FUNCTION public.getapprovalconfig(p_key character varying) TO app_reports;
GRANT ALL ON FUNCTION public.getapprovalconfig(p_key character varying) TO app_backup;


--
-- Name: FUNCTION getapprovalstatus(p_requestid bigint); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getapprovalstatus(p_requestid bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getapprovalstatus(p_requestid bigint) TO app_readonly;
GRANT ALL ON FUNCTION public.getapprovalstatus(p_requestid bigint) TO app_readwrite;
GRANT ALL ON FUNCTION public.getapprovalstatus(p_requestid bigint) TO app_admin;
GRANT ALL ON FUNCTION public.getapprovalstatus(p_requestid bigint) TO app_auditor;
GRANT ALL ON FUNCTION public.getapprovalstatus(p_requestid bigint) TO app_reports;
GRANT ALL ON FUNCTION public.getapprovalstatus(p_requestid bigint) TO app_backup;


--
-- Name: FUNCTION getbillorbondnewno(p_optype integer, p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getbillorbondnewno(p_optype integer, p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getbillorbondnewno(p_optype integer, p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getbillorbondnewno(p_optype integer, p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getbillorbondnewno(p_optype integer, p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getbillorbondnewno(p_optype integer, p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getbillorbondnewno(p_optype integer, p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getbillorbondnewno(p_optype integer, p_bracode integer) TO app_backup;


--
-- Name: FUNCTION getbranchdata(p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getbranchdata(p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getbranchdata(p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getbranchdata(p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getbranchdata(p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getbranchdata(p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getbranchdata(p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getbranchdata(p_bracode integer) TO app_backup;


--
-- Name: FUNCTION getbudgetvsactual(p_periodid integer, p_branchid integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getbudgetvsactual(p_periodid integer, p_branchid integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getbudgetvsactual(p_periodid integer, p_branchid integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getbudgetvsactual(p_periodid integer, p_branchid integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getbudgetvsactual(p_periodid integer, p_branchid integer) TO app_admin;
GRANT ALL ON FUNCTION public.getbudgetvsactual(p_periodid integer, p_branchid integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getbudgetvsactual(p_periodid integer, p_branchid integer) TO app_reports;
GRANT ALL ON FUNCTION public.getbudgetvsactual(p_periodid integer, p_branchid integer) TO app_backup;


--
-- Name: FUNCTION getbusinessunitdata(p_businessunitcode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getbusinessunitdata(p_businessunitcode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getbusinessunitdata(p_businessunitcode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getbusinessunitdata(p_businessunitcode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getbusinessunitdata(p_businessunitcode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getbusinessunitdata(p_businessunitcode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getbusinessunitdata(p_businessunitcode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getbusinessunitdata(p_businessunitcode integer) TO app_backup;


--
-- Name: FUNCTION getbusinessunittree(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getbusinessunittree() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getbusinessunittree() TO app_readonly;
GRANT ALL ON FUNCTION public.getbusinessunittree() TO app_readwrite;
GRANT ALL ON FUNCTION public.getbusinessunittree() TO app_admin;
GRANT ALL ON FUNCTION public.getbusinessunittree() TO app_auditor;
GRANT ALL ON FUNCTION public.getbusinessunittree() TO app_reports;
GRANT ALL ON FUNCTION public.getbusinessunittree() TO app_backup;


--
-- Name: FUNCTION getcashboxbalance(p_cashboxid integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getcashboxbalance(p_cashboxid integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getcashboxbalance(p_cashboxid integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getcashboxbalance(p_cashboxid integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getcashboxbalance(p_cashboxid integer) TO app_admin;
GRANT ALL ON FUNCTION public.getcashboxbalance(p_cashboxid integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getcashboxbalance(p_cashboxid integer) TO app_reports;
GRANT ALL ON FUNCTION public.getcashboxbalance(p_cashboxid integer) TO app_backup;


--
-- Name: FUNCTION getcashpaymentsbydate(p_fromdate date, p_todate date, p_cashboxid integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getcashpaymentsbydate(p_fromdate date, p_todate date, p_cashboxid integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getcashpaymentsbydate(p_fromdate date, p_todate date, p_cashboxid integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getcashpaymentsbydate(p_fromdate date, p_todate date, p_cashboxid integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getcashpaymentsbydate(p_fromdate date, p_todate date, p_cashboxid integer) TO app_admin;
GRANT ALL ON FUNCTION public.getcashpaymentsbydate(p_fromdate date, p_todate date, p_cashboxid integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getcashpaymentsbydate(p_fromdate date, p_todate date, p_cashboxid integer) TO app_reports;
GRANT ALL ON FUNCTION public.getcashpaymentsbydate(p_fromdate date, p_todate date, p_cashboxid integer) TO app_backup;


--
-- Name: FUNCTION getcashreceiptsbydate(p_fromdate date, p_todate date, p_cashboxid integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getcashreceiptsbydate(p_fromdate date, p_todate date, p_cashboxid integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getcashreceiptsbydate(p_fromdate date, p_todate date, p_cashboxid integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getcashreceiptsbydate(p_fromdate date, p_todate date, p_cashboxid integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getcashreceiptsbydate(p_fromdate date, p_todate date, p_cashboxid integer) TO app_admin;
GRANT ALL ON FUNCTION public.getcashreceiptsbydate(p_fromdate date, p_todate date, p_cashboxid integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getcashreceiptsbydate(p_fromdate date, p_todate date, p_cashboxid integer) TO app_reports;
GRANT ALL ON FUNCTION public.getcashreceiptsbydate(p_fromdate date, p_todate date, p_cashboxid integer) TO app_backup;


--
-- Name: FUNCTION getcategorydata(p_catid integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getcategorydata(p_catid integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getcategorydata(p_catid integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getcategorydata(p_catid integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getcategorydata(p_catid integer) TO app_admin;
GRANT ALL ON FUNCTION public.getcategorydata(p_catid integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getcategorydata(p_catid integer) TO app_reports;
GRANT ALL ON FUNCTION public.getcategorydata(p_catid integer) TO app_backup;


--
-- Name: FUNCTION getconversionfactor(p_unitname character varying); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getconversionfactor(p_unitname character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getconversionfactor(p_unitname character varying) TO app_readonly;
GRANT ALL ON FUNCTION public.getconversionfactor(p_unitname character varying) TO app_readwrite;
GRANT ALL ON FUNCTION public.getconversionfactor(p_unitname character varying) TO app_admin;
GRANT ALL ON FUNCTION public.getconversionfactor(p_unitname character varying) TO app_auditor;
GRANT ALL ON FUNCTION public.getconversionfactor(p_unitname character varying) TO app_reports;
GRANT ALL ON FUNCTION public.getconversionfactor(p_unitname character varying) TO app_backup;


--
-- Name: FUNCTION getcurrentapprover(p_requestid bigint); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getcurrentapprover(p_requestid bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getcurrentapprover(p_requestid bigint) TO app_readonly;
GRANT ALL ON FUNCTION public.getcurrentapprover(p_requestid bigint) TO app_readwrite;
GRANT ALL ON FUNCTION public.getcurrentapprover(p_requestid bigint) TO app_admin;
GRANT ALL ON FUNCTION public.getcurrentapprover(p_requestid bigint) TO app_auditor;
GRANT ALL ON FUNCTION public.getcurrentapprover(p_requestid bigint) TO app_reports;
GRANT ALL ON FUNCTION public.getcurrentapprover(p_requestid bigint) TO app_backup;


--
-- Name: FUNCTION getdepartmentdata(p_departmentcode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getdepartmentdata(p_departmentcode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getdepartmentdata(p_departmentcode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getdepartmentdata(p_departmentcode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getdepartmentdata(p_departmentcode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getdepartmentdata(p_departmentcode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getdepartmentdata(p_departmentcode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getdepartmentdata(p_departmentcode integer) TO app_backup;


--
-- Name: FUNCTION getdepartmenttree(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getdepartmenttree() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getdepartmenttree() TO app_readonly;
GRANT ALL ON FUNCTION public.getdepartmenttree() TO app_readwrite;
GRANT ALL ON FUNCTION public.getdepartmenttree() TO app_admin;
GRANT ALL ON FUNCTION public.getdepartmenttree() TO app_auditor;
GRANT ALL ON FUNCTION public.getdepartmenttree() TO app_reports;
GRANT ALL ON FUNCTION public.getdepartmenttree() TO app_backup;


--
-- Name: FUNCTION getdimensionactual(p_dimtype character varying, p_dimcode integer, p_periodid integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getdimensionactual(p_dimtype character varying, p_dimcode integer, p_periodid integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getdimensionactual(p_dimtype character varying, p_dimcode integer, p_periodid integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getdimensionactual(p_dimtype character varying, p_dimcode integer, p_periodid integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getdimensionactual(p_dimtype character varying, p_dimcode integer, p_periodid integer) TO app_admin;
GRANT ALL ON FUNCTION public.getdimensionactual(p_dimtype character varying, p_dimcode integer, p_periodid integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getdimensionactual(p_dimtype character varying, p_dimcode integer, p_periodid integer) TO app_reports;
GRANT ALL ON FUNCTION public.getdimensionactual(p_dimtype character varying, p_dimcode integer, p_periodid integer) TO app_backup;


--
-- Name: FUNCTION getdimensionbudget(p_dimtype character varying, p_dimcode integer, p_periodid integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getdimensionbudget(p_dimtype character varying, p_dimcode integer, p_periodid integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getdimensionbudget(p_dimtype character varying, p_dimcode integer, p_periodid integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getdimensionbudget(p_dimtype character varying, p_dimcode integer, p_periodid integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getdimensionbudget(p_dimtype character varying, p_dimcode integer, p_periodid integer) TO app_admin;
GRANT ALL ON FUNCTION public.getdimensionbudget(p_dimtype character varying, p_dimcode integer, p_periodid integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getdimensionbudget(p_dimtype character varying, p_dimcode integer, p_periodid integer) TO app_reports;
GRANT ALL ON FUNCTION public.getdimensionbudget(p_dimtype character varying, p_dimcode integer, p_periodid integer) TO app_backup;


--
-- Name: FUNCTION getdimensionfullpath(p_dimtype character varying, p_dimcode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getdimensionfullpath(p_dimtype character varying, p_dimcode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getdimensionfullpath(p_dimtype character varying, p_dimcode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getdimensionfullpath(p_dimtype character varying, p_dimcode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getdimensionfullpath(p_dimtype character varying, p_dimcode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getdimensionfullpath(p_dimtype character varying, p_dimcode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getdimensionfullpath(p_dimtype character varying, p_dimcode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getdimensionfullpath(p_dimtype character varying, p_dimcode integer) TO app_backup;


--
-- Name: FUNCTION getdimensionvariance(p_dimtype character varying, p_dimcode integer, p_periodid integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getdimensionvariance(p_dimtype character varying, p_dimcode integer, p_periodid integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getdimensionvariance(p_dimtype character varying, p_dimcode integer, p_periodid integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getdimensionvariance(p_dimtype character varying, p_dimcode integer, p_periodid integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getdimensionvariance(p_dimtype character varying, p_dimcode integer, p_periodid integer) TO app_admin;
GRANT ALL ON FUNCTION public.getdimensionvariance(p_dimtype character varying, p_dimcode integer, p_periodid integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getdimensionvariance(p_dimtype character varying, p_dimcode integer, p_periodid integer) TO app_reports;
GRANT ALL ON FUNCTION public.getdimensionvariance(p_dimtype character varying, p_dimcode integer, p_periodid integer) TO app_backup;


--
-- Name: FUNCTION getdisplayprivillages(p_usercode integer, p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getdisplayprivillages(p_usercode integer, p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getdisplayprivillages(p_usercode integer, p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getdisplayprivillages(p_usercode integer, p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getdisplayprivillages(p_usercode integer, p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getdisplayprivillages(p_usercode integer, p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getdisplayprivillages(p_usercode integer, p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getdisplayprivillages(p_usercode integer, p_bracode integer) TO app_backup;


--
-- Name: FUNCTION getdocumentstatus(p_sourcetype character varying, p_sourceid bigint); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getdocumentstatus(p_sourcetype character varying, p_sourceid bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getdocumentstatus(p_sourcetype character varying, p_sourceid bigint) TO app_readonly;
GRANT ALL ON FUNCTION public.getdocumentstatus(p_sourcetype character varying, p_sourceid bigint) TO app_readwrite;
GRANT ALL ON FUNCTION public.getdocumentstatus(p_sourcetype character varying, p_sourceid bigint) TO app_admin;
GRANT ALL ON FUNCTION public.getdocumentstatus(p_sourcetype character varying, p_sourceid bigint) TO app_auditor;
GRANT ALL ON FUNCTION public.getdocumentstatus(p_sourcetype character varying, p_sourceid bigint) TO app_reports;
GRANT ALL ON FUNCTION public.getdocumentstatus(p_sourcetype character varying, p_sourceid bigint) TO app_backup;


--
-- Name: FUNCTION geteffectiveapprover(p_userid integer, p_workflowid integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.geteffectiveapprover(p_userid integer, p_workflowid integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.geteffectiveapprover(p_userid integer, p_workflowid integer) TO app_readonly;
GRANT ALL ON FUNCTION public.geteffectiveapprover(p_userid integer, p_workflowid integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.geteffectiveapprover(p_userid integer, p_workflowid integer) TO app_admin;
GRANT ALL ON FUNCTION public.geteffectiveapprover(p_userid integer, p_workflowid integer) TO app_auditor;
GRANT ALL ON FUNCTION public.geteffectiveapprover(p_userid integer, p_workflowid integer) TO app_reports;
GRANT ALL ON FUNCTION public.geteffectiveapprover(p_userid integer, p_workflowid integer) TO app_backup;


--
-- Name: FUNCTION getexchangecurrency(p_currname character varying); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getexchangecurrency(p_currname character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getexchangecurrency(p_currname character varying) TO app_readonly;
GRANT ALL ON FUNCTION public.getexchangecurrency(p_currname character varying) TO app_readwrite;
GRANT ALL ON FUNCTION public.getexchangecurrency(p_currname character varying) TO app_admin;
GRANT ALL ON FUNCTION public.getexchangecurrency(p_currname character varying) TO app_auditor;
GRANT ALL ON FUNCTION public.getexchangecurrency(p_currname character varying) TO app_reports;
GRANT ALL ON FUNCTION public.getexchangecurrency(p_currname character varying) TO app_backup;


--
-- Name: FUNCTION getexchangerateatdate(p_currid integer, p_atdate date); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getexchangerateatdate(p_currid integer, p_atdate date) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getexchangerateatdate(p_currid integer, p_atdate date) TO app_readonly;
GRANT ALL ON FUNCTION public.getexchangerateatdate(p_currid integer, p_atdate date) TO app_readwrite;
GRANT ALL ON FUNCTION public.getexchangerateatdate(p_currid integer, p_atdate date) TO app_admin;
GRANT ALL ON FUNCTION public.getexchangerateatdate(p_currid integer, p_atdate date) TO app_auditor;
GRANT ALL ON FUNCTION public.getexchangerateatdate(p_currid integer, p_atdate date) TO app_reports;
GRANT ALL ON FUNCTION public.getexchangerateatdate(p_currid integer, p_atdate date) TO app_backup;


--
-- Name: FUNCTION getfinalaccountreport(p_fromdate date, p_todate date, p_exchangerate numeric, p_bracode integer, p_reporttype integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getfinalaccountreport(p_fromdate date, p_todate date, p_exchangerate numeric, p_bracode integer, p_reporttype integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getfinalaccountreport(p_fromdate date, p_todate date, p_exchangerate numeric, p_bracode integer, p_reporttype integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getfinalaccountreport(p_fromdate date, p_todate date, p_exchangerate numeric, p_bracode integer, p_reporttype integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getfinalaccountreport(p_fromdate date, p_todate date, p_exchangerate numeric, p_bracode integer, p_reporttype integer) TO app_admin;
GRANT ALL ON FUNCTION public.getfinalaccountreport(p_fromdate date, p_todate date, p_exchangerate numeric, p_bracode integer, p_reporttype integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getfinalaccountreport(p_fromdate date, p_todate date, p_exchangerate numeric, p_bracode integer, p_reporttype integer) TO app_reports;
GRANT ALL ON FUNCTION public.getfinalaccountreport(p_fromdate date, p_todate date, p_exchangerate numeric, p_bracode integer, p_reporttype integer) TO app_backup;


--
-- Name: FUNCTION getfundcode(p_fundname character varying); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getfundcode(p_fundname character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getfundcode(p_fundname character varying) TO app_readonly;
GRANT ALL ON FUNCTION public.getfundcode(p_fundname character varying) TO app_readwrite;
GRANT ALL ON FUNCTION public.getfundcode(p_fundname character varying) TO app_admin;
GRANT ALL ON FUNCTION public.getfundcode(p_fundname character varying) TO app_auditor;
GRANT ALL ON FUNCTION public.getfundcode(p_fundname character varying) TO app_reports;
GRANT ALL ON FUNCTION public.getfundcode(p_fundname character varying) TO app_backup;


--
-- Name: FUNCTION getinventorymovement(p_fromdate date, p_todate date, p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getinventorymovement(p_fromdate date, p_todate date, p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getinventorymovement(p_fromdate date, p_todate date, p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getinventorymovement(p_fromdate date, p_todate date, p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getinventorymovement(p_fromdate date, p_todate date, p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getinventorymovement(p_fromdate date, p_todate date, p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getinventorymovement(p_fromdate date, p_todate date, p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getinventorymovement(p_fromdate date, p_todate date, p_bracode integer) TO app_backup;


--
-- Name: FUNCTION getinventoryvaluation(p_branchid integer, p_categorycode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getinventoryvaluation(p_branchid integer, p_categorycode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getinventoryvaluation(p_branchid integer, p_categorycode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getinventoryvaluation(p_branchid integer, p_categorycode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getinventoryvaluation(p_branchid integer, p_categorycode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getinventoryvaluation(p_branchid integer, p_categorycode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getinventoryvaluation(p_branchid integer, p_categorycode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getinventoryvaluation(p_branchid integer, p_categorycode integer) TO app_backup;


--
-- Name: FUNCTION getlistofaccounts(p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getlistofaccounts(p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getlistofaccounts(p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getlistofaccounts(p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getlistofaccounts(p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getlistofaccounts(p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getlistofaccounts(p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getlistofaccounts(p_bracode integer) TO app_backup;


--
-- Name: FUNCTION getmaxbondno(p_bondtype integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getmaxbondno(p_bondtype integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getmaxbondno(p_bondtype integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getmaxbondno(p_bondtype integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getmaxbondno(p_bondtype integer) TO app_admin;
GRANT ALL ON FUNCTION public.getmaxbondno(p_bondtype integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getmaxbondno(p_bondtype integer) TO app_reports;
GRANT ALL ON FUNCTION public.getmaxbondno(p_bondtype integer) TO app_backup;


--
-- Name: FUNCTION getmaximumbillbondno(p_optype integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getmaximumbillbondno(p_optype integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getmaximumbillbondno(p_optype integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getmaximumbillbondno(p_optype integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getmaximumbillbondno(p_optype integer) TO app_admin;
GRANT ALL ON FUNCTION public.getmaximumbillbondno(p_optype integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getmaximumbillbondno(p_optype integer) TO app_reports;
GRANT ALL ON FUNCTION public.getmaximumbillbondno(p_optype integer) TO app_backup;


--
-- Name: FUNCTION getmaximumjno(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getmaximumjno() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getmaximumjno() TO app_readonly;
GRANT ALL ON FUNCTION public.getmaximumjno() TO app_readwrite;
GRANT ALL ON FUNCTION public.getmaximumjno() TO app_admin;
GRANT ALL ON FUNCTION public.getmaximumjno() TO app_auditor;
GRANT ALL ON FUNCTION public.getmaximumjno() TO app_reports;
GRANT ALL ON FUNCTION public.getmaximumjno() TO app_backup;


--
-- Name: FUNCTION getminbondno(p_bondtype integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getminbondno(p_bondtype integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getminbondno(p_bondtype integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getminbondno(p_bondtype integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getminbondno(p_bondtype integer) TO app_admin;
GRANT ALL ON FUNCTION public.getminbondno(p_bondtype integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getminbondno(p_bondtype integer) TO app_reports;
GRANT ALL ON FUNCTION public.getminbondno(p_bondtype integer) TO app_backup;


--
-- Name: FUNCTION getminimumbillbondno(p_optype integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getminimumbillbondno(p_optype integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getminimumbillbondno(p_optype integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getminimumbillbondno(p_optype integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getminimumbillbondno(p_optype integer) TO app_admin;
GRANT ALL ON FUNCTION public.getminimumbillbondno(p_optype integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getminimumbillbondno(p_optype integer) TO app_reports;
GRANT ALL ON FUNCTION public.getminimumbillbondno(p_optype integer) TO app_backup;


--
-- Name: FUNCTION getminimumjno(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getminimumjno() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getminimumjno() TO app_readonly;
GRANT ALL ON FUNCTION public.getminimumjno() TO app_readwrite;
GRANT ALL ON FUNCTION public.getminimumjno() TO app_admin;
GRANT ALL ON FUNCTION public.getminimumjno() TO app_auditor;
GRANT ALL ON FUNCTION public.getminimumjno() TO app_reports;
GRANT ALL ON FUNCTION public.getminimumjno() TO app_backup;


--
-- Name: FUNCTION getnewbondno(p_bracode integer, p_bondtype integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getnewbondno(p_bracode integer, p_bondtype integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getnewbondno(p_bracode integer, p_bondtype integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getnewbondno(p_bracode integer, p_bondtype integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getnewbondno(p_bracode integer, p_bondtype integer) TO app_admin;
GRANT ALL ON FUNCTION public.getnewbondno(p_bracode integer, p_bondtype integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getnewbondno(p_bracode integer, p_bondtype integer) TO app_reports;
GRANT ALL ON FUNCTION public.getnewbondno(p_bracode integer, p_bondtype integer) TO app_backup;


--
-- Name: FUNCTION getnewbranchno(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getnewbranchno() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getnewbranchno() TO app_readonly;
GRANT ALL ON FUNCTION public.getnewbranchno() TO app_readwrite;
GRANT ALL ON FUNCTION public.getnewbranchno() TO app_admin;
GRANT ALL ON FUNCTION public.getnewbranchno() TO app_auditor;
GRANT ALL ON FUNCTION public.getnewbranchno() TO app_reports;
GRANT ALL ON FUNCTION public.getnewbranchno() TO app_backup;


--
-- Name: FUNCTION getnewjournalno(p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getnewjournalno(p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getnewjournalno(p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getnewjournalno(p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getnewjournalno(p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getnewjournalno(p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getnewjournalno(p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getnewjournalno(p_bracode integer) TO app_backup;


--
-- Name: FUNCTION getnextapprovallevel(p_workflowid integer, p_amount numeric); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getnextapprovallevel(p_workflowid integer, p_amount numeric) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getnextapprovallevel(p_workflowid integer, p_amount numeric) TO app_readonly;
GRANT ALL ON FUNCTION public.getnextapprovallevel(p_workflowid integer, p_amount numeric) TO app_readwrite;
GRANT ALL ON FUNCTION public.getnextapprovallevel(p_workflowid integer, p_amount numeric) TO app_admin;
GRANT ALL ON FUNCTION public.getnextapprovallevel(p_workflowid integer, p_amount numeric) TO app_auditor;
GRANT ALL ON FUNCTION public.getnextapprovallevel(p_workflowid integer, p_amount numeric) TO app_reports;
GRANT ALL ON FUNCTION public.getnextapprovallevel(p_workflowid integer, p_amount numeric) TO app_backup;


--
-- Name: FUNCTION getpendingapprovals(p_userid integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getpendingapprovals(p_userid integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getpendingapprovals(p_userid integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getpendingapprovals(p_userid integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getpendingapprovals(p_userid integer) TO app_admin;
GRANT ALL ON FUNCTION public.getpendingapprovals(p_userid integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getpendingapprovals(p_userid integer) TO app_reports;
GRANT ALL ON FUNCTION public.getpendingapprovals(p_userid integer) TO app_backup;


--
-- Name: FUNCTION getpostingbonds(p_fromdate date, p_todate date, p_optype integer, p_poststatus integer, p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getpostingbonds(p_fromdate date, p_todate date, p_optype integer, p_poststatus integer, p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getpostingbonds(p_fromdate date, p_todate date, p_optype integer, p_poststatus integer, p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getpostingbonds(p_fromdate date, p_todate date, p_optype integer, p_poststatus integer, p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getpostingbonds(p_fromdate date, p_todate date, p_optype integer, p_poststatus integer, p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getpostingbonds(p_fromdate date, p_todate date, p_optype integer, p_poststatus integer, p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getpostingbonds(p_fromdate date, p_todate date, p_optype integer, p_poststatus integer, p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getpostingbonds(p_fromdate date, p_todate date, p_optype integer, p_poststatus integer, p_bracode integer) TO app_backup;


--
-- Name: FUNCTION getproductdata(p_searchtext character varying); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getproductdata(p_searchtext character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getproductdata(p_searchtext character varying) TO app_readonly;
GRANT ALL ON FUNCTION public.getproductdata(p_searchtext character varying) TO app_readwrite;
GRANT ALL ON FUNCTION public.getproductdata(p_searchtext character varying) TO app_admin;
GRANT ALL ON FUNCTION public.getproductdata(p_searchtext character varying) TO app_auditor;
GRANT ALL ON FUNCTION public.getproductdata(p_searchtext character varying) TO app_reports;
GRANT ALL ON FUNCTION public.getproductdata(p_searchtext character varying) TO app_backup;


--
-- Name: FUNCTION getproductsinventory(p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getproductsinventory(p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getproductsinventory(p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getproductsinventory(p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getproductsinventory(p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getproductsinventory(p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getproductsinventory(p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getproductsinventory(p_bracode integer) TO app_backup;


--
-- Name: FUNCTION getprofitcenterdata(p_profitcentercode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getprofitcenterdata(p_profitcentercode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getprofitcenterdata(p_profitcentercode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getprofitcenterdata(p_profitcentercode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getprofitcenterdata(p_profitcentercode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getprofitcenterdata(p_profitcentercode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getprofitcenterdata(p_profitcentercode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getprofitcenterdata(p_profitcentercode integer) TO app_backup;


--
-- Name: FUNCTION getprofitcentertree(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getprofitcentertree() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getprofitcentertree() TO app_readonly;
GRANT ALL ON FUNCTION public.getprofitcentertree() TO app_readwrite;
GRANT ALL ON FUNCTION public.getprofitcentertree() TO app_admin;
GRANT ALL ON FUNCTION public.getprofitcentertree() TO app_auditor;
GRANT ALL ON FUNCTION public.getprofitcentertree() TO app_reports;
GRANT ALL ON FUNCTION public.getprofitcentertree() TO app_backup;


--
-- Name: FUNCTION getprojectdata(p_projectcode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getprojectdata(p_projectcode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getprojectdata(p_projectcode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getprojectdata(p_projectcode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getprojectdata(p_projectcode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getprojectdata(p_projectcode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getprojectdata(p_projectcode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getprojectdata(p_projectcode integer) TO app_backup;


--
-- Name: FUNCTION getprojecttree(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getprojecttree() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getprojecttree() TO app_readonly;
GRANT ALL ON FUNCTION public.getprojecttree() TO app_readwrite;
GRANT ALL ON FUNCTION public.getprojecttree() TO app_admin;
GRANT ALL ON FUNCTION public.getprojecttree() TO app_auditor;
GRANT ALL ON FUNCTION public.getprojecttree() TO app_reports;
GRANT ALL ON FUNCTION public.getprojecttree() TO app_backup;


--
-- Name: FUNCTION getpurchasereportbyperiod(p_fromdate date, p_todate date, p_branchid integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getpurchasereportbyperiod(p_fromdate date, p_todate date, p_branchid integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getpurchasereportbyperiod(p_fromdate date, p_todate date, p_branchid integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getpurchasereportbyperiod(p_fromdate date, p_todate date, p_branchid integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getpurchasereportbyperiod(p_fromdate date, p_todate date, p_branchid integer) TO app_admin;
GRANT ALL ON FUNCTION public.getpurchasereportbyperiod(p_fromdate date, p_todate date, p_branchid integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getpurchasereportbyperiod(p_fromdate date, p_todate date, p_branchid integer) TO app_reports;
GRANT ALL ON FUNCTION public.getpurchasereportbyperiod(p_fromdate date, p_todate date, p_branchid integer) TO app_backup;


--
-- Name: FUNCTION getsalesreportbyperiod(p_fromdate date, p_todate date, p_branchid integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getsalesreportbyperiod(p_fromdate date, p_todate date, p_branchid integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getsalesreportbyperiod(p_fromdate date, p_todate date, p_branchid integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getsalesreportbyperiod(p_fromdate date, p_todate date, p_branchid integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getsalesreportbyperiod(p_fromdate date, p_todate date, p_branchid integer) TO app_admin;
GRANT ALL ON FUNCTION public.getsalesreportbyperiod(p_fromdate date, p_todate date, p_branchid integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getsalesreportbyperiod(p_fromdate date, p_todate date, p_branchid integer) TO app_reports;
GRANT ALL ON FUNCTION public.getsalesreportbyperiod(p_fromdate date, p_todate date, p_branchid integer) TO app_backup;


--
-- Name: FUNCTION getscreensprivillages(p_usercode integer, p_windowid integer, p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getscreensprivillages(p_usercode integer, p_windowid integer, p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getscreensprivillages(p_usercode integer, p_windowid integer, p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getscreensprivillages(p_usercode integer, p_windowid integer, p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getscreensprivillages(p_usercode integer, p_windowid integer, p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getscreensprivillages(p_usercode integer, p_windowid integer, p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getscreensprivillages(p_usercode integer, p_windowid integer, p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getscreensprivillages(p_usercode integer, p_windowid integer, p_bracode integer) TO app_backup;


--
-- Name: FUNCTION getsegmentdata(p_segmentcode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getsegmentdata(p_segmentcode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getsegmentdata(p_segmentcode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getsegmentdata(p_segmentcode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getsegmentdata(p_segmentcode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getsegmentdata(p_segmentcode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getsegmentdata(p_segmentcode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getsegmentdata(p_segmentcode integer) TO app_backup;


--
-- Name: FUNCTION getsegmenttree(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getsegmenttree() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getsegmenttree() TO app_readonly;
GRANT ALL ON FUNCTION public.getsegmenttree() TO app_readwrite;
GRANT ALL ON FUNCTION public.getsegmenttree() TO app_admin;
GRANT ALL ON FUNCTION public.getsegmenttree() TO app_auditor;
GRANT ALL ON FUNCTION public.getsegmenttree() TO app_reports;
GRANT ALL ON FUNCTION public.getsegmenttree() TO app_backup;


--
-- Name: FUNCTION gettraibalance(p_fromdate date, p_todate date, p_exchangerate numeric, p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.gettraibalance(p_fromdate date, p_todate date, p_exchangerate numeric, p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.gettraibalance(p_fromdate date, p_todate date, p_exchangerate numeric, p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.gettraibalance(p_fromdate date, p_todate date, p_exchangerate numeric, p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.gettraibalance(p_fromdate date, p_todate date, p_exchangerate numeric, p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.gettraibalance(p_fromdate date, p_todate date, p_exchangerate numeric, p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.gettraibalance(p_fromdate date, p_todate date, p_exchangerate numeric, p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.gettraibalance(p_fromdate date, p_todate date, p_exchangerate numeric, p_bracode integer) TO app_backup;


--
-- Name: FUNCTION gettrialbalancereport(p_fromdate date, p_todate date, p_branchid integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.gettrialbalancereport(p_fromdate date, p_todate date, p_branchid integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.gettrialbalancereport(p_fromdate date, p_todate date, p_branchid integer) TO app_readonly;
GRANT ALL ON FUNCTION public.gettrialbalancereport(p_fromdate date, p_todate date, p_branchid integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.gettrialbalancereport(p_fromdate date, p_todate date, p_branchid integer) TO app_admin;
GRANT ALL ON FUNCTION public.gettrialbalancereport(p_fromdate date, p_todate date, p_branchid integer) TO app_auditor;
GRANT ALL ON FUNCTION public.gettrialbalancereport(p_fromdate date, p_todate date, p_branchid integer) TO app_reports;
GRANT ALL ON FUNCTION public.gettrialbalancereport(p_fromdate date, p_todate date, p_branchid integer) TO app_backup;


--
-- Name: FUNCTION getuserforlogin(p_userid character varying, p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getuserforlogin(p_userid character varying, p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getuserforlogin(p_userid character varying, p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getuserforlogin(p_userid character varying, p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getuserforlogin(p_userid character varying, p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getuserforlogin(p_userid character varying, p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getuserforlogin(p_userid character varying, p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getuserforlogin(p_userid character varying, p_bracode integer) TO app_backup;


--
-- Name: FUNCTION getusernewno(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getusernewno() FROM PUBLIC;
GRANT ALL ON FUNCTION public.getusernewno() TO app_readonly;
GRANT ALL ON FUNCTION public.getusernewno() TO app_readwrite;
GRANT ALL ON FUNCTION public.getusernewno() TO app_admin;
GRANT ALL ON FUNCTION public.getusernewno() TO app_auditor;
GRANT ALL ON FUNCTION public.getusernewno() TO app_reports;
GRANT ALL ON FUNCTION public.getusernewno() TO app_backup;


--
-- Name: FUNCTION getuserno(p_userid character varying); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getuserno(p_userid character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getuserno(p_userid character varying) TO app_readonly;
GRANT ALL ON FUNCTION public.getuserno(p_userid character varying) TO app_readwrite;
GRANT ALL ON FUNCTION public.getuserno(p_userid character varying) TO app_admin;
GRANT ALL ON FUNCTION public.getuserno(p_userid character varying) TO app_auditor;
GRANT ALL ON FUNCTION public.getuserno(p_userid character varying) TO app_reports;
GRANT ALL ON FUNCTION public.getuserno(p_userid character varying) TO app_backup;


--
-- Name: FUNCTION getuserno(p_userid character varying, p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.getuserno(p_userid character varying, p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.getuserno(p_userid character varying, p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.getuserno(p_userid character varying, p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.getuserno(p_userid character varying, p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.getuserno(p_userid character varying, p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.getuserno(p_userid character varying, p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.getuserno(p_userid character varying, p_bracode integer) TO app_backup;


--
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.hmac(bytea, bytea, text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.hmac(bytea, bytea, text) TO app_readonly;
GRANT ALL ON FUNCTION public.hmac(bytea, bytea, text) TO app_readwrite;
GRANT ALL ON FUNCTION public.hmac(bytea, bytea, text) TO app_admin;
GRANT ALL ON FUNCTION public.hmac(bytea, bytea, text) TO app_auditor;
GRANT ALL ON FUNCTION public.hmac(bytea, bytea, text) TO app_reports;
GRANT ALL ON FUNCTION public.hmac(bytea, bytea, text) TO app_backup;


--
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.hmac(text, text, text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.hmac(text, text, text) TO app_readonly;
GRANT ALL ON FUNCTION public.hmac(text, text, text) TO app_readwrite;
GRANT ALL ON FUNCTION public.hmac(text, text, text) TO app_admin;
GRANT ALL ON FUNCTION public.hmac(text, text, text) TO app_auditor;
GRANT ALL ON FUNCTION public.hmac(text, text, text) TO app_reports;
GRANT ALL ON FUNCTION public.hmac(text, text, text) TO app_backup;


--
-- Name: FUNCTION int2_dist(smallint, smallint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.int2_dist(smallint, smallint) TO app_readonly;
GRANT ALL ON FUNCTION public.int2_dist(smallint, smallint) TO app_readwrite;
GRANT ALL ON FUNCTION public.int2_dist(smallint, smallint) TO app_admin;
GRANT ALL ON FUNCTION public.int2_dist(smallint, smallint) TO app_auditor;
GRANT ALL ON FUNCTION public.int2_dist(smallint, smallint) TO app_reports;
GRANT ALL ON FUNCTION public.int2_dist(smallint, smallint) TO app_backup;


--
-- Name: FUNCTION int4_dist(integer, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.int4_dist(integer, integer) TO app_readonly;
GRANT ALL ON FUNCTION public.int4_dist(integer, integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.int4_dist(integer, integer) TO app_admin;
GRANT ALL ON FUNCTION public.int4_dist(integer, integer) TO app_auditor;
GRANT ALL ON FUNCTION public.int4_dist(integer, integer) TO app_reports;
GRANT ALL ON FUNCTION public.int4_dist(integer, integer) TO app_backup;


--
-- Name: FUNCTION int8_dist(bigint, bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.int8_dist(bigint, bigint) TO app_readonly;
GRANT ALL ON FUNCTION public.int8_dist(bigint, bigint) TO app_readwrite;
GRANT ALL ON FUNCTION public.int8_dist(bigint, bigint) TO app_admin;
GRANT ALL ON FUNCTION public.int8_dist(bigint, bigint) TO app_auditor;
GRANT ALL ON FUNCTION public.int8_dist(bigint, bigint) TO app_reports;
GRANT ALL ON FUNCTION public.int8_dist(bigint, bigint) TO app_backup;


--
-- Name: FUNCTION interval_dist(interval, interval); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.interval_dist(interval, interval) TO app_readonly;
GRANT ALL ON FUNCTION public.interval_dist(interval, interval) TO app_readwrite;
GRANT ALL ON FUNCTION public.interval_dist(interval, interval) TO app_admin;
GRANT ALL ON FUNCTION public.interval_dist(interval, interval) TO app_auditor;
GRANT ALL ON FUNCTION public.interval_dist(interval, interval) TO app_reports;
GRANT ALL ON FUNCTION public.interval_dist(interval, interval) TO app_backup;


--
-- Name: FUNCTION isapprovalcomplete(p_requestid bigint); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.isapprovalcomplete(p_requestid bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.isapprovalcomplete(p_requestid bigint) TO app_readonly;
GRANT ALL ON FUNCTION public.isapprovalcomplete(p_requestid bigint) TO app_readwrite;
GRANT ALL ON FUNCTION public.isapprovalcomplete(p_requestid bigint) TO app_admin;
GRANT ALL ON FUNCTION public.isapprovalcomplete(p_requestid bigint) TO app_auditor;
GRANT ALL ON FUNCTION public.isapprovalcomplete(p_requestid bigint) TO app_reports;
GRANT ALL ON FUNCTION public.isapprovalcomplete(p_requestid bigint) TO app_backup;


--
-- Name: FUNCTION issourceapproved(p_sourcetype character varying, p_sourceid bigint); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.issourceapproved(p_sourcetype character varying, p_sourceid bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.issourceapproved(p_sourcetype character varying, p_sourceid bigint) TO app_readonly;
GRANT ALL ON FUNCTION public.issourceapproved(p_sourcetype character varying, p_sourceid bigint) TO app_readwrite;
GRANT ALL ON FUNCTION public.issourceapproved(p_sourcetype character varying, p_sourceid bigint) TO app_admin;
GRANT ALL ON FUNCTION public.issourceapproved(p_sourcetype character varying, p_sourceid bigint) TO app_auditor;
GRANT ALL ON FUNCTION public.issourceapproved(p_sourcetype character varying, p_sourceid bigint) TO app_reports;
GRANT ALL ON FUNCTION public.issourceapproved(p_sourcetype character varying, p_sourceid bigint) TO app_backup;


--
-- Name: FUNCTION oid_dist(oid, oid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.oid_dist(oid, oid) TO app_readonly;
GRANT ALL ON FUNCTION public.oid_dist(oid, oid) TO app_readwrite;
GRANT ALL ON FUNCTION public.oid_dist(oid, oid) TO app_admin;
GRANT ALL ON FUNCTION public.oid_dist(oid, oid) TO app_auditor;
GRANT ALL ON FUNCTION public.oid_dist(oid, oid) TO app_reports;
GRANT ALL ON FUNCTION public.oid_dist(oid, oid) TO app_backup;


--
-- Name: FUNCTION pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO app_readonly;
GRANT ALL ON FUNCTION public.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO app_readwrite;
GRANT ALL ON FUNCTION public.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO app_admin;
GRANT ALL ON FUNCTION public.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO app_auditor;
GRANT ALL ON FUNCTION public.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO app_reports;
GRANT ALL ON FUNCTION public.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO app_backup;


--
-- Name: FUNCTION pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO app_readonly;
GRANT ALL ON FUNCTION public.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO app_readwrite;
GRANT ALL ON FUNCTION public.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO app_admin;
GRANT ALL ON FUNCTION public.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO app_auditor;
GRANT ALL ON FUNCTION public.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO app_reports;
GRANT ALL ON FUNCTION public.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO app_backup;


--
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.pgp_armor_headers(text, OUT key text, OUT value text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.pgp_armor_headers(text, OUT key text, OUT value text) TO app_readonly;
GRANT ALL ON FUNCTION public.pgp_armor_headers(text, OUT key text, OUT value text) TO app_readwrite;
GRANT ALL ON FUNCTION public.pgp_armor_headers(text, OUT key text, OUT value text) TO app_admin;
GRANT ALL ON FUNCTION public.pgp_armor_headers(text, OUT key text, OUT value text) TO app_auditor;
GRANT ALL ON FUNCTION public.pgp_armor_headers(text, OUT key text, OUT value text) TO app_reports;
GRANT ALL ON FUNCTION public.pgp_armor_headers(text, OUT key text, OUT value text) TO app_backup;


--
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.pgp_key_id(bytea) FROM PUBLIC;
GRANT ALL ON FUNCTION public.pgp_key_id(bytea) TO app_readonly;
GRANT ALL ON FUNCTION public.pgp_key_id(bytea) TO app_readwrite;
GRANT ALL ON FUNCTION public.pgp_key_id(bytea) TO app_admin;
GRANT ALL ON FUNCTION public.pgp_key_id(bytea) TO app_auditor;
GRANT ALL ON FUNCTION public.pgp_key_id(bytea) TO app_reports;
GRANT ALL ON FUNCTION public.pgp_key_id(bytea) TO app_backup;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea) FROM PUBLIC;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea) TO app_readonly;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea) TO app_readwrite;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea) TO app_admin;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea) TO app_auditor;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea) TO app_reports;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea) TO app_backup;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) TO app_readonly;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) TO app_readwrite;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) TO app_admin;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) TO app_auditor;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) TO app_reports;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) TO app_backup;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) TO app_readonly;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) TO app_readwrite;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) TO app_admin;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) TO app_auditor;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) TO app_reports;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) TO app_backup;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) FROM PUBLIC;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) TO app_readonly;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) TO app_readwrite;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) TO app_admin;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) TO app_auditor;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) TO app_reports;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) TO app_backup;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) TO app_readonly;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) TO app_readwrite;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) TO app_admin;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) TO app_auditor;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) TO app_reports;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) TO app_backup;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO app_readonly;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO app_readwrite;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO app_admin;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO app_auditor;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO app_reports;
GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO app_backup;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea) FROM PUBLIC;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea) TO app_readonly;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea) TO app_readwrite;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea) TO app_admin;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea) TO app_auditor;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea) TO app_reports;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea) TO app_backup;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea, text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea, text) TO app_readonly;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea, text) TO app_readwrite;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea, text) TO app_admin;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea, text) TO app_auditor;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea, text) TO app_reports;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea, text) TO app_backup;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) FROM PUBLIC;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) TO app_readonly;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) TO app_readwrite;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) TO app_admin;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) TO app_auditor;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) TO app_reports;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) TO app_backup;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) TO app_readonly;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) TO app_readwrite;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) TO app_admin;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) TO app_auditor;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) TO app_reports;
GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) TO app_backup;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text) TO app_readonly;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text) TO app_readwrite;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text) TO app_admin;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text) TO app_auditor;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text) TO app_reports;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text) TO app_backup;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text, text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text, text) TO app_readonly;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text, text) TO app_readwrite;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text, text) TO app_admin;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text, text) TO app_auditor;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text, text) TO app_reports;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text, text) TO app_backup;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) TO app_readonly;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) TO app_readwrite;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) TO app_admin;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) TO app_auditor;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) TO app_reports;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) TO app_backup;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) TO app_readonly;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) TO app_readwrite;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) TO app_admin;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) TO app_auditor;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) TO app_reports;
GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) TO app_backup;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.pgp_sym_encrypt(text, text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text) TO app_readonly;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text) TO app_readwrite;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text) TO app_admin;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text) TO app_auditor;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text) TO app_reports;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text) TO app_backup;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.pgp_sym_encrypt(text, text, text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text, text) TO app_readonly;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text, text) TO app_readwrite;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text, text) TO app_admin;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text, text) TO app_auditor;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text, text) TO app_reports;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text, text) TO app_backup;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) TO app_readonly;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) TO app_readwrite;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) TO app_admin;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) TO app_auditor;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) TO app_reports;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) TO app_backup;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) TO app_readonly;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) TO app_readwrite;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) TO app_admin;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) TO app_auditor;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) TO app_reports;
GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) TO app_backup;


--
-- Name: FUNCTION refresh_critical_mvs(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.refresh_critical_mvs() FROM PUBLIC;
GRANT ALL ON FUNCTION public.refresh_critical_mvs() TO app_readonly;
GRANT ALL ON FUNCTION public.refresh_critical_mvs() TO app_readwrite;
GRANT ALL ON FUNCTION public.refresh_critical_mvs() TO app_admin;
GRANT ALL ON FUNCTION public.refresh_critical_mvs() TO app_auditor;
GRANT ALL ON FUNCTION public.refresh_critical_mvs() TO app_reports;
GRANT ALL ON FUNCTION public.refresh_critical_mvs() TO app_backup;


--
-- Name: FUNCTION searchinaccounts(p_searchtext character varying, p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.searchinaccounts(p_searchtext character varying, p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.searchinaccounts(p_searchtext character varying, p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.searchinaccounts(p_searchtext character varying, p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.searchinaccounts(p_searchtext character varying, p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.searchinaccounts(p_searchtext character varying, p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.searchinaccounts(p_searchtext character varying, p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.searchinaccounts(p_searchtext character varying, p_bracode integer) TO app_backup;


--
-- Name: FUNCTION searchincustomers(p_searchtext character varying, p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.searchincustomers(p_searchtext character varying, p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.searchincustomers(p_searchtext character varying, p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.searchincustomers(p_searchtext character varying, p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.searchincustomers(p_searchtext character varying, p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.searchincustomers(p_searchtext character varying, p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.searchincustomers(p_searchtext character varying, p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.searchincustomers(p_searchtext character varying, p_bracode integer) TO app_backup;


--
-- Name: FUNCTION searchinsuppliers(p_searchtext character varying, p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.searchinsuppliers(p_searchtext character varying, p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.searchinsuppliers(p_searchtext character varying, p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.searchinsuppliers(p_searchtext character varying, p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.searchinsuppliers(p_searchtext character varying, p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.searchinsuppliers(p_searchtext character varying, p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.searchinsuppliers(p_searchtext character varying, p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.searchinsuppliers(p_searchtext character varying, p_bracode integer) TO app_backup;


--
-- Name: FUNCTION setbondispost(p_bondpost integer, p_jno bigint, p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.setbondispost(p_bondpost integer, p_jno bigint, p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.setbondispost(p_bondpost integer, p_jno bigint, p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.setbondispost(p_bondpost integer, p_jno bigint, p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.setbondispost(p_bondpost integer, p_jno bigint, p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.setbondispost(p_bondpost integer, p_jno bigint, p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.setbondispost(p_bondpost integer, p_jno bigint, p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.setbondispost(p_bondpost integer, p_jno bigint, p_bracode integer) TO app_backup;


--
-- Name: FUNCTION showbillbondbody(p_no integer, p_optype integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.showbillbondbody(p_no integer, p_optype integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.showbillbondbody(p_no integer, p_optype integer) TO app_readonly;
GRANT ALL ON FUNCTION public.showbillbondbody(p_no integer, p_optype integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.showbillbondbody(p_no integer, p_optype integer) TO app_admin;
GRANT ALL ON FUNCTION public.showbillbondbody(p_no integer, p_optype integer) TO app_auditor;
GRANT ALL ON FUNCTION public.showbillbondbody(p_no integer, p_optype integer) TO app_reports;
GRANT ALL ON FUNCTION public.showbillbondbody(p_no integer, p_optype integer) TO app_backup;


--
-- Name: FUNCTION showbillbondheader(p_no integer, p_optype integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.showbillbondheader(p_no integer, p_optype integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.showbillbondheader(p_no integer, p_optype integer) TO app_readonly;
GRANT ALL ON FUNCTION public.showbillbondheader(p_no integer, p_optype integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.showbillbondheader(p_no integer, p_optype integer) TO app_admin;
GRANT ALL ON FUNCTION public.showbillbondheader(p_no integer, p_optype integer) TO app_auditor;
GRANT ALL ON FUNCTION public.showbillbondheader(p_no integer, p_optype integer) TO app_reports;
GRANT ALL ON FUNCTION public.showbillbondheader(p_no integer, p_optype integer) TO app_backup;


--
-- Name: FUNCTION showbondbody(p_bondno integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.showbondbody(p_bondno integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.showbondbody(p_bondno integer) TO app_readonly;
GRANT ALL ON FUNCTION public.showbondbody(p_bondno integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.showbondbody(p_bondno integer) TO app_admin;
GRANT ALL ON FUNCTION public.showbondbody(p_bondno integer) TO app_auditor;
GRANT ALL ON FUNCTION public.showbondbody(p_bondno integer) TO app_reports;
GRANT ALL ON FUNCTION public.showbondbody(p_bondno integer) TO app_backup;


--
-- Name: FUNCTION showbondheader(p_bondno integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.showbondheader(p_bondno integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.showbondheader(p_bondno integer) TO app_readonly;
GRANT ALL ON FUNCTION public.showbondheader(p_bondno integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.showbondheader(p_bondno integer) TO app_admin;
GRANT ALL ON FUNCTION public.showbondheader(p_bondno integer) TO app_auditor;
GRANT ALL ON FUNCTION public.showbondheader(p_bondno integer) TO app_reports;
GRANT ALL ON FUNCTION public.showbondheader(p_bondno integer) TO app_backup;


--
-- Name: FUNCTION showjournalbody(p_jno integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.showjournalbody(p_jno integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.showjournalbody(p_jno integer) TO app_readonly;
GRANT ALL ON FUNCTION public.showjournalbody(p_jno integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.showjournalbody(p_jno integer) TO app_admin;
GRANT ALL ON FUNCTION public.showjournalbody(p_jno integer) TO app_auditor;
GRANT ALL ON FUNCTION public.showjournalbody(p_jno integer) TO app_reports;
GRANT ALL ON FUNCTION public.showjournalbody(p_jno integer) TO app_backup;


--
-- Name: FUNCTION showjournalheader(p_jno integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.showjournalheader(p_jno integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.showjournalheader(p_jno integer) TO app_readonly;
GRANT ALL ON FUNCTION public.showjournalheader(p_jno integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.showjournalheader(p_jno integer) TO app_admin;
GRANT ALL ON FUNCTION public.showjournalheader(p_jno integer) TO app_auditor;
GRANT ALL ON FUNCTION public.showjournalheader(p_jno integer) TO app_reports;
GRANT ALL ON FUNCTION public.showjournalheader(p_jno integer) TO app_backup;


--
-- Name: FUNCTION sp_getlowstockproducts(p_store_code integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.sp_getlowstockproducts(p_store_code integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.sp_getlowstockproducts(p_store_code integer) TO app_readonly;
GRANT ALL ON FUNCTION public.sp_getlowstockproducts(p_store_code integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.sp_getlowstockproducts(p_store_code integer) TO app_admin;
GRANT ALL ON FUNCTION public.sp_getlowstockproducts(p_store_code integer) TO app_auditor;
GRANT ALL ON FUNCTION public.sp_getlowstockproducts(p_store_code integer) TO app_reports;
GRANT ALL ON FUNCTION public.sp_getlowstockproducts(p_store_code integer) TO app_backup;


--
-- Name: FUNCTION sp_getproductstock(p_product_code integer, p_store_code integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.sp_getproductstock(p_product_code integer, p_store_code integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.sp_getproductstock(p_product_code integer, p_store_code integer) TO app_readonly;
GRANT ALL ON FUNCTION public.sp_getproductstock(p_product_code integer, p_store_code integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.sp_getproductstock(p_product_code integer, p_store_code integer) TO app_admin;
GRANT ALL ON FUNCTION public.sp_getproductstock(p_product_code integer, p_store_code integer) TO app_auditor;
GRANT ALL ON FUNCTION public.sp_getproductstock(p_product_code integer, p_store_code integer) TO app_reports;
GRANT ALL ON FUNCTION public.sp_getproductstock(p_product_code integer, p_store_code integer) TO app_backup;


--
-- Name: FUNCTION time_dist(time without time zone, time without time zone); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.time_dist(time without time zone, time without time zone) TO app_readonly;
GRANT ALL ON FUNCTION public.time_dist(time without time zone, time without time zone) TO app_readwrite;
GRANT ALL ON FUNCTION public.time_dist(time without time zone, time without time zone) TO app_admin;
GRANT ALL ON FUNCTION public.time_dist(time without time zone, time without time zone) TO app_auditor;
GRANT ALL ON FUNCTION public.time_dist(time without time zone, time without time zone) TO app_reports;
GRANT ALL ON FUNCTION public.time_dist(time without time zone, time without time zone) TO app_backup;


--
-- Name: FUNCTION trg_fn_storeproducts_update(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.trg_fn_storeproducts_update() FROM PUBLIC;
GRANT ALL ON FUNCTION public.trg_fn_storeproducts_update() TO app_readonly;
GRANT ALL ON FUNCTION public.trg_fn_storeproducts_update() TO app_readwrite;
GRANT ALL ON FUNCTION public.trg_fn_storeproducts_update() TO app_admin;
GRANT ALL ON FUNCTION public.trg_fn_storeproducts_update() TO app_auditor;
GRANT ALL ON FUNCTION public.trg_fn_storeproducts_update() TO app_reports;
GRANT ALL ON FUNCTION public.trg_fn_storeproducts_update() TO app_backup;


--
-- Name: FUNCTION trg_fn_users_update(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.trg_fn_users_update() FROM PUBLIC;
GRANT ALL ON FUNCTION public.trg_fn_users_update() TO app_readonly;
GRANT ALL ON FUNCTION public.trg_fn_users_update() TO app_readwrite;
GRANT ALL ON FUNCTION public.trg_fn_users_update() TO app_admin;
GRANT ALL ON FUNCTION public.trg_fn_users_update() TO app_auditor;
GRANT ALL ON FUNCTION public.trg_fn_users_update() TO app_reports;
GRANT ALL ON FUNCTION public.trg_fn_users_update() TO app_backup;


--
-- Name: FUNCTION ts_dist(timestamp without time zone, timestamp without time zone); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.ts_dist(timestamp without time zone, timestamp without time zone) TO app_readonly;
GRANT ALL ON FUNCTION public.ts_dist(timestamp without time zone, timestamp without time zone) TO app_readwrite;
GRANT ALL ON FUNCTION public.ts_dist(timestamp without time zone, timestamp without time zone) TO app_admin;
GRANT ALL ON FUNCTION public.ts_dist(timestamp without time zone, timestamp without time zone) TO app_auditor;
GRANT ALL ON FUNCTION public.ts_dist(timestamp without time zone, timestamp without time zone) TO app_reports;
GRANT ALL ON FUNCTION public.ts_dist(timestamp without time zone, timestamp without time zone) TO app_backup;


--
-- Name: FUNCTION tstz_dist(timestamp with time zone, timestamp with time zone); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.tstz_dist(timestamp with time zone, timestamp with time zone) TO app_readonly;
GRANT ALL ON FUNCTION public.tstz_dist(timestamp with time zone, timestamp with time zone) TO app_readwrite;
GRANT ALL ON FUNCTION public.tstz_dist(timestamp with time zone, timestamp with time zone) TO app_admin;
GRANT ALL ON FUNCTION public.tstz_dist(timestamp with time zone, timestamp with time zone) TO app_auditor;
GRANT ALL ON FUNCTION public.tstz_dist(timestamp with time zone, timestamp with time zone) TO app_reports;
GRANT ALL ON FUNCTION public.tstz_dist(timestamp with time zone, timestamp with time zone) TO app_backup;


--
-- Name: FUNCTION updatebusinessunit(p_businessunitcode integer, p_businessunitid character varying, p_namear character varying, p_nameen character varying, p_parentbusinessunitcode integer, p_isactive boolean, p_notes text, p_edituser integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.updatebusinessunit(p_businessunitcode integer, p_businessunitid character varying, p_namear character varying, p_nameen character varying, p_parentbusinessunitcode integer, p_isactive boolean, p_notes text, p_edituser integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.updatebusinessunit(p_businessunitcode integer, p_businessunitid character varying, p_namear character varying, p_nameen character varying, p_parentbusinessunitcode integer, p_isactive boolean, p_notes text, p_edituser integer) TO app_readonly;
GRANT ALL ON FUNCTION public.updatebusinessunit(p_businessunitcode integer, p_businessunitid character varying, p_namear character varying, p_nameen character varying, p_parentbusinessunitcode integer, p_isactive boolean, p_notes text, p_edituser integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.updatebusinessunit(p_businessunitcode integer, p_businessunitid character varying, p_namear character varying, p_nameen character varying, p_parentbusinessunitcode integer, p_isactive boolean, p_notes text, p_edituser integer) TO app_admin;
GRANT ALL ON FUNCTION public.updatebusinessunit(p_businessunitcode integer, p_businessunitid character varying, p_namear character varying, p_nameen character varying, p_parentbusinessunitcode integer, p_isactive boolean, p_notes text, p_edituser integer) TO app_auditor;
GRANT ALL ON FUNCTION public.updatebusinessunit(p_businessunitcode integer, p_businessunitid character varying, p_namear character varying, p_nameen character varying, p_parentbusinessunitcode integer, p_isactive boolean, p_notes text, p_edituser integer) TO app_reports;
GRANT ALL ON FUNCTION public.updatebusinessunit(p_businessunitcode integer, p_businessunitid character varying, p_namear character varying, p_nameen character varying, p_parentbusinessunitcode integer, p_isactive boolean, p_notes text, p_edituser integer) TO app_backup;


--
-- Name: FUNCTION updatedepartment(p_departmentcode integer, p_departmentid character varying, p_namear character varying, p_nameen character varying, p_parentdepartmentcode integer, p_managerusercode integer, p_isactive boolean, p_effectivedate date, p_enddate date, p_notes text, p_edituser integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.updatedepartment(p_departmentcode integer, p_departmentid character varying, p_namear character varying, p_nameen character varying, p_parentdepartmentcode integer, p_managerusercode integer, p_isactive boolean, p_effectivedate date, p_enddate date, p_notes text, p_edituser integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.updatedepartment(p_departmentcode integer, p_departmentid character varying, p_namear character varying, p_nameen character varying, p_parentdepartmentcode integer, p_managerusercode integer, p_isactive boolean, p_effectivedate date, p_enddate date, p_notes text, p_edituser integer) TO app_readonly;
GRANT ALL ON FUNCTION public.updatedepartment(p_departmentcode integer, p_departmentid character varying, p_namear character varying, p_nameen character varying, p_parentdepartmentcode integer, p_managerusercode integer, p_isactive boolean, p_effectivedate date, p_enddate date, p_notes text, p_edituser integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.updatedepartment(p_departmentcode integer, p_departmentid character varying, p_namear character varying, p_nameen character varying, p_parentdepartmentcode integer, p_managerusercode integer, p_isactive boolean, p_effectivedate date, p_enddate date, p_notes text, p_edituser integer) TO app_admin;
GRANT ALL ON FUNCTION public.updatedepartment(p_departmentcode integer, p_departmentid character varying, p_namear character varying, p_nameen character varying, p_parentdepartmentcode integer, p_managerusercode integer, p_isactive boolean, p_effectivedate date, p_enddate date, p_notes text, p_edituser integer) TO app_auditor;
GRANT ALL ON FUNCTION public.updatedepartment(p_departmentcode integer, p_departmentid character varying, p_namear character varying, p_nameen character varying, p_parentdepartmentcode integer, p_managerusercode integer, p_isactive boolean, p_effectivedate date, p_enddate date, p_notes text, p_edituser integer) TO app_reports;
GRANT ALL ON FUNCTION public.updatedepartment(p_departmentcode integer, p_departmentid character varying, p_namear character varying, p_nameen character varying, p_parentdepartmentcode integer, p_managerusercode integer, p_isactive boolean, p_effectivedate date, p_enddate date, p_notes text, p_edituser integer) TO app_backup;


--
-- Name: FUNCTION updateprofitcenter(p_profitcentercode integer, p_profitcenterid character varying, p_namear character varying, p_nameen character varying, p_parentprofitcentercode integer, p_isactive boolean, p_notes text, p_edituser integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.updateprofitcenter(p_profitcentercode integer, p_profitcenterid character varying, p_namear character varying, p_nameen character varying, p_parentprofitcentercode integer, p_isactive boolean, p_notes text, p_edituser integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.updateprofitcenter(p_profitcentercode integer, p_profitcenterid character varying, p_namear character varying, p_nameen character varying, p_parentprofitcentercode integer, p_isactive boolean, p_notes text, p_edituser integer) TO app_readonly;
GRANT ALL ON FUNCTION public.updateprofitcenter(p_profitcentercode integer, p_profitcenterid character varying, p_namear character varying, p_nameen character varying, p_parentprofitcentercode integer, p_isactive boolean, p_notes text, p_edituser integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.updateprofitcenter(p_profitcentercode integer, p_profitcenterid character varying, p_namear character varying, p_nameen character varying, p_parentprofitcentercode integer, p_isactive boolean, p_notes text, p_edituser integer) TO app_admin;
GRANT ALL ON FUNCTION public.updateprofitcenter(p_profitcentercode integer, p_profitcenterid character varying, p_namear character varying, p_nameen character varying, p_parentprofitcentercode integer, p_isactive boolean, p_notes text, p_edituser integer) TO app_auditor;
GRANT ALL ON FUNCTION public.updateprofitcenter(p_profitcentercode integer, p_profitcenterid character varying, p_namear character varying, p_nameen character varying, p_parentprofitcentercode integer, p_isactive boolean, p_notes text, p_edituser integer) TO app_reports;
GRANT ALL ON FUNCTION public.updateprofitcenter(p_profitcentercode integer, p_profitcenterid character varying, p_namear character varying, p_nameen character varying, p_parentprofitcentercode integer, p_isactive boolean, p_notes text, p_edituser integer) TO app_backup;


--
-- Name: FUNCTION updateproject(p_projectcode integer, p_projectid character varying, p_namear character varying, p_nameen character varying, p_parentprojectcode integer, p_projecttype character varying, p_startdate date, p_enddate date, p_budgetamount numeric, p_actualamount numeric, p_projectstatus character varying, p_isactive boolean, p_notes text, p_edituser integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.updateproject(p_projectcode integer, p_projectid character varying, p_namear character varying, p_nameen character varying, p_parentprojectcode integer, p_projecttype character varying, p_startdate date, p_enddate date, p_budgetamount numeric, p_actualamount numeric, p_projectstatus character varying, p_isactive boolean, p_notes text, p_edituser integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.updateproject(p_projectcode integer, p_projectid character varying, p_namear character varying, p_nameen character varying, p_parentprojectcode integer, p_projecttype character varying, p_startdate date, p_enddate date, p_budgetamount numeric, p_actualamount numeric, p_projectstatus character varying, p_isactive boolean, p_notes text, p_edituser integer) TO app_readonly;
GRANT ALL ON FUNCTION public.updateproject(p_projectcode integer, p_projectid character varying, p_namear character varying, p_nameen character varying, p_parentprojectcode integer, p_projecttype character varying, p_startdate date, p_enddate date, p_budgetamount numeric, p_actualamount numeric, p_projectstatus character varying, p_isactive boolean, p_notes text, p_edituser integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.updateproject(p_projectcode integer, p_projectid character varying, p_namear character varying, p_nameen character varying, p_parentprojectcode integer, p_projecttype character varying, p_startdate date, p_enddate date, p_budgetamount numeric, p_actualamount numeric, p_projectstatus character varying, p_isactive boolean, p_notes text, p_edituser integer) TO app_admin;
GRANT ALL ON FUNCTION public.updateproject(p_projectcode integer, p_projectid character varying, p_namear character varying, p_nameen character varying, p_parentprojectcode integer, p_projecttype character varying, p_startdate date, p_enddate date, p_budgetamount numeric, p_actualamount numeric, p_projectstatus character varying, p_isactive boolean, p_notes text, p_edituser integer) TO app_auditor;
GRANT ALL ON FUNCTION public.updateproject(p_projectcode integer, p_projectid character varying, p_namear character varying, p_nameen character varying, p_parentprojectcode integer, p_projecttype character varying, p_startdate date, p_enddate date, p_budgetamount numeric, p_actualamount numeric, p_projectstatus character varying, p_isactive boolean, p_notes text, p_edituser integer) TO app_reports;
GRANT ALL ON FUNCTION public.updateproject(p_projectcode integer, p_projectid character varying, p_namear character varying, p_nameen character varying, p_parentprojectcode integer, p_projecttype character varying, p_startdate date, p_enddate date, p_budgetamount numeric, p_actualamount numeric, p_projectstatus character varying, p_isactive boolean, p_notes text, p_edituser integer) TO app_backup;


--
-- Name: FUNCTION updatesegment(p_segmentcode integer, p_segmentid character varying, p_namear character varying, p_nameen character varying, p_segmenttype character varying, p_parentsegmentcode integer, p_isactive boolean, p_notes text, p_edituser integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.updatesegment(p_segmentcode integer, p_segmentid character varying, p_namear character varying, p_nameen character varying, p_segmenttype character varying, p_parentsegmentcode integer, p_isactive boolean, p_notes text, p_edituser integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.updatesegment(p_segmentcode integer, p_segmentid character varying, p_namear character varying, p_nameen character varying, p_segmenttype character varying, p_parentsegmentcode integer, p_isactive boolean, p_notes text, p_edituser integer) TO app_readonly;
GRANT ALL ON FUNCTION public.updatesegment(p_segmentcode integer, p_segmentid character varying, p_namear character varying, p_nameen character varying, p_segmenttype character varying, p_parentsegmentcode integer, p_isactive boolean, p_notes text, p_edituser integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.updatesegment(p_segmentcode integer, p_segmentid character varying, p_namear character varying, p_nameen character varying, p_segmenttype character varying, p_parentsegmentcode integer, p_isactive boolean, p_notes text, p_edituser integer) TO app_admin;
GRANT ALL ON FUNCTION public.updatesegment(p_segmentcode integer, p_segmentid character varying, p_namear character varying, p_nameen character varying, p_segmenttype character varying, p_parentsegmentcode integer, p_isactive boolean, p_notes text, p_edituser integer) TO app_auditor;
GRANT ALL ON FUNCTION public.updatesegment(p_segmentcode integer, p_segmentid character varying, p_namear character varying, p_nameen character varying, p_segmenttype character varying, p_parentsegmentcode integer, p_isactive boolean, p_notes text, p_edituser integer) TO app_reports;
GRANT ALL ON FUNCTION public.updatesegment(p_segmentcode integer, p_segmentid character varying, p_namear character varying, p_nameen character varying, p_segmenttype character varying, p_parentsegmentcode integer, p_isactive boolean, p_notes text, p_edituser integer) TO app_backup;


--
-- Name: FUNCTION validatealldimensions(p_departmentcode integer, p_projectcode integer, p_businessunitcode integer, p_segmentcode integer, p_profitcentercode integer, p_costcentercode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.validatealldimensions(p_departmentcode integer, p_projectcode integer, p_businessunitcode integer, p_segmentcode integer, p_profitcentercode integer, p_costcentercode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.validatealldimensions(p_departmentcode integer, p_projectcode integer, p_businessunitcode integer, p_segmentcode integer, p_profitcentercode integer, p_costcentercode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.validatealldimensions(p_departmentcode integer, p_projectcode integer, p_businessunitcode integer, p_segmentcode integer, p_profitcentercode integer, p_costcentercode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.validatealldimensions(p_departmentcode integer, p_projectcode integer, p_businessunitcode integer, p_segmentcode integer, p_profitcentercode integer, p_costcentercode integer) TO app_admin;
GRANT ALL ON FUNCTION public.validatealldimensions(p_departmentcode integer, p_projectcode integer, p_businessunitcode integer, p_segmentcode integer, p_profitcentercode integer, p_costcentercode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.validatealldimensions(p_departmentcode integer, p_projectcode integer, p_businessunitcode integer, p_segmentcode integer, p_profitcentercode integer, p_costcentercode integer) TO app_reports;
GRANT ALL ON FUNCTION public.validatealldimensions(p_departmentcode integer, p_projectcode integer, p_businessunitcode integer, p_segmentcode integer, p_profitcentercode integer, p_costcentercode integer) TO app_backup;


--
-- Name: FUNCTION validatedimension(p_dimtype character varying, p_dimcode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.validatedimension(p_dimtype character varying, p_dimcode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.validatedimension(p_dimtype character varying, p_dimcode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.validatedimension(p_dimtype character varying, p_dimcode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.validatedimension(p_dimtype character varying, p_dimcode integer) TO app_admin;
GRANT ALL ON FUNCTION public.validatedimension(p_dimtype character varying, p_dimcode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.validatedimension(p_dimtype character varying, p_dimcode integer) TO app_reports;
GRANT ALL ON FUNCTION public.validatedimension(p_dimtype character varying, p_dimcode integer) TO app_backup;


--
-- Name: FUNCTION validatesession(p_sessiontoken uuid); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.validatesession(p_sessiontoken uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.validatesession(p_sessiontoken uuid) TO app_readonly;
GRANT ALL ON FUNCTION public.validatesession(p_sessiontoken uuid) TO app_readwrite;
GRANT ALL ON FUNCTION public.validatesession(p_sessiontoken uuid) TO app_admin;
GRANT ALL ON FUNCTION public.validatesession(p_sessiontoken uuid) TO app_auditor;
GRANT ALL ON FUNCTION public.validatesession(p_sessiontoken uuid) TO app_reports;
GRANT ALL ON FUNCTION public.validatesession(p_sessiontoken uuid) TO app_backup;


--
-- Name: FUNCTION verifyaccountfoundinjournalbady(p_acccode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.verifyaccountfoundinjournalbady(p_acccode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.verifyaccountfoundinjournalbady(p_acccode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.verifyaccountfoundinjournalbady(p_acccode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.verifyaccountfoundinjournalbady(p_acccode integer) TO app_admin;
GRANT ALL ON FUNCTION public.verifyaccountfoundinjournalbady(p_acccode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.verifyaccountfoundinjournalbady(p_acccode integer) TO app_reports;
GRANT ALL ON FUNCTION public.verifyaccountfoundinjournalbady(p_acccode integer) TO app_backup;


--
-- Name: FUNCTION verifyaccounthavechildren(p_acccode integer, p_bracode integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.verifyaccounthavechildren(p_acccode integer, p_bracode integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.verifyaccounthavechildren(p_acccode integer, p_bracode integer) TO app_readonly;
GRANT ALL ON FUNCTION public.verifyaccounthavechildren(p_acccode integer, p_bracode integer) TO app_readwrite;
GRANT ALL ON FUNCTION public.verifyaccounthavechildren(p_acccode integer, p_bracode integer) TO app_admin;
GRANT ALL ON FUNCTION public.verifyaccounthavechildren(p_acccode integer, p_bracode integer) TO app_auditor;
GRANT ALL ON FUNCTION public.verifyaccounthavechildren(p_acccode integer, p_bracode integer) TO app_reports;
GRANT ALL ON FUNCTION public.verifyaccounthavechildren(p_acccode integer, p_bracode integer) TO app_backup;


--
-- Name: TABLE tblaccounts; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblaccounts TO app_readonly;
GRANT SELECT ON TABLE public.tblaccounts TO app_auditor;
GRANT SELECT ON TABLE public.tblaccounts TO app_reports;
GRANT SELECT ON TABLE public.tblaccounts TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblaccounts TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblaccounts TO app_admin;


--
-- Name: TABLE mv_account_balances; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.mv_account_balances TO app_readonly;
GRANT SELECT ON TABLE public.mv_account_balances TO app_auditor;
GRANT SELECT ON TABLE public.mv_account_balances TO app_reports;
GRANT SELECT ON TABLE public.mv_account_balances TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.mv_account_balances TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.mv_account_balances TO app_admin;


--
-- Name: TABLE tblbudgets; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblbudgets TO app_readonly;
GRANT SELECT ON TABLE public.tblbudgets TO app_auditor;
GRANT SELECT ON TABLE public.tblbudgets TO app_reports;
GRANT SELECT ON TABLE public.tblbudgets TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblbudgets TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblbudgets TO app_admin;


--
-- Name: TABLE mv_budget_vs_actual_summary; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.mv_budget_vs_actual_summary TO app_readonly;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.mv_budget_vs_actual_summary TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.mv_budget_vs_actual_summary TO app_admin;
GRANT SELECT ON TABLE public.mv_budget_vs_actual_summary TO app_auditor;
GRANT SELECT ON TABLE public.mv_budget_vs_actual_summary TO app_reports;
GRANT SELECT ON TABLE public.mv_budget_vs_actual_summary TO app_backup;


--
-- Name: TABLE mv_chart_of_accounts; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.mv_chart_of_accounts TO app_readonly;
GRANT SELECT ON TABLE public.mv_chart_of_accounts TO app_auditor;
GRANT SELECT ON TABLE public.mv_chart_of_accounts TO app_reports;
GRANT SELECT ON TABLE public.mv_chart_of_accounts TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.mv_chart_of_accounts TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.mv_chart_of_accounts TO app_admin;


--
-- Name: TABLE tbloperationheader; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tbloperationheader TO app_readonly;
GRANT SELECT ON TABLE public.tbloperationheader TO app_auditor;
GRANT SELECT ON TABLE public.tbloperationheader TO app_reports;
GRANT SELECT ON TABLE public.tbloperationheader TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbloperationheader TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbloperationheader TO app_admin;


--
-- Name: TABLE mv_customer_outstanding_balance; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.mv_customer_outstanding_balance TO app_readonly;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.mv_customer_outstanding_balance TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.mv_customer_outstanding_balance TO app_admin;
GRANT SELECT ON TABLE public.mv_customer_outstanding_balance TO app_auditor;
GRANT SELECT ON TABLE public.mv_customer_outstanding_balance TO app_reports;
GRANT SELECT ON TABLE public.mv_customer_outstanding_balance TO app_backup;


--
-- Name: TABLE mv_daily_sales_summary; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.mv_daily_sales_summary TO app_readonly;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.mv_daily_sales_summary TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.mv_daily_sales_summary TO app_admin;
GRANT SELECT ON TABLE public.mv_daily_sales_summary TO app_auditor;
GRANT SELECT ON TABLE public.mv_daily_sales_summary TO app_reports;
GRANT SELECT ON TABLE public.mv_daily_sales_summary TO app_backup;


--
-- Name: TABLE mv_final_accounts; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.mv_final_accounts TO app_readonly;
GRANT SELECT ON TABLE public.mv_final_accounts TO app_auditor;
GRANT SELECT ON TABLE public.mv_final_accounts TO app_reports;
GRANT SELECT ON TABLE public.mv_final_accounts TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.mv_final_accounts TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.mv_final_accounts TO app_admin;


--
-- Name: TABLE tbljournalheader; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tbljournalheader TO app_readonly;
GRANT SELECT ON TABLE public.tbljournalheader TO app_auditor;
GRANT SELECT ON TABLE public.tbljournalheader TO app_reports;
GRANT SELECT ON TABLE public.tbljournalheader TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbljournalheader TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbljournalheader TO app_admin;


--
-- Name: TABLE mv_journal_summary; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.mv_journal_summary TO app_readonly;
GRANT SELECT ON TABLE public.mv_journal_summary TO app_auditor;
GRANT SELECT ON TABLE public.mv_journal_summary TO app_reports;
GRANT SELECT ON TABLE public.mv_journal_summary TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.mv_journal_summary TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.mv_journal_summary TO app_admin;


--
-- Name: TABLE tblstoreproducts; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblstoreproducts TO app_readonly;
GRANT SELECT ON TABLE public.tblstoreproducts TO app_auditor;
GRANT SELECT ON TABLE public.tblstoreproducts TO app_reports;
GRANT SELECT ON TABLE public.tblstoreproducts TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblstoreproducts TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblstoreproducts TO app_admin;


--
-- Name: TABLE mv_monthly_inventory_snapshot; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.mv_monthly_inventory_snapshot TO app_readonly;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.mv_monthly_inventory_snapshot TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.mv_monthly_inventory_snapshot TO app_admin;
GRANT SELECT ON TABLE public.mv_monthly_inventory_snapshot TO app_auditor;
GRANT SELECT ON TABLE public.mv_monthly_inventory_snapshot TO app_reports;
GRANT SELECT ON TABLE public.mv_monthly_inventory_snapshot TO app_backup;


--
-- Name: TABLE tblbankaccounts; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblbankaccounts TO app_readonly;
GRANT SELECT ON TABLE public.tblbankaccounts TO app_auditor;
GRANT SELECT ON TABLE public.tblbankaccounts TO app_reports;
GRANT SELECT ON TABLE public.tblbankaccounts TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblbankaccounts TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblbankaccounts TO app_admin;


--
-- Name: TABLE tblcashboxes; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblcashboxes TO app_readonly;
GRANT SELECT ON TABLE public.tblcashboxes TO app_auditor;
GRANT SELECT ON TABLE public.tblcashboxes TO app_reports;
GRANT SELECT ON TABLE public.tblcashboxes TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblcashboxes TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblcashboxes TO app_admin;


--
-- Name: TABLE mv_treasury_position; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.mv_treasury_position TO app_readonly;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.mv_treasury_position TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.mv_treasury_position TO app_admin;
GRANT SELECT ON TABLE public.mv_treasury_position TO app_auditor;
GRANT SELECT ON TABLE public.mv_treasury_position TO app_reports;
GRANT SELECT ON TABLE public.mv_treasury_position TO app_backup;


--
-- Name: TABLE mv_trial_balance; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.mv_trial_balance TO app_readonly;
GRANT SELECT ON TABLE public.mv_trial_balance TO app_auditor;
GRANT SELECT ON TABLE public.mv_trial_balance TO app_reports;
GRANT SELECT ON TABLE public.mv_trial_balance TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.mv_trial_balance TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.mv_trial_balance TO app_admin;


--
-- Name: SEQUENCE tblaccounts_accountcode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblaccounts_accountcode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblaccounts_accountcode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblaccounts_accountcode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblaccounts_accountcode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblaccounts_accountcode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblaccounts_accountcode_seq TO app_backup;


--
-- Name: TABLE tblapprovalactions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblapprovalactions TO app_readonly;
GRANT SELECT ON TABLE public.tblapprovalactions TO app_auditor;
GRANT SELECT ON TABLE public.tblapprovalactions TO app_reports;
GRANT SELECT ON TABLE public.tblapprovalactions TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblapprovalactions TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblapprovalactions TO app_admin;


--
-- Name: SEQUENCE tblapprovalactions_actionid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalactions_actionid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalactions_actionid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalactions_actionid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalactions_actionid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalactions_actionid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalactions_actionid_seq TO app_backup;


--
-- Name: TABLE tblapprovalaudit; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblapprovalaudit TO app_readonly;
GRANT SELECT ON TABLE public.tblapprovalaudit TO app_auditor;
GRANT SELECT ON TABLE public.tblapprovalaudit TO app_reports;
GRANT SELECT ON TABLE public.tblapprovalaudit TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblapprovalaudit TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblapprovalaudit TO app_admin;


--
-- Name: SEQUENCE tblapprovalaudit_auditid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalaudit_auditid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalaudit_auditid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalaudit_auditid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalaudit_auditid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalaudit_auditid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalaudit_auditid_seq TO app_backup;


--
-- Name: TABLE tblapprovalconfig; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblapprovalconfig TO app_readonly;
GRANT SELECT ON TABLE public.tblapprovalconfig TO app_auditor;
GRANT SELECT ON TABLE public.tblapprovalconfig TO app_reports;
GRANT SELECT ON TABLE public.tblapprovalconfig TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblapprovalconfig TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblapprovalconfig TO app_admin;


--
-- Name: SEQUENCE tblapprovalconfig_configid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalconfig_configid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalconfig_configid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalconfig_configid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalconfig_configid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalconfig_configid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalconfig_configid_seq TO app_backup;


--
-- Name: TABLE tblapprovaldelegations; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblapprovaldelegations TO app_readonly;
GRANT SELECT ON TABLE public.tblapprovaldelegations TO app_auditor;
GRANT SELECT ON TABLE public.tblapprovaldelegations TO app_reports;
GRANT SELECT ON TABLE public.tblapprovaldelegations TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblapprovaldelegations TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblapprovaldelegations TO app_admin;


--
-- Name: SEQUENCE tblapprovaldelegations_delegationid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblapprovaldelegations_delegationid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovaldelegations_delegationid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovaldelegations_delegationid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovaldelegations_delegationid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovaldelegations_delegationid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovaldelegations_delegationid_seq TO app_backup;


--
-- Name: TABLE tblapprovallevels; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblapprovallevels TO app_readonly;
GRANT SELECT ON TABLE public.tblapprovallevels TO app_auditor;
GRANT SELECT ON TABLE public.tblapprovallevels TO app_reports;
GRANT SELECT ON TABLE public.tblapprovallevels TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblapprovallevels TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblapprovallevels TO app_admin;


--
-- Name: SEQUENCE tblapprovallevels_levelid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblapprovallevels_levelid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovallevels_levelid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovallevels_levelid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovallevels_levelid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovallevels_levelid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovallevels_levelid_seq TO app_backup;


--
-- Name: TABLE tblapprovalrequests; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblapprovalrequests TO app_readonly;
GRANT SELECT ON TABLE public.tblapprovalrequests TO app_auditor;
GRANT SELECT ON TABLE public.tblapprovalrequests TO app_reports;
GRANT SELECT ON TABLE public.tblapprovalrequests TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblapprovalrequests TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblapprovalrequests TO app_admin;


--
-- Name: SEQUENCE tblapprovalrequests_requestid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalrequests_requestid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalrequests_requestid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalrequests_requestid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalrequests_requestid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalrequests_requestid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalrequests_requestid_seq TO app_backup;


--
-- Name: TABLE tblapprovalworkflows; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblapprovalworkflows TO app_readonly;
GRANT SELECT ON TABLE public.tblapprovalworkflows TO app_auditor;
GRANT SELECT ON TABLE public.tblapprovalworkflows TO app_reports;
GRANT SELECT ON TABLE public.tblapprovalworkflows TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblapprovalworkflows TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblapprovalworkflows TO app_admin;


--
-- Name: SEQUENCE tblapprovalworkflows_workflowid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalworkflows_workflowid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalworkflows_workflowid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalworkflows_workflowid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalworkflows_workflowid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalworkflows_workflowid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblapprovalworkflows_workflowid_seq TO app_backup;


--
-- Name: TABLE tblaudi; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblaudi TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblaudi TO app_admin;
GRANT SELECT ON TABLE public.tblaudi TO app_auditor;


--
-- Name: SEQUENCE tblaudi_audithistid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblaudi_audithistid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblaudi_audithistid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblaudi_audithistid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblaudi_audithistid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblaudi_audithistid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblaudi_audithistid_seq TO app_backup;


--
-- Name: TABLE tblaudi_security; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblaudi_security TO app_readonly;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblaudi_security TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblaudi_security TO app_admin;
GRANT SELECT ON TABLE public.tblaudi_security TO app_auditor;
GRANT SELECT ON TABLE public.tblaudi_security TO app_reports;
GRANT SELECT ON TABLE public.tblaudi_security TO app_backup;


--
-- Name: SEQUENCE tblaudi_security_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblaudi_security_id_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblaudi_security_id_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblaudi_security_id_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblaudi_security_id_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblaudi_security_id_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblaudi_security_id_seq TO app_backup;


--
-- Name: TABLE tblauditlogs; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblauditlogs TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblauditlogs TO app_admin;
GRANT SELECT ON TABLE public.tblauditlogs TO app_auditor;


--
-- Name: SEQUENCE tblauditlogs_auditid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblauditlogs_auditid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblauditlogs_auditid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblauditlogs_auditid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblauditlogs_auditid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblauditlogs_auditid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblauditlogs_auditid_seq TO app_backup;


--
-- Name: SEQUENCE tblbankaccounts_bankaccountid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblbankaccounts_bankaccountid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblbankaccounts_bankaccountid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblbankaccounts_bankaccountid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblbankaccounts_bankaccountid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblbankaccounts_bankaccountid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblbankaccounts_bankaccountid_seq TO app_backup;


--
-- Name: TABLE tblbankreconciliations; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblbankreconciliations TO app_readonly;
GRANT SELECT ON TABLE public.tblbankreconciliations TO app_auditor;
GRANT SELECT ON TABLE public.tblbankreconciliations TO app_reports;
GRANT SELECT ON TABLE public.tblbankreconciliations TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblbankreconciliations TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblbankreconciliations TO app_admin;


--
-- Name: SEQUENCE tblbankreconciliations_reconid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblbankreconciliations_reconid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblbankreconciliations_reconid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblbankreconciliations_reconid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblbankreconciliations_reconid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblbankreconciliations_reconid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblbankreconciliations_reconid_seq TO app_backup;


--
-- Name: TABLE tblbanks; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblbanks TO app_readonly;
GRANT SELECT ON TABLE public.tblbanks TO app_auditor;
GRANT SELECT ON TABLE public.tblbanks TO app_reports;
GRANT SELECT ON TABLE public.tblbanks TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblbanks TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblbanks TO app_admin;


--
-- Name: SEQUENCE tblbanks_bankcode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblbanks_bankcode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblbanks_bankcode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblbanks_bankcode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblbanks_bankcode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblbanks_bankcode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblbanks_bankcode_seq TO app_backup;


--
-- Name: TABLE tblbankstatementlines; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblbankstatementlines TO app_readonly;
GRANT SELECT ON TABLE public.tblbankstatementlines TO app_auditor;
GRANT SELECT ON TABLE public.tblbankstatementlines TO app_reports;
GRANT SELECT ON TABLE public.tblbankstatementlines TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblbankstatementlines TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblbankstatementlines TO app_admin;


--
-- Name: SEQUENCE tblbankstatementlines_stmtlineid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblbankstatementlines_stmtlineid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblbankstatementlines_stmtlineid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblbankstatementlines_stmtlineid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblbankstatementlines_stmtlineid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblbankstatementlines_stmtlineid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblbankstatementlines_stmtlineid_seq TO app_backup;


--
-- Name: TABLE tblbankstatements; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblbankstatements TO app_readonly;
GRANT SELECT ON TABLE public.tblbankstatements TO app_auditor;
GRANT SELECT ON TABLE public.tblbankstatements TO app_reports;
GRANT SELECT ON TABLE public.tblbankstatements TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblbankstatements TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblbankstatements TO app_admin;


--
-- Name: SEQUENCE tblbankstatements_statementid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblbankstatements_statementid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblbankstatements_statementid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblbankstatements_statementid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblbankstatements_statementid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblbankstatements_statementid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblbankstatements_statementid_seq TO app_backup;


--
-- Name: TABLE tblbanktransactions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblbanktransactions TO app_readonly;
GRANT SELECT ON TABLE public.tblbanktransactions TO app_auditor;
GRANT SELECT ON TABLE public.tblbanktransactions TO app_reports;
GRANT SELECT ON TABLE public.tblbanktransactions TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblbanktransactions TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblbanktransactions TO app_admin;


--
-- Name: SEQUENCE tblbanktransactions_banktxnid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblbanktransactions_banktxnid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblbanktransactions_banktxnid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblbanktransactions_banktxnid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblbanktransactions_banktxnid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblbanktransactions_banktxnid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblbanktransactions_banktxnid_seq TO app_backup;


--
-- Name: TABLE tblbondbody; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblbondbody TO app_readonly;
GRANT SELECT ON TABLE public.tblbondbody TO app_auditor;
GRANT SELECT ON TABLE public.tblbondbody TO app_reports;
GRANT SELECT ON TABLE public.tblbondbody TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblbondbody TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblbondbody TO app_admin;


--
-- Name: SEQUENCE tblbondbody_bonddetailid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblbondbody_bonddetailid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblbondbody_bonddetailid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblbondbody_bonddetailid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblbondbody_bonddetailid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblbondbody_bonddetailid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblbondbody_bonddetailid_seq TO app_backup;


--
-- Name: TABLE tblbondheader; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblbondheader TO app_readonly;
GRANT SELECT ON TABLE public.tblbondheader TO app_auditor;
GRANT SELECT ON TABLE public.tblbondheader TO app_reports;
GRANT SELECT ON TABLE public.tblbondheader TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblbondheader TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblbondheader TO app_admin;


--
-- Name: SEQUENCE tblbondheader_bondcode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblbondheader_bondcode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblbondheader_bondcode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblbondheader_bondcode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblbondheader_bondcode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblbondheader_bondcode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblbondheader_bondcode_seq TO app_backup;


--
-- Name: TABLE tblbranches; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblbranches TO app_readonly;
GRANT SELECT ON TABLE public.tblbranches TO app_auditor;
GRANT SELECT ON TABLE public.tblbranches TO app_reports;
GRANT SELECT ON TABLE public.tblbranches TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblbranches TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblbranches TO app_admin;


--
-- Name: SEQUENCE tblbranches_branchcode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblbranches_branchcode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblbranches_branchcode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblbranches_branchcode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblbranches_branchcode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblbranches_branchcode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblbranches_branchcode_seq TO app_backup;


--
-- Name: TABLE tblbudgetperiods; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblbudgetperiods TO app_readonly;
GRANT SELECT ON TABLE public.tblbudgetperiods TO app_auditor;
GRANT SELECT ON TABLE public.tblbudgetperiods TO app_reports;
GRANT SELECT ON TABLE public.tblbudgetperiods TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblbudgetperiods TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblbudgetperiods TO app_admin;


--
-- Name: SEQUENCE tblbudgetperiods_periodid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblbudgetperiods_periodid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblbudgetperiods_periodid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblbudgetperiods_periodid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblbudgetperiods_periodid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblbudgetperiods_periodid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblbudgetperiods_periodid_seq TO app_backup;


--
-- Name: SEQUENCE tblbudgets_budgetid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblbudgets_budgetid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblbudgets_budgetid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblbudgets_budgetid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblbudgets_budgetid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblbudgets_budgetid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblbudgets_budgetid_seq TO app_backup;


--
-- Name: SEQUENCE tblcashboxes_cashboxid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblcashboxes_cashboxid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblcashboxes_cashboxid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblcashboxes_cashboxid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblcashboxes_cashboxid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblcashboxes_cashboxid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblcashboxes_cashboxid_seq TO app_backup;


--
-- Name: TABLE tblcashpayments; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblcashpayments TO app_readonly;
GRANT SELECT ON TABLE public.tblcashpayments TO app_auditor;
GRANT SELECT ON TABLE public.tblcashpayments TO app_reports;
GRANT SELECT ON TABLE public.tblcashpayments TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblcashpayments TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblcashpayments TO app_admin;


--
-- Name: SEQUENCE tblcashpayments_paymentid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblcashpayments_paymentid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblcashpayments_paymentid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblcashpayments_paymentid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblcashpayments_paymentid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblcashpayments_paymentid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblcashpayments_paymentid_seq TO app_backup;


--
-- Name: TABLE tblcashreceipts; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblcashreceipts TO app_readonly;
GRANT SELECT ON TABLE public.tblcashreceipts TO app_auditor;
GRANT SELECT ON TABLE public.tblcashreceipts TO app_reports;
GRANT SELECT ON TABLE public.tblcashreceipts TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblcashreceipts TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblcashreceipts TO app_admin;


--
-- Name: SEQUENCE tblcashreceipts_receiptid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblcashreceipts_receiptid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblcashreceipts_receiptid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblcashreceipts_receiptid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblcashreceipts_receiptid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblcashreceipts_receiptid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblcashreceipts_receiptid_seq TO app_backup;


--
-- Name: TABLE tblcategories; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblcategories TO app_readonly;
GRANT SELECT ON TABLE public.tblcategories TO app_auditor;
GRANT SELECT ON TABLE public.tblcategories TO app_reports;
GRANT SELECT ON TABLE public.tblcategories TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblcategories TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblcategories TO app_admin;


--
-- Name: SEQUENCE tblcategories_categorycode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblcategories_categorycode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblcategories_categorycode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblcategories_categorycode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblcategories_categorycode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblcategories_categorycode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblcategories_categorycode_seq TO app_backup;


--
-- Name: TABLE tblcompanies; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblcompanies TO app_readonly;
GRANT SELECT ON TABLE public.tblcompanies TO app_auditor;
GRANT SELECT ON TABLE public.tblcompanies TO app_reports;
GRANT SELECT ON TABLE public.tblcompanies TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblcompanies TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblcompanies TO app_admin;


--
-- Name: SEQUENCE tblcompanies_companycode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblcompanies_companycode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblcompanies_companycode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblcompanies_companycode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblcompanies_companycode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblcompanies_companycode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblcompanies_companycode_seq TO app_backup;


--
-- Name: TABLE tblcostcenters; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblcostcenters TO app_readonly;
GRANT SELECT ON TABLE public.tblcostcenters TO app_auditor;
GRANT SELECT ON TABLE public.tblcostcenters TO app_reports;
GRANT SELECT ON TABLE public.tblcostcenters TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblcostcenters TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblcostcenters TO app_admin;


--
-- Name: SEQUENCE tblcostcenters_costcentercode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblcostcenters_costcentercode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblcostcenters_costcentercode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblcostcenters_costcentercode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblcostcenters_costcentercode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblcostcenters_costcentercode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblcostcenters_costcentercode_seq TO app_backup;


--
-- Name: TABLE tblcurrencies; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblcurrencies TO app_readonly;
GRANT SELECT ON TABLE public.tblcurrencies TO app_auditor;
GRANT SELECT ON TABLE public.tblcurrencies TO app_reports;
GRANT SELECT ON TABLE public.tblcurrencies TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblcurrencies TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblcurrencies TO app_admin;


--
-- Name: SEQUENCE tblcurrencies_currencycode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblcurrencies_currencycode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblcurrencies_currencycode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblcurrencies_currencycode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblcurrencies_currencycode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblcurrencies_currencycode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblcurrencies_currencycode_seq TO app_backup;


--
-- Name: TABLE tblcustomercontacts; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblcustomercontacts TO app_readonly;
GRANT SELECT ON TABLE public.tblcustomercontacts TO app_auditor;
GRANT SELECT ON TABLE public.tblcustomercontacts TO app_reports;
GRANT SELECT ON TABLE public.tblcustomercontacts TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblcustomercontacts TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblcustomercontacts TO app_admin;


--
-- Name: SEQUENCE tblcustomercontacts_contactid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblcustomercontacts_contactid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblcustomercontacts_contactid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblcustomercontacts_contactid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblcustomercontacts_contactid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblcustomercontacts_contactid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblcustomercontacts_contactid_seq TO app_backup;


--
-- Name: TABLE tblcustomers; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblcustomers TO app_readonly;
GRANT SELECT ON TABLE public.tblcustomers TO app_auditor;
GRANT SELECT ON TABLE public.tblcustomers TO app_reports;
GRANT SELECT ON TABLE public.tblcustomers TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblcustomers TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblcustomers TO app_admin;


--
-- Name: SEQUENCE tblcustomers_customercode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblcustomers_customercode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblcustomers_customercode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblcustomers_customercode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblcustomers_customercode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblcustomers_customercode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblcustomers_customercode_seq TO app_backup;


--
-- Name: TABLE tbldim_businessunits; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tbldim_businessunits TO app_readonly;
GRANT SELECT ON TABLE public.tbldim_businessunits TO app_auditor;
GRANT SELECT ON TABLE public.tbldim_businessunits TO app_reports;
GRANT SELECT ON TABLE public.tbldim_businessunits TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbldim_businessunits TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbldim_businessunits TO app_admin;


--
-- Name: SEQUENCE tbldim_businessunits_businessunitcode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tbldim_businessunits_businessunitcode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_businessunits_businessunitcode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_businessunits_businessunitcode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_businessunits_businessunitcode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_businessunits_businessunitcode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_businessunits_businessunitcode_seq TO app_backup;


--
-- Name: TABLE tbldim_departments; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tbldim_departments TO app_readonly;
GRANT SELECT ON TABLE public.tbldim_departments TO app_auditor;
GRANT SELECT ON TABLE public.tbldim_departments TO app_reports;
GRANT SELECT ON TABLE public.tbldim_departments TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbldim_departments TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbldim_departments TO app_admin;


--
-- Name: SEQUENCE tbldim_departments_departmentcode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tbldim_departments_departmentcode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_departments_departmentcode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_departments_departmentcode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_departments_departmentcode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_departments_departmentcode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_departments_departmentcode_seq TO app_backup;


--
-- Name: TABLE tbldim_hierarchies; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tbldim_hierarchies TO app_readonly;
GRANT SELECT ON TABLE public.tbldim_hierarchies TO app_auditor;
GRANT SELECT ON TABLE public.tbldim_hierarchies TO app_reports;
GRANT SELECT ON TABLE public.tbldim_hierarchies TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbldim_hierarchies TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbldim_hierarchies TO app_admin;


--
-- Name: SEQUENCE tbldim_hierarchies_hierarchyid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tbldim_hierarchies_hierarchyid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_hierarchies_hierarchyid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_hierarchies_hierarchyid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_hierarchies_hierarchyid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_hierarchies_hierarchyid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_hierarchies_hierarchyid_seq TO app_backup;


--
-- Name: TABLE tbldim_profitcenters; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tbldim_profitcenters TO app_readonly;
GRANT SELECT ON TABLE public.tbldim_profitcenters TO app_auditor;
GRANT SELECT ON TABLE public.tbldim_profitcenters TO app_reports;
GRANT SELECT ON TABLE public.tbldim_profitcenters TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbldim_profitcenters TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbldim_profitcenters TO app_admin;


--
-- Name: SEQUENCE tbldim_profitcenters_profitcentercode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tbldim_profitcenters_profitcentercode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_profitcenters_profitcentercode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_profitcenters_profitcentercode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_profitcenters_profitcentercode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_profitcenters_profitcentercode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_profitcenters_profitcentercode_seq TO app_backup;


--
-- Name: TABLE tbldim_projects; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tbldim_projects TO app_readonly;
GRANT SELECT ON TABLE public.tbldim_projects TO app_auditor;
GRANT SELECT ON TABLE public.tbldim_projects TO app_reports;
GRANT SELECT ON TABLE public.tbldim_projects TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbldim_projects TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbldim_projects TO app_admin;


--
-- Name: SEQUENCE tbldim_projects_projectcode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tbldim_projects_projectcode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_projects_projectcode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_projects_projectcode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_projects_projectcode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_projects_projectcode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_projects_projectcode_seq TO app_backup;


--
-- Name: TABLE tbldim_segments; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tbldim_segments TO app_readonly;
GRANT SELECT ON TABLE public.tbldim_segments TO app_auditor;
GRANT SELECT ON TABLE public.tbldim_segments TO app_reports;
GRANT SELECT ON TABLE public.tbldim_segments TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbldim_segments TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbldim_segments TO app_admin;


--
-- Name: SEQUENCE tbldim_segments_segmentcode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tbldim_segments_segmentcode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_segments_segmentcode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_segments_segmentcode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_segments_segmentcode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_segments_segmentcode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tbldim_segments_segmentcode_seq TO app_backup;


--
-- Name: TABLE tbldocumentattachments; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tbldocumentattachments TO app_readonly;
GRANT SELECT ON TABLE public.tbldocumentattachments TO app_auditor;
GRANT SELECT ON TABLE public.tbldocumentattachments TO app_reports;
GRANT SELECT ON TABLE public.tbldocumentattachments TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbldocumentattachments TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbldocumentattachments TO app_admin;


--
-- Name: SEQUENCE tbldocumentattachments_attachmentid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tbldocumentattachments_attachmentid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tbldocumentattachments_attachmentid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tbldocumentattachments_attachmentid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tbldocumentattachments_attachmentid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tbldocumentattachments_attachmentid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tbldocumentattachments_attachmentid_seq TO app_backup;


--
-- Name: TABLE tblexchangeratehistory; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblexchangeratehistory TO app_readonly;
GRANT SELECT ON TABLE public.tblexchangeratehistory TO app_auditor;
GRANT SELECT ON TABLE public.tblexchangeratehistory TO app_reports;
GRANT SELECT ON TABLE public.tblexchangeratehistory TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblexchangeratehistory TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblexchangeratehistory TO app_admin;


--
-- Name: SEQUENCE tblexchangeratehistory_ratehistid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblexchangeratehistory_ratehistid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblexchangeratehistory_ratehistid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblexchangeratehistory_ratehistid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblexchangeratehistory_ratehistid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblexchangeratehistory_ratehistid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblexchangeratehistory_ratehistid_seq TO app_backup;


--
-- Name: TABLE tblfiscalperiods; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblfiscalperiods TO app_readonly;
GRANT SELECT ON TABLE public.tblfiscalperiods TO app_auditor;
GRANT SELECT ON TABLE public.tblfiscalperiods TO app_reports;
GRANT SELECT ON TABLE public.tblfiscalperiods TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblfiscalperiods TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblfiscalperiods TO app_admin;


--
-- Name: SEQUENCE tblfiscalperiods_periodid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblfiscalperiods_periodid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblfiscalperiods_periodid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblfiscalperiods_periodid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblfiscalperiods_periodid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblfiscalperiods_periodid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblfiscalperiods_periodid_seq TO app_backup;


--
-- Name: TABLE tblfiscalyears; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblfiscalyears TO app_readonly;
GRANT SELECT ON TABLE public.tblfiscalyears TO app_auditor;
GRANT SELECT ON TABLE public.tblfiscalyears TO app_reports;
GRANT SELECT ON TABLE public.tblfiscalyears TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblfiscalyears TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblfiscalyears TO app_admin;


--
-- Name: SEQUENCE tblfiscalyears_fiscalyearid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblfiscalyears_fiscalyearid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblfiscalyears_fiscalyearid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblfiscalyears_fiscalyearid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblfiscalyears_fiscalyearid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblfiscalyears_fiscalyearid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblfiscalyears_fiscalyearid_seq TO app_backup;


--
-- Name: TABLE tblfunds; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblfunds TO app_readonly;
GRANT SELECT ON TABLE public.tblfunds TO app_auditor;
GRANT SELECT ON TABLE public.tblfunds TO app_reports;
GRANT SELECT ON TABLE public.tblfunds TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblfunds TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblfunds TO app_admin;


--
-- Name: SEQUENCE tblfunds_fundcode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblfunds_fundcode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblfunds_fundcode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblfunds_fundcode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblfunds_fundcode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblfunds_fundcode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblfunds_fundcode_seq TO app_backup;


--
-- Name: TABLE tbljournalbody; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tbljournalbody TO app_readonly;
GRANT SELECT ON TABLE public.tbljournalbody TO app_auditor;
GRANT SELECT ON TABLE public.tbljournalbody TO app_reports;
GRANT SELECT ON TABLE public.tbljournalbody TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbljournalbody TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbljournalbody TO app_admin;


--
-- Name: SEQUENCE tbljournalbody_journaldetailid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tbljournalbody_journaldetailid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tbljournalbody_journaldetailid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tbljournalbody_journaldetailid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tbljournalbody_journaldetailid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tbljournalbody_journaldetailid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tbljournalbody_journaldetailid_seq TO app_backup;


--
-- Name: SEQUENCE tbljournalheader_journalcode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tbljournalheader_journalcode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tbljournalheader_journalcode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tbljournalheader_journalcode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tbljournalheader_journalcode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tbljournalheader_journalcode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tbljournalheader_journalcode_seq TO app_backup;


--
-- Name: TABLE tblnotifications; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblnotifications TO app_readonly;
GRANT SELECT ON TABLE public.tblnotifications TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblnotifications TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblnotifications TO app_admin;
GRANT SELECT ON TABLE public.tblnotifications TO app_auditor;


--
-- Name: SEQUENCE tblnotifications_notificationid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblnotifications_notificationid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblnotifications_notificationid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblnotifications_notificationid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblnotifications_notificationid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblnotifications_notificationid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblnotifications_notificationid_seq TO app_backup;


--
-- Name: TABLE tbloperationbody; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tbloperationbody TO app_readonly;
GRANT SELECT ON TABLE public.tbloperationbody TO app_auditor;
GRANT SELECT ON TABLE public.tbloperationbody TO app_reports;
GRANT SELECT ON TABLE public.tbloperationbody TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbloperationbody TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbloperationbody TO app_admin;


--
-- Name: SEQUENCE tbloperationbody_operationdetailid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tbloperationbody_operationdetailid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tbloperationbody_operationdetailid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tbloperationbody_operationdetailid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tbloperationbody_operationdetailid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tbloperationbody_operationdetailid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tbloperationbody_operationdetailid_seq TO app_backup;


--
-- Name: SEQUENCE tbloperationheader_operationcode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tbloperationheader_operationcode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tbloperationheader_operationcode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tbloperationheader_operationcode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tbloperationheader_operationcode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tbloperationheader_operationcode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tbloperationheader_operationcode_seq TO app_backup;


--
-- Name: TABLE tbloperationtaxes; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tbloperationtaxes TO app_readonly;
GRANT SELECT ON TABLE public.tbloperationtaxes TO app_auditor;
GRANT SELECT ON TABLE public.tbloperationtaxes TO app_reports;
GRANT SELECT ON TABLE public.tbloperationtaxes TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbloperationtaxes TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbloperationtaxes TO app_admin;


--
-- Name: SEQUENCE tbloperationtaxes_operationtaxid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tbloperationtaxes_operationtaxid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tbloperationtaxes_operationtaxid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tbloperationtaxes_operationtaxid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tbloperationtaxes_operationtaxid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tbloperationtaxes_operationtaxid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tbloperationtaxes_operationtaxid_seq TO app_backup;


--
-- Name: TABLE tblpaymentmethods; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblpaymentmethods TO app_readonly;
GRANT SELECT ON TABLE public.tblpaymentmethods TO app_auditor;
GRANT SELECT ON TABLE public.tblpaymentmethods TO app_reports;
GRANT SELECT ON TABLE public.tblpaymentmethods TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblpaymentmethods TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblpaymentmethods TO app_admin;


--
-- Name: SEQUENCE tblpaymentmethods_paymentmethodcode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblpaymentmethods_paymentmethodcode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblpaymentmethods_paymentmethodcode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblpaymentmethods_paymentmethodcode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblpaymentmethods_paymentmethodcode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblpaymentmethods_paymentmethodcode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblpaymentmethods_paymentmethodcode_seq TO app_backup;


--
-- Name: TABLE tblpaymentterms; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblpaymentterms TO app_readonly;
GRANT SELECT ON TABLE public.tblpaymentterms TO app_auditor;
GRANT SELECT ON TABLE public.tblpaymentterms TO app_reports;
GRANT SELECT ON TABLE public.tblpaymentterms TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblpaymentterms TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblpaymentterms TO app_admin;


--
-- Name: SEQUENCE tblpaymentterms_paymenttermcode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblpaymentterms_paymenttermcode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblpaymentterms_paymenttermcode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblpaymentterms_paymenttermcode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblpaymentterms_paymenttermcode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblpaymentterms_paymenttermcode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblpaymentterms_paymenttermcode_seq TO app_backup;


--
-- Name: TABLE tblpricelists; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblpricelists TO app_readonly;
GRANT SELECT ON TABLE public.tblpricelists TO app_auditor;
GRANT SELECT ON TABLE public.tblpricelists TO app_reports;
GRANT SELECT ON TABLE public.tblpricelists TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblpricelists TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblpricelists TO app_admin;


--
-- Name: SEQUENCE tblpricelists_pricelistcode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblpricelists_pricelistcode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblpricelists_pricelistcode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblpricelists_pricelistcode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblpricelists_pricelistcode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblpricelists_pricelistcode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblpricelists_pricelistcode_seq TO app_backup;


--
-- Name: TABLE tblprivileges; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblprivileges TO app_readonly;
GRANT SELECT ON TABLE public.tblprivileges TO app_auditor;
GRANT SELECT ON TABLE public.tblprivileges TO app_reports;
GRANT SELECT ON TABLE public.tblprivileges TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblprivileges TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblprivileges TO app_admin;


--
-- Name: SEQUENCE tblprivileges_privilegeid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblprivileges_privilegeid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblprivileges_privilegeid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblprivileges_privilegeid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblprivileges_privilegeid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblprivileges_privilegeid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblprivileges_privilegeid_seq TO app_backup;


--
-- Name: TABLE tblproductbatches; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblproductbatches TO app_readonly;
GRANT SELECT ON TABLE public.tblproductbatches TO app_auditor;
GRANT SELECT ON TABLE public.tblproductbatches TO app_reports;
GRANT SELECT ON TABLE public.tblproductbatches TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblproductbatches TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblproductbatches TO app_admin;


--
-- Name: SEQUENCE tblproductbatches_batchid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblproductbatches_batchid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblproductbatches_batchid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblproductbatches_batchid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblproductbatches_batchid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblproductbatches_batchid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblproductbatches_batchid_seq TO app_backup;


--
-- Name: TABLE tblproductimages; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblproductimages TO app_readonly;
GRANT SELECT ON TABLE public.tblproductimages TO app_auditor;
GRANT SELECT ON TABLE public.tblproductimages TO app_reports;
GRANT SELECT ON TABLE public.tblproductimages TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblproductimages TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblproductimages TO app_admin;


--
-- Name: SEQUENCE tblproductimages_imageid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblproductimages_imageid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblproductimages_imageid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblproductimages_imageid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblproductimages_imageid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblproductimages_imageid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblproductimages_imageid_seq TO app_backup;


--
-- Name: TABLE tblproductmovement; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblproductmovement TO app_readonly;
GRANT SELECT ON TABLE public.tblproductmovement TO app_auditor;
GRANT SELECT ON TABLE public.tblproductmovement TO app_reports;
GRANT SELECT ON TABLE public.tblproductmovement TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblproductmovement TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblproductmovement TO app_admin;


--
-- Name: SEQUENCE tblproductmovement_movementid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblproductmovement_movementid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblproductmovement_movementid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblproductmovement_movementid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblproductmovement_movementid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblproductmovement_movementid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblproductmovement_movementid_seq TO app_backup;


--
-- Name: TABLE tblproductpricing; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblproductpricing TO app_readonly;
GRANT SELECT ON TABLE public.tblproductpricing TO app_auditor;
GRANT SELECT ON TABLE public.tblproductpricing TO app_reports;
GRANT SELECT ON TABLE public.tblproductpricing TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblproductpricing TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblproductpricing TO app_admin;


--
-- Name: SEQUENCE tblproductpricing_pricingid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblproductpricing_pricingid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblproductpricing_pricingid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblproductpricing_pricingid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblproductpricing_pricingid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblproductpricing_pricingid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblproductpricing_pricingid_seq TO app_backup;


--
-- Name: TABLE tblproducts; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblproducts TO app_readonly;
GRANT SELECT ON TABLE public.tblproducts TO app_auditor;
GRANT SELECT ON TABLE public.tblproducts TO app_reports;
GRANT SELECT ON TABLE public.tblproducts TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblproducts TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblproducts TO app_admin;


--
-- Name: SEQUENCE tblproducts_productcode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblproducts_productcode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblproducts_productcode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblproducts_productcode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblproducts_productcode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblproducts_productcode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblproducts_productcode_seq TO app_backup;


--
-- Name: TABLE tblreportdefinitions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblreportdefinitions TO app_readonly;
GRANT SELECT ON TABLE public.tblreportdefinitions TO app_auditor;
GRANT SELECT ON TABLE public.tblreportdefinitions TO app_reports;
GRANT SELECT ON TABLE public.tblreportdefinitions TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblreportdefinitions TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblreportdefinitions TO app_admin;


--
-- Name: SEQUENCE tblreportdefinitions_reportid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblreportdefinitions_reportid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblreportdefinitions_reportid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblreportdefinitions_reportid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblreportdefinitions_reportid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblreportdefinitions_reportid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblreportdefinitions_reportid_seq TO app_backup;


--
-- Name: TABLE tblsessions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblsessions TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblsessions TO app_admin;
GRANT SELECT ON TABLE public.tblsessions TO app_auditor;


--
-- Name: SEQUENCE tblsessions_sessionid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblsessions_sessionid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblsessions_sessionid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblsessions_sessionid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblsessions_sessionid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblsessions_sessionid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblsessions_sessionid_seq TO app_backup;


--
-- Name: SEQUENCE tblstoreproducts_storeproductid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblstoreproducts_storeproductid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblstoreproducts_storeproductid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblstoreproducts_storeproductid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblstoreproducts_storeproductid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblstoreproducts_storeproductid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblstoreproducts_storeproductid_seq TO app_backup;


--
-- Name: TABLE tblstores; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblstores TO app_readonly;
GRANT SELECT ON TABLE public.tblstores TO app_auditor;
GRANT SELECT ON TABLE public.tblstores TO app_reports;
GRANT SELECT ON TABLE public.tblstores TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblstores TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblstores TO app_admin;


--
-- Name: SEQUENCE tblstores_storecode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblstores_storecode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblstores_storecode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblstores_storecode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblstores_storecode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblstores_storecode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblstores_storecode_seq TO app_backup;


--
-- Name: TABLE tblsuppliercontacts; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblsuppliercontacts TO app_readonly;
GRANT SELECT ON TABLE public.tblsuppliercontacts TO app_auditor;
GRANT SELECT ON TABLE public.tblsuppliercontacts TO app_reports;
GRANT SELECT ON TABLE public.tblsuppliercontacts TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblsuppliercontacts TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblsuppliercontacts TO app_admin;


--
-- Name: SEQUENCE tblsuppliercontacts_contactid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblsuppliercontacts_contactid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblsuppliercontacts_contactid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblsuppliercontacts_contactid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblsuppliercontacts_contactid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblsuppliercontacts_contactid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblsuppliercontacts_contactid_seq TO app_backup;


--
-- Name: TABLE tblsuppliers; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblsuppliers TO app_readonly;
GRANT SELECT ON TABLE public.tblsuppliers TO app_auditor;
GRANT SELECT ON TABLE public.tblsuppliers TO app_reports;
GRANT SELECT ON TABLE public.tblsuppliers TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblsuppliers TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblsuppliers TO app_admin;


--
-- Name: SEQUENCE tblsuppliers_suppliercode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblsuppliers_suppliercode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblsuppliers_suppliercode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblsuppliers_suppliercode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblsuppliers_suppliercode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblsuppliers_suppliercode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblsuppliers_suppliercode_seq TO app_backup;


--
-- Name: TABLE tbltaxdefinitions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tbltaxdefinitions TO app_readonly;
GRANT SELECT ON TABLE public.tbltaxdefinitions TO app_auditor;
GRANT SELECT ON TABLE public.tbltaxdefinitions TO app_reports;
GRANT SELECT ON TABLE public.tbltaxdefinitions TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbltaxdefinitions TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbltaxdefinitions TO app_admin;


--
-- Name: SEQUENCE tbltaxdefinitions_taxid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tbltaxdefinitions_taxid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tbltaxdefinitions_taxid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tbltaxdefinitions_taxid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tbltaxdefinitions_taxid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tbltaxdefinitions_taxid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tbltaxdefinitions_taxid_seq TO app_backup;


--
-- Name: TABLE tbltaxtransactions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tbltaxtransactions TO app_readonly;
GRANT SELECT ON TABLE public.tbltaxtransactions TO app_auditor;
GRANT SELECT ON TABLE public.tbltaxtransactions TO app_reports;
GRANT SELECT ON TABLE public.tbltaxtransactions TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbltaxtransactions TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbltaxtransactions TO app_admin;


--
-- Name: SEQUENCE tbltaxtransactions_taxtransid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tbltaxtransactions_taxtransid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tbltaxtransactions_taxtransid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tbltaxtransactions_taxtransid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tbltaxtransactions_taxtransid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tbltaxtransactions_taxtransid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tbltaxtransactions_taxtransid_seq TO app_backup;


--
-- Name: TABLE tblunits; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblunits TO app_readonly;
GRANT SELECT ON TABLE public.tblunits TO app_auditor;
GRANT SELECT ON TABLE public.tblunits TO app_reports;
GRANT SELECT ON TABLE public.tblunits TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblunits TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblunits TO app_admin;


--
-- Name: SEQUENCE tblunits_unitcode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblunits_unitcode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblunits_unitcode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblunits_unitcode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblunits_unitcode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblunits_unitcode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblunits_unitcode_seq TO app_backup;


--
-- Name: TABLE tbluserroleassignments; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tbluserroleassignments TO app_readonly;
GRANT SELECT ON TABLE public.tbluserroleassignments TO app_auditor;
GRANT SELECT ON TABLE public.tbluserroleassignments TO app_reports;
GRANT SELECT ON TABLE public.tbluserroleassignments TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbluserroleassignments TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbluserroleassignments TO app_admin;


--
-- Name: SEQUENCE tbluserroleassignments_assignmentid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tbluserroleassignments_assignmentid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tbluserroleassignments_assignmentid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tbluserroleassignments_assignmentid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tbluserroleassignments_assignmentid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tbluserroleassignments_assignmentid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tbluserroleassignments_assignmentid_seq TO app_backup;


--
-- Name: TABLE tbluserroles; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tbluserroles TO app_readonly;
GRANT SELECT ON TABLE public.tbluserroles TO app_auditor;
GRANT SELECT ON TABLE public.tbluserroles TO app_reports;
GRANT SELECT ON TABLE public.tbluserroles TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbluserroles TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tbluserroles TO app_admin;


--
-- Name: SEQUENCE tbluserroles_roleid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tbluserroles_roleid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tbluserroles_roleid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tbluserroles_roleid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tbluserroles_roleid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tbluserroles_roleid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tbluserroles_roleid_seq TO app_backup;


--
-- Name: TABLE tblusers; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblusers TO app_auditor;
GRANT SELECT ON TABLE public.tblusers TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblusers TO app_admin;


--
-- Name: SEQUENCE tblusers_usercode_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblusers_usercode_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblusers_usercode_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblusers_usercode_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblusers_usercode_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblusers_usercode_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblusers_usercode_seq TO app_backup;


--
-- Name: TABLE tblwindows; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tblwindows TO app_readonly;
GRANT SELECT ON TABLE public.tblwindows TO app_auditor;
GRANT SELECT ON TABLE public.tblwindows TO app_reports;
GRANT SELECT ON TABLE public.tblwindows TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblwindows TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tblwindows TO app_admin;


--
-- Name: SEQUENCE tblwindows_windowid_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tblwindows_windowid_seq TO app_readonly;
GRANT SELECT,USAGE ON SEQUENCE public.tblwindows_windowid_seq TO app_readwrite;
GRANT SELECT,USAGE ON SEQUENCE public.tblwindows_windowid_seq TO app_admin;
GRANT SELECT,USAGE ON SEQUENCE public.tblwindows_windowid_seq TO app_auditor;
GRANT SELECT,USAGE ON SEQUENCE public.tblwindows_windowid_seq TO app_reports;
GRANT SELECT,USAGE ON SEQUENCE public.tblwindows_windowid_seq TO app_backup;


--
-- Name: TABLE vw_accounthierarchy; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_accounthierarchy TO app_readonly;
GRANT SELECT ON TABLE public.vw_accounthierarchy TO app_auditor;
GRANT SELECT ON TABLE public.vw_accounthierarchy TO app_reports;
GRANT SELECT ON TABLE public.vw_accounthierarchy TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_accounthierarchy TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_accounthierarchy TO app_admin;


--
-- Name: TABLE vw_active_sessions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_active_sessions TO app_readonly;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_active_sessions TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_active_sessions TO app_admin;
GRANT SELECT ON TABLE public.vw_active_sessions TO app_auditor;
GRANT SELECT ON TABLE public.vw_active_sessions TO app_reports;
GRANT SELECT ON TABLE public.vw_active_sessions TO app_backup;


--
-- Name: TABLE vw_activebudgets; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_activebudgets TO app_readonly;
GRANT SELECT ON TABLE public.vw_activebudgets TO app_auditor;
GRANT SELECT ON TABLE public.vw_activebudgets TO app_reports;
GRANT SELECT ON TABLE public.vw_activebudgets TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_activebudgets TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_activebudgets TO app_admin;


--
-- Name: TABLE vw_activeusers; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_activeusers TO app_readonly;
GRANT SELECT ON TABLE public.vw_activeusers TO app_auditor;
GRANT SELECT ON TABLE public.vw_activeusers TO app_reports;
GRANT SELECT ON TABLE public.vw_activeusers TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_activeusers TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_activeusers TO app_admin;


--
-- Name: TABLE vw_approval_workflow_dashboard; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_approval_workflow_dashboard TO app_readonly;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_approval_workflow_dashboard TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_approval_workflow_dashboard TO app_admin;
GRANT SELECT ON TABLE public.vw_approval_workflow_dashboard TO app_auditor;
GRANT SELECT ON TABLE public.vw_approval_workflow_dashboard TO app_reports;
GRANT SELECT ON TABLE public.vw_approval_workflow_dashboard TO app_backup;


--
-- Name: TABLE vw_approvalhistory; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_approvalhistory TO app_readonly;
GRANT SELECT ON TABLE public.vw_approvalhistory TO app_auditor;
GRANT SELECT ON TABLE public.vw_approvalhistory TO app_reports;
GRANT SELECT ON TABLE public.vw_approvalhistory TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_approvalhistory TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_approvalhistory TO app_admin;


--
-- Name: TABLE vw_approvalmetrics; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_approvalmetrics TO app_readonly;
GRANT SELECT ON TABLE public.vw_approvalmetrics TO app_auditor;
GRANT SELECT ON TABLE public.vw_approvalmetrics TO app_reports;
GRANT SELECT ON TABLE public.vw_approvalmetrics TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_approvalmetrics TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_approvalmetrics TO app_admin;


--
-- Name: TABLE vw_bankaccountbalances; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_bankaccountbalances TO app_readonly;
GRANT SELECT ON TABLE public.vw_bankaccountbalances TO app_auditor;
GRANT SELECT ON TABLE public.vw_bankaccountbalances TO app_reports;
GRANT SELECT ON TABLE public.vw_bankaccountbalances TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_bankaccountbalances TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_bankaccountbalances TO app_admin;


--
-- Name: TABLE vw_bankrecon_status; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_bankrecon_status TO app_readonly;
GRANT SELECT ON TABLE public.vw_bankrecon_status TO app_auditor;
GRANT SELECT ON TABLE public.vw_bankrecon_status TO app_reports;
GRANT SELECT ON TABLE public.vw_bankrecon_status TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_bankrecon_status TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_bankrecon_status TO app_admin;


--
-- Name: TABLE vw_bond_with_dimensions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_bond_with_dimensions TO app_readonly;
GRANT SELECT ON TABLE public.vw_bond_with_dimensions TO app_auditor;
GRANT SELECT ON TABLE public.vw_bond_with_dimensions TO app_reports;
GRANT SELECT ON TABLE public.vw_bond_with_dimensions TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_bond_with_dimensions TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_bond_with_dimensions TO app_admin;


--
-- Name: TABLE vw_bonds_with_approval; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_bonds_with_approval TO app_readonly;
GRANT SELECT ON TABLE public.vw_bonds_with_approval TO app_auditor;
GRANT SELECT ON TABLE public.vw_bonds_with_approval TO app_reports;
GRANT SELECT ON TABLE public.vw_bonds_with_approval TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_bonds_with_approval TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_bonds_with_approval TO app_admin;


--
-- Name: TABLE vw_budgetvsactual_by_dimension; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_budgetvsactual_by_dimension TO app_readonly;
GRANT SELECT ON TABLE public.vw_budgetvsactual_by_dimension TO app_auditor;
GRANT SELECT ON TABLE public.vw_budgetvsactual_by_dimension TO app_reports;
GRANT SELECT ON TABLE public.vw_budgetvsactual_by_dimension TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_budgetvsactual_by_dimension TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_budgetvsactual_by_dimension TO app_admin;


--
-- Name: TABLE vw_cash_with_approval; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_cash_with_approval TO app_readonly;
GRANT SELECT ON TABLE public.vw_cash_with_approval TO app_auditor;
GRANT SELECT ON TABLE public.vw_cash_with_approval TO app_reports;
GRANT SELECT ON TABLE public.vw_cash_with_approval TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_cash_with_approval TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_cash_with_approval TO app_admin;


--
-- Name: TABLE vw_cashboxbalances; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_cashboxbalances TO app_readonly;
GRANT SELECT ON TABLE public.vw_cashboxbalances TO app_auditor;
GRANT SELECT ON TABLE public.vw_cashboxbalances TO app_reports;
GRANT SELECT ON TABLE public.vw_cashboxbalances TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_cashboxbalances TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_cashboxbalances TO app_admin;


--
-- Name: TABLE vw_cashflow_daily; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_cashflow_daily TO app_readonly;
GRANT SELECT ON TABLE public.vw_cashflow_daily TO app_auditor;
GRANT SELECT ON TABLE public.vw_cashflow_daily TO app_reports;
GRANT SELECT ON TABLE public.vw_cashflow_daily TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_cashflow_daily TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_cashflow_daily TO app_admin;


--
-- Name: TABLE vw_costcenter_hierarchy; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_costcenter_hierarchy TO app_readonly;
GRANT SELECT ON TABLE public.vw_costcenter_hierarchy TO app_auditor;
GRANT SELECT ON TABLE public.vw_costcenter_hierarchy TO app_reports;
GRANT SELECT ON TABLE public.vw_costcenter_hierarchy TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_costcenter_hierarchy TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_costcenter_hierarchy TO app_admin;


--
-- Name: TABLE vw_customerlist; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_customerlist TO app_readonly;
GRANT SELECT ON TABLE public.vw_customerlist TO app_auditor;
GRANT SELECT ON TABLE public.vw_customerlist TO app_reports;
GRANT SELECT ON TABLE public.vw_customerlist TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_customerlist TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_customerlist TO app_admin;


--
-- Name: TABLE vw_db_size_summary; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_db_size_summary TO app_readonly;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_db_size_summary TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_db_size_summary TO app_admin;
GRANT SELECT ON TABLE public.vw_db_size_summary TO app_auditor;
GRANT SELECT ON TABLE public.vw_db_size_summary TO app_reports;
GRANT SELECT ON TABLE public.vw_db_size_summary TO app_backup;


--
-- Name: TABLE vw_dimension_usage; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_dimension_usage TO app_readonly;
GRANT SELECT ON TABLE public.vw_dimension_usage TO app_auditor;
GRANT SELECT ON TABLE public.vw_dimension_usage TO app_reports;
GRANT SELECT ON TABLE public.vw_dimension_usage TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_dimension_usage TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_dimension_usage TO app_admin;


--
-- Name: TABLE vw_dimensions_summary; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_dimensions_summary TO app_readonly;
GRANT SELECT ON TABLE public.vw_dimensions_summary TO app_auditor;
GRANT SELECT ON TABLE public.vw_dimensions_summary TO app_reports;
GRANT SELECT ON TABLE public.vw_dimensions_summary TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_dimensions_summary TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_dimensions_summary TO app_admin;


--
-- Name: TABLE vw_documents_by_source; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_documents_by_source TO app_readonly;
GRANT SELECT ON TABLE public.vw_documents_by_source TO app_auditor;
GRANT SELECT ON TABLE public.vw_documents_by_source TO app_reports;
GRANT SELECT ON TABLE public.vw_documents_by_source TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_documents_by_source TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_documents_by_source TO app_admin;


--
-- Name: TABLE vw_fiscalperiodstatus; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_fiscalperiodstatus TO app_readonly;
GRANT SELECT ON TABLE public.vw_fiscalperiodstatus TO app_auditor;
GRANT SELECT ON TABLE public.vw_fiscalperiodstatus TO app_reports;
GRANT SELECT ON TABLE public.vw_fiscalperiodstatus TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_fiscalperiodstatus TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_fiscalperiodstatus TO app_admin;


--
-- Name: TABLE vw_index_usage; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_index_usage TO app_readonly;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_index_usage TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_index_usage TO app_admin;
GRANT SELECT ON TABLE public.vw_index_usage TO app_auditor;
GRANT SELECT ON TABLE public.vw_index_usage TO app_reports;
GRANT SELECT ON TABLE public.vw_index_usage TO app_backup;


--
-- Name: TABLE vw_journalbody_with_dimensions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_journalbody_with_dimensions TO app_readonly;
GRANT SELECT ON TABLE public.vw_journalbody_with_dimensions TO app_auditor;
GRANT SELECT ON TABLE public.vw_journalbody_with_dimensions TO app_reports;
GRANT SELECT ON TABLE public.vw_journalbody_with_dimensions TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_journalbody_with_dimensions TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_journalbody_with_dimensions TO app_admin;


--
-- Name: TABLE vw_journals_with_approval; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_journals_with_approval TO app_readonly;
GRANT SELECT ON TABLE public.vw_journals_with_approval TO app_auditor;
GRANT SELECT ON TABLE public.vw_journals_with_approval TO app_reports;
GRANT SELECT ON TABLE public.vw_journals_with_approval TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_journals_with_approval TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_journals_with_approval TO app_admin;


--
-- Name: TABLE vw_login; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_login TO app_readonly;
GRANT SELECT ON TABLE public.vw_login TO app_auditor;
GRANT SELECT ON TABLE public.vw_login TO app_reports;
GRANT SELECT ON TABLE public.vw_login TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_login TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_login TO app_admin;


--
-- Name: TABLE vw_long_running_queries; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_long_running_queries TO app_readonly;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_long_running_queries TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_long_running_queries TO app_admin;
GRANT SELECT ON TABLE public.vw_long_running_queries TO app_auditor;
GRANT SELECT ON TABLE public.vw_long_running_queries TO app_reports;
GRANT SELECT ON TABLE public.vw_long_running_queries TO app_backup;


--
-- Name: TABLE vw_most_seq_scanned; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_most_seq_scanned TO app_readonly;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_most_seq_scanned TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_most_seq_scanned TO app_admin;
GRANT SELECT ON TABLE public.vw_most_seq_scanned TO app_auditor;
GRANT SELECT ON TABLE public.vw_most_seq_scanned TO app_reports;
GRANT SELECT ON TABLE public.vw_most_seq_scanned TO app_backup;


--
-- Name: TABLE vw_pendingapprovals; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_pendingapprovals TO app_readonly;
GRANT SELECT ON TABLE public.vw_pendingapprovals TO app_auditor;
GRANT SELECT ON TABLE public.vw_pendingapprovals TO app_reports;
GRANT SELECT ON TABLE public.vw_pendingapprovals TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_pendingapprovals TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_pendingapprovals TO app_admin;


--
-- Name: TABLE vw_productmovementsummary; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_productmovementsummary TO app_readonly;
GRANT SELECT ON TABLE public.vw_productmovementsummary TO app_auditor;
GRANT SELECT ON TABLE public.vw_productmovementsummary TO app_reports;
GRANT SELECT ON TABLE public.vw_productmovementsummary TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_productmovementsummary TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_productmovementsummary TO app_admin;


--
-- Name: TABLE vw_productstocksummary; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_productstocksummary TO app_readonly;
GRANT SELECT ON TABLE public.vw_productstocksummary TO app_auditor;
GRANT SELECT ON TABLE public.vw_productstocksummary TO app_reports;
GRANT SELECT ON TABLE public.vw_productstocksummary TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_productstocksummary TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_productstocksummary TO app_admin;


--
-- Name: TABLE vw_purchasesummary; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_purchasesummary TO app_readonly;
GRANT SELECT ON TABLE public.vw_purchasesummary TO app_auditor;
GRANT SELECT ON TABLE public.vw_purchasesummary TO app_reports;
GRANT SELECT ON TABLE public.vw_purchasesummary TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_purchasesummary TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_purchasesummary TO app_admin;


--
-- Name: TABLE vw_recentaudithistory; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_recentaudithistory TO app_readonly;
GRANT SELECT ON TABLE public.vw_recentaudithistory TO app_auditor;
GRANT SELECT ON TABLE public.vw_recentaudithistory TO app_reports;
GRANT SELECT ON TABLE public.vw_recentaudithistory TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_recentaudithistory TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_recentaudithistory TO app_admin;


--
-- Name: TABLE vw_salessummary; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_salessummary TO app_readonly;
GRANT SELECT ON TABLE public.vw_salessummary TO app_auditor;
GRANT SELECT ON TABLE public.vw_salessummary TO app_reports;
GRANT SELECT ON TABLE public.vw_salessummary TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_salessummary TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_salessummary TO app_admin;


--
-- Name: TABLE vw_slow_queries; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_slow_queries TO app_readonly;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_slow_queries TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_slow_queries TO app_admin;
GRANT SELECT ON TABLE public.vw_slow_queries TO app_auditor;
GRANT SELECT ON TABLE public.vw_slow_queries TO app_reports;
GRANT SELECT ON TABLE public.vw_slow_queries TO app_backup;


--
-- Name: TABLE vw_supplierlist; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_supplierlist TO app_readonly;
GRANT SELECT ON TABLE public.vw_supplierlist TO app_auditor;
GRANT SELECT ON TABLE public.vw_supplierlist TO app_reports;
GRANT SELECT ON TABLE public.vw_supplierlist TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_supplierlist TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_supplierlist TO app_admin;


--
-- Name: TABLE vw_taxtransactions_full; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_taxtransactions_full TO app_readonly;
GRANT SELECT ON TABLE public.vw_taxtransactions_full TO app_auditor;
GRANT SELECT ON TABLE public.vw_taxtransactions_full TO app_reports;
GRANT SELECT ON TABLE public.vw_taxtransactions_full TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_taxtransactions_full TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_taxtransactions_full TO app_admin;


--
-- Name: TABLE vw_treasury_with_dimensions; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_treasury_with_dimensions TO app_readonly;
GRANT SELECT ON TABLE public.vw_treasury_with_dimensions TO app_auditor;
GRANT SELECT ON TABLE public.vw_treasury_with_dimensions TO app_reports;
GRANT SELECT ON TABLE public.vw_treasury_with_dimensions TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_treasury_with_dimensions TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_treasury_with_dimensions TO app_admin;


--
-- Name: TABLE vw_treasurysummary; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_treasurysummary TO app_readonly;
GRANT SELECT ON TABLE public.vw_treasurysummary TO app_auditor;
GRANT SELECT ON TABLE public.vw_treasurysummary TO app_reports;
GRANT SELECT ON TABLE public.vw_treasurysummary TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_treasurysummary TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_treasurysummary TO app_admin;


--
-- Name: TABLE vw_unposted_pending_approval; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_unposted_pending_approval TO app_readonly;
GRANT SELECT ON TABLE public.vw_unposted_pending_approval TO app_auditor;
GRANT SELECT ON TABLE public.vw_unposted_pending_approval TO app_reports;
GRANT SELECT ON TABLE public.vw_unposted_pending_approval TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_unposted_pending_approval TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_unposted_pending_approval TO app_admin;


--
-- Name: TABLE vw_unreadnotifications; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_unreadnotifications TO app_readonly;
GRANT SELECT ON TABLE public.vw_unreadnotifications TO app_auditor;
GRANT SELECT ON TABLE public.vw_unreadnotifications TO app_reports;
GRANT SELECT ON TABLE public.vw_unreadnotifications TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_unreadnotifications TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_unreadnotifications TO app_admin;


--
-- Name: TABLE vw_unused_indexes; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_unused_indexes TO app_readonly;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_unused_indexes TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_unused_indexes TO app_admin;
GRANT SELECT ON TABLE public.vw_unused_indexes TO app_auditor;
GRANT SELECT ON TABLE public.vw_unused_indexes TO app_reports;
GRANT SELECT ON TABLE public.vw_unused_indexes TO app_backup;


--
-- Name: TABLE vw_userdelegations; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_userdelegations TO app_readonly;
GRANT SELECT ON TABLE public.vw_userdelegations TO app_auditor;
GRANT SELECT ON TABLE public.vw_userdelegations TO app_reports;
GRANT SELECT ON TABLE public.vw_userdelegations TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_userdelegations TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_userdelegations TO app_admin;


--
-- Name: TABLE vw_workflowsummary; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.vw_workflowsummary TO app_readonly;
GRANT SELECT ON TABLE public.vw_workflowsummary TO app_auditor;
GRANT SELECT ON TABLE public.vw_workflowsummary TO app_reports;
GRANT SELECT ON TABLE public.vw_workflowsummary TO app_backup;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_workflowsummary TO app_readwrite;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_workflowsummary TO app_admin;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,USAGE ON SEQUENCES TO app_readonly;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,USAGE ON SEQUENCES TO app_readwrite;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,USAGE ON SEQUENCES TO app_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,USAGE ON SEQUENCES TO app_auditor;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,USAGE ON SEQUENCES TO app_reports;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,USAGE ON SEQUENCES TO app_backup;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO app_readonly;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO app_readwrite;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO app_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO app_auditor;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO app_reports;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO app_backup;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON TABLES TO app_readonly;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES TO app_readwrite;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES TO app_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON TABLES TO app_auditor;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON TABLES TO app_reports;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON TABLES TO app_backup;


--
-- Name: mv_account_balances; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.mv_account_balances;


--
-- Name: mv_budget_vs_actual_summary; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.mv_budget_vs_actual_summary;


--
-- Name: mv_chart_of_accounts; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.mv_chart_of_accounts;


--
-- Name: mv_customer_outstanding_balance; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.mv_customer_outstanding_balance;


--
-- Name: mv_daily_sales_summary; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.mv_daily_sales_summary;


--
-- Name: mv_final_accounts; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.mv_final_accounts;


--
-- Name: mv_journal_summary; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.mv_journal_summary;


--
-- Name: mv_monthly_inventory_snapshot; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.mv_monthly_inventory_snapshot;


--
-- Name: mv_treasury_position; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.mv_treasury_position;


--
-- Name: mv_trial_balance; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.mv_trial_balance;


--
-- PostgreSQL database dump complete
--

\unrestrict OPFzC5FAhXSudeUBJo1wlo6QRYGKzOBnvbwfExgfkz7I4uEehMfHqLNStEuGSUx

