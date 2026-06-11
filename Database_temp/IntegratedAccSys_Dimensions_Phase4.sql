-- =====================================================================
-- PHASE 4 — COST CENTERS & DIMENSIONS ENGINE
-- =====================================================================
-- Project   : IntegratedAccSys
-- Database  : PostgreSQL 17.10 (IntegratedAccSys @ localhost:5432)
-- Scope     : Departments, Projects, Business Units, Segments,
--             Profit Centers, Dimension Hierarchies + Integration
-- Strategy  : ADDITIVE ONLY. No DROP, no DELETE, no rename, no redesign
--             of existing objects. All new tables, columns, functions,
--             procedures, views, triggers, and approval-workflow rows.
-- Date      : 2026-06-09
-- =====================================================================

SET client_min_messages = WARNING;
SET search_path = public, pg_catalog;

-- =====================================================================
-- SECTION 1 — DIMENSION MASTER TABLES (5 new dimensions)
--            (Cost Centers already exist as tblcostcenters)
-- =====================================================================

-- 1.1 DEPARTMENTS ------------------------------------------------------
CREATE TABLE IF NOT EXISTS tbldim_departments (
    departmentcode        INTEGER         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    departmentid          VARCHAR(30)     NOT NULL UNIQUE,
    namear                VARCHAR(100)    NOT NULL,
    nameen                VARCHAR(100),
    parentdepartmentcode  INTEGER         REFERENCES tbldim_departments(departmentcode)
                                        ON DELETE SET NULL ON UPDATE CASCADE,
    managerusercode       INTEGER         REFERENCES tblusers(usercode) ON DELETE SET NULL,
    isactive              BOOLEAN         NOT NULL DEFAULT TRUE,
    effectivedate         DATE            NOT NULL DEFAULT CURRENT_DATE,
    enddate               DATE,
    notes                 TEXT,
    adduser               INTEGER         REFERENCES tblusers(usercode),
    adddate               TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    edituser              INTEGER         REFERENCES tblusers(usercode),
    editdate              TIMESTAMP
);
CREATE INDEX IF NOT EXISTS ix_tbldim_departments_parent ON tbldim_departments(parentdepartmentcode);
CREATE INDEX IF NOT EXISTS ix_tbldim_departments_active ON tbldim_departments(isactive);
CREATE INDEX IF NOT EXISTS ix_tbldim_departments_manager ON tbldim_departments(managerusercode);
COMMENT ON TABLE tbldim_departments IS 'PHASE 4 — Departments dimension (organizational units / business functions)';

-- 1.2 PROJECTS ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS tbldim_projects (
    projectcode        INTEGER         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    projectid          VARCHAR(30)     NOT NULL UNIQUE,
    namear             VARCHAR(100)    NOT NULL,
    nameen             VARCHAR(100),
    parentprojectcode  INTEGER         REFERENCES tbldim_projects(projectcode)
                                      ON DELETE SET NULL ON UPDATE CASCADE,
    projecttype        VARCHAR(30)     NOT NULL DEFAULT 'INTERNAL', -- INTERNAL/CLIENT/CAPEX/OPEX
    startdate          DATE,
    enddate            DATE,
    budgetamount       NUMERIC(19,4)    NOT NULL DEFAULT 0,
    actualamount       NUMERIC(19,4)    NOT NULL DEFAULT 0,
    projectstatus      VARCHAR(20)     NOT NULL DEFAULT 'ACTIVE', -- ACTIVE/CLOSED/SUSPENDED
    isactive           BOOLEAN         NOT NULL DEFAULT TRUE,
    notes              TEXT,
    adduser            INTEGER         REFERENCES tblusers(usercode),
    adddate            TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    edituser           INTEGER         REFERENCES tblusers(usercode),
    editdate           TIMESTAMP
);
CREATE INDEX IF NOT EXISTS ix_tbldim_projects_parent ON tbldim_projects(parentprojectcode);
CREATE INDEX IF NOT EXISTS ix_tbldim_projects_active ON tbldim_projects(isactive);
CREATE INDEX IF NOT EXISTS ix_tbldim_projects_status ON tbldim_projects(projectstatus);
COMMENT ON TABLE tbldim_projects IS 'PHASE 4 — Projects dimension (capital, internal, client projects)';

-- 1.3 BUSINESS UNITS ---------------------------------------------------
CREATE TABLE IF NOT EXISTS tbldim_businessunits (
    businessunitcode        INTEGER         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    businessunitid          VARCHAR(30)     NOT NULL UNIQUE,
    namear                  VARCHAR(100)    NOT NULL,
    nameen                  VARCHAR(100),
    parentbusinessunitcode  INTEGER         REFERENCES tbldim_businessunits(businessunitcode)
                                            ON DELETE SET NULL ON UPDATE CASCADE,
    isactive                BOOLEAN         NOT NULL DEFAULT TRUE,
    notes                   TEXT,
    adduser                 INTEGER         REFERENCES tblusers(usercode),
    adddate                 TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    edituser                INTEGER         REFERENCES tblusers(usercode),
    editdate                TIMESTAMP
);
CREATE INDEX IF NOT EXISTS ix_tbldim_bu_parent ON tbldim_businessunits(parentbusinessunitcode);
CREATE INDEX IF NOT EXISTS ix_tbldim_bu_active ON tbldim_businessunits(isactive);
COMMENT ON TABLE tbldim_businessunits IS 'PHASE 4 — Business Units dimension (strategic / legal entity subdivisions)';

-- 1.4 SEGMENTS ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS tbldim_segments (
    segmentcode        INTEGER         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    segmentid          VARCHAR(30)     NOT NULL UNIQUE,
    namear             VARCHAR(100)    NOT NULL,
    nameen             VARCHAR(100),
    segmenttype        VARCHAR(30)     NOT NULL DEFAULT 'GEOGRAPHIC', -- GEOGRAPHIC/INDUSTRY/CHANNEL/CUSTOMER
    parentsegmentcode  INTEGER         REFERENCES tbldim_segments(segmentcode)
                                      ON DELETE SET NULL ON UPDATE CASCADE,
    isactive           BOOLEAN         NOT NULL DEFAULT TRUE,
    notes              TEXT,
    adduser            INTEGER         REFERENCES tblusers(usercode),
    adddate            TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    edituser           INTEGER         REFERENCES tblusers(usercode),
    editdate           TIMESTAMP
);
CREATE INDEX IF NOT EXISTS ix_tbldim_segments_parent ON tbldim_segments(parentsegmentcode);
CREATE INDEX IF NOT EXISTS ix_tbldim_segments_active ON tbldim_segments(isactive);
CREATE INDEX IF NOT EXISTS ix_tbldim_segments_type ON tbldim_segments(segmenttype);
COMMENT ON TABLE tbldim_segments IS 'PHASE 4 — Segments dimension (market / industry / channel segmentation)';

-- 1.5 PROFIT CENTERS ---------------------------------------------------
CREATE TABLE IF NOT EXISTS tbldim_profitcenters (
    profitcentercode        INTEGER         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    profitcenterid          VARCHAR(30)     NOT NULL UNIQUE,
    namear                  VARCHAR(100)    NOT NULL,
    nameen                  VARCHAR(100),
    parentprofitcentercode  INTEGER         REFERENCES tbldim_profitcenters(profitcentercode)
                                            ON DELETE SET NULL ON UPDATE CASCADE,
    isactive                BOOLEAN         NOT NULL DEFAULT TRUE,
    notes                   TEXT,
    adduser                 INTEGER         REFERENCES tblusers(usercode),
    adddate                 TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    edituser                INTEGER         REFERENCES tblusers(usercode),
    editdate                TIMESTAMP
);
CREATE INDEX IF NOT EXISTS ix_tbldim_pc_parent ON tbldim_profitcenters(parentprofitcentercode);
CREATE INDEX IF NOT EXISTS ix_tbldim_pc_active ON tbldim_profitcenters(isactive);
COMMENT ON TABLE tbldim_profitcenters IS 'PHASE 4 — Profit Centers dimension (P&L responsibility centers)';

-- =====================================================================
-- SECTION 2 — DIMENSION HIERARCHIES (cross-dimension relationships)
-- =====================================================================

CREATE TABLE IF NOT EXISTS tbldim_hierarchies (
    hierarchyid     BIGINT          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    hierarchytype   VARCHAR(30)     NOT NULL,  -- e.g. 'PROJECT_TO_DEPARTMENT', 'COSTCENTER_TO_BU'
    parentdimtype   VARCHAR(20)     NOT NULL,  -- DEPARTMENT / PROJECT / BUSINESSUNIT / SEGMENT / PROFITCENTER / COSTCENTER
    parentdimcode   INTEGER         NOT NULL,
    childdimtype    VARCHAR(20)     NOT NULL,
    childdimcode    INTEGER         NOT NULL,
    validfrom       DATE            NOT NULL DEFAULT CURRENT_DATE,
    validto         DATE,
    isactive        BOOLEAN         NOT NULL DEFAULT TRUE,
    notes           TEXT,
    adduser         INTEGER         REFERENCES tblusers(usercode),
    adddate         TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    edituser        INTEGER         REFERENCES tblusers(usercode),
    editdate        TIMESTAMP,
    CONSTRAINT uq_dim_hier UNIQUE (hierarchytype, parentdimtype, parentdimcode, childdimtype, childdimcode)
);
CREATE INDEX IF NOT EXISTS ix_tbldim_hier_parent ON tbldim_hierarchies(parentdimtype, parentdimcode);
CREATE INDEX IF NOT EXISTS ix_tbldim_hier_child ON tbldim_hierarchies(childdimtype, childdimcode);
CREATE INDEX IF NOT EXISTS ix_tbldim_hier_type ON tbldim_hierarchies(hierarchytype);
CREATE INDEX IF NOT EXISTS ix_tbldim_hier_active ON tbldim_hierarchies(isactive);
COMMENT ON TABLE tbldim_hierarchies IS 'PHASE 4 — Cross-dimension parent/child relationships (valid as of validfrom..validto)';

