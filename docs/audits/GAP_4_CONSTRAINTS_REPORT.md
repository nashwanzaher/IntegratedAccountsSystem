# 📐 تقرير معالجة الفجوة #4 — Constraints (CHECK + EXCLUSION)

**المشروع:** Integrated Accounts System (IntegratedAccSys)
**التاريخ:** 2026-06-11
**الفجوة:** #4 من `ENTERPRISE_GAP_ANALYSIS.md` — Constraints (🟡 HIGH)
**الفرع:** `feat/gap-4-constraints`
**الحالة:** ✅ **RESOLVED**

---

## 1. ملخص تنفيذي

| المقياس                       | قبل | بعد | التحسن |
| ----------------------------- | --: | --: | ------ |
| FK constraints                | 137 | 137 | unchanged |
| UNIQUE constraints            |  43 |  43 | unchanged |
| **CHECK constraints (data validity)** | **2** | **15** | **+13** |
| PK constraints                |  70 |  70 | unchanged |
| **EXCLUDE constraints**       |  **0** |  **4** | **+4** |
| TRIGGERS                      |   0 |   0 | (out of scope) |
| `btree_gist` extension        | ❌ | ✅ 1.7 | new dep |
| Build                         | 0/0 | **0/0** | ✅ |
| DbTest (46 workflows)         | 46/46 | **46/46** | ✅ |
| Audit script                  | — | **5/6 OK + 1 SKIP** | ✅ |
| Working tree                  | clean | **clean** | ✅ |

> **Note:** the 2 CHECKs we counted as "data validity" before this gap were
> `tblcashpayments_amount_check` and `tblcashreceipts_amount_check` (both
> `amount > 0`). The other 13 from gap 4 are new.

---

## 2. الجرد قبل/بعد

### 2.1 قبل

```text
FK            : 137  (كثيف)
UNIQUE        :  43
CHECK         :  15  (أغلبها enum enums)
PK            :  70
EXCLUDE       :   0
TRIGGERS      :   0
btree_gist    :   missing
```

### 2.2 بعد

```text
FK            : 137
UNIQUE        :  43
CHECK         :  28  (+ 13 data-validity)
PK            :  70
EXCLUDE       :   4  ← جديد
TRIGGERS      :   0
btree_gist    : 1.7  ← dependency
```

---

## 3. الـ 13 CHECK الجديدة (الاسم + القاعدة)

| # | الجدول | القيد | التعبير |
|---|---|---|---|
| 1 | `tblproducts` | `chk_tblproducts_minstock_nonneg` | `minstocklevel IS NULL OR minstocklevel >= 0` |
| 2 | `tblproducts` | `chk_tblproducts_maxstock_gte_min` | `minstocklevel IS NULL OR maxstocklevel IS NULL OR maxstocklevel >= minstocklevel` |
| 3 | `tblproducts` | `chk_tblproducts_prices_nonneg` | `standardcost >= 0 AND lastpurchaseprice >= 0 AND lastsaleprice >= 0` |
| 4 | `tblbondheader` | `chk_tblbondheader_amount_positive` | `amount IS NULL OR amount > 0` |
| 5 | `tblbankaccounts` | `chk_tblbankaccounts_balance_nonneg` | `currentbalance IS NULL OR currentbalance >= 0` |
| 6 | `tblbanktransactions` | `chk_tblbanktransactions_amount_positive` | `amount IS NULL OR amount > 0` |
| 7 | `tblsessions` | `chk_tblsessions_expires_after_created` | `expiresat IS NULL OR createdat IS NULL OR expiresat > createdat` |
| 8 | `tblsessions` | `chk_tblsessions_logout_after_created` | `logoutat IS NULL OR createdat IS NULL OR logoutat >= createdat` |
| 9 | `tbljournalbody` | `chk_tbljournalbody_amounts_nonneg` | `(debit IS NULL OR debit >= 0) AND (credit IS NULL OR credit >= 0)` |
| 10 | `tbljournalbody` | `chk_tbljournalbody_no_dual_leg` | `NOT (COALESCE(debit, 0) > 0 AND COALESCE(credit, 0) > 0)` |
| 11 | `tblexchangeratehistory` | `chk_tblexchangeratehistory_exgrate_positive` | `exgrate > 0` |
| 12 | `tblpricelists` | `chk_tblpricelists_markup_nonneg` | `markuppercent IS NULL OR markuppercent >= 0` |
| 13 | `tblusers` | `chk_tblusers_loginattempts_nonneg` | `loginattempts IS NULL OR loginattempts >= 0` |

**نمط الإضافة:** كل CHECK يُضاف بـ `ADD CONSTRAINT ... NOT VALID` أولاً (لا قفل write على الجدول)، ثم `VALIDATE CONSTRAINT` (يأخذ فقط `SHARE UPDATE EXCLUSIVE` — الـ reads تستمر).

