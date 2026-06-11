using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Windows.Forms;
using IntegratedAccSys.PL.Security;
using Microsoft.Reporting.WinForms;

namespace IntegratedAccSys.PL.Journal
{
    public partial class frmJournal : Form
    {
        BL.SysFormat.ClsSysFormat csf = new BL.SysFormat.ClsSysFormat();
        BL.Journal.ClsJournal cj = new BL.Journal.ClsJournal();
        BL.Users.ClsUsers cu = new BL.Users.ClsUsers();
        public int jNo;
        public int opType = 1;
        public frmJournal()
        {
            InitializeComponent();
            getAllCurrencies();
        }

        void getAllCurrencies()
        {
            cbCurrency.DataSource = csf.getAllCurrencies();
            cbCurrency.ValueMember = "ID";
            cbCurrency.DisplayMember = "currName";
        }

        private void txtDebitor_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsDigit(e.KeyChar) && e.KeyChar != (char)Keys.Back && e.KeyChar != '.')
            {
                e.Handled = true;
            }
            if (e.KeyChar == '.' && (sender as TextBox)?.Text?.Contains(".") == true)
            {
                e.Handled = true;
            }
        }

        private void txtCreditor_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsDigit(e.KeyChar) && e.KeyChar != (char)Keys.Back && e.KeyChar != '.')
            {
                e.Handled = true;
            }
            if (e.KeyChar == '.' && (sender as TextBox)?.Text?.Contains(".") == true)
            {
                e.Handled = true;
            }
        }

        private void txtCurrVal_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsDigit(e.KeyChar) && e.KeyChar != (char)Keys.Back && e.KeyChar != '.')
            {
                e.Handled = true;
            }
            if (e.KeyChar == '.' && (sender as TextBox)?.Text?.Contains(".") == true)
            {
                e.Handled = true;
            }
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
                    txtDebitor.Focus();
                }
            }
        }

        void resetData()
        {
            txtAccNo.Text = string.Empty;
            txtAccName.Text = string.Empty;
            txtDebitor.Text = "0.00";
            txtCreditor.Text = "0.00";
            getAllCurrencies();
            txtCurrVal.Text = "0.00";
            txtNote.Text = string.Empty;
        }

        void insertRow()
        {
            double debitTotal = 0.00;
            double creditTotal = 0.00;
            debitTotal = Convert.ToDouble(txtDebitor.Text) * Convert.ToDouble(txtCurrVal.Text);
            creditTotal = Convert.ToDouble(txtCreditor.Text) * Convert.ToDouble(txtCurrVal.Text);
            dgvData.Rows.Add(txtAccNo.Text, txtAccName.Text, txtDebitor.Text, txtCreditor.Text, cbCurrency.SelectedValue, cbCurrency.Text, txtCurrVal.Text, txtNote.Text, debitTotal, creditTotal, txtJNo.Text);
            resetData();
            txtAccNo.Focus();
        }

        void getTotal()
        {
            double debTotal = 0;
            double credTotal = 0;
            for (int i = 0; i < dgvData.Rows.Count; i++)
            {
                debTotal = debTotal + Convert.ToDouble(dgvData.Rows[i].Cells[8].Value);
                credTotal = credTotal + Convert.ToDouble(dgvData.Rows[i].Cells[9].Value);
            }
            txtDebitTotal.Text = debTotal.ToString("0.00");
            txtCreditTotal.Text = credTotal.ToString("0.00");
            txtBalance.Text = (debTotal - credTotal).ToString("0.00");
        }
        private void btnInsert_Click(object sender, EventArgs e)
        {
            if (txtAccNo.Text == "")
            {
                MessageBox.Show("يجتب إختيار الحساب المطلوب أولا", "تنبية", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }
            if (Convert.ToDouble(txtDebitor.Text) == 0.00 && Convert.ToDouble(txtCreditor.Text) == 0.00)
            {
                MessageBox.Show("يجب إدخال  المبلغ الخاص بطرف القيد المحاسبي", "تنبية", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }

            if (Convert.ToDouble(txtDebitor.Text) > 0.00 && Convert.ToDouble(txtCreditor.Text) > 0.00)
            {
                MessageBox.Show("لا يمكن إدخال مبلغ  دائن و مبلغ مبلغ مدين في نفس الوقت", "تنبية", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }

            if (txtCurrVal.Text == "0.00")
            {
                MessageBox.Show("يجب إختار عملة  أولا", "تنبية", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }

            Boolean accountExist = false;
            if (dgvData.RowCount > 0)
            {
                foreach (DataGridViewRow row in dgvData.Rows)
                {
                    if (row.Cells[0].Value != null && row.Cells[0].Value.ToString() == txtAccNo.Text)
                    {
                        MessageBox.Show("الحساب موجود مسبقا", "تنبية", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        accountExist = true;
                        break;
                    }

                }
                if (!accountExist)
                {
                    insertRow();
                }
                return;
            }
            insertRow();

        }

        private void dgvData_RowsAdded(object sender, DataGridViewRowsAddedEventArgs e)
        {
            getTotal();
        }

        private void addrow_Click(object sender, EventArgs e)
        {
            resetData();
            txtAccNo.Focus();
        }

        private void editRow_Click(object sender, EventArgs e)
        {
            txtAccNo.Text = dgvData.CurrentRow.Cells[0].Value.ToString();
            txtAccName.Text = dgvData.CurrentRow.Cells[1].Value.ToString();
            txtDebitor.Text = dgvData.CurrentRow.Cells[2].Value.ToString();
            txtCreditor.Text = dgvData.CurrentRow.Cells[3].Value.ToString();
            cbCurrency.SelectedValue = dgvData.CurrentRow.Cells[4].Value;
            txtCurrVal.Text = dgvData.CurrentRow.Cells[6].Value.ToString();
            txtNote.Text = dgvData.CurrentRow.Cells[7].Value.ToString();
            dgvData.Rows.RemoveAt(dgvData.CurrentRow.Index);
            getTotal();
        }

        private void removeRow_Click(object sender, EventArgs e)
        {
            dgvData.Rows.RemoveAt(dgvData.CurrentRow.Index);
            getTotal();
        }

        void clearData()
        {
            dtpJdate.Value = DateTime.Now;
            txtOPtype.Text = string.Empty;
            txtJoNo.Text = "0";
            txtJNote.Text = string.Empty;
            rbGeneral.Checked = true;
            txtSearch.Text = string.Empty;
            resetData();
            dgvData.Rows.Clear();
            txtDebitTotal.Text = "0.00";
            txtCreditTotal.Text = "0.00";
            txtBalance.Text = "0.00";

        }
        private void btnNew_Click(object sender, EventArgs e)
        {
            clearData();
            txtJNo.Text = cj.getNewJournalNo(Program.braCode).Rows[0][0].ToString();
            txtNote.Focus();
            ;
        }
        void addJournalHeader()
        {
            int jPost = 0;
            int jType = 0;
            int userCode;

            if (chkPost.Checked)
            {
                jPost = 1;
            }
            else
            {
                jPost = 0;
            }


            if (rbGeneral.Checked)
            {
                jType = 1;
            }

            if (rbWait.Checked)
            {
                jType = 2;
            }

            if (rbrev.Checked)
            {
                jType = 3;
            }

            userCode = Convert.ToInt32(cu.getUserNo(Program.userName).Rows[0][0].ToString());
            cj.addJournalHeader(Convert.ToInt32(txtJNo.Text), Convert.ToDateTime(dtpJdate.Value.ToShortTimeString()), txtJNote.Text, jType, jPost, Convert.ToDouble(txtDebitTotal.Text), Convert.ToDouble(txtCreditTotal.Text), Convert.ToDouble(txtBalance.Text), userCode, DateTime.Now, Program.braCode, opType);

        }

        void addJournalBody()
        {
            if (dgvData.RowCount > 0)
            {
                for (int i = 0; i < dgvData.RowCount; i++)
                {
                    int accCode = Convert.ToInt32(dgvData.Rows[i].Cells[0].Value);
                    int currID = Convert.ToInt32(dgvData.Rows[i].Cells[4].Value);
                    double currVal = Convert.ToDouble(dgvData.Rows[i].Cells[6].Value);
                    double accDebitor = Convert.ToDouble(dgvData.Rows[i].Cells[2].Value);
                    double accCreditor = Convert.ToDouble(dgvData.Rows[i].Cells[3].Value);
                    string accNote = dgvData.Rows[i].Cells[7].Value?.ToString() ?? string.Empty;
                    int jNo = Convert.ToInt32(dgvData.Rows[i].Cells[10].Value);
                    cj.addJournalBody(accCode, currID, currVal, accDebitor, accCreditor, accNote, jNo);
                }
            }
        }

        void addReverseEnteryHeader()
        {
            int jPost = 0;
            int jType = 0;
            int userCode;

            if (chkPost.Checked)
            {
                jPost = 1;
            }
            else
            {
                jPost = 0;
            }
            jType = 3;

            jNo = Convert.ToInt32(cj.getNewJournalNo(Program.braCode).Rows[0][0]);
            string jNote = "قيد عكسي لرقم القيد" + " " + "(" + txtJNo.Text + ")";
            DateTime jDate = DateTime.Now;
            userCode = Convert.ToInt32(cu.getUserNo(Program.userName).Rows[0][0].ToString());
            cj.addJournalHeader(jNo, jDate, jNote, jType, jPost, Convert.ToDouble(txtDebitTotal.Text), Convert.ToDouble(txtCreditTotal.Text), Convert.ToDouble(txtBalance.Text), userCode, DateTime.Now, Program.braCode, opType);

        }



        void addReverseEnteryBody()
        {
            if (dgvData.RowCount > 0)
            {
                for (int i = 0; i < dgvData.RowCount; i++)
                {
                    int accCode = Convert.ToInt32(dgvData.Rows[i].Cells[0].Value);
                    int currID = Convert.ToInt32(dgvData.Rows[i].Cells[4].Value);
                    double currVal = Convert.ToDouble(dgvData.Rows[i].Cells[6].Value);
                    double accDebitor = Convert.ToDouble(dgvData.Rows[i].Cells[3].Value);
                    double accCreditor = Convert.ToDouble(dgvData.Rows[i].Cells[2].Value);
                    string accNote = dgvData.Rows[i].Cells[7].Value?.ToString() ?? string.Empty;

                    cj.addJournalBody(accCode, currID, currVal, accDebitor, accCreditor, accNote, jNo);
                }
            }
        }
        private void btnAdd_Click(object sender, EventArgs e)
        {
            try
            {
                if (txtJNo.Text == "0")
                {
                    MessageBox.Show("قم بإضافة قيد جديد أولاَ", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
                if (dgvData.RowCount == 0)
                {
                    MessageBox.Show("قم بإدخال القيد المحاسبي أولا", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                if (rbGeneral.Checked == true && Convert.ToDouble(txtBalance.Text) != 0)
                {
                    MessageBox.Show("القيد المحاسبي غير متوازن", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
                if (rbrev.Checked)
                {
                    addReverseEnteryHeader();
                    addReverseEnteryBody();
                    MessageBox.Show("تمت عملية عكس القيد بنجاح", "حفظ", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    return;
                }
                addJournalHeader();
                addJournalBody();
                MessageBox.Show("تمت عملية الحفظ بنجاح", "حفظ", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }
        void showJournalHeader()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            dt = cj.showJournalHeader(Convert.ToInt32(txtJoNo.Text));
            if (dt.Rows.Count > 0)
            {
                txtJNo.Text = dt.Rows[0][0].ToString();
                dtpJdate.Text = dt.Rows[0][1].ToString();
                txtJNote.Text = dt.Rows[0][2].ToString();
                if (dt.Rows[0][3].ToString() == "1")
                {
                    rbGeneral.Checked = true;
                }
                if (dt.Rows[0][3].ToString() == "2")
                {
                    rbWait.Checked = true;
                }
                if (dt.Rows[0][3].ToString() == "3")
                {
                    rbrev.Checked = true;
                }

                if (dt.Rows[0][4].ToString() == "1")
                {
                    chkPost.Checked = true;
                }
                else
                {
                    chkPost.Checked = false;
                }

                txtDebitTotal.Text = dt.Rows[0][5].ToString();
                txtCreditTotal.Text = dt.Rows[0][6].ToString();
                txtBalance.Text = dt.Rows[0][7].ToString();

                txtInsUser.Text = dt.Rows[0][9].ToString();
                txtInsDate.Text = dt.Rows[0][10].ToString();
                txtEditUser.Text = dt.Rows[0][12].ToString();
                txtEditDate.Text = dt.Rows[0][13].ToString();
                txtOPtype.Text = dt.Rows[0][16].ToString();

            }
            else
            {
                MessageBox.Show("لا يوجد هذا السند الذي تبحث عنه");
            }
        }

        void showJournalBody()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            dt = cj.showJournalBody(Convert.ToInt32(txtJoNo.Text));
            if (dt.Rows.Count > 0)
            {
                dgvData.Rows.Clear();
                int i = 0;
                dgvData.RowCount = dt.Rows.Count;
                for (int j = 0; j < dt.Rows.Count; j++)
                {
                    dgvData.Rows[i].Cells[0].Value = dt.Rows[j][1].ToString();
                    dgvData.Rows[i].Cells[1].Value = dt.Rows[j][2].ToString();
                    dgvData.Rows[i].Cells[2].Value = dt.Rows[j][6].ToString();
                    dgvData.Rows[i].Cells[3].Value = dt.Rows[j][7].ToString();
                    dgvData.Rows[i].Cells[4].Value = dt.Rows[j][3].ToString();
                    dgvData.Rows[i].Cells[5].Value = dt.Rows[j][4].ToString();
                    dgvData.Rows[i].Cells[6].Value = dt.Rows[j][5].ToString();
                    dgvData.Rows[i].Cells[7].Value = dt.Rows[j][8].ToString();
                    dgvData.Rows[i].Cells[8].Value = Convert.ToDouble(dt.Rows[j][6].ToString()) * Convert.ToDouble(dt.Rows[j][5].ToString());
                    dgvData.Rows[i].Cells[9].Value = Convert.ToDouble(dt.Rows[j][7].ToString()) * Convert.ToDouble(dt.Rows[j][5].ToString());
                    dgvData.Rows[i].Cells[10].Value = dt.Rows[j][9].ToString();
                    i++;

                }
                getTotal();
            }
        }
        private void txtJoNo_TextChanged(object sender, EventArgs e)
        {
            showJournalHeader();
            showJournalBody();
        }

        private void btnSearch_Click(object sender, EventArgs e)
        {
            txtJoNo.Text = txtSearch.Text;
        }

        private void btnFirst_Click(object sender, EventArgs e)
        {
            txtJoNo.Text = cj.getMinimumJno().Rows[0][0].ToString();
        }

        private void btnLast_Click(object sender, EventArgs e)
        {
            txtJoNo.Text = cj.getMaximumJno().Rows[0][0].ToString();
        }

        private void btnPerv_Click(object sender, EventArgs e)
        {
            int isMin = Convert.ToInt32(cj.getMinimumJno().Rows[0][0].ToString());
            if (Convert.ToInt32(txtJoNo.Text) == isMin)
            {
                MessageBox.Show("هذا هو أصغر رقم قيد", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }
            else
            {
                txtJoNo.Text = (Convert.ToInt32(txtJoNo.Text) - 1).ToString();
            }
        }

        private void btnNext_Click(object sender, EventArgs e)
        {
            int isMax = Convert.ToInt32(cj.getMaximumJno().Rows[0][0].ToString());
            if (Convert.ToInt32(txtJoNo.Text) == isMax)
            {
                MessageBox.Show("هذا هو أكبر رقم قيد", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }
            else
            {
                txtJoNo.Text = (Convert.ToInt32(txtJoNo.Text) + 1).ToString();
            }
        }
        void editJournalHeader()
        {
            int jPost = 0;
            int jType = 0;
            int userCode;

            if (chkPost.Checked)
            {
                jPost = 1;
            }
            else
            {
                jPost = 0;
            }
            if (rbGeneral.Checked)
            {
                jType = 1;
            }

            if (rbWait.Checked)
            {
                jType = 2;
            }

            if (rbrev.Checked)
            {
                jType = 3;
            }

            userCode = Convert.ToInt32(cu.getUserNo(Program.userName).Rows[0][0].ToString());
            cj.editJournalHeader(Convert.ToInt32(txtJNo.Text), Convert.ToDateTime(dtpJdate.Value.ToShortTimeString()), txtJNote.Text, jType, jPost, Convert.ToDouble(txtDebitTotal.Text), Convert.ToDouble(txtCreditTotal.Text), Convert.ToDouble(txtBalance.Text), userCode, DateTime.Now, Program.braCode, opType);

        }

        void delJournalBody()
        {
            cj.delJournalbody(Convert.ToInt32(txtJNo.Text));
        }
        private void btnEdit_Click(object sender, EventArgs e)
        {
            try
            {
                if (chkPost.Checked)
                {
                    MessageBox.Show("لا يمكن تعديل هذا القيد لأنه مرحل", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
                if (txtOPtype.Text != "يومية عامة")
                {
                    MessageBox.Show("لا يمكن تعديل هذا القيد لأنه متعلق بعملية أخرى", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
                if (txtJNo.Text == "0")
                {
                    MessageBox.Show("إبحث عن القيد الذي تريد تعديله  أولاَ", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
                if (dgvData.RowCount == 0)
                {
                    MessageBox.Show("قم بإدخال القيد المحاسبي أولا", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                if (rbGeneral.Checked == true && Convert.ToDouble(txtBalance.Text) != 0)
                {
                    MessageBox.Show("القيد المحاسبي غير متوازن", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                editJournalHeader();
                delJournalBody();
                addJournalBody();
                MessageBox.Show("تمت عملية التعديل بنجاح", "حفظ", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnDel_Click(object sender, EventArgs e)
        {
            try
            {
                if (chkPost.Checked)
                {
                    MessageBox.Show("لا يمكن حذف هذا القيد لأنه مرحل", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
                if (txtOPtype.Text != "يومية عامة")
                {
                    MessageBox.Show("لا يمكن حذف هذا القيد لأنه متعلق بعملية أخرى", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                if (MessageBox.Show("هل تريد الحذف فعلا", "تنبيه", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes)
                {
                    cj.delJournalEntry(Convert.ToInt32(txtJNo.Text), Program.braCode);
                    MessageBox.Show("تمت عملية الحذف بنجاح", "حفظ", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    resetData();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnPrint_Click(object sender, EventArgs e)
        {
            List<ReportDataSource> dataSource = new List<ReportDataSource>
            {
                new ReportDataSource("dsBranchData",csf.getBranchData(Program.braCode)),
                new ReportDataSource("dsJournalHeader",cj.showJournalHeader(Convert.ToInt32(txtJNo.Text))),
                new ReportDataSource("dsJournalBody",cj.showJournalBody(Convert.ToInt32(txtJNo.Text))),
            };
            string reportTitle = "قيد اليومية";
            IntegratedAccSys.Reports.frmReportViewer frv = new IntegratedAccSys.Reports.frmReportViewer("rptJournalEntery.rdlc", dataSource, reportTitle);
            frv.ShowDialog();
        }

        private void frmJournal_Load(object sender, EventArgs e)
        {
            PrivilegeApplier.Apply(this, 15);
        }
    }
}
