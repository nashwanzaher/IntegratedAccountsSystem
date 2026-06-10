using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Globalization;
using IntegratedAccSys.PL.Security;

namespace IntegratedAccSys.PL.Users
{
    public partial class frmUsers : Form
    {
        BL.Users.ClsUsers cu = new BL.Users.ClsUsers();
        byte[]? uImg;
        public frmUsers()
        {
            InitializeComponent();
            dgvProperties();
            getAllUsers();

        }
        void getAllUsers()
        {
            dgvData.DataSource = cu.getAllUsers(Program.braCode);
            dgvData.Columns[0].Visible = true;
            dgvData.Columns[0].HeaderText = "رقم المستخدم";
            dgvData.Columns[1].Visible = true;
            dgvData.Columns[1].HeaderText = "إسم المستخدم";
            dgvData.Columns[2].Visible = false;
            dgvData.Columns[3].Visible = false;
            dgvData.Columns[4].Visible = true;
            dgvData.Columns[4].HeaderText = "موبايل";
            dgvData.Columns[5].Visible = true;
            dgvData.Columns[5].HeaderText = "بريد إلكتروني";
            dgvData.Columns[6].Visible = false;
            dgvData.Columns[7].Visible = false;
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

            // تنسيق خلايا البيانات
            dgvData.DefaultCellStyle.BackColor = Color.White;
            dgvData.DefaultCellStyle.ForeColor = Color.Blue;
            dgvData.DefaultCellStyle.Font = new Font("Times New Roman", 10.75F, FontStyle.Bold);
        }

        private void dgvData_DoubleClick(object sender, EventArgs e)
        {
            txtUserNo.Text = dgvData.CurrentRow.Cells[0].Value.ToString();
            txtFullName.Text = dgvData.CurrentRow.Cells[1].Value.ToString();
            txtID.Text = dgvData.CurrentRow.Cells[2].Value.ToString();
            txtPWD.Text = dgvData.CurrentRow.Cells[3].Value.ToString();
            txtMobile.Text = dgvData.CurrentRow.Cells[4].Value.ToString();
            txtUserEmail.Text = dgvData.CurrentRow.Cells[5].Value.ToString();
            if (dgvData.CurrentRow.Cells[6].Value != DBNull.Value)
            {
                uImg = (byte[])dgvData.CurrentRow.Cells[6].Value;
                MemoryStream ms = new MemoryStream(uImg);
                pbUserImg.Image = Image.FromStream(ms);
            }
            else
            {
                pbUserImg.Image = null;
            }

        }
        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        void resetData()
        {
            txtUserNo.Text = string.Empty;
            txtFullName.Text = string.Empty;
            txtID.Text = string.Empty;
            txtPWD.Text = string.Empty;
            txtMobile.Text = string.Empty;
            txtUserEmail.Text = string.Empty;
            pbUserImg.Image = null;


        }
        private void btnNew_Click(object sender, EventArgs e)
        {
            resetData();
            txtUserNo.Text = cu.getUserNewNo().Rows[0][0].ToString();
            txtFullName.Focus();
        }

        private void btnBrawse_Click(object sender, EventArgs e)
        {
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.Filter = "Image Files|*.gif;*.jpg;*.png;*.bmp|All Files|*.*";
            if (ofd.ShowDialog() == DialogResult.OK)
            {
                pbUserImg.Image = Image.FromFile(ofd.FileName);
            }
            btnAdd.Focus();
        }

        private void btnClear_Click(object sender, EventArgs e)
        {
            pbUserImg.Image = null;
        }

