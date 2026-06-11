-- =============================================================================
-- IntegratedAccSys - PostgreSQL LOGIC Objects (Views, Functions, Procedures, Triggers)
-- Generated: 2026-06-08
-- Source: Database/IntegratedAccSys_Full.sql (SQL Server 2019)
-- Target: PostgreSQL 17
-- Prerequisite: Database/IntegratedAccSys_PostgreSQL.sql must already be applied.
-- =============================================================================
-- Conversion rules applied:
--   * NVARCHAR(n)              -> VARCHAR(n)   (UTF-8 encoded DB)
--   * VARBINARY(8000)          -> BYTEA
--   * NVARCHAR(MAX)            -> TEXT
--   * DECIMAL(18,4)            -> NUMERIC(18,4)
--   * DATETIME                 -> TIMESTAMP
--   * GETDATE()                -> CURRENT_TIMESTAMP
--   * NEWID()                  -> gen_random_uuid()
--   * ISNULL(a,b)              -> COALESCE(a,b)
--   * SET @x = ...             -> SELECT ... INTO v_x
--   * @param INT                -> p_param INT
--   * CREATE OR ALTER PROC      -> CREATE OR REPLACE PROCEDURE
--   * CREATE OR ALTER FUNCTION  -> CREATE OR REPLACE FUNCTION
--   * CREATE OR ALTER VIEW      -> CREATE OR REPLACE VIEW
--   * CREATE OR ALTER TRIGGER   -> CREATE OR REPLACE TRIGGER
--   * SCOPE_IDENTITY()          -> currval(pg_get_serial_sequence(...))
--   * NEWSEQUENTIALID()         -> gen_random_uuid()
--   * PRINT 'msg'               -> RAISE NOTICE 'msg'
--   * SET NOCOUNT ON            -> removed
-- =============================================================================

-- =============================================================================
-- SECTION 9: FUNCTIONS
-- =============================================================================

-- fn_GetAccountFullPath: Returns the full hierarchical path of an account
CREATE OR REPLACE FUNCTION public.fn_GetAccountFullPath(p_account_code INT)
RETURNS TEXT
LANGUAGE plpgsql
STABLE
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

-- fn_GetCategoryFullPath: Returns the full hierarchical path of a category
CREATE OR REPLACE FUNCTION public.fn_GetCategoryFullPath(p_category_code INT)
RETURNS TEXT
LANGUAGE plpgsql
STABLE
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

-- fn_GetProductStock: Returns current stock for a product
CREATE OR REPLACE FUNCTION public.fn_GetProductStock(p_product_code INT, p_store_code INT DEFAULT NULL)
RETURNS NUMERIC(18,4)
LANGUAGE plpgsql
STABLE
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

-- fn_GetAccountBalance: Returns current balance for an account
CREATE OR REPLACE FUNCTION public.fn_GetAccountBalance(p_account_code INT, p_as_of_date TIMESTAMP DEFAULT NULL)
RETURNS NUMERIC(18,4)
LANGUAGE plpgsql
STABLE
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

-- fn_CalculateVat: Calculates VAT amount
CREATE OR REPLACE FUNCTION public.fn_CalculateVat(p_amount NUMERIC(18,4), p_vat_percent NUMERIC(5,2) DEFAULT 15)
RETURNS NUMERIC(18,4)
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    RETURN ROUND(p_amount * p_vat_percent / 100, 4);
END;
$$;

-- fn_GetCustomerBalance: Returns outstanding balance for a customer
CREATE OR REPLACE FUNCTION public.fn_GetCustomerBalance(p_customer_code INT)
RETURNS NUMERIC(18,4)
LANGUAGE plpgsql
STABLE
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

-- fn_GetSupplierBalance: Returns outstanding balance for a supplier
CREATE OR REPLACE FUNCTION public.fn_GetSupplierBalance(p_supplier_code INT)
RETURNS NUMERIC(18,4)
LANGUAGE plpgsql
STABLE
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

-- fn_IsUserHasPrivilege: Checks if user has specific privilege on window
CREATE OR REPLACE FUNCTION public.fn_IsUserHasPrivilege(
    p_user_code INT, p_window_code VARCHAR(50), p_privilege_type VARCHAR(20))
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
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

-- =============================================================================
-- SECTION 10: VIEWS
-- =============================================================================

-- vw_ActiveUsers: List of active system users
CREATE OR REPLACE VIEW public.vw_ActiveUsers AS
SELECT
    u.UserCode,
    u.UserID,
    u.UserNameAr,
    u.UserNameEn,
    u.Email,
    u.Phone,
    u.Mobile,
    u.IsAdmin,
    u.IsActive,
    u.BranchCode,
    b.BranchNameAr AS BranchName,
    u.Department,
    u.JobTitle,
    u.LastLoginAt,
    u.CreatedAt
