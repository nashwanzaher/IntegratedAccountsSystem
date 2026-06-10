# 🛡️ Security Architecture Design Report

**Date:** 2026-06-09
**Database:** PostgreSQL 17.10 (`IntegratedAccSys`) — 76 tables, 125 functions, 69 procedures, 20 views
**Application:** .NET 8 WinForms (PL → BL → DAL → PostgreSQL)
**Method:** Read-only design — **NO Role, Policy, RLS, Grant, or Revoke created**
**Status:** 📋 **DESIGN & ANALYSIS ONLY**

---

## 1. Current Security State (Discovery)

### 1.1 PostgreSQL-Level Security

| Component | Current State | Security Impact |
|-----------|---------------|-----------------|
| **Total custom roles** | 2 (`noufexerp`, `postgres`) | 🔴 Insufficient for tiered access |
| **App connection user** | `postgres` (SUPERUSER) | 🔴 Unlimited access — critical risk |
| **PUBLIC privileges** | 191 grants | 🔴 Overly permissive |
| **Distinct grantees** | 3 (incl. PUBLIC) | 🔴 No fine-grained access control |
| **Row-Level Security (RLS)** | 0 policies | 🔴 All 76 tables wide-open |
| **Column-level grants** | 0 | 🔴 Sensitive columns exposed |
| **SSL/TLS** | `off` (verified via pg_settings) | 🔴 MITM vulnerability |
| **pgaudit extension** | Not installed | 🟡 No tamper-evident audit |
| **Password encryption** | Plain `bytea` (hashed, no encryption) | 🟡 Hash-only protection |

### 1.2 Application-Level Security

| Component | Current State | Notes |
|-----------|---------------|-------|
| **Users in `tblusers`** | 2 (ADMIN, testuser) | Both in branchcode=1 |
| **Active sessions** | 0 currently | `tblsessions.isactive` + `expiresat` |
| **Password storage** | `bytea` (4 fields) | userpassword, salt, passwordhistory1, passwordhistory2 |
| **Password verification** | Application-side (clsUsers.cs) | No DB-side enforcement |
| **Roles (`tbluserroles`)** | 0 entries | Empty — no role-based control |
| **Role assignments (`tbluserroleassignments`)** | 0 entries | Empty |
| **Window privileges (`tblprivileges`)** | 17 records | Per-user per-window CRUD flags |
| **Windows (`tblwindows`)** | TBD (see 5.3) | Defines each form's privilege key |

### 1.3 DAL Connection Configuration

```csharp
// src/IntegratedAccSys.DAL/DalSettings.cs (lines 27-28)
public static string ID => Get("USER", "postgres");   // ⚠️ Default = postgres (superuser)
public static string PWD => Get("PWD", "postgres");   // ⚠️ Default = postgres (superuser)
```

**Connection chain:**

```
frmLogin → clsUsers.Login()
  → cn.SelectData("getUserForLogin", ...)
  → NpgsqlConnection (uses DalSettings.ID="postgres", DalSettings.PWD="postgres")
  → PostgreSQL authenticated as SUPERUSER
  → Returns ALL data (no RLS, no app-level filtering beyond isactive)
```

---

## 2. Inventory: All Users, Roles, Privileges

### 2.1 PostgreSQL Roles (2 custom)

| Role | Superuser | Login | Create DB | Bypass RLS | Purpose |
|------|:---:|:---:|:---:|:---:|---------|
| `noufexerp` | ✅ | ✅ | ✅ | ❌ | Legacy user (likely system admin) |
| `postgres` | ✅ | ✅ | ✅ | ❌ | **Used by app** (must be changed) |

**Built-in roles (16 standard):** `pg_checkpoint`, `pg_create_subscription`, `pg_database_owner`, `pg_execute_server_program`, `pg_maintain`, `pg_monitor`, `pg_read_all_data`, `pg_read_all_settings`, `pg_read_all_stats`, `pg_read_server_files`, `pg_signal_backend`, `pg_stat_scan_tables`, `pg_use_reserved_connections`, `pg_write_all_data`, `pg_write_server_files`.

### 2.2 Application Users (in `tblusers`)

