namespace IntegratedAccSys.PL.stores
{
    partial class frmProducts
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmProducts));
            groupBox1 = new GroupBox();
            btnExit = new Button();
            btnDel = new Button();
            btnEdit = new Button();
            btnAdd = new Button();
            btnNew = new Button();
            txtProdName = new TextBox();
            txtProdNo = new TextBox();
            label2 = new Label();
            label1 = new Label();
            dgvData = new DataGridView();
            label3 = new Label();
            label4 = new Label();
            label5 = new Label();
            label6 = new Label();
            label7 = new Label();
            cbStores = new ComboBox();
            cbCategories = new ComboBox();
            cbUnits = new ComboBox();
            txtQty = new TextBox();
            txtPrice = new TextBox();
            groupBox2 = new GroupBox();
            pbImg = new PictureBox();
            btnClear = new Button();
            btnBrowes = new Button();
            groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)dgvData).BeginInit();
            groupBox2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)pbImg).BeginInit();
            SuspendLayout();
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
            groupBox1.TabIndex = 29;
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
            // txtProdName
            // 
            txtProdName.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtProdName.Location = new Point(166, 294);
            txtProdName.Name = "txtProdName";
            txtProdName.Size = new Size(320, 30);
            txtProdName.TabIndex = 28;
            // 
            // txtProdNo
            // 
            txtProdNo.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtProdNo.Location = new Point(166, 260);
            txtProdNo.Name = "txtProdNo";
            txtProdNo.Size = new Size(320, 30);
            txtProdNo.TabIndex = 27;
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label2.Location = new Point(17, 301);
            label2.Name = "label2";
            label2.Size = new Size(82, 23);
            label2.TabIndex = 26;
            label2.Text = "إسم الصنف";
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label1.Location = new Point(17, 266);
            label1.Name = "label1";
            label1.Size = new Size(81, 23);
            label1.TabIndex = 25;
            label1.Text = "رقم الصنف";
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
            dgvData.TabIndex = 24;
            dgvData.CellDoubleClick += dgvData_CellDoubleClick;
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label3.Location = new Point(18, 336);
            label3.Name = "label3";
            label3.Size = new Size(57, 23);
            label3.TabIndex = 30;
            label3.Text = "المخزن";
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label4.Location = new Point(18, 371);
            label4.Name = "label4";
            label4.Size = new Size(132, 23);
            label4.TabIndex = 31;
            label4.Text = "المجموعة المخزنية";
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label5.Location = new Point(18, 406);
            label5.Name = "label5";
            label5.Size = new Size(52, 23);
            label5.TabIndex = 32;
            label5.Text = "الوحدة";
            // 
            // label6
            // 
            label6.AutoSize = true;
            label6.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label6.Location = new Point(18, 441);
            label6.Name = "label6";
            label6.Size = new Size(47, 23);
            label6.TabIndex = 33;
            label6.Text = "الكمية";
            // 
            // label7
            // 
            label7.AutoSize = true;
            label7.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label7.Location = new Point(18, 476);
            label7.Name = "label7";
            label7.Size = new Size(47, 23);
            label7.TabIndex = 34;
            label7.Text = "السعر";
            // 
            // cbStores
            // 
            cbStores.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            cbStores.FormattingEnabled = true;
            cbStores.Location = new Point(166, 328);
            cbStores.Name = "cbStores";
            cbStores.Size = new Size(320, 31);
            cbStores.TabIndex = 35;
            // 
            // cbCategories
            // 
            cbCategories.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            cbCategories.FormattingEnabled = true;
            cbCategories.Location = new Point(166, 363);
            cbCategories.Name = "cbCategories";
            cbCategories.Size = new Size(320, 31);
            cbCategories.TabIndex = 36;
            // 
            // cbUnits
            // 
            cbUnits.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            cbUnits.FormattingEnabled = true;
            cbUnits.Location = new Point(166, 398);
            cbUnits.Name = "cbUnits";
            cbUnits.Size = new Size(320, 31);
            cbUnits.TabIndex = 37;
            // 
            // txtQty
            // 
            txtQty.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtQty.Location = new Point(166, 433);
            txtQty.Name = "txtQty";
            txtQty.Size = new Size(320, 30);
            txtQty.TabIndex = 38;
            // 
            // txtPrice
            // 
            txtPrice.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtPrice.Location = new Point(166, 467);
            txtPrice.Name = "txtPrice";
            txtPrice.Size = new Size(322, 30);
            txtPrice.TabIndex = 39;
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
            groupBox2.TabIndex = 40;
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
            // frmProducts
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(726, 583);
            Controls.Add(groupBox2);
            Controls.Add(txtPrice);
            Controls.Add(txtQty);
            Controls.Add(cbUnits);
            Controls.Add(cbCategories);
            Controls.Add(cbStores);
            Controls.Add(label7);
            Controls.Add(label6);
            Controls.Add(label5);
            Controls.Add(label4);
            Controls.Add(label3);
            Controls.Add(groupBox1);
            Controls.Add(txtProdName);
            Controls.Add(txtProdNo);
            Controls.Add(label2);
            Controls.Add(label1);
            Controls.Add(dgvData);
            Icon = (Icon)resources.GetObject("$this.Icon");
            Name = "frmProducts";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "المنتجات";
            Load += frmProducts_Load;
            groupBox1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)dgvData).EndInit();
            groupBox2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)pbImg).EndInit();
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
        private TextBox txtProdName;
        private TextBox txtProdNo;
        private Label label2;
        private Label label1;
        private DataGridView dgvData;
        private Label label3;
        private Label label4;
        private Label label5;
        private Label label6;
        private Label label7;
        private ComboBox cbStores;
        private ComboBox cbCategories;
        private ComboBox cbUnits;
        private TextBox txtQty;
        private TextBox txtPrice;
        private GroupBox groupBox2;
        private Button btnClear;
        private Button btnBrowes;
        private PictureBox pbImg;
    }
}