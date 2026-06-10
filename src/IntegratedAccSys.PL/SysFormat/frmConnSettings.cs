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
    public partial class frmConnSettings : Form
    {
        public frmConnSettings()
        {
            InitializeComponent();
        }

        private void btnNew_Click(object sender, EventArgs e)
        {
            txtMode.Text = string.Empty;
            txtServer.Text = string.Empty;
            txtDB.Text = string.Empty;
            txtID.Text = string.Empty;
            txtPWD.Text = string.Empty;
            txtMode.Focus();
        }

        private void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                Properties.Settings.Default.Mode = txtMode.Text;
                Properties.Settings.Default.Server = txtServer.Text;
                Properties.Settings.Default.DB = txtDB.Text;
                Properties.Settings.Default.ID = txtID.Text;
                Properties.Settings.Default.PWD = txtPWD.Text;
                Properties.Settings.Default.Save();
                MessageBox.Show("تمت عملية الحفظ بنجاح", "عملية الحفظ", MessageBoxButtons.OK, MessageBoxIcon.Information);

            }
            catch (Exception ex)
            {
                MessageBox.Show("نص الخطأ" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Error);

            }
        }

        private void txtDisplay_Click(object sender, EventArgs e)
        {
            try
            {
                txtMode.Text = Properties.Settings.Default.Mode;
                txtServer.Text = Properties.Settings.Default.Server;
                txtDB.Text = Properties.Settings.Default.DB;
                txtID.Text = Properties.Settings.Default.ID;
                txtPWD.Text = Properties.Settings.Default.PWD;
            }
            catch (Exception ex)
            {
                MessageBox.Show("نص الخطأ" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Error);

            }
        }

        private void txtExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}
