namespace IntegratedAccSys.PL.Sales
{
    partial class frmSaleReturnBill
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmSaleReturnBill));
            DataGridViewCellStyle dataGridViewCellStyle1 = new DataGridViewCellStyle();
            DataGridViewCellStyle dataGridViewCellStyle2 = new DataGridViewCellStyle();
            DataGridViewCellStyle dataGridViewCellStyle3 = new DataGridViewCellStyle();
            label23 = new Label();
            label22 = new Label();
            label21 = new Label();
            label20 = new Label();
            chkPost = new CheckBox();
            txtDiscountTotal = new TextBox();
            txtAllTotal = new TextBox();
            txtOpType = new TextBox();
            delete = new ToolStripMenuItem();
            btnExit = new Button();
            btnPrint = new Button();
            btnDel = new Button();
            txtDebitLimit = new TextBox();
            btnSearch = new Button();
            txtVATTotal = new TextBox();
            txtSearch = new TextBox();
            label10 = new Label();
            txtBNo = new TextBox();
            btnPrev = new Button();
            cbFunds = new ComboBox();
            label3 = new Label();
            txtSaleCost = new TextBox();
            btnAdd = new Button();
            txtFundCode = new TextBox();
            btnNext = new Button();
            btnFirst = new Button();
            btnLast = new Button();
            brnEdit = new Button();
            btnNew = new Button();
            txtJNo = new TextBox();
            cbStores = new ComboBox();
            txtNote = new TextBox();
            txtCustName = new TextBox();
            lblFund = new Label();
            txtCustCode = new TextBox();
            cbPaymentMethod = new ComboBox();
            txtCurrVal = new TextBox();
            cbCurrencies = new ComboBox();
            dtpDate = new DateTimePicker();
            txtNo = new TextBox();
            label9 = new Label();
            label8 = new Label();
            lblCust = new Label();
            label4 = new Label();
            label2 = new Label();
            groupBox4 = new GroupBox();
            groupBox1 = new GroupBox();
            label5 = new Label();
            label1 = new Label();
            edit = new ToolStripMenuItem();
            txtNetTotal = new TextBox();
            txtCatID = new TextBox();
            btnInsert = new Button();
            txtTotal = new TextBox();
            txtVAT = new TextBox();
            txtDisCount = new TextBox();
            txtPrice = new TextBox();
            txtQty = new TextBox();
            txtConversionFactor = new TextBox();
            cbUnits = new ComboBox();
            txtProdName = new TextBox();
            txtProdCode = new TextBox();
            label18 = new Label();
            label17 = new Label();
            label16 = new Label();
            label15 = new Label();
            lblQty = new Label();
            label14 = new Label();
            label13 = new Label();
            label12 = new Label();
            label11 = new Label();
            groupBox2 = new GroupBox();
            groupBox3 = new GroupBox();
            dgvData = new DataGridView();
            Column1 = new DataGridViewTextBoxColumn();
            Column2 = new DataGridViewTextBoxColumn();
            Column3 = new DataGridViewTextBoxColumn();
            Column4 = new DataGridViewTextBoxColumn();
            Column5 = new DataGridViewTextBoxColumn();
            Qty = new DataGridViewTextBoxColumn();
            Price = new DataGridViewTextBoxColumn();
            Discount = new DataGridViewTextBoxColumn();
            VATT = new DataGridViewTextBoxColumn();
            TotalNet = new DataGridViewTextBoxColumn();
            CatNo = new DataGridViewTextBoxColumn();
            Column12 = new DataGridViewTextBoxColumn();
            Column13 = new DataGridViewTextBoxColumn();
            Column14 = new DataGridViewTextBoxColumn();
            Column15 = new DataGridViewTextBoxColumn();
            Column16 = new DataGridViewTextBoxColumn();
            Column17 = new DataGridViewTextBoxColumn();
            Column18 = new DataGridViewTextBoxColumn();
            Column6 = new DataGridViewTextBoxColumn();
            Column7 = new DataGridViewTextBoxColumn();
            cms = new ContextMenuStrip(components);
            add = new ToolStripMenuItem();
            groupBox4.SuspendLayout();
            groupBox1.SuspendLayout();
            groupBox2.SuspendLayout();
            groupBox3.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)dgvData).BeginInit();
            cms.SuspendLayout();
            SuspendLayout();
            // 
            // label23
            // 
            label23.AutoSize = true;
            label23.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label23.ForeColor = Color.Maroon;
            label23.Location = new Point(813, 671);
            label23.Name = "label23";
            label23.Size = new Size(57, 23);
            label23.TabIndex = 26;
            label23.Text = "الصافي";
            // 
            // label22
            // 
            label22.AutoSize = true;
            label22.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label22.ForeColor = Color.Maroon;
            label22.Location = new Point(813, 637);
            label22.Name = "label22";
            label22.Size = new Size(47, 23);
            label22.TabIndex = 27;
            label22.Text = "VAT";
            // 
            // label21
            // 
            label21.AutoSize = true;
            label21.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label21.ForeColor = Color.Maroon;
            label21.Location = new Point(813, 600);
            label21.Name = "label21";
            label21.Size = new Size(51, 23);
            label21.TabIndex = 28;
            label21.Text = "الخصم";
            // 
            // label20
            // 
            label20.AutoSize = true;
            label20.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label20.ForeColor = Color.Maroon;
            label20.Location = new Point(813, 565);
            label20.Name = "label20";
            label20.Size = new Size(64, 23);
            label20.TabIndex = 29;
            label20.Text = "الإجمالي";
            // 
            // chkPost
            // 
            chkPost.AutoSize = true;
            chkPost.Location = new Point(446, 14);
            chkPost.Name = "chkPost";
            chkPost.Size = new Size(68, 27);
            chkPost.TabIndex = 25;
            chkPost.Text = "مرحل";
            chkPost.UseVisualStyleBackColor = true;
            // 
            // txtDiscountTotal
            // 
            txtDiscountTotal.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtDiscountTotal.Location = new Point(889, 598);
            txtDiscountTotal.Name = "txtDiscountTotal";
            txtDiscountTotal.Size = new Size(285, 30);
            txtDiscountTotal.TabIndex = 35;
            txtDiscountTotal.Text = "0.00";
            txtDiscountTotal.TextAlign = HorizontalAlignment.Center;
            // 
            // txtAllTotal
            // 
            txtAllTotal.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtAllTotal.Location = new Point(889, 563);
            txtAllTotal.Name = "txtAllTotal";
            txtAllTotal.Size = new Size(285, 30);
            txtAllTotal.TabIndex = 34;
            txtAllTotal.Text = "0.00";
            txtAllTotal.TextAlign = HorizontalAlignment.Center;
            // 
            // txtOpType
            // 
            txtOpType.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtOpType.Location = new Point(852, 43);
            txtOpType.Name = "txtOpType";
            txtOpType.Size = new Size(30, 30);
            txtOpType.TabIndex = 24;
            txtOpType.Text = "9";
            txtOpType.TextAlign = HorizontalAlignment.Center;
            txtOpType.Visible = false;
            // 
            // delete
            // 
            delete.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            delete.Image = (Image)resources.GetObject("delete.Image");
            delete.ImageScaling = ToolStripItemImageScaling.None;
            delete.Name = "delete";
            delete.Size = new Size(133, 38);
            delete.Text = "حذف";
            delete.Click += delete_Click;
            // 
            // btnExit
            // 
            btnExit.BackColor = Color.FromArgb(64, 0, 64);
            btnExit.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnExit.Image = (Image)resources.GetObject("btnExit.Image");
            btnExit.Location = new Point(18, 18);
            btnExit.Name = "btnExit";
            btnExit.Size = new Size(123, 44);
            btnExit.TabIndex = 5;
            btnExit.UseVisualStyleBackColor = false;
            btnExit.Click += btnExit_Click;
            // 
            // btnPrint
            // 
            btnPrint.BackColor = Color.FromArgb(64, 0, 64);
            btnPrint.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnPrint.Image = (Image)resources.GetObject("btnPrint.Image");
            btnPrint.Location = new Point(562, 20);
            btnPrint.Name = "btnPrint";
            btnPrint.Size = new Size(123, 44);
            btnPrint.TabIndex = 4;
            btnPrint.UseVisualStyleBackColor = false;
            btnPrint.Click += btnPrint_Click;
            // 
            // btnDel
            // 
            btnDel.BackColor = Color.FromArgb(64, 0, 64);
            btnDel.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnDel.Image = (Image)resources.GetObject("btnDel.Image");
            btnDel.Location = new Point(685, 20);
            btnDel.Name = "btnDel";
            btnDel.Size = new Size(123, 44);
            btnDel.TabIndex = 3;
            btnDel.UseVisualStyleBackColor = false;
            btnDel.Click += btnDel_Click;
            // 
            // txtDebitLimit
            // 
            txtDebitLimit.Location = new Point(788, 43);
            txtDebitLimit.Name = "txtDebitLimit";
            txtDebitLimit.Size = new Size(30, 30);
            txtDebitLimit.TabIndex = 23;
            txtDebitLimit.Visible = false;
            // 
            // btnSearch
            // 
            btnSearch.BackColor = Color.FromArgb(64, 0, 64);
            btnSearch.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnSearch.Image = (Image)resources.GetObject("btnSearch.Image");
            btnSearch.Location = new Point(12, 72);
            btnSearch.Name = "btnSearch";
            btnSearch.Size = new Size(80, 36);
            btnSearch.TabIndex = 22;
            btnSearch.UseVisualStyleBackColor = false;
            btnSearch.Click += btnSearch_Click;
            // 
            // txtVATTotal
            // 
            txtVATTotal.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtVATTotal.Location = new Point(889, 631);
            txtVATTotal.Name = "txtVATTotal";
            txtVATTotal.Size = new Size(285, 30);
            txtVATTotal.TabIndex = 36;
            txtVATTotal.Text = "0.00";
            txtVATTotal.TextAlign = HorizontalAlignment.Center;
            // 
            // txtSearch
            // 
            txtSearch.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtSearch.Location = new Point(98, 75);
            txtSearch.Name = "txtSearch";
            txtSearch.Size = new Size(161, 30);
            txtSearch.TabIndex = 21;
            txtSearch.TextAlign = HorizontalAlignment.Center;
            // 
            // label10
            // 
            label10.AutoSize = true;
            label10.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label10.Location = new Point(265, 79);
            label10.Name = "label10";
            label10.Size = new Size(38, 23);
            label10.TabIndex = 20;
            label10.Text = "بحث";
            // 
            // txtBNo
            // 
            txtBNo.BackColor = Color.FromArgb(192, 255, 255);
            txtBNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtBNo.Location = new Point(98, 36);
            txtBNo.Name = "txtBNo";
            txtBNo.ReadOnly = true;
            txtBNo.Size = new Size(163, 30);
            txtBNo.TabIndex = 19;
            txtBNo.TextAlign = HorizontalAlignment.Center;
            txtBNo.TextChanged += txtBNo_TextChanged;
            // 
            // btnPrev
            // 
            btnPrev.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnPrev.Image = (Image)resources.GetObject("btnPrev.Image");
            btnPrev.Location = new Point(56, 37);
            btnPrev.Name = "btnPrev";
            btnPrev.Size = new Size(37, 29);
            btnPrev.TabIndex = 18;
            btnPrev.UseVisualStyleBackColor = true;
            btnPrev.Click += btnPrev_Click;
            // 
            // cbFunds
            // 
            cbFunds.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            cbFunds.FormattingEnabled = true;
            cbFunds.Location = new Point(446, 42);
            cbFunds.Name = "cbFunds";
            cbFunds.Size = new Size(261, 31);
            cbFunds.TabIndex = 26;
            cbFunds.SelectedIndexChanged += cbFunds_SelectedIndexChanged;
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label3.Location = new Point(234, 122);
            label3.Name = "label3";
            label3.Size = new Size(98, 23);
            label3.TabIndex = 17;
            label3.Text = "تكلفة المبيعات";
            // 
            // txtSaleCost
            // 
            txtSaleCost.BackColor = Color.FromArgb(192, 255, 255);
            txtSaleCost.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtSaleCost.Location = new Point(33, 115);
            txtSaleCost.Name = "txtSaleCost";
            txtSaleCost.Size = new Size(196, 30);
            txtSaleCost.TabIndex = 28;
            // 
            // btnAdd
            // 
            btnAdd.BackColor = Color.FromArgb(64, 0, 64);
            btnAdd.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnAdd.Image = (Image)resources.GetObject("btnAdd.Image");
            btnAdd.Location = new Point(931, 20);
            btnAdd.Name = "btnAdd";
            btnAdd.Size = new Size(123, 44);
            btnAdd.TabIndex = 1;
            btnAdd.UseVisualStyleBackColor = false;
            btnAdd.Click += btnAdd_Click;
            // 
            // txtFundCode
            // 
            txtFundCode.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtFundCode.Location = new Point(357, 44);
            txtFundCode.Name = "txtFundCode";
            txtFundCode.Size = new Size(83, 30);
            txtFundCode.TabIndex = 27;
            txtFundCode.Visible = false;
            // 
            // btnNext
            // 
            btnNext.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnNext.Image = (Image)resources.GetObject("btnNext.Image");
            btnNext.Location = new Point(266, 37);
            btnNext.Name = "btnNext";
            btnNext.Size = new Size(37, 29);
            btnNext.TabIndex = 17;
            btnNext.UseVisualStyleBackColor = true;
            btnNext.Click += btnNext_Click;
            // 
            // btnFirst
            // 
            btnFirst.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnFirst.Image = (Image)resources.GetObject("btnFirst.Image");
            btnFirst.Location = new Point(14, 37);
            btnFirst.Name = "btnFirst";
            btnFirst.Size = new Size(37, 29);
            btnFirst.TabIndex = 16;
            btnFirst.UseVisualStyleBackColor = true;
            btnFirst.Click += btnFirst_Click;
            // 
            // btnLast
            // 
            btnLast.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnLast.Image = (Image)resources.GetObject("btnLast.Image");
            btnLast.Location = new Point(308, 37);
            btnLast.Name = "btnLast";
            btnLast.Size = new Size(37, 29);
            btnLast.TabIndex = 15;
            btnLast.UseVisualStyleBackColor = true;
            btnLast.Click += btnLast_Click;
            // 
            // brnEdit
            // 
            brnEdit.BackColor = Color.FromArgb(64, 0, 64);
            brnEdit.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            brnEdit.Image = (Image)resources.GetObject("brnEdit.Image");
            brnEdit.Location = new Point(808, 20);
            brnEdit.Name = "brnEdit";
            brnEdit.Size = new Size(123, 44);
            brnEdit.TabIndex = 2;
            brnEdit.UseVisualStyleBackColor = false;
            brnEdit.Click += brnEdit_Click;
            // 
            // btnNew
            // 
            btnNew.BackColor = Color.FromArgb(64, 0, 64);
            btnNew.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnNew.Image = (Image)resources.GetObject("btnNew.Image");
            btnNew.Location = new Point(1054, 20);
            btnNew.Name = "btnNew";
            btnNew.Size = new Size(123, 44);
            btnNew.TabIndex = 0;
            btnNew.UseVisualStyleBackColor = false;
            btnNew.Click += btnNew_Click;
            // 
            // txtJNo
            // 
            txtJNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtJNo.Location = new Point(820, 43);
            txtJNo.Name = "txtJNo";
            txtJNo.Size = new Size(30, 30);
            txtJNo.TabIndex = 14;
            txtJNo.Visible = false;
            // 
            // cbStores
            // 
            cbStores.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            cbStores.FormattingEnabled = true;
            cbStores.Location = new Point(447, 78);
            cbStores.Name = "cbStores";
            cbStores.Size = new Size(261, 31);
            cbStores.TabIndex = 13;
            // 
            // txtNote
            // 
            txtNote.BackColor = Color.FromArgb(255, 224, 192);
            txtNote.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtNote.Location = new Point(446, 113);
            txtNote.Name = "txtNote";
            txtNote.Size = new Size(651, 30);
            txtNote.TabIndex = 12;
            // 
            // txtCustName
            // 
            txtCustName.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtCustName.Location = new Point(464, 44);
            txtCustName.Name = "txtCustName";
            txtCustName.Size = new Size(243, 30);
            txtCustName.TabIndex = 9;
            txtCustName.TextAlign = HorizontalAlignment.Center;
            txtCustName.Visible = false;
            txtCustName.KeyDown += txtCustName_KeyDown;
            // 
            // lblFund
            // 
            lblFund.AutoSize = true;
            lblFund.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            lblFund.Location = new Point(713, 48);
            lblFund.Name = "lblFund";
            lblFund.Size = new Size(67, 23);
            lblFund.TabIndex = 17;
            lblFund.Text = "الصندوق";
            // 
            // txtCustCode
            // 
            txtCustCode.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtCustCode.Location = new Point(357, 44);
            txtCustCode.Name = "txtCustCode";
            txtCustCode.Size = new Size(83, 30);
            txtCustCode.TabIndex = 8;
            txtCustCode.TextAlign = HorizontalAlignment.Center;
            txtCustCode.Visible = false;
            // 
            // cbPaymentMethod
            // 
            cbPaymentMethod.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            cbPaymentMethod.FormattingEnabled = true;
            cbPaymentMethod.Location = new Point(889, 45);
            cbPaymentMethod.Name = "cbPaymentMethod";
            cbPaymentMethod.Size = new Size(207, 31);
            cbPaymentMethod.TabIndex = 7;
            cbPaymentMethod.SelectedIndexChanged += cbPaymentMethod_SelectedIndexChanged;
            // 
            // txtCurrVal
            // 
            txtCurrVal.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtCurrVal.Location = new Point(784, 78);
            txtCurrVal.Name = "txtCurrVal";
            txtCurrVal.Size = new Size(100, 30);
            txtCurrVal.TabIndex = 6;
            txtCurrVal.TextAlign = HorizontalAlignment.Center;
            // 
            // cbCurrencies
            // 
            cbCurrencies.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            cbCurrencies.FormattingEnabled = true;
            cbCurrencies.Location = new Point(890, 79);
            cbCurrencies.Name = "cbCurrencies";
            cbCurrencies.Size = new Size(207, 31);
            cbCurrencies.TabIndex = 5;
            cbCurrencies.SelectedIndexChanged += cbCurrencies_SelectedIndexChanged;
            // 
            // dtpDate
            // 
            dtpDate.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            dtpDate.Location = new Point(551, 12);
            dtpDate.Name = "dtpDate";
            dtpDate.Size = new Size(156, 30);
            dtpDate.TabIndex = 2;
            // 
            // txtNo
            // 
            txtNo.BackColor = Color.FromArgb(192, 255, 255);
            txtNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtNo.Location = new Point(889, 12);
            txtNo.Name = "txtNo";
            txtNo.ReadOnly = true;
            txtNo.Size = new Size(207, 30);
            txtNo.TabIndex = 1;
            txtNo.TextAlign = HorizontalAlignment.Center;
            // 
            // label9
            // 
            label9.AutoSize = true;
            label9.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label9.Location = new Point(723, 82);
            label9.Name = "label9";
            label9.Size = new Size(57, 23);
            label9.TabIndex = 0;
            label9.Text = "المخزن";
            // 
            // label8
            // 
            label8.AutoSize = true;
            label8.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label8.Location = new Point(1134, 112);
            label8.Name = "label8";
            label8.Size = new Size(45, 23);
            label8.TabIndex = 0;
            label8.Text = "البيان";
            // 
            // lblCust
            // 
            lblCust.AutoSize = true;
            lblCust.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            lblCust.Location = new Point(732, 48);
            lblCust.Name = "lblCust";
            lblCust.Size = new Size(48, 23);
            lblCust.TabIndex = 0;
            lblCust.Text = "العميل";
            lblCust.Visible = false;
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label4.Location = new Point(1132, 80);
            label4.Name = "label4";
            label4.Size = new Size(47, 23);
            label4.TabIndex = 0;
            label4.Text = "العملة";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label2.Location = new Point(726, 16);
            label2.Name = "label2";
            label2.Size = new Size(54, 23);
            label2.TabIndex = 0;
            label2.Text = "التاريخ";
            // 
            // groupBox4
            // 
            groupBox4.Controls.Add(btnExit);
            groupBox4.Controls.Add(btnPrint);
            groupBox4.Controls.Add(btnDel);
            groupBox4.Controls.Add(brnEdit);
            groupBox4.Controls.Add(btnAdd);
            groupBox4.Controls.Add(btnNew);
            groupBox4.Dock = DockStyle.Bottom;
            groupBox4.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            groupBox4.Location = new Point(0, 701);
            groupBox4.Name = "groupBox4";
            groupBox4.Size = new Size(1192, 76);
            groupBox4.TabIndex = 33;
            groupBox4.TabStop = false;
            // 
            // groupBox1
            // 
            groupBox1.Controls.Add(chkPost);
            groupBox1.Controls.Add(txtOpType);
            groupBox1.Controls.Add(txtDebitLimit);
            groupBox1.Controls.Add(btnSearch);
            groupBox1.Controls.Add(txtSearch);
            groupBox1.Controls.Add(label10);
            groupBox1.Controls.Add(txtBNo);
            groupBox1.Controls.Add(txtFundCode);
            groupBox1.Controls.Add(btnPrev);
            groupBox1.Controls.Add(btnNext);
            groupBox1.Controls.Add(cbFunds);
            groupBox1.Controls.Add(btnFirst);
            groupBox1.Controls.Add(label3);
            groupBox1.Controls.Add(btnLast);
            groupBox1.Controls.Add(txtSaleCost);
            groupBox1.Controls.Add(txtJNo);
            groupBox1.Controls.Add(cbStores);
            groupBox1.Controls.Add(txtNote);
            groupBox1.Controls.Add(txtCustName);
            groupBox1.Controls.Add(lblFund);
            groupBox1.Controls.Add(txtCustCode);
            groupBox1.Controls.Add(cbPaymentMethod);
            groupBox1.Controls.Add(txtCurrVal);
            groupBox1.Controls.Add(cbCurrencies);
            groupBox1.Controls.Add(dtpDate);
            groupBox1.Controls.Add(txtNo);
            groupBox1.Controls.Add(label9);
            groupBox1.Controls.Add(label8);
            groupBox1.Controls.Add(lblCust);
            groupBox1.Controls.Add(label5);
            groupBox1.Controls.Add(label4);
            groupBox1.Controls.Add(label2);
            groupBox1.Controls.Add(label1);
            groupBox1.Dock = DockStyle.Top;
            groupBox1.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            groupBox1.Location = new Point(0, 0);
            groupBox1.Name = "groupBox1";
            groupBox1.Size = new Size(1192, 153);
            groupBox1.TabIndex = 30;
            groupBox1.TabStop = false;
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label5.Location = new Point(1095, 48);
            label5.Name = "label5";
            label5.Size = new Size(84, 23);
            label5.TabIndex = 0;
            label5.Text = "طريقة الدفع";
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label1.Location = new Point(1138, 16);
            label1.Name = "label1";
            label1.Size = new Size(41, 23);
            label1.TabIndex = 0;
            label1.Text = "الرقم";
            // 
            // edit
            // 
            edit.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            edit.Image = (Image)resources.GetObject("edit.Image");
            edit.ImageScaling = ToolStripItemImageScaling.None;
            edit.Name = "edit";
            edit.Size = new Size(133, 38);
            edit.Text = "تعديل";
            edit.Click += edit_Click;
            // 
            // txtNetTotal
            // 
            txtNetTotal.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtNetTotal.Location = new Point(889, 665);
            txtNetTotal.Name = "txtNetTotal";
            txtNetTotal.Size = new Size(285, 30);
            txtNetTotal.TabIndex = 37;
            txtNetTotal.Text = "0.00";
            txtNetTotal.TextAlign = HorizontalAlignment.Center;
            // 
            // txtCatID
            // 
            txtCatID.ForeColor = Color.Navy;
            txtCatID.Location = new Point(847, 20);
            txtCatID.Name = "txtCatID";
            txtCatID.Size = new Size(85, 30);
            txtCatID.TabIndex = 12;
            // 
            // btnInsert
            // 
            btnInsert.BackColor = Color.FromArgb(64, 0, 64);
            btnInsert.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnInsert.Image = (Image)resources.GetObject("btnInsert.Image");
            btnInsert.Location = new Point(0, 54);
            btnInsert.Name = "btnInsert";
            btnInsert.Size = new Size(63, 37);
            btnInsert.TabIndex = 10;
            btnInsert.UseVisualStyleBackColor = false;
            btnInsert.Click += btnInsert_Click;
            // 
            // txtTotal
            // 
            txtTotal.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtTotal.Location = new Point(61, 59);
            txtTotal.Name = "txtTotal";
            txtTotal.Size = new Size(155, 30);
            txtTotal.TabIndex = 9;
            txtTotal.Text = "0.00";
            txtTotal.TextAlign = HorizontalAlignment.Center;
            // 
            // txtVAT
            // 
            txtVAT.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtVAT.Location = new Point(222, 59);
            txtVAT.Name = "txtVAT";
            txtVAT.Size = new Size(105, 30);
            txtVAT.TabIndex = 8;
            txtVAT.Text = "0.00";
            txtVAT.TextAlign = HorizontalAlignment.Center;
            txtVAT.TextChanged += txtVAT_TextChanged;
            // 
            // txtDisCount
            // 
            txtDisCount.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtDisCount.Location = new Point(333, 59);
            txtDisCount.Name = "txtDisCount";
            txtDisCount.Size = new Size(105, 30);
            txtDisCount.TabIndex = 7;
            txtDisCount.Text = "0.00";
            txtDisCount.TextAlign = HorizontalAlignment.Center;
            txtDisCount.TextChanged += txtDisCount_TextChanged;
            // 
            // txtPrice
            // 
            txtPrice.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtPrice.Location = new Point(444, 59);
            txtPrice.Name = "txtPrice";
            txtPrice.Size = new Size(129, 30);
            txtPrice.TabIndex = 6;
            txtPrice.Text = "0.00";
            txtPrice.TextAlign = HorizontalAlignment.Center;
            txtPrice.TextChanged += txtPrice_TextChanged;
            // 
            // txtQty
            // 
            txtQty.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtQty.Location = new Point(579, 59);
            txtQty.Name = "txtQty";
            txtQty.Size = new Size(87, 30);
            txtQty.TabIndex = 5;
            txtQty.Text = "0.00";
            txtQty.TextAlign = HorizontalAlignment.Center;
            txtQty.TextChanged += txtQty_TextChanged;
            // 
            // txtConversionFactor
            // 
            txtConversionFactor.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtConversionFactor.ForeColor = Color.Navy;
            txtConversionFactor.Location = new Point(683, 20);
            txtConversionFactor.Name = "txtConversionFactor";
            txtConversionFactor.Size = new Size(40, 30);
            txtConversionFactor.TabIndex = 4;
            txtConversionFactor.Visible = false;
            // 
            // cbUnits
            // 
            cbUnits.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            cbUnits.FormattingEnabled = true;
            cbUnits.Location = new Point(672, 59);
            cbUnits.Name = "cbUnits";
            cbUnits.Size = new Size(119, 31);
            cbUnits.TabIndex = 3;
            cbUnits.SelectedIndexChanged += cbUnits_SelectedIndexChanged;
            // 
            // txtProdName
            // 
            txtProdName.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtProdName.Location = new Point(797, 59);
            txtProdName.Name = "txtProdName";
            txtProdName.Size = new Size(228, 30);
            txtProdName.TabIndex = 2;
            // 
            // txtProdCode
            // 
            txtProdCode.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtProdCode.Location = new Point(1031, 59);
            txtProdCode.Name = "txtProdCode";
            txtProdCode.Size = new Size(136, 30);
            txtProdCode.TabIndex = 1;
            txtProdCode.KeyDown += txtProdCode_KeyDown;
            txtProdCode.Leave += txtProdCode_Leave;
            // 
            // label18
            // 
            label18.AutoSize = true;
            label18.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label18.ForeColor = Color.Navy;
            label18.Location = new Point(152, 24);
            label18.Name = "label18";
            label18.Size = new Size(64, 23);
            label18.TabIndex = 0;
            label18.Text = "الإجمالي";
            // 
            // label17
            // 
            label17.AutoSize = true;
            label17.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label17.ForeColor = Color.Navy;
            label17.Location = new Point(280, 24);
            label17.Name = "label17";
            label17.Size = new Size(47, 23);
            label17.TabIndex = 0;
            label17.Text = "VAT";
            // 
            // label16
            // 
            label16.AutoSize = true;
            label16.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label16.ForeColor = Color.Navy;
            label16.Location = new Point(387, 24);
            label16.Name = "label16";
            label16.Size = new Size(51, 23);
            label16.TabIndex = 0;
            label16.Text = "الخصم";
            // 
            // label15
            // 
            label15.AutoSize = true;
            label15.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label15.ForeColor = Color.Navy;
            label15.Location = new Point(526, 24);
            label15.Name = "label15";
            label15.Size = new Size(47, 23);
            label15.TabIndex = 0;
            label15.Text = "السعر";
            // 
            // lblQty
            // 
            lblQty.AutoSize = true;
            lblQty.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            lblQty.ForeColor = Color.Red;
            lblQty.Location = new Point(50, 20);
            lblQty.Name = "lblQty";
            lblQty.Size = new Size(0, 23);
            lblQty.TabIndex = 0;
            // 
            // label14
            // 
            label14.AutoSize = true;
            label14.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label14.ForeColor = Color.Navy;
            label14.Location = new Point(619, 24);
            label14.Name = "label14";
            label14.Size = new Size(47, 23);
            label14.TabIndex = 0;
            label14.Text = "الكمية";
            // 
            // label13
            // 
            label13.AutoSize = true;
            label13.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label13.ForeColor = Color.Navy;
            label13.Location = new Point(739, 24);
            label13.Name = "label13";
            label13.Size = new Size(52, 23);
            label13.TabIndex = 0;
            label13.Text = "الوحدة";
            // 
            // label12
            // 
            label12.AutoSize = true;
            label12.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label12.ForeColor = Color.Navy;
            label12.Location = new Point(943, 24);
            label12.Name = "label12";
            label12.Size = new Size(82, 23);
            label12.TabIndex = 0;
            label12.Text = "إسم الصنف";
            // 
            // label11
            // 
            label11.AutoSize = true;
            label11.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label11.ForeColor = Color.Navy;
            label11.Location = new Point(1086, 24);
            label11.Name = "label11";
            label11.Size = new Size(81, 23);
            label11.TabIndex = 0;
            label11.Text = "رقم الصنف";
            // 
            // groupBox2
            // 
            groupBox2.Controls.Add(txtCatID);
            groupBox2.Controls.Add(btnInsert);
            groupBox2.Controls.Add(txtTotal);
            groupBox2.Controls.Add(txtVAT);
            groupBox2.Controls.Add(txtDisCount);
            groupBox2.Controls.Add(txtPrice);
            groupBox2.Controls.Add(txtQty);
            groupBox2.Controls.Add(txtConversionFactor);
            groupBox2.Controls.Add(cbUnits);
            groupBox2.Controls.Add(txtProdName);
            groupBox2.Controls.Add(txtProdCode);
            groupBox2.Controls.Add(label18);
            groupBox2.Controls.Add(label17);
            groupBox2.Controls.Add(label16);
            groupBox2.Controls.Add(label15);
            groupBox2.Controls.Add(lblQty);
            groupBox2.Controls.Add(label14);
            groupBox2.Controls.Add(label13);
            groupBox2.Controls.Add(label12);
            groupBox2.Controls.Add(label11);
            groupBox2.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            groupBox2.Location = new Point(5, 159);
            groupBox2.Name = "groupBox2";
            groupBox2.Size = new Size(1175, 96);
            groupBox2.TabIndex = 31;
            groupBox2.TabStop = false;
            // 
            // groupBox3
            // 
            groupBox3.Controls.Add(dgvData);
            groupBox3.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            groupBox3.Location = new Point(5, 255);
            groupBox3.Name = "groupBox3";
            groupBox3.Size = new Size(1175, 300);
            groupBox3.TabIndex = 32;
            groupBox3.TabStop = false;
            // 
            // dgvData
            // 
            dgvData.AllowUserToAddRows = false;
            dataGridViewCellStyle1.Alignment = DataGridViewContentAlignment.MiddleCenter;
            dataGridViewCellStyle1.BackColor = Color.LightSkyBlue;
            dataGridViewCellStyle1.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            dgvData.AlternatingRowsDefaultCellStyle = dataGridViewCellStyle1;
            dgvData.BackgroundColor = Color.Azure;
            dataGridViewCellStyle2.Alignment = DataGridViewContentAlignment.MiddleCenter;
            dataGridViewCellStyle2.BackColor = SystemColors.Control;
            dataGridViewCellStyle2.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            dataGridViewCellStyle2.ForeColor = SystemColors.WindowText;
            dataGridViewCellStyle2.SelectionBackColor = SystemColors.Highlight;
            dataGridViewCellStyle2.SelectionForeColor = SystemColors.HighlightText;
            dataGridViewCellStyle2.WrapMode = DataGridViewTriState.True;
            dgvData.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle2;
            dgvData.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            dgvData.Columns.AddRange(new DataGridViewColumn[] { Column1, Column2, Column3, Column4, Column5, Qty, Price, Discount, VATT, TotalNet, CatNo, Column12, Column13, Column14, Column15, Column16, Column17, Column18, Column6, Column7 });
            dgvData.ContextMenuStrip = cms;
            dataGridViewCellStyle3.Alignment = DataGridViewContentAlignment.MiddleCenter;
            dataGridViewCellStyle3.BackColor = Color.White;
            dataGridViewCellStyle3.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            dataGridViewCellStyle3.ForeColor = SystemColors.ControlText;
            dataGridViewCellStyle3.SelectionBackColor = SystemColors.Highlight;
            dataGridViewCellStyle3.SelectionForeColor = SystemColors.HighlightText;
            dataGridViewCellStyle3.WrapMode = DataGridViewTriState.False;
            dgvData.DefaultCellStyle = dataGridViewCellStyle3;
            dgvData.Dock = DockStyle.Fill;
            dgvData.GridColor = Color.FromArgb(0, 0, 192);
            dgvData.Location = new Point(3, 26);
            dgvData.Name = "dgvData";
            dgvData.RowHeadersVisible = false;
            dgvData.RowHeadersWidth = 51;
            dgvData.Size = new Size(1169, 271);
            dgvData.TabIndex = 1;
            dgvData.RowsAdded += dgvData_RowsAdded;
            // 
            // Column1
            // 
            Column1.HeaderText = "رقم الصنف";
            Column1.MinimumWidth = 6;
            Column1.Name = "Column1";
            Column1.Width = 110;
            // 
            // Column2
            // 
            Column2.HeaderText = "إسم الصنف";
            Column2.MinimumWidth = 6;
            Column2.Name = "Column2";
            Column2.Width = 111;
            // 
            // Column3
            // 
            Column3.HeaderText = "رقم الوحدة";
            Column3.MinimumWidth = 6;
            Column3.Name = "Column3";
            Column3.Visible = false;
            Column3.Width = 108;
            // 
            // Column4
            // 
            Column4.HeaderText = "إسم الوحدة";
            Column4.MinimumWidth = 6;
            Column4.Name = "Column4";
            Column4.Width = 109;
            // 
            // Column5
            // 
            Column5.HeaderText = "معامل التحويل";
            Column5.MinimumWidth = 6;
            Column5.Name = "Column5";
            Column5.Visible = false;
            Column5.Width = 128;
            // 
            // Qty
            // 
            Qty.HeaderText = "الكمية";
            Qty.MinimumWidth = 6;
            Qty.Name = "Qty";
            Qty.Width = 76;
            // 
            // Price
            // 
            Price.HeaderText = "السعر";
            Price.MinimumWidth = 6;
            Price.Name = "Price";
            Price.Width = 76;
            // 
            // Discount
            // 
            Discount.HeaderText = "الخصم";
            Discount.MinimumWidth = 6;
            Discount.Name = "Discount";
            Discount.Width = 80;
            // 
            // VATT
            // 
            VATT.HeaderText = "VAT";
            VATT.MinimumWidth = 6;
            VATT.Name = "VATT";
            VATT.Width = 76;
            // 
            // TotalNet
            // 
            TotalNet.HeaderText = "الإجمالي";
            TotalNet.MinimumWidth = 6;
            TotalNet.Name = "TotalNet";
            TotalNet.Width = 93;
            // 
            // CatNo
            // 
            CatNo.HeaderText = "م المخزنية";
            CatNo.MinimumWidth = 6;
            CatNo.Name = "CatNo";
            CatNo.Visible = false;
            CatNo.Width = 105;
            // 
            // Column12
            // 
            Column12.HeaderText = "رقم المخزن";
            Column12.MinimumWidth = 6;
            Column12.Name = "Column12";
            Column12.Visible = false;
            Column12.Width = 113;
            // 
            // Column13
            // 
            Column13.HeaderText = "ح المخزون";
            Column13.MinimumWidth = 6;
            Column13.Name = "Column13";
            Column13.Visible = false;
            Column13.Width = 112;
            // 
            // Column14
            // 
            Column14.HeaderText = "ح المبيعات";
            Column14.MinimumWidth = 6;
            Column14.Name = "Column14";
            Column14.Visible = false;
            Column14.Width = 108;
            // 
            // Column15
            // 
            Column15.HeaderText = "ح مردود المبيعات";
            Column15.MinimumWidth = 6;
            Column15.Name = "Column15";
            Column15.Visible = false;
            Column15.Width = 153;
            // 
            // Column16
            // 
            Column16.HeaderText = "ح خصم مسموح";
            Column16.MinimumWidth = 6;
            Column16.Name = "Column16";
            Column16.Visible = false;
            Column16.Width = 142;
            // 
            // Column17
            // 
            Column17.HeaderText = "ح ك مجانية مبعات";
            Column17.MinimumWidth = 6;
            Column17.Name = "Column17";
            Column17.Visible = false;
            Column17.Width = 156;
            // 
            // Column18
            // 
            Column18.HeaderText = "ح ضريبة مضافة المبيعات";
            Column18.MinimumWidth = 6;
            Column18.Name = "Column18";
            Column18.Visible = false;
            Column18.Width = 184;
            // 
            // Column6
            // 
            Column6.HeaderText = "تكلفة المبيعات";
            Column6.MinimumWidth = 6;
            Column6.Name = "Column6";
            Column6.Visible = false;
            Column6.Width = 117;
            // 
            // Column7
            // 
            Column7.HeaderText = "إيرادات المبيعات";
            Column7.MinimumWidth = 6;
            Column7.Name = "Column7";
            Column7.Visible = false;
            Column7.Width = 130;
            // 
            // cms
            // 
            cms.ImageScalingSize = new Size(20, 20);
            cms.Items.AddRange(new ToolStripItem[] { add, edit, delete });
            cms.Name = "cms";
            cms.RightToLeft = RightToLeft.Yes;
            cms.Size = new Size(134, 118);
            // 
            // add
            // 
            add.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            add.Image = (Image)resources.GetObject("add.Image");
            add.ImageScaling = ToolStripItemImageScaling.None;
            add.Name = "add";
            add.Size = new Size(133, 38);
            add.Text = "إصافة";
            add.Click += add_Click;
            // 
            // frmSaleReturnBill
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(1192, 777);
            Controls.Add(label23);
            Controls.Add(label22);
            Controls.Add(label21);
            Controls.Add(label20);
            Controls.Add(txtDiscountTotal);
            Controls.Add(txtAllTotal);
            Controls.Add(txtVATTotal);
            Controls.Add(groupBox4);
            Controls.Add(groupBox1);
            Controls.Add(txtNetTotal);
            Controls.Add(groupBox2);
            Controls.Add(groupBox3);
            Icon = (Icon)resources.GetObject("$this.Icon");
            MaximizeBox = false;
            MinimizeBox = false;
            Name = "frmSaleReturnBill";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "فاتورة مرتجع المبيعات";
            Load += frmSaleReturnBill_Load;
            groupBox4.ResumeLayout(false);
            groupBox1.ResumeLayout(false);
            groupBox1.PerformLayout();
            groupBox2.ResumeLayout(false);
            groupBox2.PerformLayout();
            groupBox3.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)dgvData).EndInit();
            cms.ResumeLayout(false);
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Label label23;
        private Label label22;
        private Label label21;
        private Label label20;
        private CheckBox chkPost;
        private TextBox txtDiscountTotal;
        private TextBox txtAllTotal;
        public TextBox txtOpType;
        private ToolStripMenuItem delete;
        private Button btnExit;
        private Button btnPrint;
        private Button btnDel;
        private TextBox txtDebitLimit;
        private Button btnSearch;
        private TextBox txtVATTotal;
        private TextBox txtSearch;
        private Label label10;
        private TextBox txtBNo;
        private Button btnPrev;
        private ComboBox cbFunds;
        private Label label3;
        private TextBox txtSaleCost;
        private Button btnAdd;
        private TextBox txtFundCode;
        private Button btnNext;
        private Button btnFirst;
        private Button btnLast;
        private Button brnEdit;
        private Button btnNew;
        private TextBox txtJNo;
        private ComboBox cbStores;
        private TextBox txtNote;
        private TextBox txtCustName;
        private Label lblFund;
        private TextBox txtCustCode;
        private ComboBox cbPaymentMethod;
        private TextBox txtCurrVal;
        private ComboBox cbCurrencies;
        private DateTimePicker dtpDate;
        private TextBox txtNo;
        private Label label9;
        private Label label8;
        private Label lblCust;
        private Label label4;
        private Label label2;
        private GroupBox groupBox4;
        private GroupBox groupBox1;
        private Label label5;
        private Label label1;
        private ToolStripMenuItem edit;
        private TextBox txtNetTotal;
        private TextBox txtCatID;
        private Button btnInsert;
        private TextBox txtTotal;
        private TextBox txtVAT;
        private TextBox txtDisCount;
        private TextBox txtPrice;
        private TextBox txtQty;
        private TextBox txtConversionFactor;
        private ComboBox cbUnits;
        private TextBox txtProdName;
        private TextBox txtProdCode;
        private Label label18;
        private Label label17;
        private Label label16;
        private Label label15;
        private Label lblQty;
        private Label label14;
        private Label label13;
        private Label label12;
        private Label label11;
        private GroupBox groupBox2;
        private GroupBox groupBox3;
        private DataGridView dgvData;
        private DataGridViewTextBoxColumn Column1;
        private DataGridViewTextBoxColumn Column2;
        private DataGridViewTextBoxColumn Column3;
        private DataGridViewTextBoxColumn Column4;
        private DataGridViewTextBoxColumn Column5;
        private DataGridViewTextBoxColumn Qty;
        private DataGridViewTextBoxColumn Price;
        private DataGridViewTextBoxColumn Discount;
        private DataGridViewTextBoxColumn VATT;
        private DataGridViewTextBoxColumn TotalNet;
        private DataGridViewTextBoxColumn CatNo;
        private DataGridViewTextBoxColumn Column12;
        private DataGridViewTextBoxColumn Column13;
        private DataGridViewTextBoxColumn Column14;
        private DataGridViewTextBoxColumn Column15;
        private DataGridViewTextBoxColumn Column16;
        private DataGridViewTextBoxColumn Column17;
        private DataGridViewTextBoxColumn Column18;
        private DataGridViewTextBoxColumn Column6;
        private DataGridViewTextBoxColumn Column7;
        private ContextMenuStrip cms;
        private ToolStripMenuItem add;
    }
}