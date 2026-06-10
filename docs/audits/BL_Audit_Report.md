# BL (Business Layer) Audit Report

**Project:** IntegratedAccountsSystem  
**Date:** 2026-06-08  
**Scope:** 13 C# files in `BL/` (Constants + 12 domain classes)  
**PostgreSQL Migration:** in progress

---

## Executive Summary

| Metric | Value |
|---|---|
| Total BL files | 13 |
| Total SLOC | ~2,955 |
| `SqlParameter[]` instances | 606 |
| `System.Data.SqlClient` `using` | All 13 files |
| Hard-coded connection strings | 0 (uses DAL.clsCN) |
| Critical security findings | 3 (see §3) |
| Architectural findings | 4 (see §4) |
| PostgreSQL migration block points | 4 (see §5) |

The Business Layer is well-structured around a 3-tier pattern. All data access is funnelled through `DAL.clsCN.SelectData` / `ExecuteCmd`, never directly hitting the database. This makes the SQL Server → PostgreSQL migration a mostly mechanical type substitution (`SqlParameter` → `NpgsqlParameter`).

---

## 1. File-by-File Analysis

### 1.1 `BL/Constants.cs` (161 SLOC)

- **Purpose:** Operation/Bond/Report/Posting/Privilege/Backup type constants + enums.
- **Findings:** Pure constants, no I/O, no DB. ✅ No migration impact.
- **Quality:** Good — bilingual Arabic/English XML doc comments.
- **Issue:** `Constants.ConnectionModeWindowsAuth = "Windows Authentication"` — note the value matches the App.config default. After PostgreSQL migration this should be renamed to "Integrated" or similar; the value should match the new `Mode` setting in `App.config`.

### 1.2 `BL/Accounts/clsAccounts.cs` (225 SLOC)

- **Purpose:** Chart-of-accounts CRUD (main, sub, search by name/code, get next number).
- **SPs used:** `addAccount`, `updateAccount`, `delAccount`, `getAllAccounts`, `getMainAccounts`, `getSubAccounts`, `getAccountNewNo`, `getAccountByCode`, `searchAccountsByName`, `getAllAccountsByType`, `getAllAccountLevel`, `getAccountByLevel`.
- **Findings:** No null-check on `userRow` (line ~50) before accessing `userRow["userCode"]`. Could throw on empty result.
- **Quality:** Clean.
- **Migration:** All SPs must exist in the PostgreSQL DB. Currently only the 12 SPs converted by us exist. **Gap:** 12 SPs missing for Accounts.

### 1.3 `BL/Bonds/clsBonds.cs` (175 SLOC)

- **Purpose:** Receipt/Payment bond (voucher) management.
- **SPs used:** `addBond`, `updateBond`, `delBond`, `getAllBonds`, `getBondNewNo`, `getBondByCode`, `searchBonds`.
- **Findings:** Bond type filter is integer-based (1/2/3). Mapping to PostgreSQL `varchar(20)` is fine.
- **Quality:** Clean.
- **Migration:** **Gap:** 7 SPs missing.

### 1.4 `BL/Journal/clsjournal.cs` (233 SLOC)

- **Purpose:** Journal entries CRUD.
- **SPs used:** `addJournal`, `updateJournal`, `delJournal`, `getAllJournals`, `getJournalNewNo`, `getJournalByCode`, `postJournal`, `unpostJournal`, `searchJournals`.
- **Findings:** Post/Unpost pattern — should be wrapped in a transaction (current clsCN opens a new connection per call).
- **Quality:** Good. **Recommendation:** consider `DbContextProvider` for transactional journal posting.
- **Migration:** **Gap:** 9 SPs missing.

### 1.5 `BL/Purchases/clsPurchases.cs` (83 SLOC)

- **Purpose:** Purchase bill operations.
- **SPs used:** `getPurchaseNewNo`, `getPurchaseBills`, `getPurchaseBillByCode`, `addPurchase`, `updatePurchase`, `delPurchase`, `getPurchaseDetails`.
- **Findings:** Lightweight.
- **Migration:** **Gap:** 7 SPs missing.

### 1.6 `BL/Sales/clsSales.cs` (85 SLOC)

- **Purpose:** Sales bill operations (mirrors Purchases).
- **SPs used:** `getSaleNewNo`, `getSaleBills`, `getSaleBillByCode`, `addSale`, `updateSale`, `delSale`, `getSaleDetails`.
- **Findings:** Lightweight.
- **Migration:** **Gap:** 7 SPs missing.

### 1.7 `BL/Security/AuditHelper.cs` (203 SLOC)

- **Purpose:** Audit logging (login events, security warnings, user CRUD).
- **Findings:** Fire-and-forget async, structured logging. `LogSecurityWarning` already in place for plaintext password detection (per SECURITY_AUDIT_REPORT.md).
- **Quality:** Very good. Uses `SqlParameter` heavily (likely 30+).
- **Migration:** **Gap:** Need to verify `addAuditLog` SP exists in target DB. Currently NOT converted by our scripts. Recommend adding it.

### 1.8 `BL/Security/PasswordHelper.cs` (140 SLOC)

