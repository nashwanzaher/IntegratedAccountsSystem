# 📐 Project Conventions — Industry-Standard

> **Source of truth** for naming, structure, and organization rules.
> All new code must comply. Existing code is being migrated in tracked phases
> (see [`docs/audits/RESTRUCTURING_PLAN.md`](audits/RESTRUCTURING_PLAN.md)).

**Version:** 1.0.0
**Effective:** 2026-06-11
**Applies to:** `src/`, `tests/`, `database/`, `docs/`, `scripts/`, `.github/`

---

## 1. Directory Structure

### 1.1 Top-level layout

```
IntegratedAccountsSystem/
├── src/                          # All production C# code
│   ├── IntegratedAccSys.Domain/         # 🆕 Entities + value objects
│   ├── IntegratedAccSys.Application/    # 🆕 Use cases, BL (existing)
│   ├── IntegratedAccSys.Infrastructure/ # 🆕 DAL + DB types
│   ├── IntegratedAccSys.UI/             # 🆕 WinForms PL
│   └── IntegratedAccSys.Shared/         # 🆕 Cross-cutting (logging, etc.)
│
├── tests/                        # All test projects
│   ├── IntegratedAccSys.UnitTests/
│   ├── IntegratedAccSys.IntegrationTests/
│   └── IntegratedAccSys.DAL.DbTest/    # existing
│
├── database/                     # PostgreSQL schema + migrations
│   ├── migrations/                      # numbered SQL migrations
│   ├── seeds/                           # reference/seed data
│   └── *.sql                            # canonical schema bundles
│
├── docs/                         # Documentation
│   ├── architecture/                    # tier maps, decisions
│   ├── audits/                          # audit reports
│   ├── adr/                             # 🆕 Architecture Decision Records
│   ├── guides/                          # 🆕 how-to guides
│   └── CONVENTIONS.md                   # this file
│
├── scripts/                      # PowerShell + batch utilities
│   ├── audits/                          # audit-g*.ps1
│   ├── build/                           # build helpers
│   └── README.md
│
├── tools/                        # 🆕 Build/CI tooling (separate from src)
│
├── .github/                      # GitHub workflows + templates
│   ├── workflows/
│   └── PULL_REQUEST_TEMPLATE.md
│
├── .editorconfig                 # 🆕 Editor style rules
├── Directory.Build.props         # 🆕 MSBuild common settings
├── Directory.Packages.props      # 🆕 Central package management
├── global.json                   # .NET SDK version pin
├── README.md                     # project entry point
├── LICENSE
├── SECURITY.md
└── IntegratedAccSys.sln          # solution
```

### 1.2 Lowercase root folders

All top-level folders are **lowercase, no underscores, no abbreviations**:
✅ `src/`, `tests/`, `docs/`, `scripts/`
❌ `SRC/`, `Test/`, `Doc/`, `utils/`

### 1.3 Path-case rule (Windows + Unix safe)

Folder names use the exact case that will be referenced in code and docs.
Because the project must work on both Windows (case-insensitive) and Linux
(usually case-sensitive), the canonical form is the one Git tracks.

Currently Git tracks `Database/` (capital D) but the filesystem shows `database/`.
**Migration target:** rename Git tracking to `database/` and update all references.

---

## 2. C# Naming Conventions (.NET / Microsoft Guidelines)

