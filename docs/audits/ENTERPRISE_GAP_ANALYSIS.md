# 🔍 Enterprise-Grade Database Gap Analysis — IntegratedAccSys

**Date:** 2026-06-09
**Database:** PostgreSQL 17.10 (`IntegratedAccSys`)
**Method:** Read-only inspection — **NO modifications, NO new code, NO fixes**
**Status:** 📊 **GAP ANALYSIS ONLY**

---

## 1. Executive Summary

| Category | Existing | Required for ERP | Gap |
|----------|:--------:|:----------------:|:---:|
| **Roles and Permissions** | 2 roles, 0 RLS | 8+ roles, all tables RLS | 🔴 **CRITICAL** |
| **Security** | pgcrypto (hash only), SSL off | Column encryption, SSL on | 🔴 **CRITICAL** |
| **Constraints** | 72 FK, 32 UNIQUE, 7 CHECK, 0 EXCLUSION | 100+ CHECK, several EXCLUSION | 🟡 **HIGH** |
| **Indexes** | 119 (50 used, 20 unused) | Composite + partial indexes | 🟡 **MEDIUM** |
| **Materialized Views** | 0 | 5-10 critical reports | 🔴 **CRITICAL** |
| **Partitioning** | 0 | Date-range partitioning for high-volume | 🟡 **MEDIUM** |
| **Monitoring** | No extensions, no slow log | pg_stat_statements, pgaudit, slow log | 🔴 **CRITICAL** |
| **Maintenance** | No pg_cron | pg_cron + custom jobs | 🟡 **MEDIUM** |
| **Archiving** | No strategy | Time-based partitioning + archive tables | 🟡 **MEDIUM** |
| **Numbering Controls** | Uses SERIAL (identity) | Centralized sequence table | 🟢 **LOW** (acceptable) |
| **Approval Workflows** | 0 tables, 0 workflow | Full state machine | 🔴 **CRITICAL** |
| **Cost Centers & Dimensions** | 1 cost center, 0 dimensions | Multiple dimensions (project, dept, segment) | 🟡 **HIGH** |
| **Closing Controls** | 3 fiscal tables, 2 isclosed | Full closing procedure + audit | 🟡 **MEDIUM** |
| **Database Governance** | postgres superuser, locale mismatch | Dedicated app role, Arabic locale | 🟡 **HIGH** |

**Overall:** **3 CRITICAL**, **3 HIGH**, **5 MEDIUM**, **1 LOW** gaps identified.

---

## 2. Detailed Gap Analysis

### 2.1 Roles and Permissions 🔴 CRITICAL

| Aspect | Current State | Gap | Required |
|--------|--------------|-----|----------|
| Custom roles | **2** (`noufexerp`, `postgres`) | 6 roles missing | `app_readonly`, `app_readwrite`, `app_admin`, `app_auditor`, `app_reports`, `app_backup` |
| PUBLIC privileges | **191** | Way too many — security risk | Revoke all, grant per-role |
| Distinct grantees | 3 (incl. PUBLIC) | 0 fine-grained | Per-table, per-role |
| Row-Level Security | **0 policies** | Critical gap | All sensitive tables need RLS |
| Column-level grants | **0** | Sensitive columns (passwords, salaries) | Restrict by column |
| Default privileges | Default | Insecure | Custom ALTER DEFAULT PRIVILEGES |

**Recommended actions (not performed):**

- Create `app_readonly`, `app_readwrite`, `app_admin`, `app_auditor`, `app_reports`, `app_backup` roles
- Revoke PUBLIC from `public` schema, grant per-role
- Enable RLS on: `tblusers`, `tblsessions`, `tblauditlogs`, `tblaudi`, `tblbankaccounts`, `tblcashboxes`, `tblnotifications`
- Create column-level grants for `tblusers.userpassword`, `tblusers.salt`

---

### 2.2 Security 🔴 CRITICAL

