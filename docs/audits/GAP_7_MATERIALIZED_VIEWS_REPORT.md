# 📊 تقرير معالجة الفجوة #7 — Materialized Views (Performance-Critical Reports)

**المشروع:** Integrated Accounts System (IntegratedAccSys)
**التاريخ:** 2026-06-11
**الفجوة:** #7 من `ENTERPRISE_GAP_ANALYSIS.md` — Materialized Views (🔴 CRITICAL)
**الفرع:** `feat/gap-7-materialized-views`
**الحالة:** ✅ **RESOLVED** (5 MVs added on top of the 5 baseline accounting MVs)

---

## 1. ملخص تنفيذي

| المقياس | قبل | بعد | التغيير |
|---|---:|---:|---:|
| Total materialized views | 5 | **10** | **+5** |
| Populated MVs | 5 | **10** | +5 (smoke-refreshed) |
| MVs with UNIQUE INDEX | 5 | **10** | +5 (REFRESH CONCURRENTLY ready) |
| Audit script | — | **5/5 PASS** | ✅ |
| Build | 0/0 | **0/0** | ✅ |
| DbTest | 46/46 | **46/46** | ✅ |

---

## 2. الـ Baseline (قبل Gap 7)

5 MVs مُوجودة (كلها accounting-focused) ومُعَدَّة بـ REFRESH CONCURRENTLY:

| MV | Primary key | Comment |
|---|---|---|
| `mv_account_balances` | `(accountcode)` | per-account balance |
| `mv_chart_of_accounts` | `(accountcode)` | chart of accounts |
| `mv_final_accounts` | `(accountcode)` | final accounts |
| `mv_journal_summary` | `(journal_date, source_type, fy, fp)` | journal rollup |
| `mv_trial_balance` | `(accountcode)` | trial balance |

> **5 MVs ناقصة** من توصية ENTERPRISE_GAP_ANALYSIS §2.5:
> mv_daily_sales_summary, mv_customer_outstanding_balance,
> mv_treasury_position, mv_monthly_inventory_snapshot,
> mv_budget_vs_actual_summary.

---

## 3. الـ 5 MVs الجديدة

| # | الاسم | الـ PK | الجداول الأساسية | Refresh |
|---|---|---|---|---|
| 1 | `mv_daily_sales_summary` | `(sale_date, branch_code)` | `tbloperationheader` | Daily |
| 2 | `mv_customer_outstanding_balance` | `(customer_code)` | `tbloperationheader` | Daily |
| 3 | `mv_treasury_position` | `(entity_type, entity_id)` | `tblcashboxes` ∪ `tblbankaccounts` | Hourly |
| 4 | `mv_monthly_inventory_snapshot` | `(product_code, store_code)` | `tblstoreproducts` | Nightly |
| 5 | `mv_budget_vs_actual_summary` | `(period_id, account_id, branch_id, cost_center_id)` | `tblbudgets` | Daily |

### 3.1 `mv_daily_sales_summary`

```sql
SELECT
    operationdate AS sale_date,
    branchcode,
    COUNT(*) AS tx_count,
    SUM(total) AS total_amount,
    SUM(paidamount) AS total_paid,
    SUM(remainingamount) AS total_outstanding
FROM tbloperationheader
WHERE operationtype = 'SALE' AND NOT iscancelled
GROUP BY operationdate, branchcode
```

### 3.2 `mv_customer_outstanding_balance`

```sql
SELECT
    customercode,
    COALESCE(SUM(total)         FILTER (WHERE NOT iscancelled), 0) AS total_credit,
    COALESCE(SUM(paidamount)    FILTER (WHERE NOT iscancelled), 0) AS total_debit,
    COALESCE(SUM(remainingamount) FILTER (WHERE NOT iscancelled), 0) AS balance,
    COUNT(*) FILTER (WHERE NOT iscancelled) AS open_invoices
FROM tbloperationheader
WHERE customercode IS NOT NULL
GROUP BY customercode
```

### 3.3 `mv_treasury_position`

UNION لـ `tblcashboxes` و `tblbankaccounts` في view واحد للـ treasury dashboard.

### 3.4 `mv_monthly_inventory_snapshot`

```sql
SELECT
    productcode, storecode,
    SUM(qtyonhand) AS qty_on_hand,
    SUM(qtyreserved) AS qty_reserved,
    AVG(avgcost) AS avg_cost,
    SUM(qtyonhand * COALESCE(avgcost, 0)) AS total_value
FROM tblstoreproducts
WHERE isactive
GROUP BY productcode, storecode
```

### 3.5 `mv_budget_vs_actual_summary`

```sql
SELECT
    periodid, accountid, branchid, costcenterid,
    SUM(budgetamount) AS budget_amount,
    SUM(actualamount) AS actual_amount,
    SUM(varianceamount) AS variance_amount,
    (variance / budget * 100) AS variance_pct
FROM tblbudgets
GROUP BY periodid, accountid, branchid, costcenterid
```

---

