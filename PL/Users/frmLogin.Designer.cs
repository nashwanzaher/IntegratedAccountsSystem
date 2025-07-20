namespace IntegratedAccSys.PL.Users
{
    partial class frmLogin
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmLogin));
            label1 = new Label();
            label2 = new Label();
            label3 = new Label();
            txtBranch = new TextBox();
            txtUser = new TextBox();
            txtPWD = new TextBox();
            btnLogin = new Button();
            btnExit = new Button();
            SuspendLayout();
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Arial", 12F, FontStyle.Bold);
            label1.ForeColor = Color.FromArgb(0, 0, 192);
            label1.Location = new Point(45, 66);
            label1.Name = "label1";
            label1.Size = new Size(68, 24);
            label1.TabIndex = 0;
            label1.Text = "المستخدم";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Arial", 12F, FontStyle.Bold);
            label2.ForeColor = Color.FromArgb(0, 0, 192);
            label2.Location = new Point(41, 105);
            label2.Name = "label2";
            label2.Size = new Size(88, 24);
            label2.TabIndex = 1;
            label2.Text = "كلمة المرور";
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Font = new Font("Arial", 12F, FontStyle.Bold);
            label3.ForeColor = Color.FromArgb(0, 0, 192);
            label3.Location = new Point(45, 27);
            label3.Name = "label3";
            label3.Size = new Size(45, 24);
            label3.TabIndex = 2;
            label3.Text = "الفرع";
            // 
            // txtBranch
            // 
            txtBranch.Font = new Font("Arial", 12F, FontStyle.Bold);
            txtBranch.ForeColor = Color.Maroon;
            txtBranch.Location = new Point(135, 27);
            txtBranch.Name = "txtBranch";
            txtBranch.Size = new Size(247, 30);
            txtBranch.TabIndex = 3;
            txtBranch.TextAlign = HorizontalAlignment.Center;
            // 
            // txtUser
            // 
            txtUser.Font = new Font("Arial", 12F, FontStyle.Bold);
            txtUser.ForeColor = Color.Maroon;
            txtUser.Location = new Point(135, 63);
            txtUser.Name = "txtUser";
            txtUser.Size = new Size(247, 30);
            txtUser.TabIndex = 4;
            txtUser.TextAlign = HorizontalAlignment.Center;
            // 
            // txtPWD
            // 
            txtPWD.Font = new Font("Arial", 12F, FontStyle.Bold);
            txtPWD.ForeColor = Color.Maroon;
            txtPWD.Location = new Point(135, 99);
            txtPWD.Name = "txtPWD";
            txtPWD.PasswordChar = '*';
            txtPWD.Size = new Size(247, 30);
            txtPWD.TabIndex = 5;
            txtPWD.TextAlign = HorizontalAlignment.Center;
            // 
            // btnLogin
            // 
            btnLogin.Font = new Font("Arial", 12F, FontStyle.Bold);
            btnLogin.Image = (Image)resources.GetObject("btnLogin.Image");
            btnLogin.Location = new Point(65, 154);
            btnLogin.Name = "btnLogin";
            btnLogin.Size = new Size(134, 43);
            btnLogin.TabIndex = 6;
            btnLogin.UseVisualStyleBackColor = true;
            btnLogin.Click += btnLogin_Click;
            // 
            // btnExit
            // 
            btnExit.Font = new Font("Arial", 12F, FontStyle.Bold);
            btnExit.Image = (Image)resources.GetObject("btnExit.Image");
            btnExit.Location = new Point(244, 154);
            btnExit.Name = "btnExit";
            btnExit.Size = new Size(134, 43);
            btnExit.TabIndex = 7;
            btnExit.UseVisualStyleBackColor = true;
            btnExit.Click += btnExit_Click;
            // 
            // frmLogin
            // 
            AcceptButton = btnLogin;
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            CancelButton = btnExit;
            ClientSize = new Size(417, 220);
            Controls.Add(btnExit);
            Controls.Add(btnLogin);
            Controls.Add(txtPWD);
            Controls.Add(txtUser);
            Controls.Add(txtBranch);
            Controls.Add(label3);
            Controls.Add(label2);
            Controls.Add(label1);
            Icon = (Icon)resources.GetObject("$this.Icon");
            MaximizeBox = false;
            MinimizeBox = false;
            Name = "frmLogin";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "دخول";
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Label label1;
        private Label label2;
        private Label label3;
        private TextBox txtBranch;
        private TextBox txtUser;
        private TextBox txtPWD;
        private Button btnLogin;
        private Button btnExit;
    }
}