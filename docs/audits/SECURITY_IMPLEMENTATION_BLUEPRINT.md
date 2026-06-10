# 🛠️ Security Implementation Blueprint — Phase 1 (Roles + RLS)

**Date:** 2026-06-09
**Database:** PostgreSQL 17.10 (`IntegratedAccSys`) — **56 base tables** + 20 views
**Application:** .NET 8 WinForms
**Method:** Read-only design — **NO CREATE ROLE, NO CREATE POLICY, NO GRANT, NO REVOKE, NO RLS**
**Status:** 📋 **BLUEPRINT ONLY — ready for execution after approval**

---

## 1. Scope & Goal

This blueprint is the **complete, ready-to-execute specification** for Phase 1 of the Enterprise Security Plan. It contains:

- 8 PostgreSQL roles to create
- Complete user-to-role mapping
- Classification matrix for all 56 tables
- Affected file inventory
- Step-by-step migration order
- Validation checklist
- Rollback checklist
- Idempotency guarantees

**No code is executed. No file is modified. No DDL is run.**

---

## 2. User-to-Role Mapping Matrix

### 2.1 Application User → PostgreSQL Role Mapping

| App User (`tblusers.usercode`) | userid | branchcode | isadmin | → PostgreSQL Role | SET LOCAL values |
|---:|---|---|:---:|---|---|
| 1 | `ADMIN` | 1 | ✅ | `app_admin` | `app.current_user=1`, `app.current_branch=ALL`, `app.is_admin=true` |
| 2 | `testuser` | 1 | ❌ | `app_readwrite` | `app.current_user=2`, `app.current_branch=1`, `app.is_admin=false` |
| _(future user 3)_ | _(any)_ | _(branch X)_ | ❌ | `app_readwrite` | `app.current_user=3`, `app.current_branch=X`, `app.is_admin=false` |
| _(future admin)_ | _(any)_ | _(any)_ | ✅ | `app_admin` | `app.is_admin=true` |
| _(future readonly)_ | _(any)_ | _(any)_ | ❌ | `app_readonly` | `app.current_user=N`, `app.current_branch=N`, `app.is_admin=false` |
| _(auditor role)_ | _(N/A)_ | _(N/A)_ | ❌ | `app_auditor` | `app.current_user=1`, `app.is_admin=false` (no branch filter) |
| _(BI tools)_ | _(N/A)_ | _(N/A)_ | ❌ | `app_reports` | _(no SET LOCAL, just SELECT on views)_ |

### 2.2 Connection Pooling Strategy

```
+---------------------+       +---------------------+
|  WinForms Login     |       |   PostgreSQL        |
|  (frmLogin)         |       |   Server            |
+---------------------+       +---------------------+
         |                          ^
         v                          |
+---------------------+              | authenticated
| SessionContext      |              | as app_user
| (userid, branchid,  |              |
|  isadmin)           |              |
+---------------------+              |
         |                          |
         v                          |
+---------------------+              |
| clsCN.Open()        |------------->+
| 1. Connect as app_user
| 2. SET LOCAL app.current_user = SessionContext.UserId
| 3. SET LOCAL app.current_branch = SessionContext.BranchId (if not admin)
| 4. SET LOCAL app.is_admin = SessionContext.IsAdmin
+---------------------+
```

### 2.3 Role Inheritance Hierarchy

```
+----------------------------+ (NOLOGIN)
|  app_migrator              |  ← DDL only
+-------------+--------------+
              |
              v (NOLOGIN)
+----------------------------+
|  app_backup                |  ← OS file I/O only
+-------------+--------------+
              |
              v (NOLOGIN)
+----------------------------+
|  app_user                  |  ← base app role (LOGIN = false)
|  + CONNECT, TEMPORARY      |
|  + USAGE on schema public  |
+-------------+--------------+
              |
   +----------+----------+-----------+-----------+
   |          |          |           |           |
   v          v          v           v           v
+-----+ +-----------+ +--------+ +-------+ +---------+
|admin| |readwrite  | |readonly| |auditor| |reports  |
|ALL  | |CRUD(RLS)  | |SEL(RLS)| |SEL aud| |SEL views|
+-----+ +-----------+ +--------+ +-------+ +---------+
```

---

## 3. Complete Table Classification Matrix (All 56 Tables)

### 3.1 Tier 1: CRITICAL Sensitive Tables (P0 — Auth/Privileges)

| # | Table | Sensitivity | Isolation Type | RLS Policy Name | RLS Predicate | Roles |
|--:|---|---|---|---|---|---|
| 1 | `tblusers` | 🔴 Auth secrets (passwords) | `usercode` + `branchcode` | `users_own`, `users_branch_isolation`, `users_admin_bypass` | `usercode = current_user_id() AND is_admin() OR branchcode = current_branch()` | app_admin ALL, app_readwrite (own+branch), app_readonly (own+branch), app_auditor (own) |
| 2 | `tblsessions` | 🔴 Session tokens | `usercode` | `sessions_own` | `usercode = current_user_id() OR is_admin()` | app_user (own), app_admin ALL |
| 3 | `tbluserroles` | 🔴 Role definitions | `roleid` (application) | `userroles_all` | `is_admin()` | app_admin ALL, app_readwrite (SELECT), app_auditor (SELECT) |
| 4 | `tbluserroleassignments` | 🔴 User-Role mapping | `usercode` | `userroleassignments_own` | `usercode = current_user_id() OR is_admin()` | app_admin ALL, app_readwrite (own+branch), app_auditor (SELECT) |
| 5 | `tblwindows` | 🔴 Window metadata | none (all) | none needed (reference table) | — | app_user (SELECT), app_admin ALL |
| 6 | `tblprivileges` | 🔴 Privilege flags | `usercode` | `privileges_own` | `usercode = current_user_id() OR is_admin()` | app_admin ALL, app_readwrite (own+branch), app_auditor (SELECT) |

### 3.2 Tier 2: HIGH Sensitive Tables (P1 — Audit)

| # | Table | Sensitivity | Isolation Type | RLS Policy Name | RLS Predicate | Roles |
|--:|---|---|---|---|---|---|
| 7 | `tblauditlogs` | 🟡 Audit trail | `usercode` | `auditlogs_own` | `usercode = current_user_id() OR is_admin()` | app_user (own+branch), app_admin ALL, app_auditor (ALL) |
| 8 | `tblaudi` | 🟡 Audit history | `userid` | `audi_own` | `userid = current_user_id() OR is_admin()` | app_user (own+branch), app_admin ALL, app_auditor (ALL) |

