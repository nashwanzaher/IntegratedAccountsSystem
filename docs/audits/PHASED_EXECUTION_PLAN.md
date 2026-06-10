# 🗺️ Phased Execution Plan — Enterprise PostgreSQL Completion

**Date:** 2026-06-09
**Database:** PostgreSQL 17.10 (`IntegratedAccSys`) — 76 tables, 125 functions, 69 procedures, 20 views
**Method:** Read-only plan — **NO modifications, NO new code, NO builds**
**Status:** 📋 **PLAN ONLY — Phase 1 awaiting approval**

---

## 1. Phasing Strategy

The plan is divided into **8 isolated phases**, each addressing a single enterprise concern. Phases are ordered by:

1. **Business impact** — what breaks first if not fixed
2. **Architectural foundation** — what other phases depend on
3. **Risk reduction** — what stabilizes the system

**Each phase is:**

- Independent (can be deferred without blocking other phases)
- Self-contained (delivers one verifiable objective)
- Reversible (rollback plan provided)

**Approval workflow:** Wait for explicit approval before moving to the next phase.

---

## 🔴 PHASE 1: Roles, Permissions & Row-Level Security (RLS) — **HIGHEST PRIORITY**

### 1.1 Objective (Single Isolated Goal)

**Replace the current 2-roles / 191-PUBLIC-privileges / 0-RLS setup with a proper multi-tier role hierarchy and Row-Level Security policies on all sensitive tables.**

> **Why this is Phase 1:** Without proper roles and RLS, every other security measure is moot. The application currently uses `postgres` (superuser) which has unlimited access. This is the foundation for all other security work.

### 1.2 Current State (Baseline)

| Aspect | Value |
|--------|-------|
| Custom roles | 2 (`noufexerp`, `postgres`) |
| App user | `postgres` (SUPERUSER) |
| PUBLIC privileges | 191 (way too many) |
| Distinct grantees | 3 |
| RLS policies | **0** |
| Sensitive tables accessible to all | 76/76 (100%) |

### 1.3 Target State (After Phase 1)

| Aspect | Target |
|--------|--------|
| Custom roles | **8** (1 app + 1 admin + 6 functional) |
| App user | `app_user` (NOSUPERUSER, NOCREATEDB) |
| PUBLIC privileges | **0** (revoke all) |
| RLS policies | **30+** on sensitive tables |
| Sensitive tables | All protected by RLS |

### 1.4 Roles to Create (8)

| Role Name | Purpose | Key Privileges |
|-----------|---------|-----------------|
| `app_user` | Default role for WinForms app | `CONNECT`, `TEMPORARY`, `USAGE` on schema `public` |
| `app_admin` | Application DBA | `app_user` + table ownership, sequence management |
| `app_readwrite` | Standard user with write access | `SELECT/INSERT/UPDATE/DELETE` on operational tables |
| `app_readonly` | Reporting/audit role | `SELECT` only on operational tables |
| `app_auditor` | Audit/Auditor role | `SELECT` on `tblaudi`, `tblauditlogs`, `tblsessions` |
| `app_reports` | Reporting tools (BI) | `SELECT` on `vw_*`, materialized views, `tblreportdefinitions` |
| `app_backup` | Backup/restore | `pg_read_server_files`, `pg_write_server_files` (restricted) |
| `app_migrator` | Schema migration | `CREATE`, `DROP`, `ALTER` on `public` schema |

### 1.5 Tables Requiring RLS (30+)

**Tier 1 — Critical (must have RLS):**

- `tblusers` (PII, passwords)
- `tblsessions` (auth tokens)
- `tbluserroles`, `tbluserroleassignments` (permissions)
- `tblprivileges` (access control)
- `tblauditlogs`, `tblaudi` (audit trail)
- `tblbankaccounts`, `tblbankstatements`, `tblbanktransactions` (financial)
- `tblcashboxes`, `tblcashreceipts`, `tblcashpayments` (financial)
- `tblbankreconciliations` (sensitive reconciliation data)

**Tier 2 — High (should have RLS):**

- `tblcustomers`, `tblsuppliers` (PII)
- `tblcustomercontacts`, `tblsuppliercontacts` (PII)
- `tblproducts`, `tblproductpricing` (pricing)
- `tblnotifications` (private messages)

**Tier 3 — Medium (recommended):**

- All other operational tables (bonds, journals, operations)

### 1.6 RLS Policy Pattern (Example for `tblusers`)

```sql
-- Example pattern, NOT applied yet
ALTER TABLE tblusers ENABLE ROW LEVEL SECURITY;

CREATE POLICY users_branch_isolation ON tblusers
    FOR ALL TO app_user
    USING (
        branchcode = (
            SELECT branchcode FROM tblusers
            WHERE usercode = current_setting('app.current_user')::INTEGER
        )
        OR current_setting('app.is_admin')::BOOLEAN = TRUE
    );

CREATE POLICY users_admin_bypass ON tblusers
    FOR ALL TO app_admin
    USING (TRUE) WITH CHECK (TRUE);
```