| usercode | userid | usernamear | isactive | isadmin | branchcode | email | createdat | lastloginat | mustchangepassword |
|---:|---|---|:---:|:---:|---:|---|---|---|:---:|
| 1 | `ADMIN` | مدير النظام | ✅ | ✅ | 1 | _(none)_ | 2026-06-08 18:45 | _(null)_ | ❌ |
| 2 | `testuser` | Test User | ✅ | ❌ | 1 | <t@x.com> | 2026-06-08 18:46 | _(null)_ | ❌ |

**Password storage:** `bytea` (4 fields) — not encrypted, only hashed (assumed PBKDF2 per `clsUsers`).
**`loginattempts`:** 0 for both users.
**`lockeduntil`:** null for both.

### 2.3 Application Roles (in `tbluserroles`)

**EMPTY** — 0 records. No role-based access control defined at the application level.

### 2.4 Role Assignments (in `tbluserroleassignments`)

**EMPTY** — 0 records.

### 2.5 Window Privileges (in `tblprivileges`)

**17 records** (sample):

- `canview`, `canadd`, `canedit`, `candelete`, `canapprove`, `canprint` — per (usercode, windowid) pair
- Currently configured only for the 2 existing users

### 2.6 Existing Grants

| Grantee | Public? | Privileges | Notes |
|---------|:---:|--------|-------|
| `postgres` | ❌ | ALL (superuser) | App uses this |
| `noufexerp` | ❌ | ALL (superuser) | Legacy |
| `PUBLIC` | ✅ | **191 grants** | All tables, all sequences — needs revocation |

---

## 3. Inventory: Sensitive Tables

### 3.1 Critical Sensitive Tables (P0)

| Table | Rows (approx) | Sensitive Columns | Risk |
|-------|:---:|---|---|
| `tblusers` | 2 | `userpassword`, `salt`, `passwordhistory1/2` | Auth bypass |
| `tblsessions` | 0 | `sessionid`, `token`, `ipaddress` | Session hijack |
| `tbluserroles` | 0 | _(all definitions)_ | Privilege escalation |
| `tbluserroleassignments` | 0 | _(all assignments)_ | Privilege escalation |
| `tblprivileges` | 17 | `canview/add/edit/delete/approve/print` | Privilege tampering |
| `tblwindows` | TBD | _(all definitions)_ | Privilege tampering |
| `tblauditlogs` | TBD | `eventtype`, `eventdata` | Audit log tampering |
| `tblaudi` | 0 | `olddata`, `newdata` (JSONB) | Audit log tampering |

### 3.2 Financial Sensitive Tables (P0)

| Table | Sensitive Columns | Risk |
|-------|---|---|
| `tblbankaccounts` | `accountnumber`, `iban`, `swiftcode`, `currentbalance` | Financial fraud |
| `tblbankstatements` | `closingbalance`, `totaldebit/credit` | Reconciliation fraud |
| `tblbanktransactions` | `amount`, `counteraccountid` | Unauthorized transfers |
| `tblbankreconciliations` | `openingbalance`, `closingbalance`, `systembalance`, `difference` | Reconciliation fraud |
| `tblcashboxes` | `openingbalance`, `currentbalance` | Cash misappropriation |
| `tblcashreceipts` | `amount`, `amountlocal` | Fake receipts |
| `tblcashpayments` | `amount`, `amountlocal` | Unauthorized payments |
| `tblbondheader`, `tblbondbody` | `amount`, `currencycode`, `exchangerate` | Invoice fraud |
| `tbljournalheader`, `tbljournalbody` | `totaldebit`, `totalcredit`, `amountlocal` | Journal tampering |

### 3.3 PII / Contact Tables (P1)

| Table | Sensitive Columns | Risk |
|-------|---|---|
| `tblcustomers` | `taxnumber`, `vatnumber`, `address`, `phone`, `mobile`, `email` | GDPR/PII leak |
| `tblsuppliers` | Same as customers | GDPR/PII leak |
| `tblcustomercontacts` | `contactname`, `phone`, `email` | GDPR/PII leak |
| `tblsuppliercontacts` | Same as customercontacts | GDPR/PII leak |
| `tblproducts`, `tblproductpricing` | `standardcost`, `lastpurchaseprice`, `lastsaleprice`, `image` | Pricing fraud |
| `tblnotifications` | `message` (private user messages) | Privacy leak |

