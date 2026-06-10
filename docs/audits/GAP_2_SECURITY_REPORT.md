# 🔐 تقرير معالجة الفجوة #2 — الأمان (Security: SSL + Column Encryption + pgaudit)

**المشروع:** Integrated Accounts System (IntegratedAccSys)
**التاريخ:** 2026-06-10
**الفجوة:** #2 من `ENTERPRISE_GAP_ANALYSIS.md` — Security (🔴 CRITICAL)
**الفرع:** `feat/gap-2-column-encryption-ssl`
**الحالة:** 🟡 **PARTIALLY RESOLVED** (immediate items ✅ | restart-required items ⏳ documented)

---

## 1. ملخص تنفيذي

| المقياس                         |                           قبل |                                                     بعد |   الحالة    |
| ------------------------------- | ----------------------------: | ------------------------------------------------------: | :---------: |
| `pgcrypto` extension            |                        ✅ 1.3 |                    ✅ 1.3 (يُستخدم الآن في PII helpers) |     ✅      |
| `pg_stat_statements`            |                  ❌ غير مثبّت |          ✅ 1.11 مثبّت (لكن يحتاج restart ليسجل فعلياً) |     🟡      |
| `log_statement`                 |                        `none` |                      `'mod'` (DDL + DML فقط، لا SELECT) |     ✅      |
| `log_min_duration_statement`    |                  `-1` (معطّل) |                       `1s` (سجلّ الاستعلامات > 1 ثانية) |     ✅      |
| Connection limits على app\_\*   |              `-1` (غير محدود) |                                          5–50 حسب الدور |     ✅      |
| `pgaudit`                       | ❌ غير متاح على هذا الـ build |                     ⏳ موثَّق في snippet للتطبيق لاحقاً |     🟡      |
| SSL/TLS                         |                        ❌ off |      ⏳ snippet جاهز، يحتاج `postgresql.conf` + restart |     🟡      |
| PII column encryption framework |                      ❌ مفقود | ✅ `fn_pii_encrypt` / `fn_pii_decrypt` + `PiiCrypto.cs` |     ✅      |
| `tblusers.photo_encrypted`      |                     غير موجود |                        ✅ موجود (nullable، غير مُدمِّر) |     ✅      |
| Audit table لمفاتيح PII         |                     غير موجود |                          ✅ `tblaudi_security` (مع RLS) |     ✅      |
| Build                           |                           0/0 |                                                 **0/0** | ✅ لم ينكسر |
| Gap 2 audit script              |                             — |                                     **8/8 checks pass** |     ✅      |
| DbTest (46 workflow)            |                         46/46 |                                    **46/46** (لم يتأثر) |     ✅      |

---

## 2. ما تم تطبيقه فوراً (بدون restart)

### 2.1 `database/IntegratedAccSys_Security.sql`

| #   | البند                                                | التأثير                                                      |
| --- | ---------------------------------------------------- | ------------------------------------------------------------ |
| 1   | `pg_stat_statements` extension                       | إحصائيات الاستعلامات (تحتاج restart لتفعيلها فعلياً)         |
| 2   | `ALTER SYSTEM SET log_statement = 'mod'`             | DDL + DML تُسجَّل في `pg_log` (لا SELECT — لتجنّب تسريب PII) |
| 3   | `ALTER SYSTEM SET log_min_duration_statement = '1s'` | الاستعلامات > 1 ثانية تُسجَّل لتحليل الأداء                  |
| 4   | `ALTER ROLE app_* CONNECTION LIMIT ...`              | حماية DoS — كل دور بحد اتصال مناسب لدوره                     |
| 5   | `fn_pii_encrypt(text) → bytea`                       | تغليف `pgp_sym_encrypt` بمفتاح GUC لكل session               |
| 6   | `fn_pii_decrypt(bytea) → text`                       | فك التشفير، يعيد NULL بصمت عند فشل المفتاح/البيانات          |
| 7   | `tblusers.photo_encrypted` (bytea, nullable)         | عمود جديد للصور المشفَّرة، العمود القديم `photo` باقٍ        |
| 8   | `tblaudi_security` (مع RLS + policies)               | سجلّ تدوير المفاتيح + أحداث أمنية، مع نفس حماية `tblaudi`    |
| 9   | `fn_g2_security_signature()`                         | بصمة idempotency (`GAP2-SECURITY-2026-06-10-v1`)             |

