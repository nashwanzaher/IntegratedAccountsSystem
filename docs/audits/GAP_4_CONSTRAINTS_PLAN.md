# 📐 خطة Gap #4 — Constraints (CHECK + EXCLUSION)

**المشروع:** Integrated Accounts System (IntegratedAccSys)
**التاريخ:** 2026-06-11
**الفجوة:** #4 من `ENTERPRISE_GAP_ANALYSIS.md` — Constraints (🟡 HIGH)
**الفرع:** `feat/gap-4-constraints`
**الحالة:** 📋 **PLANNED** — التنفيذ يتم بـ commits صغيرة قابلة للمراجعة

---

## 1. Baseline (ما هو موجود قبل البدء)

```text
FK          : 137     ✅  (أعلى من 72 المُسجَّل في التحليل الأصلي)
UNIQUE      :  43     ✅
CHECK       :  15     🟡  معظمها enum enums — قليلة data integrity
PK          :  70     ✅
EXCLUSION   :   0     ❌  كل الفجوة
TRIGGERS    :   0     ❌  (للخطة اللاحقة — out of scope)
btree_gist  :   —     ❌  (مطلوب لـ EXCLUSION)
```

---

## 2. نطاق Gap 4 (مُقسَّم إلى 4 commits صغيرة)

### Commit 1: الخطة (هذا الملف) — `docs(gap-4): add constraints plan`

لا تغييرات على الكود. توثيق الخطة فقط.

### Commit 2: `btree_gist` extension — `feat(gap-4): install btree_gist extension`

- ضروري لـ `EXCLUDE USING gist (col WITH =, range WITH &&)`
- آمن 100% — extension مُعتاد، لا تأثير على الكود
- الفحص: `SELECT extname FROM pg_extension WHERE extname='btree_gist';`

### Commit 3: CHECK constraints (data validity) — `feat(gap-4): add CHECK constraints`

قائمة الـ CHECK المُخطَّطة (NOT VALID أولاً، ثم VALIDATE في transaction منفصل):

| # | الجدول | القيد | المبرر |
|---|---|---|---|
| 1 | `tblproducts` | `minstocklevel >= 0` | لا stock سالب |
| 2 | `tblproducts` | `maxstocklevel >= minstocklevel` | تناسق |
| 3 | `tblbondheader` | `amount > 0` | مبالغ موجبة دائماً |
| 4 | `tblbankaccounts` | `currentbalance IS NULL OR currentbalance >= 0` | (NULL = غير معروف) |
| 5 | `tblsessions` | `expiresat > createdat` | منطقي |
| 6 | `tblsessions` | `logoutat IS NULL OR logoutat >= createdat` | منطقي |
| 7 | `tblcashreceipts` | `amount > 0` | (موجود بالفعل — نتحقق) |
| 8 | `tblcashpayments` | `amount > 0` | (موجود بالفعل — نتحقق) |
| 9 | `tbljournalbody` | `debitamount >= 0 AND creditamount >= 0` | الرصيد في طرف واحد |
| 10 | `tbljournalbody` | `NOT (debitamount > 0 AND creditamount > 0)` | استحالة الجمع |
| 11 | `tblexchangeratehistory` | `rate > 0` | سعر صرف موجب |
| 12 | `tblpricelists` | `discount >= 0 AND discount <= 100` | نطاق خصم معقول |
| 13 | `tblproducts` | `unitprice >= 0` | سعر غير سالب |
| 14 | `tblusers` | `failedloginattempts >= 0` | عدّاد |
| 15 | `tblusers` | `mustchangepassword IN (true, false)` | (غالباً boolean — نتحقق) |

**الإجراء:** كل CHECK يُضاف بـ `ADD CONSTRAINT ... CHECK (...) NOT VALID` ثم `ALTER TABLE ... VALIDATE CONSTRAINT ...` في transaction منفصل (لتجنّب قفل الجدول على بيانات كبيرة).

### Commit 4: EXCLUSION constraints — `feat(gap-4): add EXCLUSION constraints`

قائمة الـ EXCLUSION المُخطَّطة (كلها تحتاج `btree_gist` المُثبَّت في commit 2):

