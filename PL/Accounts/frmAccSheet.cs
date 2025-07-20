using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Runtime.InteropServices.JavaScript;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace IntegratedAccSys.PL.Accounts
{
    public partial class frmAccSheet : Form
    {
        BL.SysFormat.clsSysFormat csf = new BL.SysFormat.clsSysFormat();
        PL.Accounts.frmAccSheetReport asr = new frmAccSheetReport();
        BL.Accounts.clsAccounts ca=new BL.Accounts.clsAccounts();
        public frmAccSheet()
        {
            InitializeComponent();
        }
        void getAllCurencies()
        {
            cbCurrencies.DataSource = csf.getAllCurrencies();
            cbCurrencies.DisplayMember = "currName";
            cbCurrencies.ValueMember = "ID";
        }
        private void frmAccSheet_Load(object sender, EventArgs e)
        {
            dtpFromDate.Value = DateTime.Now;
            dtpToDate.Value = DateTime.Now;
            getAllCurencies();
        }

        private void cbCurrencies_SelectedIndexChanged(object sender, EventArgs e)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            dt = csf.getExchangeCurrency(cbCurrencies.Text);
            if (dt.Rows.Count > 0)
            {
                txtCurrVal.Text = dt.Rows[0][2].ToString();
            }
        }


        private void txtAccCode_KeyDown(object sender, KeyEventArgs e)
        {
            PL.Accounts.frmSelectAccount fsa = new Accounts.frmSelectAccount();
            if (e.KeyCode == Keys.Enter)
            {
                fsa.txtSearch.Text = txtAccCode.Text;
                fsa.ShowDialog();
                if (fsa.isOk == true)
                {
                    txtAccCode.Text = fsa.dgvData.CurrentRow.Cells[0].Value.ToString();
                    txtAccName.Text = fsa.dgvData.CurrentRow.Cells[1].Value.ToString();
                    btnDisplay.Focus();
                }
            }
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void btnDisplay_Click(object sender, EventArgs e)
        {
      
            string opTypes = "tblJournalHeader.opType=0";
            if (chkJournal.Checked == false && chkRecieveBond.Checked == false && chkPayBond.Checked == false)
            {
                MessageBox.Show("يجب إختيار عملية واحدة على الأقل", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }


            if (chkJournal.Checked == true)
            {
                opTypes = opTypes + "" + "or tblJournalHeader.opType=1";
            }

            if (chkPayBond.Checked == true)
            {
                opTypes = opTypes + "" + "or tblJournalHeader.opType=2";
            }

            if (chkRecieveBond.Checked == true)
            {
                opTypes = opTypes + "" + "or tblJournalHeader.opType=3";
            }
            
            if (chkSells.Checked == true)
            {
                opTypes = opTypes + "" + "or tblJournalHeader.opType=4";
            }

            if (chkBurchases.Checked == true)
            {
                opTypes = opTypes + "" + "or tblJournalHeader.opType=5";
            }

            if (chkImport.Checked == true)
            {
                opTypes = opTypes + "" + "or tblJournalHeader.opType=6";
            }

            if (chkExport.Checked == true)
            {
                opTypes = opTypes + "" + "or tblJournalHeader.opType=7";
            }


            if (txtAccCode.Text == "")
            {
                MessageBox.Show("يجب إدخال رقم الحساب المطلوب", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
            else
            {
              
                DataTable dt = new DataTable();
                dt.Clear();

                // بناء سلسلة العمليات المحددة
                //"1,2,3,"
                string opType = string.Empty;
                if (chkJournal.Checked) opType += "1,";
                if (chkPayBond.Checked) opType += "2,";
                if (chkRecieveBond.Checked) opType += "3,";
                if (chkSells.Checked) opType += "4,";
                if (chkBurchases.Checked) opType += "5,";
                if (chkImport.Checked) opType += "6,";
                if (chkExport.Checked) opType += "7,";
                
                if (opType.EndsWith(",")) opType = opType.TrimEnd(',');
                
                Properties.Settings.Default.opTypeSelection= opType;
                Properties.Settings.Default.Save();
               // تحديد الفترة الزمنية
               DateTime fromDate = dtpFromDate.Value.Date;
                DateTime toDate = dtpToDate.Value.Date;

                decimal exchangeRate = Convert.ToDecimal(txtCurrVal.Text);
                // استدعاء الدالة في BL للحصول على البيانات
                dt = ca.getAccountSheetReport(Convert.ToInt32(txtAccCode.Text), fromDate, toDate, exchangeRate, opType);

                if (dt.Rows.Count > 0)
                {
                    asr.dtpFromDate.Value = dtpFromDate.Value;
                    asr.dtpToDate.Value = dtpToDate.Value;
                    asr.cbCurrencies.Text = cbCurrencies.Text;
                    asr.txtCurrVal.Text = txtCurrVal.Text;
                    asr.txtAccCode.Text = txtAccCode.Text;
                    asr.txtAccName.Text = txtAccName.Text;
                    asr.dgvData.DataSource = dt;

                   
                    var (totalDebitor, totalCreditor) = ca.calculateTotals(dt);
                    asr.txtDebitor.Text = totalDebitor.ToString();
                    asr.txtCreditor.Text = totalCreditor.ToString();
                    double accBalance = Convert.ToDouble(asr.txtDebitor.Text) - Convert.ToDouble(asr.txtCreditor.Text);
                    asr.txtBalance.Text = accBalance.ToString();
                    asr.ShowDialog();
                }
                else
                {
                    MessageBox.Show("لا توجد حركة ضمن الفترة الزمنية المحدد لهذا الحساب", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
            }
        }
    }}
