using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using IntegratedAccSys.BL.Security;
using IntegratedAccSys.PL.Security;
using Microsoft.Reporting.WinForms;



namespace IntegratedAccSys.PL.Stores

{

    public partial class frmInvventroy : Form

    {

        BL.Stores.ClsInventory ci = new BL.Stores.ClsInventory();

        BL.SysFormat.ClsSysFormat csf = new BL.SysFormat.ClsSysFormat();



        // Phase 6: windowID for Products Inventory Report

        private const int WINDOW_ID = 29;



        public frmInvventroy()

        {

            InitializeComponent();

        }



        void dgvProperties()

        {

            // تنسيق رؤوس الأعمدة

            dgvData.ColumnHeadersDefaultCellStyle.ForeColor = Color.Black;

            dgvData.ColumnHeadersDefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter;

            dgvData.ColumnHeadersDefaultCellStyle.Font = new Font("Times New Roman", 10.75F, FontStyle.Bold);



            // تنسيق الصفوف المتبادلة

            dgvData.AlternatingRowsDefaultCellStyle.ForeColor = Color.Red;

            dgvData.AlternatingRowsDefaultCellStyle.BackColor = Color.SkyBlue;

            dgvData.AlternatingRowsDefaultCellStyle.Font = new Font("Times New Roman", 10.75F, FontStyle.Bold);

            dgvData.AlternatingRowsDefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter;

            // تنسيق خلايا البيانات

            dgvData.DefaultCellStyle.BackColor = Color.White;

            dgvData.DefaultCellStyle.ForeColor = Color.Blue;

            dgvData.DefaultCellStyle.Font = new Font("Times New Roman", 10.75F, FontStyle.Bold);

            dgvData.DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter;

        }



        private void frmInvventroy_Load(object sender, EventArgs e)

        {

            // Phase 6: Block form open if no display privilege

            if (!PrivilegeHelper.HasDisplayPrivilege(Program.userName, Program.braCode, WINDOW_ID))

            {

                MessageBox.Show("ليس لديك صلاحية عرض هذا التقرير.", "تعديل", MessageBoxButtons.OK, MessageBoxIcon.Stop);

                this.BeginInvoke(new Action(Close));

                return;

            }



            dgvProperties();

        }



        private void btnExit_Click(object sender, EventArgs e)

        {

            Close();

        }



        private void btnDisplay_Click(object sender, EventArgs e)

        {

            DataTable dt = new DataTable();

            dt.Clear();

            dt = ci.getProductsInventory(Program.braCode);

            if (dt.Rows.Count > 0)

            {

                dgvData.DataSource = dt;

                dgvData.Columns[0].HeaderText = "رقم الصنف";

                dgvData.Columns[1].HeaderText = "إسم الصنف";

                dgvData.Columns[2].Visible = false;

                dgvData.Columns[3].HeaderText = "إسم المخزن";

                dgvData.Columns[4].Visible = false;

                dgvData.Columns[5].HeaderText = "إسم المجموعة";

                dgvData.Columns[6].Visible = false;

                dgvData.Columns[7].HeaderText = "الوحدة";

                dgvData.Columns[8].HeaderText = "الكمية";

            }

            else

            {

                MessageBox.Show("لا توجد بيانات لعرضها");

            }

        }



        private void btnPrint_Click(object sender, EventArgs e)

        {

            // Phase 6: Block if no print privilege

            if (!PrivilegeHelper.HasPrintPrivilege(Program.userName, Program.braCode, WINDOW_ID))

            {

                AuditHelper.LogBlockedReportAccess(WINDOW_ID, "frmInvventroy");

                MessageBox.Show("ليس لديك صلاحية طباعة هذا التقرير.", "تعديل", MessageBoxButtons.OK, MessageBoxIcon.Stop);

                return;

            }



            List<ReportDataSource> dataSource = new List<ReportDataSource>

            {

                new ReportDataSource("dsBranchData", csf.getBranchData(Program.braCode)),

                new ReportDataSource("dsProductsInventory", ci.getProductsInventory(Program.braCode))

            };

            string reportTitle = "جرد المخزون";

            IntegratedAccSys.Reports.frmReportViewer frv = new IntegratedAccSys.Reports.frmReportViewer("rptProductsInventory.rdlc", dataSource, reportTitle);

            frv.ShowDialog();

        }

    }

}
