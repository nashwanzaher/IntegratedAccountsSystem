using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace IntegratedAccSys.PL.SysFormat
{
    public partial class frmAccountsJoin : Form
    {
        public frmAccountsJoin()
        {
            InitializeComponent();
        }
        void resetData()
        {
            txtInventoryCode.Text = string.Empty;
            txtDiscountRecievedCode.Text = string.Empty;
            txtDiscountAllowedCode.Text = string.Empty;
            txtVatPurchasesCode.Text = string.Empty;
            txtVatSalesCode.Text = string.Empty;
            txtSalesRevenuseCode.Text = string.Empty;
            txtSaleCostCode.Text = string.Empty;
            txtInventoryCode.Focus();
        }
        private void btnNew_Click(object sender, EventArgs e)
        {
            resetData();
        }

        private void txtInventoryCode_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
                fsa.txtSearch.Text = txtInventoryCode.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtInventoryCode.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();
                    txtDiscountRecievedCode.Focus();
                }
            }
        }

        private void txtDiscountRecievedCode_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
                fsa.txtSearch.Text = txtDiscountRecievedCode.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtDiscountRecievedCode.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();
                    txtDiscountAllowedCode.Focus();
                }
            }
        }

        private void txtDiscountAllowedCode_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
                fsa.txtSearch.Text = txtDiscountAllowedCode.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtDiscountAllowedCode.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();
                    txtVatPurchasesCode.Focus();
                }
            }
        }

        private void txtVatPurchasesCode_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
                fsa.txtSearch.Text = txtVatPurchasesCode.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtVatPurchasesCode.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();
                    txtVatSalesCode.Focus();
                }
            }
        }

        private void txtVatSalesCode_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
                fsa.txtSearch.Text = txtVatSalesCode.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtVatSalesCode.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();
                    txtSalesRevenuseCode.Focus();
                }
            }
        }
        void addSettings()
        {
            Properties.Settings.Default.inventoryCode = txtInventoryCode.Text;
            Properties.Settings.Default.discountRecivedCode = txtDiscountRecievedCode.Text;
            Properties.Settings.Default.discountAllowedCode = txtDiscountAllowedCode.Text;
            Properties.Settings.Default.purchasesVatCode = txtVatPurchasesCode.Text;
            Properties.Settings.Default.salesVatCode = txtVatSalesCode.Text;
            Properties.Settings.Default.salesRevenuseCode = txtSalesRevenuseCode.Text;
            Properties.Settings.Default.salesCostCode = txtSaleCostCode.Text;
            Properties.Settings.Default.Save();

        }
        private void btnAdd_Click(object sender, EventArgs e)
        {
            addSettings();
            MessageBox.Show("تمت عملية الحفظ بنجاح", "عملية الحفظ", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private void btnDisplay_Click(object sender, EventArgs e)
        {
            txtInventoryCode.Text = Properties.Settings.Default.inventoryCode;
            txtDiscountRecievedCode.Text = Properties.Settings.Default.discountRecivedCode;
            txtDiscountAllowedCode.Text = Properties.Settings.Default.discountAllowedCode;
            txtVatPurchasesCode.Text = Properties.Settings.Default.purchasesVatCode;
            txtVatSalesCode.Text = Properties.Settings.Default.salesVatCode;
            txtSalesRevenuseCode.Text = Properties.Settings.Default.salesRevenuseCode;
            txtSaleCostCode.Text = Properties.Settings.Default.salesCostCode;
        }

        private void btnWipe_Click(object sender, EventArgs e)
        {
            resetData();
            addSettings();
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void txtSalesRevenuseCode_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
                fsa.txtSearch.Text = txtSalesRevenuseCode.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtSalesRevenuseCode.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();
                    txtSaleCostCode.Focus();
                }
            }
        }

        private void txtSaleCostCode_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
                fsa.txtSearch.Text = txtSaleCostCode.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtSaleCostCode.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();
                    btnAdd.Focus();
                }
            }
        }
    }
}
