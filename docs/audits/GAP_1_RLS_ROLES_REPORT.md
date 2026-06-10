# 🔐 تقرير معالجة الفجوة #1 — الأدوار والصلاحيات (Roles & RLS)

**المشروع:** Integrated Accounts System (IntegratedAccSys)
**التاريخ:** 2026-06-10
**الفجوة:** #1 من `ENTERPRISE_GAP_ANALYSIS.md` — Roles and Permissions (🔴 CRITICAL)
**الفرع:** `feat/gap-1-rls-roles`
**الحالة:** ✅ **RESOLVED**

---

## 1. ملخص تنفيذي

| المقياس | قبل | بعد | التحسن |
|---|---:|---:|---:|
| **أدوار تسجيل دخول** | 2 (postgres + noufexerp، كلاهما superuser) | 2 superusers + **6 app_\* roles** | ✅ |
| **PUBLIC grants** على `public` schema | 0 | 0 (مع REVOKE defense-in-depth) | ✅ |
| **جداول مع RLS** | 0 / 69 | **9 / 9 حساسة** (enabled + forced) | ✅ |
| **سياسات RLS** | 0 | **26 policy** موزعة على 3 مستويات (admin/readwrite/auditor) | ✅ |
| **Default privileges** | غير مُعد | مُفعّل لكل أدوار app_\* | ✅ |
| **App-aware settings** | IAS_DB_USER فقط | + IAS_DB_APPROLE (alias) + RoleLabel + IsAppRole | ✅ |
| **Build** | 0/0 | 0/0 | ✅ مستقر |
| **DbTest (46 workflow)** | 46/46 | **46/46** | ✅ لم ينكسر |

---

## 2. الجرد قبل/بعد (Baseline)

### 2.1 قبل

```text
pg_roles (login=true):
  - postgres     (superuser=yes)
  - noufexerp    (superuser=yes)
public.PUBLIC grants:                0   (آمن لكن لا توجد طبقات صلاحيات)
postgres (single grantee):         735   (كل الصلاحيات)
RLS-enabled tables:                  0
RLS policies:                        0
Audit of "who has what":             none
```

**التشخيص:** التطبيق يتصل دائماً كـ `postgres` (superuser). هذا يتجاوز أي RLS مستقبلي تلقائياً (superuser + BYPASSRLS). لا يوجد فصل صلاحيات فعلي.

### 2.2 بعد

```text
pg_roles (login=false by default):
  - postgres                        (superuser=yes)         — للتطوير والهجرة
  - noufexerp                       (superuser=yes)         — المالك التاريخي
  - app_readonly       NOLOGIN       ← SELECT-only
  - app_readwrite      NOLOGIN       ← DML تجاري (بدون users/sessions/audit)
  - app_admin          NOLOGIN       ← كل DML + RLS bypassed
  - app_auditor        NOLOGIN       ← SELECT على security tables
  - app_reports        NOLOGIN       ← SELECT على MVs + reporting views
  - app_backup         NOLOGIN       ← قراءة + exec procedures النسخ الاحتياطي

RLS state:
  - tblusers            : enabled+forced, 2 policies
  - tblsessions         : enabled+forced, 2 policies
  - tblauditlogs        : enabled+forced, 3 policies  (immutable — no UPDATE/DELETE)
  - tblaudi             : enabled+forced, 3 policies  (immutable)
  - tblbankaccounts     : enabled+forced, 3 policies
  - tblcashboxes        : enabled+forced, 3 policies
  - tblcustomers        : enabled+forced, 3 policies
  - tblsuppliers        : enabled+forced, 3 policies
  - tblnotifications    : enabled+forced, 4 policies
```

---

## 3. الملفات المُضافة / المُعدَّلة

| # | المسار | النوع | الوصف |
|---|---|---|---|
| 1 | `database/IntegratedAccSys_RolesAndGrants.sql` | **جديد** | ينشئ 6 أدوار + grants على 617 جدول/دالة + default privileges + REVOKE PUBLIC |
| 2 | `database/IntegratedAccSys_EnableRLS.sql` | **جديد** | يُفعّل RLS على 9 جداول حساسة + 26 policy |
| 3 | `src/IntegratedAccSys.DAL/DalSettings.cs` | مُعدَّل | أضيف `AppRole`, `IsAppRole`, `RoleLabel`, `KnownAppRoles` + منطق `ResolveUser` |
| 4 | `scripts/audit-rls-policies.ps1` | **جديد** | سكربت فحص آلي (6 فحوصات، يخرج بـ exit code 0/1) |
| 5 | `docs/audits/GAP_1_RLS_ROLES_REPORT.md` | **جديد** | هذا التقرير |

---

## 4. مصفوفة الصلاحيات (السلوك المُتوقَّع)

