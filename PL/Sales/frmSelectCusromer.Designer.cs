namespace IntegratedAccSys.PL.Sales
{
    partial class frmSelectCusromer
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmSelectCusromer));
            btnExit = new Button();
            dgvData = new DataGridView();
            txtSearch = new TextBox();
            label1 = new Label();
            ((System.ComponentModel.ISupportInitialize)dgvData).BeginInit();
            SuspendLayout();
            // 
            // btnExit
            // 
            btnExit.BackColor = Color.White;
            btnExit.Image = (Image)resources.GetObject("btnExit.Image");
            btnExit.Location = new Point(388, 382);
            btnExit.Name = "btnExit";
            btnExit.Size = new Size(119, 55);
            btnExit.TabIndex = 11;
            btnExit.UseVisualStyleBackColor = false;
            // 
            // dgvData
            // 
            dgvData.AllowUserToAddRows = false;
            dgvData.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            dgvData.BackgroundColor = Color.Azure;
            dgvData.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            dgvData.GridColor = Color.FromArgb(0, 64, 0);
            dgvData.Location = new Point(12, 72);
            dgvData.Name = "dgvData";
            dgvData.RowHeadersVisible = false;
            dgvData.RowHeadersWidth = 51;
            dgvData.Size = new Size(495, 295);
            dgvData.TabIndex = 10;
            dgvData.CellDoubleClick += dgvData_CellDoubleClick;
            // 
            // txtSearch
            // 
            txtSearch.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtSearch.Location = new Point(111, 21);
            txtSearch.Name = "txtSearch";
            txtSearch.Size = new Size(384, 30);
            txtSearch.TabIndex = 9;
            txtSearch.TextChanged += txtSearch_TextChanged;
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label1.Location = new Point(39, 24);
            label1.Name = "label1";
            label1.Size = new Size(66, 23);
            label1.TabIndex = 8;
            label1.Text = "أبحث هنا";
            // 
            // frmSelectCusromer
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(518, 459);
            Controls.Add(btnExit);
            Controls.Add(dgvData);
            Controls.Add(txtSearch);
            Controls.Add(label1);
            Icon = (Icon)resources.GetObject("$this.Icon");
            Name = "frmSelectCusromer";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "إختيار عميل";
            Load += frmSelectCusromer_Load;
            ((System.ComponentModel.ISupportInitialize)dgvData).EndInit();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Button btnExit;
        public DataGridView dgvData;
        public TextBox txtSearch;
        public Label label1;
    }
}