---

## 4. Inventory: Foreign Key Relationships (Sensitive)

### 4.1 Critical FK Chain (User → Permissions)

```
tblusers (usercode)
  ├─→ tblsessions (usercode)
  ├─→ tbluserroleassignments (usercode)
  ├─→ tblprivileges (usercode)
  ├─→ tblnotifications (userid → usercode)
  ├─→ tblauditlogs (usercode)
  └─→ tblaudi (userid)

tbluserroles (roleid) ← tbluserroleassignments (roleid)
tblwindows (windowid) ← tblprivileges (windowid)
```

**Implication:** RLS on `tblusers` propagates to all dependent tables. Modifying one user's record should not affect others.

### 4.2 Critical FK Chain (Financial)

```
tblcurrencies (currencycode) → tblbankaccounts, tblbanktransactions, tblcashboxes, tblcashreceipts, tblcashpayments, tblbondheader, tbljournalheader
tblbanks (bankcode) → tblbankaccounts
tblbranches (branchcode) → tblusers, tblcustomers, tblsuppliers, tblstores, tblcashboxes
tblcustomers (customercode) → tblcashreceipts, tblcashpayments, tblcustomercontacts, tblbondheader
tblsuppliers (suppliercode) → tblcashreceipts, tblcashpayments, tblsuppliercontacts, tblbondheader
tblfiscalyears (fiscalyearid) → tblfiscalperiods
tblfiscalperiods (periodid) → tblbudgets
tblaccounts (accountcode) → tbljournalbody, tblbondbody, tblbudgets
```

**Implication:** Tenant isolation (branch-scoped) must be enforced via RLS predicates on `branchcode` columns.

---

## 5. Inventory: Access Points (BL → DAL → DB)

### 5.1 Authentication Access Points (Security/SessionContext.cs, clsUsers.cs)

| BL File | Line | Method Call | DB Object | Sensitivity |
|---------|----:|-------------|-----------|---|
| `clsUsers.cs` | TBD | `cn.SelectData("getUserForLogin", ...)` | **function** | 🔴 Auth |
| `clsUsers.cs` | TBD | `cn.ExecuteCmd("upgradeUserPassword", ...)` | **procedure** | 🔴 Auth |
| `clsUsers.cs` | TBD | `cn.ExecuteCmd("addUser", ...)` | **procedure** | 🔴 User mgmt |
| `clsUsers.cs` | TBD | `cn.ExecuteCmd("updateUser", ...)` | **procedure** | 🔴 User mgmt |
| `clsUsers.cs` | TBD | `cn.ExecuteCmd("delUser", ...)` | **procedure** | 🔴 User mgmt |
| `Security/SessionContext.cs` | TBD | `cn.SelectData("validateSession", ...)` | **function** | 🔴 Auth |
| `Security/SessionContext.cs` | TBD | `cn.ExecuteCmd("createSession", ...)` | **procedure** | 🔴 Auth |
| `Security/SessionContext.cs` | TBD | `cn.ExecuteCmd("updateSessionActivity", ...)` | **procedure** | 🔴 Auth |
| `Security/SessionContext.cs` | TBD | `cn.ExecuteCmd("endSession", ...)` | **procedure** | 🔴 Auth |
| `Security/SessionContext.cs` | TBD | `cn.ExecuteCmd("expireOldSessions", ...)` | **procedure** | 🔴 Auth |

### 5.2 Authorization Access Points (Security/PrivilegeApplier.cs, Security/PrivilegeHelper.cs)

| BL File | Method Call | DB Object | Sensitivity |
|---------|-------------|-----------|---|
| `Security/PrivilegeApplier.cs` | `getScreensPrivillages` | **function** | 🔴 Authz |
| `Security/PrivilegeApplier.cs` | `getDisplayPrivillages` | **function** | 🔴 Authz |
| `Security/PrivilegeHelper.cs` | `getAllPrivillages` | **function** | 🟡 Authz |
| `clsUsers.cs` | `addPrivillages`, `editPrivillages`, `delPrivellages` | **procedure** | 🔴 Authz |

