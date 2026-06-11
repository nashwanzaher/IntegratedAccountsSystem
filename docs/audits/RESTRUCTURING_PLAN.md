# 🛠️ Restructuring Plan — Industry-Standard Conventions

> **Status:** Phase 1 in progress (foundations)
> **Started:** 2026-06-11
> **Owner:** Deep audit + restructuring workstream
> **Reference:** [`docs/CONVENTIONS.md`](../CONVENTIONS.md)

---

## 1. Phased Plan

| Phase | Scope | Risk | Status |
|:-----:|-------|:----:|:------:|
| **P0** | Foundations: CONVENTIONS.md, plan doc, .editorconfig, .gitignore | 🟢 Low | ✅ Done |
| **P1** | Path + file organization: `database/` casing, scripts/ subfolders, `__*` cleanup | 🟢 Low | ⏳ In progress |
| **P2** | Documentation: outdated architecture/README.md, fix broken paths | 🟢 Low | ⏳ Next |
| **P3** | Git hygiene: PR template, CODEOWNERS, Issue templates, branch-protection hints | 🟢 Low | ⏳ Pending |
| **P4** | C# class renames: `cls*` → `Service`/`Repository`; `frm*` → `Form`; touch all consumers | 🟡 Medium | ⏳ Pending confirmation |
| **P5** | DB column renames: `PascalCase`/`camelCase` → `snake_case` (e.g. `AccountCode` → `account_code`) | 🟠 High | ⏳ Pending confirmation |
| **P6** | DB object renames: `tbl*` → plural noun; `sp_*` → verb-only; `vw_*` → `v_*` | 🟠 High | ⏳ Pending confirmation |
| **P7** | Add ADRs for major decisions | 🟢 Low | ⏳ Pending |

Each phase produces **at least one atomic commit** with passing `dotnet build` + `DbTest`.

---

## 2. Phase 0 — Foundations (✅ Done)

| Item | Result |
|------|--------|
| [`docs/CONVENTIONS.md`](../CONVENTIONS.md) | 11 sections, source of truth for all rules |
| [`docs/audits/RESTRUCTURING_PLAN.md`](RESTRUCTURING_PLAN.md) | this document |
| Audit report updated | `§13 Cleanup Actions Executed` in DEEP_ARCHITECTURE_DATABASE_AUDIT.md |

---

## 3. Phase 1 — Path & File Organization (In progress)

### 3.1 Issues identified

