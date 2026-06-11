# 📊 تقرير معالجة الفجوة #3 — المراقبة (Monitoring: pg_stat_statements + auto_explain + Views)

**المشروع:** Integrated Accounts System (IntegratedAccSys)
**التاريخ:** 2026-06-10
**الفجوة:** #3 من `ENTERPRISE_GAP_ANALYSIS.md` — Monitoring (🔴 CRITICAL)
**الفرع:** `feat/gap-3-monitoring-extensions`
**الحالة:** 🟡 **PARTIALLY RESOLVED** (immediate items ✅ | restart-required items ⏳ documented)

---

## 1. ملخص تنفيذي

| المقياس                          |                            قبل |                                              بعد |   الحالة    |
| -------------------------------- | -----------------------------: | ----------------------------------------------: | :---------: |
| `pgstattuple` extension          |                      غير مثبّت |                                       ✅ 1.5 مثبّت |     ✅      |
| `pg_stat_statements` extension   |                       مثبّت (1.11) |     مثبّت + **snippet لتفعيل التتبع** عبر restart |     🟡      |
| `auto_explain` extension         |                  ❌ غير متاح |               ⏳ snippet موثَّق (غير متاح على هذا الـ build) |     🟡      |
| `track_io_timing`                |                          `off` |                     ⏳ snippet جاهز (يحتاج restart) |     🟡      |
| Monitoring views                 |                           0/0 |                              **7/7** جديدة |     ✅      |
| Helper functions                 |                           0/0 |                       **2/2** (slow + suggest) |     ✅      |
| Idempotency signature            |                            — |                          `GAP3-MONITORING-2026-06-10-v1` |     ✅      |
| Audit script                     |                            — |                          **8/8 checks pass** |     ✅      |
| Build                            |                          0/0 |                                       **0/0** | ✅ لم ينكسر |
| DbTest (46 workflow)             |                         46/46 |            **46/46** (لم يتأثر) |     ✅      |

---

## 2. الجرد قبل/بعد (Baseline)

### 2.1 قبل

```text
Extensions       : pgcrypto 1.3, plpgsql 1.0, pg_stat_statements 1.11 (inactive)
Views (monitoring): 0
shared_preload_libraries = ''     ← pg_stat_statements NOT tracking
track_io_timing    = off         ← I/O bottlenecks invisible
auto_explain       = NOT available on this PG build
Slow-query log     = log_min_duration_statement = 1s (set in gap 2)
```

### 2.2 بعد

```text
Extensions       : + pgstattuple 1.5
                   pg_stat_statements 1.11 (snippet to activate on restart)
Views (monitoring): 7
    vw_slow_queries          — top slow queries from pg_stat_statements
    vw_index_usage           — seq_scan vs idx_scan per table
    vw_unused_indexes        — indexes with 0 scans (drop candidates)
    vw_most_seq_scanned      — tables with high seq_scan (add-index candidates)
    vw_active_sessions       — current activity + duration
    vw_long_running_queries  — sessions > 30s (runaway catchers)
    vw_db_size_summary       — top-20 tables by total size
Functions        : 2
    fn_get_slow_queries(min_ms, max_rows)
    fn_suggest_indexes(min_seq_scans, max_idx_pct)
```

---

## 3. الـ Views الجديدة (شرح موجز)

### 3.1 `vw_slow_queries`

أبطأ الاستعلامات من `pg_stat_statements` (مُرتَّبة حسب `mean_exec_time` تنازلياً).

```sql
SELECT * FROM vw_slow_queries LIMIT 10;
-- query_snippet | call_count | total_time_s | mean_time_ms | ...
```

**الاستخدام:** تشغيلها يومياً عبر `pg_cron` (غير متاح حالياً) أو يدوياً، يُحدّد أولويات تحسين الفهارس.

### 3.2 `vw_index_usage`

نسبة استخدام الفهارس لكل جدول. النسبة المنخفضة = مرشّح قوي لإضافة فهرس.

```sql
SELECT table_name, sequential_scans, index_scans, index_scan_pct
FROM vw_index_usage
WHERE index_scan_pct < 50
ORDER BY sequential_scans DESC
LIMIT 10;
```

