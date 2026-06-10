# Architecture Audit Report - IntegratedAccountsSystem

**Date:** 2026-06-08
**Auditor:** Mavis (MiniMax Agent Team)
**Scope:** Full development environment and project structure
**Approach:** File-system scan + code content analysis (no assumptions)

---

## 1. Solution & Project Structure

### 1.1 Single-Project Monolith

The solution has **one .csproj only**:

```
IntegratedAccSys.sln
  IntegratedAccSys.csproj   (net8.0-windows, WinForms)
    Output: WinExe
    NuGet: Npgsql 8.0.4, ReportViewerCore.WinForms 15.1.26
```

The 3-tier architecture (PL / BL / DAL) exists as **logical folders only**, not as separate compiled projects. All three layers compile into a single assembly (IntegratedAccSys.dll).

### 1.2 Physical Folder Layout

```
IntegratedAccountsSystem/
  IntegratedAccSys.csproj       (single project file)
  Program.cs                   (entry point)
  frmMainWindow.cs            (MAIN FORM IN ROOT - VIOLATION)
  accountSysDBDataSet.cs       (empty stub - 15 lines)
  accountSysDBDataSet.Designer.cs (1.08 MB - LEGACY dead)
  accountSysDBDataSet.xsd/.xsc/.xss (LEGACY dead)

  PL/                         (91 files: WinForms UI)
    Accounts/   (7 forms)
    Bonds/      (1 form)
    Journal/    (2 forms)
    Purchases/  (5 forms)
    Reports/    (1 form - DEAD CODE)
    Sales/      (5 forms)
    stores/     (8 forms)     <-- LOWERCASE namespace (Inconsistent)
    SysFormat/  (10 forms)
    Users/      (3 forms)

  BL/                         (13 files: business logic)
    Constants.cs
    Accounts/clsAccounts.cs
    Bonds/clsBonds.cs
    Journal/clsjournal.cs
    Purchases/clsPurchases.cs
    Sales/clsSales.cs
    Security/ (4 files: AuditHelper, PasswordHelper, PrivilegeHelper, SessionContext)
    Stores/clsInventory.cs
    SysFormat/clsSysFormat.cs
    Users/clsUsers.cs

  DAL/                        (3 files: actual DAL)
    clsCN.cs
    DbContext.cs
    DbContextProvider.cs

  Reports/                    (root: 15 files - mixed concerns)
    frmReportViewer.cs        (active - used by PL)
    frmReportViewer.Designer.cs
    *.rdlc                    (9 report definitions)
    Architecture_Audit_Report.md   <-- misplaced (belongs in docs/)
    Deep_Audit_Report.md          <-- misplaced (belongs in docs/)
    Microsoft_WinForms_3Tier_Audit.md  <-- misplaced (belongs in docs/)

  Database/                   (PostgreSQL - 22 files)
    IntegratedAccSys_CompleteLogic.sql (71 KB - current)
    *.sql (old SQL Server backups)
    *.txt (logs/outputs)

  Properties/                 (4 files: auto-generated)
  docs/                       (architecture docs, slides)
  CMP_Presentation/           (10 HTML slides - CMP presentation)
  .github/workflows/dotnet-desktop.yml
```

---

## 2. Findings, Violations & Gaps

### 2.1 CRITICAL - Single-Project Instead of 3 Projects

**Finding:** All three tiers (PL, BL, DAL) compile into a single DLL.

**Impact:**

- BL classes are publicly accessible from PL (no compile-time enforcement of layering)
- No project reference boundary between tiers
- Any code can `new` any class from any layer

**Remediation:** Split into 3 projects:

```
IntegratedAccSys.sln
  IntegratedAccSys.PL.csproj    (WinForms, references BL)
  IntegratedAccSys.BL.csproj    (Class Library, references DAL)
  IntegratedAccSys.DAL.csproj   (Class Library, no dependencies)
```

### 2.2 CRITICAL - Dead Code: accountSysDBDataSet (1.08 MB)

**Finding:** The following 4 files are residual from SQL Server typed-dataset era:

- `accountSysDBDataSet.cs` (15 lines, empty namespace blocks)
- `accountSysDBDataSet.Designer.cs` (1.08 MB, 19,000+ lines, 10 TableAdapters)
- `accountSysDBDataSet.xsd` (260 KB)
- `accountSysDBDataSet.xsc` (361 bytes)
- `accountSysDBDataSet.xss` (3.9 KB)

**Evidence:** `grep` for `new accountSysDBDataSet()` in PL and BL returns ZERO results. The dataset is not used anywhere in the codebase. It inflates compilation time and the DLL size.

