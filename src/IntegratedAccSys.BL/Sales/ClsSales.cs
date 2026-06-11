using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Reflection;
using System.Security.Policy;
using System.Text;
using System.Threading.Tasks;
using Npgsql;
using NpgsqlTypes;
using static System.Runtime.CompilerServices.RuntimeHelpers;

namespace IntegratedAccSys.BL.Sales
{
    public class ClsSales
    {
        #region Customers
        public DataTable searchInCustomers(string searchText, int braCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
               new NpgsqlParameter ("@searchText",searchText),
               new NpgsqlParameter ("@braCode",braCode)
            };
            return cn.SelectData("searchInCustomers", para);
        }

        public DataTable getAllCustomers(int braCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@braCode",braCode)
            };
            return cn.SelectData("getAllCustomers", para);
        }

        public void addCustomers(int custCode, string custName, double debitLimit, string mobile, string Email, byte[] Img, int braCode, string testImage)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                 new NpgsqlParameter("@custCode",custCode),
                 new NpgsqlParameter("@custName",custName),
                 new NpgsqlParameter("@debitLimit",debitLimit),
                 new NpgsqlParameter("@mobile",mobile),
                 new NpgsqlParameter("@Email",Email),
                 new NpgsqlParameter("@Img",Img),
                 new NpgsqlParameter("@braCode",braCode),
                 new NpgsqlParameter("@testImage",testImage),
            };
            cn.ExecuteCmd("addCustomers", para);
        }

        public void editCustomers(int custCode, string custName, double debitLimit, string mobile, string Email, byte[] Img, int braCode, string testImage)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                 new NpgsqlParameter("@custCode",custCode),
                 new NpgsqlParameter("@custName",custName),
                 new NpgsqlParameter("@debitLimit",debitLimit),
                 new NpgsqlParameter("@mobile",mobile),
                 new NpgsqlParameter("@Email",Email),
                 new NpgsqlParameter("@Img",Img),
                 new NpgsqlParameter("@braCode",braCode),
                 new NpgsqlParameter("@testImage",testImage),
            };
            cn.ExecuteCmd("editCustomers", para);
        }

        public void delCustomer(int custCode, int braCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                 new NpgsqlParameter("@custCode",custCode),
                 new NpgsqlParameter("@braCode",braCode)

            };
            cn.ExecuteCmd("delCustomer", para);
        }
        #endregion
    }
}
