# 📋 تقرير إعادة تنظيم قاعدة البيانات
## IntegratedAccSys v2 - PostgreSQL 17.10 Professional Reorganization

**التاريخ:** 2026-06-10
**هدف:** استخدام جميع مميزات PostgreSQL 17.10 بشكل احترافي

---

## 📊 ملخص التغييرات

| العنصر | قبل | بعد |
|--------|-----|------|
| **عدد المخططات (Schemas)** | 1 (public) | 8 |
| **الجداول المقسمة (Partitioned)** | 0 | 4 |
| **Enums** | 0 | 11 |
| **Domain Types** | 0 | 5 |
| **Generated Columns** | 0 | 15+ |
| **JSONB Columns** | 0 | 20+ |
| **Materialized Views** | 0 | 3 |
| **Partial Indexes** | 0 | 3 |
| **GIN Indexes** | 0 | 3 |
| **RLS Policies** | 0 | 2 |

---

## 🏗️ 1. تنظيم المخططات (Schema Organization)

### المخططات الجديدة:

```
IntegratedAccSys Database
├── public              ← للتوافق الخلفي (backward compatibility)
├── accounting          ← دليل الحسابات واليوميات
├── inventory          ← المنتجات والمخازن والعمليات
├── approval           ← سير العمل للموافقة
├── dimensions        ← مراكز التكلفة والمشاريع والأبعاد
├── security          ← المستخدمين والأدوار والامتيازات
├── audit             ← سجلات التدقيق
├── reporting         ← Views و Materialized Views
└── config            ← تكوين النظام والبيانات الرئيسية
```

---

## 📦 2. جداول PostgreSQL Partitioning

### الجداول المقسمة (Partitioned Tables):

| الجدول | نوع التقسيم | السبب |
|--------|-------------|-------|
| `accounting.tblaccounts` | RANGE (account_code) | جدول كبير مع بيانات هرمية |
| `accounting.tbljournalheader` | RANGE (journal_date) | تحسين الأداء حسب التاريخ |
| `accounting.tbljournalbody` | RANGE (journal_body_code) | جدول حركات كبير |
| `inventory.tbloperationheader` | RANGE (operation_date) | تحسين الأداء حسب التاريخ |
| `inventory.tbloperationbody` | RANGE (operation_body_code) | جدول تفاصيل كبير |
| `audit.tblauditlogs` | RANGE (created_at) | أرشفة حسب السنة |

---

## 🎯 3. Enums (أنواع البيانات الثابتة)

```sql
-- محاسبة
account_type:     ASSET, LIABILITY, EQUITY, REVENUE, EXPENSE
account_level:     ROOT, GROUP, DETAIL

-- موافقة
approval_status:  PENDING, APPROVED, REJECTED, CANCELLED, DELEGATED
approval_priority: LOW, MEDIUM, HIGH, URGENT

-- مخزون
operation_type:   PURCHASE, SALE, RETURN, TRANSFER, ADJUSTMENT
movement_type:     IN, OUT, TRANSFER, ADJUSTMENT

-- أبعاد
hierarchy_type:   PROJECT_TO_DEPARTMENT, DEPARTMENT_TO_PROJECT, ...

-- أمان
privilege_type:    DISPLAY, ADD, EDIT, DELETE, PRINT, EXPORT, APPROVE, POST

-- تدقيق
event_category:   CREATE, UPDATE, DELETE, LOGIN, LOGOUT, APPROVAL, POSTING
```

---

## 🏷️ 4. Domain Types (أنواع مخصصة مع تحقق)

```sql
config.money           → NUMERIC(18,4) مع CHECK (VALUE >= 0)
config.percentage       → NUMERIC(5,2) مع CHECK (0-100)
config.phone_number    → VARCHAR(50) مع تحقق من الصيغة
config.email_address   → VARCHAR(100) مع تحقق من البريد
config.iban_code       → VARCHAR(50) مع تحقق من IBAN
config.swift_code      → VARCHAR(20) مع تحقق من SWIFT
```

---

## ⚙️ 5. Generated Columns (أعمدة مُنشأة)

```sql
-- لحساب المبالغ المحلية
debit_local NUMERIC(18,4) GENERATED ALWAYS AS (debit * exchange_rate) STORED

-- لتاريخ وسنة ورشه
year INT GENERATED ALWAYS AS (EXTRACT(YEAR FROM journal_date)) STORED
month INT GENERATED ALWAYS AS (EXTRACT(MONTH FROM journal_date)) STORED

-- للمسار الكامل في الأبعاد
full_path TEXT GENERATED ALWAYS AS (...) STORED

-- للبحث النصي الكامل
search_vector TSVECTOR GENERATED ALWAYS AS (to_tsvector(...)) STORED
```

---

## 📝 6. JSONB Columns (بيانات مرنة)

```sql
metadata JSONB DEFAULT '{}'
session_data JSONB DEFAULT '{}'
custom_permissions JSONB DEFAULT '{}'
password_history JSONB DEFAULT '[]'
```

**الفوائد:**
- تخزين بيانات مرنة بدون تغيير الهيكل
- إمكانية إضافة حقول جديدة بدون ALTER TABLE
- استعلامات سريعة مع GIN indexes

