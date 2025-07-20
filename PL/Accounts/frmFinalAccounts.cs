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
using static System.Runtime.CompilerServices.RuntimeHelpers;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace IntegratedAccSys.PL.Accounts
{
    public partial class frmFinalAccounts : Form
    {
        BL.SysFormat.clsSysFormat csf = new BL.SysFormat.clsSysFormat();
        BL.Accounts.clsAccounts ca = new BL.Accounts.clsAccounts();
        public frmFinalAccounts()
        {
            InitializeComponent();
            dgvProperties();
            getAllCurencies();
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
        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void btnDisplay_Click(object sender, EventArgs e)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            DateTime fromDate = dtpFromDate.Value.Date;
            DateTime toDate = dtpToDate.Value.Date;
            decimal exchangeRate = Convert.ToDecimal(txtCurrVal.Text);
            int reportType = Convert.ToInt32(txtReportType.Text);
            int braCode = Program.braCode;
            dt = ca.getFinalAccountReport(fromDate, toDate, exchangeRate, braCode, reportType);
            if (dt.Rows.Count > 0)
            {
                dgvData.DataSource = dt;
            }
            var (tDebitor, tCreditor) = ca.calculateTotals(dt);
            txtDebitor.Text = tDebitor.ToString();
            txtCreditor.Text = tCreditor.ToString();
            decimal balance = Convert.ToDecimal(tDebitor - tCreditor);
            txtBalance.Text = balance.ToString();

            dgvData.Columns[0].HeaderText = "رقم الحساب";
            dgvData.Columns[1].HeaderText = "إسم الحساب";
            dgvData.Columns[2].HeaderText = "مدين";
            dgvData.Columns[3].HeaderText = "دائن";
            dgvData.Columns[4].HeaderText = "الرصيد";

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

        private void btnPrint_Click(object sender, EventArgs e)
        {
           
            DateTime fromDate =dtpFromDate.Value.Date;
            DateTime toDate = dtpToDate.Value.Date;
            decimal exchangeRate = Convert.ToDecimal(txtCurrVal.Text);
            int reportType = Convert.ToInt32(txtReportType.Text);
            int braCode = Program.braCode;
            List<ReportDataSource> dataSource = new List<ReportDataSource>
            {
                new ReportDataSource("dsBranchData",csf.getBranchData(Program.braCode)),
                new ReportDataSource("dsFinalAccount",ca.getFinalAccountReport(fromDate, toDate, exchangeRate, braCode, reportType))
            };
            string reportTitle = reportType switch
            {
                1 => $"الميزانية العمومية من تاريخ {fromDate:yyyy/MM/dd} إلى تاريخ {toDate:yyyy/MM/dd}",
                2 => $"قائمة الأرباح و الخسائر من تاريخ {fromDate:yyyy/MM/dd} إلى تاريخ {toDate:yyyy/MM/dd}",
                _ => "تقرير مالي"
            };


            IntegratedAccSys.Reports.frmReportViewer frv=new IntegratedAccSys.Reports.frmReportViewer("rptFinalAccounts.rdlc", dataSource, reportTitle);
            frv.ShowDialog();
        }
    }
}
