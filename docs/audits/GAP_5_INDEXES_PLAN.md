# 📊 خطة Gap #5 — Indexes Optimization (Composite + Partial + Drop Unused)

**المشروع:** Integrated Accounts System (IntegratedAccSys)
**التاريخ:** 2026-06-11
**الفجوة:** #5 من `ENTERPRISE_GAP_ANALYSIS.md` — Indexes (🟡 MEDIUM)
**الفرع:** `feat/gap-5-indexes-optimization`
**الحالة:** 📋 **PLANNED** — التنفيذ بـ commits صغيرة قابلة للمراجعة

---

## 1. Baseline (ما هو موجود قبل البدء)

> **ملاحظة مهمة:** الـ live DB في dev لا يوجد فيه workload حقيقي. هذا يعني
> أن `idx_scan = 0` لا يدلّ على "غير مستخدم فعلياً" — فقط لم تُستدعَ queries
> كافية. لذلك نُؤجّل DROP UNUSED إلى ما بعد جمع بيانات production.

| القياس | القيمة | ملاحظة |
|---|---:|---|
| Total user indexes | 229 | |
| Indexes with `idx_scan = 0` | 219 (96%) | ⚠️ **مُضلل** — لا workload |
| Total user tables | 75 | |
| Tables with `seq_scan > 100` | 0 | ⚠️ نفس السبب |
| Wasted bytes (idx_scan=0) | 38 MB | للمرجع فقط |
| Composite indexes | 0 | ❌ كل الـ indexes أحادية العمود |
| Partial indexes | 0 | ❌ لا `WHERE isactive = true` style |

**الاستنتاج:** في dev، لا نستطيع تمييز الـ "truly unused" من الـ "rarely used". لذلك:

> **الجزء الآمن (يُنفَّذ في هذا الـ PR):** ADD composite + partial indexes
> **الجزء المُؤجَّل:** DROP unused — يحتاج 30 يوم من بيانات production أولاً

---

## 2. نطاق Gap 5 المُعدَّل (5 commits صغيرة)

### Commit 1: هذه الخطة (توثيق)

`docs/audits/GAP_5_INDEXES_PLAN.md` — لا تغييرات على الكود.

### Commit 2: Baseline metrics captured

يُلتقط snapshot من `vw_index_usage` و `vw_unused_indexes` في
`docs/audits/gap-5-baseline.txt` (للمرجع + المقارنة بعد التنفيذ).

### Commit 3: 6 Composite indexes (الأمان أولاً)

كل INDEX يُنشأ بـ `CREATE INDEX CONCURRENTLY IF NOT EXISTS`:
- لا قفل write على الجدول أثناء البناء
- idempotent — يمكن إعادة التشغيل
- Naming: `idx_<table>_<col1>_<col2>...`

| # | الجدول | الأعمدة | المبرر |
|---|---|---|---|
| 1 | `tbljournalbody` | `(journalcode, accountcode)` | account statement queries |
| 2 | `tblbondbody` | `(bondcode, accountcode)` | bond detail lookup |
| 3 | `tblsessions` | `(userid, isactive, expiresat)` | "active sessions by user" |
| 4 | `tblaudi` | `(tablename, recordid, actiondate DESC)` | audit history |
| 5 | `tblcashreceipts` | `(receiptdate, cashboxid, status)` | cash flow reports |
| 6 | `tblcashpayments` | `(paymentdate, cashboxid, status)` | cash flow reports |

### Commit 4: 4 Partial indexes

كل INDEX يُنشأ بـ `CREATE INDEX CONCURRENTLY IF NOT EXISTS`:
- `idx_tblusers_active` ON `tblusers (usercode) WHERE isactive = true`
- `idx_tblproducts_inventory` ON `tblproducts (productcode) WHERE isinventoryitem = true AND isactive = true`
- `idx_tblsessions_active_now` ON `tblsessions (usercode) WHERE isactive = true AND expiresat > now()`
- `idx_approvalrequests_pending` ON `tblapprovalrequests (workflowcode, requestedat) WHERE status = 'PENDING'`

### Commit 5: Audit script

`scripts/audit-g5-indexes.ps1` يفحص:
1. الـ 6 composite indexes موجودة
2. الـ 4 partial indexes موجودة
3. الـ indexes تم إنشاؤها بـ ` indisready = true` (لا ongoing build)
4. Signature function returns `GAP5-INDEXES-2026-06-11-v1`

### Commit 6: Report

`docs/audits/GAP_5_INDEXES_REPORT.md` بنفس بنية الـ reports السابقة.

---

## 3. ما **لا** يُنفَّذ في هذا الـ PR (مُؤجَّل)

| الإجراء | السبب | متى يُنفَّذ |
|---|---|---|
| DROP unused indexes | لا workload في dev لتحديد "truly unused" | بعد 30 يوم production |
| REINDEX لـ bloat | يحتاج `pgstattuple` analysis على بيانات فعلية | بعد جمع بيانات production |
| Indexes على MVs | يحتاج Materialized Views (gap 7) | بعد gap 7 |

---

## 4. معايير النجاح (Definition of Done)

- [ ] dotnet build 0/0
- [ ] DbTest Passed=46 Failed=0
- [ ] audit script X/X PASS
- [ ] كل commit صغير، مُركَّز، مُوثَّق
- [ ] التقرير النهائي يُظهر before/after counts
- [ ] لا regression في gap 1/2/3/4
- [ ] Microsoft best practices:
  - `CONCURRENTLY` (no table lock during creation)
  - `IF NOT EXISTS` (idempotent)
  - Naming convention `idx_<table>_<cols>` / `idx_<table>_<subject>_partial`

---

## 5. التراجع (Rollback)

```sql
DROP INDEX CONCURRENTLY IF EXISTS public.idx_tbljournalbody_journal_account;
-- ... لكل index أُضيف
```

`CONCURRENTLY` يُمكّن من DROP بدون قفل write.

---

## 6. الجهد المُقدَّر

| Commit | الجهد |
|---|---|
| 1 (خطة) | ✅ هذا الملف |
| 2 (baseline) | 5 دقائق |
| 3 (composite) | 15 دقيقة + DbTest |
| 4 (partial) | 15 دقيقة + DbTest |
| 5 (audit) | 15 دقيقة |
| 6 (تقرير) | 15 دقيقة |
| **المجموع** | **~1 ساعة** |

---

## 7. التوقيع

| البند | القيمة |
|---|---|
| **الحالة** | 📋 **PLANNED** |
| **النطاق المُعدَّل** | ADDs only — DROPs مؤجَّلة (لا workload في dev) |
| **الفرع** | `feat/gap-5-indexes-optimization` (مُنشأ) |
| **الخطوة التالية** | تنفيذ commits 2-6 على هذا الفرع |
