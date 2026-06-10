using Npgsql;

namespace IntegratedAccSys.PL
{
    internal static class Program
    {
        public static string userName = null!;
        public static int braCode;
        /// <summary>
        ///  The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            // To customize application configuration such as set high DPI settings or default font,
            // see https://aka.ms/applicationconfiguration.
            ApplicationConfiguration.Initialize();
            Application.Run(new PL.Users.frmLogin());

        }

        /// <summary>
        /// التحقق من وجود إعدادات الاتصال بقاعدة البيانات.
        /// Returns true if all connection settings are configured.
        /// </summary>
        static bool CheckIfConnectionSettingsExist()
        {
            string mode = Properties.Settings.Default.Mode;
            string db = Properties.Settings.Default.DB;
            string server = Properties.Settings.Default.Server;
            string id = Properties.Settings.Default.ID;
            string pwd = Properties.Settings.Default.PWD;

            // التحقق من اكتمال جميع الإعدادات
            if (string.IsNullOrWhiteSpace(mode) ||
                string.IsNullOrWhiteSpace(db) ||
                string.IsNullOrWhiteSpace(server) ||
                string.IsNullOrWhiteSpace(id) ||
                string.IsNullOrWhiteSpace(pwd))
            {
                return false;
            }

            // بناء سلسلة الاتصال
            string connectionString = $"Server={server};Database={db};User ID={id};Password={pwd};";

            try
            {
                using (var conn = new NpgsqlConnection(connectionString))
                {
                    conn.Open();
                    return true; // تم الاتصال بنجاح
                }
            }
            catch
            {
                return false; // فشل الاتصال
            }
        }
    }
}