**القيود:**

- `ALTER SYSTEM` لا يعمل داخل transaction block — الملف **لا** يستخدم `BEGIN/COMMIT` (كل أمر في implicit transaction خاص به)
- الملف idempotent 100% — يمكن إعادة تشغيله بأمان

### 2.2 `src/IntegratedAccSys.DAL/Security/PiiCrypto.cs`

| Method                                          | الوصف                                                                                        |
| ----------------------------------------------- | -------------------------------------------------------------------------------------------- |
| `PiiCrypto.ApplyKey(NpgsqlConnection)`          | يقرأ المفتاح من `IAS_PII_KEY` env أو App.config، يُصدر `SET app.pii_key = '...'` على الاتصال |
| `PiiCrypto.OpenWithKey(connStr)`                | Convenience: يفتح الاتصال ويُطبّق المفتاح في خطوة واحدة                                      |
| `PiiCrypto.Encrypt(conn, plaintext) → byte[]?`  | يستدعي `fn_pii_encrypt(@s)`                                                                  |
| `PiiCrypto.Decrypt(conn, ciphertext) → string?` | يستدعي `fn_pii_decrypt(@b)` (يُعيد NULL بصمت عند الفشل)                                      |

**استخدام نموذجي:**

```csharp
using IntegratedAccSys.DAL.Security;

using (var cn = PiiCrypto.OpenWithKey(connStr))
{
    byte[] cipher = PiiCrypto.Encrypt(cn, "user-national-id-12345");
    string plain  = PiiCrypto.Decrypt(cn, cipher);
}
```

**أين يُحفَظ المفتاح؟**

- ✅ Environment variable `IAS_PII_KEY` (الموصى به)
- ⚠️ App.config appSetting `IAS_PII_KEY` (للتطوير المحلي فقط)
- ❌ **أبداً** داخل قاعدة البيانات (لا في جدول، لا في function، لا في `postgresql.auto.conf`)

### 2.3 Connection Limits (DoS Hardening)

| الدور           | الحد | المبرر                                           |
| --------------- | ---: | ------------------------------------------------ |
| `app_admin`     |   20 | البشر عبر PL (5 مستخدمين متزامنين + هامش)        |
| `app_readwrite` |   50 | PL + service workers + التقارير                  |
| `app_readonly`  |   50 | لوحات BI، استعلامات التقارير                     |
| `app_auditor`   |   10 | مراجعات يدوية، نادراً متزامنة                    |
| `app_reports`   |   20 | refresh داش-بورد + jobs مجدولة                   |
| `app_backup`    |    5 | `pg_dump` / `pg_basebackup` (لا حاجة لأكثر من 5) |

### 2.4 Logging Policy

| Setting                      | Value           | ملاحظة                                                   |
| ---------------------------- | --------------- | -------------------------------------------------------- |
| `log_statement`              | `mod`           | DDL + DML فقط (لا SELECT) — لتجنّب تسجيل PII في `pg_log` |
| `log_min_duration_statement` | `1s`            | البطيء فقط (لتجنّب ضوضاء اللوغ)                          |
| `log_destination`            | `csvlog,stderr` | موصى به في snippet لـ ingestion سهل                      |

---

## 3. ما يحتاج restart (موثَّق في snippets)

### 3.1 `database/postgresql.conf.snippet`

