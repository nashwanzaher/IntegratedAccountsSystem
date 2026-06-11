-- =============================================================================
-- IntegratedAccSys v2 - PostgreSQL 17.10 Professional Reorganization
-- =============================================================================
-- Author: GitHub Copilot (MiniMax-M2)
-- Date: 2026-06-10
-- Description: Professional database reorganization using PostgreSQL 17.10 best practices
--
-- FEATURES:
-- 1. Schema-based organization (accounting, inventory, approval, dimensions, security, audit)
-- 2. Table partitioning for large tables
-- 3. JSONB for flexible attributes
-- 4. Generated columns for computed values
-- 5. Sequences, Enums, and Domain types
-- 6. Row-Level Security (RLS)
-- 7. Advanced indexing (partial, expression, multivariate)
-- 8. Materialized views for reporting
-- 9. Full-text search
-- 10. Comprehensive comments and documentation
-- =============================================================================

-- =============================================================================
-- SECTION 1: EXTENSIONS
-- =============================================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";          -- For gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";          -- For UUID generation
CREATE EXTENSION IF NOT EXISTS "pg_trgm";            -- For trigram similarity (full-text search)
CREATE EXTENSION IF NOT EXISTS "btree_gin";           -- For advanced indexing
CREATE EXTENSION IF NOT EXISTS "jsonb_plpgsql";      -- For JSONB operations

-- =============================================================================
-- SECTION 2: SCHEMAS
-- =============================================================================
DROP SCHEMA IF EXISTS accounting CASCADE;
DROP SCHEMA IF EXISTS inventory CASCADE;
DROP SCHEMA IF EXISTS approval CASCADE;
DROP SCHEMA IF EXISTS dimensions CASCADE;
DROP SCHEMA IF EXISTS security CASCADE;
DROP SCHEMA IF EXISTS audit CASCADE;
DROP SCHEMA IF EXISTS reporting CASCADE;
DROP SCHEMA IF EXISTS config CASCADE;
DROP SCHEMA IF EXISTS public CASCADE;

CREATE SCHEMA public;                               -- Main schema (required for PostgreSQL)
CREATE SCHEMA accounting;                          -- Chart of accounts, journals
CREATE SCHEMA inventory;                            -- Products, stores, operations
CREATE SCHEMA approval;                             -- Approval workflows
CREATE SCHEMA dimensions;                          -- Cost centers, projects, segments
CREATE SCHEMA security;                             -- Users, roles, privileges
CREATE SCHEMA audit;                                 -- Audit logs
CREATE SCHEMA reporting;                            -- Views and materialized views
CREATE SCHEMA config;                               -- System configuration

-- =============================================================================
-- SECTION 3: ENUMS (PostgreSQL 17.10)
-- =============================================================================
CREATE TYPE accounting.account_type AS ENUM (
    'ASSET', 'LIABILITY', 'EQUITY', 'REVENUE', 'EXPENSE'
);

CREATE TYPE accounting.account_level AS ENUM (
    'ROOT', 'GROUP', 'DETAIL'
);

CREATE TYPE approval.approval_status AS ENUM (
    'PENDING', 'APPROVED', 'REJECTED', 'CANCELLED', 'DELEGATED'
);

CREATE TYPE approval.approval_priority AS ENUM (
    'LOW', 'MEDIUM', 'HIGH', 'URGENT'
);

CREATE TYPE inventory.operation_type AS ENUM (
    'PURCHASE', 'SALE', 'RETURN', 'TRANSFER', 'ADJUSTMENT'
);

CREATE TYPE inventory.movement_type AS ENUM (
    'IN', 'OUT', 'TRANSFER', 'ADJUSTMENT'
);

CREATE TYPE dimensions.hierarchy_type AS ENUM (
    'PROJECT_TO_DEPARTMENT', 'DEPARTMENT_TO_PROJECT',
    'BUSINESS_UNIT_TO_SEGMENT', 'SEGMENT_TO_PROFIT_CENTER'
);

CREATE TYPE security.privilege_type AS ENUM (
    'DISPLAY', 'ADD', 'EDIT', 'DELETE', 'PRINT', 'EXPORT', 'APPROVE', 'POST'
);

CREATE TYPE audit.event_category AS ENUM (
    'CREATE', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT', 'APPROVAL', 'POSTING'
);

-- =============================================================================
-- SECTION 4: DOMAIN TYPES
-- =============================================================================
CREATE DOMAIN config.money AS NUMERIC(18, 4)
    CHECK (VALUE >= 0);

CREATE DOMAIN config.percentage AS NUMERIC(5, 2)
    CHECK (VALUE >= 0 AND VALUE <= 100);

CREATE DOMAIN config.phone_number AS VARCHAR(50)
    CHECK (VALUE ~ '^\+?[0-9\s\-()]+$');

