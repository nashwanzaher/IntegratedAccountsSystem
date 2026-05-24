using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Runtime.InteropServices.JavaScript;
using System.Text;
using System.Threading.Tasks;
using static System.Runtime.CompilerServices.RuntimeHelpers;
using System.Xml.Linq;
using System.Data.SqlClient;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace IntegratedAccSys.BL.Journal
{
    internal class clsjournal
    {
        public DataTable getNewJournalNo(int braCode)
        {
            DataTable dt=new DataTable();
            dt.Clear();
            DAL.clsCN cn=new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[1];
            para[0] = new SqlParameter("@braCode", SqlDbType.Int);
            para[0].Value = braCode;
            dt =cn.SelectData("getNewJournalNo",para);
            return dt;
        }
        public void addJournalHeader(int jNo,DateTime  jDate,string jNote,int jType,int  jPost,double  accDebitor,double accCreditor,double accBalance,int  userAdd,DateTime  addDate,int  braCode,int opType)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[12];
            para[0] = new SqlParameter("@jNo",SqlDbType.Int);
            para[0].Value = jNo;
            para[1] = new SqlParameter("@jDate",SqlDbType.DateTime );
            para[1].Value = jDate;
            para[2] = new SqlParameter("@jNote",SqlDbType.NVarChar,120);
            para[2].Value = jNote;
            para[3] = new SqlParameter("@jType", SqlDbType.Int);
            para[3].Value = jType;
            para[4] = new SqlParameter("@jPost", SqlDbType.Int);
            para[4].Value = jPost;
            para[5] = new SqlParameter("@accDebitor", SqlDbType.Money);
            para[5].Value = accDebitor ;
            para[6] = new SqlParameter("@accCreditor", SqlDbType.Money);
            para[6].Value = accCreditor ;
            para[7] = new SqlParameter("@accBalance", SqlDbType.Money);
            para[7].Value = accBalance;
            para[8] = new SqlParameter("@userAdd", SqlDbType.Int);
            para[8].Value = userAdd;
            para[9] = new SqlParameter("@addDate", SqlDbType.DateTime);
            para[9].Value = addDate;
            para[10] = new SqlParameter("@braCode", SqlDbType.Int);
            para[10].Value = braCode;
            para[11] = new SqlParameter("@opType", SqlDbType.Int);
            para[11].Value = opType;
            cn.ExecuteCmd("addJournalHeader",para);

        }

        public void addJournalBody(int  accCode,int  currID,double currVal,double  accDebitor,double  accCreditor, string? entityNote, int  jNo)
        {
            DAL.clsCN cn=new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[7];
            para[0] = new SqlParameter("@accCode",SqlDbType.Int );
            para[0].Value = accCode;
            para[1] = new SqlParameter("@currID",SqlDbType.Int);
            para[1].Value = currID;
            para[2] = new SqlParameter("@currVal", SqlDbType.Money);
            para[2].Value = currVal;
            para[3] = new SqlParameter("@accDebitor",SqlDbType.Money );
            para[3].Value = accDebitor;
            para[4] = new SqlParameter("@accCreditor", SqlDbType.Money);
            para[4].Value = accCreditor ;
            para[5] = new SqlParameter("@entityNote",SqlDbType.NVarChar ,50);
            para[5].Value = entityNote;
            para[6] = new SqlParameter("@jNo", SqlDbType.Int);
            para[6].Value = jNo;
            cn.ExecuteCmd("addJournalBody",para);

        }

        public DataTable showJournalHeader(int jNo)
        {
            DataTable dt=new DataTable();
            dt.Clear();
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para=new SqlParameter[1];
            para[0] = new SqlParameter("@jNo",SqlDbType.Int );
            para[0].Value = jNo;
            dt=cn.SelectData("showJournalHeader",para);
            return dt;
        }

        public DataTable showJournalBody(int jNo)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[1];
            para[0] = new SqlParameter("@jNo", SqlDbType.Int);
            para[0].Value = jNo;
            dt = cn.SelectData("showJournalBody", para);
            return dt;
        }

        public DataTable getMaximumJno()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.clsCN cn=new DAL.clsCN();
            dt=cn.SelectData("getMaximumJno",null);
            return dt;
        }

        public DataTable getMinimumJno()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.clsCN cn = new DAL.clsCN();
            dt = cn.SelectData("getMinimumJno", null);
            return dt;
        }


        public void editJournalHeader(int jNo, DateTime jDate, string jNote, int jType, int jPost, double accDebitor, double accCreditor, double accBalance, int userEdit, DateTime editDate, int braCode,int opType)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[12];
            para[0] = new SqlParameter("@jNo", SqlDbType.Int);
            para[0].Value = jNo;
            para[1] = new SqlParameter("@jDate", SqlDbType.DateTime);
            para[1].Value = jDate;
            para[2] = new SqlParameter("@jNote", SqlDbType.NVarChar, 120);
            para[2].Value = jNote;
            para[3] = new SqlParameter("@jType", SqlDbType.Int);
            para[3].Value = jType;
            para[4] = new SqlParameter("@jPost", SqlDbType.Int);
            para[4].Value = jPost;
            para[5] = new SqlParameter("@accDebitor", SqlDbType.Money);
            para[5].Value = accDebitor;
            para[6] = new SqlParameter("@accCreditor", SqlDbType.Money);
            para[6].Value = accCreditor;
            para[7] = new SqlParameter("@accBalance", SqlDbType.Money);
            para[7].Value = accBalance;
            para[8] = new SqlParameter("@userEdit", SqlDbType.Int);
            para[8].Value = userEdit;
            para[9] = new SqlParameter("@editDate", SqlDbType.DateTime);
            para[9].Value = editDate;
            para[10] = new SqlParameter("@braCode", SqlDbType.Int);
            para[10].Value = braCode;;
            para[11] = new SqlParameter("@opType", SqlDbType.Int);
            para[11].Value = opType;
            cn.ExecuteCmd("editJournalHeader", para);

        }

        public void delJournalbody(int jNo)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[1];
            para[0] = new SqlParameter("@jNo", SqlDbType.Int);
            para[0].Value = jNo;
            cn.ExecuteCmd("delJournalbody",para);

        }

        public void delJournalEntry(int jNo,int braCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[2];
            para[0] = new SqlParameter("@jNo", SqlDbType.Int);
            para[0].Value = jNo;
            para[1] = new SqlParameter("@braCode", SqlDbType.Int);
            para[1].Value = braCode;
            cn.ExecuteCmd("delJournalEntry",para);
        }

        #region Posting

        // Set bounds post
        public DataTable setBondIsPost(int bondPost, long jNo, int braCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para =new  SqlParameter[]
            {
                new SqlParameter("@bondPost",bondPost),
                new SqlParameter("@jNo", jNo),
                new SqlParameter("@braCode", braCode),
            };
                    
           return cn.SelectData("setBondIsPost", para);
            
        }

        // Get all journal bounds that are posted or unposted
        public DataTable getPostingBonds(DateTime fromDate, DateTime toDate, int opType, int postStatus, int braCode)
        {

            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter("@fromDate",fromDate),
                new SqlParameter("@toDate", toDate),
                new SqlParameter("@opType", opType),
                new SqlParameter("@postStatus", postStatus),
                new SqlParameter("@braCode", braCode),
            };

            
                return cn.SelectData("getPostingBonds", para);
            
        }

        // Do posting or undo all determined journal bounds
        public void doBondPosting(long jNo,  int postStatus, int opType, int braCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter("@jNo",jNo),
                new SqlParameter("@postStatus", postStatus),
                new SqlParameter("@opType", opType),
                new SqlParameter("@braCode", braCode),
            };
            
                cn.ExecuteCmd("doBondPosting", para);
           
        }

        #endregion

    }
}