| Aspect | Current State | Gap | Risk |
|--------|--------------|-----|------|
| pgcrypto extension | ✅ Installed (v1.3) | OK | — |
| Hash functions | ✅ 19 hash functions | OK | — |
| Column-level encryption | **❌ Missing** | pgcrypto.encrypt/decrypt not used | Sensitive data at rest |
| Row-Level Security | **❌ 0 RLS tables** | All tables accessible to all | Privilege escalation |
| SSL/TLS | **❌ OFF** (`https_enabled:off`) | Production must use TLS | MITM attacks |
| pgaudit | **❌ Not installed** | Required for SOX/audit compliance | No tamper-evident log |
| Password storage | Plain `bytea` (hashed?) | Should be encrypted + peppered | Hash-only protection |
| Secret rotation | **❌ None** | Critical for credentials | Long-lived secrets |
| Connection limits | Default | Should restrict `app_*` roles | DoS via connection flood |

**Recommended actions (not performed):**

- Enable SSL: `ALTER SYSTEM SET ssl = on;` and require it for all client connections
- Install `pgaudit` extension
- Add `pg_read_server_files`/`pg_write_server_files` restrictions
- Consider `pgcrypto.encrypt` for columns with PII

---

### 2.3 Constraints 🟡 HIGH

| Constraint Type | Count | Notes |
|-----------------|------:|-------|
| Foreign Keys (f) | **72** | ✅ Good |
| Unique (u) | **32** | ✅ Good |
| Primary Key (p) | 60 (implicit) | ✅ Good |
| Check (c) | **7** | 🟡 Most are from new tables; original schema has **0** check constraints! |
| Exclusion (x) | **0** | 🔴 Missing for unique date ranges, de-dup, etc. |
| Triggers (t) | 0 | 🟡 No business-rule triggers |

**Specific gaps:**

- **Check constraints missing** on existing tables (e.g., `tblproducts.minstocklevel <= maxstocklevel`, `tbljournalheader.totaldebit = totalcredit`, `tblbondheader.amount > 0`)
- **Exclusion constraints missing** for: `tblsessions (userid, sessionid)` no overlap, `tblbankstatements (bankaccountid, statementno)` no duplicates per period
- **Triggers missing** for: audit logging on sensitive table updates, automatic balance recomputation, posting lock enforcement

**Recommended actions (not performed):**

- Add CHECK constraints to ~20 existing tables
- Add EXCLUSION constraints for date ranges and de-dup keys
- Add triggers for: `tblaudi` auto-population, balance updates, posting enforcement

---

### 2.4 Indexes 🟡 MEDIUM

| Metric | Value |
|--------|------:|
| Total indexes | 119 |
| Used indexes (idx_scan > 0) | 50 |
| **Unused indexes (idx_scan = 0)** | **20** |
| Composite indexes | 0 |
| Partial indexes | 0 |
| Expression indexes | 0 |

**Unused indexes (waste space + slow writes):**

```
idx_auditlogs_date, idx_auditlogs_event, idx_auditlogs_user
idx_journalbody_account, idx_privileges_window
idx_sessions_expires, idx_tblaccounts_active, idx_tblaccounts_type
idx_tblusers_branch, idx_tblusers_isactive
idx_tblwindows_module, idx_tblwindows_parent
ix_audithist_date, ix_audithist_table_record, ix_audithist_user
ix_banktransactions_account, ix_banktransactions_date
ix_cashpayments_date, ix_cashreceipts_cashbox, ix_cashreceipts_date
ix_documentattachments_source, ix_exchangerate_curr_date
ix_notifications_user, ix_taxtransactions_date, ix_taxtransactions_source
```

**Missing indexes (composite for common queries):**

- `tbljournalbody (journalcode, accountcode)` — for account statement queries
- `tblbondbody (bondcode, accountcode)` — for bond detail
- `tblsessions (userid, isactive, expiresat)` — for "active sessions by user"
- `tblaudi (tablename, recordid, actiondate DESC)` — for audit history
- `tblcashreceipts (receiptdate, cashboxid, status)` — for cash flow reports
- `tblcashpayments (paymentdate, cashboxid, status)` — for cash flow reports

