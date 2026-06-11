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
using Microsoft.CodeAnalysis.VisualBasic.Syntax;

namespace IntegratedAccSys.PL.SysFormat
{
    public partial class frmFunds : Form
    {
        BL.SysFormat.ClsSysFormat csf = new BL.SysFormat.ClsSysFormat();
        public frmFunds()
        {
            InitializeComponent();
            dgvProperties();
        }

        void dgvProperties()
        {
            // تنسيق رؤوس الأعمدة
            dgvData.ColumnHeadersDefaultCellStyle.ForeColor = Color.Red;
            dgvData.ColumnHeadersDefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter;
            dgvData.ColumnHeadersDefaultCellStyle.Font = new Font("Times New Roman", 10.75F, FontStyle.Bold);

            // تنسيق الصفوف المتبادلة
            dgvData.AlternatingRowsDefaultCellStyle.ForeColor = Color.Red;
            dgvData.AlternatingRowsDefaultCellStyle.BackColor = Color.SkyBlue;
            dgvData.AlternatingRowsDefaultCellStyle.Font = new Font("Times New Roman", 10.75F, FontStyle.Bold);

            // تنسيق خلايا البيانات
            dgvData.DefaultCellStyle.BackColor = Color.White;
            dgvData.DefaultCellStyle.ForeColor = Color.Blue;
            dgvData.DefaultCellStyle.Font = new Font("Times New Roman", 10.75F, FontStyle.Bold);
        }
        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        void resetData()
        {
            txtAccNo.Text = string.Empty;
            txtAccName.Text = string.Empty;
        }
        private void btnNew_Click(object sender, EventArgs e)
        {
            resetData();
            txtAccNo.Focus();
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
                    btnAdd.Focus();
                }
            }
        }

        void getAllFunds()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            dt = csf.getAllFunds();
            if (dt.Rows.Count > 0)
            {
                dgvData.DataSource = dt;
                dgvData.Columns[0].HeaderText = "رقم الحساب";
                dgvData.Columns[1].HeaderText = "إسم الحساب";

            }
        }

        void addFund()
        {
            csf.addFund(Convert.ToInt32(txtAccNo.Text), txtAccName.Text);
            getAllFunds();
            MessageBox.Show("تمت عملية الحفظ بنجاح", "عملية الحفظ", MessageBoxButtons.OK, MessageBoxIcon.Information);
            resetData();
        }
        private void btnAdd_Click(object sender, EventArgs e)
        {
            try
            {

                if (txtAccNo.Text == "" && txtAccName.Text == "")
                {
                    MessageBox.Show("يجب إختيار حساب ", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
                Boolean accounExist = false;
                if (dgvData.RowCount > 0)
                {
                    foreach (DataGridViewRow row in dgvData.Rows)
                    {
                        if (row.Cells[0].Value != null && row.Cells[0].Value.ToString() == txtAccNo.Text)
                        {
                            MessageBox.Show("الحساب الذي تريد إضافته موجود مسبقاً", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                            accounExist = true;
                            break;

                        }

                    }
                    if (!accounExist)
                    {
                        addFund();
                    }
                }
                else
                {
                    addFund();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Information);

            }
        }

        private void btnEdit_Click(object sender, EventArgs e)
        {
            try
            {
                if (txtAccNo.Text == "" && txtAccName.Text == "")
                {
                    MessageBox.Show("يجب إختيار حساب ", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
                csf.updateFund(Convert.ToInt32(txtAccNo.Text), txtAccName.Text);
                getAllFunds();
                MessageBox.Show("تمت عملية التعديل بنجاح", "عملية التعديل", MessageBoxButtons.OK, MessageBoxIcon.Information);
                resetData();
            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Information);

            }

        }

        private void frmFunds_Load(object sender, EventArgs e)
        {
            BL.Users.ClsUsers cu = new BL.Users.ClsUsers();
            PrivilegeApplier.Apply(this, 9);
            getAllFunds();
        }

        private void dgvData_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            txtAccNo.Text = dgvData.CurrentRow.Cells[0].Value.ToString();
            txtAccName.Text = dgvData.CurrentRow.Cells[1].Value.ToString();
        }

        private void btnDel_Click(object sender, EventArgs e)
        {
            try
            {
                if (txtAccNo.Text == "" && txtAccName.Text == "")
                {
                    MessageBox.Show("يجب إختيار حساب ", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
                if (MessageBox.Show("هل انت متأكد من أنك تريد الحذف", "تنبيه", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes)
                {
                    csf.delFund(Convert.ToInt32(txtAccNo.Text));
                    MessageBox.Show("تمت عملية الحذف بنجاح", "عملية الحذف", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    getAllFunds();
                    resetData();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Information);

            }

        }
    }
}
