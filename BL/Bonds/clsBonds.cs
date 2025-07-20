using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static System.Runtime.CompilerServices.RuntimeHelpers;

namespace IntegratedAccSys.BL.Bonds
{
    internal class clsBonds
    {
        public DataTable GetNewBondNo(int braCode,int bondType)
        {
            DataTable dt=new DataTable();
            dt.Clear();
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[2];
            para[0] = new SqlParameter("@braCode",SqlDbType.Int);
            para[0].Value = braCode;
            para[1] = new SqlParameter("@bondType", SqlDbType.Int);
            para[1].Value = bondType;
            dt =cn.SelectData("GetNewBondNo",para);
            return dt;
        }

        public void addBondHeader(int bondNo,DateTime bondDate,string bondNote,int  bondType,int  bondPost,int  accFundCode,int  accBankCode,double Amount,int  userAdd,DateTime addDate,int  braCode,int jNo)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para=new SqlParameter[12];
            para[0] = new SqlParameter("@bondNo",SqlDbType.Int);
            para[0].Value = bondNo;
            para[1] = new SqlParameter("@bondDate",SqlDbType.Date);
            para[1].Value = bondDate;
            para[2] = new SqlParameter("@bondNote",SqlDbType.NVarChar,120);
            para[2].Value = bondNote;
            para[3] = new SqlParameter("@bondType",SqlDbType.Int);
            para[3].Value = bondType;
            para[4] = new SqlParameter("@bondPost",SqlDbType.Int);
            para[4].Value = bondPost;
            para[5] = new SqlParameter("@accFundCode",SqlDbType.Int);
            para[5].Value = accFundCode;
            para[6] = new SqlParameter("@accBankCode",SqlDbType.Int );
            para[6].Value = accBankCode;
            para[7] = new SqlParameter("@Amount",SqlDbType.Money);
            para[7].Value = Amount;
            para[8] = new SqlParameter("@userAdd",SqlDbType.Int );
            para[8].Value = userAdd;
            para[9] = new SqlParameter("@addDate",SqlDbType.Date);
            para[9].Value = addDate;
            para[10] = new SqlParameter("@braCode",SqlDbType.Int);
            para[10].Value = braCode;
            para[11] = new SqlParameter("@jNo",SqlDbType.Int);
            para[11].Value = jNo;
            cn.ExecuteCmd("addBondHeader",para);
        }

        public void addBondBody(int  accCode,int  currID,double  Amont,int bondNo, double currVal)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[5];
            para[0] = new SqlParameter("@accCode",SqlDbType.Int);
            para[0].Value = accCode;
            para[1] = new SqlParameter("@currID",SqlDbType.Int);
            para[1].Value = currID;
            para[2] = new SqlParameter("@Amont",SqlDbType.Money);
            para[2].Value = Amont;
            para[3] = new SqlParameter("@bondNo",SqlDbType.Int);
            para[3].Value = bondNo;
            para[4] = new SqlParameter("@currVal",SqlDbType.Money);
            para[4].Value = currVal;
            cn.ExecuteCmd("addBondBody",para);
        }

        public DataTable showBondHeader(int bondNo)
        {
            DataTable dt=new DataTable();
            dt.Clear();
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para=new SqlParameter[1];
            para[0] = new SqlParameter("@bondNo",SqlDbType.Int);
            para[0].Value = bondNo;
            dt=cn.SelectData("showBondHeader",para);
            return dt;
        }

        public DataTable showBondBody(int bondNo)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[1];
            para[0] = new SqlParameter("@bondNo", SqlDbType.Int);
            para[0].Value = bondNo;
            dt = cn.SelectData("showBondBody", para);
            return dt;
        }

        public DataTable getMaxBondNo(int bondType)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[1];
            para[0] = new SqlParameter("@bondType", SqlDbType.Int);
            para[0].Value = bondType;
            dt=cn.SelectData("getMaxBondNo",para);
            return dt;
        }

        public DataTable getMinBondNo(int bondType)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[1];
            para[0] = new SqlParameter("@bondType", SqlDbType.Int);
            para[0].Value = bondType;
            dt = cn.SelectData("getMinBondNo", para);
            return dt;
        }

        public void editBondHeader(int bondNo, DateTime bondDate, string bondNote, int bondType, int bondPost, int accFundCode, int accBankCode, double Amount, int userEdit, DateTime editDate, int braCode, int jNo)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[12];
            para[0] = new SqlParameter("@bondNo", SqlDbType.Int);
            para[0].Value = bondNo;
            para[1] = new SqlParameter("@bondDate", SqlDbType.Date);
            para[1].Value = bondDate;
            para[2] = new SqlParameter("@bondNote", SqlDbType.NVarChar, 120);
            para[2].Value = bondNote;
            para[3] = new SqlParameter("@bondType", SqlDbType.Int);
            para[3].Value = bondType;
            para[4] = new SqlParameter("@bondPost", SqlDbType.Int);
            para[4].Value = bondPost;
            para[5] = new SqlParameter("@accFundCode", SqlDbType.Int);
            para[5].Value = accFundCode;
            para[6] = new SqlParameter("@accBankCode", SqlDbType.Int);
            para[6].Value = accBankCode;
            para[7] = new SqlParameter("@Amount", SqlDbType.Money);
            para[7].Value = Amount;
            para[8] = new SqlParameter("@userEdit", SqlDbType.Int);
            para[8].Value = userEdit;
            para[9] = new SqlParameter("@editDate", SqlDbType.Date);
            para[9].Value = editDate;
            para[10] = new SqlParameter("@braCode", SqlDbType.Int);
            para[10].Value = braCode;
            para[11] = new SqlParameter("@jNo", SqlDbType.Int);
            para[11].Value = jNo;
            cn.ExecuteCmd("editBondHeader", para);
        }

        public void delBondBody(int bondNo)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[1];
            para[0] = new SqlParameter("@bondNo",SqlDbType.Int );
            para[0].Value = bondNo;
            cn.ExecuteCmd("delBondBody",para);
        }

        public void delBond(int bondNo)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[1];
            para[0] = new SqlParameter("@bondNo", SqlDbType.Int);
            para[0].Value = bondNo;
            cn.ExecuteCmd("delBond", para);
        }


    }
}
