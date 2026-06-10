#pragma warning disable CS0169, CS0649
namespace IntegratedAccSys.PL.Stores
{
    partial class frmCategories
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmCategories));
            groupBox1 = new GroupBox();
            btnExit = new Button();
            btnDel = new Button();
            btnEdit = new Button();
            btnAdd = new Button();
            btnNew = new Button();
            tabPage1 = new TabPage();
            cbStores = new ComboBox();
            lbl1 = new Label();
            label1 = new Label();
            txtCatName = new TextBox();
            dgvData = new DataGridView();
            tabControl = new TabControl();
            tabPage2 = new TabPage();
            txtInventoryAccNo = new TextBox();
            lbl7 = new Label();
            lbl13 = new Label();
            lbl14 = new Label();
            txtCatPurchaseDiscountAccNo = new TextBox();
            txtCatPurchaseReturnAccNo = new TextBox();
            txtCatSaleDiscountAccNo = new TextBox();
            txtCatPurchaseAccNo = new TextBox();
            txtCatSaleVatAccNo = new TextBox();
            txtCatPurchaseVatAccNo = new TextBox();
            txtCatSaleQtyFreeAccNo = new TextBox();
            txtCatSaleRevenuseAccNo = new TextBox();
            txtCatSaleReturnAccNo = new TextBox();
            txtCaPurchaseQtyFreeAccNo = new TextBox();
            txtCatSaleCostAccNo = new TextBox();
            txtCatSaleAccNo = new TextBox();
            lbl15 = new Label();
            lbl11 = new Label();
            lbl12 = new Label();
            lbl17 = new Label();
            lbl10 = new Label();
            lbl16 = new Label();
            label4 = new Label();
            label3 = new Label();
            lbl9 = new Label();
            lbl8 = new Label();
            groupBox1.SuspendLayout();
            tabPage1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)dgvData).BeginInit();
            tabControl.SuspendLayout();
            tabPage2.SuspendLayout();
            SuspendLayout();
            // 
            // groupBox1
            // 
            groupBox1.Controls.Add(btnExit);
            groupBox1.Controls.Add(btnDel);
            groupBox1.Controls.Add(btnEdit);
            groupBox1.Controls.Add(btnAdd);
            groupBox1.Controls.Add(btnNew);
            groupBox1.Dock = DockStyle.Bottom;
            groupBox1.Location = new Point(0, 542);
            groupBox1.Name = "groupBox1";
            groupBox1.Size = new Size(715, 75);
            groupBox1.TabIndex = 17;
            groupBox1.TabStop = false;
            // 
            // btnExit
            // 
            btnExit.BackColor = Color.FromArgb(0, 64, 64);
            btnExit.Image = (Image)resources.GetObject("btnExit.Image");
            btnExit.Location = new Point(15, 16);
            btnExit.Name = "btnExit";
            btnExit.Size = new Size(117, 52);
            btnExit.TabIndex = 4;
            btnExit.UseVisualStyleBackColor = false;
            btnExit.Click += btnExit_Click;
            // 
            // btnDel
            // 
            btnDel.BackColor = Color.FromArgb(0, 64, 64);
            btnDel.Image = (Image)resources.GetObject("btnDel.Image");
            btnDel.Location = new Point(232, 16);
            btnDel.Name = "btnDel";
            btnDel.Size = new Size(117, 52);
            btnDel.TabIndex = 3;
            btnDel.UseVisualStyleBackColor = false;
            btnDel.Click += btnDel_Click;
            // 
            // btnEdit
            // 
            btnEdit.BackColor = Color.FromArgb(0, 64, 64);
            btnEdit.Image = (Image)resources.GetObject("btnEdit.Image");
            btnEdit.Location = new Point(349, 16);
            btnEdit.Name = "btnEdit";
            btnEdit.Size = new Size(117, 52);
            btnEdit.TabIndex = 2;
            btnEdit.UseVisualStyleBackColor = false;
            btnEdit.Click += btnEdit_Click;
            // 
            // btnAdd
            // 
            btnAdd.BackColor = Color.FromArgb(0, 64, 64);
            btnAdd.Image = (Image)resources.GetObject("btnAdd.Image");
            btnAdd.Location = new Point(466, 16);
            btnAdd.Name = "btnAdd";
            btnAdd.Size = new Size(117, 52);
            btnAdd.TabIndex = 1;
            btnAdd.UseVisualStyleBackColor = false;
            btnAdd.Click += btnAdd_Click;
            // 
            // btnNew
            // 
            btnNew.BackColor = Color.FromArgb(0, 64, 64);
            btnNew.Image = (Image)resources.GetObject("btnNew.Image");
            btnNew.Location = new Point(583, 16);
            btnNew.Name = "btnNew";
            btnNew.Size = new Size(117, 52);
            btnNew.TabIndex = 0;
            btnNew.UseVisualStyleBackColor = false;
            btnNew.Click += btnNew_Click;
            // 
            // tabPage1
            // 
            tabPage1.Controls.Add(cbStores);
            tabPage1.Controls.Add(lbl1);
            tabPage1.Controls.Add(label1);
            tabPage1.Controls.Add(txtCatName);
            tabPage1.Controls.Add(dgvData);
            tabPage1.Location = new Point(4, 29);
            tabPage1.Name = "tabPage1";
            tabPage1.Padding = new Padding(3);
            tabPage1.Size = new Size(695, 497);
            tabPage1.TabIndex = 0;
            tabPage1.Text = "المجموعات المخزنية";
            tabPage1.UseVisualStyleBackColor = true;
            // 
            // cbStores
            // 
            cbStores.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            cbStores.FormattingEnabled = true;
            cbStores.Location = new Point(47, 304);
            cbStores.Margin = new Padding(3, 4, 3, 4);
            cbStores.Name = "cbStores";
            cbStores.Size = new Size(428, 31);
            cbStores.TabIndex = 21;
            // 
            // lbl1
            // 
            lbl1.AutoSize = true;
            lbl1.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lbl1.ForeColor = Color.Blue;
            lbl1.Location = new Point(563, 308);
            lbl1.Name = "lbl1";
            lbl1.Size = new Size(57, 23);
            lbl1.TabIndex = 22;
            lbl1.Text = "المخزن";
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label1.Location = new Point(519, 345);
            label1.Name = "label1";
            label1.Size = new Size(101, 23);
            label1.TabIndex = 17;
            label1.Text = "إسم المجموعة";
            // 
            // txtCatName
            // 
            txtCatName.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtCatName.Location = new Point(47, 341);
            txtCatName.Name = "txtCatName";
            txtCatName.Size = new Size(428, 30);
            txtCatName.TabIndex = 19;
            // 
            // dgvData
            // 
            dgvData.AllowUserToAddRows = false;
            dgvData.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            dgvData.BackgroundColor = Color.Azure;
            dgvData.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            dgvData.Dock = DockStyle.Top;
            dgvData.GridColor = Color.FromArgb(0, 64, 0);
            dgvData.Location = new Point(3, 3);
            dgvData.Name = "dgvData";
            dgvData.RowHeadersVisible = false;
            dgvData.RowHeadersWidth = 51;
            dgvData.Size = new Size(689, 265);
            dgvData.TabIndex = 13;
            dgvData.CellDoubleClick += dgvData_CellDoubleClick;
            // 
            // tabControl
            // 
            tabControl.Controls.Add(tabPage1);
            tabControl.Controls.Add(tabPage2);
            tabControl.Location = new Point(12, 22);
            tabControl.Name = "tabControl";
            tabControl.RightToLeft = RightToLeft.Yes;
            tabControl.RightToLeftLayout = true;
            tabControl.SelectedIndex = 0;
            tabControl.Size = new Size(703, 530);
            tabControl.TabIndex = 18;
            // 
            // tabPage2
            // 
            tabPage2.Controls.Add(txtInventoryAccNo);
            tabPage2.Controls.Add(lbl7);
            tabPage2.Controls.Add(lbl13);
            tabPage2.Controls.Add(lbl14);
            tabPage2.Controls.Add(txtCatPurchaseDiscountAccNo);
            tabPage2.Controls.Add(txtCatPurchaseReturnAccNo);
            tabPage2.Controls.Add(txtCatSaleDiscountAccNo);
            tabPage2.Controls.Add(txtCatPurchaseAccNo);
            tabPage2.Controls.Add(txtCatSaleVatAccNo);
            tabPage2.Controls.Add(txtCatPurchaseVatAccNo);
            tabPage2.Controls.Add(txtCatSaleQtyFreeAccNo);
            tabPage2.Controls.Add(txtCatSaleRevenuseAccNo);
            tabPage2.Controls.Add(txtCatSaleReturnAccNo);
            tabPage2.Controls.Add(txtCaPurchaseQtyFreeAccNo);
            tabPage2.Controls.Add(txtCatSaleCostAccNo);
            tabPage2.Controls.Add(txtCatSaleAccNo);
            tabPage2.Controls.Add(lbl15);
            tabPage2.Controls.Add(lbl11);
            tabPage2.Controls.Add(lbl12);
            tabPage2.Controls.Add(lbl17);
            tabPage2.Controls.Add(lbl10);
            tabPage2.Controls.Add(lbl16);
            tabPage2.Controls.Add(label4);
            tabPage2.Controls.Add(label3);
            tabPage2.Controls.Add(lbl9);
            tabPage2.Controls.Add(lbl8);
            tabPage2.Location = new Point(4, 29);
            tabPage2.Name = "tabPage2";
            tabPage2.Padding = new Padding(3);
            tabPage2.RightToLeft = RightToLeft.No;
            tabPage2.Size = new Size(695, 497);
            tabPage2.TabIndex = 1;
            tabPage2.Text = "الحسابات";
            tabPage2.UseVisualStyleBackColor = true;
            // 
            // txtInventoryAccNo
            // 
            txtInventoryAccNo.BackColor = Color.LightPink;
            txtInventoryAccNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            txtInventoryAccNo.Location = new Point(141, 13);
            txtInventoryAccNo.Margin = new Padding(3, 4, 3, 4);
            txtInventoryAccNo.Name = "txtInventoryAccNo";
            txtInventoryAccNo.Size = new Size(274, 30);
            txtInventoryAccNo.TabIndex = 46;
            txtInventoryAccNo.KeyDown += txtInventoryAccNo_KeyDown;
            // 
            // lbl7
            // 
            lbl7.AutoSize = true;
            lbl7.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lbl7.ForeColor = Color.Blue;
            lbl7.Location = new Point(568, 20);
            lbl7.Name = "lbl7";
            lbl7.Size = new Size(111, 23);
            lbl7.TabIndex = 47;
            lbl7.Text = "حساب المخزون";
            // 
            // lbl13
            // 
            lbl13.AutoSize = true;
            lbl13.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lbl13.ForeColor = Color.Blue;
            lbl13.Location = new Point(496, 430);
            lbl13.Name = "lbl13";
            lbl13.Size = new Size(180, 23);
            lbl13.TabIndex = 44;
            lbl13.Text = "حساب مشتريات المجموعة";
            // 
            // lbl14
            // 
            lbl14.AutoSize = true;
            lbl14.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lbl14.ForeColor = Color.Blue;
            lbl14.Location = new Point(457, 462);
            lbl14.Name = "lbl14";
            lbl14.Size = new Size(219, 23);
            lbl14.TabIndex = 43;
            lbl14.Text = "حساب مردودات شراء المجموعة";
            // 
            // txtCatPurchaseDiscountAccNo
            // 
            txtCatPurchaseDiscountAccNo.BackColor = Color.Honeydew;
            txtCatPurchaseDiscountAccNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            txtCatPurchaseDiscountAccNo.Location = new Point(26, 322);
            txtCatPurchaseDiscountAccNo.Margin = new Padding(3, 4, 3, 4);
            txtCatPurchaseDiscountAccNo.Name = "txtCatPurchaseDiscountAccNo";
            txtCatPurchaseDiscountAccNo.Size = new Size(386, 30);
            txtCatPurchaseDiscountAccNo.TabIndex = 34;
            txtCatPurchaseDiscountAccNo.TextAlign = HorizontalAlignment.Center;
            txtCatPurchaseDiscountAccNo.KeyDown += txtCatPurchaseDiscountAccNo_KeyDown;
            // 
            // txtCatPurchaseReturnAccNo
            // 
            txtCatPurchaseReturnAccNo.BackColor = SystemColors.Info;
            txtCatPurchaseReturnAccNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            txtCatPurchaseReturnAccNo.Location = new Point(26, 454);
            txtCatPurchaseReturnAccNo.Margin = new Padding(3, 4, 3, 4);
            txtCatPurchaseReturnAccNo.Name = "txtCatPurchaseReturnAccNo";
            txtCatPurchaseReturnAccNo.Size = new Size(386, 30);
            txtCatPurchaseReturnAccNo.TabIndex = 32;
            txtCatPurchaseReturnAccNo.TextAlign = HorizontalAlignment.Center;
            txtCatPurchaseReturnAccNo.KeyDown += txtCatPurchaseReturnAccNo_KeyDown;
            // 
            // txtCatSaleDiscountAccNo
            // 
            txtCatSaleDiscountAccNo.BackColor = Color.Honeydew;
            txtCatSaleDiscountAccNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            txtCatSaleDiscountAccNo.Location = new Point(26, 67);
            txtCatSaleDiscountAccNo.Margin = new Padding(3, 4, 3, 4);
            txtCatSaleDiscountAccNo.Name = "txtCatSaleDiscountAccNo";
            txtCatSaleDiscountAccNo.Size = new Size(386, 30);
            txtCatSaleDiscountAccNo.TabIndex = 29;
            txtCatSaleDiscountAccNo.TextAlign = HorizontalAlignment.Center;
            txtCatSaleDiscountAccNo.KeyDown += txtCatSaleDiscountAccNo_KeyDown;
            // 
            // txtCatPurchaseAccNo
            // 
            txtCatPurchaseAccNo.BackColor = SystemColors.Info;
            txtCatPurchaseAccNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            txtCatPurchaseAccNo.Location = new Point(26, 422);
            txtCatPurchaseAccNo.Margin = new Padding(3, 4, 3, 4);
            txtCatPurchaseAccNo.Name = "txtCatPurchaseAccNo";
            txtCatPurchaseAccNo.Size = new Size(386, 30);
            txtCatPurchaseAccNo.TabIndex = 31;
            txtCatPurchaseAccNo.TextAlign = HorizontalAlignment.Center;
            txtCatPurchaseAccNo.KeyDown += txtCatPurchaseAccNo_KeyDown;
            // 
            // txtCatSaleVatAccNo
            // 
            txtCatSaleVatAccNo.BackColor = Color.Honeydew;
            txtCatSaleVatAccNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            txtCatSaleVatAccNo.Location = new Point(26, 100);
            txtCatSaleVatAccNo.Margin = new Padding(3, 4, 3, 4);
            txtCatSaleVatAccNo.Name = "txtCatSaleVatAccNo";
            txtCatSaleVatAccNo.Size = new Size(386, 30);
            txtCatSaleVatAccNo.TabIndex = 30;
            txtCatSaleVatAccNo.TextAlign = HorizontalAlignment.Center;
            txtCatSaleVatAccNo.KeyDown += txtCatSaleVatAccNo_KeyDown;
            // 
            // txtCatPurchaseVatAccNo
            // 
            txtCatPurchaseVatAccNo.BackColor = Color.Honeydew;
            txtCatPurchaseVatAccNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            txtCatPurchaseVatAccNo.Location = new Point(26, 355);
            txtCatPurchaseVatAccNo.Margin = new Padding(3, 4, 3, 4);
            txtCatPurchaseVatAccNo.Name = "txtCatPurchaseVatAccNo";
            txtCatPurchaseVatAccNo.Size = new Size(386, 30);
            txtCatPurchaseVatAccNo.TabIndex = 35;
            txtCatPurchaseVatAccNo.TextAlign = HorizontalAlignment.Center;
            txtCatPurchaseVatAccNo.KeyDown += txtCatPurchaseVatAccNo_KeyDown;
            // 
            // txtCatSaleQtyFreeAccNo
            // 
            txtCatSaleQtyFreeAccNo.BackColor = Color.Honeydew;
            txtCatSaleQtyFreeAccNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            txtCatSaleQtyFreeAccNo.Location = new Point(26, 133);
            txtCatSaleQtyFreeAccNo.Margin = new Padding(3, 4, 3, 4);
            txtCatSaleQtyFreeAccNo.Name = "txtCatSaleQtyFreeAccNo";
            txtCatSaleQtyFreeAccNo.Size = new Size(386, 30);
            txtCatSaleQtyFreeAccNo.TabIndex = 28;
            txtCatSaleQtyFreeAccNo.TextAlign = HorizontalAlignment.Center;
            txtCatSaleQtyFreeAccNo.KeyDown += txtCatSaleQtyFreeAccNo_KeyDown;
            // 
            // txtCatSaleRevenuseAccNo
            // 
            txtCatSaleRevenuseAccNo.BackColor = SystemColors.Info;
            txtCatSaleRevenuseAccNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            txtCatSaleRevenuseAccNo.Location = new Point(26, 265);
            txtCatSaleRevenuseAccNo.Margin = new Padding(3, 4, 3, 4);
            txtCatSaleRevenuseAccNo.Name = "txtCatSaleRevenuseAccNo";
            txtCatSaleRevenuseAccNo.Size = new Size(386, 30);
            txtCatSaleRevenuseAccNo.TabIndex = 27;
            txtCatSaleRevenuseAccNo.TextAlign = HorizontalAlignment.Center;
            txtCatSaleRevenuseAccNo.KeyDown += txtCatSaleRevenuseAccNo_KeyDown;
            // 
            // txtCatSaleReturnAccNo
            // 
            txtCatSaleReturnAccNo.BackColor = SystemColors.Info;
            txtCatSaleReturnAccNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            txtCatSaleReturnAccNo.Location = new Point(26, 199);
            txtCatSaleReturnAccNo.Margin = new Padding(3, 4, 3, 4);
            txtCatSaleReturnAccNo.Name = "txtCatSaleReturnAccNo";
            txtCatSaleReturnAccNo.Size = new Size(386, 30);
            txtCatSaleReturnAccNo.TabIndex = 27;
            txtCatSaleReturnAccNo.TextAlign = HorizontalAlignment.Center;
            txtCatSaleReturnAccNo.KeyDown += txtCatSaleReturnAccNo_KeyDown;
            // 
            // txtCaPurchaseQtyFreeAccNo
            // 
            txtCaPurchaseQtyFreeAccNo.BackColor = Color.Honeydew;
            txtCaPurchaseQtyFreeAccNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            txtCaPurchaseQtyFreeAccNo.Location = new Point(26, 389);
            txtCaPurchaseQtyFreeAccNo.Margin = new Padding(3, 4, 3, 4);
            txtCaPurchaseQtyFreeAccNo.Name = "txtCaPurchaseQtyFreeAccNo";
            txtCaPurchaseQtyFreeAccNo.Size = new Size(386, 30);
            txtCaPurchaseQtyFreeAccNo.TabIndex = 33;
            txtCaPurchaseQtyFreeAccNo.TextAlign = HorizontalAlignment.Center;
            txtCaPurchaseQtyFreeAccNo.KeyDown += txtCaPurchaseQtyFreeAccNo_KeyDown;
            // 
            // txtCatSaleCostAccNo
            // 
            txtCatSaleCostAccNo.BackColor = SystemColors.Info;
            txtCatSaleCostAccNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            txtCatSaleCostAccNo.Location = new Point(26, 232);
            txtCatSaleCostAccNo.Margin = new Padding(3, 4, 3, 4);
            txtCatSaleCostAccNo.Name = "txtCatSaleCostAccNo";
            txtCatSaleCostAccNo.Size = new Size(386, 30);
            txtCatSaleCostAccNo.TabIndex = 26;
            txtCatSaleCostAccNo.TextAlign = HorizontalAlignment.Center;
            txtCatSaleCostAccNo.KeyDown += txtCatSaleCostAccNo_KeyDown;
            // 
            // txtCatSaleAccNo
            // 
            txtCatSaleAccNo.BackColor = SystemColors.Info;
            txtCatSaleAccNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            txtCatSaleAccNo.Location = new Point(26, 166);
            txtCatSaleAccNo.Margin = new Padding(3, 4, 3, 4);
            txtCatSaleAccNo.Name = "txtCatSaleAccNo";
            txtCatSaleAccNo.Size = new Size(386, 30);
            txtCatSaleAccNo.TabIndex = 26;
            txtCatSaleAccNo.TextAlign = HorizontalAlignment.Center;
            txtCatSaleAccNo.KeyDown += txtCatSaleAccNo_KeyDown;
            // 
            // lbl15
            // 
            lbl15.AutoSize = true;
            lbl15.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lbl15.ForeColor = Color.Blue;
            lbl15.Location = new Point(425, 396);
            lbl15.Name = "lbl15";
            lbl15.Size = new Size(251, 23);
            lbl15.TabIndex = 41;
            lbl15.Text = "حساب ك المجانية مشتريات المجموعة";
            // 
            // lbl11
            // 
            lbl11.AutoSize = true;
            lbl11.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lbl11.ForeColor = Color.Blue;
            lbl11.Location = new Point(442, 104);
            lbl11.Name = "lbl11";
            lbl11.Size = new Size(234, 23);
            lbl11.TabIndex = 36;
            lbl11.Text = "خساب ق المظافة مبيعات المجموعة";
            // 
            // lbl12
            // 
            lbl12.AutoSize = true;
            lbl12.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lbl12.ForeColor = Color.Blue;
            lbl12.Location = new Point(499, 70);
            lbl12.Name = "lbl12";
            lbl12.Size = new Size(177, 23);
            lbl12.TabIndex = 38;
            lbl12.Text = "حساب الخصم المسموح به";
            // 
            // lbl17
            // 
            lbl17.AutoSize = true;
            lbl17.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lbl17.ForeColor = Color.Blue;
            lbl17.Location = new Point(521, 328);
            lbl17.Name = "lbl17";
            lbl17.Size = new Size(155, 23);
            lbl17.TabIndex = 39;
            lbl17.Text = "حساب الخصم المكتسب";
            // 
            // lbl10
            // 
            lbl10.AutoSize = true;
            lbl10.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lbl10.ForeColor = Color.Blue;
            lbl10.Location = new Point(439, 138);
            lbl10.Name = "lbl10";
            lbl10.Size = new Size(237, 23);
            lbl10.TabIndex = 40;
            lbl10.Text = "حساب ك المجانية مبيعات المجموعة";
            // 
            // lbl16
            // 
            lbl16.AutoSize = true;
            lbl16.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lbl16.ForeColor = Color.Blue;
            lbl16.Location = new Point(418, 362);
            lbl16.Name = "lbl16";
            lbl16.Size = new Size(258, 23);
            lbl16.TabIndex = 37;
            lbl16.Text = "خساب ق المضافة مشتريات  المجموعة";
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            label4.ForeColor = Color.Blue;
            label4.Location = new Point(457, 274);
            label4.Name = "label4";
            label4.Size = new Size(217, 23);
            label4.TabIndex = 42;
            label4.Text = "حساب إيرادات مبيعات المجموعة";
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            label3.ForeColor = Color.Blue;
            label3.Location = new Point(474, 240);
            label3.Name = "label3";
            label3.Size = new Size(202, 23);
            label3.TabIndex = 45;
            label3.Text = "حساب تكلفة مبيعات المجموعة";
            // 
            // lbl9
            // 
            lbl9.AutoSize = true;
            lbl9.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lbl9.ForeColor = Color.Blue;
            lbl9.Location = new Point(448, 206);
            lbl9.Name = "lbl9";
            lbl9.Size = new Size(228, 23);
            lbl9.TabIndex = 42;
            lbl9.Text = "حساب مردودات مبيعات المجموعة";
            // 
            // lbl8
            // 
            lbl8.AutoSize = true;
            lbl8.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lbl8.ForeColor = Color.Blue;
            lbl8.Location = new Point(510, 172);
            lbl8.Name = "lbl8";
            lbl8.Size = new Size(166, 23);
            lbl8.TabIndex = 45;
            lbl8.Text = "حساب مبيعات المجموعة";
            // 
            // frmCategories
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(715, 617);
            Controls.Add(tabControl);
            Controls.Add(groupBox1);
            Icon = (Icon)resources.GetObject("$this.Icon");
            MaximizeBox = false;
            MinimizeBox = false;
            Name = "frmCategories";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "المجموعات المخزنية";
            Load += frmCategories_Load;
            groupBox1.ResumeLayout(false);
            tabPage1.ResumeLayout(false);
            tabPage1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)dgvData).EndInit();
            tabControl.ResumeLayout(false);
            tabPage2.ResumeLayout(false);
            tabPage2.PerformLayout();
            ResumeLayout(false);
        }

        #endregion

        private GroupBox groupBox1;
        private Button btnExit;
        private Button btnDel;
        private Button btnEdit;
        private Button btnAdd;
        private Button btnNew;
        private TabPage tabPage1;
        private Label label1;
        private TextBox txtInvCode;
        private TextBox txtCatName;
        private Label label2;
        private DataGridView dgvData;
        private TabControl tabControl;
        private TabPage tabPage2;
        private Label lbl13;
        private Label lbl14;
        private TextBox txtCatPurchaseDiscountAccNo;
        private TextBox txtCatPurchaseReturnAccNo;
        private TextBox txtCatSaleDiscountAccNo;
        private TextBox txtCatPurchaseAccNo;
        private TextBox txtCatSaleVatAccNo;
        private TextBox txtCatPurchaseVatAccNo;
        private TextBox txtCatSaleQtyFreeAccNo;
        private TextBox txtCatSaleReturnAccNo;
        private TextBox txtCaPurchaseQtyFreeAccNo;
        private TextBox txtCatSaleAccNo;
        private Label lbl15;
        private Label lbl11;
        private Label lbl12;
        private Label lbl17;
        private Label lbl10;
        private Label lbl16;
        private Label lbl9;
        private Label lbl8;
        private TextBox txtInventoryAccNo;
        private Label lbl7;
        private ComboBox cbStores;
        private Label lbl1;
        private TextBox txtCatSaleRevenuseAccNo;
        private TextBox txtCatSaleCostAccNo;
        private Label label4;
        private Label label3;
    }
}