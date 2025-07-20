using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using static System.Runtime.CompilerServices.RuntimeHelpers;

namespace IntegratedAccSys.BL.Purchases
{
    internal class clsPurchases
    {
        #region supplaiers
        public DataTable getAllSuppliers(int braCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[] 
            {
                new SqlParameter("@braCode",braCode)
            };
            return cn.SelectData("getAllSuppliers",para);
        }

        public void addSuppleir(int suppCode,string suppName,string mobile,string Email,byte[] Img,string testImage,int braCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[] 
            { 
                new SqlParameter ("@suppCode",suppCode),
                new SqlParameter ("@suppName",suppName),
                new SqlParameter ("@mobile",mobile),
                new SqlParameter ("@Email",Email),
                new SqlParameter ("@Img",Img),
                new SqlParameter("@testImage",testImage),
                new SqlParameter ("@braCode",braCode)
            };
            cn.ExecuteCmd("addSuppleir",para);
        }

        public void editSuppleir(int suppCode, string suppName, string mobile, string Email, byte[] Img, string testImage, int braCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter ("@suppCode",suppCode),
                new SqlParameter ("@suppName",suppName),
                new SqlParameter ("@mobile",mobile),
                new SqlParameter ("@Email",Email),
                new SqlParameter ("@Img",Img),
                new SqlParameter("@testImage",testImage),
                new SqlParameter ("@braCode",braCode)
            };
            cn.ExecuteCmd("editSuppliers", para);
        }
        public void delSupplier(int suppCode,int braCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[] 
            {
               new SqlParameter ("@suppCode",suppCode),
               new SqlParameter ("@braCode",braCode)
            };
            cn.ExecuteCmd("delSupplier",para);
        }

        public DataTable searchInSuppliers(string searchText,int braCode)
        {
            DAL.clsCN cn=new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[] 
            { 
               new SqlParameter ("@searchText",searchText),
               new SqlParameter ("@braCode",braCode)
            };
            return cn.SelectData("searchInSuppliers", para);
        }
        #endregion

        #region Purchase Invoice
        #endregion
    }
}
