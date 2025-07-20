namespace IntegratedAccSys.PL.SysFormat
{
    partial class frmBanks
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmBanks));
            groupBox1 = new GroupBox();
            btnExit = new Button();
            btnDel = new Button();
            btnEdit = new Button();
            btnAdd = new Button();
            btnNew = new Button();
            txtAccName = new TextBox();
            txtAccNo = new TextBox();
            label2 = new Label();
            label1 = new Label();
            dgvData = new DataGridView();
            groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)dgvData).BeginInit();
            SuspendLayout();
            // 
            // groupBox1
            // 
            groupBox1.Controls.Add(btnExit);
            groupBox1.Controls.Add(btnDel);
            groupBox1.Controls.Add(btnEdit);
            groupBox1.Controls.Add(btnAdd);
            groupBox1.Controls.Add(btnNew);
            groupBox1.Location = new Point(12, 349);
            groupBox1.Name = "groupBox1";
            groupBox1.Size = new Size(473, 75);
            groupBox1.TabIndex = 11;
            groupBox1.TabStop = false;
            // 
            // btnExit
            // 
            btnExit.Image = (Image)resources.GetObject("btnExit.Image");
            btnExit.Location = new Point(22, 25);
            btnExit.Name = "btnExit";
            btnExit.Size = new Size(79, 42);
            btnExit.TabIndex = 4;
            btnExit.UseVisualStyleBackColor = true;
            btnExit.Click += btnExit_Click;
            // 
            // btnDel
            // 
            btnDel.Enabled = false;
            btnDel.Image = (Image)resources.GetObject("btnDel.Image");
            btnDel.Location = new Point(110, 24);
            btnDel.Name = "btnDel";
            btnDel.Size = new Size(79, 42);
            btnDel.TabIndex = 3;
            btnDel.UseVisualStyleBackColor = true;
            btnDel.Click += btnDel_Click;
            // 
            // btnEdit
            // 
            btnEdit.Enabled = false;
            btnEdit.Image = (Image)resources.GetObject("btnEdit.Image");
            btnEdit.Location = new Point(198, 24);
            btnEdit.Name = "btnEdit";
            btnEdit.Size = new Size(79, 42);
            btnEdit.TabIndex = 2;
            btnEdit.UseVisualStyleBackColor = true;
            btnEdit.Click += btnEdit_Click;
            // 
            // btnAdd
            // 
            btnAdd.Enabled = false;
            btnAdd.Image = (Image)resources.GetObject("btnAdd.Image");
            btnAdd.Location = new Point(286, 24);
            btnAdd.Name = "btnAdd";
            btnAdd.Size = new Size(79, 42);
            btnAdd.TabIndex = 1;
            btnAdd.UseVisualStyleBackColor = true;
            btnAdd.Click += btnAdd_Click;
            // 
            // btnNew
            // 
            btnNew.Image = (Image)resources.GetObject("btnNew.Image");
            btnNew.Location = new Point(374, 24);
            btnNew.Name = "btnNew";
            btnNew.Size = new Size(79, 42);
            btnNew.TabIndex = 0;
            btnNew.UseVisualStyleBackColor = true;
            btnNew.Click += btnNew_Click;
            // 
            // txtAccName
            // 
            txtAccName.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtAccName.Location = new Point(144, 303);
            txtAccName.Name = "txtAccName";
            txtAccName.Size = new Size(320, 30);
            txtAccName.TabIndex = 10;
            // 
            // txtAccNo
            // 
            txtAccNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtAccNo.Location = new Point(144, 265);
            txtAccNo.Name = "txtAccNo";
            txtAccNo.Size = new Size(320, 30);
            txtAccNo.TabIndex = 9;
            txtAccNo.KeyDown += txtAccNo_KeyDown;
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label2.Location = new Point(32, 306);
            label2.Name = "label2";
            label2.Size = new Size(87, 23);
            label2.TabIndex = 8;
            label2.Text = "إسم الحساب";
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label1.Location = new Point(32, 269);
            label1.Name = "label1";
            label1.Size = new Size(86, 23);
            label1.TabIndex = 7;
            label1.Text = "رقم الحساب";
            // 
            // dgvData
            // 
            dgvData.AllowUserToAddRows = false;
            dgvData.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            dgvData.BackgroundColor = Color.Azure;
            dgvData.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            dgvData.GridColor = Color.FromArgb(0, 64, 0);
            dgvData.Location = new Point(12, 11);
            dgvData.Name = "dgvData";
            dgvData.RowHeadersVisible = false;
            dgvData.RowHeadersWidth = 51;
            dgvData.Size = new Size(473, 234);
            dgvData.TabIndex = 6;
            dgvData.CellClick += dgvData_CellClick;
            // 
            // frmBanks
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(497, 435);
            Controls.Add(groupBox1);
            Controls.Add(txtAccName);
            Controls.Add(txtAccNo);
            Controls.Add(label2);
            Controls.Add(label1);
            Controls.Add(dgvData);
            Icon = (Icon)resources.GetObject("$this.Icon");
            Name = "frmBanks";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "البنوك";
            Load += frmBanks_Load;
            groupBox1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)dgvData).EndInit();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private GroupBox groupBox1;
        private Button btnExit;
        private Button btnDel;
        private Button btnEdit;
        private Button btnAdd;
        private Button btnNew;
        private TextBox txtAccName;
        private TextBox txtAccNo;
        private Label label2;
        private Label label1;
        private DataGridView dgvData;
    }
}