**Remediation:** Delete all 5 files. Remove from .csproj if referenced.

### 2.3 CRITICAL - frmMainWindow in Root (Not in PL/)

**Finding:** The main application window form lives in the project root:

- `frmMainWindow.cs` (378 lines)
- `frmMainWindow.Designer.cs` (34 KB)
- `frmMainWindow.resx` (1.1 MB)
- **Namespace:** `IntegratedAccSys` (not `IntegratedAccSys.PL`)
- **Entry point:** `Program.cs` instantiates `new PL.Users.frmLogin()` but the main window is at root

**Impact:** The root namespace contains a mix of entry point (Program.cs), application state (userName, braCode), and the main form. This violates organized project structure.

**Remediation:** Move frmMainWindow.cs/.Designer.cs/.resx to `PL/` folder with namespace updated to `IntegratedAccSys.PL`.

### 2.4 HIGH - Dead/Conflicting ReportViewer Form

**Finding:** Two conflicting ReportViewer classes exist:

| File | Namespace | Lines | Status |
|------|-----------|-------|--------|
| `PL/Reports/ReportViewer.cs` | IntegratedAccSys.PL.Reports | 27 | DEAD - contains infinite recursion bug |
| `Reports/frmReportViewer.cs` | IntegratedAccSys.Reports | 137 | ACTIVE - used by 12 PL forms |

`PL/Reports/ReportViewer.cs` contains this broken code:

```csharp
public ReportViewer() {
    InitializeComponent();
    ReportViewer reportViewer = new ReportViewer();  // infinite recursion!
    reportViewer.Dock = DockStyle.Fill;
    this.Controls.Add(reportViewer);
}
```

No file in PL or BL references `IntegratedAccSys.PL.Reports.ReportViewer`. All 12 report invocations use `IntegratedAccSys.Reports.frmReportViewer`.

**Remediation:** Delete `PL/Reports/ReportViewer.cs`, `PL/Reports/ReportViewer.Designer.cs`, `PL/Reports/ReportViewer.resx`.

### 2.5 HIGH - DAL Depends on Properties.Settings (Layer Bleed)

**Finding:** `DAL/clsCN.cs` (lines 21-39) reads `Properties.Settings.Default.*` directly:

```csharp
string mode = Properties.Settings.Default.Mode ?? "SQL";
// then builds connection string from Server, DB, ID, PWD settings
```

`DAL/clsCN.cs` also has `internal sealed` visibility (correct), BUT it directly depends on `IntegratedAccSys.Properties.Settings` which is a root-level application configuration class.

**Correct pattern:** DAL should receive connection string as constructor parameter or from config file, not from a UI-layer settings class.

**Remediation:** Extract connection string to `App.config` / `web.config` and use `ConfigurationManager.ConnectionStrings`.

### 2.6 HIGH - BL Depends on Root Program State

**Finding:** 3 BL classes depend on root-level `Program` class static fields:

| File | Accesses |
|------|----------|
| `BL/Security/PrivilegeHelper.cs` | `Program.braCode`, `Program.userName` |
| `BL/Security/SessionContext.cs` | `Program.userName`, `Program.braCode` (comment: "backward compat") |
| `BL/Users/clsUsers.cs` | `Program.userName`, `Program.braCode` |

**Impact:** BL layer knows about the root Program class. This creates a hard dependency between BL and the root namespace. BL cannot be reused or unit-tested in isolation.

**Remediation:** Replace `Program.userName` / `Program.braCode` with a session context interface that BL can receive as a parameter.

### 2.7 HIGH - SqlDbType Used with NpgsqlParameter

**Finding:** `SqlDbType.Money` is used with `NpgsqlParameter` in 16 locations:

| File | Lines |
|------|-------|
| `BL/Accounts/clsAccounts.cs` | 64, 65, 66, 83, 84, 85 |
| `BL/Bonds/clsBonds.cs` | 45, 66, 70, 141 |
| `BL/Journal/clsjournal.cs` | 42, 44, 46, 68, 70, 72, 139, 141, 143 |

`SqlDbType` is from `System.Data` (SQL Server types). `NpgsqlParameter` accepts both `NpgsqlDbType` and `SqlDbType` (via implicit conversion), but `SqlDbType.Money` maps to PostgreSQL `money` type, which is deprecated. Should use `NpgsqlDbType.Money` or `NpgsqlDbType.Numeric`.

`dotnet build` produces 0 errors/warnings (conversion is implicit), but the semantic mapping is wrong.

**Remediation:** Replace all `SqlDbType.Money` with `NpgsqlDbType.Money`.

