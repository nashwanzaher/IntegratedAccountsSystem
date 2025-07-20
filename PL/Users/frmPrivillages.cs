using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace IntegratedAccSys.PL.Users
{
    public partial class frmPrivillages : Form
    {
        BL.Users.clsUsers cu = new BL.Users.clsUsers();

        int userCode = 0;
        int ListID = 0;
        public frmPrivillages()
        {
            InitializeComponent();
        }

        void dgvProperties()
        {
            this.dgvData.ColumnHeadersDefaultCellStyle.ForeColor = Color.Black;
            this.dgvData.ColumnHeadersDefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter;
            this.dgvData.ColumnHeadersDefaultCellStyle.Font = new Font("Times New Roman", 10.75F, FontStyle.Bold);

            this.dgvData.AlternatingRowsDefaultCellStyle.ForeColor = Color.Red;
            this.dgvData.AlternatingRowsDefaultCellStyle.BackColor = Color.SkyBlue;
            this.dgvData.AlternatingRowsDefaultCellStyle.Font = new Font("Times New Roman", 10.75F, FontStyle.Bold);

            this.dgvData.DefaultCellStyle.BackColor = Color.White;
            this.dgvData.DefaultCellStyle.ForeColor = Color.Blue;
            this.dgvData.DefaultCellStyle.Font = new Font("Times New Roman", 10.75F, FontStyle.Bold);

        }

        private void frmPrivillages_Load(object sender, EventArgs e)
        {
            dgvProperties();
            getData();
           
            lbUsers_SelectedIndexChanged(sender, e);
            lbMenus_SelectedIndexChanged(sender, e);
        }

        void getData()
        {
            lbUsers.DataSource = cu.getAllBraUsers(Program.braCode);
            lbUsers.ValueMember = "userCode";
            lbUsers.DisplayMember = "userID";

            lbMenus.DataSource = cu.getAllLists();
            lbMenus.ValueMember = "ID";
            lbMenus.DisplayMember = "ListName";
        }

        private void btnNewUser_Click(object sender, EventArgs e)
        {
            frmUsers fu = new frmUsers();
            fu.ShowDialog();
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }

      
        void showPrivilages()
        {
            try
            {
                int braCode = Program.braCode;
                userCode = Convert.ToInt32(lbUsers.SelectedValue);
                ListID = Convert.ToInt32(lbMenus.SelectedValue);
                DataTable dt = cu.getAllPrivillages(userCode, braCode, ListID);

                if (dt.Rows.Count > 0)
                {
                    dgvData.DataSource = dt;
                }

                dgvData.Columns[0].Visible = false;
                dgvData.Columns[1].Width = 250;
                dgvData.Columns[1].HeaderText = "أسم الشاشة";
                dgvData.Columns[1].ReadOnly = true;
                dgvData.Columns[2].Visible = false;

                dgvData.Columns[3].HeaderText = "جديد";
                dgvData.Columns[4].HeaderText = "حفظ";
                dgvData.Columns[5].HeaderText = "تعديل";
                dgvData.Columns[6].HeaderText = "حذف";
                dgvData.Columns[7].HeaderText = "طباعة";
                dgvData.Columns[8].HeaderText = "عرض";

                
            }
            catch (Exception ex)
            {
                MessageBox.Show("حدث خطأ: " + ex.Message, "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        
        private void lbUsers_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadPrivileges();
        }

        private void lbMenus_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadPrivileges();
        }

        void LoadPrivileges()
        {
            if (lbUsers.SelectedValue is int user && lbMenus.SelectedValue is int list)
            {
                userCode = user;
                ListID = list;
                showPrivilages();
            }
        }

        private void btnSavePrivillages_Click(object sender, EventArgs e)
        {
           try
            {
                int userCode = Convert.ToInt32(lbUsers.SelectedValue);
                for (int i = 0; i < dgvData.Rows.Count; i++)
                {
                    int windowID = Convert.ToInt32(dgvData.Rows[i].Cells[0].Value);
                    bool new_ = dgvData.Rows[i].Cells[3].Value!=DBNull.Value && Convert.ToBoolean(dgvData.Rows[i].Cells[3].Value);
                    bool add = dgvData.Rows[i].Cells[4].Value != DBNull.Value && Convert.ToBoolean(dgvData.Rows[i].Cells[4].Value);
                    bool edit = dgvData.Rows[i].Cells[5].Value != DBNull.Value && Convert.ToBoolean(dgvData.Rows[i].Cells[5].Value);
                    bool del = dgvData.Rows[i].Cells[6].Value != DBNull.Value && Convert.ToBoolean(dgvData.Rows[i].Cells[6].Value);
                    bool print = dgvData.Rows[i].Cells[7].Value != DBNull.Value && Convert.ToBoolean(dgvData.Rows[i].Cells[7].Value);
                    bool display = dgvData.Rows[i].Cells[8].Value != DBNull.Value && Convert.ToBoolean(dgvData.Rows[i].Cells[8].Value);

                    cu.editPrivilege(userCode, windowID, new_, add, edit, del, print, display, Program.braCode);
                   
                }
                MessageBox.Show("تمت عملية حفظ الصلاحيات بنجاح", "حفظ الصلاحيات", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show("حدث خطأ أثناء تعديل الصلاحيات:" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
    }
}
