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
    public partial class frmBackUps : Form
    {
        BL.SysFormat.clsSysFormat csf = new BL.SysFormat.clsSysFormat();
        public frmBackUps()
        {
            InitializeComponent();
        }

        private void btnEXit_Click(object sender, EventArgs e)
        {
            this.Close();

        }

        private void btnBackUp_Click(object sender, EventArgs e)
        {
            try
            {
                SaveFileDialog sfd = new SaveFileDialog();
                sfd.Filter = "Backup  files(*.Bak)|*.bak";
                if (sfd.ShowDialog() == DialogResult.OK)
                {
                    string databaseName = Properties.Settings.Default.DB;
                    string pathBackup = sfd.FileName;
                    bool isOK = false;
                    isOK=csf.backupDB(databaseName, pathBackup);
                    if (isOK==true)
                    {
                        MessageBox.Show("تم عمل نسخة إحتياطية", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                  

                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("نص الخطأ" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }


        }

        private void btnRestoreDB_Click(object sender, EventArgs e)
        {
            try
            {
                OpenFileDialog ofd = new OpenFileDialog();
                ofd.Filter = "Restore Files(*.bak)|*.bak";
                if (ofd.ShowDialog() == DialogResult.OK)
                {
                    string databaseName = Properties.Settings.Default.DB;
                    string pathBackup = ofd.FileName;
                    bool isOK = false;
                    isOK = csf.restoreDB(databaseName, pathBackup);
                    if (isOK==true)
                    {
                        MessageBox.Show("تم إسترجاع النسخة الإحتياطية بنجاح", "تنبية", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("نص الخطأ" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Error);

            }
        }
    }
}