| # | Issue | File count | Risk | Action |
|--:|-------|----------:|:----:|--------|
| 1 | Git tracks `Database/` (capital D); filesystem has `database/` (lowercase) | 31 | 🟢 Low | `git mv` to canonical lowercase |
| 2 | `scripts/` has 23 flat .ps1 + 1 .bat, no sub-folders | 24 | 🟢 Low | Group by purpose |
| 3 | `__audit_*` temp files (none currently exist, but pattern in .gitignore) | 0 | 🟢 Low | Verify .gitignore covers `__*` everywhere |
| 4 | `docs/architecture/README.md` shows **OLD paths** (`D:\source\IntegratedAccountsSystem\PL\`) | 1 | 🟢 Low | Rewrite |
| 5 | `README.md` (root) shows `Database/` (capital D) | 1 | 🟢 Low | Update to `database/` |

### 3.2 Execution order

1. `git mv Database/ database/` (fix case in Git)
2. `git mv` any other mismatched paths
3. Rewrite `docs/architecture/README.md` with correct paths
4. Update root `README.md` to use `database/`
5. Verify build + DbTest pass
6. Commit

---

## 4. Phase 2 — Documentation Refresh (Pending)

| # | Doc | Issue | Action |
|--:|-----|-------|--------|
| 1 | `docs/architecture/README.md` | References deleted paths (e.g. `D:\source\IntegratedAccountsSystem\PL\`) | Full rewrite using current layout |
| 2 | `docs/architecture/Architecture.md` | Likely outdated | Cross-check against current state |
| 3 | Root `README.md` | Mixed casing (`Database/`) | Update to `database/` |
| 4 | `docs/CHANGELOG.md` | May be stale | Verify |
| 5 | `docs/README.md` | References old structure | Update |

---

## 5. Phase 3 — Git Hygiene (Pending)

| # | Item | Action |
|--:|------|--------|
| 1 | `.github/PULL_REQUEST_TEMPLATE.md` | Create with checklist |
| 2 | `.github/ISSUE_TEMPLATE/bug_report.md` | Create |
| 3 | `.github/ISSUE_TEMPLATE/feature_request.md` | Create |
| 4 | `.github/CODEOWNERS` | List code owners per layer |
| 5 | `.editorconfig` | Add with .NET + SQL rules |
| 6 | `Directory.Build.props` | Add common MSBuild settings (nullable enable, warnings as errors) |
| 7 | `Directory.Packages.props` | Central package management |

---

## 6. Phase 4 — C# Class Renames (Pending confirmation)

### 6.1 Mapping (legacy → modern)

| Legacy file | Modern file | Legacy class | Modern class |
|-------------|------------|-------------|--------------|
| `src/IntegratedAccSys.DAL/ClsCN.cs` | `NpgsqlConnectionFactory.cs` | `DAL.ClsCN` | `NpgsqlConnectionFactory` |
| `src/IntegratedAccSys.DAL/DbContext.cs` | `NpgsqlDbContext.cs` | `DAL.DbContext` | `NpgsqlDbContext` |
| `src/IntegratedAccSys.DAL/DalSettings.cs` | `DalSettings.cs` | `DAL.DalSettings` | `DalSettings` |
| `src/IntegratedAccSys.BL/Accounts/ClsAccounts.cs` | `AccountService.cs` | `BL.Accounts.ClsAccounts` | `Accounts.AccountService` |
| `src/IntegratedAccSys.BL/Bonds/ClsBonds.cs` | `BondService.cs` | `BL.Bonds.ClsBonds` | `Bonds.BondService` |
| `src/IntegratedAccSys.BL/Journal/ClsJournal.cs` | `JournalService.cs` | `BL.Journal.Clsjournal` | `Journal.JournalService` |
| `src/IntegratedAccSys.BL/Purchases/ClsPurchases.cs` | `PurchaseService.cs` | `BL.Purchases.ClsPurchases` | `Purchases.PurchaseService` |
| `src/IntegratedAccSys.BL/Sales/ClsSales.cs` | `SalesService.cs` | `BL.Sales.ClsSales` | `Sales.SalesService` |
| `src/IntegratedAccSys.BL/Stores/ClsInventory.cs` | `InventoryService.cs` | `BL.Stores.ClsInventory` | `Stores.InventoryService` |
| `src/IntegratedAccSys.BL/SysFormat/ClsSysFormat.cs` | `SystemConfigService.cs` | `BL.SysFormat.ClsSysFormat` | `SysFormat.SystemConfigService` |
| `src/IntegratedAccSys.BL/Users/ClsUsers.cs` | `UserService.cs` | `BL.Users.ClsUsers` | `Users.UserService` |
| `src/IntegratedAccSys.BL/Dimensions/ClsDimensions.cs` | `DimensionService.cs` | `BL.Dimensions.ClsDimensions` | `Dimensions.DimensionService` |
| `src/IntegratedAccSys.BL/Security/PasswordHelper.cs` | `PasswordHasher.cs` | `BL.Security.PasswordHelper` | `Security.PasswordHasher` |
| `src/IntegratedAccSys.BL/Security/SessionContext.cs` | `SessionManager.cs` | `BL.Security.SessionContext` | `Security.SessionManager` |
| `src/IntegratedAccSys.BL/Security/AuditHelper.cs` | `AuditLogger.cs` | `BL.Security.AuditHelper` | `Security.AuditLogger` |
| `src/IntegratedAccSys.BL/Security/PrivilegeHelper.cs` | `PrivilegeChecker.cs` | `BL.Security.PrivilegeHelper` | `Security.PrivilegeChecker` |
| `src/IntegratedAccSys.DAL/Security/PiiCrypto.cs` | `PiiCrypto.cs` | `DAL.Security.PiiCrypto` | `Security.PiiCrypto` |

### 6.2 PL (Forms) mapping

| Legacy | Modern |
|--------|--------|
| `frmMainWindow.cs` | `MainForm.cs` |
| `frmLogin.cs` | `LoginForm.cs` |
| `frmChartOfAccounts.cs` | `ChartOfAccountsForm.cs` |
| `frmTrailBalance.cs` | `TrialBalanceForm.cs` |
| `frmFinalAccounts.cs` | `FinalAccountsForm.cs` |
| `frmAccSheet.cs` | `AccountSheetForm.cs` |
| `frmJournal.cs` | `JournalEntryForm.cs` |
| `frmBonds.cs` | `BondForm.cs` |
| `frmCustomers.cs` | `CustomerListForm.cs` |
| `frmSuppleirs.cs` | `SupplierListForm.cs` |
| `frmPurchasesBill.cs` | `PurchaseBillForm.cs` |
| `frmSalesBill.cs` | `SalesBillForm.cs` |
| … (38 forms total) | … |
| `PrivilegeApplier.cs` | `PrivilegeApplier.cs` (no change, already modern) |

### 6.3 Execution approach

For each class:
1. Create new file with modern name + class
2. Use IDE to "Move + Rename" (preserves git history)
3. Update all `using` statements + type references across PL/BL/DAL
4. Build → fix compile errors
5. Run DbTest
6. Atomic commit

### 6.4 Rollback plan

Git history + `git revert` per phase. Each phase is one commit.

---

## 7. Phase 5 — DB Column Renames (Pending confirmation)

### 7.1 Mapping (sample, full list generated from `pg_attribute`)

| Current (PascalCase) | Target (snake_case) |
|----------------------|---------------------|
| `BranchCode` | `branch_code` |
| `BranchNameAr` | `branch_name_ar` |
| `BranchNameEn` | `branch_name_en` |
| `UserCode` | `user_id` |
| `UserID` | `user_login_id` |
| `UserNameAr` | `user_name_ar` |
| `IsActive` | `is_active` |
| `IsAdmin` | `is_admin` |
| `CreatedAt` | `created_at` |
| `UpdatedAt` | `updated_at` |
| `LastLoginAt` | `last_login_at` |
| `PasswordHash` | `password_hash` |
| `AccountCode` | `account_code` |
| `AccountNameAr` | `account_name_ar` |
| `AccountType` | `account_type` |
| `JournalCode` | `journal_id` |
| `JournalDate` | `journal_date` |
| `TotalDebit` | `total_debit` |
| `TotalCredit` | `total_credit` |
| `IsPosted` | `is_posted` |
| … (200+ columns) | … |

### 7.2 Migration approach

For each column:
1. Add new column with target name + `GENERATED ALWAYS AS (... old col) STORED` or via data copy
2. Update views/functions/procedures/triggers to use new name
3. Drop old column

This requires per-table migrations; can be batched into one migration file per
table family.

### 7.3 Estimated effort

- 200+ columns to rename
- 300+ functions/procedures to update
- 70+ tables to migrate
- Estimated **5-10 atomic migrations** to keep build green

---

## 8. Phase 6 — DB Object Renames (Pending confirmation)

### 8.1 Table renames (sample)

| Current | Target |
|---------|--------|
| `tblUsers` | `users` |
| `tblSessions` | `sessions` |
| `tblAuditLogs` | `audit_logs` |
| `tblBranches` | `branches` |
| `tblCompanies` | `companies` |
| `tblAccounts` | `accounts` |
| `tblJournalHeader` | `journal_entries` |
| `tblJournalBody` | `journal_lines` |
| `tblBondHeader` | `bonds` |
| `tblBondBody` | `bond_lines` |
| … | … |

### 8.2 Procedure renames (sample)

| Current | Target |
|---------|--------|
| `sp_expireoldsessions` | `expire_old_sessions` |
| `sp_Login` | already removed in P0 cleanup |
| `sp_Logout` | already removed in P0 cleanup |
| `sp_ValidateSession` | already removed in P0 cleanup |
| `processexpiredrequests` | `process_expired_requests` |
| `reassignpendingapprovals` | `reassign_pending_approvals` |
| `submitforapproval` | `submit_for_approval` |
| `approveRequest` | `approve_request` |
| `cancelRequest` | `cancel_request` |
| `delegateApproval` | `delegate_approval` |
| `rejectRequest` | `reject_request` |

### 8.3 Function renames (sample)

| Current | Target |
|---------|--------|
| `getAllBranches` | `get_all_branches` |
| `getAllCustomers` | `get_all_customers` |
| `addUser` | `add_user` |
| `addAccount` | `add_account` |
| `getUserForLogin` | `get_user_for_login` |
| `fn_pii_encrypt` | `pii_encrypt` (drop `fn_` prefix) |
| `fn_calculatevat` | `calculate_vat` |
| `sp_GetProductStock` | `get_product_stock` |

### 8.4 View renames

| Current | Target |
|---------|--------|
| `vw_*` (44 views) | `v_*` (drop `w`) |
| `mv_*` (10 matviews) | keep (already snake_case) |

---

## 9. Risk Matrix

| Phase | Risk | Mitigation |
|:-----:|:----:|------------|
| P0-P3 | 🟢 Low | atomic commits, build/test green per commit |
| P4 | 🟡 Medium | One namespace/type per commit; per-layer branching |
| P5 | 🟠 High | Per-table migrations; backward-compat shim views for legacy callers |
| P6 | 🟠 High | Migration scripts with idempotency; C# callers updated atomically with each DB rename |

---

## 10. Tracking Checklist

- [x] P0 — Foundations (CONVENTIONS.md, RESTRUCTURING_PLAN.md)
- [ ] P1 — Path + file organization (database/ casing, scripts/ subfolders)
- [ ] P2 — Documentation refresh
- [ ] P3 — Git hygiene (.editorconfig, PR template, CODEOWNERS)
- [ ] P4 — C# class renames (awaiting user confirmation)
- [ ] P5 — DB column renames (awaiting user confirmation)
- [ ] P6 — DB object renames (awaiting user confirmation)
- [ ] P7 — ADRs for major decisions

---

*Last updated: 2026-06-11 — after Phase 0 completion.*