-- =====================================================================
-- SECTION 3 — ADD DIMENSION COLUMNS TO EXISTING TABLES
--            (additive, nullable, with FK to new dim tables)
-- =====================================================================

DO $$
BEGIN
    -- 3.1 tblbondheader
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblbondheader' AND column_name='departmentcode') THEN
        ALTER TABLE tblbondheader ADD COLUMN departmentcode   INTEGER REFERENCES tbldim_departments(departmentcode)   ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblbondheader' AND column_name='projectcode') THEN
        ALTER TABLE tblbondheader ADD COLUMN projectcode       INTEGER REFERENCES tbldim_projects(projectcode)           ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblbondheader' AND column_name='businessunitcode') THEN
        ALTER TABLE tblbondheader ADD COLUMN businessunitcode  INTEGER REFERENCES tbldim_businessunits(businessunitcode) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblbondheader' AND column_name='segmentcode') THEN
        ALTER TABLE tblbondheader ADD COLUMN segmentcode       INTEGER REFERENCES tbldim_segments(segmentcode)           ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblbondheader' AND column_name='profitcentercode') THEN
        ALTER TABLE tblbondheader ADD COLUMN profitcentercode  INTEGER REFERENCES tbldim_profitcenters(profitcentercode) ON DELETE SET NULL;
    END IF;

    -- 3.2 tblcashreceipts
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblcashreceipts' AND column_name='departmentcode') THEN
        ALTER TABLE tblcashreceipts ADD COLUMN departmentcode   INTEGER REFERENCES tbldim_departments(departmentcode)   ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblcashreceipts' AND column_name='projectcode') THEN
        ALTER TABLE tblcashreceipts ADD COLUMN projectcode       INTEGER REFERENCES tbldim_projects(projectcode)           ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblcashreceipts' AND column_name='businessunitcode') THEN
        ALTER TABLE tblcashreceipts ADD COLUMN businessunitcode  INTEGER REFERENCES tbldim_businessunits(businessunitcode) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblcashreceipts' AND column_name='segmentcode') THEN
        ALTER TABLE tblcashreceipts ADD COLUMN segmentcode       INTEGER REFERENCES tbldim_segments(segmentcode)           ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblcashreceipts' AND column_name='profitcentercode') THEN
        ALTER TABLE tblcashreceipts ADD COLUMN profitcentercode  INTEGER REFERENCES tbldim_profitcenters(profitcentercode) ON DELETE SET NULL;
    END IF;

    -- 3.3 tblcashpayments
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblcashpayments' AND column_name='departmentcode') THEN
        ALTER TABLE tblcashpayments ADD COLUMN departmentcode   INTEGER REFERENCES tbldim_departments(departmentcode)   ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblcashpayments' AND column_name='projectcode') THEN
        ALTER TABLE tblcashpayments ADD COLUMN projectcode       INTEGER REFERENCES tbldim_projects(projectcode)           ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblcashpayments' AND column_name='businessunitcode') THEN
        ALTER TABLE tblcashpayments ADD COLUMN businessunitcode  INTEGER REFERENCES tbldim_businessunits(businessunitcode) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblcashpayments' AND column_name='segmentcode') THEN
        ALTER TABLE tblcashpayments ADD COLUMN segmentcode       INTEGER REFERENCES tbldim_segments(segmentcode)           ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblcashpayments' AND column_name='profitcentercode') THEN
        ALTER TABLE tblcashpayments ADD COLUMN profitcentercode  INTEGER REFERENCES tbldim_profitcenters(profitcentercode) ON DELETE SET NULL;
    END IF;

    -- 3.4 tblbanktransactions
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblbanktransactions' AND column_name='departmentcode') THEN
        ALTER TABLE tblbanktransactions ADD COLUMN departmentcode   INTEGER REFERENCES tbldim_departments(departmentcode)   ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblbanktransactions' AND column_name='projectcode') THEN
        ALTER TABLE tblbanktransactions ADD COLUMN projectcode       INTEGER REFERENCES tbldim_projects(projectcode)           ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblbanktransactions' AND column_name='businessunitcode') THEN
        ALTER TABLE tblbanktransactions ADD COLUMN businessunitcode  INTEGER REFERENCES tbldim_businessunits(businessunitcode) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblbanktransactions' AND column_name='segmentcode') THEN
        ALTER TABLE tblbanktransactions ADD COLUMN segmentcode       INTEGER REFERENCES tbldim_segments(segmentcode)           ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblbanktransactions' AND column_name='profitcentercode') THEN
        ALTER TABLE tblbanktransactions ADD COLUMN profitcentercode  INTEGER REFERENCES tbldim_profitcenters(profitcentercode) ON DELETE SET NULL;
    END IF;

    -- 3.5 tbljournalheader
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tbljournalheader' AND column_name='departmentcode') THEN
        ALTER TABLE tbljournalheader ADD COLUMN departmentcode   INTEGER REFERENCES tbldim_departments(departmentcode)   ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tbljournalheader' AND column_name='projectcode') THEN
        ALTER TABLE tbljournalheader ADD COLUMN projectcode       INTEGER REFERENCES tbldim_projects(projectcode)           ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tbljournalheader' AND column_name='businessunitcode') THEN
        ALTER TABLE tbljournalheader ADD COLUMN businessunitcode  INTEGER REFERENCES tbldim_businessunits(businessunitcode) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tbljournalheader' AND column_name='segmentcode') THEN
        ALTER TABLE tbljournalheader ADD COLUMN segmentcode       INTEGER REFERENCES tbldim_segments(segmentcode)           ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tbljournalheader' AND column_name='profitcentercode') THEN
        ALTER TABLE tbljournalheader ADD COLUMN profitcentercode  INTEGER REFERENCES tbldim_profitcenters(profitcentercode) ON DELETE SET NULL;
    END IF;

    -- 3.6 tbljournalbody (already has costcentercode)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tbljournalbody' AND column_name='departmentcode') THEN
        ALTER TABLE tbljournalbody ADD COLUMN departmentcode   INTEGER REFERENCES tbldim_departments(departmentcode)   ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tbljournalbody' AND column_name='projectcode') THEN
        ALTER TABLE tbljournalbody ADD COLUMN projectcode       INTEGER REFERENCES tbldim_projects(projectcode)           ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tbljournalbody' AND column_name='businessunitcode') THEN
        ALTER TABLE tbljournalbody ADD COLUMN businessunitcode  INTEGER REFERENCES tbldim_businessunits(businessunitcode) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tbljournalbody' AND column_name='segmentcode') THEN
        ALTER TABLE tbljournalbody ADD COLUMN segmentcode       INTEGER REFERENCES tbldim_segments(segmentcode)           ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tbljournalbody' AND column_name='profitcentercode') THEN
        ALTER TABLE tbljournalbody ADD COLUMN profitcentercode  INTEGER REFERENCES tbldim_profitcenters(profitcentercode) ON DELETE SET NULL;
    END IF;

    -- 3.7 tblbudgets (already has costcenterid)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblbudgets' AND column_name='departmentcode') THEN
        ALTER TABLE tblbudgets ADD COLUMN departmentcode   INTEGER REFERENCES tbldim_departments(departmentcode)   ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblbudgets' AND column_name='projectcode') THEN
        ALTER TABLE tblbudgets ADD COLUMN projectcode       INTEGER REFERENCES tbldim_projects(projectcode)           ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblbudgets' AND column_name='businessunitcode') THEN
        ALTER TABLE tblbudgets ADD COLUMN businessunitcode  INTEGER REFERENCES tbldim_businessunits(businessunitcode) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblbudgets' AND column_name='segmentcode') THEN
        ALTER TABLE tblbudgets ADD COLUMN segmentcode       INTEGER REFERENCES tbldim_segments(segmentcode)           ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tblbudgets' AND column_name='profitcentercode') THEN
        ALTER TABLE tblbudgets ADD COLUMN profitcentercode  INTEGER REFERENCES tbldim_profitcenters(profitcentercode) ON DELETE SET NULL;
    END IF;
END$$;

-- Indexes for new FK columns (for fast JOIN performance)
DO $$
DECLARE
    t TEXT;
BEGIN
    FOREACH t IN ARRAY ARRAY['tblbondheader','tblcashreceipts','tblcashpayments','tblbanktransactions','tbljournalheader','tbljournalbody','tblbudgets']
    LOOP
        EXECUTE format('CREATE INDEX IF NOT EXISTS ix_%I_dept ON %I(departmentcode)', t, t);
        EXECUTE format('CREATE INDEX IF NOT EXISTS ix_%I_proj ON %I(projectcode)', t, t);
        EXECUTE format('CREATE INDEX IF NOT EXISTS ix_%I_bu   ON %I(businessunitcode)', t, t);
        EXECUTE format('CREATE INDEX IF NOT EXISTS ix_%I_seg  ON %I(segmentcode)', t, t);
        EXECUTE format('CREATE INDEX IF NOT EXISTS ix_%I_pc   ON %I(profitcentercode)', t, t);
    END LOOP;
END$$;

-- =====================================================================
-- SECTION 4 — CRUD FUNCTIONS (one CRUD set per dimension)
-- Pattern: addX / updateX / deleteX / getAllX / getXData / getXTree
-- =====================================================================

-- ---------------------------------------------------------------------
-- 4.1 DEPARTMENTS
-- ---------------------------------------------------------------------

