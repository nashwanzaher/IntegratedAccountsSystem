# Architecture — IntegratedAccountsSystem

> System architecture documentation organized by **3-tier layering** (PL / BL / DAL) plus the PostgreSQL database layer.

**Current Version:** v2.0.0 (PostgreSQL 17)  
**Date:** 2026-06-08  
**Framework:** .NET 8 WinForms | 3-Tier Architecture (PL → BL → DAL → DB)

---

## Tier Map

The codebase is split into four logical layers, each documented separately below.

```
┌─────────────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER (PL)                                        │
│  WinForms UI (28 forms)                                         │
│  Location: D:\source\IntegratedAccountsSystem\PL\              │
│  → See: §1 PL below                                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  BUSINESS LAYER (BL)                                            │
│  Domain logic + parameter preparation (13 C# files)             │
│  Location: D:\source\IntegratedAccountsSystem\BL\              │
│  → See: §2 BL below                                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  DATA ACCESS LAYER (DAL)                                        │
│  PostgreSQL access via Npgsql                                   │
│  Location: D:\source\IntegratedAccountsSystem\DAL\             │
│  → See: §3 DAL below                                           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  DATABASE (PostgreSQL 17)                                       │
│  37 tables │ 9 views │ 78 fns │ 63 SPs │ 4 triggers            │
│  Location: D:\source\IntegratedAccountsSystem\Database\        │
│  → See: §4 Database below                                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## §1 — Presentation Layer (PL)

**Location:** `D:\source\IntegratedAccountsSystem\PL\`  
**Forms:** 28 active (across 9 sub-folders)  
**Zero direct DB access.** Every form calls BL classes only.

| Sub-folder | Forms | Purpose |
|---|---|---|
| `PL/Accounts/` | 7 | Chart of accounts, trial balance, final accounts, account sheet |
| `PL/Bonds/` | 1 | Receipt/Payment vouchers |
| `PL/Journal/` | 2 | Journal entries, posting/unposting |
| `PL/Purchases/` | 4 | Purchase bills, returns, suppliers |
| `PL/Sales/` | 4 | Sales bills, returns, customers |
| `PL/stores/` | 7 | Categories, units, stores, products, inventory movement |
| `PL/SysFormat/` | 8 | Companies, banks, currencies, funds, backups, VAT settings |
| `PL/Users/` | 3 | Login, privileges, user management |
| `PL/Reports/` | 1 | RDLC report viewer (frmReportViewer) |

**Key pattern:** `grep "using System.Data.SqlClient" PL/**/*.cs` → **0 matches**.  
Migration to PostgreSQL needed **zero PL changes** — see `audits/PL_Migration_Report.md`.

---

## §2 — Business Layer (BL)

**Location:** `D:\source\IntegratedAccountsSystem\BL\`  
**Files:** 13 main + 4 helpers (`AuditHelper`, `PasswordHelper`, etc.)  
**Parameter binding:** All `NpgsqlParameter[]` (migrated from `SqlParameter[]` — 606 replacements).

| Folder | File | Purpose |
|---|---|---|
| `BL/Accounts/` | `clsAccounts.cs` | Chart of accounts CRUD |
| `BL/Bonds/` | `clsBonds.cs` | Receipt/Payment voucher logic |
| `BL/Journal/` | `clsJournal.cs` | Journal entries + posting |
| `BL/Purchases/` | `clsPurchases.cs` | Purchase bill logic |
| `BL/Sales/` | `clsSales.cs` | Sales bill logic |
| `BL/Stores/` | `clsInventory.cs`, `clsStores.cs`, `clsProducts.cs` | Inventory management |
| `BL/SysFormat/` | `clsCompanies.cs`, `clsBanks.cs`, `clsCurrencies.cs`, etc. | System config |
| `BL/Users/` | `clsUsers.cs`, `clsPrivileges.cs` | User mgmt + RBAC |
| `BL/Security/` | `AuditHelper.cs`, `PasswordHelper.cs`, `SessionHelper.cs` | Cross-cutting concerns |

**Key pattern:** BL never imports `Npgsql` directly — all DB calls go through `clsCN` or `DbContext`.

---

## §3 — Data Access Layer (DAL)

**Location:** `D:\source\IntegratedAccountsSystem\DAL\`  
**Files:** 3 (legacy + modern paths consolidated)

| File | Purpose |
|---|---|
| `DAL/clsCN.cs` | Connection wrapper, `ExecSP/ExecQuery/ExecScalar/ExecSPWithTrans` — legacy path |
| `DAL/DbContext.cs` | Explicit transactions (`BeginTransaction/Commit/Rollback`) — modern path |
| `DAL/DbContextProvider.cs` | Thread-safe singleton context provider |

**Key pattern:** Npgsql 8.0.4 is the only DB provider. Connection pooling is Npgsql default.  
**Known issue (from `audits/ARCH_AUDIT.md` §1.4):** two parallel DAL paths (`clsCN` + `DbContext`) should be consolidated in a future refactor.

---

## §4 — Database (PostgreSQL 17)

**Location:** `D:\source\IntegratedAccountsSystem\Database\`  
**Engine:** PostgreSQL 17 @ `localhost:5432`  
**Database:** `IntegratedAccSys`

| Schema file | Size | Purpose |
|---|---|---|
| `setup.sql` | 141 B | Quickstart — `CREATE DATABASE` only |
| `IntegratedAccSys_PostgreSQL.sql` | 30 KB | **Tables + constraints** (apply first) |
| `IntegratedAccSys_CompleteLogic.sql` | 72 KB | **Authoritative logic** — views, functions, SPs, triggers, seed (apply second) |
| `IntegratedAccSys_PostgreSQL_Logic.sql` | 40 KB | v1 logic — kept for reference only |
| `IntegratedAccSys_pg_dump.sql` | 90 KB | Full `pg_dump` — alternative restore path |
| `IntegratedAccSys_Full.sql` | 144 KB | Original SQL Server full script — historical |
| `IntegratedAccSys.bak` | 7.5 MB | SQL Server backup — historical |
| `verify_coverage.ps1` | 9.4 KB | **Active** — verifies 118/118 BL call sites match DB signatures |
| `README.md` | 6.8 KB | DB setup guide |

**Apply order (fresh install):**

```bash
psql -h localhost -p 5432 -U postgres -d IntegratedAccSys -f Database/IntegratedAccSys_PostgreSQL.sql
psql -h localhost -p 5432 -U postgres -d IntegratedAccSys -f Database/IntegratedAccSys_CompleteLogic.sql
```

---

## Architecture Documents in this Folder

| File | Type | Purpose |
|---|---|---|
| `Architecture.md` | Markdown | Authoritative 3-tier architecture doc (PL/BL/DAL/DB sections) |
| `IntegratedAccountsSystem_Architecture_Documentation.pdf` | PDF | PDF export of `Architecture.md` |
| `CMP_Comprehensive_Project_Map.pdf` | PDF | Comprehensive project map (SQL Server era — historical) |
| `CMP_Comprehensive_Project_Map_Report.pdf` | PDF | Duplicate export of project map |

> The two `CMP_Comprehensive_Project_Map*.pdf` files are byte-near-identical (49531 vs 49532 bytes). One is kept for archival, the other may be deleted in a future pass.

---

## Related Documentation

- [Audits & Reports](../audits/README.md) — `ARCH_AUDIT.md`, `FINAL_REPORT.md`, audit history
- [Presentation Slides](../presentation/) — Bilingual HTML slides
- [Project Root README](../README.md) — Entry point for the whole project
- [Changelog](../CHANGELOG.md) — Version history (v1.0 SQL Server → v2.0 PostgreSQL)
