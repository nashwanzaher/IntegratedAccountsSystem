using System;
using System.Data;
using Npgsql;
using NpgsqlTypes;
using System.Text;

namespace IntegratedAccSys.DAL
{
    public sealed class DbContext : IDisposable
    {
        private NpgsqlConnection? _connection;
        private NpgsqlTransaction? _transaction;
        private bool _disposed;

        public NpgsqlConnection Connection =>
            _connection ?? throw new ObjectDisposedException(nameof(DbContext));
        public bool IsTransactionActive => _transaction != null;
        public bool IsConnectionOpen => _connection?.State == ConnectionState.Open;

        public DbContext()
        {
            _connection = new NpgsqlConnection(GetConnectionString());
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

        private static string BuildFunctionCall(string functionName, NpgsqlParameter[]? para)
        {
            var sb = new StringBuilder("SELECT * FROM ");
            sb.Append(functionName);
            sb.Append('(');
            if (para != null && para.Length > 0)
            {
                for (int i = 0; i < para.Length; i++)
                {
                    if (i > 0) sb.Append(", ");
                    sb.Append('@');
                    sb.Append(para[i].ParameterName.TrimStart('@'));
                }
            }
            sb.Append(')');
            return sb.ToString();
        }

        /// <summary>
        /// Clones a parameter array so the new parameters can be added to a
        /// different NpgsqlCommand without "already belongs to a collection" errors.
        /// </summary>
        private static NpgsqlParameter[] CloneParameters(NpgsqlParameter[]? src)
        {
            if (src == null) return Array.Empty<NpgsqlParameter>();
            var dest = new NpgsqlParameter[src.Length];
            for (int i = 0; i < src.Length; i++)
            {
                var p = src[i];
                dest[i] = new NpgsqlParameter(p.ParameterName, p.NpgsqlDbType)
                {
                    Value = p.Value,
                    Direction = p.Direction,
                    Size = p.Size,
                    IsNullable = p.IsNullable
                };
            }
            return dest;
        }

        public DataTable SelectData(string sp, NpgsqlParameter[]? parameters = null)
        {
            Open();
            try
            {
                // Try as PROCEDURE first
                try
                {
                    using var cmd = new NpgsqlCommand(sp, _connection, _transaction)
                    {
                        CommandType = CommandType.StoredProcedure
                    };
                    if (parameters != null) cmd.Parameters.AddRange(CloneParameters(parameters));
                    using var adapter = new NpgsqlDataAdapter(cmd);
                    var dt = new DataTable();
                    adapter.Fill(dt);
                    return dt;
                }
                catch (Exception procEx) when (procEx.Message.Contains("does not exist", StringComparison.OrdinalIgnoreCase)
                                                || procEx.Message.Contains("42883")
                                                || procEx.Message.Contains("42809")
                                                || procEx.Message.Contains("is not a procedure", StringComparison.OrdinalIgnoreCase))
                {
                    // Fallback: it's a FUNCTION
                    using var cmd = new NpgsqlCommand(sp, _connection, _transaction)
                    {
                        CommandType = CommandType.Text,
                        CommandText = BuildFunctionCall(sp, parameters)
                    };
                    if (parameters != null) cmd.Parameters.AddRange(CloneParameters(parameters));
                    using var adapter = new NpgsqlDataAdapter(cmd);
                    var dt = new DataTable();
                    adapter.Fill(dt);
                    return dt;
                }
            }
            finally
            {
                Close();
            }
        }

        public int Execute(string sp, NpgsqlParameter[]? parameters = null)
        {
            Open();
            try
            {
                try
                {
                    using var cmd = new NpgsqlCommand(sp, _connection, _transaction)
                    {
                        CommandType = CommandType.StoredProcedure
                    };
                    if (parameters != null) cmd.Parameters.AddRange(CloneParameters(parameters));
                    return cmd.ExecuteNonQuery();
                }
                catch (Exception procEx) when (procEx.Message.Contains("does not exist", StringComparison.OrdinalIgnoreCase)
                                                || procEx.Message.Contains("42883")
                                                || procEx.Message.Contains("42809")
                                                || procEx.Message.Contains("is not a procedure", StringComparison.OrdinalIgnoreCase))
                {
                    using var cmd = new NpgsqlCommand(sp, _connection, _transaction)
                    {
                        CommandType = CommandType.Text,
                        CommandText = BuildFunctionCall(sp, parameters)
                    };
                    if (parameters != null) cmd.Parameters.AddRange(CloneParameters(parameters));
                    return cmd.ExecuteNonQuery();
                }
            }
            finally
            {
                Close();
            }
        }

        public object? ExecuteScalar(string sp, NpgsqlParameter[]? parameters = null)
        {
            Open();
            try
            {
                try
                {
                    using var cmd = new NpgsqlCommand(sp, _connection, _transaction)
                    {
                        CommandType = CommandType.StoredProcedure
                    };
                    if (parameters != null) cmd.Parameters.AddRange(CloneParameters(parameters));
                    return cmd.ExecuteScalar();
                }
                catch (Exception procEx) when (procEx.Message.Contains("does not exist", StringComparison.OrdinalIgnoreCase)
                                                || procEx.Message.Contains("42883")
                                                || procEx.Message.Contains("42809")
                                                || procEx.Message.Contains("is not a procedure", StringComparison.OrdinalIgnoreCase))
                {
                    using var cmd = new NpgsqlCommand(sp, _connection, _transaction)
                    {
                        CommandType = CommandType.Text,
                        CommandText = BuildFunctionCall(sp, parameters)
                    };
                    if (parameters != null) cmd.Parameters.AddRange(CloneParameters(parameters));
                    return cmd.ExecuteScalar();
                }
            }
            finally
            {
                Close();
            }
        }

        public DataTable ExecuteRawSql(string query)
        {
            ValidateSqlQuery(query);
            Open();
            using var cmd = new NpgsqlCommand(query, _connection, _transaction)
            {
                CommandType = CommandType.Text
            };
            using var adapter = new NpgsqlDataAdapter(cmd);
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
            var blocked = new[] { ";", "--", "'", "\"", "/*", "*/" };
            foreach (var p in blocked)
                if (query.Contains(p))
                    throw new ArgumentException($"Potentially dangerous SQL pattern: {p}", nameof(query));
        }

        private static string GetConnectionString()
        {
            return DalSettings.Mode == "SQL"
                ? $"Host={DalSettings.Server};Port={(string.IsNullOrEmpty(DalSettings.Port) ? "5432" : DalSettings.Port)};Database={DalSettings.DB};Username={DalSettings.ID};Password={DalSettings.PWD};Include Error Detail=true;"
                : $"Host={DalSettings.Server};Port={(string.IsNullOrEmpty(DalSettings.Port) ? "5432" : DalSettings.Port)};Database={DalSettings.DB};Integrated Security=true;";
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
