using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

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
                DataTable dt=new DataTable();
                dt.Clear();
                dt = cu.Login(Convert.ToInt32(txtBranch.Text),txtUser.Text,txtPWD.Text);
                if (dt.Rows.Count > 0)
                {
                    Program.braCode =Convert.ToInt32(txtBranch.Text);
                    Program.userName = txtUser.Text;
                    frmMainWindow fmw=new frmMainWindow();
                    fmw.Show();
                    this.Hide();
                }
                else
                {
                    MessageBox.Show("تأكد من ان البيانات التي ادخلتها صحيحة" , "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    
                }
            }
            catch 
            {
                MessageBox.Show(" تعذر الإتصال بالسرفر ","تعذر الإتصال",MessageBoxButtons.OK,MessageBoxIcon.Error);           
            }
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}
