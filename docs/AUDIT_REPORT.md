# 🔍 Complete Project Traceability Audit Report

**Project:** Integrated Accounts System (IntegratedAccSys)
**Date:** 2026-06-08
**Auditor:** Solution-wide traceability analysis
**Scope:** PL → BL → DAL → PostgreSQL (entire call chain)
**Status:** ⚠️ **PASSED WITH FINDINGS**

---

## 1. Executive Summary

| Domain | Status | Notes |
|--------|:------:|-------|
| **Build Integrity** | ✅ PASS | 0 Errors |
| **Solution Structure** | ✅ PASS | 4 projects, proper folders |
| **Project References** | ✅ PASS | PL → BL → DAL only |
| **Package References** | ✅ PASS | No unused/redundant packages |
| **Namespaces** | ✅ PASS | Aligned with project paths |
| **PL → BL → DAL flow** | ✅ PASS | No cross-layer violations |
| **WinForms + Tier Pattern** | ✅ PASS | Preserved |
| **PostgreSQL Connectivity (DAL)** | ✅ PASS | All 11 DbTest checks passed |
| **BL → Database Coverage** | ⚠️ **CRITICAL FINDING** | 110 SPs called but only 4 defined |
| **Dead Code** | ⚠️ FINDING | 1 dead method, 6 possibly orphan Forms |
| **Duplicate Code** | ⚠️ FINDING | SP `getScreensPrivillages` called from 3 files |
| **Hidden Dependencies** | ⚠️ FINDING | DbTest implicit dependency on DAL config |

---

## 2. Execution Flow Trace

### 2.1 Program Entry Point → Login

```
┌─────────────────────────────────────────────────────┐
│ Program.Main (src/IntegratedAccSys.PL/Program.cs:13)  │
│   • ApplicationConfiguration.Initialize()            │
│   • Application.Run(new PL.Users.frmLogin())         │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│ frmLogin (PL/Users/frmLogin.cs)                      │
│   • btnLogin_Click → BL.Users.clsUsers.Login()       │
│   • Sets Program.userName, Program.braCode           │
│   • Calls SessionContext.Create() (BL.Security)      │
│   • Opens frmMainWindow                              │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│ frmMainWindow (PL/frmMainWindow.cs)                  │
│   • getScreensDisplayPrivs()                        │
│     → BL.Users.clsUsers.getUserNo() (call 1)         │
│     → BL.Users.clsUsers.getDisplayPrivillages()      │
│   • Menu items open Forms                           │
└─────────────────────────────────────────────────────┘
```

### 2.2 Form → BL → DAL → PostgreSQL

```
[Form: frmChartOfAccounts]                            ─── PL
   → BL.Accounts.clsAccounts (instantiated in frm)    ─── BL
      → cn.SelectData("getListOfAccounts", params)     ─── BL→DAL
         → clsCN.SelectData()                          ─── DAL
            → NpgsqlCommand("getListOfAccounts", ...)  ─── DAL→PG
               → PostgreSQL stored procedure            ─── PG
```

### 2.3 PrivilegeApplier Flow (UI Logic)

```
[Form: frmChartOfAccounts.Load]
   → PrivilegeApplier.Apply(this, 14)
      → BL.Users.clsUsers.getUserNo(Program.userName, Program.braCode)
         → cn.SelectData("getUserNo", ...)
      → BL.Users.clsUsers.getScreensPrivillages(userCode, 14, braCode)
         → cn.SelectData("getScreensPrivillages", ...)
      → ApplyButton(form, "btnNew", row, "privNew")
         [UI control manipulation - PL]
```

---

## 3. Layer-by-Layer Inventory

### 3.1 Presentation Layer (PL) — `src/IntegratedAccSys.PL/`

| Metric | Count |
|--------|-------|
| Forms (.cs files) | **38** |
| Designer files | 38 |
| Resource (.resx) files | 38 |
| RDLC reports | 9 |
| Forms with `PrivilegeApplier.Apply()` | **18 of 38** (47%) |
| Forms with no privilege call | 20 |
| Forms with 0 BL classes used | 4 (`frmReportViewer`, `frmAccountsJoin`, `frmConnSettings`, `frmVATSettings`) |

