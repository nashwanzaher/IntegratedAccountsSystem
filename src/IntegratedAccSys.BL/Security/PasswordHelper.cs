using System;
using System.Security.Cryptography;
using System.Text;

namespace IntegratedAccSys.BL.Security
{
    /// <summary>
    /// Handles salted PBKDF2 password hashing and verification.
    /// Used for secure credential storage in tblUsers.
    /// 
    /// Algorithm: PBKDF2-SHA256
    /// Iterations: 100,000 (OWASP 2023 recommendation for SHA256)
    /// Salt size: 32 bytes (256 bits) — stored as base64 string
    /// Hash size: 32 bytes (256 bits) — stored as base64 string
    /// </summary>
    public static class PasswordHelper
    {
        // OWASP 2023 recommended minimum for PBKDF2-HMAC-SHA256
        private const int DefaultIterations = 100_000;
        private const int SaltSizeBytes = 32;   // 256 bits
        private const int HashSizeBytes = 32;   // 256 bits
        private const int HashOutputBase64Len = 44; // base64 encoded 32 bytes

        /// <summary>
        /// Generates a new cryptographically random salt.
        /// </summary>
        public static string GenerateSalt()
        {
            byte[] salt = RandomNumberGenerator.GetBytes(SaltSizeBytes);
            return Convert.ToBase64String(salt);
        }

        /// <summary>
        /// Computes PBKDF2-SHA256 hash of the given password with the given salt.
        /// Returns base64-encoded hash (44 chars).
        /// </summary>
        public static string ComputeHash(string password, string saltBase64, int iterations = DefaultIterations)
        {
            if (string.IsNullOrEmpty(password))
                throw new ArgumentException("Password cannot be null or empty.", nameof(password));
            if (string.IsNullOrEmpty(saltBase64))
                throw new ArgumentException("Salt cannot be null or empty.", nameof(saltBase64));

            byte[] salt = Convert.FromBase64String(saltBase64);

            using (var pbkdf2 = new Rfc2898DeriveBytes(
                password,
                salt,
                iterations,
                HashAlgorithmName.SHA256))
            {
                byte[] hash = pbkdf2.GetBytes(HashSizeBytes);
                return Convert.ToBase64String(hash);
            }
        }

        /// <summary>
        /// Verifies a password against a stored hash and salt.
        /// Constant-time comparison to prevent timing attacks.
        /// Returns true if the password matches.
        /// </summary>
        public static bool Verify(string password, string saltBase64, string storedHashBase64, int iterations = DefaultIterations)
        {
            if (string.IsNullOrEmpty(password) || string.IsNullOrEmpty(saltBase64) || string.IsNullOrEmpty(storedHashBase64))
                return false;

            string computedHash = ComputeHash(password, saltBase64, iterations);

            // Constant-time comparison to prevent timing attacks
            byte[] computed = Convert.FromBase64String(computedHash);
            byte[] stored = Convert.FromBase64String(storedHashBase64);

            if (computed.Length != stored.Length)
                return false;

            return CryptographicOperations.FixedTimeEquals(computed, stored);
        }

        /// <summary>
        /// Computes the SHA-256 legacy hash used in Phase 1.
        /// Format: SHA256(password + 'IntegratedAccSysSalt_v1_' + braCode + '_' + userCode)
        /// Used only for backward-compatible migration from the Phase 1 SHA-256 implementation.
        /// Returns lowercase hex string (64 chars).
        /// </summary>
        public static string ComputeLegacySha256(string password, int braCode, int userCode)
        {
            if (string.IsNullOrEmpty(password))
                throw new ArgumentException("Password cannot be null or empty.", nameof(password));

            string salt = $"IntegratedAccSysSalt_v1_{braCode}_{userCode}";
            byte[] passwordBytes = Encoding.Unicode.GetBytes(password + salt);
            byte[] hash = SHA256.Create().ComputeHash(passwordBytes);
            return BitConverter.ToString(hash).Replace("-", "").ToLowerInvariant();
        }

        /// <summary>
        /// Verifies a password against the legacy Phase 1 SHA-256 hash.
        /// </summary>
        public static bool VerifyLegacySha256(string password, int braCode, int userCode, string legacyHashHex)
        {
            if (string.IsNullOrEmpty(password) || string.IsNullOrEmpty(legacyHashHex))
                return false;

            string computed = ComputeLegacySha256(password, braCode, userCode);
            return string.Equals(computed, legacyHashHex, StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// Creates a new PasswordMigrationRecord with a fresh salt and PBKDF2 hash.
        /// </summary>
        public static PasswordMigrationRecord CreatePasswordRecord(string password)
        {
            string salt = GenerateSalt();
            string hash = ComputeHash(password, salt, DefaultIterations);
            return new PasswordMigrationRecord
            {
                Salt = salt,
                Hash = hash,
                Algorithm = "PBKDF2-SHA256",
                Iterations = DefaultIterations
            };
        }

        /// <summary>
        /// Gets the recommended iteration count.
        /// </summary>
        public static int RecommendedIterations => DefaultIterations;
    }

    /// <summary>
    /// Record returned by CreatePasswordRecord.
    /// </summary>
    public class PasswordMigrationRecord
    {
        public required string Salt { get; set; }
        public required string Hash { get; set; }
        public required string Algorithm { get; set; }
        public int Iterations { get; set; }
    }
}