### 2.8 MEDIUM - Inconsistent Namespace Casing (stores vs Stores)

**Finding:** The `PL/stores/` folder has files with namespace `IntegratedAccSys.PL.stores` (all lowercase):

- `PL/stores/frmCategories.cs`
- `PL/stores/frmInvventroy.cs`
- `PL/stores/frmProducts.cs`
- `PL/stores/frmSelectItem.cs`
- `PL/stores/frmStores.cs`
- `PL/stores/frmUnits.cs`

All other PL folders use PascalCase: `IntegratedAccSys.PL.Accounts`, `IntegratedAccSys.PL.Users`, `IntegratedAccSys.PL.Sales`, etc.

**Impact:** Namespace inconsistency. File system and namespace naming mismatch (Windows is case-insensitive, Linux/Mac are not).

**Remediation:** Rename folder to `PL/Stores/` and update namespace in all 8 files.

### 2.9 MEDIUM - Duplicate ReportViewer Form in Two Locations

**Finding:** Two copies of the report viewer form:

| Location | Class | Namespace | Used? |
|----------|-------|----------|-------|
| `PL/Reports/ReportViewer.cs` | ReportViewer | IntegratedAccSys.PL.Reports | NO |
| `Reports/frmReportViewer.cs` | frmReportViewer | IntegratedAccSys.Reports | YES |

The active one (`Reports/frmReportViewer.cs`) contains full RDLC rendering logic with print support. The dead one (`PL/Reports/ReportViewer.cs`) is a stub with infinite recursion.

**Remediation:** Delete the dead PL/Reports copy. Keep `Reports/frmReportViewer.cs`.

### 2.10 MEDIUM - Legacy Settings Defaults (SQL Server Era)

**Finding:** `Properties/Settings.settings` and `Properties/Settings.Designer.cs` contain SQL Server legacy defaults:

- `Server = "MRGFG-32\SQLEXPRESS"`
- `DB = "accountSysDB"`
- `Mode = "Windows Authentication"`

`App.config` was correctly updated with PostgreSQL values (localhost, 5432, IntegratedAccSys, postgres), but the Settings.Designer.cs file still generates SQL Server defaults on regeneration.

**Impact:** If VS regenerates the designer file, it will overwrite settings with SQL Server values.

**Remediation:** Update `Settings.settings` to contain correct PostgreSQL defaults. Add a comment that these are user-settable at runtime.

### 2.11 MEDIUM - Misplaced Documentation in Reports/ Folder

**Finding:** `Reports/` folder (root) contains 3 documentation files that should be in `docs/`:

- `Reports/Architecture_Audit_Report.md` (19 KB)
- `Reports/Deep_Audit_Report.md` (23 KB)
- `Reports/Microsoft_WinForms_3Tier_Audit.md` (33 KB)

These pollute the reports folder which should contain only RDLC report definitions.

**Remediation:** Move to `docs/`.

### 2.12 MEDIUM - Dead Code: DbContext + DbContextProvider (Unused)

**Finding:** `DAL/DbContext.cs` and `DAL/DbContextProvider.cs` are not used by any PL or BL code. The only file that references them is `BL/Accounts/clsAccounts.cs` which uses `DbContextProvider.Instance`. Every other BL class uses `DAL.clsCN`.

**Evidence:**

- grep for `DbContext` or `DbContextProvider` in BL: 1 file (`clsAccounts.cs` only)
- grep for `clsCN` in BL: 10 files, 137 usages

`DbContext` and `DbContextProvider` appear to be a parallel DAL implementation created during migration but never completed.

**Impact:** Dead code, unnecessary DLL surface area.

**Remediation:** Either delete both files (if `clsAccounts.cs` is refactored to use `clsCN`), or complete the migration to use `DbContext`/`DbContextProvider` everywhere.

### 2.13 LOW - frmMainWindow Depends on BL Directly

**Finding:** `frmMainWindow.cs` (root) uses `using IntegratedAccSys.BL;` and instantiates:

```csharp
BL.Users.clsUsers cu = new BL.Users.clsUsers();
```

This is acceptable in WinForms but creates a direct dependency on BL from the root namespace.

### 2.14 LOW - Program.cs Unused Method

**Finding:** `Program.cs` contains a `CheckIfConnectionSettingsExist()` method (lines 26-59) that is never called. The method builds a connection string and tests it, but it is dead code.

### 2.15 LOW - Crystal Reports Reference in csproj (Unused)

**Finding:** `.csproj` line 9 contains:

```xml
<ReferencePath>C:\Program Files (x86)\SAP BusinessObjects\...\</ReferencePath>
```