### 1.7 Validation Criteria (How to Verify Success)

| # | Check | Expected Result | How to Verify |
|---|-------|------------------|---------------|
| 1 | All 8 roles exist | 8 rows in `pg_roles` (excluding postgres) | `SELECT rolname FROM pg_roles WHERE rolname LIKE 'app_%';` |
| 2 | `app_user` has no superuser | `rolsuper = f` | `SELECT rolsuper FROM pg_roles WHERE rolname='app_user';` |
| 3 | PUBLIC has no table privileges | 0 rows | `SELECT * FROM information_schema.role_table_grants WHERE grantee='PUBLIC' AND table_schema='public' AND privilege_type<>'EXECUTE';` |
| 4 | RLS is enabled on tier-1 tables | `rowsecurity = t` | `SELECT tablename, relrowsecurity FROM pg_tables t JOIN pg_class c ON c.relname=t.tablename WHERE t.schemaname='public' AND tablename IN ('tblusers','tblsessions',...);` |
| 5 | At least 30 RLS policies exist | 30+ rows in `pg_policies` | `SELECT COUNT(*) FROM pg_policies WHERE schemaname='public';` |
| 6 | App login as `app_user` works | Login succeeds, `current_user='app_user'` | `psql -U app_user -d IntegratedAccSys -c 'SELECT current_user;'` |
| 7 | Cross-tenant isolation works | User in branch X cannot see branch Y data | Login as `app_user` with `app.current_user`=1, query `tblusers`, expect only branch 1 users |
| 8 | Admin bypass works | `app_admin` sees all data | Login as `app_admin`, query any table, expect all rows |
| 9 | Build still clean | 0 errors, 0 warnings | `dotnet build` |
| 10 | DbTest still passes | 11/11 PASS | `dotnet run --project tests/IntegratedAccSys.DAL.DbTest` |

### 1.8 Dependencies (What Phase 1 Needs)

| Dependency | Status | Notes |
|------------|--------|-------|
| Live PostgreSQL running | ✅ Verified | localhost:5432 |
| DB has `IntegratedAccSys` | ✅ Verified | 290 objects |
| All 76 tables exist | ✅ Verified | From DB extension |
| App connects via `postgres` | ⚠️ Current state | Must be changed to `app_user` after RLS |
| App code uses Npgsql | ✅ Verified | DAL uses Npgsql 8.0.4 |
| `dotnet build` clean | ✅ Verified | 0 errors, 0 warnings |
| DbTest 11/11 PASS | ✅ Verified | All workflows work |

### 1.9 Risks

| Risk | Likelihood | Impact | Mitigation |
|------|:----------:|:------:|-------------|
| Breaking existing app login | Medium | High | Keep `postgres` role with full access; add `app_user` alongside; switch app config last |
| RLS denies legitimate access | Medium | High | Test with all 11 DbTest workflows; add `app_admin` bypass policy |
| Performance impact of RLS | Low | Medium | Add `(SELECT current_setting(...))` once in policy; cache in session |
| Need to update DAL connection string | Low | Low | Single file change in `DalSettings` |
| Lockout during migration | Low | High | Keep `postgres` as superuser; never drop it |
| C# code may have hardcoded `postgres` user | Medium | Medium | Search & update all `User ID=postgres` references |

### 1.10 Rollback Plan

**If anything goes wrong, the rollback is simple:**

```sql
-- 1. Drop all policies (idempotent)
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

-- 2. Disable RLS on all tables
ALTER TABLE tblusers DISABLE ROW LEVEL SECURITY;
ALTER TABLE tblsessions DISABLE ROW LEVEL SECURITY;
-- ... (repeat for all tier-1/2 tables)

-- 3. Restore PUBLIC privileges
GRANT ALL ON ALL TABLES IN SCHEMA public TO PUBLIC;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO PUBLIC;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO PUBLIC;

-- 4. Optionally drop the app_* roles (only if they break anything)
DROP ROLE IF EXISTS app_user;
DROP ROLE IF EXISTS app_admin;
-- ... (etc.)

-- 5. Update DAL connection string back to "postgres" if app is broken
```

**Rollback time:** < 5 minutes
**Data loss:** None (no data modified, only permissions changed)
**Recovery point:** Immediate (no transactional impact)

### 1.11 Expected Impact

| Impact Area | Before Phase 1 | After Phase 1 |
|------------|----------------|---------------|
| App user privileges | UNLIMITED (superuser) | Restricted per role |
| PUBLIC access to tables | 191 grants | 0 grants |
| Cross-tenant data leak | Possible (all roles see all data) | **PREVENTED** by RLS |
| Audit accountability | Low (all actions look like "postgres") | High (each app user is identifiable) |
| Production readiness | NOT READY (security gap) | Closer to ready |
| Performance overhead | 0 (no RLS) | < 5% (RLS predicates are subqueries, optimized) |
| Code changes | None | 1 line in `DalSettings.cs` |

