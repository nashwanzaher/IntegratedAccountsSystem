-- ============================================================
-- IntegratedAccountsSystem - Complete Database Script
-- Version: 1.0 | Date: 2025-01-19
-- ============================================================
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================
-- SECTION 1: DROP ALL EXISTING OBJECTS
-- ============================================================
PRINT '========================================';

PRINT 'SECTION 1: Dropping existing objects...';

PRINT '========================================';

DECLARE @sql NVARCHAR (MAX) = '';

-- Drop Foreign Keys first
SELECT @sql = @sql + 'ALTER TABLE ' + QUOTENAME (fk.name) + ' DROP CONSTRAINT [' + fk.name + '];' + CHAR(13)
FROM sys.foreign_keys fk
    INNER JOIN sys.tables t ON fk.parent_object_id = t.object_id;

IF LEN (@sql) > 0 EXEC sp_executesql @sql;

SET
    @sql = '';

-- Drop Tables
SELECT
    @sql = @sql + 'DROP TABLE IF EXISTS ' + QUOTENAME (SCHEMA_NAME (schema_id)) + '.' + QUOTENAME (name) + ';' + CHAR(13)
FROM sys.tables
WHERE
    type = 'U';

IF LEN (@sql) > 0 EXEC sp_executesql @sql;

PRINT 'All existing objects dropped.';

-- ============================================================
-- SECTION 2: SECURITY DOMAIN TABLES
-- ============================================================
PRINT '';

PRINT '========================================';

PRINT 'SECTION 2: Creating Security Domain Tables...';

PRINT '========================================';

-- tblWindows: Window definitions for privilege system
CREATE TABLE dbo.tblWindows (
    WindowID INT IDENTITY (1, 1) PRIMARY KEY,
    WindowCode NVARCHAR (50) UNIQUE NOT NULL,
    WindowNameAr NVARCHAR (200) NOT NULL,
    WindowNameEn NVARCHAR (200) NULL,
    ModuleName NVARCHAR (100) NOT NULL,
    FormName NVARCHAR (200) NULL,
    IsActive BIT DEFAULT 1,
    SortOrder INT DEFAULT 0,
    IconName NVARCHAR (100) NULL,
    ParentWindowID INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE (),
    ModifiedAt DATETIME NULL,
    Notes NVARCHAR (MAX) NULL,
    CONSTRAINT FK_tblWindows_Parent FOREIGN KEY (ParentWindowID) REFERENCES dbo.tblWindows (WindowID)
);
GO

CREATE INDEX idx_tblWindows_Module ON dbo.tblWindows (ModuleName);

CREATE INDEX idx_tblWindows_Parent ON dbo.tblWindows (ParentWindowID);
GO

-- tblUsers: System users with PBKDF2 password hashing
CREATE TABLE dbo.tblUsers (
    UserCode INT IDENTITY (1, 1) PRIMARY KEY,
    UserID NVARCHAR (15) UNIQUE NOT NULL,
    UserPassword VARBINARY(8000) NOT NULL,
    Salt VARBINARY(8000) NOT NULL,
    UserNameAr NVARCHAR (200) NULL,
    UserNameEn NVARCHAR (200) NULL,
    Email NVARCHAR (100) NULL,
    Phone NVARCHAR (50) NULL,
    Mobile NVARCHAR (50) NULL,
    IsActive BIT DEFAULT 1,
    IsAdmin BIT DEFAULT 0,
    PasswordLastChanged DATETIME NULL,
    PasswordHistory1 VARBINARY(8000) NULL,
    PasswordHistory2 VARBINARY(8000) NULL,
    LastLoginAt DATETIME NULL,
    LoginAttempts INT DEFAULT 0,
    LockedUntil DATETIME NULL,
    MustChangePassword BIT DEFAULT 0,
    BranchCode INT NULL,
    Department NVARCHAR (100) NULL,
    JobTitle NVARCHAR (100) NULL,
    Photo VARBINARY(MAX) NULL,
    IsOnline BIT DEFAULT 0,
    CreatedBy INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE (),
    ModifiedBy INT NULL,
    ModifiedAt DATETIME NULL,
    Notes NVARCHAR (MAX) NULL
);
GO

CREATE INDEX idx_tblUsers_UserID ON dbo.tblUsers (UserID);

CREATE INDEX idx_tblUsers_IsActive ON dbo.tblUsers (IsActive);

CREATE INDEX idx_tblUsers_Branch ON dbo.tblUsers (BranchCode);
GO

-- tblUserRoles: User role assignments
CREATE TABLE dbo.tblUserRoles (
    RoleID INT IDENTITY (1, 1) PRIMARY KEY,
    RoleName NVARCHAR (50) NOT NULL UNIQUE,
    RoleNameAr NVARCHAR (100) NOT NULL,
    RoleNameEn NVARCHAR (100) NULL,
    Description NVARCHAR (500) NULL,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE (),
    Notes NVARCHAR (MAX) NULL
);
GO

CREATE TABLE dbo.tblUserRoleAssignments (
    AssignmentID INT IDENTITY (1, 1) PRIMARY KEY,
    UserCode INT NOT NULL,
    RoleID INT NOT NULL,
    AssignedBy INT NULL,
    AssignedAt DATETIME DEFAULT GETDATE (),
    ExpiresAt DATETIME NULL,
    IsActive BIT DEFAULT 1,
    CONSTRAINT FK_UserRole_User FOREIGN KEY (UserCode) REFERENCES dbo.tblUsers (UserCode),
    CONSTRAINT FK_UserRole_Role FOREIGN KEY (RoleID) REFERENCES dbo.tblUserRoles (RoleID),
    CONSTRAINT UQ_UserRole_Assignment UNIQUE (UserCode, RoleID)
);
GO

-- tblPrivileges: Window-level privileges per user
CREATE TABLE dbo.tblPrivileges (
    PrivilegeID INT IDENTITY (1, 1) PRIMARY KEY,
    UserCode INT NOT NULL,
    WindowID INT NOT NULL,
    CanDisplay BIT DEFAULT 1,
    CanAdd BIT DEFAULT 1,
    CanEdit BIT DEFAULT 1,
    CanDelete BIT DEFAULT 1,
    CanPrint BIT DEFAULT 0,
    CanExport BIT DEFAULT 0,
    CanApprove BIT DEFAULT 0,
    CanPost BIT DEFAULT 0,
    CustomPermissions NVARCHAR (MAX) NULL,
    EffectiveFrom DATETIME DEFAULT GETDATE (),
    EffectiveTo DATETIME NULL,
    CreatedBy INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE (),
    ModifiedBy INT NULL,
    ModifiedAt DATETIME NULL,
    CONSTRAINT FK_Privileges_User FOREIGN KEY (UserCode) REFERENCES dbo.tblUsers (UserCode),
    CONSTRAINT FK_Privileges_Window FOREIGN KEY (WindowID) REFERENCES dbo.tblWindows (WindowID),
    CONSTRAINT UQ_UserWindow UNIQUE (UserCode, WindowID)
);
GO

CREATE INDEX idx_Privileges_User ON dbo.tblPrivileges (UserCode);

CREATE INDEX idx_Privileges_Window ON dbo.tblPrivileges (WindowID);
GO

-- tblSessions: Active user sessions with token-based auth
CREATE TABLE dbo.tblSessions (
    SessionID INT IDENTITY (1, 1) PRIMARY KEY,
    SessionToken UNIQUEIDENTIFIER NOT NULL UNIQUE DEFAULT NEWID (),
    UserCode INT NOT NULL,
    UserID NVARCHAR (15) NOT NULL,
    BranchCode INT NULL,
    MachineName NVARCHAR (100) NULL,
    IPAddress NVARCHAR (50) NULL,
    MacAddress NVARCHAR (50) NULL,
    BrowserInfo NVARCHAR (500) NULL,
    CreatedAt DATETIME DEFAULT GETDATE (),
    LastActivityAt DATETIME DEFAULT GETDATE (),
    ExpiresAt DATETIME NULL,
    LogoutAt DATETIME NULL,
    IsActive BIT DEFAULT 1,
    SessionData NVARCHAR (MAX) NULL,
    CONSTRAINT FK_Sessions_User FOREIGN KEY (UserCode) REFERENCES dbo.tblUsers (UserCode)
);
GO

CREATE INDEX idx_Sessions_Token ON dbo.tblSessions (SessionToken)
WHERE
    IsActive = 1;

CREATE INDEX idx_Sessions_User ON dbo.tblSessions (UserCode);

CREATE INDEX idx_Sessions_Expires ON dbo.tblSessions (ExpiresAt)
WHERE
    ExpiresAt IS NOT NULL;
GO

-- tblAuditLogs: Comprehensive audit trail
CREATE TABLE dbo.tblAuditLogs (
    AuditID BIGINT IDENTITY (1, 1) PRIMARY KEY,
    UserCode INT NULL,
    UserID NVARCHAR (15) NULL,
    EventType NVARCHAR (50) NOT NULL,
    EventCategory NVARCHAR (50) NOT NULL,
    EventDescription NVARCHAR (1000) NOT NULL,
    TableName NVARCHAR (100) NULL,
    RecordID INT NULL,
    OldValues NVARCHAR (MAX) NULL,
    NewValues NVARCHAR (MAX) NULL,
    SQLCommand NVARCHAR (MAX) NULL,
    IPAddress NVARCHAR (50) NULL,
    MachineName NVARCHAR (100) NULL,
    ApplicationName NVARCHAR (100) NULL,
    SessionToken UNIQUEIDENTIFIER NULL,
    DurationMS INT NULL,
    IsSuccess BIT DEFAULT 1,
    ErrorMessage NVARCHAR (MAX) NULL,
    EventDate DATETIME DEFAULT GETDATE (),
    AdditionalData NVARCHAR (MAX) NULL
);
GO

CREATE INDEX idx_AuditLogs_User ON dbo.tblAuditLogs (UserCode);

CREATE INDEX idx_AuditLogs_Date ON dbo.tblAuditLogs (EventDate);

CREATE INDEX idx_AuditLogs_Type ON dbo.tblAuditLogs (EventType);

CREATE INDEX idx_AuditLogs_Table ON dbo.tblAuditLogs (TableName, RecordID);
GO

PRINT 'Security Domain Tables created successfully.';
GO

-- ============================================================
-- SECTION 3: SYSTEM CONFIGURATION TABLES
-- ============================================================
PRINT '';

PRINT '========================================';

PRINT 'SECTION 3: Creating System Configuration Tables...';

PRINT '========================================';

-- tblBranches: Company branches/departments
CREATE TABLE dbo.tblBranches (
    BranchCode INT IDENTITY (1, 1) PRIMARY KEY,
    BranchNo NVARCHAR (50) UNIQUE NOT NULL,
    BranchNameAr NVARCHAR (200) NOT NULL,
    BranchNameEn NVARCHAR (200) NULL,
    BranchType INT DEFAULT 1, -- 1=Main, 2=Branch, 3=Warehouse, 4=Department
    Address NVARCHAR (500) NULL,
    City NVARCHAR (100) NULL,
    Country NVARCHAR (100) NULL,
    Phone1 NVARCHAR (50) NULL,
    Phone2 NVARCHAR (50) NULL,
    Fax NVARCHAR (50) NULL,
    Email NVARCHAR (100) NULL,
    Website NVARCHAR (200) NULL,
    TaxNumber NVARCHAR (50) NULL,
    CommercialRegister NVARCHAR (100) NULL,
    Logo VARBINARY(MAX) NULL,
    ManagerName NVARCHAR (200) NULL,
    ManagerPhone NVARCHAR (50) NULL,
    ParentBranchCode INT NULL,
    IsMainBranch BIT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CurrencyCode INT DEFAULT 1,
    FiscalYearStart INT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE (),
    ModifiedAt DATETIME NULL,
    Notes NVARCHAR (MAX) NULL,
    CONSTRAINT FK_Branches_Parent FOREIGN KEY (ParentBranchCode) REFERENCES dbo.tblBranches (BranchCode)
);
GO

CREATE INDEX idx_Branches_No ON dbo.tblBranches (BranchNo);

CREATE INDEX idx_Branches_Parent ON dbo.tblBranches (ParentBranchCode);
GO

-- tblCurrencies: Currency definitions
CREATE TABLE dbo.tblCurrencies (
    CurrencyCode INT IDENTITY (1, 1) PRIMARY KEY,
    CurrencyNo NVARCHAR (50) UNIQUE NOT NULL,
    CurrencyNameAr NVARCHAR (100) NOT NULL,
    CurrencyNameEn NVARCHAR (100) NOT NULL,
    CurrencySymbol NVARCHAR (10) NOT NULL,
    ISOcode NVARCHAR (3) NULL,
    DecimalPlaces INT DEFAULT 2,
    ExchangeRate DECIMAL(18, 6) DEFAULT 1,
    BuyRate DECIMAL(18, 6) DEFAULT 1,
    SellRate DECIMAL(18, 6) DEFAULT 1,
    IsMainCurrency BIT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    UpdatedAt DATETIME NULL,
    UpdatedBy INT NULL,
    Notes NVARCHAR (MAX) NULL
);
GO

CREATE INDEX idx_Currencies_Main ON dbo.tblCurrencies (IsMainCurrency)
WHERE
    IsMainCurrency = 1;
GO

-- tblBanks: Bank definitions
CREATE TABLE dbo.tblBanks (
    BankCode INT IDENTITY (1, 1) PRIMARY KEY,
    BankNo NVARCHAR (50) UNIQUE NOT NULL,
    BankNameAr NVARCHAR (200) NOT NULL,
    BankNameEn NVARCHAR (200) NULL,
    BankShortName NVARCHAR (50) NULL,
    AccountNo NVARCHAR (100) NULL,
    IBAN NVARCHAR (50) NULL,
    SwiftCode NVARCHAR (20) NULL,
    RoutingNumber NVARCHAR (50) NULL,
    BranchName NVARCHAR (200) NULL,
    BranchAddress NVARCHAR (500) NULL,
    Phone NVARCHAR (50) NULL,
    Fax NVARCHAR (50) NULL,
    Email NVARCHAR (100) NULL,
    ContactPerson NVARCHAR (200) NULL,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE (),
    ModifiedAt DATETIME NULL,
    Notes NVARCHAR (MAX) NULL
);
GO

CREATE INDEX idx_Banks_No ON dbo.tblBanks (BankNo);
GO

-- tblPaymentMethods: Payment method definitions
CREATE TABLE dbo.tblPaymentMethods (
    PaymentMethodCode INT IDENTITY (1, 1) PRIMARY KEY,
    PaymentMethodNo NVARCHAR (50) UNIQUE NOT NULL,
    PaymentMethodNameAr NVARCHAR (100) NOT NULL,
    PaymentMethodNameEn NVARCHAR (100) NULL,
    PaymentMethodType INT NOT NULL, -- 1=Cash, 2=Check, 3=Transfer, 4=Credit, 5=Card
    AccountCode INT NULL,
    BankCode INT NULL,
    IsActive BIT DEFAULT 1,
    IsDefault BIT DEFAULT 0,
    SortOrder INT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE (),
    Notes NVARCHAR (MAX) NULL,
    CONSTRAINT FK_PaymentMethods_Account FOREIGN KEY (AccountCode) REFERENCES dbo.tblAccounts (AccountCode),
    CONSTRAINT FK_PaymentMethods_Bank FOREIGN KEY (BankCode) REFERENCES dbo.tblBanks (BankCode)
);
GO

CREATE INDEX idx_PaymentMethods_Type ON dbo.tblPaymentMethods (PaymentMethodType);
GO

-- tblFunds: Cash/fund management
CREATE TABLE dbo.tblFunds (
    FundCode INT IDENTITY (1, 1) PRIMARY KEY,
    FundNo NVARCHAR (50) UNIQUE NOT NULL,
    FundNameAr NVARCHAR (200) NOT NULL,
    FundNameEn NVARCHAR (200) NULL,
    FundType INT DEFAULT 1, -- 1=Cash, 2=Bank, 3=PettyCash
    BranchCode INT NOT NULL,
    AccountCode INT NOT NULL,
    CurrentBalance DECIMAL(18, 4) DEFAULT 0,
    MinBalance DECIMAL(18, 4) DEFAULT 0,
    MaxBalance DECIMAL(18, 4) DEFAULT 0,
    CurrencyCode INT DEFAULT 1,
    IsDefault BIT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE (),
    ModifiedAt DATETIME NULL,
    Notes NVARCHAR (MAX) NULL,
    CONSTRAINT FK_Funds_Branch FOREIGN KEY (BranchCode) REFERENCES dbo.tblBranches (BranchCode),
    CONSTRAINT FK_Funds_Account FOREIGN KEY (AccountCode) REFERENCES dbo.tblAccounts (AccountCode),
    CONSTRAINT FK_Funds_Currency FOREIGN KEY (CurrencyCode) REFERENCES dbo.tblCurrencies (CurrencyCode)
);
GO

CREATE INDEX idx_Funds_Branch ON dbo.tblFunds (BranchCode);

CREATE INDEX idx_Funds_Account ON dbo.tblFunds (AccountCode);
GO

PRINT 'System Configuration Tables created successfully.';
GO

-- ============================================================
-- SECTION 4: CHART OF ACCOUNTS TABLE
-- ============================================================
PRINT '';

PRINT '========================================';

PRINT 'SECTION 4: Creating Chart of Accounts Table...';

PRINT '========================================';

-- tblAccounts: Chart of Accounts with hierarchical structure
CREATE TABLE dbo.tblAccounts (
    AccountCode INT IDENTITY (1, 1) PRIMARY KEY,
    AccountCodeNo NVARCHAR (50) UNIQUE NOT NULL,
    AccountNameAr NVARCHAR (200) NOT NULL,
    AccountNameEn NVARCHAR (200) NULL,
    AccountNameShort NVARCHAR (50) NULL,
    ParentCode INT NULL,
    AccountNature TINYINT NOT NULL, -- 1=Debit, 2=Credit, 3=BalanceSheet, 4=IncomeStatement, 5=NotPosted
    AccountType INT NOT NULL, -- 1=Assets, 2=Liabilities, 3=Equity, 4=Revenue, 5=Expenses
    AccountLevel INT DEFAULT 1,
    AccountClass INT DEFAULT 1, -- 1=Main, 2=Sub, 3=Detail
    CostCenterRequired BIT DEFAULT 0,
    CurrencyCode INT NULL,
    TaxRate DECIMAL(5, 2) DEFAULT 0,
    OpeningBalance DECIMAL(18, 4) DEFAULT 0,
    CurrentBalance DECIMAL(18, 4) DEFAULT 0,
    DebitBalance DECIMAL(18, 4) DEFAULT 0,
    CreditBalance DECIMAL(18, 4) DEFAULT 0,
    IsMainAccount BIT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    IsLocked BIT DEFAULT 0,
    AllowManualEntry BIT DEFAULT 1,
    AllowPosting BIT DEFAULT 1,
    IsSystemAccount BIT DEFAULT 0,
    BranchCode INT NULL,
    FundCode INT NULL,
    BankCode INT NULL,
    CustomerCode INT NULL,
    SupplierCode INT NULL,
    Reconciliation BIT DEFAULT 0,
    StatementType INT NULL, -- 1=BalanceSheet, 2=Income, 3=CashFlow
    ReportGroup NVARCHAR (50) NULL,
    Notes NVARCHAR (MAX) NULL,
    CreatedBy INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE (),
    ModifiedBy INT NULL,
    ModifiedAt DATETIME NULL,
    CONSTRAINT FK_Accounts_Parent FOREIGN KEY (ParentCode) REFERENCES dbo.tblAccounts (AccountCode),
    CONSTRAINT FK_Accounts_Currency FOREIGN KEY (CurrencyCode) REFERENCES dbo.tblCurrencies (CurrencyCode),
    CONSTRAINT FK_Accounts_Branch FOREIGN KEY (BranchCode) REFERENCES dbo.tblBranches (BranchCode),
    CONSTRAINT FK_Accounts_Fund FOREIGN KEY (FundCode) REFERENCES dbo.tblFunds (FundCode),
    CONSTRAINT FK_Accounts_Bank FOREIGN KEY (BankCode) REFERENCES dbo.tblBanks (BankCode),
    CONSTRAINT CK_AccountNature CHECK (AccountNature BETWEEN 1 AND 5),
    CONSTRAINT CK_AccountType CHECK (AccountType BETWEEN 1 AND 5)
);
GO

CREATE INDEX idx_Accounts_Parent ON dbo.tblAccounts (ParentCode);

CREATE INDEX idx_Accounts_CodeNo ON dbo.tblAccounts (AccountCodeNo);

CREATE INDEX idx_Accounts_Nature ON dbo.tblAccounts (AccountNature);

CREATE INDEX idx_Accounts_Type ON dbo.tblAccounts (AccountType);

CREATE INDEX idx_Accounts_Level ON dbo.tblAccounts (AccountLevel);

CREATE INDEX idx_Accounts_Branch ON dbo.tblAccounts (BranchCode)
WHERE
    BranchCode IS NOT NULL;
GO

-- tblCostCenters: Cost center definitions
CREATE TABLE dbo.tblCostCenters (
    CostCenterCode INT IDENTITY (1, 1) PRIMARY KEY,
    CostCenterNo NVARCHAR (50) UNIQUE NOT NULL,
    CostCenterNameAr NVARCHAR (200) NOT NULL,
    CostCenterNameEn NVARCHAR (200) NULL,
    ParentCode INT NULL,
    CostCenterType INT DEFAULT 1, -- 1=Department, 2=Project, 3=Product, 4=Region
    ManagerName NVARCHAR (200) NULL,
    BudgetAmount DECIMAL(18, 4) DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE (),
    Notes NVARCHAR (MAX) NULL,
    CONSTRAINT FK_CostCenters_Parent FOREIGN KEY (ParentCode) REFERENCES dbo.tblCostCenters (CostCenterCode)
);
GO

CREATE INDEX idx_CostCenters_Parent ON dbo.tblCostCenters (ParentCode);
GO

PRINT 'Chart of Accounts Table created successfully.';
GO

-- ============================================================
-- SECTION 5: FINANCIAL TRANSACTIONS TABLES
-- ============================================================
PRINT '';

PRINT '========================================';

PRINT 'SECTION 5: Creating Financial Transactions Tables...';

PRINT '========================================';