-- addDepartment ------------------------------------------------------------
CREATE OR REPLACE FUNCTION addDepartment(
    p_departmentid         VARCHAR,
    p_namear               VARCHAR,
    p_nameen               VARCHAR,
    p_parentdepartmentcode INTEGER,
    p_managerusercode      INTEGER,
    p_isactive             BOOLEAN,
    p_effectivedate        DATE,
    p_enddate              DATE,
    p_notes                TEXT,
    p_adduser              INTEGER
) RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_newcode INTEGER;
BEGIN
    INSERT INTO tbldim_departments(
        departmentid, namear, nameen, parentdepartmentcode, managerusercode,
        isactive, effectivedate, enddate, notes, adduser)
    VALUES (p_departmentid, p_namear, p_nameen, p_parentdepartmentcode, p_managerusercode,
            COALESCE(p_isactive, TRUE), COALESCE(p_effectivedate, CURRENT_DATE), p_enddate, p_notes, p_adduser)
    RETURNING departmentcode INTO v_newcode;
    RETURN v_newcode;
END$$;

-- updateDepartment ---------------------------------------------------------
CREATE OR REPLACE FUNCTION updateDepartment(
    p_departmentcode       INTEGER,
    p_departmentid         VARCHAR,
    p_namear               VARCHAR,
    p_nameen               VARCHAR,
    p_parentdepartmentcode INTEGER,
    p_managerusercode      INTEGER,
    p_isactive             BOOLEAN,
    p_effectivedate        DATE,
    p_enddate              DATE,
    p_notes                TEXT,
    p_edituser             INTEGER
) RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE tbldim_departments SET
        departmentid = p_departmentid,
        namear = p_namear,
        nameen = p_nameen,
        parentdepartmentcode = p_parentdepartmentcode,
        managerusercode = p_managerusercode,
        isactive = COALESCE(p_isactive, isactive),
        effectivedate = COALESCE(p_effectivedate, effectivedate),
        enddate = p_enddate,
        notes = p_notes,
        edituser = p_edituser,
        editdate = CURRENT_TIMESTAMP
    WHERE departmentcode = p_departmentcode;
END$$;

-- deleteDepartment (soft: isactive=FALSE) ---------------------------------
CREATE OR REPLACE FUNCTION deleteDepartment(
    p_departmentcode INTEGER,
    p_edituser       INTEGER
) RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE tbldim_departments
       SET isactive = FALSE, edituser = p_edituser, editdate = CURRENT_TIMESTAMP
     WHERE departmentcode = p_departmentcode;
END$$;

-- getAllDepartments --------------------------------------------------------
CREATE OR REPLACE FUNCTION getAllDepartments() RETURNS TABLE(
    departmentcode INTEGER, departmentid VARCHAR, namear VARCHAR, nameen VARCHAR,
    parentdepartmentcode INTEGER, parentname VARCHAR,
    managerusercode INTEGER, managerusernamear VARCHAR,
    isactive BOOLEAN, effectivedate DATE, enddate DATE, notes TEXT,
    adduser INTEGER, adddate TIMESTAMP, edituser INTEGER, editdate TIMESTAMP
)
LANGUAGE sql STABLE
AS $$
    SELECT d.departmentcode, d.departmentid, d.namear, d.nameen,
           d.parentdepartmentcode, p.namear,
           d.managerusercode, u.usernamear,
           d.isactive, d.effectivedate, d.enddate, d.notes,
           d.adduser, d.adddate, d.edituser, d.editdate
      FROM tbldim_departments d
      LEFT JOIN tbldim_departments p ON p.departmentcode = d.parentdepartmentcode
      LEFT JOIN tblusers u ON u.usercode = d.managerusercode
     ORDER BY d.departmentcode;
$$;

-- getDepartmentData --------------------------------------------------------
CREATE OR REPLACE FUNCTION getDepartmentData(p_departmentcode INTEGER) RETURNS TABLE(
    departmentcode INTEGER, departmentid VARCHAR, namear VARCHAR, nameen VARCHAR,
    parentdepartmentcode INTEGER, managerusercode INTEGER, isactive BOOLEAN,
    effectivedate DATE, enddate DATE, notes TEXT
)
LANGUAGE sql STABLE
AS $$
    SELECT departmentcode, departmentid, namear, nameen, parentdepartmentcode,
           managerusercode, isactive, effectivedate, enddate, notes
      FROM tbldim_departments
     WHERE departmentcode = p_departmentcode;
$$;

-- getDepartmentTree (recursive full path) ----------------------------------
CREATE OR REPLACE FUNCTION getDepartmentTree() RETURNS TABLE(
    departmentcode INTEGER, departmentid VARCHAR, namear VARCHAR, level INTEGER, fullpath VARCHAR
)
LANGUAGE sql STABLE
AS $$
    WITH RECURSIVE t AS (
        SELECT departmentcode, departmentid, namear, 0 AS level,
               namear::TEXT AS fullpath, parentdepartmentcode
          FROM tbldim_departments
         WHERE parentdepartmentcode IS NULL
        UNION ALL
        SELECT d.departmentcode, d.departmentid, d.namear, t.level + 1,
               (t.fullpath || ' / ' || d.namear)::TEXT, d.parentdepartmentcode
          FROM tbldim_departments d JOIN t ON d.parentdepartmentcode = t.departmentcode
    )
    SELECT departmentcode, departmentid, namear, level, fullpath FROM t ORDER BY fullpath;
$$;

-- ---------------------------------------------------------------------
-- 4.2 PROJECTS
-- ---------------------------------------------------------------------

CREATE OR REPLACE FUNCTION addProject(
    p_projectid         VARCHAR, p_namear VARCHAR, p_nameen VARCHAR,
    p_parentprojectcode INTEGER, p_projecttype VARCHAR,
    p_startdate DATE, p_enddate DATE,
    p_budgetamount NUMERIC, p_projectstatus VARCHAR,
    p_isactive BOOLEAN, p_notes TEXT, p_adduser INTEGER
) RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE v_newcode INTEGER;
BEGIN
    INSERT INTO tbldim_projects(
        projectid, namear, nameen, parentprojectcode, projecttype,
        startdate, enddate, budgetamount, projectstatus,
        isactive, notes, adduser)
    VALUES (p_projectid, p_namear, p_nameen, p_parentprojectcode,
            COALESCE(p_projecttype,'INTERNAL'),
            p_startdate, p_enddate, COALESCE(p_budgetamount,0),
            COALESCE(p_projectstatus,'ACTIVE'),
            COALESCE(p_isactive, TRUE), p_notes, p_adduser)
    RETURNING projectcode INTO v_newcode;
    RETURN v_newcode;
END$$;

CREATE OR REPLACE FUNCTION updateProject(
    p_projectcode       INTEGER, p_projectid VARCHAR, p_namear VARCHAR, p_nameen VARCHAR,
    p_parentprojectcode INTEGER, p_projecttype VARCHAR,
    p_startdate DATE, p_enddate DATE,
    p_budgetamount NUMERIC, p_actualamount NUMERIC, p_projectstatus VARCHAR,
    p_isactive BOOLEAN, p_notes TEXT, p_edituser INTEGER
) RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE tbldim_projects SET
        projectid=p_projectid, namear=p_namear, nameen=p_nameen,
        parentprojectcode=p_parentprojectcode, projecttype=p_projecttype,
        startdate=p_startdate, enddate=p_enddate,
        budgetamount=COALESCE(p_budgetamount,budgetamount),
        actualamount=COALESCE(p_actualamount,actualamount),
        projectstatus=COALESCE(p_projectstatus,projectstatus),
        isactive=COALESCE(p_isactive,isactive),
        notes=p_notes, edituser=p_edituser, editdate=CURRENT_TIMESTAMP
    WHERE projectcode=p_projectcode;
END$$;

CREATE OR REPLACE FUNCTION deleteProject(p_projectcode INTEGER, p_edituser INTEGER) RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN UPDATE tbldim_projects SET isactive=FALSE, edituser=p_edituser, editdate=CURRENT_TIMESTAMP
 WHERE projectcode=p_projectcode; END$$;

CREATE OR REPLACE FUNCTION getAllProjects() RETURNS TABLE(
    projectcode INTEGER, projectid VARCHAR, namear VARCHAR, nameen VARCHAR,
    parentprojectcode INTEGER, parentname VARCHAR,
    projecttype VARCHAR, startdate DATE, enddate DATE,
    budgetamount NUMERIC, actualamount NUMERIC, projectstatus VARCHAR,
    isactive BOOLEAN, notes TEXT
)
LANGUAGE sql STABLE AS $$
    SELECT pr.projectcode, pr.projectid, pr.namear, pr.nameen,
           pr.parentprojectcode, pa.namear,
           pr.projecttype, pr.startdate, pr.enddate,
           pr.budgetamount, pr.actualamount, pr.projectstatus,
           pr.isactive, pr.notes
      FROM tbldim_projects pr
      LEFT JOIN tbldim_projects pa ON pa.projectcode = pr.parentprojectcode
     ORDER BY pr.projectcode;
$$;

CREATE OR REPLACE FUNCTION getProjectData(p_projectcode INTEGER) RETURNS TABLE(
    projectcode INTEGER, projectid VARCHAR, namear VARCHAR, nameen VARCHAR,
    parentprojectcode INTEGER, projecttype VARCHAR, startdate DATE, enddate DATE,
    budgetamount NUMERIC, actualamount NUMERIC, projectstatus VARCHAR,
    isactive BOOLEAN, notes TEXT
)
LANGUAGE sql STABLE AS $$
    SELECT projectcode, projectid, namear, nameen, parentprojectcode, projecttype,
           startdate, enddate, budgetamount, actualamount, projectstatus, isactive, notes
      FROM tbldim_projects WHERE projectcode=p_projectcode;