#### Possibly Orphan Forms (not opened by other forms)

| Form | Reason |
|------|--------|
| `frmAccSheetReport` | Account sheet report — may be opened via menu (not detected) |
| `frmChartOfAccountsDoc` | Document viewer — likely opened from frmChartOfAccounts |
| `frmSelectSupplier` | Selection dialog — likely opened by purchase forms |
| `frmReportViewer` | Generic report viewer — likely opened from various contexts |
| `frmSelectCusromer` | Selection dialog (note typo: "Cusromer") — likely from sales forms |
| `frmSelectItem` | Selection dialog — likely from inventory forms |

**Status:** Most "orphan" Forms are likely opened dynamically (passed by name, instantiated via reflection, or opened from Form events not detected by static analysis). They should be manually verified.

### 3.2 Business Logic Layer (BL) — `src/IntegratedAccSys.BL/`

| Class | Stored Procedure Calls | File |
|-------|----------------------:|------|
| `clsAccounts` | 0 (only table-style queries — needs verification) | `Accounts/clsAccounts.cs` |
| `clsBonds` | 12 | `Bonds/clsBonds.cs` |
| `clsjournal` ⚠️ (lowercase 'j') | 14 | `Journal/clsjournal.cs` |
| `clsPurchases` | 4 | `Purchases/clsPurchases.cs` |
| `clsSales` | 4 | `Sales/clsSales.cs` |
| `clsInventory` | 28 | `Stores/clsInventory.cs` |
| `clsSysFormat` | 20 | `SysFormat/clsSysFormat.cs` |
| `clsUsers` | 18 | `Users/clsUsers.cs` |
| `SessionContext` (Security) | 5 | `Security/SessionContext.cs` |
| `AuditHelper` (Security) | 1 | `Security/AuditHelper.cs` |
| `PrivilegeHelper` (Security) | 1 | `Security/PrivilegeHelper.cs` |
| `PasswordHelper` (Security) | 0 (pure crypto) | `Security/PasswordHelper.cs` |
| **Total unique SPs called from BL** | **110** | (all BL files) |

### 3.3 Data Access Layer (DAL) — `src/IntegratedAccSys.DAL/`

| Class | Method | Description |
|-------|--------|-------------|
| `clsCN` | `Open()`, `Close()`, `SelectData(sp, para)`, `SelectData(query)`, `ExecuteCmd(sp, para)`, `ExecuteCmd(query)` | Connection lifecycle, SP/Raw SQL exec |
| `DbContext` | `Open()`, `Close()`, `BeginTransaction()`, `CommitTransaction()`, `RollbackTransaction()`, `SelectData()`, `Execute()`, `ExecuteScalar()`, `ExecuteRawSql()` | Modern API with transactions |
| `DbContextProvider` | `Instance`, `GetContext()`, `Release()`, `Execute<T>()` | Thread-safe singleton |
| `DalSettings` | `Mode`, `Server`, `Port`, `DB`, `ID`, `PWD` | Config from env vars + AppSettings |

### 3.4 Database — `database/`

| Object Type | Count | Names |
|-------------|------:|-------|
| **FUNCTIONS** | 14 | `fn_GetAccountFullPath`, `fn_GetCategoryFullPath`, `fn_GetProductStock`, `fn_GetAccountBalance`, `fn_CalculateVat`, `fn_GetCustomerBalance`, `fn_GetSupplierBalance`, `fn_IsUserHasPrivilege`, `sp_Login_Result`, `sp_GetProductStock`, `sp_GetLowStockProducts`, `trg_fn_Users_Update`, `trg_fn_StoreProducts_Update`, `trg_fn_AuditLogs_Insert`, `fn_GenerateOperationNo` |
| **PROCEDURES** | 4 | `sp_Login`, `sp_Logout`, `sp_ValidateSession`, `sp_ExpireOldSessions` |
| **TRIGGERS** | 3 | `trg_AuditLogs_Insert`, `trg_StoreProducts_Update`, `trg_Users_Update` |
| **VIEWS** | 11 | `vw_ActiveUsers`, `vw_AccountHierarchy`, `vw_ProductStockSummary`, `vw_CustomerList`, `vw_SupplierList`, `vw_SalesSummary`, `vw_PurchaseSummary`, `vw_JournalEntries`, `vw_BondEntries`, `vw_ProductMovementSummary`, `vw_PendingOperations` |
| **TOTAL** | **32** | |