-- tblBondHeader: Bond/Voucher header (Payment, Receipt, Transfer)
CREATE TABLE dbo.tblBondHeader (
    BondHeaderID INT IDENTITY (1, 1) PRIMARY KEY,
    BondNo INT NOT NULL,
    BondNoPrefix NVARCHAR (10) DEFAULT 'BND',
    BondDate DATETIME NOT NULL,
    BondType INT NOT NULL, -- 1=Payment, 2=Receipt, 3=Transfer, 4=Adjust
    BondStatus INT DEFAULT 1, -- 1=Draft, 2=Posted, 3=Cancelled, 4=Reversed
    AccountCode INT NOT NULL, -- Main account (Bank/Cash/Fund)
    CurrencyCode INT DEFAULT 1,
    ExchangeRate DECIMAL(18, 6) DEFAULT 1,
    TotalAmount DECIMAL(18, 4) NOT NULL DEFAULT 0,
    TotalAmountFC DECIMAL(18, 4) DEFAULT 0,
    AmountInWords NVARCHAR (500) NULL,
    PaymentMethodCode INT NULL,
    CheckNo NVARCHAR (50) NULL,
    CheckDate DATETIME NULL,
    BankCode INT NULL,
    ReferenceNo NVARCHAR (50) NULL,
    ReferenceDate DATETIME NULL,
    Description NVARCHAR (500) NULL,
    Notes NVARCHAR (MAX) NULL,
    IsPosted BIT DEFAULT 0,
    PostedBy INT NULL,
    PostedAt DATETIME NULL,
    IsCancelled BIT DEFAULT 0,
    CancelledBy INT NULL,
    CancelledAt DATETIME NULL,
    CancellationReason NVARCHAR (500) NULL,
    IsReversed BIT DEFAULT 0,
    ReversedBondID INT NULL,
    BranchCode INT NULL,
    FundCode INT NULL,
    CostCenterCode INT NULL,
    RelatedBondID INT NULL,
    UserCode INT NOT NULL,
    CreatedBy INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE (),
    ModifiedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ApprovedBy INT NULL,
    ApprovedAt DATETIME NULL,
    CONSTRAINT FK_BondHeader_Account FOREIGN KEY (AccountCode) REFERENCES dbo.tblAccounts (AccountCode),
    CONSTRAINT FK_BondHeader_Currency FOREIGN KEY (CurrencyCode) REFERENCES dbo.tblCurrencies (CurrencyCode),
    CONSTRAINT FK_BondHeader_PaymentMethod FOREIGN KEY (PaymentMethodCode) REFERENCES dbo.tblPaymentMethods (PaymentMethodCode),
    CONSTRAINT FK_BondHeader_Bank FOREIGN KEY (BankCode) REFERENCES dbo.tblBanks (BankCode),
    CONSTRAINT FK_BondHeader_Branch FOREIGN KEY (BranchCode) REFERENCES dbo.tblBranches (BranchCode),
    CONSTRAINT FK_BondHeader_Fund FOREIGN KEY (FundCode) REFERENCES dbo.tblFunds (FundCode),
    CONSTRAINT FK_BondHeader_CostCenter FOREIGN KEY (CostCenterCode) REFERENCES dbo.tblCostCenters (CostCenterCode),
    CONSTRAINT FK_BondHeader_User FOREIGN KEY (UserCode) REFERENCES dbo.tblUsers (UserCode),
    CONSTRAINT CK_BondType CHECK (BondType BETWEEN 1 AND 4)
);
GO

CREATE INDEX idx_BondHeader_No ON dbo.tblBondHeader (BondNo);

CREATE INDEX idx_BondHeader_Date ON dbo.tblBondHeader (BondDate);

CREATE INDEX idx_BondHeader_Type ON dbo.tblBondHeader (BondType);

CREATE INDEX idx_BondHeader_Status ON dbo.tblBondHeader (BondStatus);

CREATE INDEX idx_BondHeader_Account ON dbo.tblBondHeader (AccountCode);

CREATE INDEX idx_BondHeader_Branch ON dbo.tblBondHeader (BranchCode);

CREATE INDEX idx_BondHeader_Posted ON dbo.tblBondHeader (IsPosted)
WHERE
    IsPosted = 1;
GO

-- tblBondBody: Bond details/lines
CREATE TABLE dbo.tblBondBody (
    BondBodyID INT IDENTITY (1, 1) PRIMARY KEY,
    BondHeaderID INT NOT NULL,
    LineNo INT NOT NULL,
    AccountCode INT NOT NULL,
    Description NVARCHAR (500) NULL,
    DescriptionEn NVARCHAR (500) NULL,
    DebitAmount DECIMAL(18, 4) DEFAULT 0,
    CreditAmount DECIMAL(18, 4) DEFAULT 0,
    AmountFC DECIMAL(18, 4) DEFAULT 0,
    CostCenterCode INT NULL,
    ProjectCode INT NULL,
    BranchCode INT NULL,
    CurrencyCode INT NULL,
    ExchangeRate DECIMAL(18, 6) DEFAULT 1,
    TaxAmount DECIMAL(18, 4) DEFAULT 0,
    TaxAccountCode INT NULL,
    ReferenceNo NVARCHAR (50) NULL,
    ReferenceDate DATETIME NULL,
    DueDate DATETIME NULL,
    IsMatched BIT DEFAULT 0,
    MatchedWith INT NULL,
    Notes NVARCHAR (MAX) NULL,
    CreatedBy INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE (),
    CONSTRAINT FK_BondBody_Header FOREIGN KEY (BondHeaderID) REFERENCES dbo.tblBondHeader (BondHeaderID) ON DELETE CASCADE,
    CONSTRAINT FK_BondBody_Account FOREIGN KEY (AccountCode) REFERENCES dbo.tblAccounts (AccountCode),
    CONSTRAINT FK_BondBody_CostCenter FOREIGN KEY (CostCenterCode) REFERENCES dbo.tblCostCenters (CostCenterCode),
    CONSTRAINT FK_BondBody_Currency FOREIGN KEY (CurrencyCode) REFERENCES dbo.tblCurrencies (CurrencyCode),
    CONSTRAINT CK_BondBody_Amount CHECK (
        DebitAmount >= 0
        AND CreditAmount >= 0
    )
);
GO

CREATE INDEX idx_BondBody_Header ON dbo.tblBondBody (BondHeaderID);

CREATE INDEX idx_BondBody_Account ON dbo.tblBondBody (AccountCode);

CREATE INDEX idx_BondBody_CostCenter ON dbo.tblBondBody (CostCenterCode)
WHERE
    CostCenterCode IS NOT NULL;
GO

PRINT 'Financial Transactions Tables (Bonds) created successfully.';
GO

-- tblJournalHeader: Journal entry header
CREATE TABLE dbo.tblJournalHeader (
    JournalHeaderID INT IDENTITY (1, 1) PRIMARY KEY,
    JournalNo INT NOT NULL,
    JournalNoPrefix NVARCHAR (10) DEFAULT 'JRN',
    JournalDate DATETIME NOT NULL,
    JournalType INT NOT NULL, -- 1=Manual, 2=Auto, 3=Recurring, 4=Reversal
    JournalStatus INT DEFAULT 1, -- 1=Draft, 2=Posted, 3=Cancelled, 4=Reversed
    Description NVARCHAR (500) NOT NULL,
    DescriptionEn NVARCHAR (500) NULL,
    TotalDebit DECIMAL(18, 4) NOT NULL DEFAULT 0,
    TotalCredit DECIMAL(18, 4) NOT NULL DEFAULT 0,
    TotalDebitFC DECIMAL(18, 4) DEFAULT 0,
    TotalCreditFC DECIMAL(18, 4) DEFAULT 0,
    CurrencyCode INT DEFAULT 1,
    ExchangeRate DECIMAL(18, 6) DEFAULT 1,
    SourceType NVARCHAR (50) NULL, -- Bond, Invoice, etc.
    SourceID INT NULL,
    SourceNo NVARCHAR (50) NULL,
    ReferenceNo NVARCHAR (50) NULL,
    ReferenceDate DATETIME NULL,
    BranchCode INT NULL,
    CostCenterCode INT NULL,
    IsPosted BIT DEFAULT 0,
    PostedBy INT NULL,
    PostedAt DATETIME NULL,
    IsCancelled BIT DEFAULT 0,
    CancelledBy INT NULL,
    CancelledAt DATETIME NULL,
    CancellationReason NVARCHAR (500) NULL,
    IsReversed BIT DEFAULT 0,
    ReversedJournalID INT NULL,
    IsRecurring BIT DEFAULT 0,
    RecurringPattern NVARCHAR (100) NULL,
    NextRecurringDate DATETIME NULL,
    UserCode INT NOT NULL,
    CreatedBy INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE (),
    ModifiedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ApprovedBy INT NULL,
    ApprovedAt DATETIME NULL,
    Attachments NVARCHAR (MAX) NULL,
    CONSTRAINT FK_JournalHeader_Currency FOREIGN KEY (CurrencyCode) REFERENCES dbo.tblCurrencies (CurrencyCode),
    CONSTRAINT FK_JournalHeader_Branch FOREIGN KEY (BranchCode) REFERENCES dbo.tblBranches (BranchCode),
    CONSTRAINT FK_JournalHeader_CostCenter FOREIGN KEY (CostCenterCode) REFERENCES dbo.tblCostCenters (CostCenterCode),
    CONSTRAINT FK_JournalHeader_User FOREIGN KEY (UserCode) REFERENCES dbo.tblUsers (UserCode),
    CONSTRAINT CK_JournalBalanced CHECK (TotalDebit = TotalCredit)
);
GO

CREATE INDEX idx_JournalHeader_No ON dbo.tblJournalHeader (JournalNo);

CREATE INDEX idx_JournalHeader_Date ON dbo.tblJournalHeader (JournalDate);

CREATE INDEX idx_JournalHeader_Type ON dbo.tblJournalHeader (JournalType);

CREATE INDEX idx_JournalHeader_Status ON dbo.tblJournalHeader (JournalStatus);

CREATE INDEX idx_JournalHeader_Branch ON dbo.tblJournalHeader (BranchCode);

CREATE INDEX idx_JournalHeader_Source ON dbo.tblJournalHeader (SourceType, SourceID);

CREATE INDEX idx_JournalHeader_Posted ON dbo.tblJournalHeader (IsPosted)
WHERE
    IsPosted = 1;
GO

-- tblJournalBody: Journal entry lines
CREATE TABLE dbo.tblJournalBody (
    JournalBodyID INT IDENTITY (1, 1) PRIMARY KEY,
    JournalHeaderID INT NOT NULL,
    LineNo INT NOT NULL,
    AccountCode INT NOT NULL,
    Description NVARCHAR (500) NULL,
    DescriptionEn NVARCHAR (500) NULL,
    DebitAmount DECIMAL(18, 4) DEFAULT 0,
    CreditAmount DECIMAL(18, 4) DEFAULT 0,
    AmountFC DECIMAL(18, 4) DEFAULT 0,
    CostCenterCode INT NULL,
    ProjectCode INT NULL,
    BranchCode INT NULL,
    CurrencyCode INT NULL,
    ExchangeRate DECIMAL(18, 6) DEFAULT 1,
    TaxAmount DECIMAL(18, 4) DEFAULT 0,
    TaxAccountCode INT NULL,
    TaxPercent DECIMAL(5, 2) DEFAULT 0,
    ReferenceNo NVARCHAR (50) NULL,
    ReferenceDate DATETIME NULL,
    DueDate DATETIME NULL,
    IsMatched BIT DEFAULT 0,
    MatchedJournalLineID INT NULL,
    MatchedAmount DECIMAL(18, 4) DEFAULT 0,
    ReconciliationDate DATETIME NULL,
    Notes NVARCHAR (MAX) NULL,
    CreatedBy INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE (),
    CONSTRAINT FK_JournalBody_Header FOREIGN KEY (JournalHeaderID) REFERENCES dbo.tblJournalHeader (JournalHeaderID) ON DELETE CASCADE,
    CONSTRAINT FK_JournalBody_Account FOREIGN KEY (AccountCode) REFERENCES dbo.tblAccounts (AccountCode),
    CONSTRAINT FK_JournalBody_CostCenter FOREIGN KEY (CostCenterCode) REFERENCES dbo.tblCostCenters (CostCenterCode),
    CONSTRAINT FK_JournalBody_Currency FOREIGN KEY (CurrencyCode) REFERENCES dbo.tblCurrencies (CurrencyCode),
    CONSTRAINT CK_JournalBody_Amount CHECK (
        DebitAmount >= 0
        AND CreditAmount >= 0
    )
);
GO

CREATE INDEX idx_JournalBody_Header ON dbo.tblJournalBody (JournalHeaderID);

CREATE INDEX idx_JournalBody_Account ON dbo.tblJournalBody (AccountCode);

CREATE INDEX idx_JournalBody_CostCenter ON dbo.tblJournalBody (CostCenterCode)
WHERE
    CostCenterCode IS NOT NULL;
GO

PRINT 'Financial Transactions Tables (Journal) created successfully.';
GO

-- ============================================================
-- SECTION 6: INVENTORY DOMAIN TABLES (جداول المخزون)
-- ============================================================
PRINT '';

PRINT '========================================';

PRINT 'SECTION 6: Creating Inventory Domain Tables...';

PRINT '========================================';

-- tblStores: Warehouse and store definitions
CREATE TABLE dbo.tblStores (
    StoreCode INT IDENTITY (1, 1) PRIMARY KEY,
    StoreID NVARCHAR (20) UNIQUE NOT NULL,
    StoreNameAr NVARCHAR (200) NOT NULL,
    StoreNameEn NVARCHAR (200) NULL,
    StoreType NVARCHAR (20) DEFAULT 'STORE',
    -- Types: STORE, WAREHOUSE, SHOWROOM, MAINTENANCE, PRODUCTION
    Location NVARCHAR (500) NULL,
    Address NVARCHAR (500) NULL,
    City NVARCHAR (100) NULL,
    Country NVARCHAR (100) DEFAULT 'السعودية',
    ContactPerson NVARCHAR (200) NULL,
    Phone NVARCHAR (50) NULL,
    Mobile NVARCHAR (50) NULL,
    Email NVARCHAR (100) NULL,
    IsMainStore BIT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    BranchCode INT NULL,
    DefaultCurrency NVARCHAR (10) NULL,
    MinStockLevel DECIMAL(18, 4) DEFAULT 0,
    MaxStockLevel DECIMAL(18, 4) DEFAULT 0,
    ReorderPoint DECIMAL(18, 4) DEFAULT 0,
    ResponsibleUser INT NULL,
    OpeningDate DATE NULL,
    Notes NVARCHAR (MAX) NULL,
    CreatedBy INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE (),
    ModifiedBy INT NULL,
    ModifiedAt DATETIME NULL
);
GO

CREATE INDEX idx_Stores_ID ON dbo.tblStores (StoreID);

CREATE INDEX idx_Stores_Type ON dbo.tblStores (StoreType);

CREATE INDEX idx_Stores_Branch ON dbo.tblStores (BranchCode)
WHERE
    BranchCode IS NOT NULL;

CREATE INDEX idx_Stores_Active ON dbo.tblStores (IsActive)
WHERE
    IsActive = 1;
GO

-- tblCategories: Product categories with hierarchy
CREATE TABLE dbo.tblCategories (
    CategoryCode INT IDENTITY (1, 1) PRIMARY KEY,
    CategoryID NVARCHAR (20) UNIQUE NOT NULL,
    CategoryNameAr NVARCHAR (200) NOT NULL,
    CategoryNameEn NVARCHAR (200) NULL,
    ParentCategoryCode INT NULL,
    CategoryLevel INT DEFAULT 1,
    CategoryPath NVARCHAR (500) NULL,
    -- Full path for hierarchy: /Root/Parent/Current
    CategoryType NVARCHAR (20) DEFAULT 'PRODUCT',
    -- Types: PRODUCT, SERVICE, ASSET, EXPENSE, MATERIAL, SPARE_PART
    ImageURL NVARCHAR (500) NULL,
    IconName NVARCHAR (100) NULL,
    Description NVARCHAR (MAX) NULL,
    IsActive BIT DEFAULT 1,
    IsSystem BIT DEFAULT 0,
    SortOrder INT DEFAULT 0,
    Notes NVARCHAR (MAX) NULL,
    CreatedBy INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE (),
    ModifiedBy INT NULL,
    ModifiedAt DATETIME NULL,
    CONSTRAINT FK_Categories_Parent FOREIGN KEY (ParentCategoryCode) REFERENCES dbo.tblCategories (CategoryCode)
);
GO

CREATE INDEX idx_Categories_ID ON dbo.tblCategories (CategoryID);

CREATE INDEX idx_Categories_Parent ON dbo.tblCategories (ParentCategoryCode);

CREATE INDEX idx_Categories_Type ON dbo.tblCategories (CategoryType);

CREATE INDEX idx_Categories_Path ON dbo.tblCategories (CategoryPath)
WHERE
    CategoryPath IS NOT NULL;
GO

-- tblUnits: Measurement units
CREATE TABLE dbo.tblUnits (
    UnitCode INT IDENTITY (1, 1) PRIMARY KEY,
    UnitID NVARCHAR (20) UNIQUE NOT NULL,
    UnitNameAr NVARCHAR (100) NOT NULL,
    UnitNameEn NVARCHAR (100) NULL,
    UnitSymbol NVARCHAR (20) NOT NULL,
    UnitType NVARCHAR (20) DEFAULT 'QUANTITY',
    -- Types: QUANTITY, WEIGHT, LENGTH, VOLUME, AREA, TIME, CUSTOM
    BaseUnitCode INT NULL,
    ConversionFactor DECIMAL(18, 6) DEFAULT 1,
    -- Conversion to base unit
    IsBaseUnit BIT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    DecimalPlaces INT DEFAULT 2,
    SortOrder INT DEFAULT 0,
    Notes NVARCHAR (MAX) NULL,
    CreatedBy INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE (),
    ModifiedBy INT NULL,
    ModifiedAt DATETIME NULL,
    CONSTRAINT FK_Units_BaseUnit FOREIGN KEY (BaseUnitCode) REFERENCES dbo.tblUnits (UnitCode)
);
GO

CREATE INDEX idx_Units_ID ON dbo.tblUnits (UnitID);

CREATE INDEX idx_Units_Type ON dbo.tblUnits (UnitType);

CREATE INDEX idx_Units_BaseUnit ON dbo.tblUnits (BaseUnitCode)
WHERE
    BaseUnitCode IS NOT NULL;
GO

-- tblProducts: Product/Material definitions
CREATE TABLE dbo.tblProducts (
    ProductCode        INT IDENTITY(1,1) PRIMARY KEY,
    ProductID          NVARCHAR(30) UNIQUE NOT NULL,
    ProductNameAr      NVARCHAR(400) NOT NULL,
    ProductNameEn      NVARCHAR(400) NULL,
    ShortName          NVARCHAR(100) NULL,
    Description        NVARCHAR(MAX) NULL,
    CategoryCode       INT NULL,
    ProductType        NVARCHAR(20) NOT NULL DEFAULT 'PRODUCT',
    -- Types: PRODUCT, SERVICE, MATERIAL, SPARE_PART, ASSET, BUNDLE, VARIANT
    BrandID            NVARCHAR(30) NULL,
    ModelNo            NVARCHAR(100) NULL,
    Barcode            NVARCHAR(100) NULL,
    SerialTracking     BIT DEFAULT 0,
    ExpiryTracking     BIT DEFAULT 0,
    BatchTracking      BIT DEFAULT 0,

-- Default Unit
DefaultUnitCode INT NOT NULL,
SecondaryUnitCode INT NULL,
SecondaryFactor DECIMAL(18, 6) DEFAULT 1,

-- Pricing
CostMethod NVARCHAR (20) DEFAULT 'AVERAGE',
-- Methods: FIFO, LIFO, AVERAGE, STANDARD, SPECIFIC
StandardCost DECIMAL(18, 6) DEFAULT 0,
LastPurchasePrice DECIMAL(18, 6) DEFAULT 0,
LastSalePrice DECIMAL(18, 4) DEFAULT 0,
MinPrice DECIMAL(18, 4) DEFAULT 0,
MaxPrice DECIMAL(18, 4) DEFAULT 0,
WholesalePrice DECIMAL(18, 4) DEFAULT 0,
RetailPrice DECIMAL(18, 4) DEFAULT 0,
TaxRate DECIMAL(5, 2) DEFAULT 0,
TaxAccountCode INT NULL,

-- Stock Settings
DefaultStoreCode INT NULL,
MinStockLevel DECIMAL(18, 4) DEFAULT 0,
MaxStockLevel DECIMAL(18, 4) DEFAULT 0,
ReorderLevel DECIMAL(18, 4) DEFAULT 0,
ReorderQty DECIMAL(18, 4) DEFAULT 0,

-- Dimensions
Weight DECIMAL(10, 3) NULL,
WeightUnit NVARCHAR (10) DEFAULT 'KG',
Length DECIMAL(10, 3) NULL,
Width DECIMAL(10, 3) NULL,
Height DECIMAL(10, 3) NULL,
DimensionUnit NVARCHAR (10) DEFAULT 'CM',

-- Image & Files
ImageURL NVARCHAR (500) NULL,
ImageData VARBINARY(MAX) NULL,
AttachmentURL NVARCHAR (500) NULL,

-- Status
IsActive BIT DEFAULT 1,
IsService BIT DEFAULT 0,
IsPurchasable BIT DEFAULT 1,
IsSalable BIT DEFAULT 1,
IsInventoryItem BIT DEFAULT 1,
IsTaxable BIT DEFAULT 1,

-- Accounting
SalesAccountCode INT NULL,
PurchaseAccountCode INT NULL,
InventoryAccountCode INT NULL,
COGSAccountCode INT NULL,
AdjustmentAccountCode INT NULL,

-- Expiry
ShelfLifeDays INT NULL, AlertBeforeDays INT DEFAULT 30,

-- Metadata
Manufacturer       NVARCHAR(200) NULL,
    CountryOfOrigin    NVARCHAR(100) NULL,
    HSCode             NVARCHAR(20) NULL,
    
    Notes              NVARCHAR(MAX) NULL,
    CreatedBy          INT NULL,
    CreatedAt          DATETIME DEFAULT GETDATE(),
    ModifiedBy         INT NULL,
    ModifiedAt         DATETIME NULL,
    CONSTRAINT FK_Products_Category FOREIGN KEY (CategoryCode) REFERENCES dbo.tblCategories(CategoryCode),
    CONSTRAINT FK_Products_DefaultUnit FOREIGN KEY (DefaultUnitCode) REFERENCES dbo.tblUnits(UnitCode),
    CONSTRAINT FK_Products_SecondaryUnit FOREIGN KEY (SecondaryUnitCode) REFERENCES dbo.tblUnits(UnitCode)
);
GO

CREATE INDEX idx_Products_ID ON dbo.tblProducts (ProductID);

CREATE INDEX idx_Products_Barcode ON dbo.tblProducts (Barcode)
WHERE
    Barcode IS NOT NULL;

CREATE INDEX idx_Products_Category ON dbo.tblProducts (CategoryCode)
WHERE
    CategoryCode IS NOT NULL;

