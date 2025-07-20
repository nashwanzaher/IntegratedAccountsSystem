using System.Data.SqlClient;
using System.Data;

namespace IntegratedAccSys.DAL
{
    internal class clsCN
    {
        SqlConnection conn;
        SqlCommand cmd;
        SqlDataAdapter sda;
        DataTable dt;

        public clsCN()
        {
            string Mode = Properties.Settings.Default.Mode;
            if (Mode == "SQL")
            {
                conn = new SqlConnection(@"server=" + Properties.Settings.Default.Server + ";database=" + Properties.Settings.Default.DB + ";integrated security=false;User id =" + Properties.Settings.Default.ID + ";password=" + Properties.Settings.Default.PWD + ";"); 
            }
            else
            {
                conn = new SqlConnection(@"server=" + Properties.Settings.Default.Server + ";database=" + Properties.Settings.Default.DB + ";integrated security=true;");
            }
        }

        //method to open connection
        public void Open()
        {
            if (conn.State != ConnectionState.Open)
            {
                conn.Open();
            }
        }
        //method to close connection
        public void Close()
        {
            if (conn.State == ConnectionState.Open)
            {
                conn.Close();
            }
        }

        //method to read data from database using stored procedure

        public DataTable SelectData(string sp, SqlParameter[] para)
        {
            cmd = new SqlCommand();
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.CommandText = sp;
            cmd.Connection = conn;
            if (para!=null)
            {
                cmd.Parameters.AddRange(para);
            }
            
            sda =new SqlDataAdapter(cmd);
            dt = new DataTable();
            dt.Clear();
            Open();
            sda.Fill(dt);
            Close();
            return dt;
            

        }


        //method to insert ,update or Delete data from database using stored procedure

        public void ExecuteCmd(string sp, SqlParameter[] para)
        {
            cmd = new SqlCommand();
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.CommandText = sp;
            cmd.Connection = conn;
            if (para != null)
            {
                cmd.Parameters.AddRange(para);
            }
            Open();
            cmd.ExecuteNonQuery();
            Close();

        }



        //method to read data from database using Query Text

        public DataTable SelectData(string query)
        {
            cmd = new SqlCommand();
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = query;
            cmd.Connection = conn;
            
            sda = new SqlDataAdapter(cmd);
            dt = new DataTable();
            dt.Clear();
            Open();
            sda.Fill(dt);
            Close();
            return dt;


        }


        //method to insert ,update or Delete data from database using Query Text

        public void ExecuteCmd(string Query)
        {
            cmd = new SqlCommand();
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = Query;
            cmd.Connection = conn;
            Open();
            cmd.ExecuteNonQuery();
            Close();


        }



    }
}
