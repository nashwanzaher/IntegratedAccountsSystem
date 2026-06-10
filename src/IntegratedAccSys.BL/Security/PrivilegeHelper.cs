using System;
using System.Data;
using Npgsql;
using NpgsqlTypes;
using IntegratedAccSys.BL.Users;

namespace IntegratedAccSys.BL.Security
{
    /// <summary>
    /// Shared helper for checking screen-level privileges.
    /// Used when the standard ApplyPrivileges pattern needs to be applied
    /// at form-open time or per-button rather than per-control.
    ///
    /// Default-deny: if no privilege row exists, access is denied.
    /// Consistent with Phase 4 ApplyPrivileges fix.
    /// </summary>
    public static class PrivilegeHelper
    {
        /// <summary>
        /// Checks whether the given user has print privilege for a given windowID.
        /// Returns false if no privilege row exists (default-deny).
        /// </summary>
        public static bool HasPrintPrivilege(string userID, int braCode, int windowID)
        {
            try
            {
                int userCode = ResolveUserCode(userID, braCode);

                NpgsqlParameter[] para = new NpgsqlParameter[3];
                para[0] = new NpgsqlParameter("@userCode", userCode);
                para[1] = new NpgsqlParameter("@windowID", windowID);
                para[2] = new NpgsqlParameter("@braCode", braCode);

                DAL.ClsCN cn = new DAL.ClsCN();
                DataTable dt = cn.SelectData("getScreensPrivillages", para);

                if (dt.Rows.Count == 0)
                    return false;

                DataRow row = dt.Rows[0];
                return row["privPrint"] != DBNull.Value && (bool)row["privPrint"];
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Checks whether the given user has display privilege for a given windowID.
        /// Returns false if no privilege row exists (default-deny).
        /// </summary>
        public static bool HasDisplayPrivilege(string userID, int braCode, int windowID)
        {
            try
            {
                int userCode = ResolveUserCode(userID, braCode);

                NpgsqlParameter[] para = new NpgsqlParameter[3];
                para[0] = new NpgsqlParameter("@userCode", userCode);
                para[1] = new NpgsqlParameter("@windowID", windowID);
                para[2] = new NpgsqlParameter("@braCode", braCode);

                DAL.ClsCN cn = new DAL.ClsCN();
                DataTable dt = cn.SelectData("getScreensPrivillages", para);

                if (dt.Rows.Count == 0)
                    return false;

                DataRow row = dt.Rows[0];
                return row["privDisplay"] != DBNull.Value && (bool)row["privDisplay"];
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Resolves a userID to a userCode via the database.
        /// </summary>
        private static int ResolveUserCode(string userID, int braCode)
        {
            ClsUsers users = new ClsUsers();
            DataTable dt = users.getUserNo(userID, braCode);
            if (dt.Rows.Count == 0)
                throw new InvalidOperationException($"User '{userID}' not found in branch {braCode}.");
            return Convert.ToInt32(dt.Rows[0][0]);
        }
    }
}
