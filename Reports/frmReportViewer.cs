using IntegratedAccSys.PL.Reports;
using Microsoft.Reporting.WinForms;
using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Printing;
using System.IO;
using System.Windows.Forms;

namespace IntegratedAccSys.Reports
{
    public partial class frmReportViewer : Form
    {
        
        private string reportName;
        private string reportTitle;
        private List<ReportDataSource> reportDataSource=new List<ReportDataSource>();   
        private List<Metafile> pages = new List<Metafile>(); // قائمة لحفظ الصفحات
        private int currentPage = 0; //  الصفحة الحالية
        private PrintDocument printDoc = new PrintDocument(); // مستند الطباعة

        public frmReportViewer(string reportName, List<ReportDataSource> reportDataSource, string reportTitle)
        {
            InitializeComponent();
            printDoc.PrintPage += new PrintPageEventHandler(PrintReport); // ربط الحدث
            this.reportName = reportName;
            this.reportDataSource = reportDataSource;
            this.reportTitle = reportTitle;

        }

        private void frmReportViewer_Load(object sender, EventArgs e)
        {
            reportViewer.LocalReport.ReportEmbeddedResource = $"IntegratedAccSys.Reports.{reportName}";

            reportViewer.LocalReport.DataSources.Clear();

            foreach (var dataSource in reportDataSource)
            {
                reportViewer.LocalReport.DataSources.Add(dataSource);
            }

            ReportParameter paramTitle = new ReportParameter("reportTitle", reportTitle);
            reportViewer.LocalReport.SetParameters(new ReportParameter[] { paramTitle });

            reportViewer.LocalReport.Refresh();
            reportViewer.RefreshReport();

            reportViewer.SetDisplayMode(DisplayMode.PrintLayout);
            reportViewer.ZoomMode = ZoomMode.Percent;
            reportViewer.ZoomPercent = 100;
        }

        private void RenderReportToImages()
        {
            try
            {
                
                pages.Clear();
                int pageIndex = 1;

                while (true)
                {
                    string deviceInfo = $@"
                        <DeviceInfo>
                            <OutputFormat>EMF</OutputFormat>
                            <StartPage>{pageIndex}</StartPage>
                            <EndPage>{pageIndex}</EndPage>
                        </DeviceInfo>";

                    byte[] bytes = reportViewer.LocalReport.Render("IMAGE", deviceInfo,
                        out _, out _, out _,
                        out _, out _);

                    if (bytes == null || bytes.Length == 0)
                        break;

                    string tempFile = Path.GetTempFileName();
                    File.WriteAllBytes(tempFile, bytes);
                    pages.Add(new Metafile(tempFile));

                    pageIndex++;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("حدث خطأ أثناء معالجة التقرير: " + ex.Message);
            }
        }

        private void PrintReport(object sender, PrintPageEventArgs e)
        {
            try
            {
                if (currentPage < pages.Count)
                {
                    e.Graphics.DrawImage(pages[currentPage], e.PageBounds);
                    currentPage++;
                    e.HasMorePages = (currentPage < pages.Count);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("حدث خطأ أثناء الطباعة: " + ex.Message);
            }
        }

        private void btnPrint_Click(object sender, EventArgs e)
        {
            try
            {
                RenderReportToImages();

                if (pages.Count == 0)
                {
                    MessageBox.Show("لا توجد صفحات للطباعة!");
                    return;
                }

                currentPage = 0;

                // إنشاء نافذة معاينة الطباعة
                PrintPreviewDialog previewDialog = new PrintPreviewDialog();
                previewDialog.Document = printDoc;
                previewDialog.WindowState = FormWindowState.Maximized; // فتح المعاينة بكامل الشاشة

                previewDialog.ShowDialog(); // عرض المعاينة
            }
            catch (Exception ex)
            {
                MessageBox.Show("حدث خطأ أثناء الطباعة: " + ex.Message);
            }
        }
    }
}