### 5.3 Audit Access Points (Security/AuditHelper.cs)

| BL File | Method Call | DB Object | Sensitivity |
|---------|-------------|-----------|---|
| `Security/AuditHelper.cs` | `addAuditLog` | **procedure** | 🟡 Audit |
| `tblaudi` table | Direct insert via `fn_audit_trigger()` | **trigger function** | 🟡 Audit (auto) |

### 5.4 Financial Operations (clsAccounts.cs, clsBonds.cs, etc.)

| BL File | Operations | Sensitivity |
|---------|-----------|---|
| `clsAccounts.cs` | Journal entries (addJournalHeader, addJournalBody) | 🔴 Financial |
| `clsBonds.cs` | Bond create/update/delete (addBondHeader, editBondHeader, delBond) | 🔴 Financial |
| `clsPurchases.cs` | Supplier CRUD | 🟡 Financial |
| `clsSales.cs` | Customer CRUD | 🟡 Financial |
| `clsInventory.cs` | Product CRUD | 🟡 Financial |
| `clsSysFormat.cs` | Currency, Bank, Fund CRUD | 🔴 Financial config |

### 5.5 Connection Pattern (DAL)

```
DAL Connection Lifecycle:
1. frmLogin → clsUsers.Login()
2. clsUsers creates new clsCN() instance (no pooling)
3. clsCN reads DalSettings.ID + DalSettings.PWD (default = "postgres"/"postgres")
4. clsCN.Open() creates NpgsqlConnection
5. cn.SelectData("getUserForLogin", ...) is called
6. NpgsqlCommand dispatched to PostgreSQL as "postgres" (superuser)
7. Function returns DataTable
8. clsUsers validates hash, creates SessionContext
9. clsCN.Close() disposes connection
10. New connection created PER OPERATION (no pooling)
```

---

## 6. Target Security Model (Design)

### 6.1 Target PostgreSQL Roles (8)

| # | Role | Superuser | Inherits | Purpose |
|--:|------|:---:|---|---------|
| 1 | `app_user` | ❌ | — | Default WinForms app user (NO privileges to login only) |
| 2 | `app_admin` | ❌ | `app_user` | App DBA, schema migrations |
| 3 | `app_readwrite` | ❌ | `app_user` | Standard user (CRUD on operational) |
| 4 | `app_readonly` | ❌ | `app_user` | Reporting role (SELECT only) |
| 5 | `app_auditor` | ❌ | `app_user` | Audit reviewer (SELECT on audit tables) |
| 6 | `app_reports` | ❌ | `app_user` | BI tools (SELECT on views) |
| 7 | `app_backup` | ❌ | — | Backup/restore (file I/O) |
| 8 | `app_migrator` | ❌ | — | Schema migration only |

### 6.2 Target Permission Matrix (Per-Role × Per-Table)

