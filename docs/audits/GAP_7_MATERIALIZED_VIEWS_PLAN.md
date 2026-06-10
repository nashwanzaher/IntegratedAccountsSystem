# 📊 خطة Gap #7 — Materialized Views (Performance-Critical Reports)

**المشروع:** Integrated Accounts System (IntegratedAccSys)
**التاريخ:** 2026-06-11
**الفجوة:** #7 من `ENTERPRISE_GAP_ANALYSIS.md` — Materialized Views (🔴 CRITICAL)
**الفرع:** `feat/gap-7-materialized-views`
**الحالة:** 📋 **PLANNED** — التنفيذ بـ commits صغيرة قابلة للمراجعة

---

## 1. Baseline

```text
existing_mvs = 5
  mv_account_balances     (accountcode PK, parentaccountcode idx)
  mv_chart_of_accounts    (accountcode PK, acclevel + parent idx)
  mv_final_accounts       (accountcode PK, acctnature idx)
  mv_journal_summary      (composite PK: journal_date, source_type, fy, fp)
  mv_trial_balance        (accountcode PK, accountnumber idx)

All 5 are POPULATED and have UNIQUE INDEXes (REFRESH CONCURRENTLY ready).
```

**ما يَنقُص** (من توصية ENTERPRISE_GAP_ANALYSIS §2.5):

| MV المطلوبة | موجودة؟ |
|---|---|
| mv_account_balance_summary | ✅ (كـ mv_account_balances) |
| mv_daily_sales_summary | ❌ |
| mv_monthly_inventory_snapshot | ❌ |
| mv_customer_outstanding_balance | ❌ |
| mv_treasury_position | ❌ |
| mv_budget_vs_actual_summary | ❌ |

**5 MVs ناقصة — مُرتَّبة حسب الأولوية:**

---

## 2. نطاق Gap 7 (5 commits صغيرة)

### Commit 1: هذه الخطة (توثيق)

`docs/audits/GAP_7_MATERIALIZED_VIEWS_PLAN.md` — لا تغييرات على الكود.

### Commit 2: 3 MVs (Part A — Sales/Customer/Treasury)

كل MV يُنشأ بـ `CREATE MATERIALIZED VIEW IF NOT EXISTS` + `WITH NO DATA`:
- لا يستهلك وقت في الـ initial build
- idempotent (IF NOT EXISTS)
- نُضيف UNIQUE INDEX ضروري لـ `REFRESH MATERIALIZED VIEW CONCURRENTLY`

| MV | الجداول | الأعمدة الرئيسية | Refresh |
|---|---|---|---|
| `mv_daily_sales_summary` | `tbloperationheader`, `tbloperationbody` | (opdate, branchcode, totalamount, txcount) | Daily |
| `mv_customer_outstanding_balance` | `tblcustomers`, `tblbondheader`, `tbljournalbody` | (customercode, totaldebit, totalcredit, balance) | Daily |
| `mv_treasury_position` | `tblcashboxes`, `tblbankaccounts` | (entity_type, entity_id, entity_name, balance) | Hourly |

### Commit 3: 2 MVs (Part B — Inventory/Budget)

| MV | الجداول | الأعمدة | Refresh |
|---|---|---|---|
| `mv_monthly_inventory_snapshot` | `tblproducts`, `tblstoreproducts`, `tbloperationbody` | (productcode, storecode, qty, value) | Nightly |
| `mv_budget_vs_actual_summary` | `tblbudgets`, `tblbudgetperiods`, `tbljournalbody` | (periodid, accountcode, budget, actual, variance) | Daily |

**Note:** `mv_budget_vs_actual_summary` يعتمد على أن يكون التطبيق يستخدم
الـ budget tables. لو لم تكن مُستخدمة، الـ MV سيكون فارغاً (لكن schema صحيح).

### Commit 4: Audit script + helper function for refresh

- `fn_g7_refresh_mv(mv_name text)` — يُنفّذ `REFRESH MATERIALIZED VIEW CONCURRENTLY mv_name`
- `scripts/audit-g7-materialized-views.ps1` يفحص:
  1. 5 idempotency signatures
  2. 5 MVs موجودة في `pg_matviews`
  3. كل MV له UNIQUE INDEX (للـ CONCURRENTLY refresh)
  4. كل MV قابل للـ REFRESH (ينجح اختبار REFRSH)

### Commit 5: Final report

`docs/audits/GAP_7_MATERIALIZED_VIEWS_REPORT.md` بنفس بنية reports السابقة.

---

## 3. Microsoft / PostgreSQL Best Practices المُتّبعة

| الممارسة | كيف طُبّقت |
|---|---|
| `WITH NO DATA` للـ initial create | ✅ لا يستهلك وقت، لا يفشل على empty tables |
| `UNIQUE INDEX` على كل MV | ✅ ضروري لـ `REFRESH MATERIALIZED VIEW CONCURRENTLY` |
| `IF NOT EXISTS` | ✅ idempotent، re-run = no-op |
| Naming convention | ✅ `mv_<subject>` |
| Refresh function | ✅ `fn_g7_refresh_mv(name)` — يَمنع SQL injection في `REFRESH` |
| لا `BEGIN/COMMIT` | ✅ كل ملف — متّفق مع gap 2/3/4/5 |
| `WITH NO DATA` لا ينشئ الـ data على CREATE | ✅ يَتجنّب queries مكلِفة على tables فارغة |

---

## 4. ما **لا** يُنفَّذ في هذا الـ PR (مُؤجَّل)

| الإجراء | السبب | متى يُنفَّذ |
|---|---|---|
| `pg_cron` scheduled refresh | الـ extension غير متاح على هذا الـ build | بعد توفّر pg_cron |
| `REFRESH CONCURRENTLY` automation | يحتاج pg_cron | بعد توفّر pg_cron |
| MVs لـ dimension pivot | خارج نطاق gap 7 (gap 12/13) | في فجوات لاحقة |
| Drop & recreate existing 5 MVs | موجودة ومُختبَرة | لا نُعدّلها |

---

## 5. معايير النجاح (Definition of Done)

- [ ] dotnet build 0/0
- [ ] DbTest Passed=46 Failed=0
- [ ] audit script X/X PASS
- [ ] كل commit صغير، مُركَّز، مُوثَّق
- [ ] التقرير النهائي يُظهر before/after counts
- [ ] لا regression في gap 1/2/3/4/5

---

## 6. الجهد المُقدَّر

| Commit | الجهد |
|---|---|
| 1 (خطة) | ✅ هذا الملف |
| 2 (3 MVs Part A) | 30 دقيقة |
| 3 (2 MVs Part B) | 20 دقيقة |
| 4 (audit + refresh fn) | 20 دقيقة |
| 5 (تقرير) | 15 دقيقة |
| **المجموع** | **~1.5 ساعة** |

---

## 7. التراجع (Rollback)

```sql
DROP MATERIALIZED VIEW IF EXISTS public.mv_daily_sales_summary CASCADE;
-- ... لكل MV
```

`CASCADE` يحذف الـ indexes والـ function dependencies.

---

## 8. التوقيع

| البند | القيمة |
|---|---|
| **الحالة** | 📋 **PLANNED** |
| **الفرع** | `feat/gap-7-materialized-views` (مُنشأ) |
| **الخطوة التالية** | تنفيذ commits 2-5 على هذا الفرع |