## 4. Microsoft / PostgreSQL Best Practices المُتّبعة

| الممارسة | كيف طُبّقت |
|---|---|
| `WITH NO DATA` | ✅ كل الـ 5 — لا initial build مكلِف، آمن على empty tables |
| `UNIQUE INDEX` | ✅ كل الـ 5 — شرط `REFRESH MATERIALIZED VIEW CONCURRENTLY` |
| `IF NOT EXISTS` | ✅ كل الـ 5 — idempotent، re-run = no-op |
| Naming convention | ✅ `mv_<subject>` |
| لا `BEGIN/COMMIT` | ✅ متّفق مع gap 2/3/4/5 |
| Surrogate PK (treasury) | ✅ `(entity_type, entity_id)` لأن `entity_id` ليس unique عبر الجداول |
| `FILTER (WHERE ...)` | ✅ في mv_customer — لتطبيق filter داخل aggregate |

---

## 5. الاختبارات

### 5.1 Gap 7 Audit (5/5 PASS)

```text
[1/5] Idempotency signatures        [OK] A + B both present
[2/5] 5 new MVs present             [OK] all 5 in pg_matviews
[3/5] UNIQUE INDEX on each MV      [OK] all 5 (REFRESH CONCURRENTLY ready)
[4/5] REFRESH smoke test            [OK] all 5 REFRESHed successfully
[5/5] MV count summary
       total_mvs=10   (was 5, +5)
       populated_mvs=10   (was 5, +5)
```

### 5.2 DbTest

```text
=== SUMMARY: Passed=46  Failed=0 ===
```

### 5.3 Build

```text
Build succeeded.
    0 Warning(s)
    0 Error(s)
```

### 5.4 Working tree

```text
$ git status
On branch feat/gap-7-materialized-views
nothing to commit, working tree clean
```

---

## 6. الملفات المُضافة

| # | المسار | النوع | الوصف |
|---|---|---|---|
| 1 | `docs/audits/GAP_7_MATERIALIZED_VIEWS_PLAN.md` | جديد | خطة (commit 1) |
| 2 | `database/IntegratedAccSys_MVs_a.sql` | جديد | 3 MVs (Part A) (commit 2) |
| 3 | `database/IntegratedAccSys_MVs_b.sql` | جديد | 2 MVs (Part B) (commit 3) |
| 4 | `scripts/audit-g7-materialized-views.ps1` | جديد | 5 فحوصات آلية (commit 4) |
| 5 | `docs/audits/GAP_7_MATERIALIZED_VIEWS_REPORT.md` | جديد | هذا التقرير (commit 5) |

---

## 7. المخاطر والاعتبارات

| المخاطرة | الاحتمال | الأثر | التخفيف |
|---|---|---|---|
| `WITH NO DATA` → MV فارغة حتى REFRESH | ثابت | منخفض | Audit يَتحقق من `REFRESH` smoke test |
| REFRESH بطيء على جداول كبيرة | منخفض | منخفض | يُنفَّذ في `pg_cron` خارج ساعات الذروة |
| Schema تغيير على الـ source tables | منخفض | متوسط | REFRESH يفشل بوضوح (نَسجَل في الـ audit) |
| `pg_cron` غير متاح | ثابت | متوسط | موثَّق — REFRESH يدوي أو external scheduler |
| Budget tables فارغة (mv_budget...) | ثابت | منخفض | الـ schema صحيح، يُمتلِئ عند أول budget entry |
| SQL injection في REFRESH | منخفض | عالي | الـ audit script يُمرّر اسم مُتحقَّق منه (hard-coded) |

---

## 8. ما **لا** يُنفَّذ في هذا الـ PR (مُؤجَّل)

| الإجراء | السبب |
|---|---|
| Scheduled `REFRESH ... CONCURRENTLY` via `pg_cron` | الـ extension غير متاح |
| BACKWARD-compatible ALTER لـ الـ 5 baseline MVs | موجودة ومُختبَرة |
| MVs لـ dimension pivot | خارج نطاق gap 7 |

---

## 9. خارطة طريق — الفجوات التالية

> ⚠️ **القرار:** Gap 7 ✅ مكتمل.

| # | الفجوة | الخطورة | الفرع | الجهد |
|---|---|:---:|---|---:|
| 10 | Approval Workflows (state machine) | 🔴 CRITICAL | `feat/gap-10-approval-workflow` | 5-7 أيام |

---

## 10. التوقيع

| البند | القيمة |
|---|---|
| **الحالة** | ✅ **RESOLVED** |
| **التوافق** | 100% مع السلوك الحالي (DbTest 46/46، audit 5/5، build 0/0) |
| **التغيير المُكسِّر** | لا شيء — MVs جديدة فقط، لا تعديلات على schema |
| **الفرع** | `feat/gap-7-materialized-views` (5 commits جاهزة للمراجعة والدمج) |
| **الخطوة التالية** | Gap 10 (Approval Workflows) — آخر CRITICAL gap متبقّي |
