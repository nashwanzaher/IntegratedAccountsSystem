using System;
using System.Data;
using Npgsql;
using NpgsqlTypes;

namespace IntegratedAccSys.BL.Dimensions
{
    /// <summary>
    /// PHASE 4 — Cost Centers & Dimensions Engine wrapper.
    ///
    /// Bridges C# / WinForms code with the 41 PostgreSQL functions, 7 views,
    /// 5 triggers and 1 approval workflow installed by:
    ///   database/IntegratedAccSys_Dimensions_Phase4.sql
    ///
    /// Covers 6 dimension types: Departments, Projects, Business Units,
    /// Segments, Profit Centers, Cost Centers (legacy tblcostcenters).
    ///
    /// All calls flow through the shared DbContextProvider (same as
    /// clsAccounts, clsUsers, etc.) for consistent connection pooling
    /// and the SP→FUNCTION auto-dispatch in DbContext.
    /// </summary>
    public class ClsDimensions
    {
        private static readonly DAL.DbContextProvider _ctx = DAL.DbContextProvider.Instance;

        // ============================================================
        //  DEPARTMENTS
        // ============================================================
        public int AddDepartment(string? departmentId, string? nameAr, string? nameEn,
            int? parentDepartmentCode, int? managerUserCode,
            bool isActive, DateTime? effectiveDate, DateTime? endDate,
            string? notes, int? addUser)
        {
            return _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[10];
                para[0] = new NpgsqlParameter("@p_departmentid", NpgsqlDbType.Varchar)
                { Value = ((object?)departmentId) ?? DBNull.Value };
                para[1] = new NpgsqlParameter("@p_namear", NpgsqlDbType.Varchar)
                { Value = ((object?)nameAr) ?? DBNull.Value };
                para[2] = new NpgsqlParameter("@p_nameen", NpgsqlDbType.Varchar)
                { Value = ((object?)nameEn) ?? DBNull.Value };
                para[3] = new NpgsqlParameter("@p_parentdepartmentcode", NpgsqlDbType.Integer)
                { Value = ((object?)parentDepartmentCode) ?? DBNull.Value };
                para[4] = new NpgsqlParameter("@p_managerusercode", NpgsqlDbType.Integer)
                { Value = ((object?)managerUserCode) ?? DBNull.Value };
                para[5] = new NpgsqlParameter("@p_isactive", NpgsqlDbType.Boolean) { Value = isActive };
                para[6] = new NpgsqlParameter("@p_effectivedate", NpgsqlDbType.Date)
                { Value = ((object?)effectiveDate) ?? DBNull.Value };
                para[7] = new NpgsqlParameter("@p_enddate", NpgsqlDbType.Date)
                { Value = ((object?)endDate) ?? DBNull.Value };
                para[8] = new NpgsqlParameter("@p_notes", NpgsqlDbType.Text) { Value = ((object?)notes) ?? DBNull.Value };
                para[9] = new NpgsqlParameter("@p_adduser", NpgsqlDbType.Integer)
                { Value = ((object?)addUser) ?? DBNull.Value };
                var dt = ctx.SelectData("addDepartment", para);
                return dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
            });
        }

        public void UpdateDepartment(int departmentCode, string? departmentId, string? nameAr, string? nameEn,
            int? parentDepartmentCode, int? managerUserCode,
            bool? isActive, DateTime? effectiveDate, DateTime? endDate,
            string? notes, int? editUser)
        {
            _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[11];
                para[0] = new NpgsqlParameter("@p_departmentcode", NpgsqlDbType.Integer) { Value = departmentCode };
                para[1] = new NpgsqlParameter("@p_departmentid", NpgsqlDbType.Varchar)
                { Value = ((object?)departmentId) ?? DBNull.Value };
                para[2] = new NpgsqlParameter("@p_namear", NpgsqlDbType.Varchar)
                { Value = ((object?)nameAr) ?? DBNull.Value };
                para[3] = new NpgsqlParameter("@p_nameen", NpgsqlDbType.Varchar)
                { Value = ((object?)nameEn) ?? DBNull.Value };
                para[4] = new NpgsqlParameter("@p_parentdepartmentcode", NpgsqlDbType.Integer)
                { Value = ((object?)parentDepartmentCode) ?? DBNull.Value };
                para[5] = new NpgsqlParameter("@p_managerusercode", NpgsqlDbType.Integer)
                { Value = ((object?)managerUserCode) ?? DBNull.Value };
                para[6] = new NpgsqlParameter("@p_isactive", NpgsqlDbType.Boolean)
                { Value = ((object?)isActive) ?? DBNull.Value };
                para[7] = new NpgsqlParameter("@p_effectivedate", NpgsqlDbType.Date)
                { Value = ((object?)effectiveDate) ?? DBNull.Value };
                para[8] = new NpgsqlParameter("@p_enddate", NpgsqlDbType.Date)
                { Value = ((object?)endDate) ?? DBNull.Value };
                para[9] = new NpgsqlParameter("@p_notes", NpgsqlDbType.Text) { Value = ((object?)notes) ?? DBNull.Value };
                para[10] = new NpgsqlParameter("@p_edituser", NpgsqlDbType.Integer)
                { Value = ((object?)editUser) ?? DBNull.Value };
                ctx.Execute("updateDepartment", para);
            });
        }

        public void DeleteDepartment(int departmentCode, int? editUser)
        {
            _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[2];
                para[0] = new NpgsqlParameter("@p_departmentcode", NpgsqlDbType.Integer) { Value = departmentCode };
                para[1] = new NpgsqlParameter("@p_edituser", NpgsqlDbType.Integer)
                { Value = ((object?)editUser) ?? DBNull.Value };
                ctx.Execute("deleteDepartment", para);
            });
        }

        public DataTable GetAllDepartments() => _ctx.Execute(ctx => ctx.SelectData("getAllDepartments", null));

        public DataTable GetDepartmentData(int departmentCode)
        {
            return _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[1];
                para[0] = new NpgsqlParameter("@p_departmentcode", NpgsqlDbType.Integer) { Value = departmentCode };
                return ctx.SelectData("getDepartmentData", para);
            });
        }

        public DataTable GetDepartmentTree() => _ctx.Execute(ctx => ctx.SelectData("getDepartmentTree", null));

        // ============================================================
        //  PROJECTS
        // ============================================================
        public int AddProject(string? projectId, string? nameAr, string? nameEn,
            int? parentProjectCode, string? projectType,
            DateTime? startDate, DateTime? endDate,
            decimal budgetAmount, string? projectStatus,
            bool isActive, string? notes, int? addUser)
        {
            return _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[12];
                para[0] = new NpgsqlParameter("@p_projectid", NpgsqlDbType.Varchar)
                { Value = ((object?)projectId) ?? DBNull.Value };
                para[1] = new NpgsqlParameter("@p_namear", NpgsqlDbType.Varchar)
                { Value = ((object?)nameAr) ?? DBNull.Value };
                para[2] = new NpgsqlParameter("@p_nameen", NpgsqlDbType.Varchar)
                { Value = ((object?)nameEn) ?? DBNull.Value };
                para[3] = new NpgsqlParameter("@p_parentprojectcode", NpgsqlDbType.Integer)
                { Value = ((object?)parentProjectCode) ?? DBNull.Value };
                para[4] = new NpgsqlParameter("@p_projecttype", NpgsqlDbType.Varchar)
                { Value = ((object?)projectType) ?? DBNull.Value };
                para[5] = new NpgsqlParameter("@p_startdate", NpgsqlDbType.Date)
                { Value = ((object?)startDate) ?? DBNull.Value };
                para[6] = new NpgsqlParameter("@p_enddate", NpgsqlDbType.Date)
                { Value = ((object?)endDate) ?? DBNull.Value };
                para[7] = new NpgsqlParameter("@p_budgetamount", NpgsqlDbType.Numeric) { Value = budgetAmount };
                para[8] = new NpgsqlParameter("@p_projectstatus", NpgsqlDbType.Varchar)
                { Value = ((object?)projectStatus) ?? DBNull.Value };
                para[9] = new NpgsqlParameter("@p_isactive", NpgsqlDbType.Boolean) { Value = isActive };
                para[10] = new NpgsqlParameter("@p_notes", NpgsqlDbType.Text) { Value = ((object?)notes) ?? DBNull.Value };
                para[11] = new NpgsqlParameter("@p_adduser", NpgsqlDbType.Integer)
                { Value = ((object?)addUser) ?? DBNull.Value };
                var dt = ctx.SelectData("addProject", para);
                return dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
            });
        }

        public void UpdateProject(int projectCode, string? projectId, string? nameAr, string? nameEn,
            int? parentProjectCode, string? projectType,
            DateTime? startDate, DateTime? endDate,
            decimal? budgetAmount, decimal? actualAmount, string? projectStatus,
            bool? isActive, string? notes, int? editUser)
        {
            _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[13];
                para[0] = new NpgsqlParameter("@p_projectcode", NpgsqlDbType.Integer) { Value = projectCode };
                para[1] = new NpgsqlParameter("@p_projectid", NpgsqlDbType.Varchar)
                { Value = ((object?)projectId) ?? DBNull.Value };
                para[2] = new NpgsqlParameter("@p_namear", NpgsqlDbType.Varchar)
                { Value = ((object?)nameAr) ?? DBNull.Value };
                para[3] = new NpgsqlParameter("@p_nameen", NpgsqlDbType.Varchar)
                { Value = ((object?)nameEn) ?? DBNull.Value };
                para[4] = new NpgsqlParameter("@p_parentprojectcode", NpgsqlDbType.Integer)
                { Value = ((object?)parentProjectCode) ?? DBNull.Value };
                para[5] = new NpgsqlParameter("@p_projecttype", NpgsqlDbType.Varchar)
                { Value = ((object?)projectType) ?? DBNull.Value };
                para[6] = new NpgsqlParameter("@p_startdate", NpgsqlDbType.Date)
                { Value = ((object?)startDate) ?? DBNull.Value };
                para[7] = new NpgsqlParameter("@p_enddate", NpgsqlDbType.Date)
                { Value = ((object?)endDate) ?? DBNull.Value };
                para[8] = new NpgsqlParameter("@p_budgetamount", NpgsqlDbType.Numeric)
                { Value = ((object?)budgetAmount) ?? DBNull.Value };
                para[9] = new NpgsqlParameter("@p_actualamount", NpgsqlDbType.Numeric)
                { Value = ((object?)actualAmount) ?? DBNull.Value };
                para[10] = new NpgsqlParameter("@p_projectstatus", NpgsqlDbType.Varchar)
                { Value = ((object?)projectStatus) ?? DBNull.Value };
                para[11] = new NpgsqlParameter("@p_isactive", NpgsqlDbType.Boolean)
                { Value = ((object?)isActive) ?? DBNull.Value };
                para[12] = new NpgsqlParameter("@p_notes", NpgsqlDbType.Text) { Value = ((object?)notes) ?? DBNull.Value };
                // edituser parameter is param 13 — add separately
                var para2 = new NpgsqlParameter[14];
                Array.Copy(para, para2, 13);
                para2[13] = new NpgsqlParameter("@p_edituser", NpgsqlDbType.Integer)
                { Value = ((object?)editUser) ?? DBNull.Value };
                ctx.Execute("updateProject", para2);
            });
        }

        public void DeleteProject(int projectCode, int? editUser)
        {
            _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[2];
                para[0] = new NpgsqlParameter("@p_projectcode", NpgsqlDbType.Integer) { Value = projectCode };
                para[1] = new NpgsqlParameter("@p_edituser", NpgsqlDbType.Integer)
                { Value = ((object?)editUser) ?? DBNull.Value };
                ctx.Execute("deleteProject", para);
            });
        }

        public DataTable GetAllProjects() => _ctx.Execute(ctx => ctx.SelectData("getAllProjects", null));

        public DataTable GetProjectData(int projectCode)
        {
            return _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[1];
                para[0] = new NpgsqlParameter("@p_projectcode", NpgsqlDbType.Integer) { Value = projectCode };
                return ctx.SelectData("getProjectData", para);
            });
        }

        public DataTable GetProjectTree() => _ctx.Execute(ctx => ctx.SelectData("getProjectTree", null));

        // ============================================================
        //  BUSINESS UNITS
        // ============================================================
        public int AddBusinessUnit(string? businessUnitId, string? nameAr, string? nameEn,
            int? parentBusinessUnitCode, bool isActive,
            string? notes, int? addUser)
        {
            return _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[7];
                para[0] = new NpgsqlParameter("@p_businessunitid", NpgsqlDbType.Varchar)
                { Value = ((object?)businessUnitId) ?? DBNull.Value };
                para[1] = new NpgsqlParameter("@p_namear", NpgsqlDbType.Varchar)
                { Value = ((object?)nameAr) ?? DBNull.Value };
                para[2] = new NpgsqlParameter("@p_nameen", NpgsqlDbType.Varchar)
                { Value = ((object?)nameEn) ?? DBNull.Value };
                para[3] = new NpgsqlParameter("@p_parentbusinessunitcode", NpgsqlDbType.Integer)
                { Value = ((object?)parentBusinessUnitCode) ?? DBNull.Value };
                para[4] = new NpgsqlParameter("@p_isactive", NpgsqlDbType.Boolean) { Value = isActive };
                para[5] = new NpgsqlParameter("@p_notes", NpgsqlDbType.Text) { Value = ((object?)notes) ?? DBNull.Value };
                para[6] = new NpgsqlParameter("@p_adduser", NpgsqlDbType.Integer)
                { Value = ((object?)addUser) ?? DBNull.Value };
                var dt = ctx.SelectData("addBusinessUnit", para);
                return dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
            });
        }

        public void UpdateBusinessUnit(int businessUnitCode, string? businessUnitId, string? nameAr, string? nameEn,
            int? parentBusinessUnitCode, bool? isActive,
            string? notes, int? editUser)
        {
            _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[8];
                para[0] = new NpgsqlParameter("@p_businessunitcode", NpgsqlDbType.Integer) { Value = businessUnitCode };
                para[1] = new NpgsqlParameter("@p_businessunitid", NpgsqlDbType.Varchar)
                { Value = ((object?)businessUnitId) ?? DBNull.Value };
                para[2] = new NpgsqlParameter("@p_namear", NpgsqlDbType.Varchar)
                { Value = ((object?)nameAr) ?? DBNull.Value };
                para[3] = new NpgsqlParameter("@p_nameen", NpgsqlDbType.Varchar)
                { Value = ((object?)nameEn) ?? DBNull.Value };
                para[4] = new NpgsqlParameter("@p_parentbusinessunitcode", NpgsqlDbType.Integer)
                { Value = ((object?)parentBusinessUnitCode) ?? DBNull.Value };
                para[5] = new NpgsqlParameter("@p_isactive", NpgsqlDbType.Boolean)
                { Value = ((object?)isActive) ?? DBNull.Value };
                para[6] = new NpgsqlParameter("@p_notes", NpgsqlDbType.Text) { Value = ((object?)notes) ?? DBNull.Value };
                para[7] = new NpgsqlParameter("@p_edituser", NpgsqlDbType.Integer)
                { Value = ((object?)editUser) ?? DBNull.Value };
                ctx.Execute("updateBusinessUnit", para);
            });
        }

        public void DeleteBusinessUnit(int businessUnitCode, int? editUser)
        {
            _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[2];
                para[0] = new NpgsqlParameter("@p_businessunitcode", NpgsqlDbType.Integer) { Value = businessUnitCode };
                para[1] = new NpgsqlParameter("@p_edituser", NpgsqlDbType.Integer)
                { Value = ((object?)editUser) ?? DBNull.Value };
                ctx.Execute("deleteBusinessUnit", para);
            });
        }

        public DataTable GetAllBusinessUnits() => _ctx.Execute(ctx => ctx.SelectData("getAllBusinessUnits", null));

        public DataTable GetBusinessUnitData(int businessUnitCode)
        {
            return _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[1];
                para[0] = new NpgsqlParameter("@p_businessunitcode", NpgsqlDbType.Integer) { Value = businessUnitCode };
                return ctx.SelectData("getBusinessUnitData", para);
            });
        }

        public DataTable GetBusinessUnitTree() => _ctx.Execute(ctx => ctx.SelectData("getBusinessUnitTree", null));

        // ============================================================
        //  SEGMENTS
        // ============================================================
        public int AddSegment(string? segmentId, string? nameAr, string? nameEn,
            string? segmentType, int? parentSegmentCode,
            bool isActive, string? notes, int? addUser)
        {
            return _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[8];
                para[0] = new NpgsqlParameter("@p_segmentid", NpgsqlDbType.Varchar)
                { Value = ((object?)segmentId) ?? DBNull.Value };
                para[1] = new NpgsqlParameter("@p_namear", NpgsqlDbType.Varchar)
                { Value = ((object?)nameAr) ?? DBNull.Value };
                para[2] = new NpgsqlParameter("@p_nameen", NpgsqlDbType.Varchar)
                { Value = ((object?)nameEn) ?? DBNull.Value };
                para[3] = new NpgsqlParameter("@p_segmenttype", NpgsqlDbType.Varchar)
                { Value = ((object?)segmentType) ?? DBNull.Value };
                para[4] = new NpgsqlParameter("@p_parentsegmentcode", NpgsqlDbType.Integer)
                { Value = ((object?)parentSegmentCode) ?? DBNull.Value };
                para[5] = new NpgsqlParameter("@p_isactive", NpgsqlDbType.Boolean) { Value = isActive };
                para[6] = new NpgsqlParameter("@p_notes", NpgsqlDbType.Text) { Value = ((object?)notes) ?? DBNull.Value };
                para[7] = new NpgsqlParameter("@p_adduser", NpgsqlDbType.Integer)
                { Value = ((object?)addUser) ?? DBNull.Value };
                var dt = ctx.SelectData("addSegment", para);
                return dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
            });
        }

        public void UpdateSegment(int segmentCode, string? segmentId, string? nameAr, string? nameEn,
            string? segmentType, int? parentSegmentCode,
            bool? isActive, string? notes, int? editUser)
        {
            _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[8];
                para[0] = new NpgsqlParameter("@p_segmentcode", NpgsqlDbType.Integer) { Value = segmentCode };
                para[1] = new NpgsqlParameter("@p_segmentid", NpgsqlDbType.Varchar)
                { Value = ((object?)segmentId) ?? DBNull.Value };
                para[2] = new NpgsqlParameter("@p_namear", NpgsqlDbType.Varchar)
                { Value = ((object?)nameAr) ?? DBNull.Value };
                para[3] = new NpgsqlParameter("@p_nameen", NpgsqlDbType.Varchar)
                { Value = ((object?)nameEn) ?? DBNull.Value };
                para[4] = new NpgsqlParameter("@p_segmenttype", NpgsqlDbType.Varchar)
                { Value = ((object?)segmentType) ?? DBNull.Value };
                para[5] = new NpgsqlParameter("@p_parentsegmentcode", NpgsqlDbType.Integer)
                { Value = ((object?)parentSegmentCode) ?? DBNull.Value };
                para[6] = new NpgsqlParameter("@p_isactive", NpgsqlDbType.Boolean)
                { Value = ((object?)isActive) ?? DBNull.Value };
                para[7] = new NpgsqlParameter("@p_notes", NpgsqlDbType.Text) { Value = ((object?)notes) ?? DBNull.Value };
                // append edituser
                var para2 = new NpgsqlParameter[9];
                Array.Copy(para, para2, 8);
                para2[8] = new NpgsqlParameter("@p_edituser", NpgsqlDbType.Integer)
                { Value = ((object?)editUser) ?? DBNull.Value };
                ctx.Execute("updateSegment", para2);
            });
        }

        public void DeleteSegment(int segmentCode, int? editUser)
        {
            _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[2];
                para[0] = new NpgsqlParameter("@p_segmentcode", NpgsqlDbType.Integer) { Value = segmentCode };
                para[1] = new NpgsqlParameter("@p_edituser", NpgsqlDbType.Integer)
                { Value = ((object?)editUser) ?? DBNull.Value };
                ctx.Execute("deleteSegment", para);
            });
        }

        public DataTable GetAllSegments() => _ctx.Execute(ctx => ctx.SelectData("getAllSegments", null));

        public DataTable GetSegmentData(int segmentCode)
        {
            return _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[1];
                para[0] = new NpgsqlParameter("@p_segmentcode", NpgsqlDbType.Integer) { Value = segmentCode };
                return ctx.SelectData("getSegmentData", para);
            });
        }

        public DataTable GetSegmentTree() => _ctx.Execute(ctx => ctx.SelectData("getSegmentTree", null));

        // ============================================================
        //  PROFIT CENTERS
        // ============================================================
        public int AddProfitCenter(string? profitCenterId, string? nameAr, string? nameEn,
            int? parentProfitCenterCode, bool isActive,
            string? notes, int? addUser)
        {
            return _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[7];
                para[0] = new NpgsqlParameter("@p_profitcenterid", NpgsqlDbType.Varchar)
                { Value = ((object?)profitCenterId) ?? DBNull.Value };
                para[1] = new NpgsqlParameter("@p_namear", NpgsqlDbType.Varchar)
                { Value = ((object?)nameAr) ?? DBNull.Value };
                para[2] = new NpgsqlParameter("@p_nameen", NpgsqlDbType.Varchar)
                { Value = ((object?)nameEn) ?? DBNull.Value };
                para[3] = new NpgsqlParameter("@p_parentprofitcentercode", NpgsqlDbType.Integer)
                { Value = ((object?)parentProfitCenterCode) ?? DBNull.Value };
                para[4] = new NpgsqlParameter("@p_isactive", NpgsqlDbType.Boolean) { Value = isActive };
                para[5] = new NpgsqlParameter("@p_notes", NpgsqlDbType.Text) { Value = ((object?)notes) ?? DBNull.Value };
                para[6] = new NpgsqlParameter("@p_adduser", NpgsqlDbType.Integer)
                { Value = ((object?)addUser) ?? DBNull.Value };
                var dt = ctx.SelectData("addProfitCenter", para);
                return dt.Rows.Count > 0 ? Convert.ToInt32(dt.Rows[0][0]) : 0;
            });
        }

        public void UpdateProfitCenter(int profitCenterCode, string? profitCenterId, string? nameAr, string? nameEn,
            int? parentProfitCenterCode, bool? isActive,
            string? notes, int? editUser)
        {
            _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[8];
                para[0] = new NpgsqlParameter("@p_profitcentercode", NpgsqlDbType.Integer) { Value = profitCenterCode };
                para[1] = new NpgsqlParameter("@p_profitcenterid", NpgsqlDbType.Varchar)
                { Value = ((object?)profitCenterId) ?? DBNull.Value };
                para[2] = new NpgsqlParameter("@p_namear", NpgsqlDbType.Varchar)
                { Value = ((object?)nameAr) ?? DBNull.Value };
                para[3] = new NpgsqlParameter("@p_nameen", NpgsqlDbType.Varchar)
                { Value = ((object?)nameEn) ?? DBNull.Value };
                para[4] = new NpgsqlParameter("@p_parentprofitcentercode", NpgsqlDbType.Integer)
                { Value = ((object?)parentProfitCenterCode) ?? DBNull.Value };
                para[5] = new NpgsqlParameter("@p_isactive", NpgsqlDbType.Boolean)
                { Value = ((object?)isActive) ?? DBNull.Value };
                para[6] = new NpgsqlParameter("@p_notes", NpgsqlDbType.Text) { Value = ((object?)notes) ?? DBNull.Value };
                para[7] = new NpgsqlParameter("@p_edituser", NpgsqlDbType.Integer)
                { Value = ((object?)editUser) ?? DBNull.Value };
                ctx.Execute("updateProfitCenter", para);
            });
        }

        public void DeleteProfitCenter(int profitCenterCode, int? editUser)
        {
            _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[2];
                para[0] = new NpgsqlParameter("@p_profitcentercode", NpgsqlDbType.Integer) { Value = profitCenterCode };
                para[1] = new NpgsqlParameter("@p_edituser", NpgsqlDbType.Integer)
                { Value = ((object?)editUser) ?? DBNull.Value };
                ctx.Execute("deleteProfitCenter", para);
            });
        }

        public DataTable GetAllProfitCenters() => _ctx.Execute(ctx => ctx.SelectData("getAllProfitCenters", null));

        public DataTable GetProfitCenterData(int profitCenterCode)
        {
            return _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[1];
                para[0] = new NpgsqlParameter("@p_profitcentercode", NpgsqlDbType.Integer) { Value = profitCenterCode };
                return ctx.SelectData("getProfitCenterData", para);
            });
        }

        public DataTable GetProfitCenterTree() => _ctx.Execute(ctx => ctx.SelectData("getProfitCenterTree", null));

        // ============================================================
        //  COST CENTERS (existing tblcostcenters — read-only wrappers)
        // ============================================================
        public DataTable GetCostCenterHierarchy() =>
            _ctx.Execute(ctx => ctx.SelectData("vw_costcenter_hierarchy", null));

        // ============================================================
        //  CROSS-DIMENSION HIERARCHIES
        // ============================================================
        public long AddDimensionHierarchy(string? hierarchyType,
            string? parentDimType, int parentDimCode,
            string? childDimType, int childDimCode,
            DateTime? validFrom, DateTime? validTo,
            bool? isActive, string? notes, int? addUser)
        {
            return _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[10];
                para[0] = new NpgsqlParameter("@p_hierarchytype", NpgsqlDbType.Varchar)
                { Value = ((object?)hierarchyType) ?? DBNull.Value };
                para[1] = new NpgsqlParameter("@p_parentdimtype", NpgsqlDbType.Varchar)
                { Value = ((object?)parentDimType) ?? DBNull.Value };
                para[2] = new NpgsqlParameter("@p_parentdimcode", NpgsqlDbType.Integer) { Value = parentDimCode };
                para[3] = new NpgsqlParameter("@p_childdimtype", NpgsqlDbType.Varchar)
                { Value = ((object?)childDimType) ?? DBNull.Value };
                para[4] = new NpgsqlParameter("@p_childdimcode", NpgsqlDbType.Integer) { Value = childDimCode };
                para[5] = new NpgsqlParameter("@p_validfrom", NpgsqlDbType.Date)
                { Value = ((object?)validFrom) ?? DBNull.Value };
                para[6] = new NpgsqlParameter("@p_validto", NpgsqlDbType.Date)
                { Value = ((object?)validTo) ?? DBNull.Value };
                para[7] = new NpgsqlParameter("@p_isactive", NpgsqlDbType.Boolean)
                { Value = ((object?)isActive) ?? DBNull.Value };
                para[8] = new NpgsqlParameter("@p_notes", NpgsqlDbType.Text) { Value = ((object?)notes) ?? DBNull.Value };
                para[9] = new NpgsqlParameter("@p_adduser", NpgsqlDbType.Integer)
                { Value = ((object?)addUser) ?? DBNull.Value };
                var dt = ctx.SelectData("addDimensionHierarchy", para);
                return dt.Rows.Count > 0 ? Convert.ToInt64(dt.Rows[0][0]) : -1L;
            });
        }

        public void DeleteDimensionHierarchy(long hierarchyId, int? editUser)
        {
            _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[2];
                para[0] = new NpgsqlParameter("@p_hierarchyid", NpgsqlDbType.Bigint) { Value = hierarchyId };
                para[1] = new NpgsqlParameter("@p_edituser", NpgsqlDbType.Integer)
                { Value = ((object?)editUser) ?? DBNull.Value };
                ctx.Execute("deleteDimensionHierarchy", para);
            });
        }

        public DataTable GetAllDimensionHierarchies() =>
            _ctx.Execute(ctx => ctx.SelectData("getAllDimensionHierarchies", null));

        // ============================================================
        //  CROSS-DIMENSION ANALYTICS
        // ============================================================
        public bool ValidateDimension(string? dimType, int? dimCode)
        {
            return _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[2];
                para[0] = new NpgsqlParameter("@p_dimtype", NpgsqlDbType.Varchar)
                { Value = ((object?)dimType) ?? DBNull.Value };
                para[1] = new NpgsqlParameter("@p_dimcode", NpgsqlDbType.Integer)
                { Value = ((object?)dimCode) ?? DBNull.Value };
                var dt = ctx.SelectData("validateDimension", para);
                return dt.Rows.Count > 0 && Convert.ToBoolean(dt.Rows[0][0]);
            });
        }

        public string? ValidateAllDimensions(int? deptCode, int? projCode, int? buCode,
            int? segCode, int? pcCode, int? ccCode)
        {
            return _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[6];
                para[0] = new NpgsqlParameter("@p_departmentcode", NpgsqlDbType.Integer)
                { Value = ((object?)deptCode) ?? DBNull.Value };
                para[1] = new NpgsqlParameter("@p_projectcode", NpgsqlDbType.Integer)
                { Value = ((object?)projCode) ?? DBNull.Value };
                para[2] = new NpgsqlParameter("@p_businessunitcode", NpgsqlDbType.Integer)
                { Value = ((object?)buCode) ?? DBNull.Value };
                para[3] = new NpgsqlParameter("@p_segmentcode", NpgsqlDbType.Integer)
                { Value = ((object?)segCode) ?? DBNull.Value };
                para[4] = new NpgsqlParameter("@p_profitcentercode", NpgsqlDbType.Integer)
                { Value = ((object?)pcCode) ?? DBNull.Value };
                para[5] = new NpgsqlParameter("@p_costcentercode", NpgsqlDbType.Integer)
                { Value = ((object?)ccCode) ?? DBNull.Value };
                var dt = ctx.SelectData("validateAllDimensions", para);
                return dt.Rows.Count > 0 ? Convert.ToString(dt.Rows[0][0]) : null;
            });
        }

        public decimal GetDimensionActual(string? dimType, int? dimCode, int? periodId)
        {
            return _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[3];
                para[0] = new NpgsqlParameter("@p_dimtype", NpgsqlDbType.Varchar)
                { Value = ((object?)dimType) ?? DBNull.Value };
                para[1] = new NpgsqlParameter("@p_dimcode", NpgsqlDbType.Integer)
                { Value = ((object?)dimCode) ?? DBNull.Value };
                para[2] = new NpgsqlParameter("@p_periodid", NpgsqlDbType.Integer)
                { Value = ((object?)periodId) ?? DBNull.Value };
                var dt = ctx.SelectData("getDimensionActual", para);
                return dt.Rows.Count > 0 ? Convert.ToDecimal(dt.Rows[0][0]) : 0m;
            });
        }

        public decimal GetDimensionBudget(string? dimType, int? dimCode, int? periodId)
        {
            return _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[3];
                para[0] = new NpgsqlParameter("@p_dimtype", NpgsqlDbType.Varchar)
                { Value = ((object?)dimType) ?? DBNull.Value };
                para[1] = new NpgsqlParameter("@p_dimcode", NpgsqlDbType.Integer)
                { Value = ((object?)dimCode) ?? DBNull.Value };
                para[2] = new NpgsqlParameter("@p_periodid", NpgsqlDbType.Integer)
                { Value = ((object?)periodId) ?? DBNull.Value };
                var dt = ctx.SelectData("getDimensionBudget", para);
                return dt.Rows.Count > 0 ? Convert.ToDecimal(dt.Rows[0][0]) : 0m;
            });
        }

        public decimal GetDimensionVariance(string? dimType, int? dimCode, int? periodId)
        {
            return _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[3];
                para[0] = new NpgsqlParameter("@p_dimtype", NpgsqlDbType.Varchar)
                { Value = ((object?)dimType) ?? DBNull.Value };
                para[1] = new NpgsqlParameter("@p_dimcode", NpgsqlDbType.Integer)
                { Value = ((object?)dimCode) ?? DBNull.Value };
                para[2] = new NpgsqlParameter("@p_periodid", NpgsqlDbType.Integer)
                { Value = ((object?)periodId) ?? DBNull.Value };
                var dt = ctx.SelectData("getDimensionVariance", para);
                return dt.Rows.Count > 0 ? Convert.ToDecimal(dt.Rows[0][0]) : 0m;
            });
        }

        public string? GetDimensionFullPath(string? dimType, int? dimCode)
        {
            return _ctx.Execute(ctx =>
            {
                var para = new NpgsqlParameter[2];
                para[0] = new NpgsqlParameter("@p_dimtype", NpgsqlDbType.Varchar)
                { Value = ((object?)dimType) ?? DBNull.Value };
                para[1] = new NpgsqlParameter("@p_dimcode", NpgsqlDbType.Integer)
                { Value = ((object?)dimCode) ?? DBNull.Value };
                var dt = ctx.SelectData("getDimensionFullPath", para);
                return dt.Rows.Count > 0 ? Convert.ToString(dt.Rows[0][0]) : null;
            });
        }

        // ============================================================
        //  DIMENSION-AWARE VIEWS (use raw SQL because DbContext.SelectData
        //  auto-dispatches only to PROCEDURE/FUNCTION, not VIEW)
        // ============================================================
        public DataTable GetViewJournalBodyWithDimensions()
        {
            return _ctx.Execute(ctx => ctx.ExecuteRawSql("SELECT * FROM vw_journalbody_with_dimensions"));
        }

        public DataTable GetViewBondWithDimensions()
        {
            return _ctx.Execute(ctx => ctx.ExecuteRawSql("SELECT * FROM vw_bond_with_dimensions"));
        }

        public DataTable GetViewTreasuryWithDimensions()
        {
            return _ctx.Execute(ctx => ctx.ExecuteRawSql("SELECT * FROM vw_treasury_with_dimensions"));
        }

        public DataTable GetViewBudgetVsActualByDimension()
        {
            return _ctx.Execute(ctx => ctx.ExecuteRawSql("SELECT * FROM vw_budgetvsactual_by_dimension"));
        }

        public DataTable GetViewDimensionsSummary()
        {
            return _ctx.Execute(ctx => ctx.ExecuteRawSql("SELECT * FROM vw_dimensions_summary"));
        }

        public DataTable GetViewDimensionUsage()
        {
            return _ctx.Execute(ctx => ctx.ExecuteRawSql("SELECT * FROM vw_dimension_usage"));
        }
    }
}
