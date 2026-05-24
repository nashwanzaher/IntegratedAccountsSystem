using System.Data.SqlClient;
using System.Data;

namespace IntegratedAccSys.DAL
{
    /// <summary>
    /// Data access wrapper. IDisposable ensures SqlConnection, SqlCommand,
    /// and SqlDataAdapter are always disposed. callers should wrap usage in
    /// a using block or call Dispose() explicitly.
    /// </summary>
    internal sealed class clsCN : IDisposable
    {
        private SqlConnection? _conn;
        private readonly string _connectionString;

        public clsCN()
        {
            string mode = Properties.Settings.Default.Mode;
            if (mode == "SQL")
            {
                _connectionString =
                    $"server={Properties.Settings.Default.Server};" +
                    $"database={Properties.Settings.Default.DB};" +
                    $"integrated security=false;" +
                    $"User id={Properties.Settings.Default.ID};" +
                    $"password={Properties.Settings.Default.PWD};";
            }
            else
            {
                _connectionString =
                    $"server={Properties.Settings.Default.Server};" +
                    $"database={Properties.Settings.Default.DB};" +
                    $"integrated security=true;";
            }
        }

        /// <summary>
        /// Opens the shared connection. Called before each database operation.
        /// </summary>
        public void Open()
        {
            if (_conn == null)
                _conn = new SqlConnection(_connectionString);
            if (_conn.State != ConnectionState.Open)
                _conn.Open();
        }

        /// <summary>
        /// Closes the shared connection. Called after each database operation.
        /// </summary>
        public void Close()
        {
            if (_conn != null && _conn.State == ConnectionState.Open)
                _conn.Close();
        }

        /// <summary>
        /// Reads data using a stored procedure. SqlCommand and SqlDataAdapter are
        /// created and disposed locally; SqlConnection is opened/closed per call.
        /// </summary>
        public DataTable SelectData(string sp, SqlParameter[]? para)
        {
            Open();
            try
            {
                // SqlCommand and SqlDataAdapter are local — disposed immediately
                // after Fill completes.
                using (SqlCommand cmd = new SqlCommand(sp, _conn!))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    if (para != null)
                        cmd.Parameters.AddRange(para);

                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);
                        return dt;
                    }
                }
            }
            finally
            {
                Close();
            }
        }

        /// <summary>
        /// Executes a stored procedure (insert/update/delete). SqlCommand is created
        /// and disposed locally; SqlConnection is opened/closed per call.
        /// </summary>
        public void ExecuteCmd(string sp, SqlParameter[]? para)
        {
            Open();
            try
            {
                // SqlCommand is local — disposed via using.
                using (SqlCommand cmd = new SqlCommand(sp, _conn!))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    if (para != null)
                        cmd.Parameters.AddRange(para);
                    cmd.ExecuteNonQuery();
                }
            }
            finally
            {
                Close();
            }
        }

        /// <summary>
        /// Reads data using raw SQL text. SqlCommand and SqlDataAdapter are created
        /// and disposed locally; SqlConnection is opened/closed per call.
        /// </summary>
        public DataTable SelectData(string query)
        {
            Open();
            try
            {
                using (SqlCommand cmd = new SqlCommand(query, _conn!))
                {
                    cmd.CommandType = CommandType.Text;
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);
                        return dt;
                    }
                }
            }
            finally
            {
                Close();
            }
        }

        /// <summary>
        /// Executes raw SQL text (insert/update/delete). SqlCommand is created and
        /// disposed locally; SqlConnection is opened/closed per call.
        /// </summary>
        public void ExecuteCmd(string query)
        {
            Open();
            try
            {
                using (SqlCommand cmd = new SqlCommand(query, _conn!))
                {
                    cmd.CommandType = CommandType.Text;
                    cmd.ExecuteNonQuery();
                }
            }
            finally
            {
                Close();
            }
        }

        /// <summary>
        /// Disposes the shared SqlConnection. Call when finished with the instance.
        /// Safe to call multiple times.
        /// </summary>
        public void Dispose()
        {
            if (_conn != null)
            {
                _conn.Dispose();
                _conn = null;
            }
        }
    }
}