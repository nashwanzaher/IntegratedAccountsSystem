using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Npgsql;
using NpgsqlTypes;

namespace IntegratedAccSys.BL.SysFormat
{
    public class ClsSysFormat
    {
        #region Companies
        //function to get New branch Number
        public DataTable getNewBranchNo()
        {
            DataTable dt = new DataTable();
            DAL.ClsCN cn = new DAL.ClsCN();
            dt = cn.SelectData("getNewBranchNo", null);
            return dt;
        }

        // function to get  Branch data
        public DataTable getBranchData(int braCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@braCode",braCode)
            };
            return cn.SelectData("getBranchData", para);
        }


        //function to get All Branches Data
        public DataTable getAllBranches()
        {
            DataTable dt = new DataTable();
            DAL.ClsCN cn = new DAL.ClsCN();
            dt = cn.SelectData("getAllBranches", null);
            return dt;
        }

        //function to insert Branch Data

        public void addCompany(int braCode, string braName, string braAddress, string braActivity, string braTel, string braFax, string braEmail, byte[] braLogo, string testImage)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[9];
            para[0] = new NpgsqlParameter("@braCode", NpgsqlDbType.Integer);
            para[0].Value = braCode;
            para[1] = new NpgsqlParameter("@braName", NpgsqlDbType.Varchar, 120);
            para[1].Value = braName;
            para[2] = new NpgsqlParameter("@braAddress", NpgsqlDbType.Varchar, 200);
            para[2].Value = braAddress;
            para[3] = new NpgsqlParameter("@braActivity", NpgsqlDbType.Varchar, 200);
            para[3].Value = braActivity;
            para[4] = new NpgsqlParameter("@braTel", NpgsqlDbType.Varchar, 25);
            para[4].Value = braTel;
            para[5] = new NpgsqlParameter("@braFax", NpgsqlDbType.Varchar, 25);
            para[5].Value = braFax;
            para[6] = new NpgsqlParameter("@braEmail", NpgsqlDbType.Varchar, 60);
            para[6].Value = braEmail;
            para[7] = new NpgsqlParameter("@braLogo", NpgsqlDbType.Bytea);
            para[7].Value = braLogo;
            para[8] = new NpgsqlParameter("@testImage", NpgsqlDbType.Varchar, 10);
            para[8].Value = testImage;
            cn.ExecuteCmd("addCompany", para);
        }

        //function to Update Branch Data

        public void updateCompany(int braCode, string braName, string braAddress, string braActivity, string braTel, string braFax, string braEmail, byte[] braLogo, string testImage)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[9];
            para[0] = new NpgsqlParameter("@braCode", NpgsqlDbType.Integer);
            para[0].Value = braCode;
            para[1] = new NpgsqlParameter("@braName", NpgsqlDbType.Varchar, 120);
            para[1].Value = braName;
            para[2] = new NpgsqlParameter("@braAddress", NpgsqlDbType.Varchar, 200);
            para[2].Value = braAddress;
            para[3] = new NpgsqlParameter("@braActivity", NpgsqlDbType.Varchar, 200);
            para[3].Value = braActivity;
            para[4] = new NpgsqlParameter("@braTel", NpgsqlDbType.Varchar, 25);
            para[4].Value = braTel;
            para[5] = new NpgsqlParameter("@braFax", NpgsqlDbType.Varchar, 25);
            para[5].Value = braFax;
            para[6] = new NpgsqlParameter("@braEmail", NpgsqlDbType.Varchar, 60);
            para[6].Value = braEmail;
            para[7] = new NpgsqlParameter("@braLogo", NpgsqlDbType.Bytea);
            para[7].Value = braLogo;
            para[8] = new NpgsqlParameter("@testImage", NpgsqlDbType.Varchar, 10);
            para[8].Value = testImage;
            cn.ExecuteCmd("updateCompany", para);
        }

        public void delCompany(int braCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[1];
            para[0] = new NpgsqlParameter("@braCode", NpgsqlDbType.Integer);
            para[0].Value = braCode;
            cn.ExecuteCmd("delCompany", para);

        }
        #endregion

        #region Funds
        public DataTable getAllFunds()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.ClsCN cn = new DAL.ClsCN();
            dt = cn.SelectData("getAllFunds", null);
            return dt;
        }

        public DataTable getAccFundCode(string fundName)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[1];
            para[0] = new NpgsqlParameter("@fundName", NpgsqlDbType.Varchar, 50);
            para[0].Value = fundName;
            dt = cn.SelectData("getAccFundCode", para);
            return dt;
        }

        public void addFund(int fundCode, string fundName)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[2];
            para[0] = new NpgsqlParameter("@fundCode", NpgsqlDbType.Integer);
            para[0].Value = fundCode;
            para[1] = new NpgsqlParameter("@fundName", NpgsqlDbType.Varchar, 50);
            para[1].Value = fundName;
            cn.ExecuteCmd("addFund", para);
        }

        public void updateFund(int fundCode, string fundName)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[2];
            para[0] = new NpgsqlParameter("@fundCode", NpgsqlDbType.Integer);
            para[0].Value = fundCode;
            para[1] = new NpgsqlParameter("@fundName", NpgsqlDbType.Varchar, 50);
            para[1].Value = fundName;
            cn.ExecuteCmd("updateFund", para);
        }

        public void delFund(int fundCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[1];
            para[0] = new NpgsqlParameter("@fundCode", NpgsqlDbType.Integer);
            para[0].Value = fundCode;

            cn.ExecuteCmd("delFund", para);
        }

        public DataTable getFundCode(string fundName)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
              new NpgsqlParameter("@fundName",fundName)
            };
            return cn.SelectData("getFundCode", para);
        }
        #endregion

        #region Banks
        public DataTable getAllBanks()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.ClsCN cn = new DAL.ClsCN();
            dt = cn.SelectData("getAllBanks", null);
            return dt;
        }

        public void addBank(int bankCode, string bankName)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[2];
            para[0] = new NpgsqlParameter("@bankCode", NpgsqlDbType.Integer);
            para[0].Value = bankCode;
            para[1] = new NpgsqlParameter("@bankName", NpgsqlDbType.Varchar, 50);
            para[1].Value = bankName;
            cn.ExecuteCmd("addBank", para);
        }

        public void UpdateBank(int bankCode, string bankName)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[2];
            para[0] = new NpgsqlParameter("@bankCode", NpgsqlDbType.Integer);
            para[0].Value = bankCode;
            para[1] = new NpgsqlParameter("@bankName", NpgsqlDbType.Varchar, 50);
            para[1].Value = bankName;
            cn.ExecuteCmd("updateBank", para);
        }

        public void delBank(int bankCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[1];
            para[0] = new NpgsqlParameter("@bankCode", NpgsqlDbType.Integer);
            para[0].Value = bankCode;

            cn.ExecuteCmd("delBank", para);
        }
        #endregion

        #region Currencies
        public DataTable getAllCurrenciesTypes()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.ClsCN cn = new DAL.ClsCN();
            dt = cn.SelectData("getAllCurrenciesTypes", null);
            return dt;

        }

        public DataTable getAllCurrencies()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.ClsCN cn = new DAL.ClsCN();
            dt = cn.SelectData("getAllCurrencies", null);
            return dt;

        }

        public DataTable getExchangeCurrency(string currName)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[1];
            para[0] = new NpgsqlParameter("@currName", NpgsqlDbType.Varchar, 20);
            para[0].Value = currName;
            dt = cn.SelectData("getExchangeCurrency", para);
            return dt;
        }

        public void addCurrency(string currName, int currType, double currVal, string currPenny, string currSymbole)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[5];
            para[0] = new NpgsqlParameter("@currName", NpgsqlDbType.Varchar, 20);
            para[0].Value = currName;
            para[1] = new NpgsqlParameter("@currType", NpgsqlDbType.Integer);
            para[1].Value = currType;
            para[2] = new NpgsqlParameter("@currVal", NpgsqlDbType.Money);
            para[2].Value = currVal;
            para[3] = new NpgsqlParameter("@currPenny", NpgsqlDbType.Char, 10);
            para[3].Value = currPenny;
            para[4] = new NpgsqlParameter("@currSymbole", NpgsqlDbType.Char, 3);
            para[4].Value = currSymbole;
            cn.ExecuteCmd("addCurrency", para);
        }


        public void updateCurrency(string currName, int currType, double currVal, string currPenny, string currSymbole, int ID)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[6];
            para[0] = new NpgsqlParameter("@currName", NpgsqlDbType.Varchar, 20);
            para[0].Value = currName;
            para[1] = new NpgsqlParameter("@currType", NpgsqlDbType.Integer);
            para[1].Value = currType;
            para[2] = new NpgsqlParameter("@currVal", NpgsqlDbType.Money);
            para[2].Value = currVal;
            para[3] = new NpgsqlParameter("@currPenny", NpgsqlDbType.Char, 10);
            para[3].Value = currPenny;
            para[4] = new NpgsqlParameter("@currSymbole", NpgsqlDbType.Char, 3);
            para[4].Value = currSymbole;
            para[5] = new NpgsqlParameter("@ID", NpgsqlDbType.Integer);
            para[5].Value = ID;
            cn.ExecuteCmd("updateCurrency", para);
        }

        public void delCurrency(int ID)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[1];
            para[0] = new NpgsqlParameter("@ID", NpgsqlDbType.Integer);
            para[0].Value = ID;
            cn.ExecuteCmd("delCurrency", para);
        }


        #endregion

        #region Backups
        public bool backupDB(string databaseName, string backupPath)
        {

            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {

                    new NpgsqlParameter("@databaseName", databaseName),
                    new NpgsqlParameter("@backupPath", backupPath)
            };

            // تنفيذ الاستعلام واسترجاع النتائج
            cn.ExecuteCmd("backupDB", para);
            return true;
        }

        public bool restoreDB(string databaseName, string backupPath)
        {

            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {

                    new NpgsqlParameter("@databaseName", databaseName),
                    new NpgsqlParameter("@backupPath", backupPath)
            };

            // تنفيذ الاستعلام واسترجاع النتائج
            cn.ExecuteCmd("restoreDB", para);
            return true;

        }
        #endregion

        #region paymentMethods
        public DataTable getAllPaymentMethods()
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            return cn.SelectData("getAllPaymentMethods", null);
        }
        #endregion

        #region general
        public DataTable getBillOrBondNewNo(int opType, int braCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@opType",opType),
                new NpgsqlParameter ("@braCode",braCode)
            };
            return cn.SelectData("getBillOrBondNewNo", para);
        }

        #endregion

    }
}
