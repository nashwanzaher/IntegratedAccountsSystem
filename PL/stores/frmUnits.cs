using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace IntegratedAccSys.PL.stores
{
    public partial class frmUnits : Form
    {
        BL.Stores.clsInventory ci = new BL.Stores.clsInventory();
        public frmUnits()
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
        void getAllUnits()
        {
            dgvData.DataSource = ci.getAllUnits();
        }
        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void btnNew_Click(object sender, EventArgs e)
        {
            txtUnitName.Text = string.Empty;
            txtConvertionFactor.Text = string.Empty;
            txtUnitName.Focus();
        }

        private void frmUnits_Load(object sender, EventArgs e)
        {
            BL.Users.clsUsers cu = new BL.Users.clsUsers();
            cu.ApplyPrivileges(this, 24);
            dgvProperties();
            getAllUnits();
        }

        private void dgvData_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            txtUnitName.Text = dgvData.CurrentRow.Cells[1].Value.ToString();
            txtConvertionFactor.Text = dgvData.CurrentRow.Cells[2].Value.ToString();
        }

        private void btnAdd_Click(object sender, EventArgs e)
        {
            try
            {
                ci.addUnit(txtUnitName.Text, Convert.ToDecimal(txtConvertionFactor.Text));
                MessageBox.Show("تمت عملية الحفظ بنجاح", "عملية حفظ", MessageBoxButtons.OK, MessageBoxIcon.Information);
                getAllUnits();
            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void btnEdit_Click(object sender, EventArgs e)
        {
            try
            {
                int ID = Convert.ToInt32(dgvData.CurrentRow.Cells[0].Value);
                ci.editUnit(ID, txtUnitName.Text, Convert.ToDecimal(txtConvertionFactor.Text));
                MessageBox.Show("تمت عملية التعديل بنجاح", "عملية تعديل", MessageBoxButtons.OK, MessageBoxIcon.Information);
                getAllUnits();
            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void btnDel_Click(object sender, EventArgs e)
        {
            try
            {
                int ID = Convert.ToInt32(dgvData.CurrentRow.Cells[0].Value);
                if (MessageBox.Show("هل تريد الحذف","تنبيه",MessageBoxButtons.YesNo,MessageBoxIcon.Warning)==DialogResult.Yes)
                {
                    ci.delUnit(ID);
                    MessageBox.Show("تمت عملية الحذف بنجاح", "عملية حذف", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    getAllUnits();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }
    }
}
