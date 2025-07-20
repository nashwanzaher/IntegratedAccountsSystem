using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IntegratedAccSys.BL.SysFormat
{
    internal class clsSysFormat
    {
        #region Companies
        //function to get New branch Number
        public DataTable getNewBranchNo()
        {
            DataTable dt = new DataTable();
            DAL.clsCN cn=new DAL.clsCN();
            dt = cn.SelectData("getNewBranchNo",null);
            return dt;
        }

        // function to get  Branch data
        public DataTable getBranchData(int braCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter ("@braCode",braCode)
            };
            return cn.SelectData("getBranchData", para);
        }


        //function to get All Branches Data
        public DataTable getAllBranches()
        {
            DataTable dt = new DataTable();
            DAL.clsCN cn = new DAL.clsCN();
            dt = cn.SelectData("getAllBranches", null);
            return dt;
        }

        //function to insert Branch Data

        public void addCompany(int braCode,string braName,string braAddress,string braActivity,string braTel,string braFax,string braEmail,byte[] braLogo,string testImage)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[9];
            para[0] = new SqlParameter("@braCode",SqlDbType.Int);
            para[0].Value=braCode;
            para[1] = new SqlParameter("@braName", SqlDbType.NVarChar,120);
            para[1].Value = braName ;
            para[2] = new SqlParameter("@braAddress", SqlDbType.NVarChar, 200);
            para[2].Value = braAddress;
            para[3] = new SqlParameter("@braActivity", SqlDbType.NVarChar, 200);
            para[3].Value = braActivity;
            para[4] = new SqlParameter("@braTel", SqlDbType.NVarChar, 25);
            para[4].Value = braTel;
            para[5] = new SqlParameter("@braFax", SqlDbType.NVarChar, 25);
            para[5].Value = braFax;
            para[6] = new SqlParameter("@braEmail", SqlDbType.NVarChar, 60);
            para[6].Value = braEmail;
            para[7] = new SqlParameter("@braLogo", SqlDbType.Image);
            para[7].Value = braLogo;
            para[8] = new SqlParameter("@testImage", SqlDbType.NVarChar,10);
            para[8].Value = testImage;
            cn.ExecuteCmd("addCompany",para);
        }

        //function to Update Branch Data

        public void updateCompany(int braCode, string braName, string braAddress, string braActivity, string braTel, string braFax, string braEmail, byte[] braLogo, string testImage)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[9];
            para[0] = new SqlParameter("@braCode", SqlDbType.Int);
            para[0].Value = braCode;
            para[1] = new SqlParameter("@braName", SqlDbType.NVarChar, 120);
            para[1].Value = braName;
            para[2] = new SqlParameter("@braAddress", SqlDbType.NVarChar, 200);
            para[2].Value = braAddress;
            para[3] = new SqlParameter("@braActivity", SqlDbType.NVarChar, 200);
            para[3].Value = braActivity;
            para[4] = new SqlParameter("@braTel", SqlDbType.NVarChar, 25);
            para[4].Value = braTel;
            para[5] = new SqlParameter("@braFax", SqlDbType.NVarChar, 25);
            para[5].Value = braFax;
            para[6] = new SqlParameter("@braEmail", SqlDbType.NVarChar, 60);
            para[6].Value = braEmail;
            para[7] = new SqlParameter("@braLogo", SqlDbType.Image);
            para[7].Value = braLogo;
            para[8] = new SqlParameter("@testImage", SqlDbType.NVarChar, 10);
            para[8].Value = testImage;
            cn.ExecuteCmd("updateCompany", para);
        }

        public void delCompany(int braCode)
        {
            DAL.clsCN cn=new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[1];
            para[0] = new SqlParameter("@braCode", SqlDbType.Int);
            para[0].Value = braCode;
            cn.ExecuteCmd("delCompany",para);

        }
        #endregion

        #region Funds
        public DataTable getAllFunds()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.clsCN cn = new DAL.clsCN();
            dt=cn.SelectData("getAllFunds",null);
            return dt;
        }

        public DataTable getAccFundCode(string fundName)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para=new SqlParameter[1];
            para[0] = new SqlParameter("@fundName", SqlDbType.NVarChar, 50);
            para[0].Value = fundName;
            dt = cn.SelectData("getAccFundCode", para);
            return dt;
        }

        public void addFund(int fundCode,string fundName)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para=new SqlParameter[2];
            para[0] = new SqlParameter("@fundCode",SqlDbType.Int);
            para[0].Value = fundCode;
            para[1] = new SqlParameter("@fundName", SqlDbType.NVarChar,50);
            para[1].Value = fundName;
            cn.ExecuteCmd("addFund",para);
        }

        public void updateFund(int fundCode, string fundName)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[2];
            para[0] = new SqlParameter("@fundCode", SqlDbType.Int);
            para[0].Value = fundCode;
            para[1] = new SqlParameter("@fundName", SqlDbType.NVarChar, 50);
            para[1].Value = fundName;
            cn.ExecuteCmd("updateFund", para);
        }

        public void delFund(int fundCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[1];
            para[0] = new SqlParameter("@fundCode", SqlDbType.Int);
            para[0].Value = fundCode;
           
            cn.ExecuteCmd("delFund", para);
        }

        public DataTable getFundCode(string fundName)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[] 
            { 
              new SqlParameter("@fundName",fundName)
            };
            return cn.SelectData("getFundCode",para);
        }
        #endregion

        #region Banks
        public DataTable getAllBanks()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.clsCN cn = new DAL.clsCN();
            dt = cn.SelectData("getAllBanks", null);
            return dt;
        }

        public void addBank(int bankCode, string bankName)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[2];
            para[0] = new SqlParameter("@bankCode", SqlDbType.Int);
            para[0].Value = bankCode;
            para[1] = new SqlParameter("@bankName", SqlDbType.NVarChar, 50);
            para[1].Value = bankName;
            cn.ExecuteCmd("addBank", para);
        }

        public void UpdateBank(int bankCode, string bankName)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[2];
            para[0] = new SqlParameter("@bankCode", SqlDbType.Int);
            para[0].Value = bankCode;
            para[1] = new SqlParameter("@bankName", SqlDbType.NVarChar, 50);
            para[1].Value = bankName;
            cn.ExecuteCmd("updateBank", para);
        }

        public void delBank(int bankCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[1];
            para[0] = new SqlParameter("@bankCode", SqlDbType.Int);
            para[0].Value = bankCode;

            cn.ExecuteCmd("delBank", para);
        }
        #endregion

        #region Currencies
        public DataTable getAllCurrenciesTypes()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.clsCN cn=new DAL.clsCN();
            dt=cn.SelectData("getAllCurrenciesTypes",null);
            return dt;

        }

        public DataTable getAllCurrencies()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.clsCN cn = new DAL.clsCN();
            dt = cn.SelectData("getAllCurrencies", null);
            return dt;

        }

        public DataTable getExchangeCurrency(string currName)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para=new SqlParameter[1];
            para[0] = new SqlParameter("@currName",SqlDbType.NVarChar,20);
            para[0].Value = currName;
            dt=cn.SelectData("getExchangeCurrency",para);
            return dt;
        }

        public void addCurrency(string currName,int currType,double currVal,string currPenny,string currSymbole)
        {
            DAL.clsCN cn=new DAL.clsCN();
            SqlParameter[] para=new SqlParameter[5];
            para[0] = new SqlParameter("@currName",SqlDbType.NVarChar,20);
            para[0].Value = currName;
            para[1] = new SqlParameter("@currType", SqlDbType.Int);
            para[1].Value = currType;
            para[2] = new SqlParameter("@currVal", SqlDbType.Money);
            para[2].Value = currVal ;
            para[3] = new SqlParameter("@currPenny", SqlDbType.NChar,10);
            para[3].Value = currPenny;
            para[4] = new SqlParameter("@currSymbole", SqlDbType.NChar, 3);
            para[4].Value = currSymbole;
            cn.ExecuteCmd("addCurrency",para);
        }


        public void updateCurrency(string currName, int currType, double currVal, string currPenny, string currSymbole,int ID)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[6];
            para[0] = new SqlParameter("@currName", SqlDbType.NVarChar, 20);
            para[0].Value = currName;
            para[1] = new SqlParameter("@currType", SqlDbType.Int);
            para[1].Value = currType;
            para[2] = new SqlParameter("@currVal", SqlDbType.Money);
            para[2].Value = currVal;
            para[3] = new SqlParameter("@currPenny", SqlDbType.NChar, 10);
            para[3].Value = currPenny;
            para[4] = new SqlParameter("@currSymbole", SqlDbType.NChar, 3);
            para[4].Value = currSymbole;
            para[5] = new SqlParameter("@ID", SqlDbType.Int);
            para[5].Value = ID;
            cn.ExecuteCmd("updateCurrency", para);
        }

        public void delCurrency(int ID)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para=new SqlParameter[1];
            para[0] = new SqlParameter("@ID",SqlDbType.Int);
            para[0].Value = ID;
            cn.ExecuteCmd("delCurrency",para);
        }


        #endregion

        #region Backups
        public bool backupDB(string databaseName, string backupPath)
        {

            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {

                    new SqlParameter("@databaseName", databaseName),
                    new SqlParameter("@backupPath", backupPath)
            };

            // تنفيذ الاستعلام واسترجاع النتائج
            cn.ExecuteCmd("backupDB", para);
            return true;
        }

        public bool restoreDB(string databaseName, string backupPath)
        {

            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {

                    new SqlParameter("@databaseName", databaseName),
                    new SqlParameter("@backupPath", backupPath)
            };

            // تنفيذ الاستعلام واسترجاع النتائج
             cn.ExecuteCmd("restoreDB", para);
            return true;

        }
        #endregion

        #region paymentMethods
        public DataTable getAllPaymentMethods()
        {
            DAL.clsCN cn=new DAL.clsCN();
            return cn.SelectData("getAllPaymentMethods",null);
        }
        #endregion

        #region general
        public DataTable getBillOrBondNewNo(int opType, int braCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter ("@opType",opType),
                new SqlParameter ("@braCode",braCode)
            };
            return cn.SelectData("getBillOrBondNewNo", para);
        }

        #endregion

    }
}
