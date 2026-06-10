--
-- PostgreSQL database dump
--

\restrict dAO0Jimy6Npj7Et1QXcFnYwfb5VRu9jowbsgwZBYL80c8Js7uIVwJ9nKSKrVKcg

-- Dumped from database version 17.10
-- Dumped by pg_dump version 17.10

SET statement_timeout = 0;

SET lock_timeout = 0;

SET idle_in_transaction_session_timeout = 0;

SET transaction_timeout = 0;

SET client_encoding = 'UTF8';

SET standard_conforming_strings = on;

SELECT pg_catalog.set_config ('search_path', '', false);

SET check_function_bodies = false;

SET xmloption = content;

SET client_min_messages = warning;

SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS '';

--
-- Name: fn_calculatevat(numeric, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_calculatevat(p_amount numeric, p_vat_percent numeric DEFAULT 15) RETURNS numeric
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    RETURN ROUND(p_amount * p_vat_percent / 100, 4);
END;
$$;

--
-- Name: fn_generateoperationno(character varying, bigint); Type: FUNCTION; Schema: public; Owner: -
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

--
-- Name: fn_getaccountbalance(integer, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: -
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

--
-- Name: fn_getaccountfullpath(integer); Type: FUNCTION; Schema: public; Owner: -
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

--
-- Name: fn_getcategoryfullpath(integer); Type: FUNCTION; Schema: public; Owner: -
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

--
-- Name: fn_getcustomerbalance(integer); Type: FUNCTION; Schema: public; Owner: -
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

--
-- Name: fn_getproductstock(integer, integer); Type: FUNCTION; Schema: public; Owner: -
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

--
-- Name: fn_getsupplierbalance(integer); Type: FUNCTION; Schema: public; Owner: -
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

--
-- Name: fn_isuserhasprivilege(integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
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

--
-- Name: sp_expireoldsessions(); Type: PROCEDURE; Schema: public; Owner: -
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

--
-- Name: sp_getlowstockproducts(integer); Type: FUNCTION; Schema: public; Owner: -
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

--
-- Name: sp_getproductstock(integer, integer); Type: FUNCTION; Schema: public; Owner: -
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

--
-- Name: sp_login(character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: -
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

--
-- Name: sp_login_result(character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sp_login_result(p_user_id character varying, p_password character varying, p_computer_name character varying DEFAULT NULL::character varying, p_ip_address character varying DEFAULT NULL::character varying) RETURNS TABLE(isvalid boolean, token uuid, usercode integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_password_hash BYTEA;
    v_salt          BYTEA;
    v_locked_until  TIMESTAMP;
    v_user_code     INT;
    v_token         UUID;
    v_is_valid      BOOLEAN := FALSE;
BEGIN
    SELECT "UserPassword", "Salt", "LockedUntil"
      INTO v_password_hash, v_salt, v_locked_until
      FROM public."tblUsers"
     WHERE "UserID"  = p_user_id
       AND "IsActive" = TRUE;

    IF FOUND
       AND (v_locked_until IS NULL OR v_locked_until <= CURRENT_TIMESTAMP)
       AND convert_from(v_password_hash, 'UTF8') = p_password THEN
        v_token := gen_random_uuid();
        v_user_code := (SELECT "UserCode" FROM public."tblUsers" WHERE "UserID" = p_user_id);
        v_is_valid := TRUE;

        INSERT INTO public."tblSessions" (
            "SessionToken", "UserCode", "UserID", "BranchCode", "MachineName", "IPAddress",
            "CreatedAt", "LastActivityAt", "ExpiresAt", "IsActive")
        SELECT v_token, "UserCode", "UserID", "BranchCode", p_computer_name, p_ip_address,
               CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '8 hours', TRUE
          FROM public."tblUsers" WHERE "UserID" = p_user_id;

        UPDATE public."tblUsers"
           SET "LastLoginAt"   = CURRENT_TIMESTAMP,
               "LoginAttempts" = 0,
               "IsOnline"      = TRUE
         WHERE "UserID" = p_user_id;
    ELSE
        UPDATE public."tblUsers"
           SET "LoginAttempts" = "LoginAttempts" + 1
         WHERE "UserID" = p_user_id;
    END IF;

    RETURN QUERY SELECT v_is_valid, v_token, v_user_code;
END;
$$;

--
-- Name: sp_logout(uuid); Type: PROCEDURE; Schema: public; Owner: -
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

--
-- Name: sp_validatesession(uuid); Type: PROCEDURE; Schema: public; Owner: -
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

--
-- Name: trg_fn_auditlogs_insert(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trg_fn_auditlogs_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW."CreatedAt" IS NULL THEN
        NEW."CreatedAt" := CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$;

--
-- Name: trg_fn_operationheader_afterinsert(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trg_fn_operationheader_afterinsert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_prefix VARCHAR(15);
BEGIN
    v_prefix := CASE NEW."OperationType"
        WHEN 'SALE'           THEN 'INV'
        WHEN 'PURCHASE'       THEN 'PINV'
        WHEN 'SALE_RETURN'    THEN 'SRTN'
        WHEN 'PURCHASE_RETURN' THEN 'PRTN'
        ELSE 'DOC'
    END || '-' || TO_CHAR(CURRENT_TIMESTAMP, 'YYMM') || '-';

    NEW."OperationID" := v_prefix || LPAD(NEW."OperationCode"::TEXT, 5, '0');
    RETURN NEW;
END;
$$;

--
-- Name: trg_fn_storeproducts_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trg_fn_storeproducts_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW."QtyReserved" > NEW."QtyOnHand" THEN
        RAISE EXCEPTION 'الكمية المحجوزة لا يمكن أن تتجاوز الكمية المتاحة (QtyReserved (%) > QtyOnHand (%))',
            NEW."QtyReserved", NEW."QtyOnHand";
    END IF;
    RETURN NEW;
END;
$$;

--
-- Name: trg_fn_users_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trg_fn_users_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF OLD."UserPassword" IS DISTINCT FROM NEW."UserPassword" THEN
        NEW."PasswordHistory2"   := OLD."PasswordHistory1";
        NEW."PasswordHistory1"   := OLD."UserPassword";
        NEW."PasswordLastChanged" := CURRENT_TIMESTAMP;
        NEW."MustChangePassword" := FALSE;
        NEW."LoginAttempts"      := 0;
        NEW."LockedUntil"        := NULL;
    END IF;
    RETURN NEW;
END;
$$;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: tblaccounts; Type: TABLE; Schema: public; Owner: -
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
    openingbalance numeric(18, 4) DEFAULT 0,
    currentbalance numeric(18, 4) DEFAULT 0,
    isactive boolean DEFAULT true,
    notes text
);

--
-- Name: tblaccounts_accountcode_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblaccounts
ALTER COLUMN accountcode
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblaccounts_accountcode_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblauditlogs; Type: TABLE; Schema: public; Owner: -
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
    sqlcommand text
);

--
-- Name: tblauditlogs_auditid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblauditlogs
ALTER COLUMN auditid
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblauditlogs_auditid_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblbanks; Type: TABLE; Schema: public; Owner: -
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
    openingbalance numeric(18, 4) DEFAULT 0,
    currentbalance numeric(18, 4) DEFAULT 0,
    isactive boolean DEFAULT true,
    notes text
);

--
-- Name: tblbanks_bankcode_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblbanks
ALTER COLUMN bankcode
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblbanks_bankcode_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblbondbody; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tblbondbody (
    bonddetailid bigint NOT NULL,
    bondcode bigint NOT NULL,
    linenumber integer NOT NULL,
    accountcode integer NOT NULL,
    costcentercode integer,
    description character varying(500),
    debit numeric(18, 4) DEFAULT 0,
    credit numeric(18, 4) DEFAULT 0
);

--
-- Name: tblbondbody_bonddetailid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblbondbody
ALTER COLUMN bonddetailid
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblbondbody_bonddetailid_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblbondheader; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tblbondheader (
    bondcode bigint NOT NULL,
    bondid character varying(30) NOT NULL,
    bondtype character varying(20) NOT NULL,
    bonddate date NOT NULL,
    fiscalyear integer NOT NULL,
    fiscalperiod integer NOT NULL,
    amount numeric(18, 4) NOT NULL,
    currencycode integer,
    exchangerate numeric(18, 8) DEFAULT 1.0,
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
    notes text
);

--
-- Name: tblbondheader_bondcode_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblbondheader
ALTER COLUMN bondcode
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblbondheader_bondcode_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblbranches; Type: TABLE; Schema: public; Owner: -
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

--
-- Name: tblbranches_branchcode_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblbranches
ALTER COLUMN branchcode
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblbranches_branchcode_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblcategories; Type: TABLE; Schema: public; Owner: -
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

--
-- Name: tblcategories_categorycode_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblcategories
ALTER COLUMN categorycode
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblcategories_categorycode_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblcompanies; Type: TABLE; Schema: public; Owner: -
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

--
-- Name: tblcompanies_companycode_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblcompanies
ALTER COLUMN companycode
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblcompanies_companycode_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblcostcenters; Type: TABLE; Schema: public; Owner: -
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

--
-- Name: tblcostcenters_costcentercode_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblcostcenters
ALTER COLUMN costcentercode
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblcostcenters_costcentercode_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblcurrencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tblcurrencies (
    currencycode integer NOT NULL,
    currencyid character varying(10) NOT NULL,
    currencynamear character varying(100) NOT NULL,
    currencynameen character varying(100),
    symbol character varying(10),
    exchangerate numeric(18, 8) DEFAULT 1.0,
    isbasecurrency boolean DEFAULT false,
    isactive boolean DEFAULT true,
    lastupdatedat timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

--
-- Name: tblcurrencies_currencycode_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblcurrencies
ALTER COLUMN currencycode
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblcurrencies_currencycode_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblcustomercontacts; Type: TABLE; Schema: public; Owner: -
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

--
-- Name: tblcustomercontacts_contactid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblcustomercontacts
ALTER COLUMN contactid
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblcustomercontacts_contactid_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblcustomers; Type: TABLE; Schema: public; Owner: -
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

--
-- Name: tblcustomers_customercode_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblcustomers
ALTER COLUMN customercode
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblcustomers_customercode_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblfunds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tblfunds (
    fundcode integer NOT NULL,
    fundid character varying(15) NOT NULL,
    fundnamear character varying(200) NOT NULL,
    fundnameen character varying(200),
    fundtype character varying(50),
    currencycode integer,
    openingbalance numeric(18, 4) DEFAULT 0,
    currentbalance numeric(18, 4) DEFAULT 0,
    isactive boolean DEFAULT true,
    notes text
);

--
-- Name: tblfunds_fundcode_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblfunds
ALTER COLUMN fundcode
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblfunds_fundcode_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tbljournalbody; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbljournalbody (
    journaldetailid bigint NOT NULL,
    journalcode bigint NOT NULL,
    linenumber integer NOT NULL,
    accountcode integer NOT NULL,
    costcentercode integer,
    description character varying(500),
    debit numeric(18, 4) DEFAULT 0,
    credit numeric(18, 4) DEFAULT 0,
    currencycode integer,
    debitlocal numeric(18, 4) DEFAULT 0,
    creditlocal numeric(18, 4) DEFAULT 0
);

--
-- Name: tbljournalbody_journaldetailid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tbljournalbody
ALTER COLUMN journaldetailid
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tbljournalbody_journaldetailid_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tbljournalheader; Type: TABLE; Schema: public; Owner: -
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
    exchangerate numeric(18, 8) DEFAULT 1.0,
    totaldebit numeric(18, 4) DEFAULT 0,
    totalcredit numeric(18, 4) DEFAULT 0,
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
    notes text
);

--
-- Name: tbljournalheader_journalcode_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tbljournalheader
ALTER COLUMN journalcode
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tbljournalheader_journalcode_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tbloperationbody; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbloperationbody (
    operationdetailid bigint NOT NULL,
    operationcode bigint NOT NULL,
    linenumber integer NOT NULL,
    productcode integer NOT NULL,
    unitcode integer,
    batchid integer,
    quantity numeric(18, 4) DEFAULT 0,
    unitprice numeric(18, 4) DEFAULT 0,
    cost numeric(18, 4) DEFAULT 0,
    discountpercent numeric(8, 3) DEFAULT 0,
    discountamount numeric(18, 4) DEFAULT 0,
    taxpercent numeric(8, 3) DEFAULT 0,
    taxamount numeric(18, 4) DEFAULT 0,
    total numeric(18, 4) DEFAULT 0,
    storecode integer,
    description character varying(500)
);

--
-- Name: tbloperationbody_operationdetailid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tbloperationbody
ALTER COLUMN operationdetailid
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tbloperationbody_operationdetailid_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tbloperationheader; Type: TABLE; Schema: public; Owner: -
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
    exchangerate numeric(18, 8) DEFAULT 1.0,
    subtotal numeric(18, 4) DEFAULT 0,
    discountpercent numeric(8, 3) DEFAULT 0,
    discountamount numeric(18, 4) DEFAULT 0,
    taxamount numeric(18, 4) DEFAULT 0,
    additionalcharges numeric(18, 4) DEFAULT 0,
    total numeric(18, 4) DEFAULT 0,
    paidamount numeric(18, 4) DEFAULT 0,
    remainingamount numeric(18, 4) DEFAULT 0,
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

--
-- Name: tbloperationheader_operationcode_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tbloperationheader
ALTER COLUMN operationcode
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tbloperationheader_operationcode_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tbloperationtaxes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tbloperationtaxes (
    operationtaxid bigint NOT NULL,
    operationcode bigint NOT NULL,
    taxtype character varying(50),
    taxpercent numeric(8, 3) DEFAULT 0,
    taxamount numeric(18, 4) DEFAULT 0
);

--
-- Name: tbloperationtaxes_operationtaxid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tbloperationtaxes
ALTER COLUMN operationtaxid
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tbloperationtaxes_operationtaxid_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblpaymentmethods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tblpaymentmethods (
    paymentmethodcode integer NOT NULL,
    methodnamear character varying(100) NOT NULL,
    methodnameen character varying(100),
    methodtype character varying(50),
    isactive boolean DEFAULT true,
    notes text
);

--
-- Name: tblpaymentmethods_paymentmethodcode_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblpaymentmethods
ALTER COLUMN paymentmethodcode
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblpaymentmethods_paymentmethodcode_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblpaymentterms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tblpaymentterms (
    paymenttermcode integer NOT NULL,
    termnamear character varying(100) NOT NULL,
    termnameen character varying(100),
    dayscount integer DEFAULT 0,
    isactive boolean DEFAULT true,
    notes text
);

--
-- Name: tblpaymentterms_paymenttermcode_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblpaymentterms
ALTER COLUMN paymenttermcode
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblpaymentterms_paymenttermcode_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblpricelists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tblpricelists (
    pricelistcode integer NOT NULL,
    pricelistnamear character varying(200) NOT NULL,
    pricelistnameen character varying(200),
    currencycode integer,
    markuppercent numeric(8, 3) DEFAULT 0,
    validfrom date,
    validto date,
    isactive boolean DEFAULT true,
    notes text
);

--
-- Name: tblpricelists_pricelistcode_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblpricelists
ALTER COLUMN pricelistcode
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblpricelists_pricelistcode_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblprivileges; Type: TABLE; Schema: public; Owner: -
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

--
-- Name: tblprivileges_privilegeid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblprivileges
ALTER COLUMN privilegeid
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblprivileges_privilegeid_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblproductbatches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tblproductbatches (
    batchid integer NOT NULL,
    productcode integer NOT NULL,
    batchno character varying(50) NOT NULL,
    expirydate date,
    manufacturedate date
);

--
-- Name: tblproductbatches_batchid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblproductbatches
ALTER COLUMN batchid
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblproductbatches_batchid_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblproductimages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tblproductimages (
    imageid integer NOT NULL,
    productcode integer NOT NULL,
    imagedata bytea,
    caption character varying(200),
    isprimary boolean DEFAULT false,
    sortorder integer DEFAULT 0
);

--
-- Name: tblproductimages_imageid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblproductimages
ALTER COLUMN imageid
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblproductimages_imageid_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblproductmovement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tblproductmovement (
    movementid bigint NOT NULL,
    productcode integer NOT NULL,
    storecode integer NOT NULL,
    movementtype character varying(20) NOT NULL,
    movementdate timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    quantity numeric(18, 4) NOT NULL,
    unitcost numeric(18, 4) DEFAULT 0,
    referencetype character varying(50),
    referencecode bigint,
    batchid integer,
    notes text
);

--
-- Name: tblproductmovement_movementid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblproductmovement
ALTER COLUMN movementid
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblproductmovement_movementid_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblproductpricing; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tblproductpricing (
    pricingid integer NOT NULL,
    productcode integer NOT NULL,
    pricelistcode integer NOT NULL,
    unitcode integer NOT NULL,
    price numeric(18, 4) NOT NULL,
    minquantity numeric(18, 4) DEFAULT 1,
    validfrom date,
    validto date
);

--
-- Name: tblproductpricing_pricingid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblproductpricing
ALTER COLUMN pricingid
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblproductpricing_pricingid_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblproducts; Type: TABLE; Schema: public; Owner: -
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
    standardcost numeric(18, 4) DEFAULT 0,
    lastpurchaseprice numeric(18, 4) DEFAULT 0,
    lastsaleprice numeric(18, 4) DEFAULT 0,
    minstocklevel numeric(18, 4) DEFAULT 0,
    maxstocklevel numeric(18, 4) DEFAULT 0,
    reorderlevel numeric(18, 4) DEFAULT 0,
    isactive boolean DEFAULT true,
    createdby integer,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    notes text
);

--
-- Name: tblproducts_productcode_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblproducts
ALTER COLUMN productcode
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblproducts_productcode_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblsessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tblsessions (
    sessionid integer NOT NULL,
    sessiontoken uuid DEFAULT gen_random_uuid () NOT NULL,
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
    sessiondata text
);

--
-- Name: tblsessions_sessionid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblsessions
ALTER COLUMN sessionid
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblsessions_sessionid_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblstoreproducts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tblstoreproducts (
    storeproductid integer NOT NULL,
    storecode integer NOT NULL,
    productcode integer NOT NULL,
    batchid integer,
    qtyonhand numeric(18, 4) DEFAULT 0,
    qtyreserved numeric(18, 4) DEFAULT 0,
    avgcost numeric(18, 4) DEFAULT 0,
    lastcost numeric(18, 4) DEFAULT 0,
    locationinstore character varying(50),
    isactive boolean DEFAULT true
);

--
-- Name: tblstoreproducts_storeproductid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblstoreproducts
ALTER COLUMN storeproductid
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblstoreproducts_storeproductid_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblstores; Type: TABLE; Schema: public; Owner: -
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

--
-- Name: tblstores_storecode_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblstores
ALTER COLUMN storecode
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblstores_storecode_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblsuppliercontacts; Type: TABLE; Schema: public; Owner: -
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

--
-- Name: tblsuppliercontacts_contactid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblsuppliercontacts
ALTER COLUMN contactid
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblsuppliercontacts_contactid_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblsuppliers; Type: TABLE; Schema: public; Owner: -
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

--
-- Name: tblsuppliers_suppliercode_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblsuppliers
ALTER COLUMN suppliercode
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblsuppliers_suppliercode_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblunits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tblunits (
    unitcode integer NOT NULL,
    unitid character varying(15) NOT NULL,
    unitnamear character varying(100) NOT NULL,
    unitnameen character varying(100),
    symbol character varying(20),
    isactive boolean DEFAULT true
);

--
-- Name: tblunits_unitcode_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblunits
ALTER COLUMN unitcode
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblunits_unitcode_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tbluserroleassignments; Type: TABLE; Schema: public; Owner: -
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

--
-- Name: tbluserroleassignments_assignmentid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tbluserroleassignments
ALTER COLUMN assignmentid
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tbluserroleassignments_assignmentid_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tbluserroles; Type: TABLE; Schema: public; Owner: -
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

--
-- Name: tbluserroles_roleid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tbluserroles
ALTER COLUMN roleid
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tbluserroles_roleid_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblusers; Type: TABLE; Schema: public; Owner: -
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
    notes text
);

--
-- Name: tblusers_usercode_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblusers
ALTER COLUMN usercode
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblusers_usercode_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: tblwindows; Type: TABLE; Schema: public; Owner: -
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

--
-- Name: tblwindows_windowid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.tblwindows
ALTER COLUMN windowid
ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tblwindows_windowid_seq START
    WITH
        1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1
);

--
-- Name: vw_accounthierarchy; Type: VIEW; Schema: public; Owner: -
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

--
-- Name: vw_activeusers; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_activeusers AS
SELECT
    u.usercode,
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
FROM (
        public.tblusers u
        LEFT JOIN public.tblbranches b ON ((u.branchcode = b.branchcode))
    )
WHERE (u.isactive = true);

--
-- Name: vw_customerlist; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_customerlist AS
SELECT
    c.customercode,
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
FROM (
        public.tblcustomers c
        LEFT JOIN public.tblbranches b ON ((c.branchcode = b.branchcode))
    );

--
-- Name: vw_productmovementsummary; Type: VIEW; Schema: public; Owner: -
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

--
-- Name: vw_productstocksummary; Type: VIEW; Schema: public; Owner: -
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

--
-- Name: vw_purchasesummary; Type: VIEW; Schema: public; Owner: -
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

--
-- Name: vw_salessummary; Type: VIEW; Schema: public; Owner: -
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

--
-- Name: vw_supplierlist; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_supplierlist AS
SELECT
    s.suppliercode,
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
FROM (
        public.tblsuppliers s
        LEFT JOIN public.tblbranches b ON ((s.branchcode = b.branchcode))
    );

--
-- Name: tblaccounts tblaccounts_accountid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblaccounts
ADD CONSTRAINT tblaccounts_accountid_key UNIQUE (accountid);

--
-- Name: tblaccounts tblaccounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblaccounts
ADD CONSTRAINT tblaccounts_pkey PRIMARY KEY (accountcode);

--
-- Name: tblauditlogs tblauditlogs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblauditlogs
ADD CONSTRAINT tblauditlogs_pkey PRIMARY KEY (auditid);

--
-- Name: tblbanks tblbanks_bankid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblbanks
ADD CONSTRAINT tblbanks_bankid_key UNIQUE (bankid);

--
-- Name: tblbanks tblbanks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblbanks
ADD CONSTRAINT tblbanks_pkey PRIMARY KEY (bankcode);

--
-- Name: tblbondbody tblbondbody_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblbondbody
ADD CONSTRAINT tblbondbody_pkey PRIMARY KEY (bonddetailid);

--
-- Name: tblbondheader tblbondheader_bondid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblbondheader
ADD CONSTRAINT tblbondheader_bondid_key UNIQUE (bondid);

--
-- Name: tblbondheader tblbondheader_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblbondheader
ADD CONSTRAINT tblbondheader_pkey PRIMARY KEY (bondcode);

--
-- Name: tblbranches tblbranches_branchid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblbranches
ADD CONSTRAINT tblbranches_branchid_key UNIQUE (branchid);

--
-- Name: tblbranches tblbranches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblbranches
ADD CONSTRAINT tblbranches_pkey PRIMARY KEY (branchcode);

--
-- Name: tblcategories tblcategories_categoryid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblcategories
ADD CONSTRAINT tblcategories_categoryid_key UNIQUE (categoryid);

--
-- Name: tblcategories tblcategories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblcategories
ADD CONSTRAINT tblcategories_pkey PRIMARY KEY (categorycode);

--
-- Name: tblcompanies tblcompanies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblcompanies
ADD CONSTRAINT tblcompanies_pkey PRIMARY KEY (companycode);

--
-- Name: tblcostcenters tblcostcenters_costcenterid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblcostcenters
ADD CONSTRAINT tblcostcenters_costcenterid_key UNIQUE (costcenterid);

--
-- Name: tblcostcenters tblcostcenters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblcostcenters
ADD CONSTRAINT tblcostcenters_pkey PRIMARY KEY (costcentercode);

--
-- Name: tblcurrencies tblcurrencies_currencyid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblcurrencies
ADD CONSTRAINT tblcurrencies_currencyid_key UNIQUE (currencyid);

--
-- Name: tblcurrencies tblcurrencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblcurrencies
ADD CONSTRAINT tblcurrencies_pkey PRIMARY KEY (currencycode);

--
-- Name: tblcustomercontacts tblcustomercontacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblcustomercontacts
ADD CONSTRAINT tblcustomercontacts_pkey PRIMARY KEY (contactid);

--
-- Name: tblcustomers tblcustomers_customerid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblcustomers
ADD CONSTRAINT tblcustomers_customerid_key UNIQUE (customerid);

--
-- Name: tblcustomers tblcustomers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblcustomers
ADD CONSTRAINT tblcustomers_pkey PRIMARY KEY (customercode);

--
-- Name: tblfunds tblfunds_fundid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblfunds
ADD CONSTRAINT tblfunds_fundid_key UNIQUE (fundid);

--
-- Name: tblfunds tblfunds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblfunds
ADD CONSTRAINT tblfunds_pkey PRIMARY KEY (fundcode);

--
-- Name: tbljournalbody tbljournalbody_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbljournalbody
ADD CONSTRAINT tbljournalbody_pkey PRIMARY KEY (journaldetailid);

--
-- Name: tbljournalheader tbljournalheader_journalid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbljournalheader
ADD CONSTRAINT tbljournalheader_journalid_key UNIQUE (journalid);

--
-- Name: tbljournalheader tbljournalheader_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbljournalheader
ADD CONSTRAINT tbljournalheader_pkey PRIMARY KEY (journalcode);

--
-- Name: tbloperationbody tbloperationbody_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbloperationbody
ADD CONSTRAINT tbloperationbody_pkey PRIMARY KEY (operationdetailid);

--
-- Name: tbloperationheader tbloperationheader_operationid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbloperationheader
ADD CONSTRAINT tbloperationheader_operationid_key UNIQUE (operationid);

--
-- Name: tbloperationheader tbloperationheader_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbloperationheader
ADD CONSTRAINT tbloperationheader_pkey PRIMARY KEY (operationcode);

--
-- Name: tbloperationtaxes tbloperationtaxes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbloperationtaxes
ADD CONSTRAINT tbloperationtaxes_pkey PRIMARY KEY (operationtaxid);

--
-- Name: tblpaymentmethods tblpaymentmethods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblpaymentmethods
ADD CONSTRAINT tblpaymentmethods_pkey PRIMARY KEY (paymentmethodcode);

--
-- Name: tblpaymentterms tblpaymentterms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblpaymentterms
ADD CONSTRAINT tblpaymentterms_pkey PRIMARY KEY (paymenttermcode);

--
-- Name: tblpricelists tblpricelists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblpricelists
ADD CONSTRAINT tblpricelists_pkey PRIMARY KEY (pricelistcode);

--
-- Name: tblprivileges tblprivileges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblprivileges
ADD CONSTRAINT tblprivileges_pkey PRIMARY KEY (privilegeid);

--
-- Name: tblproductbatches tblproductbatches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblproductbatches
ADD CONSTRAINT tblproductbatches_pkey PRIMARY KEY (batchid);

--
-- Name: tblproductimages tblproductimages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblproductimages
ADD CONSTRAINT tblproductimages_pkey PRIMARY KEY (imageid);

--
-- Name: tblproductmovement tblproductmovement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblproductmovement
ADD CONSTRAINT tblproductmovement_pkey PRIMARY KEY (movementid);

--
-- Name: tblproductpricing tblproductpricing_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblproductpricing
ADD CONSTRAINT tblproductpricing_pkey PRIMARY KEY (pricingid);

--
-- Name: tblproducts tblproducts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblproducts
ADD CONSTRAINT tblproducts_pkey PRIMARY KEY (productcode);

--
-- Name: tblproducts tblproducts_productid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblproducts
ADD CONSTRAINT tblproducts_productid_key UNIQUE (productid);

--
-- Name: tblsessions tblsessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblsessions
ADD CONSTRAINT tblsessions_pkey PRIMARY KEY (sessionid);

--
-- Name: tblsessions tblsessions_sessiontoken_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblsessions
ADD CONSTRAINT tblsessions_sessiontoken_key UNIQUE (sessiontoken);

--
-- Name: tblstoreproducts tblstoreproducts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblstoreproducts
ADD CONSTRAINT tblstoreproducts_pkey PRIMARY KEY (storeproductid);

--
-- Name: tblstores tblstores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblstores
ADD CONSTRAINT tblstores_pkey PRIMARY KEY (storecode);

--
-- Name: tblstores tblstores_storeid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblstores
ADD CONSTRAINT tblstores_storeid_key UNIQUE (storeid);

--
-- Name: tblsuppliercontacts tblsuppliercontacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblsuppliercontacts
ADD CONSTRAINT tblsuppliercontacts_pkey PRIMARY KEY (contactid);

--
-- Name: tblsuppliers tblsuppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblsuppliers
ADD CONSTRAINT tblsuppliers_pkey PRIMARY KEY (suppliercode);

--
-- Name: tblsuppliers tblsuppliers_supplierid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblsuppliers
ADD CONSTRAINT tblsuppliers_supplierid_key UNIQUE (supplierid);

--
-- Name: tblunits tblunits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblunits
ADD CONSTRAINT tblunits_pkey PRIMARY KEY (unitcode);

--
-- Name: tblunits tblunits_unitid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblunits
ADD CONSTRAINT tblunits_unitid_key UNIQUE (unitid);

--
-- Name: tbluserroleassignments tbluserroleassignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbluserroleassignments
ADD CONSTRAINT tbluserroleassignments_pkey PRIMARY KEY (assignmentid);

--
-- Name: tbluserroles tbluserroles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbluserroles
ADD CONSTRAINT tbluserroles_pkey PRIMARY KEY (roleid);

--
-- Name: tbluserroles tbluserroles_rolename_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbluserroles
ADD CONSTRAINT tbluserroles_rolename_key UNIQUE (rolename);

--
-- Name: tblusers tblusers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblusers
ADD CONSTRAINT tblusers_pkey PRIMARY KEY (usercode);

--
-- Name: tblusers tblusers_userid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblusers
ADD CONSTRAINT tblusers_userid_key UNIQUE (userid);

--
-- Name: tblwindows tblwindows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblwindows
ADD CONSTRAINT tblwindows_pkey PRIMARY KEY (windowid);

--
-- Name: tblwindows tblwindows_windowcode_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblwindows
ADD CONSTRAINT tblwindows_windowcode_key UNIQUE (windowcode);

--
-- Name: tblstoreproducts uq_storeproduct_batch; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblstoreproducts
ADD CONSTRAINT uq_storeproduct_batch UNIQUE (
    storecode,
    productcode,
    batchid
);

--
-- Name: tbluserroleassignments uq_userrole_assignment; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbluserroleassignments
ADD CONSTRAINT uq_userrole_assignment UNIQUE (usercode, roleid);

--
-- Name: tblprivileges uq_userwindow; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblprivileges
ADD CONSTRAINT uq_userwindow UNIQUE (usercode, windowid);

--
-- Name: idx_journalbody_account; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_journalbody_account ON public.tbljournalbody USING btree (accountcode);

--
-- Name: idx_journalbody_journal; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_journalbody_journal ON public.tbljournalbody USING btree (journalcode);

--
-- Name: idx_privileges_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_privileges_user ON public.tblprivileges USING btree (usercode);

--
-- Name: idx_privileges_window; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_privileges_window ON public.tblprivileges USING btree (windowid);

--
-- Name: idx_sessions_expires; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sessions_expires ON public.tblsessions USING btree (expiresat);

--
-- Name: idx_sessions_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sessions_token ON public.tblsessions USING btree (sessiontoken);

--
-- Name: idx_sessions_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sessions_user ON public.tblsessions USING btree (usercode);

--
-- Name: idx_tblaccounts_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tblaccounts_active ON public.tblaccounts USING btree (isactive);

--
-- Name: idx_tblaccounts_parent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tblaccounts_parent ON public.tblaccounts USING btree (parentaccountcode);

--
-- Name: idx_tblaccounts_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tblaccounts_type ON public.tblaccounts USING btree (accounttype);

--
-- Name: idx_tblusers_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tblusers_branch ON public.tblusers USING btree (branchcode);

--
-- Name: idx_tblusers_isactive; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tblusers_isactive ON public.tblusers USING btree (isactive);

--
-- Name: idx_tblusers_userid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tblusers_userid ON public.tblusers USING btree (userid);

--
-- Name: idx_tblwindows_module; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tblwindows_module ON public.tblwindows USING btree (modulename);

--
-- Name: idx_tblwindows_parent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tblwindows_parent ON public.tblwindows USING btree (parentwindowid);

--
-- Name: tblauditlogs trg_auditlogs_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_auditlogs_insert BEFORE INSERT ON public.tblauditlogs FOR EACH ROW EXECUTE FUNCTION public.trg_fn_auditlogs_insert();

--
-- Name: tblstoreproducts trg_storeproducts_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_storeproducts_update BEFORE INSERT OR UPDATE ON public.tblstoreproducts FOR EACH ROW EXECUTE FUNCTION public.trg_fn_storeproducts_update();

--
-- Name: tblusers trg_users_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_users_update BEFORE UPDATE ON public.tblusers FOR EACH ROW EXECUTE FUNCTION public.trg_fn_users_update();

--
-- Name: tblaccounts fk_accounts_parent; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblaccounts
ADD CONSTRAINT fk_accounts_parent FOREIGN KEY (parentaccountcode) REFERENCES public.tblaccounts (accountcode);

--
-- Name: tblproductbatches fk_batches_product; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblproductbatches
ADD CONSTRAINT fk_batches_product FOREIGN KEY (productcode) REFERENCES public.tblproducts (productcode);

--
-- Name: tblbondbody fk_bondbody_account; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblbondbody
ADD CONSTRAINT fk_bondbody_account FOREIGN KEY (accountcode) REFERENCES public.tblaccounts (accountcode);

--
-- Name: tblbondbody fk_bondbody_header; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblbondbody
ADD CONSTRAINT fk_bondbody_header FOREIGN KEY (bondcode) REFERENCES public.tblbondheader (bondcode) ON DELETE CASCADE;

--
-- Name: tblcategories fk_categories_parent; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblcategories
ADD CONSTRAINT fk_categories_parent FOREIGN KEY (parentcategorycode) REFERENCES public.tblcategories (categorycode);

--
-- Name: tblcustomercontacts fk_customercontacts_customer; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblcustomercontacts
ADD CONSTRAINT fk_customercontacts_customer FOREIGN KEY (customercode) REFERENCES public.tblcustomers (customercode) ON DELETE CASCADE;

--
-- Name: tblcustomers fk_customers_branch; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblcustomers
ADD CONSTRAINT fk_customers_branch FOREIGN KEY (branchcode) REFERENCES public.tblbranches (branchcode);

--
-- Name: tblcustomers fk_customers_paymentterm; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblcustomers
ADD CONSTRAINT fk_customers_paymentterm FOREIGN KEY (paymenttermcode) REFERENCES public.tblpaymentterms (paymenttermcode);

--
-- Name: tblcustomers fk_customers_pricelist; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblcustomers
ADD CONSTRAINT fk_customers_pricelist FOREIGN KEY (pricelistcode) REFERENCES public.tblpricelists (pricelistcode);

--
-- Name: tblproductimages fk_images_product; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblproductimages
ADD CONSTRAINT fk_images_product FOREIGN KEY (productcode) REFERENCES public.tblproducts (productcode) ON DELETE CASCADE;

--
-- Name: tbljournalbody fk_journalbody_account; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbljournalbody
ADD CONSTRAINT fk_journalbody_account FOREIGN KEY (accountcode) REFERENCES public.tblaccounts (accountcode);

--
-- Name: tbljournalbody fk_journalbody_header; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbljournalbody
ADD CONSTRAINT fk_journalbody_header FOREIGN KEY (journalcode) REFERENCES public.tbljournalheader (journalcode) ON DELETE CASCADE;

--
-- Name: tblproductmovement fk_movement_product; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblproductmovement
ADD CONSTRAINT fk_movement_product FOREIGN KEY (productcode) REFERENCES public.tblproducts (productcode);

--
-- Name: tblproductmovement fk_movement_store; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblproductmovement
ADD CONSTRAINT fk_movement_store FOREIGN KEY (storecode) REFERENCES public.tblstores (storecode);

--
-- Name: tbloperationbody fk_opbody_batch; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbloperationbody
ADD CONSTRAINT fk_opbody_batch FOREIGN KEY (batchid) REFERENCES public.tblproductbatches (batchid);

--
-- Name: tbloperationbody fk_opbody_header; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbloperationbody
ADD CONSTRAINT fk_opbody_header FOREIGN KEY (operationcode) REFERENCES public.tbloperationheader (operationcode) ON DELETE CASCADE;

--
-- Name: tbloperationbody fk_opbody_product; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbloperationbody
ADD CONSTRAINT fk_opbody_product FOREIGN KEY (productcode) REFERENCES public.tblproducts (productcode);

--
-- Name: tbloperationbody fk_opbody_unit; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbloperationbody
ADD CONSTRAINT fk_opbody_unit FOREIGN KEY (unitcode) REFERENCES public.tblunits (unitcode);

--
-- Name: tbloperationheader fk_opheader_branch; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbloperationheader
ADD CONSTRAINT fk_opheader_branch FOREIGN KEY (branchcode) REFERENCES public.tblbranches (branchcode);

--
-- Name: tbloperationheader fk_opheader_currency; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbloperationheader
ADD CONSTRAINT fk_opheader_currency FOREIGN KEY (currencycode) REFERENCES public.tblcurrencies (currencycode);

--
-- Name: tbloperationheader fk_opheader_customer; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbloperationheader
ADD CONSTRAINT fk_opheader_customer FOREIGN KEY (customercode) REFERENCES public.tblcustomers (customercode);

--
-- Name: tbloperationheader fk_opheader_paymentmethod; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbloperationheader
ADD CONSTRAINT fk_opheader_paymentmethod FOREIGN KEY (paymentmethodcode) REFERENCES public.tblpaymentmethods (paymentmethodcode);

--
-- Name: tbloperationheader fk_opheader_store; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbloperationheader
ADD CONSTRAINT fk_opheader_store FOREIGN KEY (storecode) REFERENCES public.tblstores (storecode);

--
-- Name: tbloperationheader fk_opheader_supplier; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbloperationheader
ADD CONSTRAINT fk_opheader_supplier FOREIGN KEY (suppliercode) REFERENCES public.tblsuppliers (suppliercode);

--
-- Name: tbloperationtaxes fk_optaxes_header; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbloperationtaxes
ADD CONSTRAINT fk_optaxes_header FOREIGN KEY (operationcode) REFERENCES public.tbloperationheader (operationcode) ON DELETE CASCADE;

--
-- Name: tblproductpricing fk_pricing_pricelist; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblproductpricing
ADD CONSTRAINT fk_pricing_pricelist FOREIGN KEY (pricelistcode) REFERENCES public.tblpricelists (pricelistcode);

--
-- Name: tblproductpricing fk_pricing_product; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblproductpricing
ADD CONSTRAINT fk_pricing_product FOREIGN KEY (productcode) REFERENCES public.tblproducts (productcode);

--
-- Name: tblproductpricing fk_pricing_unit; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblproductpricing
ADD CONSTRAINT fk_pricing_unit FOREIGN KEY (unitcode) REFERENCES public.tblunits (unitcode);

--
-- Name: tblprivileges fk_privileges_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblprivileges
ADD CONSTRAINT fk_privileges_user FOREIGN KEY (usercode) REFERENCES public.tblusers (usercode);

--
-- Name: tblprivileges fk_privileges_window; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblprivileges
ADD CONSTRAINT fk_privileges_window FOREIGN KEY (windowid) REFERENCES public.tblwindows (windowid);

--
-- Name: tblproducts fk_products_category; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblproducts
ADD CONSTRAINT fk_products_category FOREIGN KEY (categorycode) REFERENCES public.tblcategories (categorycode);

--
-- Name: tblproducts fk_products_unit; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblproducts
ADD CONSTRAINT fk_products_unit FOREIGN KEY (defaultunitcode) REFERENCES public.tblunits (unitcode);

--
-- Name: tblsessions fk_sessions_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblsessions
ADD CONSTRAINT fk_sessions_user FOREIGN KEY (usercode) REFERENCES public.tblusers (usercode);

--
-- Name: tblstoreproducts fk_storeproducts_batch; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblstoreproducts
ADD CONSTRAINT fk_storeproducts_batch FOREIGN KEY (batchid) REFERENCES public.tblproductbatches (batchid);

--
-- Name: tblstoreproducts fk_storeproducts_product; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblstoreproducts
ADD CONSTRAINT fk_storeproducts_product FOREIGN KEY (productcode) REFERENCES public.tblproducts (productcode);

--
-- Name: tblstoreproducts fk_storeproducts_store; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblstoreproducts
ADD CONSTRAINT fk_storeproducts_store FOREIGN KEY (storecode) REFERENCES public.tblstores (storecode);

--
-- Name: tblstores fk_stores_branch; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblstores
ADD CONSTRAINT fk_stores_branch FOREIGN KEY (branchcode) REFERENCES public.tblbranches (branchcode);

--
-- Name: tblsuppliercontacts fk_suppliercontacts_supplier; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblsuppliercontacts
ADD CONSTRAINT fk_suppliercontacts_supplier FOREIGN KEY (suppliercode) REFERENCES public.tblsuppliers (suppliercode) ON DELETE CASCADE;

--
-- Name: tblsuppliers fk_suppliers_branch; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblsuppliers
ADD CONSTRAINT fk_suppliers_branch FOREIGN KEY (branchcode) REFERENCES public.tblbranches (branchcode);

--
-- Name: tblsuppliers fk_suppliers_paymentterm; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblsuppliers
ADD CONSTRAINT fk_suppliers_paymentterm FOREIGN KEY (paymenttermcode) REFERENCES public.tblpaymentterms (paymenttermcode);

--
-- Name: tblwindows fk_tblwindows_parent; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tblwindows
ADD CONSTRAINT fk_tblwindows_parent FOREIGN KEY (parentwindowid) REFERENCES public.tblwindows (windowid);

--
-- Name: tbluserroleassignments fk_userrole_role; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbluserroleassignments
ADD CONSTRAINT fk_userrole_role FOREIGN KEY (roleid) REFERENCES public.tbluserroles (roleid);

--
-- Name: tbluserroleassignments fk_userrole_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tbluserroleassignments
ADD CONSTRAINT fk_userrole_user FOREIGN KEY (usercode) REFERENCES public.tblusers (usercode);

--
-- PostgreSQL database dump complete
--

\unrestrict dAO0Jimy6Npj7Et1QXcFnYwfb5VRu9jowbsgwZBYL80c8Js7uIVwJ9nKSKrVKcg