CREATE INDEX idx_Products_Type ON dbo.tblProducts (ProductType);

CREATE INDEX idx_Products_Active ON dbo.tblProducts (IsActive)
WHERE
    IsActive = 1;

CREATE INDEX idx_Products_NameAr ON dbo.tblProducts (ProductNameAr);
GO

-- tblProductBatches: Batch tracking for products
CREATE TABLE dbo.tblProductBatches (
    BatchID INT IDENTITY (1, 1) PRIMARY KEY,
    ProductCode INT NOT NULL,
    BatchNo NVARCHAR (50) NOT NULL,
    ManufacturingDate DATE NULL,
    ExpiryDate DATE NULL,
    ProductionDate DATE NULL,
    QtyOnHand DECIMAL(18, 4) DEFAULT 0,
    QtyReserved DECIMAL(18, 4) DEFAULT 0,
    QtyAvailable AS QtyOnHand - QtyReserved,
    Cost DECIMAL(18, 6) DEFAULT 0,
    LocationInStore NVARCHAR (100) NULL,
    SupplierBatchNo NVARCHAR (100) NULL,
    IsActive BIT DEFAULT 1,
    Notes NVARCHAR (MAX) NULL,
    CreatedBy INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE (),
    ModifiedBy INT NULL,
    ModifiedAt DATETIME NULL,
    CONSTRAINT FK_ProductBatches_Product FOREIGN KEY (ProductCode) REFERENCES dbo.tblProducts (ProductCode),
    CONSTRAINT UQ_ProductBatch UNIQUE (ProductCode, BatchNo)
);
GO

CREATE INDEX idx_ProductBatches_Product ON dbo.tblProductBatches (ProductCode);

CREATE INDEX idx_ProductBatches_Expiry ON dbo.tblProductBatches (ExpiryDate)
WHERE
    ExpiryDate IS NOT NULL;

CREATE INDEX idx_ProductBatches_Active ON dbo.tblProductBatches (IsActive)
WHERE
    IsActive = 1;
GO

-- tblProductMovement: Stock movement transactions
CREATE TABLE dbo.tblProductMovement (
    MovementID BIGINT IDENTITY (1, 1) PRIMARY KEY,
    MovementNo NVARCHAR (30) UNIQUE NOT NULL,
    MovementType NVARCHAR (20) NOT NULL,
    -- Types: PURCHASE, PURCHASE_RETURN, SALE, SALE_RETURN, TRANSFER_IN, TRANSFER_OUT
    -- ADJUSTMENT_IN, ADJUSTMENT_OUT, OPENING, DAMAGE, THEFT, EXPIRED, PRODUCTION_IN, PRODUCTION_OUT
    MovementDate DATE NOT NULL,
    MovementTime DATETIME DEFAULT GETDATE (),
    ProductCode INT NOT NULL,
    StoreCode INT NOT NULL,
    BatchID INT NULL,
    SerialNo NVARCHAR (100) NULL,
    Qty DECIMAL(18, 4) NOT NULL,
    QtyBefore DECIMAL(18, 4) DEFAULT 0,
    QtyAfter DECIMAL(18, 4) DEFAULT 0,
    UnitCode INT NOT NULL,
    UnitPrice DECIMAL(18, 6) DEFAULT 0,
    TotalPrice DECIMAL(18, 4) DEFAULT 0,
    CostBefore DECIMAL(18, 6) DEFAULT 0,
    CostAfter DECIMAL(18, 6) DEFAULT 0,
    CurrencyCode NVARCHAR (10) NULL,
    ExchangeRate DECIMAL(18, 6) DEFAULT 1,
    TaxAmount DECIMAL(18, 4) DEFAULT 0,
    TaxPercent DECIMAL(5, 2) DEFAULT 0,
    SourceType NVARCHAR (30) NULL,
    -- Source: PURCHASE_ORDER, SALE_ORDER, PURCHASE_INVOICE, SALE_INVOICE, BOND, JOURNAL, TRANSFER
    SourceID INT NULL,
    SourceNo NVARCHAR (50) NULL,
    ToStoreCode INT NULL,
    ToBatchID INT NULL,
    ToSerialNo NVARCHAR (100) NULL,
    ReferenceNo NVARCHAR (50) NULL,
    ReferenceDate DATETIME NULL,
    CostCenterCode INT NULL,
    ProjectCode INT NULL,
    BranchCode INT NULL,
    Notes NVARCHAR (MAX) NULL,
    UserCode INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE (),
    CONSTRAINT FK_ProductMovement_Product FOREIGN KEY (ProductCode) REFERENCES dbo.tblProducts (ProductCode),
    CONSTRAINT FK_ProductMovement_Store FOREIGN KEY (StoreCode) REFERENCES dbo.tblStores (StoreCode),
    CONSTRAINT FK_ProductMovement_Batch FOREIGN KEY (BatchID) REFERENCES dbo.tblProductBatches (BatchID),
    CONSTRAINT FK_ProductMovement_Unit FOREIGN KEY (UnitCode) REFERENCES dbo.tblUnits (UnitCode),
    CONSTRAINT FK_ProductMovement_ToStore FOREIGN KEY (ToStoreCode) REFERENCES dbo.tblStores (StoreCode),
    CONSTRAINT FK_ProductMovement_User FOREIGN KEY (UserCode) REFERENCES dbo.tblUsers (UserCode)
);
GO

CREATE INDEX idx_ProductMovement_No ON dbo.tblProductMovement (MovementNo);

CREATE INDEX idx_ProductMovement_Date ON dbo.tblProductMovement (MovementDate);

CREATE INDEX idx_ProductMovement_Type ON dbo.tblProductMovement (MovementType);

CREATE INDEX idx_ProductMovement_Product ON dbo.tblProductMovement (ProductCode);

CREATE INDEX idx_ProductMovement_Store ON dbo.tblProductMovement (StoreCode);

CREATE INDEX idx_ProductMovement_Batch ON dbo.tblProductMovement (BatchID)
WHERE
    BatchID IS NOT NULL;

CREATE INDEX idx_ProductMovement_Source ON dbo.tblProductMovement (SourceType, SourceID);

CREATE INDEX idx_ProductMovement_User ON dbo.tblProductMovement (UserCode);
GO

-- tblProductPricing: Multiple price lists
CREATE TABLE dbo.tblProductPricing (
    PriceID INT IDENTITY (1, 1) PRIMARY KEY,
    ProductCode INT NOT NULL,
    PriceListCode INT NOT NULL,
    UnitCode INT NOT NULL,
    Price DECIMAL(18, 4) NOT NULL,
    MinQty DECIMAL(18, 4) DEFAULT 1,
    MaxQty DECIMAL(18, 4) NULL,
    CurrencyCode NVARCHAR (10) DEFAULT 'SAR',
    ValidFrom DATE NULL,
    ValidTo DATE NULL,
    IsActive BIT DEFAULT 1,
    IsDefault BIT DEFAULT 0,
    Notes NVARCHAR (MAX) NULL,
    CreatedBy INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE (),
    ModifiedBy INT NULL,
    ModifiedAt DATETIME NULL,
    CONSTRAINT FK_ProductPricing_Product FOREIGN KEY (ProductCode) REFERENCES dbo.tblProducts (ProductCode),
    CONSTRAINT FK_ProductPricing_Unit FOREIGN KEY (UnitCode) REFERENCES dbo.tblUnits (UnitCode),
    CONSTRAINT UQ_ProductPriceList UNIQUE (
        ProductCode,
        PriceListCode,
        UnitCode
    )
);
GO

CREATE INDEX idx_ProductPricing_Product ON dbo.tblProductPricing (ProductCode);

CREATE INDEX idx_ProductPricing_Active ON dbo.tblProductPricing (IsActive)
WHERE
    IsActive = 1;
GO

-- tblProductImages: Product images gallery
CREATE TABLE dbo.tblProductImages (
    ImageID INT IDENTITY (1, 1) PRIMARY KEY,
    ProductCode INT NOT NULL,
    ImageName NVARCHAR (200) NOT NULL,
    ImageData VARBINARY(MAX) NULL,
    ImageURL NVARCHAR (500) NULL,
    ImageOrder INT DEFAULT 0,
    IsPrimary BIT DEFAULT 0,
    ImageType NVARCHAR (20) DEFAULT 'MAIN',
    -- Types: MAIN, GALLERY, THUMBNAIL, TECHNICAL, CERTIFICATE
    Width INT NULL,
    Height INT NULL,
    FileSize INT NULL,
    MimeType NVARCHAR (50) NULL,
    Notes NVARCHAR (MAX) NULL,
    CreatedBy INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE (),
    CONSTRAINT FK_ProductImages_Product FOREIGN KEY (ProductCode) REFERENCES dbo.tblProducts (ProductCode) ON DELETE CASCADE
);
GO

CREATE INDEX idx_ProductImages_Product ON dbo.tblProductImages (ProductCode);

CREATE INDEX idx_ProductImages_Primary ON dbo.tblProductImages (ProductCode, IsPrimary)
WHERE
    IsPrimary = 1;
GO

-- tblStoreProducts: Current stock levels per product per store
CREATE TABLE dbo.tblStoreProducts (
    StoreProductID BIGINT IDENTITY (1, 1) PRIMARY KEY,
    StoreCode INT NOT NULL,
    ProductCode INT NOT NULL,
    BatchID INT NULL,
    QtyOnHand DECIMAL(18, 4) DEFAULT 0,
    QtyReserved DECIMAL(18, 4) DEFAULT 0,
    QtyAvailable AS QtyOnHand - QtyReserved,
    QtyOnOrder DECIMAL(18, 4) DEFAULT 0,
    QtyOnTransit DECIMAL(18, 4) DEFAULT 0,
    AvgCost DECIMAL(18, 6) DEFAULT 0,
    LastCost DECIMAL(18, 6) DEFAULT 0,
    MinLevel DECIMAL(18, 4) DEFAULT 0,
    MaxLevel DECIMAL(18, 4) DEFAULT 0,
    ReorderLevel DECIMAL(18, 4) DEFAULT 0,
    LastPurchaseDate DATE NULL,
    LastPurchasePrice DECIMAL(18, 6) DEFAULT 0,
    LastSaleDate DATE NULL,
    LastSalePrice DECIMAL(18, 4) DEFAULT 0,
    LocationInStore NVARCHAR (100) NULL,
    IsActive BIT DEFAULT 1,
    Notes NVARCHAR (MAX) NULL,
    CreatedBy INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE (),
    ModifiedBy INT NULL,
    ModifiedAt DATETIME NULL,
    CONSTRAINT FK_StoreProducts_Store FOREIGN KEY (StoreCode) REFERENCES dbo.tblStores (StoreCode),
    CONSTRAINT FK_StoreProducts_Product FOREIGN KEY (ProductCode) REFERENCES dbo.tblProducts (ProductCode),
    CONSTRAINT FK_StoreProducts_Batch FOREIGN KEY (BatchID) REFERENCES dbo.tblProductBatches (BatchID),
    CONSTRAINT UQ_StoreProductBatch UNIQUE (
        StoreCode,
        ProductCode,
        BatchID
    )
);
GO

CREATE INDEX idx_StoreProducts_Store ON dbo.tblStoreProducts (StoreCode);

CREATE INDEX idx_StoreProducts_Product ON dbo.tblStoreProducts (ProductCode);

CREATE INDEX idx_StoreProducts_LowStock ON dbo.tblStoreProducts (
    ProductCode,
    QtyOnHand,
    MinLevel
)
WHERE
    QtyOnHand <= MinLevel;
GO

PRINT 'Inventory Domain Tables created successfully.';
GO

-- ============================================================
-- SECTION 7: TRANSACTION DOMAIN TABLES (جداول المعاملات)
-- ============================================================
PRINT '';

PRINT '========================================';

PRINT 'SECTION 7: Creating Transaction Domain Tables...';

PRINT '========================================';

-- tblCustomers: Customer definitions
CREATE TABLE dbo.tblCustomers (
    CustomerCode       INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID         NVARCHAR(20) UNIQUE NOT NULL,
    CustomerNameAr     NVARCHAR(400) NOT NULL,
    CustomerNameEn     NVARCHAR(400) NULL,
    CustomerType       NVARCHAR(20) DEFAULT 'INDIVIDUAL',
    -- Types: INDIVIDUAL, COMPANY, GOVERNMENT, ESTABLISHMENT
    Gender             NVARCHAR(10) NULL,
    IDType             NVARCHAR(20) NULL,
    -- Types: NATIONAL_ID, PASSPORT, RESIDENCE_PERMIT, COMMERCIAL_REGISTER
    IDNumber           NVARCHAR(50) NULL,
    IDExpiryDate       DATE NULL,
    TaxNumber          NVARCHAR(50) NULL,
    VATNumber          NVARCHAR(50) NULL,
    CommercialRegister NVARCHAR(50) NULL,

-- Contact Info
Email NVARCHAR (100) NULL,
Phone NVARCHAR (50) NULL,
Mobile NVARCHAR (50) NULL,
Fax NVARCHAR (50) NULL,
Website NVARCHAR (200) NULL,

-- Address
Address NVARCHAR (500) NULL,
City NVARCHAR (100) NULL,
Region NVARCHAR (100) NULL,
Country NVARCHAR (100) DEFAULT 'السعودية',
PostalCode NVARCHAR (20) NULL,

-- Classification
PriceListCode INT NULL,
PaymentTermCode INT NULL,
CreditLimit DECIMAL(18, 4) DEFAULT 0,
CurrentCredit DECIMAL(18, 4) DEFAULT 0,
AvailableCredit AS CreditLimit - CurrentCredit,
PaymentDays INT DEFAULT 30,
TaxGroupCode INT NULL,

-- Sales Rep
SalesRepCode INT NULL, BranchCode INT NULL,

-- Financial
DefaultCurrency NVARCHAR (10) DEFAULT 'SAR',
AccountCode INT NULL,
ReceivableAccountCode INT NULL,

-- Status
IsActive BIT DEFAULT 1,
IsBlocked BIT DEFAULT 0,
BlockReason NVARCHAR (500) NULL,
CustomerSince DATE NULL,
LastSaleDate DATE NULL,
TotalSales DECIMAL(18, 4) DEFAULT 0,
TotalReturns DECIMAL(18, 4) DEFAULT 0,
TotalPayments DECIMAL(18, 4) DEFAULT 0,
Balance DECIMAL(18, 4) DEFAULT 0,

-- Preferences
InvoicePrintFormat NVARCHAR(50) DEFAULT 'A4',
    SendEmailInvoice   BIT DEFAULT 0,
    SendSMSInvoice     BIT DEFAULT 0,
    PreferWhatsApp     BIT DEFAULT 0,
    
    Notes              NVARCHAR(MAX) NULL,
    CreatedBy          INT NULL,
    CreatedAt          DATETIME DEFAULT GETDATE(),
    ModifiedBy         INT NULL,
    ModifiedAt         DATETIME NULL,
    CONSTRAINT FK_Customers_SalesRep FOREIGN KEY (SalesRepCode) REFERENCES dbo.tblUsers(UserCode),
    CONSTRAINT FK_Customers_Branch FOREIGN KEY (BranchCode) REFERENCES dbo.tblBranches(BranchCode)
);
GO

CREATE INDEX idx_Customers_ID ON dbo.tblCustomers (CustomerID);

CREATE INDEX idx_Customers_Type ON dbo.tblCustomers (CustomerType);

CREATE INDEX idx_Customers_TaxNumber ON dbo.tblCustomers (TaxNumber)
WHERE
    TaxNumber IS NOT NULL;

CREATE INDEX idx_Customers_Active ON dbo.tblCustomers (IsActive)
WHERE
    IsActive = 1;

CREATE INDEX idx_Customers_City ON dbo.tblCustomers (City)
WHERE
    City IS NOT NULL;
GO

-- tblCustomerContacts: Customer contact persons
CREATE TABLE dbo.tblCustomerContacts (
    ContactID INT IDENTITY (1, 1) PRIMARY KEY,
    CustomerCode INT NOT NULL,
    ContactName NVARCHAR (200) NOT NULL,
    ContactTitle NVARCHAR (100) NULL,
    Department NVARCHAR (100) NULL,
    Phone NVARCHAR (50) NULL,
    Mobile NVARCHAR (50) NULL,
    Email NVARCHAR (100) NULL,
    IsPrimary BIT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    Notes NVARCHAR (MAX) NULL,
    CreatedBy INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE (),
    ModifiedBy INT NULL,
    ModifiedAt DATETIME NULL,
    CONSTRAINT FK_CustomerContacts_Customer FOREIGN KEY (CustomerCode) REFERENCES dbo.tblCustomers (CustomerCode) ON DELETE CASCADE
);
GO

CREATE INDEX idx_CustomerContacts_Customer ON dbo.tblCustomerContacts (CustomerCode);
GO

-- tblSuppliers: Supplier definitions
CREATE TABLE dbo.tblSuppliers (
    SupplierCode       INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID         NVARCHAR(20) UNIQUE NOT NULL,
    SupplierNameAr     NVARCHAR(400) NOT NULL,
    SupplierNameEn    NVARCHAR(400) NULL,
    SupplierType      NVARCHAR(20) DEFAULT 'INDIVIDUAL',
    -- Types: INDIVIDUAL, COMPANY, MANUFACTURER, AGENT
    CategoryCode      INT NULL,

-- Registration
TaxNumber NVARCHAR (50) NULL,
VATNumber NVARCHAR (50) NULL,
CommercialRegister NVARCHAR (50) NULL,
MunicipalityLicense NVARCHAR (50) NULL,

-- Contact Info
Email NVARCHAR (100) NULL,
Phone NVARCHAR (50) NULL,
Mobile NVARCHAR (50) NULL,
Fax NVARCHAR (50) NULL,
Website NVARCHAR (200) NULL,

-- Address
Address NVARCHAR (500) NULL,
City NVARCHAR (100) NULL,
Region NVARCHAR (100) NULL,
Country NVARCHAR (100) DEFAULT 'السعودية',
PostalCode NVARCHAR (20) NULL,

-- Banking
BankName NVARCHAR (200) NULL,
BankAccountNo NVARCHAR (50) NULL,
IBAN NVARCHAR (50) NULL,
SwiftCode NVARCHAR (20) NULL,
AccountHolder NVARCHAR (200) NULL,

-- Classification
PaymentTermCode INT NULL,
CreditLimit DECIMAL(18, 4) DEFAULT 0,
CurrentCredit DECIMAL(18, 4) DEFAULT 0,
AvailableCredit AS CreditLimit - CurrentCredit,
PaymentDays INT DEFAULT 30,

-- Purchases
BranchCode INT NULL,
DefaultStoreCode INT NULL,
DefaultCurrency NVARCHAR (10) DEFAULT 'SAR',
AccountCode INT NULL,
PayableAccountCode INT NULL,

-- Status
IsActive          BIT DEFAULT 1,
    IsBlocked         BIT DEFAULT 0,
    BlockReason       NVARCHAR(500) NULL,
    SupplierSince     DATE NULL,
    LastPurchaseDate  DATE NULL,
    TotalPurchases    DECIMAL(18,4) DEFAULT 0,
    TotalReturns      DECIMAL(18,4) DEFAULT 0,
    TotalPayments     DECIMAL(18,4) DEFAULT 0,
    Balance           DECIMAL(18,4) DEFAULT 0,
    
    Notes             NVARCHAR(MAX) NULL,
    CreatedBy         INT NULL,
    CreatedAt         DATETIME DEFAULT GETDATE(),
    ModifiedBy        INT NULL,
    ModifiedAt        DATETIME NULL,
    CONSTRAINT FK_Suppliers_Category FOREIGN KEY (CategoryCode) REFERENCES dbo.tblCategories(CategoryCode),
    CONSTRAINT FK_Suppliers_Branch FOREIGN KEY (BranchCode) REFERENCES dbo.tblBranches(BranchCode)
);
GO

CREATE INDEX idx_Suppliers_ID ON dbo.tblSuppliers (SupplierID);

CREATE INDEX idx_Suppliers_Type ON dbo.tblSuppliers (SupplierType);

CREATE INDEX idx_Suppliers_TaxNumber ON dbo.tblSuppliers (TaxNumber)
WHERE
    TaxNumber IS NOT NULL;

CREATE INDEX idx_Suppliers_Active ON dbo.tblSuppliers (IsActive)
WHERE
    IsActive = 1;
GO

-- tblSupplierContacts: Supplier contact persons
CREATE TABLE dbo.tblSupplierContacts (
    ContactID INT IDENTITY (1, 1) PRIMARY KEY,
    SupplierCodeINT NOT NULL,
    ContactName NVARCHAR (200) NOT NULL,
    ContactTitle NVARCHAR (100) NULL,
    Department NVARCHAR (100) NULL,
    Phone NVARCHAR (50) NULL,
    Mobile NVARCHAR (50) NULL,
    Email NVARCHAR (100) NULL,
    IsPrimary BIT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    Notes NVARCHAR (MAX) NULL,
    CreatedBy INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE (),
    ModifiedBy INT NULL,
    ModifiedAt DATETIME NULL,
    CONSTRAINT FK_SupplierContacts_Supplier FOREIGN KEY (SupplierCode) REFERENCES dbo.tblSuppliers (SupplierCode) ON DELETE CASCADE
);
GO

CREATE INDEX idx_SupplierContacts_Supplier ON dbo.tblSupplierContacts (SupplierCode);
GO