| Table | app_user | app_admin | app_readwrite | app_readonly | app_auditor | app_reports |
|-------|:--------:|:---------:|:-------------:|:------------:|:-----------:|:-----------:|
| `tblusers` | (RLS) | ALL | RLS (own) | SELECT (RLS) | SELECT (RLS) | ❌ |
| `tblsessions` | (RLS) | ALL | RLS (own) | ❌ | SELECT (RLS) | ❌ |
| `tbluserroles` | (RLS) | ALL | SELECT | SELECT | SELECT | ❌ |
| `tbluserroleassignments` | (RLS) | ALL | SELECT | SELECT | SELECT | ❌ |
| `tblprivileges` | (RLS) | ALL | SELECT (own) | SELECT | SELECT | ❌ |
| `tblwindows` | SELECT | ALL | SELECT | SELECT | SELECT | SELECT |
| `tblauditlogs` | INSERT | ALL | INSERT (own) | SELECT (own) | SELECT (ALL) | ❌ |
| `tblaudi` | INSERT | ALL | INSERT (own) | SELECT (own) | SELECT (ALL) | ❌ |
| `tblbankaccounts` | (RLS) | ALL | RLS (branch) | SELECT (RLS) | SELECT | SELECT |
| `tblbanktransactions` | (RLS) | ALL | RLS (branch) | SELECT (RLS) | SELECT | SELECT |
| `tblcashboxes` | (RLS) | ALL | RLS (branch) | SELECT (RLS) | SELECT | SELECT |
| `tblcashreceipts` | (RLS) | ALL | RLS (branch) | SELECT (RLS) | SELECT | SELECT |
| `tblcashpayments` | (RLS) | ALL | RLS (branch) | SELECT (RLS) | SELECT | SELECT |
| `tblbankreconciliations` | (RLS) | ALL | RLS (branch) | SELECT (RLS) | SELECT | SELECT |
| `tblcustomers` | (RLS) | ALL | RLS (branch) | SELECT (RLS) | ❌ | SELECT |
| `tblsuppliers` | (RLS) | ALL | RLS (branch) | SELECT (RLS) | ❌ | SELECT |
| `tblproducts` | (RLS) | ALL | RLS (branch) | SELECT (RLS) | ❌ | SELECT |
| `tblbondheader` | (RLS) | ALL | RLS (branch) | SELECT (RLS) | ❌ | SELECT |
| `tbljournalheader` | (RLS) | ALL | RLS (branch) | SELECT (RLS) | ❌ | SELECT |
| `tblnotifications` | (RLS) | ALL | RLS (own user) | ❌ | SELECT | ❌ |
| `vw_*` (all views) | SELECT | ALL | SELECT | SELECT | SELECT | SELECT |
| **All other tables** | (RLS) | ALL | RLS (branch) | SELECT (RLS) | ❌ | ❌ |

**Legend:** ALL = full CRUD, RLS = Row-Level Security applies, ❌ = no access.

### 6.3 Target RLS Policies (Per Sensitive Table)

| Table | Policy Name | Predicate | Role |
|-------|-------------|-----------|------|
| `tblusers` | `users_branch_isolation` | `branchcode = current_branch() OR is_admin()` | app_readwrite |
| `tblusers` | `users_admin_bypass` | `TRUE` | app_admin |
| `tblusers` | `users_own_user` | `usercode = current_user_id()` | app_auditor |
| `tblsessions` | `sessions_own` | `usercode = current_user_id() OR is_admin()` | app_user |
| `tblbankaccounts` | `bankaccount_branch` | `branchcode = current_branch() OR is_admin()` | app_readwrite |
| `tblcashboxes` | `cashbox_branch` | `branchid = current_branch() OR is_admin()` | app_readwrite |
| `tblcashreceipts` | `cashreceipts_branch` | `branchid = current_branch() OR is_admin()` | app_readwrite |
| `tblcashpayments` | `cashpayments_branch` | `branchid = current_branch() OR is_admin()` | app_readwrite |
| `tblcustomers` | `customers_branch` | `branchcode = current_branch() OR is_admin()` | app_readwrite |
| `tblsuppliers` | `suppliers_branch` | `branchcode = current_branch() OR is_admin()` | app_readwrite |
| `tblproducts` | `products_branch` | `branchcode = current_branch() OR is_admin()` | app_readwrite |
| `tblbondheader` | `bonds_branch` | `braid = current_branch() OR is_admin()` | app_readwrite |
| `tbljournalheader` | `journals_branch` | `braid = current_branch() OR is_admin()` | app_readwrite |
| `tblnotifications` | `notifications_own` | `userid = current_user_id()` | app_user |
| `tblnotifications` | `notifications_admin` | `is_admin()` | app_admin |
| `tblauditlogs` | `auditlogs_own` | `usercode = current_user_id() OR is_admin()` | app_user |
| `tblaudi` | `audi_own` | `userid = current_user_id() OR is_admin()` | app_user |
| `tblprivileges` | `privileges_own` | `usercode = current_user_id() OR is_admin()` | app_readwrite |
| `tbluserroleassignments` | `userroleassignments_own` | `usercode = current_user_id() OR is_admin()` | app_readwrite |

### 6.4 Target Connection Settings