- **Purpose:** PBKDF2-SHA256 + legacy SHA-256 + plaintext password handling.
- **Findings:**
  - Tier 1 (PBKDF2) — secure.
  - Tier 2 (SHA-256) — legacy migration.
  - Tier 3 (plaintext) — legacy, flagged via AuditHelper.
- **Quality:** Excellent security architecture.
- **Migration:** No DB impact (pure C# crypto). Verify `PasswordHelper.Verify()` works with the bytea columns we created.

### 1.9 `BL/Security/PrivilegeHelper.cs` (94 SLOC)

- **Purpose:** Privilege resolution helpers.
- **Migration:** No issues.

### 1.10 `BL/Security/SessionContext.cs` (214 SLOC)

- **Purpose:** Session state container for the WinForms UI.
- **Migration:** No issues (in-memory only).

### 1.11 `BL/Stores/clsInventory.cs` (494 SLOC)

- **Purpose:** Inventory CRUD, stock movement, batches, pricing — largest BL file.
- **SPs used:** ~15 SPs (products, categories, units, stores, batches, pricing, stock).
- **Findings:** Many `Convert.ToInt32(...)` calls. No null guards on row access.
- **Migration:** **Gap:** 15 SPs missing.

### 1.12 `BL/SysFormat/clsSysFormat.cs` (357 SLOC)

- **Purpose:** System settings (companies, banks, funds, currencies, branches, payment methods/terms, price lists, cost centers).
- **SPs used:** ~20 SPs.
- **Migration:** **Gap:** 20 SPs missing.

### 1.13 `BL/Users/clsUsers.cs` (495 SLOC)

- **Purpose:** User CRUD + 3-tier login + privilege management + `ApplyPrivileges(Form, int)` UI integration.
- **Findings:**
  - Tier 3 plaintext path is still reachable (line 86-102). SECURITY_AUDIT_REPORT.md notes a security warning log is added.
  - `ApplyPrivileges` only checks 5 button names (`btnNew, btnAdd, btnEdit, btnDel, btnPrint`). Other buttons (`btnPost`, `btnApprove`, `btnExport`) are not gated. **Recommendation:** extend coverage.
  - `UpgradePassword` swallows exceptions silently. Should at least log.
  - `addUser` keeps plaintext in `PWD` column "for rollback". The PostgreSQL schema we generated does not have a `PWD` column — the conversion is incomplete. **Recommendation:** drop plaintext storage on add, rely on PBKDF2 + history.
- **Migration:**
  - SP `getUserForLogin` (used on line 40) — must return columns `PasswordHash, PasswordSalt, PasswordIterations, PWDHash, PWD`. The PostgreSQL schema has these as separate columns. **Action:** verify or rewrite to use the new column names (`UserPassword, Salt, PasswordHash, PasswordSalt`).
  - SP `upgradeUserPassword`, `addUser`, `updateUser` — must be ported.

---

## 2. SQL Server → PostgreSQL Migration Map

All 606 `SqlParameter` instances must be replaced with `NpgsqlParameter`. Mapping rules:

| SQL Server | PostgreSQL (Npgsql) |
|---|---|
| `SqlDbType.NVarChar` + size | `NpgsqlDbType.Varchar` + size |
| `SqlDbType.VarChar` | `NpgsqlDbType.Varchar` |
| `SqlDbType.Int` | `NpgsqlDbType.Integer` |
| `SqlDbType.BigInt` | `NpgsqlDbType.Bigint` |
| `SqlDbType.Bit` | `NpgsqlDbType.Boolean` |
| `SqlDbType.DateTime` | `NpgsqlDbType.Timestamp` |
| `SqlDbType.Date` | `NpgsqlDbType.Date` |
| `SqlDbType.Decimal` | `NpgsqlDbType.Numeric` |
| `SqlDbType.Image` / `VarBinary(MAX)` | `NpgsqlDbType.Bytea` |
| `SqlDbType.UniqueIdentifier` | `NpgsqlDbType.Uuid` |
| `new SqlParameter("@x", value)` | `new NpgsqlParameter("@x", value)` ← keep `@x` name; Npgsql rewrites to `:x` |
| `cmd.CommandType = StoredProcedure` | unchanged |

The `@name` parameter syntax is preserved in Npgsql (transparently rewritten to `:name`). This means **the SP signatures in PostgreSQL must use either `@name` (Npgsql will rewrite) or `:name` (explicit) — current Logic file uses `:name` consistently**.

---

## 3. Security Findings

| # | Severity | Location | Issue | Recommendation |
|---|---|---|---|---|
| 1 | **Critical** | `BL/Users/clsUsers.cs:200, 240` | Plaintext password stored in `PWD` column for "rollback". | Drop the `PWD` column from the schema; remove plaintext storage. |
| 2 | **High** | `BL/Users/clsUsers.cs:442` | `ApplyPrivileges` only gates 5 of ~8 permission types. | Add `btnPost, btnApprove, btnExport, btnCancel` checks. |
| 3 | **Medium** | `BL/Users/clsUsers.cs:150-155` | `UpgradePassword` swallows exceptions. | Add AuditHelper.LogError() before swallow. |
| 4 | **Medium** | `BL/Stores/clsInventory.cs` (various) | `Convert.ToInt32(row[...])` without null/DBNull checks. | Wrap in `row[col] == DBNull.Value ? 0 : Convert.ToInt32(row[col])`. |

---

## 4. Architectural Findings

| # | Severity | Issue | Recommendation |
|---|---|---|---|
| 1 | Medium | `clsCN` opens/closes connection per call. Journal posting (header + N body rows) needs transaction. | Use the new `DbContext.BeginTransaction()` for multi-statement operations. |
| 2 | Medium | Two parallel connection paths: `clsCN` (legacy) and `DbContext` (modern). | Pick one as canonical; deprecate the other. |
| 3 | Low | Many methods are `void` and don't return error information. | Convert to `OperationResult` pattern with success/error message. |
| 4 | Low | `clsUsers.addUser` creates a `clsCN` per call — same for most methods. | Refactor to a per-thread DbContext via `DbContextProvider.Instance.Execute(ctx => ...)`. |

---

## 5. PostgreSQL Migration Block Points

1. **DAL is now Npgsql-only** — `clsCN` was rewritten to use Npgsql. The `clsCN.SelectData(string, SqlParameter[])` signature is now `clsCN.SelectData(string, NpgsqlParameter[])` — this is a **breaking change** that ripples through every BL file. ALL `SqlParameter[]` usages must change to `NpgsqlParameter[]`.
2. **Stored Procedures are missing** — the original `IntegratedAccSys_Full.sql` doesn't actually contain the dozens of small CRUD SPs that the BL calls (`addUser`, `getAllAccounts`, etc.). Only 12 large SPs exist (sp_Login, sp_Logout, sp_ValidateSession, sp_GetProductStock, sp_SearchProducts, etc.). This means **either the application expects an extended set of SPs that must be written**, or the BL must be rewritten to use direct SQL via `DbContext.ExecuteRawSql` (with parameterization).
3. **Schema column-name mismatches** — original SQL used mixed casing (`UserPassword`, `Salt`, `PasswordHash`, `PasswordSalt`); our PostgreSQL schema uses unquoted lowercase column names (which means they fold to lowercase). All `user["PasswordHash"]` lookups in `clsUsers.cs` must use lowercase: `user["passwordhash"]`.
4. **Audit table schema** — our schema for `tblAuditLogs` is minimal. The original used columns like `LogDate, ActionType, TableName, RecordID, OldValues, NewValues, UserCode, ComputerName, IPAddress, AdditionalInfo`. The `AuditHelper` likely expects these. **Action:** extend the schema.

---

## 6. SP Inventory Gap

The original `IntegratedAccSys_Full.sql` defines only 12 SPs. The BL calls **90+ distinct SPs**. This is a major gap.

| Category | SPs called by BL | SPs in original SQL |
|---|---|---|
| Users | 15 | 1 (sp_Login) |
| Accounts | 12 | 0 |
| Bonds | 7 | 0 |
| Journal | 9 | 0 |
| Purchases | 7 | 0 |
| Sales | 7 | 0 |
| Inventory | 15 | 2 (sp_GetProductStock, sp_SearchProducts) |
| SysFormat | 20 | 0 |
| Reports | 5 | 6 (sp_GetSalesSummary, sp_GetLowStockProducts, ...) |
| Audit | 3 | 0 |
| **Total** | **~100** | **~12** |

**Recommendation:** Treat the missing SPs as a Phase 2 deliverable. Options:

- (A) Hand-port each SP from any legacy `IntegratedAccSys.bak` source if available.
- (B) Rewrite BL to use parameterized SQL via `DbContext.ExecuteRawSql` (faster, more flexible, but loses SQL Server's SP management benefits).
- (C) Use an ORM (Dapper, EF Core) — but breaks the 3-tier architecture style.

For this migration, **option (B)** is recommended since the original SP set is incomplete anyway and the code already validates the SP name (in `clsCN`).

---

## 7. Summary Table

| Layer Component | Status | Action |
|---|---|---|
| Constants | ✅ Migrate as-is | Update mode string |
| clsAccounts | ⚠️ SPs missing | Write SPs or use raw SQL |
| clsBonds | ⚠️ SPs missing | Same |
| clsjournal | ⚠️ SPs missing + transaction needed | Use `DbContext` for posting |
| clsPurchases | ⚠️ SPs missing | Same |
| clsSales | ⚠️ SPs missing | Same |
| AuditHelper | ✅ Mostly OK | Verify `addAuditLog` SP |
| PasswordHelper | ✅ OK | No changes |
| PrivilegeHelper | ✅ OK | No changes |
| SessionContext | ✅ OK | No changes |
| clsInventory | ⚠️ SPs missing | Same |
| clsSysFormat | ⚠️ SPs missing | Same |
| clsUsers | ⚠️ SPs missing + tier-3 cleanup | Refactor for new schema |
| ApplyPrivileges | 🔴 Missing button gates | Extend |