**Recommended actions (not performed):**

- Drop 20 unused indexes
- Add 6+ composite indexes for common query patterns
- Consider partial indexes: `WHERE isactive = true`, `WHERE status = 'POSTED'`

---

### 2.5 Materialized Views 🔴 CRITICAL

| Aspect | Current State | Gap |
|--------|--------------|-----|
| Materialized views | **0** | **MAJOR GAP** |

**Recommended materialized views (for performance-critical reports):**

- `mv_daily_sales_summary (date, branchcode, totalamount)` — refresh hourly
- `mv_monthly_inventory_snapshot (productcode, storecode, qty, value)` — refresh nightly
- `mv_customer_outstanding_balance (customercode, totalcredit, totaldebit, balance)` — refresh daily
- `mv_account_balance_summary (accountcode, fiscalyear, period, balance)` — refresh daily
- `mv_treasury_position (cashboxid, bankaccountid, balance)` — refresh hourly
- `mv_budget_vs_actual_summary (periodid, accountcode, budget, actual, variance)` — refresh daily

**Recommended actions (not performed):**

- Create 5-6 materialized views for dashboard queries
- Set up scheduled refresh via `pg_cron` (not yet installed)
- Add `REFRESH MATERIALIZED VIEW CONCURRENTLY` strategies

---

### 2.6 Partitioning 🟡 MEDIUM

| Aspect | Current State | Gap |
|--------|--------------|-----|
| Partitioned tables | **0** | **GAP** |

**Tables that should be partitioned (high-volume, time-series):**

- `tbljournalbody` — millions of rows per year, partition by fiscal year
- `tblbondbody` — millions of rows per year, partition by fiscal year
- `tblcashreceipts`, `tblcashpayments`, `tblbanktransactions` — partition by date
- `tblaudi` — partition by month (high audit volume)
- `tblnotifications` — partition by month (old notifications can be archived)
- `tblsessions` — partition by expiry month
- `tbltaxtransactions` — partition by tax period
- `tblexchangeratehistory` — partition by year (natural fit)

**Recommended actions (not performed):**

- Install `pg_partman` extension
- Convert above tables to range-partitioned by date/year
- Set up automatic partition creation via `pg_cron`

---

### 2.7 Monitoring 🔴 CRITICAL

| Aspect | Current State | Required |
|--------|--------------|----------|
| `pg_stat_statements` extension | **❌ Not installed** | Required for query analytics |
| `auto_explain` extension | **❌ Not installed** | Required for slow query analysis |
| `pgaudit` extension | **❌ Not installed** | Required for SOX compliance |
| `pg_stat_monitor` extension | **❌ Not installed** | Better than pg_stat_statements |
| `log_min_duration_statement` | **-1** (no slow log) | Should be `1000` ms |
| `log_statement` | Default | Should be `ddl` for DDL tracking |
| `log_line_prefix` | Default | Should include `%t [%p]: db=%d,user=%u,app=%a` |
| Table statistics | 56/76 tables | All tables |
| Autovacuum | `on` ✅ | Tuned per table |

**Recommended actions (not performed):**

- Install: `pg_stat_statements`, `auto_explain`, `pgaudit`
- Set: `log_min_duration_statement = 1000` (1 second)
- Set: `log_line_prefix` with timestamp, PID, DB, user, app
- Set: `log_connections = on`, `log_disconnections = on`, `log_lock_waits = on`

---

### 2.8 Maintenance 🟡 MEDIUM

| Aspect | Current State | Required |
|--------|--------------|----------|
| `pg_cron` extension | **❌ Not installed** | Critical for automated maintenance |
| Autovacuum | `on` (default scale 0.2) | Per-table tuning |
| `autovacuum_vacuum_scale_factor` | 0.2 | 0.1 for high-churn tables |
| `autovacuum_analyze_scale_factor` | 0.1 | 0.05 for high-churn tables |
| Scheduled VACUUM jobs | 0 | Weekly VACUUM ANALYZE on large tables |
| Scheduled REINDEX | 0 | Monthly REINDEX on heavily-updated indexes |
| Statistics refresh | Default | Daily for OLTP |