Reference: [Microsoft C# Coding Conventions](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions)
and [Framework Design Guidelines](https://learn.microsoft.com/en-us/dotnet/standard/design-guidelines/).

### 2.1 Type & Member Naming

| Element | Convention | Example (✅) | Example (❌) |
|---------|-----------|--------------|--------------|
| **Namespace** | `PascalCase`, dot-separated | `IntegratedAccSys.Application.Accounts` | `integratedAccSys.application.accounts` |
| **Class** | `PascalCase`, **no prefix** | `AccountService` | `clsAccounts`, `CAccounts`, `AccountSvc` |
| **Interface** | `IPascalCase` | `IAccountRepository` | `AccountRepositoryInterface` |
| **Public method** | `PascalCase`, verb-noun | `GetByIdAsync(int id)` | `getById`, `get_by_id` |
| **Public property** | `PascalCase`, noun | `AccountName` | `accountName` (when public) |
| **Public field** | Avoid; use property | `public int MaxCount { get; }` | `public int MAX_COUNT` |
| **Constant** | `PascalCase` | `DefaultPageSize` | `DEFAULT_PAGE_SIZE`, `defaultPageSize` |
| **Private field** | `_camelCase` | `private int _currentId;` | `private int currentId;` |
| **Local variable** | `camelCase` | `var account = …;` | `var Account = …;` |
| **Parameter** | `camelCase` | `void Add(int accountId)` | `void Add(int AccountId)` |
| **Enum** | `PascalCase` singular type, `PascalCase` values | `enum AccountType { Asset, Liability }` | `enum ACCOUNT_TYPE { ASSET }` |
| **Generic type param** | `TPascalCase` | `class Repository<TEntity>` | `class Repository<T>` |

### 2.2 File Naming

| Element | Convention | Example (✅) | Example (❌) |
|---------|-----------|--------------|--------------|
| **One class per file** | file name = class name (with `.cs`) | `AccountService.cs` | `clsAccounts.cs`, `AccountService_Helpers.cs` |
| **Designer files** | `<FormName>.Designer.cs` | `LoginForm.Designer.cs` | `frmLogin.Designer.cs` |
| **Resource files** | `<FormName>.resx` | `LoginForm.resx` | `frmLogin.resx` |
| **Project files** | match assembly name, no prefix | `IntegratedAccSys.Application.csproj` | `app.csproj`, `bl.csproj` |

### 2.3 Remove Legacy Prefixes

These legacy Hungarian-style prefixes are **forbidden** in new code and are
being migrated in existing code:

| Old (❌) | New (✅) | Notes |
|----------|----------|-------|
| `clsAccounts`, `clsBonds`, … | `AccountService`, `BondService`, … | Drop `cls` prefix; use service suffix for business logic |
| `frmLogin`, `frmMain`, … | `LoginForm`, `MainForm`, … | Drop `frm` prefix; use `Form` suffix |
| `ucHeader` | `HeaderControl` | Drop `uc` prefix; use `Control` suffix |
| `dalClsCN` | `NpgsqlConnectionFactory` | Drop Hungarian notation |

### 2.4 Class Naming by Layer

| Layer | Recommended suffix | Example |
|-------|-------------------|---------|
| **Domain entity** | (no suffix) | `Account`, `JournalEntry` |
| **Value object** | (no suffix) | `Money`, `CurrencyCode` |
| **Domain event** | `Event` | `JournalPostedEvent` |
| **Application service** | `Service` | `AccountService`, `JournalPostingService` |
| **Repository** | `Repository` | `IAccountRepository`, `AccountRepository` |
| **Use case / command** | `Command`, `Query`, `Handler` | `PostJournalCommand`, `PostJournalHandler` |
| **DTO** | `Dto` | `AccountDto`, `JournalEntryDto` |
| **Form (PL)** | `Form` | `LoginForm`, `ChartOfAccountsForm` |
| **User control** | `Control` | `HeaderControl`, `LookupControl` |
| **Validator** | `Validator` | `JournalEntryValidator` |

---

## 3. Database Naming Conventions (PostgreSQL)

Reference: [PostgreSQL official docs — naming](https://www.postgresql.org/docs/current/sql-syntax-lexical.html#SQL-SYNTAX-IDENTIFIERS)
and the [Citrus / Crunchy Data PostgreSQL Style Guide](https://github.com/CrunchyData/postgresql-style-guide).

### 3.1 Identifiers

| Element | Convention | Example (✅) | Example (❌) |
|---------|-----------|--------------|--------------|
| **All identifiers** | `snake_case` | `account_code`, `journal_entry` | `AccountCode`, `Journal_Entry`, `tblaccount` |
| **Length** | ≤ 63 bytes (PostgreSQL NAMEDATALEN default) | — | very long names |
| **Reserved words** | never as bare names; quote if forced | `"user"`, `"order"` | `user` (ambiguous) |
| **Quoting** | prefer no-quote; use `lower_case` | `select * from accounts` | `SELECT * FROM "Accounts"` |

### 3.2 Tables

| Rule | Example (✅) | Example (❌) |
|------|--------------|--------------|
| **Plural, no prefix** | `accounts`, `journal_entries` | `tblAccount`, `T_Account`, `account_table` |
| **No Hungarian notation** | `users` | `tblUsers`, `t_users`, `tbUser` |
| **No schema in name** | `accounts` (in `public` schema) | `public_accounts` |
| **Junction table** | plural of both, alphabetical | `account_users` | `account_user_link`, `linkAccountUser` |

### 3.3 Columns

| Rule | Example (✅) | Example (❌) |
|------|--------------|--------------|
| **snake_case** | `account_code`, `created_at` | `AccountCode`, `CreatedAt` |
| **Primary key** | `<table_singular>_id` | `id`, `AccountID`, `accountID` |
| **Foreign key** | `<referenced_table_singular>_id` | `account_code` (in `journal_entries`) |
| **Timestamps** | `_at` suffix, both columns on every table | `CreatedDate`, `InsertTime` |
| **Booleans** | `is_*` or `has_*` prefix | `Active`, `active_flag`, `isactive` |
| **Money** | `_amount` or `_value` suffix, with explicit currency | `debit_amount`, `total_value` | `debit`, `Total` |
| **Enums** | lowercase string with `_` separator (or use `CREATE TYPE … AS ENUM`) | `status`, `account_type` | `Status`, `AccountType` (as text) |
| **Audit columns** | `created_at`, `updated_at`, `created_by`, `updated_by`, `is_deleted` (or `deleted_at` for soft-delete) | — | — |

### 3.4 Functions, Procedures, Views, Triggers

| Object | Convention | Example (✅) | Example (❌) |
|--------|-----------|--------------|--------------|
| **Function** | `snake_case`, verb-first, no prefix | `get_account_balance`, `calculate_vat` | `getAccountBalance`, `fnGetAccountBalance`, `sp_GetAccountBalance` |
| **Procedure** | `snake_case`, verb-imperative, no `sp_` prefix | `post_journal`, `expire_old_sessions` | `sp_ExpireOldSessions`, `PostJournal` |
| **View** | `snake_case`, plural noun, `v_` prefix optional | `account_hierarchy`, `v_account_hierarchy` | `vw_AccountHierarchy`, `AccountHierarchy` |
| **Materialized view** | plural noun, `mv_` prefix | `mv_daily_sales_summary` | `mvDailySalesSummary`, `dailySalesMV` |
| **Trigger function** | `<purpose>_<table>_trg` | `audit_journal_entries_trg` | `trg_audit_journal` |
| **Trigger** | `<event>_<table>_trg` | `insert_audit_log_trg`, `update_journal_trg` | `trg_auditlog`, `JournalInsertTrigger` |
| **Index** | `idx_<table>_<columns>` | `idx_journal_entries_account_code` | `JournalEntries_AccountCode_IDX` |
| **Unique index** | `uniq_<table>_<columns>` | `uniq_users_user_id` | `users_user_id_uk` |
| **FK constraint** | `fk_<table>_<ref_table>` | `fk_journal_entries_accounts` | `FK_Journal_Account` |
| **Check constraint** | `chk_<table>_<rule>` | `chk_journal_body_debit_nonneg` | `CK_Journal_Debit` |
| **Policy** | `<role>_<table>_<action>` | `app_auditor_users_select` | `pol_users_select` |

### 3.5 Naming Migration Phases

The current DB uses legacy `PascalCase` and `tbl*` / `sp_*` prefixes. Migration
phases are documented in [`docs/audits/RESTRUCTURING_PLAN.md`](audits/RESTRUCTURING_PLAN.md).

---

## 4. File & Folder Layout per Layer

### 4.1 PL (WinForms) — `src/IntegratedAccSys.UI/`

```
src/IntegratedAccSys.UI/
├── Program.cs
├── MainForm.cs                        # was frmMainWindow.cs
├── MainForm.Designer.cs
├── MainForm.resx
├── Login/
│   ├── LoginForm.cs                   # was frmLogin.cs
│   ├── LoginForm.Designer.cs
│   └── LoginForm.resx
├── Accounts/
│   ├── ChartOfAccountsForm.cs
│   ├── TrialBalanceForm.cs
│   ├── FinalAccountsForm.cs
│   └── AccountSheetForm.cs
├── Bonds/
│   └── BondForm.cs
├── Journal/
│   ├── JournalEntryForm.cs
│   └── JournalPostingForm.cs
├── ...
└── Reports/
    ├── ReportViewerForm.cs
    └── *.rdlc
```

### 4.2 BL (Application) — `src/IntegratedAccSys.Application/`

```
src/IntegratedAccSys.Application/
├── Accounts/
│   ├── AccountService.cs              # was clsAccounts.cs
│   ├── DTOs/
│   │   └── AccountDto.cs
│   └── Validators/
│       └── AccountValidator.cs
├── Bonds/
│   └── BondService.cs
├── Journal/
│   ├── JournalService.cs
│   ├── DTOs/
│   └── PostJournalCommand.cs          # CQRS-lite
├── ...
├── Security/
│   ├── PasswordHasher.cs              # was PasswordHelper.cs
│   ├── SessionManager.cs              # was SessionContext.cs
│   ├── AuditLogger.cs                 # was AuditHelper.cs
│   └── PrivilegeChecker.cs            # was PrivilegeHelper.cs
└── DependencyInjection.cs             # 🆕 extension method for IServiceCollection
```

### 4.3 DAL (Infrastructure) — `src/IntegratedAccSys.Infrastructure/`

```
src/IntegratedAccSys.Infrastructure/
├── Persistence/
│   ├── NpgsqlConnectionFactory.cs     # was clsCN.cs
│   ├── NpgsqlDbContext.cs             # was DbContext.cs
│   ├── DbContextProvider.cs
│   └── DalSettings.cs
├── Repositories/
│   ├── AccountRepository.cs
│   ├── JournalRepository.cs
│   └── UserRepository.cs
├── Security/
│   └── PiiCrypto.cs
└── DependencyInjection.cs
```

---

## 5. SQL File Organization

### 5.1 Folder layout

```
database/
├── migrations/                        # time-ordered, never edit after applied
│   ├── 2026_06_11_01_drop_legacy_auth_procedures.sql
│   ├── 2026_06_12_01_rename_tbl_prefix_to_snake_case.sql
│   └── ...
├── seeds/                             # repeatable reference data
│   ├── reference_data.sql             # currencies, units, payment methods
│   └── default_admin.sql
├── bundles/                           # consolidated schema snapshots
│   ├── 1_schema.sql
│   ├── 2_logic.sql
│   └── 3_seed.sql
├── functions/                         # one CREATE per file (or grouped)
│   ├── accounts/
│   ├── auth/
│   └── reporting/
└── README.md                          # migration order + setup instructions
```

### 5.2 Migration file naming

`YYYY_MM_DD_NN_<verb>_<object>.sql` — e.g.:

- `2026_06_11_01_drop_legacy_auth_procedures.sql`
- `2026_06_12_01_rename_tbl_users_to_accounts.sql`

Each migration is **forward-only**, contains a transaction wrapper, and starts
with idempotency guards (`IF EXISTS` / `IF NOT EXISTS`).

---

## 6. Documentation Conventions

### 6.1 Folder structure

```
docs/
├── README.md                          # project landing page
├── CONVENTIONS.md                     # this file
├── WORKFLOW.md                        # dev workflow
├── ARCHITECTURE.md                    # top-level architecture
├── CHANGELOG.md                       # release notes
├── architecture/                      # deep-dive, per-layer
├── audits/                            # audit reports (read-only)
├── adr/                               # 🆕 Architecture Decision Records
│   ├── 0001-use-postgresql.md
│   ├── 0002-use-3-tier-architecture.md
│   └── template.md
├── guides/                            # 🆕 how-to
│   ├── how-to-add-a-new-endpoint.md
│   ├── how-to-write-a-migration.md
│   └── how-to-add-an-rdlc-report.md
└── presentation/                      # one-off slide decks
```

### 6.2 ADR template

Each ADR uses the [Michael Nygard template](https://github.com/joelparkerhenderson/architecture-decision-record):

```markdown
# <number>. <title>

## Status
Proposed | Accepted | Deprecated | Superseded by ADR-XXXX

## Context
What is the issue we're seeing?

## Decision
What did we decide?

## Consequences
What becomes easier? What becomes harder?
```

### 6.3 Markdown style

- ATX headers (`#` not `===`)
- Sentence case for headers
- Code fences with language: `​```sql`, `​```csharp`, `​```powershell`
- Tables for comparisons
- Filenames in backticks, not bold

---

## 7. Git Conventions

### 7.1 Branch naming

`<type>/<scope>-<short-description>`

| Type | Example |
|------|---------|
| `feat/` | `feat/accounts-reports` |
| `fix/` | `fix/journal-posting-bug` |
| `chore/` | `chore/cleanup-audit` |
| `refactor/` | `refactor/extract-repository` |
| `docs/` | `docs/add-conventions` |
| `audit/` | `audit/gap-10-approval` |

### 7.2 Commit message format

[Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Allowed types:** `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `perf`, `build`, `ci`, `audit`, `revert`

**Subject:** imperative mood, ≤ 72 chars, no trailing period.

**Body:** explains *what* and *why* (not how). Wrap at 72 cols.

**Footer:** references (`Refs: #123`, `Closes: #456`) and breaking-change notes
(`BREAKING CHANGE: …`).

### 7.3 .gitignore must cover

✅ Build output: `bin/`, `obj/`
✅ IDE: `.vs/`, `.vscode/`, `.idea/`
✅ OS: `.DS_Store`, `Thumbs.db`
✅ Secrets: `*.pfx`, `*.key`, `appsettings.*.local.json`
✅ Audit artifacts: `__*`, `*.audit.log`
✅ Generated: `coverage/`, `*.coverage`

---

## 8. EditorConfig (`.editorconfig`)

Enforces whitespace, encoding, and C# style from a single file:

```ini
root = true

[*]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.{cs,xaml}]
csharp_style_namespace_declarations = file_scoped:warning
csharp_using_directive_placement = outside_namespace:warning
csharp_new_line_before_open_brace = all
csharp_prefer_braces = true:warning
dotnet_diagnostic.CA1707.severity = none  # allow _ in test method names

[*.{sql,ps1,sh}]
indent_size = 4

[*.md]
trim_trailing_whitespace = false
```

---

## 9. CI/CD (GitHub Actions)

```
.github/
├── workflows/
│   ├── build.yml          # build on every push
│   ├── test.yml           # run DbTest on PR
│   ├── audit.yml          # run audit-g*.ps1
│   └── release.yml        # tag → publish artifact
├── PULL_REQUEST_TEMPLATE.md
├── ISSUE_TEMPLATE/
│   ├── bug_report.md
│   └── feature_request.md
└── CODEOWNERS             # require review from owner
```

---

## 10. Versioning

[Semantic Versioning 2.0.0](https://semver.org/):

- `MAJOR` — incompatible API or schema changes
- `MINOR` — backward-compatible features
- `PATCH` — backward-compatible bug fixes

Schema migrations are **always** major-version when they rename or drop
publicly-used objects; minor-version when adding; patch-version for data
fixes.

---

## 11. Enforcement

| Tool | What it checks | When it runs |
|------|----------------|--------------|
| `dotnet format` | C# style | pre-commit, CI |
| `dotnet build -warnaserror` | compile errors + analyzer warnings | CI |
| `audit-naming-conventions.ps1` | cls*/frm* prefix, PascalCase, file/class mismatch | pre-commit, CI |
| `audit-g4-constraints.ps1` | SQL constraint naming | pre-commit, CI |
| `DbTest` | smoke test of DB | pre-commit, CI |

---

*Conventions are living documentation. Propose changes via PR; ADR required
for any non-cosmetic rule change.*
