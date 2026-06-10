using Microsoft.Reporting.WinForms;
using Microsoft.ReportingServices.Interfaces;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using IntegratedAccSys.PL.Security;

namespace IntegratedAccSys.PL.Bonds
{
    public partial class frmBonds : Form
    {
        BL.SysFormat.ClsSysFormat csf = new BL.SysFormat.ClsSysFormat();
        BL.Bonds.ClsBonds cb = new BL.Bonds.ClsBonds();
        BL.Journal.ClsJournal cj = new BL.Journal.ClsJournal();
        BL.Users.ClsUsers cu = new BL.Users.ClsUsers();
        public frmBonds()
        {
            InitializeComponent();
        }
        void getAllCurrencies()
        {
            cbCurrency.DataSource = csf.getAllCurrencies();
            cbCurrency.ValueMember = "ID";
            cbCurrency.DisplayMember = "currName";
        }

        void getAllFunds()
        {
            cbFunds.DataSource = csf.getAllFunds();
            cbFunds.ValueMember = "fundCode";
            cbFunds.DisplayMember = "fundName";
        }
        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void txtAccNo_KeyDown(object sender, KeyEventArgs e)
        {
            PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
            if (e.KeyCode == Keys.Enter)
            {
                fsa.txtSearch.Text = txtAccNo.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtAccNo.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();
                    txtAccName.Text = fsa.dgvData.CurrentRow.Cells[1].Value.ToString();
                    txtAmount.Focus();
                }
            }

        }

        private void frmBonds_Load(object sender, EventArgs e)
        {
            BL.Users.ClsUsers cu = new BL.Users.ClsUsers();
            if (txtBType.Text == "2")
            {
                PrivilegeApplier.Apply(this, 16);
            }
            if (txtBType.Text == "3")
            {
                PrivilegeApplier.Apply(this, 16);
            }

            getAllCurrencies();
            getAllFunds();
        }

