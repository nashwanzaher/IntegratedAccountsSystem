using Microsoft.Reporting.WinForms;

using System;

using System.Collections.Generic;

using System.ComponentModel;

using System.Data;

using System.Drawing;

using System.Linq;

using System.Runtime.InteropServices.JavaScript;

using System.Text;

using System.Threading.Tasks;

using System.Windows.Forms;

using static System.Runtime.InteropServices.JavaScript.JSType;

using IntegratedAccSys.BL.Security;

using IntegratedAccSys.PL.Security;



namespace IntegratedAccSys.PL.Accounts

{

    public partial class frmAccSheetReport : Form

    {

        BL.SysFormat.ClsSysFormat csf = new BL.SysFormat.ClsSysFormat();

        BL.Accounts.ClsAccounts ca = new BL.Accounts.ClsAccounts();



        // Phase 6: windowID for Account Sheet Report

        private const int WINDOW_ID = 31;



        public frmAccSheetReport()

        {

            InitializeComponent();

            dgvProperties();

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



        private void btnExit_Click(object sender, EventArgs e)

        {

            this.Close();

        }



        private void btnPrint_Click(object sender, EventArgs e)

        {

            // Phase 6: Block if no print privilege

            if (!PrivilegeHelper.HasPrintPrivilege(Program.userName, Program.braCode, WINDOW_ID))

            {

                AuditHelper.LogBlockedReportAccess(WINDOW_ID, "frmAccSheetReport");

                MessageBox.Show("ليس لديك صلاحية طباعة هذا التقرير.", "تعديل", MessageBoxButtons.OK, MessageBoxIcon.Stop);

                return;

            }



            DateTime fromDate = dtpFromDate.Value.Date;

            DateTime toDate = dtpToDate.Value.Date;

            decimal exchangeRate = Convert.ToDecimal(txtCurrVal.Text);

            string opType = Properties.Settings.Default.opTypeSelection;

            List<ReportDataSource> dataSource = new List<ReportDataSource>

            {

                new ReportDataSource("dsBranchData",csf.getBranchData(Program.braCode)),

                new ReportDataSource("dsAccountSheet",ca.getAccountSheetReport(Convert.ToInt32(txtAccCode.Text), fromDate, toDate, exchangeRate, opType))

            };

            string reportTitle = "كشف حساب";

            IntegratedAccSys.Reports.frmReportViewer frv = new IntegratedAccSys.Reports.frmReportViewer("rptAccountSheet.rdlc", dataSource, reportTitle);

            frv.ShowDialog();

            Properties.Settings.Default.opTypeSelection = "";

            Properties.Settings.Default.Save();

        }



        private void frmAccSheetReport_Load(object sender, EventArgs e)

        {

            // Phase 6: Block form open if no display privilege

            if (!PrivilegeHelper.HasDisplayPrivilege(Program.userName, Program.braCode, WINDOW_ID))

            {

                MessageBox.Show("ليس لديك صلاحية عرض هذا التقرير.", "تعديل", MessageBoxButtons.OK, MessageBoxIcon.Stop);

                this.BeginInvoke(new Action(Close));

                return;

            }



            dgvData.Columns[0].HeaderText = "التاريخ";

            dgvData.Columns[1].HeaderText = "رقم الحساب";

            dgvData.Columns[2].HeaderText = "إسم الحساب";

            dgvData.Columns[3].HeaderText = "مدين";

            dgvData.Columns[4].HeaderText = "دائن";

            dgvData.Columns[5].HeaderText = "البيان";

            dgvData.Columns[6].HeaderText = "العملية";

        }

    }

}
