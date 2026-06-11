using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Text.RegularExpressions;
using Npgsql;
using NpgsqlTypes;

namespace IntegratedAccSys.DAL
{
    /// <summary>
    /// PostgreSQL data access wrapper. Mirrors the SQL Server clsCN API
    /// (SelectData / ExecuteCmd) but uses Npgsql and supports both stored
    /// procedures and SQL functions. Callers should use a using block
    /// or call Dispose() explicitly.
    ///
    /// Strategy: try as STORED PROCEDURE first (original SQL Server semantics),
    /// and if that fails because the name refers to a FUNCTION, fall back to
    /// SELECT * FROM fn(args). Parameters are cloned for each attempt.
    /// </summary>
    public sealed class ClsCN : IDisposable
    {
        private NpgsqlConnection? _conn;
        private readonly string _connectionString;

        // ─── Object-type cache (performance optimization) ───────────────────
        // The auto-dispatch logic (try procedure → fall back to function) makes
        // 1 wasted round-trip on the first call for every new DB object name.
        // To eliminate that cost, we cache the pg_proc.prokind value ('f' or 'p')
        // per identifier. Lookup is O(1) and thread-safe.
        private static readonly ConcurrentDictionary<string, char> _objectKindCache = new(StringComparer.OrdinalIgnoreCase);

        /// <summary>
        /// Resolves a DB object name to its pg_proc.prokind:
        ///   'f' = function  → use SELECT * FROM fn(args)
        ///   'p' = procedure → use CALL proc(args)
        ///   '?' = unknown    → will fall back to auto-dispatch (try procedure first)
        /// Cached results are reused across all clsCN instances.
        /// </summary>
        private static char ResolveObjectKind(string name, NpgsqlConnection conn)
        {
            if (_objectKindCache.TryGetValue(name, out var cached))
                return cached;

            try
            {
                using var probe = new NpgsqlCommand(
                    "SELECT prokind FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid " +
                    "WHERE n.nspname = 'public' AND p.proname = @n LIMIT 1",
                    conn);
                probe.Parameters.AddWithValue("@n", name);
                var result = probe.ExecuteScalar();
                char kind = result switch
                {
                    'f' => 'f',
                    'p' => 'p',
                    _ => '?'
                };
                _objectKindCache.TryAdd(name, kind);
                return kind;
            }
            catch
            {
                return '?'; // Fall through to auto-dispatch
            }
        }

        /// <summary>
        /// Clears the static object-kind cache. Useful in tests or after schema changes.
        /// </summary>
        public static void ClearObjectKindCache() => _objectKindCache.Clear();

        public ClsCN()
        {
            string mode = DalSettings.Mode;
            if (mode == "SQL")
            {
                _connectionString =
                    $"Host={DalSettings.Server};" +
                    $"Port={(string.IsNullOrEmpty(DalSettings.Port) ? "5432" : DalSettings.Port)};" +
                    $"Database={DalSettings.DB};" +
                    $"Username={DalSettings.ID};" +
                    $"Password={DalSettings.PWD};" +
                    $"Include Error Detail=true;";
            }
            else
            {
                _connectionString =
                    $"Host={DalSettings.Server};" +
                    $"Port={(string.IsNullOrEmpty(DalSettings.Port) ? "5432" : DalSettings.Port)};" +
                    $"Database={DalSettings.DB};" +
                    $"Integrated Security=true;";
            }
        }

        public void Open()
        {
            if (_conn == null)
                _conn = new NpgsqlConnection(_connectionString);
            if (_conn.State != ConnectionState.Open)
                _conn.Open();
        }

