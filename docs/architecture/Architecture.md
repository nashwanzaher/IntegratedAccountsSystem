# IntegratedAccountsSystem - Architecture Documentation

**Version:** 2.0.0 (PostgreSQL)  
**Date:** 2026-06-08  
**Framework:** .NET 8 WinForms | 3-Tier Architecture

---

## 1. Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER (PL)                      │
│  WinForms UI (28 forms)                                         │
│  • frmMain, frmLogin, frmUsers, frmChartOfAccounts, frmJournal │
│  • frmSalesBill, frmPurchasesBill, frmBonds, frmCategories    │
│  • All forms call BL methods only — no direct DB access       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    BUSINESS LAYER (BL)                         │
│  Domain logic + parameter preparation (13 C# files)           │
│  • BL/Users/clsUsers.cs       — Login 3-tier auth + privileges │
│  • BL/Accounts/clsAccounts.cs — Chart of accounts CRUD         │
│  • BL/Journal/clsjournal.cs  — Journal entries CRUD           │
│  • BL/Stores/clsInventory.cs — Inventory management            │
│  • BL/Security/AuditHelper.cs — Audit logging (fire-and-forget)│
│  • BL/Security/PasswordHelper.cs — PBKDF2-SHA256 hashing      │
│  All use: NpgsqlParameter[] (migrated from SqlParameter)       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    DATA ACCESS LAYER (DAL)                      │
│  PostgreSQL access via Npgsql (migrated from SqlClient)         │
│  • clsCN.cs              — Connection wrapper (IDisposable)    │
│  • DbContext.cs          — Transaction support (Begin/Commit)  │
│  • DbContextProvider.cs   — Thread-safe singleton context        │
│  Connection string from App.config (Properties.Settings)       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    DATABASE (PostgreSQL 17)                    │
│  37 tables │ 8 views │ 16 functions │ 4 procedures │ 4 triggers│
│  • Security domain: Users, Sessions, Privileges, AuditLogs    │
│  • Configuration: Branches, Currencies, Banks, Funds          │
│  • Accounting: Accounts, Journal, Bonds                         │
│  • Inventory: Products, Stores, Batches, Movements              │
│  • Transactions: Customers, Suppliers, Operations               │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. 3-Tier Architecture Details

### Presentation Layer (PL)

**Location:** `D:\source\IntegratedAccountsSystem\PL\`

| Folder | Forms | Purpose |
|---|---|---|
| `Accounts/` | 7 | Chart of accounts, trial balance, final accounts, account sheet |
| `Bonds/` | 1 | Receipt/Payment vouchers |
| `Journal/` | 2 | Journal entries, posting/unposting |
| `Purchases/` | 4 | Purchase bills, returns, suppliers |
| `Sales/` | 4 | Sales bills, returns, customers |
| `stores/` | 7 | Categories, units, stores, products, inventory movement |
| `SysFormat/` | 8 | Companies, banks, currencies, funds, backups, VAT settings |
| `Users/` | 3 | Login, privileges, user management |
| `Reports/` | 1 | Report viewer (RDLC) |

**Key pattern:** Every form calls BL classes. No direct `using System.Data.SqlClient` or `using Npgsql`. ✅ Zero direct DB access.

### Business Layer (BL)

**Location:** `D:\source\IntegratedAccountsSystem\BL\`

| File | SLOC | Responsibility |
|---|---|---|
| `Constants.cs` | 161 | Operation/Bond/Report type constants + enums |
| `Users/clsUsers.cs` | 495 | 3-tier login (PBKDF2/SHA256/Plaintext), user CRUD, ApplyPrivileges() |
| `Accounts/clsAccounts.cs` | 225 | Account CRUD, hierarchy, search |
| `Journal/clsjournal.cs` | 233 | Journal CRUD, post/unpost |
| `Bonds/clsBonds.cs` | 175 | Bond CRUD |
| `Stores/clsInventory.cs` | 494 | Products, categories, stores, batches, stock, pricing |
| `SysFormat/clsSysFormat.cs` | 357 | Companies, banks, currencies, funds, branches, payment terms |
| `Security/AuditHelper.cs` | 203 | Fire-and-forget async audit logging |
| `Security/PasswordHelper.cs` | 140 | PBKDF2-SHA256 + legacy SHA256 hashing |
| `Security/PrivilegeHelper.cs` | 94 | Privilege resolution |
| `Security/SessionContext.cs` | 214 | Session state container |
| `Purchases/clsPurchases.cs` | 83 | Purchase bill operations |
| `Sales/clsSales.cs` | 85 | Sales bill operations |

**Parameter migration:** 606 `SqlParameter` → `NpgsqlParameter` (2026-06-08)

### Data Access Layer (DAL)

**Location:** `D:\source\IntegratedAccountsSystem\DAL\`

| File | Responsibility |
|---|---|
| `clsCN.cs` | Connection wrapper with `SelectData(string, NpgsqlParameter[])` and `ExecuteCmd(string, NpgsqlParameter[])`. SQL injection validation built-in. IDisposable pattern. |
| `DbContext.cs` | Transaction support with `BeginTransaction/CommitTransaction/RollbackTransaction`. Raw SQL validation. |
| `DbContextProvider.cs` | Thread-safe singleton for connection pooling. Reference counting for cleanup. |

---

## 3. Database Schema

### 3.1 Security Domain (5 tables)

```
tblUsers ─────────┐
  ├── tblUserRoles (many-to-many via tblUserRoleAssignments)
  ├── tblPrivileges (UserCode + WindowID → permissions)
  ├── tblSessions (token-based, 8-hour expiry)
  └── tblAuditLogs (comprehensive event trail)

tblWindows (hierarchical window definitions for privilege system)
```

**Key columns in tblUsers:**

- `UserCode` (PK), `UserID` (unique), `UserPassword` (BYTEA), `Salt` (BYTEA)
- `IsAdmin`, `IsActive`, `IsOnline`
- `PasswordLastChanged`, `PasswordHistory1/2` (BYTEA)
- `LoginAttempts`, `LockedUntil` (lockout: 5 fails → 30 min)

**Key columns in tblSessions:**

- `SessionToken` (UUID, unique), `UserCode` (FK), `ExpiresAt`, `IsActive`
- `MachineName`, `IPAddress`, `MacAddress`

### 3.2 Configuration Domain (7 tables)

`tblBranches` → multi-branch support  
`tblCompanies` → company settings  
`tblCurrencies` → exchange rates (ExchangeRate column)  
`tblBanks` → bank accounts  
`tblFunds` → cash/bank funds  
`tblCostCenters` → cost center hierarchy  
`tblPaymentMethods` → CASH/BANK/CHECK/CARD/CREDIT  
`tblPaymentTerms` → Net 15/30/45/60/90 etc.  
`tblPriceLists` → sales/wholesale/cost pricing

### 3.3 Accounting Domain (5 tables)

```
tblAccounts (hierarchical: ParentAccountCode self-reference)
  ├── AccountType: ASSET / LIABILITY / EQUITY / REVENUE / EXPENSE
  ├── AccountNature: Debit / Credit
  └── IsPostable: controls whether leaf accounts can receive transactions

tblJournalHeader ←→ tblJournalBody (1:N)
tblBondHeader ←→ tblBondBody (1:N)
```

### 3.4 Inventory Domain (7 tables)

```
tblCategories (hierarchical: ParentCategoryCode)
tblUnits
tblStores (FK → tblBranches)
tblProducts (FK → tblCategories, tblUnits)
  ├── IsInventoryItem
  ├── MinStockLevel, MaxStockLevel, ReorderLevel
  └── StandardCost, LastPurchasePrice, LastSalePrice

tblProductBatches
tblStoreProducts (StoreCode + ProductCode + BatchID → UNIQUE)
  ├── QtyOnHand, QtyReserved
  ├── AvgCost, LastCost
  └── Generated column: AvailableCredit (for customers/suppliers)

tblProductPricing
tblProductMovement
```

### 3.5 Transaction Domain (7 tables)

```
tblCustomers (FK → tblBranches, tblPriceLists, tblPaymentTerms)
  └── Generated column: AvailableCredit = CreditLimit - CurrentCredit

tblSuppliers (FK → tblBranches, tblPaymentTerms)
  └── Generated column: AvailableCredit = CreditLimit - CurrentCredit

tblOperationHeader (SALE/PURCHASE/SALE_RETURN/PURCHASE_RETURN)
  ├── SubTotal, DiscountPercent, DiscountAmount
  ├── TaxAmount (VAT)
  ├── AdditionalCharges, Total, PaidAmount, RemainingAmount
  └── IsPosted, IsCancelled

tblOperationBody ←→ tblOperationHeader (1:N)
tblOperationTaxes ←→ tblOperationHeader (1:N)
```

---

## 4. Key Flows

### 4.1 Login Flow

```
frmLogin → BL.Users.clsUsers.Login(userID, PWD)
  → DAL.clsCN.SelectData("getUserForLogin", params)
  → PostgreSQL: sp_Login_Result() function
  → 3-tier password verification:
     1. PBKDF2-SHA256 (new)
     2. Legacy SHA-256 (phase 1 migration)
     3. Plaintext (legacy, flagged via AuditHelper)
  → Create session: INSERT INTO tblSessions (gen_random_uuid())
  → Update tblUsers.IsOnline = TRUE
  → Return DataTable with user row
  → frmMainWindow loads with session context
```

### 4.2 Sales Bill Flow

```
frmSalesBill → BL.Sales.clsSales.addSale(...)
  → DAL.clsCN.ExecuteCmd("addSale", NpgsqlParameter[])
  → PostgreSQL: INSERT INTO tblOperationHeader
  → INSERT INTO tblOperationBody (one row per line item)
  → UPDATE tblStoreProducts (QtyOnHand decrease)
  → INSERT INTO tblProductMovement (OUT movement)
  → Journal entry auto-generated (via trigger or SP)
  → AuditHelper.Log(...) async
```

### 4.3 Journal Posting Flow

```
frmJournal → BL.Journal.clsjournal.postJournal(journalCode)
  → DAL.clsCN.Open()
  → DAL.clsCN.BeginTransaction()
  → UPDATE tblJournalHeader SET IsPosted = TRUE
  → UPDATE tblAccounts SET CurrentBalance (via trigger or manual)
  → DAL.clsCN.CommitTransaction()
  → AuditHelper.Log(...)
```

---

## 5. Stored Procedures & Functions

### Core Procedures (PostgreSQL)

| Name | Type | Purpose |
|---|---|---|
| `sp_Login` | PROCEDURE | Creates session, returns token |
| `sp_Login_Result` | FUNCTION | Returns (IsValid, Token, UserCode) as table |
| `sp_Logout` | PROCEDURE | Ends session |
| `sp_ValidateSession` | PROCEDURE | Check + refresh token expiry |
| `sp_GetProductStock` | FUNCTION | Stock levels per store |
| `sp_GetLowStockProducts` | FUNCTION | Products below reorder level |
| `sp_ExpireOldSessions` | PROCEDURE | Cleanup expired sessions |

### Key Functions

| Name | Returns | Purpose |
|---|---|---|
| `fn_GetAccountFullPath` | TEXT | Hierarchical account path (e.g., "الأصول > الأصول المتداولة > الصندوق") |
| `fn_GetCategoryFullPath` | TEXT | Hierarchical category path |
| `fn_GetProductStock` | NUMERIC(18,4) | Current stock quantity |
| `fn_GetAccountBalance` | NUMERIC(18,4) | Debit - Credit balance |
| `fn_CalculateVat` | NUMERIC(18,4) | Amount * VAT% / 100 |
| `fn_GetCustomerBalance` | NUMERIC(18,4) | Customer outstanding balance |
| `fn_GetSupplierBalance` | NUMERIC(18,4) | Supplier outstanding balance |
| `fn_IsUserHasPrivilege` | BOOLEAN | RBAC privilege check |
| `fn_GenerateOperationNo` | VARCHAR(30) | Generates OperationID (INV-2606-00001, etc.) |

---

## 6. Security Architecture

```
┌────────────────────────────────────────────────┐
│              Authentication (3-tier)            │
│                                              │
│  Tier 1: PBKDF2-SHA256 (100K iterations)     │
│    PasswordHelper.CreatePasswordRecord()      │
│    PasswordHelper.Verify()                     │
│                                              │
│  Tier 2: Legacy SHA-256 (flagged for migrate)│
│    PasswordHelper.VerifyLegacySha256()        │
│                                              │
│  Tier 3: Plaintext (SECURITY WARNING logged) │
│    AuditHelper.LogSecurityWarning()           │
└────────────────────────────────────────────────┘

┌────────────────────────────────────────────────┐
│              Session Management                │
│                                              │
│  • UUID tokens (gen_random_uuid())           │
│  • 8-hour expiry (ExpiresAt)                 │
│  • 5 failed attempts → 30 min lockout        │
│  • IsOnline flag on tblUsers                  │
│  • Auto-cleanup via sp_ExpireOldSessions     │
└────────────────────────────────────────────────┘

┌────────────────────────────────────────────────┐
│              Privilege System (RBAC)           │
│                                              │
│  tblWindows (WindowCode, ModuleName, Form)   │
│  tblPrivileges (CanDisplay/Add/Edit/Delete/  │
│                    Print/Export/Approve/Post) │
│  tblUserRoles (ADMIN/MANAGER/ACCOUNTANT/...) │
│  tblUserRoleAssignments                      │
│  ApplyPrivileges(Form, WindowID) in UI        │
└────────────────────────────────────────────────┘
```

---

## 7. Connection & Transaction Management

```
App.config
  └─ Properties.Settings.Default
       ├─ Mode: "SQL" (PostgreSQL)
       ├─ Server: "localhost"
       ├─ Port: "5432"
       ├─ DB: "IntegratedAccSys"
       ├─ ID: "postgres"
       └─ PWD: "..."

clsCN (per-call open/close, stateless)
  └─ NpgsqlConnection (from connection string)

DbContext (explicit transaction support)
  ├─ BeginTransaction()
  ├─ CommitTransaction()
  └─ RollbackTransaction()

DbContextProvider (thread-safe singleton)
  └─ Instance.Execute(ctx => ...)
```

---

## 8. Build & Run

```powershell
dotnet restore
dotnet build
dotnet run
# or open IntegratedAccSys.sln in Visual Studio 2022
```

**Default credentials:** `UserID: ADMIN | Password: Admin@123`

---

**Author:** IntegratedAccSys Team  
**Last Updated:** 2026-06-08
