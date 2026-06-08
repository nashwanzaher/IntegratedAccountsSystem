using System;
using System.Threading;

namespace IntegratedAccSys.DAL
{
    /// <summary>
    /// Centralized DbContext provider with thread-safe connection management
    /// </summary>
    public sealed class DbContextProvider : IDisposable
    {
        private static readonly Lazy<DbContextProvider> _instance = 
            new Lazy<DbContextProvider>(() => new DbContextProvider(), LazyThreadSafetyMode.ExecutionAndPublication);
        
        private DbContext? _context;
        private int _referenceCount = 0;
        private readonly object _lock = new object();

        public static DbContextProvider Instance => _instance.Value;

        private DbContextProvider() { }

        /// <summary>
        /// Get or create a DbContext instance (thread-safe)
        /// </summary>
        public DbContext GetContext()
        {
            lock (_lock)
            {
                if (_context == null)
                {
                    _context = new DbContext();
                }
                _referenceCount++;
                return _context;
            }
        }

        /// <summary>
        /// Release a reference (call when done with operations)
        /// </summary>
        public void Release()
        {
            lock (_lock)
            {
                _referenceCount--;
                if (_referenceCount <= 0)
                {
                    _context?.Dispose();
                    _context = null;
                    _referenceCount = 0;
                }
            }
        }

        /// <summary>
        /// Execute operation with shared context
        /// </summary>
        public T Execute<T>(Func<DbContext, T> operation)
        {
            var context = GetContext();
            try
            {
                return operation(context);
            }
            finally
            {
                Release();
            }
        }

        /// <summary>
        /// Execute operation with shared context (void)
        /// </summary>
        public void Execute(Action<DbContext> operation)
        {
            var context = GetContext();
            try
            {
                operation(context);
            }
            finally
            {
                Release();
            }
        }

        public void Dispose()
        {
            lock (_lock)
            {
                _context?.Dispose();
                _context = null;
                _referenceCount = 0;
            }
        }
    }
}