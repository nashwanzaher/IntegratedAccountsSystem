using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace IntegratedAccSys.PL.Sales
{
    public partial class frmSelectCusromer : Form
    {
        BL.Sales.clsSales cs = new BL.Sales.clsSales();
        public bool isOk = false;
        public frmSelectCusromer()
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

            // تنسيق خلايا البيانات
            dgvData.DefaultCellStyle.BackColor = Color.White;
            dgvData.DefaultCellStyle.ForeColor = Color.Blue;
            dgvData.DefaultCellStyle.Font = new Font("Times New Roman", 10.75F, FontStyle.Bold);
        }

        private void frmSelectCusromer_Load(object sender, EventArgs e)
        {
            dgvProperties();
        }
        void searchInCustomers()
        {
            dgvData.DataSource = cs.searchInCustomers(txtSearch.Text, Program.braCode);
        }

        private void txtSearch_TextChanged(object sender, EventArgs e)
        {
            searchInCustomers();
        }

        private void dgvData_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            isOk = true;
            this.Close();
        }
    }
}
