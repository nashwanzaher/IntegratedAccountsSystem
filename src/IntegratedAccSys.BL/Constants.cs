using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IntegratedAccSys.BL
{
    /// <summary>
    /// ثوابت وتصنيفات النظام
    /// System Constants and Enumerations
    /// </summary>
    public static class Constants
    {
        #region Operation Types - أنواع العمليات

        /// <summary>رقم تعريف عملية البيع</summary>
        public const int OpTypeSale = 4;

        /// <summary>رقم تعريف عملية الشراء</summary>
        public const int OpTypePurchase = 5;

        /// <summary>رقم تعريف عملية التوريد المخزني</summary>
        public const int OpTypeStoreImport = 6;

        /// <summary>رقم تعريف عملية الصرف المخزني</summary>
        public const int OpTypeStoreExport = 7;

        #endregion

        #region Bond Types - أنواع السندات

        /// <summary>سند قبض (استلام)</summary>
        public const int BondTypeReceive = 2;

        /// <summary>سند صرف (دفع)</summary>
        public const int BondTypePay = 3;

        #endregion

        #region Report Types - أنواع التقارير

        /// <summary>تقرير قائمة الميزانية العمومية</summary>
        public const int ReportTypeBalanceSheet = 1;

        /// <summary>تقرير قائمة الأرباح والخسائر</summary>
        public const int ReportTypeProfitAndLoss = 2;

        #endregion

        #region Posting Status - حالة الترحيل

        /// <summary>ترحيل الحسابات</summary>
        public const int PostingStatusPost = 1;

        /// <summary>إلغاء ترحيل الحسابات</summary>
        public const int PostingStatusUnpost = 2;

        #endregion

        #region Privilege Values - قيم الصلاحيات

        /// <summary>تمكين</summary>
        public const int PrivilegeEnabled = 1;

        /// <summary>تعطيل</summary>
        public const int PrivilegeDisabled = 0;

        #endregion

        #region Backup Types - أنواع النسخ الاحتياطية

        /// <summary>نسخ احتياطي</summary>
        public const int BackupTypeCreate = 1;

        /// <summary>استرجاع</summary>
        public const int BackupTypeRestore = 2;

        #endregion

        #region Connection Modes - أوضاع الاتصال

        /// <summary>وضع المصادقة عبر ويندوز</summary>
        public const string ConnectionModeWindowsAuth = "Windows Authentication";

        /// <summary>وضع المصادقة عبر SQL Server</summary>
        public const string ConnectionModeSQLAuth = "SQL";

        #endregion
    }

    #region Enums - للتصنيفات المسماة

    /// <summary>
    /// أنواع عمليات النظام
    /// </summary>
    public enum OperationType
    {
        /// <summary>بيع</summary>
        Sale = 4,

        /// <summary>شراء</summary>
        Purchase = 5,

        /// <summary>توريد مخزني</summary>
        StoreImport = 6,

        /// <summary>صرف مخزني</summary>
        StoreExport = 7
    }

    /// <summary>
    /// أنواع السندات
    /// </summary>
    public enum BondType
    {
        /// <summary>سند قبض (استلام)</summary>
        Receive = 2,

        /// <summary>سند صرف (دفع)</summary>
        Pay = 3
    }

    /// <summary>
    /// أنواع التقارير المالية
    /// </summary>
    public enum ReportType
    {
        /// <summary>قائمة الميزانية العمومية</summary>
        BalanceSheet = 1,

        /// <summary>قائمة الأرباح والخسائر</summary>
        ProfitAndLoss = 2
    }

    /// <summary>
    /// حالة الترحيل
    /// </summary>
    public enum PostingStatus
    {
        /// <summary>ترحيل</summary>
        Post = 1,

        /// <summary>إلغاء ترحيل</summary>
        Unpost = 2
    }

    /// <summary>
    /// أنواع النسخ الاحتياطية
    /// </summary>
    public enum BackupType
    {
        /// <summary>إنشاء نسخة احتياطية</summary>
        Create = 1,

        /// <summary>استرجاع نسخة احتياطية</summary>
        Restore = 2
    }

    #endregion
}