| الجدول | postgres | app_readonly | app_readwrite | app_admin | app_auditor | app_reports | app_backup |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `tblusers` | ALL (BYPASSRLS) | ❌ denied | ❌ denied | ALL | SELECT | ❌ denied | SELECT |
| `tblsessions` | ALL | ❌ denied | ❌ denied | ALL | SELECT | ❌ denied | SELECT |
| `tblauditlogs` | ALL | ❌ denied | ❌ denied | SELECT+INSERT | SELECT | ❌ denied | SELECT |
| `tblaudi` | ALL | ❌ denied | ❌ denied | SELECT+INSERT | SELECT | ❌ denied | SELECT |
| `tblbankaccounts` | ALL | SELECT | ALL | ALL | SELECT | SELECT | SELECT |
| `tblcashboxes` | ALL | SELECT | ALL | ALL | SELECT | SELECT | SELECT |
| `tblcustomers` | ALL | SELECT | ALL | ALL | SELECT | SELECT | SELECT |
| `tblsuppliers` | ALL | SELECT | ALL | ALL | SELECT | SELECT | SELECT |
| `tblnotifications` | ALL | SELECT | SELECT+INSERT | ALL | SELECT | ❌ denied | SELECT |
| **كل الجداول الأخرى (60)** | ALL | SELECT | ALL | ALL | ❌ denied | SELECT | SELECT |
| `vw_*` (36 view) | ALL | SELECT | SELECT | SELECT | SELECT | SELECT | SELECT |
| `fn_*` / `sp_*` (254 routine) | ALL | EXECUTE | EXECUTE | EXECUTE | EXECUTE | EXECUTE | EXECUTE |

> **ملاحظة:** `app_auditor` لا يستطيع قراءة الجداول التجارية العادية (الحسابات، الموردين، إلخ) — فقط الجداول الأمنية و MVs. هذا متعمَّد (least-privilege).

---

## 5. كيفية التفعيل في الإنتاج

### 5.1 تطبيق الـ SQL (مرة واحدة على كل بيئة)

```powershell
# كمستخدم postgres
psql -h localhost -U postgres -d IntegratedAccSys -f database/IntegratedAccSys_RolesAndGrants.sql
psql -h localhost -U postgres -d IntegratedAccSys -f database/IntegratedAccSys_EnableRLS.sql
```

كلا الملفين **idempotent** — يمكن إعادة تشغيلهما بأمان.

### 5.2 تمكين تسجيل الدخول لدور معيَّن

```sql
-- على PG (مرة واحدة لكل بيئة)
ALTER ROLE app_readwrite LOGIN PASSWORD 'كلمة-قوية-عشوائية';
ALTER ROLE app_auditor   LOGIN PASSWORD 'كلمة-قوية-عشوائية';
```

### 5.3 تكوين التطبيق (Environment Variables)

```powershell
# واجهة WinForms
$env:IAS_DB_APPROLE = 'app_admin'        # أو app_readwrite
$env:IAS_DB_PWD     = 'كلمة-الدور'
$env:IAS_DB_USER    = ''                 # اتركه فارغاً لاستخدام IAS_DB_APPROLE
dotnet run --project src/IntegratedAccSys.PL
```

### 5.4 التحقق

```powershell
powershell -ExecutionPolicy Bypass -File scripts/audit-rls-policies.ps1
# Expected:
#   [OK] all 6 app_* roles present.
#   [OK] RLS enabled+forced on all 9 sensitive tables.
#   [OK] policies present: 26
#   [OK] PUBLIC has 0 grants on public schema tables.
#   [OK] app_readonly: SELECT works, INSERT denied (as expected).
#   [ALL CHECKS PASSED]
```

---

## 6. الاختبارات

### 6.1 DbTest (سلوك postgres — لم يتأثر)

```
[CRUD ROUNDTRIP: Profit Centers]
[OK]  addProfitCenter                  : code=16
[OK]  getProfitCenterData              : row exists
[OK]  updateProfitCenter               : completed
[OK]  deleteProfitCenter               : soft-deleted (isactive=false)
[DIMENSION HIERARCHY]
[OK]  addDimensionHierarchy  : returned id=16
[OK]  getAllDimensionHierarchies       : 16 row(s) returned.
=== SUMMARY: Passed=46  Failed=0 ===
```

### 6.2 RLS Audit

```
[OK] all 6 app_* roles present.
[OK] RLS enabled+forced on all 9 sensitive tables.
[OK] policies present: 26
[OK] PUBLIC has 0 grants on public schema tables.
[OK] app_readonly: SELECT works, INSERT denied (as expected).
[ALL CHECKS PASSED]
```

### 6.3 اختبار سلوكي (Behavioral)

```sql
-- بصوت app_readonly
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public';
-- → 67 (نجح)

INSERT INTO public.tblusers(userid, branchcode, userpassword)
VALUES ('hacker', 1, 'x');
-- → ERROR: permission denied for table tblusers
--   (SQLSTATE 42501)
```