```ini
# 1. SSL/TLS
ssl = on
ssl_cert_file = 'server.crt'
ssl_key_file  = 'server.key'
ssl_min_protocol_version = 'TLSv1.2'

# 2. shared_preload_libraries (يُفعّل pg_stat_statements فعلياً)
shared_preload_libraries = 'pg_stat_statements'

# 3. Hardening
idle_in_transaction_session_timeout = '30s'
statement_timeout                   = '60s'
lock_timeout                        = '10s'

# 4. pgaudit (إذا تم تثبيت الـ extension على مستوى OS)
# shared_preload_libraries = 'pg_stat_statements,pgaudit'
# pgaudit.log = 'write, ddl, role, grant'
# pgaudit.log_parameter = on
```

**خطوات التطبيق على بيئة الإنتاج:**

```powershell
# 1. Generate self-signed cert (dev) أو use CA cert (prod)
openssl req -new -x509 -days 3650 -nodes -text `
    -out server.crt -keyout server.key -subj "/CN=db.example.com"

# 2. Copy to PG data dir + lock down perms
Copy-Item server.crt, server.key "C:\Program Files\PostgreSQL\17\data\"
icacls "C:\Program Files\PostgreSQL\17\data\server.key" /inheritance:r /grant:r "$($env:USERNAME):R"

# 3. Append snippet
Get-Content database\postgresql.conf.snippet | `
    Add-Content "C:\Program Files\PostgreSQL\17\data\postgresql.conf"

# 4. Restart (NOT reload — shared_preload_libraries needs full restart)
Restart-Service postgresql-x64-17
```

### 3.2 `database/pg_hba.conf.snippet`

يُجبر SSL على جميع `app_*` عبر `hostssl` ويرفض plaintext:

```conf
# Per-role rules (SSL mandatory for app_*)
hostssl   IntegratedAccSys   app_admin     127.0.0.1/32   scram-sha-256
hostssl   IntegratedAccSys   app_readwrite 127.0.0.1/32   scram-sha-256
hostssl   IntegratedAccSys   app_readonly  127.0.0.1/32   scram-sha-256
hostssl   IntegratedAccSys   app_auditor   127.0.0.1/32   scram-sha-256
hostssl   IntegratedAccSys   app_reports   127.0.0.1/32   scram-sha-256
hostssl   IntegratedAccSys   app_backup    127.0.0.1/32   scram-sha-256

# Backstop: reject any non-SSL connection to the app database
host    all             all             127.0.0.1/32            reject
```

### 3.3 pgaudit (خارج النطاق حالياً)

- الـ extension **غير متاح** في build الـ PostgreSQL 17.10 المُثبَّت على هذا الخادم
- `log_statement = 'mod'` هو fallback كافٍ حتى يتم تثبيت pgaudit
- عند توفّر pgaudit: enable extension + add to `shared_preload_libraries` + restart

---

## 4. استراتيجية تشفير PII

### 4.1 الأعمدة المستهدفة

| الجدول        | العمود               | data_type | الحالة الحالية          | الإجراء                                        |
| ------------- | -------------------- | --------- | ----------------------- | ---------------------------------------------- |
| `tblusers`    | `userpassword`       | bytea     | PBKDF2 hash + salt      | ✅ آمن (لا يحتاج تشفير)                        |
| `tblusers`    | `salt`               | bytea     | 32-byte random          | ✅ آمن (الـ secret هو الـ hash، الـ salt علني) |
| `tblusers`    | `passwordhistory1/2` | bytea     | PBKDF2 hash             | ✅ آمن                                         |
| `tblusers`    | `photo`              | bytea     | **plaintext**           | ⏳ للترحيل → `photo_encrypted`                 |
| `tblusers`    | `photo_encrypted`    | bytea     | (جديد) pgcrypto pgp_sym | ✅ جاهز للاستخدام                              |
| `tblsessions` | `sessiontoken`       | uuid      | random                  | ✅ آمن                                         |

**الخلاصة:** `userpassword` و`salt` **آمنان** (PBKDF2 + 32-byte salt + 100k iterations — OWASP 2023). الشيء الوحيد الذي يحتاج تشفير هو `photo` (PII بصري).

### 4.2 نمط الاستخدام (مثال: حفظ صورة مستخدم)