$$;

CREATE OR REPLACE FUNCTION getProjectTree() RETURNS TABLE(
    projectcode INTEGER, projectid VARCHAR, namear VARCHAR, level INTEGER, fullpath VARCHAR
)
LANGUAGE sql STABLE AS $$
    WITH RECURSIVE t AS (
        SELECT projectcode, projectid, namear, 0 AS level, namear::TEXT AS fullpath, parentprojectcode
          FROM tbldim_projects WHERE parentprojectcode IS NULL
        UNION ALL
        SELECT p.projectcode, p.projectid, p.namear, t.level+1,
               (t.fullpath||' / '||p.namear)::TEXT, p.parentprojectcode
          FROM tbldim_projects p JOIN t ON p.parentprojectcode=t.projectcode
    )
    SELECT projectcode, projectid, namear, level, fullpath FROM t ORDER BY fullpath;
$$;

-- ---------------------------------------------------------------------
-- 4.3 BUSINESS UNITS
-- ---------------------------------------------------------------------

CREATE OR REPLACE FUNCTION addBusinessUnit(
    p_businessunitid VARCHAR, p_namear VARCHAR, p_nameen VARCHAR,
    p_parentbusinessunitcode INTEGER, p_isactive BOOLEAN, p_notes TEXT, p_adduser INTEGER
) RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE v INTEGER;
BEGIN
    INSERT INTO tbldim_businessunits(businessunitid,namear,nameen,parentbusinessunitcode,isactive,notes,adduser)
    VALUES (p_businessunitid,p_namear,p_nameen,p_parentbusinessunitcode,COALESCE(p_isactive,TRUE),p_notes,p_adduser)
    RETURNING businessunitcode INTO v; RETURN v;
END$$;

CREATE OR REPLACE FUNCTION updateBusinessUnit(
    p_businessunitcode INTEGER, p_businessunitid VARCHAR, p_namear VARCHAR, p_nameen VARCHAR,
    p_parentbusinessunitcode INTEGER, p_isactive BOOLEAN, p_notes TEXT, p_edituser INTEGER
) RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE tbldim_businessunits SET
        businessunitid=p_businessunitid, namear=p_namear, nameen=p_nameen,
        parentbusinessunitcode=p_parentbusinessunitcode,
        isactive=COALESCE(p_isactive,isactive), notes=p_notes,
        edituser=p_edituser, editdate=CURRENT_TIMESTAMP
    WHERE businessunitcode=p_businessunitcode;
END$$;

CREATE OR REPLACE FUNCTION deleteBusinessUnit(p_businessunitcode INTEGER, p_edituser INTEGER) RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN UPDATE tbldim_businessunits SET isactive=FALSE, edituser=p_edituser, editdate=CURRENT_TIMESTAMP
 WHERE businessunitcode=p_businessunitcode; END$$;

CREATE OR REPLACE FUNCTION getAllBusinessUnits() RETURNS TABLE(
    businessunitcode INTEGER, businessunitid VARCHAR, namear VARCHAR, nameen VARCHAR,
    parentbusinessunitcode INTEGER, parentname VARCHAR,
    isactive BOOLEAN, notes TEXT
)
LANGUAGE sql STABLE AS $$
    SELECT b.businessunitcode, b.businessunitid, b.namear, b.nameen,
           b.parentbusinessunitcode, p.namear, b.isactive, b.notes
      FROM tbldim_businessunits b
      LEFT JOIN tbldim_businessunits p ON p.businessunitcode=b.parentbusinessunitcode
     ORDER BY b.businessunitcode;
$$;

CREATE OR REPLACE FUNCTION getBusinessUnitData(p_businessunitcode INTEGER) RETURNS TABLE(
    businessunitcode INTEGER, businessunitid VARCHAR, namear VARCHAR, nameen VARCHAR,
    parentbusinessunitcode INTEGER, isactive BOOLEAN, notes TEXT
)
LANGUAGE sql STABLE AS $$
    SELECT businessunitcode, businessunitid, namear, nameen, parentbusinessunitcode, isactive, notes
      FROM tbldim_businessunits WHERE businessunitcode=p_businessunitcode;
$$;

CREATE OR REPLACE FUNCTION getBusinessUnitTree() RETURNS TABLE(
    businessunitcode INTEGER, businessunitid VARCHAR, namear VARCHAR, level INTEGER, fullpath VARCHAR
)
LANGUAGE sql STABLE AS $$
    WITH RECURSIVE t AS (
        SELECT businessunitcode, businessunitid, namear, 0 AS level, namear::TEXT AS fullpath, parentbusinessunitcode
          FROM tbldim_businessunits WHERE parentbusinessunitcode IS NULL
        UNION ALL
        SELECT b.businessunitcode, b.businessunitid, b.namear, t.level+1,
               (t.fullpath||' / '||b.namear)::TEXT, b.parentbusinessunitcode
          FROM tbldim_businessunits b JOIN t ON b.parentbusinessunitcode=t.businessunitcode
    )
    SELECT businessunitcode, businessunitid, namear, level, fullpath FROM t ORDER BY fullpath;
$$;

-- ---------------------------------------------------------------------
-- 4.4 SEGMENTS
-- ---------------------------------------------------------------------

CREATE OR REPLACE FUNCTION addSegment(
    p_segmentid VARCHAR, p_namear VARCHAR, p_nameen VARCHAR,
    p_segmenttype VARCHAR, p_parentsegmentcode INTEGER,
    p_isactive BOOLEAN, p_notes TEXT, p_adduser INTEGER
) RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE v INTEGER;
BEGIN
    INSERT INTO tbldim_segments(segmentid,namear,nameen,segmenttype,parentsegmentcode,isactive,notes,adduser)
    VALUES (p_segmentid,p_namear,p_nameen,COALESCE(p_segmenttype,'GEOGRAPHIC'),p_parentsegmentcode,COALESCE(p_isactive,TRUE),p_notes,p_adduser)
    RETURNING segmentcode INTO v; RETURN v;
END$$;

CREATE OR REPLACE FUNCTION updateSegment(
    p_segmentcode INTEGER, p_segmentid VARCHAR, p_namear VARCHAR, p_nameen VARCHAR,
    p_segmenttype VARCHAR, p_parentsegmentcode INTEGER,
    p_isactive BOOLEAN, p_notes TEXT, p_edituser INTEGER
) RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE tbldim_segments SET
        segmentid=p_segmentid, namear=p_namear, nameen=p_nameen,
        segmenttype=COALESCE(p_segmenttype,segmenttype),
        parentsegmentcode=p_parentsegmentcode,
        isactive=COALESCE(p_isactive,isactive), notes=p_notes,
        edituser=p_edituser, editdate=CURRENT_TIMESTAMP
    WHERE segmentcode=p_segmentcode;
END$$;

CREATE OR REPLACE FUNCTION deleteSegment(p_segmentcode INTEGER, p_edituser INTEGER) RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN UPDATE tbldim_segments SET isactive=FALSE, edituser=p_edituser, editdate=CURRENT_TIMESTAMP
 WHERE segmentcode=p_segmentcode; END$$;

CREATE OR REPLACE FUNCTION getAllSegments() RETURNS TABLE(
    segmentcode INTEGER, segmentid VARCHAR, namear VARCHAR, nameen VARCHAR,
    segmenttype VARCHAR, parentsegmentcode INTEGER, parentname VARCHAR,
    isactive BOOLEAN, notes TEXT
)
LANGUAGE sql STABLE AS $$
    SELECT s.segmentcode, s.segmentid, s.namear, s.nameen, s.segmenttype,
           s.parentsegmentcode, p.namear, s.isactive, s.notes
      FROM tbldim_segments s
      LEFT JOIN tbldim_segments p ON p.segmentcode=s.parentsegmentcode
     ORDER BY s.segmentcode;
$$;

CREATE OR REPLACE FUNCTION getSegmentData(p_segmentcode INTEGER) RETURNS TABLE(
    segmentcode INTEGER, segmentid VARCHAR, namear VARCHAR, nameen VARCHAR,
    segmenttype VARCHAR, parentsegmentcode INTEGER, isactive BOOLEAN, notes TEXT
)
LANGUAGE sql STABLE AS $$
    SELECT segmentcode, segmentid, namear, nameen, segmenttype, parentsegmentcode, isactive, notes
      FROM tbldim_segments WHERE segmentcode=p_segmentcode;
$$;

CREATE OR REPLACE FUNCTION getSegmentTree() RETURNS TABLE(
    segmentcode INTEGER, segmentid VARCHAR, namear VARCHAR, level INTEGER, fullpath VARCHAR
)
LANGUAGE sql STABLE AS $$
    WITH RECURSIVE t AS (
        SELECT segmentcode, segmentid, namear, 0 AS level, namear::TEXT AS fullpath, parentsegmentcode
          FROM tbldim_segments WHERE parentsegmentcode IS NULL
        UNION ALL
        SELECT s.segmentcode, s.segmentid, s.namear, t.level+1,
               (t.fullpath||' / '||s.namear)::TEXT, s.parentsegmentcode
          FROM tbldim_segments s JOIN t ON s.parentsegmentcode=t.segmentcode
    )
    SELECT segmentcode, segmentid, namear, level, fullpath FROM t ORDER BY fullpath;
$$;

-- ---------------------------------------------------------------------
-- 4.5 PROFIT CENTERS
-- ---------------------------------------------------------------------

