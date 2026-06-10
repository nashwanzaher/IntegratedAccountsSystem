namespace IntegratedAccSys.PL.SysFormat
{
    partial class frmVATSettings
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmVATSettings));
            label1 = new Label();
            txtTaxPresenetage = new TextBox();
            btnNew = new Button();
            btnSave = new Button();
            btnWipe = new Button();
            btnExit = new Button();
            btnDisplay = new Button();
            SuspendLayout();
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            label1.Location = new Point(38, 40);
            label1.Name = "label1";
            label1.Size = new Size(96, 23);
            label1.TabIndex = 0;
            label1.Text = "نسبة الضريبة";
            // 
            // txtTaxPresenetage
            // 
            txtTaxPresenetage.Enabled = false;
            txtTaxPresenetage.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            txtTaxPresenetage.Location = new Point(164, 37);
            txtTaxPresenetage.Name = "txtTaxPresenetage";
            txtTaxPresenetage.Size = new Size(277, 30);
            txtTaxPresenetage.TabIndex = 1;
            txtTaxPresenetage.TextAlign = HorizontalAlignment.Center;
            // 
            // btnNew
            // 
            btnNew.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnNew.Image = (Image)resources.GetObject("btnNew.Image");
            btnNew.Location = new Point(12, 93);
            btnNew.Name = "btnNew";
            btnNew.Size = new Size(94, 41);
            btnNew.TabIndex = 2;
            btnNew.UseVisualStyleBackColor = true;
            btnNew.Click += btnNew_Click;
            // 
            // btnSave
            // 
            btnSave.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnSave.Image = (Image)resources.GetObject("btnSave.Image");
            btnSave.Location = new Point(108, 93);
            btnSave.Name = "btnSave";
            btnSave.Size = new Size(94, 41);
            btnSave.TabIndex = 3;
            btnSave.UseVisualStyleBackColor = true;
            btnSave.Click += btnSave_Click;
            // 
            // btnWipe
            // 
            btnWipe.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnWipe.Image = (Image)resources.GetObject("btnWipe.Image");
            btnWipe.Location = new Point(300, 93);
            btnWipe.Name = "btnWipe";
            btnWipe.Size = new Size(94, 41);
            btnWipe.TabIndex = 4;
            btnWipe.UseVisualStyleBackColor = true;
            btnWipe.Click += btnWipe_Click;
            // 
            // btnExit
            // 
            btnExit.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnExit.Image = (Image)resources.GetObject("btnExit.Image");
            btnExit.Location = new Point(396, 93);
            btnExit.Name = "btnExit";
            btnExit.Size = new Size(94, 41);
            btnExit.TabIndex = 5;
            btnExit.UseVisualStyleBackColor = true;
            btnExit.Click += btnExit_Click;
            // 
            // btnDisplay
            // 
            btnDisplay.Image = (Image)resources.GetObject("btnDisplay.Image");
            btnDisplay.Location = new Point(204, 93);
            btnDisplay.Name = "btnDisplay";
            btnDisplay.Size = new Size(94, 41);
            btnDisplay.TabIndex = 6;
            btnDisplay.UseVisualStyleBackColor = true;
            btnDisplay.Click += btnDisplay_Click;
            // 
            // frmVATSettings
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(502, 168);
            Controls.Add(btnDisplay);
            Controls.Add(btnExit);
            Controls.Add(btnWipe);
            Controls.Add(btnSave);
            Controls.Add(btnNew);
            Controls.Add(txtTaxPresenetage);
            Controls.Add(label1);
            Icon = (Icon)resources.GetObject("$this.Icon");
            MaximizeBox = false;
            MinimizeBox = false;
            Name = "frmVATSettings";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "ضريبة القيمة المضافة";
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Label label1;
        private TextBox txtTaxPresenetage;
        private Button btnNew;
        private Button btnSave;
        private Button btnWipe;
        private Button btnExit;
        private Button btnDisplay;
    }
}