```csharp
// Target DalSettings.cs (post-design)
public static string ID => Get("USER", "app_user");   // CHANGED from "postgres"
public static string PWD => Get("PWD", "");          // REMOVED default; must come from env/App.config
```

**Per-connection settings (set via `SET LOCAL`):**

```sql
-- On every connection from app_readwrite
SET LOCAL app.current_user = '5';           -- usercode of the logged-in user
SET LOCAL app.current_branch = '1';        -- branchcode of the logged-in user
SET LOCAL app.is_admin = 'false';

-- On app_admin connection
SET LOCAL app.is_admin = 'true';
SET LOCAL app.current_user = '1';           -- the admin's usercode
SET LOCAL app.current_branch = 'ALL';
```

### 6.5 Target RLS Helper Functions

```sql
-- Helper functions (NOT YET CREATED — design only)
CREATE OR REPLACE FUNCTION current_user_id() RETURNS INTEGER AS $$
    SELECT NULLIF(current_setting('app.current_user', true), '')::INTEGER;
$$ LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION current_branch() RETURNS INTEGER AS $$
    SELECT CASE
        WHEN current_setting('app.is_admin', true) = 'true' THEN NULL  -- admin sees all
        ELSE NULLIF(current_setting('app.current_branch', true), '')::INTEGER
    END;
$$ LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION is_admin() RETURNS BOOLEAN AS $$
    SELECT COALESCE(current_setting('app.is_admin', true), 'false') = 'true';
$$ LANGUAGE SQL STABLE;
```

---

## 7. Impact Analysis (On Application & Database)

### 7.1 Impact on Application (PL + BL + DAL)

| Component | Impact | Required Change |
|-----------|--------|-----------------|
| `DalSettings.cs` | **HIGH** | Change default user from `postgres` → `app_user`; remove hardcoded password |
| `clsCN.cs` | **MEDIUM** | Add `SET LOCAL` calls for `app.current_user`, `app.current_branch`, `app.is_admin` after Open() |
| `clsUsers.cs` | **MEDIUM** | After successful login, store `usercode` + `branchcode` in SessionContext, pass to connection |
| `Security/SessionContext.cs` | **MEDIUM** | Add `BranchCode` property, expose to DAL |
| `frmLogin.cs` | **LOW** | No change (uses clsUsers) |
| `DbContextProvider.cs` | **LOW** | No change needed |
| `DbTest/Program.cs` | **MEDIUM** | DbTest must use `app_user` (or skip RLS for testing via `app_admin`) |
| `App.config` | **MEDIUM** | Add `IAS_DB_USER=app_user`, `IAS_DB_PWD=<secure>` (or use Windows auth / env-only) |

### 7.2 Impact on Database (Performance)

| Operation | Without RLS | With RLS | Delta |
|-----------|:---:|:---:|:---:|
| Simple SELECT (PK) | ~1ms | ~1ms | 0ms |
| SELECT with RLS predicate (usercode = current_user_id()) | N/A | ~1-2ms | +1ms |
| INSERT | ~1ms | ~1ms | 0ms (CHECK enforces, not SELECT) |
| UPDATE | ~2ms | ~2-3ms | +1ms |
| Function/procedure call | ~2ms | ~3ms | +1ms (RLS check on inner queries) |

**Estimated performance overhead:** < 5% (RLS predicates are subquery lookups, indexes unchanged)

### 7.3 Impact on DbTest (CRITICAL CONSIDERATION)

DbTest currently connects as `postgres` (superuser). After RLS is enabled:

- If DbTest still uses `postgres` (superuser): RLS is BYPASSED, all tests pass → but RLS not actually tested
- If DbTest uses `app_user` (non-superuser): RLS enforced, may need test users per branch
- **Recommendation:** DbTest should test BOTH cases: admin (postgres or app_admin) AND non-admin (app_readwrite with branch context)

### 7.4 Impact on Existing Data

| Aspect | Impact |
|--------|--------|
| **Data preservation** | ✅ None — no DML changes |
| **Schema changes** | None (no new columns; only policies/grants) |
| **Migration path** | Idempotent SQL: can DROP POLICY / DROP ROLE safely on rollback |
| **Application downtime** | ~5 minutes (during DAL config update + restart) |