CREATE OR REPLACE FUNCTION addProfitCenter(
    p_profitcenterid VARCHAR, p_namear VARCHAR, p_nameen VARCHAR,
    p_parentprofitcentercode INTEGER, p_isactive BOOLEAN, p_notes TEXT, p_adduser INTEGER
) RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE v INTEGER;
BEGIN
    INSERT INTO tbldim_profitcenters(profitcenterid,namear,nameen,parentprofitcentercode,isactive,notes,adduser)
    VALUES (p_profitcenterid,p_namear,p_nameen,p_parentprofitcentercode,COALESCE(p_isactive,TRUE),p_notes,p_adduser)
    RETURNING profitcentercode INTO v; RETURN v;
END$$;

CREATE OR REPLACE FUNCTION updateProfitCenter(
    p_profitcentercode INTEGER, p_profitcenterid VARCHAR, p_namear VARCHAR, p_nameen VARCHAR,
    p_parentprofitcentercode INTEGER, p_isactive BOOLEAN, p_notes TEXT, p_edituser INTEGER
) RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE tbldim_profitcenters SET
        profitcenterid=p_profitcenterid, namear=p_namear, nameen=p_nameen,
        parentprofitcentercode=p_parentprofitcentercode,
        isactive=COALESCE(p_isactive,isactive), notes=p_notes,
        edituser=p_edituser, editdate=CURRENT_TIMESTAMP
    WHERE profitcentercode=p_profitcentercode;
END$$;

CREATE OR REPLACE FUNCTION deleteProfitCenter(p_profitcentercode INTEGER, p_edituser INTEGER) RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN UPDATE tbldim_profitcenters SET isactive=FALSE, edituser=p_edituser, editdate=CURRENT_TIMESTAMP
 WHERE profitcentercode=p_profitcentercode; END$$;

CREATE OR REPLACE FUNCTION getAllProfitCenters() RETURNS TABLE(
    profitcentercode INTEGER, profitcenterid VARCHAR, namear VARCHAR, nameen VARCHAR,
    parentprofitcentercode INTEGER, parentname VARCHAR,
    isactive BOOLEAN, notes TEXT
)
LANGUAGE sql STABLE AS $$
    SELECT pc.profitcentercode, pc.profitcenterid, pc.namear, pc.nameen,
           pc.parentprofitcentercode, pa.namear, pc.isactive, pc.notes
      FROM tbldim_profitcenters pc
      LEFT JOIN tbldim_profitcenters pa ON pa.profitcentercode=pc.parentprofitcentercode
     ORDER BY pc.profitcentercode;
$$;

CREATE OR REPLACE FUNCTION getProfitCenterData(p_profitcentercode INTEGER) RETURNS TABLE(
    profitcentercode INTEGER, profitcenterid VARCHAR, namear VARCHAR, nameen VARCHAR,
    parentprofitcentercode INTEGER, isactive BOOLEAN, notes TEXT
)
LANGUAGE sql STABLE AS $$
    SELECT profitcentercode, profitcenterid, namear, nameen, parentprofitcentercode, isactive, notes
      FROM tbldim_profitcenters WHERE profitcentercode=p_profitcentercode;
$$;

CREATE OR REPLACE FUNCTION getProfitCenterTree() RETURNS TABLE(
    profitcentercode INTEGER, profitcenterid VARCHAR, namear VARCHAR, level INTEGER, fullpath VARCHAR
)
LANGUAGE sql STABLE AS $$
    WITH RECURSIVE t AS (
        SELECT profitcentercode, profitcenterid, namear, 0 AS level, namear::TEXT AS fullpath, parentprofitcentercode
          FROM tbldim_profitcenters WHERE parentprofitcentercode IS NULL
        UNION ALL
        SELECT pc.profitcentercode, pc.profitcenterid, pc.namear, t.level+1,
               (t.fullpath||' / '||pc.namear)::TEXT, pc.parentprofitcentercode
          FROM tbldim_profitcenters pc JOIN t ON pc.parentprofitcentercode=t.profitcentercode
    )
    SELECT profitcentercode, profitcenterid, namear, level, fullpath FROM t ORDER BY fullpath;
$$;

-- =====================================================================
-- SECTION 5 — DIMENSION HIERARCHY CRUD
-- =====================================================================

CREATE OR REPLACE FUNCTION addDimensionHierarchy(
    p_hierarchytype VARCHAR, p_parentdimtype VARCHAR, p_parentdimcode INTEGER,
    p_childdimtype VARCHAR, p_childdimcode INTEGER,
    p_validfrom DATE, p_validto DATE, p_isactive BOOLEAN,
    p_notes TEXT, p_adduser INTEGER
) RETURNS BIGINT LANGUAGE plpgsql AS $$
DECLARE v BIGINT;
BEGIN
    INSERT INTO tbldim_hierarchies(hierarchytype,parentdimtype,parentdimcode,childdimtype,childdimcode,
                                    validfrom,validto,isactive,notes,adduser)
    VALUES (p_hierarchytype,p_parentdimtype,p_parentdimcode,p_childdimtype,p_childdimcode,
            COALESCE(p_validfrom,CURRENT_DATE),p_validto,COALESCE(p_isactive,TRUE),p_notes,p_adduser)
    RETURNING hierarchyid INTO v; RETURN v;
EXCEPTION
    WHEN unique_violation THEN RETURN -1; -- duplicate
END$$;

CREATE OR REPLACE FUNCTION deleteDimensionHierarchy(p_hierarchyid BIGINT, p_edituser INTEGER) RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN UPDATE tbldim_hierarchies
       SET isactive=FALSE, edituser=p_edituser, editdate=CURRENT_TIMESTAMP
     WHERE hierarchyid=p_hierarchyid; END$$;

CREATE OR REPLACE FUNCTION getAllDimensionHierarchies() RETURNS TABLE(
    hierarchyid BIGINT, hierarchytype VARCHAR,
    parentdimtype VARCHAR, parentdimcode INTEGER, parentname VARCHAR,
    childdimtype VARCHAR, childdimcode INTEGER, childname VARCHAR,
    validfrom DATE, validto DATE, isactive BOOLEAN
)
LANGUAGE sql STABLE AS $$
    SELECT h.hierarchyid, h.hierarchytype,
           h.parentdimtype, h.parentdimcode, h_parent.namear,
           h.childdimtype, h.childdimcode, h_child.namear,
           h.validfrom, h.validto, h.isactive
      FROM tbldim_hierarchies h
      LEFT JOIN (SELECT 'DEPARTMENT' AS t, departmentcode AS c, namear FROM tbldim_departments
                 UNION ALL SELECT 'PROJECT', projectcode, namear FROM tbldim_projects
                 UNION ALL SELECT 'BUSINESSUNIT', businessunitcode, namear FROM tbldim_businessunits
                 UNION ALL SELECT 'SEGMENT', segmentcode, namear FROM tbldim_segments
                 UNION ALL SELECT 'PROFITCENTER', profitcentercode, namear FROM tbldim_profitcenters
                 UNION ALL SELECT 'COSTCENTER', costcentercode, costcenternamear FROM tblcostcenters
                ) h_parent ON h_parent.t=h.parentdimtype AND h_parent.c=h.parentdimcode
      LEFT JOIN (SELECT 'DEPARTMENT' AS t, departmentcode AS c, namear FROM tbldim_departments
                 UNION ALL SELECT 'PROJECT', projectcode, namear FROM tbldim_projects
                 UNION ALL SELECT 'BUSINESSUNIT', businessunitcode, namear FROM tbldim_businessunits
                 UNION ALL SELECT 'SEGMENT', segmentcode, namear FROM tbldim_segments
                 UNION ALL SELECT 'PROFITCENTER', profitcentercode, namear FROM tbldim_profitcenters
                 UNION ALL SELECT 'COSTCENTER', costcentercode, costcenternamear FROM tblcostcenters
                ) h_child ON h_child.t=h.childdimtype AND h_child.c=h.childdimcode
     ORDER BY h.hierarchytype, h.parentdimcode, h.childdimcode;
$$;

-- =====================================================================
-- SECTION 6 — CROSS-DIMENSION ANALYTICS FUNCTIONS
-- =====================================================================

-- 6.1 Validate one dimension reference (active, in date range) ---------
CREATE OR REPLACE FUNCTION validateDimension(
    p_dimtype VARCHAR, p_dimcode INTEGER
) RETURNS BOOLEAN LANGUAGE plpgsql STABLE AS $$
DECLARE v_ok BOOLEAN := FALSE;
BEGIN
    IF p_dimcode IS NULL THEN RETURN TRUE; END IF;
    IF p_dimtype='DEPARTMENT' THEN
        SELECT isactive AND (enddate IS NULL OR enddate >= CURRENT_DATE)
          INTO v_ok FROM tbldim_departments WHERE departmentcode=p_dimcode;
    ELSIF p_dimtype='PROJECT' THEN
        SELECT isactive AND projectstatus='ACTIVE'
          INTO v_ok FROM tbldim_projects WHERE projectcode=p_dimcode;
    ELSIF p_dimtype='BUSINESSUNIT' THEN
        SELECT isactive INTO v_ok FROM tbldim_businessunits WHERE businessunitcode=p_dimcode;
    ELSIF p_dimtype='SEGMENT' THEN
        SELECT isactive INTO v_ok FROM tbldim_segments WHERE segmentcode=p_dimcode;
    ELSIF p_dimtype='PROFITCENTER' THEN
        SELECT isactive INTO v_ok FROM tbldim_profitcenters WHERE profitcentercode=p_dimcode;
    ELSIF p_dimtype='COSTCENTER' THEN
        SELECT isactive INTO v_ok FROM tblcostcenters WHERE costcentercode=p_dimcode;
    END IF;
    RETURN COALESCE(v_ok, FALSE);
END$$;

