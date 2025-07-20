namespace IntegratedAccSys.Reports
{
    partial class frmReportViewer
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmReportViewer));
            reportViewer = new Microsoft.Reporting.WinForms.ReportViewer();
            btnPrint = new Button();
            SuspendLayout();
            // 
            // reportViewer
            // 
            reportViewer.Dock = DockStyle.Fill;
            reportViewer.Location = new Point(0, 0);
            reportViewer.Name = "ReportViewer";
            reportViewer.ServerReport.BearerToken = null;
            reportViewer.Size = new Size(1297, 739);
            reportViewer.TabIndex = 0;
            // 
            // btnPrint
            // 
            btnPrint.Image = (Image)resources.GetObject("btnPrint.Image");
            btnPrint.Location = new Point(772, 1);
            btnPrint.Name = "btnPrint";
            btnPrint.Size = new Size(46, 29);
            btnPrint.TabIndex = 1;
            btnPrint.UseVisualStyleBackColor = true;
            btnPrint.Click += btnPrint_Click;
            // 
            // frmReportViewer
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(1297, 739);
            Controls.Add(btnPrint);
            Controls.Add(reportViewer);
            Icon = (Icon)resources.GetObject("$this.Icon");
            Name = "frmReportViewer";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "عارض التقارير";
            Load += frmReportViewer_Load;
            ResumeLayout(false);
        }

        #endregion

        private Microsoft.Reporting.WinForms.ReportViewer reportViewer;
        private Button btnPrint;
    }
}