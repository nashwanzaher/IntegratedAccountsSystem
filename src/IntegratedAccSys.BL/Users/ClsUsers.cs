using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IntegratedAccSys.BL.Security;
using Npgsql;
using NpgsqlTypes;

namespace IntegratedAccSys.BL.Users
{
    public class ClsUsers
    {
        #region login

        /// <summary>
        /// Authenticates a user with 3-tier verification:
        /// 1. PBKDF2-SHA256 (new salted format) — if PasswordHash is set
        /// 2. Legacy SHA-256 hash (Phase 1) — if PWDHash is set
        /// 3. Legacy plaintext — if only PWD is set
        ///
        /// On successful tier-2 or tier-3 authentication, the user's password is
        /// immediately upgraded to PBKDF2-SHA256 (tier 1).
        /// </summary>
        /// <returns>DataTable with user row if authenticated, empty DataTable if failed.</returns>
        public DataTable Login(int braCode, string userID, string PWD)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.ClsCN cn = new DAL.ClsCN();

            NpgsqlParameter[] selectParams = new NpgsqlParameter[2];
            selectParams[0] = new NpgsqlParameter("@userID", NpgsqlDbType.Varchar, 15);
            selectParams[0].Value = userID;
            selectParams[1] = new NpgsqlParameter("@braCode", NpgsqlDbType.Integer);
            selectParams[1].Value = braCode;

            // Use getUserForLogin which returns all security columns in one trip
            DataTable userRow = cn.SelectData("getUserForLogin", selectParams);

            if (userRow.Rows.Count == 0)
            {
                // User not found — log as failed attempt
                AuditHelper.LogLoginFailure(userID, braCode, "User not found");
                return dt;
            }

            DataRow user = userRow.Rows[0];
            int userCode = Convert.ToInt32(user["userCode"]);

            bool authenticated = false;
            bool needsUpgrade = false;

            // ─── TIER 1: PBKDF2-SHA256 (new format) ─────────────────────────────────
            if (user["PasswordHash"] != DBNull.Value &&
                !string.IsNullOrEmpty(Convert.ToString(user["PasswordHash"])))
            {
                string salt = Convert.ToString(user["PasswordSalt"]) ?? "";
                string storedHash = Convert.ToString(user["PasswordHash"]) ?? "";
                int iterations = user["PasswordIterations"] != DBNull.Value
                    ? Convert.ToInt32(user["PasswordIterations"])
                    : PasswordHelper.RecommendedIterations;

                if (PasswordHelper.Verify(PWD, salt, storedHash, iterations))
                {
                    authenticated = true;
                    // No upgrade needed — already PBKDF2
                }
            }

            // ─── TIER 2: Legacy SHA-256 hash (Phase 1 migration) ───────────────────
            else if (user["PWDHash"] != DBNull.Value &&
                     !string.IsNullOrEmpty(Convert.ToString(user["PWDHash"])))
            {
                string legacyHashHex = Convert.ToString(user["PWDHash"]) ?? "";
                if (PasswordHelper.VerifyLegacySha256(PWD, braCode, userCode, legacyHashHex))
                {
                    authenticated = true;
                    needsUpgrade = true; // Upgrade to PBKDF2 after successful login
                }
            }

            // ─── TIER 3: Plaintext fallback (original — pre-migration) ─────────────
            // ⚠️ SECURITY WARNING: Plaintext password detected - indicates legacy user
            else if (user["PWD"] != DBNull.Value)
            {
                string storedPWD = Convert.ToString(user["PWD"]) ?? "";
                if (storedPWD == PWD)
                {
                    authenticated = true;
                    needsUpgrade = true; // Upgrade to PBKDF2 after successful login

                    // ⚠️ SECURITY: Log plaintext authentication detection
                    // This indicates a legacy account that should be migrated
                    AuditHelper.LogSecurityWarning(
                        userCode,
                        userID,
                        "Plaintext password authentication - user requires password migration"
                    );
                }
            }

