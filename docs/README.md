# 📊 نظام المحاسبة المتكامل | Integrated Accounting System

> **Current Version:** v2.0.0 (PostgreSQL 17)
> **Updated:** 2026-06-08
> **Previous:** v1.x (SQL Server 2019)

نظام محاسبي متكامل يدعم الحسابات، المخازن، المشتريات، المبيعات، صلاحيات المستخدم، وإعدادات النظام. مصمم للعمل في بيئة حديثة باستخدام:

A comprehensive accounting system supporting accounts, inventory, purchases, sales, user permissions, and system settings, designed to work on a modern environment using:

- **.NET 8** (WinForms)
- **Visual Studio 2022**
- **PostgreSQL 17** ← *(previously SQL Server 2019)*
- **RDLC Reports**
- **Npgsql 8.0** ← *(previously System.Data.SqlClient)*

---

## 🚩 الميزات الرئيسية | Key Features

- ✅ إدارة الحسابات المالية (رئيسية وفرعية) | Manage financial accounts (main and sub-accounts)
- ✅ إدارة المخازن مع دعم متعدد الفروع | Inventory management with multi-branch support
- ✅ المشتريات والمبيعات مع التحكم الكامل | Purchases and sales with full control
- ✅ صلاحيات المستخدمين (RBAC) | User permissions for role-based access control
- ✅ PBKDF2-SHA256 لتشفير كلمات المرور | PBKDF2-SHA256 password hashing
- ✅ نظام جلسات آمن مع token-based auth | Session management with token-based auth
- ✅ تدقيق شامل (Audit Logging) | Comprehensive audit logging
- ✅ إعدادات النظام مرنة | Flexible system settings
- ✅ متعدد العملات | Multi-currency support
- ✅ متعدد الوحدات | Multi-unit support
- ✅ تقارير RDLC مع التصدير | Dynamic RDLC reports with PDF and Excel export
- ✅ متعدد الفروع | Multi-branch support
- ✅ واجهة مستخدم سهلة | User-friendly interface

---

## 🗄️ قاعدة البيانات | Database

**Engine:** PostgreSQL 17 (previously SQL Server 2019)

```
Database: IntegratedAccSys
Host:     localhost
Port:     5432
User:     postgres
```

### Quick Setup

```bash
# 1. Ensure PostgreSQL 17 is running on port 5432
# 2. Apply the schema:
psql -h localhost -p 5432 -U postgres -d IntegratedAccSys -f Database/IntegratedAccSys_PostgreSQL.sql
psql -h localhost -p 5432 -U postgres -d IntegratedAccSys -f Database/IntegratedAccSys_PostgreSQL_Logic.sql

# Or use pg_dump restore:
psql -h localhost -p 5432 -U postgres -d IntegratedAccSys -f Database/IntegratedAccSys_pg_dump.sql
```

### Database Structure

| Category | Tables | Description |
|---|---|---|
| Security | 5 | tblUsers, tblSessions, tblPrivileges, tblWindows, tblAuditLogs |
| Configuration | 7 | tblBranches, tblCompanies, tblCurrencies, tblBanks, tblFunds, tblCostCenters, tblPaymentMethods, tblPaymentTerms |
| Accounting | 5 | tblAccounts, tblJournalHeader, tblJournalBody, tblBondHeader, tblBondBody |
| Inventory | 7 | tblCategories, tblUnits, tblStores, tblProducts, tblProductBatches, tblStoreProducts, tblProductMovement |
| Transactions | 7 | tblCustomers, tblCustomerContacts, tblSuppliers, tblSupplierContacts, tblOperationHeader, tblOperationBody, tblOperationTaxes |

**Total: 37 tables, 8 views, 16 functions, 4 procedures, 4 triggers, 74 indexes**

---

## 🔧 متطلبات النظام | System Requirements

- .NET 8 SDK
- Visual Studio 2022 or later
- PostgreSQL 17 (or 15/16 with minor adjustments)
- Windows OS (WinForms)

---

## 🚀 كيفية الإعداد والتشغيل | Setup and Run

### 1. Database Setup

```bash
# Restore from backup (if you have data)
pg_restore -h localhost -p 5432 -U postgres -d IntegratedAccSys -c database/IntegratedAccSys.bak

# Or create fresh from SQL files:
psql -h localhost -p 5432 -U postgres -d postgres -c "CREATE DATABASE IntegratedAccSys;"
psql -h localhost -p 5432 -U postgres -d IntegratedAccSys -f database/IntegratedAccSys_PostgreSQL.sql
psql -h localhost -p 5432 -U postgres -d IntegratedAccSys -f database/IntegratedAccSys_PostgreSQL_Logic.sql
```

### 2. Configure Connection

Edit `App.config`:

```xml
<IntegratedAccSys.Properties.Settings>
  <setting name="Mode" serializeAs="String">
    <value>SQL</value>  <!-- "SQL" = PostgreSQL authentication -->
  </setting>
  <setting name="Server" serializeAs="String">
    <value>localhost</value>
  </setting>
  <setting name="Port" serializeAs="String">
    <value>5432</value>
  </setting>
  <setting name="DB" serializeAs="String">
    <value>IntegratedAccSys</value>
  </setting>
  <setting name="ID" serializeAs="String">
    <value>postgres</value>
  </setting>
  <setting name="PWD" serializeAs="String">
    <value>YOUR_PASSWORD</value>
  </setting>
</IntegratedAccSys.Properties.Settings>
```

### 3. Build and Run

