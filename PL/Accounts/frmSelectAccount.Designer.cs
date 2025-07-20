namespace IntegratedAccSys.PL.Accounts
{
    partial class frmSelectAccount
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmSelectAccount));
            label1 = new Label();
            txtSearch = new TextBox();
            dgvData = new DataGridView();
            btnExit = new Button();
            ((System.ComponentModel.ISupportInitialize)dgvData).BeginInit();
            SuspendLayout();
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label1.Location = new Point(39, 31);
            label1.Name = "label1";
            label1.Size = new Size(66, 23);
            label1.TabIndex = 0;
            label1.Text = "أبحث هنا";
            // 
            // txtSearch
            // 
            txtSearch.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtSearch.Location = new Point(111, 28);
            txtSearch.Name = "txtSearch";
            txtSearch.Size = new Size(384, 30);
            txtSearch.TabIndex = 1;
            txtSearch.TextChanged += txtSearch_TextChanged;
            // 
            // dgvData
            // 
            dgvData.AllowUserToAddRows = false;
            dgvData.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            dgvData.BackgroundColor = Color.Azure;
            dgvData.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            dgvData.GridColor = Color.FromArgb(0, 64, 0);
            dgvData.Location = new Point(12, 79);
            dgvData.Name = "dgvData";
            dgvData.RowHeadersVisible = false;
            dgvData.RowHeadersWidth = 51;
            dgvData.Size = new Size(495, 295);
            dgvData.TabIndex = 2;
            dgvData.CellClick += dgvData_CellClick;
            // 
            // btnExit
            // 
            btnExit.BackColor = Color.White;
            btnExit.Image = (Image)resources.GetObject("btnExit.Image");
            btnExit.Location = new Point(388, 389);
            btnExit.Name = "btnExit";
            btnExit.Size = new Size(119, 55);
            btnExit.TabIndex = 3;
            btnExit.UseVisualStyleBackColor = false;
            btnExit.Click += btnExit_Click;
            // 
            // frmSelectAccount
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(518, 459);
            Controls.Add(btnExit);
            Controls.Add(dgvData);
            Controls.Add(txtSearch);
            Controls.Add(label1);
            Icon = (Icon)resources.GetObject("$this.Icon");
            Name = "frmSelectAccount";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "إختيار حساب ";
            ((System.ComponentModel.ISupportInitialize)dgvData).EndInit();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion
        private Button btnExit;
        public Label label1;
        public TextBox txtSearch;
        public DataGridView dgvData;
    }
}