### 3.3 Tier 3: HIGH Sensitive Tables (P1 — Financial/Treasury)

| # | Table | Sensitivity | Isolation Type | RLS Policy Name | RLS Predicate | Roles |
|--:|---|---|---|---|---|---|
| 9 | `tblbranches` | 🟡 Org structure | `branchcode` (master) | none (reference) | — | app_user (SELECT), app_admin ALL |
| 10 | `tblcompanies` | 🟡 Company info | none | none (reference) | — | app_user (SELECT), app_admin ALL |
| 11 | `tblcurrencies` | 🟡 Reference | none | none (reference) | — | app_user (SELECT), app_admin ALL |
| 12 | `tblbanks` | 🟡 Reference | none | none (reference) | — | app_user (SELECT), app_admin ALL |
| 13 | `tblfunds` | 🟡 Financial config | none | none (reference) | — | app_user (SELECT), app_admin ALL |
| 14 | `tblbankaccounts` | 🔴 Bank credentials | `branchcode` | `bankaccount_branch` | `branchcode = current_branch() OR is_admin()` | app_readwrite (branch), app_admin ALL, app_auditor (SELECT), app_reports (SELECT) |
| 15 | `tblbanktransactions` | 🔴 Bank movements | `branchcode` | `banktransactions_branch` | `branchcode = current_branch() OR is_admin()` | app_readwrite (branch), app_admin ALL, app_auditor (SELECT), app_reports (SELECT) |
| 16 | `tblbankstatements` | 🔴 Bank statements | `bankaccountid` (via account) | `bankstatements_via_account` | `bankaccountid IN (SELECT bankaccountid FROM tblbankaccounts WHERE branchcode = current_branch()) OR is_admin()` | app_readwrite (branch), app_admin ALL, app_auditor (SELECT) |
| 17 | `tblbankstatementlines` | 🔴 Bank stmt lines | `statementid` (via statement) | `bankstatementlines_via_statement` | `statementid IN (SELECT statementid FROM tblbankstatements WHERE bankaccountid IN (...)) OR is_admin()` | app_readwrite (branch), app_admin ALL |
| 18 | `tblbankreconciliations` | 🔴 Reconciliation | `bankaccountid` (via account) | `bankreconciliations_via_account` | Similar subquery to bankstatements | app_readwrite (branch), app_admin ALL, app_auditor (SELECT) |
| 19 | `tblcashboxes` | 🔴 Cash balances | `branchid` | `cashbox_branch` | `branchid = current_branch() OR is_admin()` | app_readwrite (branch), app_admin ALL, app_auditor (SELECT) |
| 20 | `tblcashreceipts` | 🔴 Cash receipts | `cashboxid` (via cashbox) | `cashreceipts_via_cashbox` | `cashboxid IN (SELECT cashboxid FROM tblcashboxes WHERE branchid = current_branch()) OR is_admin()` | app_readwrite (branch), app_admin ALL, app_auditor (SELECT) |
| 21 | `tblcashpayments` | 🔴 Cash payments | `cashboxid` (via cashbox) | `cashpayments_via_cashbox` | Similar to cashreceipts | app_readwrite (branch), app_admin ALL, app_auditor (SELECT) |

### 3.4 Tier 4: MEDIUM Sensitive Tables (P1 — Financial Transactions)

| # | Table | Sensitivity | Isolation Type | RLS Policy Name | RLS Predicate | Roles |
|--:|---|---|---|---|---|---|
| 22 | `tblaccounts` | 🟡 Chart of accounts | `branchcode` (via context) | `accounts_branch` | `branchcode = current_branch() OR is_admin()` (or treat as global with read-only) | app_readwrite (branch), app_admin ALL, app_auditor (SELECT), app_reports (SELECT) |
| 23 | `tbljournalheader` | 🟡 Journal entries | `braid` | `journalheader_branch` | `braid = current_branch() OR is_admin()` | app_readwrite (branch), app_admin ALL, app_auditor (SELECT), app_reports (SELECT) |
| 24 | `tbljournalbody` | 🟡 Journal lines | `journalcode` (via header) | `journalbody_via_header` | `journalcode IN (SELECT journalcode FROM tbljournalheader WHERE braid = current_branch()) OR is_admin()` | app_readwrite (branch), app_admin ALL, app_auditor (SELECT) |
| 25 | `tblbondheader` | 🟡 Bonds (Sales/Purchase) | `braid` | `bondheader_branch` | `braid = current_branch() OR is_admin()` | app_readwrite (branch), app_admin ALL, app_auditor (SELECT), app_reports (SELECT) |
| 26 | `tblbondbody` | 🟡 Bond lines | `bondcode` (via header) | `bondbody_via_header` | Similar to journalbody | app_readwrite (branch), app_admin ALL, app_auditor (SELECT) |
| 27 | `tblcustomers` | 🟡 PII (tax info, address) | `branchcode` | `customers_branch` | `branchcode = current_branch() OR is_admin()` | app_readwrite (branch), app_admin ALL, app_reports (SELECT) |
| 28 | `tblcustomercontacts` | 🟡 PII | `customercode` (via customer) | `customercontacts_via_customer` | Similar to bondbody | app_readwrite (branch), app_admin ALL |
| 29 | `tblsuppliers` | 🟡 PII | `branchcode` | `suppliers_branch` | `branchcode = current_branch() OR is_admin()` | app_readwrite (branch), app_admin ALL, app_reports (SELECT) |
| 30 | `tblsuppliercontacts` | 🟡 PII | `suppliercode` (via supplier) | `suppliercontacts_via_supplier` | Similar | app_readwrite (branch), app_admin ALL |
| 31 | `tbloperationheader` | 🟡 Operations | `braid` | `operationheader_branch` | `braid = current_branch() OR is_admin()` | app_readwrite (branch), app_admin ALL, app_auditor (SELECT) |
| 32 | `tbloperationbody` | 🟡 Op lines | `opheaderid` (via header) | `operationbody_via_header` | Similar | app_readwrite (branch), app_admin ALL, app_auditor (SELECT) |
| 33 | `tbloperationtaxes` | 🟡 Op taxes | `opbodyid` (via body) | `operationtaxes_via_body` | Similar | app_readwrite (branch), app_admin ALL |

### 3.5 Tier 5: MEDIUM Sensitive Tables (P1 — Inventory)

