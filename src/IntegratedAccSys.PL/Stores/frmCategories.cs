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

namespace IntegratedAccSys.PL.Stores
{
    public partial class frmCategories : Form
    {
        BL.Stores.ClsInventory ci = new BL.Stores.ClsInventory();

        public frmCategories()
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
        void getAllCategories()
        {
            dgvData.DataSource = ci.getAllCategories();
            dgvData.Columns[0].HeaderText = "الرقم";
            dgvData.Columns[1].HeaderText = "إسم المجموعة";
            dgvData.Columns[16].HeaderText = "المخزن";
            dgvData.Columns[2].Visible = false;
            dgvData.Columns[3].Visible = false;
            dgvData.Columns[4].Visible = false;
            dgvData.Columns[5].Visible = false;
            dgvData.Columns[6].Visible = false;
            dgvData.Columns[7].Visible = false;
            dgvData.Columns[8].Visible = false;
            dgvData.Columns[9].Visible = false;
            dgvData.Columns[10].Visible = false;
            dgvData.Columns[11].Visible = false;
            dgvData.Columns[12].Visible = false;
            dgvData.Columns[13].Visible = false;
            dgvData.Columns[14].Visible = false;
            dgvData.Columns[15].Visible = false;

        }
        private void btnNew_Click(object sender, EventArgs e)
        {
            txtCatName.Text = string.Empty;
            txtInvCode.Text = string.Empty;

            txtCatName.Focus();
        }
        void getStoreData()
        {

            //get All Stores Data
            cbStores.DataSource = ci.getAllStroes();
            cbStores.ValueMember = "الرقم";
            cbStores.DisplayMember = "إسم المخزن";
            cbStores.Text = "إختار المخزن";

        }
        private void frmCategories_Load(object sender, EventArgs e)
        {
            BL.Users.ClsUsers cu = new BL.Users.ClsUsers();
            PrivilegeApplier.Apply(this, 23);
            dgvProperties();
            getAllCategories();
            getStoreData();

        }