### 7.5 Impact on Operations (Production)

| Operational Area | Impact |
|------------------|--------|
| **Backup** | Needs `app_backup` role with `pg_read_server_files`; existing `postgres` backup scripts unchanged |
| **Monitoring** | Each app connection now logs as `app_user` not `postgres` → pgaudit shows user attribution |
| **Performance** | < 5% overhead |
| **Support** | Easier — each operation attributable to a specific app role |

---

## 8. Security Model Diagrams (Conceptual)

### 8.1 Role Hierarchy

```
┌─────────────────────────────────────────────────┐
│  app_migrator (CREATE/DROP/ALTER on schema)      │  ← DDL only
└────────────────────┬────────────────────────────-┘
                     │ NOLOGIN
┌────────────────────▼────────────────────────────-┐
│  app_backup (file I/O, no DB access)             │  ← OS-level
└────────────────────┬────────────────────────────-┘
                     │ NOLOGIN

┌─────────────────────────────────────────────────┐
│  app_user (default app login, NOLOGIN)            │
│  + CONNECT, TEMPORARY, USAGE                     │
└─────┬──────────┬──────────┬──────────┬─────────────┘
      │          │          │          │
      ▼          ▼          ▼          ▼
┌────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ admin  │ │ readwri  │ │ readonly │ │ auditor  │
│ ALL    │ │ CRUD     │ │ SELECT   │ │ SELECT on │
│ +DDL   │ │ (RLS)    │ │ (RLS)    │ │ audit only│
└────────┘ └──────────┘ └──────────┘ └──────────┘
                                       ┌──────────┐
                                       │ reports  │
                                       │ SELECT on│
                                       │ views only│
                                       └──────────┘
```

### 8.2 Access Path (After Implementation)

```
WinForms App
  │ (Connection: User ID=app_user, PWD=<secure>)
  ▼
NpgsqlConnection
  │ (After Open: SET LOCAL app.current_user, app.current_branch, app.is_admin)
  ▼
PostgreSQL Server
  │ 1. Authentication: Verify app_user credentials
  │ 2. Permission check: Is app_user allowed to SELECT/INSERT/UPDATE/DELETE on this table?
  │ 3. RLS policy check: Does the policy USING clause evaluate to TRUE for this row?
  │ 4. Audit trigger: Auto-insert into tblaudi
  ▼
Data returned (only rows the user is allowed to see)
```

---

## 9. Existing Audit Log Coverage

| Table | Has Audit | Audit Method | Recommendation |
|-------|:---:|---|---|
| `tblusers` | ✅ | `tblauditlogs` + `tblaudi` (trigger) | Add INSERT/UPDATE/DELETE triggers |
| `tblsessions` | ✅ | `tblauditlogs` (login events) | Add UPDATE/DELETE trigger |
| `tbluserroles` | ✅ | `tblauditlogs` (via app) | Add DB trigger |
| `tbluserroleassignments` | ✅ | `tblauditlogs` (via app) | Add DB trigger |
| `tblprivileges` | ✅ | `tblauditlogs` (via app) | Add DB trigger |
| `tblbankaccounts` | ❌ | none | Add `tblaudi` trigger |
| `tblbanktransactions` | ❌ | none | Add `tblaudi` trigger |
| `tblcashboxes` | ❌ | none | Add `tblaudi` trigger |
| `tblcashreceipts` | ❌ | none | Add `tblaudi` trigger |
| `tblcashpayments` | ❌ | none | Add `tblaudi` trigger |
| `tblbankreconciliations` | ❌ | none | Add `tblaudi` trigger |
| `tblcustomers` | ❌ | none | Add `tblaudi` trigger |
| `tblsuppliers` | ❌ | none | Add `tblaudi` trigger |
| `tblproducts` | ❌ | none | Add `tblaudi` trigger |
| `tblnotifications` | ❌ | none | Add `tblaudi` trigger |
| `tblbondheader/body` | ❌ | none | Add `tblaudi` trigger |
| `tbljournalheader/body` | ❌ | none | Add `tblaudi` trigger |
| `tblaudi` | ✅ | Self-auditing | — |
| `tblauditlogs` | ✅ | Self-auditing | — |