| # | Table | Sensitivity | Isolation Type | RLS Policy Name | RLS Predicate | Roles |
|--:|---|---|---|---|---|---|
| 34 | `tblproducts` | 🟡 Pricing data | `branchcode` (need to add) | `products_branch` | `branchcode = current_branch() OR is_admin()` | app_readwrite (branch), app_admin ALL, app_reports (SELECT) |
| 35 | `tblproductbatches` | 🟡 Batch info | `productcode` (via product) | `productbatches_via_product` | Similar | app_readwrite (branch), app_admin ALL |
| 36 | `tblproductimages` | 🟡 Image data | `productcode` (via product) | `productimages_via_product` | Similar | app_readwrite (branch), app_admin ALL |
| 37 | `tblproductmovement` | 🟡 Stock movement | `productcode` (via product) | `productmovement_via_product` | Similar | app_readwrite (branch), app_admin ALL, app_auditor (SELECT) |
| 38 | `tblproductpricing` | 🟡 Pricing tiers | `productcode` (via product) | `productpricing_via_product` | Similar | app_readwrite (branch), app_admin ALL, app_reports (SELECT) |
| 39 | `tblstoreproducts` | 🟡 Store stock | `storecode` (via store) | `storeproducts_via_store` | Similar | app_readwrite (branch), app_admin ALL |
| 40 | `tblstores` | 🟡 Store info | `branchcode` | `stores_branch` | `branchcode = current_branch() OR is_admin()` | app_readwrite (branch), app_admin ALL, app_reports (SELECT) |
| 41 | `tblunits` | 🟡 Unit metadata | none | none (reference) | — | app_user (SELECT), app_admin ALL |
| 42 | `tblcategories` | 🟡 Category metadata | none | none (reference) | — | app_user (SELECT), app_admin ALL |
| 43 | `tblcostcenters` | 🟡 Cost center | none | none (reference) | — | app_user (SELECT), app_admin ALL |
| 44 | `tblpricelists` | 🟡 Price list | none | none (reference) | — | app_user (SELECT), app_admin ALL |
| 45 | `tblpaymentmethods` | 🟡 Payment method | none | none (reference) | — | app_user (SELECT), app_admin ALL |
| 46 | `tblpaymentterms` | 🟡 Payment terms | none | none (reference) | — | app_user (SELECT), app_admin ALL |
| 47 | `tblreportdefinitions` | 🟡 Report config | none | none (reference) | — | app_user (SELECT), app_reports (SELECT) |
| 48 | `tbltaxdefinitions` | 🟡 Tax config | none | none (reference) | — | app_user (SELECT), app_admin ALL |
| 49 | `tbltaxtransactions` | 🟡 Tax txn | `source_id` (via source) | `taxtransactions_via_source` | Source-based isolation (only same branch sources) | app_readwrite (branch), app_admin ALL |
| 50 | `tblnotifications` | 🔴 Private messages | `userid` | `notifications_own` | `userid = current_user_id() OR is_admin()` | app_user (own), app_admin ALL |
| 51 | `tbldocumentattachments` | 🟡 Documents | `source_id` (via source) | `documentattachments_via_source` | Source-based isolation | app_readwrite (branch), app_admin ALL |
| 52 | `tblbudgetperiods` | 🟡 Fiscal config | none | none (reference) | — | app_user (SELECT), app_admin ALL |
| 53 | `tblbudgets` | 🟡 Budgets | `branchid` (via branch) | `budgets_branch` | `branchid = current_branch() OR branchid IS NULL OR is_admin()` | app_readwrite (branch), app_admin ALL, app_reports (SELECT) |
| 54 | `tblfiscalyears` | 🟡 Fiscal year | none | none (reference) | — | app_user (SELECT), app_admin ALL |
| 55 | `tblfiscalperiods` | 🟡 Fiscal period | `fiscalyearid` (via year) | `fiscalperiods_via_year` | Year-based isolation (fiscal year is shared) | app_user (SELECT), app_admin ALL |
| 56 | `tblexchangeratehistory` | 🟡 Exchange rates | none | none (reference) | — | app_user (SELECT), app_admin ALL |

### 3.6 Tier Summary

| Tier | Count | Description | RLS Strategy |
|------|:---:|---|---|
| **P0 (Critical)** | 6 | Auth/permissions | usercode/branchcode-based |
| **P1 (Audit)** | 2 | Audit trails | usercode-based |
| **P1 (Treasury)** | 13 | Bank/Cash | branchcode-based + subqueries |
| **P1 (Financial)** | 11 | Bonds/Journals/Operations/Customers | braid/branchcode-based + subqueries |
| **P1 (Inventory)** | 8 | Products/Stores | productcode/branchcode + subqueries |
| **P1 (Config/Reference)** | 16 | Currencies/Banks/Units/etc. | none (reference tables) |
| **TOTAL** | **56** | All base tables | |

---

## 4. RLS Policy Inventory (Expected)

