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

namespace IntegratedAccSys.PL.SysFormat
{
    public partial class frmCurrencies : Form
    {
        BL.SysFormat.ClsSysFormat csf = new BL.SysFormat.ClsSysFormat();
        public frmCurrencies()
        {
            InitializeComponent();
            getAllCurrencies();
        }

        void getAllCurrencies()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            dt = csf.getAllCurrencies();
            if (dt.Rows.Count > 0)
            {
                dgvData.DataSource = dt;
                dgvData.Columns[0].Visible = false;
                dgvData.Columns[1].HeaderText = "إسم العملة";
                dgvData.Columns[2].Visible = false;
                dgvData.Columns[3].Visible = false;
                dgvData.Columns[4].HeaderText = "الفكة";
                dgvData.Columns[5].HeaderText = "الرمز";

            }
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
            dgvData.AlternatingRowsDefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter;
            dgvData.AlternatingRowsDefaultCellStyle.Font = new Font("Times New Roman", 10.75F, FontStyle.Bold);

            // تنسيق خلايا البيانات
            dgvData.DefaultCellStyle.BackColor = Color.White;
            dgvData.DefaultCellStyle.ForeColor = Color.Blue;
            dgvData.DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter;
            dgvData.DefaultCellStyle.Font = new Font("Times New Roman", 10.75F, FontStyle.Bold);
        }

        void getAllCurrenciesTypes()
        {
            cbCurrType.DataSource = csf.getAllCurrenciesTypes();
            cbCurrType.ValueMember = "ID";
            cbCurrType.DisplayMember = "currtype";
        }

        private void frmCurrencies_Load(object sender, EventArgs e)
        {
            BL.Users.ClsUsers cu = new BL.Users.ClsUsers();
            PrivilegeApplier.Apply(this, 11);
            dgvProperties();
            getAllCurrenciesTypes();
        }

        void resetData()
        {
            getAllCurrenciesTypes();
            txtCurrName.Text = string.Empty;
            txtPenny.Text = string.Empty;
            txtSymbole.Text = string.Empty;
            txtCurrVal.Text = string.Empty;
            txtCurrID.Text = string.Empty;

        }
        private void btnNew_Click(object sender, EventArgs e)
        {
            resetData();
            cbCurrType.Focus();
            btnAdd.Enabled = true;
            btnEdit.Enabled = false;
            btnDel.Enabled = false;
        }

        private void txtCurrVal_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsDigit(e.KeyChar) && e.KeyChar != (char)Keys.Back && e.KeyChar != '.')
            {
                e.Handled = true;
            }
            if (e.KeyChar == '.' && (sender as TextBox)?.Text.Contains(".") == true)
            {
                e.Handled = true;
            }
        }

        void addCurrency()
        {
            csf.addCurrency(txtCurrName.Text, Convert.ToInt32(cbCurrType.SelectedValue), Convert.ToDouble(txtCurrVal.Text), txtPenny.Text, txtSymbole.Text);
            MessageBox.Show("تمت عملية الإضافة بنجاح", "عملية الحفظ", MessageBoxButtons.OK, MessageBoxIcon.Information);
            resetData();
            getAllCurrencies();
        }
        private void btnAdd_Click(object sender, EventArgs e)
        {
            try
            {
                Boolean currencyExist = false;
                if (dgvData.RowCount > 0)
                {
                    foreach (DataGridViewRow row in dgvData.Rows)
                    {
                        if (row.Cells[1].Value.ToString() == txtCurrName.Text)
                        {
                            MessageBox.Show("العملة التي تريد إدخالها موجود مسبقا", "تنبية", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                            currencyExist = true;
                            break;
                        }
                    }
                    if (!currencyExist)
                    {
                        addCurrency();
                    }
                }
                else
                {
                    addCurrency();
                }


            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Error);

            }
        }

        private void dgvData_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            txtCurrID.Text = dgvData.CurrentRow.Cells[0].Value.ToString();
            txtCurrName.Text = dgvData.CurrentRow.Cells[1].Value.ToString();
            cbCurrType.SelectedValue = dgvData.CurrentRow.Cells[2].Value;
            txtPenny.Text = dgvData.CurrentRow.Cells[4].Value.ToString();
            txtSymbole.Text = dgvData.CurrentRow.Cells[5].Value.ToString();
            txtCurrVal.Text = dgvData.CurrentRow.Cells[3].Value.ToString();
            btnAdd.Enabled = true;
            btnEdit.Enabled = true;
            btnDel.Enabled = true;
        }

        private void btnEdit_Click(object sender, EventArgs e)
        {
            try
            {
                if (txtCurrID.Text == "")
                {
                    MessageBox.Show("قم بإختيار العملة التي تريد تعديلها", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
                csf.updateCurrency(txtCurrName.Text, Convert.ToInt32(cbCurrType.SelectedValue), Convert.ToDouble(txtCurrVal.Text), txtPenny.Text, txtSymbole.Text, Convert.ToInt32(txtCurrID.Text));
                MessageBox.Show("تمت عملية التعديل بنجاح", "عملية التعديل", MessageBoxButtons.OK, MessageBoxIcon.Information);
                resetData();
                getAllCurrencies();
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
                if (txtCurrID.Text == "")
                {
                    MessageBox.Show("قم بإختيار العملة التي تريد حذفها", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
                if (MessageBox.Show("هل فعلا تريد حذف العملة", "حذف عملة", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes)
                {
                    csf.delCurrency(Convert.ToInt32(txtCurrID.Text));
                    MessageBox.Show("تمت عملية الحذف بنجاح", "عملية الحذف", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    resetData();
                    getAllCurrencies();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Error);

            }
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            Close();
        }
    }
}
