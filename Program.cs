using System.Data.SqlClient;

namespace IntegratedAccSys
{
    internal static class Program
    {
        public static string userName;
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

        static bool CheckIfConnectionSettingsExist()
        {
            string mode = Properties.Settings.Default.Mode;
            string db = Properties.Settings.Default.DB;
            string server = Properties.Settings.Default.Server;
            string id = Properties.Settings.Default.ID;
            string pwd = Properties.Settings.Default.PWD;
            // ›«—€… €Ì— «·ﬁÌ„ ﬂ· √‰ «· √ﬂœ
            if (string.IsNullOrWhiteSpace(mode) ||
                string.IsNullOrWhiteSpace(db) ||
                string.IsNullOrWhiteSpace(server) ||
                string.IsNullOrWhiteSpace(id) ||
                string.IsNullOrWhiteSpace(pwd))
            {
                return false;
            }

            //  Õﬁﬁ „‰ «·« ’«· «·›⁄·Ì
            string connectionString = $"Server={server};Database={db};User ID={id};Password={pwd};";

            try
            {
                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    return true; // «·« ’«· ‰«ÃÕ
                }
            }
            catch
            {
                return false; // ›‘· «·« ’«·
            }
        }
    }
}