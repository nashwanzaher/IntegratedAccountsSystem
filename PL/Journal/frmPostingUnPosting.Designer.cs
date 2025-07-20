namespace IntegratedAccSys.PL.Journal
{
    partial class frmPostingUnPosting
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmPostingUnPosting));
            btnPosing = new Button();
            btnUndoPosting = new Button();
            btnExit = new Button();
            btnSearch = new Button();
            rbSaleBill = new RadioButton();
            rbPurBill = new RadioButton();
            rbMoneyRecieveBond = new RadioButton();
            rbMoneyPayBond = new RadioButton();
            rbJurnalEntry = new RadioButton();
            gpOpreation = new GroupBox();
            rbSaleReturnBill = new RadioButton();
            rbPurReturnBill = new RadioButton();
            dtpRptToDate = new DateTimePicker();
            txtPostStatus = new TextBox();
            dtpRptFromDate = new DateTimePicker();
            lbl2 = new Label();
            lbl1 = new Label();
            gpPosting = new GroupBox();
            dgvData = new DataGridView();
            Column1 = new DataGridViewCheckBoxColumn();
            Column2 = new DataGridViewTextBoxColumn();
            Column3 = new DataGridViewTextBoxColumn();
            Column4 = new DataGridViewTextBoxColumn();
            Column5 = new DataGridViewTextBoxColumn();
            gpOpreation.SuspendLayout();
            gpPosting.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)dgvData).BeginInit();
            SuspendLayout();
            // 
            // btnPosing
            // 
            btnPosing.BackColor = Color.FromArgb(192, 255, 255);
            btnPosing.Image = (Image)resources.GetObject("btnPosing.Image");
            btnPosing.Location = new Point(22, 511);
            btnPosing.Margin = new Padding(3, 4, 3, 4);
            btnPosing.Name = "btnPosing";
            btnPosing.Size = new Size(118, 51);
            btnPosing.TabIndex = 2;
            btnPosing.UseVisualStyleBackColor = false;
            btnPosing.Visible = false;
            btnPosing.Click += btnPosing_Click;
            // 
            // btnUndoPosting
            // 
            btnUndoPosting.BackColor = Color.FromArgb(192, 255, 255);
            btnUndoPosting.Image = (Image)resources.GetObject("btnUndoPosting.Image");
            btnUndoPosting.Location = new Point(22, 511);
            btnUndoPosting.Margin = new Padding(3, 4, 3, 4);
            btnUndoPosting.Name = "btnUndoPosting";
            btnUndoPosting.Size = new Size(118, 51);
            btnUndoPosting.TabIndex = 2;
            btnUndoPosting.UseVisualStyleBackColor = false;
            btnUndoPosting.Visible = false;
            btnUndoPosting.Click += btnUndoPosting_Click;
            // 
            // btnExit
            // 
            btnExit.BackColor = Color.FromArgb(192, 255, 255);
            btnExit.Image = (Image)resources.GetObject("btnExit.Image");
            btnExit.Location = new Point(750, 511);
            btnExit.Margin = new Padding(3, 4, 3, 4);
            btnExit.Name = "btnExit";
            btnExit.Size = new Size(121, 51);
            btnExit.TabIndex = 2;
            btnExit.UseVisualStyleBackColor = false;
            btnExit.Click += btnExit_Click;
            // 
            // btnSearch
            // 
            btnSearch.BackColor = Color.FromArgb(64, 0, 64);
            btnSearch.Image = (Image)resources.GetObject("btnSearch.Image");
            btnSearch.Location = new Point(15, 1);
            btnSearch.Margin = new Padding(3, 4, 3, 4);
            btnSearch.Name = "btnSearch";
            btnSearch.Size = new Size(134, 52);
            btnSearch.TabIndex = 0;
            btnSearch.UseVisualStyleBackColor = false;
            btnSearch.Click += btnSearch_Click;
            // 
            // rbSaleBill
            // 
            rbSaleBill.Font = new Font("Times New Roman", 13.8F, FontStyle.Bold, GraphicsUnit.Point, 0);
            rbSaleBill.ForeColor = Color.FromArgb(0, 64, 0);
            rbSaleBill.Location = new Point(245, 31);
            rbSaleBill.Margin = new Padding(3, 4, 3, 4);
            rbSaleBill.Name = "rbSaleBill";
            rbSaleBill.Size = new Size(136, 36);
            rbSaleBill.TabIndex = 0;
            rbSaleBill.TabStop = true;
            rbSaleBill.Text = "فاتورة مبيعات";
            rbSaleBill.UseVisualStyleBackColor = true;
            // 
            // rbPurBill
            // 
            rbPurBill.Font = new Font("Times New Roman", 13.8F, FontStyle.Bold, GraphicsUnit.Point, 0);
            rbPurBill.ForeColor = Color.FromArgb(0, 64, 0);
            rbPurBill.Location = new Point(381, 31);
            rbPurBill.Margin = new Padding(3, 4, 3, 4);
            rbPurBill.Name = "rbPurBill";
            rbPurBill.Size = new Size(156, 36);
            rbPurBill.TabIndex = 0;
            rbPurBill.TabStop = true;
            rbPurBill.Text = "فاتورة مشتريات";
            rbPurBill.UseVisualStyleBackColor = true;
            // 
            // rbMoneyRecieveBond
            // 
            rbMoneyRecieveBond.Font = new Font("Times New Roman", 13.8F, FontStyle.Bold, GraphicsUnit.Point, 0);
            rbMoneyRecieveBond.ForeColor = Color.FromArgb(192, 0, 0);
            rbMoneyRecieveBond.Location = new Point(537, 31);
            rbMoneyRecieveBond.Margin = new Padding(3, 4, 3, 4);
            rbMoneyRecieveBond.Name = "rbMoneyRecieveBond";
            rbMoneyRecieveBond.Size = new Size(108, 36);
            rbMoneyRecieveBond.TabIndex = 0;
            rbMoneyRecieveBond.TabStop = true;
            rbMoneyRecieveBond.Text = "سند قبض نقدي";
            rbMoneyRecieveBond.UseVisualStyleBackColor = true;
            // 
            // rbMoneyPayBond
            // 
            rbMoneyPayBond.Font = new Font("Times New Roman", 13.8F, FontStyle.Bold, GraphicsUnit.Point, 0);
            rbMoneyPayBond.ForeColor = Color.FromArgb(192, 0, 0);
            rbMoneyPayBond.Location = new Point(645, 31);
            rbMoneyPayBond.Margin = new Padding(3, 4, 3, 4);
            rbMoneyPayBond.Name = "rbMoneyPayBond";
            rbMoneyPayBond.Size = new Size(116, 36);
            rbMoneyPayBond.TabIndex = 0;
            rbMoneyPayBond.TabStop = true;
            rbMoneyPayBond.Text = "سند صرف نقدي";
            rbMoneyPayBond.UseVisualStyleBackColor = true;
            // 
            // rbJurnalEntry
            // 
            rbJurnalEntry.Font = new Font("Times New Roman", 13.8F, FontStyle.Bold, GraphicsUnit.Point, 0);
            rbJurnalEntry.ForeColor = Color.Navy;
            rbJurnalEntry.Location = new Point(761, 31);
            rbJurnalEntry.Margin = new Padding(3, 4, 3, 4);
            rbJurnalEntry.Name = "rbJurnalEntry";
            rbJurnalEntry.Size = new Size(107, 36);
            rbJurnalEntry.TabIndex = 0;
            rbJurnalEntry.TabStop = true;
            rbJurnalEntry.Text = "قيد يومية";
            rbJurnalEntry.UseVisualStyleBackColor = true;
            // 
            // gpOpreation
            // 
            gpOpreation.Controls.Add(rbSaleReturnBill);
            gpOpreation.Controls.Add(rbSaleBill);
            gpOpreation.Controls.Add(rbPurReturnBill);
            gpOpreation.Controls.Add(rbPurBill);
            gpOpreation.Controls.Add(rbMoneyRecieveBond);
            gpOpreation.Controls.Add(rbMoneyPayBond);
            gpOpreation.Controls.Add(rbJurnalEntry);
            gpOpreation.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            gpOpreation.ForeColor = Color.FromArgb(192, 0, 0);
            gpOpreation.Location = new Point(6, 47);
            gpOpreation.Margin = new Padding(3, 4, 3, 4);
            gpOpreation.Name = "gpOpreation";
            gpOpreation.Padding = new Padding(3, 4, 3, 4);
            gpOpreation.Size = new Size(871, 79);
            gpOpreation.TabIndex = 4;
            gpOpreation.TabStop = false;
            gpOpreation.Text = "العمليات";
            // 
            // rbSaleReturnBill
            // 
            rbSaleReturnBill.Font = new Font("Times New Roman", 13.8F, FontStyle.Bold, GraphicsUnit.Point, 0);
            rbSaleReturnBill.ForeColor = Color.Blue;
            rbSaleReturnBill.Location = new Point(1, 31);
            rbSaleReturnBill.Margin = new Padding(3, 4, 3, 4);
            rbSaleReturnBill.Name = "rbSaleReturnBill";
            rbSaleReturnBill.Size = new Size(116, 36);
            rbSaleReturnBill.TabIndex = 0;
            rbSaleReturnBill.TabStop = true;
            rbSaleReturnBill.Text = "مرتجع بيع";
            rbSaleReturnBill.UseVisualStyleBackColor = true;
            // 
            // rbPurReturnBill
            // 
            rbPurReturnBill.Font = new Font("Times New Roman", 13.8F, FontStyle.Bold, GraphicsUnit.Point, 0);
            rbPurReturnBill.ForeColor = Color.Blue;
            rbPurReturnBill.Location = new Point(117, 31);
            rbPurReturnBill.Margin = new Padding(3, 4, 3, 4);
            rbPurReturnBill.Name = "rbPurReturnBill";
            rbPurReturnBill.Size = new Size(128, 36);
            rbPurReturnBill.TabIndex = 0;
            rbPurReturnBill.TabStop = true;
            rbPurReturnBill.Text = "مرتجع شراء";
            rbPurReturnBill.UseVisualStyleBackColor = true;
            // 
            // dtpRptToDate
            // 
            dtpRptToDate.Font = new Font("Times New Roman", 10.8F, FontStyle.Bold, GraphicsUnit.Point, 0);
            dtpRptToDate.Location = new Point(225, 9);
            dtpRptToDate.Margin = new Padding(3, 4, 3, 4);
            dtpRptToDate.Name = "dtpRptToDate";
            dtpRptToDate.Size = new Size(191, 28);
            dtpRptToDate.TabIndex = 5;
            // 
            // txtPostStatus
            // 
            txtPostStatus.Location = new Point(376, 511);
            txtPostStatus.Margin = new Padding(3, 4, 3, 4);
            txtPostStatus.Name = "txtPostStatus";
            txtPostStatus.Size = new Size(41, 27);
            txtPostStatus.TabIndex = 7;
            txtPostStatus.Visible = false;
            // 
            // dtpRptFromDate
            // 
            dtpRptFromDate.Font = new Font("Times New Roman", 10.8F, FontStyle.Bold, GraphicsUnit.Point, 0);
            dtpRptFromDate.Location = new Point(585, 11);
            dtpRptFromDate.Margin = new Padding(3, 4, 3, 4);
            dtpRptFromDate.Name = "dtpRptFromDate";
            dtpRptFromDate.Size = new Size(191, 28);
            dtpRptFromDate.TabIndex = 6;
            // 
            // lbl2
            // 
            lbl2.AutoSize = true;
            lbl2.Font = new Font("Times New Roman", 10.8F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lbl2.ForeColor = Color.Blue;
            lbl2.Location = new Point(428, 13);
            lbl2.Name = "lbl2";
            lbl2.Size = new Size(64, 20);
            lbl2.TabIndex = 3;
            lbl2.Text = "إلى تاريخ";
            // 
            // lbl1
            // 
            lbl1.AutoSize = true;
            lbl1.Font = new Font("Times New Roman", 10.8F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lbl1.ForeColor = Color.Blue;
            lbl1.Location = new Point(788, 15);
            lbl1.Name = "lbl1";
            lbl1.Size = new Size(63, 20);
            lbl1.TabIndex = 4;
            lbl1.Text = "من تاريخ";
            // 
            // gpPosting
            // 
            gpPosting.BackColor = Color.Gainsboro;
            gpPosting.Controls.Add(dtpRptToDate);
            gpPosting.Controls.Add(dtpRptFromDate);
            gpPosting.Controls.Add(lbl2);
            gpPosting.Controls.Add(lbl1);
            gpPosting.Controls.Add(btnSearch);
            gpPosting.Dock = DockStyle.Top;
            gpPosting.Location = new Point(0, 0);
            gpPosting.Margin = new Padding(3, 4, 3, 4);
            gpPosting.Name = "gpPosting";
            gpPosting.Padding = new Padding(3, 4, 3, 4);
            gpPosting.Size = new Size(883, 56);
            gpPosting.TabIndex = 2;
            gpPosting.TabStop = false;
            // 
            // dgvData
            // 
            dgvData.AllowUserToAddRows = false;
            dgvData.BackgroundColor = Color.AliceBlue;
            dgvData.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            dgvData.Columns.AddRange(new DataGridViewColumn[] { Column1, Column2, Column3, Column4, Column5 });
            dgvData.GridColor = Color.FromArgb(0, 0, 192);
            dgvData.Location = new Point(6, 139);
            dgvData.Margin = new Padding(3, 4, 3, 4);
            dgvData.Name = "dgvData";
            dgvData.RowHeadersVisible = false;
            dgvData.RowHeadersWidth = 51;
            dgvData.RowTemplate.Height = 26;
            dgvData.Size = new Size(870, 364);
            dgvData.TabIndex = 5;
            dgvData.CellContentClick += dgvData_CellContentClick;
            // 
            // Column1
            // 
            Column1.AutoSizeMode = DataGridViewAutoSizeColumnMode.None;
            Column1.FillWeight = 160.4278F;
            Column1.Frozen = true;
            Column1.HeaderText = "";
            Column1.MinimumWidth = 6;
            Column1.Name = "Column1";
            Column1.Width = 30;
            // 
            // Column2
            // 
            Column2.AutoSizeMode = DataGridViewAutoSizeColumnMode.None;
            Column2.FillWeight = 84.89304F;
            Column2.Frozen = true;
            Column2.HeaderText = "رقم القيد";
            Column2.MinimumWidth = 6;
            Column2.Name = "Column2";
            Column2.ReadOnly = true;
            Column2.Width = 110;
            // 
            // Column3
            // 
            Column3.AutoSizeMode = DataGridViewAutoSizeColumnMode.ColumnHeader;
            Column3.HeaderText = "رقم السند";
            Column3.MinimumWidth = 6;
            Column3.Name = "Column3";
            Column3.ReadOnly = true;
            Column3.Width = 99;
            // 
            // Column4
            // 
            Column4.AutoSizeMode = DataGridViewAutoSizeColumnMode.None;
            Column4.FillWeight = 84.89304F;
            Column4.HeaderText = "تاريخ السند";
            Column4.MinimumWidth = 6;
            Column4.Name = "Column4";
            Column4.ReadOnly = true;
            Column4.Width = 160;
            // 
            // Column5
            // 
            Column5.AutoSizeMode = DataGridViewAutoSizeColumnMode.None;
            Column5.FillWeight = 84.89304F;
            Column5.HeaderText = "البيان";
            Column5.MinimumWidth = 6;
            Column5.Name = "Column5";
            Column5.ReadOnly = true;
            Column5.Width = 300;
            // 
            // frmPostingUnPosting
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = Color.Gainsboro;
            ClientSize = new Size(883, 567);
            Controls.Add(btnExit);
            Controls.Add(txtPostStatus);
            Controls.Add(btnPosing);
            Controls.Add(btnUndoPosting);
            Controls.Add(dgvData);
            Controls.Add(gpOpreation);
            Controls.Add(gpPosting);
            Icon = (Icon)resources.GetObject("$this.Icon");
            MaximizeBox = false;
            MinimizeBox = false;
            Name = "frmPostingUnPosting";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Load += frmPostingUnPosting_Load;
            gpOpreation.ResumeLayout(false);
            gpPosting.ResumeLayout(false);
            gpPosting.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)dgvData).EndInit();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion
        public Button btnPosing;
        public Button btnUndoPosting;
        private Button btnExit;
        private Button btnSearch;
        private RadioButton rbSaleBill;
        private RadioButton rbPurBill;
        private RadioButton rbMoneyRecieveBond;
        private RadioButton rbMoneyPayBond;
        private RadioButton rbJurnalEntry;
        private GroupBox gpOpreation;
        public DateTimePicker dtpRptToDate;
        public TextBox txtPostStatus;
        public DateTimePicker dtpRptFromDate;
        private Label lbl2;
        private Label lbl1;
        private GroupBox gpPosting;
        private DataGridView dgvData;
        private RadioButton rbSaleReturnBill;
        private RadioButton rbPurReturnBill;
        private DataGridViewCheckBoxColumn Column1;
        private DataGridViewTextBoxColumn Column2;
        private DataGridViewTextBoxColumn Column3;
        private DataGridViewTextBoxColumn Column4;
        private DataGridViewTextBoxColumn Column5;
    }
}