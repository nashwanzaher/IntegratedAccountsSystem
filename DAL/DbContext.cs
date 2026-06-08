using System;
using System.Data;
using System.Data.SqlClient;
using System.Text.RegularExpressions;

namespace IntegratedAccSys.DAL
{
    public sealed class DbContext : IDisposable
    {
        private SqlConnection? _connection;
        private SqlTransaction? _transaction;
        private bool _disposed;

        public SqlConnection Connection => _connection ?? throw new ObjectDisposedException(nameof(DbContext));
        public bool IsTransactionActive => _transaction != null;
        public bool IsConnectionOpen => _connection?.State == ConnectionState.Open;

        public DbContext()
        {
            _connection = new SqlConnection(GetConnectionString());
        }

        public void Open()
        {
            if (_connection?.State != ConnectionState.Open)
                _connection?.Open();
        }

        public void Close()
        {
            if (_connection?.State == ConnectionState.Open)
                _connection?.Close();
        }

        public void BeginTransaction()
        {
            Open();
            _transaction = _connection!.BeginTransaction();
        }

        public void CommitTransaction()
        {
            _transaction?.Commit();
            _transaction = null;
        }

        public void RollbackTransaction()
        {
            _transaction?.Rollback();
            _transaction = null;
        }

        public DataTable SelectData(string sp, SqlParameter[]? parameters = null)
        {
            Open();
            using var cmd = new SqlCommand(sp, _connection!, _transaction)
            {
                CommandType = CommandType.StoredProcedure
            };
            if (parameters != null)
                cmd.Parameters.AddRange(parameters);
            using var adapter = new SqlDataAdapter(cmd);
            var dt = new DataTable();
            adapter.Fill(dt);
            return dt;
        }

        public int Execute(string sp, SqlParameter[]? parameters = null)
        {
            Open();
            using var cmd = new SqlCommand(sp, _connection!, _transaction)
            {
                CommandType = CommandType.StoredProcedure
            };
            if (parameters != null)
                cmd.Parameters.AddRange(parameters);
            return cmd.ExecuteNonQuery();
        }

        public object? ExecuteScalar(string sp, SqlParameter[]? parameters = null)
        {
            Open();
            using var cmd = new SqlCommand(sp, _connection!, _transaction)
            {
                CommandType = CommandType.StoredProcedure
            };
            if (parameters != null)
                cmd.Parameters.AddRange(parameters);
            return cmd.ExecuteScalar();
        }

        public DataTable ExecuteRawSql(string query)
        {
            ValidateSqlQuery(query);
            Open();
            using var cmd = new SqlCommand(query, _connection!, _transaction)
            {
                CommandType = CommandType.Text
            };
            using var adapter = new SqlDataAdapter(cmd);
            var dt = new DataTable();
            adapter.Fill(dt);
            return dt;
        }

        private static void ValidateSqlQuery(string query)
        {
            if (string.IsNullOrWhiteSpace(query))
                throw new ArgumentException("Query cannot be empty.", nameof(query));
            if (query.Length > 10000)
                throw new ArgumentException("Query exceeds maximum length.", nameof(query));
            string pattern = @"(?i)(\bDROP\b|\bDELETE\b|\bTRUNCATE\b|\bALTER\b|\bINSERT\b|\bUPDATE\b|\bEXEC\b|\bEXECUTE\b|--|\bUNION\b|;|'";
            if (Regex.IsMatch(query, pattern))
                throw new ArgumentException("Potentially dangerous SQL detected.", nameof(query));
        }

        private static string GetConnectionString()
        {
            return System.Configuration.ConfigurationManager.ConnectionStrings["MyDB"]?.ConnectionString
                ?? "Data Source=.\\SQLEXPRESS;Initial Catalog=IntegratedAccSys;Integrated Security=True;Encrypt=False";
        }

        public void Dispose()
        {
            if (_disposed) return;
            _transaction?.Dispose();
            _connection?.Dispose();
            _disposed = true;
        }
    }
}