        private void dgvData_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            txtCatName.Text = dgvData.CurrentRow.Cells[1].Value.ToString();
            txtInventoryAccNo.Text = dgvData.CurrentRow.Cells[2].Value.ToString();
            txtCatSaleAccNo.Text = dgvData.CurrentRow.Cells[3].Value.ToString();
            txtCatSaleReturnAccNo.Text = dgvData.CurrentRow.Cells[4].Value.ToString();
            txtCatSaleDiscountAccNo.Text = dgvData.CurrentRow.Cells[5].Value.ToString();
            txtCatSaleQtyFreeAccNo.Text = dgvData.CurrentRow.Cells[6].Value.ToString();
            txtCatSaleVatAccNo.Text = dgvData.CurrentRow.Cells[7].Value.ToString();
            txtCatSaleCostAccNo.Text = dgvData.CurrentRow.Cells[8].Value.ToString();
            txtCatSaleRevenuseAccNo.Text = dgvData.CurrentRow.Cells[9].Value.ToString();
            txtCatPurchaseAccNo.Text = dgvData.CurrentRow.Cells[10].Value.ToString();
            txtCatPurchaseReturnAccNo.Text = dgvData.CurrentRow.Cells[11].Value.ToString();
            txtCatPurchaseDiscountAccNo.Text = dgvData.CurrentRow.Cells[12].Value.ToString();
            txtCaPurchaseQtyFreeAccNo.Text = dgvData.CurrentRow.Cells[13].Value.ToString();
            txtCatPurchaseVatAccNo.Text = dgvData.CurrentRow.Cells[14].Value.ToString();
            cbStores.Text = dgvData.CurrentRow.Cells[16].Value.ToString();
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void btnAdd_Click(object sender, EventArgs e)
        {
            try
            {


                ci.addCategories(txtCatName.Text, Convert.ToInt32(cbStores.SelectedValue), Convert.ToInt32(txtInventoryAccNo.Text), Convert.ToInt32(txtCatSaleAccNo.Text), Convert.ToInt32(txtCatSaleReturnAccNo.Text), Convert.ToInt32(txtCatSaleVatAccNo.Text), Convert.ToInt32(txtCatSaleDiscountAccNo.Text), Convert.ToInt32(txtCatSaleQtyFreeAccNo.Text), Convert.ToInt32(txtCatSaleCostAccNo.Text), Convert.ToInt32(txtCatSaleRevenuseAccNo.Text), Convert.ToInt32(txtCatPurchaseAccNo.Text), Convert.ToInt32(txtCatPurchaseReturnAccNo.Text), Convert.ToInt32(txtCatPurchaseVatAccNo.Text), Convert.ToInt32(txtCatPurchaseDiscountAccNo.Text), Convert.ToInt32(txtCaPurchaseQtyFreeAccNo.Text));
                MessageBox.Show("تمت عملية الحفظ بنجاح", "عملية حفظ", MessageBoxButtons.OK, MessageBoxIcon.Information);
                getAllCategories();
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
                ci.editCategories(ID, txtCatName.Text, Convert.ToInt32(cbStores.SelectedValue), Convert.ToInt32(txtInventoryAccNo.Text), Convert.ToInt32(txtCatSaleAccNo.Text), Convert.ToInt32(txtCatSaleReturnAccNo.Text), Convert.ToInt32(txtCatSaleVatAccNo.Text), Convert.ToInt32(txtCatSaleDiscountAccNo.Text), Convert.ToInt32(txtCatSaleQtyFreeAccNo.Text), Convert.ToInt32(txtCatSaleCostAccNo.Text), Convert.ToInt32(txtCatSaleRevenuseAccNo.Text), Convert.ToInt32(txtCatPurchaseAccNo.Text), Convert.ToInt32(txtCatPurchaseReturnAccNo.Text), Convert.ToInt32(txtCatPurchaseVatAccNo.Text), Convert.ToInt32(txtCatPurchaseDiscountAccNo.Text), Convert.ToInt32(txtCaPurchaseQtyFreeAccNo.Text));
                MessageBox.Show("تمت عملية التعديل بنجاح", "عملية تعديل", MessageBoxButtons.OK, MessageBoxIcon.Information);
                getAllCategories();
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
                if (MessageBox.Show("هل تريد الحذف", "تنبيه", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes)
                {
                    ci.delCategories(ID, Program.braCode);
                    MessageBox.Show("تمت عملية الحذف بنجاح", "عملية حذف", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    getAllCategories();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void txtInvCode_KeyDown(object sender, KeyEventArgs e)
        {
            PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
            if (e.KeyCode == Keys.Enter)
            {
                fsa.txtSearch.Text = txtInvCode.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtInvCode.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();
                    btnAdd.Focus();
                }
            }
        }

        private void txtInventoryAccNo_KeyDown(object sender, KeyEventArgs e)
        {
            PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
            if (e.KeyCode == Keys.Enter)
            {
                fsa.txtSearch.Text = txtInventoryAccNo.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtInventoryAccNo.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();

                    txtCatSaleDiscountAccNo.Focus();
                }
            }
        }
        private void txtCatSaleDiscountAccNo_KeyDown(object sender, KeyEventArgs e)
        {
            PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
            if (e.KeyCode == Keys.Enter)
            {
                fsa.txtSearch.Text = txtCatSaleDiscountAccNo.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtCatSaleDiscountAccNo.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();

                    txtCatSaleVatAccNo.Focus();
                }
            }
        }

        private void txtCatSaleVatAccNo_KeyDown(object sender, KeyEventArgs e)
        {
            PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
            if (e.KeyCode == Keys.Enter)
            {
                fsa.txtSearch.Text = txtCatSaleVatAccNo.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtCatSaleVatAccNo.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();

                    txtCatSaleQtyFreeAccNo.Focus();
                }
            }
        }

        private void txtCatSaleQtyFreeAccNo_KeyDown(object sender, KeyEventArgs e)
        {
            PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
            if (e.KeyCode == Keys.Enter)
            {
                fsa.txtSearch.Text = txtCatSaleQtyFreeAccNo.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtCatSaleQtyFreeAccNo.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();

                    txtCatSaleAccNo.Focus();
                }
            }
        }