```bash
cd D:\source\IntegratedAccountsSystem
dotnet restore
dotnet build
dotnet run
```

### 4. Default Login

```
UserID:  ADMIN
Password: Admin@123
```

⚠️ **Important:** Change the admin password on first login.

---

## 📁 هيكل المشروع | Project Structure

```
IntegratedAccountsSystem/
├── PL/              # Presentation Layer (WinForms UI) — 28 forms
├── BL/              # Business Logic Layer — 13 files
├── DAL/             # Data Access Layer (Npgsql) — 3 files
├── Reports/         # RDLC report definitions (9 .rdlc)
├── database/        # PostgreSQL schema files (lowercase canonical)
│   ├── README.md
│   ├── setup.sql                          # Quickstart CREATE DATABASE
│   ├── IntegratedAccSys_PostgreSQL.sql    # Tables + Constraints
│   ├── IntegratedAccSys_CompleteLogic.sql # Authoritative logic
│   ├── IntegratedAccSys_PostgreSQL_Logic.sql  # v1 logic (reference)
│   ├── IntegratedAccSys_pg_dump.sql       # Full pg_dump
│   ├── IntegratedAccSys_Full.sql          # Original SQL Server (historical)
│   ├── IntegratedAccSys.bak               # SQL Server backup (historical)
│   └── verify_coverage.ps1                # BL/DB signature verifier
├── docs/            # Documentation (organized — see below)
│   ├── README.md                          # This file
│   ├── CHANGELOG.md                       # Version history
│   ├── architecture/                      # PL/BL/DAL architecture docs
│   │   ├── README.md                      # Tier map + per-layer inventory
│   │   ├── Architecture.md
│   │   └── *.pdf
│   ├── audits/                            # Audit & migration reports
│   │   ├── README.md
│   │   ├── FINAL_REPORT.md                # Consolidated v1+v2+v3
│   │   ├── ARCH_AUDIT.md
│   │   ├── PL_Migration_Report.md
│   │   ├── BL_Audit_Report.md
│   │   ├── SECURITY_AUDIT_REPORT.md
│   │   └── historical/                    # Pre-PostgreSQL reports
│   ├── presentation/                      # HTML slides
│   └── slides/                            # PNG slide images
└── App.config       # Connection configuration
```

---

## 🔐 الأمان | Security

- PBKDF2-SHA256 password hashing (100,000 iterations)
- Session tokens (UUID) with 8-hour expiry
- Login attempt lockout (5 failed → 30 min)
- Comprehensive audit logging
- Row-level privilege system (CanAdd/CanEdit/CanDelete/CanPrint/CanExport/CanApprove/CanPost)
- Default-deny privilege enforcement

---

## 📋 التقارير | Reports

Located in `Reports/`:

- rptAccountSheet.rdlc
- rptBillBond.rdlc
- rptBonds.rdlc
- rptChartOfAccounts.rdlc
- rptFinalAccounts.rdlc
- rptInventoryMovement.rdlc
- rptJournalEntery.rdlc
- rptProductsInventory.rdlc
- rptTrailBalance.rdlc

---

## 📚 التوثيق | Documentation

### Top-Level Docs (in this folder)

| File | Description |
|---|---|
| `README.md` | This file (entry point) |
| `CHANGELOG.md` | Version history (v1 SQL Server → v2 PostgreSQL) |

### Architecture (organized by PL / BL / DAL tiers)

See **[`ARCHITECTURE.md`](ARCHITECTURE.md)** — the authoritative 3-tier architecture validation report with evidence.

Supplementary PDFs in [`architecture/`](architecture/):

| File | Description |
|---|---|
| `architecture/README.md` | Tier map + per-layer file inventory |
| `architecture/*.pdf` | PDF exports of the architecture doc |

### Audits & Reports

See **[`audits/README.md`](audits/README.md)** for full index.

| File | Description |
|---|---|
| `audits/FINAL_REPORT.md` | Consolidated PostgreSQL migration report (v1+v2+v3) |
| `audits/ARCH_AUDIT.md` | Latest architecture audit (2026-06-08) — 15 findings |
| `audits/PL_Migration_Report.md` | PL layer analysis — 0 changes needed |
| `audits/BL_Audit_Report.md` | Business Layer pre-migration audit |
| `audits/SECURITY_AUDIT_REPORT.md` | Security findings and fixes |
| `audits/historical/` | Pre-PostgreSQL (SQL Server era) reports |

### Other

| File | Description |
|---|---|
| `presentation/` | Bilingual HTML slides (12 slides) |
| `slides/` | Pre-rendered slide PNG images |
| `../database/README.md` | Database setup guide |
| `../database/verify_coverage.ps1` | 118/118 BL↔DB signature verifier |

---

## 🔄 Migration Notes (v1 → v2)

| Item | Old (SQL Server) | New (PostgreSQL) |
|---|---|---|
| Provider | System.Data.SqlClient 4.8.6 | Npgsql 8.0.4 |
| Connection String | `Data Source=...;Initial Catalog=...` | `Host=...;Port=...;Database=...` |
| Parameter Syntax | `SqlParameter("@name", ...)` | `NpgsqlParameter("@name", ...)` (same in Npgsql) |
| Max Connections | per-call open/close | Connection pooling via Npgsql |
| Transactions | implicit per-call | explicit via `DbContext.BeginTransaction()` |

**Breaking changes:** `SqlParameter` replaced with `NpgsqlParameter` in all BL files. PL unchanged.

---

**Last Updated:** 2026-06-08
**Maintainer:** IntegratedAccSys Team