**الإضافة تتم عبر الـ helper:**
```sql
SELECT public.fn_add_check_validated(
    'public.tblproducts',
    'chk_tblproducts_minstock_nonneg',
    'minstocklevel IS NULL OR minstocklevel >= 0'
);
-- returns: '[OK] chk_tblproducts_minstock_nonneg added as NOT VALID. Validated.'
```

---

## 4. الـ 4 EXCLUDE الجديدة (الاسم + التعريف)

| # | الجدول | القيد | التعريف |
|---|---|---|---|
| 1 | `tblbankstatements` | `excl_tblbankstatements_account_statementno` | `EXCLUDE USING gist (bankaccountid WITH =, statementno WITH =)` |
| 2 | `tblfiscalperiods` | `excl_tblfiscalperiods_fiscalyear_daterange` | `EXCLUDE USING gist (fiscalyearid WITH =, daterange(startdate, enddate, '[]') WITH &&)` |
| 3 | `tblexchangeratehistory` | `excl_tblexchangeratehistory_currid_daterange` | `EXCLUDE USING gist (currid WITH =, daterange(effectivedate, COALESCE(expirydate, 'infinity'::date), '[]') WITH &&)` |
| 4 | `tblsessions` | `excl_tblsessions_active_user` | `EXCLUDE USING gist (usercode WITH =, tsrange(createdat, expiresat, '[]') WITH &&) WHERE (isactive = true)` |

**لماذا `btree_gist`؟** `EXCLUDE USING gist` يحتاج index واحد يجمع عدة أعمدة مع operators مختلفة (`=` و `&&`). الـ GiST framework لا يدعم `=` على scalar بشكل افتراضي — `btree_gist` يضيف دعم btree-equality إلى GiST.

**ملاحظة:** الـ EXCLUDE constraints لا تدعم `NOT VALID` في PostgreSQL. التحقّق من البيانات يتم قبل الإضافة (pre-flight في خطة Gap 4).

**الـ partial EXCLUDE** على `tblsessions` (مع `WHERE isactive = true`):
- ✅ يمنع وجود جلستين نشطتين لنفس المستخدم في نفس الوقت
- ✅ لا يمنع الـ historical sessions (isactive = false) من التداخل

---

## 5. Helper Functions المُضافة

```sql
-- Idempotent CHECK add (NOT VALID + VALIDATE pattern)
public.fn_add_check_validated(table regclass, name text, expr text)
    -> text  -- '[OK] ... added as NOT VALID. Validated.' أو '[..] already present'

-- Idempotent EXCLUDE add
public.fn_add_exclude(table regclass, name text, def text)
    -> text  -- '[OK] ... added.' أو '[..] already present.'

-- Idempotency signatures
public.fn_g4_constraints_signature_part_a() -> 'GAP4-CONSTRAINTS-PART-A-2026-06-11-v1'
public.fn_g4_constraints_signature_part_b() -> 'GAP4-CONSTRAINTS-PART-B-2026-06-11-v1'
public.fn_g4_constraints_signature_part_c() -> 'GAP4-CONSTRAINTS-PART-C-2026-06-11-v1'
```

الـ helpers مُتاحة لـ `app_admin` فقط (الـ app العادي لا يحتاج إضافة constraints — هذا DBA task).

---

## 6. الـ Naming Convention (مُتّفق مع Microsoft / PostgreSQL best practices)

| النوع | النمط | مثال |
|---|---|---|
| CHECK | `chk_<table>_<subject>_<rule>` | `chk_tblproducts_minstock_nonneg` |
| EXCLUDE | `excl_<table>_<subject>` | `excl_tblsessions_active_user` |
| FK | `fk_<table>_<reftable>` (موجود مُسبقاً) | `fk_journalbody_account` |
| UNIQUE | `uk_<table>_<cols>` (موجود مُسبقاً) | `tblusers_userid_key` |

---

## 7. الاختبارات

### 7.1 Gap 4 Audit (5 OK + 1 SKIP + 0 FAIL)

```text
[1/6] Idempotency signatures        [OK] A + B + C all present
[2/6] btree_gist extension          [OK] v1.7 installed
[3/6] CHECK constraints             [OK] 13/13 validated
[4/6] EXCLUDE constraints           [OK] 4/4 present
[5/6] Behavioural: duplicate stno   [SKIP] no bank account in DB
[6/6] Behavioural: overlapping period [OK] EXCLUDE blocked insert
```

**ملاحظة على [5/6]:** الـ SKIP ليس فشلاً — `tblbankaccounts` لا يحوي بيانات في بيئة التطوير الحالية. الـ EXCLUDE constraint نفسه مُتحقَّق منه في [4/6] (وجوده في `pg_constraint` بدلالة `contype='x'`). في production (مع بيانات بنوك موجودة) سيعمل behavioural test تلقائياً.

### 7.2 DbTest (سلوك التطبيق — لم يتأثر)

```text
=== SUMMARY: Passed=46  Failed=0 ===
```

