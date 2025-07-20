namespace IntegratedAccSys.PL.SysFormat
{
    partial class frmConnSettings
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmConnSettings));
            btnNew = new Button();
            btnSave = new Button();
            txtDisplay = new Button();
            txtExit = new Button();
            groupBox1 = new GroupBox();
            txtPWD = new TextBox();
            txtID = new TextBox();
            txtDB = new TextBox();
            txtServer = new TextBox();
            txtMode = new TextBox();
            label5 = new Label();
            label4 = new Label();
            label3 = new Label();
            label2 = new Label();
            label1 = new Label();
            groupBox2 = new GroupBox();
            groupBox1.SuspendLayout();
            groupBox2.SuspendLayout();
            SuspendLayout();
            // 
            // btnNew
            // 
            btnNew.Font = new Font("Arial", 13.8F, FontStyle.Bold);
            btnNew.ForeColor = Color.FromArgb(0, 64, 0);
            btnNew.Image = (Image)resources.GetObject("btnNew.Image");
            btnNew.Location = new Point(381, 23);
            btnNew.Name = "btnNew";
            btnNew.Size = new Size(113, 40);
            btnNew.TabIndex = 10;
            btnNew.UseVisualStyleBackColor = true;
            btnNew.Click += btnNew_Click;
            // 
            // btnSave
            // 
            btnSave.Font = new Font("Arial", 13.8F, FontStyle.Bold);
            btnSave.ForeColor = Color.FromArgb(0, 64, 0);
            btnSave.Image = (Image)resources.GetObject("btnSave.Image");
            btnSave.Location = new Point(264, 23);
            btnSave.Name = "btnSave";
            btnSave.Size = new Size(113, 40);
            btnSave.TabIndex = 11;
            btnSave.UseVisualStyleBackColor = true;
            btnSave.Click += btnSave_Click;
            // 
            // txtDisplay
            // 
            txtDisplay.Font = new Font("Arial", 13.8F, FontStyle.Bold);
            txtDisplay.ForeColor = Color.FromArgb(0, 64, 0);
            txtDisplay.Image = (Image)resources.GetObject("txtDisplay.Image");
            txtDisplay.Location = new Point(147, 23);
            txtDisplay.Name = "txtDisplay";
            txtDisplay.Size = new Size(113, 40);
            txtDisplay.TabIndex = 12;
            txtDisplay.UseVisualStyleBackColor = true;
            txtDisplay.Click += txtDisplay_Click;
            // 
            // txtExit
            // 
            txtExit.Font = new Font("Arial", 13.8F, FontStyle.Bold);
            txtExit.ForeColor = Color.FromArgb(0, 64, 0);
            txtExit.Image = (Image)resources.GetObject("txtExit.Image");
            txtExit.Location = new Point(30, 23);
            txtExit.Name = "txtExit";
            txtExit.Size = new Size(113, 40);
            txtExit.TabIndex = 13;
            txtExit.UseVisualStyleBackColor = true;
            txtExit.Click += txtExit_Click;
            // 
            // groupBox1
            // 
            groupBox1.Controls.Add(txtPWD);
            groupBox1.Controls.Add(txtID);
            groupBox1.Controls.Add(txtDB);
            groupBox1.Controls.Add(txtServer);
            groupBox1.Controls.Add(txtMode);
            groupBox1.Controls.Add(label5);
            groupBox1.Controls.Add(label4);
            groupBox1.Controls.Add(label3);
            groupBox1.Controls.Add(label2);
            groupBox1.Controls.Add(label1);
            groupBox1.Dock = DockStyle.Top;
            groupBox1.Location = new Point(0, 0);
            groupBox1.Name = "groupBox1";
            groupBox1.Size = new Size(517, 264);
            groupBox1.TabIndex = 14;
            groupBox1.TabStop = false;
            // 
            // txtPWD
            // 
            txtPWD.Font = new Font("Arial", 13.8F, FontStyle.Bold);
            txtPWD.ForeColor = Color.Navy;
            txtPWD.Location = new Point(17, 220);
            txtPWD.Name = "txtPWD";
            txtPWD.PasswordChar = '*';
            txtPWD.RightToLeft = RightToLeft.No;
            txtPWD.Size = new Size(310, 34);
            txtPWD.TabIndex = 19;
            txtPWD.TextAlign = HorizontalAlignment.Center;
            // 
            // txtID
            // 
            txtID.Font = new Font("Arial", 13.8F, FontStyle.Bold);
            txtID.ForeColor = Color.Navy;
            txtID.Location = new Point(17, 170);
            txtID.Name = "txtID";
            txtID.RightToLeft = RightToLeft.No;
            txtID.Size = new Size(310, 34);
            txtID.TabIndex = 18;
            txtID.TextAlign = HorizontalAlignment.Center;
            // 
            // txtDB
            // 
            txtDB.Font = new Font("Arial", 13.8F, FontStyle.Bold);
            txtDB.ForeColor = Color.Navy;
            txtDB.Location = new Point(17, 120);
            txtDB.Name = "txtDB";
            txtDB.RightToLeft = RightToLeft.No;
            txtDB.Size = new Size(310, 34);
            txtDB.TabIndex = 17;
            txtDB.TextAlign = HorizontalAlignment.Center;
            // 
            // txtServer
            // 
            txtServer.Font = new Font("Arial", 13.8F, FontStyle.Bold);
            txtServer.ForeColor = Color.Navy;
            txtServer.Location = new Point(17, 70);
            txtServer.Name = "txtServer";
            txtServer.RightToLeft = RightToLeft.No;
            txtServer.Size = new Size(310, 34);
            txtServer.TabIndex = 16;
            txtServer.TextAlign = HorizontalAlignment.Center;
            // 
            // txtMode
            // 
            txtMode.Font = new Font("Arial", 13.8F, FontStyle.Bold);
            txtMode.ForeColor = Color.Navy;
            txtMode.Location = new Point(17, 20);
            txtMode.Name = "txtMode";
            txtMode.RightToLeft = RightToLeft.No;
            txtMode.Size = new Size(310, 34);
            txtMode.TabIndex = 15;
            txtMode.TextAlign = HorizontalAlignment.Center;
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Font = new Font("Arial", 13.8F, FontStyle.Bold);
            label5.ForeColor = Color.Maroon;
            label5.Location = new Point(374, 223);
            label5.Name = "label5";
            label5.Size = new Size(101, 27);
            label5.TabIndex = 14;
            label5.Text = "كلمة المرور";
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Font = new Font("Arial", 13.8F, FontStyle.Bold);
            label4.ForeColor = Color.Maroon;
            label4.Location = new Point(395, 173);
            label4.Name = "label4";
            label4.Size = new Size(80, 27);
            label4.TabIndex = 13;
            label4.Text = "المستخدم";
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Font = new Font("Arial", 13.8F, FontStyle.Bold);
            label3.ForeColor = Color.Maroon;
            label3.Location = new Point(364, 123);
            label3.Name = "label3";
            label3.Size = new Size(111, 27);
            label3.TabIndex = 12;
            label3.Text = "قاعدة البيانات";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Arial", 13.8F, FontStyle.Bold);
            label2.ForeColor = Color.Maroon;
            label2.Location = new Point(412, 73);
            label2.Name = "label2";
            label2.Size = new Size(63, 27);
            label2.TabIndex = 11;
            label2.Text = "السرفر";
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Arial", 13.8F, FontStyle.Bold);
            label1.ForeColor = Color.Maroon;
            label1.Location = new Point(425, 23);
            label1.Name = "label1";
            label1.Size = new Size(50, 27);
            label1.TabIndex = 10;
            label1.Text = "النمط";
            // 
            // groupBox2
            // 
            groupBox2.Controls.Add(btnSave);
            groupBox2.Controls.Add(txtExit);
            groupBox2.Controls.Add(btnNew);
            groupBox2.Controls.Add(txtDisplay);
            groupBox2.Dock = DockStyle.Bottom;
            groupBox2.Location = new Point(0, 270);
            groupBox2.Name = "groupBox2";
            groupBox2.Size = new Size(517, 83);
            groupBox2.TabIndex = 15;
            groupBox2.TabStop = false;
            // 
            // frmConnSettings
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(517, 353);
            Controls.Add(groupBox2);
            Controls.Add(groupBox1);
            Icon = (Icon)resources.GetObject("$this.Icon");
            Name = "frmConnSettings";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "إعدادات الإتصال";
            groupBox1.ResumeLayout(false);
            groupBox1.PerformLayout();
            groupBox2.ResumeLayout(false);
            ResumeLayout(false);
        }

        #endregion
        private Button btnNew;
        private Button btnSave;
        private Button txtDisplay;
        private Button txtExit;
        private GroupBox groupBox1;
        private TextBox txtPWD;
        private TextBox txtID;
        private TextBox txtDB;
        private TextBox txtServer;
        private TextBox txtMode;
        private Label label5;
        private Label label4;
        private Label label3;
        private Label label2;
        private Label label1;
        private GroupBox groupBox2;
    }
}