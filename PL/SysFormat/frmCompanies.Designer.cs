namespace IntegratedAccSys.PL.SysFormat
{
    partial class frmCompanies
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmCompanies));
            groupBox1 = new GroupBox();
            dgvData = new DataGridView();
            groupBox2 = new GroupBox();
            groupBox4 = new GroupBox();
            btnClear = new Button();
            btnBrawse = new Button();
            PbLogo = new PictureBox();
            txtBraEmail = new TextBox();
            txtBraFax = new TextBox();
            txtBraTel = new TextBox();
            txtBraActivity = new TextBox();
            txtBraAddress = new TextBox();
            txtBraName = new TextBox();
            txtBranchNo = new TextBox();
            label7 = new Label();
            label6 = new Label();
            label5 = new Label();
            label4 = new Label();
            label3 = new Label();
            label2 = new Label();
            label1 = new Label();
            groupBox3 = new GroupBox();
            btnExit = new Button();
            btnDel = new Button();
            btnEdit = new Button();
            btnAdd = new Button();
            btnNew = new Button();
            groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)dgvData).BeginInit();
            groupBox2.SuspendLayout();
            groupBox4.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)PbLogo).BeginInit();
            groupBox3.SuspendLayout();
            SuspendLayout();
            // 
            // groupBox1
            // 
            groupBox1.Controls.Add(dgvData);
            groupBox1.Dock = DockStyle.Top;
            groupBox1.Location = new Point(0, 0);
            groupBox1.Name = "groupBox1";
            groupBox1.Size = new Size(689, 191);
            groupBox1.TabIndex = 0;
            groupBox1.TabStop = false;
            // 
            // dgvData
            // 
            dgvData.AllowUserToAddRows = false;
            dgvData.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            dgvData.BackgroundColor = Color.Azure;
            dgvData.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            dgvData.Dock = DockStyle.Fill;
            dgvData.Location = new Point(3, 23);
            dgvData.Name = "dgvData";
            dgvData.RowHeadersVisible = false;
            dgvData.RowHeadersWidth = 51;
            dgvData.Size = new Size(683, 165);
            dgvData.TabIndex = 0;
            dgvData.DoubleClick += dgvData_DoubleClick;
            // 
            // groupBox2
            // 
            groupBox2.Controls.Add(groupBox4);
            groupBox2.Controls.Add(txtBraEmail);
            groupBox2.Controls.Add(txtBraFax);
            groupBox2.Controls.Add(txtBraTel);
            groupBox2.Controls.Add(txtBraActivity);
            groupBox2.Controls.Add(txtBraAddress);
            groupBox2.Controls.Add(txtBraName);
            groupBox2.Controls.Add(txtBranchNo);
            groupBox2.Controls.Add(label7);
            groupBox2.Controls.Add(label6);
            groupBox2.Controls.Add(label5);
            groupBox2.Controls.Add(label4);
            groupBox2.Controls.Add(label3);
            groupBox2.Controls.Add(label2);
            groupBox2.Controls.Add(label1);
            groupBox2.Location = new Point(6, 197);
            groupBox2.Name = "groupBox2";
            groupBox2.Size = new Size(671, 328);
            groupBox2.TabIndex = 1;
            groupBox2.TabStop = false;
            groupBox2.UseCompatibleTextRendering = true;
            // 
            // groupBox4
            // 
            groupBox4.Controls.Add(btnClear);
            groupBox4.Controls.Add(btnBrawse);
            groupBox4.Controls.Add(PbLogo);
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
            // PbLogo
            // 
            PbLogo.BackgroundImage = (Image)resources.GetObject("PbLogo.BackgroundImage");
            PbLogo.BackgroundImageLayout = ImageLayout.Stretch;
            PbLogo.Location = new Point(6, 26);
            PbLogo.Name = "PbLogo";
            PbLogo.Size = new Size(194, 191);
            PbLogo.SizeMode = PictureBoxSizeMode.StretchImage;
            PbLogo.TabIndex = 0;
            PbLogo.TabStop = false;
            // 
            // txtBraEmail
            // 
            txtBraEmail.Font = new Font("Arial", 12F, FontStyle.Bold);
            txtBraEmail.ForeColor = Color.Navy;
            txtBraEmail.Location = new Point(266, 283);
            txtBraEmail.Name = "txtBraEmail";
            txtBraEmail.Size = new Size(239, 30);
            txtBraEmail.TabIndex = 13;
            txtBraEmail.TextAlign = HorizontalAlignment.Center;
            // 
            // txtBraFax
            // 
            txtBraFax.Font = new Font("Arial", 12F, FontStyle.Bold);
            txtBraFax.ForeColor = Color.Navy;
            txtBraFax.Location = new Point(266, 241);
            txtBraFax.Name = "txtBraFax";
            txtBraFax.Size = new Size(239, 30);
            txtBraFax.TabIndex = 12;
            txtBraFax.TextAlign = HorizontalAlignment.Center;
            // 
            // txtBraTel
            // 
            txtBraTel.Font = new Font("Arial", 12F, FontStyle.Bold);
            txtBraTel.ForeColor = Color.Navy;
            txtBraTel.Location = new Point(266, 199);
            txtBraTel.Name = "txtBraTel";
            txtBraTel.Size = new Size(239, 30);
            txtBraTel.TabIndex = 11;
            txtBraTel.TextAlign = HorizontalAlignment.Center;
            // 
            // txtBraActivity
            // 
            txtBraActivity.Font = new Font("Arial", 12F, FontStyle.Bold);
            txtBraActivity.ForeColor = Color.Navy;
            txtBraActivity.Location = new Point(266, 157);
            txtBraActivity.Name = "txtBraActivity";
            txtBraActivity.Size = new Size(239, 30);
            txtBraActivity.TabIndex = 10;
            txtBraActivity.TextAlign = HorizontalAlignment.Center;
            // 
            // txtBraAddress
            // 
            txtBraAddress.Font = new Font("Arial", 12F, FontStyle.Bold);
            txtBraAddress.ForeColor = Color.Navy;
            txtBraAddress.Location = new Point(266, 115);
            txtBraAddress.Name = "txtBraAddress";
            txtBraAddress.Size = new Size(239, 30);
            txtBraAddress.TabIndex = 9;
            txtBraAddress.TextAlign = HorizontalAlignment.Center;
            // 
            // txtBraName
            // 
            txtBraName.Font = new Font("Arial", 12F, FontStyle.Bold);
            txtBraName.ForeColor = Color.Navy;
            txtBraName.Location = new Point(266, 73);
            txtBraName.Name = "txtBraName";
            txtBraName.Size = new Size(239, 30);
            txtBraName.TabIndex = 8;
            txtBraName.TextAlign = HorizontalAlignment.Center;
            // 
            // txtBranchNo
            // 
            txtBranchNo.BackColor = Color.FromArgb(192, 255, 255);
            txtBranchNo.Font = new Font("Arial", 12F, FontStyle.Bold);
            txtBranchNo.ForeColor = Color.Navy;
            txtBranchNo.Location = new Point(266, 31);
            txtBranchNo.Multiline = true;
            txtBranchNo.Name = "txtBranchNo";
            txtBranchNo.ReadOnly = true;
            txtBranchNo.Size = new Size(239, 27);
            txtBranchNo.TabIndex = 7;
            txtBranchNo.TextAlign = HorizontalAlignment.Center;
            // 
            // label7
            // 
            label7.AutoSize = true;
            label7.Font = new Font("Arial", 12F, FontStyle.Bold);
            label7.ForeColor = Color.FromArgb(192, 0, 0);
            label7.Location = new Point(527, 290);
            label7.Name = "label7";
            label7.Size = new Size(117, 24);
            label7.TabIndex = 6;
            label7.Text = "البريد الألكتروني";
            // 
            // label6
            // 
            label6.AutoSize = true;
            label6.Font = new Font("Arial", 12F, FontStyle.Bold);
            label6.ForeColor = Color.FromArgb(192, 0, 0);
            label6.Location = new Point(598, 248);
            label6.Name = "label6";
            label6.Size = new Size(46, 24);
            label6.TabIndex = 5;
            label6.Text = "فاكس";
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Font = new Font("Arial", 12F, FontStyle.Bold);
            label5.ForeColor = Color.FromArgb(192, 0, 0);
            label5.Location = new Point(598, 206);
            label5.Name = "label5";
            label5.Size = new Size(46, 24);
            label5.TabIndex = 4;
            label5.Text = "تلفون";
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Font = new Font("Arial", 12F, FontStyle.Bold);
            label4.ForeColor = Color.FromArgb(192, 0, 0);
            label4.Location = new Point(593, 164);
            label4.Name = "label4";
            label4.Size = new Size(51, 24);
            label4.TabIndex = 3;
            label4.Text = "النشاط";
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Font = new Font("Arial", 12F, FontStyle.Bold);
            label3.ForeColor = Color.FromArgb(192, 0, 0);
            label3.Location = new Point(589, 122);
            label3.Name = "label3";
            label3.Size = new Size(55, 24);
            label3.TabIndex = 2;
            label3.Text = "العنوان";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Arial", 12F, FontStyle.Bold);
            label2.ForeColor = Color.FromArgb(192, 0, 0);
            label2.Location = new Point(570, 80);
            label2.Name = "label2";
            label2.Size = new Size(74, 24);
            label2.TabIndex = 1;
            label2.Text = "إسم الفرع";
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Arial", 12F, FontStyle.Bold);
            label1.ForeColor = Color.FromArgb(192, 0, 0);
            label1.Location = new Point(571, 38);
            label1.Name = "label1";
            label1.Size = new Size(73, 24);
            label1.TabIndex = 0;
            label1.Text = "رقم الفرع";
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
            groupBox3.TabIndex = 2;
            groupBox3.TabStop = false;
            // 
            // btnExit
            // 
            btnExit.Image = (Image)resources.GetObject("btnExit.Image");
            btnExit.Location = new Point(80, 20);
            btnExit.Name = "btnExit";
            btnExit.Size = new Size(94, 48);
            btnExit.TabIndex = 4;
            btnExit.UseVisualStyleBackColor = true;
            btnExit.Click += btnExit_Click;
            // 
            // btnDel
            // 
            btnDel.Image = (Image)resources.GetObject("btnDel.Image");
            btnDel.Location = new Point(191, 20);
            btnDel.Name = "btnDel";
            btnDel.Size = new Size(94, 48);
            btnDel.TabIndex = 3;
            btnDel.UseVisualStyleBackColor = true;
            btnDel.Click += btnDel_Click;
            // 
            // btnEdit
            // 
            btnEdit.Image = (Image)resources.GetObject("btnEdit.Image");
            btnEdit.Location = new Point(302, 20);
            btnEdit.Name = "btnEdit";
            btnEdit.Size = new Size(94, 48);
            btnEdit.TabIndex = 2;
            btnEdit.UseVisualStyleBackColor = true;
            btnEdit.Click += btnEdit_Click;
            // 
            // btnAdd
            // 
            btnAdd.Image = (Image)resources.GetObject("btnAdd.Image");
            btnAdd.Location = new Point(413, 20);
            btnAdd.Name = "btnAdd";
            btnAdd.Size = new Size(94, 48);
            btnAdd.TabIndex = 1;
            btnAdd.UseVisualStyleBackColor = true;
            btnAdd.Click += btnAdd_Click;
            // 
            // btnNew
            // 
            btnNew.Image = (Image)resources.GetObject("btnNew.Image");
            btnNew.Location = new Point(524, 20);
            btnNew.Name = "btnNew";
            btnNew.Size = new Size(94, 48);
            btnNew.TabIndex = 0;
            btnNew.UseVisualStyleBackColor = true;
            btnNew.Click += btnNew_Click;
            // 
            // frmCompanies
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(689, 611);
            Controls.Add(groupBox3);
            Controls.Add(groupBox2);
            Controls.Add(groupBox1);
            Icon = (Icon)resources.GetObject("$this.Icon");
            Name = "frmCompanies";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "بيانات الشركة";
            Load += frmCompanies_Load;
            groupBox1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)dgvData).EndInit();
            groupBox2.ResumeLayout(false);
            groupBox2.PerformLayout();
            groupBox4.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)PbLogo).EndInit();
            groupBox3.ResumeLayout(false);
            ResumeLayout(false);
        }

        #endregion

        private GroupBox groupBox1;
        private GroupBox groupBox2;
        private GroupBox groupBox3;
        private DataGridView dgvData;
        private TextBox txtBraEmail;
        private TextBox txtBraFax;
        private TextBox txtBraTel;
        private TextBox txtBraActivity;
        private TextBox txtBraAddress;
        private TextBox txtBraName;
        private Label label7;
        private Label label6;
        private Label label5;
        private Label label4;
        private Label label3;
        private Label label2;
        private Label label1;
        private GroupBox groupBox4;
        private Button btnClear;
        private Button btnBrawse;
        private PictureBox PbLogo;
        private Button btnExit;
        private Button btnDel;
        private Button btnEdit;
        private Button btnAdd;
        private Button btnNew;
        private TextBox txtBranchNo;
    }
}