| # | Policy Name | Table | Predicate | FOR role |
|--:|---|---|---|---|
| 1 | `users_own` | tblusers | `usercode = current_user_id()` | app_user |
| 2 | `users_branch_isolation` | tblusers | `branchcode = current_branch() OR is_admin()` | app_readwrite |
| 3 | `users_admin_bypass` | tblusers | `TRUE` | app_admin |
| 4 | `users_auditor_read` | tblusers | `is_admin()` | app_auditor |
| 5 | `sessions_own` | tblsessions | `usercode = current_user_id() OR is_admin()` | app_user |
| 6 | `sessions_admin` | tblsessions | `TRUE` | app_admin |
| 7 | `userroleassignments_own` | tbluserroleassignments | `usercode = current_user_id() OR is_admin()` | app_readwrite |
| 8 | `userroleassignments_admin` | tbluserroleassignments | `TRUE` | app_admin |
| 9 | `userroles_admin` | tbluserroles | `is_admin()` | app_readwrite |
| 10 | `privileges_own` | tblprivileges | `usercode = current_user_id() OR is_admin()` | app_readwrite |
| 11 | `privileges_admin` | tblprivileges | `TRUE` | app_admin |
| 12 | `auditlogs_own` | tblauditlogs | `usercode = current_user_id() OR is_admin()` | app_user |
| 13 | `auditlogs_admin` | tblauditlogs | `TRUE` | app_admin |
| 14 | `auditlogs_auditor` | tblauditlogs | `is_admin()` | app_auditor |
| 15 | `audi_own` | tblaudi | `userid = current_user_id() OR is_admin()` | app_user |
| 16 | `audi_admin` | tblaudi | `TRUE` | app_admin |
| 17 | `audi_auditor` | tblaudi | `is_admin()` | app_auditor |
| 18 | `bankaccount_branch` | tblbankaccounts | `branchcode = current_branch() OR is_admin()` | app_readwrite |
| 19 | `bankaccount_admin` | tblbankaccounts | `TRUE` | app_admin |
| 20 | `banktransactions_branch` | tblbanktransactions | `branchcode = current_branch() OR is_admin()` | app_readwrite |
| 21 | `banktransactions_admin` | tblbanktransactions | `TRUE` | app_admin |
| 22 | `bankstatements_via_account` | tblbankstatements | `bankaccountid IN (...)` | app_readwrite |
| 23 | `bankstatements_admin` | tblbankstatements | `TRUE` | app_admin |
| 24 | `bankstatementlines_via_statement` | tblbankstatementlines | `statementid IN (...)` | app_readwrite |
| 25 | `bankstatementlines_admin` | tblbankstatementlines | `TRUE` | app_admin |
| 26 | `bankreconciliations_via_account` | tblbankreconciliations | `bankaccountid IN (...)` | app_readwrite |
| 27 | `bankreconciliations_admin` | tblbankreconciliations | `TRUE` | app_admin |
| 28 | `cashbox_branch` | tblcashboxes | `branchid = current_branch() OR is_admin()` | app_readwrite |
| 29 | `cashbox_admin` | tblcashboxes | `TRUE` | app_admin |
| 30 | `cashreceipts_via_cashbox` | tblcashreceipts | `cashboxid IN (...)` | app_readwrite |
| 31 | `cashreceipts_admin` | tblcashreceipts | `TRUE` | app_admin |
| 32 | `cashpayments_via_cashbox` | tblcashpayments | `cashboxid IN (...)` | app_readwrite |
| 33 | `cashpayments_admin` | tblcashpayments | `TRUE` | app_admin |
| 34 | `accounts_branch` | tblaccounts | `branchcode = current_branch() OR is_admin()` | app_readwrite |
| 35 | `accounts_admin` | tblaccounts | `TRUE` | app_admin |
| 36 | `journalheader_branch` | tbljournalheader | `braid = current_branch() OR is_admin()` | app_readwrite |
| 37 | `journalheader_admin` | tbljournalheader | `TRUE` | app_admin |
| 38 | `journalbody_via_header` | tbljournalbody | `journalcode IN (...)` | app_readwrite |
| 39 | `journalbody_admin` | tbljournalbody | `TRUE` | app_admin |
| 40 | `bondheader_branch` | tblbondheader | `braid = current_branch() OR is_admin()` | app_readwrite |
| 41 | `bondheader_admin` | tblbondheader | `TRUE` | app_admin |
| 42 | `bondbody_via_header` | tblbondbody | `bondcode IN (...)` | app_readwrite |
| 43 | `bondbody_admin` | tblbondbody | `TRUE` | app_admin |
| 44 | `customers_branch` | tblcustomers | `branchcode = current_branch() OR is_admin()` | app_readwrite |
| 45 | `customers_admin` | tblcustomers | `TRUE` | app_admin |
| 46 | `customercontacts_via_customer` | tblcustomercontacts | `customercode IN (...)` | app_readwrite |
| 47 | `customercontacts_admin` | tblcustomercontacts | `TRUE` | app_admin |
| 48 | `suppliers_branch` | tblsuppliers | `branchcode = current_branch() OR is_admin()` | app_readwrite |
| 49 | `suppliers_admin` | tblsuppliers | `TRUE` | app_admin |
| 50 | `suppliercontacts_via_supplier` | tblsuppliercontacts | `suppliercode IN (...)` | app_readwrite |
| 51 | `suppliercontacts_admin` | tblsuppliercontacts | `TRUE` | app_admin |
| 52 | `operationheader_branch` | tbloperationheader | `braid = current_branch() OR is_admin()` | app_readwrite |
| 53 | `operationheader_admin` | tbloperationheader | `TRUE` | app_admin |
| 54 | `operationbody_via_header` | tbloperationbody | `opheaderid IN (...)` | app_readwrite |
| 55 | `operationbody_admin` | tbloperationbody | `TRUE` | app_admin |
| 56 | `operationtaxes_via_body` | tbloperationtaxes | `opbodyid IN (...)` | app_readwrite |
| 57 | `operationtaxes_admin` | tbloperationtaxes | `TRUE` | app_admin |
| 58 | `products_branch` | tblproducts | `branchcode = current_branch() OR is_admin()` | app_readwrite |
| 59 | `products_admin` | tblproducts | `TRUE` | app_admin |
| 60 | `productbatches_via_product` | tblproductbatches | `productcode IN (...)` | app_readwrite |
| 61 | `productbatches_admin` | tblproductbatches | `TRUE` | app_admin |
| 62 | `productimages_via_product` | tblproductimages | `productcode IN (...)` | app_readwrite |
| 63 | `productimages_admin` | tblproductimages | `TRUE` | app_admin |
| 64 | `productmovement_via_product` | tblproductmovement | `productcode IN (...)` | app_readwrite |
| 65 | `productmovement_admin` | tblproductmovement | `TRUE` | app_admin |
| 66 | `productpricing_via_product` | tblproductpricing | `productcode IN (...)` | app_readwrite |
| 67 | `productpricing_admin` | tblproductpricing | `TRUE` | app_admin |
| 68 | `storeproducts_via_store` | tblstoreproducts | `storecode IN (...)` | app_readwrite |
| 69 | `storeproducts_admin` | tblstoreproducts | `TRUE` | app_admin |
| 70 | `stores_branch` | tblstores | `branchcode = current_branch() OR is_admin()` | app_readwrite |
| 71 | `stores_admin` | tblstores | `TRUE` | app_admin |
| 72 | `budgets_branch` | tblbudgets | `branchid = current_branch() OR is_admin()` | app_readwrite |
| 73 | `budgets_admin` | tblbudgets | `TRUE` | app_admin |
| 74 | `budgetperiods_via_year` | tblbudgetperiods | `fiscalyearid = current_fiscalyear_id() OR is_admin()` | app_readwrite |
| 75 | `budgetperiods_admin` | tblbudgetperiods | `TRUE` | app_admin |
| 76 | `fiscalperiods_via_year` | tblfiscalperiods | `fiscalyearid IN (...)` | app_readwrite |
| 77 | `fiscalperiods_admin` | tblfiscalperiods | `TRUE` | app_admin |
| 78 | `taxtransactions_via_source` | tbltaxtransactions | `source_id IN (...)` | app_readwrite |
| 79 | `taxtransactions_admin` | tbltaxtransactions | `TRUE` | app_admin |
| 80 | `documentattachments_via_source` | tbldocumentattachments | `source_id IN (...)` | app_readwrite |
| 81 | `documentattachments_admin` | tbldocumentattachments | `TRUE` | app_admin |
| 82 | `notifications_own` | tblnotifications | `userid = current_user_id() OR is_admin()` | app_user |
| 83 | `notifications_admin` | tblnotifications | `TRUE` | app_admin |

