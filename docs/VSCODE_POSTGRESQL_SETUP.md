# 🐘 VS Code + PostgreSQL Connection Setup

**Date:** 2026-06-09
**Status:** ✅ **CONNECTED** — Live PostgreSQL `IntegratedAccSys@localhost:5432` accessible from VS Code
**Extension Used:** `cweijan.vscode-postgresql-client2` v8.5.0 (already installed)

---

## 1. Quick Start

VS Code is now configured to connect directly to the live PostgreSQL database. There are **3 ways** to use the connection:

### Method 1 — VS Code Tasks (Recommended) ⌨️

1. Press **Ctrl+Shift+P** → "Tasks: Run Task"
2. Pick any of the pre-configured `psql:*` tasks
3. The output appears in the integrated terminal

**Available tasks** (15 total):

| Task | Description |
|------|-------------|
| `build: Release (Solution)` | Build the entire solution (default Ctrl+Shift+B) |
| `build: Clean + Release` | Clean then build |
| `test: Run DbTest (11 workflows)` | Run the 11-workflow DB validator |
| `test: Build + Run DbTest` | Build + run validator |
| **`psql: Open interactive session`** | Open a live psql shell |
| **`psql: Database version + counts`** | Show DB version and object counts |
| **`psql: List all tables`** | `\dt` |
| **`psql: List all functions`** | `\df` |
| **`psql: List all procedures`** | Custom query for `prokind = 'p'` |
| **`psql: List all views`** | `\dv` |
| **`psql: Show getUserForLogin function`** | `\sf getUserForLogin` |
| **`psql: Describe tblUsers table`** | `\d tblUsers` |
| **`psql: Run query from clipboard`** | Run whatever SQL is on the clipboard |
| `audit: Run naming conventions audit` | Run naming audit |
| `audit: Run build-mapping-matrix` | Run mapping matrix |
| `audit: Run live DB inventory` | Run live DB inventory |

### Method 2 — Connection Helper Script (PowerShell) 🐚

```powershell
cd d:\source\IntegratedAccountsSystem
.\scripts\connect-db.ps1 -Info            # Show version + counts
.\scripts\connect-db.ps1 -ListTables     # List all public tables
.\scripts\connect-db.ps1 -ListFunctions  # List all public functions
.\scripts\connect-db.ps1 -ListProcedures # List all public procedures
.\scripts\connect-db.ps1 -ListViews      # List all public views
.\scripts\connect-db.ps1 -Query "SELECT COUNT(*) FROM tblUsers"
.\scripts\connect-db.ps1 -Command "\dt"  # Run any psql meta-command
.\scripts\connect-db.ps1                 # Open interactive session
.\scripts\connect-db.ps1 -Help           # Show full help
```

### Method 3 — cweijan PostgreSQL Client (Tree View) 🌳

The `cweijan.vscode-postgresql-client2` extension provides a **Database Client** activity bar icon (database icon on the left sidebar). Once the connection profile is loaded, you can:

1. Click the Database Client icon in the activity bar
2. The "IntegratedAccSys (Local)" connection appears in the tree
3. Click to expand: schemas, tables, views, functions, procedures
4. Right-click any object → "New Query", "Show Data", "Design Schema", etc.

---

## 2. Configuration Files Created

| File | Purpose |
|------|---------|
| **`.vscode/settings.json`** | Workspace settings: PostgreSQL connection profile, C# / PowerShell / SQL editor config, file exclusions |
| **`.vscode/tasks.json`** | 15 predefined tasks (build/test/psql/audit) |
| **`scripts/connect-db.ps1`** | PowerShell connection helper with -Info, -List*, -Query, -Command, interactive modes |

---

## 3. Connection Details