**قبل (غير آمن):**

```csharp
cmd.CommandText = "UPDATE tblusers SET photo = @img WHERE userid = @uid";
cmd.Parameters.AddWithValue("@img", imageBytes);   // plain bytea
cmd.ExecuteNonQuery();
```

**بعد (مشفر):**

```csharp
byte[] cipher = PiiCrypto.Encrypt(cn, Convert.ToBase64String(imageBytes));
cmd.CommandText = "UPDATE tblusers SET photo_encrypted = @img WHERE userid = @uid";
cmd.Parameters.AddWithValue("@img", cipher);
cmd.ExecuteNonQuery();
```

**للقراءة:**

```csharp
byte[] cipher = (byte[])cmd.ExecuteScalar();
string plainB64 = PiiCrypto.Decrypt(cn, cipher);
byte[] imageBytes = Convert.FromBase64String(plainB64);
```

### 4.3 تدوير المفاتيح (Key Rotation)

نمط مُقترَح (للخطة المستقبلية، **ليس** في هذا الـ PR):

```sql
-- 1. Set old key temporarily to decrypt
SET app.pii_key = '<old-key>';

-- 2. Read all ciphertext, re-encrypt with new key
SET app.pii_key = '<new-key>';
UPDATE tblusers
SET photo_encrypted = fn_pii_encrypt(fn_pii_decrypt(photo_encrypted))
WHERE photo_encrypted IS NOT NULL;

-- 3. Log the rotation
INSERT INTO tblaudi_security(event_type, event_payload)
VALUES ('PII_KEY_ROTATED', jsonb_build_object('at', now(), 'rows', ROW_COUNT));

-- 4. Update env / secrets store with new key
```

---

## 5. الاختبارات

### 5.1 Gap 2 Audit (8/8 PASS)

```
[1/8] Idempotency signature                    [OK] GAP2-SECURITY-2026-06-10-v1
[2/8] pg_stat_statements extension             [OK] installed v1.11
[3/8] log_statement + log_min_duration         [OK] 'mod' + 1s
[4/8] Connection limits on app_* roles         [OK] 6/6 limits match policy
[5/8] PII helpers (fn_pii_encrypt/decrypt)     [OK] both functions present
[6/8] PII round-trip behaviour                 [OK] encrypt → decrypt works
[7/8] tblusers.photo_encrypted column          [OK] column present
[8/8] Restart-required items (informational)   [..] 3 items pending DBA action
```

### 5.2 DbTest (سلوك التطبيق — لم يتأثر)

```
=== SUMMARY: Passed=46  Failed=0 ===
```

### 5.3 Round-Trip Behavioural Test

```sql
-- In session with app.pii_key set
SELECT fn_pii_decrypt(fn_pii_encrypt('hello world'));
-- → 'hello world'  (لا تسريب للـ plaintext في log لأن log_statement='mod')
```

### 5.4 Build

```
Build succeeded.
    0 Warning(s)
    0 Error(s)
Time Elapsed 00:00:01.57
```

---

## 6. المخاطر والاعتبارات

| المخاطرة                                            | الاحتمال | الأثر | التخفيف                                                                          |
| --------------------------------------------------- | -------- | ----- | -------------------------------------------------------------------------------- |
| التطبيق لا يستدعي `PiiCrypto.ApplyKey` على كل اتصال | متوسط    | عالي  | `OpenWithKey()` يجعلها صعبة التخطي (الافتراضي)                                   |
| مفتاح PII ضعيف أو قصير                              | منخفض    | عالي  | `MinKeyLength = 16` مُفعَّل، يفحص في `ApplyKey`                                  |
| تسريب المفتاح عبر logs                              | منخفض    | عالي  | `log_statement='mod'` لا يسجّل SELECT (الدوال تُستدعى عبر SELECT)                |
| فقدان المفتاح = فقدان كل الصور                      | ثابت     | عالي  | snippet key rotation + نسخ احتياطي آمن للمفتاح (KMS / secrets manager)           |
| `pgaudit` غير متاح على هذا الـ build                | ثابت     | متوسط | `log_statement='mod'` fallback، التطبيق العملي مستقر                             |
| `app.pii_key` يُسرَّب عبر `pg_stat_statements`      | منخفض    | عالي  | تأكد أن `pg_stat_statements.track = 'top'` (افتراضي) — لا يسجّل parameter values |
| app\_\* roles لا تستخدم SSL بعد (post-restart)      | متوسط    | عالي  | `pg_hba.conf.snippet` يُجبر `hostssl` — يجب تطبيقه بالتزامن مع SSL snippet       |

