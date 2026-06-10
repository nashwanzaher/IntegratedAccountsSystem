namespace IntegratedAccSys.PL.Stores
{
    partial class frmUnits
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmUnits));
            groupBox1 = new GroupBox();
            btnExit = new Button();
            btnDel = new Button();
            btnEdit = new Button();
            btnAdd = new Button();
            btnNew = new Button();
            txtConvertionFactor = new TextBox();
            txtUnitName = new TextBox();
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
            groupBox1.TabIndex = 23;
            groupBox1.TabStop = false;
            // 
            // btnExit
            // 
            btnExit.BackColor = Color.FromArgb(0, 64, 64);
            btnExit.Image = (Image)resources.GetObject("btnExit.Image");
            btnExit.Location = new Point(15, 25);
            btnExit.Name = "btnExit";
            btnExit.Size = new Size(89, 42);
            btnExit.TabIndex = 4;
            btnExit.UseVisualStyleBackColor = false;
            btnExit.Click += btnExit_Click;
            // 
            // btnDel
            // 
            btnDel.BackColor = Color.FromArgb(0, 64, 64);
            btnDel.Image = (Image)resources.GetObject("btnDel.Image");
            btnDel.Location = new Point(103, 24);
            btnDel.Name = "btnDel";
            btnDel.Size = new Size(89, 42);
            btnDel.TabIndex = 3;
            btnDel.UseVisualStyleBackColor = false;
            btnDel.Click += btnDel_Click;
            // 
            // btnEdit
            // 
            btnEdit.BackColor = Color.FromArgb(0, 64, 64);
            btnEdit.Image = (Image)resources.GetObject("btnEdit.Image");
            btnEdit.Location = new Point(191, 24);
            btnEdit.Name = "btnEdit";
            btnEdit.Size = new Size(89, 42);
            btnEdit.TabIndex = 2;
            btnEdit.UseVisualStyleBackColor = false;
            btnEdit.Click += btnEdit_Click;
            // 
            // btnAdd
            // 
            btnAdd.BackColor = Color.FromArgb(0, 64, 64);
            btnAdd.Image = (Image)resources.GetObject("btnAdd.Image");
            btnAdd.Location = new Point(279, 24);
            btnAdd.Name = "btnAdd";
            btnAdd.Size = new Size(89, 42);
            btnAdd.TabIndex = 1;
            btnAdd.UseVisualStyleBackColor = false;
            btnAdd.Click += btnAdd_Click;
            // 
            // btnNew
            // 
            btnNew.BackColor = Color.FromArgb(0, 64, 64);
            btnNew.Image = (Image)resources.GetObject("btnNew.Image");
            btnNew.Location = new Point(367, 24);
            btnNew.Name = "btnNew";
            btnNew.Size = new Size(89, 42);
            btnNew.TabIndex = 0;
            btnNew.UseVisualStyleBackColor = false;
            btnNew.Click += btnNew_Click;
            // 
            // txtConvertionFactor
            // 
            txtConvertionFactor.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtConvertionFactor.Location = new Point(144, 303);
            txtConvertionFactor.Name = "txtConvertionFactor";
            txtConvertionFactor.Size = new Size(320, 30);
            txtConvertionFactor.TabIndex = 22;
            // 
            // txtUnitName
            // 
            txtUnitName.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtUnitName.Location = new Point(144, 265);
            txtUnitName.Name = "txtUnitName";
            txtUnitName.Size = new Size(320, 30);
            txtUnitName.TabIndex = 21;
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label2.Location = new Point(32, 306);
            label2.Name = "label2";
            label2.Size = new Size(99, 23);
            label2.TabIndex = 20;
            label2.Text = "معامل التحويل";
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label1.Location = new Point(32, 269);
            label1.Name = "label1";
            label1.Size = new Size(80, 23);
            label1.TabIndex = 19;
            label1.Text = "إسم الوحدة";
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
            dgvData.TabIndex = 18;
            dgvData.CellDoubleClick += dgvData_CellDoubleClick;
            // 
            // frmUnits
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(497, 435);
            Controls.Add(groupBox1);
            Controls.Add(txtConvertionFactor);
            Controls.Add(txtUnitName);
            Controls.Add(label2);
            Controls.Add(label1);
            Controls.Add(dgvData);
            MaximizeBox = false;
            MinimizeBox = false;
            Name = "frmUnits";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "الوحدات";
            Load += frmUnits_Load;
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
        private TextBox txtConvertionFactor;
        private TextBox txtUnitName;
        private Label label2;
        private Label label1;
        private DataGridView dgvData;
    }
}