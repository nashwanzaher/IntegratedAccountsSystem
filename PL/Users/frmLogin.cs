using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using IntegratedAccSys.BL.Security;

namespace IntegratedAccSys.PL.Users
{
    public partial class frmLogin : Form
    {
        public frmLogin()
        {
            InitializeComponent();
        }

        private void btnLogin_Click(object sender, EventArgs e)
        {
            try
            {
                BL.Users.clsUsers cu = new BL.Users.clsUsers();
                DataTable dt = new DataTable();
                dt.Clear();
                dt = cu.Login(Convert.ToInt32(txtBranch.Text), txtUser.Text, txtPWD.Text);

                if (dt.Rows.Count > 0)
                {
                    int braCode = Convert.ToInt32(txtBranch.Text);
                    string userID = txtUser.Text;
                    int userCode = Convert.ToInt32(dt.Rows[0]["userCode"]);

                    // Set static Program fields (backward compat — DO NOT remove)
                    Program.braCode = braCode;
                    Program.userName = userID;

                    // Phase 7: Create token-based session
                    SessionContext.Create(userCode, userID, braCode);

                    frmMainWindow fmw = new frmMainWindow();
                    fmw.Show();
                    this.Hide();
                }
                else
                {
                    MessageBox.Show("تأكد من ان البيانات التي ادخلتها صحيحة", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(" تعذر الإتصال بالسرفر ", "تعذر الإتصال", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}