using System;

namespace IntegratedAccSys.DAL
{
    /// <summary>
    /// DAL-specific configuration settings.
    /// Reads connection settings from environment variables first, then falls
    /// back to System.Configuration defaults. This allows the DAL layer to be
    /// configured independently of the PL layer (proper tier separation).
    /// 
    /// Environment variables (override order):
    ///   IAS_DB_MODE    — "SQL" or "Windows"
    ///   IAS_DB_SERVER  — PostgreSQL host
    ///   IAS_DB_PORT    — PostgreSQL port (default 5432)
    ///   IAS_DB_NAME    — Database name
    ///   IAS_DB_USER    — Username
    ///   IAS_DB_PWD     — Password
    /// </summary>
    public static class DalSettings
    {
        private const string Prefix = "IAS_DB_";

        public static string Mode => Get("MODE", "SQL");
        public static string Server => Get("SERVER", "localhost");
        public static string Port => Get("PORT", "5432");
        public static string DB => Get("NAME", "IntegratedAccSys");
        public static string ID => Get("USER", "postgres");
        public static string PWD => Get("PWD", "postgres");

        private static string Get(string suffix, string fallback)
        {
            string envKey = Prefix + suffix;
            string? value = Environment.GetEnvironmentVariable(envKey);
            if (!string.IsNullOrWhiteSpace(value))
                return value;

            // Fallback: read from App.config if available
            try
            {
                var appSetting = System.Configuration.ConfigurationManager.AppSettings[envKey];
                if (!string.IsNullOrWhiteSpace(appSetting))
                    return appSetting;
            }
            catch
            {
                // ConfigurationManager may not be available in some contexts
            }

            return fallback;
        }
    }
}
