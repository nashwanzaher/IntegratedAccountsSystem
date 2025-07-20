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

namespace IntegratedAccSys.PL.Accounts
{
    public partial class frmChartOfAccountsDoc : Form
    {
        BL.Accounts.clsAccounts ca = new BL.Accounts.clsAccounts();
        BL.SysFormat.clsSysFormat csf = new BL.SysFormat.clsSysFormat();
        
        public frmChartOfAccountsDoc()
        {
            InitializeComponent();
            dispalyData();

        }


        void dispalyData()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            dt = ca.displayChartofAccounts(Program.braCode);
            if (dt.Rows.Count > 0)
            {
                dgvData.DataSource = dt;
                dgvData.Columns[0].Visible = true;
                dgvData.Columns[1].Visible = true;
                dgvData.Columns[2].Visible = true;
                dgvData.Columns[3].Visible = true;
                dgvData.Columns[4].Visible = false;
                dgvData.Columns[5].Visible = true;
                dgvData.Columns[6].Visible = false;
                dgvData.Columns[7].Visible = true;
                dgvData.Columns[8].Visible = true;
                dgvData.Columns[9].Visible = true;
                dgvData.Columns[10].Visible = true;
                dgvData.Columns[11].Visible = true;
                dgvData.Columns[12].Visible = false;

                dgvData.Columns[0].HeaderText = "رقم الحساب";
                dgvData.Columns[1].HeaderText = "الحساب الأب";
                dgvData.Columns[2].HeaderText = "الحساب";
                dgvData.Columns[3].HeaderText = "المستوى ";
                dgvData.Columns[5].HeaderText = "نوع الحساب";
                dgvData.Columns[7].HeaderText = "نوع التقرير";
                dgvData.Columns[8].HeaderText = "رصيد مدين";
                dgvData.Columns[9].HeaderText = "رصيد دائن";
                dgvData.Columns[10].HeaderText = "الرصيد";
                dgvData.Columns[11].HeaderText = "مغلق؟";

                dgvData.Columns[2].Width = 300;
                dgvData.Columns[7].Width = 200;


            }
            else
            {
                MessageBox.Show("لا توجد بيانات لعرضها", "تنبية", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }

        }
        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void btnPrint_Click(object sender, EventArgs e)
        {
            List<ReportDataSource> dataSource = new List<ReportDataSource>
            {
                new ReportDataSource("dsBraData",csf.getBranchData(Program.braCode)),
                new ReportDataSource("dsChartOfAccounts",ca.getAllAccounts(Program.braCode)),
            };
            string reportTitle = "الدليل المحاسبي";
            IntegratedAccSys.Reports.frmReportViewer frv = new IntegratedAccSys.Reports.frmReportViewer("rptChartOfAccounts.rdlc", dataSource, reportTitle);
            frv.ShowDialog();

        }
    }
}
