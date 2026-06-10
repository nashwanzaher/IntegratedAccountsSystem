using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using IntegratedAccSys.PL.Security;
using Microsoft.Reporting.WinForms;

namespace IntegratedAccSys.PL.Purchases
{
    public partial class frmPurReturnBill : Form
    {
        BL.SysFormat.ClsSysFormat csf = new BL.SysFormat.ClsSysFormat();
        frmSelectSupplier fss = new frmSelectSupplier();
        BL.Stores.ClsInventory ci = new BL.Stores.ClsInventory();
        BL.Journal.ClsJournal cj = new BL.Journal.ClsJournal();
        BL.Users.ClsUsers cu = new BL.Users.ClsUsers();


        double subTotal = 0.00;
        double vat = 0.00;

        int inventoryCode;
        int purAccCode;
        int purReturnAccCode;
        int purDiscAccCode;
        int purQtyFreeAccCode;
        int purVatAccCode;

        public frmPurReturnBill()
        {
            InitializeComponent();
            dgvData.Columns[0].Width = 120;
            dgvData.Columns[1].Width = 300;
            dgvData.Columns[2].Width = 120;
            dgvData.Columns[3].Width = 120;
            dgvData.Columns[4].Width = 120;
            dgvData.Columns[5].Width = 120;
            dgvData.Columns[6].Width = 120;
            dgvData.Columns[7].Width = 120;
            dgvData.Columns[8].Width = 120;
            dgvData.Columns[9].Width = 150;
        }

        void getAllData()
        {
            //get all payment Method
            cbPaymentMethod.DataSource = csf.getAllPaymentMethods();
            cbPaymentMethod.ValueMember = "ID";
            cbPaymentMethod.DisplayMember = "PaymentMethod";

            //get All Stores Data
            cbStores.DataSource = ci.getAllStroes();
            cbStores.ValueMember = "الرقم";
            cbStores.DisplayMember = "إسم المخزن";

            //get all currencies data
            cbCurrencies.DataSource = csf.getAllCurrencies();
            cbCurrencies.ValueMember = "ID";
            cbCurrencies.DisplayMember = "currName";

            //get all units data
            cbUnits.DataSource = ci.getAllUnits();
            cbUnits.ValueMember = "رقم الوحدة";
            cbUnits.DisplayMember = "إسم الوحدة";

            //get all funds data
            cbFunds.DataSource = csf.getAllFunds();
            cbFunds.ValueMember = "fundCode";
            cbFunds.DisplayMember = "fundName";
        }

        private void frmPurReturnBill_Load(object sender, EventArgs e)
        {
            BL.Users.ClsUsers cu = new BL.Users.ClsUsers();
            PrivilegeApplier.Apply(this, 33);

            getAllData();
        }

