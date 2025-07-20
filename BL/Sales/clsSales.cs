using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static System.Runtime.CompilerServices.RuntimeHelpers;
using System.Reflection;
using System.Security.Policy;

namespace IntegratedAccSys.BL.Sales
{
    internal class clsSales
    {
        #region Customers
        public DataTable searchInCustomers(string searchText, int braCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
               new SqlParameter ("@searchText",searchText),
               new SqlParameter ("@braCode",braCode)
            };
            return cn.SelectData("searchInCustomers", para);
        }

        public DataTable getAllCustomers(int braCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter ("@braCode",braCode)
            };
            return cn.SelectData("getAllCustomers",para);
        }

        public void addCustomers(int custCode,string  custName,double debitLimit,string mobile,string Email,byte[] Img,int braCode,string testImage)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                 new SqlParameter("@custCode",custCode),
                 new SqlParameter("@custName",custName),
                 new SqlParameter("@debitLimit",debitLimit),
                 new SqlParameter("@mobile",mobile),
                 new SqlParameter("@Email",Email),
                 new SqlParameter("@Img",Img),
                 new SqlParameter("@braCode",braCode),
                 new SqlParameter("@testImage",testImage),
            };
            cn.ExecuteCmd("addCustomers",para);
        }

        public void editCustomers(int custCode, string custName, double debitLimit, string mobile, string Email, byte[] Img, int braCode, string testImage)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                 new SqlParameter("@custCode",custCode),
                 new SqlParameter("@custName",custName),
                 new SqlParameter("@debitLimit",debitLimit),
                 new SqlParameter("@mobile",mobile),
                 new SqlParameter("@Email",Email),
                 new SqlParameter("@Img",Img),
                 new SqlParameter("@braCode",braCode),
                 new SqlParameter("@testImage",testImage),
            };
            cn.ExecuteCmd("editCustomers", para);
        }

        public void delCustomer(int custCode,  int braCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                 new SqlParameter("@custCode",custCode),
                 new SqlParameter("@braCode",braCode)
                 
            };
            cn.ExecuteCmd("delCustomer", para);
        }
        #endregion
    }
}