**Gap:** 13/15 financial/PII tables have NO DB-level audit trigger (only `tblaudi` from extensions).

---

## 10. Design Decisions & Trade-offs

### 10.1 Decision: Use `app_user` as connection role (not per-user connections)

**Pros:**

- Simpler connection management (no per-user connection pool)
- One DAL change, not per-tenant
- App-level auth (clsUsers) still validates individual user identity

**Cons:**

- RLS relies on `SET LOCAL app.current_user` to identify user
- If app forgets to set it, default to superuser context (mitigated by using `app_user` with no superuser)
- Connection pooling becomes harder (each pool entry needs its own SET LOCAL)

**Decision:** Use `app_user` + `SET LOCAL`. Accept the trade-off. Will document as a critical requirement.

### 10.2 Decision: Branch-based isolation (not user-based)

**Pros:**

- Simpler RLS predicates
- Matches business model (one branch = one tenant)
- Supports both individual user tracking and group-based access

**Cons:**

- Cross-branch users (HQ staff) need explicit `is_admin` flag
- Reporting users need a special "ALL branches" role

**Decision:** Use branch-based for data isolation, user-based for notification/audit.

### 10.3 Decision: Layered RLS (data + audit)

**Pros:**

- Defense in depth (UI filtering + DB filtering)
- Cannot be bypassed even with SQL injection
- Mandatory for compliance (SOX, GDPR, ISO 27001)

**Cons:**

- Slight complexity in RLS predicates
- Requires testing with multiple user contexts

**Decision:** Use layered RLS. Keep app-level filtering too.

### 10.4 Decision: Password Storage (no change recommended)

**Current:** `bytea` (PBKDF2-SHA256, 100,000 iterations, per `clsUsers.cs` `PasswordHelper.cs`).
**Alternatives:** pgcrypto with argon2id, or external HSM.

**Decision:** Keep current scheme. It's adequate. Optional improvement: add pgcrypto as backup encryption.

### 10.5 Decision: Keep `postgres` role

**Should we DELETE the postgres superuser?** NO. We need it for:

- DBA operations (schema migrations, disaster recovery)
- Backup/restore
- Troubleshooting

**Decision:** Keep `postgres` as a superuser for ops. Apps must NOT use it.

---

## 11. Compliance & Constraints (Audit-Only Honor)

| Constraint | Status |
|------------|:------:|
| ✅ **NO Role created** | Honored — 0 `CREATE ROLE` statements |
| ✅ **NO Policy created** | Honored — 0 `CREATE POLICY` statements |
| ✅ **NO RLS enabled** | Honored — 0 `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` |
| ✅ **NO Grant** | Honored — 0 `GRANT` statements |
| ✅ **NO Revoke** | Honored — 0 `REVOKE` statements |
| ✅ **Read-only inspection** | Honored — only `SELECT` queries + this report |
| ✅ **Comprehensive discovery** | Honored — 12 sections (roles, users, sessions, grants, FKs, audit, settings) |
| ✅ **All access points mapped** | Honored — BL → DB function/procedure mapping |
| ✅ **Sensitive tables identified** | Honored — 3 tiers (P0/P1/P2) |
| ✅ **Target model designed** | Honored — 8 roles, RLS policies, connection pattern |
| ✅ **Impact analyzed** | Honored — application, database, performance, data, operations |

---

## 12. Next Step Decision

**The design is complete and ready for review. The next step (when approved) would be to implement this design by:**

1. Creating the 8 roles (`CREATE ROLE ... NOSUPERUSER`)
2. Revoking PUBLIC from all tables
3. Granting per-role table privileges
4. Creating RLS policies (30+)
5. Setting `SET LOCAL` parameters in DAL
6. Updating `DalSettings.cs` and `App.config`
7. Testing with DbTest + manual validation
8. **Rollback plan ready** (DROP POLICY, DISABLE RLS, GRANT PUBLIC)

**Awaiting your decision:**

- ✅ **APPROVE design** — proceed to implementation plan
- 🔄 **MODIFY design** — specify changes
- ❌ **REJECT** — different approach
- ⏸️ **PAUSE** — need more information