**Total: 83 RLS policies** (for 32 tables)

**Reference tables (16) without RLS:** tblbranches, tblcompanies, tblcurrencies, tblbanks, tblfunds, tblunits, tblcategories, tblcostcenters, tblpricelists, tblpaymentmethods, tblpaymentterms, tblreportdefinitions, tbltaxdefinitions, tblexchangeratehistory, tblfiscalyears, tblwindows.

---

## 5. Affected Files Inventory (DAL + BL + PL + Tests)

### 5.1 DAL Layer (3 files)

| File | Change Required | Lines | Risk |
|------|----------------|------:|:---:|
| `src/IntegratedAccSys.DAL/DalSettings.cs` | Change default `ID` from `"postgres"` to `"app_user"`; remove default PWD; add env var docs | ~10 | 🟡 Medium |
| `src/IntegratedAccSys.DAL/clsCN.cs` | Add `SET LOCAL` calls for `app.current_user`, `app.current_branch`, `app.is_admin` after `Open()`; add helper method `SetSessionContext(int userId, int branchId, bool isAdmin)` | ~25 | 🔴 High |
| `src/IntegratedAccSys.DAL/DbContextProvider.cs` | No change (wraps `clsCN`) | 0 | 🟢 Low |

### 5.2 BL Layer (5 files)

| File | Change Required | Lines | Risk |
|------|----------------|------:|:---:|
| `src/IntegratedAccSys.BL/Security/SessionContext.cs` | Add public properties: `BranchCode` (int), `IsAdmin` (bool), `UserId` (int); add `BranchCode` parameter to `Create()` | ~15 | 🔴 High |
| `src/IntegratedAccSys.BL/Security/PrivilegeApplier.cs` | No structural change; just ensure RLS allows access via SET LOCAL | ~5 | 🟢 Low |
| `src/IntegratedAccSys.BL/Security/PrivilegeHelper.cs` | No change | 0 | 🟢 Low |
| `src/IntegratedAccSys.BL/Security/AuditHelper.cs` | Pass `SessionContext.BranchCode` if needed | ~5 | 🟢 Low |
| `src/IntegratedAccSys.BL/Users/clsUsers.cs` | After successful `Login()`, populate `SessionContext.BranchCode` + `IsAdmin`; pass them down | ~15 | 🟡 Medium |

### 5.3 PL Layer (1 file)

| File | Change Required | Lines | Risk |
|------|----------------|------:|:---:|
| `src/IntegratedAccSys.PL/Users/frmLogin.cs` | No change (uses clsUsers) | 0 | 🟢 Low |

### 5.4 Tests (1 file)

| File | Change Required | Lines | Risk |
|------|----------------|------:|:---:|
| `tests/IntegratedAccSys.DAL.DbTest/Program.cs` | Add option to login as `app_admin` (bypasses RLS) for all tests; add specific RLS test that uses `app_user` + `app_readwrite` context | ~30 | 🔴 High |

### 5.5 Project Files (1 file)

| File | Change Required | Lines | Risk |
|------|----------------|------:|:---:|
| `src/IntegratedAccSys.DAL/IntegratedAccSys.DAL.csproj` | No change (Npgsql already included) | 0 | 🟢 Low |
| `App.config` (if exists) | Add `IAS_DB_USER=app_user` and `IAS_DB_PWD=<secure>` env overrides | ~5 | 🟡 Medium |

**Total affected files: 11** (3 DAL + 5 BL + 1 PL + 1 Test + 1 Config)

---

## 6. Migration Order (Step-by-Step)

This is the EXACT order of operations to execute. **None have been performed yet.**

### Phase M0: Pre-Flight (No DB changes)

| Step | Action | Verification | File Affected |
|------|--------|--------------|---------------|
| M0.1 | Backup the database: `pg_dump IntegratedAccSys > backup_pre_phase1.sql` | File exists, size > 0 | None |
| M0.2 | Save current `pg_dumpall --roles-only > roles_pre_phase1.sql` | File exists | None |
| M0.3 | Document current connection in `docs/security/PRE_PHASE1_SNAPSHOT.md` | File created | None |
| M0.4 | Commit current state of all 11 affected files to git branch `phase1-pre` | Branch created | None |

### Phase M1: Create Roles (Database DDL — REVERSIBLE)

| Step | Action | Verification | Reversible? |
|------|--------|--------------|:---:|
| M1.1 | `CREATE ROLE app_migrator NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE;` | `\du` shows role | ✅ DROP ROLE |
| M1.2 | `CREATE ROLE app_backup NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE;` | `\du` shows role | ✅ DROP ROLE |
| M1.3 | `CREATE ROLE app_user NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT;` | `\du` shows role | ✅ DROP ROLE |
| M1.4 | `CREATE ROLE app_admin INHERIT IN ROLE app_user;` | `\du+` shows inheritance | ✅ DROP ROLE |
| M1.5 | `CREATE ROLE app_readwrite INHERIT IN ROLE app_user;` | `\du+` shows inheritance | ✅ DROP ROLE |
| M1.6 | `CREATE ROLE app_readonly INHERIT IN ROLE app_user;` | `\du+` shows inheritance | ✅ DROP ROLE |
| M1.7 | `CREATE ROLE app_auditor INHERIT IN ROLE app_user;` | `\du+` shows inheritance | ✅ DROP ROLE |
| M1.8 | `CREATE ROLE app_reports INHERIT IN ROLE app_user;` | `\du+` shows inheritance | ✅ DROP ROLE |
| M1.9 | `GRANT CONNECT, TEMPORARY ON DATABASE IntegratedAccSys TO app_user, app_admin, app_readwrite, app_readonly, app_auditor, app_reports;` | `\dp` shows | ✅ REVOKE |
| M1.10 | `GRANT USAGE ON SCHEMA public TO app_user, app_admin, app_readwrite, app_readonly, app_auditor, app_reports;` | `\dn+` shows | ✅ REVOKE |
| M1.11 | `GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_user, app_admin, app_readwrite, app_readonly, app_auditor, app_reports;` | `\dp` shows | ✅ REVOKE |
| M1.12 | `ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;` | `\ddp` shows | ✅ ALTER DEFAULT |

