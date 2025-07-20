using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static System.Runtime.CompilerServices.RuntimeHelpers;

namespace IntegratedAccSys.BL.Users
{
    internal class clsUsers
    {
        #region login
        public DataTable Login(int braCode, string userID, string PWD)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[3];
            para[0] = new SqlParameter("@braCode", SqlDbType.Int);
            para[0].Value = braCode;
            para[1] = new SqlParameter("@userID", SqlDbType.NVarChar, 15);
            para[1].Value = userID;
            para[2] = new SqlParameter("@PWD", SqlDbType.NVarChar, 500);
            para[2].Value = PWD;
            dt = cn.SelectData("userLogin", para);
            return dt;

        }
        #endregion

        #region Users
        //function to get All Users Data in determine Branch
        public DataTable getAllUsers(int braCode)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.clsCN cu = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[1];
            para[0] = new SqlParameter("@braCode", SqlDbType.Int);
            para[0].Value = braCode;
            dt = cu.SelectData("getAllusers", para);
            return dt;
        }

        // function to generate New number for user
        public DataTable getUserNewNo()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.clsCN cn = new DAL.clsCN();
            dt = cn.SelectData("getUserNewNo", null);
            return dt;
        }

        //function  to add data into Users Table
        public void addUser(int userCode, string userFName, string userID, string PWD, string userMobile, string userEmail, byte[] userImg, int braCode, string testImage)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[9];
            para[0] = new SqlParameter("@userCode", SqlDbType.Int);
            para[0].Value = userCode;
            para[1] = new SqlParameter("@userFName", SqlDbType.NVarChar, 50);
            para[1].Value = userFName;
            para[2] = new SqlParameter("@userID", SqlDbType.NVarChar, 15);
            para[2].Value = userID;
            para[3] = new SqlParameter("@PWD", SqlDbType.NVarChar, 500);
            para[3].Value = PWD;
            para[4] = new SqlParameter("@userMobile", SqlDbType.NVarChar, 25);
            para[4].Value = userMobile;
            para[5] = new SqlParameter("@userEmail", SqlDbType.NVarChar, 50);
            para[5].Value = userEmail;
            para[6] = new SqlParameter("@userImg", SqlDbType.Image);
            para[6].Value = userImg;
            para[7] = new SqlParameter("@braCode", SqlDbType.Int);
            para[7].Value = braCode;
            para[8] = new SqlParameter("@testImage", SqlDbType.NVarChar, 15);
            para[8].Value = testImage;
            cn.ExecuteCmd("addUser", para);

        }

        //function  to update data in Users Table
        public void updateUser(int userCode, string userFName, string userID, string PWD, string userMobile, string userEmail, byte[] userImg, int braCode, string testImage)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[9];
            para[0] = new SqlParameter("@userCode", SqlDbType.Int);
            para[0].Value = userCode;
            para[1] = new SqlParameter("@userFName", SqlDbType.NVarChar, 50);
            para[1].Value = userFName;
            para[2] = new SqlParameter("@userID", SqlDbType.NVarChar, 15);
            para[2].Value = userID;
            para[3] = new SqlParameter("@PWD", SqlDbType.NVarChar, 500);
            para[3].Value = PWD;
            para[4] = new SqlParameter("@userMobile", SqlDbType.NVarChar, 25);
            para[4].Value = userMobile;
            para[5] = new SqlParameter("@userEmail", SqlDbType.NVarChar, 50);
            para[5].Value = userEmail;
            para[6] = new SqlParameter("@userImg", SqlDbType.Image);
            para[6].Value = userImg;
            para[7] = new SqlParameter("@braCode", SqlDbType.Int);
            para[7].Value = braCode;
            para[8] = new SqlParameter("@testImage", SqlDbType.NVarChar, 15);
            para[8].Value = testImage;
            cn.ExecuteCmd("updateUser", para);

        }

        //function to delete user 
        public void delUser(int userCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[1];
            para[0] = new SqlParameter("@userCode", SqlDbType.Int);
            para[0].Value = userCode;
            cn.ExecuteCmd("delUser", para);
        }

        public DataTable getUserNo(string userID)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[1];
            para[0] = new SqlParameter("@userID", SqlDbType.NVarChar, 15);
            para[0].Value = userID;
            dt = cn.SelectData("getUserNo", para);
            return dt;
        }
        #endregion

        #region Privilleges

        // add privileges
        public void addPrivillages(int userCode, int braCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                    new SqlParameter("@userCode", userCode ),
                    new SqlParameter("@braCode",braCode )
            };
            cn.ExecuteCmd("addPrivillages", para);
        }

        // Edit privileges
        public void editPrivillages(int userCode, int windowID, bool privNew, bool privAdd, bool privEdit, bool privDel, bool privPrint, bool privDisplay, int braCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter("@userCode", userCode ),
                new SqlParameter("@windowID", windowID) ,
                new SqlParameter("@privNew", privNew ),
                new SqlParameter("@privAdd", privAdd ),
                new SqlParameter("@privEdit",privEdit ),
                new SqlParameter("@privDel", privDel ),
                new SqlParameter("@privPrint", privPrint ),
                new SqlParameter("@privDisplay", privDisplay),
                new SqlParameter("@braCode",braCode )
            };

            cn.ExecuteCmd("editPrivillages", para);

        }

        // Delete privileges
        public void delPrivellages(int userCode, int braCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                    new SqlParameter("@userCode", userCode ),
                    new SqlParameter("@braCode",braCode )
            };

            cn.ExecuteCmd("delPrivellages", para);
        }


        // get all users No an  Name
        public DataTable getAllBraUsers(int braCode)
        {

            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                 new SqlParameter("@braCode",braCode )
            };
            return cn.SelectData("getAllBraUsers", para);
        }


        // Get all  lists
        public DataTable getAllLists()
        {
            DAL.clsCN cn = new DAL.clsCN();
            return cn.SelectData("getAllLists", null);
        }

        public DataTable getAllPrivillages(int userCode, int braCode, int listID)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                    new SqlParameter("@userCode", userCode ),
                    new SqlParameter("@listID",listID ),
                    new SqlParameter("@braCode", braCode )
            };
            return cn.SelectData("getAllPrivillages", para);
        }

        // Edit privileges
        public void editPrivilege(int userCode, int WindowsID, bool privNew, bool privAdd, bool privEdit, bool privDel,bool privPrint, bool privDisplay, int braCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {      
                new SqlParameter("@userCode", userCode ),
                new SqlParameter("@windowID",WindowsID ),
                new SqlParameter("@privNew",  privNew ),
                new SqlParameter("@privAdd", privAdd ),
                new SqlParameter("@privEdit",  privEdit),
                new SqlParameter("@privDel", privDel ),
                new SqlParameter("@privDisplay",privDisplay ),
                new SqlParameter("@privPrint",privPrint ),
                new SqlParameter("@braCode",  braCode ),
            };
            cn.ExecuteCmd("editPrivillages", para);
           
        }

        // get Screens Display privileges
        public DataTable getDisplayPrivillages(int userCode, int braCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter("@userCode", userCode ),
                new SqlParameter("@braCode",  braCode ),
            };
            return cn.SelectData("getDisplayPrivillages", para);
        }

        // get Screens privileges
        public DataTable getScreensPrivillages(int userCode, int WindowsID,int braCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter("@userCode", userCode ),
                new SqlParameter("@windowID",WindowsID ),
                new SqlParameter("@braCode",  braCode )
            };
            return cn.SelectData("getScreensPrivillages", para);

        }

        public void ApplyPrivileges(Form form, int windowID)
        {
            int userCode = Convert.ToInt32(getUserNo(Program.userName).Rows[0][0]);
            int braCode = Program.braCode;

            DataTable dt = getScreensPrivillages(userCode, windowID, braCode);
            if (dt.Rows.Count == 0) return;

            DataRow row = dt.Rows[0];

            // ابحث عن الأزرار حسب اسمها
            Control[] controls = form.Controls.Find("btnNew", true);
            if (controls.Length > 0)
                controls[0].Enabled = row["privNew"] != DBNull.Value && (bool)row["privNew"];

            controls = form.Controls.Find("btnAdd", true);
            if (controls.Length > 0)
                controls[0].Enabled = row["privAdd"] != DBNull.Value && (bool)row["privAdd"];

            controls = form.Controls.Find("btnEdit", true);
            if (controls.Length > 0)
                controls[0].Enabled = row["privEdit"] != DBNull.Value && (bool)row["privEdit"];

            controls = form.Controls.Find("btnDel", true);
            if (controls.Length > 0)
                controls[0].Enabled = row["privDel"] != DBNull.Value && (bool)row["privDel"];

            controls = form.Controls.Find("btnPrint", true);
            if (controls.Length > 0)
                controls[0].Enabled = row["privPrint"] != DBNull.Value && (bool)row["privPrint"];
        }


        #endregion


    }
}