FROM public.tblUsers u
    LEFT JOIN public.tblBranches b ON u.BranchCode = b.BranchCode
WHERE
    u.IsActive = TRUE;

-- vw_AccountHierarchy: Chart of accounts with hierarchy
CREATE OR REPLACE VIEW public.vw_AccountHierarchy AS
SELECT
    a.AccountCode,
    a.AccountID,
    a.AccountNameAr,
    a.AccountNameEn,
    a.AccountType,
    a.ParentAccountCode,
    p.AccountNameAr AS ParentAccountName,
    a.AccountLevel,
    public.fn_GetAccountFullPath (a.AccountCode) AS FullPath,
    a.IsActive,
    a.IsMainAccount,
    a.IsPostable,
    a.AccountNature,
    CASE
        WHEN a.AccountNature = 'Debit' THEN public.fn_GetAccountBalance (a.AccountCode)
        ELSE - public.fn_GetAccountBalance (a.AccountCode)
    END AS Balance
FROM public.tblAccounts a
    LEFT JOIN public.tblAccounts p ON a.ParentAccountCode = p.AccountCode;

-- vw_ProductStockSummary: Current stock levels across all stores
CREATE OR REPLACE VIEW public.vw_ProductStockSummary AS
SELECT
    p.ProductCode,
    p.ProductID,
    p.ProductNameAr,
    p.ProductNameEn,
    p.CategoryCode,
    c.CategoryNameAr AS CategoryName,
    p.DefaultUnitCode,
    u.UnitNameAr AS UnitName,
    p.StandardCost,
    p.LastPurchasePrice,
    p.LastSalePrice,
    COALESCE(sp.QtyOnHand, 0) AS TotalQtyOnHand,
    COALESCE(sp.QtyReserved, 0) AS TotalQtyReserved,
    COALESCE(sp.QtyOnHand, 0) - COALESCE(sp.QtyReserved, 0) AS QtyAvailable,
    COALESCE(sp.AvgCost, 0) AS AvgCost,
    p.MinStockLevel,
    p.MaxStockLevel,
    CASE
        WHEN COALESCE(sp.QtyOnHand, 0) <= p.MinStockLevel THEN 'LOW_STOCK'
        WHEN COALESCE(sp.QtyOnHand, 0) >= p.MaxStockLevel THEN 'OVER_STOCK'
        ELSE 'NORMAL'
    END AS StockStatus
FROM public.tblProducts p
    LEFT JOIN public.tblCategories c ON p.CategoryCode = c.CategoryCode
    LEFT JOIN public.tblUnits u ON p.DefaultUnitCode = u.UnitCode
    LEFT JOIN (
        SELECT
            ProductCode, SUM(QtyOnHand) AS QtyOnHand, SUM(QtyReserved) AS QtyReserved, AVG(AvgCost) AS AvgCost
        FROM public.tblStoreProducts
        WHERE
            IsActive = TRUE
        GROUP BY
            ProductCode
    ) sp ON p.ProductCode = sp.ProductCode
WHERE
    p.IsActive = TRUE
    AND p.IsInventoryItem = TRUE;

-- vw_CustomerList: Customer overview
CREATE OR REPLACE VIEW public.vw_CustomerList AS
SELECT
    c.CustomerCode,
    c.CustomerID,
    c.CustomerNameAr,
    c.CustomerNameEn,
    c.CustomerType,
    c.Email,
    c.Mobile,
    c.Phone,
    c.City,
    c.Country,
    c.BranchCode,
    b.BranchNameAr AS BranchName,
    c.PriceListCode,
    c.PaymentTermCode,
    c.CreditLimit,
    c.CurrentCredit,
    c.AvailableCredit,
    c.PaymentDays,
    c.IsActive,
    c.IsBlocked,
    c.CustomerSince,
    c.LastSaleDate,
    c.TotalSales,
    c.Balance,
    c.TaxNumber,
    c.VATNumber
FROM public.tblCustomers c
    LEFT JOIN public.tblBranches b ON c.BranchCode = b.BranchCode;

