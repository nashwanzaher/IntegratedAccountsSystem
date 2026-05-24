using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using IntegratedAccSys.BL.Security;

namespace IntegratedAccSys
{

    public partial class frmMainWindow : Form
    {
        BL.Users.clsUsers cu = new BL.Users.clsUsers();
        public Button btnNew = null!;
        public Button btnAdd = null!;
        public Button btnEdit = null!;
        public Button btnDel = null!;
        public Button btnPrint = null!;

        public frmMainWindow()
        {
            InitializeComponent();
        }




        void getScreensDisplayPrivs()
        {
            int userCode = Convert.ToInt32(cu.getUserNo(Program.userName).Rows[0][0]);
            int braCode = Program.braCode;
            DataTable dt = cu.getDisplayPrivillages(userCode, braCode);

            if (dt.Rows.Count > 0)
            {
                ToolStripMenuItem[] screens = new ToolStripMenuItem[]
                {
                    Backup,
                    BackRestore,
                    ConnSettings,
                    Users,
                    tsmUsersPrivillages,
                    tsmJournalPosting,
                    tsmJournalUnposting,
                    Campanies,
                    Funds,
                    Banks,
                    Currencies,
                    btnVat,
                    btnAccountsJoin,
                    ChartOfAccount,
                    Journal,
                    bondRecieve,
                    bondPay,
                    AccountSheet,
                    TrailBalance,
                    BalanceSheet,
                    ProfitAndLosses,
                    Stores,
                    Cataegories,
                    Units,
                    Products,
                    btnPrice,
                    ptnImport,
                    ptnExport,
                    Inventory,
                    ItemsMovement,
                    Suppliers,
                    PurchasesInvoice,
                    tsmPurReturnBill,
                    Customers,
                    Representative,
                    SalessInvoice,
                    tsmSaleReturnBill,
                    About
                };


                for (int i = 0; i < Math.Min(dt.Rows.Count, screens.Length); i++)
                {
                    bool isEnabled = dt.Rows[i][1] != DBNull.Value && Convert.ToInt32(dt.Rows[i][1]) == 1;

                    screens[i].Enabled = isEnabled;

                    if (!isEnabled)
                        MessageBox.Show($"العنصر المعطّل: {screens[i].Name}");

                }

            }

        }

        private void ConnSettings_Click(object sender, EventArgs e)
        {
            PL.SysFormat.frmConnSettings fcs = new PL.SysFormat.frmConnSettings();
            fcs.ShowDialog();
        }

        private void Exit_Click(object sender, EventArgs e)
        {
            // Phase 7: End the session on logout
            SessionContext.End();
            this.Close();
        }

        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            base.OnFormClosing(e);

            // Phase 7: End session on any form close (logout button, X button, Alt+F4)
            // Only end if the session is still active (not already ended by Exit_Click)
            if (SessionContext.IsActive)
            {
                SessionContext.End();
            }
        }

