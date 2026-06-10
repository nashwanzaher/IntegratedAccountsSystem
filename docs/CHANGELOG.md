# Changelog

All notable changes to the IntegratedAccountingSystem project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [2.0.0] - 2026-06-08 — PostgreSQL Migration

### 🎯 Major Change: SQL Server → PostgreSQL Migration

This is the most significant architectural change since the project's inception.

### Breaking Changes

| Component | Old | New |
|---|---|---|
| Database | SQL Server 2019 | **PostgreSQL 17** |
| Data Provider | `System.Data.SqlClient` 4.8.6 | **`Npgsql` 8.0.4** |
| Connection String | `server=...;database=...;integrated security=...` | `Host=...;Port=...;Database=...;Username=...;Password=...` |
| Parameters | `SqlParameter[]` | **`NpgsqlParameter[]`** |
| Connection per call | Open/close | Connection pooling (Npgsql default) |

### Added

- **PostgreSQL Database**: `IntegratedAccSys` created on localhost:5432
  - 37 tables with full constraint definitions
  - 8 reporting views (vw_ActiveUsers, vw_AccountHierarchy, vw_ProductStockSummary, etc.)
  - 16 database functions (fn_GetAccountFullPath, fn_CalculateVat, etc.)
  - 4 stored procedures (sp_Login, sp_Logout, sp_ValidateSession, sp_ExpireOldSessions)
  - 4 triggers (password history rotation, stock validation, audit defaults, operation ID generation)
  - 74 indexes for performance
  - Seed data: branches, currencies, banks, payment methods, units, categories, price lists, system windows, user roles, default admin

- **New Configuration**: `Port` setting in `App.config` (default: 5432)

- **PostgreSQL Schema Files**:
  - `Database/IntegratedAccSys_PostgreSQL.sql` — Tables + Constraints
  - `Database/IntegratedAccSys_PostgreSQL_Logic.sql` — Views + Functions + Procedures + Triggers + Seed Data
  - `Database/IntegratedAccSys_pg_dump.sql` — Full pg_dump of schema

- **DAL Migration**: `clsCN.cs`, `DbContext.cs`, `DbContextProvider.cs` rewritten to use Npgsql

- **BL Migration**: All 13 files converted from `SqlParameter` to `NpgsqlParameter` (606 total replacements)

- **csproj Update**: `System.Data.SqlClient` removed, `Npgsql` 8.0.4 added

- **App.config Update**: Mode set to "SQL", Server set to "localhost", Port added (5432), DB set to "IntegratedAccSys"

### Security

- PBKDF2-SHA256 password hashing (verified working with new schema columns)
- SQL injection validation in both `clsCN` and `DbContext`
- Session token management via `gen_random_uuid()` (PostgreSQL native)
- Generated columns for `AvailableCredit` (customers/suppliers)

### Documentation

- `README.md` — Complete rewrite (Arabic + English), PostgreSQL-focused
- `Database/README.md` — Database setup guide with pgAdmin instructions
- `Architecture.md` — Comprehensive system architecture (NEW)
- `BL_Audit_Report.md` — Business Layer audit findings
- `PL_Migration_Report.md` — Presentation Layer analysis (zero changes required)
- `CHANGELOG.md` — This file (NEW)
- `DELIVERY_SUMMARY.md` — Migration summary (NEW)
- `FINAL_REPORT.md` — Comprehensive migration report (NEW)

### Architecture Improvements

- **Two connection paths consolidated** (clsCN legacy + DbContext modern) — note: both remain, pick one as canonical in future
- **Transaction support** via `DbContext.BeginTransaction/CommitTransaction/RollbackTransaction`
- **Thread-safe connection management** via `DbContextProvider` singleton
- **Parameter type mapping** documented for all SqlDbType → NpgsqlDbType conversions

### Migration Notes

- PL layer required **zero code changes** — architecture validated ✅
- BL layer required **606 parameter type replacements** — automated via PowerShell
- Original SQL Server SP set was incomplete (12 SPs in script vs ~90 called by BL) — gap documented
- Audit table schema simplified vs original — extension recommended in Phase 2
- Trigger for OperationID generation disabled (column is NOT NULL, must be set by app layer)

---

## [1.0.0] - 2025-01-19 — SQL Server Baseline

### Added

- Initial release with SQL Server 2019
- Full 3-tier architecture (PL/BL/DAL)
- 37 tables covering: Security, Configuration, Accounting, Inventory, Transactions
- PBKDF2-SHA256 password hashing with 3-tier authentication
- Comprehensive audit logging (AuditHelper)
- Session management with token-based auth
- RBAC privilege system (Windows, Roles, Privileges)
- 9 RDLC reports
- Multi-branch support
- Multi-currency support
- 28 WinForms forms

### Security Fixes Applied (2025-01-14)

- Plaintext password detection logging (Tier 3 → AuditHelper.LogSecurityWarning)
- SQL injection protection via ValidateStoredProcedureCall() in clsCN
- DPAPI encryption for credentials in Properties/Settings.Designer.cs

---

## Migration Guide: v1.x → v2.0

### For existing SQL Server installations

1. **Backup your SQL Server database** before any migration steps
2. **Export data** if you need to preserve existing records
3. **Create PostgreSQL database**:

   ```sql
   CREATE DATABASE IntegratedAccSys;
   ```

4. **Apply schema**:

   ```bash
   psql -h localhost -p 5432 -U postgres -d IntegratedAccSys -f Database/IntegratedAccSys_PostgreSQL.sql
   psql -h localhost -p 5432 -U postgres -d IntegratedAccSys -f Database/IntegratedAccSys_PostgreSQL_Logic.sql
   ```

5. **Migrate user passwords**: Users with PBKDF2 hashes will work directly. Legacy users will auto-upgrade on first login.
6. **Update App.config** connection settings
7. **Build**: `dotnet build`
8. **Test**: Login with ADMIN / Admin@123

### For new installations

Follow the Quick Setup section in `README.md`.

---

**Next Phase Recommendations:**

- Phase 2: Port the missing ~90 stored procedures (see BL_Audit_Report.md §6)
- Phase 3: Add `addAuditLog` procedure to match AuditHelper expectations
- Phase 4: Consolidate clsCN + DbContext into a single canonical DAL entry point
