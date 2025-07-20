namespace IntegratedAccSys.PL.stores
{
    partial class frmInventoryMovement
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmInventoryMovement));
            DataGridViewCellStyle dataGridViewCellStyle1 = new DataGridViewCellStyle();
            DataGridViewCellStyle dataGridViewCellStyle2 = new DataGridViewCellStyle();
            DataGridViewCellStyle dataGridViewCellStyle3 = new DataGridViewCellStyle();
            btnExit = new Button();
            btnPrint = new Button();
            dgvData = new DataGridView();
            btnDisplay = new Button();
            dtpToDate = new DateTimePicker();
            dtpFromDate = new DateTimePicker();
            label3 = new Label();
            label2 = new Label();
            ((System.ComponentModel.ISupportInitialize)dgvData).BeginInit();
            SuspendLayout();
            // 
            // btnExit
            // 
            btnExit.BackColor = Color.FromArgb(0, 64, 64);
            btnExit.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnExit.Image = (Image)resources.GetObject("btnExit.Image");
            btnExit.Location = new Point(919, 632);
            btnExit.Name = "btnExit";
            btnExit.Size = new Size(104, 49);
            btnExit.TabIndex = 62;
            btnExit.UseVisualStyleBackColor = false;
            btnExit.Click += btnExit_Click;
            // 
            // btnPrint
            // 
            btnPrint.BackColor = Color.FromArgb(0, 64, 64);
            btnPrint.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnPrint.Image = (Image)resources.GetObject("btnPrint.Image");
            btnPrint.Location = new Point(37, 632);
            btnPrint.Name = "btnPrint";
            btnPrint.Size = new Size(131, 49);
            btnPrint.TabIndex = 61;
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
            dgvData.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.AllCells;
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
            dgvData.Location = new Point(12, 81);
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
            dgvData.Size = new Size(1049, 533);
            dgvData.TabIndex = 60;
            // 
            // btnDisplay
            // 
            btnDisplay.Image = (Image)resources.GetObject("btnDisplay.Image");
            btnDisplay.Location = new Point(937, 18);
            btnDisplay.Name = "btnDisplay";
            btnDisplay.Size = new Size(108, 43);
            btnDisplay.TabIndex = 59;
            btnDisplay.UseVisualStyleBackColor = true;
            btnDisplay.Click += btnDisplay_Click;
            // 
            // dtpToDate
            // 
            dtpToDate.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            dtpToDate.Location = new Point(459, 24);
            dtpToDate.Name = "dtpToDate";
            dtpToDate.Size = new Size(202, 30);
            dtpToDate.TabIndex = 58;
            // 
            // dtpFromDate
            // 
            dtpFromDate.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            dtpFromDate.Location = new Point(124, 24);
            dtpFromDate.Name = "dtpFromDate";
            dtpFromDate.Size = new Size(202, 30);
            dtpFromDate.TabIndex = 57;
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label3.ForeColor = Color.Blue;
            label3.Location = new Point(363, 28);
            label3.Name = "label3";
            label3.Size = new Size(70, 23);
            label3.TabIndex = 56;
            label3.Text = "إلى تاريخ";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label2.ForeColor = Color.Blue;
            label2.Location = new Point(26, 28);
            label2.Name = "label2";
            label2.Size = new Size(69, 23);
            label2.TabIndex = 55;
            label2.Text = "من تاريخ";
            // 
            // frmInventoryMovement
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(1073, 698);
            Controls.Add(btnExit);
            Controls.Add(btnPrint);
            Controls.Add(dgvData);
            Controls.Add(btnDisplay);
            Controls.Add(dtpToDate);
            Controls.Add(dtpFromDate);
            Controls.Add(label3);
            Controls.Add(label2);
            MaximizeBox = false;
            MinimizeBox = false;
            Name = "frmInventoryMovement";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "حركة المخزون";
            Load += frmInventoryMovement_Load;
            ((System.ComponentModel.ISupportInitialize)dgvData).EndInit();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Button btnExit;
        private Button btnPrint;
        public DataGridView dgvData;
        private Button btnDisplay;
        public DateTimePicker dtpToDate;
        public DateTimePicker dtpFromDate;
        private Label label3;
        private Label label2;
    }
}