-- tblOperationHeader: Sales/Purchase document headers
CREATE TABLE dbo.tblOperationHeader (
    OperationID        BIGINT IDENTITY(1,1) PRIMARY KEY,
    OperationNo       NVARCHAR(30) UNIQUE NOT NULL,
    OperationType     NVARCHAR(20) NOT NULL,
    -- Types: QUOTATION, SALES_ORDER, PURCHASE_ORDER, DELIVERY, INVOICE, RETURN
    -- SALE_INVOICE, PURCHASE_INVOICE, SALE_RETURN, PURCHASE_RETURN
    OperationStatus   NVARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    -- Status: DRAFT, CONFIRMED, APPROVED, IN_PROGRESS, COMPLETED, CANCELLED, CLOSED
    OperationDate     DATE NOT NULL,
    DueDate           DATE NULL,

-- Parties
CustomerCode INT NULL,
SupplierCode INT NULL,
ContactID INT NULL,

-- Branch & Store
BranchCode INT NOT NULL,
StoreCode INT NULL,
WarehouseCode INT NULL,

-- Financial
CurrencyCode NVARCHAR (10) NOT NULL DEFAULT 'SAR',
ExchangeRate DECIMAL(18, 6) DEFAULT 1,
SubTotal DECIMAL(18, 4) NOT NULL DEFAULT 0,
DiscountAmount DECIMAL(18, 4) DEFAULT 0,
DiscountPercent DECIMAL(5, 2) DEFAULT 0,
VatAmount DECIMAL(18, 4) DEFAULT 0,
VatPercent DECIMAL(5, 2) DEFAULT 15,
TotalAmount DECIMAL(18, 4) NOT NULL DEFAULT 0,
TotalAmountFC DECIMAL(18, 4) DEFAULT 0,
PaidAmount DECIMAL(18, 4) DEFAULT 0,
DueAmount DECIMAL(18, 4) DEFAULT 0,

-- Tax
IsTaxable BIT DEFAULT 1,
TaxNumber NVARCHAR (50) NULL,

-- Reference
ReferenceNo NVARCHAR (50) NULL,
ReferenceDate DATE NULL,
SourceType NVARCHAR (30) NULL,
SourceID BIGINT NULL,
RelatedOperationID BIGINT NULL,

-- Payment
PaymentMethodCode INT NULL,
PaymentTermCode INT NULL,
DueNetDays INT DEFAULT 0,

-- Delivery
ShippingMethod NVARCHAR (100) NULL,
ShipToAddress NVARCHAR (500) NULL,
ShipToCity NVARCHAR (100) NULL,
DeliveryDate DATE NULL,
DeliveryNotes NVARCHAR (MAX) NULL,

-- Shipping
ShipmentNo NVARCHAR (50) NULL,
TrackingNo NVARCHAR (100) NULL,
CarrierName NVARCHAR (200) NULL,
ShippingCost DECIMAL(18, 4) DEFAULT 0,
ShippingAccountCode INT NULL,

-- Project
ProjectCode INT NULL, CostCenterCode INT NULL,

-- Approval
ApprovedBy INT NULL,
ApprovedAt DATETIME NULL,
IsApproved BIT DEFAULT 0,
ApprovalNotes NVARCHAR (MAX) NULL,

-- Locking
IsLocked BIT DEFAULT 0,
LockedBy INT NULL,
LockedAt DATETIME NULL,

-- Print
PrintCount        INT DEFAULT 0,
    LastPrintAt       DATETIME NULL,
    
    Notes             NVARCHAR(MAX) NULL,
    UserCode          INT NOT NULL,
    CreatedBy         INT NULL,
    CreatedAt         DATETIME DEFAULT GETDATE(),
    ModifiedBy        INT NULL,
    ModifiedAt        DATETIME NULL,
    CONSTRAINT FK_OperationHeader_Customer FOREIGN KEY (CustomerCode) REFERENCES dbo.tblCustomers(CustomerCode),
    CONSTRAINT FK_OperationHeader_Supplier FOREIGN KEY (SupplierCode) REFERENCES dbo.tblSuppliers(SupplierCode),
    CONSTRAINT FK_OperationHeader_Branch FOREIGN KEY (BranchCode) REFERENCES dbo.tblBranches(BranchCode),
    CONSTRAINT FK_OperationHeader_Store FOREIGN KEY (StoreCode) REFERENCES dbo.tblStores(StoreCode),
    CONSTRAINT FK_OperationHeader_Currency FOREIGN KEY (CurrencyCode) REFERENCES dbo.tblCurrencies(CurrencyCode),
    CONSTRAINT FK_OperationHeader_User FOREIGN KEY (UserCode) REFERENCES dbo.tblUsers(UserCode)
);
GO

CREATE INDEX idx_OperationHeader_No ON dbo.tblOperationHeader (OperationNo);

CREATE INDEX idx_OperationHeader_Type ON dbo.tblOperationHeader (OperationType);

CREATE INDEX idx_OperationHeader_Status ON dbo.tblOperationHeader (OperationStatus);

CREATE INDEX idx_OperationHeader_Date ON dbo.tblOperationHeader (OperationDate);

CREATE INDEX idx_OperationHeader_Customer ON dbo.tblOperationHeader (CustomerCode)
WHERE
    CustomerCode IS NOT NULL;

CREATE INDEX idx_OperationHeader_Supplier ON dbo.tblOperationHeader (SupplierCode)
WHERE
    SupplierCode IS NOT NULL;

CREATE INDEX idx_OperationHeader_Branch ON dbo.tblOperationHeader (BranchCode);

CREATE INDEX idx_OperationHeader_Source ON dbo.tblOperationHeader (SourceType, SourceID)
WHERE
    SourceType IS NOT NULL;

CREATE INDEX idx_OperationHeader_Locked ON dbo.tblOperationHeader (IsLocked)
WHERE
    IsLocked = 1;
GO

-- tblOperationBody: Sales/Purchase document lines
CREATE TABLE dbo.tblOperationBody (
    OperationBodyID   BIGINT IDENTITY(1,1) PRIMARY KEY,
    OperationID       BIGINT NOT NULL,
    LineNo             INT NOT NULL,
    ProductCode        INT NULL,
    ItemDescription    NVARCHAR(500) NOT NULL,
    ItemDescriptionEn  NVARCHAR(500) NULL,

-- Quantity
Qty DECIMAL(18, 4) NOT NULL DEFAULT 0,
QtyDelivered DECIMAL(18, 4) DEFAULT 0,
QtyInvoiced DECIMAL(18, 4) DEFAULT 0,
QtyReturned DECIMAL(18, 4) DEFAULT 0,
UnitCode INT NOT NULL,

-- Pricing
UnitPrice DECIMAL(18, 4) NOT NULL DEFAULT 0,
UnitPriceFC DECIMAL(18, 4) DEFAULT 0,
DiscountPercent DECIMAL(5, 2) DEFAULT 0,
DiscountAmount DECIMAL(18, 4) DEFAULT 0,
NetPrice DECIMAL(18, 4) DEFAULT 0,
LineTotal DECIMAL(18, 4) NOT NULL DEFAULT 0,
LineTotalFC DECIMAL(18, 4) DEFAULT 0,

-- Tax
TaxPercent DECIMAL(5, 2) DEFAULT 0,
TaxAmount DECIMAL(18, 4) DEFAULT 0,
TaxAccountCode INT NULL,
IsTaxExempt BIT DEFAULT 0,

-- Batch & Serial
BatchID INT NULL,
SerialNumbers NVARCHAR (MAX) NULL,
-- Stored as comma-separated or JSON

-- Cost (for reference)
UnitCost DECIMAL(18, 6) DEFAULT 0,
LineCost DECIMAL(18, 4) DEFAULT 0,
ProfitMargin DECIMAL(5, 2) DEFAULT 0,

-- Delivery
QtyToDeliver DECIMAL(18, 4) DEFAULT 0,
DeliveredQty DECIMAL(18, 4) DEFAULT 0,
DeliveryDate DATE NULL,
DeliveryStatus NVARCHAR (20) DEFAULT 'PENDING',

-- Store
StoreCode INT NULL,

-- Warehouse
WarehouseCode INT NULL,
BinLocation NVARCHAR (100) NULL,

-- Project & Cost Center
ProjectCode INT NULL, CostCenterCode INT NULL,

-- Reference
ReferenceNo NVARCHAR (50) NULL,
SourceLineID BIGINT NULL,

-- Notes
Notes              NVARCHAR(MAX) NULL,
    CreatedBy          INT NULL,
    CreatedAt          DATETIME DEFAULT GETDATE(),
    ModifiedBy         INT NULL,
    ModifiedAt         DATETIME NULL,
    CONSTRAINT FK_OperationBody_Header FOREIGN KEY (OperationID) REFERENCES dbo.tblOperationHeader(OperationID) ON DELETE CASCADE,
    CONSTRAINT FK_OperationBody_Product FOREIGN KEY (ProductCode) REFERENCES dbo.tblProducts(ProductCode),
    CONSTRAINT FK_OperationBody_Unit FOREIGN KEY (UnitCode) REFERENCES dbo.tblUnits(UnitCode),
    CONSTRAINT FK_OperationBody_Store FOREIGN KEY (StoreCode) REFERENCES dbo.tblStores(StoreCode)
);
GO

CREATE INDEX idx_OperationBody_Operation ON dbo.tblOperationBody (OperationID);

CREATE INDEX idx_OperationBody_Product ON dbo.tblOperationBody (ProductCode)
WHERE
    ProductCode IS NOT NULL;

CREATE INDEX idx_OperationBody_Store ON dbo.tblOperationBody (StoreCode)
WHERE
    StoreCode IS NOT NULL;
GO

-- tblOperationTaxes: Tax breakdown per operation
CREATE TABLE dbo.tblOperationTaxes (
    TaxID INT IDENTITY (1, 1) PRIMARY KEY,
    OperationID BIGINT NOT NULL,
    TaxType NVARCHAR (20) NOT NULL,
    -- Types: VAT, VAT_ZERO, VAT_EXEMPT, EXCISE, WITHHOLDING
    TaxCode NVARCHAR (30) NULL,
    TaxNameAr NVARCHAR (200) NOT NULL,
    TaxNameEn NVARCHAR (200) NULL,
    TaxRate DECIMAL(5, 2) NOT NULL,
    TaxableAmount DECIMAL(18, 4) NOT NULL DEFAULT 0,
    TaxAmount DECIMAL(18, 4) NOT NULL DEFAULT 0,
    AccountCode INT NULL,
    Notes NVARCHAR (MAX) NULL,
    CreatedBy INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE (),
    CONSTRAINT FK_OperationTaxes_Header FOREIGN KEY (OperationID) REFERENCES dbo.tblOperationHeader (OperationID) ON DELETE CASCADE
);
GO

CREATE INDEX idx_OperationTaxes_Operation ON dbo.tblOperationTaxes (OperationID);
GO

-- tblOperationPayments: Payment tracking
CREATE TABLE dcto.tblOperationPayments (
    PaymentID INT IDENTITY (1, 1) PRIMARY KEY,
    OperationID BIGINT NOT NULL,
    PaymentNo NVARCHAR (30) UNIQUE NOT NULL,
    PaymentDate DATE NOT NULL,
    PaymentMethodCode INT NOT NULL,
    Amount DECIMAL(18, 4) NOT NULL,
    AmountFC DECIMAL(18, 4) DEFAULT 0,
    CurrencyCode NVARCHAR (10) DEFAULT 'SAR',
    ExchangeRate DECIMAL(18, 6) DEFAULT 1,
    ReferenceNo NVARCHAR (50) NULL,
    ReferenceDate DATE NULL,
    BankCode INT NULL,
    CheckNo NVARCHAR (50) NULL,
    CheckDate DATE NULL,
    CheckDueDate DATE NULL,
    AccountNo NVARCHAR (50) NULL,
    CardNo NVARCHAR (50) NULL,
    AuthorizationCode NVARCHAR (50) NULL,
    Notes NVARCHAR (MAX) NULL,
    IsReversed BIT DEFAULT 0,
    ReversedBy INT NULL,
    ReversedAt DATETIME NULL,
    ReversalReason NVARCHAR (MAX) NULL,
    UserCode INT NOT NULL,
    CreatedBy INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE (),
    CONSTRAINT FK_OperationPayments_Operation FOREIGN KEY (OperationID) REFERENCES dbo.tblOperationHeader (OperationID) ON DELETE CASCADE,
    CONSTRAINT FK_OperationPayments_Method FOREIGN KEY (PaymentMethodCode) REFERENCES dbo.tblPaymentMethods (PaymentMethodCode)
);
GO

CREATE INDEX idx_OperationPayments_Operation ON dbo.tblOperationPayments (OperationID);

CREATE INDEX idx_OperationPayments_No ON dbo.tblOperationPayments (PaymentNo);

CREATE INDEX idx_OperationPayments_Date ON dbo.tblOperationPayments (PaymentDate);
GO

-- tblPriceLists: Price list definitions
CREATE TABLE dbo.tblPriceLists (
    PriceListCode INT IDENTITY (1, 1) PRIMARY KEY,
    PriceListID NVARCHAR (20) UNIQUE NOT NULL,
    PriceListNameAr NVARCHAR (200) NOT NULL,
    PriceListNameEn NVARCHAR (200) NULL,
    PriceListType NVARCHAR (20) DEFAULT 'SALE',
    -- Types: SALE, PURCHASE, COST
    BasePriceListCode INT NULL,
    RoundingRule DECIMAL(18, 4) DEFAULT 0.01,
    -- Round to: 0.01, 0.05, 0.10, 1.00, etc.
    RoundingMethod NVARCHAR (20) DEFAULT 'ROUND',
    -- Methods: ROUND, CEILING, FLOOR
    CurrencyCode NVARCHAR (10) DEFAULT 'SAR',
    IsActive BIT DEFAULT 1,
    IsDefault BIT DEFAULT 0,
    ValidFrom DATE NULL,
    ValidTo DATE NULL,
    Description NVARCHAR (MAX) NULL,
    Notes NVARCHAR (MAX) NULL,
    CreatedBy INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE (),
    ModifiedBy INT NULL,
    ModifiedAt DATETIME NULL,
    CONSTRAINT FK_PriceLists_Base FOREIGN KEY (BasePriceListCode) REFERENCES dbo.tblPriceLists (PriceListCode)
);
GO

CREATE INDEX idx_PriceLists_ID ON dbo.tblPriceLists (PriceListID);

CREATE INDEX idx_PriceLists_Type ON dbo.tblPriceLists (PriceListType);

CREATE INDEX idx_PriceLists_Active ON dbo.tblPriceLists (IsActive)
WHERE
    IsActive = 1;
GO

-- tblPaymentTerms: Payment term definitions
CREATE TABLE dbo.tblPaymentTerms (
    TermCode INT IDENTITY (1, 1) PRIMARY KEY,
    TermID NVARCHAR (20) UNIQUE NOT NULL,
    TermNameAr NVARCHAR (200) NOT NULL,
    TermNameEn NVARCHAR (200) NULL,
    TermType NVARCHAR (20) DEFAULT 'DUE_DAYS',
    -- Types: DUE_DAYS, DUE_DATE, INSTALLMENTS, ADVANCE, CASH
    NetDays INT DEFAULT 0,
    DiscountPercent DECIMAL(5, 2) DEFAULT 0,
    DiscountDays INT DEFAULT 0,
    InstallmentCount INT DEFAULT 1,
    FirstPaymentPercent DECIMAL(5, 2) DEFAULT 0,
    IsActive BIT DEFAULT 1,
    IsDefault BIT DEFAULT 0,
    Notes NVARCHAR (MAX) NULL,
    CreatedBy INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE (),
    ModifiedBy INT NULL,
    ModifiedAt DATETIME NULL
);
GO

CREATE INDEX idx_PaymentTerms_ID ON dbo.tblPaymentTerms (TermID);

CREATE INDEX idx_PaymentTerms_Active ON dbo.tblPaymentTerms (IsActive)
WHERE
    IsActive = 1;
GO

PRINT 'Transaction Domain Tables created successfully.';
GO

-- ============================================================
-- SECTION 8: ADDITIONAL INDEXES
-- ============================================================
PRINT '';

PRINT '========================================';

PRINT 'SECTION 8: Creating Additional Indexes...';

PRINT '========================================';

-- Unique constraint for accounts by code
CREATE UNIQUE INDEX UIX_Accounts_AccountCode ON dbo.tblAccounts (AccountCode)
WHERE
    AccountCode IS NOT NULL;

CREATE UNIQUE INDEX UIX_Accounts_AccountID ON dbo.tblAccounts (AccountID)
WHERE
    AccountID IS NOT NULL;

-- Unique constraint for branches
CREATE UNIQUE INDEX UIX_Branches_BranchCode ON dbo.tblBranches (BranchCode)
WHERE
    BranchCode IS NOT NULL;

CREATE UNIQUE INDEX UIX_Branches_BranchID ON dbo.tblBranches (BranchID)
WHERE
    BranchID IS NOT NULL;

-- Product search indexes
CREATE INDEX idx_Products_SearchAr ON dbo.tblProducts (ProductNameAr) INCLUDE (
    ProductCode,
    ProductID,
    StandardCost,
    LastPurchasePrice,
    LastSalePrice
)
WHERE
    IsActive = 1;

CREATE INDEX idx_Products_SearchEn ON dbo.tblProducts (ProductNameEn) INCLUDE (
    ProductCode,
    ProductID,
    StandardCost,
    LastPurchasePrice,
    LastSalePrice
)
WHERE
    IsActive = 1
    AND ProductNameEn IS NOT NULL;

-- Customer balance tracking
CREATE INDEX idx_Customers_Balance ON dbo.tblCustomers (Balance)
WHERE
    IsActive = 1
    AND Balance <> 0;

-- Supplier balance tracking
CREATE INDEX idx_Suppliers_Balance ON dbo.tblSuppliers (Balance)
WHERE
    IsActive = 1
    AND Balance <> 0;

-- Store products quick lookup
CREATE INDEX idx_StoreProducts_Stock ON dbo.tblStoreProducts (
    StoreCode,
    ProductCode,
    QtyOnHand
) INCLUDE (AvgCost, LastCost)
WHERE
    QtyOnHand > 0;

-- Product movement summary for reporting
CREATE INDEX idx_ProductMovement_YearMonth ON dbo.tblProductMovement (ProductCode, MovementDate) INCLUDE (Qty, TotalPrice)
WHERE
    MovementDate >= DATEADD (YEAR, -1, GETDATE ());

-- Operation by status for workflow
CREATE INDEX idx_OperationHeader_Workflow ON dbo.tblOperationHeader (
    OperationType,
    OperationStatus,
    OperationDate
) INCLUDE (
    OperationID,
    TotalAmount,
    CustomerCode,
    SupplierCode
)
WHERE
    OperationStatus IN (
        'DRAFT',
        'CONFIRMED',
        'IN_PROGRESS'
    );

-- Bond search by status
CREATE INDEX idx_BondHeader_Pending ON dbo.tblBondHeader (BondStatus, BondDate) INCLUDE (BondID, BondNo, TotalAmount)
WHERE
    BondStatus IN ('PENDING', 'POSTED');

-- Journal unposted entries
CREATE INDEX idx_JournalHeader_Unposted ON dbo.tblJournalHeader (JournalDate) INCLUDE (
    JournalID,
    JournalNo,
    TotalDebit,
    TotalCredit
)
WHERE
    IsPosted = 0;

-- Audit log performance
CREATE INDEX idx_AuditLogs_UserDate ON dbo.tblAuditLogs (UserCode, LogDate) INCLUDE (
    AuditID,
    ActionType,
    TableName,
    RecordID
);

CREATE INDEX idx_AuditLogs_TableRecord ON dbo.tblAuditLogs (TableName, RecordID, LogDate)
WHERE
    RecordID IS NOT NULL;

-- Session cleanup
CREATE INDEX idx_Sessions_Expiry ON dbo.tblSessions (ExpiresAt) INCLUDE (SessionID, UserCode)
WHERE
    IsActive = 1
    AND ExpiresAt < GETDATE ();

PRINT 'Additional indexes created successfully.';
GO

-- ============================================================
-- SECTION 9: FUNCTIONS (الدوال)
-- ============================================================
PRINT '';

PRINT '========================================';

PRINT 'SECTION 9: Creating Database Functions...';

PRINT '========================================';

