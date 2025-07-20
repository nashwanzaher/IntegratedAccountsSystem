namespace IntegratedAccSys.PL.SysFormat
{
    partial class frmCurrencies
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmCurrencies));
            dgvData = new DataGridView();
            label1 = new Label();
            label2 = new Label();
            label3 = new Label();
            label4 = new Label();
            label5 = new Label();
            cbCurrType = new ComboBox();
            txtCurrName = new TextBox();
            txtPenny = new TextBox();
            txtSymbole = new TextBox();
            txtCurrVal = new TextBox();
            groupBox1 = new GroupBox();
            btnExit = new Button();
            btnDel = new Button();
            btnEdit = new Button();
            btnAdd = new Button();
            btnNew = new Button();
            txtCurrID = new TextBox();
            ((System.ComponentModel.ISupportInitialize)dgvData).BeginInit();
            groupBox1.SuspendLayout();
            SuspendLayout();
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
            dgvData.Size = new Size(459, 219);
            dgvData.TabIndex = 0;
            dgvData.CellClick += dgvData_CellClick;
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label1.Location = new Point(19, 247);
            label1.Name = "label1";
            label1.Size = new Size(77, 23);
            label1.TabIndex = 1;
            label1.Text = "نوع العملة";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label2.Location = new Point(19, 287);
            label2.Name = "label2";
            label2.Size = new Size(75, 23);
            label2.TabIndex = 2;
            label2.Text = "إسم العملة";
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label3.Location = new Point(19, 327);
            label3.Name = "label3";
            label3.Size = new Size(40, 23);
            label3.TabIndex = 3;
            label3.Text = "الفكة";
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label4.Location = new Point(19, 367);
            label4.Name = "label4";
            label4.Size = new Size(45, 23);
            label4.TabIndex = 4;
            label4.Text = "الرمز";
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label5.Location = new Point(19, 407);
            label5.Name = "label5";
            label5.Size = new Size(58, 23);
            label5.TabIndex = 5;
            label5.Text = "الصرف";
            // 
            // cbCurrType
            // 
            cbCurrType.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            cbCurrType.FormattingEnabled = true;
            cbCurrType.Location = new Point(116, 247);
            cbCurrType.Name = "cbCurrType";
            cbCurrType.Size = new Size(210, 31);
            cbCurrType.TabIndex = 6;
            // 
            // txtCurrName
            // 
            txtCurrName.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtCurrName.Location = new Point(116, 286);
            txtCurrName.Name = "txtCurrName";
            txtCurrName.Size = new Size(339, 30);
            txtCurrName.TabIndex = 7;
            // 
            // txtPenny
            // 
            txtPenny.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtPenny.Location = new Point(116, 324);
            txtPenny.Name = "txtPenny";
            txtPenny.Size = new Size(339, 30);
            txtPenny.TabIndex = 8;
            // 
            // txtSymbole
            // 
            txtSymbole.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtSymbole.Location = new Point(116, 362);
            txtSymbole.Name = "txtSymbole";
            txtSymbole.Size = new Size(339, 30);
            txtSymbole.TabIndex = 9;
            // 
            // txtCurrVal
            // 
            txtCurrVal.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtCurrVal.Location = new Point(116, 400);
            txtCurrVal.Name = "txtCurrVal";
            txtCurrVal.Size = new Size(339, 30);
            txtCurrVal.TabIndex = 10;
            txtCurrVal.KeyPress += txtCurrVal_KeyPress;
            // 
            // groupBox1
            // 
            groupBox1.Controls.Add(btnExit);
            groupBox1.Controls.Add(btnDel);
            groupBox1.Controls.Add(btnEdit);
            groupBox1.Controls.Add(btnAdd);
            groupBox1.Controls.Add(btnNew);
            groupBox1.Location = new Point(12, 433);
            groupBox1.Name = "groupBox1";
            groupBox1.Size = new Size(459, 78);
            groupBox1.TabIndex = 11;
            groupBox1.TabStop = false;
            // 
            // btnExit
            // 
            btnExit.Image = (Image)resources.GetObject("btnExit.Image");
            btnExit.Location = new Point(19, 22);
            btnExit.Name = "btnExit";
            btnExit.Size = new Size(80, 46);
            btnExit.TabIndex = 4;
            btnExit.UseVisualStyleBackColor = true;
            btnExit.Click += btnExit_Click;
            // 
            // btnDel
            // 
            btnDel.Enabled = false;
            btnDel.Image = (Image)resources.GetObject("btnDel.Image");
            btnDel.Location = new Point(104, 22);
            btnDel.Name = "btnDel";
            btnDel.Size = new Size(80, 46);
            btnDel.TabIndex = 3;
            btnDel.UseVisualStyleBackColor = true;
            btnDel.Click += btnDel_Click;
            // 
            // btnEdit
            // 
            btnEdit.Enabled = false;
            btnEdit.Image = (Image)resources.GetObject("btnEdit.Image");
            btnEdit.Location = new Point(189, 22);
            btnEdit.Name = "btnEdit";
            btnEdit.Size = new Size(80, 46);
            btnEdit.TabIndex = 2;
            btnEdit.UseVisualStyleBackColor = true;
            btnEdit.Click += btnEdit_Click;
            // 
            // btnAdd
            // 
            btnAdd.Enabled = false;
            btnAdd.Image = (Image)resources.GetObject("btnAdd.Image");
            btnAdd.Location = new Point(274, 22);
            btnAdd.Name = "btnAdd";
            btnAdd.Size = new Size(80, 46);
            btnAdd.TabIndex = 1;
            btnAdd.UseVisualStyleBackColor = true;
            btnAdd.Click += btnAdd_Click;
            // 
            // btnNew
            // 
            btnNew.Image = (Image)resources.GetObject("btnNew.Image");
            btnNew.Location = new Point(359, 22);
            btnNew.Name = "btnNew";
            btnNew.Size = new Size(80, 46);
            btnNew.TabIndex = 0;
            btnNew.UseVisualStyleBackColor = true;
            btnNew.Click += btnNew_Click;
            // 
            // txtCurrID
            // 
            txtCurrID.Location = new Point(359, 247);
            txtCurrID.Name = "txtCurrID";
            txtCurrID.Size = new Size(93, 27);
            txtCurrID.TabIndex = 12;
            txtCurrID.Visible = false;
            // 
            // frmCurrencies
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(483, 514);
            Controls.Add(txtCurrID);
            Controls.Add(groupBox1);
            Controls.Add(txtCurrVal);
            Controls.Add(txtSymbole);
            Controls.Add(txtPenny);
            Controls.Add(txtCurrName);
            Controls.Add(cbCurrType);
            Controls.Add(label5);
            Controls.Add(label4);
            Controls.Add(label3);
            Controls.Add(label2);
            Controls.Add(label1);
            Controls.Add(dgvData);
            Icon = (Icon)resources.GetObject("$this.Icon");
            Name = "frmCurrencies";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "العملات";
            Load += frmCurrencies_Load;
            ((System.ComponentModel.ISupportInitialize)dgvData).EndInit();
            groupBox1.ResumeLayout(false);
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private DataGridView dgvData;
        private Label label1;
        private Label label2;
        private Label label3;
        private Label label4;
        private Label label5;
        private ComboBox cbCurrType;
        private TextBox txtCurrName;
        private TextBox txtPenny;
        private TextBox txtSymbole;
        private TextBox txtCurrVal;
        private GroupBox groupBox1;
        private Button btnExit;
        private Button btnDel;
        private Button btnEdit;
        private Button btnAdd;
        private Button btnNew;
        private TextBox txtCurrID;
    }
}