        public void Close()
        {
            if (_conn != null && _conn.State == ConnectionState.Open)
                _conn.Close();
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
                    if (i > 0)
                        sb.Append(", ");
                    sb.Append('@');
                    sb.Append(para[i].ParameterName.TrimStart('@'));
                }
            }
            sb.Append(')');
            return sb.ToString();
        }

        private static NpgsqlParameter[] CloneParameters(NpgsqlParameter[]? src)
        {
            if (src == null)
                return Array.Empty<NpgsqlParameter>();
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

        public DataTable SelectData(string sp, NpgsqlParameter[]? para)
        {
            Open();
            try
            {
                // ─── Fast path: cache hit ──────────────────────────────────────
                char cachedKind = ResolveObjectKind(sp, _conn!);
                if (cachedKind == 'f')
                {
                    // Known FUNCTION — skip the procedure attempt entirely
                    using (NpgsqlCommand cmd = new NpgsqlCommand(sp, _conn!))
                    {
                        cmd.CommandType = CommandType.Text;
                        cmd.CommandText = BuildFunctionCall(sp, para);
                        if (para != null)
                            cmd.Parameters.AddRange(CloneParameters(para));

                        using (NpgsqlDataAdapter sda = new NpgsqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            sda.Fill(dt);
                            return dt;
                        }
                    }
                }
                if (cachedKind == 'p')
                {
                    // Known PROCEDURE — direct call, no fallback needed
                    using (NpgsqlCommand cmd = new NpgsqlCommand(sp, _conn!))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        if (para != null)
                            cmd.Parameters.AddRange(CloneParameters(para));

                        using (NpgsqlDataAdapter sda = new NpgsqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            sda.Fill(dt);
                            return dt;
                        }
                    }
                }

                // ─── Slow path: cache miss — try procedure, fall back to function ─
                try
                {
                    using (NpgsqlCommand cmd = new NpgsqlCommand(sp, _conn!))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        if (para != null)
                            cmd.Parameters.AddRange(CloneParameters(para));

                        using (NpgsqlDataAdapter sda = new NpgsqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            sda.Fill(dt);
                            // Remember: this name is a procedure
                            _objectKindCache.TryAdd(sp, 'p');
                            return dt;
                        }
                    }
                }
                catch (Exception procEx) when (procEx.Message.Contains("does not exist", StringComparison.OrdinalIgnoreCase)
                                                || procEx.Message.Contains("42883")
                                                || procEx.Message.Contains("42809")
                                                || procEx.Message.Contains("is not a procedure", StringComparison.OrdinalIgnoreCase))
                {
                    using (NpgsqlCommand cmd = new NpgsqlCommand(sp, _conn!))
                    {
                        cmd.CommandType = CommandType.Text;
                        cmd.CommandText = BuildFunctionCall(sp, para);
                        if (para != null)
                            cmd.Parameters.AddRange(CloneParameters(para));

                        using (NpgsqlDataAdapter sda = new NpgsqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            sda.Fill(dt);
                            // Remember: this name is a function
                            _objectKindCache.TryAdd(sp, 'f');
                            return dt;
                        }
                    }
                }
            }
            finally
            {
                Close();
            }
        }

        public void ExecuteCmd(string sp, NpgsqlParameter[]? para)
        {
            Open();
            try
            {
                // ─── Fast path: cache hit ──────────────────────────────────────
                char cachedKind = ResolveObjectKind(sp, _conn!);
                if (cachedKind == 'f')
                {
                    using (NpgsqlCommand cmd = new NpgsqlCommand(sp, _conn!))
                    {
                        cmd.CommandType = CommandType.Text;
                        cmd.CommandText = BuildFunctionCall(sp, para);
                        if (para != null)
                            cmd.Parameters.AddRange(CloneParameters(para));
                        cmd.ExecuteNonQuery();
                        return;
                    }
                }
                if (cachedKind == 'p')
                {
                    using (NpgsqlCommand cmd = new NpgsqlCommand(sp, _conn!))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        if (para != null)
                            cmd.Parameters.AddRange(CloneParameters(para));
                        cmd.ExecuteNonQuery();
                        return;
                    }
                }

                // ─── Slow path: cache miss — try procedure, fall back to function ─
                try
                {
                    using (NpgsqlCommand cmd = new NpgsqlCommand(sp, _conn!))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        if (para != null)
                            cmd.Parameters.AddRange(CloneParameters(para));
                        cmd.ExecuteNonQuery();
                        _objectKindCache.TryAdd(sp, 'p');
                        return;
                    }
                }
                catch (Exception procEx) when (procEx.Message.Contains("does not exist", StringComparison.OrdinalIgnoreCase)
                                                || procEx.Message.Contains("42883")
                                                || procEx.Message.Contains("42809")
                                                || procEx.Message.Contains("is not a procedure", StringComparison.OrdinalIgnoreCase))
                {
                    using (NpgsqlCommand cmd = new NpgsqlCommand(sp, _conn!))
                    {
                        cmd.CommandType = CommandType.Text;
                        cmd.CommandText = BuildFunctionCall(sp, para);
                        if (para != null)
                            cmd.Parameters.AddRange(CloneParameters(para));
                        cmd.ExecuteNonQuery();
                        _objectKindCache.TryAdd(sp, 'f');
                    }
                }
            }
            finally
            {
                Close();
            }
        }

        public DataTable SelectData(string query)
        {
            ValidateSafeIdentifier(query, "SelectData");
            Open();
            try
            {
                using (NpgsqlCommand cmd = new NpgsqlCommand(query, _conn!))
                {
                    cmd.CommandType = CommandType.Text;
                    using (NpgsqlDataAdapter sda = new NpgsqlDataAdapter(cmd))
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

        public void ExecuteCmd(string query)
        {
            ValidateSafeIdentifier(query, "ExecuteCmd");
            Open();
            try
            {
                using (NpgsqlCommand cmd = new NpgsqlCommand(query, _conn!))
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

        private static void ValidateSafeIdentifier(string query, string methodName)
        {
            if (string.IsNullOrWhiteSpace(query))
                throw new SqlInjectionException($"[{methodName}] Empty identifier.");

            if (query.Length > 128)
                throw new SqlInjectionException($"[{methodName}] Identifier exceeds 128 chars.");

            if (!Regex.IsMatch(query, @"^[a-zA-Z_][a-zA-Z0-9_]*$"))
                throw new SqlInjectionException($"[{methodName}] Invalid identifier format.");

            string lower = query.ToLowerInvariant();
            string[] blocked = {
                "select", "insert", "update", "delete", "drop", "create",
                "alter", "truncate", "exec", "union", "where", "--", "/*", "*/",
                ";", "0x", "'", "\"", "information_schema"
            };
            foreach (var p in blocked)
                if (lower.Contains(p))
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