-- vw_SupplierList: Supplier overview
CREATE OR REPLACE VIEW public.vw_SupplierList AS
SELECT
    s.SupplierCode,
    s.SupplierID,
    s.SupplierNameAr,
    s.SupplierNameEn,
    s.SupplierType,
    s.Email,
    s.Mobile,
    s.Phone,
    s.City,
    s.Country,
    s.BranchCode,
    b.BranchNameAr AS BranchName,
    s.PaymentTermCode,
    s.CreditLimit,
    s.CurrentCredit,
    s.AvailableCredit,
    s.PaymentDays,
    s.IsActive,
    s.IsBlocked,
    s.SupplierSince,
    s.LastPurchaseDate,
    s.TotalPurchases,
    s.Balance,
    s.TaxNumber,
    s.VATNumber,
    s.BankName,
    s.IBAN
FROM public.tblSuppliers s
    LEFT JOIN public.tblBranches b ON s.BranchCode = b.BranchCode;

-- vw_SalesSummary: Sales operations summary
CREATE OR REPLACE VIEW public.vw_SalesSummary AS
SELECT
    oh.OperationCode AS OperationID,
    oh.OperationID AS OperationNo,
    oh.OperationType,
    oh.OperationDate,
    oh.CustomerCode,
    c.CustomerNameAr AS CustomerName,
    c.CustomerID AS CustomerCodeID,
    oh.BranchCode,
    b.BranchNameAr AS BranchName,
    oh.StoreCode,
    st.StoreNameAr AS StoreName,
    oh.CurrencyCode,
    oh.SubTotal,
    oh.DiscountAmount,
    oh.TaxAmount,
    oh.Total,
    oh.PaidAmount,
    oh.RemainingAmount,
    oh.CreatedBy AS UserCode,
    u.UserNameAr AS CreatedByName,
    oh.CreatedAt
FROM
    public.tblOperationHeader oh
    LEFT JOIN public.tblCustomers c ON oh.CustomerCode = c.CustomerCode
    LEFT JOIN public.tblBranches b ON oh.BranchCode = b.BranchCode
    LEFT JOIN public.tblStores st ON oh.StoreCode = st.StoreCode
    LEFT JOIN public.tblUsers u ON oh.CreatedBy = u.UserCode
WHERE
    oh.OperationType IN ('SALE', 'SALE_RETURN');

-- vw_PurchaseSummary: Purchase operations summary
CREATE OR REPLACE VIEW public.vw_PurchaseSummary AS
SELECT
    oh.OperationCode AS OperationID,
    oh.OperationID AS OperationNo,
    oh.OperationType,
    oh.OperationDate,
    oh.SupplierCode,
    s.SupplierNameAr AS SupplierName,
    s.SupplierID AS SupplierCodeID,
    oh.BranchCode,
    b.BranchNameAr AS BranchName,
    oh.StoreCode,
    st.StoreNameAr AS StoreName,
    oh.CurrencyCode,
    oh.SubTotal,
    oh.DiscountAmount,
    oh.TaxAmount,
    oh.Total,
    oh.PaidAmount,
    oh.RemainingAmount,
    oh.CreatedBy AS UserCode,
    u.UserNameAr AS CreatedByName,
    oh.CreatedAt
FROM
    public.tblOperationHeader oh
    LEFT JOIN public.tblSuppliers s ON oh.SupplierCode = s.SupplierCode
    LEFT JOIN public.tblBranches b ON oh.BranchCode = b.BranchCode
    LEFT JOIN public.tblStores st ON oh.StoreCode = st.StoreCode
    LEFT JOIN public.tblUsers u ON oh.CreatedBy = u.UserCode
WHERE
    oh.OperationType IN ('PURCHASE', 'PURCHASE_RETURN');

-- vw_JournalEntries: Journal entries with account details
CREATE OR REPLACE VIEW public.vw_JournalEntries AS
SELECT
    jh."JournalCode" AS "JournalHeaderID",
    jh."JournalID"   AS "JournalNo",
    jh."OperationDate" AS "JournalDate",
    jh."Description"  AS "HeaderDescription",
    jh."BranchCode",  b."BranchNameAr" AS "BranchName",
    jh."CurrencyCode",
    jh."TotalDebit", jh."TotalCredit", jh."IsPosted",
    jb."JournalDetailID", jb."LineNumber", jb."AccountCode",
    a."AccountID", a."AccountNameAr" AS "AccountName", a."AccountType",
    jb."Description" AS "LineDescription", jb."Debit", jb."Credit",
    jb."CostCenterCode",
    jh."CreatedBy" AS "UserCode", u."UserNameAr" AS "CreatedByName", jh."CreatedAt"