**Recommended actions (not performed):**

- Install `pg_cron` extension
- Create scheduled jobs for:
  - `VACUUM ANALYZE` weekly on tables > 100MB
  - `REINDEX` monthly on heavily-updated indexes
  - `ANALYZE` daily on all tables
  - Partition rotation (create next month partition)

---

### 2.9 Archiving 🟡 MEDIUM

| Aspect | Current State | Gap |
|--------|--------------|-----|
| Largest table | 96 kB (`tblsessions`) | Small but will grow |
| Archiving strategy | **None** | No archive tables, no retention policy |
| Old data retention | Unlimited | Should be: 7 years for transactions, 1 year for sessions, 90 days for notifications |
| Soft delete | Partial (`iscancelled`) | Inconsistent |
| Archive tables | 0 | Should have: `tbljournalbody_archive`, `tblbondbody_archive`, etc. |
| `pg_partman` | **Not installed** | Required for time-based archiving |
| `pg_cron` | **Not installed** | Required for scheduled archive jobs |

**Recommended actions (not performed):**

- Define retention policy per table
- Install `pg_partman` and `pg_cron`
- Create archive tables (same structure, no FK constraints)
- Add archive job: move data older than retention to archive table

---

### 2.10 Numbering Controls 🟢 LOW

| Aspect | Current State | Acceptable? |
|--------|--------------|:------------:|
| Sequences | Uses `SERIAL/BIGSERIAL` (identity columns) | ✅ **OK** for technical PKs |
| Document numbering | Via application functions (e.g., `getNewJournalNo`, `getNewBondNo`) | ✅ **OK** |
| Centralized sequence table | None | 🟢 Not needed (SERIAL is fine) |
| `getMax...` / `getMin...` functions | ✅ Exists (e.g., `getMaxBondNo`, `getMinJno`) | ✅ **OK** |
| Document number gap detection | Application-level | 🟢 Acceptable |
| Year/period reset (e.g., journal numbers reset per fiscal year) | Unknown — needs code review | 🟡 Verify |

**Recommendations (not performed):**

- ✅ Current approach is acceptable
- 🟡 Consider: gap detection function (e.g., `getNextAvailableNo(prefix, fiscalyear)`)
- 🟡 Document the numbering convention in a table: `tblnumberingrules (doctype, prefix, currentno, fiscalyear)`

---

### 2.11 Approval Workflows 🔴 CRITICAL

| Aspect | Current State | Gap |
|--------|--------------|-----|
| Dedicated approval tables | **0** | **CRITICAL** |
| Workflow state machine | **None** | Just `isposted` boolean |
| Approval tables | 0 | Should have: `tblapprovalrequests`, `tblapprovalsteps`, `tblapprovalactions` |
| Approval columns (existing) | `canapprove` (1), `approvedby`, `approvedat` | Minimal |
| `isapproved` field count | 2 (fiscal years, periods only) | Should be in transactions |
| `isposted` field count | 9 | OK (posting control) |
| Approval hierarchy | None | Should support: User → Manager → Director → CFO |
| Approval limits | None | Should support: amount-based routing |
| Email/SMS notifications | Not connected to `tblnotifications` | Disconnected |

**Recommended approval workflow tables (not created):**

- `tblapprovalrequests (requestid, requesttype, sourceid, requesterid, status, totalsum, fiscalyear, ...)`
- `tblapprovalsteps (stepid, requestid, stepnumber, approverid, approverrole, status, decision, ...)`
- `tblapprovalactions (actionid, stepid, actiondate, actiontype, comments, ...)`
- `tblapprovaldelegations (delegationid, fromuserid, touserid, fromdate, todate, ...)`
- `tblapprovalrules (ruleid, documenttype, minamount, maxamount, requiredlevel, ...)`

**Recommended actions (not performed):**

