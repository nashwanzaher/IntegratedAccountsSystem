using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace IntegratedAccSys.PL.Purchases
{
    public partial class frmSelectSupplier : Form
    {

        public  bool isOk = false;
        BL.Purchases.clsPurchases cp = new BL.Purchases.clsPurchases();
        public frmSelectSupplier()
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

        private void frmSelectSupplier_Load(object sender, EventArgs e)
        {
            dgvProperties();

        }

        void searchInSuppliers()
        {
            dgvData.DataSource = cp.searchInSuppliers(txtSearch.Text, Program.braCode);
        }

        private void txtSearch_TextChanged(object sender, EventArgs e)
        {
            searchInSuppliers();
        }

        private void dgvData_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            isOk = true;
            this.Close();
        }
    }
}
