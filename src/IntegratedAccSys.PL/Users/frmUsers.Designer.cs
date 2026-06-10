namespace IntegratedAccSys.PL.Users
{
    partial class frmUsers
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmUsers));
            btnDel = new Button();
            btnEdit = new Button();
            btnNew = new Button();
            btnExit = new Button();
            groupBox3 = new GroupBox();
            btnAdd = new Button();
            dgvData = new DataGridView();
            groupBox1 = new GroupBox();
            label1 = new Label();
            label2 = new Label();
            label3 = new Label();
            label4 = new Label();
            label5 = new Label();
            label6 = new Label();
            txtUserNo = new TextBox();
            txtFullName = new TextBox();
            txtID = new TextBox();
            txtPWD = new TextBox();
            txtMobile = new TextBox();
            txtUserEmail = new TextBox();
            groupBox4 = new GroupBox();
            btnClear = new Button();
            btnBrawse = new Button();
            pbUserImg = new PictureBox();
            groupBox2 = new GroupBox();
            groupBox3.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)dgvData).BeginInit();
            groupBox1.SuspendLayout();
            groupBox4.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)pbUserImg).BeginInit();
            groupBox2.SuspendLayout();
            SuspendLayout();
            // 
            // btnDel
            // 
            btnDel.Image = (Image)resources.GetObject("btnDel.Image");
            btnDel.Location = new Point(211, 20);
            btnDel.Name = "btnDel";
            btnDel.Size = new Size(111, 48);
            btnDel.TabIndex = 3;
            btnDel.UseVisualStyleBackColor = true;
            btnDel.Click += btnDel_Click;
            // 
            // btnEdit
            // 
            btnEdit.Image = (Image)resources.GetObject("btnEdit.Image");
            btnEdit.Location = new Point(322, 20);
            btnEdit.Name = "btnEdit";
            btnEdit.Size = new Size(111, 48);
            btnEdit.TabIndex = 2;
            btnEdit.UseVisualStyleBackColor = true;
            btnEdit.Click += btnEdit_Click;
            // 
            // btnNew
            // 
            btnNew.Image = (Image)resources.GetObject("btnNew.Image");
            btnNew.Location = new Point(544, 20);
            btnNew.Name = "btnNew";
            btnNew.Size = new Size(111, 48);
            btnNew.TabIndex = 0;
            btnNew.UseVisualStyleBackColor = true;
            btnNew.Click += btnNew_Click;
            // 
            // btnExit
            // 
            btnExit.Image = (Image)resources.GetObject("btnExit.Image");
            btnExit.Location = new Point(31, 20);
            btnExit.Name = "btnExit";
            btnExit.Size = new Size(126, 48);
            btnExit.TabIndex = 0;
            btnExit.Click += btnExit_Click;
            // 
            // groupBox3
            // 
            groupBox3.Controls.Add(btnExit);
            groupBox3.Controls.Add(btnDel);
            groupBox3.Controls.Add(btnEdit);
            groupBox3.Controls.Add(btnAdd);
            groupBox3.Controls.Add(btnNew);
            groupBox3.Dock = DockStyle.Bottom;
            groupBox3.Location = new Point(0, 523);
            groupBox3.Name = "groupBox3";
            groupBox3.Size = new Size(689, 88);
            groupBox3.TabIndex = 5;
            groupBox3.TabStop = false;
            // 
            // btnAdd
            // 
            btnAdd.Image = (Image)resources.GetObject("btnAdd.Image");
            btnAdd.Location = new Point(433, 20);
            btnAdd.Name = "btnAdd";
            btnAdd.Size = new Size(111, 48);
            btnAdd.TabIndex = 1;
            btnAdd.UseVisualStyleBackColor = true;
            btnAdd.Click += btnAdd_Click;
            // 
            // dgvData
            // 
            dgvData.AllowUserToAddRows = false;
            dgvData.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            dgvData.BackgroundColor = Color.Azure;
            dgvData.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            dgvData.Location = new Point(12, 23);
            dgvData.Name = "dgvData";
            dgvData.RowHeadersVisible = false;
            dgvData.RowHeadersWidth = 51;
            dgvData.Size = new Size(665, 165);
            dgvData.TabIndex = 0;
            dgvData.DoubleClick += dgvData_DoubleClick;
            // 
            // groupBox1
            // 
            groupBox1.Controls.Add(dgvData);
            groupBox1.Dock = DockStyle.Top;
            groupBox1.Location = new Point(0, 0);
            groupBox1.Name = "groupBox1";
            groupBox1.Size = new Size(689, 191);
            groupBox1.TabIndex = 3;
            groupBox1.TabStop = false;
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Arial", 12F, FontStyle.Bold);
            label1.ForeColor = Color.FromArgb(192, 0, 0);
            label1.Location = new Point(559, 34);
            label1.Name = "label1";
            label1.Size = new Size(88, 24);
            label1.TabIndex = 0;
            label1.Text = "رقم الستخدم";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Arial", 12F, FontStyle.Bold);
            label2.ForeColor = Color.FromArgb(192, 0, 0);
            label2.Location = new Point(558, 76);
            label2.Name = "label2";
            label2.Size = new Size(89, 24);
            label2.TabIndex = 1;
            label2.Text = "الإسم رباعيا";
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Font = new Font("Arial", 12F, FontStyle.Bold);
            label3.ForeColor = Color.FromArgb(192, 0, 0);
            label3.Location = new Point(579, 118);
            label3.Name = "label3";
            label3.Size = new Size(68, 24);
            label3.TabIndex = 2;
            label3.Text = "المستخدم";
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Font = new Font("Arial", 12F, FontStyle.Bold);
            label4.ForeColor = Color.FromArgb(192, 0, 0);
            label4.Location = new Point(559, 160);
            label4.Name = "label4";
            label4.Size = new Size(88, 24);
            label4.TabIndex = 3;
            label4.Text = "كلمة المرور";
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Font = new Font("Arial", 12F, FontStyle.Bold);
            label5.ForeColor = Color.FromArgb(192, 0, 0);
            label5.Location = new Point(596, 202);
            label5.Name = "label5";
            label5.Size = new Size(51, 24);
            label5.TabIndex = 4;
            label5.Text = "موبايل";
            // 
            // label6
            // 
            label6.AutoSize = true;
            label6.Font = new Font("Arial", 12F, FontStyle.Bold);
            label6.ForeColor = Color.FromArgb(192, 0, 0);
            label6.Location = new Point(530, 244);
            label6.Name = "label6";
            label6.Size = new Size(117, 24);
            label6.TabIndex = 5;
            label6.Text = "البريد الإلكتروني";
            // 
            // txtUserNo
            // 
            txtUserNo.BackColor = Color.FromArgb(192, 255, 255);
            txtUserNo.Font = new Font("Arial", 12F, FontStyle.Bold);
            txtUserNo.ForeColor = Color.Navy;
            txtUserNo.Location = new Point(266, 31);
            txtUserNo.Multiline = true;
            txtUserNo.Name = "txtUserNo";
            txtUserNo.ReadOnly = true;
            txtUserNo.Size = new Size(239, 27);
            txtUserNo.TabIndex = 7;
            txtUserNo.TextAlign = HorizontalAlignment.Center;
            // 
            // txtFullName
            // 
            txtFullName.Font = new Font("Arial", 12F, FontStyle.Bold);
            txtFullName.ForeColor = Color.Navy;
            txtFullName.Location = new Point(266, 73);
            txtFullName.Name = "txtFullName";
            txtFullName.Size = new Size(239, 30);
            txtFullName.TabIndex = 8;
            txtFullName.TextAlign = HorizontalAlignment.Center;
            txtFullName.Enter += txtFullName_Enter;
            txtFullName.KeyDown += txtFullName_KeyDown;
            // 
            // txtID
            // 
            txtID.Font = new Font("Arial", 12F, FontStyle.Bold);
            txtID.ForeColor = Color.Navy;
            txtID.Location = new Point(266, 115);
            txtID.Name = "txtID";
            txtID.Size = new Size(239, 30);
            txtID.TabIndex = 9;
            txtID.TextAlign = HorizontalAlignment.Center;
            txtID.Enter += txtID_Enter;
            txtID.KeyDown += txtID_KeyDown;
            // 
            // txtPWD
            // 
            txtPWD.Font = new Font("Arial", 12F, FontStyle.Bold);
            txtPWD.ForeColor = Color.Navy;
            txtPWD.Location = new Point(266, 157);
            txtPWD.Name = "txtPWD";
            txtPWD.PasswordChar = '*';
            txtPWD.Size = new Size(239, 30);
            txtPWD.TabIndex = 10;
            txtPWD.TextAlign = HorizontalAlignment.Center;
            txtPWD.Enter += txtPWD_Enter;
            txtPWD.KeyDown += txtPWD_KeyDown;
            // 
            // txtMobile
            // 
            txtMobile.Font = new Font("Arial", 12F, FontStyle.Bold);
            txtMobile.ForeColor = Color.Navy;
            txtMobile.Location = new Point(266, 199);
            txtMobile.Name = "txtMobile";
            txtMobile.Size = new Size(239, 30);
            txtMobile.TabIndex = 11;
            txtMobile.TextAlign = HorizontalAlignment.Center;
            txtMobile.Enter += txtMobile_Enter;
            txtMobile.KeyDown += txtMobile_KeyDown;
            // 
            // txtUserEmail
            // 
            txtUserEmail.Font = new Font("Arial", 12F, FontStyle.Bold);
            txtUserEmail.ForeColor = Color.Navy;
            txtUserEmail.Location = new Point(266, 241);
            txtUserEmail.Name = "txtUserEmail";
            txtUserEmail.Size = new Size(239, 30);
            txtUserEmail.TabIndex = 12;
            txtUserEmail.TextAlign = HorizontalAlignment.Center;
            txtUserEmail.Enter += txtUserEmail_Enter;
            txtUserEmail.KeyDown += txtUserEmail_KeyDown;
            // 
            // groupBox4
            // 
            groupBox4.Controls.Add(btnClear);
            groupBox4.Controls.Add(btnBrawse);
            groupBox4.Controls.Add(pbUserImg);
            groupBox4.Location = new Point(13, 18);
            groupBox4.Name = "groupBox4";
            groupBox4.Size = new Size(219, 295);
            groupBox4.TabIndex = 14;
            groupBox4.TabStop = false;
            // 
            // btnClear
            // 
            btnClear.Image = (Image)resources.GetObject("btnClear.Image");
            btnClear.Location = new Point(6, 239);
            btnClear.Name = "btnClear";
            btnClear.Size = new Size(94, 50);
            btnClear.TabIndex = 2;
            btnClear.UseVisualStyleBackColor = true;
            btnClear.Click += btnClear_Click;
            // 
            // btnBrawse
            // 
            btnBrawse.Image = (Image)resources.GetObject("btnBrawse.Image");
            btnBrawse.Location = new Point(106, 239);
            btnBrawse.Name = "btnBrawse";
            btnBrawse.Size = new Size(94, 50);
            btnBrawse.TabIndex = 1;
            btnBrawse.UseVisualStyleBackColor = true;
            btnBrawse.Click += btnBrawse_Click;
            // 
            // pbUserImg
            // 
            pbUserImg.BackColor = Color.FromArgb(255, 224, 192);
            pbUserImg.BackgroundImageLayout = ImageLayout.Stretch;
            pbUserImg.Location = new Point(6, 26);
            pbUserImg.Name = "pbUserImg";
            pbUserImg.Size = new Size(194, 191);
            pbUserImg.SizeMode = PictureBoxSizeMode.StretchImage;
            pbUserImg.TabIndex = 0;
            pbUserImg.TabStop = false;
            // 
            // groupBox2
            // 
            groupBox2.Controls.Add(groupBox4);
            groupBox2.Controls.Add(txtUserEmail);
            groupBox2.Controls.Add(txtMobile);
            groupBox2.Controls.Add(txtPWD);
            groupBox2.Controls.Add(txtID);
            groupBox2.Controls.Add(txtFullName);
            groupBox2.Controls.Add(txtUserNo);
            groupBox2.Controls.Add(label6);
            groupBox2.Controls.Add(label5);
            groupBox2.Controls.Add(label4);
            groupBox2.Controls.Add(label3);
            groupBox2.Controls.Add(label2);
            groupBox2.Controls.Add(label1);
            groupBox2.Location = new Point(6, 197);
            groupBox2.Name = "groupBox2";
            groupBox2.Size = new Size(671, 328);
            groupBox2.TabIndex = 4;
            groupBox2.TabStop = false;
            groupBox2.UseCompatibleTextRendering = true;
            // 
            // frmUsers
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(689, 611);
            Controls.Add(groupBox3);
            Controls.Add(groupBox2);
            Controls.Add(groupBox1);
            Icon = (Icon)resources.GetObject("$this.Icon");
            Name = "frmUsers";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "المستخدمين";
            Load += frmUsers_Load;
            groupBox3.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)dgvData).EndInit();
            groupBox1.ResumeLayout(false);
            groupBox4.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)pbUserImg).EndInit();
            groupBox2.ResumeLayout(false);
            groupBox2.PerformLayout();
            ResumeLayout(false);
        }

        #endregion

        private Button btnDel;
        private Button btnEdit;
        private Button btnNew;
        private Button btnExit;
        private GroupBox groupBox3;
        private Button btnAdd;
        private DataGridView dgvData;
        private GroupBox groupBox1;
        private Label label1;
        private Label label2;
        private Label label3;
        private Label label4;
        private Label label5;
        private Label label6;
        private TextBox txtUserNo;
        private TextBox txtFullName;
        private TextBox txtID;
        private TextBox txtPWD;
        private TextBox txtMobile;
        private TextBox txtUserEmail;
        private GroupBox groupBox4;
        private Button btnClear;
        private Button btnBrawse;
        private PictureBox pbUserImg;
        private GroupBox groupBox2;
    }
}