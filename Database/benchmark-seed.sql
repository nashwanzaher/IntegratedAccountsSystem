-- Fast seed using generate_series + INSERT ... SELECT
DO $$
DECLARE
    v_customerid INTEGER;
    v_productid INTEGER;
    v_branchcode INTEGER;
    v_currid INTEGER;
    v_accountcode INTEGER;
BEGIN
    SELECT customercode INTO v_customerid FROM tblcustomers LIMIT 1;
    SELECT productcode INTO v_productid FROM tblproducts LIMIT 1;
    SELECT branchcode INTO v_branchcode FROM tblbranches LIMIT 1;
    SELECT currencycode INTO v_currid FROM tblcurrencies LIMIT 1;
    SELECT accountcode INTO v_accountcode FROM tblaccounts LIMIT 1;

    IF v_currid IS NULL THEN INSERT INTO tblcurrencies (currencyid, currencynamear) VALUES ('SAR', 'ريال سعودي') ON CONFLICT DO NOTHING RETURNING currencycode INTO v_currid; END IF;
    IF v_customerid IS NULL THEN INSERT INTO tblcustomers (customerid, customernamear) VALUES ('BENCH-CUST', 'Benchmark Customer') ON CONFLICT DO NOTHING; SELECT customercode INTO v_customerid FROM tblcustomers WHERE customerid = 'BENCH-CUST'; END IF;
    IF v_branchcode IS NULL THEN INSERT INTO tblbranches (branchid, branchnamear) VALUES ('BENCH-BR', 'Benchmark Branch') ON CONFLICT DO NOTHING; SELECT branchcode INTO v_branchcode FROM tblbranches WHERE branchid = 'BENCH-BR'; END IF;
    IF v_accountcode IS NULL THEN INSERT INTO tblaccounts (accountid, accountnamear, accounttype, accountnature) VALUES ('BENCH-ACC', 'Benchmark Account', 'ASSET', 'DEBIT') ON CONFLICT DO NOTHING; SELECT accountcode INTO v_accountcode FROM tblaccounts WHERE accountid = 'BENCH-ACC'; END IF;

    -- Insert 50K bonds in batches using INSERT ... SELECT
    INSERT INTO tblbondheader (bondid, bondtype, bonddate, fiscalyear, fiscalperiod, amount, currencycode, exchangerate, customercode, accountcode, description, createdby)
    SELECT
        'BENCH-B-' || gs,
        CASE WHEN gs % 2 = 0 THEN 'SALE' ELSE 'PURCHASE' END,
        (CURRENT_DATE - ((gs % 365) || ' days')::interval)::date,
        2026, ((gs % 12) + 1), (gs * 100)::numeric,
        v_currid, 1.0, v_customerid, v_accountcode,
        'Benchmark bond ' || gs, 1
    FROM generate_series(1, 50000) AS gs
    ON CONFLICT (bondid) DO NOTHING;

    RAISE NOTICE 'Bonds inserted';

    INSERT INTO tbljournalheader (journalid, journaldate, fiscalyear, fiscalperiod, description, totaldebit, totalcredit, currencycode, exchangerate, accountcode, createdby)
    SELECT
        'BENCH-J-' || gs,
        (CURRENT_DATE - ((gs % 365) || ' days')::interval)::date,
        2026, ((gs % 12) + 1), 'Benchmark journal ' || gs,
        (gs * 50)::numeric, (gs * 50)::numeric,
        v_currid, 1.0, v_accountcode, 1
    FROM generate_series(1, 50000) AS gs
    ON CONFLICT (journalid) DO NOTHING;

    RAISE NOTICE 'Journals inserted';
END $$;

SELECT 'bonds' AS entity, COUNT(*) AS total FROM tblbondheader
UNION ALL SELECT 'journals', COUNT(*) FROM tbljournalheader
ORDER BY entity;
