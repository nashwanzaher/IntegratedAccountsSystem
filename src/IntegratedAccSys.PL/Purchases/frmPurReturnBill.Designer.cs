namespace IntegratedAccSys.PL.Purchases
{
    partial class frmPurReturnBill
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmPurReturnBill));
            DataGridViewCellStyle dataGridViewCellStyle1 = new DataGridViewCellStyle();
            DataGridViewCellStyle dataGridViewCellStyle2 = new DataGridViewCellStyle();
            DataGridViewCellStyle dataGridViewCellStyle3 = new DataGridViewCellStyle();
            CatNo = new DataGridViewTextBoxColumn();
            VATT = new DataGridViewTextBoxColumn();
            Discount = new DataGridViewTextBoxColumn();
            Price = new DataGridViewTextBoxColumn();
            Qty = new DataGridViewTextBoxColumn();
            covertFactor = new DataGridViewTextBoxColumn();
            unitName = new DataGridViewTextBoxColumn();
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
            unitID = new DataGridViewTextBoxColumn();
            ProdName = new DataGridViewTextBoxColumn();
            prodNo = new DataGridViewTextBoxColumn();
            TotalNet = new DataGridViewTextBoxColumn();
            groupBox3 = new GroupBox();
            dgvData = new DataGridView();
            Column12 = new DataGridViewTextBoxColumn();
            Column13 = new DataGridViewTextBoxColumn();
            Column19 = new DataGridViewTextBoxColumn();
            Column20 = new DataGridViewTextBoxColumn();
            Column21 = new DataGridViewTextBoxColumn();
            Column22 = new DataGridViewTextBoxColumn();
            Column23 = new DataGridViewTextBoxColumn();
            cms = new ContextMenuStrip(components);
            add = new ToolStripMenuItem();
            edit = new ToolStripMenuItem();
            delete = new ToolStripMenuItem();
            txtNetTotal = new TextBox();
            txtDiscountTotal = new TextBox();
            txtAllTotal = new TextBox();
            label23 = new Label();
            label22 = new Label();
            label21 = new Label();
            label20 = new Label();
            btnExit = new Button();
            groupBox4 = new GroupBox();
            btnPrint = new Button();
            btnDel = new Button();
            brnEdit = new Button();
            btnAdd = new Button();
            btnNew = new Button();
            label17 = new Label();
            txtFundCode = new TextBox();
            txtSaleCost = new TextBox();
            chkPost = new CheckBox();
            btnSearch = new Button();
            txtSearch = new TextBox();
            label10 = new Label();
            txtBNo = new TextBox();
            btnPrev = new Button();
            btnNext = new Button();
            cbFunds = new ComboBox();
            btnFirst = new Button();
            btnLast = new Button();
            txtOpType = new TextBox();
            txtJNo = new TextBox();
            cbStores = new ComboBox();
            txtNote = new TextBox();
            txtSuppName = new TextBox();
            cbPaymentMethod = new ComboBox();
            groupBox1 = new GroupBox();
            lblFund = new Label();
            txtCurrVal = new TextBox();
            cbCurrencies = new ComboBox();
            dtpDate = new DateTimePicker();
            txtNo = new TextBox();
            label9 = new Label();
            label8 = new Label();
            lblSupp = new Label();
            label5 = new Label();
            label4 = new Label();
            label2 = new Label();
            label1 = new Label();
            txtSuppCode = new TextBox();
            label16 = new Label();
            label15 = new Label();
            label14 = new Label();
            label13 = new Label();
            label11 = new Label();
            txtVATTotal = new TextBox();
            groupBox2 = new GroupBox();
            label12 = new Label();
            groupBox3.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)dgvData).BeginInit();
            cms.SuspendLayout();
            groupBox4.SuspendLayout();
            groupBox1.SuspendLayout();
            groupBox2.SuspendLayout();
            SuspendLayout();
            // 
            // CatNo
            // 
            CatNo.HeaderText = "م المخزنية";
            CatNo.MinimumWidth = 6;
            CatNo.Name = "CatNo";
            CatNo.Visible = false;
            CatNo.Width = 105;
            // 
            // VATT
            // 
            VATT.HeaderText = "ق المضافة";
            VATT.MinimumWidth = 6;
            VATT.Name = "VATT";
            VATT.Width = 107;
            // 
            // Discount
            // 
            Discount.HeaderText = "الخصم";
            Discount.MinimumWidth = 6;
            Discount.Name = "Discount";
            Discount.Width = 80;
            // 
            // Price
            // 
            Price.HeaderText = "السعر";
            Price.MinimumWidth = 6;
            Price.Name = "Price";
            Price.Width = 76;
            // 
            // Qty
            // 
            Qty.HeaderText = "الكمية";
            Qty.MinimumWidth = 6;
            Qty.Name = "Qty";
            Qty.Width = 76;
            // 
            // covertFactor
            // 
            covertFactor.HeaderText = "معامل التحويل";
            covertFactor.MinimumWidth = 6;
            covertFactor.Name = "covertFactor";
            covertFactor.Visible = false;
            covertFactor.Width = 128;
            // 
            // unitName
            // 
            unitName.HeaderText = "إسم الوحدة";
            unitName.MinimumWidth = 6;
            unitName.Name = "unitName";
            unitName.Width = 109;
            // 
            // txtCatID
            // 
            txtCatID.Location = new Point(819, 20);
            txtCatID.Name = "txtCatID";
            txtCatID.Size = new Size(125, 30);
            txtCatID.TabIndex = 11;
            // 
            // btnInsert
            // 
            btnInsert.BackColor = Color.FromArgb(64, 0, 64);
            btnInsert.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnInsert.Image = (Image)resources.GetObject("btnInsert.Image");
            btnInsert.Location = new Point(0, 58);
            btnInsert.Name = "btnInsert";
            btnInsert.Size = new Size(54, 34);
            btnInsert.TabIndex = 10;
            btnInsert.UseVisualStyleBackColor = false;
            btnInsert.Click += btnInsert_Click;
            // 
            // txtTotal
            // 
            txtTotal.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtTotal.Location = new Point(61, 58);
            txtTotal.Name = "txtTotal";
            txtTotal.Size = new Size(155, 30);
            txtTotal.TabIndex = 9;
            txtTotal.Text = "0.00";
            txtTotal.TextAlign = HorizontalAlignment.Center;
            // 
            // txtVAT
            // 
            txtVAT.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtVAT.Location = new Point(222, 58);
            txtVAT.Name = "txtVAT";
            txtVAT.Size = new Size(112, 30);
            txtVAT.TabIndex = 8;
            txtVAT.Text = "0.00";
            txtVAT.TextAlign = HorizontalAlignment.Center;
            txtVAT.TextChanged += txtVAT_TextChanged;
            // 
            // txtDisCount
            // 
            txtDisCount.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtDisCount.Location = new Point(340, 58);
            txtDisCount.Name = "txtDisCount";
            txtDisCount.Size = new Size(97, 30);
            txtDisCount.TabIndex = 7;
            txtDisCount.Text = "0.00";
            txtDisCount.TextAlign = HorizontalAlignment.Center;
            txtDisCount.TextChanged += txtDisCount_TextChanged;
            // 
            // txtPrice
            // 
            txtPrice.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtPrice.Location = new Point(443, 58);
            txtPrice.Name = "txtPrice";
            txtPrice.Size = new Size(132, 30);
            txtPrice.TabIndex = 6;
            txtPrice.Text = "0.00";
            txtPrice.TextAlign = HorizontalAlignment.Center;
            txtPrice.TextChanged += txtPrice_TextChanged;
            // 
            // txtQty
            // 
            txtQty.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtQty.Location = new Point(581, 58);
            txtQty.Name = "txtQty";
            txtQty.Size = new Size(82, 30);
            txtQty.TabIndex = 5;
            txtQty.Text = "0.00";
            txtQty.TextAlign = HorizontalAlignment.Center;
            txtQty.TextChanged += txtQty_TextChanged;
            // 
            // txtConversionFactor
            // 
            txtConversionFactor.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtConversionFactor.Location = new Point(673, 20);
            txtConversionFactor.Name = "txtConversionFactor";
            txtConversionFactor.Size = new Size(65, 30);
            txtConversionFactor.TabIndex = 4;
            // 
            // cbUnits
            // 
            cbUnits.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            cbUnits.FormattingEnabled = true;
            cbUnits.Location = new Point(669, 58);
            cbUnits.Name = "cbUnits";
            cbUnits.Size = new Size(119, 31);
            cbUnits.TabIndex = 3;
            cbUnits.SelectedIndexChanged += cbUnits_SelectedIndexChanged;
            // 
            // txtProdName
            // 
            txtProdName.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtProdName.Location = new Point(794, 58);
            txtProdName.Name = "txtProdName";
            txtProdName.Size = new Size(228, 30);
            txtProdName.TabIndex = 2;
            // 
            // txtProdCode
            // 
            txtProdCode.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtProdCode.Location = new Point(1028, 58);
            txtProdCode.Name = "txtProdCode";
            txtProdCode.Size = new Size(135, 30);
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
            // unitID
            // 
            unitID.HeaderText = "رقم الوحدة";
            unitID.MinimumWidth = 6;
            unitID.Name = "unitID";
            unitID.Visible = false;
            unitID.Width = 108;
            // 
            // ProdName
            // 
            ProdName.HeaderText = "إسم الصنف";
            ProdName.MinimumWidth = 6;
            ProdName.Name = "ProdName";
            ProdName.Width = 111;
            // 
            // prodNo
            // 
            prodNo.HeaderText = "رقم الصنف";
            prodNo.MinimumWidth = 6;
            prodNo.Name = "prodNo";
            prodNo.Width = 110;
            // 
            // TotalNet
            // 
            TotalNet.HeaderText = "الإجمالي";
            TotalNet.MinimumWidth = 6;
            TotalNet.Name = "TotalNet";
            TotalNet.Width = 93;
            // 
            // groupBox3
            // 
            groupBox3.Controls.Add(dgvData);
            groupBox3.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            groupBox3.Location = new Point(5, 242);
            groupBox3.Name = "groupBox3";
            groupBox3.Size = new Size(1175, 313);
            groupBox3.TabIndex = 14;
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
            dgvData.Columns.AddRange(new DataGridViewColumn[] { prodNo, ProdName, unitID, unitName, covertFactor, Qty, Price, Discount, VATT, TotalNet, CatNo, Column12, Column13, Column19, Column20, Column21, Column22, Column23 });
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
            dgvData.Size = new Size(1169, 284);
            dgvData.TabIndex = 0;
            dgvData.RowsAdded += dgvData_RowsAdded;
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
            // Column19
            // 
            Column19.HeaderText = "ح المشتريات";
            Column19.MinimumWidth = 6;
            Column19.Name = "Column19";
            Column19.Visible = false;
            Column19.Width = 122;
            // 
            // Column20
            // 
            Column20.HeaderText = "ح مردودات المشتريات";
            Column20.MinimumWidth = 6;
            Column20.Name = "Column20";
            Column20.Visible = false;
            Column20.Width = 184;
            // 
            // Column21
            // 
            Column21.HeaderText = "ح الخصم المكتسب";
            Column21.MinimumWidth = 6;
            Column21.Name = "Column21";
            Column21.Visible = false;
            Column21.Width = 156;
            // 
            // Column22
            // 
            Column22.HeaderText = "ح ك المجانية المشتريات";
            Column22.MinimumWidth = 6;
            Column22.Name = "Column22";
            Column22.Visible = false;
            Column22.Width = 193;
            // 
            // Column23
            // 
            Column23.HeaderText = "ح القيمة المضافة المشتريات";
            Column23.MinimumWidth = 6;
            Column23.Name = "Column23";
            Column23.Visible = false;
            Column23.Width = 219;
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
            // txtNetTotal
            // 
            txtNetTotal.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtNetTotal.Location = new Point(886, 665);
            txtNetTotal.Name = "txtNetTotal";
            txtNetTotal.Size = new Size(288, 30);
            txtNetTotal.TabIndex = 19;
            txtNetTotal.Text = "0.00";
            txtNetTotal.TextAlign = HorizontalAlignment.Center;
            // 
            // txtDiscountTotal
            // 
            txtDiscountTotal.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtDiscountTotal.Location = new Point(886, 598);
            txtDiscountTotal.Name = "txtDiscountTotal";
            txtDiscountTotal.Size = new Size(288, 30);
            txtDiscountTotal.TabIndex = 17;
            txtDiscountTotal.Text = "0.00";
            txtDiscountTotal.TextAlign = HorizontalAlignment.Center;
            // 
            // txtAllTotal
            // 
            txtAllTotal.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtAllTotal.Location = new Point(886, 563);
            txtAllTotal.Name = "txtAllTotal";
            txtAllTotal.Size = new Size(288, 30);
            txtAllTotal.TabIndex = 16;
            txtAllTotal.Text = "0.00";
            txtAllTotal.TextAlign = HorizontalAlignment.Center;
            // 
            // label23
            // 
            label23.AutoSize = true;
            label23.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label23.ForeColor = Color.Maroon;
            label23.Location = new Point(813, 671);
            label23.Name = "label23";
            label23.Size = new Size(57, 23);
            label23.TabIndex = 8;
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
            label22.TabIndex = 9;
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
            label21.TabIndex = 10;
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
            label20.TabIndex = 11;
            label20.Text = "الإجمالي";
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
            groupBox4.TabIndex = 15;
            groupBox4.TabStop = false;
            // 
            // btnPrint
            // 
            btnPrint.BackColor = Color.FromArgb(64, 0, 64);
            btnPrint.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnPrint.Image = (Image)resources.GetObject("btnPrint.Image");
            btnPrint.Location = new Point(563, 18);
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
            btnDel.Location = new Point(686, 18);
            btnDel.Name = "btnDel";
            btnDel.Size = new Size(123, 44);
            btnDel.TabIndex = 3;
            btnDel.UseVisualStyleBackColor = false;
            btnDel.Click += btnDel_Click;
            // 
            // brnEdit
            // 
            brnEdit.BackColor = Color.FromArgb(64, 0, 64);
            brnEdit.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            brnEdit.Image = (Image)resources.GetObject("brnEdit.Image");
            brnEdit.Location = new Point(809, 18);
            brnEdit.Name = "brnEdit";
            brnEdit.Size = new Size(123, 44);
            brnEdit.TabIndex = 2;
            brnEdit.UseVisualStyleBackColor = false;
            brnEdit.Click += brnEdit_Click;
            // 
            // btnAdd
            // 
            btnAdd.BackColor = Color.FromArgb(64, 0, 64);
            btnAdd.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnAdd.Image = (Image)resources.GetObject("btnAdd.Image");
            btnAdd.Location = new Point(932, 18);
            btnAdd.Name = "btnAdd";
            btnAdd.Size = new Size(123, 44);
            btnAdd.TabIndex = 1;
            btnAdd.UseVisualStyleBackColor = false;
            btnAdd.Click += btnAdd_Click;
            // 
            // btnNew
            // 
            btnNew.BackColor = Color.FromArgb(64, 0, 64);
            btnNew.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnNew.Image = (Image)resources.GetObject("btnNew.Image");
            btnNew.Location = new Point(1055, 18);
            btnNew.Name = "btnNew";
            btnNew.Size = new Size(123, 44);
            btnNew.TabIndex = 0;
            btnNew.UseVisualStyleBackColor = false;
            btnNew.Click += btnNew_Click;
            // 
            // label17
            // 
            label17.AutoSize = true;
            label17.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label17.ForeColor = Color.Navy;
            label17.Location = new Point(287, 24);
            label17.Name = "label17";
            label17.Size = new Size(47, 23);
            label17.TabIndex = 0;
            label17.Text = "VAT";
            // 
            // txtFundCode
            // 
            txtFundCode.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtFundCode.Location = new Point(367, 47);
            txtFundCode.Name = "txtFundCode";
            txtFundCode.Size = new Size(92, 30);
            txtFundCode.TabIndex = 11;
            // 
            // txtSaleCost
            // 
            txtSaleCost.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtSaleCost.Location = new Point(266, 122);
            txtSaleCost.Name = "txtSaleCost";
            txtSaleCost.Size = new Size(193, 30);
            txtSaleCost.TabIndex = 12;
            txtSaleCost.Text = "0.00";
            txtSaleCost.Visible = false;
            // 
            // chkPost
            // 
            chkPost.AutoSize = true;
            chkPost.Location = new Point(467, 13);
            chkPost.Name = "chkPost";
            chkPost.Size = new Size(68, 27);
            chkPost.TabIndex = 23;
            chkPost.Text = "مرحل";
            chkPost.UseVisualStyleBackColor = true;
            // 
            // btnSearch
            // 
            btnSearch.BackColor = Color.FromArgb(64, 0, 64);
            btnSearch.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnSearch.Image = (Image)resources.GetObject("btnSearch.Image");
            btnSearch.Location = new Point(20, 74);
            btnSearch.Name = "btnSearch";
            btnSearch.Size = new Size(78, 36);
            btnSearch.TabIndex = 22;
            btnSearch.UseVisualStyleBackColor = false;
            btnSearch.Click += btnSearch_Click;
            // 
            // txtSearch
            // 
            txtSearch.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtSearch.Location = new Point(104, 77);
            txtSearch.Name = "txtSearch";
            txtSearch.Size = new Size(158, 30);
            txtSearch.TabIndex = 21;
            txtSearch.TextAlign = HorizontalAlignment.Center;
            // 
            // label10
            // 
            label10.AutoSize = true;
            label10.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label10.Location = new Point(268, 81);
            label10.Name = "label10";
            label10.Size = new Size(38, 23);
            label10.TabIndex = 20;
            label10.Text = "بحث";
            // 
            // txtBNo
            // 
            txtBNo.BackColor = Color.FromArgb(192, 255, 255);
            txtBNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtBNo.Location = new Point(104, 34);
            txtBNo.Name = "txtBNo";
            txtBNo.ReadOnly = true;
            txtBNo.Size = new Size(159, 30);
            txtBNo.TabIndex = 19;
            txtBNo.TextAlign = HorizontalAlignment.Center;
            txtBNo.TextChanged += txtBNo_TextChanged;
            // 
            // btnPrev
            // 
            btnPrev.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnPrev.Image = (Image)resources.GetObject("btnPrev.Image");
            btnPrev.Location = new Point(62, 35);
            btnPrev.Name = "btnPrev";
            btnPrev.Size = new Size(37, 29);
            btnPrev.TabIndex = 18;
            btnPrev.UseVisualStyleBackColor = true;
            btnPrev.Click += btnPrev_Click;
            // 
            // btnNext
            // 
            btnNext.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnNext.Image = (Image)resources.GetObject("btnNext.Image");
            btnNext.Location = new Point(268, 35);
            btnNext.Name = "btnNext";
            btnNext.Size = new Size(37, 29);
            btnNext.TabIndex = 17;
            btnNext.UseVisualStyleBackColor = true;
            btnNext.Click += btnNext_Click;
            // 
            // cbFunds
            // 
            cbFunds.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            cbFunds.FormattingEnabled = true;
            cbFunds.Location = new Point(467, 47);
            cbFunds.Name = "cbFunds";
            cbFunds.Size = new Size(261, 31);
            cbFunds.TabIndex = 10;
            cbFunds.SelectedIndexChanged += cbFunds_SelectedIndexChanged;
            // 
            // btnFirst
            // 
            btnFirst.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnFirst.Image = (Image)resources.GetObject("btnFirst.Image");
            btnFirst.Location = new Point(20, 35);
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
            btnLast.Location = new Point(310, 35);
            btnLast.Name = "btnLast";
            btnLast.Size = new Size(37, 29);
            btnLast.TabIndex = 15;
            btnLast.UseVisualStyleBackColor = true;
            btnLast.Click += btnLast_Click;
            // 
            // txtOpType
            // 
            txtOpType.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtOpType.Location = new Point(421, 11);
            txtOpType.Name = "txtOpType";
            txtOpType.Size = new Size(38, 30);
            txtOpType.TabIndex = 14;
            txtOpType.Text = "8";
            txtOpType.Visible = false;
            // 
            // txtJNo
            // 
            txtJNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtJNo.Location = new Point(367, 11);
            txtJNo.Name = "txtJNo";
            txtJNo.Size = new Size(48, 30);
            txtJNo.TabIndex = 14;
            txtJNo.Visible = false;
            // 
            // cbStores
            // 
            cbStores.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            cbStores.FormattingEnabled = true;
            cbStores.Location = new Point(467, 85);
            cbStores.Name = "cbStores";
            cbStores.Size = new Size(261, 31);
            cbStores.TabIndex = 13;
            // 
            // txtNote
            // 
            txtNote.BackColor = Color.FromArgb(255, 224, 192);
            txtNote.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtNote.Location = new Point(467, 122);
            txtNote.Name = "txtNote";
            txtNote.Size = new Size(616, 30);
            txtNote.TabIndex = 12;
            // 
            // txtSuppName
            // 
            txtSuppName.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtSuppName.Location = new Point(467, 47);
            txtSuppName.Name = "txtSuppName";
            txtSuppName.Size = new Size(241, 30);
            txtSuppName.TabIndex = 9;
            txtSuppName.TextAlign = HorizontalAlignment.Center;
            txtSuppName.Visible = false;
            txtSuppName.KeyDown += txtSuppName_KeyDown;
            // 
            // cbPaymentMethod
            // 
            cbPaymentMethod.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            cbPaymentMethod.FormattingEnabled = true;
            cbPaymentMethod.Location = new Point(915, 47);
            cbPaymentMethod.Name = "cbPaymentMethod";
            cbPaymentMethod.Size = new Size(168, 31);
            cbPaymentMethod.TabIndex = 7;
            cbPaymentMethod.SelectedIndexChanged += cbPaymentMethod_SelectedIndexChanged;
            // 
            // groupBox1
            // 
            groupBox1.Controls.Add(txtFundCode);
            groupBox1.Controls.Add(txtSaleCost);
            groupBox1.Controls.Add(chkPost);
            groupBox1.Controls.Add(btnSearch);
            groupBox1.Controls.Add(txtSearch);
            groupBox1.Controls.Add(label10);
            groupBox1.Controls.Add(txtBNo);
            groupBox1.Controls.Add(btnPrev);
            groupBox1.Controls.Add(btnNext);
            groupBox1.Controls.Add(cbFunds);
            groupBox1.Controls.Add(btnFirst);
            groupBox1.Controls.Add(btnLast);
            groupBox1.Controls.Add(txtOpType);
            groupBox1.Controls.Add(txtJNo);
            groupBox1.Controls.Add(cbStores);
            groupBox1.Controls.Add(txtNote);
            groupBox1.Controls.Add(txtSuppName);
            groupBox1.Controls.Add(cbPaymentMethod);
            groupBox1.Controls.Add(lblFund);
            groupBox1.Controls.Add(txtCurrVal);
            groupBox1.Controls.Add(cbCurrencies);
            groupBox1.Controls.Add(dtpDate);
            groupBox1.Controls.Add(txtNo);
            groupBox1.Controls.Add(label9);
            groupBox1.Controls.Add(label8);
            groupBox1.Controls.Add(lblSupp);
            groupBox1.Controls.Add(label5);
            groupBox1.Controls.Add(label4);
            groupBox1.Controls.Add(label2);
            groupBox1.Controls.Add(label1);
            groupBox1.Controls.Add(txtSuppCode);
            groupBox1.Dock = DockStyle.Top;
            groupBox1.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            groupBox1.Location = new Point(0, 0);
            groupBox1.Name = "groupBox1";
            groupBox1.Size = new Size(1192, 158);
            groupBox1.TabIndex = 12;
            groupBox1.TabStop = false;
            // 
            // lblFund
            // 
            lblFund.AutoSize = true;
            lblFund.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            lblFund.Location = new Point(734, 51);
            lblFund.Name = "lblFund";
            lblFund.Size = new Size(67, 23);
            lblFund.TabIndex = 0;
            lblFund.Text = "الصندوق";
            // 
            // txtCurrVal
            // 
            txtCurrVal.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtCurrVal.Location = new Point(809, 85);
            txtCurrVal.Name = "txtCurrVal";
            txtCurrVal.Size = new Size(104, 30);
            txtCurrVal.TabIndex = 6;
            txtCurrVal.TextAlign = HorizontalAlignment.Center;
            // 
            // cbCurrencies
            // 
            cbCurrencies.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            cbCurrencies.FormattingEnabled = true;
            cbCurrencies.Location = new Point(915, 85);
            cbCurrencies.Name = "cbCurrencies";
            cbCurrencies.Size = new Size(168, 31);
            cbCurrencies.TabIndex = 5;
            cbCurrencies.SelectedIndexChanged += cbCurrencies_SelectedIndexChanged;
            // 
            // dtpDate
            // 
            dtpDate.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            dtpDate.Location = new Point(572, 11);
            dtpDate.Name = "dtpDate";
            dtpDate.Size = new Size(156, 30);
            dtpDate.TabIndex = 2;
            // 
            // txtNo
            // 
            txtNo.BackColor = Color.FromArgb(192, 255, 255);
            txtNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtNo.Location = new Point(915, 11);
            txtNo.Name = "txtNo";
            txtNo.ReadOnly = true;
            txtNo.Size = new Size(168, 30);
            txtNo.TabIndex = 1;
            txtNo.TextAlign = HorizontalAlignment.Center;
            // 
            // label9
            // 
            label9.AutoSize = true;
            label9.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label9.Location = new Point(744, 89);
            label9.Name = "label9";
            label9.Size = new Size(57, 23);
            label9.TabIndex = 0;
            label9.Text = "المخزن";
            // 
            // label8
            // 
            label8.AutoSize = true;
            label8.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label8.Location = new Point(1135, 126);
            label8.Name = "label8";
            label8.Size = new Size(45, 23);
            label8.TabIndex = 0;
            label8.Text = "البيان";
            // 
            // lblSupp
            // 
            lblSupp.AutoSize = true;
            lblSupp.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            lblSupp.Location = new Point(750, 51);
            lblSupp.Name = "lblSupp";
            lblSupp.Size = new Size(52, 23);
            lblSupp.TabIndex = 0;
            lblSupp.Text = "المورد";
            lblSupp.Visible = false;
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label5.Location = new Point(1096, 51);
            label5.Name = "label5";
            label5.Size = new Size(84, 23);
            label5.TabIndex = 0;
            label5.Text = "طريقة الدفع";
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label4.Location = new Point(1133, 89);
            label4.Name = "label4";
            label4.Size = new Size(47, 23);
            label4.TabIndex = 0;
            label4.Text = "العملة";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label2.Location = new Point(747, 15);
            label2.Name = "label2";
            label2.Size = new Size(54, 23);
            label2.TabIndex = 0;
            label2.Text = "التاريخ";
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label1.Location = new Point(1139, 15);
            label1.Name = "label1";
            label1.Size = new Size(41, 23);
            label1.TabIndex = 0;
            label1.Text = "الرقم";
            // 
            // txtSuppCode
            // 
            txtSuppCode.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtSuppCode.Location = new Point(367, 47);
            txtSuppCode.Name = "txtSuppCode";
            txtSuppCode.Size = new Size(92, 30);
            txtSuppCode.TabIndex = 8;
            txtSuppCode.Text = "0";
            txtSuppCode.TextAlign = HorizontalAlignment.Center;
            // 
            // label16
            // 
            label16.AutoSize = true;
            label16.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label16.ForeColor = Color.Navy;
            label16.Location = new Point(386, 24);
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
            label15.Location = new Point(528, 24);
            label15.Name = "label15";
            label15.Size = new Size(47, 23);
            label15.TabIndex = 0;
            label15.Text = "السعر";
            // 
            // label14
            // 
            label14.AutoSize = true;
            label14.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label14.ForeColor = Color.Navy;
            label14.Location = new Point(616, 24);
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
            label13.Location = new Point(736, 24);
            label13.Name = "label13";
            label13.Size = new Size(52, 23);
            label13.TabIndex = 0;
            label13.Text = "الوحدة";
            // 
            // label11
            // 
            label11.AutoSize = true;
            label11.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label11.ForeColor = Color.Navy;
            label11.Location = new Point(1082, 24);
            label11.Name = "label11";
            label11.Size = new Size(81, 23);
            label11.TabIndex = 0;
            label11.Text = "رقم الصنف";
            // 
            // txtVATTotal
            // 
            txtVATTotal.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtVATTotal.Location = new Point(886, 631);
            txtVATTotal.Name = "txtVATTotal";
            txtVATTotal.Size = new Size(288, 30);
            txtVATTotal.TabIndex = 18;
            txtVATTotal.Text = "0.00";
            txtVATTotal.TextAlign = HorizontalAlignment.Center;
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
            groupBox2.Controls.Add(label14);
            groupBox2.Controls.Add(label13);
            groupBox2.Controls.Add(label12);
            groupBox2.Controls.Add(label11);
            groupBox2.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            groupBox2.ForeColor = Color.Navy;
            groupBox2.Location = new Point(5, 153);
            groupBox2.Name = "groupBox2";
            groupBox2.Size = new Size(1175, 96);
            groupBox2.TabIndex = 13;
            groupBox2.TabStop = false;
            // 
            // label12
            // 
            label12.AutoSize = true;
            label12.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label12.ForeColor = Color.Navy;
            label12.Location = new Point(940, 24);
            label12.Name = "label12";
            label12.Size = new Size(82, 23);
            label12.TabIndex = 0;
            label12.Text = "إسم الصنف";
            // 
            // frmPurReturnBill
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(1192, 777);
            Controls.Add(groupBox3);
            Controls.Add(txtNetTotal);
            Controls.Add(txtDiscountTotal);
            Controls.Add(txtAllTotal);
            Controls.Add(label23);
            Controls.Add(label22);
            Controls.Add(label21);
            Controls.Add(label20);
            Controls.Add(groupBox4);
            Controls.Add(groupBox1);
            Controls.Add(txtVATTotal);
            Controls.Add(groupBox2);
            Icon = (Icon)resources.GetObject("$this.Icon");
            MaximizeBox = false;
            MinimizeBox = false;
            Name = "frmPurReturnBill";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "فاتورة مرتجع الشراء";
            Load += frmPurReturnBill_Load;
            groupBox3.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)dgvData).EndInit();
            cms.ResumeLayout(false);
            groupBox4.ResumeLayout(false);
            groupBox1.ResumeLayout(false);
            groupBox1.PerformLayout();
            groupBox2.ResumeLayout(false);
            groupBox2.PerformLayout();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private DataGridViewTextBoxColumn CatNo;
        private DataGridViewTextBoxColumn VATT;
        private DataGridViewTextBoxColumn Discount;
        private DataGridViewTextBoxColumn Price;
        private DataGridViewTextBoxColumn Qty;
        private DataGridViewTextBoxColumn covertFactor;
        private DataGridViewTextBoxColumn unitName;
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
        private DataGridViewTextBoxColumn unitID;
        private DataGridViewTextBoxColumn ProdName;
        private DataGridViewTextBoxColumn prodNo;
        private DataGridViewTextBoxColumn TotalNet;
        private GroupBox groupBox3;
        private DataGridView dgvData;
        private DataGridViewTextBoxColumn Column12;
        private DataGridViewTextBoxColumn Column13;
        private DataGridViewTextBoxColumn Column19;
        private DataGridViewTextBoxColumn Column20;
        private DataGridViewTextBoxColumn Column21;
        private DataGridViewTextBoxColumn Column22;
        private DataGridViewTextBoxColumn Column23;
        private ContextMenuStrip cms;
        private ToolStripMenuItem add;
        private ToolStripMenuItem edit;
        private ToolStripMenuItem delete;
        private TextBox txtNetTotal;
        private TextBox txtDiscountTotal;
        private TextBox txtAllTotal;
        private Label label23;
        private Label label22;
        private Label label21;
        private Label label20;
        private Button btnExit;
        private GroupBox groupBox4;
        private Button btnPrint;
        private Button btnDel;
        private Button brnEdit;
        private Button btnAdd;
        private Button btnNew;
        private Label label17;
        private TextBox txtFundCode;
        private TextBox txtSaleCost;
        private CheckBox chkPost;
        private Button btnSearch;
        private TextBox txtSearch;
        private Label label10;
        private TextBox txtBNo;
        private Button btnPrev;
        private Button btnNext;
        private ComboBox cbFunds;
        private Button btnFirst;
        private Button btnLast;
        public TextBox txtOpType;
        private TextBox txtJNo;
        private ComboBox cbStores;
        private TextBox txtNote;
        private TextBox txtSuppName;
        private ComboBox cbPaymentMethod;
        private GroupBox groupBox1;
        private Label lblFund;
        private TextBox txtCurrVal;
        private ComboBox cbCurrencies;
        private DateTimePicker dtpDate;
        private TextBox txtNo;
        private Label label9;
        private Label label8;
        private Label lblSupp;
        private Label label5;
        private Label label4;
        private Label label2;
        private Label label1;
        private TextBox txtSuppCode;
        private Label label16;
        private Label label15;
        private Label label14;
        private Label label13;
        private Label label11;
        private TextBox txtVATTotal;
        private GroupBox groupBox2;
        private Label label12;
    }
}