            if (!authenticated)
            {
                AuditHelper.LogLoginFailure(userID, braCode, "Invalid password");
                return dt; // Failed — return empty
            }

            // ─── PASSWORD UPGRADE ───────────────────────────────────────────────────
            if (needsUpgrade)
            {
                UpgradePassword(userCode, PWD);
            }

            // ─── SUCCESS: log before returning ─────────────────────────────────────
            AuditHelper.LogLoginSuccess(userCode, userID, braCode);

            // Return full user row so the caller gets userCode/userFName/etc.
            return userRow;
        }

        /// <summary>
        /// Upgrades a user's password to PBKDF2-SHA256.
        /// Called automatically after a successful tier-2 or tier-3 login.
        /// </summary>
        private void UpgradePassword(int userCode, string plainPWD)
        {
            try
            {
                var record = PasswordHelper.CreatePasswordRecord(plainPWD);

                DAL.ClsCN cn = new DAL.ClsCN();
                NpgsqlParameter[] para = new NpgsqlParameter[6];
                para[0] = new NpgsqlParameter("@userCode", NpgsqlDbType.Integer);
                para[0].Value = userCode;
                para[1] = new NpgsqlParameter("@PasswordSalt", NpgsqlDbType.Varchar, 128);
                para[1].Value = record.Salt;
                para[2] = new NpgsqlParameter("@PasswordHash", NpgsqlDbType.Varchar, 256);
                para[2].Value = record.Hash;
                para[3] = new NpgsqlParameter("@PasswordAlgorithm", NpgsqlDbType.Varchar, 20);
                para[3].Value = record.Algorithm;
                para[4] = new NpgsqlParameter("@PasswordIterations", NpgsqlDbType.Integer);
                para[4].Value = record.Iterations;
                para[5] = new NpgsqlParameter("@PWD", NpgsqlDbType.Varchar, 500);
                para[5].Value = plainPWD; // Keep PWD column for rollback

                cn.ExecuteCmd("upgradeUserPassword", para);
            }
            catch
            {
                // Upgrade failure must NOT break the login flow.
                // Authentication already succeeded — this is a best-effort upgrade.
                // Log internally if a logger were available.
            }
        }

        #endregion

        #region Users

