# Architecture — IntegratedAccountsSystem

> System architecture documentation organized by **3-tier layering** (PL → BL → DAL) plus the PostgreSQL database layer.

**Current Version:** v3.0 (PostgreSQL 17)
**Last Updated:** 2026-06-11
**Framework:** .NET 8 WinForms | 3-Tier Architecture (PL → BL → DAL → DB)

---

## Tier Map

```
┌─────────────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER (PL)                                        │
│  WinForms UI (38 forms + 9 RDLC reports)                        │
│  Location: src/IntegratedAccSys.PL/                            │
│  → See: §1 PL below                                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  BUSINESS LOGIC LAYER (BL)                                      │
│  Domain logic + parameter preparation (13 C# files)             │
│  Location: src/IntegratedAccSys.BL/                            │
│  → See: §2 BL below                                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  DATA ACCESS LAYER (DAL)                                        │
│  PostgreSQL access via Npgsql 8.0.4                             │
│  Location: src/IntegratedAccSys.DAL/                            │
│  → See: §3 DAL below                                           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  DATABASE (PostgreSQL 17.10)                                    │
│  70 tables │ 46 views │ 384 fns │ 76 procs │ 14 triggers │ 29 RLS │
│  10 matviews │ 242 indexes │ 70 sequences                       │
│  Location: database/                                            │
│  → See: §4 Database below                                      │
└─────────────────────────────────────────────────────────────────┘
```

> **Note:** Object counts above are from the live `IntegratedAccSys` database
> as of 2026-06-11. See [`../audits/DEEP_ARCHITECTURE_DATABASE_AUDIT.md`](../audits/DEEP_ARCHITECTURE_DATABASE_AUDIT.md)
> for the full inventory.

---

## §1 — Presentation Layer (PL)

**Location:** `src/IntegratedAccSys.PL/`
**Files:** 38 WinForms `.cs` + 9 RDLC reports
**Zero direct DB access.** Every form calls BL classes only via `cn.SelectData`/`cn.ExecuteCmd` indirection.

| Sub-folder | Forms | Purpose |
|------------|------:|---------|
| `PL/Accounts/` | 7 | Chart of accounts, trial balance, final accounts, account sheet |
| `PL/Bonds/` | 1 | Receipt/Payment vouchers |
| `PL/Journal/` | 2 | Journal entries, posting/unposting |
| `PL/Purchases/` | 4 | Purchase bills, returns, suppliers |
| `PL/Sales/` | 4 | Sales bills, returns, customers |
| `PL/Stores/` | 7 | Categories, units, stores, products, inventory movement |
| `PL/SysFormat/` | 8 | Companies, banks, currencies, funds, backups, VAT settings |
| `PL/Users/` | 3 | Login, privileges, user management |
| `PL/Reports/` | 1 + 9 RDLC | RDLC report viewer |
| `PL/Security/` | 1 | `PrivilegeApplier.cs` (UI-layer privilege enforcement) |
| `PL/Properties/` | — | Resources, Settings, AssemblyInfo |

**Key invariants:**

- `grep "Npgsql" src/IntegratedAccSys.PL/**/*.cs` → **0 matches** (PL is DB-agnostic)
- `grep "System.Data.SqlClient" src/IntegratedAccSys.PL/**/*.cs` → **0 matches** (migrated to PostgreSQL with zero PL changes — see `audits/PL_Migration_Report.md`)

---

## §2 — Business Logic Layer (BL)

**Location:** `src/IntegratedAccSys.BL/`
**Files:** 13 main classes + 4 helpers
**Parameter binding:** All `NpgsqlParameter[]` (migrated from `SqlParameter[]` — 606 replacements).
**BL ↔ DB coverage:** 175/175 unique C# references resolved against the live DB.

| Sub-folder | File | Purpose |
|------------|------|---------|
| `BL/Accounts/` | `ClsAccounts.cs` | Chart of accounts CRUD |
| `BL/Bonds/` | `ClsBonds.cs` | Receipt/Payment voucher logic |
| `BL/Journal/` | `ClsJournal.cs` | Journal entries + posting |
| `BL/Purchases/` | `ClsPurchases.cs` | Purchase bill logic |
| `BL/Sales/` | `ClsSales.cs` | Sales bill logic |
| `BL/Stores/` | `ClsInventory.cs` | Inventory management |
| `BL/SysFormat/` | `ClsSysFormat.cs` | System config (branches, banks, etc.) |
| `BL/Users/` | `ClsUsers.cs` | User mgmt + RBAC |
| `BL/Dimensions/` | `ClsDimensions.cs` | Cost-centers, projects, business units, segments, profit centers |
| `BL/Security/` | `PasswordHelper.cs`, `SessionContext.cs`, `AuditHelper.cs`, `PrivilegeHelper.cs` | Cross-cutting concerns |