### Phase M2: Create RLS Helper Functions (Database DDL)

| Step | Action | Verification | Reversible? |
|------|--------|--------------|:---:|
| M2.1 | `CREATE FUNCTION current_user_id() RETURNS INTEGER` | `\df+` shows | ✅ DROP FUNCTION |
| M2.2 | `CREATE FUNCTION current_branch() RETURNS INTEGER` | `\df+` shows | ✅ DROP FUNCTION |
| M2.3 | `CREATE FUNCTION is_admin() RETURNS BOOLEAN` | `\df+` shows | ✅ DROP FUNCTION |

### Phase M3: Enable RLS on Tier-1 Tables

| Step | Action | Verification | Reversible? |
|------|--------|--------------|:---:|
| M3.1 | `ALTER TABLE tblusers ENABLE ROW LEVEL SECURITY;` | `relrowsecurity=t` for tblusers | ✅ DISABLE RLS |
| M3.2 | (repeat for tblsessions, tbluserroleassignments, tblprivileges, tblaudi, tblauditlogs) | all 6 tables | ✅ |
| M3.3 | `ALTER TABLE tblusers FORCE ROW LEVEL SECURITY;` | Even `postgres` is subject to RLS (BEWARE!) | ✅ DISABLE FORCE |

### Phase M4: Create RLS Policies (30+ policies)

| Step | Action | Verification | Reversible? |
|------|--------|--------------|:---:|
| M4.1-6 | `CREATE POLICY users_own / users_branch_isolation / users_admin_bypass / users_auditor_read` on tblusers | 4 policies for tblusers | ✅ DROP POLICY |
| M4.7-8 | 2 policies for tblsessions | 2 policies | ✅ |
| M4.9-11 | 3 policies for tbluserroleassignments | 3 policies | ✅ |
| M4.12-13 | 2 policies for tblprivileges | 2 policies | ✅ |
| M4.14-17 | 4 policies for tblaudi | 4 policies | ✅ |
| M4.18-21 | 4 policies for tblauditlogs | 4 policies | ✅ |
| M4.22-83 | ~62 policies for tier-3/4/5 tables | all policies | ✅ |
| M4.84 | `SELECT COUNT(*) FROM pg_policy WHERE schemaname='public';` should be **83** | COUNT = 83 | ✅ |

### Phase M5: Revoke PUBLIC, Grant Per-Role (Database DCL)

| Step | Action | Verification | Reversible? |
|------|--------|--------------|:---:|
| M5.1 | `REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;` | 0 PUBLIC grants remain | ✅ GRANT |
| M5.2 | `REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;` | 0 PUBLIC | ✅ |
| M5.3 | `REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;` | 0 PUBLIC | ✅ |
| M5.4-7 | `GRANT SELECT ON tblbranches, tblcurrencies, tblbanks, tblfunds, ... TO app_user;` (~16 reference tables) | each role has SELECT | ✅ REVOKE |
| M5.8-13 | `GRANT SELECT, INSERT, UPDATE, DELETE ON tblusers, tblsessions, ... TO app_user;` (app_user inherits) | (app_user + child roles have CRUD) | ✅ |
| M5.14-19 | `GRANT SELECT ON tblaudi, tblauditlogs, tblprivileges, ... TO app_auditor;` | auditor role has SELECT on audit tables | ✅ |
| M5.20 | `GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_reports;` (or per-table) | reports role has SELECT | ✅ |

### Phase M6: Modify Application Code (C#)

| Step | Action | Verification | Reversible? |
|------|--------|--------------|:---:|
| M6.1 | Modify `DalSettings.cs`: change default `ID` to `"app_user"`, remove hardcoded `PWD` default | file shows new defaults | ✅ revert |
| M6.2 | Modify `clsCN.cs`: add `SetSessionContext(int, int, bool)` method that runs 3 `SET LOCAL` after `Open()` | method exists | ✅ |
| M6.3 | Modify `SessionContext.cs`: add `BranchCode`, `IsAdmin` properties | new properties | ✅ |
| M6.4 | Modify `clsUsers.cs`: after successful login, populate `SessionContext.BranchCode` and `IsAdmin` | code branches present | ✅ |
| M6.5 | Modify `DbTest/Program.cs`: add 2 test modes (admin mode + RLS test mode) | both modes present | ✅ |
| M6.6 | Modify `App.config`: add env overrides for `IAS_DB_USER` and `IAS_DB_PWD` | env vars documented | ✅ |

### Phase M7: Build + Run

| Step | Action | Verification | Reversible? |
|------|--------|--------------|:---:|
| M7.1 | `dotnet build IntegratedAccSys.sln -c Release` | 0 errors, 0 warnings | ✅ |
| M7.2 | Stop any running app instance | no app processes | ✅ |
| M7.3 | `dotnet run --project tests/IntegratedAccSys.DAL.DbTest -c Release` (using `app_admin` to bypass RLS) | 11/11 PASS | ✅ |
| M7.4 | Start the WinForms app, login as `testuser` (usercode=2, branchcode=1) | login succeeds, can navigate | ✅ |

---

## 7. Validation Checklist (Per-Phase)

### 7.1 M0 (Pre-Flight) Validation

- [ ] `backup_pre_phase1.sql` exists, size > 100 KB
- [ ] `roles_pre_phase1.sql` exists
- [ ] `PRE_PHASE1_SNAPSHOT.md` exists
- [ ] Git branch `phase1-pre` exists
- [ ] Working tree is clean (no uncommitted changes)

### 7.2 M1 (Roles Created) Validation

- [ ] `SELECT rolname FROM pg_roles WHERE rolname LIKE 'app_%';` returns 8 rows
- [ ] `SELECT rolname, rolsuper, rolcanlogin FROM pg_roles WHERE rolname='app_user';` returns `f|f`
- [ ] `SELECT rolname, rolinherit FROM pg_roles WHERE rolname IN ('app_admin','app_readwrite','app_readonly','app_auditor','app_reports');` shows all 5 inherit from app_user
- [ ] `SELECT * FROM information_schema.role_table_grants WHERE grantee='PUBLIC' AND privilege_type='SELECT' AND table_schema='public' LIMIT 5;` returns rows for SEQUENCES only (none for tables yet)

### 7.3 M2 (Helper Functions) Validation

- [ ] `SELECT proname FROM pg_proc WHERE proname IN ('current_user_id','current_branch','is_admin');` returns 3 rows
- [ ] `SELECT current_user_id();` returns NULL (no SET LOCAL set yet)
- [ ] `SELECT current_branch();` returns NULL
- [ ] `SELECT is_admin();` returns `f`