-- 6.2 Validate all 6 dimensions on a journal/bond/treasury record ------
CREATE OR REPLACE FUNCTION validateAllDimensions(
    p_departmentcode INTEGER, p_projectcode INTEGER, p_businessunitcode INTEGER,
    p_segmentcode INTEGER, p_profitcentercode INTEGER, p_costcentercode INTEGER
) RETURNS TEXT LANGUAGE plpgsql STABLE AS $$
DECLARE v_bad TEXT := '';
BEGIN
    IF NOT validateDimension('DEPARTMENT',p_departmentcode)   THEN v_bad := v_bad || 'DEPT,'; END IF;
    IF NOT validateDimension('PROJECT',p_projectcode)         THEN v_bad := v_bad || 'PROJ,'; END IF;
    IF NOT validateDimension('BUSINESSUNIT',p_businessunitcode) THEN v_bad := v_bad || 'BU,';  END IF;
    IF NOT validateDimension('SEGMENT',p_segmentcode)         THEN v_bad := v_bad || 'SEG,'; END IF;
    IF NOT validateDimension('PROFITCENTER',p_profitcentercode) THEN v_bad := v_bad || 'PC,';  END IF;
    IF NOT validateDimension('COSTCENTER',p_costcentercode)   THEN v_bad := v_bad || 'CC,';  END IF;
    IF v_bad = '' THEN RETURN NULL; END IF;
    RETURN substring(v_bad FROM 1 FOR length(v_bad)-1);
END$$;

-- 6.3 Actual amount posted against a dimension (per period) -----------
CREATE OR REPLACE FUNCTION getDimensionActual(
    p_dimtype VARCHAR, p_dimcode INTEGER, p_periodid INTEGER
) RETURNS NUMERIC LANGUAGE plpgsql STABLE AS $$
DECLARE v_actual NUMERIC(19,4) := 0;
BEGIN
    IF p_dimcode IS NULL THEN RETURN 0; END IF;
    SELECT COALESCE(SUM(GREATEST(jb.debit, jb.credit)), 0)
      INTO v_actual
      FROM tbljournalbody jb
      JOIN tbljournalheader jh ON jh.journalcode=jb.journalcode
     WHERE jh.isposted=TRUE
       AND jh.iscancelled=FALSE
       AND (p_periodid IS NULL OR jh.fiscalperiod=p_periodid)
       AND (
            (p_dimtype='DEPARTMENT'   AND jb.departmentcode=p_dimcode)    OR
            (p_dimtype='PROJECT'     AND jb.projectcode=p_dimcode)        OR
            (p_dimtype='BUSINESSUNIT' AND jb.businessunitcode=p_dimcode)  OR
            (p_dimtype='SEGMENT'     AND jb.segmentcode=p_dimcode)        OR
            (p_dimtype='PROFITCENTER' AND jb.profitcentercode=p_dimcode)  OR
            (p_dimtype='COSTCENTER'  AND jb.costcentercode=p_dimcode)
       );
    RETURN COALESCE(v_actual,0);
END$$;

-- 6.4 Budget amount allocated to a dimension ---------------------------
CREATE OR REPLACE FUNCTION getDimensionBudget(
    p_dimtype VARCHAR, p_dimcode INTEGER, p_periodid INTEGER
) RETURNS NUMERIC LANGUAGE plpgsql STABLE AS $$
DECLARE v_budget NUMERIC(19,4) := 0;
BEGIN
    IF p_dimcode IS NULL THEN RETURN 0; END IF;
    SELECT COALESCE(SUM(b.budgetamount), 0)
      INTO v_budget
      FROM tblbudgets b
     WHERE (p_periodid IS NULL OR b.periodid=p_periodid)
       AND (
            (p_dimtype='DEPARTMENT'   AND b.departmentcode=p_dimcode)    OR
            (p_dimtype='PROJECT'     AND b.projectcode=p_dimcode)        OR
            (p_dimtype='BUSINESSUNIT' AND b.businessunitcode=p_dimcode)  OR
            (p_dimtype='SEGMENT'     AND b.segmentcode=p_dimcode)        OR
            (p_dimtype='PROFITCENTER' AND b.profitcentercode=p_dimcode)  OR
            (p_dimtype='COSTCENTER'  AND b.costcenterid=p_dimcode)
       );
    RETURN COALESCE(v_budget,0);
END$$;

-- 6.5 Variance budget vs actual ----------------------------------------
CREATE OR REPLACE FUNCTION getDimensionVariance(
    p_dimtype VARCHAR, p_dimcode INTEGER, p_periodid INTEGER
) RETURNS NUMERIC LANGUAGE plpgsql STABLE AS $$
BEGIN
    RETURN getDimensionBudget(p_dimtype, p_dimcode, p_periodid)
         - getDimensionActual(p_dimtype, p_dimcode, p_periodid);
END$$;

-- 6.6 Resolve a dimension's full path (uses hierarchies + recursion) --
CREATE OR REPLACE FUNCTION getDimensionFullPath(
    p_dimtype VARCHAR, p_dimcode INTEGER
) RETURNS TEXT LANGUAGE plpgsql STABLE AS $$
DECLARE v_path TEXT;
BEGIN
    IF p_dimcode IS NULL THEN RETURN NULL; END IF;
    IF p_dimtype='DEPARTMENT' THEN
        WITH RECURSIVE t AS (
            SELECT departmentcode, namear, 0 AS lvl, namear::TEXT AS path, parentdepartmentcode
              FROM tbldim_departments WHERE departmentcode=p_dimcode
            UNION ALL
            SELECT d.departmentcode, d.namear, t.lvl+1, (d.namear||' / '||t.path)::TEXT, d.parentdepartmentcode
              FROM tbldim_departments d JOIN t ON d.departmentcode=t.parentdepartmentcode
        )
        SELECT path INTO v_path FROM t WHERE lvl=(SELECT MAX(lvl) FROM t);
    ELSIF p_dimtype='PROJECT' THEN
        WITH RECURSIVE t AS (
            SELECT projectcode, namear, 0 AS lvl, namear::TEXT AS path, parentprojectcode
              FROM tbldim_projects WHERE projectcode=p_dimcode
            UNION ALL
            SELECT p.projectcode, p.namear, t.lvl+1, (p.namear||' / '||t.path)::TEXT, p.parentprojectcode
              FROM tbldim_projects p JOIN t ON p.projectcode=t.parentprojectcode
        )
        SELECT path INTO v_path FROM t WHERE lvl=(SELECT MAX(lvl) FROM t);
    ELSIF p_dimtype='COSTCENTER' THEN
        WITH RECURSIVE t AS (
            SELECT costcentercode, costcenternamear, 0 AS lvl, costcenternamear::TEXT AS path, parentcostcentercode
              FROM tblcostcenters WHERE costcentercode=p_dimcode
            UNION ALL
            SELECT c.costcentercode, c.costcenternamear, t.lvl+1, (c.costcenternamear||' / '||t.path)::TEXT, c.parentcostcentercode
              FROM tblcostcenters c JOIN t ON c.costcentercode=t.parentcostcentercode
        )
        SELECT path INTO v_path FROM t WHERE lvl=(SELECT MAX(lvl) FROM t);
    ELSE
        SELECT namear INTO v_path FROM tbldim_businessunits WHERE businessunitcode=p_dimcode AND p_dimtype='BUSINESSUNIT';
        IF v_path IS NULL THEN
            SELECT namear INTO v_path FROM tbldim_segments WHERE segmentcode=p_dimcode AND p_dimtype='SEGMENT';
        END IF;
        IF v_path IS NULL THEN
            SELECT namear INTO v_path FROM tbldim_profitcenters WHERE profitcentercode=p_dimcode AND p_dimtype='PROFITCENTER';
        END IF;
    END IF;
    RETURN v_path;
END$$;

-- =====================================================================
-- SECTION 7 — INTEGRATION VIEWS
-- =====================================================================

-- 7.1 Journal body with all dimensions resolved ------------------------
CREATE OR REPLACE VIEW vw_journalbody_with_dimensions AS
SELECT
    jb.journaldetailid, jb.journalcode, jb.linenumber, jb.accountcode,
    cc.costcentercode, cc.costcenternamear AS costcentername,
    d.departmentcode, d.namear AS departmentname,
    p.projectcode, p.namear AS projectname,
    bu.businessunitcode, bu.namear AS businessunitname,
    s.segmentcode, s.namear AS segmentname,
    pc.profitcentercode, pc.namear AS profitcentername,
    jb.description, jb.debit, jb.credit, jb.currencycode,
    jb.debitlocal, jb.creditlocal
FROM tbljournalbody jb
LEFT JOIN tblcostcenters       cc  ON cc.costcentercode    = jb.costcentercode
LEFT JOIN tbldim_departments   d   ON d.departmentcode     = jb.departmentcode
LEFT JOIN tbldim_projects      p   ON p.projectcode        = jb.projectcode
LEFT JOIN tbldim_businessunits bu  ON bu.businessunitcode  = jb.businessunitcode
LEFT JOIN tbldim_segments      s   ON s.segmentcode        = jb.segmentcode
LEFT JOIN tbldim_profitcenters pc  ON pc.profitcentercode  = jb.profitcentercode;

-- 7.2 Bond header with all dimensions resolved -------------------------
CREATE OR REPLACE VIEW vw_bond_with_dimensions AS
SELECT
    bh.bondcode, bh.bondid, bh.bondtype, bh.bonddate, bh.fiscalyear, bh.fiscalperiod,
    bh.amount, bh.currencycode, bh.exchangerate,
    bh.paymentmethodcode, bh.bankcode, bh.fundcode,
    bh.customercode, bh.suppliercode, bh.accountcode,
    d.departmentcode, d.namear AS departmentname,
    p.projectcode, p.namear AS projectname,
    bu.businessunitcode, bu.namear AS businessunitname,
    s.segmentcode, s.namear AS segmentname,
    pc.profitcentercode, pc.namear AS profitcentername,
    cc.costcentercode, cc.costcenternamear AS costcentername,
    bh.isposted, bh.approvalrequestid, bh.notes