---

## 7. الملفات المُضافة / المُعدَّلة

| #   | المسار                                           | النوع    | الوصف                                                                                                        |
| --- | ------------------------------------------------ | -------- | ------------------------------------------------------------------------------------------------------------ |
| 1   | `database/IntegratedAccSys_Security.sql`         | **جديد** | idempotent: pg_stat_statements + log config + conn limits + PII helpers + photo_encrypted + tblaudi_security |
| 2   | `database/postgresql.conf.snippet`               | **جديد** | SSL + shared_preload_libraries + hardening (يحتاج restart)                                                   |
| 3   | `database/pg_hba.conf.snippet`                   | **جديد** | `hostssl` إلزامي لـ app\_\* + reject لـ plaintext (يحتاج reload)                                             |
| 4   | `src/IntegratedAccSys.DAL/Security/PiiCrypto.cs` | **جديد** | C# helper: ApplyKey/OpenWithKey/Encrypt/Decrypt                                                              |
| 5   | `scripts/audit-g2-security.ps1`                  | **جديد** | 8 فحوصات آلية + restart-required items marker                                                                |
| 6   | `docs/audits/GAP_2_SECURITY_REPORT.md`           | **جديد** | هذا التقرير                                                                                                  |

---

## 8. خارطة طريق — الفجوات التالية

> ⚠️ **القرار:** gap 2 **مُعالَج جزئياً**. الباقي (SSL + pgaudit) يحتاج تدخل DBA على postgresql.conf.

| #   | الفجوة                                                        | الخطورة | الفرع المُقترح                     |    الجهد |
| --- | ------------------------------------------------------------- | :-----: | ---------------------------------- | -------: |
| 3   | Monitoring (`pg_stat_statements` activation + `auto_explain`) |   🔴    | `feat/gap-3-monitoring-extensions` |  1-2 يوم |
| 4   | Constraints (CHECK + EXCLUSION)                               |   🟡    | `feat/gap-4-constraints`           | 3-4 أيام |
| 5   | Indexes (composite + partial + drop unused)                   |   🟡    | `feat/gap-5-indexes-optimization`  |    1 يوم |
| 6   | Partitioning (journal/audit/cash)                             |   🟡    | `feat/gap-6-partitioning`          |  1 أسبوع |
| 7   | Closing controls + fiscal year audit                          |   🟡    | `feat/gap-7-closing-controls`      | 3-4 أيام |
| 8   | Database governance (roles + locale)                          |   🟡    | `feat/gap-8-governance`            |  1-2 يوم |

---

## 9. التوقيع

| البند                 | القيمة                                                                         |
| --------------------- | ------------------------------------------------------------------------------ |
| **الحالة**            | 🟡 **PARTIALLY RESOLVED** — immediate items ✅، restart items موثَّقة ⏳       |
| **التوافق**           | 100% مع السلوك الحالي (DbTest 46/46، audit 8/8)                                |
| **التغيير المُكسِّر** | لا شيء — التطبيق الحالي لم يتأثر (العمود الجديد nullable، الدوال جديدة)        |
| **الفرع**             | `feat/gap-2-column-encryption-ssl` (جاهز للمراجعة والدمج)                      |
| **الخطوة التالية**    | تطبيق snippets (SSL + pg_hba.conf) على production + بدء الفجوة #3 (Monitoring) |
