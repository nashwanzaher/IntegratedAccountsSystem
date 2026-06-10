namespace IntegratedAccSys.PL.Users
{
    partial class frmPrivillages
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmPrivillages));
            lbUsers = new ListBox();
            lbMenus = new ListBox();
            dgvData = new DataGridView();
            btnNewUser = new Button();
            btnSavePrivillages = new Button();
            btnExit = new Button();
            label1 = new Label();
            label2 = new Label();
            ((System.ComponentModel.ISupportInitialize)dgvData).BeginInit();
            SuspendLayout();
            // 
            // lbUsers
            // 
            lbUsers.BackColor = Color.Navy;
            lbUsers.Font = new Font("Times New Roman", 14F, FontStyle.Bold);
            lbUsers.ForeColor = Color.White;
            lbUsers.FormattingEnabled = true;
            lbUsers.ItemHeight = 25;
            lbUsers.Location = new Point(29, 71);
            lbUsers.Name = "lbUsers";
            lbUsers.Size = new Size(224, 154);
            lbUsers.TabIndex = 0;
            lbUsers.SelectedIndexChanged += lbUsers_SelectedIndexChanged;
            // 
            // lbMenus
            // 
            lbMenus.BackColor = Color.FromArgb(0, 64, 64);
            lbMenus.Font = new Font("Times New Roman", 14F, FontStyle.Bold);
            lbMenus.ForeColor = Color.Yellow;
            lbMenus.FormattingEnabled = true;
            lbMenus.ItemHeight = 25;
            lbMenus.Location = new Point(29, 311);
            lbMenus.Name = "lbMenus";
            lbMenus.Size = new Size(224, 229);
            lbMenus.TabIndex = 1;
            lbMenus.SelectedIndexChanged += lbMenus_SelectedIndexChanged;
            // 
            // dgvData
            // 
            dgvData.AllowUserToAddRows = false;
            dgvData.BackgroundColor = Color.Ivory;
            dgvData.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            dgvData.Location = new Point(275, 71);
            dgvData.Name = "dgvData";
            dgvData.RowHeadersVisible = false;
            dgvData.RowHeadersWidth = 51;
            dgvData.Size = new Size(1022, 474);
            dgvData.TabIndex = 2;
            // 
            // btnNewUser
            // 
            btnNewUser.BackColor = Color.FromArgb(64, 0, 64);
            btnNewUser.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnNewUser.ForeColor = Color.White;
            btnNewUser.Image = (Image)resources.GetObject("btnNewUser.Image");
            btnNewUser.ImageAlign = ContentAlignment.MiddleRight;
            btnNewUser.Location = new Point(42, 565);
            btnNewUser.Name = "btnNewUser";
            btnNewUser.Size = new Size(181, 50);
            btnNewUser.TabIndex = 3;
            btnNewUser.Text = "مستخدم جديد";
            btnNewUser.UseVisualStyleBackColor = false;
            btnNewUser.Click += btnNewUser_Click;
            // 
            // btnSavePrivillages
            // 
            btnSavePrivillages.BackColor = Color.FromArgb(64, 0, 64);
            btnSavePrivillages.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnSavePrivillages.ForeColor = Color.White;
            btnSavePrivillages.Image = (Image)resources.GetObject("btnSavePrivillages.Image");
            btnSavePrivillages.ImageAlign = ContentAlignment.MiddleRight;
            btnSavePrivillages.Location = new Point(229, 565);
            btnSavePrivillages.Name = "btnSavePrivillages";
            btnSavePrivillages.Size = new Size(181, 50);
            btnSavePrivillages.TabIndex = 4;
            btnSavePrivillages.Text = "حفظ الصلاحيات";
            btnSavePrivillages.UseVisualStyleBackColor = false;
            btnSavePrivillages.Click += btnSavePrivillages_Click;
            // 
            // btnExit
            // 
            btnExit.BackColor = Color.FromArgb(64, 0, 64);
            btnExit.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnExit.ForeColor = Color.White;
            btnExit.Image = (Image)resources.GetObject("btnExit.Image");
            btnExit.ImageAlign = ContentAlignment.MiddleRight;
            btnExit.Location = new Point(1154, 565);
            btnExit.Name = "btnExit";
            btnExit.Size = new Size(143, 50);
            btnExit.TabIndex = 5;
            btnExit.Text = "خروج";
            btnExit.UseVisualStyleBackColor = false;
            btnExit.Click += btnExit_Click;
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Times New Roman", 14F, FontStyle.Bold);
            label1.ForeColor = Color.FromArgb(192, 0, 0);
            label1.Location = new Point(29, 31);
            label1.Name = "label1";
            label1.Size = new Size(106, 26);
            label1.TabIndex = 6;
            label1.Text = "المستخدمين";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Times New Roman", 14F, FontStyle.Bold);
            label2.ForeColor = Color.FromArgb(192, 0, 0);
            label2.Location = new Point(29, 270);
            label2.Name = "label2";
            label2.Size = new Size(63, 26);
            label2.TabIndex = 7;
            label2.Text = "القوائم";
            // 
            // frmPrivillages
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = Color.Gainsboro;
            ClientSize = new Size(1309, 633);
            Controls.Add(label2);
            Controls.Add(label1);
            Controls.Add(btnExit);
            Controls.Add(btnSavePrivillages);
            Controls.Add(btnNewUser);
            Controls.Add(dgvData);
            Controls.Add(lbMenus);
            Controls.Add(lbUsers);
            Icon = (Icon)resources.GetObject("$this.Icon");
            MaximizeBox = false;
            MinimizeBox = false;
            Name = "frmPrivillages";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "صلاحيات المستخدمين";
            Load += frmPrivillages_Load;
            ((System.ComponentModel.ISupportInitialize)dgvData).EndInit();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private ListBox lbUsers;
        private ListBox lbMenus;
        private DataGridView dgvData;
        private Button btnNewUser;
        private Button btnSavePrivillages;
        private Button btnExit;
        private Label label1;
        private Label label2;
    }
}