# 🏛️ Integrated Accounts System (IntegratedAccSys)

A complete accounting system using **C# / WinForms (.NET 8)** with **3-Tier Architecture** and **PostgreSQL 17**.

---

## 📁 Solution Structure

```text
IntegratedAccSys/
├── src/                                # Source projects (Tier Architecture)
│   ├── IntegratedAccSys.DAL/           # Data Access Layer (Class Library)
│   │   ├── clsCN.cs                    # PostgreSQL connection wrapper
│   │   ├── DbContext.cs                # Connection + transaction management
│   │   ├── DbContextProvider.cs        # Thread-safe singleton provider
│   │   └── DalSettings.cs              # DAL-layer config (env vars + AppSettings)
│   │
│   ├── IntegratedAccSys.BL/            # Business Logic Layer (Class Library)
│   │   ├── Constants.cs                # System constants & enums
│   │   ├── Accounts/clsAccounts.cs     # Chart of accounts logic
│   │   ├── Bonds/clsBonds.cs           # Bond / cheque management
│   │   ├── Journal/clsjournal.cs       # Journal entries + posting
│   │   ├── Purchases/clsPurchases.cs   # Supplier + purchase operations
│   │   ├── Sales/clsSales.cs           # Customer + sales operations
│   │   ├── Security/                   # Auth, hashing, sessions, privileges
│   │   ├── Stores/clsInventory.cs      # Inventory management
│   │   ├── SysFormat/clsSysFormat.cs   # System config (branches, banks, etc.)
│   │   └── Users/clsUsers.cs           # User auth + privilege management
│   │
│   └── IntegratedAccSys.PL/            # Presentation Layer (WinForms)
│       ├── Program.cs                  # Entry point
│       ├── frmMainWindow.cs            # Main MDI form
│       ├── Security/PrivilegeApplier.cs # PL-layer privilege applier
│       ├── Properties/Resources, Settings
│       ├── Accounts/, Bonds/, Journal/, Purchases/, Sales/, Stores/,
│       │   SysFormat/, Users/          # Form files
│       └── Reports/                    # RDLC + frmReportViewer
│
├── tests/                              # Test projects
│   └── IntegratedAccSys.DAL.DbTest/    # PostgreSQL connectivity test
│       └── Program.cs                  # Verifies DAL → PostgreSQL access
│
├── database/                           # PostgreSQL scripts
│   ├── IntegratedAccSys_PostgreSQL.sql        # Schema (tables, FKs, indexes)
│   ├── IntegratedAccSys_PostgreSQL_Logic.sql  # Views, functions, procedures, triggers
│   ├── IntegratedAccSys_pg_dump.sql           # Full DB dump (for restore)
│   ├── IntegratedAccSys_CompleteLogic.sql     # Combined logic
│   ├── IntegratedAccSys_Full.sql              # Combined full
│   ├── IntegratedAccSys.bak                   # SQL Server backup (legacy)
│   ├── setup.sql                              # Create empty DB
│   ├── verify_coverage.ps1                    # PowerShell coverage checker
│   └── README.md                              # Database setup guide
│
├── docs/                               # Documentation
│   └── ARCHITECTURE.md                 # Architecture validation report
│
├── scripts/                            # Utility scripts
│   └── start-db-test.bat               # Quick-start DbTest runner
│
├── .gitattributes
├── .gitignore
├── .github/                            # GitHub workflows
├── .vs/                                # Visual Studio cache
├── IntegratedAccSys.sln                # Solution file
└── README.md                           # This file
```

---

## 🏗️ Tier Architecture (PL → BL → DAL → PostgreSQL)

```text
┌────────────────────────┐
│ Presentation Layer (PL) │  Windows Forms, Reports, User Interaction
│   src/IntegratedAccSys.PL
└───────────┬────────────┘
            │ ProjectReference
            ▼
┌────────────────────────┐
│ Business Logic (BL)    │  Business Rules, Validation, Workflows
│   src/IntegratedAccSys.BL
└───────────┬────────────┘
            │ ProjectReference
            ▼
┌────────────────────────┐
│ Data Access (DAL)      │  Npgsql, SQL, Stored Procedures
│   src/IntegratedAccSys.DAL
└───────────┬────────────┘
            │ Npgsql
            ▼
┌────────────────────────┐
│ PostgreSQL 17          │  Tables, Views, Functions, Procedures, Triggers
│   database/ scripts
└────────────────────────┘
```

---

## 🚀 Quick Start

### 1. Database Setup

```cmd
# Create empty database
psql -h localhost -U postgres -c "CREATE DATABASE IntegratedAccSys;"

# Apply schema
psql -h localhost -U postgres -d IntegratedAccSys -f database/IntegratedAccSys_PostgreSQL.sql

# Apply logic (views, functions, procedures, triggers, seed data)
psql -h localhost -U postgres -d IntegratedAccSys -f database/IntegratedAccSys_PostgreSQL_Logic.sql
```

### 2. Build Solution

```cmd
dotnet build IntegratedAccSys.sln
```

### 3. Run Connectivity Test

```cmd
scripts\start-db-test.bat
```

### 4. Run Application

```cmd
dotnet run --project src/IntegratedAccSys.PL
```

### 5. Default Login

- **User:** `ADMIN`
- **Password:** `Admin@123`

---

## 🔧 Configuration

### PostgreSQL Connection (DAL Settings)

Override defaults via **Environment Variables**:

| Variable        | Default            | Description        |
| --------------- | ------------------ | ------------------ |
| `IAS_DB_MODE`   | `SQL`              | `SQL` or `Windows` |
| `IAS_DB_SERVER` | `localhost`        | PostgreSQL host    |
| `IAS_DB_PORT`   | `5432`             | PostgreSQL port    |
| `IAS_DB_NAME`   | `IntegratedAccSys` | Database name      |
| `IAS_DB_USER`   | `postgres`         | Username           |
| `IAS_DB_PWD`    | `postgres`         | Password           |

Example:

```cmd
set IAS_DB_SERVER=myserver.local
set IAS_DB_USER=app_user
set IAS_DB_PWD=secret123
```

---

## 📊 Architecture Validation

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the complete validation report with evidence.

**Key results:**

- ✅ 0 architectural violations
- ✅ Strict PL → BL → DAL only
- ✅ **Build: 0 Errors / 0 Warnings**
- ✅ **DbTest: 46/46 passing**
- ✅ PostgreSQL 17.10 reachable via DAL
- ✅ All DAL connectivity checks passed
- ✅ **5/5 CRITICAL ENTERPRISE gaps closed** (Roles, Security, MVs, Monitoring, Approvals)
- ✅ **6 audit scripts** in `scripts/audit-g*.ps1` — all pass:
  - `audit-g2-security.ps1`
  - `audit-g3-monitoring.ps1`
  - `audit-g4-constraints.ps1`
  - `audit-g5-indexes.ps1`
  - `audit-g7-materialized-views.ps1`
  - `audit-g10-approval-workflow.ps1`

---

## 🛠️ Technology Stack

- **.NET 8** (WinForms for PL, Class Libraries for BL & DAL)
- **C#** (latest nullable reference types)
- **PostgreSQL 17** (via Npgsql 8.0.4)
- **ReportViewerCore.WinForms 15.1.26** (RDLC reports)
- **System.Configuration.ConfigurationManager 8.0.1**

---

## 📜 License

Internal accounting system — proprietary.
