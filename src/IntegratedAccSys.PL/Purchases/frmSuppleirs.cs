using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows.Forms;
using IntegratedAccSys.PL.Security;

namespace IntegratedAccSys.PL.Purchases
{
    public partial class frmSuppleirs : Form
    {
        BL.Purchases.ClsPurchases cp = new BL.Purchases.ClsPurchases();
        public frmSuppleirs()
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
        void getAllSuppliers()
        {
            dgvData.DataSource = cp.getAllSuppliers(Program.braCode);
            dgvData.Columns[4].Visible = false;
            dgvData.Columns[5].Visible = false;
        }

        private void frmSuppleirs_Load(object sender, EventArgs e)
        {
            BL.Users.ClsUsers cu = new BL.Users.ClsUsers();
            PrivilegeApplier.Apply(this, 31);
            dgvProperties();
            getAllSuppliers();
        }

        private void txtSuppAccCode_KeyDown(object sender, KeyEventArgs e)
        {
            PL.Accounts.frmSelectAccount fsa = new PL.Accounts.frmSelectAccount();
            if (e.KeyCode == Keys.Enter)
            {
                fsa.txtSearch.Text = txtSuppAccCode.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtSuppAccCode.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();
                    txtSuppName.Text = fsa.dgvData.CurrentRow.Cells[1].Value.ToString();
                    txtMobile.Focus();
                }
            }
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
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

        private void dgvData_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            txtSuppAccCode.Text = dgvData.CurrentRow.Cells[0].Value.ToString();
            txtSuppName.Text = dgvData.CurrentRow.Cells[1].Value.ToString();
            txtMobile.Text = dgvData.CurrentRow.Cells[2].Value.ToString();
            txtEmail.Text = dgvData.CurrentRow.Cells[3].Value.ToString();
            if (dgvData.CurrentRow.Cells[4].Value == DBNull.Value)
            {
                pbImg.Image = null;
            }
            else
            {
                byte[] pImg = (byte[])dgvData.CurrentRow.Cells[4].Value;
                MemoryStream ms = new MemoryStream(pImg);
                pbImg.Image = Image.FromStream(ms);
            }


        }

        private void btnNew_Click(object sender, EventArgs e)
        {
            txtSuppAccCode.Text = string.Empty;
            txtSuppName.Text = string.Empty;
            txtMobile.Text = string.Empty;
            txtEmail.Text = string.Empty;
            txtSuppAccCode.Focus();
        }

        private void btnAdd_Click(object sender, EventArgs e)
        {
            try
            {
                byte[] pImg;
                if (pbImg.Image == null)
                {
                    pImg = new byte[0];
                    cp.addSuppleir(Convert.ToInt32(txtSuppAccCode.Text), txtSuppName.Text, txtMobile.Text, txtEmail.Text, pImg, "withoutImg", Program.braCode);
                    MessageBox.Show("تمت عملية الحفط بنجاح", "عملية الحفظ", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    getAllSuppliers();
                }
                else
                {
                    MemoryStream ms = new MemoryStream();
                    pbImg.Image.Save(ms, pbImg.Image.RawFormat);
                    pImg = ms.ToArray();
                    cp.addSuppleir(Convert.ToInt32(txtSuppAccCode.Text), txtSuppName.Text, txtMobile.Text, txtEmail.Text, pImg, "withImg", Program.braCode);
                    MessageBox.Show("تمت عملية الحفط بنجاح", "عملية الحفظ", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    getAllSuppliers();
                }

            }
            catch (Exception ex)
            {
                MessageBox.Show("نص الخطأ" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void btnEdit_Click(object sender, EventArgs e)
        {
            try
            {
                byte[] pImg;
                if (pbImg.Image == null)
                {
                    pImg = new byte[0];
                    cp.editSuppleir(Convert.ToInt32(txtSuppAccCode.Text), txtSuppName.Text, txtMobile.Text, txtEmail.Text, pImg, "withoutImg", Program.braCode);
                    MessageBox.Show("تمت عملية التعديل بنجاح", "عملية التعديل", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    getAllSuppliers();
                }
                else
                {
                    MemoryStream ms = new MemoryStream();
                    pbImg.Image.Save(ms, pbImg.Image.RawFormat);
                    pImg = ms.ToArray();
                    cp.editSuppleir(Convert.ToInt32(txtSuppAccCode.Text), txtSuppName.Text, txtMobile.Text, txtEmail.Text, pImg, "withImg", Program.braCode);
                    MessageBox.Show("تمت عملية التعديل بنجاح", "عملية التعديل", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    getAllSuppliers();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("نص الخطأ" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void btnDel_Click(object sender, EventArgs e)
        {
            try
            {
                if (MessageBox.Show("هل تريد الحذف", "تنبيه", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes)
                {
                    cp.delSupplier(Convert.ToInt32(txtSuppAccCode.Text), Program.braCode);
                    MessageBox.Show("تمت عملية الحذف بنجاح", "عملية الحذف", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    getAllSuppliers();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("نص الخطأ" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }
    }
}