---

## 4. ⚠️ CRITICAL FINDING: BL → DB Coverage Gap

### 4.1 The Problem

The BL layer calls **110 unique stored procedures** but the PostgreSQL database only defines **4 procedures** (+ 14 functions + 3 triggers + 11 views = 32 objects).

```
BL SP Calls:  110
DB Objects:    32  (4 procedures + 14 functions + 3 triggers + 11 views)
                          ─────
GAP:         ~78  SPs have no corresponding PostgreSQL object
```

### 4.2 Examples of Missing SPs

The following SPs are called from BL but NOT defined in PostgreSQL:

- `addBank`, `addBondBody`, `addBondHeader`, `addCategories`, `addCompany`, `addCurrency`
- `addCustomers`, `addFund`, `addJournalBody`, `addJournalHeader`, `addOperationBody`, `addOperationHdr`
- `addPrivillages`, `addProduct`, `addProductMovement`, `addStore`, `addSuppleir`, `addUnit`, `addUser`
- `delBank`, `delBond`, `delBondBody`, `delCategories`, `delCompany`, `delCurrency`, `delCustomer`
- `delFund`, `delJournalbody`, `delJournalEntry`, `delPrivellages`, `delProduct`, `delStore`, `delSupplier`
- `delUnite`, `delUser`, `doBondPosting`
- `editBillBondHeader`, `editBondHeader`, `editCategories`, `editCustomers`, `editJournalHeader`
- `editPrivillages`, `editProduct`, `editStore`, `editSuppliers`, `editUnit`
- `getAccFundCode`, `getAllBanks`, `getAllBranches`, `getAllBraUsers`, `getAllCurrencies`, `getAllCurrenciesTypes`
- `getAllCustomers`, `getAllCutegories`, `getAllFunds`, `getAllLists`, `getAllPaymentMethods`
- `getAllPrivillages`, `getAllProducts`, `getAllStores`, `getAllSuppliers`, `getAllUnits`
- `getBillOrBondNewNo`, `getBranchData`, `getCategoryData`, `getConversionFactor`, `getDisplayPrivillages`
- `getExchangeCurrency`, `getFundCode`, `getInventoryMovement`, `getMaxBondNo`, `getMaximumBillBondNo`
- `getMaximumJno`, `getMinBondNo`, `getMinimumBillBondNo`, `getMinimumJno`, `GetNewBondNo`, `getNewBranchNo`
- `getNewJournalNo`, `getPostingBonds`, `getProductData`, `getProductsInventory`, `getUserForLogin`
- `getUserNewNo`, `getUserNo`, `searchInCustomers`, `searchInSuppliers`, `setBondIsPost`
- `showBillBondBody`, `showBillBondHeader`, `showBondBody`, `showBondHeader`
- `showJournalBody`, `showJournalHeader`, `updateBank`, `updateCompany`, `updateCurrency`
- `updateFund`, `updateProductData`, `updateUser`, `upgradeUserPassword`
- `backupDB`, `restoreDB`

### 4.3 Root Cause

The codebase was originally written for **SQL Server** (legacy `.bak` file confirms this). The PostgreSQL migration added the schema (tables), some functions, and 4 authentication-related procedures — but did **not** port the application-level stored procedures (CRUD operations, business workflow procs).

### 4.4 Risk

