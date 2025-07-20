namespace IntegratedAccSys.PL.SysFormat
{
    partial class frmBackUps
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmBackUps));
            btnBackUp = new Button();
            btnRestoreDB = new Button();
            btnEXit = new Button();
            txtBackType = new TextBox();
            SuspendLayout();
            // 
            // btnBackUp
            // 
            btnBackUp.BackColor = Color.FromArgb(64, 0, 64);
            btnBackUp.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnBackUp.ForeColor = Color.Yellow;
            btnBackUp.Location = new Point(31, 22);
            btnBackUp.Name = "btnBackUp";
            btnBackUp.Size = new Size(417, 48);
            btnBackUp.TabIndex = 0;
            btnBackUp.Text = "عمل نسخة إحتياطية";
            btnBackUp.UseVisualStyleBackColor = false;
            btnBackUp.Click += btnBackUp_Click;
            // 
            // btnRestoreDB
            // 
            btnRestoreDB.BackColor = Color.FromArgb(64, 0, 64);
            btnRestoreDB.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnRestoreDB.ForeColor = Color.Yellow;
            btnRestoreDB.Location = new Point(31, 22);
            btnRestoreDB.Name = "btnRestoreDB";
            btnRestoreDB.Size = new Size(417, 48);
            btnRestoreDB.TabIndex = 1;
            btnRestoreDB.Text = "إسترجاع النسخة الإحتياطية";
            btnRestoreDB.UseVisualStyleBackColor = false;
            btnRestoreDB.Click += btnRestoreDB_Click;
            // 
            // btnEXit
            // 
            btnEXit.BackColor = Color.FromArgb(0, 64, 64);
            btnEXit.Font = new Font("Times New Roman", 12F, FontStyle.Bold);
            btnEXit.Image = (Image)resources.GetObject("btnEXit.Image");
            btnEXit.Location = new Point(454, 22);
            btnEXit.Name = "btnEXit";
            btnEXit.Size = new Size(94, 48);
            btnEXit.TabIndex = 2;
            btnEXit.UseVisualStyleBackColor = false;
            btnEXit.Click += btnEXit_Click;
            // 
            // txtBackType
            // 
            txtBackType.Location = new Point(212, 76);
            txtBackType.Name = "txtBackType";
            txtBackType.Size = new Size(125, 27);
            txtBackType.TabIndex = 3;
            txtBackType.Visible = false;
            // 
            // frmBackUps
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(577, 104);
            Controls.Add(txtBackType);
            Controls.Add(btnEXit);
            Controls.Add(btnRestoreDB);
            Controls.Add(btnBackUp);
            Icon = (Icon)resources.GetObject("$this.Icon");
            MaximizeBox = false;
            MinimizeBox = false;
            Name = "frmBackUps";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        public Button btnBackUp;
        public Button btnRestoreDB;
        public Button btnEXit;
        public TextBox txtBackType;
    }
}