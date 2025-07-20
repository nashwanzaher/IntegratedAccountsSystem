using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace IntegratedAccSys.PL.stores
{
    public partial class frmSelectItem : Form
    {
        BL.Stores.clsInventory ci = new BL.Stores.clsInventory();
        public bool isOk = false;
        public frmSelectItem()
        {
            InitializeComponent();
        }

        private void txtSearch_TextChanged(object sender, EventArgs e)
        {
            dgvData.DataSource = ci.getProductData(txtSearch.Text);
            dgvData.Columns[2].Visible= false;
            dgvData.Columns[3].Visible= false;
        }

        private void dgvData_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            isOk = true;
            this.Close();
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}
