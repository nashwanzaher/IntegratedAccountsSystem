using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows.Forms;
using IntegratedAccSys.PL.Security;

namespace IntegratedAccSys.PL.Sales
{
    public partial class frmCustomers : Form
    {
        BL.Sales.ClsSales cs = new BL.Sales.ClsSales();
        public frmCustomers()
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
        void getAllCustomers()
        {
            dgvData.DataSource = cs.getAllCustomers(Program.braCode);
            dgvData.Columns[4].Visible = false;
            dgvData.Columns[5].Visible = false;
            dgvData.Columns[6].Visible = false;
        }
        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void frmCustomers_Load(object sender, EventArgs e)
        {
            BL.Users.ClsUsers cu = new BL.Users.ClsUsers();
            PrivilegeApplier.Apply(this, 34);
            getAllCustomers();
            dgvProperties();
        }

        private void dgvData_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            txtCustAccCode.Text = dgvData.CurrentRow.Cells[0].Value.ToString();
            txtCustName.Text = dgvData.CurrentRow.Cells[1].Value.ToString();
            txtMobile.Text = dgvData.CurrentRow.Cells[3].Value.ToString();
            txtEmail.Text = dgvData.CurrentRow.Cells[4].Value.ToString();
            txtDebitLimit.Text = dgvData.CurrentRow.Cells[2].Value.ToString();
            if (dgvData.CurrentRow.Cells[5].Value == DBNull.Value)
            {
                pbImg.Image = null;
            }
            else
            {
                byte[] pImg = (byte[])dgvData.CurrentRow.Cells[5].Value;
                MemoryStream ms = new MemoryStream(pImg);
                pbImg.Image = Image.FromStream(ms);
            }

        }

        private void btnBrowes_Click(object sender, EventArgs e)
        {
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.Filter = "Image Files|*.gif;*.jpg;*.png;*.bmp";
            if (ofd.ShowDialog() == DialogResult.OK)
            {
                pbImg.Image = Image.FromFile(ofd.FileName);
            }
        }

        private void btnClear_Click(object sender, EventArgs e)
        {
            pbImg.Image = null;
        }

        void resetData()
        {
            pbImg.Image = null;
            txtCustAccCode.Text = string.Empty;
            txtCustName.Text = string.Empty;
            txtMobile.Text = string.Empty;
            txtEmail.Text = string.Empty;
            txtDebitLimit.Text = "0.00";
            txtCustAccCode.Focus();
        }
        private void btnNew_Click(object sender, EventArgs e)
        {
            resetData();
        }

        private void txtCustAccCode_KeyDown(object sender, KeyEventArgs e)
        {
            PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
            if (e.KeyCode == Keys.Enter)
            {
                fsa.txtSearch.Text = txtCustAccCode.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtCustAccCode.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();
                    txtCustName.Text = fsa.dgvData.CurrentRow.Cells[1].Value.ToString();
                    txtMobile.Focus();
                }
            }
        }

        private void txtEmail_Validated(object sender, EventArgs e)
        {
            Regex reg = new Regex(@"^\w+([-_.]\w+)*@\w+([-.]\w+)*\.\w+$");
            if (!reg.IsMatch(txtEmail.Text))
            {
                MessageBox.Show("الصيغة التي أدخلتها غير صحيحة", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Error);
                txtEmail.Focus();
                return;
            }
        }

        private void btnAdd_Click(object sender, EventArgs e)
        {
            byte[] pImg;
            if (pbImg.Image == null)
            {

                int custCode = Convert.ToInt32(txtCustAccCode.Text);
                string custName = txtCustName.Text;
                double debitLimit = Convert.ToDouble(txtDebitLimit.Text);
                string mobile = txtMobile.Text;
                string Email = txtEmail.Text;
                pImg = new byte[0];
                int braCode = Program.braCode;
                string testImage = "withoutImg";
                cs.addCustomers(custCode, custName, debitLimit, mobile, Email, pImg, braCode, testImage);
            }
            else
            {
                MemoryStream ms = new MemoryStream();
                pbImg.Image.Save(ms, pbImg.Image.RawFormat);
                pImg = ms.ToArray();
                int custCode = Convert.ToInt32(txtCustAccCode.Text);
                string custName = txtCustName.Text;
                double debitLimit = Convert.ToDouble(txtDebitLimit.Text);
                string mobile = txtMobile.Text;
                string Email = txtEmail.Text;
                int braCode = Program.braCode;
                string testImage = "withImg";
                cs.addCustomers(custCode, custName, debitLimit, mobile, Email, pImg, braCode, testImage);

            }
            MessageBox.Show("تمت عملية الخفظ بنجاح", "عملية حفظ", MessageBoxButtons.OK, MessageBoxIcon.Information);
            getAllCustomers();
        }

        private void btnEdit_Click(object sender, EventArgs e)
        {
            byte[] pImg;
            if (pbImg.Image == null)
            {

                int custCode = Convert.ToInt32(txtCustAccCode.Text);
                string custName = txtCustName.Text;
                double debitLimit = Convert.ToDouble(txtDebitLimit.Text);
                string mobile = txtMobile.Text;
                string Email = txtEmail.Text;
                pImg = new byte[0];
                int braCode = Program.braCode;
                string testImage = "withoutImg";
                cs.editCustomers(custCode, custName, debitLimit, mobile, Email, pImg, braCode, testImage);
            }
            else
            {
                MemoryStream ms = new MemoryStream();
                pbImg.Image.Save(ms, pbImg.Image.RawFormat);
                pImg = ms.ToArray();
                int custCode = Convert.ToInt32(txtCustAccCode.Text);
                string custName = txtCustName.Text;
                double debitLimit = Convert.ToDouble(txtDebitLimit.Text);
                string mobile = txtMobile.Text;
                string Email = txtEmail.Text;
                int braCode = Program.braCode;
                string testImage = "withImg";
                cs.editCustomers(custCode, custName, debitLimit, mobile, Email, pImg, braCode, testImage);

            }
            MessageBox.Show("تمت عملية التعديل بنجاح", "عملية تعديل", MessageBoxButtons.OK, MessageBoxIcon.Information);
            getAllCustomers();
        }

        private void btnDel_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show("هل تريد الحذف", "تنبيه", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes)
            {
                cs.delCustomer(Convert.ToInt32(txtCustAccCode.Text), Program.braCode);
                MessageBox.Show("تمت عملية الحذف بنجاح", "عملية حذف", MessageBoxButtons.OK, MessageBoxIcon.Information);
                getAllCustomers();
            }
        }
    }
}