        private void cbCurrency_SelectedIndexChanged(object sender, EventArgs e)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            dt = csf.getExchangeCurrency(cbCurrency.Text);
            if (dt.Rows.Count > 0)
            {
                txtCurrVal.Text = dt.Rows[0][2].ToString();
            }
        }

        private void cbFunds_SelectedIndexChanged(object sender, EventArgs e)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            dt = csf.getAccFundCode(cbFunds.Text);
            if (dt.Rows.Count > 0)
            {
                txtFundCode.Text = dt.Rows[0][0].ToString();
            }

        }

        void resetData()
        {
            txtBondNo.Text = "0";
            dtpBdate.Text = DateTime.Now.ToString();
            txtJno.Text = "0";
            txtNote.Text = string.Empty;
            txtFundCode.Text = "0";
            txtAccNo.Text = string.Empty;
            txtAmount.Text = "0.00";
            txtCurrVal.Text = "0.00";
            txtlocalAmount.Text = "0.00";
            txtUserAdd.Text = string.Empty;
            txtAddDate.Text = string.Empty;
            txtUserEdit.Text = string.Empty;
            txtEditDate.Text = string.Empty;
            dgvData.Rows.Clear();
            getAllCurrencies();
            getAllFunds();
            txtBondTotal.Text = "0.00";
            txtBNo.Text = "0";
        }
        private void btnNew_Click(object sender, EventArgs e)
        {
            resetData();
            txtBondNo.Text = cb.GetNewBondNo(Program.braCode, Convert.ToInt32(txtBType.Text)).Rows[0][0].ToString();
            txtJno.Text = cj.getNewJournalNo(Program.braCode).Rows[0][0].ToString();

            txtNote.Focus();
        }


        void resetInsertRow()
        {
            txtAccNo.Text = string.Empty;
            txtAccName.Text = string.Empty;
            txtAmount.Text = "0.00";
            getAllCurrencies();
            txtlocalAmount.Text = string.Empty;
            txtAccNo.Focus();
        }

        void GetBondTotal()
        {
            double amountTatal = 0;
            for (int i = 0; i < dgvData.Rows.Count; i++)
            {
                amountTatal = amountTatal + Convert.ToDouble(dgvData.Rows[i].Cells[6].Value);
            }
            txtBondTotal.Text = amountTatal.ToString("0.00");
        }
        private void btInsert_Click(object sender, EventArgs e)
        {
            if (txtAccNo.Text == "")
            {
                MessageBox.Show("يجب إختيار الحساب أولا", "تنبية", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (Convert.ToDouble(txtlocalAmount.Text) == 0)
            {
                MessageBox.Show("يجب إدخال المبلغ أولا", "تنبية", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
            dgvData.Rows.Add(txtAccNo.Text, txtAccName.Text, txtAmount.Text, cbCurrency.SelectedValue, cbCurrency.Text, txtCurrVal.Text, txtlocalAmount.Text, txtBondNo.Text);
            GetBondTotal();

            resetInsertRow();
        }

        private void txtAmount_TextChanged(object sender, EventArgs e)
        {
            txtlocalAmount.Text = (Convert.ToDouble(txtAmount.Text) * Convert.ToDouble(txtCurrVal.Text)).ToString();
        }

        private void txtCurrVal_TextChanged(object sender, EventArgs e)
        {
            txtlocalAmount.Text = (Convert.ToDouble(txtAmount.Text) * Convert.ToDouble(txtCurrVal.Text)).ToString();
        }

        private void btnAddRow_Click(object sender, EventArgs e)
        {
            resetInsertRow();
            txtAccNo.Focus();
        }

        private void btnEditRow_Click(object sender, EventArgs e)
        {
            txtAccNo.Text = dgvData.CurrentRow.Cells[0].Value.ToString();
            txtAccName.Text = dgvData.CurrentRow.Cells[1].Value.ToString();
            txtAmount.Text = dgvData.CurrentRow.Cells[2].Value.ToString();
            cbCurrency.SelectedValue = dgvData.CurrentRow.Cells[3].Value;
            cbCurrency.Text = dgvData.CurrentRow.Cells[4].Value.ToString();
            txtCurrVal.Text = dgvData.CurrentRow.Cells[5].Value.ToString();
            txtlocalAmount.Text = dgvData.CurrentRow.Cells[6].Value.ToString();
            dgvData.Rows.RemoveAt(dgvData.CurrentRow.Index);
            GetBondTotal();
        }

        private void btnDelRaw_Click(object sender, EventArgs e)
        {
            dgvData.Rows.RemoveAt(dgvData.CurrentRow.Index);
            GetBondTotal();
        }

        void addBondHeader()
        {
            int bPost = 0;
            if (chkPost.Checked)
            {
                bPost = 1;
            }
            else
            {
                bPost = 0;
            }
            int userCode = Convert.ToInt32(cu.getUserNo(Program.userName).Rows[0][0]);
            DateTime bDate = DateTime.Now;
            cb.addBondHeader(Convert.ToInt32(txtBondNo.Text), Convert.ToDateTime(dtpBdate.Value.ToShortDateString()), txtNote.Text, Convert.ToInt32(txtBType.Text), bPost, Convert.ToInt32(txtFundCode.Text), 0, Convert.ToDouble(txtBondTotal.Text), userCode, bDate, Program.braCode, Convert.ToInt32(txtJno.Text));
        }

        void addBondBody()
        {
            for (int i = 0; i < dgvData.Rows.Count; i++)
            {
                int accCode = Convert.ToInt32(dgvData.Rows[i].Cells[0].Value);
                int currID = Convert.ToInt32(dgvData.Rows[i].Cells[3].Value);
                double amount = Convert.ToDouble(dgvData.Rows[i].Cells[2].Value);
                int bondNo = Convert.ToInt32(dgvData.Rows[i].Cells[7].Value);
                double currVal = Convert.ToDouble(dgvData.Rows[i].Cells[5].Value);
                cb.addBondBody(accCode, currID, amount, bondNo, currVal);
            }
        }

        void addjournalHeader()
        {
            int jType = 1;
            int jPost = 0;

            int userCode = Convert.ToInt32(cu.getUserNo(Program.userName).Rows[0][0]);
            DateTime jDate = DateTime.Now;
            cj.addJournalHeader(Convert.ToInt32(txtJno.Text), Convert.ToDateTime(dtpBdate.Value.ToShortDateString()), txtNote.Text, jType, jPost, Convert.ToDouble(txtBondTotal.Text), Convert.ToDouble(txtBondTotal.Text), 0, userCode, jDate, Program.braCode, Convert.ToInt32(txtBType.Text));

        }

        void addJournalBody()
        {

            if (txtBType.Text == "2")
            {
                for (int i = 0; i < dgvData.Rows.Count; i++)
                {
                    int accCode = Convert.ToInt32(dgvData.Rows[i].Cells[0].Value);
                    int currID = Convert.ToInt32(dgvData.Rows[i].Cells[3].Value);
                    double currVal = Convert.ToDouble(dgvData.Rows[i].Cells[5].Value);
                    double accDebitor = Convert.ToDouble(txtBondTotal.Text);
                    double accCreditor = 0;
                    string Note = txtNote.Text;
                    int jNo = Convert.ToInt32(txtJno.Text);
                    cj.addJournalBody(accCode, currID, currVal, accDebitor, accCreditor, Note, jNo);
                }
                cj.addJournalBody(Convert.ToInt32(txtFundCode.Text), Convert.ToInt32(cbCurrency.SelectedValue), Convert.ToDouble(txtCurrVal.Text), 0, Convert.ToDouble(txtBondTotal.Text), txtNote.Text, Convert.ToInt32(txtJno.Text));
            }
            else
            {

                cj.addJournalBody(Convert.ToInt32(txtFundCode.Text), Convert.ToInt32(cbCurrency.SelectedValue), Convert.ToDouble(txtCurrVal.Text), Convert.ToDouble(txtBondTotal.Text), 0, txtNote.Text, Convert.ToInt32(txtJno.Text));

                for (int i = 0; i < dgvData.Rows.Count; i++)
                {
                    int accCode = Convert.ToInt32(dgvData.Rows[i].Cells[0].Value);
                    int currID = Convert.ToInt32(dgvData.Rows[i].Cells[3].Value);
                    double currVal = Convert.ToDouble(dgvData.Rows[i].Cells[5].Value);
                    double accDebitor = 0;
                    double accCreditor = Convert.ToDouble(txtBondTotal.Text);
                    string Note = txtNote.Text;
                    int jNo = Convert.ToInt32(txtJno.Text);
                    cj.addJournalBody(accCode, currID, currVal, accDebitor, accCreditor, Note, jNo);
                }
            }
        }
        private void btnAdd_Click(object sender, EventArgs e)
        {
            try
            {
                addBondHeader();
                addBondBody();
                addjournalHeader();
                addJournalBody();
                MessageBox.Show("تمت عملية الحفظ بنجاح", "حفظ", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show("حدث خطأ" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void btnSearch_Click(object sender, EventArgs e)
        {
            txtBNo.Text = txtSearch.Text;
        }
        void showBondHeader()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            dt = cb.showBondHeader(Convert.ToInt32(txtBNo.Text));
            if (dt.Rows.Count > 0)
            {
                txtBondNo.Text = dt.Rows[0][0].ToString();
                dtpBdate.Text = dt.Rows[0][1].ToString();
                txtNote.Text = dt.Rows[0][2].ToString();
                txtBType.Text = dt.Rows[0][3].ToString();
                if (Convert.ToInt32(dt.Rows[0][4]) == 1)
                {
                    chkPost.Checked = true;
                }
                else
                {
                    chkPost.Checked = false;
                }
                txtFundCode.Text = dt.Rows[0][5].ToString();
                txtBondTotal.Text = dt.Rows[0][7].ToString();
                txtUserAdd.Text = dt.Rows[0][8].ToString();
                txtAddDate.Text = dt.Rows[0][9].ToString();
                txtUserEdit.Text = dt.Rows[0][10].ToString();
                txtEditDate.Text = dt.Rows[0][11].ToString();
                txtJno.Text = dt.Rows[0][13].ToString();

            }
        }

        void showBondBody()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            dt = cb.showBondBody(Convert.ToInt32(txtBNo.Text));
            if (dt.Rows.Count > 0)
            {
                dgvData.Rows.Clear();
                int i = 0;
                dgvData.RowCount = dt.Rows.Count;
                for (int j = 0; j < dt.Rows.Count; j++)
                {
                    dgvData.Rows[i].Cells[0].Value = dt.Rows[j][1];
                    dgvData.Rows[i].Cells[1].Value = dt.Rows[j][2];
                    dgvData.Rows[i].Cells[2].Value = dt.Rows[j][5];
                    dgvData.Rows[i].Cells[3].Value = dt.Rows[j][3];
                    dgvData.Rows[i].Cells[4].Value = dt.Rows[j][4];
                    dgvData.Rows[i].Cells[5].Value = dt.Rows[j][7];
                    dgvData.Rows[i].Cells[6].Value = Convert.ToDouble(dt.Rows[j][5]) * Convert.ToDouble(dt.Rows[j][7]);
                    dgvData.Rows[i].Cells[7].Value = dt.Rows[j][6];
                    i++;
                }
            }
        }
        private void txtBNo_TextChanged(object sender, EventArgs e)
        {
            try
            {
                showBondHeader();
                showBondBody();
            }
            catch (Exception ex)
            {
                MessageBox.Show("خطأ" + ex.Message, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnLast_Click(object sender, EventArgs e)
        {
            txtBNo.Text = cb.getMaxBondNo(Convert.ToInt32(txtBType.Text)).Rows[0][0].ToString();
        }

        private void btnFirst_Click(object sender, EventArgs e)
        {
            txtBNo.Text = cb.getMinBondNo(Convert.ToInt32(txtBType.Text)).Rows[0][0].ToString();
        }

        private void btnPerv_Click(object sender, EventArgs e)
        {
            int MinNo = Convert.ToInt32(cb.getMinBondNo(Convert.ToInt32(txtBType.Text)).Rows[0][0]);
            if (Convert.ToInt32(txtBNo.Text) == MinNo)
            {
                MessageBox.Show("هذا هو اول سجل", "معلومة", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }
            else
            {
                txtBNo.Text = (Convert.ToInt32(txtBNo.Text) - 1).ToString();
            }
        }

        private void btnNext_Click(object sender, EventArgs e)
        {
            int MaxNo = Convert.ToInt32(cb.getMaxBondNo(Convert.ToInt32(txtBType.Text)).Rows[0][0]);
            if (Convert.ToInt32(txtBNo.Text) == MaxNo)
            {
                MessageBox.Show("هذا هو أخر سجل", "معلومة", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }
            else
            {
                txtBNo.Text = (Convert.ToInt32(txtBNo.Text) + 1).ToString();
            }
        }

        void editBondHeader()
        {
            int bPost = 0;
            if (chkPost.Checked)
            {
                bPost = 1;
            }
            else
            {
                bPost = 0;
            }

            int userCode = Convert.ToInt32(cu.getUserNo(Program.userName).Rows[0][0]);
            DateTime bDate = DateTime.Now;
            cb.editBondHeader(Convert.ToInt32(txtBondNo.Text), Convert.ToDateTime(dtpBdate.Value.ToShortDateString()), txtNote.Text, Convert.ToInt32(txtBType.Text), bPost, Convert.ToInt32(txtFundCode.Text), 0, Convert.ToDouble(txtBondTotal.Text), userCode, bDate, Program.braCode, Convert.ToInt32(txtJno.Text));
        }

        void delBondBody()
        {
            cb.delBondBody(Convert.ToInt32(txtBondNo.Text));
        }
        private void btnEdit_Click(object sender, EventArgs e)
        {
            editBondHeader();
            delBondBody();
            addBondBody();
            cj.delJournalEntry(Convert.ToInt32(txtJno.Text), Program.braCode);
            addjournalHeader();
            addJournalBody();

            MessageBox.Show("تمت عملية التعديل بنجاح", "تعديل", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private void btnDel_Click(object sender, EventArgs e)
        {

            if (MessageBox.Show("هل تريد حذف هذا السجل", "تنبيه", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes)
            {
                cj.delJournalEntry(Convert.ToInt32(txtJno.Text), Program.braCode);
                cb.delBond(Convert.ToInt32(txtBondNo.Text));
                MessageBox.Show("تمت عملية الحذف بنجاح", "حذف", MessageBoxButtons.OK, MessageBoxIcon.Information);
                resetData();
            }
        }

        private void btnPrint_Click(object sender, EventArgs e)
        {
            List<ReportDataSource> dataSource = new List<ReportDataSource>
            {
                new ReportDataSource("dsBranchData",csf.getBranchData(Program.braCode)),
                new ReportDataSource("dsBondHeader",cb.showBondHeader(Convert.ToInt32(txtBondNo.Text))),
                new ReportDataSource("dsBondBody",cb.showBondBody(Convert.ToInt32(txtBondNo.Text))),
            };
            string reportTitle = "";
            if (Convert.ToInt32(txtBType.Text) == 2)
            {
                reportTitle = "سند صرف";
            }
            if (Convert.ToInt32(txtBType.Text) == 3)
            {
                reportTitle = "سند قبض";
            }
            IntegratedAccSys.Reports.frmReportViewer frv = new IntegratedAccSys.Reports.frmReportViewer("rptBonds.rdlc", dataSource, reportTitle);
            frv.ShowDialog();
        }
    }
}