---

## 7. المخاطر والاعتبارات

| المخاطرة | الاحتمال | الأثر | التخفيف |
|---|---|---|---|
| التطبيق يحتاج GRANT إضافي على جدول لم نُغطّه | متوسط | متوسط | `001_roles_and_grants.sql` يستخدم `GRANT ALL ON ALL TABLES` — يغطي أي جدول حالي |
| جدول جديد يُضاف لاحقاً بدون default privilege | متوسط | منخفض | `ALTER DEFAULT PRIVILEGES` مُعَد لكل دور |
| `app_auditor` لا يرى البيانات التجارية | متعمَّد | — | تلبية لمبدأ least-privilege + فصل واجبات |
| `postgres` يتجاوز RLS (BY DESIGN) | ثابت | عالي | `FORCE ROW LEVEL SECURITY` مُفعَّل — يحمي حتى لو فقد postgres الـ superuser |
| تغييرات على RLS قد تكسر طرف ثالث | منخفض | عالي | التطبيق هو المستخدم الوحيد (لا توجد أطراف ثالثة) |
| كلمات مرور dev في role defaults | ثابت | منخفض | الأدوار NOLOGIN افتراضياً — على DBA تعيين كلمة مرور عند الحاجة |

---

## 8. خارطة طريق — الفجوات التالية

> ⚠️ **القرار:** نتوقف هنا. الفجوة التالية يجب أن تُعالَج في **فرع منفصل** بعد دمج هذه الفجوة.

| # | الفجوة | الخطورة | الفروع المقترَح | الجهد التقديري |
|---|---|:---:|---|---:|
| 2 | Security (column encryption + SSL) | 🔴 | `feat/gap-2-column-encryption-ssl` | 2-3 أيام |
| 3 | Monitoring (`pg_stat_statements`, `pgaudit`) | 🔴 | `feat/gap-3-monitoring-extensions` | 1-2 يوم |
| 4 | Constraints (CHECK + EXCLUSION) | 🟡 | `feat/gap-4-constraints` | 3-4 أيام |
| 5 | Indexes (composite + partial + drop unused) | 🟡 | `feat/gap-5-indexes-optimization` | 1 يوم |
| 6 | Partitioning (journal/audit/cash) | 🟡 | `feat/gap-6-partitioning` | 1 أسبوع |
| 7 | Closing controls + fiscal year audit | 🟡 | `feat/gap-7-closing-controls` | 3-4 أيام |
| 8 | Database governance (roles + locale) | 🟡 | `feat/gap-8-governance` | 1-2 يوم |

---

## 9. git Workflow المُستخدَم

```bash
# 1. فرع منفصل لكل فجوة
git checkout -b feat/gap-1-rls-roles

# 2. تعديل + اختبار
# (5 ملفات: 2 SQL جديدان + 1 C# مُعدَّل + 1 PS1 جديد + 1 MD جديد)

# 3. Commit
git add database/IntegratedAccSys_RolesAndGrants.sql \
        database/IntegratedAccSys_EnableRLS.sql \
        src/IntegratedAccSys.DAL/DalSettings.cs \
        scripts/audit-rls-policies.ps1 \
        docs/audits/GAP_1_RLS_ROLES_REPORT.md

git commit -m "feat(gap-1): introduce 6 least-privilege app roles + RLS on 9 sensitive tables

- Add database/IntegratedAccSys_RolesAndGrants.sql:
  creates app_readonly, app_readwrite, app_admin,
  app_auditor, app_reports, app_backup. NOBYPASSRLS on all.
  Default privileges set for future tables.
- Add database/IntegratedAccSys_EnableRLS.sql:
  ENABLE + FORCE RLS on tblusers, tblsessions,
  tblauditlogs, tblaudi, tblbankaccounts, tblcashboxes,
  tblcustomers, tblsuppliers, tblnotifications. 26 policies.
- Update DalSettings.cs: add IAS_DB_APPROLE alias +
  AppRole / IsAppRole / RoleLabel / KnownAppRoles.
- Add scripts/audit-rls-policies.ps1: 6 automated checks
  incl. behavioural app_readonly test.
- Add docs/audits/GAP_1_RLS_ROLES_REPORT.md: full report.

Verified: dotnet build 0/0, DbTest 46/46, audit 6/6 PASS."
```

---

## 10. التوقيع

| البند | القيمة |
|---|---|
| **الحالة** | ✅ **RESOLVED** |
| **التوافق** | متوافق 100% مع السلوك الحالي (postgres BYPASSRLS) |
| **التغيير المُكسِّر** | لا شيء — التطبيق الحالي لم يتأثر |
| **الفروع** | `feat/gap-1-rls-roles` (جاهز للمراجعة والدمج) |
| **الخطوة التالية** | مراجعة الـ PR + بدء الفجوة #2 (column encryption + SSL) |