FROM public."tblJournalHeader" jh
INNER JOIN public."tblJournalBody" jb ON jh."JournalCode" = jb."JournalCode"
LEFT JOIN public."tblBranches" b     ON jh."BranchCode"  = b."BranchCode"
LEFT JOIN public."tblAccounts" a     ON jb."AccountCode" = a."AccountCode"
LEFT JOIN public."tblUsers" u        ON jh."CreatedBy"   = u."UserCode";

-- vw_BondEntries: Voucher entries with account details
CREATE OR REPLACE VIEW public.vw_BondEntries AS
SELECT
    bh."BondCode" AS "BondHeaderID", bh."BondID" AS "BondNo", bh."BondType",
    bh."BondDate", bh."Description" AS "HeaderDescription",
    bh."BranchCode", b."BranchNameAr" AS "BranchName",
    bh."CurrencyCode", bh."Amount" AS "TotalAmount", bh."IsPosted",
    bb."BondDetailID", bb."LineNumber", bb."AccountCode",
    a."AccountID", a."AccountNameAr" AS "AccountName", a."AccountType",
    bb."Description" AS "LineDescription", bb."Debit", bb."Credit",
    bh."PaymentMethodCode", pm."MethodNameAr" AS "PaymentMethodName",
    bh."FundCode", f."FundNameAr" AS "FundName",
    bh."CreatedBy" AS "UserCode", u."UserNameAr" AS "CreatedByName", bh."CreatedAt"
FROM public."tblBondHeader" bh
INNER JOIN public."tblBondBody" bb ON bh."BondCode" = bb."BondCode"
LEFT JOIN public."tblBranches" b   ON bh."BranchCode"        = b."BranchCode"
LEFT JOIN public."tblAccounts" a   ON bb."AccountCode"       = a."AccountCode"
LEFT JOIN public."tblPaymentMethods" pm ON bh."PaymentMethodCode" = pm."PaymentMethodCode"
LEFT JOIN public."tblFunds" f      ON bh."FundCode"          = f."FundCode"
LEFT JOIN public."tblUsers" u      ON bh."CreatedBy"         = u."UserCode";

-- vw_ProductMovementSummary: Stock movement summary
CREATE OR REPLACE VIEW public.vw_ProductMovementSummary AS
SELECT
    pm.MovementID,
    pm.MovementType,
    pm.MovementDate,
    p.ProductID,
    p.ProductNameAr,
    st.StoreNameAr AS StoreName,
    pm.Quantity AS Qty,
    pm.UnitCost,
    pm.ReferenceType,
    pm.ReferenceCode,
    pm.Notes,
    CASE
        WHEN pm.Quantity > 0 THEN 'IN'
        ELSE 'OUT'
    END AS Direction
FROM public.tblProductMovement pm
    INNER JOIN public.tblProducts p ON pm.ProductCode = p.ProductCode
    INNER JOIN public.tblStores st ON pm.StoreCode = st.StoreCode;

-- vw_PendingOperations: Operations awaiting approval or posting

CREATE OR REPLACE VIEW public.vw_PendingOperations AS
SELECT
    'SALE'::TEXT AS OperationCategory,
    oh.OperationCode AS OperationID, oh.OperationID AS OperationNo,
    oh.OperationType, oh.OperationDate, oh.CustomerCode,
    c.CustomerNameAr AS PartyName, oh.Total AS TotalAmount,
    oh.CreatedBy AS UserCode, u.UserNameAr AS CreatedByName, oh.CreatedAt
FROM public.tblOperationHeader oh
LEFT JOIN public.tblCustomers c ON oh.CustomerCode = c.CustomerCode
LEFT JOIN public.tblUsers u     ON oh.CreatedBy    = u.UserCode
WHERE oh.OperationType = 'SALE' AND oh.IsPosted = FALSE

UNION ALL

SELECT
    'PURCHASE'::TEXT, oh.OperationCode, oh.OperationID, oh.OperationType, oh.OperationDate,
    oh.SupplierCode, s.SupplierNameAr, oh.Total, oh.CreatedBy, u.UserNameAr, oh.CreatedAt
FROM public.tblOperationHeader oh
LEFT JOIN public.tblSuppliers s ON oh.SupplierCode = s.SupplierCode
LEFT JOIN public.tblUsers u    ON oh.CreatedBy    = u.UserCode
WHERE oh.OperationType = 'PURCHASE' AND oh.IsPosted = FALSE

UNION ALL

SELECT
    'JOURNAL'::TEXT, jh."JournalCode", jh."JournalID", jh."ReferenceNo", jh."OperationDate",
    NULL, jh."Description", jh."TotalDebit", jh."CreatedBy", u."UserNameAr", jh."CreatedAt"