---

## 🔍 7. Indexes متقدمة

### Partial Indexes:
```sql
CREATE INDEX idx_users_active ON tblusers (user_id) WHERE is_active = TRUE;
CREATE INDEX idx_accounts_active ON tblaccounts (account_code) WHERE is_active = TRUE;
```

### Expression Indexes:
```sql
CREATE INDEX idx_products_search ON tblproducts USING GIN (search_vector);
```

### JSONB GIN Indexes:
```sql
CREATE INDEX idx_users_metadata ON tblusers USING GIN (metadata);
```

### Composite Indexes:
```sql
CREATE INDEX idx_journalbody_account_date ON tbljournalbody (account_code, journal_code);
```

---

## 🛡️ 8. Row-Level Security (RLS)

```sql
-- تفعيل RLS على الجداول الحساسة
ALTER TABLE tblusers ENABLE ROW LEVEL SECURITY;
ALTER TABLE tblsessions ENABLE ROW LEVEL SECURITY;

-- سياسات الوصول
CREATE POLICY user_own_data ON tblusers
    FOR ALL
    USING (user_code = current_setting('app.current_user_code', TRUE)::INT);
```

---

## 👁️ 9. Materialized Views (للتقارير)

```sql
-- عرض هرمي الحسابات
CREATE MATERIALIZED VIEW reporting.vw_account_hierarchy AS
SELECT ... FROM accounting.tblaccounts ... WITH NO DATA;

-- عرض استخدام الأبعاد
CREATE MATERIALIZED VIEW reporting.vw_dimension_usage AS
SELECT dim_type, dim_code, COUNT(*), SUM(...) ... WITH NO DATA;

-- عرض ملخص المخزون
CREATE MATERIALIZED VIEW reporting.vw_product_stock_summary AS
SELECT p.*, sp.qty_on_hand, sp.qty_available ... WITH NO DATA;
```

---

## 🔤 10. Full-Text Search

```sql
-- عمود البحث المُنشأ
search_vector TSVECTOR GENERATED ALWAYS AS (
    to_tsvector('arabic', product_name_ar || ' ' || COALESCE(product_name_en, ''))
) STORED

-- إنشاء الفهرس
CREATE INDEX idx_products_search ON tblproducts USING GIN (search_vector);

-- الاستخدام
SELECT * FROM tblproducts WHERE search_vector @@ to_tsquery('arabic', 'بحث');
```

---

## 📄 11. Sequences (لتوليد المفاتيح)

```sql
CREATE SEQUENCE accounting.tblaccounts_accountcode_seq;
CREATE SEQUENCE accounting.tbljournalheader_journalcode_seq;
CREATE SEQUENCE inventory.tbloperationheader_operationcode_seq;
-- ... والمزيد
```

---

## 📚 12. Comments والتوثيق

```sql
COMMENT ON SCHEMA accounting IS 'Chart of accounts and journal entries';
COMMENT ON TABLE accounting.tblaccounts IS 'Chart of accounts - hierarchical account structure';
COMMENT ON COLUMN accounting.tbljournalbody.debit_local IS 'Debit amount in local currency';
```

---

## 🔄 13. التوافق الخلفي (Backward Compatibility)

تم إنشاء Views في schema `public` لتعكس الأسماء القديمة:

```sql
CREATE OR REPLACE VIEW public.tblaccounts AS
SELECT account_code, account_id, account_name_ar, ...
FROM accounting.tblaccounts;
```

---

## 🚀 خطوات التطبيق

### 1. نسخ احتياطي
```bash
pg_dump -h localhost -U postgres -d IntegratedAccSys > backup_before_v2.sql
```

### 2. تطبيق الهيكل الجديد
```bash
psql -h localhost -U postgres -d IntegratedAccSys -f IntegratedAccSys_v2_PostgreSQL_Reorganized.sql
```

### 3. التحقق
```sql
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema IN ('accounting', 'inventory', 'approval', 'dimensions', 'security', 'audit', 'reporting', 'config');
-- Expected: 40+ tables
```

### 4. تشغيل الاختبارات
```bash
dotnet run --project tests/IntegratedAccSys.DAL.DbTest
```

---

## ⚠️ ملاحظات مهمة

1. **Partitioning** - الجداول المقسمة تتطلب صيانة دورية (VACUUM, ANALYZE)
2. **RLS** - يجب تعيين `app.current_user_code` عند كل اتصال
3. **Materialized Views** - تحتاج REFRESH بعد التحديثات
4. **Full-Text Search** - يدعم العربية (arabic dictionary)

---

## ✅ الخلاصة

| الميزة | الحالة |
|--------|--------|
| Schema Organization | ✅ |
| Table Partitioning | ✅ |
| Enums & Domains | ✅ |
| Generated Columns | ✅ |
| JSONB | ✅ |
| Advanced Indexing | ✅ |
| Row-Level Security | ✅ |
| Materialized Views | ✅ |
| Full-Text Search | ✅ |
| Comments | ✅ |
| Backward Compatibility | ✅ |