        private void txtSuppName_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                fss.txtSearch.Text = txtSuppName.Text;
                fss.ShowDialog();
                if (fss.isOk == true)
                {
                    txtSuppCode.Text = fss.dgvData.CurrentRow.Cells[0].Value.ToString();
                    txtSuppName.Text = fss.dgvData.CurrentRow.Cells[1].Value.ToString();
                }
            }
        }

        private void cbCurrencies_SelectedIndexChanged(object sender, EventArgs e)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            dt = csf.getExchangeCurrency(cbCurrencies.Text);
            if (dt.Rows.Count > 0)
            {
                txtCurrVal.Text = dt.Rows[0][2].ToString();
            }
        }

        private void cbUnits_SelectedIndexChanged(object sender, EventArgs e)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            dt = ci.getConversionFactor(cbUnits.Text);
            if (dt.Rows.Count > 0)
            {
                txtConversionFactor.Text = dt.Rows[0][2].ToString();
            }
        }

        private void cbFunds_SelectedIndexChanged(object sender, EventArgs e)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            dt = csf.getFundCode(cbFunds.Text);
            if (dt.Rows.Count > 0)
            {
                txtFundCode.Text = dt.Rows[0][0].ToString();
            }
        }

        private void txtProdCode_KeyDown(object sender, KeyEventArgs e)
        {
            PL.Stores.frmSelectItem fst = new PL.Stores.frmSelectItem();
            if (e.KeyCode == Keys.Enter)
            {
                fst.txtSearch.Text = txtProdCode.Text;
                fst.ShowDialog();
                if (fst.isOk == true)
                {
                    txtProdCode.Text = fst.dgvData.CurrentRow.Cells[0].Value.ToString();
                    txtProdName.Text = fst.dgvData.CurrentRow.Cells[1].Value.ToString();
                    txtPrice.Text = fst.dgvData.CurrentRow.Cells[2].Value.ToString();
                    txtCatID.Text = fst.dgvData.CurrentRow.Cells[3].Value.ToString();
                    txtQty.Focus();
                }
            }
        }

        void resetRow()
        {
            txtProdCode.Text = string.Empty;
            txtProdName.Text = string.Empty;
            txtPrice.Text = "0.00";
            txtQty.Text = "0.00";
            txtDisCount.Text = "0.00";
            txtVAT.Text = "0.00";
            txtTotal.Text = "0.00";
            cbUnits.Text = "إختار وحدة";
            txtCatID.Text = string.Empty;
            txtProdCode.Focus();
        }

        void Total()
        {
            double discountTotal = 0.00;
            double vatTotal = 0.00;
            double billTotal = 0.00;
            double billNetTotal = 0.00;

            for (int i = 0; i < dgvData.Rows.Count; i++)
            {
                discountTotal += Convert.ToDouble(dgvData.Rows[i].Cells[7].Value);
                vatTotal += Convert.ToDouble(dgvData.Rows[i].Cells[8].Value);
                billNetTotal += Convert.ToDouble(dgvData.Rows[i].Cells[9].Value);
                billTotal += (Convert.ToDouble(dgvData.Rows[i].Cells[5].Value) *
                              Convert.ToDouble(dgvData.Rows[i].Cells[6].Value));
            }

            txtAllTotal.Text = billTotal.ToString("0.00");
            txtDiscountTotal.Text = discountTotal.ToString("0.00");
            txtVATTotal.Text = vatTotal.ToString("0.00");
            txtNetTotal.Text = billNetTotal.ToString("0.00");
        }

        void getTotal()
        {
            vat = ((Convert.ToDouble(txtQty.Text) * Convert.ToDouble(txtPrice.Text)) -
                   Convert.ToDouble(txtDisCount.Text)) * Convert.ToDouble(Properties.Settings.Default.VAT) / 100;
            txtVAT.Text = vat.ToString();
            subTotal = (Convert.ToDouble(txtQty.Text) * Convert.ToDouble(txtPrice.Text)) -
                Convert.ToDouble(txtDisCount.Text) + vat;
            txtTotal.Text = subTotal.ToString();
        }

        private void btnInsert_Click(object sender, EventArgs e)
        {
            if (txtProdCode.Text == "")
            {
                MessageBox.Show("يجب إختيار صنف أولاً", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (cbUnits.Text == "إختار وحدة")
            {
                MessageBox.Show("يجب إختيار وحدة أولاً", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (txtQty.Text == "0.00")
            {
                MessageBox.Show("يجب إختيار الكمية المطلوبة أولاً", "تنبيه", MessageBoxButtons.OK,
                    MessageBoxIcon.Warning);
                return;
            }

            if (txtPrice.Text == "0.00")
            {
                MessageBox.Show("يجب تسعير هذا الصنف أولاً", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            DataTable dt = new DataTable();
            dt.Clear();
            dt = ci.getCategoryData(Convert.ToInt32(txtCatID.Text));
            if (dt.Rows.Count > 0)
            {
                inventoryCode = Convert.ToInt32(dt.Rows[0][2]);
                purAccCode = Convert.ToInt32(dt.Rows[0][10]);
                purReturnAccCode = Convert.ToInt32(dt.Rows[0][11]);
                purDiscAccCode = Convert.ToInt32(dt.Rows[0][12]);
                purQtyFreeAccCode = Convert.ToInt32(dt.Rows[0][13]);
                purVatAccCode = Convert.ToInt32(dt.Rows[0][14]);
            }

            for (int i = 0; i < dgvData.Rows.Count; i++)
            {
                if (txtProdCode.Text == dgvData.Rows[i].Cells[0].Value.ToString())
                {
                    MessageBox.Show("لا يمكن تكرار إدخال صنف ", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
            }

            getTotal();
            dgvData.Rows.Add(txtProdCode.Text, txtProdName.Text, cbUnits.SelectedValue, cbUnits.Text,
                txtConversionFactor.Text, txtQty.Text, txtPrice.Text, txtDisCount.Text, txtVAT.Text, txtTotal.Text,
                txtCatID.Text, cbStores.SelectedValue, inventoryCode, purAccCode, purReturnAccCode, purDiscAccCode,
                purQtyFreeAccCode, purVatAccCode);
            resetRow();
        }

        private void txtQty_TextChanged(object sender, EventArgs e)
        {
            getTotal();
        }

        private void txtPrice_TextChanged(object sender, EventArgs e)
        {
            getTotal();
        }

        private void txtDisCount_TextChanged(object sender, EventArgs e)
        {
            getTotal();
        }

        private void txtVAT_TextChanged(object sender, EventArgs e)
        {
            getTotal();
        }

        private void dgvData_RowsAdded(object sender, DataGridViewRowsAddedEventArgs e)
        {
            Total();
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void add_Click(object sender, EventArgs e)
        {
            txtProdCode.Focus();
        }

        private void edit_Click(object sender, EventArgs e)
        {
            txtProdCode.Text = dgvData.CurrentRow.Cells[0].Value.ToString();
            txtProdName.Text = dgvData.CurrentRow.Cells[1].Value.ToString();
            cbUnits.SelectedValue = dgvData.CurrentRow.Cells[2].Value;
            txtConversionFactor.Text = dgvData.CurrentRow.Cells[4].Value.ToString();
            txtQty.Text = dgvData.CurrentRow.Cells[5].Value.ToString();
            txtPrice.Text = dgvData.CurrentRow.Cells[6].Value.ToString();
            txtDisCount.Text = dgvData.CurrentRow.Cells[7].Value.ToString();
            txtVAT.Text = dgvData.CurrentRow.Cells[8].Value.ToString();
            txtTotal.Text = dgvData.CurrentRow.Cells[9].Value.ToString();
            txtCatID.Text = dgvData.CurrentRow.Cells[10].Value.ToString();
            cbStores.SelectedValue = dgvData.CurrentRow.Cells[11].Value;
            dgvData.Rows.RemoveAt(dgvData.CurrentRow.Index);
            Total();
        }

        private void delete_Click(object sender, EventArgs e)
        {
            dgvData.Rows.RemoveAt(dgvData.CurrentRow.Index);
        }

        void resetData()
        {
            txtNo.Text = string.Empty;
            dtpDate.Value = DateTime.Now;
            getAllData();
            txtSuppName.Text = string.Empty;
            txtSuppCode.Text = "0";
            txtNote.Text = string.Empty;
            resetRow();
            dgvData.Rows.Clear();
            txtAllTotal.Text = "0.0000";
            txtDiscountTotal.Text = "0.0000";
            txtVATTotal.Text = "0.0000";
            txtNetTotal.Text = "0.0000";
            txtSaleCost.Text = "0";
        }

        private void btnNew_Click(object sender, EventArgs e)
        {
            resetData();
            txtNo.Text = ci.getBillOrBondNewNo(Convert.ToInt32(txtOpType.Text), Program.braCode).Rows[0][0].ToString();
            txtJNo.Text = cj.getNewJournalNo(Program.braCode).Rows[0][0].ToString();
            txtNote.Focus();
        }

        // function to add data into bonds,bills Header Table
        void addOperationHeader()
        {
            int Post = 0;
            if (chkPost.Checked)
            {
                Post = 1;
            }
            else
            {
                Post = 0;
            }

            int userCode = Convert.ToInt32(cu.getUserNo(Program.userName).Rows[0][0]);
            ci.addOperationHdr(Convert.ToInt32(txtNo.Text), Convert.ToDateTime(dtpDate.Value.ToShortTimeString()),
                Convert.ToInt32(txtOpType.Text), Post, txtNote.Text, 0, 0, Convert.ToInt32(txtSuppCode.Text), userCode,
                DateTime.Now, Program.braCode, Convert.ToInt32(cbPaymentMethod.SelectedValue),
                Convert.ToInt32(txtFundCode.Text), Convert.ToDecimal(txtAllTotal.Text),
                Convert.ToDecimal(txtDiscountTotal.Text), Convert.ToDecimal(txtVATTotal.Text),
                Convert.ToDecimal(txtNetTotal.Text), Convert.ToInt32(txtJNo.Text), 0);
        }

        //function to add data into bonds,bills body table
        void addOperationBody()
        {
            if (dgvData.Rows.Count > 0)
            {
                for (int i = 0; i < dgvData.Rows.Count; i++)
                {
                    int prodCode = Convert.ToInt32(dgvData.Rows[i].Cells[0].Value);
                    int currID = Convert.ToInt32(cbCurrencies.SelectedValue);
                    int unitID = Convert.ToInt32(dgvData.Rows[i].Cells[2].Value);
                    decimal Qty = Convert.ToDecimal(dgvData.Rows[i].Cells[5].Value);
                    decimal price = Convert.ToDecimal(dgvData.Rows[i].Cells[6].Value);
                    decimal discount = Convert.ToDecimal(dgvData.Rows[i].Cells[7].Value);
                    decimal VAT = Convert.ToDecimal(dgvData.Rows[i].Cells[8].Value);
                    int No = Convert.ToInt32(txtNo.Text);
                    decimal currVal = Convert.ToDecimal(txtCurrVal.Text);
                    decimal conversionFactor = Convert.ToDecimal(dgvData.Rows[i].Cells[4].Value);
                    int opType = Convert.ToInt32(txtOpType.Text);
                    ci.addOperationBody(prodCode, currID, unitID, Qty, price, discount, VAT, No, currVal,
                        conversionFactor, opType);
                }
            }
        }

        // function to add data into Inventory Table
        void addProductMovement()
        {
            if (dgvData.Rows.Count > 0)
            {
                for (int i = 0; i < dgvData.Rows.Count; i++)
                {
                    int prodCode = Convert.ToInt32(dgvData.Rows[i].Cells[0].Value);
                    decimal Qty = Convert.ToDecimal(dgvData.Rows[i].Cells[5].Value);
                    decimal price = Convert.ToDecimal(dgvData.Rows[i].Cells[6].Value);
                    decimal conversionFactor = Convert.ToDecimal(dgvData.Rows[i].Cells[4].Value);
                    decimal BaseQty = Qty * conversionFactor;
                    decimal Total = Qty * price;
                    decimal BasePrice = Total / BaseQty;
                    int unitID = Convert.ToInt32(dgvData.Rows[i].Cells[2].Value);
                    int storeID = Convert.ToInt32(dgvData.Rows[i].Cells[11].Value);
                    int catID = Convert.ToInt32(dgvData.Rows[i].Cells[10].Value);
                    DateTime moveDate = Convert.ToDateTime(dtpDate.Value.ToShortDateString());
                    int No = Convert.ToInt32(txtNo.Text);

                    int opType = Convert.ToInt32(txtOpType.Text);
                    ci.addProductMovement(prodCode, BaseQty, BasePrice, unitID, storeID, catID, moveDate, No,
                        conversionFactor, opType);
                }
            }
        }

        //void addProductMovement()
        //{
        //    if (dgvData.Rows.Count > 0)
        //    {
        //        for (int i = 0; i < dgvData.Rows.Count; i++)
        //        {
        //            int prodCode = Convert.ToInt32(dgvData.Rows[i].Cells[0].Value);
        //            decimal Qty = Convert.ToDecimal(dgvData.Rows[i].Cells[5].Value);
        //            decimal price = Convert.ToDecimal(dgvData.Rows[i].Cells[6].Value);
        //            int unitID = Convert.ToInt32(dgvData.Rows[i].Cells[2].Value);
        //            int storeID = Convert.ToInt32(dgvData.Rows[i].Cells[11].Value);
        //            int catID = Convert.ToInt32(dgvData.Rows[i].Cells[10].Value);
        //            DateTime moveDate = Convert.ToDateTime(dtpDate.Value.ToShortDateString());
        //            int No = Convert.ToInt32(txtNo.Text);
        //            decimal conversionFactor = Convert.ToDecimal(dgvData.Rows[i].Cells[4].Value);
        //            int opType = Convert.ToInt32(txtOpType.Text);

        //            // ✅ تحويل الكمية إلى الوحدة الأساسية
        //            decimal baseQty = Qty * conversionFactor;

        //            // ✅ تحويل السعر إلى الوحدة الأساسية
        //            decimal basePrice = price / conversionFactor;

        //            // ✅ إدخال القيم المحولة للوحدة الأساسية في قاعدة البيانات
        //            ci.addProductMovement(prodCode, baseQty, basePrice, unitID, storeID, catID, moveDate, No, conversionFactor, opType);
        //        }
        //    }
        //}

        // function to update data in  products Table
        void updateProductData()
        {
            if (dgvData.Rows.Count > 0)
            {
                for (int i = 0; i < dgvData.Rows.Count; i++)
                {
                    int prodCode = Convert.ToInt32(dgvData.Rows[i].Cells[0].Value);
                    decimal Qty = Convert.ToDecimal(dgvData.Rows[i].Cells[5].Value);
                    int opType = Convert.ToInt32(txtOpType.Text);
                    ci.updateProductData(prodCode, Qty, opType);
                }
            }
        }

        //function to add data into Journal header table
        void addJournalHeader()
        {
            int jType = 1;
            int jPost = 0;

            int userCode = Convert.ToInt32(cu.getUserNo(Program.userName).Rows[0][0]);
            DateTime jDate = DateTime.Now;
            cj.addJournalHeader(Convert.ToInt32(txtJNo.Text), Convert.ToDateTime(dtpDate.Value.ToShortDateString()),
                txtNote.Text, jType, jPost, Convert.ToDouble(txtNetTotal.Text), Convert.ToDouble(txtNetTotal.Text), 0,
                userCode, jDate, Program.braCode, Convert.ToInt32(txtOpType.Text));
        }

        //funtion to add data into journal body table
        //void addJournalBody()
        //{
        //    double InventoryAmount = Convert.ToDouble(txtAllTotal.Text) / Convert.ToDouble(txtCurrVal.Text);
        //    double PurcahaseVATAmount = Convert.ToDouble(txtVATTotal.Text) / Convert.ToDouble(txtCurrVal.Text);
        //    double FundAmount = Convert.ToDouble(txtNetTotal.Text) / Convert.ToDouble(txtCurrVal.Text);
        //    double SuppAmount = Convert.ToDouble(txtNetTotal.Text) / Convert.ToDouble(txtCurrVal.Text);
        //    double discountAmount = Convert.ToDouble(txtDiscountTotal.Text) / Convert.ToDouble(txtCurrVal.Text);

        //    if (txtOpType.Text == "5")
        //    {

        //        if (cbPaymentMethod.Text.Trim() == "نقداً")
        //        {
        //            //               من ح / المخزون
        //            //  ح / ضريبة القيمة المضافة

        //            cj.addJournalBody(Convert.ToInt32(Properties.Settings.Default.inventoryCode), Convert.ToInt32(cbCurrencies.SelectedValue), Convert.ToDouble(txtCurrVal.Text), InventoryAmount, 0, txtNote.Text, Convert.ToInt32(txtJNo.Text));
        //            if (Convert.ToDouble(txtVATTotal.Text) > 0)
        //            {
        //                cj.addJournalBody(Convert.ToInt32(Properties.Settings.Default.purchasesVatCode), Convert.ToInt32(cbCurrencies.SelectedValue), Convert.ToDouble(txtCurrVal.Text), PurcahaseVATAmount, 0, txtNote.Text, Convert.ToInt32(txtJNo.Text));

        //            }

        //            //              إلى ح / الصندوق
        //            //         ح / الخصم الكتسب
        //            cj.addJournalBody(Convert.ToInt32(txtFundCode.Text), Convert.ToInt32(cbCurrencies.SelectedValue), Convert.ToDouble(txtCurrVal.Text), 0, FundAmount, txtNote.Text, Convert.ToInt32(txtJNo.Text));
        //            if (Convert.ToDouble(txtDiscountTotal.Text) > 0)
        //            {
        //                cj.addJournalBody(Convert.ToInt32(Properties.Settings.Default.discountRecivedCode), Convert.ToInt32(cbCurrencies.SelectedValue), Convert.ToDouble(txtCurrVal.Text), 0, discountAmount, txtNote.Text, Convert.ToInt32(txtJNo.Text));

        //            }

        //        }
        //        if (cbPaymentMethod.Text.Trim() == "آجل")
        //        {
        //            //               من ح / المخزون
        //            //  ح / ضريبة القيمة المضافة

        //            cj.addJournalBody(Convert.ToInt32(Properties.Settings.Default.inventoryCode), Convert.ToInt32(cbCurrencies.SelectedValue), Convert.ToDouble(txtCurrVal.Text), InventoryAmount, 0, txtNote.Text, Convert.ToInt32(txtJNo.Text));
        //            if (Convert.ToDouble(txtVATTotal.Text) > 0)
        //            {
        //                cj.addJournalBody(Convert.ToInt32(Properties.Settings.Default.purchasesVatCode), Convert.ToInt32(cbCurrencies.SelectedValue), Convert.ToDouble(txtCurrVal.Text), PurcahaseVATAmount, 0, txtNote.Text, Convert.ToInt32(txtJNo.Text));

        //            }
        //            //               إلى ح / المورد
        //            //         ح / الخصم الكتسب
        //            cj.addJournalBody(Convert.ToInt32(txtSuppCode.Text), Convert.ToInt32(cbCurrencies.SelectedValue), Convert.ToDouble(txtCurrVal.Text), 0, SuppAmount, txtNote.Text, Convert.ToInt32(txtJNo.Text));
        //            if (Convert.ToDouble(txtDiscountTotal.Text) > 0)
        //            {
        //                cj.addJournalBody(Convert.ToInt32(Properties.Settings.Default.discountRecivedCode), Convert.ToInt32(cbCurrencies.SelectedValue), Convert.ToDouble(txtCurrVal.Text), 0, discountAmount, txtNote.Text, Convert.ToInt32(txtJNo.Text));

        //            }
        //        }

        //    }

        //    if (txtOpType.Text == "6")
        //    {
        //        if (cbPaymentMethod.Text.Trim() == "نقداً")
        //        {
        //            //        من ح/ المخزون
        //            //ح / القيمة المضافة

        //            cj.addJournalBody(Convert.ToInt32(Properties.Settings.Default.inventoryCode), Convert.ToInt32(cbCurrencies.SelectedValue), Convert.ToDouble(txtCurrVal.Text), InventoryAmount, 0, txtNote.Text, Convert.ToInt32(txtJNo.Text));
        //            if (Convert.ToDouble(txtVATTotal.Text) > 0)
        //            {
        //                cj.addJournalBody(Convert.ToInt32(Properties.Settings.Default.purchasesVatCode), Convert.ToInt32(cbCurrencies.SelectedValue), Convert.ToDouble(txtCurrVal.Text), PurcahaseVATAmount, 0, txtNote.Text, Convert.ToInt32(txtJNo.Text));

        //            }
        //            //       إلى ح  الصندوق
        //            cj.addJournalBody(Convert.ToInt32(txtFundCode.Text), Convert.ToInt32(cbCurrencies.SelectedValue), Convert.ToDouble(txtCurrVal.Text), 0, FundAmount, txtNote.Text, Convert.ToInt32(txtJNo.Text));
        //        }
        //        if (cbPaymentMethod.Text.Trim() == "آجل")
        //        {
        //            //        من ح/ المخزون
        //            //ح / القيمة المضافة

        //            cj.addJournalBody(Convert.ToInt32(Properties.Settings.Default.inventoryCode), Convert.ToInt32(cbCurrencies.SelectedValue), Convert.ToDouble(txtCurrVal.Text), InventoryAmount, 0, txtNote.Text, Convert.ToInt32(txtJNo.Text));
        //            if (Convert.ToDouble(txtVATTotal.Text) > 0)
        //            {
        //                cj.addJournalBody(Convert.ToInt32(Properties.Settings.Default.purchasesVatCode), Convert.ToInt32(cbCurrencies.SelectedValue), Convert.ToDouble(txtCurrVal.Text), PurcahaseVATAmount, 0, txtNote.Text, Convert.ToInt32(txtJNo.Text));

        //            }
        //            //        إلى ح / المورد
        //            cj.addJournalBody(Convert.ToInt32(txtSuppCode.Text), Convert.ToInt32(cbCurrencies.SelectedValue), Convert.ToDouble(txtCurrVal.Text), 0, SuppAmount, txtNote.Text, Convert.ToInt32(txtJNo.Text));
        //        }
        //    }

        //}

        private void addJournalBody()
        {
            // القاموس لتجميع البيانات حسب رقم المجموعة
            Dictionary<int, double[]> groupedData = new Dictionary<int, double[]>();

            foreach (DataGridViewRow row in dgvData.Rows)
            {
                if (row.IsNewRow)
                    continue;

                int groupId = Convert.ToInt32(row.Cells["CatNo"].Value);
                double qty = Convert.ToDouble(row.Cells["Qty"].Value);
                double price = Convert.ToDouble(row.Cells["Price"].Value);
                double discount = Convert.ToDouble(row.Cells["discount"].Value);
                double vat = Convert.ToDouble(row.Cells["VATT"].Value);
                double total = Convert.ToDouble(row.Cells["TotalNet"].Value);

                if (!groupedData.ContainsKey(groupId))
                    groupedData[groupId] = new double[5];

                groupedData[groupId][0] += qty;
                groupedData[groupId][1] += qty * price;
                groupedData[groupId][2] += discount;
                groupedData[groupId][3] += vat;
                groupedData[groupId][4] += total;
            }

            // بيانات عامة
            int currencyId = Convert.ToInt32(cbCurrencies.SelectedValue);
            double currencyRate = Convert.ToDouble(txtCurrVal.Text);
            int journalNo = Convert.ToInt32(txtJNo.Text);
            string note = txtNote.Text;

            // مجاميع للتحقق من التوازن
            double totalDebit = 0;
            double totalCredit = 0;

            foreach (var item in groupedData)
            {
                int groupId = item.Key;
                double[] values = item.Value;

                double qtyTotal = values[0];
                double totalPrice = values[1];
                double totalDiscount = values[2];
                double totalVAT = values[3];
                double grandTotal = values[4]; // إجمالي الفاتورة النهائية مع الضريبة وبدون الخصم
                double net = totalPrice - totalDiscount;

                // جلب الحسابات الخاصة بالمجموعة
                DataTable dt = ci.getCategoryData(groupId);
                if (dt.Rows.Count == 0)
                {
                    MessageBox.Show($"لم يتم العثور على حسابات للمجموعة {groupId}");
                    continue;
                }

                int purAccCode = Convert.ToInt32(dt.Rows[0][10]); // حساب المشتريات
                int purDiscAccCode = Convert.ToInt32(dt.Rows[0][12]); // حساب الخصم
                int purVatAccCode = Convert.ToInt32(dt.Rows[0][14]); // حساب الضريبة
                int inventoryAccCode = Convert.ToInt32(dt.Rows[0][2]); // حساب المخزون


                // الطرف المدين
                // المورد أو الصندوق
                int creditAccount = cbPaymentMethod.Text.Trim() == "نقداً"
                    ? Convert.ToInt32(txtFundCode.Text)
                    : Convert.ToInt32(txtSuppCode.Text);

                double creditAmount = grandTotal - totalDiscount;

                cj.addJournalBody(creditAccount, currencyId, currencyRate, creditAmount, 0, note, journalNo);
                totalDebit += creditAmount;

                if (totalDiscount > 0)
                {
                    cj.addJournalBody(purDiscAccCode, currencyId, currencyRate, totalDiscount, 0, note, journalNo);
                    totalDebit += totalDiscount;
                }


                // الطرف الدائن
                cj.addJournalBody(inventoryAccCode, currencyId, currencyRate, 0, net, note, journalNo);
                totalCredit += net;

                if (totalVAT > 0)
                {
                    cj.addJournalBody(purVatAccCode, currencyId, currencyRate, 0, totalVAT, note, journalNo);
                    totalCredit += totalVAT;
                }
            }

            // التحقق من التوازن
            if (Math.Round(totalDebit, 2) != Math.Round(totalCredit, 2))
            {
                MessageBox.Show($"⚠️ القيد غير متوازن! المدين = {totalDebit}, الدائن = {totalCredit}", "تنبيه",
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
            else
            {
                MessageBox.Show("✅ تم إضافة القيود بنجاح والقيد متوازن.", "نجاح", MessageBoxButtons.OK,
                    MessageBoxIcon.Information);
            }
        }

        private void btnAdd_Click(object sender, EventArgs e)
        {
            try
            {
                if (dgvData.RowCount == 0)
                {
                    MessageBox.Show("يجب إختيار الأصناف اولا", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                addOperationHeader();
                addOperationBody();
                addProductMovement();
                updateProductData();
                if (Convert.ToInt32(txtOpType.Text) == 5)
                {
                    addJournalHeader();
                    addJournalBody();
                }

                MessageBox.Show("تمت عملية الحفظ بنجاح", "عملية الحفظ", MessageBoxButtons.OK,
                    MessageBoxIcon.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        void editBillBondHeader()
        {
            int Post = 0;
            if (chkPost.Checked)
            {
                Post = 1;
            }
            else
            {
                Post = 0;
            }

            int userCode = Convert.ToInt32(cu.getUserNo(Program.userName).Rows[0][0]);
            ci.editBillBondHeader(Convert.ToInt32(txtNo.Text), Convert.ToDateTime(dtpDate.Value.ToShortTimeString()),
                Convert.ToInt32(txtOpType.Text), Post, txtNote.Text, 0, 0, Convert.ToInt32(txtSuppCode.Text), userCode,
                DateTime.Now, Program.braCode, Convert.ToInt32(cbPaymentMethod.SelectedValue),
                Convert.ToInt32(txtFundCode.Text), Convert.ToDecimal(txtAllTotal.Text),
                Convert.ToDecimal(txtDiscountTotal.Text), Convert.ToDecimal(txtVATTotal.Text),
                Convert.ToDecimal(txtNetTotal.Text), Convert.ToInt32(txtJNo.Text), Convert.ToDouble(txtSaleCost.Text));
        }

        void deleteBillBondBody()
        {
            for (int i = 0; i < dgvData.Rows.Count; i++)
            {
                int No = Convert.ToInt32(txtNo.Text);
                int opTypeNo = Convert.ToInt32(txtOpType.Text);
                int proCode = Convert.ToInt32(dgvData.Rows[i].Cells[0].Value);
                decimal Qty = Convert.ToDecimal(dgvData.Rows[i].Cells[5].Value);
                decimal price = Convert.ToDecimal(dgvData.Rows[i].Cells[6].Value);
                int unitID = Convert.ToInt32(dgvData.Rows[i].Cells[2].Value);
                int storeID = Convert.ToInt32(dgvData.Rows[i].Cells[11].Value);
                int catID = Convert.ToInt32(dgvData.Rows[i].Cells[10].Value);
                DateTime moveDate = Convert.ToDateTime(dtpDate.Value.ToShortDateString());
                decimal conversionFactor = Convert.ToDecimal(dgvData.Rows[i].Cells[4].Value);

                ci.deleteBillbondbody(No, opTypeNo, proCode, Qty, price, unitID, storeID, catID, moveDate,
                    conversionFactor);
            }
        }

        private void brnEdit_Click(object sender, EventArgs e)
        {
            try
            {
                //edit data in  Bill or Bond table Header
                editBillBondHeader();
                //delete data of  Bill or Bond table body
                deleteBillBondBody();
                //delete journal entery
                if (Convert.ToInt32(txtOpType.Text) == 5)
                {
                    cj.delJournalEntry(Convert.ToInt32(txtJNo.Text), Program.braCode);
                }

                //add data into  Bill or Bond table body
                addOperationBody();
                //update Qty in Products Table
                updateProductData();
                //add movement into Inventory Table
                addProductMovement();
                //add journal entery
                if (Convert.ToInt32(txtOpType.Text) == 5)
                {
                    addJournalHeader();
                    addJournalBody();
                }

                MessageBox.Show("نمت عملية التعديل بنجاح", "عملية تعديل", MessageBoxButtons.OK,
                    MessageBoxIcon.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        void deleteBillBondHeader()
        {
            for (int i = 0; i < dgvData.Rows.Count; i++)
            {
                int No = Convert.ToInt32(txtNo.Text);
                int opTypeNo = Convert.ToInt32(txtOpType.Text);
                int proCode = Convert.ToInt32(dgvData.Rows[i].Cells[0].Value);
                decimal Qty = Convert.ToDecimal(dgvData.Rows[i].Cells[5].Value);
                decimal price = Convert.ToDecimal(dgvData.Rows[i].Cells[6].Value);
                int unitID = Convert.ToInt32(dgvData.Rows[i].Cells[2].Value);
                int storeID = Convert.ToInt32(dgvData.Rows[i].Cells[11].Value);
                int catID = Convert.ToInt32(dgvData.Rows[i].Cells[10].Value);
                DateTime moveDate = Convert.ToDateTime(dtpDate.Value.ToShortDateString());
                decimal conversionFactor = Convert.ToDecimal(dgvData.Rows[i].Cells[4].Value);

                ci.deleteBillbondHeader(No, opTypeNo, proCode, Qty, price, unitID, storeID, catID, moveDate,
                    conversionFactor);
            }
        }

        private void btnDel_Click(object sender, EventArgs e)
        {
            try
            {
                if (MessageBox.Show("هل انت متأكد من أنك تريد حذف الفاتورة او السند", "تنبيه", MessageBoxButtons.YesNo,
                        MessageBoxIcon.Warning) == DialogResult.Yes)
                {
                    if (Convert.ToInt32(txtOpType.Text) == 5)
                    {
                        cj.delJournalEntry(Convert.ToInt32(txtJNo.Text), Program.braCode);
                    }

                    deleteBillBondHeader();
                    MessageBox.Show("تمت عملية الحذف بنجاح", "عملية الحذف", MessageBoxButtons.OK,
                        MessageBoxIcon.Information);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }


        // function  to  show data of bill or bond  Header
        void showBillBondHeader()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            dt = ci.showBillBondHeader(Convert.ToInt32(txtBNo.Text), Convert.ToInt32(txtOpType.Text));
            if (dt.Rows.Count > 0)
            {
                txtNo.Text = dt.Rows[0][0].ToString();
                dtpDate.Text = dt.Rows[0][1].ToString();
                txtOpType.Text = dt.Rows[0][2].ToString();
                if (Convert.ToInt32(dt.Rows[0][3]) == 1)
                {
                    chkPost.Checked = true;
                }
                else
                {
                    chkPost.Checked = false;
                }

                txtNote.Text = dt.Rows[0][4].ToString();
                txtSuppCode.Text = dt.Rows[0][5].ToString();
                txtSuppName.Text = dt.Rows[0][6].ToString();
                cbPaymentMethod.Text = dt.Rows[0][15].ToString();
                txtFundCode.Text = dt.Rows[0][16].ToString();
                cbFunds.Text = dt.Rows[0][17].ToString();

                //Totals
                txtAllTotal.Text = dt.Rows[0][18].ToString();
                txtDiscountTotal.Text = dt.Rows[0][19].ToString();
                txtVATTotal.Text = dt.Rows[0][20].ToString();
                txtNetTotal.Text = dt.Rows[0][21].ToString();

                txtJNo.Text = dt.Rows[0][22].ToString();
                if (txtOpType.Text == "5")
                {
                    txtSaleCost.Text = dt.Rows[0][23].ToString();
                }
                else
                {
                    txtSaleCost.Text = "0";
                }
            }
            else
            {
                MessageBox.Show("لا توجد الفاتورة التي تبحث عنها", "تنبيه", MessageBoxButtons.OK,
                    MessageBoxIcon.Warning);
            }
        }

        // function  to  show data of bill or bond Body
        void showBillBondBody()
        {
            DataTable dt = new DataTable();
            dt.Clear();
            dt = ci.showBillBondBody(Convert.ToInt32(txtNo.Text), Convert.ToInt32(txtOpType.Text));

            if (dt.Rows.Count > 0)
            {
                cbCurrencies.Text = dt.Rows[0][6].ToString();
                txtCurrVal.Text = dt.Rows[0][14].ToString();
                cbStores.Text = dt.Rows[0][3].ToString();

                dgvData.Rows.Clear();
                int i = 0;
                dgvData.RowCount = dt.Rows.Count;
                for (int j = 0; j < dt.Rows.Count; j++)
                {
                    dgvData.Rows[i].Cells[0].Value = dt.Rows[j][0].ToString();
                    dgvData.Rows[i].Cells[1].Value = dt.Rows[j][1].ToString();
                    dgvData.Rows[i].Cells[2].Value = dt.Rows[j][7].ToString();
                    dgvData.Rows[i].Cells[3].Value = dt.Rows[j][8].ToString();
                    dgvData.Rows[i].Cells[4].Value = dt.Rows[j][15].ToString();
                    dgvData.Rows[i].Cells[5].Value = dt.Rows[j][9].ToString(); //Qty
                    dgvData.Rows[i].Cells[6].Value = dt.Rows[j][10].ToString(); //Price
                    dgvData.Rows[i].Cells[7].Value = dt.Rows[j][11].ToString(); //Discount
                    dgvData.Rows[i].Cells[8].Value = dt.Rows[j][12].ToString(); //VAT
                    dgvData.Rows[i].Cells[9].Value = Convert.ToDouble(dt.Rows[j][9].ToString()) *
                                                     Convert.ToDouble(dt.Rows[j][10].ToString());
                    dgvData.Rows[i].Cells[10].Value = dt.Rows[j][4].ToString();
                    dgvData.Rows[i].Cells[11].Value = dt.Rows[j][2].ToString();
                    i++;
                }

                Total();
            }
        }

        private void txtBNo_TextChanged(object sender, EventArgs e)
        {
            try
            {
                resetData();
                showBillBondHeader();
                showBillBondBody();
            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void btnSearch_Click(object sender, EventArgs e)
        {
            txtBNo.Text = txtSearch.Text;
        }

        private void btnFirst_Click(object sender, EventArgs e)
        {
            txtBNo.Text = ci.getMinimumBillBondNo(Convert.ToInt32(txtOpType.Text)).Rows[0][0].ToString();
        }

        private void btnLast_Click(object sender, EventArgs e)
        {
            txtBNo.Text = ci.getMaximumBillBondNo(Convert.ToInt32(txtOpType.Text)).Rows[0][0].ToString();
        }

        private void btnPrev_Click(object sender, EventArgs e)
        {
            int isMin = Convert.ToInt32(ci.getMinimumBillBondNo(Convert.ToInt32(txtOpType.Text)).Rows[0][0].ToString());
            if (Convert.ToInt32(txtBNo.Text) == isMin)
            {
                MessageBox.Show("هذا هو أصغر رقم ", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }
            else
            {
                txtBNo.Text = (Convert.ToInt32(txtBNo.Text) - 1).ToString();
            }
        }

        private void btnNext_Click(object sender, EventArgs e)
        {
            int isMax = Convert.ToInt32(ci.getMaximumBillBondNo(Convert.ToInt32(txtOpType.Text)).Rows[0][0].ToString());
            if (Convert.ToInt32(txtBNo.Text) == isMax)
            {
                MessageBox.Show("هذا هو أكبر رقم ", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }
            else
            {
                txtBNo.Text = (Convert.ToInt32(txtBNo.Text) + 1).ToString();
            }
        }

        private void txtProdCode_Leave(object sender, EventArgs e)
        {
            if (txtProdCode.Text != string.Empty)
            {
                DataTable dt = new DataTable();
                dt.Clear();
                dt = ci.getProductData(txtProdCode.Text);
                if (dt.Rows.Count > 0)
                {
                    txtProdCode.Text = dt.Rows[0][0].ToString();
                    txtProdName.Text = dt.Rows[0][1].ToString();
                    txtPrice.Text = dt.Rows[0][2].ToString();
                    txtCatID.Text = dt.Rows[0][3].ToString();
                }
                else
                {
                    MessageBox.Show("هذا الصنف غير موجود", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
            }
        }

        private void cbPaymentMethod_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (cbPaymentMethod.Text.Trim() == "نقداً")
            {
                lblFund.Visible = true;
                cbFunds.Visible = true;
                txtFundCode.Visible = false;

                lblSupp.Visible = false;
                txtSuppName.Visible = false;
                txtSuppCode.Visible = false;
            }

            if (cbPaymentMethod.Text.Trim() == "آجل")
            {
                lblFund.Visible = false;
                cbFunds.Visible = false;
                txtFundCode.Visible = false;

                lblSupp.Visible = true;
                txtSuppName.Visible = true;
                txtSuppCode.Visible = false;
            }
        }

        private void btnPrint_Click(object sender, EventArgs e)
        {
            int opType = Convert.ToInt32(txtOpType.Text);
            List<ReportDataSource> dataSource = new List<ReportDataSource>
            {
                new ReportDataSource("dsBranchData", csf.getBranchData(Program.braCode)),
                new ReportDataSource("dsShowBillBondHeader",
                    ci.showBillBondHeader(Convert.ToInt32(txtNo.Text), opType)),
                new ReportDataSource("dsShowBillBondBody", ci.showBillBondBody(Convert.ToInt32(txtNo.Text), opType)),
            };
            string reportTitle = "";
            reportTitle = "فاتورة مرتجع مشتريات";


            IntegratedAccSys.Reports.frmReportViewer frv =
                new IntegratedAccSys.Reports.frmReportViewer("rptBillBond.rdlc", dataSource, reportTitle);
            frv.ShowDialog();
        }
    }
}