FROM public."tblJournalHeader" jh
LEFT JOIN public."tblUsers" u ON jh."CreatedBy" = u."UserCode"
WHERE jh."IsPosted" = FALSE;

-- =============================================================================
-- SECTION 11: STORED PROCEDURES
-- =============================================================================
-- 2026-06-11 cleanup (DEEP_ARCHITECTURE_DATABASE_AUDIT.md §7.2)
-- The following 4 legacy auth routines were DROPPED from the live DB:
--   * public.sp_Login             PROCEDURE  -> superseded by getUserForLogin()
--   * public.sp_Login_Result      FUNCTION   -> superseded by getUserForLogin()
--   * public.sp_Logout            PROCEDURE  -> superseded by endSession()
--   * public.sp_ValidateSession   PROCEDURE  -> superseded by validateSession()
-- Rationale: 0 calls from C# (grep verified), 0 DB dependencies (pg_depend verified).
-- See database/migrations/2026_06_11_01_drop_legacy_auth_procedures.sql
-- ============================================================================

-- sp_GetProductStock: Gets stock levels for a product
-- Implemented as a function so callers can use SELECT * FROM sp_GetProductStock(...)
-- (PostgreSQL procedures cannot RETURN QUERY.)
CREATE OR REPLACE FUNCTION public.sp_GetProductStock(
    p_product_code INT,
    p_store_code   INT DEFAULT NULL)
RETURNS TABLE (
    productcode INT, productid VARCHAR, productnamear VARCHAR,
    storecode INT, storenamear VARCHAR,
    qtyonhand NUMERIC, qtyreserved NUMERIC, qtyavailable NUMERIC, avgcost NUMERIC,
    batchid INT, batchno VARCHAR, expirydate DATE)
LANGUAGE plpgsql
STABLE
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

-- sp_GetLowStockProducts: Gets products below reorder level
CREATE OR REPLACE FUNCTION public.sp_GetLowStockProducts(p_store_code INT DEFAULT NULL)
RETURNS TABLE (
    productcode INT, productid VARCHAR, productnamear VARCHAR,
    storecode INT, storenamear VARCHAR,
    qtyonhand NUMERIC, qtyreserved NUMERIC,
    minstocklevel NUMERIC, reorderlevel NUMERIC, shortage NUMERIC)
LANGUAGE plpgsql
STABLE
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

-- sp_ExpireOldSessions: Cleanup expired sessions
CREATE OR REPLACE PROCEDURE public.sp_ExpireOldSessions()
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

-- =============================================================================
-- SECTION 12: TRIGGERS
-- =============================================================================

-- trg_Users_Update: Audit user changes (rotate password history)
CREATE OR REPLACE FUNCTION public.trg_fn_Users_Update()
RETURNS TRIGGER
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

DROP TRIGGER IF EXISTS trg_Users_Update ON public.tblUsers;

CREATE TRIGGER trg_Users_Update
BEFORE UPDATE ON public.tblUsers
FOR EACH ROW
EXECUTE FUNCTION public.trg_fn_Users_Update();

-- trg_StoreProducts_Update: Validate QtyReserved <= QtyOnHand
CREATE OR REPLACE FUNCTION public.trg_fn_StoreProducts_Update()
RETURNS TRIGGER
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

DROP TRIGGER IF EXISTS trg_StoreProducts_Update ON public.tblStoreProducts;

CREATE TRIGGER trg_StoreProducts_Update
BEFORE INSERT OR UPDATE ON public.tblStoreProducts
FOR EACH ROW
EXECUTE FUNCTION public.trg_fn_StoreProducts_Update();

-- trg_AuditLogs_Insert: Default LogDate to NOW() if missing
CREATE OR REPLACE FUNCTION public.trg_fn_AuditLogs_Insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW."CreatedAt" IS NULL THEN
        NEW."CreatedAt" := CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_AuditLogs_Insert ON public.tblAuditLogs;

CREATE TRIGGER trg_AuditLogs_Insert
BEFORE INSERT ON public.tblAuditLogs
FOR EACH ROW
EXECUTE FUNCTION public.trg_fn_AuditLogs_Insert();

