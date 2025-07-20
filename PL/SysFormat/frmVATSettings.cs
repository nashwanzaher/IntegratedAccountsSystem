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
    public partial class frmVATSettings : Form
    {
        public frmVATSettings()
        {
            InitializeComponent();
        }

        private void btnNew_Click(object sender, EventArgs e)
        {
            txtTaxPresenetage.Enabled = true;
            txtTaxPresenetage.Focus();
        }

        private void btnSave_Click(object sender, EventArgs e)
        {
            Properties.Settings.Default.VAT = txtTaxPresenetage.Text;
            Properties.Settings.Default.Save();
            MessageBox.Show("تمت عملية الحفظ بنجاح","عملية حفظ",MessageBoxButtons.OK,MessageBoxIcon.Information);

        }

        private void btnWipe_Click(object sender, EventArgs e)
        {
            Properties.Settings.Default.VAT = "";
            Properties.Settings.Default.Save();
            txtTaxPresenetage.Text = string.Empty;
            txtTaxPresenetage.Enabled = false;
            MessageBox.Show("تمت عملية الحذف بنجاح", "عملية حذف", MessageBoxButtons.OK, MessageBoxIcon.Information);

        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void btnDisplay_Click(object sender, EventArgs e)
        {
            txtTaxPresenetage.Text = Properties.Settings.Default.VAT;
        }
    }
}
