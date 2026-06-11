# 🛠️ Zaher Workflow — Integrated Accounts System

> **Project:** IntegratedAccSys (WinForms + .NET 8 + PostgreSQL 17 + 3-Tier)
> **Branch Convention:** Local `zaher-main` ↔ Remote `zaher-origin/main`
> **Last Updated:** 2026-06-11
> **Status:** ✅ Active and enforced

This document defines the **single source of truth** for the development workflow.
It is synchronized with the project's 3-tier architecture (PL → BL → DAL → PostgreSQL) and the
technology stack (.NET 8, Npgsql 8.0.4, ReportViewerCore.WinForms 15.1.26, PostgreSQL 17).

---

## 📋 Table of Contents

1. [Repository Topology](#1-repository-topology)
2. [Golden Rules (Non-Negotiable)](#2-golden-rules-non-negotiable)
3. [Daily Development Workflow](#3-daily-development-workflow)
4. [Per-Layer Workflow (PL / BL / DAL)](#4-per-layer-workflow-pl--bl--dal)
5. [Database Workflow (PostgreSQL)](#5-database-workflow-postgresql)
6. [Build, Test & Audit Workflow](#6-build-test--audit-workflow)
7. [Commit & PR Workflow](#7-commit--pr-workflow)
8. [Release & Tagging Workflow](#8-release--tagging-workflow)
9. [Rollback & Recovery Workflow](#9-rollback--recovery-workflow)
10. [Documentation Workflow](#10-documentation-workflow)
11. [Naming Conventions](#11-naming-conventions)
12. [Troubleshooting & Quick Reference](#12-troubleshooting--quick-reference)

---

## 1. Repository Topology

| Component | Name | Purpose | Lifetime |
|-----------|------|---------|:--------:|
| **Local branch** | `zaher-main` | The **only** local working branch | Permanent |
| **Remote** | `zaher-origin` | The **only** remote (GitHub: `nashwanzaher/IntegratedAccountsSystem`) | Permanent |
| **Remote default branch** | `origin/main` (i.e. `zaher-origin/main`) | Trunk, always deployable | Permanent |
| **Working submodules** | _none_ | Submodules are forbidden | n/a |

### Push/Pull defaults

```text
Local:   zaher-main  ─────push/pull────▶  zaher-origin/main
              ▲                                   │
              └───── fast-forward only ───────────┘
```

> **Rule:** All `git push` / `git pull` / `git fetch` go to `zaher-origin` automatically
> because `zaher-main` tracks `zaher-origin/main`. Do **not** specify `--remote` flags
> unless overriding temporarily.

### Configuration snapshot (`.git/config`)

```ini
[remote "zaher-origin"]
    url = https://github.com/nashwanzaher/IntegratedAccountsSystem.git
    fetch = +refs/heads/*:refs/remotes/zaher-origin/*

[branch "zaher-main"]
    remote = zaher-origin
    merge = refs/heads/main
```

---

## 2. Golden Rules (Non-Negotiable)

| # | Rule | Why |
|---|------|-----|
| **G1** | **One local branch only**: `zaher-main` | Avoid stale branches and merge debt |
| **G2** | **One remote only**: `zaher-origin` | Single source of truth, no scattered mirrors |
| **G3** | **No submodules** | All code lives in one repo |
| **G4** | **PL → BL → DAL only** (never skip a layer) | Architectural invariant — see [ARCHITECTURE.md](ARCHITECTURE.md) §4 |
| **G5** | **DAL contains zero business logic** | Pure SQL/Sproc wrapper layer |
| **G6** | **BL contains zero UI types** (`System.Windows.Forms`) | Keep UI in PL |
| **G7** | **Database objects are SQL-first** | Views, functions, procedures, triggers live in `database/*.sql` |
| **G8** | **Build clean**: 0 errors, 0 new warnings | `dotnet build -c Release` must pass |
| **G9** | **Tests pass**: DbTest 46/46 minimum | `dotnet run --project tests/IntegratedAccSys.DAL.DbTest` |
| **G10** | **All 6 audit scripts pass** before push | `scripts/audit-g*.ps1` |

---

## 3. Daily Development Workflow

### 3.1 Morning Sync (start of day)

```powershell
# 1. Move to the (only) local branch
cd d:\source\IntegratedAccountsSystem
git checkout zaher-main

# 2. Fast-forward sync with the remote
git pull --ff-only zaher-origin main

# 3. Confirm clean state
git status     # should report: "Your branch is up to date with 'zaher-origin/main'."

# 4. Confirm build still compiles
dotnet build IntegratedAccSys.sln -c Release

# 5. Confirm DB connectivity (optional, 5 s)
scripts\start-db-test.bat
```

> If `git pull` reports a non-fast-forward, **STOP** — see [§9 Rollback](#9-rollback--recovery-workflow).

### 3.2 Coding Cycle (TDD-ish, but light)

For every change:

1. **Locate the layer**:
   - SQL/queries/stored-proc names → `src/IntegratedAccSys.DAL/`
   - Business rules/validation → `src/IntegratedAccSys.BL/`
   - Forms/reports/UI → `src/IntegratedAccSys.PL/`
   - DB schema/logic → `database/`

2. **Edit** the file(s) in the correct layer.

3. **Build**:

   ```powershell
   dotnet build IntegratedAccSys.sln -c Release
   ```

   *Must end with `Build succeeded. 0 Error(s)`.*

4. **Smoke test** the affected workflow via DbTest (if it touches DAL/DB).

5. **Audit** if the change crosses a layer:

   ```powershell
   scripts\audit-g2-security.ps1        # if auth/privilege/RBAC
   scripts\audit-g3-monitoring.ps1      # if events/metrics
   scripts\audit-g4-constraints.ps1     # if CHECK/UNIQUE/EXCLUDE
   scripts\audit-g5-indexes.ps1         # if index changes
   scripts\audit-g7-materialized-views  # if MVs added/changed
   scripts\audit-g10-approval-workflow  # if approval state machine
   ```

6. **Commit** (see [§7](#7-commit--pr-workflow)).

7. **Push**:

   ```powershell
   git push       # defaults to zaher-origin main
   ```

### 3.3 End-of-day Hygiene

```powershell
git status            # should be clean
git log --oneline -5  # review your work
dotnet build -c Release   # last sanity build
```

---

## 4. Per-Layer Workflow (PL / BL / DAL)

### 4.1 Data Access Layer (DAL) — `src/IntegratedAccSys.DAL/`

**Responsibility:** PostgreSQL access only.

| File | Purpose | Touch when… |
|------|---------|-------------|
| `clsCN.cs` | Connection wrapper | Connection lifecycle changes |
| `DbContext.cs` | Connection + transaction mgmt | Transaction semantics change |
| `DbContextProvider.cs` | Thread-safe singleton | Concurrency / DI changes |
| `DalSettings.cs` | DAL config (env vars + AppSettings) | New env var, default change |

**DAL checklist before commit:**

- [ ] No `using IntegratedAccSys.BL` or `using IntegratedAccSys.PL`
- [ ] No `System.Windows.Forms`
- [ ] No business rule (no validation, no workflow logic)
- [ ] All SQL parameterised (no string concat of user input)
- [ ] All transactions call `Begin` / `Commit` / `Rollback` correctly
- [ ] `dotnet build -c Release` clean

### 4.2 Business Logic Layer (BL) — `src/IntegratedAccSys.BL/`

**Responsibility:** Business rules, validation, workflows.

| Sub-folder | Domain | Key class(es) |
|------------|--------|----------------|
| `Accounts/` | Chart of accounts | `ClsAccounts` |
| `Bonds/`   | Bond / cheque mgmt | `ClsBonds` |
| `Journal/` | Journal entries + posting | `ClsJournal` |
| `Purchases/` | Supplier + purchase ops | `ClsPurchases` |
| `Sales/`   | Customer + sales ops | `ClsSales` |
| `Stores/`  | Inventory | `ClsInventory` |
| `SysFormat/` | System config (branches, banks, …) | `ClsSysFormat` |
| `Users/`   | Auth + privilege | `ClsUsers` |
| `Security/` | Hashing, sessions, audit, privileges | `PasswordHelper`, `SessionContext`, `AuditHelper`, `PrivilegeHelper` |
| `Constants.cs` | System-wide enums + constants | All |

**BL checklist before commit:**

- [ ] No `using IntegratedAccSys.PL`
- [ ] No `System.Windows.Forms`
- [ ] All DB calls go through DAL (no `Npgsql.*` directly)
- [ ] All entry points validate inputs
- [ ] All privilege checks consult `PrivilegeHelper` if the action is privileged
- [ ] All state-changing actions call `AuditHelper.Log(...)`

### 4.3 Presentation Layer (PL) — `src/IntegratedAccSys.PL/`

**Responsibility:** Windows Forms, RDLC reports, user interaction.

| Sub-folder | Contains |
|------------|----------|
| `Program.cs`, `frmMainWindow.cs`, `frmLogin.cs` | App shell, MDI parent, login |
| `Accounts/`, `Bonds/`, `Journal/`, `Purchases/`, `Sales/`, `Stores/`, `SysFormat/`, `Users/` | WinForms for each domain |
| `Reports/` | RDLC files + `frmReportViewer` |
| `Security/PrivilegeApplier.cs` | Applies user privileges to UI elements (hide/disable) |
| `Properties/` | Resources, Settings |

**PL checklist before commit:**

- [ ] All `using IntegratedAccSys.DAL` removed (must go through BL)
- [ ] No business rule in code-behind (delegate to BL)
- [ ] Privilege checks call `PrivilegeApplier.Apply(...)` at form `Load`
- [ ] New reports added to `Reports/` and use the existing `frmReportViewer`
- [ ] No new `Properties.Settings` keys (use environment variables via `DalSettings`)

### 4.4 Audit grep (run before every commit)

```powershell
# PL → DAL direct reference (forbidden)
findstr /S /I "IntegratedAccSys.DAL" src\IntegratedAccSys.PL\*.cs src\IntegratedAccSys.PL\**\*.cs

# BL → PL (forbidden)
findstr /S /I "IntegratedAccSys.PL"   src\IntegratedAccSys.BL\*.cs src\IntegratedAccSys.BL\**\*.cs

# DAL → BL or PL (forbidden)
findstr /S /I "IntegratedAccSys.BL"   src\IntegratedAccSys.DAL\*.cs src\IntegratedAccSys.DAL\**\*.cs
findstr /S /I "IntegratedAccSys.PL"   src\IntegratedAccSys.DAL\*.cs src\IntegratedAccSys.DAL\**\*.cs

# BL → Windows Forms (forbidden)
findstr /S /I "System.Windows.Forms"  src\IntegratedAccSys.BL\*.cs src\IntegratedAccSys.BL\**\*.cs
```

> All four must return **no matches**.

---

## 5. Database Workflow (PostgreSQL)

### 5.1 Live database contract

| Setting | Value |
|---------|-------|
| Service | `postgresql-x64-17` (Windows service, Automatic) |
| Host | `localhost:5432` |
| Database | `IntegratedAccSys` |
| User | `postgres` (dev only — production should use least-privilege role) |
| Password | `656650` (dev) — supplied via `$env:PGPASSWORD` or `IAS_DB_PWD` |
| Connection mode | `SQL` (`IAS_DB_MODE=SQL`) |
| Object count target | 116 tables, 46 views (as of 2026-06-11) |

### 5.2 SQL Script Hierarchy

Apply in this order against an **empty** `IntegratedAccSys` database:

```text
1. database/setup.sql                                  # Create empty DB (if needed)
2. database/IntegratedAccSys_PostgreSQL.sql            # Schema (tables, FKs, indexes)
3. database/IntegratedAccSys_RolesAndGrants.sql         # 6 least-privilege roles
4. database/IntegratedAccSys_EnableRLS.sql              # Row-Level Security
5. database/IntegratedAccSys_Security.sql               # pgcrypto + security definer
6. database/IntegratedAccSys_PostgreSQL_Logic.sql       # Views, functions, procs, triggers, seed
7. database/IntegratedAccSys_MVs_a.sql + MVs_b.sql      # Materialized views
8. database/IntegratedAccSys_MaterializedViews.sql      # REFRESH CONCURRENTLY setup
9. database/IntegratedAccSys_Approval_fn.sql            # Approval workflow functions
10. database/IntegratedAccSys_Approval_trg.sql          # Approval workflow triggers
11. database/IntegratedAccSys_Approval_view.sql         # Approval dashboard view
12. database/IntegratedAccSys_ApprovalIntegration.sql   # Approval wiring
13. database/IntegratedAccSys_ApprovalWorkflow.sql      # End-to-end approval logic
14. database/IntegratedAccSys_Constraints.sql           # CHECK constraints
15. database/IntegratedAccSys_Constraints_chk.sql       # Additional CHECK
16. database/IntegratedAccSys_Constraints_excl.sql      # EXCLUDE constraints
17. database/IntegratedAccSys_Indexes.sql               # Composite indexes
18. database/IntegratedAccSys_Indexes_partial.sql        # Partial indexes
19. database/IntegratedAccSys_Monitoring.sql             # Monitoring views / event triggers
20. database/IntegratedAccSys_Extensions.sql + Extensions_Views.sql
21. database/IntegratedAccSys_Dimensions_Phase4.sql     # Phase 4 dimensions
22. database/IntegratedAccSys_CompleteLogic.sql         # Combined logic (idempotent re-apply)
23. database/IntegratedAccSys_Full.sql                  # Combined full (one-shot for fresh DB)
24. database/benchmark-seed.sql                         # Benchmark seed data
```

> **One-shot fresh setup:** run only `IntegratedAccSys_Full.sql` then `Dimensions_Phase4.sql` then
> `ApprovalWorkflow.sql`. The split files exist for incremental, focused changes.

### 5.3 Applying a change to the DB

1. **Edit the SQL file** under `database/`. Never hand-edit the live DB.
2. **Apply locally**:

   ```powershell
   $env:PGPASSWORD='656650'
   psql -h localhost -U postgres -d IntegratedAccSys -v ON_ERROR_STOP=1 -f database\IntegratedAccSys_PostgreSQL_Logic.sql
   ```

3. **Validate** with the live inventory:

   ```powershell
   scripts\inventory-live-db.ps1
   ```

4. **Run the relevant audit** (g2, g3, g4, g5, g7, g10).
5. **Commit** the SQL file (and any related C# wrapper in DAL).

### 5.4 Resetting the DB (dev only)

```powershell
psql -h localhost -U postgres -c "DROP DATABASE IntegratedAccSys;"
psql -h localhost -U postgres -c "CREATE DATABASE IntegratedAccSys;"
psql -h localhost -U postgres -d IntegratedAccSys -v ON_ERROR_STOP=1 -f database\IntegratedAccSys_Full.sql
psql -h localhost -U postgres -d IntegratedAccSys -v ON_ERROR_STOP=1 -f database\IntegratedAccSys_Dimensions_Phase4.sql
psql -h localhost -U postgres -d IntegratedAccSys -v ON_ERROR_STOP=1 -f database\IntegratedAccSys_ApprovalWorkflow.sql
scripts\inventory-live-db.ps1
```

### 5.5 Environment Variables (DAL)

Set these **per shell session** (do not commit credentials):

| Var | Default | Use |
|-----|---------|-----|
| `IAS_DB_MODE` | `SQL` | `SQL` (Npgsql) or `Windows` (SSPI) |
| `IAS_DB_SERVER` | `localhost` | PostgreSQL host |
| `IAS_DB_PORT` | `5432` | PostgreSQL port |
| `IAS_DB_NAME` | `IntegratedAccSys` | Database name |
| `IAS_DB_USER` | `postgres` | Username |
| `IAS_DB_PWD` | `postgres` | Password |

---

## 6. Build, Test & Audit Workflow

### 6.1 Local tasks (VS Code Terminal → Run Task)

| Task | Command | Use |
|------|---------|-----|
| `build: Release (Solution)` | `dotnet build IntegratedAccSys.sln -c Release` | Default build |
| `build: Clean + Release` | clean + build | After dependency changes |
| `test: Build + Run DbTest` | build + DbTest | Full smoke test |
| `test: Run DbTest (11 workflows)` | start-db-test.bat | DbTest only (faster) |

### 6.2 DbTest expected output

```
=== SUMMARY: Passed=46  Failed=0 ===
```

> If any test fails, **do not push**. Investigate locally.

### 6.3 Audit scripts

Run **before every commit** that touches the relevant area:

| Script | Checks | When to run |
|--------|--------|-------------|
| `audit-g2-security.ps1` | Roles, GRANTs, RLS, password hashing | Any auth/privilege change |
| `audit-g3-monitoring.ps1` | Event triggers, monitoring views | Any monitoring/metrics change |
| `audit-g4-constraints.ps1` | CHECK, UNIQUE, EXCLUDE constraints | Any constraint change |
| `audit-g5-indexes.ps1` | Composite + partial indexes | Any index change |
| `audit-g7-materialized-views.ps1` | MV presence, unique idx, REFRESH, counts | Any MV change |
| `audit-g10-approval-workflow.ps1` | Signatures, fns, triggers, view, smoke test | Any approval change |

### 6.4 Static checks (always-on pre-commit)

```powershell
# Architectural invariants (one-liner)
findstr /S /I "IntegratedAccSys.DAL" src\IntegratedAccSys.PL\**\*.cs  # must be 0
findstr /S /I "IntegratedAccSys.PL"   src\IntegratedAccSys.BL\**\*.cs  # must be 0
findstr /S /I "IntegratedAccSys.BL"   src\IntegratedAccSys.DAL\**\*.cs # must be 0
findstr /S /I "IntegratedAccSys.PL"   src\IntegratedAccSys.DAL\**\*.cs # must be 0
findstr /S /I "System.Windows.Forms"  src\IntegratedAccSys.BL\**\*.cs  # must be 0

# Naming conventions
scripts\audit-naming-conventions.ps1
```

---

## 7. Commit & PR Workflow

### 7.1 Branching policy

> There is **one** branch (`zaher-main`) and **one** remote (`zaher-origin`).
> All work is committed directly to `zaher-main` against `zaher-origin/main`.
> No feature branches, no PRs in the local repo's normal flow.

If a temporary spike is required, use a **detached HEAD** or a throwaway worktree,
**do not** create a named branch.

### 7.2 Commit message convention (Conventional Commits)

```text
<type>(<scope>): <subject>

<body (optional)>

<footer (optional)>
```

| Type | Use for |
|------|---------|
| `feat` | New user-visible feature (form, report, workflow) |
| `fix` | Bug fix |
| `refactor` | Code change with no behaviour change |
| `perf` | Performance improvement |
| `docs` | Documentation only |
| `test` | Add or fix tests |
| `chore` | Build, tooling, dependency updates |
| `db` | Database schema/logic changes |

**Scope** is the layer: `pl`, `bl`, `dal`, `db`, `audit`, `docs`, `repo`, `agent`.

**Examples:**

```text
feat(bl): add validateDimension to Phase 4 cost-centre helpers
fix(dal): close Npgsql connection on exception in DbContext.Begin
db: add 2 partial indexes (isactive, isinventoryitem) for hot filters
docs(readme): refresh architecture validation results
chore(agent): update project status, DB inventory, and gap roadmap
```

### 7.3 Commit cadence

- **Small, atomic commits** — one logical change per commit.
- **Build-clean** — every commit must leave the tree in a build-clean state.
- **No "wip" commits** on `zaher-main` — squash locally before pushing.

### 7.4 Pre-push checklist

```powershell
# 1. Status clean
git status

# 2. Diff review
git diff --stat

# 3. Build
dotnet build IntegratedAccSys.sln -c Release

# 4. Tests
scripts\start-db-test.bat

# 5. Audits (whichever apply)
scripts\audit-g2-security.ps1
# ... (others as needed)

# 6. Push
git push
```

---

## 8. Release & Tagging Workflow

### 8.1 Versioning

**Semantic Versioning:** `MAJOR.MINOR.PATCH`

| Component | When to bump |
|-----------|--------------|
| **MAJOR** | Breaking schema change, breaking API change, .NET upgrade |
| **MINOR** | New feature, new DB object, new audit script |
| **PATCH** | Bug fix, doc fix, non-breaking tweak |

### 8.2 Tag & release

```powershell
# 1. Ensure clean & synced
git checkout zaher-main
git pull --ff-only zaher-origin main
git status   # nothing to commit

# 2. Build clean
dotnet build IntegratedAccSys.sln -c Release
scripts\start-db-test.bat

# 3. Tag
git tag -a vX.Y.Z -m "Release vX.Y.Z — <one-line summary>"

# 4. Push tag
git push zaher-origin vX.Y.Z

# 5. Create GitHub release (manual)
#    https://github.com/nashwanzaher/IntegratedAccountsSystem/releases/new
#    Choose the tag, paste `git log --oneline vPrev..vX.Y.Z` into the body.
```

### 8.3 Release artefacts to include

- `IntegratedAccSys.sln` + full `src/`, `tests/`
- `database/IntegratedAccSys_Full.sql` (one-shot restore)
- `database/benchmark-seed.sql`
- `PRODUCTION_READINESS_REPORT.md`
- `docs/ARCHITECTURE.md`
- All `audit-g*.ps1` outputs (paste as release notes)

---

## 9. Rollback & Recovery Workflow

### 9.1 Local build broken

```powershell
dotnet clean IntegratedAccSys.sln -c Release
git checkout -- .                       # discard local edits
git clean -fd                           # remove untracked
dotnet build IntegratedAccSys.sln -c Release
```

### 9.2 Last commit broken on `zaher-main`

```powershell
# Soft (keep changes staged)
git reset --soft HEAD~1

# Hard (destroy changes — DANGEROUS)
git reset --hard HEAD~1
```

### 9.3 `git pull` reports non-fast-forward

**This should never happen** (one branch, one remote, fast-forward-only policy).

If it does:

1. **STOP** — do not merge or rebase blindly.
2. Inspect the remote history:

   ```powershell
   git fetch zaher-origin
   git log --oneline -10 zaher-origin/main
   ```

3. If a force-push happened on the remote, your local is stale. Re-sync via:

   ```powershell
   git reset --hard zaher-origin/main
   ```

4. If the conflict is real, the workflow was violated. Replay your work from
   `git reflog` on top of `zaher-origin/main`.

### 9.4 DB object broken

```powershell
# 1. Identify the offending script
psql -h localhost -U postgres -d IntegratedAccSys -c "\df+ <name>"

# 2. Revert that script in `database/`
git checkout zaher-origin/main -- database/IntegratedAccSys_PostgreSQL_Logic.sql

# 3. Re-apply
psql -h localhost -U postgres -d IntegratedAccSys -v ON_ERROR_STOP=1 -f database\IntegratedAccSys_PostgreSQL_Logic.sql

# 4. Re-run inventory + audit
scripts\inventory-live-db.ps1
scripts\audit-g2-security.ps1
```

### 9.5 Reflog (the safety net)

```powershell
git reflog                              # find a "good" point
git reset --hard HEAD@{<index>}         # jump there
```

> Reflog entries are pruned after 90 days. Don't rely on it for long-term recovery —
> use tags (§8) and the remote (`zaher-origin`).

---

## 10. Documentation Workflow

### 10.1 Doc locations

| Path | Content | Owner |
|------|---------|-------|
| `README.md` | Top-level: structure, quick start, stack | Whoever changes public API |
| `docs/ARCHITECTURE.md` | Architecture validation report | After any architectural change |
| `docs/WORKFLOW.md` | **This file** | After any workflow change |
| `docs/AUDIT_REPORT.md` | Audit results | After each audit run |
| `docs/CHANGELOG.md` | Version history | Every release |
| `docs/audits/GAP_*_REPORT.md` | Per-gap deep dives | After closing a gap |
| `database/README.md` | DB setup guide | After DB script changes |
| `PRODUCTION_READINESS_REPORT.md` | Production-readiness evidence | Every release |
| `.agent.md` | Agent-readable project status | After every meaningful change |

### 10.2 Update triggers

| Doc | Update when… |
|-----|--------------|
| `README.md` | New project, new layer, new quick-start step |
| `docs/ARCHITECTURE.md` | Layer split, new dependency, violation found |
| `docs/WORKFLOW.md` | Workflow change (this doc is itself versioned) |
| `docs/CHANGELOG.md` | Every release tag |
| `PRODUCTION_READINESS_REPORT.md` | Every release, every gap closure |
| `.agent.md` | After every meaningful change (agent reads this first) |

### 10.3 The `.agent.md` rule

`.agent.md` is the **first file** any agent reads. Keep it accurate:

```powershell
# After every meaningful change:
code .agent.md
# Update: project status, DB inventory, gap roadmap, last commit hash.
git add .agent.md
git commit -m "docs(agent): update project status, DB inventory, and gap roadmap"
```

---

## 11. Naming Conventions

### 11.1 Branches & remotes

| Entity | Pattern | Example |
|--------|---------|---------|
| Local branch | `zaher-*` | `zaher-main` |
| Remote | `zaher-*` | `zaher-origin` |
| Tags | `vMAJOR.MINOR.PATCH` | `v1.4.2` |

### 11.2 Files

| Layer | File pattern | Example |
|-------|--------------|---------|
| DAL classes | `cls<Name>.cs` or `<Name>.cs` | `clsCN.cs`, `DbContext.cs` |
| BL entities  | `Cls<Name>.cs` (capital `C`) | `ClsAccounts.cs` |
| PL forms | `frm<Name>.cs` | `frmMainWindow.cs` |
| PL reports | `<name>.rdlc` | `ChartOfAccounts.rdlc` |
| SQL scripts | `IntegratedAccSys_<Topic>.sql` | `IntegratedAccSys_PostgreSQL.sql` |
| Audit scripts | `audit-g<N>-<topic>.ps1` | `audit-g10-approval-workflow.ps1` |
| Docs | `<TOPIC>.md` (kebab) | `ARCHITECTURE.md`, `WORKFLOW.md` |

### 11.3 Database

| Object | Convention | Example |
|--------|------------|---------|
| Tables | `tbl<Name>` | `tblUsers`, `tblJournalHeader` |
| Views | `vw_<snake_case>` | `vw_journalbody`, `vw_dimensions_summary` |
| Functions | `get<Name>` / `add<Name>` / `update<Name>` / `delete<Name>` / `validate<Name>` | `getUserForLogin`, `addDepartment` |
| Procedures | `sp<Name>` | `spPostJournal` |
| Triggers | `trg_<table>_<event>` | `trg_journal_after_post` |
| Indexes | `ix_<table>_<cols>` | `ix_users_isactive` |

---

## 12. Troubleshooting & Quick Reference

### 12.1 PowerShell aliases (cheat sheet)

| PowerShell | Git equivalent |
|------------|----------------|
| `git status -sb` | compact status |
| `git log --oneline --graph -20` | visual log |
| `git diff --stat` | changed-line summary |
| `git rev-parse --abbrev-ref HEAD` | current branch |
| `git remote -v` | remotes + URLs |
| `git branch -vv` | local branches + tracking |

### 12.2 Common error → fix

| Symptom | Fix |
|---------|-----|
| `fatal: no upstream configured` | `git branch --set-upstream-to=zaher-origin/main zaher-main` |
| `non-fast-forward` on push | **STOP.** Investigate before force-pushing. See §9.3. |
| `dotnet build` → `error CS0246` | `dotnet restore` then rebuild |
| `DbTest` → `connection refused` | Start PostgreSQL service: `Start-Service postgresql-x64-17` |
| `DbTest` → `password authentication failed` | `$env:PGPASSWORD='656650'` or set `IAS_DB_PWD` |
| `psql` → single-quote escape errors in PowerShell | wrap query in double quotes for psql, e.g. `psql -c "SELECT * FROM tbl WHERE col = 'x'"` |
| `findstr` returns matches in `bin/obj` | always pass `src\...` or `tests\...` to scope |

### 12.3 Quick verification (run after every session)

```powershell
# Git
git branch -vv                                                # one branch: zaher-main
git remote -v                                                 # one remote: zaher-origin
git status                                                    # clean
git log --oneline -3                                          # last 3 commits

# Build
dotnet build IntegratedAccSys.sln -c Release                 # 0 errors

# DB
Get-Service postgresql-x64-17 | Select Status                 # Running
scripts\start-db-test.bat                                      # SUMMARY: Passed=46 Failed=0
```

### 12.4 One-line full sanity check

```powershell
git status -sb && dotnet build IntegratedAccSys.sln -c Release --nologo -v q && scripts\start-db-test.bat
```

Expected end-of-output:

```text
## zaher-main...zaher-origin/main
Build succeeded.  0 Error(s)
=== SUMMARY: Passed=46  Failed=0 ===
```

---

## Appendix A — Task quick reference (VS Code)

These tasks are defined in `.vscode/tasks.json` and are the recommended entry points.

| Task | Use |
|------|-----|
| `build: Release (Solution)` | Default build (default build group) |
| `build: Clean + Release` | Clean + build (after deps change) |
| `test: Build + Run DbTest` | Full smoke test (build + DbTest) |
| `test: Run DbTest (11 workflows)` | DbTest only (faster) |
| `psql: Open interactive session` | Open psql with credentials pre-set |
| `psql: Database version + counts` | Quick DB health |
| `psql: List all tables` | `\dt` |
| `psql: List all functions` | `\df` |
| `psql: List all procedures` | `\df+` |
| `psql: List all views` | `\dv` |
| `psql: Show getUserForLogin function` | `\sf getUserForLogin` |
| `psql: Describe tblUsers table` | `\d tblUsers` |
| `psql: Run query from clipboard` | Run whatever is in the clipboard |
| `audit: Run naming conventions audit` | Naming audit |
| `audit: Run build-mapping-matrix` | BL → DB mapping matrix |
| `audit: Run live DB inventory` | Live inventory script |

---

## Appendix B — Where to find what

| Question | Look in |
|----------|---------|
| "How do I add a new column to `tblUsers`?" | `database/IntegratedAccSys_PostgreSQL.sql` (schema) → re-apply → audit-g2 |
| "How do I add a new BL method?" | `src/IntegratedAccSys.BL/<Domain>/ClsXxx.cs` |
| "How do I add a new WinForm?" | `src/IntegratedAccSys.PL/<Domain>/frmXxx.cs` + `.resx` + `PrivilegeApplier` |
| "How do I add a new audit?" | `scripts/audit-g<N>-<topic>.ps1` + add a task in `.vscode/tasks.json` |
| "How do I add a new migration?" | Create a new `database/IntegratedAccSys_<Topic>.sql`, apply, commit |
| "What is the current DB state?" | `scripts\inventory-live-db.ps1` |
| "What gaps are still open?" | `PRODUCTION_READINESS_REPORT.md` and `.agent.md` |

---

**End of workflow.** This document is versioned with the repo. When you change it, bump
`PRODUCTION_READINESS_REPORT.md` if the change is material, and update `.agent.md` so
the next agent reads the latest version.
