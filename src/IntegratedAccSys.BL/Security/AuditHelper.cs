using System;
using System.Threading.Tasks;
using System.Net;
using Npgsql;
using NpgsqlTypes;
using System.Text;

namespace IntegratedAccSys.BL.Security
{
    /// <summary>
    /// Fire-and-forget audit logger. All methods catch exceptions internally
    /// so logging failures never interrupt business operations.
    /// </summary>
    public static class AuditHelper
    {
        // ─── Event type constants ───────────────────────────────────────────
        public const string EventLoginSuccess = "LOGIN_SUCCESS";
        public const string EventLoginFailure = "LOGIN_FAILURE";
        public const string EventUserCreated = "USER_CREATED";
        public const string EventUserUpdated = "USER_UPDATED";
        public const string EventPasswordUpdated = "PASSWORD_UPDATED";
        public const string EventPrivilegeUpdated = "PRIVILEGE_UPDATED";
        public const string EventSessionCreated = "SESSION_CREATED";
        public const string EventSessionEnded = "SESSION_ENDED";
        public const string EventSessionExpired = "SESSION_EXPIRED";
        public const string EventSessionInvalid = "SESSION_INVALID";
        public const string EventSecurityWarning = "SECURITY_WARNING";

        // ─── Static machine name (captured once at startup) ─────────────────
        private static readonly string MachineName = Environment.MachineName;

        /// <summary>
        /// Logs an audit event asynchronously (fire-and-forget).
        /// Never throws — exceptions are swallowed internally.
        /// </summary>
        public static void Log(
            string? eventType,
            string? actionName,
            string? entityName = null,
            string? entityKey = null,
            string? newValue = null,
            bool success = true,
            string? errorMessage = null,
            int? userCode = null,
            string? userID = null,
            int? braCode = null,
            int? windowID = null,
            string? moduleName = null)
        {
            Task.Run(() => LogSync(
                eventType, actionName, entityName, entityKey,
                newValue, success, errorMessage,
                userCode, userID, braCode, windowID, moduleName));
        }

        public static void LogSync(
            string? eventType,
            string? actionName,
            string? entityName = null,
            string? entityKey = null,
            string? newValue = null,
            bool success = true,
            string? errorMessage = null,
            int? userCode = null,
            string? userID = null,
            int? braCode = null,
            int? windowID = null,
            string? moduleName = null)
        {
            try
            {
                DAL.ClsCN cn = new DAL.ClsCN();

                NpgsqlParameter[] para = new NpgsqlParameter[14];
                para[0] = new NpgsqlParameter("@eventType", (object?)eventType ?? DBNull.Value);
                para[1] = new NpgsqlParameter("@userCode", (object?)userCode ?? DBNull.Value);
                para[2] = new NpgsqlParameter("@userID", (object?)userID ?? DBNull.Value);
                para[3] = new NpgsqlParameter("@braCode", (object?)braCode ?? DBNull.Value);
                para[4] = new NpgsqlParameter("@windowID", (object?)windowID ?? DBNull.Value);
                para[5] = new NpgsqlParameter("@moduleName", (object?)moduleName ?? DBNull.Value);
                para[6] = new NpgsqlParameter("@actionName", (object?)actionName ?? DBNull.Value);
                para[7] = new NpgsqlParameter("@entityName", (object?)entityName ?? DBNull.Value);
                para[8] = new NpgsqlParameter("@entityKey", (object?)entityKey ?? DBNull.Value);
                para[9] = new NpgsqlParameter("@oldValue", DBNull.Value);
                para[10] = new NpgsqlParameter("@newValue", (object?)newValue ?? DBNull.Value);
                para[11] = new NpgsqlParameter("@success", success);
                para[12] = new NpgsqlParameter("@errorMessage", (object?)errorMessage ?? DBNull.Value);
                para[13] = new NpgsqlParameter("@machineName", MachineName);

                cn.ExecuteCmd("addAuditLog", para);
            }
            catch
            {
                // Swallow all exceptions — audit failure must never crash the business operation.
            }
        }

