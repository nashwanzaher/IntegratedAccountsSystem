namespace IntegratedAccSys.PL.Accounts
{
    partial class frmAccSheet
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmAccSheet));
            chkJournal = new CheckBox();
            chkPayBond = new CheckBox();
            chkRecieveBond = new CheckBox();
            label2 = new Label();
            label3 = new Label();
            dtpFromDate = new DateTimePicker();
            dtpToDate = new DateTimePicker();
            label4 = new Label();
            label5 = new Label();
            cbCurrencies = new ComboBox();
            txtCurrVal = new TextBox();
            label6 = new Label();
            label7 = new Label();
            txtAccCode = new TextBox();
            txtAccName = new TextBox();
            btnDisplay = new Button();
            btnExit = new Button();
            groupBox1 = new GroupBox();
            chkExport = new CheckBox();
            chkImport = new CheckBox();
            chkSells = new CheckBox();
            chkBurchases = new CheckBox();
            groupBox1.SuspendLayout();
            SuspendLayout();
            // 
            // chkJournal
            // 
            chkJournal.AutoSize = true;
            chkJournal.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            chkJournal.Location = new Point(95, 34);
            chkJournal.Name = "chkJournal";
            chkJournal.Size = new Size(90, 27);
            chkJournal.TabIndex = 1;
            chkJournal.Text = "قيد يومية";
            chkJournal.UseVisualStyleBackColor = true;
            // 
            // chkPayBond
            // 
            chkPayBond.AutoSize = true;
            chkPayBond.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            chkPayBond.Location = new Point(85, 66);
            chkPayBond.Name = "chkPayBond";
            chkPayBond.Size = new Size(100, 27);
            chkPayBond.TabIndex = 2;
            chkPayBond.Text = "سند صرف";
            chkPayBond.UseVisualStyleBackColor = true;
            // 
            // chkRecieveBond
            // 
            chkRecieveBond.AutoSize = true;
            chkRecieveBond.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            chkRecieveBond.Location = new Point(92, 98);
            chkRecieveBond.Name = "chkRecieveBond";
            chkRecieveBond.Size = new Size(93, 27);
            chkRecieveBond.TabIndex = 3;
            chkRecieveBond.Text = "سند قبض";
            chkRecieveBond.UseVisualStyleBackColor = true;
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label2.Location = new Point(37, 12);
            label2.Name = "label2";
            label2.Size = new Size(69, 23);
            label2.TabIndex = 4;
            label2.Text = "من تاريخ";
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label3.Location = new Point(37, 58);
            label3.Name = "label3";
            label3.Size = new Size(70, 23);
            label3.TabIndex = 5;
            label3.Text = "إلى تاريخ";
            // 
            // dtpFromDate
            // 
            dtpFromDate.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            dtpFromDate.Location = new Point(139, 12);
            dtpFromDate.Name = "dtpFromDate";
            dtpFromDate.Size = new Size(266, 30);
            dtpFromDate.TabIndex = 6;
            // 
            // dtpToDate
            // 
            dtpToDate.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            dtpToDate.Location = new Point(139, 53);
            dtpToDate.Name = "dtpToDate";
            dtpToDate.Size = new Size(266, 30);
            dtpToDate.TabIndex = 7;
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label4.Location = new Point(37, 101);
            label4.Name = "label4";
            label4.Size = new Size(47, 23);
            label4.TabIndex = 8;
            label4.Text = "العملة";
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label5.Location = new Point(37, 146);
            label5.Name = "label5";
            label5.Size = new Size(58, 23);
            label5.TabIndex = 9;
            label5.Text = "الصرف";
            // 
            // cbCurrencies
            // 
            cbCurrencies.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            cbCurrencies.FormattingEnabled = true;
            cbCurrencies.Location = new Point(139, 101);
            cbCurrencies.Name = "cbCurrencies";
            cbCurrencies.Size = new Size(266, 31);
            cbCurrencies.TabIndex = 10;
            cbCurrencies.SelectedIndexChanged += cbCurrencies_SelectedIndexChanged;
            // 
            // txtCurrVal
            // 
            txtCurrVal.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtCurrVal.Location = new Point(139, 146);
            txtCurrVal.Name = "txtCurrVal";
            txtCurrVal.Size = new Size(266, 30);
            txtCurrVal.TabIndex = 11;
            // 
            // label6
            // 
            label6.AutoSize = true;
            label6.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label6.Location = new Point(37, 207);
            label6.Name = "label6";
            label6.Size = new Size(86, 23);
            label6.TabIndex = 12;
            label6.Text = "رقم الحساب";
            // 
            // label7
            // 
            label7.AutoSize = true;
            label7.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label7.Location = new Point(37, 251);
            label7.Name = "label7";
            label7.Size = new Size(87, 23);
            label7.TabIndex = 13;
            label7.Text = "إسم الحساب";
            // 
            // txtAccCode
            // 
            txtAccCode.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtAccCode.Location = new Point(139, 200);
            txtAccCode.Name = "txtAccCode";
            txtAccCode.Size = new Size(266, 30);
            txtAccCode.TabIndex = 14;
            txtAccCode.KeyDown += txtAccCode_KeyDown;
            // 
            // txtAccName
            // 
            txtAccName.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtAccName.Location = new Point(139, 248);
            txtAccName.Name = "txtAccName";
            txtAccName.Size = new Size(266, 30);
            txtAccName.TabIndex = 15;
            // 
            // btnDisplay
            // 
            btnDisplay.BackColor = Color.FromArgb(0, 64, 64);
            btnDisplay.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnDisplay.Image = (Image)resources.GetObject("btnDisplay.Image");
            btnDisplay.Location = new Point(37, 298);
            btnDisplay.Name = "btnDisplay";
            btnDisplay.Size = new Size(131, 40);
            btnDisplay.TabIndex = 17;
            btnDisplay.UseVisualStyleBackColor = false;
            btnDisplay.Click += btnDisplay_Click;
            // 
            // btnExit
            // 
            btnExit.BackColor = Color.FromArgb(0, 64, 64);
            btnExit.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnExit.Image = (Image)resources.GetObject("btnExit.Image");
            btnExit.Location = new Point(551, 298);
            btnExit.Name = "btnExit";
            btnExit.Size = new Size(104, 40);
            btnExit.TabIndex = 18;
            btnExit.UseVisualStyleBackColor = false;
            btnExit.Click += btnExit_Click;
            // 
            // groupBox1
            // 
            groupBox1.Controls.Add(chkJournal);
            groupBox1.Controls.Add(chkPayBond);
            groupBox1.Controls.Add(chkExport);
            groupBox1.Controls.Add(chkImport);
            groupBox1.Controls.Add(chkSells);
            groupBox1.Controls.Add(chkBurchases);
            groupBox1.Controls.Add(chkRecieveBond);
            groupBox1.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            groupBox1.Location = new Point(432, 12);
            groupBox1.Name = "groupBox1";
            groupBox1.Size = new Size(223, 266);
            groupBox1.TabIndex = 19;
            groupBox1.TabStop = false;
            groupBox1.Text = "العمليات";
            // 
            // chkExport
            // 
            chkExport.AutoSize = true;
            chkExport.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            chkExport.Location = new Point(36, 226);
            chkExport.Name = "chkExport";
            chkExport.Size = new Size(149, 27);
            chkExport.TabIndex = 3;
            chkExport.Text = "سند صرف مخزني";
            chkExport.UseVisualStyleBackColor = true;
            // 
            // chkImport
            // 
            chkImport.AutoSize = true;
            chkImport.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            chkImport.Location = new Point(40, 194);
            chkImport.Name = "chkImport";
            chkImport.Size = new Size(145, 27);
            chkImport.TabIndex = 3;
            chkImport.Text = "سند توريد مخزني";
            chkImport.UseVisualStyleBackColor = true;
            // 
            // chkSells
            // 
            chkSells.AutoSize = true;
            chkSells.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            chkSells.Location = new Point(64, 162);
            chkSells.Name = "chkSells";
            chkSells.Size = new Size(121, 27);
            chkSells.TabIndex = 3;
            chkSells.Text = "فاتورة مبيعات";
            chkSells.UseVisualStyleBackColor = true;
            // 
            // chkBurchases
            // 
            chkBurchases.AutoSize = true;
            chkBurchases.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            chkBurchases.Location = new Point(50, 130);
            chkBurchases.Name = "chkBurchases";
            chkBurchases.Size = new Size(135, 27);
            chkBurchases.TabIndex = 3;
            chkBurchases.Text = "فاتورة مشتريات";
            chkBurchases.UseVisualStyleBackColor = true;
            // 
            // frmAccSheet
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(677, 344);
            Controls.Add(groupBox1);
            Controls.Add(btnExit);
            Controls.Add(btnDisplay);
            Controls.Add(txtAccName);
            Controls.Add(txtAccCode);
            Controls.Add(label7);
            Controls.Add(label6);
            Controls.Add(txtCurrVal);
            Controls.Add(cbCurrencies);
            Controls.Add(label5);
            Controls.Add(label4);
            Controls.Add(dtpToDate);
            Controls.Add(dtpFromDate);
            Controls.Add(label3);
            Controls.Add(label2);
            Icon = (Icon)resources.GetObject("$this.Icon");
            MaximizeBox = false;
            MinimizeBox = false;
            Name = "frmAccSheet";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "كشف حساب";
            Load += frmAccSheet_Load;
            groupBox1.ResumeLayout(false);
            groupBox1.PerformLayout();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion
        private CheckBox chkJournal;
        private CheckBox chkPayBond;
        private CheckBox chkRecieveBond;
        private Label label2;
        private Label label3;
        private DateTimePicker dtpFromDate;
        private DateTimePicker dtpToDate;
        private Label label4;
        private Label label5;
        private ComboBox cbCurrencies;
        private TextBox txtCurrVal;
        private Label label6;
        private Label label7;
        private TextBox txtAccCode;
        private TextBox txtAccName;
        private Button btnDisplay;
        private Button btnExit;
        private GroupBox groupBox1;
        private CheckBox chkExport;
        private CheckBox chkImport;
        private CheckBox chkSells;
        private CheckBox chkBurchases;
    }
}