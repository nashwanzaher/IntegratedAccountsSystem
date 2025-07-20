namespace IntegratedAccSys.PL.Accounts
{
    partial class frmTrailBalance
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmTrailBalance));
            DataGridViewCellStyle dataGridViewCellStyle1 = new DataGridViewCellStyle();
            DataGridViewCellStyle dataGridViewCellStyle2 = new DataGridViewCellStyle();
            DataGridViewCellStyle dataGridViewCellStyle3 = new DataGridViewCellStyle();
            txtBalance = new TextBox();
            txtCreditor = new TextBox();
            txtDebitor = new TextBox();
            label9 = new Label();
            label8 = new Label();
            label1 = new Label();
            btnExit = new Button();
            btnPrint = new Button();
            dgvData = new DataGridView();
            txtCurrVal = new TextBox();
            cbCurrencies = new ComboBox();
            label5 = new Label();
            label4 = new Label();
            dtpToDate = new DateTimePicker();
            dtpFromDate = new DateTimePicker();
            label3 = new Label();
            label2 = new Label();
            btnDisplay = new Button();
            ((System.ComponentModel.ISupportInitialize)dgvData).BeginInit();
            SuspendLayout();
            // 
            // txtBalance
            // 
            txtBalance.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtBalance.Location = new Point(795, 476);
            txtBalance.Name = "txtBalance";
            txtBalance.ReadOnly = true;
            txtBalance.Size = new Size(151, 30);
            txtBalance.TabIndex = 58;
            txtBalance.Text = "0";
            txtBalance.TextAlign = HorizontalAlignment.Center;
            // 
            // txtCreditor
            // 
            txtCreditor.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtCreditor.Location = new Point(517, 476);
            txtCreditor.Name = "txtCreditor";
            txtCreditor.ReadOnly = true;
            txtCreditor.Size = new Size(151, 30);
            txtCreditor.TabIndex = 57;
            txtCreditor.Text = "0";
            txtCreditor.TextAlign = HorizontalAlignment.Center;
            // 
            // txtDebitor
            // 
            txtDebitor.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtDebitor.Location = new Point(217, 476);
            txtDebitor.Name = "txtDebitor";
            txtDebitor.ReadOnly = true;
            txtDebitor.Size = new Size(151, 30);
            txtDebitor.TabIndex = 56;
            txtDebitor.Text = "0";
            txtDebitor.TextAlign = HorizontalAlignment.Center;
            // 
            // label9
            // 
            label9.AutoSize = true;
            label9.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label9.ForeColor = Color.FromArgb(192, 0, 0);
            label9.Location = new Point(719, 479);
            label9.Name = "label9";
            label9.Size = new Size(55, 23);
            label9.TabIndex = 55;
            label9.Text = "الرصيد";
            // 
            // label8
            // 
            label8.AutoSize = true;
            label8.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label8.ForeColor = Color.FromArgb(192, 0, 0);
            label8.Location = new Point(419, 479);
            label8.Name = "label8";
            label8.Size = new Size(78, 23);
            label8.TabIndex = 54;
            label8.Text = "رصيد دائن";
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label1.ForeColor = Color.FromArgb(192, 0, 0);
            label1.Location = new Point(114, 479);
            label1.Name = "label1";
            label1.Size = new Size(82, 23);
            label1.TabIndex = 53;
            label1.Text = "رصيد مدين";
            // 
            // btnExit
            // 
            btnExit.BackColor = Color.FromArgb(0, 64, 64);
            btnExit.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnExit.Image = (Image)resources.GetObject("btnExit.Image");
            btnExit.Location = new Point(894, 516);
            btnExit.Name = "btnExit";
            btnExit.Size = new Size(104, 49);
            btnExit.TabIndex = 52;
            btnExit.UseVisualStyleBackColor = false;
            btnExit.Click += btnExit_Click;
            // 
            // btnPrint
            // 
            btnPrint.BackColor = Color.FromArgb(0, 64, 64);
            btnPrint.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnPrint.Image = (Image)resources.GetObject("btnPrint.Image");
            btnPrint.Location = new Point(12, 516);
            btnPrint.Name = "btnPrint";
            btnPrint.Size = new Size(131, 49);
            btnPrint.TabIndex = 51;
            btnPrint.UseVisualStyleBackColor = false;
            btnPrint.Click += btnPrint_Click;
            // 
            // dgvData
            // 
            dgvData.AllowUserToAddRows = false;
            dataGridViewCellStyle1.Alignment = DataGridViewContentAlignment.MiddleCenter;
            dataGridViewCellStyle1.BackColor = Color.LightSkyBlue;
            dataGridViewCellStyle1.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            dataGridViewCellStyle1.ForeColor = Color.Black;
            dgvData.AlternatingRowsDefaultCellStyle = dataGridViewCellStyle1;
            dgvData.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            dgvData.BackgroundColor = Color.Azure;
            dataGridViewCellStyle2.Alignment = DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle2.BackColor = SystemColors.Control;
            dataGridViewCellStyle2.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            dataGridViewCellStyle2.ForeColor = SystemColors.WindowText;
            dataGridViewCellStyle2.SelectionBackColor = SystemColors.Highlight;
            dataGridViewCellStyle2.SelectionForeColor = SystemColors.HighlightText;
            dataGridViewCellStyle2.WrapMode = DataGridViewTriState.True;
            dgvData.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle2;
            dgvData.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            dgvData.GridColor = Color.Blue;
            dgvData.Location = new Point(12, 120);
            dgvData.Name = "dgvData";
            dataGridViewCellStyle3.Alignment = DataGridViewContentAlignment.MiddleCenter;
            dataGridViewCellStyle3.BackColor = Color.White;
            dataGridViewCellStyle3.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            dataGridViewCellStyle3.ForeColor = SystemColors.WindowText;
            dataGridViewCellStyle3.SelectionBackColor = SystemColors.Highlight;
            dataGridViewCellStyle3.SelectionForeColor = SystemColors.HighlightText;
            dataGridViewCellStyle3.WrapMode = DataGridViewTriState.True;
            dgvData.RowHeadersDefaultCellStyle = dataGridViewCellStyle3;
            dgvData.RowHeadersVisible = false;
            dgvData.RowHeadersWidth = 51;
            dgvData.Size = new Size(986, 345);
            dgvData.TabIndex = 50;
            // 
            // txtCurrVal
            // 
            txtCurrVal.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtCurrVal.Location = new Point(473, 61);
            txtCurrVal.Name = "txtCurrVal";
            txtCurrVal.ReadOnly = true;
            txtCurrVal.Size = new Size(195, 30);
            txtCurrVal.TabIndex = 45;
            // 
            // cbCurrencies
            // 
            cbCurrencies.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            cbCurrencies.FormattingEnabled = true;
            cbCurrencies.Location = new Point(473, 17);
            cbCurrencies.Name = "cbCurrencies";
            cbCurrencies.Size = new Size(195, 31);
            cbCurrencies.TabIndex = 44;
            cbCurrencies.SelectedIndexChanged += cbCurrencies_SelectedIndexChanged;
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label5.ForeColor = Color.Blue;
            label5.Location = new Point(392, 65);
            label5.Name = "label5";
            label5.Size = new Size(58, 23);
            label5.TabIndex = 43;
            label5.Text = "الصرف";
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label4.ForeColor = Color.Blue;
            label4.Location = new Point(397, 21);
            label4.Name = "label4";
            label4.Size = new Size(47, 23);
            label4.TabIndex = 42;
            label4.Text = "العملة";
            // 
            // dtpToDate
            // 
            dtpToDate.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            dtpToDate.Location = new Point(121, 62);
            dtpToDate.Name = "dtpToDate";
            dtpToDate.Size = new Size(202, 30);
            dtpToDate.TabIndex = 41;
            // 
            // dtpFromDate
            // 
            dtpFromDate.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            dtpFromDate.Location = new Point(123, 18);
            dtpFromDate.Name = "dtpFromDate";
            dtpFromDate.Size = new Size(202, 30);
            dtpFromDate.TabIndex = 40;
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label3.ForeColor = Color.Blue;
            label3.Location = new Point(25, 66);
            label3.Name = "label3";
            label3.Size = new Size(70, 23);
            label3.TabIndex = 39;
            label3.Text = "إلى تاريخ";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label2.ForeColor = Color.Blue;
            label2.Location = new Point(25, 22);
            label2.Name = "label2";
            label2.Size = new Size(69, 23);
            label2.TabIndex = 38;
            label2.Text = "من تاريخ";
            // 
            // btnDisplay
            // 
            btnDisplay.Image = (Image)resources.GetObject("btnDisplay.Image");
            btnDisplay.Location = new Point(894, 36);
            btnDisplay.Name = "btnDisplay";
            btnDisplay.Size = new Size(94, 52);
            btnDisplay.TabIndex = 59;
            btnDisplay.UseVisualStyleBackColor = true;
            btnDisplay.Click += btnDisplay_Click;
            // 
            // frmTrailBalance
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(1010, 583);
            Controls.Add(btnDisplay);
            Controls.Add(txtBalance);
            Controls.Add(txtCreditor);
            Controls.Add(txtDebitor);
            Controls.Add(label9);
            Controls.Add(label8);
            Controls.Add(label1);
            Controls.Add(btnExit);
            Controls.Add(btnPrint);
            Controls.Add(dgvData);
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
            Name = "frmTrailBalance";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "ميزان المراجعة";
            Load += frmTrailBalance_Load;
            ((System.ComponentModel.ISupportInitialize)dgvData).EndInit();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        public TextBox txtBalance;
        public TextBox txtCreditor;
        public TextBox txtDebitor;
        private Label label9;
        private Label label8;
        private Label label1;
        private Button btnExit;
        private Button btnPrint;
        public DataGridView dgvData;
        public TextBox txtCurrVal;
        public ComboBox cbCurrencies;
        private Label label5;
        private Label label4;
        public DateTimePicker dtpToDate;
        public DateTimePicker dtpFromDate;
        private Label label3;
        private Label label2;
        private Button btnDisplay;
    }
}