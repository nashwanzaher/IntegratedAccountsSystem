# Database Architecture Report

## IntegratedAccountsSystem - 2025-01-19

## Summary

| Item | Count |
|------|-------|
| Tables | 24 |
| Stored Procedures | 130+ |
| Modules | 10 |
| Domains | 7 |

---

## Domains & Tables

### 1. Security Domain

| Table | Primary Key | Foreign Keys |
|-------|-------------|--------------|
| tblUsers | UserCode | - |
| tblSessions | SessionToken | UserCode → tblUsers |
| tblPrivileges | PrivilegeID | UserCode → tblUsers, WindowID → tblWindows |
| tblWindows | WindowID | - |
| tblAuditLogs | AuditID | UserCode → tblUsers |

### 2. Chart of Accounts Domain

| Table | Primary Key | Foreign Keys |
|-------|-------------|--------------|
| tblAccounts | AccountCode | ParentCode → tblAccounts, CurrencyCode → tblCurrencies |

### 3. Financial Transactions Domain

| Table | Primary Key | Foreign Keys |
|-------|-------------|--------------|
| tblBondHeader | BondHeaderID | AccountCode, UserCode, BranchCode |
| tblBondBody | BondBodyID | BondHeaderID, AccountCode |
| tblJournalHeader | JournalHeaderID | UserCode, BranchCode |
| tblJournalBody | JournalBodyID | JournalHeaderID, AccountCode |

### 4. Sales & Purchases Domain

| Table | Primary Key | Foreign Keys |
|-------|-------------|--------------|
| tblCustomers | CustomerCode | - |
| tblSuppliers | SupplierCode | - |
| tblOperationHeader | OperationID | StoreCode, CustomerCode, UserCode, BranchCode |
| tblOperationBody | OperationBodyID | OperationID, ProductCode, UnitCode |

### 5. Inventory Domain

| Table | Primary Key | Foreign Keys |
|-------|-------------|--------------|
| tblStores | StoreCode | - |
| tblCategories | CategoryCode | ParentCategoryCode → tblCategories |
| tblUnits | UnitCode | - |
| tblProducts | ProductCode | CategoryCode, UnitCode |
| tblProductMovement | MovementID | ProductCode, StoreCode, UnitCode |

### 6. System Configuration Domain

| Table | Primary Key | Foreign Keys |
|-------|-------------|--------------|
| tblBranches | BranchCode | - |
| tblFunds | FundCode | BranchCode, AccountCode |
| tblBanks | BankCode | - |
| tblCurrencies | CurrencyCode | - |
| tblPaymentMethods | PaymentMethodCode | AccountCode |

---

## Key Field Types

- Primary Keys: INT IDENTITY, UNIQUEIDENTIFIER
- Password: VARBINARY(8000) with PBKDF2-SHA256 + Salt
- Amounts: DECIMAL(18,4)
- Dates: DATETIME
- Names: NVARCHAR(200)
- Codes: NVARCHAR(50)

---

## PostgreSQL Schema Proposal

\\\sql
-- Create Schemas
CREATE SCHEMA security;
CREATE SCHEMA core;
CREATE SCHEMA finance;
CREATE SCHEMA inventory;
CREATE SCHEMA transactions;
CREATE SCHEMA system;