-- trg_OperationHeader_AfterInsert: Generate OperationNo
-- Note: OperationID is NOT NULL in the base DDL, so this BEFORE INSERT trigger
-- cannot fire on a NULL value. The C# application layer is responsible for
-- setting OperationID before insert (see BL layer's operation creation code).
-- Keeping the function definition for callers that want to call it explicitly.
CREATE OR REPLACE FUNCTION public.fn_GenerateOperationNo(p_operation_type VARCHAR(20), p_operation_code BIGINT)
RETURNS VARCHAR(30)
LANGUAGE plpgsql
IMMUTABLE
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

-- =============================================================================
-- SECTION 13: REFERENCE DATA (Reference seed data)
-- =============================================================================
-- Note: This is a minimal seed to demonstrate the system. In production, this
-- would be loaded via a separate migration tool.

-- Branches
INSERT INTO
    public.tblBranches (
        BranchID,
        BranchNameAr,
        BranchNameEn,
        IsMainBranch,
        IsActive,
        City,
        Country
    )
VALUES (
        'BR001',
        N'المقر الرئيسي',
        'Main Branch',
        TRUE,
        TRUE,
        N'الرياض',
        'SA'
    ),
    (
        'BR002',
        N'فرع جدة',
        'Jeddah Branch',
        FALSE,
        TRUE,
        N'جدة',
        'SA'
    ),
    (
        'BR003',
        N'فرع الدمام',
        'Dammam Branch',
        FALSE,
        TRUE,
        N'الدمام',
        'SA'
    ) ON CONFLICT (BranchID) DO NOTHING;

-- Currencies
INSERT INTO
    public.tblCurrencies (
        CurrencyID,
        CurrencyNameAr,
        CurrencyNameEn,
        Symbol,
        ExchangeRate,
        IsBaseCurrency,
        IsActive
    )
VALUES (
        'SAR',
        N'ريال سعودي',
        'Saudi Riyal',
        N'ر.س',
        1.0,
        TRUE,
        TRUE
    ),
    (
        'USD',
        N'دولار أمريكي',
        'US Dollar',
        '$',
        3.75,
        FALSE,
        TRUE
    ),
    (
        'EUR',
        N'يورو',
        'Euro',
        '€',
        4.10,
        FALSE,
        TRUE
    ),
    (
        'AED',
        N'درهم إماراتي',
        'UAE Dirham',
        N'د.إ',
        1.02,
        FALSE,
        TRUE
    ),
    (
        'EGP',
        N'جنيه مصري',
        'Egyptian Pound',
        N'ج.م',
        0.12,
        FALSE,
        TRUE
    ) ON CONFLICT (CurrencyID) DO NOTHING;

-- Banks
INSERT INTO
    public.tblBanks (
        BankID,
        BankNameAr,
        BankNameEn,
        IsActive
    )
VALUES (
        'SABB',
        N'البنك السعودي البريطاني',
        'SABB',
        TRUE
    ),
    (
        'SNB',
        N'البنك الأهلي',
        'National Commercial Bank',
        TRUE
    ),
    (
        'RJHI',
        N'بنك الراجحي',
        'Al Rajhi Bank',
        TRUE
    ),
    (
        'BSF',
        N'بنك الرياض',
        'Banque Saudi Fransi',
        TRUE
    ),
    (
        'BAM',
        N'بنك الإنماء',
        'Al Inma Bank',
        TRUE
    ) ON CONFLICT (BankID) DO NOTHING;

-- Payment Methods
INSERT INTO
    public.tblPaymentMethods (
        MethodNameAr,
        MethodNameEn,
        MethodType,
        IsActive
    )
VALUES (N'نقدي', 'Cash', 'CASH', TRUE),
    (
        N'تحويل بنكي',
        'Bank Transfer',
        'BANK',
        TRUE
    ),
    (
        N'شيك',
        'Check',
        'CHECK',
        TRUE
    ),
    (
        N'بطاقة ائتمان',
        'Credit Card',
        'CARD',
        TRUE
    ),
    (
        N'بطاقة مدين',
        'Debit Card',
        'CARD',
        TRUE
    ),
    (N'مدى', 'Mada', 'CARD', TRUE),
    (
        N'آجل',
        'Credit/Terms',
        'CREDIT',
        TRUE
    ) ON CONFLICT DO NOTHING;

-- Funds
INSERT INTO
    public.tblFunds (
        FundID,
        FundNameAr,
        FundNameEn,
        FundType,
        IsActive
    )
VALUES (
        'CASH_MAIN',
        N'الصندوق الرئيسي',
        'Main Cash',
        'CASH',
        TRUE
    ),
    (
        'CASH_JEDDAH',
        N'صندوق جدة',
        'Jeddah Cash',
        'CASH',
        TRUE
    ),
    (
        'BANK_SABB',
        N'بنك ساب',
        'SABB Account',
        'BANK',
        TRUE
    ),
    (
        'BANK_SNB',
        N'بنك الأهلي',
        'NCB Account',
        'BANK',
        TRUE
    ) ON CONFLICT (FundID) DO NOTHING;

-- Units
INSERT INTO
    public.tblUnits (
        UnitID,
        UnitNameAr,
        UnitNameEn,
        Symbol,
        IsActive
    )
VALUES (
        'PCS',
        N'قطعة',
        'Piece',
        N'قطعة',
        TRUE
    ),
    (
        'BOX',
        N'علبة',
        'Box',
        N'علبة',
        TRUE
    ),
    (
        'KG',
        N'كيلوغرام',
        'Kilogram',
        N'كجم',
        TRUE
    ),
    (
        'G',
        N'غرام',
        'Gram',
        N'جم',
        TRUE
    ),
    (
        'L',
        N'لتر',
        'Liter',
        N'لتر',
        TRUE
    ),
    (
        'ML',
        N'ميلليلتر',
        'Milliliter',
        N'مل',
        TRUE
    ),
    (
        'M',
        N'متر',
        'Meter',
        N'م',
        TRUE
    ),
    (
        'CM',
        N'سنتيمتر',
        'Centimeter',
        N'سم',
        TRUE
    ),
    (
        'SET',
        N'طقم',
        'Set',
        N'طقم',
        TRUE
    ),
    (
        'DOZ',
        N'دزينة',
        'Dozen',
        N'دز',
        TRUE
    ),
    (
        'PACK',
        N'حزمة',
        'Pack',
        N'حزمة',
        TRUE
    ),
    (
        'ROLL',
        N'لفة',
        'Roll',
        N'لفة',
        TRUE
    ) ON CONFLICT (UnitID) DO NOTHING;

-- Categories
INSERT INTO
    public.tblCategories (
        CategoryID,
        CategoryNameAr,
        CategoryNameEn,
        IsActive
    )
VALUES (
        'CAT_P',
        N'المنتجات',
        'Products',
        TRUE
    ),
    (
        'CAT_S',
        N'الخدمات',
        'Services',
        TRUE
    ),
    (
        'CAT_E',
        N'مستلزمات',
        'Supplies',
        TRUE
    ),
    (
        'CAT_SP',
        N'قطع الغيار',
        'Spare Parts',
        TRUE
    ) ON CONFLICT (CategoryID) DO NOTHING;

-- Payment Terms
INSERT INTO
    public.tblPaymentTerms (
        TermNameAr,
        TermNameEn,
        DaysCount,
        IsActive
    )
VALUES (N'نقدي', 'Cash', 0, TRUE),
    (N'15 يوم', 'Net 15', 15, TRUE),
    (N'30 يوم', 'Net 30', 30, TRUE),
    (N'45 يوم', 'Net 45', 45, TRUE),
    (N'60 يوم', 'Net 60', 60, TRUE),
    (N'90 يوم', 'Net 90', 90, TRUE) ON CONFLICT DO NOTHING;

-- Price Lists
INSERT INTO
    public.tblPriceLists (
        PriceListNameAr,
        PriceListNameEn,
        CurrencyCode,
        IsActive
    )
VALUES (
        N'سعر البيع',
        'Sales Price',
        (
            SELECT CurrencyCode
            FROM public.tblCurrencies
            WHERE
                CurrencyID = 'SAR'
        ),
        TRUE
    ),
    (
        N'سعر الجملة',
        'Wholesale Price',
        (
            SELECT CurrencyCode
            FROM public.tblCurrencies
            WHERE
                CurrencyID = 'SAR'
        ),
        TRUE
    ),
    (
        N'سعر التكلفة',
        'Cost Price',
        (
            SELECT CurrencyCode
            FROM public.tblCurrencies
            WHERE
                CurrencyID = 'SAR'
        ),
        TRUE
    ) ON CONFLICT DO NOTHING;

-- System Windows
INSERT INTO
    public.tblWindows (
        WindowCode,
        WindowNameAr,
        WindowNameEn,
        ModuleName,
        FormName,
        IsActive,
        SortOrder
    )
VALUES (
        'SYS_MAIN',
        N'النظام الرئيسي',
        'Main System',
        'System',
        'frmMain',
        TRUE,
        0
    ),
    (
        'SYS_USERS',
        N'إدارة المستخدمين',
        'User Management',
        'System',
        'frmUsers',
        TRUE,
        1
    ),
    (
        'SYS_ROLES',
        N'إدارة الأدوار',
        'Role Management',
        'System',
        'frmRoles',
        TRUE,
        2
    ),
    (
        'SYS_PRIVILEGES',
        N'الصلاحيات',
        'Privileges',
        'System',
        'frmPrivileges',
        TRUE,
        3
    ),
    (
        'SYS_SETTINGS',
        N'الإعدادات',
        'Settings',
        'System',
        'frmSettings',
        TRUE,
        4
    ),
    (
        'SYS_BACKUP',
        N'النسخ الاحتياطي',
        'Backup',
        'System',
        'frmBackup',
        TRUE,
        5
    ),
    (
        'ACC_ACCOUNTS',
        N'خطة الحسابات',
        'Chart of Accounts',
        'Accounting',
        'frmAccounts',
        TRUE,
        10
    ),
    (
        'ACC_JOURNAL',
        N'القيود اليومية',
        'Journal Entries',
        'Accounting',
        'frmJournal',
        TRUE,
        11
    ),
    (
        'ACC_BONDS',
        N'السندات',
        'Vouchers',
        'Accounting',
        'frmBonds',
        TRUE,
        12
    ),
    (
        'INV_STORES',
        N'المخازن',
        'Stores',
        'Inventory',
        'frmStores',
        TRUE,
        20
    ),
    (
        'INV_PRODUCTS',
        N'المنتجات',
        'Products',
        'Inventory',
        'frmProducts',
        TRUE,
        21
    ),
    (
        'SALES',
        N'المبيعات',
        'Sales',
        'Sales',
        'frmSales',
        TRUE,
        30
    ),
    (
        'PURCHASES',
        N'المشتريات',
        'Purchases',
        'Purchases',
        'frmPurchases',
        TRUE,
        40
    ),
    (
        'CUSTOMERS',
        N'العملاء',
        'Customers',
        'Sales',
        'frmCustomers',
        TRUE,
        31
    ),
    (
        'SUPPLIERS',
        N'الموردين',
        'Suppliers',
        'Purchases',
        'frmSuppliers',
        TRUE,
        41
    ) ON CONFLICT (WindowCode) DO NOTHING;

-- User Roles
INSERT INTO
    public.tblUserRoles (
        RoleName,
        RoleNameAr,
        RoleNameEn,
        IsActive
    )
VALUES (
        'ADMIN',
        N'مدير النظام',
        'System Administrator',
        TRUE
    ),
    (
        'MANAGER',
        N'مدير',
        'Manager',
        TRUE
    ),
    (
        'ACCOUNTANT',
        N'محاسب',
        'Accountant',
        TRUE
    ),
    (
        'SALES',
        N'مندوب مبيعات',
        'Sales Representative',
        TRUE
    ),
    (
        'STORE',
        N'أمين مخزن',
        'Store Keeper',
        TRUE
    ) ON CONFLICT (RoleName) DO NOTHING;

-- Default Admin User (Password: Admin@123)
-- Note: production uses PBKDF2-SHA256 with random salt. Here we use a fixed
-- demo hash. The C# PasswordHelper has the real implementation.
INSERT INTO
    public.tblUsers (
        UserID,
        UserNameAr,
        UserNameEn,
        Email,
        Phone,
        UserPassword,
        Salt,
        IsActive,
        IsAdmin,
        MustChangePassword,
        CreatedAt
    )
VALUES (
        'ADMIN',
        N'مدير النظام',
        'System Administrator',
        'admin@company.com',
        '0500000000',
        convert_to ('Admin@123', 'UTF8'),
        convert_to ('DefaultSalt123', 'UTF8'),
        TRUE,
        TRUE,
        TRUE,
        CURRENT_TIMESTAMP
    ) ON CONFLICT (UserID) DO NOTHING;

-- =============================================================================
-- SUMMARY
-- =============================================================================
DO $$
DECLARE
    v_views INT; v_funcs INT; v_procs INT; v_trigs INT; v_tables INT;
BEGIN
    SELECT count(*) INTO v_views  FROM information_schema.views
        WHERE table_schema = 'public';
    SELECT count(*) INTO v_funcs  FROM information_schema.routines
        WHERE routine_schema = 'public' AND routine_type = 'FUNCTION';
    SELECT count(*) INTO v_procs  FROM information_schema.routines
        WHERE routine_schema = 'public' AND routine_type = 'PROCEDURE';
    SELECT count(*) INTO v_trigs  FROM information_schema.triggers
        WHERE trigger_schema = 'public';
    SELECT count(*) INTO v_tables FROM information_schema.tables
        WHERE table_schema = 'public' AND table_type = 'BASE TABLE';

    RAISE NOTICE 'IntegratedAccSys PostgreSQL Logic installed.';
    RAISE NOTICE 'Tables: %, Views: %, Functions: %, Procedures: %, Triggers: %',
        v_tables, v_views, v_funcs, v_procs, v_trigs;
END $$;
