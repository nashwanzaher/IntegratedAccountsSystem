# 🌐 نظام المحاسبة المتكامل - Integrated Accounting System

نظام محاسبي متكامل باستخدام C# و SQL Server، يشمل إدارة الحسابات، المخزون، الفواتير، التقارير، وغيرها من الوظائف المحاسبية.

A complete accounting system developed using C# and SQL Server, covering accounts, inventory, invoicing, reporting, and more.

---

## 📌 إعداد قاعدة البيانات | Database Setup

### 🗄️ اسم قاعدة البيانات | Database Name:
`IntegratedAccSys`

---

## 🔁 خطوات استيراد النسخة الاحتياطية | Restore Backup Steps

1. افتح SQL Server Management Studio (SSMS)  
   Open SQL Server Management Studio (SSMS)

2. اتصل بالسيرفر المحلي مثل:  
   Connect to your local server, such as:  
   - `localhost`  
   - `.\SQLEXPRESS`  
   - `(local)`

3. اضغط بزر الفأرة الأيمن على `Databases` واختر "Restore Database"  
   Right-click on `Databases` → Choose **Restore Database**

4. اختر "Device" ثم حدد ملف النسخة الاحتياطية:  
   Select **Device**, then browse and select the backup file:  
   `Database\IntegratedAccSys.bak`

5. اضغط OK لاستيراد القاعدة.  
   Click OK to complete the restore.

---

## 🔐 إعداد الاتصال | Connection String

### الاتصال بنظام ويندوز (Windows Authentication)

```csharp
Data Source=.\SQLEXPRESS;Initial Catalog=IntegratedAccSys;Integrated Security=True;
