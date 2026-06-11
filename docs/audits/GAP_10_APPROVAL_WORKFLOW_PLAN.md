# 📋 خطة Gap #10 — Approval Workflows (State Machine + Triggers)

**المشروع:** Integrated Accounts System (IntegratedAccSys)
**التاريخ:** 2026-06-11
**الفجوة:** #10 من `ENTERPRISE_GAP_ANALYSIS.md` — Approval Workflows (🔴 CRITICAL)
**الفرع:** `feat/gap-10-approval-workflow`
**الحالة:** 📋 **PLANNED** — التنفيذ بـ commits صغيرة قابلة للمراجعة

---

## 1. Baseline (ما هو موجود قبل البدء)

**Tables (7) — موجودة من Gap 1 + أعمال سابقة:**
- `tblapprovalworkflows` — workflow definitions
- `tblapprovalrequests` — actual requests
- `tblapprovalactions` — actions taken
- `tblapprovalaudit` — audit log
- `tblapprovalconfig` — config
- `tblapprovaldelegations` — delegations
- `tblapprovallevels` — levels in a workflow

**Functions (9):**
- `submitforapproval(p_requestid)` (procedure)
- `delegateapproval(...)` (procedure)
- `reassignpendingapprovals(...)` (procedure)
- `fn_auto_submit_for_approval(...)`
- `getapprovalconfig(...)`
- `getapprovalstatus(...)`
- `getnextapprovallevel(...)`
- `getpendingapprovals(...)`
- `isapprovalcomplete(p_requestid)` ← يُمكن استخدامَه في الـ trigger

**Triggers: 0** ← **هذا هو الفجوة الحقيقي**
**Views: 0** للـ workflow dashboard

**Status flow (من الـ CHECK constraints):**
- `tblapprovalrequests.status`:
  - `PENDING` → `IN_REVIEW` → `APPROVED` / `REJECTED` / `CANCELLED` / `EXPIRED`
- `tblapprovalactions.actiontype`:
  - `SUBMITTED` / `APPROVED` / `REJECTED` / `DELEGATED` / `RETURNED` / `EXPIRED` / `CANCELLED`

**ما يُنفَّذ في هذا الـ PR (5 commits):**

---

## 2. نطاق Gap 10 المُعدَّل (6 commits صغيرة)

### Commit 1: هذه الخطة (توثيق)

`docs/audits/GAP_10_APPROVAL_WORKFLOW_PLAN.md` — لا تغييرات على الكود.

### Commit 2: 2 Helper Functions (Part A)

| Function | النوع | الغرض |
|---|---|---|
| `fn_g10_approval_valid_transition(old_status, new_status)` | `bool` | يَتحقق من صلاحية الانتقال بين حالات |
| `fn_g10_approval_compute_status(p_requestid)` | `text` | يَحسب الحالة المتوقَّعة من الـ actions |

**State machine المُعتمدة:**

```
PENDING ──submit──> IN_REVIEW ──approve all levels──> APPROVED
   │                  │
   │                  ├──reject──> REJECTED
   │                  ├──delegate──> IN_REVIEW (with new approver)
   │                  └──return──> PENDING
   │
   ├──cancel──> CANCELLED
   └──expire──> EXPIRED
```

### Commit 3: 2 Triggers (Part B)

| Trigger | التوقيت | الجدول | الفعل |
|---|---|---|---|
| `trg_g10_approval_action_audit` | AFTER INSERT | `tblapprovalactions` | INSERT في `tblapprovalaudit` (action logged) |
| `trg_g10_approval_request_status_update` | AFTER INSERT | `tblapprovalactions` | UPDATE `tblapprovalrequests.status` استناداً إلى الـ action + استدعاء `isapprovalcomplete()` |

**السلامة:**
- كل trigger يستخدم `DROP TRIGGER IF EXISTS` ثم `CREATE TRIGGER` — idempotent
- `WHEN (OLD.* IS DISTINCT FROM NEW.*)` لتجنّب firing على no-op
- `isapprovalcomplete()` يُستدعى من الـ trigger لتحديد ما إذا كان الطلب كاملاً

### Commit 4: Dashboard View

`vw_approval_workflow_dashboard` — يَجمع:
- request info (number, source, totals, dates)
- current level + total levels
- latest action (status, approver, date)
- workflow name
- status (final / in-flight / rejected)

### Commit 5: Audit script + Idempotency

- `scripts/audit-g10-approval-workflow.ps1` يفحص:
  1. 2 idempotency signatures
  2. 2 helper functions موجودة
  3. 2 triggers موجودة ومُفعَّلة
  4. View موجود
  5. Smoke test: INSERT في `tblapprovalactions` يُفعّل كلا الـ triggers

### Commit 6: Final report

`docs/audits/GAP_10_APPROVAL_WORKFLOW_REPORT.md`.

---

## 3. Microsoft / PostgreSQL Best Practices المُتّبعة

| الممارسة | كيف طُبَّقت |
|---|---|
| `DROP TRIGGER IF EXISTS` + `CREATE TRIGGER` | ✅ idempotent |
| `WHEN (OLD.* IS DISTINCT FROM NEW.*)` | ✅ يتجنّب firing على no-op |
| `EXECUTE PROCEDURE fn_...()` (not inline) | ✅ منطق قابل للاختبار مُستقلاً |
| `SECURITY DEFINER` على الدوال الحساسة | ✅ نَمنع privilege escalation |
| `IMMUTABLE` / `STABLE` / `VOLATILE` correctly | ✅ `STABLE` للـ query functions |
| `IF NOT EXISTS` على الـ functions | ✅ متّفق مع gap 2-7 |
| `EXCEPTION WHEN OTHERS` يُسجّل في audit | ✅ يتجنّب تعطّل الـ trigger |

---

## 4. معايير النجاح (Definition of Done)

- [ ] dotnet build 0/0
- [ ] DbTest Passed=46 Failed=0
- [ ] audit script X/X PASS
- [ ] كل commit صغير، مُركَّز، مُوثَّق
- [ ] لا regression في gap 1/2/3/4/5/7
- [ ] 0 Empty Commits

---

## 5. التراجع (Rollback)

```sql
DROP TRIGGER IF EXISTS trg_g10_approval_action_audit ON tblapprovalactions;
DROP TRIGGER IF EXISTS trg_g10_approval_request_status_update ON tblapprovalactions;
DROP FUNCTION IF EXISTS fn_g10_approval_compute_status(bigint);
DROP FUNCTION IF EXISTS fn_g10_approval_valid_transition(text, text);
DROP MATERIALIZED VIEW IF EXISTS vw_approval_workflow_dashboard;  -- not a MV
DROP VIEW IF EXISTS vw_approval_workflow_dashboard;
```

---

## 6. الجهد المُقدَّر

| Commit | الجهد |
|---|---|
| 1 (خطة) | ✅ هذا الملف |
| 2 (Part A — 2 functions) | 20 دقيقة |
| 3 (Part B — 2 triggers) | 25 دقيقة |
| 4 (view) | 15 دقيقة |
| 5 (audit) | 15 دقيقة |
| 6 (تقرير) | 15 دقيقة |
| **المجموع** | **~1.5 ساعة** |

---

## 7. التوقيع

| البند | القيمة |
|---|---|
| **الحالة** | 📋 **PLANNED** |
| **الفرع** | `feat/gap-10-approval-workflow` (مُنشأ) |
| **الخطوة التالية** | تنفيذ commits 2-6 |