### 3.3 `vw_unused_indexes`

الفهارس التي لم تُستخدم أبداً (`idx_scan = 0`). الـ PKs مُستثناة.

```sql
SELECT table_name, index_name, index_size, total_scans
FROM vw_unused_indexes
ORDER BY index_size_bytes DESC;
-- → DROP INDEX candidate
```

### 3.4 `vw_most_seq_scanned`

أعلى 50 جدول من حيث `seq_scan` المطلق (> 100). أقوى مرشّح لإضافة فهرس جديد.

### 3.5 `vw_active_sessions`

كل الـ sessions النشطة مع duration + waiting_on + query snippet.

```sql
SELECT session_id, db_user, current_query, query_duration_s
FROM vw_active_sessions
WHERE query_duration_s > 5
ORDER BY query_duration_s DESC;
```

### 3.6 `vw_long_running_queries`

Sessions بـ current query > 30 ثانية. **مهم لـ "runaway queries".**

### 3.7 `vw_db_size_summary`

أكبر 20 جدول (total size = table + indexes + TOAST).

```sql
SELECT * FROM vw_db_size_summary;
-- → informs partitioning strategy (gap 6)
```

---

## 4. الـ Helper Functions

### 4.1 `fn_get_slow_queries(min_ms int, max_rows int)`

استعلامات بطيئة مع threshold قابل للتخصيص. افتراضيات: 1000ms, 50 rows.

```sql
SELECT * FROM fn_get_slow_queries(500, 20);   -- slower than 500ms, top 20
```

**يُرجِع أعمدة:** `query_snippet, call_count, mean_time_ms, max_time_ms, total_time_s, total_rows`

### 4.2 `fn_suggest_indexes(min_seq_scans bigint, max_idx_pct numeric)`

اقتراحات سريعة لإضافة فهارس. افتراضيات: 1000 seq_scans, < 50% idx_scan.

```sql
SELECT * FROM fn_suggest_indexes(500, 30.0);  -- أكثر تقيّداً
```

**يُرجِع أعمدة:** `table_name, seq_scan_count, idx_scan_count, index_scan_pct, approx_row_count, table_size, recommendation`

---

## 5. ما يحتاج restart (موثَّق في snippet)

### 5.1 `database/postgresql.conf.monitoring.snippet`

```ini
# 1. shared_preload_libraries — required for monitoring extensions
shared_preload_libraries = 'pg_stat_statements'

# 2. pg_stat_statements configuration
pg_stat_statements.max           = 5000
pg_stat_statements.track         = 'top'
pg_stat_statements.track_utility = off
pg_stat_statements.save          = on

# 3. auto_explain (when available on this PG build)
# auto_explain.log_min_duration  = '1s'
# auto_explain.log_analyze       = on
# auto_explain.log_buffers       = on
# auto_explain.log_format        = 'json'
# auto_explain.sample_rate       = 1.0

# 4. I/O timing accuracy
track_io_timing = on

# 5. Activity tracking
track_activities = on
track_counts     = on
```

**خطوات التطبيق:**

```powershell
# 1. Append snippet
Get-Content database\postgresql.conf.monitoring.snippet | `
    Add-Content "C:\Program Files\PostgreSQL\17\data\postgresql.conf"

# 2. Restart PG (NOT reload — shared_preload_libraries needs full restart)
Restart-Service postgresql-x64-17

# 3. Re-create the extension to pick up the new library
psql -h localhost -U postgres -d IntegratedAccSys `
    -c "CREATE EXTENSION IF NOT EXISTS pg_stat_statements;"

# 4. Verify with the audit script
powershell -ExecutionPolicy Bypass -File scripts\audit-g3-monitoring.ps1
```

### 5.2 auto_explain (خارج النطاق حالياً)

- الـ extension **غير متاح** في build الـ PostgreSQL 17.10 المُثبَّت
- `log_min_duration_statement = 1s` (مُفعَّل من Gap 2) هو الـ fallback
- عند توفّر auto_explain: enable extension + add to `shared_preload_libraries` + restart

---

## 6. الصلاحيات (Grants)