        private void txtCatSaleAccNo_KeyDown(object sender, KeyEventArgs e)
        {
            PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
            if (e.KeyCode == Keys.Enter)
            {
                fsa.txtSearch.Text = txtCatSaleAccNo.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtCatSaleAccNo.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();

                    txtCatSaleReturnAccNo.Focus();
                }
            }
        }

        private void txtCatSaleReturnAccNo_KeyDown(object sender, KeyEventArgs e)
        {
            PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
            if (e.KeyCode == Keys.Enter)
            {
                fsa.txtSearch.Text = txtCatSaleReturnAccNo.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtCatSaleReturnAccNo.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();

                    txtCatSaleCostAccNo.Focus();
                }
            }
        }

        private void txtCatSaleCostAccNo_KeyDown(object sender, KeyEventArgs e)
        {
            PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
            if (e.KeyCode == Keys.Enter)
            {
                fsa.txtSearch.Text = txtCatSaleCostAccNo.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtCatSaleCostAccNo.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();

                    txtCatSaleRevenuseAccNo.Focus();
                }
            }
        }

        private void txtCatSaleRevenuseAccNo_KeyDown(object sender, KeyEventArgs e)
        {
            PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
            if (e.KeyCode == Keys.Enter)
            {
                fsa.txtSearch.Text = txtCatSaleRevenuseAccNo.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtCatSaleRevenuseAccNo.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();

                    txtCatPurchaseDiscountAccNo.Focus();
                }
            }
        }

        private void txtCatPurchaseDiscountAccNo_KeyDown(object sender, KeyEventArgs e)
        {
            PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
            if (e.KeyCode == Keys.Enter)
            {
                fsa.txtSearch.Text = txtCatPurchaseDiscountAccNo.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtCatPurchaseDiscountAccNo.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();

                    txtCatPurchaseVatAccNo.Focus();
                }
            }
        }

        private void txtCatPurchaseVatAccNo_KeyDown(object sender, KeyEventArgs e)
        {
            PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
            if (e.KeyCode == Keys.Enter)
            {
                fsa.txtSearch.Text = txtCatPurchaseVatAccNo.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtCatPurchaseVatAccNo.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();

                    txtCaPurchaseQtyFreeAccNo.Focus();
                }
            }
        }

        private void txtCaPurchaseQtyFreeAccNo_KeyDown(object sender, KeyEventArgs e)
        {
            PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
            if (e.KeyCode == Keys.Enter)
            {
                fsa.txtSearch.Text = txtCaPurchaseQtyFreeAccNo.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtCaPurchaseQtyFreeAccNo.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();

                    txtCatPurchaseAccNo.Focus();
                }
            }
        }

        private void txtCatPurchaseAccNo_KeyDown(object sender, KeyEventArgs e)
        {
            PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
            if (e.KeyCode == Keys.Enter)
            {
                fsa.txtSearch.Text = txtCatPurchaseAccNo.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtCatPurchaseAccNo.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();

                    txtCatPurchaseReturnAccNo.Focus();
                }
            }
        }

        private void txtCatPurchaseReturnAccNo_KeyDown(object sender, KeyEventArgs e)
        {
            PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
            if (e.KeyCode == Keys.Enter)
            {
                fsa.txtSearch.Text = txtCatPurchaseReturnAccNo.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtCatPurchaseReturnAccNo.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();

                    btnAdd.Focus();
                }
            }
        }
    }
}