FROM tblbondheader bh
LEFT JOIN tbldim_departments   d   ON d.departmentcode     = bh.departmentcode
LEFT JOIN tbldim_projects      p   ON p.projectcode        = bh.projectcode
LEFT JOIN tbldim_businessunits bu  ON bu.businessunitcode  = bh.businessunitcode
LEFT JOIN tbldim_segments      s   ON s.segmentcode        = bh.segmentcode
LEFT JOIN tbldim_profitcenters pc  ON pc.profitcentercode  = bh.profitcentercode
LEFT JOIN tblcostcenters       cc  ON cc.costcentercode    = bh.accountcode  -- existing legacy link (kept harmless)
   AND FALSE;  -- note: tblbondheader does not have costcentercode in current schema

-- 7.3 Treasury (cash receipts + payments + bank txns) with dimensions -
CREATE OR REPLACE VIEW vw_treasury_with_dimensions AS
SELECT 'CASH_RECEIPT' AS txntype, r.receiptid::TEXT AS txnid, r.receiptno AS txnno,
       r.receiptdate AS txndate, r.amount, r.currid, r.exgrate, r.amountlocal,
       r.customerid, r.supplierid, r.status, r.approvalrequestid,
       r.departmentcode, d.namear AS departmentname,
       r.projectcode, p.namear AS projectname,
       r.businessunitcode, bu.namear AS businessunitname,
       r.segmentcode, s.namear AS segmentname,
       r.profitcentercode, pc.namear AS profitcentername
  FROM tblcashreceipts r
  LEFT JOIN tbldim_departments   d  ON d.departmentcode    = r.departmentcode
  LEFT JOIN tbldim_projects      p  ON p.projectcode       = r.projectcode
  LEFT JOIN tbldim_businessunits bu ON bu.businessunitcode = r.businessunitcode
  LEFT JOIN tbldim_segments      s  ON s.segmentcode       = r.segmentcode
  LEFT JOIN tbldim_profitcenters pc ON pc.profitcentercode = r.profitcentercode
UNION ALL
SELECT 'CASH_PAYMENT', p.paymentid::TEXT, p.paymentno,
       p.paymentdate, p.amount, p.currid, p.exgrate, p.amountlocal,
       p.customerid, p.supplierid, p.status, p.approvalrequestid,
       p.departmentcode, d.namear,
       p.projectcode, pr.namear,
       p.businessunitcode, bu.namear,
       p.segmentcode, s.namear,
       p.profitcentercode, pc.namear
  FROM tblcashpayments p
  LEFT JOIN tbldim_departments   d  ON d.departmentcode    = p.departmentcode
  LEFT JOIN tbldim_projects      pr ON pr.projectcode      = p.projectcode
  LEFT JOIN tbldim_businessunits bu ON bu.businessunitcode = p.businessunitcode
  LEFT JOIN tbldim_segments      s  ON s.segmentcode       = p.segmentcode
  LEFT JOIN tbldim_profitcenters pc ON pc.profitcentercode = p.profitcentercode
UNION ALL
SELECT 'BANK_TXN', b.banktxnid::TEXT, b.refno,
       b.txndate, b.amount, b.currid, b.exgrate, b.amountlocal,
       NULL, NULL, b.status, b.approvalrequestid,
       b.departmentcode, d.namear,
       b.projectcode, pr.namear,
       b.businessunitcode, bu.namear,
       b.segmentcode, s.namear,
       b.profitcentercode, pc.namear
  FROM tblbanktransactions b
  LEFT JOIN tbldim_departments   d  ON d.departmentcode    = b.departmentcode
  LEFT JOIN tbldim_projects      pr ON pr.projectcode      = b.projectcode
  LEFT JOIN tbldim_businessunits bu ON bu.businessunitcode = b.businessunitcode
  LEFT JOIN tbldim_segments      s  ON s.segmentcode       = b.segmentcode
  LEFT JOIN tbldim_profitcenters pc ON pc.profitcentercode = b.profitcentercode;

-- 7.4 Budget vs actual grouped by any dimension -----------------------
CREATE OR REPLACE VIEW vw_budgetvsactual_by_dimension AS
SELECT 'DEPARTMENT' AS dimtype, b.departmentcode::TEXT AS dimcode,
       NULL::TEXT AS dimname, b.periodid, b.accountid, b.branchid,
       b.budgetamount, COALESCE(SUM(GREATEST(jb.debit, jb.credit)),0) AS actualamount,
       b.budgetamount - COALESCE(SUM(GREATEST(jb.debit, jb.credit)),0) AS varianceamount
  FROM tblbudgets b
  LEFT JOIN tbljournalbody jb ON jb.departmentcode = b.departmentcode
  LEFT JOIN tbljournalheader jh ON jh.journalcode = jb.journalcode AND jh.isposted=TRUE AND jh.iscancelled=FALSE
 WHERE b.departmentcode IS NOT NULL
 GROUP BY b.departmentcode, b.periodid, b.accountid, b.branchid, b.budgetamount
UNION ALL
SELECT 'PROJECT', b.projectcode::TEXT, NULL, b.periodid, b.accountid, b.branchid,
       b.budgetamount, COALESCE(SUM(GREATEST(jb.debit, jb.credit)),0),
       b.budgetamount - COALESCE(SUM(GREATEST(jb.debit, jb.credit)),0)
  FROM tblbudgets b
  LEFT JOIN tbljournalbody jb ON jb.projectcode = b.projectcode
  LEFT JOIN tbljournalheader jh ON jh.journalcode = jb.journalcode AND jh.isposted=TRUE AND jh.iscancelled=FALSE
 WHERE b.projectcode IS NOT NULL
 GROUP BY b.projectcode, b.periodid, b.accountid, b.branchid, b.budgetamount
UNION ALL
SELECT 'BUSINESSUNIT', b.businessunitcode::TEXT, NULL, b.periodid, b.accountid, b.branchid,
       b.budgetamount, COALESCE(SUM(GREATEST(jb.debit, jb.credit)),0),
       b.budgetamount - COALESCE(SUM(GREATEST(jb.debit, jb.credit)),0)
  FROM tblbudgets b
  LEFT JOIN tbljournalbody jb ON jb.businessunitcode = b.businessunitcode
  LEFT JOIN tbljournalheader jh ON jh.journalcode = jb.journalcode AND jh.isposted=TRUE AND jh.iscancelled=FALSE
 WHERE b.businessunitcode IS NOT NULL
 GROUP BY b.businessunitcode, b.periodid, b.accountid, b.branchid, b.budgetamount
UNION ALL
SELECT 'COSTCENTER', b.costcenterid::TEXT, cc.costcenternamear, b.periodid, b.accountid, b.branchid,
       b.budgetamount, COALESCE(SUM(GREATEST(jb.debit, jb.credit)),0),
       b.budgetamount - COALESCE(SUM(GREATEST(jb.debit, jb.credit)),0)
  FROM tblbudgets b
  LEFT JOIN tblcostcenters cc ON cc.costcentercode = b.costcenterid
  LEFT JOIN tbljournalbody jb ON jb.costcentercode = b.costcenterid
  LEFT JOIN tbljournalheader jh ON jh.journalcode = jb.journalcode AND jh.isposted=TRUE AND jh.iscancelled=FALSE
 WHERE b.costcenterid IS NOT NULL
 GROUP BY b.costcenterid, cc.costcenternamear, b.periodid, b.accountid, b.branchid, b.budgetamount;

-- 7.5 Cost center hierarchy (recursive view) --------------------------
CREATE OR REPLACE VIEW vw_costcenter_hierarchy AS
WITH RECURSIVE t AS (
    SELECT costcentercode, costcenterid, costcenternamear, costcenternameen,
           0 AS level, costcenternamear::TEXT AS fullpath, parentcostcentercode, isactive
      FROM tblcostcenters WHERE parentcostcentercode IS NULL
    UNION ALL
    SELECT c.costcentercode, c.costcenterid, c.costcenternamear, c.costcenternameen,
           t.level+1, (t.fullpath||' / '||c.costcenternamear)::TEXT, c.parentcostcentercode, c.isactive
      FROM tblcostcenters c JOIN t ON c.parentcostcentercode=t.costcentercode
)
SELECT * FROM t ORDER BY fullpath;

-- 7.6 Dimensions summary view (counts per type) -----------------------
CREATE OR REPLACE VIEW vw_dimensions_summary AS
SELECT 'DEPARTMENT' AS dimtype, COUNT(*) AS total, SUM(CASE WHEN isactive THEN 1 ELSE 0 END) AS active FROM tbldim_departments
UNION ALL SELECT 'PROJECT', COUNT(*), SUM(CASE WHEN isactive THEN 1 ELSE 0 END) FROM tbldim_projects
UNION ALL SELECT 'BUSINESSUNIT', COUNT(*), SUM(CASE WHEN isactive THEN 1 ELSE 0 END) FROM tbldim_businessunits
UNION ALL SELECT 'SEGMENT', COUNT(*), SUM(CASE WHEN isactive THEN 1 ELSE 0 END) FROM tbldim_segments
UNION ALL SELECT 'PROFITCENTER', COUNT(*), SUM(CASE WHEN isactive THEN 1 ELSE 0 END) FROM tbldim_profitcenters
UNION ALL SELECT 'COSTCENTER', COUNT(*), SUM(CASE WHEN isactive THEN 1 ELSE 0 END) FROM tblcostcenters;

