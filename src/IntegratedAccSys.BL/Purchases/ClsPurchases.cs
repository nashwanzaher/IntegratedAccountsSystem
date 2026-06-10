using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using Npgsql;
using NpgsqlTypes;
using static System.Runtime.CompilerServices.RuntimeHelpers;

namespace IntegratedAccSys.BL.Purchases
{
    public class ClsPurchases
    {
        #region supplaiers
        public DataTable getAllSuppliers(int braCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter("@braCode",braCode)
            };
            return cn.SelectData("getAllSuppliers", para);
        }

        public void addSuppleir(int suppCode, string suppName, string mobile, string Email, byte[] Img, string testImage, int braCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@suppCode",suppCode),
                new NpgsqlParameter ("@suppName",suppName),
                new NpgsqlParameter ("@mobile",mobile),
                new NpgsqlParameter ("@Email",Email),
                new NpgsqlParameter ("@Img",Img),
                new NpgsqlParameter("@testImage",testImage),
                new NpgsqlParameter ("@braCode",braCode)
            };
            cn.ExecuteCmd("addSuppleir", para);
        }

        public void editSuppleir(int suppCode, string suppName, string mobile, string Email, byte[] Img, string testImage, int braCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@suppCode",suppCode),
                new NpgsqlParameter ("@suppName",suppName),
                new NpgsqlParameter ("@mobile",mobile),
                new NpgsqlParameter ("@Email",Email),
                new NpgsqlParameter ("@Img",Img),
                new NpgsqlParameter("@testImage",testImage),
                new NpgsqlParameter ("@braCode",braCode)
            };
            cn.ExecuteCmd("editSuppliers", para);
        }
        public void delSupplier(int suppCode, int braCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
               new NpgsqlParameter ("@suppCode",suppCode),
               new NpgsqlParameter ("@braCode",braCode)
            };
            cn.ExecuteCmd("delSupplier", para);
        }

        public DataTable searchInSuppliers(string searchText, int braCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
               new NpgsqlParameter ("@searchText",searchText),
               new NpgsqlParameter ("@braCode",braCode)
            };
            return cn.SelectData("searchInSuppliers", para);
        }
        #endregion

        #region Purchase Invoice
        #endregion
    }
}