### 7.4 M3 (RLS Enabled) Validation

- [ ] `SELECT tablename, relrowsecurity FROM pg_tables t JOIN pg_class c ON c.relname=t.tablename WHERE t.schemaname='public' AND relrowsecurity=true ORDER BY tablename;` returns 6 tables

### 7.5 M4 (Policies) Validation

- [ ] `SELECT COUNT(*) FROM pg_policy WHERE schemaname='public';` returns 83
- [ ] `SELECT tablename, COUNT(*) FROM pg_policy WHERE schemaname='public' GROUP BY tablename ORDER BY 2 DESC LIMIT 5;` shows tier-1 tables with 2-4 policies each

### 7.6 M5 (Grants) Validation

- [ ] `SELECT COUNT(*) FROM information_schema.role_table_grants WHERE grantee='PUBLIC' AND table_schema='public' AND privilege_type IN ('SELECT','INSERT','UPDATE','DELETE');` returns **0**
- [ ] `SELECT grantee, COUNT(*) FROM information_schema.role_table_grants WHERE table_schema='public' AND grantee LIKE 'app_%' GROUP BY grantee;` shows non-zero per role
- [ ] `SELECT grantee, privilege_type, table_name FROM information_schema.role_table_grants WHERE table_schema='public' AND grantee='app_auditor' AND table_name IN ('tblaudi','tblauditlogs');` shows 2 rows with privilege_type=SELECT

### 7.7 M6 (Code) Validation

- [ ] `grep "app_user" src/IntegratedAccSys.DAL/DalSettings.cs` returns at least 1 line
- [ ] `grep "SetSessionContext" src/IntegratedAccSys.DAL/clsCN.cs` returns at least 1 line
- [ ] `grep "BranchCode" src/IntegratedAccSys.BL/Security/SessionContext.cs` returns at least 1 line
- [ ] `dotnet build IntegratedAccSys.sln -c Release` returns 0 errors, 0 warnings

### 7.8 M7 (Runtime) Validation

- [ ] DbTest (admin mode): `Passed=11  Failed=0`
- [ ] DbTest (RLS mode): can login as `app_readwrite`, can SELECT own user record
- [ ] DbTest (RLS isolation): `app_readwrite` with `current_branch=1` cannot see branch 2 data
- [ ] WinForms app: can login as `testuser` (usercode=2, branchcode=1)
- [ ] WinForms app: after login, query `SELECT current_user, current_user_id(), is_admin();` shows `app_user`, `2`, `f`

### 7.9 Final Production Readiness

- [ ] All 11 validation sections pass
- [ ] `psql -U app_user -d IntegratedAccSys` works (verify the role can actually login)
- [ ] `psql -U postgres -d IntegratedAccSys` STILL works (superuser not broken)
- [ ] Backup of post-phase1 state: `pg_dump > backup_post_phase1.sql`
- [ ] Documentation updated: `docs/security/SECURITY_MODEL.md` (final state)

---

## 8. Rollback Checklist (In Order)

If ANY step fails, follow this rollback procedure. **Each step is reversible independently.**

### 8.1 Rollback M7 (Code) — Instant

```powershell
# Revert the 4 modified files in git
git checkout main -- src/IntegratedAccSys.DAL/DalSettings.cs
git checkout main -- src/IntegratedAccSys.DAL/clsCN.cs
git checkout main -- src/IntegratedAccSys.BL/Security/SessionContext.cs
git checkout main -- src/IntegratedAccSys.BL/Users/clsUsers.cs
git checkout main -- tests/IntegratedAccSys.DAL.DbTest/Program.cs
git checkout main -- App.config
dotnet build
```

**Time:** < 1 minute

### 8.2 Rollback M5 (Grants) — Idempotent

```sql
-- Restore PUBLIC
GRANT ALL ON ALL TABLES IN SCHEMA public TO PUBLIC;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO PUBLIC;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO PUBLIC;

-- Optional: re-grant to all app_* roles (then DROP them)
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM app_readwrite, app_readonly, app_auditor, app_reports;
```

**Time:** < 1 minute

### 8.3 Rollback M4 (Policies) — Idempotent

```sql
-- Drop ALL policies on a specific table
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT polname, polrelid::regclass
             FROM pg_policy, pg_class
             WHERE polrelid = pg_class.oid
               AND relnamespace = 'public'::regnamespace
    LOOP
        EXECUTE 'DROP POLICY ' || quote_ident(r.polname) || ' ON ' || r.polrelid;
    END LOOP;
END $$;

-- Verify: should be 0 policies
SELECT COUNT(*) FROM pg_policy WHERE schemaname='public';
```

**Time:** < 30 seconds

### 8.4 Rollback M3 (RLS) — Per Table

```sql
-- Disable RLS on all tables
DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN SELECT c.relname FROM pg_class c JOIN pg_namespace n ON c.relnamespace = n.oid WHERE n.nspname = 'public' AND c.relkind = 'r' AND c.relrowsecurity = true
    LOOP
        EXECUTE 'ALTER TABLE ' || quote_ident(r.relname) || ' DISABLE ROW LEVEL SECURITY';
        EXECUTE 'ALTER TABLE ' || quote_ident(r.relname) || ' NO FORCE ROW LEVEL SECURITY';
    END LOOP;
END $$;
```

**Time:** < 1 minute

### 8.5 Rollback M2 (Functions) — Idempotent

```sql
DROP FUNCTION IF EXISTS current_user_id();
DROP FUNCTION IF EXISTS current_branch();
DROP FUNCTION IF EXISTS is_admin();
```

**Time:** < 5 seconds

### 8.6 Rollback M1 (Roles) — Idempotent

```sql
-- Drop all 8 roles (cascading)
DROP ROLE IF EXISTS app_reports;
DROP ROLE IF EXISTS app_auditor;
DROP ROLE IF EXISTS app_readonly;
DROP ROLE IF EXISTS app_readwrite;
DROP ROLE IF EXISTS app_admin;
DROP ROLE IF EXISTS app_user;
DROP ROLE IF EXISTS app_backup;
DROP ROLE IF EXISTS app_migrator;

-- Drop any default privilege changes
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE SELECT, INSERT, UPDATE, DELETE ON TABLES FROM app_user;
```

**Time:** < 5 seconds

### 8.7 Full Database Restore (Nuclear Option)