This points to Crystal Reports SDK but no Crystal-related code exists in the project. This is a leftover reference.

---

## 3. Summary: Issues by Severity

| # | Severity | Issue | Files Affected |
|---|----------|-------|----------------|
| 1 | CRITICAL | Single-project (not 3 projects) | All |
| 2 | CRITICAL | Dead accountSysDBDataSet (1.08 MB) | 5 files |
| 3 | CRITICAL | frmMainWindow in root (not PL/) | 3 files |
| 4 | HIGH | Dead ReportViewer in PL/Reports (infinite recursion) | 3 files |
| 5 | HIGH | DAL depends on Properties.Settings | clsCN.cs |
| 6 | HIGH | BL depends on root Program state | 3 BL files |
| 7 | HIGH | SqlDbType.Money with NpgsqlParameter | 3 BL files, 16 locations |
| 8 | MEDIUM | Inconsistent namespace casing (stores) | 8 files |
| 9 | MEDIUM | Duplicate ReportViewer form (dead copy) | 3 files |
| 10 | MEDIUM | Legacy SQL Server settings defaults | 2 files |
| 11 | MEDIUM | Misplaced docs in Reports/ folder | 3 files |
| 12 | MEDIUM | Unused DbContext + DbContextProvider | 2 files |
| 13 | LOW | frmMainWindow root dependency on BL | frmMainWindow.cs |
| 14 | LOW | Unused Program.CheckIfConnectionSettingsExist() | Program.cs |
| 15 | LOW | Unused Crystal Reports csproj reference | IntegratedAccSys.csproj |

---

## 4. Required Restructuring Actions

### Immediate (Safe Deletions)

1. Delete `accountSysDBDataSet.cs`, `.Designer.cs`, `.xsd`, `.xsc`, `.xss`
2. Delete `PL/Reports/ReportViewer.cs`, `PL/Reports/ReportViewer.Designer.cs`, `PL/Reports/ReportViewer.resx`
3. Delete `Reports/Architecture_Audit_Report.md`, `Reports/Deep_Audit_Report.md`, `Reports/Microsoft_WinForms_3Tier_Audit.md`
4. Move the 3 doc files to `docs/`
5. Delete `Program.cs` lines 26-59 (unused `CheckIfConnectionSettingsExist`)

### Short-Term (Refactoring)

6. Move `frmMainWindow.cs/.Designer.cs/.resx` to `PL/` with namespace updated to `IntegratedAccSys.PL`
2. Rename `PL/stores/` to `PL/Stores/` and update namespace in 8 files
3. Replace all `SqlDbType.Money` with `NpgsqlDbType.Money` in 3 BL files
4. Update `Properties/Settings.settings` with correct PostgreSQL defaults

### Medium-Term (Architecture)

10. Remove `Properties.Settings` dependency from `DAL/clsCN.cs` - use `ConfigurationManager`
2. Replace `Program.userName`/`Program.braCode` references in BL with a session context interface
3. Remove unused Crystal Reports `<ReferencePath>` from `.csproj`
4. Decide on `DbContext`/`DbContextProvider` - either complete migration or delete both

### Long-Term (Full Architecture)

14. Split into 3 separate `.csproj` files: PL, BL, DAL
2. Add compile-time project reference enforcement between layers

---

## 5. What Is Correct

The audit found several things that ARE correctly implemented:

1. **Namespace alignment with folder structure** - Most PL/BL namespaces correctly mirror the physical folder hierarchy (Accounts, Users, Sales, etc.)
2. **PL does NOT use DAL directly** - All PL code goes through BL classes. grep for `clsCN` in PL returns 0 results.
3. **Security layer in BL** - AuditHelper, PasswordHelper, SessionContext, PrivilegeHelper are correctly placed in `BL/Security/`
4. **BL sub-namespaces** - Each BL domain (Accounts, Journal, Stores, etc.) has its own namespace
5. **Report viewer singleton** - Only one `frmReportViewer` is actually used (in `Reports/` root), and all 12 invocations are consistent
6. **Compilation is clean** - `dotnet build` produces 0 errors, 0 warnings
7. **Connection string injection** - `clsCN` correctly reads from `Properties.Settings` (at runtime, from App.config)
8. **Internal DAL visibility** - `clsCN` is `internal sealed` - PL cannot access it directly
9. **Gitignore coverage** - `bin/`, `obj/`, `.vs/` are properly ignored
10. **Crystal Reports RDLC files** - The 9 `.rdlc` files in `Reports/` are correctly embedded as `EmbeddedResource`

---

*Report generated by Mavis (MiniMax Agent) - 2026-06-08*