**Key invariants:**

- BL never imports Npgsql directly — all DB calls go through `DAL.ClsCN` or `DAL.DbContext`.
- BL never imports `System.Windows.Forms` — UI logic is in PL.

---

## §3 — Data Access Layer (DAL)

**Location:** `src/IntegratedAccSys.DAL/`
**Files:** 4 main + 1 helper

| File | Purpose |
|------|---------|
| `ClsCN.cs` | Connection wrapper (`SelectData` / `ExecuteCmd` / `ExecuteScalar`) — legacy path |
| `DbContext.cs` | Explicit transactions (`BeginTransaction/Commit/Rollback`) — modern path |
| `DbContextProvider.cs` | Thread-safe singleton context provider |
| `DalSettings.cs` | DAL config (env vars + AppSettings) |
| `Security/PiiCrypto.cs` | PII column encryption helpers (G2 closure) |

**Key pattern:** `ClsCN.cs` auto-dispatches between PostgreSQL function vs procedure semantics.
See `audits/PRODUCTION_READINESS_REPORT.md` §4 for the dispatch logic.

**Known issue (from `audits/ARCH_AUDIT.md` §1.4):** two parallel DAL paths
(`ClsCN` + `DbContext`) should be consolidated in Phase-4 restructuring
(see `../audits/RESTRUCTURING_PLAN.md`).

---

## §4 — Database (PostgreSQL 17)

**Location:** `database/`
**Engine:** PostgreSQL 17.10 @ `localhost:5432`
**Database:** `IntegratedAccSys`

| Live DB object | Count | Source-of-truth file |
|----------------|------:|---------------------|
| Tables | 70 | `database/IntegratedAccSys_PostgreSQL.sql` |
| Views | 46 | `database/IntegratedAccSys_PostgreSQL_Logic.sql` |
| Functions (user) | ~167 | `database/IntegratedAccSys_CompleteLogic.sql` |
| Procedures | 76 | `database/IntegratedAccSys_CompleteLogic.sql` |
| Triggers | 14 | `database/IntegratedAccSys_PostgreSQL.sql` |
| Materialized views | 10 | `database/IntegratedAccSys_MaterializedViews.sql` |
| Indexes | 242 | `database/IntegratedAccSys_Indexes.sql` |
| RLS policies | 29 | `database/IntegratedAccSys_EnableRLS.sql` |

**Apply order (fresh install):**

```bash
# 1. Create DB
psql -h localhost -p 5432 -U postgres -d postgres -c "CREATE DATABASE IntegratedAccSys;"

# 2. Apply schema
psql -h localhost -p 5432 -U postgres -d IntegratedAccSys -f database/IntegratedAccSys_PostgreSQL.sql

# 3. Apply logic (v2 + complete coverage)
psql -h localhost -p 5432 -U postgres -d IntegratedAccSys -f database/IntegratedAccSys_CompleteLogic.sql

# 4. Optional: append-only migrations
psql -h localhost -p 5432 -U postgres -d IntegratedAccSys -f database/migrations/2026_06_11_01_drop_legacy_auth_procedures.sql
```

**Migrations folder** (`database/migrations/`):
- `2026_06_11_01_drop_legacy_auth_procedures.sql` — drops 3 legacy auth procs
- `pre_cleanup_20260611_063502.sql` — pre-cleanup DB dump (recovery)

---

## Architecture Documents in this Folder

| File | Type | Purpose |
|------|------|---------|
| `IntegratedAccountsSystem_Architecture_Documentation.pdf` | PDF | Visual architecture export |
| `CMP_Comprehensive_Project_Map.pdf` | PDF | Comprehensive project map (SQL Server era — historical) |
| `CMP_Comprehensive_Project_Map_Report.pdf` | PDF | Duplicate export of project map |

---

## Related Documentation

- [`../CONVENTIONS.md`](../CONVENTIONS.md) — naming & structure rules (industry-standard)
- [`../ARCHITECTURE.md`](../ARCHITECTURE.md) — top-level architecture validation
- [`../WORKFLOW.md`](../WORKFLOW.md) — development workflow
- [`../CHANGELOG.md`](../CHANGELOG.md) — version history
- [`../audits/DEEP_ARCHITECTURE_DATABASE_AUDIT.md`](../audits/DEEP_ARCHITECTURE_DATABASE_AUDIT.md) — full DB + asset audit
- [`../audits/RESTRUCTURING_PLAN.md`](../audits/RESTRUCTURING_PLAN.md) — ongoing restructuring phases
- [`../audits/README.md`](../audits/README.md) — index of all audit reports