| # | الجدول | القيد | المبرر |
|---|---|---|---|
| 1 | `tblsessions` | `EXCLUDE USING gist (usercode WITH =, tstzrange(createdat, expiresat) WITH &&) WHERE (isactive = true)` | مستخدم واحد = session نشط واحد |
| 2 | `tblfiscalperiods` | `EXCLUDE USING gist (fiscalyearcode WITH =, daterange(startdate, enddate, '[]') WITH &&)` | لا تداخل فترات |
| 3 | `tblexchangeratehistory` | `EXCLUDE USING gist (currencycode WITH =, daterange(effectivedate, enddate, '[]') WITH &&)` | لا تداخل أسعار |
| 4 | `tblbankstatements` | `EXCLUDE USING gist (bankaccountid WITH =, statementno WITH =)` | لا تكرار statement number |
| 5 | `tblusersessions` (إن وُجد) | `EXCLUDE USING gist (userid WITH =, sessionwindow WITH &&)` | (احتياطي) |

> **ملاحظة:** commit 3 و 4 قد يُدمجان في commit واحد إذا كانت CHECK صغيرة. سأقرّر أثناء التنفيذ.

### Commit 5: Audit script — `feat(gap-4): add audit script`

`scripts/audit-g4-constraints.ps1` يفحص:
1. `btree_gist` extension مُثبَّت
2. جميع الـ CHECK المُضافة موجودة
3. جميع الـ EXCLUSION موجودة
4. `NOT VALID` count = 0 (كلها validated)
5. `SELECT conname FROM pg_constraint WHERE contype='x'` يُرجِع العدد المتوقع
6. اختبار سلوكي: محاولة إدراج بيانات مُخالفة (rollback تلقائي)

### Commit 6: التقرير — `docs(gap-4): final report`

`docs/audits/GAP_4_CONSTRAINTS_REPORT.md` بنفس بنية gap 2/3 reports.

---

## 3. معايير النجاح (Definition of Done)

- [ ] dotnet build 0/0
- [ ] DbTest Passed=46 Failed=0
- [ ] audit script X/X PASS
- [ ] كل commit صغير، مُركَّز، مُوثَّق
- [ ] التقرير النهائي يُظهر before/after counts
- [ ] لا regression في gap 1/2/3 (audit لا يزال passes)
- [ ] يعمل على Microsoft / PostgreSQL best practices:
  - `NOT VALID` ثم `VALIDATE` pattern (no table lock)
  - Constraint names واضحة: `chk_<table>_<col>_<rule>` / `excl_<table>_<rule>`
  - Idempotent SQL (DO blocks + IF NOT EXISTS patterns)
  - كل CHECK موثَّق بـ COMMENT ON CONSTRAINT

---

## 4. المخاطر والتخفيف

| المخاطرة | الاحتمال | الأثر | التخفيف |
|---|---|---|---|
| CHECK يُرفض بسبب بيانات موجودة مُخالفة | منخفض | متوسط | `NOT VALID` ثم فحص، ثم `VALIDATE` |
| EXCLUSION يُبطئ INSERTs | منخفض | منخفض | الفهارس الـ GiST تُستخدم تلقائياً |
| قفل طويل أثناء ADD CONSTRAINT | متوسط | متوسط | `NOT VALID` pattern — لا قفل على validation |
| التطبيق يكسر بسبب CHECK جديد | منخفض | عالي | تشغيل DbTest بعد كل commit |
| Trigger بُرمج بشكل خاطئ | — | — | خارج النطاق — commits منفصلة لاحقاً |

---

## 5. الترتيب الزمني المُقدَّر

| Commit | الجهد المُقدَّر |
|---|---|
| 1 (خطة) | ✅ هذا الملف |
| 2 (btree_gist) | 5 دقائق |
| 3 (CHECK) | 30-60 دقيقة (15 CHECK + 2-3 DbTest runs) |
| 4 (EXCLUSION) | 30-60 دقيقة (5 EXCL + 2-3 DbTest runs) |
| 5 (audit script) | 20 دقيقة |
| 6 (تقرير) | 15 دقيقة |
| **المجموع** | **~2-3 ساعات** |

---

## 6. التراجع (Rollback)

كل commit قابل للعكس بـ:
```sql
-- CHECK
ALTER TABLE tblproducts DROP CONSTRAINT chk_tblproducts_minstocklevel_nonneg;

-- EXCLUSION
ALTER TABLE tblsessions DROP CONSTRAINT excl_tblsessions_active_user;
```

الـ SQL idempotent — يمكن إعادة تشغيله بأمان.

---

## 7. التوقيع

| البند | القيمة |
|---|---|
| **الحالة** | 📋 **PLANNED** |
| **الفرع** | `feat/gap-4-constraints` (يُنشأ عند commit 1) |
| **التغيير المُكسِّر** | لا شيء متوقَّع — CHECK/EXCLUSION هي defensive |
| **الخطوة التالية** | تنفيذ commit 1 (هذا الملف) ثم commit 2 (btree_gist) |