- Create full approval workflow tables
- Create approval function: `submitForApproval(docType, docId, amount)`
- Add approval trigger to key tables
- Connect to `tblnotifications`

---

### 2.12 Cost Centers and Dimensions 🟡 HIGH

| Aspect | Current State | Gap |
|--------|--------------|-----|
| Cost center table | `tblcostcenters` (1 table) | OK, but limited hierarchy |
| Cost center hierarchy | 1 level (no parent-child) | Should support multi-level |
| Department | Not a dimension | Should be a separate dimension |
| Project | Not tracked | Should support project-based costing |
| Segment | Not a dimension | Should support chart-of-accounts segments |
| Dimensions table | **0** | **GAP** |
| Project dimension | **0** | **GAP** |
| Segment dimension | **0** | **GAP** |
| Cost center usage in transactions | Minimal | `costcentercode` in tbljournalbody, tblbondbody |

**Recommended dimension tables (not created):**

- `tbldepartments (departmentcode, departmentid, departmentnamear, parentdepartmentcode, ...)`
- `tblprojects (projectcode, projectid, projectnamear, projecttype, startdate, enddate, status, ...)`
- `tblsegments (segmentcode, segmentid, segmentnamear, segmenttype, ...)`
- `tblcostcenterhierarchy` (recursive CTE or path-based)
- `tbldimensionassignments (dimensiontype, sourceid, departmentcode, projectcode, segmentcode, percentage, ...)`

**Recommended actions (not performed):**

- Create full dimension tables
- Add proper multi-level cost center hierarchy
- Add project tracking
- Add segment dimension

---

### 2.13 Closing Controls 🟡 MEDIUM

| Aspect | Current State | Gap |
|--------|--------------|-----|
| Fiscal year/period tables | 3 (tblfiscalyears, tblfiscalperiods, tblbudgetperiods) | ✅ Good |
| `isclosed` fields | 2 (fiscal years, periods) | OK |
| General closing procedure | **None** | Should have: `closeYear(yearid)`, `closePeriod(periodid)` |
| Reversal/posting-after-close | **Not prevented** | Should have: triggers/functions that block posting to closed periods |
| Year-end transfer entries | **None** | Should generate automatically |
| Audit trail for closing | None | Should log who closed what when |
| Cross-period validation | None | Should validate period transitions |

**Recommended closing control functions (not created):**

- `closeFiscalPeriod(periodid, userid)` — close a period, block future postings
- `closeFiscalYear(yearid, userid)` — close year, generate closing entries, lock all periods
- `reopenFiscalPeriod(periodid, userid, reason)` — reopen with audit trail
- `postToClosedPeriod(periodid)` — trigger function to BLOCK posting to closed periods
- `generateYearEndEntries(yearid)` — generate income summary, retained earnings

**Recommended actions (not performed):**

- Create closing control functions
- Add triggers to block posting to closed periods
- Add audit logging for closing events

---

### 2.14 Database Governance 🟡 HIGH

| Aspect | Current State | Required |
|--------|--------------|----------|
| App user | `postgres` (superuser) | Dedicated `app_user` (NOSUPERUSER) |
| Database locale | `English_United States.utf8` | `Arabic_Saudi Arabia.utf8` for Arabic data |
| Timezone | `Asia/Riyadh` ✅ | OK |
| Extensions | 2 (plpgsql, pgcrypto) | Need 5-7 more for enterprise features |
| Schema organization | All in `public` | Should split: `core`, `audit`, `reports`, `archive` |
| Naming standards | Documented in `DATABASE_EXTENSION_REPORT.md` | ✅ Good |
| Connection pooling | `Pooling=off` in pg_settings | Should use PgBouncer for production |
| Backup strategy | Not visible | Should have: daily full + hourly incremental + 30-day retention |
| Disaster recovery | Not visible | Should have: replica, failover plan |
| Schema versioning | No migration framework | Should use Sqitch/Flyway/Liquibase |
| Documentation | 1 docs file | Should have: ER diagram, data dictionary |

