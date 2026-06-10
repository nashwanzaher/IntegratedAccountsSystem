namespace IntegratedAccSys.PL.Sales
{
    partial class frmCustomers
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmCustomers));
            txtCustAccCode = new TextBox();
            btnAdd = new Button();
            groupBox2 = new GroupBox();
            pbImg = new PictureBox();
            btnClear = new Button();
            btnBrowes = new Button();
            btnEdit = new Button();
            txtMobile = new TextBox();
            txtEmail = new TextBox();
            label7 = new Label();
            label6 = new Label();
            txtCustName = new TextBox();
            btnDel = new Button();
            label2 = new Label();
            label1 = new Label();
            dgvData = new DataGridView();
            groupBox1 = new GroupBox();
            btnExit = new Button();
            btnNew = new Button();
            label3 = new Label();
            txtDebitLimit = new TextBox();
            groupBox2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)pbImg).BeginInit();
            ((System.ComponentModel.ISupportInitialize)dgvData).BeginInit();
            groupBox1.SuspendLayout();
            SuspendLayout();
            // 
            // txtCustAccCode
            // 
            txtCustAccCode.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtCustAccCode.Location = new Point(176, 291);
            txtCustAccCode.Name = "txtCustAccCode";
            txtCustAccCode.Size = new Size(320, 30);
            txtCustAccCode.TabIndex = 61;
            txtCustAccCode.TextAlign = HorizontalAlignment.Center;
            txtCustAccCode.KeyDown += txtCustAccCode_KeyDown;
            // 
            // btnAdd
            // 
            btnAdd.BackColor = Color.FromArgb(0, 64, 64);
            btnAdd.Image = (Image)resources.GetObject("btnAdd.Image");
            btnAdd.Location = new Point(426, 25);
            btnAdd.Name = "btnAdd";
            btnAdd.Size = new Size(135, 42);
            btnAdd.TabIndex = 1;
            btnAdd.UseVisualStyleBackColor = false;
            btnAdd.Click += btnAdd_Click;
            // 
            // groupBox2
            // 
            groupBox2.BackColor = Color.FromArgb(192, 255, 255);
            groupBox2.Controls.Add(pbImg);
            groupBox2.Controls.Add(btnClear);
            groupBox2.Controls.Add(btnBrowes);
            groupBox2.Location = new Point(503, 252);
            groupBox2.Name = "groupBox2";
            groupBox2.Size = new Size(211, 238);
            groupBox2.TabIndex = 68;
            groupBox2.TabStop = false;
            // 
            // pbImg
            // 
            pbImg.Location = new Point(17, 21);
            pbImg.Name = "pbImg";
            pbImg.Size = new Size(175, 167);
            pbImg.SizeMode = PictureBoxSizeMode.StretchImage;
            pbImg.TabIndex = 3;
            pbImg.TabStop = false;
            // 
            // btnClear
            // 
            btnClear.BackColor = Color.FromArgb(255, 224, 192);
            btnClear.Image = (Image)resources.GetObject("btnClear.Image");
            btnClear.Location = new Point(17, 194);
            btnClear.Name = "btnClear";
            btnClear.Size = new Size(75, 38);
            btnClear.TabIndex = 2;
            btnClear.UseVisualStyleBackColor = false;
            btnClear.Click += btnClear_Click;
            // 
            // btnBrowes
            // 
            btnBrowes.BackColor = Color.FromArgb(255, 224, 192);
            btnBrowes.Image = (Image)resources.GetObject("btnBrowes.Image");
            btnBrowes.Location = new Point(98, 194);
            btnBrowes.Name = "btnBrowes";
            btnBrowes.Size = new Size(94, 38);
            btnBrowes.TabIndex = 1;
            btnBrowes.UseVisualStyleBackColor = false;
            btnBrowes.Click += btnBrowes_Click;
            // 
            // btnEdit
            // 
            btnEdit.BackColor = Color.FromArgb(0, 64, 64);
            btnEdit.Image = (Image)resources.GetObject("btnEdit.Image");
            btnEdit.Location = new Point(286, 25);
            btnEdit.Name = "btnEdit";
            btnEdit.Size = new Size(135, 42);
            btnEdit.TabIndex = 2;
            btnEdit.UseVisualStyleBackColor = false;
            btnEdit.Click += btnEdit_Click;
            // 
            // txtMobile
            // 
            txtMobile.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtMobile.Location = new Point(176, 363);
            txtMobile.Name = "txtMobile";
            txtMobile.Size = new Size(320, 30);
            txtMobile.TabIndex = 66;
            txtMobile.TextAlign = HorizontalAlignment.Center;
            // 
            // txtEmail
            // 
            txtEmail.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtEmail.Location = new Point(176, 399);
            txtEmail.Name = "txtEmail";
            txtEmail.Size = new Size(322, 30);
            txtEmail.TabIndex = 67;
            txtEmail.TextAlign = HorizontalAlignment.Center;
            txtEmail.Validated += txtEmail_Validated;
            // 
            // label7
            // 
            label7.AutoSize = true;
            label7.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label7.Location = new Point(28, 405);
            label7.Name = "label7";
            label7.Size = new Size(116, 23);
            label7.TabIndex = 65;
            label7.Text = "البريد الإلكتروني";
            // 
            // label6
            // 
            label6.AutoSize = true;
            label6.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label6.Location = new Point(28, 369);
            label6.Name = "label6";
            label6.Size = new Size(60, 23);
            label6.TabIndex = 64;
            label6.Text = "الموبايل";
            // 
            // txtCustName
            // 
            txtCustName.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtCustName.Location = new Point(176, 327);
            txtCustName.Name = "txtCustName";
            txtCustName.Size = new Size(320, 30);
            txtCustName.TabIndex = 62;
            txtCustName.TextAlign = HorizontalAlignment.Center;
            // 
            // btnDel
            // 
            btnDel.BackColor = Color.FromArgb(0, 64, 64);
            btnDel.Image = (Image)resources.GetObject("btnDel.Image");
            btnDel.Location = new Point(146, 25);
            btnDel.Name = "btnDel";
            btnDel.Size = new Size(135, 42);
            btnDel.TabIndex = 3;
            btnDel.UseVisualStyleBackColor = false;
            btnDel.Click += btnDel_Click;
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label2.Location = new Point(27, 333);
            label2.Name = "label2";
            label2.Size = new Size(76, 23);
            label2.TabIndex = 60;
            label2.Text = "إسم العميل";
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label1.Location = new Point(27, 297);
            label1.Name = "label1";
            label1.Size = new Size(120, 23);
            label1.TabIndex = 59;
            label1.Text = "رقم حساب العميل";
            // 
            // dgvData
            // 
            dgvData.AllowUserToAddRows = false;
            dgvData.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            dgvData.BackgroundColor = Color.Azure;
            dgvData.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            dgvData.GridColor = Color.FromArgb(0, 64, 0);
            dgvData.Location = new Point(12, 12);
            dgvData.Name = "dgvData";
            dgvData.RowHeadersVisible = false;
            dgvData.RowHeadersWidth = 51;
            dgvData.Size = new Size(702, 234);
            dgvData.TabIndex = 58;
            dgvData.CellDoubleClick += dgvData_CellDoubleClick;
            // 
            // groupBox1
            // 
            groupBox1.Controls.Add(btnExit);
            groupBox1.Controls.Add(btnDel);
            groupBox1.Controls.Add(btnEdit);
            groupBox1.Controls.Add(btnAdd);
            groupBox1.Controls.Add(btnNew);
            groupBox1.Location = new Point(12, 496);
            groupBox1.Name = "groupBox1";
            groupBox1.Size = new Size(702, 75);
            groupBox1.TabIndex = 63;
            groupBox1.TabStop = false;
            // 
            // btnExit
            // 
            btnExit.BackColor = Color.FromArgb(0, 64, 64);
            btnExit.Image = (Image)resources.GetObject("btnExit.Image");
            btnExit.Location = new Point(6, 25);
            btnExit.Name = "btnExit";
            btnExit.Size = new Size(135, 42);
            btnExit.TabIndex = 4;
            btnExit.UseVisualStyleBackColor = false;
            btnExit.Click += btnExit_Click;
            // 
            // btnNew
            // 
            btnNew.BackColor = Color.FromArgb(0, 64, 64);
            btnNew.Image = (Image)resources.GetObject("btnNew.Image");
            btnNew.Location = new Point(566, 25);
            btnNew.Name = "btnNew";
            btnNew.Size = new Size(135, 42);
            btnNew.TabIndex = 0;
            btnNew.UseVisualStyleBackColor = false;
            btnNew.Click += btnNew_Click;
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label3.Location = new Point(28, 441);
            label3.Name = "label3";
            label3.Size = new Size(64, 23);
            label3.TabIndex = 65;
            label3.Text = "حد الدين";
            // 
            // txtDebitLimit
            // 
            txtDebitLimit.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtDebitLimit.Location = new Point(176, 435);
            txtDebitLimit.Name = "txtDebitLimit";
            txtDebitLimit.Size = new Size(322, 30);
            txtDebitLimit.TabIndex = 67;
            txtDebitLimit.TextAlign = HorizontalAlignment.Center;
            // 
            // frmCustomers
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(726, 583);
            Controls.Add(txtCustAccCode);
            Controls.Add(groupBox2);
            Controls.Add(txtMobile);
            Controls.Add(txtDebitLimit);
            Controls.Add(label3);
            Controls.Add(txtEmail);
            Controls.Add(label7);
            Controls.Add(label6);
            Controls.Add(txtCustName);
            Controls.Add(label2);
            Controls.Add(label1);
            Controls.Add(dgvData);
            Controls.Add(groupBox1);
            Icon = (Icon)resources.GetObject("$this.Icon");
            MaximizeBox = false;
            MinimizeBox = false;
            Name = "frmCustomers";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "العملاء";
            Load += frmCustomers_Load;
            groupBox2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)pbImg).EndInit();
            ((System.ComponentModel.ISupportInitialize)dgvData).EndInit();
            groupBox1.ResumeLayout(false);
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private TextBox txtCustAccCode;
        private Button btnAdd;
        private GroupBox groupBox2;
        private PictureBox pbImg;
        private Button btnClear;
        private Button btnBrowes;
        private Button btnEdit;
        private TextBox txtMobile;
        private TextBox txtEmail;
        private Label label7;
        private Label label6;
        private TextBox txtCustName;
        private Button btnDel;
        private Label label2;
        private Label label1;
        private DataGridView dgvData;
        private GroupBox groupBox1;
        private Button btnExit;
        private Button btnNew;
        private Label label3;
        private TextBox txtDebitLimit;
    }
}