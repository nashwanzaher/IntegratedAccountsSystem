namespace IntegratedAccSys.PL.Bonds
{
    partial class frmBonds
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmBonds));
            DataGridViewCellStyle dataGridViewCellStyle1 = new DataGridViewCellStyle();
            DataGridViewCellStyle dataGridViewCellStyle2 = new DataGridViewCellStyle();
            DataGridViewCellStyle dataGridViewCellStyle3 = new DataGridViewCellStyle();
            label1 = new Label();
            label2 = new Label();
            label4 = new Label();
            label5 = new Label();
            label6 = new Label();
            label7 = new Label();
            label8 = new Label();
            label9 = new Label();
            label10 = new Label();
            label11 = new Label();
            label12 = new Label();
            label13 = new Label();
            label14 = new Label();
            label15 = new Label();
            txtBondNo = new TextBox();
            dtpBdate = new DateTimePicker();
            txtNote = new TextBox();
            cbFunds = new ComboBox();
            txtFundCode = new TextBox();
            txtAccNo = new TextBox();
            txtAccName = new TextBox();
            txtAmount = new TextBox();
            cbCurrency = new ComboBox();
            txtCurrVal = new TextBox();
            txtlocalAmount = new TextBox();
            btInsert = new Button();
            dgvData = new DataGridView();
            Column1 = new DataGridViewTextBoxColumn();
            Column2 = new DataGridViewTextBoxColumn();
            Column3 = new DataGridViewTextBoxColumn();
            Column4 = new DataGridViewTextBoxColumn();
            Column5 = new DataGridViewTextBoxColumn();
            Column6 = new DataGridViewTextBoxColumn();
            Column7 = new DataGridViewTextBoxColumn();
            Column8 = new DataGridViewTextBoxColumn();
            cms = new ContextMenuStrip(components);
            btnAddRow = new ToolStripMenuItem();
            btnEditRow = new ToolStripMenuItem();
            btnDelRaw = new ToolStripMenuItem();
            txtUserAdd = new TextBox();
            txtAddDate = new TextBox();
            txtUserEdit = new TextBox();
            txtEditDate = new TextBox();
            groupBox2 = new GroupBox();
            btnFirst = new Button();
            btnPerv = new Button();
            btnNext = new Button();
            btnLast = new Button();
            txtBNo = new TextBox();
            btnSearch = new Button();
            txtSearch = new TextBox();
            groupBox1 = new GroupBox();
            btnExit = new Button();
            btnPrint = new Button();
            btnDel = new Button();
            btnEdit = new Button();
            btnAdd = new Button();
            btnNew = new Button();
            txtBType = new TextBox();
            chkPost = new CheckBox();
            txtJno = new TextBox();
            txtBondTotal = new TextBox();
            label3 = new Label();
            ((System.ComponentModel.ISupportInitialize)dgvData).BeginInit();
            cms.SuspendLayout();
            groupBox2.SuspendLayout();
            groupBox1.SuspendLayout();
            SuspendLayout();
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label1.Location = new Point(6, 31);
            label1.Name = "label1";
            label1.Size = new Size(70, 23);
            label1.TabIndex = 0;
            label1.Text = "رقم السند";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label2.Location = new Point(218, 31);
            label2.Name = "label2";
            label2.Size = new Size(83, 23);
            label2.TabIndex = 1;
            label2.Text = "تاريخ السند";
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label4.Location = new Point(6, 81);
            label4.Name = "label4";
            label4.Size = new Size(45, 23);
            label4.TabIndex = 3;
            label4.Text = "البيان";
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label5.Location = new Point(376, 81);
            label5.Name = "label5";
            label5.Size = new Size(67, 23);
            label5.TabIndex = 4;
            label5.Text = "الصندوق";
            // 
            // label6
            // 
            label6.AutoSize = true;
            label6.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label6.Location = new Point(21, 135);
            label6.Name = "label6";
            label6.Size = new Size(86, 23);
            label6.TabIndex = 5;
            label6.Text = "رقم الحساب";
            // 
            // label7
            // 
            label7.AutoSize = true;
            label7.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label7.Location = new Point(181, 135);
            label7.Name = "label7";
            label7.Size = new Size(87, 23);
            label7.TabIndex = 6;
            label7.Text = "إسم الحساب";
            // 
            // label8
            // 
            label8.AutoSize = true;
            label8.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label8.Location = new Point(501, 135);
            label8.Name = "label8";
            label8.Size = new Size(46, 23);
            label8.TabIndex = 7;
            label8.Text = "المبلغ";
            // 
            // label9
            // 
            label9.AutoSize = true;
            label9.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label9.Location = new Point(624, 135);
            label9.Name = "label9";
            label9.Size = new Size(47, 23);
            label9.TabIndex = 8;
            label9.Text = "العملة";
            // 
            // label10
            // 
            label10.AutoSize = true;
            label10.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label10.Location = new Point(797, 135);
            label10.Name = "label10";
            label10.Size = new Size(58, 23);
            label10.TabIndex = 9;
            label10.Text = "الصرف";
            // 
            // label11
            // 
            label11.AutoSize = true;
            label11.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label11.Location = new Point(928, 135);
            label11.Name = "label11";
            label11.Size = new Size(144, 23);
            label11.TabIndex = 10;
            label11.Text = "المبلغ بالعملة المحلية";
            // 
            // label12
            // 
            label12.AutoSize = true;
            label12.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label12.Location = new Point(35, 544);
            label12.Name = "label12";
            label12.Size = new Size(68, 23);
            label12.TabIndex = 11;
            label12.Text = "المستخدم";
            // 
            // label13
            // 
            label13.AutoSize = true;
            label13.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label13.Location = new Point(268, 544);
            label13.Name = "label13";
            label13.Size = new Size(95, 23);
            label13.TabIndex = 12;
            label13.Text = "تاريخ الإدخال";
            // 
            // label14
            // 
            label14.AutoSize = true;
            label14.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label14.Location = new Point(599, 544);
            label14.Name = "label14";
            label14.Size = new Size(68, 23);
            label14.TabIndex = 13;
            label14.Text = "المستخدم";
            // 
            // label15
            // 
            label15.AutoSize = true;
            label15.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label15.Location = new Point(832, 544);
            label15.Name = "label15";
            label15.Size = new Size(92, 23);
            label15.TabIndex = 14;
            label15.Text = "تاريخ التعديل";
            // 
            // txtBondNo
            // 
            txtBondNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtBondNo.Location = new Point(80, 27);
            txtBondNo.Name = "txtBondNo";
            txtBondNo.Size = new Size(125, 30);
            txtBondNo.TabIndex = 15;
            // 
            // dtpBdate
            // 
            dtpBdate.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            dtpBdate.Location = new Point(307, 25);
            dtpBdate.Name = "dtpBdate";
            dtpBdate.Size = new Size(218, 30);
            dtpBdate.TabIndex = 16;
            // 
            // txtNote
            // 
            txtNote.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtNote.Location = new Point(69, 77);
            txtNote.Name = "txtNote";
            txtNote.Size = new Size(292, 30);
            txtNote.TabIndex = 19;
            // 
            // cbFunds
            // 
            cbFunds.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            cbFunds.FormattingEnabled = true;
            cbFunds.Location = new Point(447, 77);
            cbFunds.Name = "cbFunds";
            cbFunds.Size = new Size(190, 31);
            cbFunds.TabIndex = 20;
            cbFunds.SelectedIndexChanged += cbFunds_SelectedIndexChanged;
            // 
            // txtFundCode
            // 
            txtFundCode.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtFundCode.Location = new Point(643, 77);
            txtFundCode.Name = "txtFundCode";
            txtFundCode.Size = new Size(146, 30);
            txtFundCode.TabIndex = 21;
            // 
            // txtAccNo
            // 
            txtAccNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtAccNo.Location = new Point(25, 161);
            txtAccNo.Name = "txtAccNo";
            txtAccNo.Size = new Size(145, 30);
            txtAccNo.TabIndex = 22;
            txtAccNo.KeyDown += txtAccNo_KeyDown;
            // 
            // txtAccName
            // 
            txtAccName.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtAccName.Location = new Point(179, 161);
            txtAccName.Name = "txtAccName";
            txtAccName.Size = new Size(295, 30);
            txtAccName.TabIndex = 23;
            // 
            // txtAmount
            // 
            txtAmount.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtAmount.Location = new Point(483, 161);
            txtAmount.Name = "txtAmount";
            txtAmount.Size = new Size(125, 30);
            txtAmount.TabIndex = 24;
            txtAmount.Text = "0.00";
            txtAmount.TextAlign = HorizontalAlignment.Center;
            txtAmount.TextChanged += txtAmount_TextChanged;
            // 
            // cbCurrency
            // 
            cbCurrency.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            cbCurrency.FormattingEnabled = true;
            cbCurrency.Location = new Point(617, 161);
            cbCurrency.Name = "cbCurrency";
            cbCurrency.Size = new Size(167, 31);
            cbCurrency.TabIndex = 25;
            cbCurrency.SelectedIndexChanged += cbCurrency_SelectedIndexChanged;
            // 
            // txtCurrVal
            // 
            txtCurrVal.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtCurrVal.Location = new Point(793, 161);
            txtCurrVal.Name = "txtCurrVal";
            txtCurrVal.Size = new Size(125, 30);
            txtCurrVal.TabIndex = 26;
            txtCurrVal.Text = "0.00";
            txtCurrVal.TextAlign = HorizontalAlignment.Center;
            txtCurrVal.TextChanged += txtCurrVal_TextChanged;
            // 
            // txtlocalAmount
            // 
            txtlocalAmount.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtlocalAmount.Location = new Point(927, 161);
            txtlocalAmount.Name = "txtlocalAmount";
            txtlocalAmount.ReadOnly = true;
            txtlocalAmount.Size = new Size(150, 30);
            txtlocalAmount.TabIndex = 27;
            // 
            // btInsert
            // 
            btInsert.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btInsert.Image = (Image)resources.GetObject("btInsert.Image");
            btInsert.Location = new Point(1094, 131);
            btInsert.Name = "btInsert";
            btInsert.Size = new Size(56, 60);
            btInsert.TabIndex = 28;
            btInsert.UseVisualStyleBackColor = true;
            btInsert.Click += btInsert_Click;
            // 
            // dgvData
            // 
            dgvData.AllowUserToAddRows = false;
            dataGridViewCellStyle1.Alignment = DataGridViewContentAlignment.MiddleCenter;
            dataGridViewCellStyle1.BackColor = Color.LightSkyBlue;
            dataGridViewCellStyle1.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            dataGridViewCellStyle1.ForeColor = Color.Red;
            dgvData.AlternatingRowsDefaultCellStyle = dataGridViewCellStyle1;
            dgvData.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            dgvData.BackgroundColor = Color.Azure;
            dataGridViewCellStyle2.Alignment = DataGridViewContentAlignment.MiddleCenter;
            dataGridViewCellStyle2.BackColor = SystemColors.Control;
            dataGridViewCellStyle2.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            dataGridViewCellStyle2.ForeColor = SystemColors.WindowText;
            dataGridViewCellStyle2.SelectionBackColor = SystemColors.Highlight;
            dataGridViewCellStyle2.SelectionForeColor = SystemColors.HighlightText;
            dataGridViewCellStyle2.WrapMode = DataGridViewTriState.True;
            dgvData.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle2;
            dgvData.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            dgvData.Columns.AddRange(new DataGridViewColumn[] { Column1, Column2, Column3, Column4, Column5, Column6, Column7, Column8 });
            dgvData.ContextMenuStrip = cms;
            dgvData.GridColor = Color.Blue;
            dgvData.Location = new Point(12, 198);
            dgvData.Name = "dgvData";
            dgvData.RowHeadersVisible = false;
            dgvData.RowHeadersWidth = 51;
            dataGridViewCellStyle3.Alignment = DataGridViewContentAlignment.MiddleCenter;
            dataGridViewCellStyle3.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            dataGridViewCellStyle3.ForeColor = Color.Navy;
            dgvData.RowsDefaultCellStyle = dataGridViewCellStyle3;
            dgvData.Size = new Size(1151, 293);
            dgvData.TabIndex = 29;
            // 
            // Column1
            // 
            Column1.HeaderText = "رقم الحساب";
            Column1.MinimumWidth = 6;
            Column1.Name = "Column1";
            // 
            // Column2
            // 
            Column2.HeaderText = "إسم الحساب";
            Column2.MinimumWidth = 6;
            Column2.Name = "Column2";
            // 
            // Column3
            // 
            Column3.HeaderText = "المبلغ";
            Column3.MinimumWidth = 6;
            Column3.Name = "Column3";
            // 
            // Column4
            // 
            Column4.HeaderText = "رقم العملة";
            Column4.MinimumWidth = 6;
            Column4.Name = "Column4";
            // 
            // Column5
            // 
            Column5.HeaderText = "إسم العملة";
            Column5.MinimumWidth = 6;
            Column5.Name = "Column5";
            // 
            // Column6
            // 
            Column6.HeaderText = "الصرف";
            Column6.MinimumWidth = 6;
            Column6.Name = "Column6";
            // 
            // Column7
            // 
            Column7.HeaderText = "إجمالي المبلغ";
            Column7.MinimumWidth = 6;
            Column7.Name = "Column7";
            // 
            // Column8
            // 
            Column8.HeaderText = "رقم السند";
            Column8.MinimumWidth = 6;
            Column8.Name = "Column8";
            // 
            // cms
            // 
            cms.ImageScalingSize = new Size(20, 20);
            cms.Items.AddRange(new ToolStripItem[] { btnAddRow, btnEditRow, btnDelRaw });
            cms.Name = "cms";
            cms.RightToLeft = RightToLeft.Yes;
            cms.Size = new Size(169, 118);
            // 
            // btnAddRow
            // 
            btnAddRow.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnAddRow.Image = (Image)resources.GetObject("btnAddRow.Image");
            btnAddRow.ImageScaling = ToolStripItemImageScaling.None;
            btnAddRow.Name = "btnAddRow";
            btnAddRow.Size = new Size(168, 38);
            btnAddRow.Text = "إضافة صف";
            btnAddRow.Click += btnAddRow_Click;
            // 
            // btnEditRow
            // 
            btnEditRow.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnEditRow.Image = (Image)resources.GetObject("btnEditRow.Image");
            btnEditRow.ImageScaling = ToolStripItemImageScaling.None;
            btnEditRow.Name = "btnEditRow";
            btnEditRow.Size = new Size(168, 38);
            btnEditRow.Text = "تعديل صف";
            btnEditRow.Click += btnEditRow_Click;
            // 
            // btnDelRaw
            // 
            btnDelRaw.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnDelRaw.Image = (Image)resources.GetObject("btnDelRaw.Image");
            btnDelRaw.ImageScaling = ToolStripItemImageScaling.None;
            btnDelRaw.Name = "btnDelRaw";
            btnDelRaw.Size = new Size(168, 38);
            btnDelRaw.Text = "خذف صف";
            btnDelRaw.Click += btnDelRaw_Click;
            // 
            // txtUserAdd
            // 
            txtUserAdd.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtUserAdd.Location = new Point(123, 540);
            txtUserAdd.Name = "txtUserAdd";
            txtUserAdd.Size = new Size(125, 30);
            txtUserAdd.TabIndex = 30;
            // 
            // txtAddDate
            // 
            txtAddDate.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtAddDate.Location = new Point(383, 540);
            txtAddDate.Name = "txtAddDate";
            txtAddDate.Size = new Size(196, 30);
            txtAddDate.TabIndex = 31;
            // 
            // txtUserEdit
            // 
            txtUserEdit.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtUserEdit.Location = new Point(687, 540);
            txtUserEdit.Name = "txtUserEdit";
            txtUserEdit.Size = new Size(125, 30);
            txtUserEdit.TabIndex = 32;
            // 
            // txtEditDate
            // 
            txtEditDate.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtEditDate.Location = new Point(944, 540);
            txtEditDate.Name = "txtEditDate";
            txtEditDate.Size = new Size(196, 30);
            txtEditDate.TabIndex = 33;
            // 
            // groupBox2
            // 
            groupBox2.Controls.Add(btnFirst);
            groupBox2.Controls.Add(btnPerv);
            groupBox2.Controls.Add(btnNext);
            groupBox2.Controls.Add(btnLast);
            groupBox2.Controls.Add(txtBNo);
            groupBox2.Location = new Point(800, 5);
            groupBox2.Name = "groupBox2";
            groupBox2.Size = new Size(372, 65);
            groupBox2.TabIndex = 47;
            groupBox2.TabStop = false;
            // 
            // btnFirst
            // 
            btnFirst.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnFirst.Image = (Image)resources.GetObject("btnFirst.Image");
            btnFirst.Location = new Point(17, 19);
            btnFirst.Name = "btnFirst";
            btnFirst.Size = new Size(59, 29);
            btnFirst.TabIndex = 11;
            btnFirst.UseVisualStyleBackColor = true;
            btnFirst.Click += btnFirst_Click;
            // 
            // btnPerv
            // 
            btnPerv.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnPerv.Image = (Image)resources.GetObject("btnPerv.Image");
            btnPerv.Location = new Point(80, 19);
            btnPerv.Name = "btnPerv";
            btnPerv.Size = new Size(59, 29);
            btnPerv.TabIndex = 12;
            btnPerv.UseVisualStyleBackColor = true;
            btnPerv.Click += btnPerv_Click;
            // 
            // btnNext
            // 
            btnNext.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnNext.Image = (Image)resources.GetObject("btnNext.Image");
            btnNext.Location = new Point(235, 19);
            btnNext.Name = "btnNext";
            btnNext.Size = new Size(59, 29);
            btnNext.TabIndex = 13;
            btnNext.UseVisualStyleBackColor = true;
            btnNext.Click += btnNext_Click;
            // 
            // btnLast
            // 
            btnLast.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnLast.Image = (Image)resources.GetObject("btnLast.Image");
            btnLast.Location = new Point(298, 19);
            btnLast.Name = "btnLast";
            btnLast.Size = new Size(59, 29);
            btnLast.TabIndex = 14;
            btnLast.UseVisualStyleBackColor = true;
            btnLast.Click += btnLast_Click;
            // 
            // txtBNo
            // 
            txtBNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtBNo.Location = new Point(143, 18);
            txtBNo.Name = "txtBNo";
            txtBNo.ReadOnly = true;
            txtBNo.Size = new Size(88, 30);
            txtBNo.TabIndex = 15;
            txtBNo.Text = "0";
            txtBNo.TextAlign = HorizontalAlignment.Center;
            txtBNo.TextChanged += txtBNo_TextChanged;
            // 
            // btnSearch
            // 
            btnSearch.BackColor = Color.FromArgb(0, 64, 64);
            btnSearch.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnSearch.Image = (Image)resources.GetObject("btnSearch.Image");
            btnSearch.Location = new Point(1083, 70);
            btnSearch.Name = "btnSearch";
            btnSearch.Size = new Size(46, 38);
            btnSearch.TabIndex = 46;
            btnSearch.UseVisualStyleBackColor = false;
            btnSearch.Click += btnSearch_Click;
            // 
            // txtSearch
            // 
            txtSearch.BackColor = Color.FromArgb(192, 255, 255);
            txtSearch.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtSearch.Location = new Point(904, 78);
            txtSearch.Name = "txtSearch";
            txtSearch.Size = new Size(173, 30);
            txtSearch.TabIndex = 45;
            txtSearch.Text = "0";
            txtSearch.TextAlign = HorizontalAlignment.Center;
            // 
            // groupBox1
            // 
            groupBox1.Controls.Add(btnExit);
            groupBox1.Controls.Add(btnPrint);
            groupBox1.Controls.Add(btnDel);
            groupBox1.Controls.Add(btnEdit);
            groupBox1.Controls.Add(btnAdd);
            groupBox1.Controls.Add(btnNew);
            groupBox1.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            groupBox1.Location = new Point(12, 579);
            groupBox1.Name = "groupBox1";
            groupBox1.Size = new Size(1146, 81);
            groupBox1.TabIndex = 48;
            groupBox1.TabStop = false;
            // 
            // btnExit
            // 
            btnExit.BackColor = Color.FromArgb(0, 64, 64);
            btnExit.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnExit.Image = (Image)resources.GetObject("btnExit.Image");
            btnExit.Location = new Point(19, 22);
            btnExit.Name = "btnExit";
            btnExit.Size = new Size(169, 46);
            btnExit.TabIndex = 5;
            btnExit.UseVisualStyleBackColor = false;
            btnExit.Click += btnExit_Click;
            // 
            // btnPrint
            // 
            btnPrint.BackColor = Color.FromArgb(0, 64, 64);
            btnPrint.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnPrint.Image = (Image)resources.GetObject("btnPrint.Image");
            btnPrint.Location = new Point(445, 22);
            btnPrint.Name = "btnPrint";
            btnPrint.Size = new Size(138, 46);
            btnPrint.TabIndex = 4;
            btnPrint.UseVisualStyleBackColor = false;
            btnPrint.Click += btnPrint_Click;
            // 
            // btnDel
            // 
            btnDel.BackColor = Color.FromArgb(0, 64, 64);
            btnDel.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnDel.Image = (Image)resources.GetObject("btnDel.Image");
            btnDel.Location = new Point(583, 22);
            btnDel.Name = "btnDel";
            btnDel.Size = new Size(138, 46);
            btnDel.TabIndex = 3;
            btnDel.UseVisualStyleBackColor = false;
            btnDel.Click += btnDel_Click;
            // 
            // btnEdit
            // 
            btnEdit.BackColor = Color.FromArgb(0, 64, 64);
            btnEdit.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnEdit.Image = (Image)resources.GetObject("btnEdit.Image");
            btnEdit.Location = new Point(721, 22);
            btnEdit.Name = "btnEdit";
            btnEdit.Size = new Size(138, 46);
            btnEdit.TabIndex = 2;
            btnEdit.UseVisualStyleBackColor = false;
            btnEdit.Click += btnEdit_Click;
            // 
            // btnAdd
            // 
            btnAdd.BackColor = Color.FromArgb(0, 64, 64);
            btnAdd.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnAdd.Image = (Image)resources.GetObject("btnAdd.Image");
            btnAdd.Location = new Point(859, 22);
            btnAdd.Name = "btnAdd";
            btnAdd.Size = new Size(138, 46);
            btnAdd.TabIndex = 1;
            btnAdd.UseVisualStyleBackColor = false;
            btnAdd.Click += btnAdd_Click;
            // 
            // btnNew
            // 
            btnNew.BackColor = Color.FromArgb(0, 64, 64);
            btnNew.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnNew.Image = (Image)resources.GetObject("btnNew.Image");
            btnNew.Location = new Point(997, 22);
            btnNew.Name = "btnNew";
            btnNew.Size = new Size(138, 46);
            btnNew.TabIndex = 0;
            btnNew.UseVisualStyleBackColor = false;
            btnNew.Click += btnNew_Click;
            // 
            // txtBType
            // 
            txtBType.Location = new Point(722, 26);
            txtBType.Name = "txtBType";
            txtBType.ReadOnly = true;
            txtBType.Size = new Size(67, 27);
            txtBType.TabIndex = 49;
            // 
            // chkPost
            // 
            chkPost.AutoSize = true;
            chkPost.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            chkPost.Location = new Point(569, 27);
            chkPost.Name = "chkPost";
            chkPost.Size = new Size(68, 27);
            chkPost.TabIndex = 50;
            chkPost.Text = "مرحل";
            chkPost.UseVisualStyleBackColor = true;
            // 
            // txtJno
            // 
            txtJno.Location = new Point(652, 27);
            txtJno.Name = "txtJno";
            txtJno.Size = new Size(61, 27);
            txtJno.TabIndex = 51;
            txtJno.Text = "0";
            // 
            // txtBondTotal
            // 
            txtBondTotal.BackColor = Color.FromArgb(192, 255, 255);
            txtBondTotal.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtBondTotal.Location = new Point(878, 497);
            txtBondTotal.Name = "txtBondTotal";
            txtBondTotal.ReadOnly = true;
            txtBondTotal.Size = new Size(151, 30);
            txtBondTotal.TabIndex = 52;
            txtBondTotal.Text = "0.00";
            txtBondTotal.TextAlign = HorizontalAlignment.Center;
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label3.Location = new Point(763, 500);
            label3.Name = "label3";
            label3.Size = new Size(92, 23);
            label3.TabIndex = 53;
            label3.Text = "إجمالي السند";
            // 
            // frmBonds
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(1175, 665);
            Controls.Add(label3);
            Controls.Add(txtBondTotal);
            Controls.Add(txtJno);
            Controls.Add(chkPost);
            Controls.Add(txtBType);
            Controls.Add(groupBox1);
            Controls.Add(groupBox2);
            Controls.Add(btnSearch);
            Controls.Add(txtSearch);
            Controls.Add(txtEditDate);
            Controls.Add(txtUserEdit);
            Controls.Add(txtAddDate);
            Controls.Add(txtUserAdd);
            Controls.Add(dgvData);
            Controls.Add(btInsert);
            Controls.Add(txtlocalAmount);
            Controls.Add(txtCurrVal);
            Controls.Add(cbCurrency);
            Controls.Add(txtAmount);
            Controls.Add(txtAccName);
            Controls.Add(txtAccNo);
            Controls.Add(txtFundCode);
            Controls.Add(cbFunds);
            Controls.Add(txtNote);
            Controls.Add(dtpBdate);
            Controls.Add(txtBondNo);
            Controls.Add(label15);
            Controls.Add(label14);
            Controls.Add(label13);
            Controls.Add(label12);
            Controls.Add(label11);
            Controls.Add(label10);
            Controls.Add(label9);
            Controls.Add(label8);
            Controls.Add(label7);
            Controls.Add(label6);
            Controls.Add(label5);
            Controls.Add(label4);
            Controls.Add(label2);
            Controls.Add(label1);
            Icon = (Icon)resources.GetObject("$this.Icon");
            Name = "frmBonds";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "0.00";
            Load += frmBonds_Load;
            ((System.ComponentModel.ISupportInitialize)dgvData).EndInit();
            cms.ResumeLayout(false);
            groupBox2.ResumeLayout(false);
            groupBox2.PerformLayout();
            groupBox1.ResumeLayout(false);
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Label label1;
        private Label label2;
        private Label label4;
        private Label label5;
        private Label label6;
        private Label label7;
        private Label label8;
        private Label label9;
        private Label label10;
        private Label label11;
        private Label label12;
        private Label label13;
        private Label label14;
        private Label label15;
        private TextBox txtBondNo;
        private DateTimePicker dtpBdate;
        private TextBox txtNote;
        private ComboBox cbFunds;
        private TextBox txtFundCode;
        private TextBox txtAccNo;
        private TextBox txtAccName;
        private TextBox txtAmount;
        private ComboBox cbCurrency;
        private TextBox txtCurrVal;
        private TextBox txtlocalAmount;
        private Button btInsert;
        private DataGridView dgvData;
        private TextBox txtUserAdd;
        private TextBox txtAddDate;
        private TextBox txtUserEdit;
        private TextBox txtEditDate;
        private GroupBox groupBox2;
        private Button btnFirst;
        private Button btnPerv;
        private Button btnNext;
        private Button btnLast;
        private TextBox txtBNo;
        private Button btnSearch;
        private TextBox txtSearch;
        private GroupBox groupBox1;
        private Button btnExit;
        private Button btnPrint;
        private Button btnDel;
        private Button btnEdit;
        private Button btnAdd;
        private Button btnNew;
        public TextBox txtBType;
        private CheckBox chkPost;
        private DataGridViewTextBoxColumn Column1;
        private DataGridViewTextBoxColumn Column2;
        private DataGridViewTextBoxColumn Column3;
        private DataGridViewTextBoxColumn Column4;
        private DataGridViewTextBoxColumn Column5;
        private DataGridViewTextBoxColumn Column6;
        private DataGridViewTextBoxColumn Column7;
        private DataGridViewTextBoxColumn Column8;
        private TextBox txtJno;
        private TextBox txtBondTotal;
        private Label label3;
        private ContextMenuStrip cms;
        private ToolStripMenuItem btnAddRow;
        private ToolStripMenuItem btnEditRow;
        private ToolStripMenuItem btnDelRaw;
    }
}