        public static void LogLoginSuccess(int userCode, string userID, int braCode)
        {
            Log(EventLoginSuccess, "Login", "User", userID,
                success: true, userCode: userCode, userID: userID, braCode: braCode);
        }

        public static void LogLoginFailure(string userID, int braCode, string reason)
        {
            Log(EventLoginFailure, "Login", "User", userID,
                success: false, errorMessage: reason,
                userID: userID, braCode: braCode);
        }

        public static void LogUserCreated(int userCode, string userID, int braCode)
        {
            Log(EventUserCreated, "AddUser", "User", userID,
                newValue: $"userCode={userCode}",
                success: true, userCode: userCode, userID: userID, braCode: braCode,
                moduleName: "frmUsers");
        }

        public static void LogUserUpdated(int userCode, string userID, int braCode)
        {
            Log(EventUserUpdated, "UpdateUser", "User", userID,
                newValue: $"userCode={userCode}",
                success: true, userCode: userCode, userID: userID, braCode: braCode,
                moduleName: "frmUsers");
        }

        public static void LogPasswordUpdated(int userCode, string userID, int braCode)
        {
            Log(EventPasswordUpdated, "PasswordUpdate", "User", userID,
                newValue: "[REDACTED]",
                success: true, userCode: userCode, userID: userID, braCode: braCode);
        }

        public static void LogPrivilegeUpdated(int userCode, string targetUserID, int braCode, int windowID)
        {
            Log(EventPrivilegeUpdated, "EditPrivilege", "Privilege",
                $"userCode={userCode}, windowID={windowID}",
                newValue: $"braCode={braCode}",
                success: true,
                userCode: userCode, braCode: braCode,
                windowID: windowID,
                moduleName: "frmPrivillages");
        }

        public static void LogBlockedReportAccess(int windowID, string formName)
        {
            Log("REPORT_ACCESS_DENIED", "OpenReport", "Report",
                $"windowID={windowID}",
                success: false,
                errorMessage: "Access denied — insufficient privilege",
                windowID: windowID,
                moduleName: formName);
        }

        public static void LogSessionCreated(int userCode, string userID, int braCode)
        {
            Log(EventSessionCreated, "CreateSession", "Session", userID,
                newValue: $"braCode={braCode}",
                success: true,
                userCode: userCode, userID: userID, braCode: braCode,
                moduleName: "frmLogin");
        }

        public static void LogSessionEnded(int userCode, string userID, int braCode)
        {
            Log(EventSessionEnded, "EndSession", "Session", userID,
                success: true,
                userCode: userCode, userID: userID, braCode: braCode,
                moduleName: "frmMainWindow");
        }

        public static void LogSessionExpired(int userCode, string userID, int braCode)
        {
            Log(EventSessionExpired, "SessionExpired", "Session", userID,
                success: false,
                errorMessage: "Session expired",
                userCode: userCode, userID: userID, braCode: braCode,
                moduleName: "SessionContext");
        }

        public static void LogSessionInvalid(int userCode, string userID, int braCode)
        {
            Log(EventSessionInvalid, "InvalidSession", "Session", userID,
                success: false,
                errorMessage: "Invalid or tampered session token",
                userCode: userCode, userID: userID, braCode: braCode,
                moduleName: "SessionContext");
        }

        /// <summary>
        /// ⚠️ SECURITY: Logs security warnings for plaintext password detection.
        /// This helps identify legacy accounts that need migration.
        /// </summary>
        public static void LogSecurityWarning(int userCode, string userID, string warningMessage)
        {
            Log(EventSecurityWarning, "SecurityWarning", "Security", userID,
                newValue: warningMessage,
                success: false,
                errorMessage: warningMessage,
                userCode: userCode, userID: userID,
                moduleName: "SecurityMonitor");
        }
    }
}
