namespace IntegratedAccSys.PL.SysFormat
{
    partial class frmAccountsJoin
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmAccountsJoin));
            label1 = new Label();
            label2 = new Label();
            label3 = new Label();
            label4 = new Label();
            label5 = new Label();
            txtInventoryCode = new TextBox();
            txtDiscountRecievedCode = new TextBox();
            txtDiscountAllowedCode = new TextBox();
            txtVatPurchasesCode = new TextBox();
            txtVatSalesCode = new TextBox();
            btnNew = new Button();
            btnAdd = new Button();
            btnDisplay = new Button();
            btnWipe = new Button();
            btnExit = new Button();
            textBox2 = new TextBox();
            label6 = new Label();
            label7 = new Label();
            txtSalesRevenuseCode = new TextBox();
            txtSaleCostCode = new TextBox();
            SuspendLayout();
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label1.Location = new Point(15, 24);
            label1.Name = "label1";
            label1.Size = new Size(111, 23);
            label1.TabIndex = 0;
            label1.Text = "حساب المخزون";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label2.Location = new Point(15, 57);
            label2.Name = "label2";
            label2.Size = new Size(155, 23);
            label2.TabIndex = 0;
            label2.Text = "حساب الخصم المكتسب";
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label3.Location = new Point(15, 90);
            label3.Name = "label3";
            label3.Size = new Size(177, 23);
            label3.TabIndex = 0;
            label3.Text = "حساب الخصم المسموح به";
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label4.Location = new Point(15, 123);
            label4.Name = "label4";
            label4.Size = new Size(224, 23);
            label4.TabIndex = 0;
            label4.Text = "حساب القيمة المضاقة  للمشتريات";
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label5.Location = new Point(15, 156);
            label5.Name = "label5";
            label5.Size = new Size(205, 23);
            label5.TabIndex = 0;
            label5.Text = "حساب القيمة المضافة للمبيعات";
            // 
            // txtInventoryCode
            // 
            txtInventoryCode.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtInventoryCode.Location = new Point(245, 18);
            txtInventoryCode.Name = "txtInventoryCode";
            txtInventoryCode.Size = new Size(329, 30);
            txtInventoryCode.TabIndex = 1;
            txtInventoryCode.TextAlign = HorizontalAlignment.Center;
            txtInventoryCode.KeyDown += txtInventoryCode_KeyDown;
            // 
            // txtDiscountRecievedCode
            // 
            txtDiscountRecievedCode.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtDiscountRecievedCode.Location = new Point(245, 51);
            txtDiscountRecievedCode.Name = "txtDiscountRecievedCode";
            txtDiscountRecievedCode.Size = new Size(329, 30);
            txtDiscountRecievedCode.TabIndex = 1;
            txtDiscountRecievedCode.TextAlign = HorizontalAlignment.Center;
            txtDiscountRecievedCode.KeyDown += txtDiscountRecievedCode_KeyDown;
            // 
            // txtDiscountAllowedCode
            // 
            txtDiscountAllowedCode.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtDiscountAllowedCode.Location = new Point(245, 84);
            txtDiscountAllowedCode.Name = "txtDiscountAllowedCode";
            txtDiscountAllowedCode.Size = new Size(329, 30);
            txtDiscountAllowedCode.TabIndex = 1;
            txtDiscountAllowedCode.TextAlign = HorizontalAlignment.Center;
            txtDiscountAllowedCode.KeyDown += txtDiscountAllowedCode_KeyDown;
            // 
            // txtVatPurchasesCode
            // 
            txtVatPurchasesCode.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtVatPurchasesCode.Location = new Point(245, 117);
            txtVatPurchasesCode.Name = "txtVatPurchasesCode";
            txtVatPurchasesCode.Size = new Size(329, 30);
            txtVatPurchasesCode.TabIndex = 1;
            txtVatPurchasesCode.TextAlign = HorizontalAlignment.Center;
            txtVatPurchasesCode.KeyDown += txtVatPurchasesCode_KeyDown;
            // 
            // txtVatSalesCode
            // 
            txtVatSalesCode.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtVatSalesCode.Location = new Point(245, 150);
            txtVatSalesCode.Name = "txtVatSalesCode";
            txtVatSalesCode.Size = new Size(329, 30);
            txtVatSalesCode.TabIndex = 1;
            txtVatSalesCode.TextAlign = HorizontalAlignment.Center;
            txtVatSalesCode.KeyDown += txtVatSalesCode_KeyDown;
            // 
            // btnNew
            // 
            btnNew.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnNew.Image = (Image)resources.GetObject("btnNew.Image");
            btnNew.Location = new Point(64, 273);
            btnNew.Name = "btnNew";
            btnNew.Size = new Size(94, 46);
            btnNew.TabIndex = 2;
            btnNew.UseVisualStyleBackColor = true;
            btnNew.Click += btnNew_Click;
            // 
            // btnAdd
            // 
            btnAdd.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnAdd.Image = (Image)resources.GetObject("btnAdd.Image");
            btnAdd.Location = new Point(162, 273);
            btnAdd.Name = "btnAdd";
            btnAdd.Size = new Size(94, 46);
            btnAdd.TabIndex = 3;
            btnAdd.UseVisualStyleBackColor = true;
            btnAdd.Click += btnAdd_Click;
            // 
            // btnDisplay
            // 
            btnDisplay.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnDisplay.Image = (Image)resources.GetObject("btnDisplay.Image");
            btnDisplay.Location = new Point(260, 273);
            btnDisplay.Name = "btnDisplay";
            btnDisplay.Size = new Size(94, 46);
            btnDisplay.TabIndex = 4;
            btnDisplay.UseVisualStyleBackColor = true;
            btnDisplay.Click += btnDisplay_Click;
            // 
            // btnWipe
            // 
            btnWipe.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnWipe.Image = (Image)resources.GetObject("btnWipe.Image");
            btnWipe.Location = new Point(358, 273);
            btnWipe.Name = "btnWipe";
            btnWipe.Size = new Size(94, 46);
            btnWipe.TabIndex = 5;
            btnWipe.UseVisualStyleBackColor = true;
            btnWipe.Click += btnWipe_Click;
            // 
            // btnExit
            // 
            btnExit.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnExit.Image = (Image)resources.GetObject("btnExit.Image");
            btnExit.Location = new Point(456, 273);
            btnExit.Name = "btnExit";
            btnExit.Size = new Size(94, 46);
            btnExit.TabIndex = 6;
            btnExit.UseVisualStyleBackColor = true;
            btnExit.Click += btnExit_Click;
            // 
            // textBox2
            // 
            textBox2.Location = new Point(242, 87);
            textBox2.Name = "textBox2";
            textBox2.Size = new Size(286, 27);
            textBox2.TabIndex = 1;
            // 
            // label6
            // 
            label6.AutoSize = true;
            label6.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label6.Location = new Point(15, 189);
            label6.Name = "label6";
            label6.Size = new Size(141, 23);
            label6.TabIndex = 0;
            label6.Text = "حساب إيراد المبيعات";
            // 
            // label7
            // 
            label7.AutoSize = true;
            label7.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label7.Location = new Point(15, 222);
            label7.Name = "label7";
            label7.Size = new Size(143, 23);
            label7.TabIndex = 0;
            label7.Text = "حساب تكلفة المبيعات";
            // 
            // txtSalesRevenuseCode
            // 
            txtSalesRevenuseCode.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtSalesRevenuseCode.Location = new Point(245, 183);
            txtSalesRevenuseCode.Name = "txtSalesRevenuseCode";
            txtSalesRevenuseCode.Size = new Size(329, 30);
            txtSalesRevenuseCode.TabIndex = 1;
            txtSalesRevenuseCode.TextAlign = HorizontalAlignment.Center;
            txtSalesRevenuseCode.KeyDown += txtSalesRevenuseCode_KeyDown;
            // 
            // txtSaleCostCode
            // 
            txtSaleCostCode.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtSaleCostCode.Location = new Point(245, 216);
            txtSaleCostCode.Name = "txtSaleCostCode";
            txtSaleCostCode.Size = new Size(329, 30);
            txtSaleCostCode.TabIndex = 1;
            txtSaleCostCode.TextAlign = HorizontalAlignment.Center;
            txtSaleCostCode.KeyDown += txtSaleCostCode_KeyDown;
            // 
            // frmAccountsJoin
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(596, 340);
            Controls.Add(btnExit);
            Controls.Add(btnWipe);
            Controls.Add(btnDisplay);
            Controls.Add(btnAdd);
            Controls.Add(btnNew);
            Controls.Add(txtSaleCostCode);
            Controls.Add(txtSalesRevenuseCode);
            Controls.Add(txtVatSalesCode);
            Controls.Add(txtVatPurchasesCode);
            Controls.Add(txtDiscountAllowedCode);
            Controls.Add(txtDiscountRecievedCode);
            Controls.Add(txtInventoryCode);
            Controls.Add(label7);
            Controls.Add(label6);
            Controls.Add(label5);
            Controls.Add(label4);
            Controls.Add(label3);
            Controls.Add(label2);
            Controls.Add(label1);
            Icon = (Icon)resources.GetObject("$this.Icon");
            MaximizeBox = false;
            MinimizeBox = false;
            Name = "frmAccountsJoin";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "ربط المشتريات و المبيعات  بالحسابات";
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Label label1;
        private Label label2;
        private Label label3;
        private Label label4;
        private Label label5;
        private TextBox txtInventoryCode;
        private TextBox txtDiscountRecievedCode;
        private TextBox txtDiscountAllowedCode;
        private TextBox txtVatPurchasesCode;
        private TextBox txtVatSalesCode;
        private Button btnNew;
        private Button btnAdd;
        private Button btnDisplay;
        private Button btnWipe;
        private Button btnExit;
        private TextBox textBox2;
        private Label label6;
        private Label label7;
        private TextBox txtSalesRevenuseCode;
        private TextBox txtSaleCostCode;
    }
}