### 1.12 Implementation Steps (Not Applied — Awaiting Approval)

The following steps would be performed to implement Phase 1. **None have been executed yet.**

1. **Inspect existing connection string** in `src/IntegratedAccSys.DAL/DalSettings.cs`
2. **Create 8 roles** via `CREATE ROLE ... NOSUPERUSER NOCREATEDB`
3. **Grant schema usage** to all 8 roles
4. **Revoke PUBLIC** from schema and tables
5. **Grant table-level permissions** to each role (SELECT/INSERT/UPDATE/DELETE per table)
6. **Enable RLS** on tier-1 tables (12 tables)
7. **Create RLS policies** (~30 policies)
8. **Update `DalSettings.cs`** to use `app_user` instead of `postgres`
9. **Update `App.config`** to use new connection credentials
10. **Run validation suite** (10 checks from §1.7)
11. **Run DbTest** to verify no regression
12. **Document** in `docs/database/SECURITY_MODEL.md`

### 1.13 Estimated Time & Effort

| Task | Estimated Time |
|------|----------------:|
| Role creation + privilege grants | 30 minutes |
| RLS policy design (30+ policies) | 2 hours |
| Tier-1 table RLS implementation | 1 hour |
| Tier-2 table RLS implementation | 1 hour |
| App connection string update | 15 minutes |
| Testing & validation (10 checks + 11 DbTests) | 1 hour |
| Documentation | 30 minutes |
| **TOTAL** | **~6 hours** |

### 1.14 Decision Required

**Please confirm one of the following:**

- ✅ **APPROVE** — Proceed with Phase 1 implementation
- 🔄 **MODIFY** — Specify changes to the plan (e.g., different roles, different tier-1 tables, different policy pattern)
- ❌ **REJECT** — Defer Phase 1; specify which phase should be next
- ⏸️ **PAUSE** — Need more info before deciding

---

## 📋 Plan for Future Phases (Brief — Detail on Approval)

| Phase | Title | Priority | Depends On | Est. Time |
|:-----:|-------|:--------:|-----------|----------:|
| **2** | Enable SSL + pgaudit + monitoring extensions | 🔴 CRITICAL | Phase 1 | 4 hours |
| **3** | Approval workflow tables (5 tables + state machine) | 🔴 CRITICAL | Phase 1 | 8 hours |
| **4** | Materialized views (5-6 critical reports) | 🔴 CRITICAL | None | 6 hours |
| **5** | Closing controls (closeYear, closePeriod, block-posting triggers) | 🟡 HIGH | Phase 1 | 4 hours |
| **6** | Dimensions (departments, projects, segments) + extended cost center | 🟡 HIGH | None | 6 hours |
| **7** | Constraints cleanup (CHECK + EXCLUSION + unused index removal) | 🟡 MEDIUM | None | 4 hours |
| **8** | pg_cron + pg_partman (partitioning + scheduled maintenance) | 🟡 MEDIUM | Phase 1 | 8 hours |

**Total estimated time for all 8 phases:** ~46 hours (~6 working days)

---

## 2. Why This Order?

**Phase 1 (Roles + RLS) FIRST** because:

- All other security (Phase 2) assumes proper roles exist
- All other phases that modify tables need RLS-aware policies
- Without roles, you can't safely test other features
- Highest business risk: data leak in production

**Phase 2 (Monitoring) SECOND** because:

- Once roles are in place, you need to know what each role is doing
- pgaudit provides tamper-evident log of all role activities
- Required for any compliance audit

**Phase 3 (Approval Workflows) THIRD** because:

- Business-critical (financial transactions)
- Most user-facing feature missing
- Depends on roles for approver identity

**Phases 4-8** are operational enhancements (reporting, performance, governance) — important but not blocking.

---

## 3. Compliance with Plan-Only Constraints

| Constraint | Status |
|------------|:------:|
| ✅ **NO building at once** | Honored — only Phase 1 detailed; 7 others are brief |
| ✅ **NO modification** | Honored — 0 source files modified |
| ✅ **Single isolated objective per phase** | Honored — each phase has one clear goal |
| ✅ **Based on actual DB state** | Honored — uses the 290 objects from previous extension work |
| ✅ **Prioritized by business impact** | Honored — 3 CRITICAL phases first |
| ✅ **Validation criteria** | Honored — 10 checks defined for Phase 1 |
| ✅ **Dependencies** | Honored — 7 dependencies identified |
| ✅ **Risks** | Honored — 6 risks with mitigations |
| ✅ **Rollback plan** | Honored — 5-step < 5 minute rollback |
| ✅ **Expected impact** | Honored — before/after comparison provided |
| ✅ **Start with highest-priority only** | Honored — Phase 1 detailed; waiting for approval |

---

**End of Phased Execution Plan — Status: ⏸️ AWAITING APPROVAL FOR PHASE 1**

**The next step (Phase 2+) will be selected by the user after reviewing this plan.**