        private void frmMainWindow_Load(object sender, EventArgs e)
        {
            // Phase 7: Validate session — block access if session is invalid or expired
            if (!SessionContext.Validate())
            {
                MessageBox.Show("انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.", "انتهاء الجلسة", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                SessionContext.End();
                Application.Restart();
                return;
            }

            lblCurrentUser.Text = Program.userName;
            lblInsertDate.Text = DateTime.Now.ToString();
            lblCurrBranch.Text = Program.braCode.ToString();
            getScreensDisplayPrivs();
        }

        private void Campanies_Click(object sender, EventArgs e)
        {
            PL.SysFormat.frmCompanies fc = new PL.SysFormat.frmCompanies();
            fc.ShowDialog();
        }

        private void Users_Click(object sender, EventArgs e)
        {
            PL.Users.frmUsers fu = new PL.Users.frmUsers();
            fu.ShowDialog();
        }

        private void ChartOfAccount_Click(object sender, EventArgs e)
        {
            PL.Accounts.frmChartOfAccounts fca = new PL.Accounts.frmChartOfAccounts();
            fca.ShowDialog();
        }

        private void Funds_Click(object sender, EventArgs e)
        {
            PL.SysFormat.frmFunds ff = new PL.SysFormat.frmFunds();
            ff.ShowDialog();
        }

        private void Banks_Click(object sender, EventArgs e)
        {
            PL.SysFormat.frmBanks fb = new PL.SysFormat.frmBanks();
            fb.ShowDialog();
        }

        private void Currencies_Click(object sender, EventArgs e)
        {
            PL.SysFormat.frmCurrencies fc = new PL.SysFormat.frmCurrencies();
            fc.ShowDialog();
        }

        private void Journal_Click(object sender, EventArgs e)
        {
            PL.Journal.frmJournal fj = new PL.Journal.frmJournal();
            fj.ShowDialog();
        }

        private void bondRecieve_Click(object sender, EventArgs e)
        {
            PL.Bonds.frmBonds fb = new PL.Bonds.frmBonds();
            fb.Text = "سند صرف";
            fb.txtBType.Text = "2";
            fb.ShowDialog();
        }

        private void bondPay_Click(object sender, EventArgs e)
        {
            PL.Bonds.frmBonds fb = new PL.Bonds.frmBonds();
            fb.Text = "سند قبض";
            fb.txtBType.Text = "3";
            fb.ShowDialog();
        }

        private void AccountSheet_Click(object sender, EventArgs e)
        {
            PL.Accounts.frmAccSheet fas = new PL.Accounts.frmAccSheet();
            fas.ShowDialog();
        }

        private void TrailBalance_Click(object sender, EventArgs e)
        {
            PL.Accounts.frmTrailBalance ftb = new PL.Accounts.frmTrailBalance();
            ftb.ShowDialog();
        }

        private void BalanceSheet_Click(object sender, EventArgs e)
        {
            PL.Accounts.frmFinalAccounts ffa = new PL.Accounts.frmFinalAccounts();
            ffa.Text = "قائمة الميزانية العمومية";
            ffa.txtReportType.Text = "1";
            ffa.ShowDialog();

        }

        private void ProfitAndLosses_Click(object sender, EventArgs e)
        {
            PL.Accounts.frmFinalAccounts ffa = new PL.Accounts.frmFinalAccounts();
            ffa.Text = "قائمة الأرباح و الخسائر";
            ffa.txtReportType.Text = "2";
            ffa.ShowDialog();

        }

        private void Backup_Click(object sender, EventArgs e)
        {
            PL.SysFormat.frmBackUps fbu = new PL.SysFormat.frmBackUps();
            fbu.btnBackUp.Visible = true;
            fbu.btnRestoreDB.Visible = false;
            fbu.txtBackType.Text = "1";
            fbu.Text = "عمل نسخة إحتياطية";
            fbu.ShowDialog();

        }

        private void BackRestore_Click(object sender, EventArgs e)
        {
            PL.SysFormat.frmBackUps fbu = new PL.SysFormat.frmBackUps();
            fbu.btnBackUp.Visible = false;
            fbu.btnRestoreDB.Visible = true;
            fbu.txtBackType.Text = "2";
            fbu.Text = "إسترجاع النسخة الإحتياطية";
            fbu.ShowDialog();
        }

        private void Stores_Click(object sender, EventArgs e)
        {
            PL.stores.frmStores fs = new PL.stores.frmStores();
            fs.ShowDialog();
        }

        private void Cataegories_Click(object sender, EventArgs e)
        {
            PL.stores.frmCategories fc = new PL.stores.frmCategories();
            fc.ShowDialog();
        }

        private void Units_Click(object sender, EventArgs e)
        {
            PL.stores.frmUnits fu = new PL.stores.frmUnits();
            fu.ShowDialog();
        }

        private void Products_Click(object sender, EventArgs e)
        {
            PL.stores.frmProducts fp = new PL.stores.frmProducts();
            fp.ShowDialog();
        }

        private void Suppliers_Click(object sender, EventArgs e)
        {
            PL.Purchases.frmSuppleirs fs = new PL.Purchases.frmSuppleirs();
            fs.ShowDialog();
        }

        private void PurchasesInvoice_Click(object sender, EventArgs e)
        {
            PL.Purchases.frmPurchasesBill fpb = new PL.Purchases.frmPurchasesBill();
            fpb.txtOpType.Text = "5";
            fpb.ShowDialog();
        }

        private void SalessInvoice_Click(object sender, EventArgs e)
        {
            PL.Sales.frmSalesBill fsb = new PL.Sales.frmSalesBill();
            fsb.txtOpType.Text = "4";
            fsb.ShowDialog();
        }

        private void btnVat_Click(object sender, EventArgs e)
        {
            PL.SysFormat.frmVATSettings fvs = new PL.SysFormat.frmVATSettings();
            fvs.ShowDialog();
        }

        private void ptnImport_Click(object sender, EventArgs e)
        {
            PL.Purchases.frmPurchasesBill fpb = new PL.Purchases.frmPurchasesBill();
            fpb.txtOpType.Text = "6";
            fpb.Text = "سند توريد مخزني";
            fpb.ShowDialog();
        }

        private void ptnExport_Click(object sender, EventArgs e)
        {
            PL.Sales.frmSalesBill fsb = new PL.Sales.frmSalesBill();
            fsb.txtOpType.Text = "7";
            fsb.Text = "سند صرف مخزني";
            fsb.ShowDialog();
        }

        private void btnAccountsJoin_Click(object sender, EventArgs e)
        {
            PL.SysFormat.frmAccountsJoin faj = new PL.SysFormat.frmAccountsJoin();
            faj.ShowDialog();
        }

        private void Customers_Click(object sender, EventArgs e)
        {
            PL.Sales.frmCustomers fc = new PL.Sales.frmCustomers();
            fc.ShowDialog();
        }

        private void Inventory_Click(object sender, EventArgs e)
        {
            PL.stores.frmInvventroy fv = new PL.stores.frmInvventroy();
            fv.ShowDialog();
        }

        private void ItemsMovement_Click(object sender, EventArgs e)
        {
            PL.stores.frmInventoryMovement fim = new PL.stores.frmInventoryMovement();
            fim.ShowDialog();
        }

        private void tsmJournalPosting_Click(object sender, EventArgs e)
        {
            PL.Journal.frmPostingUnPosting fjp = new PL.Journal.frmPostingUnPosting();
            fjp.Text = "ترحيل الحسابات";
            fjp.txtPostStatus.Text = "1";
            fjp.btnPosing.Visible = true;
            fjp.ShowDialog();
        }

        private void tsmJournalUnposting_Click(object sender, EventArgs e)
        {
            PL.Journal.frmPostingUnPosting fjp = new PL.Journal.frmPostingUnPosting();
            fjp.Text = "إلغاء ترحيل الحسابات";
            fjp.txtPostStatus.Text = "2";
            fjp.btnPosing.Visible = true;
            fjp.ShowDialog();
        }

        private void tsmPurReturnBill_Click(object sender, EventArgs e)
        {
            PL.Purchases.frmPurReturnBill prb = new PL.Purchases.frmPurReturnBill();
            prb.ShowDialog();
        }

        private void tsmSaleReturnBill_Click(object sender, EventArgs e)
        {
            PL.Sales.frmSaleReturnBill srb = new PL.Sales.frmSaleReturnBill();
            srb.ShowDialog();
        }

        private void tsmUsersPrivillages_Click(object sender, EventArgs e)
        {
            PL.Users.frmPrivillages fp = new PL.Users.frmPrivillages();
            fp.ShowDialog();
        }

        private void UserSwitch_Click(object sender, EventArgs e)
        {
            Application.Restart();
        }
    }
}