        void addPrivillages()
        {
            int userCode = Convert.ToInt32(cu.getUserNo(txtID.Text).Rows[0][0]);
            cu.addPrivillages(userCode, Program.braCode);
        }
        private void btnAdd_Click(object sender, EventArgs e)
        {

            try
            {
                if (pbUserImg.Image == null)
                {
                    uImg = new byte[0];
                    cu.addUser(Convert.ToInt32(txtUserNo.Text), txtFullName.Text, txtID.Text, txtPWD.Text, txtMobile.Text, txtUserEmail.Text, uImg, Program.braCode, "withoutImage");
                }
                else
                {
                    MemoryStream ms = new MemoryStream();
                    pbUserImg.Image.Save(ms, pbUserImg.Image.RawFormat);
                    uImg = ms.ToArray();
                    cu.addUser(Convert.ToInt32(txtUserNo.Text), txtFullName.Text, txtID.Text, txtPWD.Text, txtMobile.Text, txtUserEmail.Text, uImg, Program.braCode, "withImage");
                }
                addPrivillages();
                MessageBox.Show("تمت عملية الحفظ بنجاح", "حفظ", MessageBoxButtons.OK, MessageBoxIcon.Information);
                getAllUsers();
                btnNew.Focus();

            }
            catch (Exception ex)
            {
                MessageBox.Show("نص الخطأ" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }

        }

        private void btnEdit_Click(object sender, EventArgs e)
        {
            try
            {
                if (pbUserImg.Image == null)
                {
                    uImg = new byte[0];
                    cu.updateUser(Convert.ToInt32(txtUserNo.Text), txtFullName.Text, txtID.Text, txtPWD.Text, txtMobile.Text, txtUserEmail.Text, uImg, Program.braCode, "withoutImage");
                }
                else
                {
                    MemoryStream ms = new MemoryStream();
                    pbUserImg.Image.Save(ms, pbUserImg.Image.RawFormat);
                    uImg = ms.ToArray();
                    cu.updateUser(Convert.ToInt32(txtUserNo.Text), txtFullName.Text, txtID.Text, txtPWD.Text, txtMobile.Text, txtUserEmail.Text, uImg, Program.braCode, "withImage");
                }
                MessageBox.Show("تمت عملية التعديل بنجاح", "تعديل", MessageBoxButtons.OK, MessageBoxIcon.Information);
                getAllUsers();

            }
            catch (Exception ex)
            {
                MessageBox.Show("نص الخطأ" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
        }

        private void btnDel_Click(object sender, EventArgs e)
        {
            try
            {
                if (MessageBox.Show("هل تريد حذف بيانات المستخدم  أم لا", "تنبيه", MessageBoxButtons.YesNo) == DialogResult.Yes)
                {
                    cu.delUser(Convert.ToInt32(txtUserNo.Text));
                    MessageBox.Show("تمت عملية الحذف بنجاح", "حذف", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    getAllUsers();
                    resetData();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("نص الخطأ" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void txtFullName_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                txtID.Focus();
            }
        }

        private void txtID_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                txtPWD.Focus();
            }
        }

        private void txtPWD_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                txtMobile.Focus();
            }
        }

        private void txtMobile_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                txtUserEmail.Focus();
            }
        }

        private void txtUserEmail_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                btnBrawse.Focus();
            }
        }

        private void txtFullName_Enter(object sender, EventArgs e)
        {
            Application.CurrentInputLanguage = InputLanguage.FromCulture(new CultureInfo("ar-ye"))!;
        }

        private void txtID_Enter(object sender, EventArgs e)
        {
            Application.CurrentInputLanguage = InputLanguage.FromCulture(new CultureInfo("en-us"))!;
        }

        private void txtPWD_Enter(object sender, EventArgs e)
        {
            Application.CurrentInputLanguage = InputLanguage.FromCulture(new CultureInfo("en-us"))!;
        }

        private void txtMobile_Enter(object sender, EventArgs e)
        {
            Application.CurrentInputLanguage = InputLanguage.FromCulture(new CultureInfo("en-us"))!;
        }

        private void txtUserEmail_Enter(object sender, EventArgs e)
        {
            Application.CurrentInputLanguage = InputLanguage.FromCulture(new CultureInfo("en-us"))!;
        }

        private void frmUsers_Load(object sender, EventArgs e)
        {
            BL.Users.ClsUsers cu = new BL.Users.ClsUsers();
            PrivilegeApplier.Apply(this, 4);
        }
    }
}
