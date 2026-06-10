using System;
using System.Data;
using Npgsql;
using NpgsqlTypes;
namespace IntegratedAccSys.BL.Security
{
    /// <summary>
    /// Token-based session management.
    /// Stores the active session token in static fields — survives as long as the app domain runs.
    /// Does NOT replace Program.userName or Program.braCode — maintains them for backward compatibility.
    ///
    /// Session flow:
    /// 1. Login success → createSession (DB) → store token in SessionContext
    /// 2. Entry-point validation (frmMainWindow Load) → validateSession (DB)
    /// 3. Periodic activity → updateSessionActivity (DB, sliding 1h expiry)
    /// 4. Logout / app exit → endSession (DB)
    /// </summary>
    public static class SessionContext
    {
        // ─── Static session state ───────────────────────────────────────────
        // These persist for the lifetime of the application domain.
        // They are set on successful login and cleared on logout/app exit.

        private static Guid? _sessionToken = null;
        private static int? _sessionUserCode = null;
        private static string? _sessionUserID = null;
        private static int? _sessionBraCode = null;

        /// <summary>Current session token. Null if no active session.</summary>
        public static Guid? SessionToken => _sessionToken;

        /// <summary>True if a valid active session exists.</summary>
        public static bool IsActive => _sessionToken.HasValue;

        /// <summary>User code of the current session's user.</summary>
        public static int? SessionUserCode => _sessionUserCode;

        /// <summary>User ID of the current session's user.</summary>
        public static string? SessionUserID => _sessionUserID;

        /// <summary>Branch code of the current session.</summary>
        public static int? SessionBraCode => _sessionBraCode;

        // ─── Create session (called after successful login) ─────────────────

        /// <summary>
        /// Creates a new session in the database and stores the token locally.
        /// Called from frmLogin after successful authentication.
        /// </summary>
        public static bool Create(int userCode, string userID, int braCode)
        {
            try
            {
                DAL.ClsCN cn = new DAL.ClsCN();

                NpgsqlParameter[] inPara = new NpgsqlParameter[4];
                inPara[0] = new NpgsqlParameter("@userCode", userCode);
                inPara[1] = new NpgsqlParameter("@userID", userID);
                inPara[2] = new NpgsqlParameter("@braCode", braCode);
                inPara[3] = new NpgsqlParameter("@machineName", Environment.MachineName);

                NpgsqlParameter outPara = new NpgsqlParameter("@sessionToken", NpgsqlDbType.Uuid);
                outPara.Direction = ParameterDirection.Output;

                NpgsqlParameter[] allPara = new NpgsqlParameter[5];
                Array.Copy(inPara, allPara, 4);
                allPara[4] = outPara;

                cn.ExecuteCmd("createSession", allPara);

                if (outPara.Value != null && outPara.Value != DBNull.Value)
                {
                    _sessionToken = (Guid)outPara.Value;
                    _sessionUserCode = userCode;
                    _sessionUserID = userID;
                    _sessionBraCode = braCode;

                    AuditHelper.LogSessionCreated(userCode, userID, braCode);
                    return true;
                }
                return false;
            }
            catch
            {
                // Session creation failure must NOT break login.
                // The user is already authenticated — best effort.
                return false;
            }
        }

        // ─── Validate session (called at entry points) ─────────────────────

        /// <summary>
        /// Validates the current session token against the database.
        /// Returns true if the session is valid and active; false otherwise.
        /// On false, the session context is cleared.
        /// </summary>
        public static bool Validate()
        {
            if (!_sessionToken.HasValue)
                return false;

            try
            {
                DAL.ClsCN cn = new DAL.ClsCN();
                NpgsqlParameter[] para = new NpgsqlParameter[1];
                para[0] = new NpgsqlParameter("@sessionToken", _sessionToken.Value);

                DataTable dt = cn.SelectData("validateSession", para);

                if (dt.Rows.Count == 0)
                {
                    Clear();
                    AuditHelper.LogSessionInvalid(_sessionUserCode ?? 0, _sessionUserID ?? "", _sessionBraCode ?? 0);
                    return false;
                }

                // Update sliding expiration on activity
                UpdateActivity();
                return true;
            }
            catch
            {
                return false;
            }
        }

        // ─── Update activity (sliding window) ──────────────────────────────

        /// <summary>
        /// Updates lastActivityAt and extends expiresAt by 1 hour.
        /// Called on each Validate() success or periodically from active forms.
        /// </summary>
        public static void UpdateActivity()
        {
            if (!_sessionToken.HasValue)
                return;

            try
            {
                DAL.ClsCN cn = new DAL.ClsCN();
                NpgsqlParameter[] para = new NpgsqlParameter[1];
                para[0] = new NpgsqlParameter("@sessionToken", _sessionToken.Value);
                cn.ExecuteCmd("updateSessionActivity", para);
            }
            catch
            {
                // Best effort — never block business code
            }
        }

        // ─── End session ─────────────────────────────────────────────────────

        /// <summary>
        /// Ends the current session in the database and clears local state.
        /// Called on logout or application exit.
        /// </summary>
        public static void End()
        {
            if (!_sessionToken.HasValue)
                return;

            try
            {
                DAL.ClsCN cn = new DAL.ClsCN();
                NpgsqlParameter[] para = new NpgsqlParameter[1];
                para[0] = new NpgsqlParameter("@sessionToken", _sessionToken.Value);
                cn.ExecuteCmd("endSession", para);
            }
            catch
            {
                // Best effort
            }

            int? uc = _sessionUserCode;
            string? uid = _sessionUserID;
            int? bc = _sessionBraCode;

            Clear();

            if (uc.HasValue)
                AuditHelper.LogSessionEnded(uc.Value, uid ?? "", bc ?? 0);
        }

        // ─── Expire old sessions (scheduled/cleanup) ───────────────────────

        /// <summary>
        /// Expires all sessions that have passed their expiry time.
        /// Can be called on app startup or on a schedule.
        /// </summary>
        public static void ExpireOldSessions()
        {
            try
            {
                DAL.ClsCN cn = new DAL.ClsCN();
                cn.ExecuteCmd("expireOldSessions", null);
            }
            catch
            {
                // Best effort
            }
        }

        // ─── Clear local state ───────────────────────────────────────────────

        private static void Clear()
        {
            _sessionToken = null;
            _sessionUserCode = null;
            _sessionUserID = null;
            _sessionBraCode = null;
        }
    }
}
