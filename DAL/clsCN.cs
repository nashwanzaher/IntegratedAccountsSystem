using System.Data.SqlClient;
using System.Data;
using System.Text.RegularExpressions;

namespace IntegratedAccSys.DAL
{
    /// <summary>
    /// Data access wrapper. IDisposable ensures SqlConnection, SqlCommand,
    /// and SqlDataAdapter are always disposed. Callers should wrap usage in
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

        public void Open()
        {
            if (_conn == null)
                _conn = new SqlConnection(_connectionString);
            if (_conn.State != ConnectionState.Open)
                _conn.Open();
        }

        public void Close()
        {
            if (_conn != null && _conn.State == ConnectionState.Open)
                _conn.Close();
        }

        public DataTable SelectData(string sp, SqlParameter[]? para)
        {
            Open();
            try
            {
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

        public void ExecuteCmd(string sp, SqlParameter[]? para)
        {
            Open();
            try
            {
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
        /// Reads data using raw SQL text. Now validates stored procedure names.
        /// </summary>
        public DataTable SelectData(string query)
        {
            ValidateStoredProcedureCall(query, "SelectData");
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
        /// Executes raw SQL text. Now validates stored procedure names.
        /// </summary>
        public void ExecuteCmd(string query)
        {
            ValidateStoredProcedureCall(query, "ExecuteCmd");
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
        /// Validates that the input is a valid stored procedure name.
        /// Rejects raw SQL queries to prevent SQL injection attacks.
        /// </summary>
        private static void ValidateStoredProcedureCall(string query, string methodName)
        {
            if (string.IsNullOrWhiteSpace(query))
                throw new SqlInjectionException($"[{methodName}] Empty procedure name.");

            if (query.Length > 128)
                throw new SqlInjectionException($"[{methodName}] Name exceeds 128 chars.");

            if (!Regex.IsMatch(query, @"^[a-zA-Z_][a-zA-Z0-9_]*$"))
                throw new SqlInjectionException($"[{methodName}] Invalid procedure format.");

            string upper = query.ToUpperInvariant();
            string[] blocked = { "SELECT", "INSERT", "UPDATE", "DELETE", "DROP", "CREATE", 
                "ALTER", "TRUNCATE", "EXEC", "UNION", "WHERE", "--", "/*", "*/", ";", 
                "xp_", "sp_", "0x", "'", "\"", "INFORMATION_SCHEMA" };
            
            foreach (var p in blocked)
                if (upper.Contains(p))
                    throw new SqlInjectionException($"[{methodName}] Blocked pattern: {p}");
        }

        public void Dispose()
        {
            if (_conn != null)
            {
                _conn.Dispose();
                _conn = null;
            }
        }
    }

    /// <summary>
    /// Exception thrown when SQL injection patterns are detected.
    /// </summary>
    public class SqlInjectionException : Exception
    {
        public SqlInjectionException() { }
        public SqlInjectionException(string message) : base(message) { }
        public SqlInjectionException(string message, Exception inner) : base(message, inner) { }
    }
}