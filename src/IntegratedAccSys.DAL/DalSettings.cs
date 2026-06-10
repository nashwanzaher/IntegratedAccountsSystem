using System;
using System.Collections.Generic;

namespace IntegratedAccSys.DAL
{
    /// <summary>
    /// DAL-specific configuration settings.
    /// Reads connection settings from environment variables first, then falls
    /// back to System.Configuration defaults. This allows the DAL layer to be
    /// configured independently of the PL layer (proper tier separation).
    ///
    /// Environment variables (override order):
    ///   IAS_DB_MODE     — "SQL" or "Windows"
    ///   IAS_DB_SERVER   — PostgreSQL host
    ///   IAS_DB_PORT     — PostgreSQL port (default 5432)
    ///   IAS_DB_NAME     — Database name
    ///   IAS_DB_USER     — Literal PostgreSQL username (highest priority)
    ///   IAS_DB_PWD      — Password for the above user
    ///   IAS_DB_APPROLE  — Friendly alias for a least-privilege app role.
    ///                     One of: postgres, app_readonly, app_readwrite,
    ///                     app_admin, app_auditor, app_reports, app_backup.
    ///                     Used only when IAS_DB_USER is NOT set. Lets ops
    ///                     switch from "postgres (superuser)" to a least-
    ///                     privilege role without touching secrets.
    /// </summary>
    public static class DalSettings
    {
        private const string Prefix = "IAS_DB_";

        /// <summary>
        /// Known application roles. Any other value of IAS_DB_APPROLE is rejected.
        /// </summary>
        public static readonly IReadOnlySet<string> KnownAppRoles =
            new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            {
                "postgres",
                "app_readonly",
                "app_readwrite",
                "app_admin",
                "app_auditor",
                "app_reports",
                "app_backup",
            };

        public static string Mode => Get("MODE", "SQL");
        public static string Server => Get("SERVER", "localhost");
        public static string Port => Get("PORT", "5432");
        public static string DB => Get("NAME", "IntegratedAccSys");

        /// <summary>
        /// Resolved PostgreSQL username.
        /// Priority: IAS_DB_USER → IAS_DB_APPROLE → "postgres".
        /// </summary>
        public static string ID => ResolveUser();

        public static string PWD => Get("PWD", "postgres");

        /// <summary>
        /// Raw value of IAS_DB_APPROLE. Empty if not set.
        /// Use <see cref="IsAppRole"/> to check whether the effective user is a
        /// least-privilege app role (recommended for production).
        /// </summary>
        public static string AppRole => Get("APPROLE", string.Empty);

        /// <summary>
        /// True if the effective connection user is one of the app_* roles.
        /// </summary>
        public static bool IsAppRole =>
            ID.StartsWith("app_", StringComparison.OrdinalIgnoreCase);

        /// <summary>
        /// Effective role label for logging / audit. Falls back to the
        /// resolved user (ID) when AppRole is empty.
        /// </summary>
        public static string RoleLabel =>
            string.IsNullOrWhiteSpace(AppRole) ? ID : AppRole;

        private static string ResolveUser()
        {
            // 1. Explicit IAS_DB_USER wins (backwards compatible).
            string? explicitUser = Environment.GetEnvironmentVariable(Prefix + "USER");
            if (!string.IsNullOrWhiteSpace(explicitUser))
                return explicitUser;

            try
            {
                var appUser = System.Configuration.ConfigurationManager.AppSettings[Prefix + "USER"];
                if (!string.IsNullOrWhiteSpace(appUser))
                    return appUser;
            }
            catch
            {
                // ConfigurationManager may not be available in some contexts
            }

            // 2. Friendly alias IAS_DB_APPROLE (new in Gap #1).
            string appRole = Get("APPROLE", string.Empty);
            if (!string.IsNullOrWhiteSpace(appRole))
            {
                if (KnownAppRoles.Contains(appRole))
                    return appRole;

                // Unknown alias — fail loud rather than silently fall through.
                throw new InvalidOperationException(
                    $"Unknown IAS_DB_APPROLE value: '{appRole}'. " +
                    $"Allowed values: {string.Join(", ", KnownAppRoles)}");
            }

            // 3. Default — postgres superuser (dev only).
            return "postgres";
        }

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