🔴 **HIGH SEVERITY** — The application will fail at runtime with "procedure does not exist" errors as soon as any user attempts a CRUD operation (login aside). The DbTest only verifies connectivity, not these operations.

### 4.5 Recommended Actions

| # | Action | Priority |
|---|--------|:--------:|
| 1 | Either (a) create the missing ~78 stored procedures in PostgreSQL, OR (b) refactor the BL layer to use raw SQL / functions / views instead of stored procedures | 🔴 P0 |
| 2 | Use SQL Server's `sp_helptext` and pgAdmin to extract SP definitions from the original `.bak` and port to PostgreSQL | 🟡 P1 |
| 3 | Add integration tests in `tests/IntegratedAccSys.DAL.DbTest` (or a new test project) that exercise every CRUD SP to detect this gap before runtime | 🟡 P1 |
| 4 | Consider migrating to an ORM (Dapper / EF Core) to reduce the SP surface area | 🟢 P2 |

---

## 5. Findings

### 5.1 Dead Code

| Type | Location | Status |
|------|----------|:------:|
| `CheckIfConnectionSettingsExist()` | `src/IntegratedAccSys.PL/Program.cs:26` | 🟡 Defined but never called anywhere |
| `frmReportViewer` (no BL usage, no PrivilegeApply) | `src/IntegratedAccSys.PL/Reports/frmReportViewer.cs` | 🟡 Probably opened dynamically by report name |
| 6 "orphan" Forms | Various | 🟡 Most likely opened dynamically — manual verification needed |

### 5.2 Duplicate Code

| Pattern | Locations | Count |
|---------|-----------|:-----:|
| `cn.SelectData("getScreensPrivillages", ...)` | `BL/Security/PrivilegeHelper.cs`, `BL/Users/clsUsers.cs` | 2 |
| `cn.SelectData("getUserNo", ...)` | `BL/Users/clsUsers.cs` | 2 |

**Risk:** Low — different parameter signatures, but identical business intent. Could be refactored into a shared method, but not a critical violation.

### 5.3 Hidden Dependencies

| Hidden Dependency | Location | Evidence |
|--------------------|----------|----------|
| `DbContextProvider` is a singleton that wraps `DbContext` | `src/IntegratedAccSys.DAL/DbContextProvider.cs:13` | BUT — no other code in the solution actually uses `DbContextProvider.Instance`; all BL code uses `new clsCN()` directly |
| `DbContext.GetConnectionString()` reads from `ConfigurationManager.ConnectionStrings["MyDB"]` | `src/IntegratedAccSys.DAL/DbContext.cs:119` | Fallback to inline hardcoded connection (lines 121–122) — **smell**: hardcoded credentials in code |
| `clsCN` reads from `DalSettings` | `src/IntegratedAccSys.DAL/clsCN.cs:19` | ✅ Clean dependency on DAL config |
| `DbTest` implicitly depends on `DalSettings` env vars | `tests/IntegratedAccSys.DAL.DbTest/Program.cs` | ✅ Works because default values point to localhost |

### 5.4 Orphan Database Objects (DB-side, no BL calls)

