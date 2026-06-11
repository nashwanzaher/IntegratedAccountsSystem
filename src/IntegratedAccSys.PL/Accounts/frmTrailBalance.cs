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

namespace IntegratedAccSys.PL.Accounts
{
    public partial class frmTrailBalance : Form
    {
        BL.Accounts.ClsAccounts ca = new BL.Accounts.ClsAccounts();
        BL.SysFormat.ClsSysFormat csf = new BL.SysFormat.ClsSysFormat();

        // Phase 6: windowID for Trail Balance Report
        private const int WINDOW_ID = 34;

        public frmTrailBalance()
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

        void getAllCurencies()
        {
            cbCurrencies.DataSource = csf.getAllCurrencies();
            cbCurrencies.DisplayMember = "currName";
            cbCurrencies.ValueMember = "ID";
        }

        private void frmTrailBalance_Load(object sender, EventArgs e)
        {
            // Phase 6: Block form open if no display privilege
            if (!PrivilegeHelper.HasDisplayPrivilege(Program.userName, Program.braCode, WINDOW_ID))
            {
                MessageBox.Show("ليس لديك صلاحية عرض هذا التقرير.", "تعديل", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                this.BeginInvoke(new Action(Close));
                return;
            }

            getAllCurencies();
            dtpFromDate.Value = DateTime.Now;
            dtpToDate.Value = DateTime.Now;
        }

        private void cbCurrencies_SelectedIndexChanged(object sender, EventArgs e)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            dt = csf.getExchangeCurrency(cbCurrencies.Text);
            if (dt.Rows.Count > 0)
            {
                txtCurrVal.Text = dt.Rows[0][2].ToString();
            }
        }

        private void btnDisplay_Click(object sender, EventArgs e)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DateTime fromDate = dtpFromDate.Value.Date;
            DateTime toDate = dtpToDate.Value.Date;
            decimal exchangeRate = Convert.ToDecimal(txtCurrVal.Text);
            int braCode = Program.braCode;
            dt = ca.getTraiBalance(fromDate, toDate, exchangeRate, braCode);
            if (dt.Rows.Count > 0)
            {
                dgvData.DataSource = dt;
            }

            var (totalDebitor, totalCreditor) = ca.calculateTotals(dt);
            txtDebitor.Text = totalDebitor.ToString();
            txtCreditor.Text = totalCreditor.ToString();
            double accBalance = Convert.ToDouble(totalDebitor - totalCreditor);
            txtBalance.Text = accBalance.ToString();

            dgvData.Columns[0].HeaderText = "رقم الحساب";
            dgvData.Columns[1].HeaderText = "إسم الحساب";
            dgvData.Columns[2].HeaderText = "رصيد مدين";
            dgvData.Columns[3].HeaderText = "رصيد ائن";
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
                AuditHelper.LogBlockedReportAccess(WINDOW_ID, "frmTrailBalance");
                MessageBox.Show("ليس لديك صلاحية طباعة هذا التقرير.", "تعديل", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                return;
            }

            DateTime fromDate = dtpFromDate.Value.Date;
            DateTime toDate = dtpToDate.Value.Date;
            decimal exchangeRate = Convert.ToDecimal(txtCurrVal.Text);
            int braCode = Program.braCode;
            List<ReportDataSource> dataSource = new List<ReportDataSource>
            {
                new ReportDataSource("dsBranchData", csf.getBranchData(Program.braCode)),
                new ReportDataSource("dsTrailBalance", ca.getTraiBalance(fromDate, toDate, exchangeRate, braCode))
            };
            string reportTitle = "ميزان المراجعة";
            IntegratedAccSys.Reports.frmReportViewer frv = new IntegratedAccSys.Reports.frmReportViewer("rptTrailBalance.rdlc", dataSource, reportTitle);
            frv.ShowDialog();
        }
    }
}
