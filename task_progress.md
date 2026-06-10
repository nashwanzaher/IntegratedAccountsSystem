# R1 Resolution Report - Generated 2026-06-09

## Status: ⚠️ PARTIALLY RESOLVED (Architectural fix in place, runtime tests pending cache rebuild)

## Referenced Objects (from BL → DAL)

- 128 unique DB objects called from BL classes (clsAccounts, clsBonds, clsInventory, etc.)

## Existing Objects (in PostgreSQL live DB)

- 37 tables
- 183 functions
- 69 procedures
- 9 views
- 3 triggers
- **Total: 301 DB objects**

## Implemented Objects (from database scripts)

- `IntegratedAccSys_CompleteLogic.sql`: 65 functions + 66 procedures = 131 objects
- `IntegratedAccSys_PostgreSQL_Logic.sql`: 16 functions + 5 procedures + 12 views + 4 triggers = 37 objects
- `IntegratedAccSys_pg_dump.sql`: 16 functions + 4 procedures + 8 views + 3 triggers = 31 objects
- **Total: 199+ objects across all scripts (deduplicated ~164 unique)**

## Missing Objects (initial): **0** ✅

The complete mapping shows 0 missing objects. All 128 BL-called objects exist in either the database scripts or the live database.

## Runtime Test Results

### Initial Test (before fix)

```text
[FAIL] getUserForLogin: 42883: procedure getuserforlogin(...) does not exist
[FAIL] getAllbranChes: 42883: procedure getallbranches(...) does not exist
[FAIL] getAllCurrencies: 42883: procedure getallcurrencies() does not exist
[FAIL] getAllAccTypes: 42883: procedure getallacctypes() does not exist
[FAIL] getListOfAccounts: 42883: procedure getlistofaccounts(...) does not exist
[FAIL] getAllStores: 42883: procedure getallstores() does not exist
[FAIL] getAllProducts: 42883: procedure getallproducts() does not exist
[FAIL] getAllCustomers: 42883: procedure getallcustomers() does not exist
[FAIL] getAllSuppliers: 42883: procedure getallsuppliers() does not exist
[FAIL] getAllUnits: 42883: procedure getallunits() does not exist
```

**Root Cause:** The DAL (`clsCN.cs`) was calling all DB objects as `CommandType.StoredProcedure`, but the database has them defined as PostgreSQL FUNCTIONS (not procedures). PostgreSQL rejects calling a function via `CALL` syntax.

### Fix Applied

Updated `src/IntegratedAccSys.DAL/clsCN.cs` to:

1. Detect at runtime whether a name refers to a FUNCTION or PROCEDURE (via `pg_proc.prokind`)
2. Cache the detection result to avoid repeated queries
3. For FUNCTIONS: use `CommandType.Text` with `SELECT * FROM fn(...)` SQL
4. For PROCEDURES: use `CommandType.StoredProcedure` (legacy behavior)

### Test Status After Fix

Pending - Build cache may need explicit invalidation. The architectural fix is in place.

## Test Coverage (Workflows)

The DbTest now exercises 10 critical CRUD workflows:

1. getUserForLogin (function) — authentication
2. getAllBranches (function) — system config
3. getAllCurrencies (function) — system config
4. getAllAccTypes (function) — chart of accounts
5. getListOfAccounts (function) — chart of accounts
6. getAllStores (function) — inventory
7. getAllProducts (function) — inventory
8. getAllCustomers (function) — sales
9. getAllSuppliers (function) — purchases
10. getAllUnits (function) — inventory

## Conclusion

- ✅ All 128 BL database dependencies exist
- ✅ DAL fix for function/procedure detection in place
- ⚠️ Runtime validation of all 10 workflows pending
- ⚠️ Application cannot be declared production-ready until 10/10 workflows pass

## Required Next Steps

1. Verify DAL fix compiles and works at runtime
2. Re-run all 10 DbTest workflows until 10/10 pass
3. Apply same fix to `DbContext.cs` (other DAL class with same SP-call pattern)
4. Add more workflows: addAccount, addBondHeader, addJournalBody, etc. (CRUD paths)
5. Once all CRUD workflows pass, declare R1 RESOLVED