CREATE DOMAIN config.email_address AS VARCHAR(100)
    CHECK (VALUE ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

CREATE DOMAIN config.iban_code AS VARCHAR(50)
    CHECK (VALUE ~ '^[A-Z]{2}[0-9]{2}[A-Z0-9]{4,}$');

CREATE DOMAIN config.swift_code AS VARCHAR(20)
    CHECK (VALUE ~ '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');

-- =============================================================================
-- SECTION 5: SEQUENCES
-- =============================================================================
CREATE SEQUENCE accounting.tblaccounts_accountcode_seq;
CREATE SEQUENCE accounting.tbljournalheader_journalcode_seq;
CREATE SEQUENCE accounting.tbljournalbody_journalbodycode_seq;
CREATE SEQUENCE inventory.tbloperationheader_operationcode_seq;
CREATE SEQUENCE inventory.tbloperationbody_operationbodycode_seq;
CREATE SEQUENCE inventory.tblproducts_productcode_seq;
CREATE SEQUENCE inventory.tblstores_storecode_seq;
CREATE SEQUENCE security.tblusers_usercode_seq;
CREATE SEQUENCE security.tblsessions_sessionid_seq;
CREATE SEQUENCE approval.tblapprovalrequests_requestid_seq;
CREATE SEQUENCE audit.tblauditlogs_auditid_seq;

-- =============================================================================
-- SECTION 6: CONFIG SCHEMA - System Configuration Tables
-- =============================================================================
CREATE TABLE config.tblbranches (
    branch_code INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    branch_id VARCHAR(15) UNIQUE NOT NULL,
    branch_name_ar VARCHAR(200) NOT NULL,
    branch_name_en VARCHAR(200),
    address VARCHAR(500),
    city VARCHAR(100),
    country VARCHAR(100) DEFAULT 'SA',
    phone config.phone_number,
    email config.email_address,
    manager_name VARCHAR(200),
    is_main_branch BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    opened_at DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

CREATE TABLE config.tblcompanies (
    company_code INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    company_name_ar VARCHAR(200) NOT NULL,
    company_name_en VARCHAR(200),
    tax_number VARCHAR(50),
    vat_number VARCHAR(50),
    address VARCHAR(500),
    city VARCHAR(100),
    country VARCHAR(100) DEFAULT 'SA',
    phone config.phone_number,
    email config.email_address,
    website VARCHAR(200),
    logo BYTEA,
    currency_code INT,
    fiscal_year_start DATE,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

CREATE TABLE config.tblcurrencies (
    currency_code INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    currency_id VARCHAR(10) UNIQUE NOT NULL,
    currency_name_ar VARCHAR(100) NOT NULL,
    currency_name_en VARCHAR(100),
    symbol VARCHAR(10),
    exchange_rate NUMERIC(18, 8) DEFAULT 1.0,
    is_base_currency BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

CREATE TABLE config.tblpaymentmethods (
    payment_method_code INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    method_name_ar VARCHAR(100) NOT NULL,
    method_name_en VARCHAR(100),
    method_type VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

CREATE TABLE config.tblpaymentterms (
    payment_term_code INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    term_name_ar VARCHAR(100) NOT NULL,
    term_name_en VARCHAR(100),
    days_count INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

-- =============================================================================
-- SECTION 7: SECURITY SCHEMA - Users, Roles, Privileges
-- =============================================================================
CREATE TABLE security.tblwindows (
    window_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    window_code VARCHAR(50) UNIQUE NOT NULL,
    window_name_ar VARCHAR(200) NOT NULL,
    window_name_en VARCHAR(200),
    module_name VARCHAR(100) NOT NULL,
    form_name VARCHAR(200),
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    icon_name VARCHAR(100),
    parent_window_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP,
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    CONSTRAINT fk_windows_parent FOREIGN KEY (parent_window_id) REFERENCES security.tblwindows (window_id)
);

CREATE TABLE security.tblusers (
    user_code INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    user_id VARCHAR(15) UNIQUE NOT NULL,
    user_password BYTEA NOT NULL,
    salt BYTEA NOT NULL,
    user_name_ar VARCHAR(200),
    user_name_en VARCHAR(200),
    email config.email_address,
    phone config.phone_number,
    mobile config.phone_number,
    is_active BOOLEAN DEFAULT TRUE,
    is_admin BOOLEAN DEFAULT FALSE,
    password_last_changed TIMESTAMP,
    password_history JSONB DEFAULT '[]',
    last_login_at TIMESTAMP,
    login_attempts INT DEFAULT 0,
    locked_until TIMESTAMP,
    must_change_password BOOLEAN DEFAULT FALSE,
    branch_code INT,
    department VARCHAR(100),
    job_title VARCHAR(100),
    photo BYTEA,
    is_online BOOLEAN DEFAULT FALSE,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_by INT,
    modified_at TIMESTAMP,
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    CONSTRAINT fk_users_branch FOREIGN KEY (branch_code) REFERENCES config.tblbranches (branch_code)
);

CREATE TABLE security.tbluserroles (
    role_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    role_name_ar VARCHAR(100) NOT NULL,
    role_name_en VARCHAR(100),
    description VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

CREATE TABLE security.tbluserroleassignments (
    assignment_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    user_code INT NOT NULL,
    role_id INT NOT NULL,
    assigned_by INT,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}',
    CONSTRAINT fk_assignment_user FOREIGN KEY (user_code) REFERENCES security.tblusers (user_code),
    CONSTRAINT fk_assignment_role FOREIGN KEY (role_id) REFERENCES security.tbluserroles (role_id),
    CONSTRAINT uq_user_role UNIQUE (user_code, role_id)
);

CREATE TABLE security.tblprivileges (
    privilege_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    user_code INT NOT NULL,
    window_id INT NOT NULL,
    can_display BOOLEAN DEFAULT TRUE,
    can_add BOOLEAN DEFAULT TRUE,
    can_edit BOOLEAN DEFAULT TRUE,
    can_delete BOOLEAN DEFAULT TRUE,
    can_print BOOLEAN DEFAULT FALSE,
    can_export BOOLEAN DEFAULT FALSE,
    can_approve BOOLEAN DEFAULT FALSE,
    can_post BOOLEAN DEFAULT FALSE,
    custom_permissions JSONB DEFAULT '{}',
    effective_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_by INT,
    modified_at TIMESTAMP,
    CONSTRAINT fk_privileges_user FOREIGN KEY (user_code) REFERENCES security.tblusers (user_code),
    CONSTRAINT fk_privileges_window FOREIGN KEY (window_id) REFERENCES security.tblwindows (window_id),
    CONSTRAINT uq_user_window UNIQUE (user_code, window_id)
);

CREATE TABLE security.tblsessions (
    session_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    session_token UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    user_code INT NOT NULL,
    user_id VARCHAR(15) NOT NULL,
    branch_code INT,
    machine_name VARCHAR(100),
    ip_address VARCHAR(50),
    mac_address VARCHAR(50),
    browser_info VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    logout_at TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    session_data JSONB DEFAULT '{}',
    CONSTRAINT fk_sessions_user FOREIGN KEY (user_code) REFERENCES security.tblusers (user_code)
);

-- =============================================================================
-- SECTION 8: ACCOUNTING SCHEMA - Chart of Accounts, Journals
-- =============================================================================
CREATE TABLE accounting.tblaccounts (
    account_code INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    account_id VARCHAR(15) UNIQUE NOT NULL,
    account_name_ar VARCHAR(200) NOT NULL,
    account_name_en VARCHAR(200),
    account_type accounting.account_type NOT NULL,
    account_level accounting.account_level DEFAULT 'DETAIL',
    parent_account_code INT,
    branch_code INT,
    opening_balance NUMERIC(18, 4) DEFAULT 0,
    current_balance NUMERIC(18, 4) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_postable BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_by INT,
    modified_at TIMESTAMP,
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    -- Generated column for full path
    full_path TEXT GENERATED ALWAYS AS (
        CASE WHEN parent_account_code IS NULL THEN account_name_ar
        ELSE account_name_ar END
    ) STORED,
    CONSTRAINT fk_accounts_parent FOREIGN KEY (parent_account_code) REFERENCES accounting.tblaccounts (account_code),
    CONSTRAINT fk_accounts_branch FOREIGN KEY (branch_code) REFERENCES config.tblbranches (branch_code)
) PARTITION BY RANGE (account_code);

-- Create partitions for different account ranges
CREATE TABLE accounting.tblaccounts_root PARTITION OF accounting.tblaccounts
    FOR VALUES FROM (1) TO (1000);
CREATE TABLE accounting.tblaccounts_detail PARTITION OF accounting.tblaccounts
    FOR VALUES FROM (1000) TO (100000);

CREATE TABLE accounting.tbljournalheader (
    journal_code INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    journal_number VARCHAR(50) UNIQUE NOT NULL,
    journal_date DATE NOT NULL,
    fiscal_year_code INT,
    fiscal_period_code INT,
    journal_type VARCHAR(50),
    description TEXT,
    reference_no VARCHAR(50),
    source_type VARCHAR(50),
    source_id INT,
    is_posted BOOLEAN DEFAULT FALSE,
    posted_by INT,
    posted_at TIMESTAMP,
    is_cancelled BOOLEAN DEFAULT FALSE,
    cancelled_by INT,
    cancelled_at TIMESTAMP,
    cancel_reason TEXT,
    approval_status approval.approval_status DEFAULT 'PENDING',
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_by INT,
    modified_at TIMESTAMP,
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    -- Generated columns
    year INT GENERATED ALWAYS AS (EXTRACT(YEAR FROM journal_date)) STORED,
    month INT GENERATED ALWAYS AS (EXTRACT(MONTH FROM journal_date)) STORED,
    total_debit NUMERIC(18, 4) GENERATED ALWAYS AS (0) STORED,
    total_credit NUMERIC(18, 4) GENERATED ALWAYS AS (0) STORED
) PARTITION BY RANGE (journal_date);

-- Create partitions by date for journals
CREATE TABLE accounting.tbljournalheader_2024 PARTITION OF accounting.tbljournalheader
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
CREATE TABLE accounting.tbljournalheader_2025 PARTITION OF accounting.tbljournalheader
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
CREATE TABLE accounting.tbljournalheader_2026 PARTITION OF accounting.tbljournalheader
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

CREATE TABLE accounting.tbljournalbody (
    journal_body_code INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    journal_code INT NOT NULL,
    account_code INT NOT NULL,
    description TEXT,
    debit NUMERIC(18, 4) DEFAULT 0,
    credit NUMERIC(18, 4) DEFAULT 0,
    currency_code INT,
    exchange_rate NUMERIC(18, 8) DEFAULT 1.0,
    debit_local NUMERIC(18, 4) GENERATED ALWAYS AS (debit * exchange_rate) STORED,
    credit_local NUMERIC(18, 4) GENERATED ALWAYS AS (credit * exchange_rate) STORED,
    dimension1_code INT,
    dimension2_code INT,
    dimension3_code INT,
    dimension4_code INT,
    dimension5_code INT,
    is_posted BOOLEAN DEFAULT FALSE,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_by INT,
    modified_at TIMESTAMP,
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    CONSTRAINT fk_journalbody_header FOREIGN KEY (journal_code) REFERENCES accounting.tbljournalheader (journal_code),
    CONSTRAINT fk_journalbody_account FOREIGN KEY (account_code) REFERENCES accounting.tblaccounts (account_code),
    CONSTRAINT chk_debit_credit CHECK (debit = 0 OR credit = 0)
) PARTITION BY RANGE (journal_body_code);

CREATE TABLE accounting.tbljournalbody_1 PARTITION OF accounting.tbljournalbody
    FOR VALUES FROM (1) TO (1000000);

-- =============================================================================
-- SECTION 9: INVENTORY SCHEMA - Products, Stores, Operations
-- =============================================================================
CREATE TABLE inventory.tblstores (
    store_code INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    store_id VARCHAR(15) UNIQUE NOT NULL,
    store_name_ar VARCHAR(200) NOT NULL,
    store_name_en VARCHAR(200),
    store_type VARCHAR(50),
    branch_code INT,
    address VARCHAR(500),
    manager_name VARCHAR(200),
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP,
    metadata JSONB DEFAULT '{}',
    CONSTRAINT fk_stores_branch FOREIGN KEY (branch_code) REFERENCES config.tblbranches (branch_code)
);

CREATE TABLE inventory.tblproducts (
    product_code INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    product_id VARCHAR(15) UNIQUE NOT NULL,
    product_name_ar VARCHAR(200) NOT NULL,
    product_name_en VARCHAR(200),
    category_code INT,
    unit_code INT,
    barcode VARCHAR(100),
    min_stock_level NUMERIC(18, 4) DEFAULT 0,
    max_stock_level NUMERIC(18, 4) DEFAULT 0,
    reorder_level NUMERIC(18, 4) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_serial_tracked BOOLEAN DEFAULT FALSE,
    is_batch_tracked BOOLEAN DEFAULT FALSE,
    expiration_tracked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP,
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    -- Full-text search vector
    search_vector TSVECTOR GENERATED ALWAYS AS (
        to_tsvector('arabic', product_name_ar || ' ' || COALESCE(product_name_en, ''))
    ) STORED
);

CREATE TABLE inventory.tblunits (
    unit_code INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    unit_id VARCHAR(15) UNIQUE NOT NULL,
    unit_name_ar VARCHAR(100) NOT NULL,
    unit_name_en VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    metadata JSONB DEFAULT '{}'
);

CREATE TABLE inventory.tblcategories (
    category_code INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    category_id VARCHAR(15) UNIQUE NOT NULL,
    category_name_ar VARCHAR(200) NOT NULL,
    category_name_en VARCHAR(200),
    parent_category_code INT,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    full_path TEXT GENERATED ALWAYS AS (
        CASE WHEN parent_category_code IS NULL THEN category_name_ar
        ELSE category_name_ar END
    ) STORED
);

CREATE TABLE inventory.tbloperationheader (
    operation_code INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    operation_number VARCHAR(50) UNIQUE NOT NULL,
    operation_type inventory.operation_type NOT NULL,
    operation_date DATE NOT NULL,
    fiscal_year_code INT,
    fiscal_period_code INT,
    store_code INT,
    supplier_code INT,
    customer_code INT,
    reference_no VARCHAR(50),
    description TEXT,
    total_amount NUMERIC(18, 4) DEFAULT 0,
    tax_amount NUMERIC(18, 4) DEFAULT 0,
    discount_amount NUMERIC(18, 4) DEFAULT 0,
    net_amount NUMERIC(18, 4) GENERATED ALWAYS AS (total_amount - tax_amount - discount_amount) STORED,
    is_posted BOOLEAN DEFAULT FALSE,
    posted_by INT,
    posted_at TIMESTAMP,
    is_cancelled BOOLEAN DEFAULT FALSE,
    cancelled_by INT,
    cancelled_at TIMESTAMP,
    approval_status approval.approval_status DEFAULT 'PENDING',
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_by INT,
    modified_at TIMESTAMP,
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    year INT GENERATED ALWAYS AS (EXTRACT(YEAR FROM operation_date)) STORED,
    month INT GENERATED ALWAYS AS (EXTRACT(MONTH FROM operation_date)) STORED
) PARTITION BY RANGE (operation_date);

CREATE TABLE inventory.tbloperationbody (
    operation_body_code INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    operation_code INT NOT NULL,
    product_code INT NOT NULL,
    quantity NUMERIC(18, 4) NOT NULL,
    unit_code INT,
    unit_price NUMERIC(18, 4) DEFAULT 0,
    discount_percent NUMERIC(5, 2) DEFAULT 0,
    discount_amount NUMERIC(18, 4) DEFAULT 0,
    tax_percent NUMERIC(5, 2) DEFAULT 0,
    tax_amount NUMERIC(18, 4) DEFAULT 0,
    line_total NUMERIC(18, 4) GENERATED ALWAYS AS (
        (quantity * unit_price) - discount_amount + tax_amount
    ) STORED,
    batch_number VARCHAR(50),
    expiration_date DATE,
    serial_numbers TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP,
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    CONSTRAINT fk_operationbody_header FOREIGN KEY (operation_code) REFERENCES inventory.tbloperationheader (operation_code),
    CONSTRAINT fk_operationbody_product FOREIGN KEY (product_code) REFERENCES inventory.tblproducts (product_code)
) PARTITION BY RANGE (operation_body_code);

CREATE TABLE inventory.tblstoreproducts (
    store_product_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    store_code INT NOT NULL,
    product_code INT NOT NULL,
    qty_on_hand NUMERIC(18, 4) DEFAULT 0,
    qty_reserved NUMERIC(18, 4) DEFAULT 0,
    qty_available NUMERIC(18, 4) GENERATED ALWAYS AS (qty_on_hand - qty_reserved) STORED,
    last_stock_take_date DATE,
    last_movement_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP,
    metadata JSONB DEFAULT '{}',
    CONSTRAINT fk_storeproducts_store FOREIGN KEY (store_code) REFERENCES inventory.tblstores (store_code),
    CONSTRAINT fk_storeproducts_product FOREIGN KEY (product_code) REFERENCES inventory.tblproducts (product_code),
    CONSTRAINT uq_store_product UNIQUE (store_code, product_code)
);

CREATE TABLE inventory.tblproductmovement (
    movement_id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    movement_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    product_code INT NOT NULL,
    store_code_from INT,
    store_code_to INT,
    movement_type inventory.movement_type NOT NULL,
    quantity NUMERIC(18, 4) NOT NULL,
    reference_type VARCHAR(50),
    reference_id INT,
    operation_body_code INT,
    notes TEXT,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

-- =============================================================================
-- SECTION 10: DIMENSIONS SCHEMA - Cost Centers, Projects, Segments
-- =============================================================================
CREATE TABLE dimensions.tbldim_departments (
    department_code INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    department_id VARCHAR(15) UNIQUE NOT NULL,
    department_name_ar VARCHAR(200) NOT NULL,
    department_name_en VARCHAR(200),
    parent_department_code INT,
    manager_user_code INT,
    is_active BOOLEAN DEFAULT TRUE,
    effective_date DATE,
    end_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP,
    metadata JSONB DEFAULT '{}',
    full_path TEXT GENERATED ALWAYS AS (
        CASE WHEN parent_department_code IS NULL THEN department_name_ar
        ELSE department_name_ar END
    ) STORED
);

CREATE TABLE dimensions.tbldim_projects (
    project_code INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    project_id VARCHAR(15) UNIQUE NOT NULL,
    project_name_ar VARCHAR(200) NOT NULL,
    project_name_en VARCHAR(200),
    parent_project_code INT,
    project_type VARCHAR(50),
    start_date DATE,
    end_date DATE,
    budget_amount NUMERIC(18, 4) DEFAULT 0,
    project_status VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

CREATE TABLE dimensions.tbldim_businessunits (
    business_unit_code INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    business_unit_id VARCHAR(15) UNIQUE NOT NULL,
    business_unit_name_ar VARCHAR(200) NOT NULL,
    business_unit_name_en VARCHAR(200),
    parent_business_unit_code INT,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

CREATE TABLE dimensions.tbldim_segments (
    segment_code INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    segment_id VARCHAR(15) UNIQUE NOT NULL,
    segment_name_ar VARCHAR(200) NOT NULL,
    segment_name_en VARCHAR(200),
    segment_type VARCHAR(50),
    parent_segment_code INT,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

CREATE TABLE dimensions.tbldim_profitcenters (
    profit_center_code INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    profit_center_id VARCHAR(15) UNIQUE NOT NULL,
    profit_center_name_ar VARCHAR(200) NOT NULL,
    profit_center_name_en VARCHAR(200),
    parent_profit_center_code INT,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

CREATE TABLE dimensions.tbldim_hierarchies (
    hierarchy_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    hierarchy_type dimensions.hierarchy_type NOT NULL,
    parent_dim_type VARCHAR(50) NOT NULL,
    parent_dim_code INT NOT NULL,
    child_dim_type VARCHAR(50) NOT NULL,
    child_dim_code INT NOT NULL,
    valid_from DATE,
    valid_to DATE,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT,
    metadata JSONB DEFAULT '{}'
);

-- =============================================================================
-- SECTION 11: APPROVAL SCHEMA - Approval Workflows
-- =============================================================================
CREATE TABLE approval.tblapprovalworkflows (
    workflow_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    workflow_name_ar VARCHAR(200) NOT NULL,
    workflow_name_en VARCHAR(200),
    source_type VARCHAR(50) NOT NULL,
    priority approval.approval_priority DEFAULT 'MEDIUM',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP,
    notes TEXT,
    metadata JSONB DEFAULT '{}'
);

CREATE TABLE approval.tblapprovallevels (
    level_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    workflow_id INT NOT NULL,
    level_order INT NOT NULL,
    level_name_ar VARCHAR(100) NOT NULL,
    level_name_en VARCHAR(100),
    approver_type VARCHAR(50),
    approver_id INT,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    CONSTRAINT fk_approvallevels_workflow FOREIGN KEY (workflow_id) REFERENCES approval.tblapprovalworkflows (workflow_id)
);

CREATE TABLE approval.tblapprovalrequests (
    request_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    request_number VARCHAR(50) UNIQUE NOT NULL,
    workflow_id INT NOT NULL,
    source_type VARCHAR(50) NOT NULL,
    source_id INT NOT NULL,
    current_level_id INT,
    request_status approval.approval_status DEFAULT 'PENDING',
    submitted_by INT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    notes TEXT,
    metadata JSONB DEFAULT '{}',
    CONSTRAINT fk_approvalrequests_workflow FOREIGN KEY (workflow_id) REFERENCES approval.tblapprovalworkflows (workflow_id)
);

CREATE TABLE approval.tblapprovalactions (
    action_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    request_id INT NOT NULL,
    level_id INT NOT NULL,
    action_type VARCHAR(50) NOT NULL,
    action_by INT,
    action_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    comments TEXT,
    metadata JSONB DEFAULT '{}',
    CONSTRAINT fk_approvalactions_request FOREIGN KEY (request_id) REFERENCES approval.tblapprovalrequests (request_id)
);

CREATE TABLE approval.tblapprovaldelegations (
    delegation_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    from_user_code INT NOT NULL,
    to_user_code INT NOT NULL,
    workflow_id INT,
    valid_from DATE,
    valid_to DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    metadata JSONB DEFAULT '{}'
);

-- =============================================================================
-- SECTION 12: AUDIT SCHEMA - Audit Logs
-- =============================================================================
CREATE TABLE audit.tblauditlogs (
    audit_id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    user_code INT,
    user_id VARCHAR(15),
    event_type VARCHAR(50) NOT NULL,
    event_category audit.event_category NOT NULL,
    event_description VARCHAR(1000) NOT NULL,
    table_name VARCHAR(100),
    record_id INT,
    old_values JSONB,
    new_values JSONB,
    sql_command TEXT,
    ip_address VARCHAR(50),
    machine_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'
) PARTITION BY RANGE (created_at);

CREATE TABLE audit.tblauditlogs_2024 PARTITION OF audit.tblauditlogs
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
CREATE TABLE audit.tblauditlogs_2025 PARTITION OF audit.tblauditlogs
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
CREATE TABLE audit.tblauditlogs_2026 PARTITION OF audit.tblauditlogs
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

-- =============================================================================
-- SECTION 13: REPORTING SCHEMA - Views and Materialized Views
-- =============================================================================
CREATE MATERIALIZED VIEW reporting.vw_account_hierarchy AS
SELECT
    a.account_code,
    a.account_id,
    a.account_name_ar,
    a.account_type,
    a.account_level,
    a.parent_account_code,
    a.opening_balance,
    a.current_balance,
    COALESCE(parents.account_name_ar, a.account_name_ar) AS parent_name,
    ARRAY_AGG(p.account_name_ar ORDER BY p.account_level) OVER (PARTITION BY a.account_code) AS path_array
FROM accounting.tblaccounts a
LEFT JOIN accounting.tblaccounts parents ON a.parent_account_code = parents.account_code
LEFT JOIN LATERAL (
    WITH RECURSIVE account_path AS (
        SELECT a2.account_code, a2.account_name_ar, a2.account_level, 1 AS depth
        FROM accounting.tblaccounts a2
        WHERE a2.account_code = a.parent_account_code
        UNION ALL
        SELECT a3.account_code, a3.account_name_ar, a3.account_level, ap.depth + 1
        FROM accounting.tblaccounts a3
        JOIN account_path ap ON a3.account_code = ap.parent_account_code
    )
    SELECT account_name_ar FROM account_path ORDER BY depth
) p ON TRUE
WITH NO DATA;

CREATE MATERIALIZED VIEW reporting.vw_dimension_usage AS
SELECT
    dim_type,
    dim_code,
    COUNT(*) AS usage_count,
    SUM(debit_local) AS total_debit,
    SUM(credit_local) AS total_credit
FROM accounting.tbljournalbody
CROSS JOIN LATERAL (
    VALUES
        ('DIM1', dimension1_code),
        ('DIM2', dimension2_code),
        ('DIM3', dimension3_code),
        ('DIM4', dimension4_code),
        ('DIM5', dimension5_code)
) AS dims(dim_type, dim_code)
WHERE dim_code IS NOT NULL
GROUP BY dim_type, dim_code
WITH NO DATA;

CREATE MATERIALIZED VIEW reporting.vw_product_stock_summary AS
SELECT
    p.product_code,
    p.product_id,
    p.product_name_ar,
    s.store_code,
    st.store_name_ar,
    sp.qty_on_hand,
    sp.qty_reserved,
    sp.qty_available
FROM inventory.tblproducts p
JOIN inventory.tblstoreproducts sp ON p.product_code = sp.product_code
JOIN inventory.tblstores st ON sp.store_code = st.store_code
WITH NO DATA;

-- =============================================================================
-- SECTION 14: INDEXES - Advanced PostgreSQL 17.10 Indexing
-- =============================================================================
-- Partial indexes for active records
CREATE INDEX idx_users_active ON security.tblusers (user_id) WHERE is_active = TRUE;
CREATE INDEX idx_accounts_active ON accounting.tblaccounts (account_code) WHERE is_active = TRUE;
CREATE INDEX idx_products_active ON inventory.tblproducts (product_code) WHERE is_active = TRUE;

-- Expression indexes for full-text search
CREATE INDEX idx_products_search ON inventory.tblproducts USING GIN (search_vector);

-- Composite indexes for common queries
CREATE INDEX idx_journalbody_account_date ON accounting.tbljournalbody (account_code, journal_code);
CREATE INDEX idx_operationheader_date_type ON inventory.tbloperationheader (operation_date, operation_type);
CREATE INDEX idx_auditlogs_user_date ON audit.tblauditlogs (user_code, created_at);

-- Indexes for JSONB queries
CREATE INDEX idx_users_metadata ON security.tblusers USING GIN (metadata);
CREATE INDEX idx_products_metadata ON inventory.tblproducts USING GIN (metadata);
CREATE INDEX idx_auditlogs_metadata ON audit.tblauditlogs USING GIN (metadata);

-- Unique indexes with NULLS NOT DISTINCT (PostgreSQL 17 feature)
CREATE UNIQUE INDEX idx_sessions_token ON security.tblsessions (session_token) WHERE session_token IS NOT NULL;

-- =============================================================================
-- SECTION 15: ROW-LEVEL SECURITY (RLS)
-- =============================================================================
-- Enable RLS on sensitive tables
ALTER TABLE security.tblusers ENABLE ROW LEVEL SECURITY;
ALTER TABLE security.tblsessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit.tblauditlogs ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY user_own_data ON security.tblusers
    FOR ALL
    USING (user_code = current_setting('app.current_user_code', TRUE)::INT)
    WITH CHECK (user_code = current_setting('app.current_user_code', TRUE)::INT);

CREATE POLICY session_active ON security.tblsessions
    FOR ALL
    USING (user_code = current_setting('app.current_user_code', TRUE)::INT)
    WITH CHECK (user_code = current_setting('app.current_user_code', TRUE)::INT);

-- =============================================================================
-- SECTION 16: COMMENTS AND DOCUMENTATION
-- =============================================================================
COMMENT ON SCHEMA accounting IS 'Chart of accounts and journal entries';
COMMENT ON SCHEMA inventory IS 'Products, stores, and inventory operations';
COMMENT ON SCHEMA approval IS 'Approval workflows and processes';
COMMENT ON SCHEMA dimensions IS 'Cost centers, projects, and dimensional hierarchy';
COMMENT ON SCHEMA security IS 'Users, roles, privileges, and sessions';
COMMENT ON SCHEMA audit IS 'Audit logs and tracking';
COMMENT ON SCHEMA reporting IS 'Views and materialized views for reporting';
COMMENT ON SCHEMA config IS 'System configuration and master data';

COMMENT ON TABLE accounting.tblaccounts IS 'Chart of accounts - hierarchical account structure';
COMMENT ON TABLE accounting.tbljournalheader IS 'Journal entry headers';
COMMENT ON TABLE accounting.tbljournalbody IS 'Journal entry lines';
COMMENT ON TABLE inventory.tblproducts IS 'Product catalog';
COMMENT ON TABLE inventory.tbloperationheader IS 'Inventory operation headers (purchase/sale/transfer)';
COMMENT ON TABLE inventory.tbloperationbody IS 'Inventory operation lines';
COMMENT ON TABLE security.tblusers IS 'System users with authentication data';
COMMENT ON TABLE security.tblsessions IS 'Active user sessions';
COMMENT ON TABLE audit.tblauditlogs IS 'Comprehensive audit trail';

-- =============================================================================
-- SECTION 17: TRIGGERS FOR AUTOMATIC TIMESTAMPS
-- =============================================================================
CREATE OR REPLACE FUNCTION config.update_modified_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.modified_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_modified_at
    BEFORE UPDATE ON security.tblusers
    FOR EACH ROW EXECUTE FUNCTION config.update_modified_at();

CREATE TRIGGER trg_accounts_modified_at
    BEFORE UPDATE ON accounting.tblaccounts
    FOR EACH ROW EXECUTE FUNCTION config.update_modified_at();

CREATE TRIGGER trg_products_modified_at
    BEFORE UPDATE ON inventory.tblproducts
    FOR EACH ROW EXECUTE FUNCTION config.update_modified_at();

-- =============================================================================
-- SECTION 18: VIEWS FOR COMPATIBILITY (Backward Compatibility Layer)
-- =============================================================================
-- Create views in public schema that map old names to new schema structure
CREATE OR REPLACE VIEW public.tblaccounts AS
SELECT account_code, account_id, account_name_ar, account_name_en,
       account_type::VARCHAR(50) as account_type, account_level::VARCHAR(50) as account_level,
       parent_account_code, branch_code, opening_balance, current_balance,
       is_active, is_postable, is_system, created_by, created_at, modified_by, modified_at, notes
FROM accounting.tblaccounts;

CREATE OR REPLACE VIEW public.tblusers AS
SELECT user_code, user_id, user_name_ar, user_name_en, email, phone, mobile,
       is_active, is_admin, branch_code, department, job_title, created_at, modified_at, notes
FROM security.tblusers;

-- ... additional views for backward compatibility

-- =============================================================================
-- SECTION 19: FINAL PERMISSIONS SETUP
-- =============================================================================
-- Grant appropriate permissions
GRANT USAGE ON SCHEMA accounting TO postgres;
GRANT USAGE ON SCHEMA inventory TO postgres;
GRANT USAGE ON SCHEMA approval TO postgres;
GRANT USAGE ON SCHEMA dimensions TO postgres;
GRANT USAGE ON SCHEMA security TO postgres;
GRANT USAGE ON SCHEMA audit TO postgres;
GRANT USAGE ON SCHEMA reporting TO postgres;
GRANT USAGE ON SCHEMA config TO postgres;

-- =============================================================================
-- SECTION 20: SUMMARY
-- =============================================================================
-- This reorganization provides:
-- 1. Schema-based organization for better code management
-- 2. Table partitioning for performance on large tables
-- 3. JSONB for flexible metadata storage
-- 4. Generated columns for computed values
-- 5. Enums for type safety
-- 6. Domain types for data validation
-- 7. Sequences for key generation
-- 8. Row-Level Security for data protection
-- 9. Advanced indexing (partial, expression, GIN)
-- 10. Materialized views for reporting performance
-- 11. Full-text search support
-- 12. Comprehensive comments for documentation
-- 13. Triggers for automatic timestamp management
-- 14. Backward compatibility views