        //function to get All Users Data in determine Branch
        public DataTable getAllUsers(int braCode)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.ClsCN cu = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[1];
            para[0] = new NpgsqlParameter("@braCode", NpgsqlDbType.Integer);
            para[0].Value = braCode;
            dt = cu.SelectData("getAllusers", para);
            return dt;
        }

        // function to generate New number for user
        public DataTable getUserNewNo()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.ClsCN cn = new DAL.ClsCN();
            dt = cn.SelectData("getUserNewNo", null);
            return dt;
        }

        //function  to add data into Users Table
        public void addUser(int userCode, string userFName, string userID, string PWD, string userMobile, string userEmail, byte[] userImg, int braCode, string testImage)
        {
            // Create PBKDF2 password record at creation time
            var record = PasswordHelper.CreatePasswordRecord(PWD);

            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[12];
            para[0] = new NpgsqlParameter("@userCode", NpgsqlDbType.Integer);
            para[0].Value = userCode;
            para[1] = new NpgsqlParameter("@userFName", NpgsqlDbType.Varchar, 50);
            para[1].Value = userFName;
            para[2] = new NpgsqlParameter("@userID", NpgsqlDbType.Varchar, 15);
            para[2].Value = userID;
            para[3] = new NpgsqlParameter("@PWD", NpgsqlDbType.Varchar, 500);
            para[3].Value = PWD; // Keep plaintext for rollback compatibility
            para[4] = new NpgsqlParameter("@userMobile", NpgsqlDbType.Varchar, 25);
            para[4].Value = userMobile;
            para[5] = new NpgsqlParameter("@userEmail", NpgsqlDbType.Varchar, 50);
            para[5].Value = userEmail;
            para[6] = new NpgsqlParameter("@userImg", NpgsqlDbType.Bytea);
            para[6].Value = userImg;
            para[7] = new NpgsqlParameter("@braCode", NpgsqlDbType.Integer);
            para[7].Value = braCode;
            para[8] = new NpgsqlParameter("@testImage", NpgsqlDbType.Varchar, 15);
            para[8].Value = testImage;
            // New PBKDF2 fields
            para[9] = new NpgsqlParameter("@PasswordSalt", NpgsqlDbType.Varchar, 128);
            para[9].Value = record.Salt;
            para[10] = new NpgsqlParameter("@PasswordHash", NpgsqlDbType.Varchar, 256);
            para[10].Value = record.Hash;
            para[11] = new NpgsqlParameter("@PasswordAlgorithm", NpgsqlDbType.Varchar, 20);
            para[11].Value = record.Algorithm;
            // Note: PasswordIterations stored in DB default, stored in record.Iterations
            cn.ExecuteCmd("addUser", para);

            // Audit: user creation
            AuditHelper.LogUserCreated(userCode, userID, braCode);
        }

        //function  to update data in Users Table
        public void updateUser(int userCode, string userFName, string userID, string PWD, string userMobile, string userEmail, byte[] userImg, int braCode, string testImage)
        {
            // Always regenerate PBKDF2 hash on password change
            var record = PasswordHelper.CreatePasswordRecord(PWD);

            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[12];
            para[0] = new NpgsqlParameter("@userCode", NpgsqlDbType.Integer);
            para[0].Value = userCode;
            para[1] = new NpgsqlParameter("@userFName", NpgsqlDbType.Varchar, 50);
            para[1].Value = userFName;
            para[2] = new NpgsqlParameter("@userID", NpgsqlDbType.Varchar, 15);
            para[2].Value = userID;
            para[3] = new NpgsqlParameter("@PWD", NpgsqlDbType.Varchar, 500);
            para[3].Value = PWD; // Keep plaintext for rollback
            para[4] = new NpgsqlParameter("@userMobile", NpgsqlDbType.Varchar, 25);
            para[4].Value = userMobile;
            para[5] = new NpgsqlParameter("@userEmail", NpgsqlDbType.Varchar, 50);
            para[5].Value = userEmail;
            para[6] = new NpgsqlParameter("@userImg", NpgsqlDbType.Bytea);
            para[6].Value = userImg;
            para[7] = new NpgsqlParameter("@braCode", NpgsqlDbType.Integer);
            para[7].Value = braCode;
            para[8] = new NpgsqlParameter("@testImage", NpgsqlDbType.Varchar, 15);
            para[8].Value = testImage;
            // New PBKDF2 fields
            para[9] = new NpgsqlParameter("@PasswordSalt", NpgsqlDbType.Varchar, 128);
            para[9].Value = record.Salt;
            para[10] = new NpgsqlParameter("@PasswordHash", NpgsqlDbType.Varchar, 256);
            para[10].Value = record.Hash;
            para[11] = new NpgsqlParameter("@PasswordAlgorithm", NpgsqlDbType.Varchar, 20);
            para[11].Value = record.Algorithm;
            cn.ExecuteCmd("updateUser", para);

            // Audit: user update
            AuditHelper.LogUserUpdated(userCode, userID, braCode);
        }

        //function to delete user
        public void delUser(int userCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[1];
            para[0] = new NpgsqlParameter("@userCode", NpgsqlDbType.Integer);
            para[0].Value = userCode;
            cn.ExecuteCmd("delUser", para);
        }

        public DataTable getUserNo(string userID)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[1];
            para[0] = new NpgsqlParameter("@userID", NpgsqlDbType.Varchar, 15);
            para[0].Value = userID;
            dt = cn.SelectData("getUserNo", para);
            return dt;
        }

        // Overload: getUserNo with braCode for precise lookup
        public DataTable getUserNo(string userID, int braCode)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[2];
            para[0] = new NpgsqlParameter("@userID", NpgsqlDbType.Varchar, 15);
            para[0].Value = userID;
            para[1] = new NpgsqlParameter("@braCode", NpgsqlDbType.Integer);
            para[1].Value = braCode;
            dt = cn.SelectData("getUserNo", para);
            return dt;
        }

        #endregion

        #region Privilleges

        // add privileges
        public void addPrivillages(int userCode, int braCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                    new NpgsqlParameter("@userCode", userCode ),
                    new NpgsqlParameter("@braCode",braCode )
            };
            cn.ExecuteCmd("addPrivillages", para);
        }

        // Edit privileges
        public void editPrivillages(int userCode, int windowID, bool privNew, bool privAdd, bool privEdit, bool privDel, bool privPrint, bool privDisplay, int braCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter("@userCode", userCode ),
                new NpgsqlParameter("@windowID", windowID) ,
                new NpgsqlParameter("@privNew", privNew ),
                new NpgsqlParameter("@privAdd", privAdd ),
                new NpgsqlParameter("@privEdit",privEdit ),
                new NpgsqlParameter("@privDel", privDel ),
                new NpgsqlParameter("@privPrint", privPrint ),
                new NpgsqlParameter("@privDisplay", privDisplay),
                new NpgsqlParameter("@braCode",braCode )
            };

            cn.ExecuteCmd("editPrivillages", para);

        }

        // Delete privileges
        public void delPrivellages(int userCode, int braCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                    new NpgsqlParameter("@userCode", userCode ),
                    new NpgsqlParameter("@braCode",braCode )
            };

            cn.ExecuteCmd("delPrivellages", para);
        }


        // get all users No an  Name
        public DataTable getAllBraUsers(int braCode)
        {


            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                 new NpgsqlParameter("@braCode",braCode )
            };
            return cn.SelectData("getAllBraUsers", para);
        }


        // Get all  lists
        public DataTable getAllLists()
        {

            DAL.ClsCN cn = new DAL.ClsCN();
            return cn.SelectData("getAllLists", null);
        }

        public DataTable getAllPrivillages(int userCode, int braCode, int listID)
        {


            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                    new NpgsqlParameter("@userCode", userCode ),
                    new NpgsqlParameter("@listID",listID ),
                    new NpgsqlParameter("@braCode", braCode )
            };
            return cn.SelectData("getAllPrivillages", para);
        }

        // Edit privileges
        public void editPrivilege(int userCode, int WindowsID, bool privNew, bool privAdd, bool privEdit, bool privDel, bool privPrint, bool privDisplay, int braCode)
        {


            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter("@userCode", userCode ),
                new NpgsqlParameter("@windowID",WindowsID ),
                new NpgsqlParameter("@privNew",  privNew ),
                new NpgsqlParameter("@privAdd", privAdd ),
                new NpgsqlParameter("@privEdit",  privEdit),
                new NpgsqlParameter("@privDel", privDel ),
                new NpgsqlParameter("@privDisplay",privDisplay ),
                new NpgsqlParameter("@privPrint",privPrint ),
                new NpgsqlParameter("@braCode",  braCode ),
            };
            cn.ExecuteCmd("editPrivillages", para);

        }

        // get Screens Display privileges
        public DataTable getDisplayPrivillages(int userCode, int braCode)
        {


            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter("@userCode", userCode ),
                new NpgsqlParameter("@braCode",  braCode ),
            };
            return cn.SelectData("getDisplayPrivillages", para);
        }

        // get Screens privileges
        public DataTable getScreensPrivillages(int userCode, int WindowsID, int braCode)
        {


            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter("@userCode", userCode ),
                new NpgsqlParameter("@windowID",WindowsID ),
                new NpgsqlParameter("@braCode",  braCode )
            };
            return cn.SelectData("getScreensPrivillages", para);

        }




        #endregion


    }
}
