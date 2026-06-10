using Microsoft.Reporting.WinForms;

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



namespace IntegratedAccSys.PL.Stores

{

    public partial class frmInventoryMovement : Form

    {

        BL.Stores.ClsInventory ci = new BL.Stores.ClsInventory();

        BL.SysFormat.ClsSysFormat csf = new BL.SysFormat.ClsSysFormat();



        // Phase 6: windowID for Inventory Movement Report

        private const int WINDOW_ID = 30;



        public frmInventoryMovement()

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



        private void frmInventoryMovement_Load(object sender, EventArgs e)

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

            this.Close();

        }



        private void btnDisplay_Click(object sender, EventArgs e)

        {

            DataTable dt = new DataTable();

            dt.Clear();

            dt = ci.getInventoryMovement(Convert.ToDateTime(dtpFromDate.Value), Convert.ToDateTime(dtpToDate.Value), Program.braCode);

            if (dt.Rows.Count > 0)

            {

                dgvData.DataSource = dt;

                dgvData.Columns[0].HeaderText = "رقم الصنف";

                dgvData.Columns[1].HeaderText = "إسم الصنف";

                dgvData.Columns[2].HeaderText = "الكمية الواردة";

                dgvData.Columns[3].HeaderText = "الكمية المنصرفة";

                dgvData.Columns[4].HeaderText = "السعر";

                dgvData.Columns[5].Visible = false;

                dgvData.Columns[6].HeaderText = "الوحدة";

                dgvData.Columns[7].Visible = false;

                dgvData.Columns[8].HeaderText = "المخزن";

                dgvData.Columns[9].Visible = false;

                dgvData.Columns[10].HeaderText = "المجموعة";

                dgvData.Columns[11].HeaderText = "التاريخ";

                dgvData.Columns[12].HeaderText = "رقم السند/الفاتورة";

                dgvData.Columns[13].Visible = false;

                dgvData.Columns[14].Visible = false;

                dgvData.Columns[15].HeaderText = "العملية";

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

                AuditHelper.LogBlockedReportAccess(WINDOW_ID, "frmInventoryMovement");

                MessageBox.Show("ليس لديك صلاحية طباعة هذا التقرير.", "تعديل", MessageBoxButtons.OK, MessageBoxIcon.Stop);

                return;

            }



            List<ReportDataSource> dataSource = new List<ReportDataSource>

            {

                new ReportDataSource("dsBranchData", csf.getBranchData(Program.braCode)),

                new ReportDataSource("dsInventoryMovement", ci.getInventoryMovement(Convert.ToDateTime(dtpFromDate.Value), Convert.ToDateTime(dtpToDate.Value), Program.braCode)),

            };

            string reportTitle = "حركة المخزون";

            IntegratedAccSys.Reports.frmReportViewer frv = new IntegratedAccSys.Reports.frmReportViewer("rptInventoryMovement.rdlc", dataSource, reportTitle);

            frv.ShowDialog();

        }

    }

}