| DB Object | Type | Called from BL? |
|-----------|------|:--------------:|
| `fn_GetAccountFullPath` | FUNCTION | ❌ NOT called |
| `fn_GetCategoryFullPath` | FUNCTION | ❌ NOT called |
| `fn_GetProductStock` | FUNCTION | ❌ NOT called |
| `fn_GetAccountBalance` | FUNCTION | ❌ NOT called |
| `fn_CalculateVat` | FUNCTION | ❌ NOT called |
| `fn_GetCustomerBalance` | FUNCTION | ❌ NOT called |
| `fn_GetSupplierBalance` | FUNCTION | ❌ NOT called |
| `fn_IsUserHasPrivilege` | FUNCTION | ❌ NOT called |
| `sp_Login_Result` | FUNCTION | ❌ NOT called |
| `sp_GetProductStock` | FUNCTION | ❌ NOT called |
| `sp_GetLowStockProducts` | FUNCTION | ❌ NOT called |
| `fn_GenerateOperationNo` | FUNCTION | ❌ NOT called |
| `trg_AuditLogs_Insert` | TRIGGER | implicit (auto-fired) |
| `trg_StoreProducts_Update` | TRIGGER | implicit (auto-fired) |
| `trg_Users_Update` | TRIGGER | implicit (auto-fired) |
| `vw_ActiveUsers` | VIEW | ❌ NOT called |
| `vw_AccountHierarchy` | VIEW | ❌ NOT called |
| `vw_ProductStockSummary` | VIEW | ❌ NOT called |
| `vw_CustomerList` | VIEW | ❌ NOT called |
| `vw_SupplierList` | VIEW | ❌ NOT called |
| `vw_SalesSummary` | VIEW | ❌ NOT called |
| `vw_PurchaseSummary` | VIEW | ❌ NOT called |
| `vw_JournalEntries` | VIEW | ❌ NOT called |
| `vw_BondEntries` | VIEW | ❌ NOT called |
| `vw_ProductMovementSummary` | VIEW | ❌ NOT called |
| `vw_PendingOperations` | VIEW | ❌ NOT called |

**Finding:** The 11 views and 12 of the 14 functions are defined in PostgreSQL but never referenced from the C# code. The triggers are auto-fired by the database engine, so they are not orphan.

---

## 6. Code Quality Observations

| Observation | Location | Risk |
|-------------|----------|:----:|
| Class name `clsjournal` (lowercase 'j') | `src/IntegratedAccSys.BL/Journal/clsjournal.cs:15` | 🟡 Inconsistent naming (warning CS8981) |
| `private` constructor + `public` method `GetNewBondNo` (uppercase G) | `BL/Bonds/clsBonds.cs` | 🟡 Inconsistent naming |
| `frmSelectCusromer` (typo: "Cusromer") | `src/IntegratedAccSys.PL/Sales/frmSelectCusromer.cs` | 🟡 Should be `frmSelectCustomer` |
| `frmInvventroy` (typo: extra 'v') | `src/IntegratedAccSys.PL/Stores/frmInvventroy.cs` | 🟡 Should be `frmInventory` |
| 61 nullable-reference warnings (CS8625, CS8602, etc.) | Various | 🟡 Pre-existing; non-architectural |
| 4 duplicate `using` directives | `BL/Journal/clsjournal.cs:10`, `BL/Sales/clsSales.cs:4` | 🟢 Trivial |

---

## 7. Architectural Boundary Validation

### 7.1 Project References

```
IntegratedAccSys.PL          ──refs──>  IntegratedAccSys.BL       ✅
IntegratedAccSys.BL          ──refs──>  IntegratedAccSys.DAL      ✅
IntegratedAccSys.DAL.DbTest  ──refs──>  IntegratedAccSys.DAL      ✅
IntegratedAccSys.DAL         (no refs)                            ✅
```

### 7.2 Cross-Layer Class References (findstr audit)

| Check | Result |
|-------|:------:|
| PL files referencing `IntegratedAccSys.DAL` | ✅ NONE |
| BL files referencing `IntegratedAccSys.PL` | ✅ NONE |
| DAL files referencing `IntegratedAccSys.BL` | ✅ NONE |
| DAL files referencing `IntegratedAccSys.PL` | ✅ NONE |
| BL files referencing `System.Windows.Forms` | ✅ NONE |

**Verdict:** Architectural boundaries are clean.

---

## 8. Package Reference Validation

| Project | Required Packages | Unused? | Redundant? |
|---------|------------------|:-------:|:----------:|
| `IntegratedAccSys.DAL` | Npgsql 8.0.4, ConfigurationManager 8.0.1 | ❌ Used | ✅ Clean |
| `IntegratedAccSys.BL` | (none) | — | ✅ Clean |
| `IntegratedAccSys.PL` | ReportViewerCore.WinForms 15.1.26 | ❌ Used | ✅ Clean |
| `IntegratedAccSys.DAL.DbTest` | (uses transitive Npgsql) | — | ✅ Clean |