-- 7.7 Dimension usage analytics (FK counts) ---------------------------
CREATE OR REPLACE VIEW vw_dimension_usage AS
SELECT 'BOND' AS source, 'DEPARTMENT' AS dimtype, COUNT(*) AS usage_count
  FROM tblbondheader WHERE departmentcode IS NOT NULL
UNION ALL SELECT 'BOND', 'PROJECT', COUNT(*) FROM tblbondheader WHERE projectcode IS NOT NULL
UNION ALL SELECT 'BOND', 'BUSINESSUNIT', COUNT(*) FROM tblbondheader WHERE businessunitcode IS NOT NULL
UNION ALL SELECT 'BOND', 'SEGMENT', COUNT(*) FROM tblbondheader WHERE segmentcode IS NOT NULL
UNION ALL SELECT 'BOND', 'PROFITCENTER', COUNT(*) FROM tblbondheader WHERE profitcentercode IS NOT NULL
UNION ALL SELECT 'JOURNAL_BODY', 'DEPARTMENT', COUNT(*) FROM tbljournalbody WHERE departmentcode IS NOT NULL
UNION ALL SELECT 'JOURNAL_BODY', 'PROJECT', COUNT(*) FROM tbljournalbody WHERE projectcode IS NOT NULL
UNION ALL SELECT 'CASH_RECEIPT', 'DEPARTMENT', COUNT(*) FROM tblcashreceipts WHERE departmentcode IS NOT NULL
UNION ALL SELECT 'CASH_RECEIPT', 'PROJECT', COUNT(*) FROM tblcashreceipts WHERE projectcode IS NOT NULL
UNION ALL SELECT 'CASH_PAYMENT', 'DEPARTMENT', COUNT(*) FROM tblcashpayments WHERE departmentcode IS NOT NULL
UNION ALL SELECT 'BANK_TXN', 'DEPARTMENT', COUNT(*) FROM tblbanktransactions WHERE departmentcode IS NOT NULL
UNION ALL SELECT 'BUDGET', 'DEPARTMENT', COUNT(*) FROM tblbudgets WHERE departmentcode IS NOT NULL
UNION ALL SELECT 'BUDGET', 'PROJECT', COUNT(*) FROM tblbudgets WHERE projectcode IS NOT NULL;

-- =====================================================================
-- SECTION 8 — APPROVAL WORKFLOW INTEGRATION
-- =====================================================================

-- 8.1 Add config key for dimension-based amount threshold ----------
INSERT INTO tblapprovalconfig (configkey, configvalue, description, adduser)
SELECT 'DIMENSION_AUTO_APPROVE_THRESHOLD', '0.0000',
       'Threshold above which a transaction with dimension override is auto-submitted (0=always)', 0
WHERE NOT EXISTS (SELECT 1 FROM tblapprovalconfig WHERE configkey='DIMENSION_AUTO_APPROVE_THRESHOLD');

-- 8.2 New approval workflow: DIMENSION_MASTER_CHANGE ----------------
INSERT INTO tblapprovalworkflows (workflowcode, workflownamear, workflownameen, sourcetype, description, isactive, adduser)
SELECT 'DIMENSION_MASTER_CHANGE',
       'تغيير بيانات الأبعاد الرئيسية',
       'Dimension Master Change',
       'OTHER',
       'Approval required for adding/editing critical dimension master codes (Departments/Projects/BUs/PCs)',
       TRUE, 0
WHERE NOT EXISTS (SELECT 1 FROM tblapprovalworkflows WHERE workflowcode='DIMENSION_MASTER_CHANGE');

-- 8.3 Default 2-level chain for the new workflow --------------------
DO $$
DECLARE
    v_wf INTEGER;
BEGIN
    SELECT workflowid INTO v_wf FROM tblapprovalworkflows WHERE workflowcode='DIMENSION_MASTER_CHANGE';
    IF v_wf IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM tblapprovallevels WHERE workflowid=v_wf AND levelnumber=1) THEN
            INSERT INTO tblapprovallevels(workflowid, levelnumber, levelnamear, levelnameen, requiredrole, amountmin, amountmax, ismandatory, isactive)
            VALUES (v_wf, 1, 'المستوى الأول - المدير المالي', 'Level 1 - Finance Manager', 'FINANCE_MANAGER', 0, 999999999, TRUE, TRUE);
        END IF;
        IF NOT EXISTS (SELECT 1 FROM tblapprovallevels WHERE workflowid=v_wf AND levelnumber=2) THEN
            INSERT INTO tblapprovallevels(workflowid, levelnumber, levelnamear, levelnameen, requiredrole, amountmin, amountmax, ismandatory, isactive)
            VALUES (v_wf, 2, 'المستوى الثاني - المدير التنفيذي', 'Level 2 - CFO', 'CFO', 0, 999999999, TRUE, TRUE);
        END IF;
    END IF;
END$$;

-- =====================================================================
-- SECTION 9 — TRIGGER: auto-update project.actualamount on journal post
-- =====================================================================

CREATE OR REPLACE FUNCTION fn_dim_updateprojectactual() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.projectcode IS NOT NULL THEN
        UPDATE tbldim_projects
           SET actualamount = COALESCE(actualamount,0)
                             + COALESCE(NEW.debitlocal, NEW.debit, 0)
                             - COALESCE(NEW.creditlocal, NEW.credit, 0),
               editdate = CURRENT_TIMESTAMP
         WHERE projectcode = NEW.projectcode;
    END IF;
    RETURN NEW;
END$$;

DROP TRIGGER IF EXISTS trg_dim_journalbody_updateprojectactual ON tbljournalbody;
CREATE TRIGGER trg_dim_journalbody_updateprojectactual
AFTER INSERT ON tbljournalbody
FOR EACH ROW
EXECUTE FUNCTION fn_dim_updateprojectactual();

-- =====================================================================
-- SECTION 10 — TRIGGER: validate dimensions on insert (journal body)
-- (raises exception if any dimension is referenced but inactive/closed)
-- =====================================================================

CREATE OR REPLACE FUNCTION fn_dim_validateondimcolumns() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE v_bad TEXT;
BEGIN
    v_bad := validateAllDimensions(NEW.departmentcode, NEW.projectcode,
                                   NEW.businessunitcode, NEW.segmentcode,
                                   NEW.profitcentercode, NEW.costcentercode);
    IF v_bad IS NOT NULL THEN
        RAISE EXCEPTION 'Invalid or inactive dimension(s) referenced: %', v_bad
            USING ERRCODE = '23514';
    END IF;
    RETURN NEW;
END$$;

DROP TRIGGER IF EXISTS trg_dim_journalbody_validate ON tbljournalbody;
CREATE TRIGGER trg_dim_journalbody_validate
BEFORE INSERT OR UPDATE ON tbljournalbody
FOR EACH ROW
EXECUTE FUNCTION fn_dim_validateondimcolumns();

DROP TRIGGER IF EXISTS trg_dim_bondheader_validate ON tblbondheader;
CREATE TRIGGER trg_dim_bondheader_validate
BEFORE INSERT OR UPDATE ON tblbondheader
FOR EACH ROW
EXECUTE FUNCTION fn_dim_validateondimcolumns();  -- uses only 5 cols (CC not in bond)

-- (cash receipts/payments/bank transactions use the same validation but
--  only have 5 dimension columns; the function ignores CC if not present)

-- =====================================================================
-- SECTION 11 — DONE. Verification queries follow below.
-- =====================================================================

-- Verification counts (do not fail script if mismatched)
DO $$
DECLARE
    v_tables INTEGER; v_funcs INTEGER; v_views INTEGER; v_trig INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_tables FROM information_schema.tables
      WHERE table_schema='public' AND table_type='BASE TABLE'
        AND (table_name LIKE 'tbldim_%' OR table_name='tblcostcenters');
    SELECT COUNT(*) INTO v_funcs FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid
      WHERE n.nspname='public' AND p.prokind='f' AND (proname LIKE 'get%dim%' OR proname LIKE 'get%Depart%' OR proname LIKE 'get%Proj%' OR proname LIKE 'get%Business%' OR proname LIKE 'get%Seg%' OR proname LIKE 'get%Profit%' OR proname LIKE 'add%Depart%' OR proname LIKE 'add%Proj%' OR proname LIKE 'add%Business%' OR proname LIKE 'add%Seg%' OR proname LIKE 'add%Profit%' OR proname LIKE 'update%Depart%' OR proname LIKE 'update%Proj%' OR proname LIKE 'update%Business%' OR proname LIKE 'update%Seg%' OR proname LIKE 'update%Profit%' OR proname LIKE 'delete%Depart%' OR proname LIKE 'delete%Proj%' OR proname LIKE 'delete%Business%' OR proname LIKE 'delete%Seg%' OR proname LIKE 'delete%Profit%' OR proname='validateDimension' OR proname='validateAllDimensions');
    SELECT COUNT(*) INTO v_views FROM information_schema.views
      WHERE table_schema='public' AND (table_name LIKE 'vw_%dim%' OR table_name='vw_journalbody_with_dimensions' OR table_name='vw_bond_with_dimensions' OR table_name='vw_treasury_with_dimensions' OR table_name='vw_budgetvsactual_by_dimension' OR table_name='vw_costcenter_hierarchy' OR table_name='vw_dimensions_summary' OR table_name='vw_dimension_usage');
    SELECT COUNT(*) INTO v_trig FROM information_schema.triggers
      WHERE trigger_schema='public' AND trigger_name LIKE 'trg_dim_%';
    RAISE NOTICE 'PHASE 4 INSTALLED — dimension tables/related: %, functions: %, views: %, new triggers: %', v_tables, v_funcs, v_views, v_trig;
END$$;