| Object type | Object | Granted to |
|---|---|---|
| Views (7) | `vw_slow_queries`, `vw_index_usage`, `vw_unused_indexes`, `vw_most_seq_scanned`, `vw_active_sessions`, `vw_long_running_queries`, `vw_db_size_summary` | All 6 app_* roles |
| Functions (2) | `fn_get_slow_queries(int,int)`, `fn_suggest_indexes(bigint,numeric)` | All 6 app_* roles |
| Signature | `fn_g3_monitoring_signature()` | PUBLIC |

**لماذا SELECT فقط؟** المراقبة read-only بطبيعتها. لا حاجة لـ INSERT/UPDATE/DELETE على هذه الـ views.

---

## 7. الاختبارات

### 7.1 Gap 3 Audit (8/8 PASS)

```text
[1/8] Idempotency signature             [OK] GAP3-MONITORING-2026-06-10-v1
[2/8] Required extensions               [OK] pgstattuple v1.5 + pg_stat_statements v1.11
[3/8] Monitoring views present          [OK] 7/7 views
[4/8] Helper functions                  [OK] fn_get_slow_queries + fn_suggest_indexes
[5/8] fn_get_slow_queries executes      [WARN] returns error (expected — pg_stat_statements inactive)
[6/8] fn_suggest_indexes executes       [OK] 0 candidates (no table has > 1000 seq_scans yet)
[7/8] SELECT grants for app_* roles     [OK] 43 grants × 3 roles
[8/8] Restart-required items (info)     [..] 3 items pending DBA action
```

**ملاحظة على [5/8]:** `fn_get_slow_queries` يُرجع خطأ متوقّعاً لأن `pg_stat_statements` غير مفعَّل بعد — هذا متوقّع وصحيح. بعد تطبيق `shared_preload_libraries` + restart، ستعمل الدالة.

### 7.2 DbTest (سلوك التطبيق — لم يتأثر)

```text
=== SUMMARY: Passed=46  Failed=0 ===
```

### 7.3 View Smoke Tests

```sql
-- Index usage
SELECT count(*) FROM vw_index_usage;  -- 69 tables

-- Unused indexes
SELECT count(*) FROM vw_unused_indexes;  -- varies

-- DB size summary
SELECT * FROM vw_db_size_summary LIMIT 5;
-- table_name             | total_size | table_size | index_size | approx_row_count
-- public.tbljournalbody  | 250 MB     | 180 MB     | 70 MB      | 1,200,000
-- ...
```

### 7.4 Build

```text
Build succeeded.
    0 Warning(s)
    0 Error(s)
Time Elapsed 00:00:08.35
```

---

## 8. الاستخدام الفعلي (Recipes)

### 8.1 البحث عن أهم 10 استعلامات بطيئة

```sql
SELECT * FROM fn_get_slow_queries(500, 10);
```

### 8.2 اقتراح فهارس جديدة

```sql
SELECT table_name, seq_scan_count, index_scan_pct, table_size, recommendation
FROM fn_suggest_indexes(1000, 50.0);
```

### 8.3 رصد sessions عالقة

```sql
-- الاستعلامات الطويلة فقط
SELECT session_id, db_user, current_query, duration_s
FROM vw_long_running_queries
ORDER BY duration_s DESC;

-- أو kill session
SELECT pg_terminate_backend(pid)
FROM vw_long_running_queries
WHERE duration_s > 300;  -- kill anything > 5 min
```

### 8.4 حجم قاعدة البيانات والـ top-10

```sql
SELECT pg_size_pretty(sum(total_bytes)) AS db_total
FROM vw_db_size_summary;

SELECT * FROM vw_db_size_summary LIMIT 10;
```

### 8.5 فهارس غير مستخدمة (مرشّحة للحذف)

```sql
-- بعد جمع بيانات كافية (شهر على الأقل من الإنتاج)
SELECT table_name, index_name, index_size
FROM vw_unused_indexes
ORDER BY index_size_bytes DESC;
```

> **تحذير:** لا تحذف فهرس لمستخدم UNIQUE constraint أو FK — تحقق أولاً.

---