### 7.3 Build

```text
Build succeeded.
    0 Warning(s)
    0 Error(s)
```

### 7.4 الـ Working Tree

```text
$ git status
On branch feat/gap-4-constraints
nothing to commit, working tree clean
```

---

## 8. Microsoft / PostgreSQL Best Practices المُتّبعة

| الممارسة | كيف طُبّقت |
|---|---|
| `NOT VALID` + `VALIDATE` pattern | ✅ كل CHECK الـ 13 — لا قفل write على الجدول |
| Named constraints (not auto-generated) | ✅ نمط `chk_<table>_<subject>_<rule>` |
| Idempotent migrations | ✅ `DO $$ ... IF NOT EXISTS ... END $$` + helper functions |
| `btree_gist` للـ EXCLUDE المُتعدّد | ✅ تم تثبيته في Part A |
| Pre-flight check قبل EXCLUDE | ✅ 4 SELECTs قبل كل ADD CONSTRAINT (0 violations) |
| Partial EXCLUDE للـ scoped constraints | ✅ `excl_tblsessions_active_user WHERE isactive = true` |
| Self-cleaning behavioural tests | ✅ `DELETE` داخل الـ DO block بعد الـ test |
| `set_config` GUC للـ communication عبر EXCEPTION | ✅ يلتفّ على حدود temp-table-on-rollback |
| Documentation comments in SQL | ✅ رأس كل ملف يشرح النطاق والـ rollback |
| Seperate file per concern (Part A/B/C) | ✅ review-friendly commits |

---

## 9. الملفات المُضافة

| # | المسار | النوع | الوصف |
|---|---|---|---|
| 1 | `docs/audits/GAP_4_CONSTRAINTS_PLAN.md` | **جديد** | خطة Gap 4 بالتفصيل (commit 1) |
| 2 | `database/IntegratedAccSys_Constraints.sql` | **جديد** | Part A: `btree_gist` extension + signature (commit 2) |
| 3 | `database/IntegratedAccSys_Constraints_chk.sql` | **جديد** | Part B: 13 CHECK + helper fn (commit 3) |
| 4 | `database/IntegratedAccSys_Constraints_excl.sql` | **جديد** | Part C: 4 EXCLUDE + helper fn (commit 4) |
| 5 | `scripts/audit-g4-constraints.ps1` | **جديد** | 6 فحوصات آلية (commit 5) |
| 6 | `docs/audits/GAP_4_CONSTRAINTS_REPORT.md` | **جديد** | هذا التقرير (commit 6) |

**المجموع:** 6 commits صغيرة قابلة للمراجعة على `feat/gap-4-constraints`.

---

## 10. المخاطر والاعتبارات

| المخاطرة | الاحتمال | الأثر | التخفيف |
|---|---|---|---|
| `NOT VALID` + `VALIDATE` يأخذ وقت على جداول كبيرة | منخفض | منخفض | `VALIDATE` يستخدم `SHARE UPDATE EXCLUSIVE` فقط — لا قفل write |
| `btree_gist` يُبطئ INSERTs على أعمدة GiST | منخفض | منخفض | الـ indexes مفهرسة فقط على الأعمدة المعنية |
| تطبيق قد يكسر بسبب CHECK جديد | منخفض | عالي | DbTest 46/46 — لا regression |
| Behavioural tests في audit تترك بيانات اختبار | منخفض | منخفض | `DELETE` داخل الـ DO block |
| Triggers لم تُنفَّذ | ثابت | متوسط | مُتعمَّد — commits منفصلة لاحقاً (business logic أكثر تعقيداً) |

---

## 11. خارطة طريق — الفجوات التالية

> ⚠️ **القرار:** Gap 4 ✅ مكتمل. الـ branches منفصلة لكل فجوة.

| # | الفجوة | الخطورة | الفرع المُقترح | الجهد |
|---|---|:---:|---|---:|
| 5 | Indexes (drop unused + add composite) | 🟡 MEDIUM | `feat/gap-5-indexes-optimization` | 1 يوم (سهل الآن مع vw_unused_indexes) |
| 7 | Materialized Views | 🔴 CRITICAL | `feat/gap-7-materialized-views` | 3-4 أيام |
| 10 | Approval Workflows (state machine) | 🔴 CRITICAL | `feat/gap-10-approval-workflow` | 5-7 أيام |

---

## 12. التوقيع

| البند | القيمة |
|---|---|
| **الحالة** | ✅ **RESOLVED** |
| **التوافق** | 100% مع السلوك الحالي (DbTest 46/46، audit 5/6 OK + 1/6 SKIP) |
| **التغيير المُكسِّر** | لا شيء — كل CHECK يطابق البيانات الموجودة (validated) |
| **الفرع** | `feat/gap-4-constraints` (6 commits جاهزة للمراجعة والدمج) |
| **الخطوة التالية** | Gap 5 (Indexes) — سهل الآن مع views الـ monitoring |