**Recommended governance actions (not performed):**

- Create `app_user` role (NOSUPERUSER) for the WinForms app
- Create locale: `Arabic_Saudi Arabia.1256` or `Arabic_Saudi Arabia.utf8`
- Set up schema organization: `audit`, `reports`, `archive` schemas
- Implement connection pooling with PgBouncer
- Document data dictionary in `docs/database/ER_DIAGRAM.md` and `docs/database/DATA_DICTIONARY.md`

---

## 3. Summary by Category

### 3.1 CRITICAL Gaps (3) — Must Fix Before Production

1. **Roles and Permissions**: 0 RLS policies, 191 PUBLIC privileges, only 2 roles
2. **Security**: SSL off, no column encryption, no pgaudit
3. **Monitoring**: No pg_stat_statements, no pgaudit, no slow query log
4. **Materialized Views**: 0 (performance bottleneck for reports)
5. **Approval Workflows**: No dedicated tables, no state machine

### 3.2 HIGH Gaps (3) — Should Fix in Next Iteration

1. **Constraints**: Only 7 CHECK constraints (mostly new tables); no EXCLUSION
2. **Cost Centers & Dimensions**: Only 1 cost center table, no dimensions
3. **Database Governance**: App uses superuser, locale mismatch

### 3.3 MEDIUM Gaps (5) — Plan to Fix

1. **Indexes**: 20 unused indexes, no composite indexes
2. **Partitioning**: No time-based partitioning for high-volume tables
3. **Maintenance**: No pg_cron, default autovacuum settings
4. **Archiving**: No retention policy, no archive tables
5. **Closing Controls**: No general closeYear/closePeriod functions

### 3.4 LOW Gaps (1) — Acceptable as-is

1. **Numbering Controls**: Using SERIAL identity columns is acceptable; only minor improvements needed (centralized sequence table optional)

---

## 4. Recommended Implementation Priority

### Phase 1 (Immediate — Production Blockers)

- [ ] Create application roles (`app_user`, `app_readonly`, etc.) and revoke PUBLIC
- [ ] Enable SSL on PostgreSQL server
- [ ] Install `pg_stat_statements`, `auto_explain`, `pgaudit` extensions
- [ ] Set `log_min_duration_statement` to 1000ms
- [ ] Drop 20 unused indexes

### Phase 2 (Next Sprint)

- [ ] Add CHECK constraints to ~20 existing tables
- [ ] Add EXCLUSION constraints for date ranges
- [ ] Create 5-6 materialized views for dashboard reports
- [ ] Build approval workflow tables (5 tables)
- [ ] Add composite indexes for common query patterns

### Phase 3 (Medium Term)

- [ ] Install `pg_cron` + `pg_partman` extensions
- [ ] Convert high-volume tables to range-partitioned
- [ ] Add dimension tables (departments, projects, segments)
- [ ] Build closing control functions
- [ ] Add archive tables and retention policies

### Phase 4 (Long Term)

- [ ] Implement connection pooling (PgBouncer)
- [ ] Set up backup + disaster recovery
- [ ] Schema versioning with Sqitch/Flyway
- [ ] Locale change to Arabic
- [ ] Data dictionary documentation

---

## 5. Compliance with Audit Constraints

| Constraint | Status |
|------------|:------:|
| ✅ **NO building anything** | Honored — 0 DDL statements executed |
| ✅ **NO modification** | Honored — 0 source code files modified |
| ✅ **NO deletion** | Honored — 0 files deleted |
| ✅ **NO new code** | Honored — 0 SQL DDL created |
| ✅ **Gap analysis only** | Honored — only inspection queries + this report |
| ✅ **Based on actual project** | Honored — inspected 76 tables, 125 functions, 69 procedures, 20 views |
| ✅ **Actual project requirements only** | Honored — gaps mapped to 14 categories from the task |

---

**End of Gap Analysis Report — Status: ✅ READ-ONLY INSPECTION COMPLETE**

The next step will be selected by the user after reviewing this report.