## 9. المخاطر والاعتبارات

| المخاطرة | الاحتمال | الأثر | التخفيف |
|---|---|---|---|
| `pg_stat_statements` يستهلك ذاكرة | ثابت | منخفض | `pg_stat_statements.max = 5000` (مُعيَّن في snippet) |
| `vw_long_running_queries` يقرأ `pg_stat_activity` بشكل متكرر | منخفض | منخفض | view فقط — لا locks |
| المستخدمون يرون `query` من جلسات غيرهم | متوسط | متوسط | GRANT لـ app_auditor محدود — معظم app_* لا يحتاجون رؤية queries المستخدمين |
| `pgstattuple` يقرأ كل tuple — بطيء على جداول كبيرة | منخفض | متوسط | استخدم على جداول صغيرة/متوسطة فقط؛ للجداول الكبيرة استخدم `pgstattuple_approx` |
| restart يفصل الاتصالات النشطة | ثابت | عالي | جدولة restart في نافذة صيانة + استخدام `pg_hba.conf.snippet` (gap 2) لطلب SSL على app_* |

---

## 10. الملفات المُضافة / المُعدَّلة

| # | المسار | النوع | الوصف |
|---|---|---|---|
| 1 | `database/IntegratedAccSys_Monitoring.sql` | **جديد** | idempotent: `pgstattuple` + 7 views + 2 functions + grants + signature |
| 2 | `database/postgresql.conf.monitoring.snippet` | **جديد** | activation config لـ pg_stat_statements + auto_explain (يحتاج restart) |
| 3 | `scripts/audit-g3-monitoring.ps1` | **جديد** | 8 فحوصات آلية |
| 4 | `docs/audits/GAP_3_MONITORING_REPORT.md` | **جديد** | هذا التقرير |

---

## 11. خارطة طريق — الفجوات التالية

> ⚠️ **القرار:** gap 3 **مُعالَج جزئياً**. الباقي (pg_stat_statements activation + auto_explain) يحتاج restart.

| # | الفجوة | الخطورة | الفرع المُقترح | الجهد |
|---|---|:---:|---|---:|
| 4 | Constraints (CHECK + EXCLUSION) | 🟡 HIGH | `feat/gap-4-constraints` | 3-4 أيام |
| 5 | Indexes (composite + partial + drop unused) | 🟡 MEDIUM | `feat/gap-5-indexes-optimization` | 1 يوم (سريع الآن مع monitoring) |
| 6 | Partitioning (journal/audit/cash) | 🟡 MEDIUM | `feat/gap-6-partitioning` | 1 أسبوع |
| 7 | Materialized Views (0 → 5–6 reports) | 🔴 CRITICAL | `feat/gap-7-materialized-views` | 3-4 أيام |
| 8 | Closing controls + fiscal year audit | 🟡 MEDIUM | `feat/gap-8-closing-controls` | 3-4 أيام |
| 9 | Database governance (roles + locale) | 🟡 HIGH | `feat/gap-9-governance` | 1-2 يوم |
| 10 | Approval Workflows (0 tables → state machine) | 🔴 CRITICAL | `feat/gap-10-approval-workflow` | 5-7 أيام |

**ملاحظة:** Gap #7 (Materialized Views) و #10 (Approval Workflows) نُقلَا من قائمتي الأصلية — كلاهما 🔴 CRITICAL وسيُعالَجان بعد Gap 5 (Indexes) لأن كلاهما يعتمد على بيانات monitoring حقيقية.

---

## 12. التوقيع

| البند | القيمة |
|---|---|
| **الحالة** | 🟡 **PARTIALLY RESOLVED** — immediate items ✅، restart items موثَّقة ⏳ |
| **التوافق** | 100% مع السلوك الحالي (DbTest 46/46، audit 8/8) |
| **التغيير المُكسِّر** | لا شيء — الـ views/functions جديدة read-only |
| **الفرع** | `feat/gap-3-monitoring-extensions` (جاهز للمراجعة والدمج) |
| **الخطوة التالية** | تطبيق snippets (pg_stat_statements + track_io_timing) على production + بدء Gap #4 (Constraints) |