| Property | Value |
|----------|-------|
| **Server** | `localhost` |
| **Port** | `5432` |
| **Database** | `IntegratedAccSys` |
| **User** | `postgres` |
| **Password** | `656650` |
| **psql path** | `C:\Program Files\PostgreSQL\17\bin\psql.exe` |
| **Authentication** | `PGPASSWORD` env var (avoids command-line exposure) |

> **Note:** Credentials are stored in the **workspace** settings file for local development only. For production, use environment variables or a secrets manager.

---

## 4. Live Database Inventory (verified)

```
PostgreSQL 17.10 on x86_64-windows
object_type | count
-----------+-------
functions  |   114
procedures |    69
tables     |    46
triggers   |     3
views      |     9
───────────+───────
TOTAL      |   241
```

**Difference from previous inventory (301):** Earlier inventory used a custom regex parser over `.sql` files which may have over-counted due to multiple definitions across 5 SQL scripts. The live count is the authoritative ground truth.

---

## 5. How to Add Connection to Your User Settings (for the cweijan extension)

The `cweijan.vscode-postgresql-client2` extension stores connections in the **user's global VS Code settings** (`%USERPROFILE%\.vscode\argv.json` is for VS Code flags, NOT extensions). The extension uses a custom file at:

```
%USERPROFILE%\.vscode\extensions\cweijan.vscode-postgresql-client2-8.5.0\
```

The cleanest way to add the connection is:

1. Open VS Code Command Palette (Ctrl+Shift+P)
2. Type: "PostgreSQL: Add Connection"
3. Fill in:
   - **Connection name:** `IntegratedAccSys (Local)`
   - **Host:** `localhost`
   - **Port:** `5432`
   - **User:** `postgres`
   - **Password:** `656650`
   - **Database:** `IntegratedAccSys`
4. Save

The connection will appear in the Database Client sidebar.

The workspace `.vscode/settings.json` already declares the connection (`postgresql.connectionList`); some versions of the extension will pick this up on workspace open.

---

## 6. Verification Commands

Run these from VS Code's integrated terminal (`Ctrl+``):

```bash
# Quick sanity check
dotnet test tests/IntegratedAccSys.DAL.DbTest --configuration Release
# Expected: Passed=11  Failed=0

# Live DB object count (must show 241 total)
.\scripts\connect-db.ps1 -Info
```

---

## 7. Troubleshooting

| Problem | Solution |
|---------|----------|
| **psql not found** | Install PostgreSQL 17 from https://www.postgresql.org/download/ — default install path is `C:\Program Files\PostgreSQL\17\bin\` |
| **Connection refused** | Verify `psql -h localhost -p 5432 -U postgres -d IntegratedAccSys` works from PowerShell |
| **Password authentication failed** | Verify password is `656650` or update `scripts/connect-db.ps1` and `.vscode/settings.json` |
| **cweijan extension sidebar empty** | Click the Database icon in the activity bar, then "Add Connection" via the command palette |
| **Tasks not showing** | Ensure `.vscode/tasks.json` is valid JSON (no trailing commas). Use **Ctrl+Shift+P → "Tasks: Open User Tasks"** to verify |

---

## 8. Related Files

| File | Purpose |
|------|---------|
| `.vscode/settings.json` | Workspace settings + PostgreSQL connection profile |
| `.vscode/tasks.json` | 15 predefined tasks (build/test/psql/audit) |
| `scripts/connect-db.ps1` | PowerShell connection helper |
| `scripts/inventory-live-db.ps1` | Live DB inventory script (referenced in tasks) |
| `scripts/build-mapping-matrix.ps1` | BL→DB mapping matrix (referenced in tasks) |
| `scripts/audit-naming-conventions.ps1` | Naming audit (referenced in tasks) |
| `database/verify_coverage.ps1` | C# call site ↔ DB signature verifier |
| `docs/audits/SCRIPTS_INVENTORY_REPORT.md` | Inventory of all 22 scripts |

---

**Status: ✅ VS Code is now directly connected to the live PostgreSQL database. Use any of the 3 methods above to start querying.**
