using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Npgsql;
using NpgsqlTypes;
using static System.Runtime.CompilerServices.RuntimeHelpers;

namespace IntegratedAccSys.BL.Bonds
{
    public class ClsBonds
    {
        public DataTable GetNewBondNo(int braCode, int bondType)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[2];
            para[0] = new NpgsqlParameter("@braCode", NpgsqlDbType.Integer);
            para[0].Value = braCode;
            para[1] = new NpgsqlParameter("@bondType", NpgsqlDbType.Integer);
            para[1].Value = bondType;
            dt = cn.SelectData("GetNewBondNo", para);
            return dt;
        }

        public void addBondHeader(int bondNo, DateTime bondDate, string bondNote, int bondType, int bondPost, int accFundCode, int accBankCode, double Amount, int userAdd, DateTime addDate, int braCode, int jNo)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[12];
            para[0] = new NpgsqlParameter("@bondNo", NpgsqlDbType.Integer);
            para[0].Value = bondNo;
            para[1] = new NpgsqlParameter("@bondDate", NpgsqlDbType.Date);
            para[1].Value = bondDate;
            para[2] = new NpgsqlParameter("@bondNote", NpgsqlDbType.Varchar, 120);
            para[2].Value = bondNote;
            para[3] = new NpgsqlParameter("@bondType", NpgsqlDbType.Integer);
            para[3].Value = bondType;
            para[4] = new NpgsqlParameter("@bondPost", NpgsqlDbType.Integer);
            para[4].Value = bondPost;
            para[5] = new NpgsqlParameter("@accFundCode", NpgsqlDbType.Integer);
            para[5].Value = accFundCode;
            para[6] = new NpgsqlParameter("@accBankCode", NpgsqlDbType.Integer);
            para[6].Value = accBankCode;
            para[7] = new NpgsqlParameter("@Amount", NpgsqlDbType.Money);
            para[7].Value = Amount;
            para[8] = new NpgsqlParameter("@userAdd", NpgsqlDbType.Integer);
            para[8].Value = userAdd;
            para[9] = new NpgsqlParameter("@addDate", NpgsqlDbType.Date);
            para[9].Value = addDate;
            para[10] = new NpgsqlParameter("@braCode", NpgsqlDbType.Integer);
            para[10].Value = braCode;
            para[11] = new NpgsqlParameter("@jNo", NpgsqlDbType.Integer);
            para[11].Value = jNo;
            cn.ExecuteCmd("addBondHeader", para);
        }

        public void addBondBody(int accCode, int currID, double Amont, int bondNo, double currVal)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[5];
            para[0] = new NpgsqlParameter("@accCode", NpgsqlDbType.Integer);
            para[0].Value = accCode;
            para[1] = new NpgsqlParameter("@currID", NpgsqlDbType.Integer);
            para[1].Value = currID;
            para[2] = new NpgsqlParameter("@Amont", NpgsqlDbType.Money);
            para[2].Value = Amont;
            para[3] = new NpgsqlParameter("@bondNo", NpgsqlDbType.Integer);
            para[3].Value = bondNo;
            para[4] = new NpgsqlParameter("@currVal", NpgsqlDbType.Money);
            para[4].Value = currVal;
            cn.ExecuteCmd("addBondBody", para);
        }

        public DataTable showBondHeader(int bondNo)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[1];
            para[0] = new NpgsqlParameter("@bondNo", NpgsqlDbType.Integer);
            para[0].Value = bondNo;
            dt = cn.SelectData("showBondHeader", para);
            return dt;
        }

        public DataTable showBondBody(int bondNo)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[1];
            para[0] = new NpgsqlParameter("@bondNo", NpgsqlDbType.Integer);
            para[0].Value = bondNo;
            dt = cn.SelectData("showBondBody", para);
            return dt;
        }

        public DataTable getMaxBondNo(int bondType)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[1];
            para[0] = new NpgsqlParameter("@bondType", NpgsqlDbType.Integer);
            para[0].Value = bondType;
            dt = cn.SelectData("getMaxBondNo", para);
            return dt;
        }

        public DataTable getMinBondNo(int bondType)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[1];
            para[0] = new NpgsqlParameter("@bondType", NpgsqlDbType.Integer);
            para[0].Value = bondType;
            dt = cn.SelectData("getMinBondNo", para);
            return dt;
        }

        public void editBondHeader(int bondNo, DateTime bondDate, string bondNote, int bondType, int bondPost, int accFundCode, int accBankCode, double Amount, int userEdit, DateTime editDate, int braCode, int jNo)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[12];
            para[0] = new NpgsqlParameter("@bondNo", NpgsqlDbType.Integer);
            para[0].Value = bondNo;
            para[1] = new NpgsqlParameter("@bondDate", NpgsqlDbType.Date);
            para[1].Value = bondDate;
            para[2] = new NpgsqlParameter("@bondNote", NpgsqlDbType.Varchar, 120);
            para[2].Value = bondNote;
            para[3] = new NpgsqlParameter("@bondType", NpgsqlDbType.Integer);
            para[3].Value = bondType;
            para[4] = new NpgsqlParameter("@bondPost", NpgsqlDbType.Integer);
            para[4].Value = bondPost;
            para[5] = new NpgsqlParameter("@accFundCode", NpgsqlDbType.Integer);
            para[5].Value = accFundCode;
            para[6] = new NpgsqlParameter("@accBankCode", NpgsqlDbType.Integer);
            para[6].Value = accBankCode;
            para[7] = new NpgsqlParameter("@Amount", NpgsqlDbType.Money);
            para[7].Value = Amount;
            para[8] = new NpgsqlParameter("@userEdit", NpgsqlDbType.Integer);
            para[8].Value = userEdit;
            para[9] = new NpgsqlParameter("@editDate", NpgsqlDbType.Date);
            para[9].Value = editDate;
            para[10] = new NpgsqlParameter("@braCode", NpgsqlDbType.Integer);
            para[10].Value = braCode;
            para[11] = new NpgsqlParameter("@jNo", NpgsqlDbType.Integer);
            para[11].Value = jNo;
            cn.ExecuteCmd("editBondHeader", para);
        }

        public void delBondBody(int bondNo)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[1];
            para[0] = new NpgsqlParameter("@bondNo", NpgsqlDbType.Integer);
            para[0].Value = bondNo;
            cn.ExecuteCmd("delBondBody", para);
        }

        public void delBond(int bondNo)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[1];
            para[0] = new NpgsqlParameter("@bondNo", NpgsqlDbType.Integer);
            para[0].Value = bondNo;
            cn.ExecuteCmd("delBond", para);
        }


    }
}