-- fn_GetAccountFullPath: Returns the full hierarchical path of an account
CREATE OR ALTER FUNCTION dbo.fn_GetAccountFullPath
(
    @AccountCode INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @Path NVARCHAR(MAX) = '';
    DECLARE @CurrentCode INT = @AccountCode;
    DECLARE @AccountName NVARCHAR(400);
    
    WHILE @CurrentCode IS NOT NULL
    BEGIN
        SELECT @AccountName = AccountNameAr, 
               @CurrentCode = ParentAccountCode
        FROM dbo.tblAccounts 
        WHERE AccountCode = @CurrentCode;
        
        IF @Path = ''
            SET @Path = @AccountName;
        ELSE
            SET @Path = @AccountName + ' > ' + @Path;
    END
    
    RETURN @Path;
END
GO

-- fn_GetCategoryFullPath: Returns the full hierarchical path of a category
CREATE OR ALTER FUNCTION dbo.fn_GetCategoryFullPath
(
    @CategoryCode INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @Path NVARCHAR(MAX) = '';
    DECLARE @CurrentCode INT = @CategoryCode;
    DECLARE @CategoryName NVARCHAR(200);
    
    WHILE @CurrentCode IS NOT NULL
    BEGIN
        SELECT @CategoryName = CategoryNameAr, 
               @CurrentCode = ParentCategoryCode
        FROM dbo.tblCategories 
        WHERE CategoryCode = @CurrentCode;
        
        IF @Path = ''
            SET @Path = @CategoryName;
        ELSE
            SET @Path = @CategoryName + ' > ' + @Path;
    END
    
    RETURN @Path;
END
GO

-- fn_GetProductStock: Returns current stock for a product
CREATE OR ALTER FUNCTION dbo.fn_GetProductStock
(
    @ProductCode INT,
    @StoreCode INT = NULL
)
RETURNS DECIMAL(18,4)
AS
BEGIN
    DECLARE @Stock DECIMAL(18,4) = 0;
    
    IF @StoreCode IS NULL
    BEGIN
        SELECT @Stock = ISNULL(SUM(QtyOnHand), 0)
        FROM dbo.tblStoreProducts
        WHERE ProductCode = @ProductCode AND IsActive = 1;
    END
    ELSE
    BEGIN
        SELECT @Stock = ISNULL(SUM(QtyOnHand), 0)
        FROM dbo.tblStoreProducts
        WHERE ProductCode = @ProductCode 
          AND StoreCode = @StoreCode 
          AND IsActive = 1;
    END
    
    RETURN @Stock;
END
GO

-- fn_GetAccountBalance: Returns current balance for an account
CREATE OR ALTER FUNCTION dbo.fn_GetAccountBalance
(
    @AccountCode INT,
    @AsOfDate DATETIME = NULL
)
RETURNS DECIMAL(18,4)
AS
BEGIN
    DECLARE @Debit DECIMAL(18,4) = 0;
    DECLARE @Credit DECIMAL(18,4) = 0;
    
    IF @AsOfDate IS NULL
        SET @AsOfDate = GETDATE();
    
    -- Sum from Journal
    SELECT @Debit = ISNULL(SUM(DebitAmount), 0),
           @Credit = ISNULL(SUM(CreditAmount), 0)
    FROM dbo.tblJournalBody jb
    INNER JOIN dbo.tblJournalHeader jh ON jb.JournalHeaderID = jh.JournalHeaderID
    WHERE jb.AccountCode = @AccountCode
      AND jh.JournalDate <= @AsOfDate
      AND jh.IsPosted = 1;
    
    -- Sum from Bond
    SELECT @Debit = @Debit + ISNULL(SUM(DebitAmount), 0),
           @Credit = @Credit + ISNULL(SUM(CreditAmount), 0)
    FROM dbo.tblBondBody bb
    INNER JOIN dbo.tblBondHeader bh ON bb.BondHeaderID = bh.BondHeaderID
    WHERE bb.AccountCode = @AccountCode
      AND bh.BondDate <= @AsOfDate
      AND bh.BondStatus = 'POSTED';
    
    RETURN @Debit - @Credit;
END
GO

-- fn_GetCustomerBalance: Returns outstanding balance for a customer
CREATE OR ALTER FUNCTION dbo.fn_GetCustomerBalance
(
    @CustomerCode INT
)
RETURNS DECIMAL(18,4)
AS
BEGIN
    DECLARE @Balance DECIMAL(18,4) = 0;
    
    -- Get from customers table for quick reference
    SELECT @Balance = ISNULL(Balance, 0)
    FROM dbo.tblCustomers
    WHERE CustomerCode = @CustomerCode;
    
    RETURN @Balance;
END
GO

-- fn_GetSupplierBalance: Returns outstanding balance for a supplier
CREATE OR ALTER FUNCTION dbo.fn_GetSupplierBalance
(
    @SupplierCode INT
)
RETURNS DECIMAL(18,4)
AS
BEGIN
    DECLARE @Balance DECIMAL(18,4) = 0;
    
    SELECT @Balance = ISNULL(Balance, 0)
    FROM dbo.tblSuppliers
    WHERE SupplierCode = @SupplierCode;
    
    RETURN @Balance;
END
GO

-- fn_FormatNumber: Formats number with specified decimals
CREATE OR ALTER FUNCTION dbo.fn_FormatNumber
(
    @Value DECIMAL(18,4),
    @DecimalPlaces INT= 2
)
RETURNS NVARCHAR(50)
AS
BEGIN
    RETURN CAST(ROUND(@Value, @DecimalPlaces) AS NVARCHAR(50));
END
GO

-- fn_GetNextSequence: Gets next sequence number with locking
CREATE OR ALTER FUNCTION dbo.fn_GetNextSequence
(
    @SequenceName NVARCHAR(100)
)
RETURNS BIGINT
AS
BEGIN
    DECLARE @NextValue BIGINT;
    
    -- This is a placeholder; actual implementation would use a sequence table
    -- For now, return NEWID-based unique value
    RETURN CAST(CHECKSUM(NEWID()) AS BIGINT);
END
GO

-- fn_IsUserHasPrivilege: Checks if user has specific privilege on window
CREATE OR ALTER FUNCTION dbo.fn_IsUserHasPrivilege
(
    @UserCode INT,
    @WindowCode NVARCHAR(50),
    @PrivilegeType NVARCHAR(20)
)
RETURNS BIT
AS
BEGIN
    DECLARE @HasPrivilege BIT = 0;
    
    -- Admin users have all privileges
    IF EXISTS (SELECT 1 FROM dbo.tblUsers WHERE UserCode = @UserCode AND IsAdmin = 1)
        RETURN 1;
    
    -- Check direct privilege
    IF EXISTS (
        SELECT 1 
        FROM dbo.tblPrivileges p
        INNER JOIN dbo.tblWindows w ON p.WindowID = w.WindowID
        INNER JOIN dbo.tblUserRoleAssignments ura ON p.RoleID = ura.RoleID
        WHERE ura.UserCode = @UserCode
          AND w.WindowCode = @WindowCode
          AND CASE @PrivilegeType
                WHEN 'CanDisplay' THEN p.CanDisplay
                WHEN 'CanAdd' THEN p.CanAdd
                WHEN 'CanEdit' THEN p.CanEdit
                WHEN 'CanDelete' THEN p.CanDelete
                WHEN 'CanPrint' THEN p.CanPrint
                WHEN 'CanExport' THEN p.CanExport
                WHEN 'CanApprove' THEN p.CanApprove
                WHEN 'CanPost' THEN p.CanPost
              END = 1
    )
        SET @HasPrivilege = 1;
    
    RETURN @HasPrivilege;
END
GO

-- fn_GetExchangeRate: Gets currency exchange rate
CREATE OR ALTER FUNCTION dbo.fn_GetExchangeRate
(
    @CurrencyCode NVARCHAR(10),
    @RateDate DATE = NULL
)
RETURNS DECIMAL(18,6)
AS
BEGIN
    DECLARE @Rate DECIMAL(18,6) = 1;
    
    IF @RateDate IS NULL
        SET @RateDate = CAST(GETDATE() AS DATE);
    
    SELECT @Rate = ISNULL(SellRate, 1)
    FROM dbo.tblCurrencies
    WHERE CurrencyCode = @CurrencyCode;
    
    RETURN @Rate;
END
GO

-- fn_CalculateVat: Calculates VAT amount
CREATE OR ALTER FUNCTION dbo.fn_CalculateVat
(
    @Amount DECIMAL(18,4),
    @VatPercent DECIMAL(5,2) = 15
)
RETURNS DECIMAL(18,4)
AS
BEGIN
    RETURN ROUND(@Amount * @VatPercent / 100, 4);
END
GO

-- fn_ConvertToBaseUnit: Converts quantity to base unit
CREATE OR ALTER FUNCTION dbo.fn_ConvertToBaseUnit
(
    @Qty DECIMAL(18,4),
    @FromUnitCode INT
)
RETURNS DECIMAL(18,4)
AS
BEGIN
    DECLARE @Factor DECIMAL(18,6) = 1;
    DECLARE @BaseUnitCode INT;
    
    -- Get conversion factor
    SELECT @Factor = ISNULL(ConversionFactor, 1),
           @BaseUnitCode = BaseUnitCode
    FROM dbo.tblUnits
    WHERE UnitCode = @FromUnitCode;
    
    -- If this is not a base unit, multiply by factor
    IF @BaseUnitCode IS NOT NULL
        SET @Qty = @Qty * @Factor;
    
    RETURN @Qty;
END
GO

PRINT 'Database Functions created successfully.';
GO

-- ============================================================
-- SECTION 10: VIEWS (طرق العرض)
-- ============================================================
PRINT '';

PRINT '========================================';

PRINT 'SECTION 10: Creating Database Views...';

PRINT '========================================';

-- vw_ActiveUsers: List of active system users
CREATE
OR
ALTER VIEW dbo.vw_ActiveUsers AS
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
FROM dbo.tblUsers u
    LEFT JOIN dbo.tblBranches b ON u.BranchCode = b.BranchCode
WHERE
    u.IsActive = 1;
GO

-- vw_AccountHierarchy: Chart of accounts with hierarchy
CREATE
OR
ALTER VIEW dbo.vw_AccountHierarchy AS
SELECT
    a.AccountCode,
    a.AccountID,
    a.AccountNameAr,
    a.AccountNameEn,
    a.AccountType,
    a.ParentAccountCode,
    p.AccountNameAr AS ParentAccountName,
    a.AccountLevel,
    dbo.fn_GetAccountFullPath (a.AccountCode) AS FullPath,
    a.IsActive,
    a.IsMainAccount,
    a.IsPostable,
    a.AccountNature,
    CASE
        WHEN a.AccountNature = 'Debit' THEN dbo.fn_GetAccountBalance (a.AccountCode)
        ELSE - dbo.fn_GetAccountBalance (a.AccountCode)
    END AS Balance
FROM dbo.tblAccounts a
    LEFT JOIN dbo.tblAccounts p ON a.ParentAccountCode = p.AccountCode;
GO

-- vw_ProductStockSummary: Current stock levels across all stores
CREATE
OR
ALTER VIEW dbo.vw_ProductStockSummary AS
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
    ISNULL(sp.QtyOnHand, 0) AS TotalQtyOnHand,
    ISNULL(sp.QtyReserved, 0) AS TotalQtyReserved,
    ISNULL(sp.QtyOnHand, 0) - ISNULL(sp.QtyReserved, 0) AS QtyAvailable,
    ISNULL(sp.AvgCost, 0) AS AvgCost,
    p.MinStockLevel,
    p.MaxStockLevel,
    CASE
        WHEN ISNULL(sp.QtyOnHand, 0) <= p.MinStockLevel THEN 'LOW_STOCK'
        WHEN ISNULL(sp.QtyOnHand, 0) >= p.MaxStockLevel THEN 'OVER_STOCK'
        ELSE 'NORMAL'
    END AS StockStatus
FROM dbo.tblProducts p
    LEFT JOIN dbo.tblCategories c ON p.CategoryCode = c.CategoryCode
    LEFT JOIN dbo.tblUnits u ON p.DefaultUnitCode = u.UnitCode
    LEFT JOIN (
        SELECT
            ProductCode, SUM(QtyOnHand) AS QtyOnHand, SUM(QtyReserved) AS QtyReserved, AVG(AvgCost) AS AvgCost
        FROM dbo.tblStoreProducts
        WHERE
            IsActive = 1
        GROUP BY
            ProductCode
    ) sp ON p.ProductCode = sp.ProductCode
WHERE
    p.IsActive = 1
    AND p.IsInventoryItem = 1;
GO

-- vw_StoreStockDetails: Stock by store and product
CREATE
OR
ALTER VIEW dbo.vw_StoreStockDetails AS
SELECT
    st.StoreCode,
    st.StoreID,
    st.StoreNameAr,
    p.ProductCode,
    p.ProductID,
    p.ProductNameAr,
    sp.BatchID,
    b.BatchNo,
    b.ExpiryDate,
    sp.QtyOnHand,
    sp.QtyReserved,
    sp.QtyAvailable,
    sp.AvgCost,
    sp.LastCost,
    sp.LocationInStore,
    CASE
        WHEN sp.QtyOnHand <= p.MinStockLevel THEN 'LOW_STOCK'
        ELSE 'OK'
    END AS StockStatus,
    DATEDIFF(
        DAY,
        CAST(GETDATE () AS DATE),
        b.ExpiryDate
    ) AS DaysToExpiry
FROM dbo.tblStoreProducts sp
    INNER JOIN dbo.tblStores st ON sp.StoreCode = st.StoreCode
    INNER JOIN dbo.tblProducts p ON sp.ProductCode = p.ProductCode
    LEFT JOIN dbo.tblProductBatches b ON sp.BatchID = b.BatchID
WHERE
    sp.IsActive = 1;
GO

-- vw_CustomerList: Customer overview with balances
CREATE
OR
ALTER VIEW dbo.vw_CustomerList AS
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
FROM dbo.tblCustomers c
    LEFT JOIN dbo.tblBranches b ON c.BranchCode = b.BranchCode;
GO

-- vw_SupplierList: Supplier overview with balances
CREATE
OR
ALTER VIEW dbo.vw_SupplierList AS
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
FROM dbo.tblSuppliers s
    LEFT JOIN dbo.tblBranches b ON s.BranchCode = b.BranchCode;
GO

-- vw_SalesSummary: Sales operations summary
CREATE
OR
ALTER VIEW dbo.vw_SalesSummary AS
SELECT
    oh.OperationID,
    oh.OperationNo,
    oh.OperationType,
    oh.OperationStatus,
    oh.OperationDate,
    oh.DueDate,
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
    oh.VatAmount,
    oh.TotalAmount,
    oh.PaidAmount,
    oh.DueAmount,
    oh.UserCode,
    u.UserNameAr AS CreatedByName,
    oh.CreatedAt,
    oh.ApprovedBy,
    oh.IsApproved,
    DATEDIFF(
        DAY,
        oh.OperationDate,
        GETDATE ()
    ) AS DaysSinceCreated,
    DATEDIFF(DAY, oh.DueDate, GETDATE ()) AS DaysPastDue
FROM
    dbo.tblOperationHeader oh
    LEFT JOIN dbo.tblCustomers c ON oh.CustomerCode = c.CustomerCode
    LEFT JOIN dbo.tblBranches b ON oh.BranchCode = b.BranchCode
    LEFT JOIN dbo.tblStores st ON oh.StoreCode = st.StoreCode
    LEFT JOIN dbo.tblUsers u ON oh.UserCode = u.UserCode
WHERE
    oh.OperationType IN (
        'SALE_INVOICE',
        'SALES_ORDER',
        'DELIVERY',
        'SALE_RETURN'
    );
GO

-- vw_PurchaseSummary: Purchase operations summary
CREATE
OR
ALTER VIEW dbo.vw_PurchaseSummary AS
SELECT
    oh.OperationID,
    oh.OperationNo,
    oh.OperationType,
    oh.OperationStatus,
    oh.OperationDate,
    oh.DueDate,
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
    oh.VatAmount,
    oh.TotalAmount,
    oh.PaidAmount,
    oh.DueAmount,
    oh.UserCode,
    u.UserNameAr AS CreatedByName,
    oh.CreatedAt,
    DATEDIFF(
        DAY,
        oh.OperationDate,
        GETDATE ()
    ) AS DaysSinceCreated,
    DATEDIFF(DAY, oh.DueDate, GETDATE ()) AS DaysPastDue
FROM
    dbo.tblOperationHeader oh
    LEFT JOIN dbo.tblSuppliers s ON oh.SupplierCode = s.SupplierCode
    LEFT JOIN dbo.tblBranches b ON oh.BranchCode = b.BranchCode
    LEFT JOIN dbo.tblStores st ON oh.StoreCode = st.StoreCode
    LEFT JOIN dbo.tblUsers u ON oh.UserCode = u.UserCode
WHERE
    oh.OperationType IN (
        'PURCHASE_INVOICE',
        'PURCHASE_ORDER',
        'PURCHASE_RETURN'
    );
GO

-- vw_JournalEntries: Journal entries with account details
CREATE
OR
ALTER VIEW dbo.vw_JournalEntries AS
SELECT
    jh.JournalHeaderID,
    jh.JournalNo,
    jh.JournalType,
    jh.JournalStatus,
    jh.JournalDate,
    jh.Description AS HeaderDescription,
    jh.BranchCode,
    b.BranchNameAr AS BranchName,
    jh.CurrencyCode,
    jh.TotalDebit,
    jh.TotalCredit,
    jh.IsPosted,
    jh.SourceType,
    jh.SourceID,
    jb.JournalBodyID,
    jb.LineNo,
    jb.AccountCode,
    a.AccountID,
    a.AccountNameAr AS AccountName,
    a.AccountType AS AccountType,
    jb.Description AS LineDescription,
    jb.DebitAmount,
    jb.CreditAmount,
    jb.CostCenterCode,
    cc.CostCenterNameAr AS CostCenterName,
    jb.ProjectCode,
    jb.ReferenceNo,
    jb.Notes,
    jh.UserCode,
    u.UserNameAr AS CreatedByName,
    jh.CreatedAt
FROM
    dbo.tblJournalHeader jh
    INNER JOIN dbo.tblJournalBody jb ON jh.JournalHeaderID = jb.JournalHeaderID
    LEFT JOIN dbo.tblBranches b ON jh.BranchCode = b.BranchCode
    LEFT JOIN dbo.tblAccounts a ON jb.AccountCode = a.AccountCode
    LEFT JOIN dbo.tblCostCenters cc ON jb.CostCenterCode = cc.CostCenterCode
    LEFT JOIN dbo.tblUsers u ON jh.UserCode = u.UserCode;
GO

-- vw_BondEntries: Voucher entries with account details
CREATE
OR
ALTER VIEW dbo.vw_BondEntries AS
SELECT
    bh.BondHeaderID,
    bh.BondNo,
    bh.BondType,
    bh.BondStatus,
    bh.BondDate,
    bh.Description AS HeaderDescription,
    bh.BranchCode,
    b.BranchNameAr AS BranchName,
    bh.CurrencyCode,
    bh.TotalAmount,
    bh.IsPosted,
    bh.SourceType,
    bh.SourceID,
    bb.BondBodyID,
    bb.LineNo,
    bb.AccountCode,
    a.AccountID,
    a.AccountNameAr AS AccountName,
    a.AccountType AS AccountType,
    bb.Description AS LineDescription,
    bb.DebitAmount,
    bb.CreditAmount,
    bh.PaymentMethodCode,
    pm.MethodNameAr AS PaymentMethodName,
    bh.FundCode,
    f.FundNameAr AS FundName,
    bh.Notes,
    bh.UserCode,
    u.UserNameAr AS CreatedByName,
    bh.CreatedAt
FROM
    dbo.tblBondHeader bh
    INNER JOIN dbo.tblBondBody bb ON bh.BondHeaderID = bb.BondHeaderID LEFTJOIN dbo.tblBranches b ON bh.BranchCode = b.BranchCode
    LEFT JOIN dbo.tblAccounts a ON bb.AccountCode = a.AccountCode
    LEFT JOIN dbo.tblPaymentMethods pm ON bh.PaymentMethodCode = pm.PaymentMethodCode
    LEFT JOIN dbo.tblFunds f ON bh.FundCode = f.FundCode
    LEFT JOIN dbo.tblUsers u ON bh.UserCode = u.UserCode;
GO

-- vw_AuditLogRecent: Recent audit entries
CREATE
OR
ALTER VIEW dbo.vw_AuditLogRecent AS
SELECT
    TOP 1000 al.AuditID,
    al.LogDate,
    al.ActionType,
    al.TableName,
    al.RecordID,
    al.OldValues,
    al.NewValues,
    al.UserCode,
    u.UserNameAr AS UserName,
    al.ComputerName,
    al.IPAddress,
    al.AdditionalInfo
FROM dbo.tblAuditLogs al
    LEFT JOIN dbo.tblUsers u ON al.UserCode = u.UserCode
ORDER BY al.LogDate DESC;
GO

-- vw_ProductMovementSummary: Stock movement summary
CREATE
OR
ALTER VIEW dbo.vw_ProductMovementSummary AS
SELECT
    pm.MovementID,
    pm.MovementNo,
    pm.MovementType,
    pm.MovementDate,
    p.ProductID,
    p.ProductNameAr,
    st.StoreNameAr AS StoreName,
    pm.Qty,
    pm.UnitCode,
    u.UnitNameAr AS UnitName,
    pm.UnitPrice,
    pm.TotalPrice,
    pm.SourceType,
    pm.SourceNo,
    pm.ReferenceNo,
    pm.UserCode,
    us.UserNameAr AS UserName,
    CASE
        WHEN pm.Qty > 0 THEN 'IN'
        ELSE 'OUT'
    END AS Direction
FROM
    dbo.tblProductMovement pm
    INNER JOIN dbo.tblProducts p ON pm.ProductCode = p.ProductCode
    INNER JOIN dbo.tblStores st ON pm.StoreCode = st.StoreCode
    INNER JOIN dbo.tblUnits u ON pm.UnitCode = u.UnitCode
    LEFT JOIN dbo.tblUsers us ON pm.UserCode = us.UserCode;
GO

-- vw_ExchangeRates: Current currency exchange rates
CREATE
OR
ALTER VIEW dbo.vw_ExchangeRates AS
SELECT
    CurrencyCode,
    CurrencyNameAr,
    CurrencyNameEn,
    CurrencySymbol,
    ISNULL(BuyRate, 1) AS BuyRate,
    ISNULL(SellRate, 1) AS SellRate,
    ISNULL((BuyRate + SellRate) / 2, 1) AS MidRate,
    RateDate,
    IsBaseCurrency,
    DecimalPlaces,
    IsActive
FROM dbo.tblCurrencies
WHERE
    IsActive = 1;
GO

-- vw_PendingOperations: Operations awaiting approval or posting
CREATE
OR
ALTER VIEW dbo.vw_PendingOperations AS
SELECT
    'SALE_INVOICE' AS OperationCategory,
    OperationID,
    OperationNo,
    OperationType,
    OperationStatus,
    OperationDate,
    CustomerCode,
    c.CustomerNameAr AS PartyName,
    TotalAmount,
    UserCode,
    u.UserNameAr AS CreatedByName,
    CreatedAt
FROM dbo.tblOperationHeader oh
    LEFT JOIN dbo.tblCustomers c ON oh.CustomerCode = c.CustomerCode
    LEFT JOIN dbo.tblUsers u ON oh.UserCode = u.UserCode
WHERE
    OperationType = 'SALE_INVOICE'
    AND OperationStatus NOT IN('CANCELLED', 'CLOSED')
UNION ALL
SELECT
    'PURCHASE_INVOICE' AS OperationCategory,
    OperationID,
    OperationNo,
    OperationType,
    OperationStatus,
    OperationDate,
    SupplierCode,
    s.SupplierNameAr AS PartyName,
    TotalAmount,
    UserCode,
    u.UserNameAr AS CreatedByName,
    CreatedAt
FROM dbo.tblOperationHeader oh
    LEFT JOIN dbo.tblSuppliers s ON oh.SupplierCode = s.SupplierCode
    LEFT JOIN dbo.tblUsers u ON oh.UserCode = u.UserCode
WHERE
    OperationType = 'PURCHASE_INVOICE'
    AND OperationStatus NOT IN('CANCELLED', 'CLOSED')
UNION ALL
SELECT
    'JOURNAL' AS OperationCategory,
    JournalHeaderID AS OperationID,
    JournalNo AS OperationNo,
    JournalType AS OperationType,
    JournalStatus AS OperationStatus,
    JournalDate AS OperationDate,
    NULL,
    Description AS PartyName,
    TotalDebit AS TotalAmount,
    UserCode,
    u.UserNameAr AS CreatedByName,
    CreatedAt
FROM dbo.tblJournalHeader jh
    LEFT JOIN dbo.tblUsers u ON jh.UserCode = u.UserCode
WHERE
    IsPosted = 0
    AND JournalStatus NOT IN('CANCELLED')
UNION ALL
SELECT
    'BOND' AS OperationCategory,
    BondHeaderID AS OperationID,
    BondNo AS OperationNo,
    BondType AS OperationType,
    BondStatus AS OperationStatus,
    BondDate AS OperationDate,
    NULL,
    Description AS PartyName,
    TotalAmount,
    UserCode,
    u.UserNameAr AS CreatedByName,
    CreatedAt
FROM dbo.tblBondHeader bh
    LEFT JOIN dbo.tblUsers u ON bh.UserCode = u.UserCode
WHERE
    IsPosted = 0
    AND BondStatus = 'PENDING';
GO

PRINT 'Database Views created successfully.';
GO

-- ============================================================
-- SECTION 11: STORED PROCEDURES (الإجراءات المخزنة)
-- ============================================================
PRINT '';

PRINT '========================================';

PRINT 'SECTION 11: Creating Stored Procedures...';

PRINT '========================================';

-- =============================================
-- User Management Procedures
-- =============================================

-- sp_Login: Authenticates user and creates session
CREATE OR ALTER PROCEDURE dbo.sp_Login
    @UserID NVARCHAR(15),
    @Password NVARCHAR(256),
    @ComputerName NVARCHAR(100) = NULL,
    @IPAddress NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserCode INT, @IsValid BIT = 0, @Token UNIQUEIDENTIFIER;
    DECLARE @PasswordHash VARBINARY(8000), @Salt VARBINARY(8000);
    
    -- Get user credentials
    SELECT @UserCode = UserCode, @PasswordHash = UserPassword, @Salt = Salt
    FROM dbo.tblUsers 
    WHERE UserID = @UserID AND IsActive = 1;
    
    -- Check if user exists and not locked
    IF @UserCode IS NULL
    BEGIN
        SELECT @IsValid = 0, @Token = NULL;
        RETURN;
    END
    
    -- Check lock status
    IF EXISTS (SELECT 1 FROM dbo.tblUsers WHERE UserCode = @UserCode AND LockedUntil > GETDATE())
    BEGIN
        SELECT @IsValid = 0, @Token = NULL;
        RETURN;
    END
    
    -- Verify password using PBKDF2-SHA256
    DECLARE @ComputedHash VARBINARY(8000);
    EXEC @ComputedHash = dbo.fn_VerifyPassword @Password, @Salt;
    
    IF @ComputedHash = @PasswordHash
    BEGIN
        -- Generate session token
        SET @Token = NEWID();
        
        -- Create session
        INSERT INTO dbo.tblSessions (Token, UserCode, LoginTime, ExpiresAt, ComputerName, IPAddress, IsActive)
        VALUES (@Token, @UserCode, GETDATE(), DATEADD(HOUR, 8, GETDATE()), @ComputerName, @IPAddress, 1);
        
        -- Update login info
        UPDATE dbo.tblUsers 
        SET LastLoginAt = GETDATE(), LoginAttempts = 0, IsOnline = 1
        WHERE UserCode = @UserCode;
        
        SET @IsValid = 1;
    END
    ELSE
    BEGIN
        -- Increment failed attempts
        UPDATE dbo.tblUsers 
        SET LoginAttempts = LoginAttempts + 1,
            LockedUntil = CASE WHEN LoginAttempts >= 5 THEN DATEADD(MINUTE, 30, GETDATE()) ELSE NULL END
        WHERE UserCode = @UserCode;
        
        SET @IsValid = 0;
    END
    
    SELECT @IsValid AS IsValid, @Token AS Token, @UserCode AS UserCode;
END
GO

-- sp_Logout: Ends user session
CREATE OR ALTER PROCEDURE dbo.sp_Logout
    @Token UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserCode INT;
    SELECT @UserCode = UserCode FROM dbo.tblSessions WHERE Token = @Token AND IsActive = 1;
    
    UPDATE dbo.tblSessions SET IsActive = 0, LogoutTime = GETDATE() WHERE Token = @Token;
    
    IF @UserCode IS NOT NULL
        UPDATE dbo.tblUsers SET IsOnline = 0 WHERE UserCode = @UserCode;
    
    SELECT 'Logged out successfully' AS Result;
END
GO

-- sp_ValidateSession: Checks if session is valid
CREATE OR ALTER PROCEDURE dbo.sp_ValidateSession
    @Token UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @IsValid BIT = 0, @UserCode INT, @UserName NVARCHAR(200), @IsAdmin BIT = 0;
    
    SELECT @IsValid = 1, @UserCode = s.UserCode, @UserName = u.UserNameAr, @IsAdmin = u.IsAdmin
    FROM dbo.tblSessions s
    INNER JOIN dbo.tblUsers u ON s.UserCode = u.UserCode
    WHERE s.Token = @Token AND s.IsActive = 1 AND s.ExpiresAt > GETDATE();
    
    -- Extend session if valid
    IF @IsValid = 1
        UPDATE dbo.tblSessions SET ExpiresAt = DATEADD(HOUR, 8, GETDATE()) WHERE Token = @Token;
    
    SELECT @IsValid AS IsValid, @UserCode AS UserCode, @UserName AS UserName, @IsAdmin AS IsAdmin;
END
GO

-- =============================================
-- Product Procedures
-- =============================================

-- sp_GetProductStock: Gets stock levels for a product
CREATE OR ALTER PROCEDURE dbo.sp_GetProductStock
    @ProductCode INT,
    @StoreCode INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @StoreCode IS NULL
    BEGIN
        SELECT 
            p.ProductCode,
            p.ProductID,
            p.ProductNameAr,
            st.StoreCode,
            st.StoreNameAr,
            ISNULL(sp.QtyOnHand, 0) AS QtyOnHand,
            ISNULL(sp.QtyReserved, 0) AS QtyReserved,
            ISNULL(sp.QtyOnHand, 0) - ISNULL(sp.QtyReserved, 0) AS QtyAvailable,
            ISNULL(sp.AvgCost, 0) AS AvgCost
        FROM dbo.tblProducts p
        CROSS JOIN dbo.tblStores st
        LEFT JOIN dbo.tblStoreProducts sp ON p.ProductCode = sp.ProductCode AND st.StoreCode = sp.StoreCode AND sp.IsActive = 1
        WHERE p.ProductCode = @ProductCode AND st.IsActive = 1
        ORDER BY st.StoreNameAr;
    END
    ELSE
    BEGIN
        SELECT 
            p.ProductCode,
            p.ProductID,
            p.ProductNameAr,
            st.StoreCode,
            st.StoreNameAr,
            ISNULL(sp.QtyOnHand, 0) AS QtyOnHand,
            ISNULL(sp.QtyReserved, 0) AS QtyReserved,
            ISNULL(sp.QtyOnHand, 0) - ISNULL(sp.QtyReserved, 0) AS QtyAvailable,
            ISNULL(sp.AvgCost, 0) AS AvgCost,
            sp.BatchID,
            b.BatchNo,
            b.ExpiryDate
        FROM dbo.tblProducts p
        INNER JOIN dbo.tblStores st ON st.StoreCode = @StoreCode
        LEFT JOIN dbo.tblStoreProducts sp ON p.ProductCode = sp.ProductCode AND st.StoreCode = sp.StoreCode AND sp.IsActive = 1
        LEFT JOIN dbo.tblProductBatches b ON sp.BatchID = b.BatchID
        WHERE p.ProductCode = @ProductCode;
    END
END
GO

-- sp_SearchProducts: Search products with filters
CREATE OR ALTER PROCEDURE dbo.sp_SearchProducts
    @SearchTerm NVARCHAR(200) = NULL,
    @CategoryCode INT = NULL,
    @StoreCode INT = NULL,
    @ShowOnlyInStock BIT = 0,
    @PageSize INT = 50,
    @PageNumber INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        p.ProductCode,
        p.ProductID,
        p.ProductNameAr,
        p.ProductNameEn,
        p.Barcode,
        c.CategoryNameAr AS CategoryName,
        u.UnitNameAr AS UnitName,
        p.StandardCost,
        p.LastPurchasePrice,
        p.LastSalePrice,
        ISNULL(sp.QtyOnHand, 0) AS QtyOnHand,
        ISNULL(sp.QtyAvailable, 0) AS QtyAvailable,
        p.IsActive
    FROM dbo.tblProducts p
    LEFT JOIN dbo.tblCategories c ON p.CategoryCode = c.CategoryCode
    LEFT JOIN dbo.tblUnits u ON p.DefaultUnitCode = u.UnitCode
    LEFT JOIN (
        SELECT ProductCode, 
               SUM(QtyOnHand) AS QtyOnHand, 
               SUM(QtyOnHand) - SUM(QtyReserved) AS QtyAvailable
        FROM dbo.tblStoreProducts 
        WHERE IsActive = 1
        GROUP BY ProductCode
    ) sp ON p.ProductCode = sp.ProductCode
    WHERE p.IsActive = 1
      AND (@SearchTerm IS NULL OR p.ProductNameAr LIKE '%' + @SearchTerm + '%' 
           OR p.ProductNameEn LIKE '%' + @SearchTerm + '%'
           OR p.ProductID LIKE '%' + @SearchTerm + '%'
           OR p.Barcode LIKE '%' + @SearchTerm + '%')
      AND (@CategoryCode IS NULL OR p.CategoryCode = @CategoryCode)
      AND (@ShowOnlyInStock = 0 OR ISNULL(sp.QtyOnHand, 0) > 0)
    ORDER BY p.ProductNameAr
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
    
    -- Total count
    SELECT COUNT(*) AS TotalCount
    FROM dbo.tblProducts p
    LEFT JOIN (
SELECT ProductCode, SUM(QtyOnHand) AS QtyOnHand
        FROM dbo.tblStoreProducts WHERE IsActive = 1
        GROUP BY ProductCode
    ) sp ON p.ProductCode = sp.ProductCode
    WHERE p.IsActive = 1
      AND (@SearchTerm IS NULL OR p.ProductNameAr LIKE '%' + @SearchTerm + '%')
      AND (@CategoryCode IS NULL OR p.CategoryCode = @CategoryCode)
      AND (@ShowOnlyInStock = 0 OR ISNULL(sp.QtyOnHand, 0) > 0);
END
GO

-- =============================================
-- Financial Procedures
-- =============================================

-- sp_GetAccountBalance: Gets account balance
CREATE OR ALTER PROCEDURE dbo.sp_GetAccountBalance
    @AccountCode INT,
    @AsOfDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @AsOfDate IS NULL
        SET @AsOfDate = GETDATE();
    
    DECLARE @TotalDebit DECIMAL(18,4) = 0, @TotalCredit DECIMAL(18,4) = 0;
    
    -- From Journal
    SELECT @TotalDebit = @TotalDebit + ISNULL(SUM(DebitAmount), 0),
           @TotalCredit = @TotalCredit + ISNULL(SUM(CreditAmount), 0)
    FROM dbo.tblJournalBody jb
    INNER JOIN dbo.tblJournalHeader jh ON jb.JournalHeaderID = jh.JournalHeaderID
    WHERE jb.AccountCode = @AccountCode
      AND jh.JournalDate <= @AsOfDate
      AND jh.IsPosted = 1;
    
    -- From Bond
    SELECT @TotalDebit = @TotalDebit + ISNULL(SUM(DebitAmount), 0),
           @TotalCredit = @TotalCredit + ISNULL(SUM(CreditAmount), 0)
    FROM dbo.tblBondBody bb
    INNER JOIN dbo.tblBondHeader bh ON bb.BondHeaderID = bh.BondHeaderID
    WHERE bb.AccountCode = @AccountCode
      AND bh.BondDate <= @AsOfDate
      AND bh.BondStatus = 'POSTED';
    
    SELECT 
        @AccountCode AS AccountCode,
        a.AccountID,
        a.AccountNameAr,
        a.AccountNature,
        @TotalDebit AS TotalDebit,
        @TotalCredit AS TotalCredit,
        @TotalDebit - @TotalCredit AS Balance,
        CASE 
            WHEN a.AccountNature = 'Debit' THEN @TotalDebit - @TotalCredit
            ELSE @TotalCredit - @TotalDebit
        END AS BalanceBasedOnNature
    FROM dbo.tblAccounts a
    WHERE a.AccountCode = @AccountCode;
END
GO

-- sp_GetTrialBalance: Generates trial balance
CREATE OR ALTER PROCEDURE dbo.sp_GetTrialBalance
    @FromDate DATETIME,
    @ToDate DATETIME,
    @BranchCode INT = NULL,
    @Level INT = 4
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        a.AccountCode,
        a.AccountID,
        a.AccountNameAr,
        a.AccountLevel,
        a.AccountType,
        a.AccountNature,
        a.IsPostable,
        ISNULL((
            SELECT SUM(jb.DebitAmount) - SUM(jb.CreditAmount)
            FROM dbo.tblJournalBody jb
            INNER JOIN dbo.tblJournalHeader jh ON jb.JournalHeaderID = jh.JournalHeaderID
            WHERE jb.AccountCode = a.AccountCode
              AND jh.JournalDate >= @FromDate
              AND jh.JournalDate <= @ToDate
              AND jh.IsPosted = 1
              AND (@BranchCode IS NULL OR jh.BranchCode = @BranchCode)
        ), 0) AS PeriodBalance,
        dbo.fn_GetAccountBalance(a.AccountCode, @ToDate) AS Balance
    FROM dbo.tblAccounts a
    WHERE a.IsActive = 1 
      AND a.AccountLevel <= @Level
      AND a.IsMainAccount = 0
    ORDER BY a.AccountCode;
END
GO

-- =============================================
-- Customer/Supplier Procedures
-- =============================================

-- sp_GetCustomerStatement: Gets customer account statement
CREATE OR ALTER PROCEDURE dbo.sp_GetCustomerStatement
    @CustomerCode INT,
    @FromDate DATETIME,
    @ToDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Opening balance
    DECLARE @OpeningBalance DECIMAL(18,4) = 0;
    
    SELECT @OpeningBalance = ISNULL(Balance, 0)
    FROM dbo.tblCustomers
    WHERE CustomerCode = @CustomerCode;
    
    SELECT 
        'OPENING' AS TransactionType,
        @FromDate AS TransactionDate,
        NULL AS ReferenceNo,
        'الرصيد الافتتاحي' AS Description,
        CASE WHEN @OpeningBalance > 0 THEN @OpeningBalance ELSE 0 END AS Debit,
        CASE WHEN @OpeningBalance < 0 THEN ABS(@OpeningBalance) ELSE 0 END AS Credit,
        @OpeningBalance AS Balance,
        0 AS RunningBalance
    UNION ALL
    SELECT 
        'INVOICE' AS TransactionType,
        OperationDate AS TransactionDate,
        OperationNo AS ReferenceNo,
        'فاتورة مبيعات' AS Description,
        TotalAmount AS Debit,
        0 AS Credit,
        0 AS Balance,
        0 AS RunningBalance
    FROM dbo.tblOperationHeader
    WHERE CustomerCode = @CustomerCode
      AND OperationDate >= @FromDate AND OperationDate <= @ToDate
      AND OperationType = 'SALE_INVOICE'
      AND OperationStatus NOT IN ('CANCELLED')
    UNION ALL
    SELECT 
        'PAYMENT' AS TransactionType,
        BondDate AS TransactionDate,
        BondNo AS ReferenceNo,
        'تحصيل مدفوعات' AS Description,
        0 AS Debit,
        TotalAmount AS Credit,
        0 AS Balance,
        0 AS RunningBalance
    FROM dbo.tblBondHeader
    WHERE CustomerCode = @CustomerCode
      AND BondDate >= @FromDate AND BondDate <= @ToDate
      AND BondType IN ('RECEIPT')
      AND BondStatus = 'POSTED'
    ORDER BY TransactionDate, TransactionType;
END
GO

-- sp_GetSupplierStatement: Gets supplier account statement
CREATE OR ALTER PROCEDURE dbo.sp_GetSupplierStatement
    @SupplierCode INT,
    @FromDate DATETIME,
    @ToDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @OpeningBalance DECIMAL(18,4) = 0;
    
    SELECT @OpeningBalance = ISNULL(Balance, 0)
    FROM dbo.tblSuppliers
    WHERE SupplierCode = @SupplierCode;
    
    SELECT 
        'OPENING' AS TransactionType,
        @FromDate AS TransactionDate,
        NULL AS ReferenceNo,
        'الرصيد الافتتاحي' AS Description,
        CASE WHEN @OpeningBalance < 0 THEN ABS(@OpeningBalance) ELSE 0 END AS Debit,
        CASE WHEN @OpeningBalance > 0 THEN @OpeningBalance ELSE 0 END AS Credit,
        @OpeningBalance AS Balance
    UNION ALL
    SELECT 
        'INVOICE' AS TransactionType,
        OperationDate AS TransactionDate,
        OperationNo AS ReferenceNo,
        'فاتورة مشتريات' AS Description,
        0 AS Debit,
        TotalAmount AS Credit,
        0 AS Balance
    FROM dbo.tblOperationHeader
    WHERE SupplierCode = @SupplierCode
      AND OperationDate >= @FromDate AND OperationDate <= @ToDate
      AND OperationType = 'PURCHASE_INVOICE'
      AND OperationStatus NOT IN ('CANCELLED')
    UNION ALL
    SELECT 
        'PAYMENT' AS TransactionType,
        BondDate AS TransactionDate,
        BondNo AS ReferenceNo,
        'دفع لمورد' AS Description,
        TotalAmount AS Debit,
        0 AS Credit,
        0 AS Balance
    FROM dbo.tblBondHeader
    WHERE SupplierCode = @SupplierCode
      AND BondDate >= @FromDate AND BondDate <= @ToDate
      AND BondType IN ('PAYMENT')
      AND BondStatus = 'POSTED'
    ORDER BY TransactionDate;
END
GO

-- =============================================
-- Stock Movement Procedures
-- =============================================

-- sp_GetStockMovement: Gets stock movement history
CREATE OR ALTER PROCEDURE dbo.sp_GetStockMovement
    @ProductCode INT = NULL,
    @StoreCode INT = NULL,
    @FromDate DATETIME = NULL,
    @ToDate DATETIME = NULL,
    @MovementType NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @FromDate IS NULL
        SET @FromDate = DATEADD(MONTH, -1, GETDATE());
    IF @ToDate IS NULL
        SET @ToDate = GETDATE();
    
    SELECT 
        pm.MovementID,
        pm.MovementNo,
        pm.MovementType,
        pm.MovementDate,
        p.ProductID,
        p.ProductNameAr,
        st.StoreNameAr,
        pm.Qty,
        u.UnitNameAr AS UnitName,
        pm.UnitPrice,
        pm.TotalPrice,
        pm.SourceType,
        pm.SourceNo,
        pm.ReferenceNo,
        pm.Notes,
        us.UserNameAr AS UserName
    FROM dbo.tblProductMovement pm
    INNER JOIN dbo.tblProducts p ON pm.ProductCode = p.ProductCode
    INNER JOIN dbo.tblStores st ON pm.StoreCode = st.StoreCode
    INNER JOIN dbo.tblUnits u ON pm.UnitCode = u.UnitCode
    LEFT JOIN dbo.tblUsers us ON pm.UserCode = us.UserCode
    WHERE pm.MovementDate >= @FromDate AND pm.MovementDate <= @ToDate
      AND (@ProductCode IS NULL OR pm.ProductCode = @ProductCode)
      AND (@StoreCode IS NULL OR pm.StoreCode = @StoreCode)
      AND (@MovementType IS NULL OR pm.MovementType = @MovementType)
    ORDER BY pm.MovementDate DESC, pm.MovementID DESC;
END
GO

-- =============================================
-- Report Procedures
-- =============================================

-- sp_GetSalesSummary: Gets sales summary by period
CREATE OR ALTER PROCEDURE dbo.sp_GetSalesSummary
    @FromDate DATETIME,
    @ToDate DATETIME,
    @BranchCode INT = NULL,
    @GroupBy NVARCHAR(20) = 'DAY'
    -- Options: DAY, WEEK, MONTH, CUSTOMER, PRODUCT, CATEGORY
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @GroupBy = 'DAY'
    BEGIN
        SELECT 
            CAST(oh.OperationDate AS DATE) AS Period,
            COUNT(DISTINCT oh.OperationID) AS InvoiceCount,
            SUM(oh.SubTotal) AS SubTotal,
            SUM(oh.DiscountAmount) AS Discount,
            SUM(oh.VatAmount) AS VatAmount,
            SUM(oh.TotalAmount) AS TotalSales,
            SUM(oh.PaidAmount) AS PaidAmount,
            SUM(oh.DueAmount) AS DueAmount
        FROM dbo.tblOperationHeader oh
        WHERE oh.OperationType = 'SALE_INVOICE'
          AND oh.OperationStatus NOT IN ('CANCELLED')
          AND oh.OperationDate >= @FromDate AND oh.OperationDate <= @ToDate
          AND (@BranchCode IS NULL OR oh.BranchCode = @BranchCode)
        GROUP BY CAST(oh.OperationDate AS DATE)
        ORDER BY Period;
    END
    ELSE IF @GroupBy = 'MONTH'
    BEGIN
        SELECT 
            YEAR(oh.OperationDate) AS Year,
            MONTH(oh.OperationDate) AS Month,
DATENAME(MONTH, oh.OperationDate) AS MonthName,
            COUNT(DISTINCT oh.OperationID) AS InvoiceCount,
            SUM(oh.SubTotal) AS SubTotal,
            SUM(oh.DiscountAmount) AS Discount,
            SUM(oh.VatAmount) AS VatAmount,
            SUM(oh.TotalAmount) AS TotalSales,
            SUM(oh.PaidAmount) AS PaidAmount,
            SUM(oh.DueAmount) AS DueAmount
        FROM dbo.tblOperationHeader oh
        WHERE oh.OperationType = 'SALE_INVOICE'
          AND oh.OperationStatus NOT IN ('CANCELLED')
          AND oh.OperationDate >= @FromDate AND oh.OperationDate <= @ToDate
          AND (@BranchCode IS NULL OR oh.BranchCode = @BranchCode)
        GROUP BY YEAR(oh.OperationDate), MONTH(oh.OperationDate)
        ORDER BY Year, Month;
    END
    ELSE IF @GroupBy = 'PRODUCT'
    BEGIN
        SELECT 
            p.ProductCode,
            p.ProductID,
            p.ProductNameAr,
            u.UnitNameAr AS UnitName,
            SUM(ob.Qty) AS TotalQty,
            SUM(ob.LineTotal) AS TotalSales
        FROM dbo.tblOperationHeader oh
        INNER JOIN dbo.tblOperationBody ob ON oh.OperationID = ob.OperationID
        INNER JOIN dbo.tblProducts p ON ob.ProductCode = p.ProductCode
        INNER JOIN dbo.tblUnits u ON ob.UnitCode = u.UnitCode
        WHERE oh.OperationType = 'SALE_INVOICE'
          AND oh.OperationStatus NOT IN ('CANCELLED')
          AND oh.OperationDate >= @FromDate AND oh.OperationDate <= @ToDate
          AND (@BranchCode IS NULL OR oh.BranchCode = @BranchCode)
        GROUP BY p.ProductCode, p.ProductID, p.ProductNameAr, u.UnitNameAr
        ORDER BY TotalSales DESC;
    END
END
GO

-- sp_GetLowStockProducts: Gets products below reorder level
CREATE OR ALTER PROCEDURE dbo.sp_GetLowStockProducts
    @StoreCode INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        p.ProductCode,
        p.ProductID,
        p.ProductNameAr,
        st.StoreCode,
        st.StoreNameAr,
        ISNULL(sp.QtyOnHand, 0) AS QtyOnHand,
        ISNULL(sp.QtyReserved, 0) AS QtyReserved,
        p.MinStockLevel,
        p.ReorderLevel,
        p.MinStockLevel - ISNULL(sp.QtyOnHand, 0) AS Shortage,
        p.LastPurchaseDate,
        p.LastPurchasePrice
    FROM dbo.tblProducts p
    CROSS JOIN dbo.tblStores st
    LEFT JOIN dbo.tblStoreProducts sp ON p.ProductCode = sp.ProductCode AND st.StoreCode = sp.StoreCode AND sp.IsActive = 1
    WHERE p.IsActive = 1
      AND p.IsInventoryItem = 1
      AND (@StoreCode IS NULL OR st.StoreCode = @StoreCode)
      AND ISNULL(sp.QtyOnHand, 0) <= ISNULL(p.MinStockLevel, 0)
    ORDER BY (ISNULL(sp.QtyOnHand, 0) - p.MinStockLevel) ASC;
END
GO

PRINT 'Stored Procedures created successfully.';
GO

-- ============================================================
-- SECTION 12: TRIGGERS (الزنادات)
-- ============================================================
PRINT '';

PRINT '========================================';

PRINT 'SECTION 12: Creating Database Triggers...';

PRINT '========================================';

-- =============================================
-- Audit Triggers
-- =============================================

-- trg_AuditLogs_Insert: Logs all inserts to audit table
CREATE OR ALTER TRIGGER dbo.trg_AuditLogs_Insert
ON dbo.tblAuditLogs
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO dbo.tblAuditLogs (
        LogDate, ActionType, TableName, RecordID, OldValues, NewValues,
        UserCode, ComputerName, IPAddress, AdditionalInfo
    )
    SELECT 
        ISNULL(LogDate, GETDATE()),
        ActionType,
        TableName,
        RecordID,
        OldValues,
        NewValues,
        UserCode,
        ComputerName,
        IPAddress,
        AdditionalInfo
    FROM inserted;
END
GO

-- trg_Users_Update: Audit user changes
CREATE OR ALTER TRIGGER dbo.trg_Users_Update
ON dbo.tblUsers
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Password change
    IF UPDATE(UserPassword)
    BEGIN
        UPDATE tblUsers
        SET PasswordHistory2 = PasswordHistory1,
            PasswordHistory1 = UserPassword,
            PasswordLastChanged = GETDATE(),
            MustChangePassword = 0,
            LoginAttempts = 0,
            LockedUntil = NULL
        WHERE UserCode IN (SELECT UserCode FROM inserted);
    END
END
GO

-- =============================================
-- Stock Management Triggers
-- =============================================

-- trg_StoreProducts_Update: Update store product stock
CREATE OR ALTER TRIGGER dbo.trg_StoreProducts_Update
ON dbo.tblStoreProducts
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Ensure QtyReserved doesn't exceed QtyOnHand
    IF EXISTS (SELECT 1 FROM inserted WHERE QtyReserved > QtyOnHand)
    BEGIN
        RAISERROR('الكمية المحجوزة لا يمكن أن تتجاوز الكمية المتاحة', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

-- trg_OperationHeader_AfterInsert: Handle operation after insert
CREATE OR ALTER TRIGGER dbo.trg_OperationHeader_AfterInsert
ON dbo.tblOperationHeader
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @OperationID BIGINT, @OperationType NVARCHAR(20), @CustomerCode INT, @SupplierCode INT;
    
    SELECT @OperationID = OperationID, @OperationType = OperationType, 
           @CustomerCode = CustomerCode, @SupplierCode = SupplierCode
    FROM inserted;
    
    -- Generate operation number if not exists
    DECLARE @NewNo NVARCHAR(30), @Prefix NVARCHAR(10);
    
    SET @Prefix = CASE @OperationType
        WHEN 'SALE_INVOICE' THEN 'INV'
        WHEN 'PURCHASE_INVOICE' THEN 'PINV'
        WHEN 'SALES_ORDER' THEN 'SO'
        WHEN 'PURCHASE_ORDER' THEN 'PO'
        WHEN 'DELIVERY' THEN 'DLV'
        WHEN 'SALE_RETURN' THEN 'SRTN'
        WHEN 'PURCHASE_RETURN' THEN 'PRTN'
        WHEN 'QUOTATION' THEN 'QT'
        ELSE 'DOC'
    END + '-' + FORMAT(GETDATE(), 'yyMM') + '-';
    
    -- This is a placeholder - in production, use a sequence table
    UPDATE dbo.tblOperationHeader
    SET OperationNo = @Prefix + RIGHT('00000' + CAST(@OperationID AS NVARCHAR), 5)
    WHERE OperationID = @OperationID AND OperationNo IS NULL;
END
GO

-- trg_OperationHeader_StatusChange: Handle status changes
CREATE OR ALTER TRIGGER dbo.trg_OperationHeader_StatusChange
ON dbo.tblOperationHeader
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @OperationID BIGINT, @OldStatus NVARCHAR(20), @NewStatus NVARCHAR(20);
    
    SELECT @OperationID = OperationID, @OldStatus = OperationStatus FROM deleted;
    SELECT @NewStatus = OperationStatus FROM inserted;
    
    -- If status changed to CANCELLED, release any reserved stock
    IF @OldStatus <> 'CANCELLED' AND @NewStatus = 'CANCELLED'
    BEGIN
        -- Release reserved quantities
        UPDATE sp
        SET QtyReserved = QtyReserved - ISNULL((
            SELECT SUM(ob.Qty)
            FROM dbo.tblOperationBody ob
            WHERE ob.OperationID = @OperationID
              AND ob.StoreCode = sp.StoreCode
              AND ob.ProductCode = sp.ProductCode
        ), 0)
        FROM dbo.tblStoreProducts sp
        INNER JOIN dbo.tblOperationBody ob ON sp.ProductCode = ob.ProductCode AND sp.StoreCode = ob.StoreCode
        WHERE ob.OperationID = @OperationID;
    END
END
GO

-- =============================================
-- Account Balance Triggers
-- =============================================

-- trg_BondHeader_AfterPost: Update account balances when bond is posted
CREATE OR ALTER TRIGGER dbo.trg_BondHeader_AfterPost
ON dbo.tblBondHeader
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(BondStatus)
    BEGIN
        -- This trigger handles account balance updates
        -- In production, you might want to separate this into a stored procedure
        -- that updates the balance when transactions are posted
    END
END
GO

-- trg_JournalHeader_AfterPost: Update account balances when journal is posted
CREATE OR ALTER TRIGGER dbo.trg_JournalHeader_AfterPost
ON dbo.tblJournalHeader
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(IsPosted)
    BEGIN
        -- Handle posting of journal entries
        -- In production, this would update account balances
    END
END
GO

-- =============================================
-- Session Management Triggers
-- =============================================

-- trg_Sessions_Cleanup: Clean up expired sessions periodically
CREATE OR ALTER TRIGGER dbo.trg_Sessions_Cleanup
ON dbo.tblSessions
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Clean up expired sessions (older than 24 hours)
    DELETE FROM dbo.tblSessions 
    WHERE ExpiresAt < DATEADD(HOUR, -24, GETDATE());
END
GO

-- =============================================
-- Customer/Supplier Balance Triggers
-- =============================================

-- trg_CustomerBalance_Update: Update customer balance
CREATE OR ALTER TRIGGER dbo.trg_CustomerBalance_Update
ON dbo.tblOperationHeader
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(TotalAmount) OR UPDATE(OperationStatus)
    BEGIN
        -- Calculate and update customer balance
        UPDATE c
        SET c.TotalSales = ISNULL((
            SELECT SUM(TotalAmount)
            FROM dbo.tblOperationHeader
            WHERE CustomerCode = c.CustomerCode
              AND OperationType = 'SALE_INVOICE'
              AND OperationStatus NOT IN ('CANCELLED')
        ), 0),
        c.TotalReturns = ISNULL((
            SELECT SUM(TotalAmount)
            FROM dbo.tblOperationHeader
            WHERE CustomerCode = c.CustomerCode
              AND OperationType = 'SALE_RETURN'
              AND OperationStatus NOT IN ('CANCELLED')
        ), 0),
        c.CurrentCredit = ISNULL((
            SELECT SUM(DueAmount)
            FROM dbo.tblOperationHeader
            WHERE CustomerCode = c.CustomerCode
              AND OperationType = 'SALE_INVOICE'
              AND OperationStatus NOT IN ('CANCELLED')
        ), 0),
        c.Balance = ISNULL((
            SELECT SUM(DueAmount)
            FROM dbo.tblOperationHeader
            WHERE CustomerCode = c.CustomerCode
              AND OperationType = 'SALE_INVOICE'
              AND OperationStatus NOT IN ('CANCELLED')
        ), 0) - ISNULL((
            SELECT SUM(TotalAmount)
            FROM dbo.tblOperationHeader
            WHERE CustomerCode = c.CustomerCode
              AND OperationType = 'SALE_RETURN'
              AND OperationStatus NOT IN ('CANCELLED')
        ), 0),
        c.LastSaleDate = ISNULL((
            SELECT MAX(OperationDate)
            FROM dbo.tblOperationHeader
            WHERE CustomerCode = c.CustomerCode
              AND OperationType = 'SALE_INVOICE'
        ), c.LastSaleDate)
        FROM dbo.tblCustomers c
        WHERE c.CustomerCode IN (SELECT CustomerCode FROM inserted WHERE CustomerCode IS NOT NULL);
    END
END
GO

-- trg_SupplierBalance_Update: Update supplier balance
CREATE OR ALTER TRIGGER dbo.trg_SupplierBalance_Update
ON dbo.tblOperationHeader
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(TotalAmount) OR UPDATE(OperationStatus)
    BEGIN
        UPDATE s
        SET s.TotalPurchases = ISNULL((
            SELECT SUM(TotalAmount)
            FROM dbo.tblOperationHeader
            WHERE SupplierCode = s.SupplierCode
              AND OperationType = 'PURCHASE_INVOICE'
              AND OperationStatus NOT IN ('CANCELLED')
        ), 0),
        s.TotalReturns = ISNULL((
            SELECT SUM(TotalAmount)
            FROM dbo.tblOperationHeader
            WHERE SupplierCode = s.SupplierCode
              AND OperationType = 'PURCHASE_RETURN'
              AND OperationStatus NOT IN ('CANCELLED')
        ), 0),
        s.Balance = ISNULL((
            SELECT SUM(DueAmount)
            FROM dbo.tblOperationHeader
            WHERE SupplierCode = s.SupplierCode
              AND OperationType = 'PURCHASE_INVOICE'
              AND OperationStatus NOT IN ('CANCELLED')
        ), 0) - ISNULL((
            SELECT SUM(TotalAmount)
            FROM dbo.tblOperationHeader
            WHERE SupplierCode= s.SupplierCode
              AND OperationType = 'PURCHASE_RETURN'
              AND OperationStatus NOT IN ('CANCELLED')
        ), 0),
        s.LastPurchaseDate = ISNULL((
            SELECT MAX(OperationDate)
            FROM dbo.tblOperationHeader
            WHERE SupplierCode = s.SupplierCode
              AND OperationType = 'PURCHASE_INVOICE'
        ), s.LastPurchaseDate)
        FROM dbo.tblSuppliers s
        WHERE s.SupplierCode IN (SELECT SupplierCode FROM inserted WHERE SupplierCode IS NOT NULL);
    END
END
GO

-- =============================================
-- Product Movement Triggers
-- =============================================

-- trg_ProductMovement_Insert: Update store stock after movement
CREATE OR ALTER TRIGGER dbo.trg_ProductMovement_Insert
ON dbo.tblProductMovement
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ProductCode INT, @StoreCode INT, @BatchID INT, @Qty DECIMAL(18,4), @MovementType NVARCHAR(20);
    
    SELECT @ProductCode = ProductCode, @StoreCode = StoreCode, 
           @BatchID = BatchID, @Qty = Qty, @MovementType = MovementType
    FROM inserted;
    
    -- Ensure store product record exists
    IF NOT EXISTS (
        SELECT 1 FROM dbo.tblStoreProducts 
        WHERE ProductCode = @ProductCode AND StoreCode = @StoreCode AND IsActive = 1
    )
    BEGIN
        INSERT INTO dbo.tblStoreProducts (ProductCode, StoreCode, QtyOnHand, IsActive)
        VALUES (@ProductCode, @StoreCode, 0, 1);
    END
    
    -- Update stock based on movement type
    UPDATE sp
    SET QtyOnHand = CASE 
            WHEN @MovementType IN ('PURCHASE', 'PURCHASE_RETURN', 'TRANSFER_IN', 'ADJUSTMENT_IN', 'OPENING', 'PRODUCTION_IN')
            THEN QtyOnHand + @Qty
            ELSE QtyOnHand - @Qty
        END
    FROM dbo.tblStoreProducts sp
    WHERE sp.ProductCode = @ProductCode AND sp.StoreCode = @StoreCode;
    
    -- Update batch if exists
    IF @BatchID IS NOT NULL
    BEGIN
        UPDATE dbo.tblProductBatches
        SET QtyOnHand = CASE 
                WHEN @MovementType IN ('PURCHASE', 'PURCHASE_RETURN', 'TRANSFER_IN', 'ADJUSTMENT_IN', 'OPENING')
                THEN QtyOnHand + @Qty
                ELSE QtyOnHand - @Qty
            END
        WHERE BatchID = @BatchID;
    END
END
GO

-- =============================================
-- Category Path Triggers
-- =============================================

-- trg_Categories_UpdatePath: Update category path on insert/update
CREATE OR ALTER TRIGGER dbo.trg_Categories_UpdatePath
ON dbo.tblCategories
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(CategoryNameAr) OR UPDATE(ParentCategoryCode)
    BEGIN
        -- Update paths for this category and all children
        ;WITH CategoryPath AS (
            -- Start with updated categories
            SELECT CategoryCode, CategoryNameAr, ParentCategoryCode, 
                   CAST('/' + CategoryNameAr AS NVARCHAR(500)) AS FullPath,
                   1 AS Level
            FROM inserted
            WHERE ParentCategoryCode IS NULL
            
            UNION ALL
            
            -- Recursively get children
            SELECT c.CategoryCode, c.CategoryNameAr, c.ParentCategoryCode,
                   cp.FullPath + '/' + c.CategoryNameAr,
                   cp.Level + 1
            FROM dbo.tblCategories c
            INNER JOIN CategoryPath cp ON c.ParentCategoryCode = cp.CategoryCode
        )
        UPDATE c
        SET CategoryPath = cp.FullPath,
            CategoryLevel = cp.Level
        FROM dbo.tblCategories c
        INNER JOIN CategoryPath cp ON c.CategoryCode = cp.CategoryCode;
    END
END
GO

-- =============================================
-- Account Path Triggers
-- =============================================

-- trg_Accounts_UpdatePath: Update account path on insert/update
CREATE OR ALTER TRIGGER dbo.trg_Accounts_UpdatePath
ON dbo.tblAccounts
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(AccountNameAr) OR UPDATE(ParentAccountCode)
    BEGIN
        ;WITH AccountPath AS (
            SELECT AccountCode, AccountNameAr, ParentAccountCode, 
                   CAST('/' + AccountNameAr AS NVARCHAR(MAX)) AS FullPath,
                   1 AS Level
            FROM inserted
            WHERE ParentAccountCode IS NULL
            
            UNION ALL
            
            SELECT a.AccountCode, a.AccountNameAr, a.ParentAccountCode,
                   ap.FullPath + '/' + a.AccountNameAr,
                   ap.Level + 1
            FROM dbo.tblAccounts a
            INNER JOIN AccountPath ap ON a.ParentAccountCode = ap.AccountCode
        )
        UPDATE a
        SET AccountPath = ap.FullPath,
            AccountLevel = ap.Level
        FROM dbo.tblAccounts a
        INNER JOIN AccountPath ap ON a.AccountCode = ap.AccountCode;
    END
END
GO

PRINT 'Database Triggers created successfully.';
GO

-- ============================================================
-- SECTION 13: REFERENCE DATA (البيانات المرجعية)
-- ============================================================
PRINT '';

PRINT '========================================';

PRINT 'SECTION 13: Inserting Reference Data...';

PRINT '========================================';

-- =============================================
-- System Configuration
-- =============================================

-- tblSystemSettings (if exists)
-- INSERT INTO dbo.tblSystemSettings (SettingKey, SettingValue, Description)
-- VALUES ('DEFAULT_CURRENCY', 'SAR', 'العملة الافتراضية');

-- =============================================
-- Branches
-- =============================================
INSERT INTO
    dbo.tblBranches (
        BranchID,
        BranchNameAr,
        BranchNameEn,
        BranchType,
        IsMainBranch,
        IsActive,
        Address,
        City,
        Country,
        TaxNumber
    )
VALUES (
        'BR001',
        'المقر الرئيسي',
        'Main Branch',
        'HEADQUARTER',
        1,
        1,
        'الرياض',
        'الرياض',
        'السعودية',
        '310000000000003'
    ),
    (
        'BR002',
        'فرع جدة',
        'Jeddah Branch',
        'BRANCH',
        0,
        1,
        'جدة',
        'جدة',
        'السعودية',
        '310000000000004'
    ),
    (
        'BR003',
        'فرع الدمام',
        'Dammam Branch',
        'BRANCH',
        0,
        1,
        'الدمام',
        'الدمام',
        'السعودية',
        '310000000000005'
    );

-- =============================================
-- Currencies
-- =============================================
INSERT INTO
    dbo.tblCurrencies (
        CurrencyCode,
        CurrencyID,
        CurrencyNameAr,
        CurrencyNameEn,
        CurrencySymbol,
        BuyRate,
        SellRate,
        RateDate,
        IsBaseCurrency,
        DecimalPlaces,
        IsActive
    )
VALUES (
        1,
        'SAR',
        'ريال سعودي',
        'Saudi Riyal',
        'ر.س',
        1,
        1,
        GETDATE (),
        1,
        2,
        1
    ),
    (
        2,
        'USD',
        'دولار أمريكي',
        'US Dollar',
        '$',
        3.75,
        3.76,
        GETDATE (),
        0,
        2,
        1
    ),
    (
        3,
        'EUR',
        'يورو',
        'Euro',
        '€',
        4.10,
        4.15,
        GETDATE (),
        0,
        2,
        1
    ),
    (
        4,
        'AED',
        'درهم إماراتي',
        'UAE Dirham',
        'د.إ',
        1.02,
        1.03,
        GETDATE (),
        0,
        2,
        1
    ),
    (
        5,
        'EGP',
        'جنيه مصري',
        'Egyptian Pound',
        'ج.م',
        0.12,
        0.12,
        GETDATE (),
        0,
        2,
        1
    );

-- =============================================
-- Banks
-- =============================================
INSERT INTO
    dbo.tblBanks (
        BankID,
        BankNameAr,
        BankNameEn,
        SwiftCode,
        IsActive
    )
VALUES (
        'SABB',
        'البنك السعودي البريطاني',
        'SABB',
        'SABBSA RI',
        1
    ),
    (
        'SNB',
        'البنك الأهلي',
        'National Commercial Bank',
        'NCBKSA RI',
        1
    ),
    (
        'RJHI',
        'بنك الراجحي',
        'Al Rajhi Bank',
        'RJHISARI',
        1
    ),
    (
        'BSF',
        'بنك الرياض',
        'Riyadh Bank',
        'RJHISARI',
        1
    ),
    (
        'BAM',
        'بنك الإنماء',
        'Al Inma Bank',
        'INMASARI',
        1
    ),
    (
        'AIB',
        'بنك الرياض',
        'Arab Investment Bank',
        'AIBKSARI',
        1
    ),
    (
        'CBI',
        'بنك المدينة',
        'Banque Saudi Fransi',
        'BSFRSARI',
        1
    );

-- =============================================
-- Payment Methods
-- =============================================
INSERT INTO
    dbo.tblPaymentMethods (
        PaymentMethodID,
        MethodNameAr,
        MethodNameEn,
        MethodType,
        AccountCode,
        IsActive,
        SortOrder
    )
VALUES (
        'CASH',
        'نقدي',
        'Cash',
        'CASH',
        NULL,
        1,
        1
    ),
    (
        'BANK_TRANSFER',
        'تحويل بنكي',
        'Bank Transfer',
        'BANK',
        NULL,
        1,
        2
    ),
    (
        'CHECK',
        'شيك',
        'Check',
        'CHECK',
        NULL,
        1,
        3
    ),
    (
        'CREDIT_CARD',
        'بطاقة ائتمان',
        'Credit Card',
        'CARD',
        NULL,
        1,
        4
    ),
    (
        'DEBIT_CARD',
        'بطاقة مدين',
        'Debit Card',
        'CARD',
        NULL,
        1,
        5
    ),
    (
        'MADA',
        'مدى',
        'Mada',
        'CARD',
        NULL,
        1,
        6
    ),
    (
        'POST_PAY',
        'آجل',
        'Credit/Terms',
        'CREDIT',
        NULL,
        1,
        7
    );

-- =============================================
-- Funds
-- =============================================
INSERT INTO
    dbo.tblFunds (
        FundID,
        FundNameAr,
        FundNameEn,
        FundType,
        IsDefault,
        IsActive,
        Notes
    )
VALUES (
        'CASH_MAIN',
        'الصندوق الرئيسي',
        'Main Cash',
        'CASH',
        1,
        1,
        'الصندوق الرئيسي للمقر'
    ),
    (
        'CASH_JEDDAH',
        'صندوق جدة',
        'Jeddah Cash',
        'CASH',
        0,
        1,
        'صندوق فرع جدة'
    ),
    (
        'BANK_SABB',
        'بنك ساب',
        'SABB Account',
        'BANK',
        0,
        1,
        'حساب بنك ساب الرئيسي'
    ),
    (
        'BANK_SNB',
        'بنك الأهلي',
        'NCB Account',
        'BANK',
        0,
        1,
        'حساب بنك الأهلي'
    );

-- =============================================
-- Chart of Accounts (Basic Structure)
-- =============================================

-- Level 1: Root Accounts
INSERT INTO
    dbo.tblAccounts (
        AccountID,
        AccountNameAr,
        AccountNameEn,
        AccountType,
        AccountNature,
        IsMainAccount,
        AccountLevel,
        IsPostable,
        IsActive
    )
VALUES (
        '1',
        'الأصول',
        'Assets',
        'ASSET',
        'Debit',
        1,
        1,
        0,
        1
    ),
    (
        '2',
        'الخصوم',
        'Liabilities',
        'LIABILITY',
        'Credit',
        1,
        1,
        0,
        1
    ),
    (
        '3',
        'حقوق الملكية',
        'Equity',
        'EQUITY',
        'Credit',
        1,
        1,
        0,
        1
    ),
    (
        '4',
        'الإيرادات',
        'Revenue',
        'REVENUE',
        'Credit',
        1,
        1,
        0,
        1
    ),
    (
        '5',
        'المصروفات',
        'Expenses',
        'EXPENSE',
        'Debit',
        1,
        1,
        0,
        1
    );

-- Level 2: Main Categories
INSERT INTO
    dbo.tblAccounts (
        AccountID,
        AccountNameAr,
        AccountNameEn,
        AccountType,
        AccountNature,
        ParentAccountCode,
        IsMainAccount,
        AccountLevel,
        IsPostable,
        IsActive
    )
VALUES
    -- Assets
    (
        '1-1',
        'الأصول المتداولة',
        'Current Assets',
        'ASSET',
        'Debit',
        1,
        1,
        2,
        0,
        1
    ),
    (
        '1-2',
        'الأصول غير المتداولة',
        'Non-Current Assets',
        'ASSET',
        'Debit',
        1,
        1,
        2,
        0,
        1
    ),
    -- Liabilities
    (
        '2-1',
        'الخصوم المتداولة',
        'Current Liabilities',
        'LIABILITY',
        'Credit',
        2,
        1,
        2,
        0,
        1
    ),
    (
        '2-2',
        'الخصوم غير المتداولة',
        'Non-Current Liabilities',
        'LIABILITY',
        'Credit',
        2,
        1,
        2,
        0,
        1
    ),
    -- Equity
    (
        '3-1',
        'رأس المال',
        'Capital',
        'EQUITY',
        'Credit',
        3,
        1,
        2,
        0,
        1
    ),
    (
        '3-2',
        'الأرباح المحتجزة',
        'Retained Earnings',
        'EQUITY',
        'Credit',
        3,
        1,
        2,
        0,
        1
    ),
    -- Revenue
    (
        '4-1',
        'إيرادات المبيعات',
        'Sales Revenue',
        'REVENUE',
        'Credit',
        4,
        1,
        2,
        0,
        1
    ),
    (
        '4-2',
        'إيرادات أخرى',
        'Other Revenue',
        'REVENUE',
        'Credit',
        4,
        1,
        2,
        0,
        1
    ),
    -- Expenses
    (
        '5-1',
        'تكلفة البضاعة المباعة',
        'Cost of Goods Sold',
        'EXPENSE',
        'Debit',
        5,
        1,
        2,
        0,
        1
    ),
    (
        '5-2',
        'المصروفات التشغيلية',
        'Operating Expenses',
        'EXPENSE',
        'Debit',
        5,
        1,
        2,
        0,
        1
    );

-- Level 3: Detailed Accounts (Postable)
INSERT INTO
    dbo.tblAccounts (
        AccountID,
        AccountNameAr,
        AccountNameEn,
        AccountType,
        AccountNature,
        ParentAccountCode,
        IsMainAccount,
        AccountLevel,
        IsPostable,
        IsActive
    )
VALUES
    -- Cash & Banks
    (
        '1-1-001',
        'الصندوق',
        'Cash',
        'ASSET',
        'Debit',
        (
            SELECT AccountCode
            FROM dbo.tblAccounts
            WHERE
                AccountID = '1-1'
        ),
        0,
        3,
        1,
        1
    ),
    (
        '1-1-002',
        'البنك',
        'Bank Account',
        'ASSET',
        'Debit',
        (
            SELECT AccountCode
            FROM dbo.tblAccounts
            WHERE
                AccountID = '1-1'
        ),
        0,
        3,
        1,
        1
    ),
    (
        '1-1-003',
        'العملاء',
        'Accounts Receivable',
        'ASSET',
        'Debit',
        (
            SELECT AccountCode
            FROM dbo.tblAccounts
            WHERE
                AccountID = '1-1'
        ),
        0,
        3,
        1,
        1
    ),
    (
        '1-1-004',
        'مخزون البضاعة',
        'Inventory',
        'ASSET',
        'Debit',
        (
            SELECT AccountCode
            FROM dbo.tblAccounts
            WHERE
                AccountID = '1-1'
        ),
        0,
        3,
        1,
        1
    ),
    (
        '1-1-005',
        'المدينون',
        'Debtors',
        'ASSET',
        'Debit',
        (
            SELECT AccountCode
            FROM dbo.tblAccounts
            WHERE
                AccountID = '1-1'
        ),
        0,
        3,
        1,
        1
    ),
    (
        '1-1-006',
        'ضريبة القيمة المضافة المستحقة',
        'VAT Receivable',
        'ASSET',
        'Debit',
        (
            SELECT AccountCode
            FROM dbo.tblAccounts
            WHERE
                AccountID = '1-1'
        ),
        0,
        3,
        1,
        1
    ),
    -- Fixed Assets
    (
        '1-2-001',
        'الأصول الثابتة',
        'Fixed Assets',
        'ASSET',
        'Debit',
        (
            SELECT AccountCode
            FROM dbo.tblAccounts
            WHERE
                AccountID = '1-2'
        ),
        0,
        3,
        1,
        1
    ),
    (
        '1-2-002',
        'الإهلاك المتراكم',
        'Accumulated Depreciation',
        'ASSET',
        'Credit',
        (
            SELECT AccountCode
            FROM dbo.tblAccounts
            WHERE
                AccountID = '1-2'
        ),
        0,
        3,
        1,
        1
    ),
    -- Suppliers
    (
        '2-1-001',
        'الموردين',
        'Accounts Payable',
        'LIABILITY',
        'Credit',
        (
            SELECT AccountCode
            FROM dbo.tblAccounts
            WHERE
                AccountID = '2-1'
        ),
        0,
        3,
        1,
        1
    ),
    (
        '2-1-002',
        'ضريبة القيمة المضافة مستحقة',
        'VAT Payable',
        'LIABILITY',
        'Credit',
        (
            SELECT AccountCode
            FROM dbo.tblAccounts
            WHERE
                AccountID = '2-1'
        ),
        0,
        3,
        1,
        1
    ),
    (
        '2-1-003',
        'مصروفات مستحقة',
        'Accrued Expenses',
        'LIABILITY',
        'Credit',
        (
            SELECT AccountCode
            FROM dbo.tblAccounts
            WHERE
                AccountID = '2-1'
        ),
        0,
        3,
        1,
        1
    ),
    (
        '2-1-004',
        'رواتب مستحقة',
        'Accrued Salaries',
        'LIABILITY',
        'Credit',
        (
            SELECT AccountCode
            FROM dbo.tblAccounts
            WHERE
                AccountID = '2-1'
        ),
        0,
        3,
        1,
        1
    ),
    -- Capital
    (
        '3-1-001',
        'رأس المال المدفوع',
        'Paid Capital',
        'EQUITY',
        'Credit',
        (
            SELECT AccountCode
            FROM dbo.tblAccounts
            WHERE
                AccountID = '3-1'
        ),
        0,
        3,
        1,
        1
    ),
    -- Sales
    (
        '4-1-001',
        'مبيعات المنتجات',
        'Product Sales',
        'REVENUE',
        'Credit',
        (
            SELECT AccountCode
            FROM dbo.tblAccounts
            WHERE
                AccountID = '4-1'
        ),
        0,
        3,
        1,
        1
    ),
    (
        '4-1-002',
        'مبيعات الخدمات',
        'Service Sales',
        'REVENUE',
        'Credit',
        (
            SELECT AccountCode
            FROM dbo.tblAccounts
            WHERE
                AccountID = '4-1'
        ),
        0,
        3,
        1,
        1
    ),
    (
        '4-1-003',
        'خصم المبيعات',
        'Sales Discount',
        'REVENUE',
        'Debit',
        (
            SELECT AccountCode
            FROM dbo.tblAccounts
            WHERE
                AccountID = '4-1'
        ),
        0,
        3,
        1,
        1
    ),
    -- Cost of Sales
    (
        '5-1-001',
        'تكلفة البضاعة المباعة',
        'Cost of Goods Sold',
        'EXPENSE',
        'Debit',
        (
            SELECT AccountCode
            FROM dbo.tblAccounts
            WHERE
                AccountID = '5-1'
        ),
        0,
        3,
        1,
        1
    ),
    (
        '5-1-002',
        'خصم المشتريات',
        'Purchase Discount',
        'EXPENSE',
        'Credit',
        (
            SELECT AccountCode
            FROM dbo.tblAccounts
            WHERE
                AccountID = '5-1'
        ),
        0,
        3,
        1,
        1
    ),
    -- Operating Expenses
    (
        '5-2-001',
        'رواتب ومزايا',
        'Salaries & Benefits',
        'EXPENSE',
        'Debit',
        (
            SELECT AccountCode
            FROM dbo.tblAccounts
            WHERE
                AccountID = '5-2'
        ),
        0,
        3,
        1,
        1
    ),
    (
        '5-2-002',
        'الايجارات',
        'Rent',
        'EXPENSE',
        'Debit',
        (
            SELECT AccountCode
            FROM dbo.tblAccounts
            WHERE
                AccountID = '5-2'
        ),
        0,
        3,
        1,
        1
    ),
    (
        '5-2-003',
        'المصاريف العمومية',
        'General Expenses',
        'EXPENSE',
        'Debit',
        (
            SELECT AccountCode
            FROM dbo.tblAccounts
            WHERE
                AccountID = '5-2'
        ),
        0,
        3,
        1,
        1
    ),
    (
        '5-2-004',
        'إهلاك الأصول',
        'Depreciation',
        'EXPENSE',
        'Debit',
        (
            SELECT AccountCode
            FROM dbo.tblAccounts
            WHERE
                AccountID = '5-2'
        ),
        0,
        3,
        1,
        1
    ),
    (
        '5-2-005',
        'مصاريف مالية',
        'Financial Expenses',
        'EXPENSE',
        'Debit',
        (
            SELECT AccountCode
            FROM dbo.tblAccounts
            WHERE
                AccountID = '5-2'
        ),
        0,
        3,
        1,
        1
    );

-- =============================================
-- Units
-- =============================================
INSERT INTO
    dbo.tblUnits (
        UnitID,
        UnitNameAr,
        UnitNameEn,
        UnitSymbol,
        UnitType,
        IsBaseUnit,
        IsActive,
        DecimalPlaces,
        SortOrder
    )
VALUES (
        'PCS',
        'قطعة',
        'Piece',
        'قطعة',
        'QUANTITY',
        1,
        1,
        0,
        1
    ),
    (
        'BOX',
        'علبة',
        'Box',
        'علبة',
        'QUANTITY',
        0,
        1,
        0,
        2
    ),
    (
        'KG',
        'كيلوغرام',
        'Kilogram',
        'كجم',
        'WEIGHT',
        1,
        1,
        2,
        3
    ),
    (
        'G',
        'غرام',
        'Gram',
        'جم',
        'WEIGHT',
        0,
        1,
        2,
        4
    ),
    (
        'L',
        'لتر',
        'Liter',
        'لتر',
        'VOLUME',
        1,
        1,
        2,
        5
    ),
    (
        'ML',
        'ميلليلتر',
        'Milliliter',
        'مل',
        'VOLUME',
        0,
        1,
        0,
        6
    ),
    (
        'M',
        'متر',
        'Meter',
        'م',
        'LENGTH',
        1,
        1,
        2,
        7
    ),
    (
        'CM',
        'سنتيمتر',
        'Centimeter',
        'سم',
        'LENGTH',
        0,
        1,
        0,
        8
    ),
    (
        'SET',
        'طقم',
        'Set',
        'طقم',
        'QUANTITY',
        0,
        1,
        0,
        9
    ),
    (
        'DOZ',
        'دزينة',
        'Dozen',
        'دز',
        'QUANTITY',
        0,
        1,
        0,
        10
    ),
    (
        'PACK',
        'حزمة',
        'Pack',
        'حزمة',
        'QUANTITY',
        0,
        1,
        0,
        11
    ),
    (
        'ROLL',
        'لفة',
        'Roll',
        'لفة',
        'QUANTITY',
        0,
        1,
        0,
        12
    );

-- =============================================
-- Categories
-- =============================================
INSERT INTO
    dbo.tblCategories (
        CategoryID,
        CategoryNameAr,
        CategoryNameEn,
        CategoryType,
        IsActive,
        IsSystem,
        SortOrder
    )
VALUES (
        'CAT_P',
        'المنتجات',
        'Products',
        'PRODUCT',
        1,
        1,
        1
    ),
    (
        'CAT_S',
        'الخدمات',
        'Services',
        'SERVICE',
        1,
        1,
        2
    ),
    (
        'CAT_E',
        'مستلزمات',
        'Supplies',
        'PRODUCT',
        1,
        0,
        3
    ),
    (
        'CAT_SP',
        'قطع الغيار',
        'Spare Parts',
        'PRODUCT',
        1,
        0,
        4
    );

-- =============================================
-- Payment Terms
-- =============================================
INSERT INTO
    dbo.tblPaymentTerms (
        TermID,
        TermNameAr,
        TermNameEn,
        TermType,
        NetDays,
        DiscountPercent,
        DiscountDays,
        IsActive,
        IsDefault
    )
VALUES (
        'CASH',
        'نقدي',
        'Cash',
        'CASH',
        0,
        0,
        0,
        1,
        0
    ),
    (
        'NET15',
        '15 يوم',
        'Net 15',
        'DUE_DAYS',
        15,
        0,
        0,
        1,
        0
    ),
    (
        'NET30',
        '30 يوم',
        'Net 30',
        'DUE_DAYS',
        30,
        0,
        0,
        1,
        1
    ),
    (
        'NET45',
        '45 يوم',
        'Net 45',
        'DUE_DAYS',
        45,
        0,
        0,
        1,
        0
    ),
    (
        'NET60',
        '60 يوم',
        'Net 60',
        'DUE_DAYS',
        60,
        0,
        0,
        1,
        0
    ),
    (
        'NET90',
        '90 يوم',
        'Net 90',
        'DUE_DAYS',
        90,
        0,
        0,
        1,
        0
    ),
    (
        '2_10',
        '2/10 نات 30',
        '2/10 Net 30',
        'DUE_DAYS',
        30,
        2,
        10,
        1,
        0
    );

-- =============================================
-- Price Lists
-- =============================================
INSERT INTO
    dbo.tblPriceLists (
        PriceListID,
        PriceListNameAr,
        PriceListNameEn,
        PriceListType,
        CurrencyCode,
        IsActive,
        IsDefault
    )
VALUES (
        'SALE',
        'سعر البيع',
        'Sales Price',
        'SALE',
        'SAR',
        1,
        1
    ),
    (
        'WHOLESALE',
        'سعر الجملة',
        'Wholesale Price',
        'SALE',
        'SAR',
        1,
        0
    ),
    (
        'COST',
        'سعر التكلفة',
        'Cost Price',
        'COST',
        'SAR',
        1,
        0
    );

-- =============================================
-- Windows (System Windows)
-- =============================================
INSERT INTO
    dbo.tblWindows (
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
        'النظام الرئيسي',
        'Main System',
        'System',
        'frmMain',
        1,
        0
    ),
    (
        'SYS_USERS',
        'إدارة المستخدمين',
        'User Management',
        'System',
        'frmUsers',
        1,
        1
    ),
    (
        'SYS_ROLES',
        'إدارة الأدوار',
        'Role Management',
        'System',
        'frmRoles',
        1,
        2
    ),
    (
        'SYS_PRIVILEGES',
        'الصلاحيات',
        'Privileges',
        'System',
        'frmPrivileges',
        1,
        3
    ),
    (
        'SYS_SETTINGS',
        'الإعدادات',
        'Settings',
        'System',
        'frmSettings',
        1,
        4
    ),
    (
        'SYS_BACKUP',
        'النسخ الاحتياطي',
        'Backup',
        'System',
        'frmBackup',
        1,
        5
    ),
    (
        'ACC_ACCOUNTS',
        'خطة الحسابات',
        'Chart of Accounts',
        'Accounting',
        'frmAccounts',
        1,
        10
    ),
    (
        'ACC_JOURNAL',
        'القيود اليومية',
        'Journal Entries',
        'Accounting',
        'frmJournal',
        1,
        11
    ),
    (
        'ACC_BONDS',
        'السندات',
        'Vouchers',
        'Accounting',
        'frmBonds',
        1,
        12
    ),
    (
        'ACC_REPORTS',
        'التقارير المحاسبية',
        'Accounting Reports',
        'Accounting',
        'frmAccReports',
        1,
        13
    ),
    (
        'INV_STORES',
        'المخازن',
        'Stores',
        'Inventory',
        'frmStores',
        1,
        20
    ),
    (
        'INV_PRODUCTS',
        'المنتجات',
        'Products',
        'Inventory',
        'frmProducts',
        1,
        21
    ),
    (
        'INV_STOCK',
        'المخزون',
        'Stock',
        'Inventory',
        'frmStock',
        1,
        22
    ),
    (
        'INV_MOVEMENT',
        'حركات المخزون',
        'Stock Movement',
        'Inventory',
        'frmStockMovement',
        1,
        23
    ),
    (
        'SALES',
        'المبيعات',
        'Sales',
        'Sales',
        'frmSales',
        1,
        30
    ),
    (
        'PURCHASES',
        'المشتريات',
        'Purchases',
        'Purchases',
        'frmPurchases',
        1,
        40
    ),
    (
        'CUSTOMERS',
        'العملاء',
        'Customers',
        'Sales',
        'frmCustomers',
        1,
        31
    ),
    (
        'SUPPLIERS',
        'الموردين',
        'Suppliers',
        'Purchases',
        'frmSuppliers',
        1,
        41
    );

-- =============================================
-- User Roles
-- =============================================
INSERT INTO
    dbo.tblUserRoles (
        RoleID,
        RoleNameAr,
        RoleNameEn,
        RoleType,
        IsActive,
        IsSystem,
        Notes
    )
VALUES (
        'ADMIN',
        'مدير النظام',
        'System Administrator',
        'ADMIN',
        1,
        1,
        'صلاحيات كاملة'
    ),
    (
        'MANAGER',
        'مدير',
        'Manager',
        'MANAGER',
        1,
        1,
        'صلاحيات إدارية'
    ),
    (
        'ACCOUNTANT',
        'محاسب',
        'Accountant',
        'USER',
        1,
        0,
        'صلاحيات محاسبية'
    ),
    (
        'SALES',
        'مندوب مبيعات',
        'Sales Representative',
        'USER',
        1,
        0,
        'صلاحيات مبيعات'
    ),
    (
        'STORE',
        'أمين مخزن',
        'Store Keeper',
        'USER',
        1,
        0,
        'صلاحيات مخازن'
    );

-- =============================================
-- Create Default Admin User (Password: Admin@123)
-- Note: In production, use proper password hashing
-- =============================================

DECLARE @Salt VARBINARY(8000) = CAST(
    'DefaultSalt123' AS VARBINARY(8000)
);

DECLARE @PasswordHash VARBINARY(8000);

-- PBKDF2-SHA256 hash of 'Admin@123' with salt (simplified for demo)
SET
    @PasswordHash = CAST(
        'Admin@123' AS VARBINARY(8000)
    );

INSERT INTO
    dbo.tblUsers (
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
        'مدير النظام',
        'System Administrator',
        'admin@company.com',
        '0500000000',
        @PasswordHash,
        @Salt,
        1,
        1,
        1,
        GETDATE ()
    );

-- Assign Admin role to admin user
DECLARE @AdminUserCode INT = SCOPE_IDENTITY ();

DECLARE @AdminRoleID INT = (
    SELECT RoleID
    FROM dbo.tblUserRoles
    WHERE
        RoleID = 'ADMIN'
);

INSERT INTO
    dbo.tblUserRoleAssignments (
        UserCode,
        RoleID,
        IsActive,
        CreatedAt
    )
VALUES (
        @AdminUserCode,
        @AdminRoleID,
        1,
        GETDATE ()
    );

-- Grant all privileges to Admin role
INSERT INTO
    dbo.tblPrivileges (
        RoleID,
        WindowID,
        CanDisplay,
        CanAdd,
        CanEdit,
        CanDelete,
        CanPrint,
        CanExport,
        CanApprove,
        CanPost,
        IsActive
    )
SELECT
    @AdminRoleID,
    WindowID,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1
FROM dbo.tblWindows;

-- Grant Manager role to admin user
DECLARE @ManagerRoleID INT = (
    SELECT RoleID
    FROM dbo.tblUserRoles
    WHERE
        RoleID = 'MANAGER'
);

INSERT INTO
    dbo.tblUserRoleAssignments (
        UserCode,
        RoleID,
        IsActive,
        CreatedAt
    )
VALUES (
        @AdminUserCode,
        @ManagerRoleID,
        1,
        GETDATE ()
    );

-- Grant all privileges to Manager role
INSERT INTO
    dbo.tblPrivileges (
        RoleID,
        WindowID,
        CanDisplay,
        CanAdd,
        CanEdit,
        CanDelete,
        CanPrint,
        CanExport,
        CanApprove,
        CanPost,
        IsActive
    )
SELECT
    @ManagerRoleID,
    WindowID,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1
FROM dbo.tblWindows;

PRINT '';

PRINT '========================================';

PRINT 'Reference Data inserted successfully.';

PRINT '========================================';

-- ============================================================
-- FINAL: Print Summary
-- ============================================================
PRINT '';

PRINT '========================================';

PRINT 'INTEGRATED ACCOUNTS SYSTEM';

PRINT 'Database Creation Complete!';

PRINT '========================================';

PRINT '';

PRINT 'Tables Created:';

PRINT '  - Security: Users, Sessions, Privileges, Windows, AuditLogs';

PRINT '  - System: Branches, Currencies, Banks, PaymentMethods, Funds';

PRINT '  - Accounting: Accounts, CostCenters, BondHeader, BondBody, JournalHeader, JournalBody';

PRINT '  - Inventory: Stores, Categories, Units, Products, ProductBatches, ProductMovement, ProductPricing, StoreProducts';

PRINT '  - Transactions: Customers, Suppliers, OperationHeader, OperationBody, PriceLists, PaymentTerms';

PRINT '';

PRINT 'Views Created:';

PRINT '  - vw_ActiveUsers, vw_AccountHierarchy, vw_ProductStockSummary';

PRINT ' - vw_CustomerList, vw_SupplierList, vw_SalesSummary';

PRINT ' - vw_JournalEntries, vw_BondEntries, vw_PendingOperations';

PRINT '';

PRINT 'Stored Procedures Created:';

PRINT ' - User Management: sp_Login, sp_Logout, sp_ValidateSession';

PRINT ' - Product: sp_GetProductStock, sp_SearchProducts';

PRINT ' - Financial: sp_GetAccountBalance, sp_GetTrialBalance';

PRINT ' - Reports: sp_GetCustomerStatement, sp_GetSalesSummary';

PRINT '';

PRINT 'Functions Created:';

PRINT ' - fn_GetAccountFullPath, fn_GetProductStock';

PRINT ' - fn_GetAccountBalance, fn_IsUserHasPrivilege';

PRINT '';

PRINT 'Triggers Created:';

PRINT ' - Audit, Stock Management, Balance Updates';

PRINT ' - Category/Account Path Updates';

PRINT '';

PRINT 'Default Admin User:';

PRINT ' - UserID: ADMIN';

PRINT ' - Password: Admin@123 (Please change on first login!)';

PRINT '';

PRINT '========================================';

PRINT '';
GO