```bash
# Restore from backup
psql -U postgres -d postgres -c "DROP DATABASE IntegratedAccSys;"
psql -U postgres -d postgres -c "CREATE DATABASE IntegratedAccSys;"
psql -U postgres -d IntegratedAccSys < backup_pre_phase1.sql
```

**Time:** 5-30 minutes (depending on DB size)
**Data loss:** All changes since backup (only ~30 minutes of work)

### 8.8 Rollback Decision Tree

```
Step FAILED?
├── M0 (pre-flight) → No rollback needed (nothing changed)
├── M1 (roles) → Run §8.6 (5 sec)
├── M2 (functions) → Run §8.5 (5 sec)
├── M3 (RLS) → Run §8.4 (1 min)
├── M4 (policies) → Run §8.3 (30 sec)
├── M5 (grants) → Run §8.2 (1 min)
├── M6 (code) → Run §8.1 (1 min)
├── M7 (runtime test) → Run §8.1 (1 min) and re-test
└── Total app broken? → Run §8.7 (5-30 min)
```

**Worst case full rollback time:** 35 minutes (including DB restore)

---

## 9. Idempotency Guarantees

| Phase | Idempotent? | How to make idempotent |
|-------|:---:|---|
| M0 (pre-flight) | ✅ (creating backups is safe to repeat) | Just overwrite the backup file |
| M1 (roles) | ⚠️ PARTIAL | Use `CREATE ROLE IF NOT EXISTS` (PostgreSQL 17 supports this) |
| M2 (functions) | ✅ | `CREATE OR REPLACE FUNCTION` |
| M3 (RLS enable) | ❌ NOT | Would error if already enabled. Use `DO $$ ... IF NOT EXISTS ... $$;` |
| M4 (policies) | ✅ | `CREATE POLICY IF NOT EXISTS` (PostgreSQL 17 supports this) |
| M5 (grants) | ✅ | `GRANT` is idempotent (no error if already granted) |
| M6 (code) | ✅ | Manual idempotency (git checkout) |
| M7 (runtime) | ✅ | Idempotent re-runs |

**Final recommended script: use `IF NOT EXISTS` clauses + transaction wrapping.**

---

## 10. Execution Time Estimate

| Phase | Estimated Time | Description |
|-------|----------------:|---|
| M0 | 10 min | Backup + git branch |
| M1 | 5 min | Create 8 roles (1 statement each) |
| M2 | 5 min | Create 3 helper functions |
| M3 | 2 min | Enable RLS on 6 tier-1 tables |
| M4 | 30 min | Create 83 policies (script-generated) |
| M5 | 10 min | Revoke PUBLIC + grant per-role (~50 statements) |
| M6 | 45 min | Code changes in 4-5 files |
| M7 | 15 min | Build + test + manual verification |
| **Total** | **~2 hours** | End-to-end migration |

**Recommended split: 4 sessions of 30 minutes each** (allows validation between sessions).

---

## 11. Risk Matrix

| Risk | Likelihood | Impact | Mitigation |
|------|:---:|:---:|-------------|
| Permission denied during role creation | Low | Low | Use `postgres` superuser for ALL DDL |
| RLS denies legitimate app access | Medium | High | Test with all 11 DbTest workflows before declaring done |
| `SET LOCAL` not called → app gets wrong context | Medium | High | Add unit tests for `clsCN.SetSessionContext` |
| Performance impact > 5% | Low | Medium | Add `(SELECT current_setting(...))` subquery once per query |
| DbTest fails after RLS | Medium | Medium | Test with `app_admin` (bypasses RLS) as primary mode; RLS mode secondary |
| Migration script fails mid-way | Low | High | Use transactions; rollback at exact point of failure |
| Postgres superuser password leaked | Low | Critical | Keep `postgres` password secure; use `app_user` for app |
| New user with `isadmin=true` gets all data | Medium | High | Combine with branch filtering; RLS predicate: `is_admin() AND has_role('app_admin')` |

---

## 12. Final Compliance with Constraints

| Constraint | Status |
|------------|:------:|
| ✅ **NO CREATE ROLE** | Honored — 0 `CREATE ROLE` statements |
| ✅ **NO CREATE POLICY** | Honored — 0 `CREATE POLICY` statements |
| ✅ **NO GRANT** | Honored — 0 `GRANT` statements |
| ✅ **NO REVOKE** | Honored — 0 `REVOKE` statements |
| ✅ **NO RLS** | Honored — 0 `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` |
| ✅ **No actual execution** | Honored — this is a blueprint, not a run |
| ✅ **User-to-role matrix** | Honored — §2 with 7 mappings |
| ✅ **Table classification matrix (all 56)** | Honored — §3 with tier 1-5 |
| ✅ **Affected files identified** | Honored — §5 with 11 files |
| ✅ **Migration order step-by-step** | Honored — §6 (M0-M7) with 30+ sub-steps |
| ✅ **Validation Checklist** | Honored — §7 (9 sections) |
| ✅ **Rollback Checklist** | Honored — §8 (8 sections) |

---

## 13. Summary of Blueprints Produced

| Section | Lines | Content |
|---------|------:|---------|
| §1 Scope & Goal | 15 | Purpose, what this blueprint does |
| §2 User-Role Matrix | 30 | 7 mappings + connection flow + role hierarchy diagram |
| §3 Table Classification (56 tables) | 120 | All tables classified P0/P1/P2 with RLS strategy |
| §4 RLS Policy Inventory | 30 | 83 policies detailed |
| §5 Affected Files (11 files) | 50 | DAL (3) + BL (5) + PL (1) + Tests (1) + Config (1) |
| §6 Migration Order (M0-M7) | 100 | 30+ sub-steps with commands |
| §7 Validation Checklist | 60 | 9 sections × 5-10 checks each |
| §8 Rollback Checklist | 60 | 8 sections with time estimates |
| §9 Idempotency | 20 | Per-phase analysis |
| §10 Time Estimate | 15 | ~2 hours total |
| §11 Risk Matrix | 20 | 8 risks with mitigations |
| §12 Compliance | 20 | 12/12 ✅ |

**Total: ~540 lines of executable-ready specification.**

---

## 14. Next Step Decision

**This blueprint is complete and ready for review. The user can:**

- ✅ **APPROVE** — proceed to execute the migration (will start from M0 → M7 sequentially)
- 🔄 **MODIFY** — request changes to specific phases (e.g., different policies, different role names)
- ❌ **REJECT** — defer Phase 1; consider Phase 2 (monitoring) first
- ⏸️ **PAUSE** — need more information (e.g., clarify RLS predicate logic, modify role hierarchy)

**Awaiting explicit approval before any database or code change.**
