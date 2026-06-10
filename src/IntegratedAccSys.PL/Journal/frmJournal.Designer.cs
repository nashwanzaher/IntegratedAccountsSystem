namespace IntegratedAccSys.PL.Journal
{
    partial class frmJournal
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmJournal));
            DataGridViewCellStyle dataGridViewCellStyle1 = new DataGridViewCellStyle();
            DataGridViewCellStyle dataGridViewCellStyle2 = new DataGridViewCellStyle();
            DataGridViewCellStyle dataGridViewCellStyle3 = new DataGridViewCellStyle();
            label1 = new Label();
            txtJNo = new TextBox();
            label2 = new Label();
            dtpJdate = new DateTimePicker();
            label4 = new Label();
            txtJNote = new TextBox();
            label5 = new Label();
            rbGeneral = new RadioButton();
            rbWait = new RadioButton();
            btnFirst = new Button();
            btnPerv = new Button();
            btnNext = new Button();
            btnLast = new Button();
            txtJoNo = new TextBox();
            dgvData = new DataGridView();
            Column1 = new DataGridViewTextBoxColumn();
            Column2 = new DataGridViewTextBoxColumn();
            Column3 = new DataGridViewTextBoxColumn();
            Column4 = new DataGridViewTextBoxColumn();
            Column5 = new DataGridViewTextBoxColumn();
            Column6 = new DataGridViewTextBoxColumn();
            Column7 = new DataGridViewTextBoxColumn();
            Column8 = new DataGridViewTextBoxColumn();
            Column9 = new DataGridViewTextBoxColumn();
            Column10 = new DataGridViewTextBoxColumn();
            Column11 = new DataGridViewTextBoxColumn();
            cms = new ContextMenuStrip(components);
            addrow = new ToolStripMenuItem();
            editRow = new ToolStripMenuItem();
            removeRow = new ToolStripMenuItem();
            label6 = new Label();
            label7 = new Label();
            label8 = new Label();
            label9 = new Label();
            label10 = new Label();
            label11 = new Label();
            label12 = new Label();
            txtAccNo = new TextBox();
            txtAccName = new TextBox();
            txtDebitor = new TextBox();
            txtCreditor = new TextBox();
            cbCurrency = new ComboBox();
            txtCurrVal = new TextBox();
            txtNote = new TextBox();
            btnInsert = new Button();
            groupBox1 = new GroupBox();
            btnExit = new Button();
            btnPrint = new Button();
            btnDel = new Button();
            btnEdit = new Button();
            btnAdd = new Button();
            btnNew = new Button();
            label13 = new Label();
            txtInsUser = new TextBox();
            label14 = new Label();
            txtInsDate = new TextBox();
            label15 = new Label();
            txtEditUser = new TextBox();
            label16 = new Label();
            txtEditDate = new TextBox();
            txtSearch = new TextBox();
            btnSearch = new Button();
            rbrev = new RadioButton();
            groupBox2 = new GroupBox();
            groupBox3 = new GroupBox();
            chkPost = new CheckBox();
            label17 = new Label();
            label18 = new Label();
            label19 = new Label();
            txtDebitTotal = new TextBox();
            txtCreditTotal = new TextBox();
            txtBalance = new TextBox();
            txtOPtype = new TextBox();
            ((System.ComponentModel.ISupportInitialize)dgvData).BeginInit();
            cms.SuspendLayout();
            groupBox1.SuspendLayout();
            groupBox2.SuspendLayout();
            groupBox3.SuspendLayout();
            SuspendLayout();
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label1.Location = new Point(30, 26);
            label1.Name = "label1";
            label1.Size = new Size(81, 23);
            label1.TabIndex = 0;
            label1.Text = "رقم اليومية";
            // 
            // txtJNo
            // 
            txtJNo.BackColor = Color.FromArgb(192, 255, 255);
            txtJNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtJNo.Location = new Point(124, 22);
            txtJNo.Name = "txtJNo";
            txtJNo.ReadOnly = true;
            txtJNo.Size = new Size(125, 30);
            txtJNo.TabIndex = 1;
            txtJNo.Text = "0";
            txtJNo.TextAlign = HorizontalAlignment.Center;
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label2.Location = new Point(265, 26);
            label2.Name = "label2";
            label2.Size = new Size(54, 23);
            label2.TabIndex = 2;
            label2.Text = "التاريخ";
            // 
            // dtpJdate
            // 
            dtpJdate.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            dtpJdate.Location = new Point(335, 22);
            dtpJdate.Name = "dtpJdate";
            dtpJdate.Size = new Size(250, 30);
            dtpJdate.TabIndex = 3;
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label4.Location = new Point(27, 78);
            label4.Name = "label4";
            label4.Size = new Size(45, 23);
            label4.TabIndex = 6;
            label4.Text = "البيان";
            // 
            // txtJNote
            // 
            txtJNote.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtJNote.Location = new Point(89, 74);
            txtJNote.Name = "txtJNote";
            txtJNote.Size = new Size(496, 30);
            txtJNote.TabIndex = 7;
            txtJNote.TextAlign = HorizontalAlignment.Center;
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label5.Location = new Point(601, 78);
            label5.Name = "label5";
            label5.Size = new Size(67, 23);
            label5.TabIndex = 8;
            label5.Text = "نوع القيد";
            // 
            // rbGeneral
            // 
            rbGeneral.AutoSize = true;
            rbGeneral.Checked = true;
            rbGeneral.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            rbGeneral.Location = new Point(691, 76);
            rbGeneral.Name = "rbGeneral";
            rbGeneral.Size = new Size(54, 27);
            rbGeneral.TabIndex = 9;
            rbGeneral.TabStop = true;
            rbGeneral.Text = "عام";
            rbGeneral.UseVisualStyleBackColor = true;
            // 
            // rbWait
            // 
            rbWait.AutoSize = true;
            rbWait.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            rbWait.Location = new Point(762, 76);
            rbWait.Name = "rbWait";
            rbWait.Size = new Size(63, 27);
            rbWait.TabIndex = 10;
            rbWait.Text = "معلق";
            rbWait.UseVisualStyleBackColor = true;
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
            // txtJoNo
            // 
            txtJoNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtJoNo.Location = new Point(143, 18);
            txtJoNo.Name = "txtJoNo";
            txtJoNo.ReadOnly = true;
            txtJoNo.Size = new Size(88, 30);
            txtJoNo.TabIndex = 15;
            txtJoNo.Text = "0";
            txtJoNo.TextAlign = HorizontalAlignment.Center;
            txtJoNo.TextChanged += txtJoNo_TextChanged;
            // 
            // dgvData
            // 
            dgvData.AllowUserToAddRows = false;
            dataGridViewCellStyle1.Alignment = DataGridViewContentAlignment.MiddleCenter;
            dataGridViewCellStyle1.BackColor = Color.DeepSkyBlue;
            dataGridViewCellStyle1.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            dataGridViewCellStyle1.ForeColor = Color.White;
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
            dgvData.Columns.AddRange(new DataGridViewColumn[] { Column1, Column2, Column3, Column4, Column5, Column6, Column7, Column8, Column9, Column10, Column11 });
            dgvData.ContextMenuStrip = cms;
            dataGridViewCellStyle3.Alignment = DataGridViewContentAlignment.MiddleCenter;
            dataGridViewCellStyle3.BackColor = Color.White;
            dataGridViewCellStyle3.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            dataGridViewCellStyle3.ForeColor = Color.Blue;
            dataGridViewCellStyle3.SelectionBackColor = SystemColors.Highlight;
            dataGridViewCellStyle3.SelectionForeColor = SystemColors.HighlightText;
            dataGridViewCellStyle3.WrapMode = DataGridViewTriState.False;
            dgvData.DefaultCellStyle = dataGridViewCellStyle3;
            dgvData.GridColor = Color.FromArgb(0, 64, 0);
            dgvData.Location = new Point(12, 235);
            dgvData.Name = "dgvData";
            dgvData.RowHeadersVisible = false;
            dgvData.RowHeadersWidth = 51;
            dgvData.Size = new Size(1315, 326);
            dgvData.TabIndex = 16;
            dgvData.RowsAdded += dgvData_RowsAdded;
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
            Column3.HeaderText = "مدين";
            Column3.MinimumWidth = 6;
            Column3.Name = "Column3";
            // 
            // Column4
            // 
            Column4.HeaderText = "دائن";
            Column4.MinimumWidth = 6;
            Column4.Name = "Column4";
            // 
            // Column5
            // 
            Column5.HeaderText = "رقم العملة";
            Column5.MinimumWidth = 6;
            Column5.Name = "Column5";
            Column5.Visible = false;
            // 
            // Column6
            // 
            Column6.HeaderText = "إسم العملة";
            Column6.MinimumWidth = 6;
            Column6.Name = "Column6";
            // 
            // Column7
            // 
            Column7.HeaderText = "الصرف";
            Column7.MinimumWidth = 6;
            Column7.Name = "Column7";
            // 
            // Column8
            // 
            Column8.HeaderText = "البيان";
            Column8.MinimumWidth = 6;
            Column8.Name = "Column8";
            // 
            // Column9
            // 
            Column9.HeaderText = "إجمالي مدين";
            Column9.MinimumWidth = 6;
            Column9.Name = "Column9";
            Column9.Visible = false;
            // 
            // Column10
            // 
            Column10.HeaderText = "إجمالي دائن";
            Column10.MinimumWidth = 6;
            Column10.Name = "Column10";
            Column10.Visible = false;
            // 
            // Column11
            // 
            Column11.HeaderText = "رقم القيد";
            Column11.MinimumWidth = 6;
            Column11.Name = "Column11";
            Column11.Visible = false;
            // 
            // cms
            // 
            cms.ImageScalingSize = new Size(20, 20);
            cms.Items.AddRange(new ToolStripItem[] { addrow, editRow, removeRow });
            cms.Name = "cms";
            cms.RightToLeft = RightToLeft.Yes;
            cms.Size = new Size(169, 118);
            // 
            // addrow
            // 
            addrow.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            addrow.Image = (Image)resources.GetObject("addrow.Image");
            addrow.ImageScaling = ToolStripItemImageScaling.None;
            addrow.Name = "addrow";
            addrow.Size = new Size(168, 38);
            addrow.Text = "إضافة صف";
            addrow.Click += addrow_Click;
            // 
            // editRow
            // 
            editRow.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            editRow.Image = (Image)resources.GetObject("editRow.Image");
            editRow.ImageScaling = ToolStripItemImageScaling.None;
            editRow.Name = "editRow";
            editRow.Size = new Size(168, 38);
            editRow.Text = "تعديل صف";
            editRow.Click += editRow_Click;
            // 
            // removeRow
            // 
            removeRow.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            removeRow.Image = (Image)resources.GetObject("removeRow.Image");
            removeRow.ImageScaling = ToolStripItemImageScaling.None;
            removeRow.Name = "removeRow";
            removeRow.Size = new Size(168, 38);
            removeRow.Text = "حذف صف";
            removeRow.Click += removeRow_Click;
            // 
            // label6
            // 
            label6.AutoSize = true;
            label6.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label6.ForeColor = Color.FromArgb(0, 64, 64);
            label6.Location = new Point(1214, 23);
            label6.Name = "label6";
            label6.Size = new Size(86, 23);
            label6.TabIndex = 17;
            label6.Text = "رقم الحساب";
            // 
            // label7
            // 
            label7.AutoSize = true;
            label7.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label7.ForeColor = Color.FromArgb(0, 64, 64);
            label7.Location = new Point(1067, 23);
            label7.Name = "label7";
            label7.Size = new Size(87, 23);
            label7.TabIndex = 18;
            label7.Text = "إسم الحساب";
            // 
            // label8
            // 
            label8.AutoSize = true;
            label8.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label8.ForeColor = Color.FromArgb(0, 64, 64);
            label8.Location = new Point(863, 23);
            label8.Name = "label8";
            label8.Size = new Size(41, 23);
            label8.TabIndex = 19;
            label8.Text = "مدين";
            // 
            // label9
            // 
            label9.AutoSize = true;
            label9.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label9.ForeColor = Color.FromArgb(0, 64, 64);
            label9.Location = new Point(731, 23);
            label9.Name = "label9";
            label9.Size = new Size(37, 23);
            label9.TabIndex = 20;
            label9.Text = "دائن";
            // 
            // label10
            // 
            label10.AutoSize = true;
            label10.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label10.ForeColor = Color.FromArgb(0, 64, 64);
            label10.Location = new Point(592, 23);
            label10.Name = "label10";
            label10.Size = new Size(47, 23);
            label10.TabIndex = 21;
            label10.Text = "العملة";
            // 
            // label11
            // 
            label11.AutoSize = true;
            label11.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label11.ForeColor = Color.FromArgb(0, 64, 64);
            label11.Location = new Point(407, 23);
            label11.Name = "label11";
            label11.Size = new Size(58, 23);
            label11.TabIndex = 22;
            label11.Text = "الصرف";
            // 
            // label12
            // 
            label12.AutoSize = true;
            label12.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label12.ForeColor = Color.FromArgb(0, 64, 64);
            label12.Location = new Point(289, 23);
            label12.Name = "label12";
            label12.Size = new Size(45, 23);
            label12.TabIndex = 23;
            label12.Text = "البيان";
            // 
            // txtAccNo
            // 
            txtAccNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtAccNo.Location = new Point(1181, 60);
            txtAccNo.Name = "txtAccNo";
            txtAccNo.Size = new Size(125, 30);
            txtAccNo.TabIndex = 24;
            txtAccNo.TextAlign = HorizontalAlignment.Center;
            txtAccNo.KeyDown += txtAccNo_KeyDown;
            // 
            // txtAccName
            // 
            txtAccName.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtAccName.Location = new Point(919, 60);
            txtAccName.Name = "txtAccName";
            txtAccName.ReadOnly = true;
            txtAccName.Size = new Size(256, 30);
            txtAccName.TabIndex = 25;
            txtAccName.TextAlign = HorizontalAlignment.Center;
            // 
            // txtDebitor
            // 
            txtDebitor.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtDebitor.Location = new Point(788, 60);
            txtDebitor.Name = "txtDebitor";
            txtDebitor.Size = new Size(125, 30);
            txtDebitor.TabIndex = 26;
            txtDebitor.Text = "0.00";
            txtDebitor.TextAlign = HorizontalAlignment.Center;
            txtDebitor.KeyPress += txtDebitor_KeyPress;
            // 
            // txtCreditor
            // 
            txtCreditor.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtCreditor.Location = new Point(657, 60);
            txtCreditor.Name = "txtCreditor";
            txtCreditor.Size = new Size(125, 30);
            txtCreditor.TabIndex = 27;
            txtCreditor.Text = "0.00";
            txtCreditor.TextAlign = HorizontalAlignment.Center;
            txtCreditor.KeyPress += txtCreditor_KeyPress;
            // 
            // cbCurrency
            // 
            cbCurrency.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            cbCurrency.FormattingEnabled = true;
            cbCurrency.Location = new Point(471, 60);
            cbCurrency.Name = "cbCurrency";
            cbCurrency.Size = new Size(180, 31);
            cbCurrency.TabIndex = 28;
            cbCurrency.SelectedIndexChanged += cbCurrency_SelectedIndexChanged;
            // 
            // txtCurrVal
            // 
            txtCurrVal.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtCurrVal.Location = new Point(366, 60);
            txtCurrVal.Name = "txtCurrVal";
            txtCurrVal.ReadOnly = true;
            txtCurrVal.Size = new Size(99, 30);
            txtCurrVal.TabIndex = 29;
            txtCurrVal.Text = "0.00";
            txtCurrVal.TextAlign = HorizontalAlignment.Center;
            txtCurrVal.KeyPress += txtCurrVal_KeyPress;
            // 
            // txtNote
            // 
            txtNote.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtNote.Location = new Point(72, 60);
            txtNote.Name = "txtNote";
            txtNote.Size = new Size(288, 30);
            txtNote.TabIndex = 30;
            txtNote.TextAlign = HorizontalAlignment.Center;
            // 
            // btnInsert
            // 
            btnInsert.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnInsert.Image = (Image)resources.GetObject("btnInsert.Image");
            btnInsert.Location = new Point(3, 53);
            btnInsert.Name = "btnInsert";
            btnInsert.Size = new Size(63, 43);
            btnInsert.TabIndex = 31;
            btnInsert.UseVisualStyleBackColor = true;
            btnInsert.Click += btnInsert_Click;
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
            groupBox1.Location = new Point(14, 664);
            groupBox1.Name = "groupBox1";
            groupBox1.Size = new Size(1315, 81);
            groupBox1.TabIndex = 32;
            groupBox1.TabStop = false;
            // 
            // btnExit
            // 
            btnExit.BackColor = Color.FromArgb(0, 64, 64);
            btnExit.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnExit.Image = (Image)resources.GetObject("btnExit.Image");
            btnExit.Location = new Point(23, 29);
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
            btnPrint.Location = new Point(455, 29);
            btnPrint.Name = "btnPrint";
            btnPrint.Size = new Size(169, 46);
            btnPrint.TabIndex = 4;
            btnPrint.UseVisualStyleBackColor = false;
            btnPrint.Click += btnPrint_Click;
            // 
            // btnDel
            // 
            btnDel.BackColor = Color.FromArgb(0, 64, 64);
            btnDel.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnDel.Image = (Image)resources.GetObject("btnDel.Image");
            btnDel.Location = new Point(625, 29);
            btnDel.Name = "btnDel";
            btnDel.Size = new Size(169, 46);
            btnDel.TabIndex = 3;
            btnDel.UseVisualStyleBackColor = false;
            btnDel.Click += btnDel_Click;
            // 
            // btnEdit
            // 
            btnEdit.BackColor = Color.FromArgb(0, 64, 64);
            btnEdit.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnEdit.Image = (Image)resources.GetObject("btnEdit.Image");
            btnEdit.Location = new Point(795, 29);
            btnEdit.Name = "btnEdit";
            btnEdit.Size = new Size(169, 46);
            btnEdit.TabIndex = 2;
            btnEdit.UseVisualStyleBackColor = false;
            btnEdit.Click += btnEdit_Click;
            // 
            // btnAdd
            // 
            btnAdd.BackColor = Color.FromArgb(0, 64, 64);
            btnAdd.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnAdd.Image = (Image)resources.GetObject("btnAdd.Image");
            btnAdd.Location = new Point(965, 29);
            btnAdd.Name = "btnAdd";
            btnAdd.Size = new Size(169, 46);
            btnAdd.TabIndex = 1;
            btnAdd.UseVisualStyleBackColor = false;
            btnAdd.Click += btnAdd_Click;
            // 
            // btnNew
            // 
            btnNew.BackColor = Color.FromArgb(0, 64, 64);
            btnNew.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnNew.Image = (Image)resources.GetObject("btnNew.Image");
            btnNew.Location = new Point(1135, 29);
            btnNew.Name = "btnNew";
            btnNew.Size = new Size(169, 46);
            btnNew.TabIndex = 0;
            btnNew.UseVisualStyleBackColor = false;
            btnNew.Click += btnNew_Click;
            // 
            // label13
            // 
            label13.AutoSize = true;
            label13.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label13.Location = new Point(30, 630);
            label13.Name = "label13";
            label13.Size = new Size(76, 23);
            label13.TabIndex = 33;
            label13.Text = "مدخل القيد";
            // 
            // txtInsUser
            // 
            txtInsUser.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtInsUser.Location = new Point(132, 626);
            txtInsUser.Name = "txtInsUser";
            txtInsUser.ReadOnly = true;
            txtInsUser.Size = new Size(125, 30);
            txtInsUser.TabIndex = 34;
            txtInsUser.TextAlign = HorizontalAlignment.Center;
            // 
            // label14
            // 
            label14.AutoSize = true;
            label14.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label14.Location = new Point(283, 630);
            label14.Name = "label14";
            label14.Size = new Size(95, 23);
            label14.TabIndex = 35;
            label14.Text = "تاريخ الإدخال";
            // 
            // txtInsDate
            // 
            txtInsDate.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtInsDate.Location = new Point(404, 626);
            txtInsDate.Name = "txtInsDate";
            txtInsDate.ReadOnly = true;
            txtInsDate.Size = new Size(266, 30);
            txtInsDate.TabIndex = 36;
            txtInsDate.TextAlign = HorizontalAlignment.Center;
            // 
            // label15
            // 
            label15.AutoSize = true;
            label15.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label15.Location = new Point(696, 630);
            label15.Name = "label15";
            label15.Size = new Size(73, 23);
            label15.TabIndex = 37;
            label15.Text = "معدل القيد";
            // 
            // txtEditUser
            // 
            txtEditUser.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtEditUser.Location = new Point(795, 626);
            txtEditUser.Name = "txtEditUser";
            txtEditUser.ReadOnly = true;
            txtEditUser.Size = new Size(125, 30);
            txtEditUser.TabIndex = 38;
            txtEditUser.TextAlign = HorizontalAlignment.Center;
            // 
            // label16
            // 
            label16.AutoSize = true;
            label16.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label16.Location = new Point(946, 630);
            label16.Name = "label16";
            label16.Size = new Size(98, 23);
            label16.TabIndex = 39;
            label16.Text = "تاريخ ىالتعديل";
            // 
            // txtEditDate
            // 
            txtEditDate.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtEditDate.Location = new Point(1063, 626);
            txtEditDate.Name = "txtEditDate";
            txtEditDate.ReadOnly = true;
            txtEditDate.Size = new Size(266, 30);
            txtEditDate.TabIndex = 40;
            txtEditDate.TextAlign = HorizontalAlignment.Center;
            // 
            // txtSearch
            // 
            txtSearch.BackColor = Color.FromArgb(192, 255, 255);
            txtSearch.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtSearch.Location = new Point(964, 83);
            txtSearch.Name = "txtSearch";
            txtSearch.Size = new Size(291, 30);
            txtSearch.TabIndex = 41;
            txtSearch.Text = "0";
            txtSearch.TextAlign = HorizontalAlignment.Center;
            // 
            // btnSearch
            // 
            btnSearch.BackColor = Color.FromArgb(0, 64, 64);
            btnSearch.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnSearch.Image = (Image)resources.GetObject("btnSearch.Image");
            btnSearch.Location = new Point(1258, 78);
            btnSearch.Name = "btnSearch";
            btnSearch.Size = new Size(46, 38);
            btnSearch.TabIndex = 42;
            btnSearch.UseVisualStyleBackColor = false;
            btnSearch.Click += btnSearch_Click;
            // 
            // rbrev
            // 
            rbrev.AutoSize = true;
            rbrev.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            rbrev.Location = new Point(835, 76);
            rbrev.Name = "rbrev";
            rbrev.Size = new Size(73, 27);
            rbrev.TabIndex = 43;
            rbrev.Text = "عكسي";
            rbrev.UseVisualStyleBackColor = true;
            // 
            // groupBox2
            // 
            groupBox2.Controls.Add(btnFirst);
            groupBox2.Controls.Add(btnPerv);
            groupBox2.Controls.Add(btnNext);
            groupBox2.Controls.Add(btnLast);
            groupBox2.Controls.Add(txtJoNo);
            groupBox2.Location = new Point(949, 12);
            groupBox2.Name = "groupBox2";
            groupBox2.Size = new Size(372, 65);
            groupBox2.TabIndex = 44;
            groupBox2.TabStop = false;
            // 
            // groupBox3
            // 
            groupBox3.Controls.Add(label6);
            groupBox3.Controls.Add(txtAccNo);
            groupBox3.Controls.Add(label7);
            groupBox3.Controls.Add(txtAccName);
            groupBox3.Controls.Add(txtDebitor);
            groupBox3.Controls.Add(label8);
            groupBox3.Controls.Add(txtCreditor);
            groupBox3.Controls.Add(label9);
            groupBox3.Controls.Add(cbCurrency);
            groupBox3.Controls.Add(label10);
            groupBox3.Controls.Add(txtCurrVal);
            groupBox3.Controls.Add(label11);
            groupBox3.Controls.Add(txtNote);
            groupBox3.Controls.Add(label12);
            groupBox3.Controls.Add(btnInsert);
            groupBox3.Location = new Point(12, 119);
            groupBox3.Name = "groupBox3";
            groupBox3.Size = new Size(1315, 110);
            groupBox3.TabIndex = 45;
            groupBox3.TabStop = false;
            // 
            // chkPost
            // 
            chkPost.AutoSize = true;
            chkPost.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            chkPost.Location = new Point(842, 24);
            chkPost.Name = "chkPost";
            chkPost.Size = new Size(68, 27);
            chkPost.TabIndex = 46;
            chkPost.Text = "مرحل";
            chkPost.UseVisualStyleBackColor = true;
            // 
            // label17
            // 
            label17.AutoSize = true;
            label17.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label17.ForeColor = Color.FromArgb(192, 0, 0);
            label17.Location = new Point(253, 578);
            label17.Name = "label17";
            label17.Size = new Size(90, 23);
            label17.TabIndex = 47;
            label17.Text = "إجمالي مدين";
            // 
            // label18
            // 
            label18.AutoSize = true;
            label18.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label18.ForeColor = Color.FromArgb(192, 0, 0);
            label18.Location = new Point(545, 578);
            label18.Name = "label18";
            label18.Size = new Size(86, 23);
            label18.TabIndex = 48;
            label18.Text = "إجمالي دائن";
            // 
            // label19
            // 
            label19.AutoSize = true;
            label19.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label19.ForeColor = Color.FromArgb(192, 0, 0);
            label19.Location = new Point(862, 578);
            label19.Name = "label19";
            label19.Size = new Size(55, 23);
            label19.TabIndex = 49;
            label19.Text = "الرصيد";
            // 
            // txtDebitTotal
            // 
            txtDebitTotal.BackColor = Color.Black;
            txtDebitTotal.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtDebitTotal.ForeColor = Color.Yellow;
            txtDebitTotal.Location = new Point(361, 574);
            txtDebitTotal.Name = "txtDebitTotal";
            txtDebitTotal.ReadOnly = true;
            txtDebitTotal.Size = new Size(153, 30);
            txtDebitTotal.TabIndex = 50;
            txtDebitTotal.Text = "0.00";
            txtDebitTotal.TextAlign = HorizontalAlignment.Center;
            // 
            // txtCreditTotal
            // 
            txtCreditTotal.BackColor = Color.Black;
            txtCreditTotal.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtCreditTotal.ForeColor = Color.Yellow;
            txtCreditTotal.Location = new Point(659, 574);
            txtCreditTotal.Name = "txtCreditTotal";
            txtCreditTotal.ReadOnly = true;
            txtCreditTotal.Size = new Size(152, 30);
            txtCreditTotal.TabIndex = 51;
            txtCreditTotal.Text = "0.00";
            txtCreditTotal.TextAlign = HorizontalAlignment.Center;
            // 
            // txtBalance
            // 
            txtBalance.BackColor = Color.Black;
            txtBalance.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtBalance.ForeColor = Color.Yellow;
            txtBalance.Location = new Point(949, 574);
            txtBalance.Name = "txtBalance";
            txtBalance.ReadOnly = true;
            txtBalance.Size = new Size(137, 30);
            txtBalance.TabIndex = 52;
            txtBalance.Text = "0.00";
            txtBalance.TextAlign = HorizontalAlignment.Center;
            // 
            // txtOPtype
            // 
            txtOPtype.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtOPtype.Location = new Point(601, 22);
            txtOPtype.Name = "txtOPtype";
            txtOPtype.ReadOnly = true;
            txtOPtype.Size = new Size(210, 30);
            txtOPtype.TabIndex = 15;
            txtOPtype.TextAlign = HorizontalAlignment.Center;
            txtOPtype.TextChanged += txtJoNo_TextChanged;
            // 
            // frmJournal
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(1339, 752);
            Controls.Add(txtBalance);
            Controls.Add(txtCreditTotal);
            Controls.Add(txtDebitTotal);
            Controls.Add(txtOPtype);
            Controls.Add(label19);
            Controls.Add(label18);
            Controls.Add(label17);
            Controls.Add(chkPost);
            Controls.Add(groupBox3);
            Controls.Add(groupBox2);
            Controls.Add(rbrev);
            Controls.Add(btnSearch);
            Controls.Add(txtSearch);
            Controls.Add(txtEditDate);
            Controls.Add(label16);
            Controls.Add(txtEditUser);
            Controls.Add(label15);
            Controls.Add(txtInsDate);
            Controls.Add(label14);
            Controls.Add(txtInsUser);
            Controls.Add(label13);
            Controls.Add(groupBox1);
            Controls.Add(dgvData);
            Controls.Add(rbWait);
            Controls.Add(rbGeneral);
            Controls.Add(label5);
            Controls.Add(txtJNote);
            Controls.Add(label4);
            Controls.Add(dtpJdate);
            Controls.Add(label2);
            Controls.Add(txtJNo);
            Controls.Add(label1);
            Icon = (Icon)resources.GetObject("$this.Icon");
            Name = "frmJournal";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "دفتر اليومية العامة";
            Load += frmJournal_Load;
            ((System.ComponentModel.ISupportInitialize)dgvData).EndInit();
            cms.ResumeLayout(false);
            groupBox1.ResumeLayout(false);
            groupBox2.ResumeLayout(false);
            groupBox2.PerformLayout();
            groupBox3.ResumeLayout(false);
            groupBox3.PerformLayout();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Label label1;
        private TextBox txtJNo;
        private Label label2;
        private DateTimePicker dtpJdate;
        private Label label4;
        private TextBox txtJNote;
        private Label label5;
        private RadioButton rbGeneral;
        private RadioButton rbWait;
        private Button btnFirst;
        private Button btnPerv;
        private Button btnNext;
        private Button btnLast;
        private TextBox txtJoNo;
        private DataGridView dgvData;
        private Label label6;
        private Label label7;
        private Label label8;
        private Label label9;
        private Label label10;
        private Label label11;
        private Label label12;
        private TextBox txtAccNo;
        private TextBox txtAccName;
        private TextBox txtDebitor;
        private TextBox txtCreditor;
        private ComboBox cbCurrency;
        private TextBox txtCurrVal;
        private TextBox txtNote;
        private Button btnInsert;
        private GroupBox groupBox1;
        private Button btnExit;
        private Button btnPrint;
        private Button btnDel;
        private Button btnEdit;
        private Button btnAdd;
        private Button btnNew;
        private Label label13;
        private TextBox txtInsUser;
        private Label label14;
        private TextBox txtInsDate;
        private Label label15;
        private TextBox txtEditUser;
        private Label label16;
        private TextBox txtEditDate;
        private TextBox txtSearch;
        private Button btnSearch;
        private RadioButton rbrev;
        private GroupBox groupBox2;
        private GroupBox groupBox3;
        private CheckBox chkPost;
        private Label label17;
        private Label label18;
        private Label label19;
        private TextBox txtDebitTotal;
        private TextBox txtCreditTotal;
        private TextBox txtBalance;
        private ContextMenuStrip cms;
        private ToolStripMenuItem addrow;
        private ToolStripMenuItem editRow;
        private ToolStripMenuItem removeRow;
        private DataGridViewTextBoxColumn Column1;
        private DataGridViewTextBoxColumn Column2;
        private DataGridViewTextBoxColumn Column3;
        private DataGridViewTextBoxColumn Column4;
        private DataGridViewTextBoxColumn Column5;
        private DataGridViewTextBoxColumn Column6;
        private DataGridViewTextBoxColumn Column7;
        private DataGridViewTextBoxColumn Column8;
        private DataGridViewTextBoxColumn Column9;
        private DataGridViewTextBoxColumn Column10;
        private DataGridViewTextBoxColumn Column11;
        private TextBox txtOPtype;
    }
}