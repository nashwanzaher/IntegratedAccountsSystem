namespace IntegratedAccSys.PL.Reports
{
    partial class ReportViewer
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
            rptViewer = new Microsoft.Reporting.WinForms.ReportViewer();
            SuspendLayout();
            // 
            // rptViewer
            // 
            rptViewer.AllowDrop = true;
            rptViewer.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            rptViewer.AutoSize = true;
            rptViewer.ImeMode = ImeMode.NoControl;
            rptViewer.Location = new Point(0, 0);
            rptViewer.Name = "ReportViewer";
            rptViewer.ServerReport.BearerToken = null;
            rptViewer.Size = new Size(947, 569);
            rptViewer.TabIndex = 0;
            // 
            // ReportViewer
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(947, 569);
            Controls.Add(rptViewer);
            Name = "ReportViewer";
            Text = "ReportViewer";
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        public Microsoft.Reporting.WinForms.ReportViewer rptViewer;
    }
}