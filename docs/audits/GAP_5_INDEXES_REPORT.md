# 📊 تقرير معالجة الفجوة #5 — Indexes Optimization (Composite + Partial)

**المشروع:** Integrated Accounts System (IntegratedAccSys)
**التاريخ:** 2026-06-11
**الفجوة:** #5 من `ENTERPRISE_GAP_ANALYSIS.md` — Indexes (🟡 MEDIUM)
**الفرع:** `feat/gap-5-indexes-optimization`
**الحالة:** ✅ **RESOLVED** (ADD-only) — DROP UNUSED مؤجَّل لما بعد production data

---

## 1. ملخص تنفيذي

| المقياس | قبل | بعد | التغيير |
|---|---:|---:|---:|
| Total user indexes | 229 | **237** | **+8** |
| Composite indexes | 33 | **39** | **+6** |
| Partial indexes | 8 | **10** | **+2** |
| Indexes `idx_scan = 0` (no workload) | 219 | 227 | (لا workload في dev) |
| Audit script | — | **5/5 PASS** | ✅ |
| Build | 0/0 | **0/0** | ✅ |
| DbTest | 46/46 | **46/46** | ✅ |

> **تنبيه:** الـ live DB في dev لا يوجد فيه workload حقيقي. لذلك
> `idx_scan = 0` لا يدلّ على "غير مستخدم". الـ DROP UNUSED مؤجَّل لما بعد
> 30 يوم من بيانات production.

---

## 2. الـ 6 Composite Indexes الجديدة

| # | الاسم | الجدول | الأعمدة | المبرر |
|---|---|---|---|---|
| 1 | `idx_tbljournalbody_journal_account` | `tbljournalbody` | `(journalcode, accountcode)` | account statement queries |
| 2 | `idx_tblbondbody_bond_account` | `tblbondbody` | `(bondcode, accountcode)` | bond detail lookup |
| 3 | `idx_tblsessions_user_active_expires` | `tblsessions` | `(userid, isactive, expiresat)` | "active sessions by user" + ORDER BY expiresat |
| 4 | `idx_tblaudi_table_record_date` | `tblaudi` | `(tablename, recordid, actiondate DESC)` | audit history (no extra sort) |
| 5 | `idx_tblcashreceipts_date_cashbox_status` | `tblcashreceipts` | `(receiptdate, cashboxid, status)` | cash flow reports |
| 6 | `idx_tblcashpayments_date_cashbox_status` | `tblcashpayments` | `(paymentdate, cashboxid, status)` | cash flow reports |

**#3 يُكمّل** الـ EXCLUDE constraint `excl_tblsessions_active_user` من gap 4 — الـ EXCLUDE يَمنع overlap، الـ composite يخدّم "find all active sessions for a user ordered by expiry".

**#4 يُكمّل** الـ existing `ix_audithist_table_record` — نفس الـ leading columns، لكن بإضافة `actiondate DESC` للأداء بدون sort.

---

## 3. الـ 2 Partial Indexes الجديدة

| # | الاسم | الجدول | العمود | الفلتر |
|---|---|---|---|---|
| 1 | `idx_tblusers_active` | `tblusers` | `usercode` | `WHERE isactive = true` |
| 2 | `idx_tblproducts_inventory` | `tblproducts` | `productcode` | `WHERE isinventoryitem = true AND isactive = true` |

**ما تم تخطيه (مُغطّى بقيد موجود):**
- `idx_tblsessions_active_now` ← `excl_tblsessions_active_user` يَخدم
- `idx_approvalrequests_pending` ← `ix_approvalrequests_due` (PENDING/IN_REVIEW) يَخدم

---

## 4. الـ DROP UNUSED — مؤجَّل

**السبب:** الـ live DB في dev لا يوجد فيه workload حقيقي. 219/229 indexes
لديها `idx_scan = 0` فقط لأن لا queries تَمَرّ. لا يمكن تمييز الـ "truly
unused" من الـ "rarely used" بدون بيانات production.

**متى يُنفَّذ:**
- بعد 30 يوم من تشغيل production
- بالاعتماد على `vw_unused_indexes` (من gap 3)
- مع drop فقط للـ indexes التي:
  - 0 scans فعلاً
  - ليست primary keys
  - ليست unique constraints (backing FKs)
  - ليست ضرورية لـ safety (مثل `isactive` indexes)

---

## 5. Microsoft / PostgreSQL Best Practices المُتّبعة

| الممارسة | كيف طُبّقت |
|---|---|
| `CREATE INDEX CONCURRENTLY` | ✅ كل الـ 8 indexes — لا قفل write على الجدول |
| `IF NOT EXISTS` | ✅ كل الـ 8 — idempotent، re-run = no-op |
| Pre-flight cleanup of INVALID indexes | ✅ DO block في رأس كل ملف — DROPs leftover من failed builds |
| `No BEGIN/COMMIT` | ✅ كل ملف — CONCURRENTLY لا يعمل داخل transaction |
| Microsoft naming convention | ✅ `idx_<table>_<cols>` / `idx_<table>_<subject>_active` |
| `indisvalid` check in audit | ✅ `pg_class` JOIN `pg_index` يتحقق من `i.indisvalid` |
| Self-contained SQL files | ✅ Part A (composite) و Part B (partial) منفصلتان |

