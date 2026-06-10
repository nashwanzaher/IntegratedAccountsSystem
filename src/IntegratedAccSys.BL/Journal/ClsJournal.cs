using System;
using System.Collections.Generic;
using System.Data;
using Npgsql;
using NpgsqlTypes;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IntegratedAccSys.BL.Journal
{
    /// <summary>
    /// Business logic for journal entries and posting operations.
    /// Renamed from <c>clsjournal</c> to <c>ClsJournal</c> (PascalCase, CS8981 fix).
    /// All PL callers have been updated to use <see cref="ClsJournal"/>.
    /// </summary>
    public class ClsJournal
    {
        public DataTable getNewJournalNo(int braCode)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[1];
            para[0] = new NpgsqlParameter("@braCode", NpgsqlDbType.Integer);
            para[0].Value = braCode;
            dt = cn.SelectData("getNewJournalNo", para);
            return dt;
        }

        public void addJournalHeader(int jNo, DateTime jDate, string jNote, int jType, int jPost, double accDebitor,
            double accCreditor, double accBalance, int userAdd, DateTime addDate, int braCode, int opType)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[12];
            para[0] = new NpgsqlParameter("@jNo", NpgsqlDbType.Integer);
            para[0].Value = jNo;
            para[1] = new NpgsqlParameter("@jDate", NpgsqlDbType.Timestamp);
            para[1].Value = jDate;
            para[2] = new NpgsqlParameter("@jNote", NpgsqlDbType.Varchar, 120);
            para[2].Value = jNote;
            para[3] = new NpgsqlParameter("@jType", NpgsqlDbType.Integer);
            para[3].Value = jType;
            para[4] = new NpgsqlParameter("@jPost", NpgsqlDbType.Integer);
            para[4].Value = jPost;
            para[5] = new NpgsqlParameter("@accDebitor", NpgsqlDbType.Money);
            para[5].Value = accDebitor;
            para[6] = new NpgsqlParameter("@accCreditor", NpgsqlDbType.Money);
            para[6].Value = accCreditor;
            para[7] = new NpgsqlParameter("@accBalance", NpgsqlDbType.Money);
            para[7].Value = accBalance;
            para[8] = new NpgsqlParameter("@userAdd", NpgsqlDbType.Integer);
            para[8].Value = userAdd;
            para[9] = new NpgsqlParameter("@addDate", NpgsqlDbType.Timestamp);
            para[9].Value = addDate;
            para[10] = new NpgsqlParameter("@braCode", NpgsqlDbType.Integer);
            para[10].Value = braCode;
            para[11] = new NpgsqlParameter("@opType", NpgsqlDbType.Integer);
            para[11].Value = opType;
            cn.ExecuteCmd("addJournalHeader", para);
        }

        public void addJournalBody(int accCode, int currID, double currVal, double accDebitor, double accCreditor,
            string? entityNote, int jNo)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[7];
            para[0] = new NpgsqlParameter("@accCode", NpgsqlDbType.Integer);
            para[0].Value = accCode;
            para[1] = new NpgsqlParameter("@currID", NpgsqlDbType.Integer);
            para[1].Value = currID;
            para[2] = new NpgsqlParameter("@currVal", NpgsqlDbType.Money);
            para[2].Value = currVal;
            para[3] = new NpgsqlParameter("@accDebitor", NpgsqlDbType.Money);
            para[3].Value = accDebitor;
            para[4] = new NpgsqlParameter("@accCreditor", NpgsqlDbType.Money);
            para[4].Value = accCreditor;
            para[5] = new NpgsqlParameter("@entityNote", NpgsqlDbType.Varchar, 50);
            para[5].Value = entityNote;
            para[6] = new NpgsqlParameter("@jNo", NpgsqlDbType.Integer);
            para[6].Value = jNo;
            cn.ExecuteCmd("addJournalBody", para);
        }

        public DataTable showJournalHeader(int jNo)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[1];
            para[0] = new NpgsqlParameter("@jNo", NpgsqlDbType.Integer);
            para[0].Value = jNo;
            dt = cn.SelectData("showJournalHeader", para);
            return dt;
        }

        public DataTable showJournalBody(int jNo)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[1];
            para[0] = new NpgsqlParameter("@jNo", NpgsqlDbType.Integer);
            para[0].Value = jNo;
            dt = cn.SelectData("showJournalBody", para);
            return dt;
        }

        public DataTable getMaximumJno()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.ClsCN cn = new DAL.ClsCN();
            dt = cn.SelectData("getMaximumJno", null);
            return dt;
        }

        public DataTable getMinimumJno()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DAL.ClsCN cn = new DAL.ClsCN();
            dt = cn.SelectData("getMinimumJno", null);
            return dt;
        }


        public void editJournalHeader(int jNo, DateTime jDate, string jNote, int jType, int jPost, double accDebitor,
            double accCreditor, double accBalance, int userEdit, DateTime editDate, int braCode, int opType)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[12];
            para[0] = new NpgsqlParameter("@jNo", NpgsqlDbType.Integer);
            para[0].Value = jNo;
            para[1] = new NpgsqlParameter("@jDate", NpgsqlDbType.Timestamp);
            para[1].Value = jDate;
            para[2] = new NpgsqlParameter("@jNote", NpgsqlDbType.Varchar, 120);
            para[2].Value = jNote;
            para[3] = new NpgsqlParameter("@jType", NpgsqlDbType.Integer);
            para[3].Value = jType;
            para[4] = new NpgsqlParameter("@jPost", NpgsqlDbType.Integer);
            para[4].Value = jPost;
            para[5] = new NpgsqlParameter("@accDebitor", NpgsqlDbType.Money);
            para[5].Value = accDebitor;
            para[6] = new NpgsqlParameter("@accCreditor", NpgsqlDbType.Money);
            para[6].Value = accCreditor;
            para[7] = new NpgsqlParameter("@accBalance", NpgsqlDbType.Money);
            para[7].Value = accBalance;
            para[8] = new NpgsqlParameter("@userEdit", NpgsqlDbType.Integer);
            para[8].Value = userEdit;
            para[9] = new NpgsqlParameter("@editDate", NpgsqlDbType.Timestamp);
            para[9].Value = editDate;
            para[10] = new NpgsqlParameter("@braCode", NpgsqlDbType.Integer);
            para[10].Value = braCode;
            ;
            para[11] = new NpgsqlParameter("@opType", NpgsqlDbType.Integer);
            para[11].Value = opType;
            cn.ExecuteCmd("editJournalHeader", para);
        }

        public void delJournalbody(int jNo)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[1];
            para[0] = new NpgsqlParameter("@jNo", NpgsqlDbType.Integer);
            para[0].Value = jNo;
            cn.ExecuteCmd("delJournalbody", para);
        }

        public void delJournalEntry(int jNo, int braCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[2];
            para[0] = new NpgsqlParameter("@jNo", NpgsqlDbType.Integer);
            para[0].Value = jNo;
            para[1] = new NpgsqlParameter("@braCode", NpgsqlDbType.Integer);
            para[1].Value = braCode;
            cn.ExecuteCmd("delJournalEntry", para);
        }

        #region Posting

        // Set bounds post
        public DataTable setBondIsPost(int bondPost, long jNo, int braCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter("@bondPost", bondPost),
                new NpgsqlParameter("@jNo", jNo),
                new NpgsqlParameter("@braCode", braCode),
            };

            return cn.SelectData("setBondIsPost", para);
        }

        // Get all journal bounds that are posted or unposted
        public DataTable getPostingBonds(DateTime fromDate, DateTime toDate, int opType, int postStatus, int braCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter("@fromDate", fromDate),
                new NpgsqlParameter("@toDate", toDate),
                new NpgsqlParameter("@opType", opType),
                new NpgsqlParameter("@postStatus", postStatus),
                new NpgsqlParameter("@braCode", braCode),
            };


            return cn.SelectData("getPostingBonds", para);
        }

        // Do posting or undo all determined journal bounds
        public void doBondPosting(long jNo, int postStatus, int opType, int braCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter("@jNo", jNo),
                new NpgsqlParameter("@postStatus", postStatus),
                new NpgsqlParameter("@opType", opType),
                new NpgsqlParameter("@braCode", braCode),
            };

            cn.ExecuteCmd("doBondPosting", para);
        }

        #endregion
    }
}
