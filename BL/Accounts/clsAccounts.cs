using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IntegratedAccSys.BL.Accounts
{
    internal class clsAccounts
    {
        #region ChartOfAccounts

        public DataTable getListOfAccounts(int braCode)
        {
            DataTable dt =new DataTable();
            dt.Clear();
            DAL.clsCN cn=new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[1];
            para[0] = new SqlParameter("@braCode",SqlDbType.Int);
            para[0].Value = braCode;
            dt=cn.SelectData("getListOfAccounts",para);
            return dt;
        }

        public DataTable getAllAccounts(int braCode)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[1];
            para[0] = new SqlParameter("@braCode", SqlDbType.Int);
            para[0].Value = braCode;
            dt = cn.SelectData("getAllAccounts", para);
            return dt;
        }

        public DataTable getAllAccTypes()
        {
            DataTable dt=new DataTable();
            dt.Clear();
            DAL.clsCN cn=new DAL.clsCN();
            dt=cn.SelectData("getAllAccTypes",null);
            return dt;  
        }

        public DataTable getAllReportTypes()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.clsCN cn = new DAL.clsCN();
            dt = cn.SelectData("getAllReportTypes", null);
            return dt;
        }

        public DataTable getAccountData(int braCode ,int accCode)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[2];
            para[0] = new SqlParameter("@braCode", SqlDbType.Int);
            para[0].Value = braCode;
            para[1] = new SqlParameter("@accCode", SqlDbType.Int);
            para[1].Value = accCode;
            dt=cn.SelectData("getAccountData",para);
            return dt;

        }

        public void addAccount(int accCode,int accParentCode ,string accName,int accLevel,int accType,int accReport,double accDebitor,double accCreditor,double accBalance,int isLock,int braCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[11];
            para[0] = new SqlParameter("@accCode", SqlDbType.Int);
            para[0].Value = accCode;
            para[1] = new SqlParameter("@accParentCode", SqlDbType.Int);
            para[1].Value = accParentCode;
            para[2] = new SqlParameter("@accName", SqlDbType.NVarChar,50);
            para[2].Value = accName;
            para[3] = new SqlParameter("@accLevel", SqlDbType.Int);
            para[3].Value = accLevel;
            para[4] = new SqlParameter("@accType", SqlDbType.Int);
            para[4].Value = accType;
            para[5] = new SqlParameter("@accReport", SqlDbType.Int);
            para[5].Value = accReport;
            para[6] = new SqlParameter("@accDebitor", SqlDbType.Money);
            para[6].Value = accDebitor;
            para[7] = new SqlParameter("@accCreditor", SqlDbType.Money);
            para[7].Value = accCreditor;
            para[8] = new SqlParameter("@accBalance", SqlDbType.Money);
            para[8].Value = accBalance;
            para[9] = new SqlParameter("@isLock", SqlDbType.Int);
            para[9].Value = isLock  ;
            para[10] = new SqlParameter("@braCode", SqlDbType.Int);
            para[10].Value = braCode;
            cn.ExecuteCmd("addAccount",para);

        }

        public void updateAccount(int accCode, int accParentCode, string accName, int accLevel, int accType, int accReport, double accDebitor, double accCreditor, double accBalance, int isLock, int braCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[11];
            para[0] = new SqlParameter("@accCode", SqlDbType.Int);
            para[0].Value = accCode;
            para[1] = new SqlParameter("@accParentCode", SqlDbType.Int);
            para[1].Value = accParentCode;
            para[2] = new SqlParameter("@accName", SqlDbType.NVarChar, 50);
            para[2].Value = accName;
            para[3] = new SqlParameter("@accLevel", SqlDbType.Int);
            para[3].Value = accLevel;
            para[4] = new SqlParameter("@accType", SqlDbType.Int);
            para[4].Value = accType;
            para[5] = new SqlParameter("@accReport", SqlDbType.Int);
            para[5].Value = accReport;
            para[6] = new SqlParameter("@accDebitor", SqlDbType.Money);
            para[6].Value = accDebitor;
            para[7] = new SqlParameter("@accCreditor", SqlDbType.Money);
            para[7].Value = accCreditor;
            para[8] = new SqlParameter("@accBalance", SqlDbType.Money);
            para[8].Value = accBalance;
            para[9] = new SqlParameter("@isLock", SqlDbType.Int);
            para[9].Value = isLock;
            para[10] = new SqlParameter("@braCode", SqlDbType.Int);
            para[10].Value = braCode;
            cn.ExecuteCmd("updateAccount", para);

        }

        public void deleteAccount(int accCode,int braCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[2];
            para[0] = new SqlParameter("@accCode", SqlDbType.Int);
            para[0].Value = accCode;
            para[1] = new SqlParameter("@braCode", SqlDbType.Int);
            para[1].Value = braCode;
            cn.ExecuteCmd("deleteAccount",para);

        }

        public DataTable verifyAccountHaveChildren(int accCode,int braCode)
        {
            DataTable dt=new DataTable();
            dt.Clear();
            DAL.clsCN cn=new DAL.clsCN();
            SqlParameter[] para=new SqlParameter[2];
            para[0] = new SqlParameter("@accCode",SqlDbType.Int);
            para[0].Value = accCode;
            para[1] = new SqlParameter("@braCode",SqlDbType.Int);
            para[1].Value = braCode;
            dt=cn.SelectData("verifyAccountHaveChildren",para);
            return dt;
        }

        public DataTable verifyAccountFoundInJournalBady(int accCode)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[1];
            para[0] = new SqlParameter("@accCode", SqlDbType.Int);
            para[0].Value = accCode;
            dt=cn.SelectData("verifyAccountFoundInJournalBady",para);
            return dt;
        }

        public DataTable displayChartofAccounts(int braCode)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[1];
            para[0] = new SqlParameter("@braCode",SqlDbType.Int);
            para[0].Value = braCode;
            dt=cn.SelectData("getAllAccounts",para);
            return dt;

        }

        public DataTable getAccountsForAccParent(int accCode, int braCode)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[2];
            para[0] = new SqlParameter("@accCode", SqlDbType.Int);
            para[0].Value = accCode;
            para[1] = new SqlParameter("@braCode", SqlDbType.Int);
            para[1].Value = braCode;
            dt = cn.SelectData("getAccountsForAccParent", para);
            return dt;
        }

        public DataTable getAccNoMax(int accParentCode, int braCode)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[2];
            para[0] = new SqlParameter("@accParentCode", SqlDbType.Int);
            para[0].Value = accParentCode;
            para[1] = new SqlParameter("@braCode", SqlDbType.Int);
            para[1].Value = braCode;
            dt = cn.SelectData("getAccNoMax", para);
            return dt;
        }

        #endregion

        #region Search in Accounts
        public DataTable searchInAccounts(string searchText,int braCode)
        {
            DataTable dt=new DataTable();
            dt.Clear();
            DAL.clsCN cn=new DAL.clsCN();
            SqlParameter[] para=new SqlParameter[2];
            para[0] = new SqlParameter("@searchText",SqlDbType.NVarChar,20);
            para[0].Value= searchText;
            para[1] = new SqlParameter("@braCode", SqlDbType.Int);
            para[1].Value = braCode;
            dt=cn.SelectData("searchInAccounts",para);
            return dt;
        }
        #endregion

        #region 


        public DataTable getAccountSheetReport(int accCode, DateTime fromDate, DateTime toDate, decimal exchangeRate, string opType)
        {

            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                    new SqlParameter("@accCode", accCode),
                    new SqlParameter("@fromDate", fromDate),
                    new SqlParameter("@toDate", toDate),
                    new SqlParameter("@exchangeRate", exchangeRate),
                    new SqlParameter("@opType", opType)
            };

            // تنفيذ الاستعلام واسترجاع النتائج
            return cn.SelectData("getAccountSheetReport", para);

        }


        public (decimal totalDebitor, decimal totalCreditor) calculateTotals(DataTable dt)
        {
            decimal totalDebitor = 0;
            decimal totalCreditor = 0;

            foreach (DataRow row in dt.Rows)
            {
                totalDebitor += row["Debitor"] != DBNull.Value ? Convert.ToDecimal(row["Debitor"]) : 0;
                totalCreditor += row["Creditor"] != DBNull.Value ? Convert.ToDecimal(row["Creditor"]) : 0;
            }

            return (totalDebitor, totalCreditor);
        }


        public DataTable getTraiBalance( DateTime fromDate, DateTime toDate, decimal exchangeRate ,int braCode)
        {

            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                    
                    new SqlParameter("@fromDate", fromDate),
                    new SqlParameter("@toDate", toDate),
                    new SqlParameter("@exchangeRate", exchangeRate),
                    new SqlParameter("@braCode", braCode)
            };

            // تنفيذ الاستعلام واسترجاع النتائج
            return cn.SelectData("getTraiBalance", para);

        }


        public DataTable getFinalAccountReport(DateTime fromDate, DateTime toDate, decimal exchangeRate, int braCode,int reportType)
        {

            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {

                    new SqlParameter("@fromDate", fromDate),
                    new SqlParameter("@toDate", toDate),
                    new SqlParameter("@exchangeRate", exchangeRate),
                    new SqlParameter("@braCode", braCode),
                    new SqlParameter("@reportType",reportType)

            };

            // تنفيذ الاستعلام واسترجاع النتائج
            return cn.SelectData("getFinalAccountReport", para);

        }

        #endregion



    }
}
