using System;
using System.Data;
using System.Data.SqlClient;

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
        /// Checks whether the current user has print privilege for a given windowID.
        /// Returns false if no privilege row exists (default-deny).
        /// </summary>
        /// <param name="windowID">The windowID from tblWindows</param>
        /// <returns>true if print is allowed, false otherwise</returns>
        public static bool HasPrintPrivilege(int windowID)
        {
            try
            {
                int userCode = GetCurrentUserCode();
                int braCode = Program.braCode;

                SqlParameter[] para = new SqlParameter[3];
                para[0] = new SqlParameter("@userCode", userCode);
                para[1] = new SqlParameter("@windowID", windowID);
                para[2] = new SqlParameter("@braCode", braCode);

                DAL.clsCN cn = new DAL.clsCN();
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
        /// Checks whether the current user has display privilege for a given windowID.
        /// Returns false if no privilege row exists (default-deny).
        /// </summary>
        /// <param name="windowID">The windowID from tblWindows</param>
        /// <returns>true if display is allowed, false otherwise</returns>
        public static bool HasDisplayPrivilege(int windowID)
        {
            try
            {
                int userCode = GetCurrentUserCode();
                int braCode = Program.braCode;

                SqlParameter[] para = new SqlParameter[3];
                para[0] = new SqlParameter("@userCode", userCode);
                para[1] = new SqlParameter("@windowID", windowID);
                para[2] = new SqlParameter("@braCode", braCode);

                DAL.clsCN cn = new DAL.clsCN();
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

        private static int GetCurrentUserCode()
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[1];
            para[0] = new SqlParameter("@userID", Program.userName);
            DataTable dt = cn.SelectData("getUserNo", para);
            if (dt.Rows.Count == 0)
                throw new InvalidOperationException($"User '{Program.userName}' not found.");
            return Convert.ToInt32(dt.Rows[0][0]);
        }
    }
}