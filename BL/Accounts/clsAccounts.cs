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
        private static readonly DAL.DbContextProvider _ctx = DAL.DbContextProvider.Instance;

        #region ChartOfAccounts

        public DataTable getListOfAccounts(int braCode)
        {
            return _ctx.Execute(ctx => {
                var para = new SqlParameter[1];
                para[0] = new SqlParameter("@braCode", SqlDbType.Int) { Value = braCode };
                return ctx.SelectData("getListOfAccounts", para);
            });
        }

        public DataTable getAllAccounts(int braCode)
        {
            return _ctx.Execute(ctx => {
                var para = new SqlParameter[1];
                para[0] = new SqlParameter("@braCode", SqlDbType.Int) { Value = braCode };
                return ctx.SelectData("getAllAccounts", para);
            });
        }

        public DataTable getAllAccTypes()
        {
            return _ctx.Execute(ctx => ctx.SelectData("getAllAccTypes", null));
        }

        public DataTable getAllReportTypes()
        {
            return _ctx.Execute(ctx => ctx.SelectData("getAllReportTypes", null));
        }

        public DataTable getAccountData(int braCode, int accCode)
        {
            return _ctx.Execute(ctx => {
                var para = new SqlParameter[2];
                para[0] = new SqlParameter("@braCode", SqlDbType.Int) { Value = braCode };
                para[1] = new SqlParameter("@accCode", SqlDbType.Int) { Value = accCode };
                return ctx.SelectData("getAccountData", para);
            });
        }

        public void addAccount(int accCode, int accParentCode, string accName, int accLevel, int accType, int accReport, double accDebitor, double accCreditor, double accBalance, int isLock, int braCode)
        {
            _ctx.Execute(ctx => {
                var para = new SqlParameter[11];
                para[0] = new SqlParameter("@accCode", SqlDbType.Int) { Value = accCode };
                para[1] = new SqlParameter("@accParentCode", SqlDbType.Int) { Value = accParentCode };
                para[2] = new SqlParameter("@accName", SqlDbType.NVarChar, 50) { Value = accName };
                para[3] = new SqlParameter("@accLevel", SqlDbType.Int) { Value = accLevel };
                para[4] = new SqlParameter("@accType", SqlDbType.Int) { Value = accType };
                para[5] = new SqlParameter("@accReport", SqlDbType.Int) { Value = accReport };
                para[6] = new SqlParameter("@accDebitor", SqlDbType.Money) { Value = accDebitor };
                para[7] = new SqlParameter("@accCreditor", SqlDbType.Money) { Value = accCreditor };
                para[8] = new SqlParameter("@accBalance", SqlDbType.Money) { Value = accBalance };
                para[9] = new SqlParameter("@isLock", SqlDbType.Int) { Value = isLock };
                para[10] = new SqlParameter("@braCode", SqlDbType.Int) { Value = braCode };
                ctx.Execute("addAccount", para);
            });
        }

        public void updateAccount(int accCode, int accParentCode, string accName, int accLevel, int accType, int accReport, double accDebitor, double accCreditor, double accBalance, int isLock, int braCode)
        {
            _ctx.Execute(ctx => {
                var para = new SqlParameter[11];
                para[0] = new SqlParameter("@accCode", SqlDbType.Int) { Value = accCode };
                para[1] = new SqlParameter("@accParentCode", SqlDbType.Int) { Value = accParentCode };
                para[2] = new SqlParameter("@accName", SqlDbType.NVarChar, 50) { Value = accName };
                para[3] = new SqlParameter("@accLevel", SqlDbType.Int) { Value = accLevel };
                para[4] = new SqlParameter("@accType", SqlDbType.Int) { Value = accType };
                para[5] = new SqlParameter("@accReport", SqlDbType.Int) { Value = accReport };
                para[6] = new SqlParameter("@accDebitor", SqlDbType.Money) { Value = accDebitor };
                para[7] = new SqlParameter("@accCreditor", SqlDbType.Money) { Value = accCreditor };
                para[8] = new SqlParameter("@accBalance", SqlDbType.Money) { Value = accBalance };
                para[9] = new SqlParameter("@isLock", SqlDbType.Int) { Value = isLock };
                para[10] = new SqlParameter("@braCode", SqlDbType.Int) { Value = braCode };
                ctx.Execute("updateAccount", para);
            });
        }

        public void deleteAccount(int accCode, int braCode)
        {
            _ctx.Execute(ctx => {
                var para = new SqlParameter[2];
                para[0] = new SqlParameter("@accCode", SqlDbType.Int) { Value = accCode };
                para[1] = new SqlParameter("@braCode", SqlDbType.Int) { Value = braCode };
                ctx.Execute("deleteAccount", para);
            });
        }

        public DataTable verifyAccountHaveChildren(int accCode, int braCode)
        {
            return _ctx.Execute(ctx => {
                var para = new SqlParameter[2];
                para[0] = new SqlParameter("@accCode", SqlDbType.Int) { Value = accCode };
                para[1] = new SqlParameter("@braCode", SqlDbType.Int) { Value = braCode };
                return ctx.SelectData("verifyAccountHaveChildren", para);
            });
        }

        public DataTable verifyAccountFoundInJournalBady(int accCode)
        {
            return _ctx.Execute(ctx => {
                var para = new SqlParameter[1];
                para[0] = new SqlParameter("@accCode", SqlDbType.Int) { Value = accCode };
                return ctx.SelectData("verifyAccountFoundInJournalBady", para);
            });
        }

        public DataTable displayChartofAccounts(int braCode)
        {
            return _ctx.Execute(ctx => {
                var para = new SqlParameter[1];
                para[0] = new SqlParameter("@braCode", SqlDbType.Int) { Value = braCode };
                return ctx.SelectData("getAllAccounts", para);
            });
        }

        public DataTable getAccountsForAccParent(int accCode, int braCode)
        {
            return _ctx.Execute(ctx => {
                var para = new SqlParameter[2];
                para[0] = new SqlParameter("@accCode", SqlDbType.Int) { Value = accCode };
                para[1] = new SqlParameter("@braCode", SqlDbType.Int) { Value = braCode };
                return ctx.SelectData("getAccountsForAccParent", para);
            });
        }

        public DataTable getAccNoMax(int accParentCode, int braCode)
        {
            return _ctx.Execute(ctx => {
                var para = new SqlParameter[2];
                para[0] = new SqlParameter("@accParentCode", SqlDbType.Int) { Value = accParentCode };
                para[1] = new SqlParameter("@braCode", SqlDbType.Int) { Value = braCode };
                return ctx.SelectData("getAccNoMax", para);
            });
        }

        #endregion

        #region Search in Accounts

        public DataTable searchInAccounts(string searchText, int braCode)
        {
            return _ctx.Execute(ctx => {
                var para = new SqlParameter[2];
                para[0] = new SqlParameter("@searchText", SqlDbType.NVarChar, 20) { Value = searchText };
                para[1] = new SqlParameter("@braCode", SqlDbType.Int) { Value = braCode };
                return ctx.SelectData("searchInAccounts", para);
            });
        }

        #endregion

        #region Reports

        public DataTable getAccountSheetReport(int accCode, DateTime fromDate, DateTime toDate, decimal exchangeRate, string opType)
        {
            return _ctx.Execute(ctx => {
                var para = new SqlParameter[] {
                    new SqlParameter("@accCode", accCode),
                    new SqlParameter("@fromDate", fromDate),
                    new SqlParameter("@toDate", toDate),
                    new SqlParameter("@exchangeRate", exchangeRate),
                    new SqlParameter("@opType", opType)
                };
                return ctx.SelectData("getAccountSheetReport", para);
            });
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

        public DataTable getTraiBalance(DateTime fromDate, DateTime toDate, decimal exchangeRate, int braCode)
        {
            return _ctx.Execute(ctx => {
                var para = new SqlParameter[] {
                    new SqlParameter("@fromDate", fromDate),
                    new SqlParameter("@toDate", toDate),
                    new SqlParameter("@exchangeRate", exchangeRate),
                    new SqlParameter("@braCode", braCode)
                };
                return ctx.SelectData("getTraiBalance", para);
            });
        }

        public DataTable getFinalAccountReport(DateTime fromDate, DateTime toDate, decimal exchangeRate, int braCode, int reportType)
        {
            return _ctx.Execute(ctx => {
                var para = new SqlParameter[] {
                    new SqlParameter("@fromDate", fromDate),
                    new SqlParameter("@toDate", toDate),
                    new SqlParameter("@exchangeRate", exchangeRate),
                    new SqlParameter("@braCode", braCode),
                    new SqlParameter("@reportType", reportType)
                };
                return ctx.SelectData("getFinalAccountReport", para);
            });
        }

        #endregion

    }
}