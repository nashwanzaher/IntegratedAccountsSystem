using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace IntegratedAccSys.PL.SysFormat
{
    public partial class frmBanks : Form
    {
        BL.SysFormat.clsSysFormat csf = new BL.SysFormat.clsSysFormat();
        public frmBanks()
        {
            InitializeComponent();
            dgvProperties();
            getAllBanks();

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
            btnAdd.Enabled = true;
        }

        private void txtAccNo_KeyDown(object sender, KeyEventArgs e)
        {
            PL.Accounts.frmSelectAccount fsa = new PL.Accounts.frmSelectAccount();
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

        void getAllBanks()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            dt = csf.getAllBanks();
            if (dt.Rows.Count > 0)
            {
                dgvData.DataSource = dt;
                dgvData.Columns[0].HeaderText = "رقم الحساب";
                dgvData.Columns[1].HeaderText = "إسم الحساب";
            }
        }
        void addBank()
        {
            csf.addBank(Convert.ToInt32(txtAccNo.Text), txtAccName.Text);
            MessageBox.Show("تمت عملية الحفظ بنجاح", "عملية الحفظ", MessageBoxButtons.OK, MessageBoxIcon.Information);
            resetData();
            getAllBanks();
        }
        private void btnAdd_Click(object sender, EventArgs e)
        {
            try
            {
                if (txtAccNo.Text == "" && txtAccName.Text == "")
                {
                    MessageBox.Show("يجب إختيار حساب محدد", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
                Boolean accountExist = false;
                if (dgvData.RowCount > 0)
                {
                    foreach (DataGridViewRow row in dgvData.Rows)
                    {
                        if (row.Cells[0].Value != null && row.Cells[0].Value.ToString() == txtAccNo.Text)
                        {
                            MessageBox.Show("الحساب الذي تريد إدخاله موجود مسبقا", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                            accountExist = true;
                            break;

                        }
                    }
                    if (!accountExist)
                    {
                        addBank();
                    }
                }
                else
                {
                    addBank();
                }


            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Error);

            }
        }

        private void btnEdit_Click(object sender, EventArgs e)
        {
            try
            {
                if (txtAccNo.Text == "" && txtAccName.Text == "")
                {
                    MessageBox.Show("يجب إختيار حساب محدد", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
                csf.UpdateBank(Convert.ToInt32(txtAccNo.Text), txtAccName.Text);
                MessageBox.Show("تمت عملية التعديل بنجاح", "عملية التعديل", MessageBoxButtons.OK, MessageBoxIcon.Information);
                resetData();
                getAllBanks();
            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Error);

            }
        }

        private void dgvData_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            txtAccNo.Text = dgvData.CurrentRow.Cells[0].Value.ToString();
            txtAccName.Text = dgvData.CurrentRow.Cells[1].Value.ToString();

            btnAdd.Enabled = false;
            btnEdit.Enabled = true;
            btnDel.Enabled = true;
            btnEdit.Focus();
        }

        private void btnDel_Click(object sender, EventArgs e)
        {
            try
            {
                if (MessageBox.Show("هل تريد الحذف بالفعل", "تنبيه", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes)
                {
                    csf.delBank(Convert.ToInt32(txtAccNo.Text));
                    MessageBox.Show("تمت عملية الحذف بنجاح", "عملية الحذف", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    resetData();
                    getAllBanks();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Error);

            }
        }

        private void frmBanks_Load(object sender, EventArgs e)
        {
            BL.Users.clsUsers cu = new BL.Users.clsUsers();
            cu.ApplyPrivileges(this, 10);
        }
    }
}
