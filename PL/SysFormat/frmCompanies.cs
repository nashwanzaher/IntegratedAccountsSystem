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
    public partial class frmCompanies : Form
    {
        BL.SysFormat.clsSysFormat csf = new BL.SysFormat.clsSysFormat();
        byte[] cImg;
        public frmCompanies()
        {
            InitializeComponent();
            dgvProperties();
            getAllBraches();
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
        void getAllBraches()
        {
            dgvData.DataSource = csf.getAllBranches();
            dgvData.Columns[0].Visible = true;
            dgvData.Columns[0].HeaderText = "رقم الفرع";
            dgvData.Columns[1].Visible = true;
            dgvData.Columns[1].HeaderText = "إسم الفرع";
            dgvData.Columns[2].Visible = false;
            dgvData.Columns[3].Visible = false;
            dgvData.Columns[4].Visible = true;
            dgvData.Columns[4].HeaderText = "رقم التلفون";
            dgvData.Columns[5].Visible = false;
            dgvData.Columns[6].Visible = false;
            dgvData.Columns[7].Visible = false;
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        void resetData()
        {
            txtBranchNo.Text = string.Empty;
            txtBraName.Text = string.Empty;
            txtBraAddress.Text = string.Empty;
            txtBraActivity.Text = string.Empty;
            txtBraTel.Text = string.Empty;
            txtBraFax.Text = string.Empty;
            txtBraEmail.Text = string.Empty;
            PbLogo.Image = null;
        }
        private void btnNew_Click(object sender, EventArgs e)
        {
            resetData();

            txtBranchNo.Text = csf.getNewBranchNo().Rows[0][0].ToString();
        }

        private void btnBrawse_Click(object sender, EventArgs e)
        {
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.Filter = "Image Files|*.gif;*.jpg;*.png;*.bmp|All Files|*.*";
            if (ofd.ShowDialog() == DialogResult.OK)
            {
                PbLogo.Image = Image.FromFile(ofd.FileName);
            }
        }

        private void btnClear_Click(object sender, EventArgs e)
        {
            PbLogo.Image = null;
        }

        private void btnAdd_Click(object sender, EventArgs e)
        {
            try
            {
                if (PbLogo.Image == null)
                {
                    cImg = new byte[0];
                    csf.addCompany(Convert.ToInt32(txtBranchNo.Text), txtBraName.Text, txtBraAddress.Text, txtBraActivity.Text, txtBraTel.Text, txtBraFax.Text, txtBraEmail.Text, cImg, "withoutImage");
                }
                else
                {
                    MemoryStream ms = new MemoryStream();
                    PbLogo.Image.Save(ms, PbLogo.Image.RawFormat);
                    cImg = ms.ToArray();
                    csf.addCompany(Convert.ToInt32(txtBranchNo.Text), txtBraName.Text, txtBraAddress.Text, txtBraActivity.Text, txtBraTel.Text, txtBraFax.Text, txtBraEmail.Text, cImg, "withImage");

                }
                MessageBox.Show("تمت عملية الحفظ بنجاح", "حفظ", MessageBoxButtons.OK, MessageBoxIcon.Information);
                getAllBraches();
            }
            catch (Exception ex)
            {
                MessageBox.Show("نص رسالة الخطأ" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void dgvData_DoubleClick(object sender, EventArgs e)
        {
            txtBranchNo.Text = dgvData.CurrentRow.Cells[0].Value.ToString();
            txtBraName.Text = dgvData.CurrentRow.Cells[1].Value.ToString();
            txtBraAddress.Text = dgvData.CurrentRow.Cells[2].Value.ToString();
            txtBraActivity.Text = dgvData.CurrentRow.Cells[3].Value.ToString();
            txtBraTel.Text = dgvData.CurrentRow.Cells[4].Value.ToString();
            txtBraFax.Text = dgvData.CurrentRow.Cells[5].Value.ToString();
            txtBraEmail.Text = dgvData.CurrentRow.Cells[6].Value.ToString();
            if (dgvData.CurrentRow.Cells[7].Value != DBNull.Value)
            {
                cImg = (byte[])dgvData.CurrentRow.Cells[7].Value;
                MemoryStream ms = new MemoryStream(cImg);
                PbLogo.Image = Image.FromStream(ms);
            }
            else
            {
                PbLogo.Image = null;
            }

        }

        private void btnEdit_Click(object sender, EventArgs e)
        {
            try
            {
                if (PbLogo.Image == null)
                {
                    cImg = new byte[0];
                    csf.updateCompany(Convert.ToInt32(txtBranchNo.Text), txtBraName.Text, txtBraAddress.Text, txtBraActivity.Text, txtBraTel.Text, txtBraFax.Text, txtBraEmail.Text, cImg, "withoutImage");
                }
                else
                {
                    MemoryStream ms = new MemoryStream();
                    PbLogo.Image.Save(ms, PbLogo.Image.RawFormat);
                    cImg = ms.ToArray();
                    csf.updateCompany(Convert.ToInt32(txtBranchNo.Text), txtBraName.Text, txtBraAddress.Text, txtBraActivity.Text, txtBraTel.Text, txtBraFax.Text, txtBraEmail.Text, cImg, "withImage");

                }
                MessageBox.Show("تمت عملية التعديل بنجاح", "تعديل", MessageBoxButtons.OK, MessageBoxIcon.Information);
                getAllBraches();
            }
            catch (Exception ex)
            {
                MessageBox.Show("نص رسالة الخطأ" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnDel_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show("هل انت متأكد من انك تريد حذف هذا السجل أم لا", "تحذير", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes)
            {
                csf.delCompany(Convert.ToInt32(txtBranchNo.Text));
                getAllBraches();
                resetData();
                MessageBox.Show("تمت عملية الحذف بنجاح", "حذف", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
        }

        private void frmCompanies_Load(object sender, EventArgs e)
        {
            BL.Users.clsUsers cu = new BL.Users.clsUsers();
            cu.ApplyPrivileges(this, 8);
        }
    }
}