-- Security Schema
CREATE TABLE security.users (
    user_code SERIAL PRIMARY KEY,
    user_id VARCHAR(15) UNIQUE NOT NULL,
    user_password BYTEA NOT NULL,
    salt BYTEA NOT NULL,
    user_name_ar VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE security.sessions (
    session_token UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_code INTEGER NOT NULL REFERENCES security.users(user_code),
    branch_code INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE security.privileges (
    privilege_id SERIAL PRIMARY KEY,
    user_code INTEGER NOT NULL REFERENCES security.users(user_code),
    window_id INTEGER NOT NULL,
    can_print BOOLEAN DEFAULT FALSE,
    can_display BOOLEAN DEFAULT TRUE,
    can_add BOOLEAN DEFAULT TRUE,
    can_edit BOOLEAN DEFAULT TRUE,
    can_delete BOOLEAN DEFAULT TRUE,
    UNIQUE(user_code, window_id)
);

-- Core Schema (Chart of Accounts)
CREATE TABLE core.accounts (
    account_code SERIAL PRIMARY KEY,
    account_code_no VARCHAR(50) UNIQUE NOT NULL,
    account_name_ar VARCHAR(200) NOT NULL,
    parent_code INTEGER REFERENCES core.accounts(account_code),
    account_nature SMALLINT NOT NULL CHECK (account_nature BETWEEN 1 AND 5),
    account_type INTEGER NOT NULL CHECK (account_type BETWEEN 1 AND 5),
    is_active BOOLEAN DEFAULT TRUE,
    opening_balance DECIMAL(18,4) DEFAULT 0,
    current_balance DECIMAL(18,4) DEFAULT 0
);

-- Finance Schema (Journals & Bonds)
CREATE TABLE finance.journal_headers (
    journal_header_id SERIAL PRIMARY KEY,
    journal_no INTEGER NOT NULL,
    journal_date TIMESTAMP NOT NULL,
    description VARCHAR(500),
    total_debit DECIMAL(18,4) NOT NULL,
    total_credit DECIMAL(18,4) NOT NULL,
    is_posted BOOLEAN DEFAULT FALSE,
    user_code INTEGER NOT NULL REFERENCES security.users(user_code),
    CONSTRAINT chk_journal_balanced CHECK (total_debit = total_credit)
);

CREATE TABLE finance.journal_lines (
    journal_line_id SERIAL PRIMARY KEY,
    journal_header_id INTEGER NOT NULL REFERENCES finance.journal_headers(journal_header_id),
    account_code INTEGER NOT NULL REFERENCES core.accounts(account_code),
    debit_amount DECIMAL(18,4) DEFAULT 0,
    credit_amount DECIMAL(18,4) DEFAULT 0
);

CREATE TABLE finance.bond_headers (
    bond_header_id SERIAL PRIMARY KEY,
    bond_no INTEGER NOT NULL,
    bond_date TIMESTAMP NOT NULL,
    bond_type INTEGER NOT NULL,
    account_code INTEGER NOT NULL REFERENCES core.accounts(account_code),
    total_amount DECIMAL(18,4) NOT NULL,
    is_posted BOOLEAN DEFAULT FALSE,
    user_code INTEGER NOT NULL REFERENCES security.users(user_code),
    branch_code INTEGER
);

CREATE TABLE finance.bond_lines (
    bond_line_id SERIAL PRIMARY KEY,
    bond_header_id INTEGER NOT NULL REFERENCES finance.bond_headers(bond_header_id),
    account_code INTEGER NOT NULL REFERENCES core.accounts(account_code),
    debit_amount DECIMAL(18,4) DEFAULT 0,
    credit_amount DECIMAL(18,4) DEFAULT 0
);

-- Inventory Schema
CREATE TABLE inventory.stores (
    store_code SERIAL PRIMARY KEY,
    store_no VARCHAR(50) UNIQUE,
    store_name_ar VARCHAR(200) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE inventory.categories (
    category_code SERIAL PRIMARY KEY,
    category_no VARCHAR(50) UNIQUE,
    category_name_ar VARCHAR(200) NOT NULL,
    parent_category_code INTEGER REFERENCES inventory.categories(category_code)
);

CREATE TABLE inventory.units (
    unit_code SERIAL PRIMARY KEY,
    unit_no VARCHAR(50) UNIQUE,
    unit_name_ar VARCHAR(100) NOT NULL,
    is_basic_unit BOOLEAN DEFAULT FALSE,
    conversion_factor DECIMAL(18,6) DEFAULT 1
);

CREATE TABLE inventory.products (
    product_code SERIAL PRIMARY KEY,
    product_no VARCHAR(50) UNIQUE,
    product_name_ar VARCHAR(200) NOT NULL,
    category_code INTEGER REFERENCES inventory.categories(category_code),
    unit_code INTEGER REFERENCES inventory.units(unit_code),
    purchase_price DECIMAL(18,6) DEFAULT 0,
    sale_price DECIMAL(18,6) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE inventory.product_movements (
    movement_id BIGSERIAL PRIMARY KEY,
    product_code INTEGER NOT NULL REFERENCES inventory.products(product_code),
    store_code INTEGER NOT NULL REFERENCES inventory.stores(store_code),
    movement_date TIMESTAMP NOT NULL,
    movement_type INTEGER NOT NULL,
    quantity_in DECIMAL(18,6) DEFAULT 0,
    quantity_out DECIMAL(18,6) DEFAULT 0
);

-- Transactions Schema
CREATE TABLE transactions.customers (
    customer_code SERIAL PRIMARY KEY,
    customer_no VARCHAR(50) UNIQUE,
    customer_name_ar VARCHAR(200) NOT NULL,
    credit_limit DECIMAL(18,4) DEFAULT 0,
    current_balance DECIMAL(18,4) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE transactions.suppliers (
    supplier_code SERIAL PRIMARY KEY,
    supplier_no VARCHAR(50) UNIQUE,
    supplier_name_ar VARCHAR(200) NOT NULL,
    credit_limit DECIMAL(18,4) DEFAULT 0,
    current_balance DECIMAL(18,4) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE transactions.operation_headers (
    operation_id SERIAL PRIMARY KEY,
    operation_no INTEGER NOT NULL,
    operation_type INTEGER NOT NULL,
    operation_date TIMESTAMP NOT NULL,
    store_code INTEGER REFERENCES inventory.stores(store_code),
    customer_code INTEGER,
    payment_method_code INTEGER,
    total_amount DECIMAL(18,4) NOT NULL,
    net_amount DECIMAL(18,4) NOT NULL,
    is_posted BOOLEAN DEFAULT FALSE,
    user_code INTEGER NOT NULL REFERENCES security.users(user_code)
);

CREATE TABLE transactions.operation_lines (
    operation_line_id SERIAL PRIMARY KEY,
    operation_id INTEGER NOT NULL REFERENCES transactions.operation_headers(operation_id),
    product_code INTEGER NOT NULL REFERENCES inventory.products(product_code),
    quantity DECIMAL(18,6) NOT NULL,
    unit_code INTEGER REFERENCES inventory.units(unit_code),
    unit_price DECIMAL(18,6) NOT NULL,
    line_total DECIMAL(18,4) NOT NULL
);

-- System Schema
CREATE TABLE system.branches (
    branch_code SERIAL PRIMARY KEY,
    branch_no VARCHAR(50) UNIQUE,
    branch_name_ar VARCHAR(200) NOT NULL,
    is_main_branch BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE system.currencies (
    currency_code SERIAL PRIMARY KEY,
    currency_no VARCHAR(50) UNIQUE,
    currency_name_ar VARCHAR(100) NOT NULL,
    currency_symbol VARCHAR(10) NOT NULL,
    exchange_rate DECIMAL(18,6) DEFAULT 1,
    is_main_currency BOOLEAN DEFAULT FALSE
);

CREATE TABLE system.payment_methods (
    payment_method_code SERIAL PRIMARY KEY,
    payment_method_name_ar VARCHAR(100) NOT NULL,
    account_code INTEGER REFERENCES core.accounts(account_code),
    is_active BOOLEAN DEFAULT TRUE
);

-- Indexes
CREATE INDEX idx_sessions_user ON security.sessions(user_code);
CREATE INDEX idx_accounts_parent ON core.accounts(parent_code);
CREATE INDEX idx_journals_date ON finance.journal_headers(journal_date);
CREATE INDEX idx_movements_product ON inventory.product_movements(product_code);
CREATE INDEX idx_movements_date ON inventory.product_movements(movement_date);
\\\

---

## SQL Server → PostgreSQL Mapping

| SQL Server | PostgreSQL |
|------------|------------|
| NVARCHAR | VARCHAR |
| DATETIME | TIMESTAMP |
| INT IDENTITY | SERIAL |
| BIGINT IDENTITY | BIGSERIAL |
| BIT | BOOLEAN |
| VARBINARY | BYTEA |
| UNIQUEIDENTIFIER | UUID |
| GETDATE() | CURRENT_TIMESTAMP |
| ISNULL() | COALESCE() |

---

## Gap Analysis

### Missing Features

- Projects Management Module
- Fixed Assets Management
- Employee Management
- Multi-branch Consolidation
- REST API for Integration
- Redis Caching Layer
- Table Partitioning by Date

### Performance Issues

- Missing composite indexes on frequently queried columns
- No query optimization hints
- No caching layer for reference data

### Security Gaps

- No 2FA support
- No IP whitelist
- No API key authentication

---

## ERD (Entity Relationship Diagram)

\\\
┌─────────────────────────────────────────────────────────────────────────┐
│                            SECURITY DOMAIN                               │
│  ┌─────────┐      ┌────────────┐      ┌──────────────┐      ┌─────────┐  │
│  │ tblUsers │───< │tblSessions │      │tblPrivileges│───<  │tblWindow│  │
│  └─────────┘      └────────────┘      └──────────────┘      └─────────┘  │
│       │                                        │                          │
│       └──────────────────────────────────────>┘                          │
│       │                                                                 │
│  ┌─────────────┐                                                        │
│  │tblAuditLogs│                                                        │
│  └─────────────┘                                                        │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                         CHART OF ACCOUNTS                                │
│  ┌─────────────────────────────────────────────────────┐                │
│  │                    tblAccounts                       │                │
│  │              (Self-Referential Tree)                │                │
│  │              ParentCode → AccountCode                │                │
│  └─────────────────────────────────────────────────────┘                │
│       │                           │                                        │
│       │  ┌────────────┐     ┌─────────────┐                             │
│       └──│tblBondHdr │────<│tblBondBody  │                             │
│          └────────────┘     └─────────────┘                             │
│       │                                                                  │
│       │  ┌─────────────┐     ┌─────────────┐                            │
│       └──│tblJournalHdr│────<│tblJournalLin│                            │
│          └─────────────┘     └─────────────┘                            │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                            INVENTORY DOMAIN                              │
│  ┌──────────┐     ┌─────────────────────┐     ┌───────────┐             │
│  │tblStores │───< │tblProductMovement  │     │tblProducts│             │
│  └──────────┘     └─────────────────────┘     └───────────┘             │
│                                                  │                       │
│                    ┌────────────┐           ┌─────────┐                  │
│                    │tblCategories│───────<  │tblUnits │                  │
│                    │(Self-Ref)   │          └─────────┘                  │
│                    └────────────┘                                        │
│                           │                                              │
│  ┌───────────────────────┼───────────────────────────────────────┐    │
│  │ TRANSACTIONS DOMAIN   │                                         │    │
│  │  ┌─────────────────────┐     ┌─────────────────────┐           │    │
│  │  │tblOperationHeader   │────< │tblOperationBody    │           │    │
│  │  └─────────────────────┘     └─────────────────────┘           │    │
│  │         │                                                        │    │
│  │  ┌────────────┐     ┌────────────┐                              │    │
│  │  │tblCustomer │     │tblSupplier │                              │    │
│  │  └────────────┘     └────────────┘                              │    │
│  └────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                         SYSTEM CONFIG DOMAIN                             │
│  ┌───────────┐     ┌─────────┐     ┌─────────┐     ┌───────────────┐    │
│  │tblBranches│───< │tblFunds │     │tblBanks │     │tblPaymentMthd │    │
│  └───────────┘     └─────────┘     └─────────┘     └───────────────┘    │
│                                               │                    │    │
│                                         ┌─────────────┐          │    │
│                                         │tblCurrencies│          │    │
│                                         └─────────────┘          │    │
│                                                                    │    │
│                                      tblAccounts (Fund/Pmt Account)─┘    │
└─────────────────────────────────────────────────────────────────────────┘
\\\

---

**End of Report**