---

## 6. الاختبارات

### 6.1 Gap 5 Audit (5/5 PASS)

```text
[1/5] Idempotency signatures        [OK] A + B both present
[2/5] 6 composite indexes           [OK] all 6 valid
[3/5] 2 partial indexes             [OK] both valid
[4/5] No INVALID leftover indexes   [OK] 0 invalid
[5/5] Index count summary
       total_user_indexes=237   (was 229, +8)
       composite_indexes=39    (was 33,  +6)
       partial_indexes=10      (was 8,   +2)
```

### 6.2 DbTest (سلوك التطبيق — لم يتأثر)

```text
=== SUMMARY: Passed=46  Failed=0 ===
```

### 6.3 Build

```text
Build succeeded.
    0 Warning(s)
    0 Error(s)
```

### 6.4 Working tree

```text
$ git status
On branch feat/gap-5-indexes-optimization
nothing to commit, working tree clean
```

---

## 7. الملفات المُضافة

| # | المسار | النوع | الوصف |
|---|---|---|---|
| 1 | `docs/audits/GAP_5_INDEXES_PLAN.md` | جديد | الخطة المُفصّلة (commit 1) |
| 2 | `docs/audits/gap-5-baseline.txt` | جديد | Baseline snapshot (commit 2) |
| 3 | `database/IntegratedAccSys_Indexes.sql` | جديد | 6 composite indexes (commit 3) |
| 4 | `database/IntegratedAccSys_Indexes_partial.sql` | جديد | 2 partial indexes (commit 4) |
| 5 | `scripts/audit-g5-indexes.ps1` | جديد | 5 فحوصات آلية (commit 5) |
| 6 | `docs/audits/GAP_5_INDEXES_REPORT.md` | جديد | هذا التقرير (commit 6) |

**المجموع:** 6 commits صغيرة قابلة للمراجعة على `feat/gap-5-indexes-optimization`.

---

## 8. المخاطر والاعتبارات

| المخاطرة | الاحتمال | الأثر | التخفيف |
|---|---|---|---|
| Index كبير على جدول ضخم يأخذ وقت | منخفض | منخفض | `CONCURRENTLY` يَمنع قفل write — التطبيق يستمر |
| `CONCURRENTLY` يفشل (server crash) → INVALID index | منخفض | منخفض | Pre-flight `DROP INDEX IF EXISTS` للأسماء المعروفة |
| Index فائض عن الحاجة (نفس الـ leading columns) | متوسط | منخفض | الـ 6 الجديدة مَخدومة بـ queries واضحة؛ التداخل مع existing indexes مُراجَع (e.g., #4) |
| `actiondate DESC` غير مُحَسَّن لـ `NULLS FIRST/LAST` | منخفض | منخفض | PostgreSQL default: `NULLS LAST` for `DESC` — منطقي للأحدث أولاً |
| DROP UNUSED مؤجَّل — قد تتراكم indexes ضائعة | ثابت | منخفض | موثَّق في §4 + متى يُنفَّذ |

---

## 9. خارطة طريق — الفجوات التالية

> ⚠️ **القرار:** Gap 5 ✅ مكتمل (ADD part). DROP UNUSED مؤجَّل.

| # | الفجوة | الخطورة | الفرع | الجهد |
|---|---|:---:|---|---:|
| 7 | Materialized Views | 🔴 CRITICAL | `feat/gap-7-materialized-views` | 3-4 أيام |
| 10 | Approval Workflows (state machine) | 🔴 CRITICAL | `feat/gap-10-approval-workflow` | 5-7 أيام |
| — | DROP UNUSED (بعد 30 يوم production) | 🟡 MEDIUM | `feat/gap-5-drop-unused` (لاحقاً) | 1 يوم |

---

## 10. التوقيع

| البند | القيمة |
|---|---|
| **الحالة** | ✅ **RESOLVED (ADD-only)** |
| **DROP UNUSED** | 🟡 **DEFERRED** — يُنفَّذ بعد 30 يوم production data |
| **التوافق** | 100% مع السلوك الحالي (DbTest 46/46، audit 5/5، build 0/0) |
| **التغيير المُكسِّر** | لا شيء — indexes جديدة فقط، لا تعديلات على schema |
| **الفرع** | `feat/gap-5-indexes-optimization` (6 commits جاهزة للمراجعة والدمج) |
| **الخطوة التالية** | Gap 7 (Materialized Views) — CRITICAL للأداء في التقارير |
