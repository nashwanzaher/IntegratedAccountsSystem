namespace IntegratedAccSys.PL.Accounts
{
    partial class frmChartOfAccounts
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmChartOfAccounts));
            groupBox1 = new GroupBox();
            btnSearch = new Button();
            txtSearch = new TextBox();
            label10 = new Label();
            btnPrint = new Button();
            tvAccounts = new TreeView();
            groupBox2 = new GroupBox();
            chkLock = new CheckBox();
            txtTag = new TextBox();
            groupBox3 = new GroupBox();
            btnExit = new Button();
            btnDelete = new Button();
            btnUpdate = new Button();
            btnAdd = new Button();
            btnNew = new Button();
            cbAccReport = new ComboBox();
            cbAccTypes = new ComboBox();
            txtBalance = new TextBox();
            txtCreditor = new TextBox();
            txtDebitor = new TextBox();
            txtAccLevel = new TextBox();
            txtAccName = new TextBox();
            txtAccNo = new TextBox();
            txtAccParentNo = new TextBox();
            label9 = new Label();
            label8 = new Label();
            label7 = new Label();
            label6 = new Label();
            label5 = new Label();
            label4 = new Label();
            label3 = new Label();
            label2 = new Label();
            label1 = new Label();
            groupBox1.SuspendLayout();
            groupBox2.SuspendLayout();
            groupBox3.SuspendLayout();
            SuspendLayout();
            // 
            // groupBox1
            // 
            groupBox1.Controls.Add(btnSearch);
            groupBox1.Controls.Add(txtSearch);
            groupBox1.Controls.Add(label10);
            groupBox1.Controls.Add(btnPrint);
            groupBox1.Controls.Add(tvAccounts);
            groupBox1.Dock = DockStyle.Left;
            groupBox1.Location = new Point(0, 0);
            groupBox1.Name = "groupBox1";
            groupBox1.Size = new Size(477, 572);
            groupBox1.TabIndex = 0;
            groupBox1.TabStop = false;
            // 
            // btnSearch
            // 
            btnSearch.BackColor = Color.FromArgb(255, 224, 192);
            btnSearch.Image = (Image)resources.GetObject("btnSearch.Image");
            btnSearch.Location = new Point(24, 30);
            btnSearch.Name = "btnSearch";
            btnSearch.Size = new Size(64, 35);
            btnSearch.TabIndex = 4;
            btnSearch.UseVisualStyleBackColor = false;
            btnSearch.Click += btnSearch_Click;
            // 
            // txtSearch
            // 
            txtSearch.BackColor = Color.FromArgb(192, 255, 255);
            txtSearch.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtSearch.Location = new Point(103, 33);
            txtSearch.Name = "txtSearch";
            txtSearch.Size = new Size(282, 30);
            txtSearch.TabIndex = 3;
            txtSearch.TextAlign = HorizontalAlignment.Center;
            // 
            // label10
            // 
            label10.AutoSize = true;
            label10.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label10.Location = new Point(391, 36);
            label10.Name = "label10";
            label10.Size = new Size(38, 23);
            label10.TabIndex = 2;
            label10.Text = "بحث";
            // 
            // btnPrint
            // 
            btnPrint.BackColor = Color.FromArgb(0, 64, 64);
            btnPrint.Image = (Image)resources.GetObject("btnPrint.Image");
            btnPrint.Location = new Point(6, 506);
            btnPrint.Name = "btnPrint";
            btnPrint.Size = new Size(465, 59);
            btnPrint.TabIndex = 1;
            btnPrint.UseVisualStyleBackColor = false;
            btnPrint.Click += btnPrint_Click;
            // 
            // tvAccounts
            // 
            tvAccounts.BackColor = Color.Azure;
            tvAccounts.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            tvAccounts.ForeColor = Color.Maroon;
            tvAccounts.Location = new Point(6, 82);
            tvAccounts.Name = "tvAccounts";
            tvAccounts.RightToLeft = RightToLeft.Yes;
            tvAccounts.RightToLeftLayout = true;
            tvAccounts.Size = new Size(465, 418);
            tvAccounts.TabIndex = 0;
            tvAccounts.AfterSelect += tvAccounts_AfterSelect;
            // 
            // groupBox2
            // 
            groupBox2.Controls.Add(chkLock);
            groupBox2.Controls.Add(txtTag);
            groupBox2.Controls.Add(groupBox3);
            groupBox2.Controls.Add(cbAccReport);
            groupBox2.Controls.Add(cbAccTypes);
            groupBox2.Controls.Add(txtBalance);
            groupBox2.Controls.Add(txtCreditor);
            groupBox2.Controls.Add(txtDebitor);
            groupBox2.Controls.Add(txtAccLevel);
            groupBox2.Controls.Add(txtAccName);
            groupBox2.Controls.Add(txtAccNo);
            groupBox2.Controls.Add(txtAccParentNo);
            groupBox2.Controls.Add(label9);
            groupBox2.Controls.Add(label8);
            groupBox2.Controls.Add(label7);
            groupBox2.Controls.Add(label6);
            groupBox2.Controls.Add(label5);
            groupBox2.Controls.Add(label4);
            groupBox2.Controls.Add(label3);
            groupBox2.Controls.Add(label2);
            groupBox2.Controls.Add(label1);
            groupBox2.Dock = DockStyle.Right;
            groupBox2.Location = new Point(495, 0);
            groupBox2.Name = "groupBox2";
            groupBox2.Size = new Size(648, 572);
            groupBox2.TabIndex = 1;
            groupBox2.TabStop = false;
            // 
            // chkLock
            // 
            chkLock.AutoSize = true;
            chkLock.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            chkLock.ForeColor = Color.Blue;
            chkLock.Location = new Point(418, 458);
            chkLock.Name = "chkLock";
            chkLock.Size = new Size(64, 27);
            chkLock.TabIndex = 20;
            chkLock.Text = "مغلق";
            chkLock.UseVisualStyleBackColor = true;
            // 
            // txtTag
            // 
            txtTag.Font = new Font("Times New Roman", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            txtTag.ForeColor = Color.FromArgb(192, 0, 0);
            txtTag.Location = new Point(29, 41);
            txtTag.Name = "txtTag";
            txtTag.Size = new Size(128, 30);
            txtTag.TabIndex = 19;
            txtTag.TextAlign = HorizontalAlignment.Center;
            txtTag.Visible = false;
            txtTag.TextChanged += txtTag_TextChanged;
            // 
            // groupBox3
            // 
            groupBox3.Controls.Add(btnExit);
            groupBox3.Controls.Add(btnDelete);
            groupBox3.Controls.Add(btnUpdate);
            groupBox3.Controls.Add(btnAdd);
            groupBox3.Controls.Add(btnNew);
            groupBox3.Dock = DockStyle.Bottom;
            groupBox3.Location = new Point(3, 482);
            groupBox3.Name = "groupBox3";
            groupBox3.Size = new Size(642, 87);
            groupBox3.TabIndex = 18;
            groupBox3.TabStop = false;
            // 
            // btnExit
            // 
            btnExit.BackColor = Color.FromArgb(0, 64, 64);
            btnExit.Image = (Image)resources.GetObject("btnExit.Image");
            btnExit.Location = new Point(9, 24);
            btnExit.Name = "btnExit";
            btnExit.Size = new Size(123, 59);
            btnExit.TabIndex = 4;
            btnExit.UseVisualStyleBackColor = false;
            btnExit.Click += btnExit_Click;
            // 
            // btnDelete
            // 
            btnDelete.BackColor = Color.FromArgb(0, 64, 64);
            btnDelete.Image = (Image)resources.GetObject("btnDelete.Image");
            btnDelete.Location = new Point(136, 24);
            btnDelete.Name = "btnDelete";
            btnDelete.Size = new Size(123, 59);
            btnDelete.TabIndex = 3;
            btnDelete.UseVisualStyleBackColor = false;
            btnDelete.Click += btnDelete_Click;
            // 
            // btnUpdate
            // 
            btnUpdate.BackColor = Color.FromArgb(0, 64, 64);
            btnUpdate.Image = (Image)resources.GetObject("btnUpdate.Image");
            btnUpdate.Location = new Point(259, 24);
            btnUpdate.Name = "btnUpdate";
            btnUpdate.Size = new Size(123, 59);
            btnUpdate.TabIndex = 2;
            btnUpdate.UseVisualStyleBackColor = false;
            btnUpdate.Click += btnUpdate_Click;
            // 
            // btnAdd
            // 
            btnAdd.BackColor = Color.FromArgb(0, 64, 64);
            btnAdd.Image = (Image)resources.GetObject("btnAdd.Image");
            btnAdd.Location = new Point(382, 24);
            btnAdd.Name = "btnAdd";
            btnAdd.Size = new Size(123, 59);
            btnAdd.TabIndex = 1;
            btnAdd.UseVisualStyleBackColor = false;
            btnAdd.Click += btnAdd_Click;
            // 
            // btnNew
            // 
            btnNew.BackColor = Color.FromArgb(0, 64, 64);
            btnNew.Image = (Image)resources.GetObject("btnNew.Image");
            btnNew.Location = new Point(505, 24);
            btnNew.Name = "btnNew";
            btnNew.Size = new Size(123, 59);
            btnNew.TabIndex = 0;
            btnNew.UseVisualStyleBackColor = false;
            btnNew.Click += btnNew_Click;
            // 
            // cbAccReport
            // 
            cbAccReport.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            cbAccReport.FormattingEnabled = true;
            cbAccReport.Location = new Point(193, 411);
            cbAccReport.Name = "cbAccReport";
            cbAccReport.Size = new Size(289, 31);
            cbAccReport.TabIndex = 17;
            // 
            // cbAccTypes
            // 
            cbAccTypes.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            cbAccTypes.FormattingEnabled = true;
            cbAccTypes.Location = new Point(193, 364);
            cbAccTypes.Name = "cbAccTypes";
            cbAccTypes.Size = new Size(289, 31);
            cbAccTypes.TabIndex = 16;
            // 
            // txtBalance
            // 
            txtBalance.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtBalance.Location = new Point(29, 318);
            txtBalance.Name = "txtBalance";
            txtBalance.Size = new Size(453, 30);
            txtBalance.TabIndex = 15;
            txtBalance.Text = "0.00";
            txtBalance.TextAlign = HorizontalAlignment.Center;
            txtBalance.KeyPress += txtBalance_KeyPress;
            // 
            // txtCreditor
            // 
            txtCreditor.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtCreditor.Location = new Point(29, 272);
            txtCreditor.Name = "txtCreditor";
            txtCreditor.Size = new Size(453, 30);
            txtCreditor.TabIndex = 14;
            txtCreditor.Text = "0.00";
            txtCreditor.TextAlign = HorizontalAlignment.Center;
            txtCreditor.KeyPress += txtCreditor_KeyPress;
            // 
            // txtDebitor
            // 
            txtDebitor.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtDebitor.Location = new Point(29, 226);
            txtDebitor.Name = "txtDebitor";
            txtDebitor.Size = new Size(453, 30);
            txtDebitor.TabIndex = 13;
            txtDebitor.Text = "0.00";
            txtDebitor.TextAlign = HorizontalAlignment.Center;
            txtDebitor.KeyPress += txtDebitor_KeyPress;
            // 
            // txtAccLevel
            // 
            txtAccLevel.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtAccLevel.Location = new Point(262, 180);
            txtAccLevel.Name = "txtAccLevel";
            txtAccLevel.ReadOnly = true;
            txtAccLevel.Size = new Size(220, 30);
            txtAccLevel.TabIndex = 12;
            txtAccLevel.TextAlign = HorizontalAlignment.Center;
            txtAccLevel.KeyPress += txtAccLevel_KeyPress;
            // 
            // txtAccName
            // 
            txtAccName.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtAccName.Location = new Point(29, 134);
            txtAccName.Name = "txtAccName";
            txtAccName.Size = new Size(453, 30);
            txtAccName.TabIndex = 11;
            txtAccName.TextAlign = HorizontalAlignment.Center;
            // 
            // txtAccNo
            // 
            txtAccNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtAccNo.Location = new Point(29, 88);
            txtAccNo.Name = "txtAccNo";
            txtAccNo.ReadOnly = true;
            txtAccNo.Size = new Size(453, 30);
            txtAccNo.TabIndex = 10;
            txtAccNo.TextAlign = HorizontalAlignment.Center;
            txtAccNo.KeyPress += txtAccNo_KeyPress;
            txtAccNo.Leave += txtAccNo_Leave;
            // 
            // txtAccParentNo
            // 
            txtAccParentNo.BackColor = Color.FromArgb(255, 224, 192);
            txtAccParentNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtAccParentNo.Location = new Point(262, 42);
            txtAccParentNo.Name = "txtAccParentNo";
            txtAccParentNo.ReadOnly = true;
            txtAccParentNo.Size = new Size(220, 30);
            txtAccParentNo.TabIndex = 9;
            txtAccParentNo.TextAlign = HorizontalAlignment.Center;
            // 
            // label9
            // 
            label9.AutoSize = true;
            label9.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label9.ForeColor = Color.FromArgb(192, 0, 0);
            label9.Location = new Point(517, 413);
            label9.Name = "label9";
            label9.Size = new Size(100, 23);
            label9.TabIndex = 8;
            label9.Text = "مصب الحساب";
            // 
            // label8
            // 
            label8.AutoSize = true;
            label8.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label8.ForeColor = Color.FromArgb(192, 0, 0);
            label8.Location = new Point(528, 367);
            label8.Name = "label8";
            label8.Size = new Size(89, 23);
            label8.TabIndex = 7;
            label8.Text = "نوع الحساب";
            // 
            // label7
            // 
            label7.AutoSize = true;
            label7.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label7.ForeColor = Color.FromArgb(192, 0, 0);
            label7.Location = new Point(562, 321);
            label7.Name = "label7";
            label7.Size = new Size(55, 23);
            label7.TabIndex = 6;
            label7.Text = "الرصيد";
            // 
            // label6
            // 
            label6.AutoSize = true;
            label6.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label6.ForeColor = Color.FromArgb(192, 0, 0);
            label6.Location = new Point(539, 275);
            label6.Name = "label6";
            label6.Size = new Size(78, 23);
            label6.TabIndex = 5;
            label6.Text = "رصيد دائن";
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label5.ForeColor = Color.FromArgb(192, 0, 0);
            label5.Location = new Point(535, 229);
            label5.Name = "label5";
            label5.Size = new Size(82, 23);
            label5.TabIndex = 4;
            label5.Text = "رصيد مدين";
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label4.ForeColor = Color.FromArgb(192, 0, 0);
            label4.Location = new Point(506, 183);
            label4.Name = "label4";
            label4.Size = new Size(111, 23);
            label4.TabIndex = 3;
            label4.Text = "مستوى الحساب";
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label3.ForeColor = Color.FromArgb(192, 0, 0);
            label3.Location = new Point(525, 137);
            label3.Name = "label3";
            label3.Size = new Size(92, 23);
            label3.TabIndex = 2;
            label3.Text = "إسم الحساب ";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label2.ForeColor = Color.FromArgb(192, 0, 0);
            label2.Location = new Point(531, 91);
            label2.Name = "label2";
            label2.Size = new Size(86, 23);
            label2.TabIndex = 1;
            label2.Text = "رقم الحساب";
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label1.ForeColor = Color.FromArgb(192, 0, 0);
            label1.Location = new Point(504, 45);
            label1.Name = "label1";
            label1.Size = new Size(118, 23);
            label1.TabIndex = 0;
            label1.Text = "رقم الحساب الأب";
            // 
            // frmChartOfAccounts
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(1143, 572);
            Controls.Add(groupBox2);
            Controls.Add(groupBox1);
            Icon = (Icon)resources.GetObject("$this.Icon");
            Name = "frmChartOfAccounts";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "الدليل المحاسبي ";
            Load += frmChartOfAccounts_Load;
            groupBox1.ResumeLayout(false);
            groupBox1.PerformLayout();
            groupBox2.ResumeLayout(false);
            groupBox2.PerformLayout();
            groupBox3.ResumeLayout(false);
            ResumeLayout(false);
        }

        #endregion

        private GroupBox groupBox1;
        private GroupBox groupBox2;
        private Button btnPrint;
        private TreeView tvAccounts;
        private ComboBox cbAccTypes;
        private TextBox txtBalance;
        private TextBox txtCreditor;
        private TextBox txtDebitor;
        private TextBox txtAccLevel;
        private TextBox txtAccName;
        private TextBox txtAccNo;
        private TextBox txtAccParentNo;
        private Label label9;
        private Label label8;
        private Label label7;
        private Label label6;
        private Label label5;
        private Label label4;
        private Label label3;
        private Label label2;
        private Label label1;
        private Button btnSearch;
        private TextBox txtSearch;
        private Label label10;
        private GroupBox groupBox3;
        private Button btnExit;
        private Button btnDelete;
        private Button btnUpdate;
        private Button btnAdd;
        private Button btnNew;
        private ComboBox cbAccReport;
        private TextBox txtTag;
        private CheckBox chkLock;
    }
}