namespace IntegratedAccSys.PL
{
    partial class frmMainWindow
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmMainWindow));
            pictureBox = new PictureBox();
            menuStrip = new MenuStrip();
            FileMenu = new ToolStripMenuItem();
            UserSwitch = new ToolStripMenuItem();
            BackupSettings = new ToolStripMenuItem();
            Backup = new ToolStripMenuItem();
            BackRestore = new ToolStripMenuItem();
            ConnSettings = new ToolStripMenuItem();
            Users = new ToolStripMenuItem();
            tsmUsersPrivillages = new ToolStripMenuItem();
            tsmPosting = new ToolStripMenuItem();
            tsmJournalPosting = new ToolStripMenuItem();
            tsmJournalUnposting = new ToolStripMenuItem();
            Exit = new ToolStripMenuItem();
            SettingsMenue = new ToolStripMenuItem();
            Campanies = new ToolStripMenuItem();
            Funds = new ToolStripMenuItem();
            Banks = new ToolStripMenuItem();
            Currencies = new ToolStripMenuItem();
            btnVat = new ToolStripMenuItem();
            btnAccountsJoin = new ToolStripMenuItem();
            AccountsMenu = new ToolStripMenuItem();
            ChartOfAccount = new ToolStripMenuItem();
            Journal = new ToolStripMenuItem();
            Leader = new ToolStripMenuItem();
            bondRecieve = new ToolStripMenuItem();
            bondPay = new ToolStripMenuItem();
            toolStripSeparator1 = new ToolStripSeparator();
            AccountSheet = new ToolStripMenuItem();
            TrailBalance = new ToolStripMenuItem();
            BalanceSheet = new ToolStripMenuItem();
            ProfitAndLosses = new ToolStripMenuItem();
            StoresMenu = new ToolStripMenuItem();
            Stores = new ToolStripMenuItem();
            Cataegories = new ToolStripMenuItem();
            Units = new ToolStripMenuItem();
            Products = new ToolStripMenuItem();
            btnPrice = new ToolStripMenuItem();
            toolStripSeparator2 = new ToolStripSeparator();
            ptnImport = new ToolStripMenuItem();
            ptnExport = new ToolStripMenuItem();
            toolStripSeparator3 = new ToolStripSeparator();
            Inventory = new ToolStripMenuItem();
            ItemsMovement = new ToolStripMenuItem();
            PurchasesMenu = new ToolStripMenuItem();
            Suppliers = new ToolStripMenuItem();
            PurchasesInvoice = new ToolStripMenuItem();
            tsmPurReturnBill = new ToolStripMenuItem();
            SaleMenu = new ToolStripMenuItem();
            Customers = new ToolStripMenuItem();
            Representative = new ToolStripMenuItem();
            SalessInvoice = new ToolStripMenuItem();
            tsmSaleReturnBill = new ToolStripMenuItem();
            HelpMenu = new ToolStripMenuItem();
            About = new ToolStripMenuItem();
            statusStrip = new StatusStrip();
            lbl1 = new ToolStripStatusLabel();
            lblCurrentUser = new ToolStripStatusLabel();
            lbl2 = new ToolStripStatusLabel();
            lblInsertDate = new ToolStripStatusLabel();
            lbl3 = new ToolStripStatusLabel();
            lblCurrBranch = new ToolStripStatusLabel();
            ((System.ComponentModel.ISupportInitialize)pictureBox).BeginInit();
            menuStrip.SuspendLayout();
            statusStrip.SuspendLayout();
            SuspendLayout();
            // 
            // pictureBox
            // 
            pictureBox.Dock = DockStyle.Fill;
            pictureBox.Image = (Image)resources.GetObject("pictureBox.Image");
            pictureBox.Location = new Point(0, 58);
            pictureBox.Name = "pictureBox";
            pictureBox.Size = new Size(1341, 552);
            pictureBox.SizeMode = PictureBoxSizeMode.StretchImage;
            pictureBox.TabIndex = 1;
            pictureBox.TabStop = false;
            // 
            // menuStrip
            // 
            menuStrip.ImageScalingSize = new Size(20, 20);
            menuStrip.Items.AddRange(new ToolStripItem[] { FileMenu, SettingsMenue, AccountsMenu, StoresMenu, PurchasesMenu, SaleMenu, HelpMenu });
            menuStrip.Location = new Point(0, 0);
            menuStrip.Name = "menuStrip";
            menuStrip.Size = new Size(1341, 58);
            menuStrip.TabIndex = 0;
            menuStrip.Text = "menuStrip1";
            // 
            // FileMenu
            // 
            FileMenu.DropDownItems.AddRange(new ToolStripItem[] { UserSwitch, BackupSettings, ConnSettings, Users, tsmUsersPrivillages, tsmPosting, Exit });
            FileMenu.Font = new Font("Tahoma", 10.2F, FontStyle.Bold);
            FileMenu.Image = (Image)resources.GetObject("FileMenu.Image");
            FileMenu.ImageScaling = ToolStripItemImageScaling.None;
            FileMenu.Name = "FileMenu";
            FileMenu.Size = new Size(107, 54);
            FileMenu.Text = "ملف";
            // 
            // UserSwitch
            // 
            UserSwitch.Image = (Image)resources.GetObject("UserSwitch.Image");
            UserSwitch.ImageScaling = ToolStripItemImageScaling.None;
            UserSwitch.Name = "UserSwitch";
            UserSwitch.Size = new Size(283, 38);
            UserSwitch.Text = "تبديل المستخدم";
            UserSwitch.Click += UserSwitch_Click;
            // 
            // BackupSettings
            // 
            BackupSettings.DropDownItems.AddRange(new ToolStripItem[] { Backup, BackRestore });
            BackupSettings.Image = (Image)resources.GetObject("BackupSettings.Image");
            BackupSettings.ImageScaling = ToolStripItemImageScaling.None;
            BackupSettings.Name = "BackupSettings";
            BackupSettings.Size = new Size(283, 38);
            BackupSettings.Text = "النسخ الإحتياطي";
            // 
            // Backup
            // 
            Backup.Image = (Image)resources.GetObject("Backup.Image");
            Backup.ImageScaling = ToolStripItemImageScaling.None;
            Backup.Name = "Backup";
            Backup.Size = new Size(330, 38);
            Backup.Text = "عمل نسخة إحتياطية";
            Backup.Click += Backup_Click;
            // 
            // BackRestore
            // 
            BackRestore.Image = (Image)resources.GetObject("BackRestore.Image");
            BackRestore.ImageScaling = ToolStripItemImageScaling.None;
            BackRestore.Name = "BackRestore";
            BackRestore.Size = new Size(330, 38);
            BackRestore.Text = "إسترجاع النسخة الإحتياطية";
            BackRestore.Click += BackRestore_Click;
            // 
            // ConnSettings
            // 
            ConnSettings.Image = (Image)resources.GetObject("ConnSettings.Image");
            ConnSettings.ImageScaling = ToolStripItemImageScaling.None;
            ConnSettings.Name = "ConnSettings";
            ConnSettings.Size = new Size(283, 38);
            ConnSettings.Text = "إعداد الإتصال";
            ConnSettings.Click += ConnSettings_Click;
            // 
            // Users
            // 
            Users.Image = (Image)resources.GetObject("Users.Image");
            Users.ImageScaling = ToolStripItemImageScaling.None;
            Users.Name = "Users";
            Users.Size = new Size(283, 38);
            Users.Text = "المستخدمين";
            Users.Click += Users_Click;
            // 
            // tsmUsersPrivillages
            // 
            tsmUsersPrivillages.Image = (Image)resources.GetObject("tsmUsersPrivillages.Image");
            tsmUsersPrivillages.ImageScaling = ToolStripItemImageScaling.None;
            tsmUsersPrivillages.Name = "tsmUsersPrivillages";
            tsmUsersPrivillages.Size = new Size(283, 38);
            tsmUsersPrivillages.Text = "صلاحيات المستخدمين";
            tsmUsersPrivillages.Click += tsmUsersPrivillages_Click;
            // 
            // tsmPosting
            // 
            tsmPosting.DropDownItems.AddRange(new ToolStripItem[] { tsmJournalPosting, tsmJournalUnposting });
            tsmPosting.Font = new Font("Tahoma", 10F, FontStyle.Bold);
            tsmPosting.Image = (Image)resources.GetObject("tsmPosting.Image");
            tsmPosting.ImageScaling = ToolStripItemImageScaling.None;
            tsmPosting.Name = "tsmPosting";
            tsmPosting.Size = new Size(283, 38);
            tsmPosting.Text = "الترحيل";
            // 
            // tsmJournalPosting
            // 
            tsmJournalPosting.Font = new Font("Tahoma", 10F, FontStyle.Bold);
            tsmJournalPosting.Image = (Image)resources.GetObject("tsmJournalPosting.Image");
            tsmJournalPosting.ImageScaling = ToolStripItemImageScaling.None;
            tsmJournalPosting.Name = "tsmJournalPosting";
            tsmJournalPosting.Size = new Size(295, 38);
            tsmJournalPosting.Text = "ترحيل قيود اليومية";
            tsmJournalPosting.Click += tsmJournalPosting_Click;
            // 
            // tsmJournalUnposting
            // 
            tsmJournalUnposting.Font = new Font("Tahoma", 10F, FontStyle.Bold);
            tsmJournalUnposting.Image = (Image)resources.GetObject("tsmJournalUnposting.Image");
            tsmJournalUnposting.ImageScaling = ToolStripItemImageScaling.None;
            tsmJournalUnposting.Name = "tsmJournalUnposting";
            tsmJournalUnposting.Size = new Size(295, 38);
            tsmJournalUnposting.Text = "إلغاء ترحيل قيود اليومية";
            tsmJournalUnposting.Click += tsmJournalUnposting_Click;
            // 
            // Exit
            // 
            Exit.Image = (Image)resources.GetObject("Exit.Image");
            Exit.ImageScaling = ToolStripItemImageScaling.None;
            Exit.Name = "Exit";
            Exit.Size = new Size(283, 38);
            Exit.Text = "خروج";
            Exit.Click += Exit_Click;
            // 
            // SettingsMenue
            // 
            SettingsMenue.DropDownItems.AddRange(new ToolStripItem[] { Campanies, Funds, Banks, Currencies, btnVat, btnAccountsJoin });
            SettingsMenue.Font = new Font("Tahoma", 10.2F, FontStyle.Bold);
            SettingsMenue.Image = (Image)resources.GetObject("SettingsMenue.Image");
            SettingsMenue.ImageScaling = ToolStripItemImageScaling.None;
            SettingsMenue.Name = "SettingsMenue";
            SettingsMenue.Size = new Size(192, 54);
            SettingsMenue.Text = "إعدادات النظام";
            // 
            // Campanies
            // 
            Campanies.Image = (Image)resources.GetObject("Campanies.Image");
            Campanies.ImageScaling = ToolStripItemImageScaling.None;
            Campanies.Name = "Campanies";
            Campanies.Size = new Size(280, 38);
            Campanies.Text = "بيانات الشركة";
            Campanies.Click += Campanies_Click;
            // 
            // Funds
            // 
            Funds.Image = (Image)resources.GetObject("Funds.Image");
            Funds.ImageScaling = ToolStripItemImageScaling.None;
            Funds.Name = "Funds";
            Funds.Size = new Size(280, 38);
            Funds.Text = "الصناديق";
            Funds.Click += Funds_Click;
            // 
            // Banks
            // 
            Banks.Image = (Image)resources.GetObject("Banks.Image");
            Banks.ImageScaling = ToolStripItemImageScaling.None;
            Banks.Name = "Banks";
            Banks.Size = new Size(280, 38);
            Banks.Text = "البنوك";
            Banks.Click += Banks_Click;
            // 
            // Currencies
            // 
            Currencies.Image = (Image)resources.GetObject("Currencies.Image");
            Currencies.ImageScaling = ToolStripItemImageScaling.None;
            Currencies.Name = "Currencies";
            Currencies.Size = new Size(280, 38);
            Currencies.Text = "العملات";
            Currencies.Click += Currencies_Click;
            // 
            // btnVat
            // 
            btnVat.Image = (Image)resources.GetObject("btnVat.Image");
            btnVat.ImageScaling = ToolStripItemImageScaling.None;
            btnVat.Name = "btnVat";
            btnVat.Size = new Size(280, 38);
            btnVat.Text = "ضريبة القيمة المضافة";
            btnVat.Click += btnVat_Click;
            // 
            // btnAccountsJoin
            // 
            btnAccountsJoin.Image = (Image)resources.GetObject("btnAccountsJoin.Image");
            btnAccountsJoin.ImageScaling = ToolStripItemImageScaling.None;
            btnAccountsJoin.Name = "btnAccountsJoin";
            btnAccountsJoin.Size = new Size(280, 38);
            btnAccountsJoin.Text = "ربط الحسابات";
            btnAccountsJoin.Click += btnAccountsJoin_Click;
            // 
            // AccountsMenu
            // 
            AccountsMenu.DropDownItems.AddRange(new ToolStripItem[] { ChartOfAccount, Journal, Leader, toolStripSeparator1, AccountSheet, TrailBalance, BalanceSheet, ProfitAndLosses });
            AccountsMenu.Font = new Font("Tahoma", 10.2F, FontStyle.Bold);
            AccountsMenu.Image = (Image)resources.GetObject("AccountsMenu.Image");
            AccountsMenu.ImageScaling = ToolStripItemImageScaling.None;
            AccountsMenu.Name = "AccountsMenu";
            AccountsMenu.Size = new Size(149, 54);
            AccountsMenu.Text = "الحسابات";
            // 
            // ChartOfAccount
            // 
            ChartOfAccount.Image = (Image)resources.GetObject("ChartOfAccount.Image");
            ChartOfAccount.ImageScaling = ToolStripItemImageScaling.None;
            ChartOfAccount.Name = "ChartOfAccount";
            ChartOfAccount.Size = new Size(286, 38);
            ChartOfAccount.Text = "الدليل المحاسبي";
            ChartOfAccount.Click += ChartOfAccount_Click;
            // 
            // Journal
            // 
            Journal.Image = (Image)resources.GetObject("Journal.Image");
            Journal.ImageScaling = ToolStripItemImageScaling.None;
            Journal.Name = "Journal";
            Journal.Size = new Size(286, 38);
            Journal.Text = "دفتر اليومية العامة";
            Journal.Click += Journal_Click;
            // 
            // Leader
            // 
            Leader.DropDownItems.AddRange(new ToolStripItem[] { bondRecieve, bondPay });
            Leader.Image = (Image)resources.GetObject("Leader.Image");
            Leader.ImageScaling = ToolStripItemImageScaling.None;
            Leader.Name = "Leader";
            Leader.Size = new Size(286, 38);
            Leader.Text = "السندات";
            // 
            // bondRecieve
            // 
            bondRecieve.Image = (Image)resources.GetObject("bondRecieve.Image");
            bondRecieve.ImageScaling = ToolStripItemImageScaling.None;
            bondRecieve.Name = "bondRecieve";
            bondRecieve.Size = new Size(189, 38);
            bondRecieve.Text = "سند صرف";
            bondRecieve.Click += bondRecieve_Click;
            // 
            // bondPay
            // 
            bondPay.Image = (Image)resources.GetObject("bondPay.Image");
            bondPay.ImageScaling = ToolStripItemImageScaling.None;
            bondPay.Name = "bondPay";
            bondPay.Size = new Size(189, 38);
            bondPay.Text = "سند قبض";
            bondPay.Click += bondPay_Click;
            // 
            // toolStripSeparator1
            // 
            toolStripSeparator1.Name = "toolStripSeparator1";
            toolStripSeparator1.Size = new Size(283, 6);
            // 
            // AccountSheet
            // 
            AccountSheet.Image = (Image)resources.GetObject("AccountSheet.Image");
            AccountSheet.ImageScaling = ToolStripItemImageScaling.None;
            AccountSheet.Name = "AccountSheet";
            AccountSheet.Size = new Size(286, 38);
            AccountSheet.Text = "كشف حساب";
            AccountSheet.Click += AccountSheet_Click;
            // 
            // TrailBalance
            // 
            TrailBalance.Image = (Image)resources.GetObject("TrailBalance.Image");
            TrailBalance.ImageScaling = ToolStripItemImageScaling.None;
            TrailBalance.Name = "TrailBalance";
            TrailBalance.Size = new Size(286, 38);
            TrailBalance.Text = "ميزان المراجعة";
            TrailBalance.Click += TrailBalance_Click;
            // 
            // BalanceSheet
            // 
            BalanceSheet.Image = (Image)resources.GetObject("BalanceSheet.Image");
            BalanceSheet.ImageScaling = ToolStripItemImageScaling.None;
            BalanceSheet.Name = "BalanceSheet";
            BalanceSheet.Size = new Size(286, 38);
            BalanceSheet.Text = "الميزانية العمومية";
            BalanceSheet.Click += BalanceSheet_Click;
            // 
            // ProfitAndLosses
            // 
            ProfitAndLosses.Image = (Image)resources.GetObject("ProfitAndLosses.Image");
            ProfitAndLosses.ImageScaling = ToolStripItemImageScaling.None;
            ProfitAndLosses.Name = "ProfitAndLosses";
            ProfitAndLosses.Size = new Size(286, 38);
            ProfitAndLosses.Text = "قائمة الأرباح و الخسائر";
            ProfitAndLosses.Click += ProfitAndLosses_Click;
            // 
            // StoresMenu
            // 
            StoresMenu.DropDownItems.AddRange(new ToolStripItem[] { Stores, Cataegories, Units, Products, btnPrice, toolStripSeparator2, ptnImport, ptnExport, toolStripSeparator3, Inventory, ItemsMovement });
            StoresMenu.Font = new Font("Tahoma", 10.2F, FontStyle.Bold);
            StoresMenu.Image = (Image)resources.GetObject("StoresMenu.Image");
            StoresMenu.ImageScaling = ToolStripItemImageScaling.None;
            StoresMenu.Name = "StoresMenu";
            StoresMenu.Size = new Size(134, 54);
            StoresMenu.Text = "المخازن";
            // 
            // Stores
            // 
            Stores.Image = (Image)resources.GetObject("Stores.Image");
            Stores.ImageScaling = ToolStripItemImageScaling.None;
            Stores.Name = "Stores";
            Stores.Size = new Size(269, 38);
            Stores.Text = "المخازن";
            Stores.Click += Stores_Click;
            // 
            // Cataegories
            // 
            Cataegories.Image = (Image)resources.GetObject("Cataegories.Image");
            Cataegories.ImageScaling = ToolStripItemImageScaling.None;
            Cataegories.Name = "Cataegories";
            Cataegories.Size = new Size(269, 38);
            Cataegories.Text = "المجموعات المخزنية";
            Cataegories.Click += Cataegories_Click;
            // 
            // Units
            // 
            Units.Image = (Image)resources.GetObject("Units.Image");
            Units.ImageScaling = ToolStripItemImageScaling.None;
            Units.Name = "Units";
            Units.Size = new Size(269, 38);
            Units.Text = "الوحدات";
            Units.Click += Units_Click;
            // 
            // Products
            // 
            Products.Image = (Image)resources.GetObject("Products.Image");
            Products.ImageScaling = ToolStripItemImageScaling.None;
            Products.Name = "Products";
            Products.Size = new Size(269, 38);
            Products.Text = "الأصناف";
            Products.Click += Products_Click;
            // 
            // btnPrice
            // 
            btnPrice.Image = (Image)resources.GetObject("btnPrice.Image");
            btnPrice.ImageScaling = ToolStripItemImageScaling.None;
            btnPrice.Name = "btnPrice";
            btnPrice.Size = new Size(269, 38);
            btnPrice.Text = "تسعير الأصناف";
            // 
            // toolStripSeparator2
            // 
            toolStripSeparator2.Name = "toolStripSeparator2";
            toolStripSeparator2.Size = new Size(266, 6);
            // 
            // ptnImport
            // 
            ptnImport.Image = (Image)resources.GetObject("ptnImport.Image");
            ptnImport.ImageScaling = ToolStripItemImageScaling.None;
            ptnImport.Name = "ptnImport";
            ptnImport.Size = new Size(269, 38);
            ptnImport.Text = "سند توريد مخزني";
            ptnImport.Click += ptnImport_Click;
            // 
            // ptnExport
            // 
            ptnExport.Image = (Image)resources.GetObject("ptnExport.Image");
            ptnExport.ImageScaling = ToolStripItemImageScaling.None;
            ptnExport.Name = "ptnExport";
            ptnExport.Size = new Size(269, 38);
            ptnExport.Text = "سند صرف مخزني";
            ptnExport.Click += ptnExport_Click;
            // 
            // toolStripSeparator3
            // 
            toolStripSeparator3.Name = "toolStripSeparator3";
            toolStripSeparator3.Size = new Size(266, 6);
            // 
            // Inventory
            // 
            Inventory.Image = (Image)resources.GetObject("Inventory.Image");
            Inventory.ImageScaling = ToolStripItemImageScaling.None;
            Inventory.Name = "Inventory";
            Inventory.Size = new Size(269, 38);
            Inventory.Text = "جرد المخزون";
            Inventory.Click += Inventory_Click;
            // 
            // ItemsMovement
            // 
            ItemsMovement.Image = (Image)resources.GetObject("ItemsMovement.Image");
            ItemsMovement.ImageScaling = ToolStripItemImageScaling.None;
            ItemsMovement.Name = "ItemsMovement";
            ItemsMovement.Size = new Size(269, 38);
            ItemsMovement.Text = "حركة الأصناف";
            ItemsMovement.Click += ItemsMovement_Click;
            // 
            // PurchasesMenu
            // 
            PurchasesMenu.DropDownItems.AddRange(new ToolStripItem[] { Suppliers, PurchasesInvoice, tsmPurReturnBill });
            PurchasesMenu.Font = new Font("Tahoma", 10.2F, FontStyle.Bold);
            PurchasesMenu.Image = (Image)resources.GetObject("PurchasesMenu.Image");
            PurchasesMenu.ImageScaling = ToolStripItemImageScaling.None;
            PurchasesMenu.Name = "PurchasesMenu";
            PurchasesMenu.Size = new Size(157, 54);
            PurchasesMenu.Text = "المشتريات";
            // 
            // Suppliers
            // 
            Suppliers.Image = (Image)resources.GetObject("Suppliers.Image");
            Suppliers.ImageScaling = ToolStripItemImageScaling.None;
            Suppliers.Name = "Suppliers";
            Suppliers.Size = new Size(253, 38);
            Suppliers.Text = "الموردين";
            Suppliers.Click += Suppliers_Click;
            // 
            // PurchasesInvoice
            // 
            PurchasesInvoice.Image = (Image)resources.GetObject("PurchasesInvoice.Image");
            PurchasesInvoice.ImageScaling = ToolStripItemImageScaling.None;
            PurchasesInvoice.Name = "PurchasesInvoice";
            PurchasesInvoice.Size = new Size(253, 38);
            PurchasesInvoice.Text = "فاتورة المشتريات";
            PurchasesInvoice.Click += PurchasesInvoice_Click;
            // 
            // tsmPurReturnBill
            // 
            tsmPurReturnBill.Image = (Image)resources.GetObject("tsmPurReturnBill.Image");
            tsmPurReturnBill.ImageScaling = ToolStripItemImageScaling.None;
            tsmPurReturnBill.Name = "tsmPurReturnBill";
            tsmPurReturnBill.Size = new Size(253, 38);
            tsmPurReturnBill.Text = "فاتورة مرتجع شراء";
            tsmPurReturnBill.Click += tsmPurReturnBill_Click;
            // 
            // SaleMenu
            // 
            SaleMenu.DropDownItems.AddRange(new ToolStripItem[] { Customers, Representative, SalessInvoice, tsmSaleReturnBill });
            SaleMenu.Font = new Font("Tahoma", 10.2F, FontStyle.Bold);
            SaleMenu.Image = (Image)resources.GetObject("SaleMenu.Image");
            SaleMenu.ImageScaling = ToolStripItemImageScaling.None;
            SaleMenu.Name = "SaleMenu";
            SaleMenu.Size = new Size(140, 54);
            SaleMenu.Text = "المبيعات";
            // 
            // Customers
            // 
            Customers.Image = (Image)resources.GetObject("Customers.Image");
            Customers.ImageScaling = ToolStripItemImageScaling.None;
            Customers.Name = "Customers";
            Customers.Size = new Size(240, 38);
            Customers.Text = "العملاء";
            Customers.Click += Customers_Click;
            // 
            // Representative
            // 
            Representative.Image = (Image)resources.GetObject("Representative.Image");
            Representative.ImageScaling = ToolStripItemImageScaling.None;
            Representative.Name = "Representative";
            Representative.Size = new Size(240, 38);
            Representative.Text = "مندوبي المبيعات";
            // 
            // SalessInvoice
            // 
            SalessInvoice.Image = (Image)resources.GetObject("SalessInvoice.Image");
            SalessInvoice.ImageScaling = ToolStripItemImageScaling.None;
            SalessInvoice.Name = "SalessInvoice";
            SalessInvoice.Size = new Size(240, 38);
            SalessInvoice.Text = "فاتورة المبيعات";
            SalessInvoice.Click += SalessInvoice_Click;
            // 
            // tsmSaleReturnBill
            // 
            tsmSaleReturnBill.Image = (Image)resources.GetObject("tsmSaleReturnBill.Image");
            tsmSaleReturnBill.ImageScaling = ToolStripItemImageScaling.None;
            tsmSaleReturnBill.Name = "tsmSaleReturnBill";
            tsmSaleReturnBill.Size = new Size(240, 38);
            tsmSaleReturnBill.Text = "فاتورة مرتجع بيع";
            tsmSaleReturnBill.Click += tsmSaleReturnBill_Click;
            // 
            // HelpMenu
            // 
            HelpMenu.DropDownItems.AddRange(new ToolStripItem[] { About });
            HelpMenu.Font = new Font("Tahoma", 10.2F, FontStyle.Bold);
            HelpMenu.Image = (Image)resources.GetObject("HelpMenu.Image");
            HelpMenu.ImageScaling = ToolStripItemImageScaling.None;
            HelpMenu.Name = "HelpMenu";
            HelpMenu.Size = new Size(138, 54);
            HelpMenu.Text = "مساعدة";
            // 
            // About
            // 
            About.Image = (Image)resources.GetObject("About.Image");
            About.ImageScaling = ToolStripItemImageScaling.None;
            About.Name = "About";
            About.Size = new Size(168, 38);
            About.Text = "من نحن";
            // 
            // statusStrip
            // 
            statusStrip.ImageScalingSize = new Size(20, 20);
            statusStrip.Items.AddRange(new ToolStripItem[] { lbl1, lblCurrentUser, lbl2, lblInsertDate, lbl3, lblCurrBranch });
            statusStrip.Location = new Point(0, 583);
            statusStrip.Name = "statusStrip";
            statusStrip.Size = new Size(1341, 27);
            statusStrip.TabIndex = 3;
            statusStrip.Text = "statusStrip1";
            // 
            // lbl1
            // 
            lbl1.Font = new Font("Tahoma", 10.2F, FontStyle.Bold);
            lbl1.Name = "lbl1";
            lbl1.Size = new Size(153, 21);
            lbl1.Text = "المستخدم الحالي";
            // 
            // lblCurrentUser
            // 
            lblCurrentUser.Font = new Font("Tahoma", 10.2F, FontStyle.Bold);
            lblCurrentUser.ForeColor = Color.Red;
            lblCurrentUser.Name = "lblCurrentUser";
            lblCurrentUser.Size = new Size(15, 21);
            lblCurrentUser.Text = ".";
            // 
            // lbl2
            // 
            lbl2.Font = new Font("Tahoma", 10.2F, FontStyle.Bold);
            lbl2.Name = "lbl2";
            lbl2.Size = new Size(111, 21);
            lbl2.Text = "تاريخ الدخول";
            // 
            // lblInsertDate
            // 
            lblInsertDate.Font = new Font("Tahoma", 10.2F, FontStyle.Bold);
            lblInsertDate.ForeColor = Color.Red;
            lblInsertDate.Name = "lblInsertDate";
            lblInsertDate.Size = new Size(15, 21);
            lblInsertDate.Text = ".";
            // 
            // lbl3
            // 
            lbl3.Font = new Font("Tahoma", 10.2F, FontStyle.Bold);
            lbl3.Name = "lbl3";
            lbl3.Size = new Size(57, 21);
            lbl3.Text = "الفرع ";
            // 
            // lblCurrBranch
            // 
            lblCurrBranch.Font = new Font("Tahoma", 10.2F, FontStyle.Bold);
            lblCurrBranch.ForeColor = Color.Red;
            lblCurrBranch.Name = "lblCurrBranch";
            lblCurrBranch.Size = new Size(15, 21);
            lblCurrBranch.Text = ".";
            // 
            // frmMainWindow
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(1341, 610);
            Controls.Add(statusStrip);
            Controls.Add(pictureBox);
            Controls.Add(menuStrip);
            Icon = (Icon)resources.GetObject("$this.Icon");
            IsMdiContainer = true;
            MainMenuStrip = menuStrip;
            Name = "frmMainWindow";
            RightToLeft = RightToLeft.Yes;
            RightToLeftLayout = true;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "النطام المحاسبي المتكامل";
            WindowState = FormWindowState.Maximized;
            Load += frmMainWindow_Load;
            ((System.ComponentModel.ISupportInitialize)pictureBox).EndInit();
            menuStrip.ResumeLayout(false);
            menuStrip.PerformLayout();
            statusStrip.ResumeLayout(false);
            statusStrip.PerformLayout();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private PictureBox pictureBox;
        private MenuStrip menuStrip;
        private ToolStripMenuItem FileMenu;
        private ToolStripMenuItem SettingsMenue;
        private ToolStripMenuItem AccountsMenu;
        private ToolStripMenuItem StoresMenu;
        private ToolStripMenuItem PurchasesMenu;
        private ToolStripMenuItem SaleMenu;
        private ToolStripMenuItem HelpMenu;
        private ToolStripMenuItem UserSwitch;
        private ToolStripMenuItem BackupSettings;
        private ToolStripMenuItem Backup;
        private ToolStripMenuItem BackRestore;
        private ToolStripMenuItem Exit;
        private ToolStripMenuItem Campanies;
        private ToolStripMenuItem Funds;
        private ToolStripMenuItem Banks;
        private ToolStripMenuItem Currencies;
        private ToolStripMenuItem ChartOfAccount;
        private ToolStripMenuItem Journal;
        private ToolStripMenuItem Leader;
        private ToolStripMenuItem AccountSheet;
        private ToolStripMenuItem TrailBalance;
        private ToolStripMenuItem BalanceSheet;
        private ToolStripMenuItem ProfitAndLosses;
        private ToolStripMenuItem Stores;
        private ToolStripMenuItem Cataegories;
        private ToolStripMenuItem Units;
        private ToolStripMenuItem Products;
        private ToolStripMenuItem Inventory;
        private ToolStripMenuItem ItemsMovement;
        private ToolStripMenuItem Suppliers;
        private ToolStripMenuItem PurchasesInvoice;
        private ToolStripMenuItem Customers;
        private ToolStripMenuItem Representative;
        private ToolStripMenuItem SalessInvoice;
        private ToolStripMenuItem About;
        private ToolStripMenuItem Users;
        private ToolStripSeparator toolStripSeparator1;
        private StatusStrip statusStrip;
        private ToolStripStatusLabel lbl1;
        private ToolStripStatusLabel lblCurrentUser;
        private ToolStripStatusLabel lbl2;
        private ToolStripStatusLabel lblInsertDate;
        private ToolStripStatusLabel lbl3;
        private ToolStripStatusLabel lblCurrBranch;
        private ToolStripMenuItem ConnSettings;
        private ToolStripMenuItem bondRecieve;
        private ToolStripMenuItem bondPay;
        private ToolStripMenuItem btnVat;
        private ToolStripMenuItem btnPrice;
        private ToolStripSeparator toolStripSeparator2;
        private ToolStripMenuItem ptnImport;
        private ToolStripMenuItem ptnExport;
        private ToolStripSeparator toolStripSeparator3;
        private ToolStripMenuItem btnAccountsJoin;
        private ToolStripMenuItem tsmPosting;
        private ToolStripMenuItem tsmJournalPosting;
        private ToolStripMenuItem tsmJournalUnposting;
        private ToolStripMenuItem tsmPurReturnBill;
        private ToolStripMenuItem tsmSaleReturnBill;
        private ToolStripMenuItem tsmUsersPrivillages;
    }
}