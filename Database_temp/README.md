# 🌐 نظام المحاسبة المتكامل - Database Setup

A complete accounting system using C# and PostgreSQL 17, covering accounts, inventory, invoicing, reporting, and more.

---

## 🗄️ Database Name

`IntegratedAccSys`

---

## 📋 Database Objects

| Object Type | Count | Notes |
|---|---|---|
| Tables | 37 | Core domain tables |
| Views | 8 | Reporting views (vw_ActiveUsers, vw_AccountHierarchy, ...) |
| Functions | 16 | fn_GetAccountFullPath, fn_GetProductStock, fn_CalculateVat, ... |
| Procedures | 4 | sp_Login, sp_Logout, sp_ValidateSession, sp_ExpireOldSessions |
| Triggers | 4 | Password history rotation, stock validation, audit defaults |
| Indexes | 74 | Performance indexes on all FK and frequently queried columns |
| Constraints | 102 | PK, UK, FK, CHECK |

---

## 🔧 Setup Steps

### Option 1: Apply SQL Files (Recommended)

```bash
# 1. Create empty database
psql -h localhost -p 5432 -U postgres -d postgres -c "CREATE DATABASE IntegratedAccSys;"

# 2. Apply table schema
psql -h localhost -p 5432 -U postgres -d IntegratedAccSys -f Database/IntegratedAccSys_PostgreSQL.sql

# 3. Apply logic (views, functions, procedures, triggers, seed data)
psql -h localhost -p 5432 -U postgres -d IntegratedAccSys -f Database/IntegratedAccSys_PostgreSQL_Logic.sql
```

### Option 2: pg_dump Restore

```bash
psql -h localhost -p 5432 -U postgres -d postgres -c "CREATE DATABASE IntegratedAccSys;"
psql -h localhost -p 5432 -U postgres -d IntegratedAccSys -f Database/IntegratedAccSys_pg_dump.sql
```

### Option 3: pgAdmin GUI

1. Open pgAdmin → Connect to `localhost:5432`
2. Right-click **Databases** → **Create** → **Database**
3. Name: `IntegratedAccSys` → Save
4. Right-click `IntegratedAccSys` → **Restore** → Select `Database/IntegratedAccSys_pg_dump.sql`

---

## 🔐 Connection String

### PostgreSQL Mode (App.config)

```xml
<setting name="Mode" serializeAs="String">
    <value>SQL</value>
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
```

### C# Npgsql Connection String

```csharp
Host=localhost;Port=5432;Database=IntegratedAccSys;Username=postgres;Password=YOUR_PASSWORD;Include Error Detail=true;
```

---

## 🌱 Default Seed Data

The `IntegratedAccSys_PostgreSQL_Logic.sql` includes seed data:

| Category | Items |
|---|---|
| Branches | 3 (Main + Jeddah + Dammam) |
| Currencies | 5 (SAR, USD, EUR, AED, EGP) |
| Banks | 5 (SABB, SNB, RJHI, BSF, BAM) |
| Payment Methods | 7 (Cash, Bank Transfer, Check, Credit Card, Mada, etc.) |
| Funds | 4 (Cash Main, Jeddah, SABB, SNB) |
| Units | 12 (PCS, BOX, KG, G, L, ML, M, CM, SET, DOZ, PACK, ROLL) |
| Categories | 4 (Products, Services, Supplies, Spare Parts) |
| Payment Terms | 6 (Cash, Net 15/30/45/60/90) |
| Price Lists | 3 (Sales, Wholesale, Cost) |
| System Windows | 15 (SYS_MAIN, ACC_ACCOUNTS, INV_STORES, SALES, PURCHASES, etc.) |
| User Roles | 5 (ADMIN, MANAGER, ACCOUNTANT, SALES, STORE) |
| Default Admin | UserID: ADMIN, Password: Admin@123 |

---

## 🏗️ Database Architecture

```
┌─────────────────────────────────────────────────┐
│                 public schema                   │
├─────────────────────────────────────────────────┤
│ SECURITY DOMAIN                                 │
│   tblWindows → tblPrivileges → tblUserRoles    │
│   tblUsers ← tblUserRoleAssignments            │
│   tblSessions (token-based auth)               │
│   tblAuditLogs (comprehensive audit)          │
├─────────────────────────────────────────────────┤
│ SYSTEM CONFIGURATION                            │
│   tblBranches (multi-branch)                   │
│   tblCompanies, tblCurrencies                  │
│   tblBanks, tblFunds, tblCostCenters           │
│   tblPaymentMethods, tblPaymentTerms           │
│   tblPriceLists                                 │
├─────────────────────────────────────────────────┤
│ ACCOUNTING                                      │
│   tblAccounts (hierarchical chart)            │
│   tblJournalHeader/BondHeader                  │
│   tblJournalBody/BondBody                       │
├─────────────────────────────────────────────────┤
│ INVENTORY                                       │
│   tblCategories, tblUnits, tblStores           │
│   tblProducts, tblProductBatches               │
│   tblStoreProducts, tblProductPricing           │
│   tblProductMovement                            │
├─────────────────────────────────────────────────┤
│ TRANSACTIONS                                    │
│   tblCustomers, tblSuppliers                   │
│   tblOperationHeader (SALE/PURCHASE/...)       │
│   tblOperationBody, tblOperationTaxes          │
└─────────────────────────────────────────────────┘
```

---

## 🔍 Query Examples

```sql
-- Check all tables
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Check views
SELECT table_name FROM information_schema.views
WHERE table_schema = 'public';

-- Check functions
SELECT routine_name FROM information_schema.routines
WHERE routine_schema = 'public' AND routine_type = 'FUNCTION';

-- Check procedures
SELECT routine_name FROM information_schema.routines
WHERE routine_schema = 'public' AND routine_type = 'PROCEDURE';

-- Check triggers
SELECT trigger_name, event_object_table
FROM information_schema.triggers
WHERE trigger_schema = 'public';

-- Active users
SELECT * FROM vw_ActiveUsers;

-- Account hierarchy
SELECT * FROM vw_AccountHierarchy LIMIT 10;

-- Stock summary
SELECT * FROM vw_ProductStockSummary;
```

---

**Updated:** 2026-06-08 | PostgreSQL 17