**Verdict:** No unused or redundant packages. All package references are minimal and justified.

---

## 9. Risk Summary

| # | Risk | Severity | Action Required |
|---|------|:---------:|------------------|
| R1 | BL calls ~78 SPs that don't exist in PostgreSQL | 🔴 CRITICAL | Create the missing SPs OR refactor BL to use functions/views |
| R2 | 1 dead method (`CheckIfConnectionSettingsExist`) | 🟡 LOW | Remove or use it |
| R3 | 6 "orphan" Forms (probably reachable dynamically) | 🟡 LOW | Manual verification |
| R4 | 11 views + 12 functions never called from C# | 🟡 MEDIUM | Either use them in BL or remove from DB schema |
| R5 | `clsjournal` lowercase naming | 🟡 LOW | Rename to `ClsJournal` or `Journal` |
| R6 | Hardcoded credentials fallback in `DbContext.GetConnectionString` | 🟡 MEDIUM | Move to `DalSettings` or require App.config |
| R7 | Form name typos (`frmSelectCusromer`, `frmInvventroy`) | 🟢 LOW | Rename for clarity |
| R8 | 61 nullable-reference warnings | 🟡 LOW | Address gradually |
| R9 | `DbContextProvider` not used by any BL code (dead provider) | 🟡 LOW | Use it from BL or remove |

---

## 10. Required Actions (Priority Order)

| Priority | Action | Owner | Target |
|---------:|---------|:------:|--------|
| **P0** | Address R1: port missing SPs to PostgreSQL OR refactor BL | — | Sprint 1 |
| **P1** | Address R6: remove hardcoded credential fallback | — | Sprint 1 |
| **P1** | Address R4: use DB views/functions or remove from schema | — | Sprint 2 |
| **P2** | Address R2, R3, R5, R7, R9 (cleanup) | — | Sprint 3 |
| **P3** | Address R8 (nullable warnings) | — | Ongoing |

---

## 11. WinForms + Tier Architecture Compliance

| Requirement | Compliance | Evidence |
|-------------|:-----------:|----------|
| WinForms for UI | ✅ | `<UseWindowsForms>true</UseWindowsForms>` in PL csproj |
| 3-Tier Architecture (PL, BL, DAL) | ✅ | 3 source projects + 1 test project |
| PL → BL → DAL flow | ✅ | No inversions detected |
| PL = Forms, Reports, User Interaction | ✅ | 38 Forms, 9 RDLC reports |
| BL = Business Rules, Validation, Workflows | ✅ | Validation, CRUD orchestration, security helpers |
| DAL = Data Access Only | ✅ | Npgsql, SP wrappers, transactions |
| Database = Tables, Views, Functions, Procedures, Triggers | ✅ | 37 tables + 11 views + 14 fns + 4 SPs + 3 triggers |
| Npgsql for PostgreSQL | ✅ | Npgsql 8.0.4 |
| RDLC / ReportViewer | ✅ | ReportViewerCore.WinForms 15.1.26 |
| .NET 8 | ✅ | All csproj: `net8.0*` |

**Verdict:** WinForms + Tier Architecture pattern is **preserved exactly as required**.

---

## 12. Conclusions

✅ **Architectural integrity:** WinForms + Tier Architecture is correctly implemented and preserved.
✅ **Build:** 0 Errors.
✅ **PostgreSQL connectivity:** Verified through DAL DbTest.
⚠️ **Runtime functionality at risk:** 78 stored procedures called from BL are missing from PostgreSQL — this is a critical gap that must be addressed before the application can perform real CRUD operations beyond authentication.
⚠️ **Code quality:** 61 nullable warnings, 1 dead method, naming inconsistencies, Form name typos — non-architectural, low severity.

**Recommendation:** Fix R1 (missing SPs) as the top priority. Once that is resolved, the application will be runtime-ready and the WinForms + Tier Architecture will be fully functional.
