using System;
using System.Configuration;
using Npgsql;

namespace IntegratedAccSys.DAL.Security
{
    /// <summary>
    /// Application-side helper for PII column encryption / decryption.
    ///
    /// The actual encryption is performed by the pgcrypto-backed SQL
    /// functions <c>fn_pii_encrypt(text)</c> and
    /// <c>fn_pii_decrypt(bytea)</c> installed by
    /// <c>database/IntegratedAccSys_Security.sql</c>. The symmetric key
    /// is supplied per-session via the <c>app.pii_key</c> GUC and
    /// is <b>never</b> persisted in the database.
    ///
    /// Wire the key into the connection by calling
    /// <see cref="ApplyKey"/> immediately after opening it:
    /// <code>
    /// using (var cn = new NpgsqlConnection(connStr))
    /// {
    ///     cn.Open();
    ///     PiiCrypto.ApplyKey(cn);   // issues SET app.pii_key = '...'
    ///     // ... use the connection ...
    /// }
    /// </code>
    ///
    /// The key source, in priority order:
    ///   1. Environment variable <c>IAS_PII_KEY</c> (recommended).
    ///   2. App.config appSetting <c>IAS_PII_KEY</c> (dev only).
    /// </summary>
    public static class PiiCrypto
    {
        private const string KeyEnvVar = "IAS_PII_KEY";
        private const string KeyAppSetting = "IAS_PII_KEY";
        private const string PgGuc = "app.pii_key";
        private const int MinKeyLength = 16;

        /// <summary>
        /// Reads the PII key from env / config and issues
        /// <c>SET app.pii_key = '...'</c> on the given connection.
        /// Throws if the key is missing or shorter than 16 characters.
        /// </summary>
        public static void ApplyKey(NpgsqlConnection connection)
        {
            if (connection is null) throw new ArgumentNullException(nameof(connection));
            if (connection.State != System.Data.ConnectionState.Open)
                throw new InvalidOperationException("Connection must be open before ApplyKey().");

            string? key = ResolveKey();
            if (string.IsNullOrEmpty(key) || key.Length < MinKeyLength)
                throw new InvalidOperationException(
                    $"{KeyEnvVar} must be at least {MinKeyLength} characters. " +
                    "Set it as an env var (preferred) or in App.config (dev only).");

            using (var cmd = new NpgsqlCommand($"SET {PgGuc} = @k", connection))
            {
                cmd.Parameters.AddWithValue("@k", key);
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Convenience wrapper that opens a connection, applies the key,
        /// and returns it ready to use. Caller owns disposal.
        /// </summary>
        public static NpgsqlConnection OpenWithKey(string connectionString)
        {
            if (string.IsNullOrWhiteSpace(connectionString))
                throw new ArgumentException("Connection string is required.", nameof(connectionString));

            var cn = new NpgsqlConnection(connectionString);
            cn.Open();
            ApplyKey(cn);
            return cn;
        }

        /// <summary>
        /// Encrypts a PII string by calling <c>fn_pii_encrypt(@s)</c>
        /// on the supplied open connection. Returns <c>null</c> if
        /// the input is null.
        /// </summary>
        public static byte[]? Encrypt(NpgsqlConnection connection, string plaintext)
        {
            if (plaintext is null) return null;
            if (connection is null) throw new ArgumentNullException(nameof(connection));

            using (var cmd = new NpgsqlCommand("SELECT fn_pii_encrypt(@s)", connection))
            {
                cmd.Parameters.AddWithValue("@s", plaintext);
                var raw = cmd.ExecuteScalar();
                if (raw is null or DBNull) return null;
                return (byte[])raw;
            }
        }

        /// <summary>
        /// Decrypts a PII blob by calling <c>fn_pii_decrypt(@b)</c>
        /// on the supplied open connection. Returns <c>null</c> if
        /// the input is null OR the key is wrong / the blob is corrupt.
        /// </summary>
        public static string? Decrypt(NpgsqlConnection connection, byte[] ciphertext)
        {
            if (ciphertext is null) return null;
            if (connection is null) throw new ArgumentNullException(nameof(connection));

            using (var cmd = new NpgsqlCommand("SELECT fn_pii_decrypt(@b)", connection))
            {
                cmd.Parameters.AddWithValue("@b", ciphertext);
                var raw = cmd.ExecuteScalar();
                if (raw is null or DBNull) return null;
                return (string)raw;
            }
        }

        private static string? ResolveKey()
        {
            string? fromEnv = Environment.GetEnvironmentVariable(KeyEnvVar);
            if (!string.IsNullOrEmpty(fromEnv)) return fromEnv;

            try
            {
                string? fromConfig = ConfigurationManager.AppSettings[KeyAppSetting];
                if (!string.IsNullOrEmpty(fromConfig)) return fromConfig;
            }
            catch
            {
                // ConfigurationManager not available in some test contexts.
            }

            return null;
        }
    }
}
