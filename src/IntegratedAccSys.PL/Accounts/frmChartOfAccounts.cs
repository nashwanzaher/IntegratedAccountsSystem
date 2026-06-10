using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using IntegratedAccSys.PL.Security;

namespace IntegratedAccSys.PL.Accounts
{
    public partial class frmChartOfAccounts : Form
    {
        BL.Accounts.ClsAccounts ca = new BL.Accounts.ClsAccounts();
        public frmChartOfAccounts()
        {
            InitializeComponent();
            createNode();
            getData();
        }

        void getData()
        {
            cbAccTypes.DataSource = ca.getAllAccTypes();
            cbAccTypes.ValueMember = "ID";
            cbAccTypes.DisplayMember = "accType";

            cbAccReport.DataSource = ca.getAllReportTypes();
            cbAccReport.ValueMember = "ID";
            cbAccReport.DisplayMember = "accReport";
        }

        private void createNode()
        {
            tvAccounts.Nodes.Clear();
            TreeNode rootNode = new TreeNode("الدليل المحاسبي");
            rootNode.Tag = "0";
            tvAccounts.Nodes.Add(rootNode);

            DataTable dt = new DataTable();
            dt.Clear();
            dt = ca.getListOfAccounts(Program.braCode);
            DataView dv = new DataView(dt);
            dv.RowFilter = "accParentCode=0";
            foreach (DataRowView drv in dv)
            {
                TreeNode node = new TreeNode(drv["accCode"].ToString() + "   " + drv["accName"].ToString());
                node.Tag = drv["accCode"].ToString();
                rootNode.Nodes.Add(node);
            }
            foreach (TreeNode cNode in rootNode.Nodes)
            {
                childNode(cNode);
            }
        }

        private void childNode(TreeNode bNode)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            dt = ca.getListOfAccounts(Program.braCode);
            DataView dv = new DataView(dt);
            dv.RowFilter = "accParentCode=" + Convert.ToInt32(bNode.Tag);
            foreach (DataRowView drv in dv)
            {
                TreeNode node = new TreeNode(drv["accCode"].ToString() + "  " + drv["accName"].ToString());
                node.Tag = drv["accCode"].ToString();
                bNode.Nodes.Add(node);
                childNode(node);
            }
        }

        private void btnPrint_Click(object sender, EventArgs e)
        {
            PL.Accounts.frmChartOfAccountsDoc cad = new frmChartOfAccountsDoc();
            cad.ShowDialog();

        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void searchTreeView(string searchText)
        {
            foreach (TreeNode node in tvAccounts.Nodes)
            {
                searchNode(node, searchText);
            }
        }

        private void searchNode(TreeNode parentNode, string searchText)
        {
            foreach (TreeNode node in parentNode.Nodes)
            {
                if (node.Text.Contains(searchText))
                {
                    tvAccounts.SelectedNode = node;
                    node.BackColor = Color.Yellow;
                    break;
                }
                searchNode(node, searchText);
            }
        }
        private void btnSearch_Click(object sender, EventArgs e)
        {
            searchTreeView(txtSearch.Text);
        }

        private void tvAccounts_AfterSelect(object sender, TreeViewEventArgs e)
        {
            txtTag.Text = tvAccounts.SelectedNode.Tag.ToString();
        }

        private void txtTag_TextChanged(object sender, EventArgs e)
        {
            DataTable dt = new DataTable();
            dt.Clear();
            dt = ca.getAccountData(Program.braCode, Convert.ToInt32(txtTag.Text));
            if (dt.Rows.Count > 0)
            {
                txtAccNo.Text = dt.Rows[0][0].ToString();
                txtAccParentNo.Text = dt.Rows[0][1].ToString();
                txtAccName.Text = dt.Rows[0][2].ToString();
                txtAccLevel.Text = dt.Rows[0][3].ToString();
                getData();
                cbAccTypes.SelectedValue = dt.Rows[0][4];
                cbAccReport.SelectedValue = dt.Rows[0][5];
                txtDebitor.Text = dt.Rows[0][6].ToString();
                txtCreditor.Text = dt.Rows[0][7].ToString();
                txtBalance.Text = dt.Rows[0][8].ToString();

            }
        }
        void resetData()
        {
            txtAccNo.Text = string.Empty;
            txtAccParentNo.Text = string.Empty;
            txtAccName.Text = string.Empty;
            txtAccLevel.Text = string.Empty;
            txtDebitor.Text = string.Empty;
            txtCreditor.Text = string.Empty;
            txtBalance.Text = string.Empty;
            cbAccTypes.Text = "إختار نوع الحساب";
            cbAccReport.Text = "إختار نوع التقرير";

        }
        private void btnNew_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtAccNo.Text))
            {
                MessageBox.Show("إختار الحساب الأب من شجرة الحسابات أولاً", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }
            int accParent = Convert.ToInt32(tvAccounts.SelectedNode.Tag);
            int acclevel = Convert.ToInt32(txtAccLevel.Text);

            DataTable dt = ca.getAccountsForAccParent(accParent, Program.braCode);

            if (dt.Rows.Count > 0)
            {
                DataTable dtmax = ca.getAccNoMax(accParent, Program.braCode);
                if (dtmax.Rows.Count > 0)
                {
                    txtAccNo.Text = (Convert.ToInt32(dtmax.Rows[0][0]) + 1).ToString();
                    txtAccParentNo.Text = (Convert.ToInt32(dtmax.Rows[0][2])).ToString();
                    cbAccReport.SelectedValue = dtmax.Rows[0][4];
                    cbAccTypes.SelectedValue = dtmax.Rows[0][3];
                    txtAccLevel.Text = (Convert.ToInt32(dtmax.Rows[0][5])).ToString();
                }
            }
            else
            {
                if (acclevel < 4)
                {
                    txtAccParentNo.Text = accParent.ToString();
                    txtAccNo.Text = (accParent * 10 + 1).ToString();
                    txtAccLevel.Text = (acclevel + 1).ToString();
                    cbAccTypes.SelectedValue = 1; // يمكن تخصيص هذا القيمة بناءً على احتياجاتك
                }
                else if (acclevel == 4)
                {
                    txtAccParentNo.Text = accParent.ToString();
                    txtAccNo.Text = (accParent * 100 + 1).ToString();
                    txtAccLevel.Text = (acclevel + 1).ToString();
                    cbAccTypes.SelectedValue = 1; // يمكن تخصيص هذا القيمة بناءً على احتياجاتك
                }
                else if (acclevel == 5)
                {
                    txtAccParentNo.Text = accParent.ToString();
                    txtAccNo.Text = (accParent * 1000 + 1).ToString();
                    txtAccLevel.Text = (acclevel + 1).ToString();
                    cbAccTypes.SelectedValue = 2; // يمكن تخصيص هذا القيمة بناءً على احتياجاتك
                }
                else
                {
                    MessageBox.Show("لا يمكنك إنشاء حساب في المستوى السابع", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                    return;
                }

            }
            txtAccName.Text = string.Empty;
            txtAccName.Focus();
            txtDebitor.Text = "0.00";
            txtCreditor.Text = "0.00";
            txtBalance.Text = "0.00";
            chkLock.Checked = false;
        }

        private void txtAccNo_Leave(object sender, EventArgs e)
        {
            try
            {
                DataTable dt = new DataTable();
                dt.Clear();
                dt = ca.getAccountData(Program.braCode, Convert.ToInt32(txtAccNo.Text));
                if (dt.Rows.Count > 0)
                {
                    MessageBox.Show("رقم الحساب الذي أدخلته موجود مسبقاً", "تكرار بيانات", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    txtAccNo.Text = string.Empty;
                    txtAccNo.Focus();

                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex.Message, "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnAdd_Click(object sender, EventArgs e)
        {
            try
            {
                int islock;
                if (chkLock.Checked == true)
                {
                    islock = 1;
                }
                else
                {
                    islock = 0;
                }
                ca.addAccount(Convert.ToInt32(txtAccNo.Text), Convert.ToInt32(txtAccParentNo.Text), txtAccName.Text, Convert.ToInt32(txtAccLevel.Text), Convert.ToInt32(cbAccTypes.SelectedValue), Convert.ToInt32(cbAccReport.SelectedValue), Convert.ToDouble(txtDebitor.Text), Convert.ToDouble(txtCreditor.Text), Convert.ToDouble(txtBalance.Text), islock, Program.braCode);
                MessageBox.Show("تمت عملية الإضافة بنجاح", "عملية إضافة", MessageBoxButtons.OK, MessageBoxIcon.Information);
                createNode();
                resetData();

            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }


        private void btnUpdate_Click(object sender, EventArgs e)
        {
            try
            {
                DataTable dt1 = new DataTable();
                dt1.Clear();
                dt1 = ca.verifyAccountFoundInJournalBady(Convert.ToInt32(txtAccNo.Text));
                if (dt1.Rows.Count > 0)
                {
                    MessageBox.Show("لا يمكن حذف أو تعديل الحساب ", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    return;
                }
                else
                {
                    DataTable dt2 = new DataTable();
                    dt2.Clear();
                    dt2 = ca.verifyAccountHaveChildren(Convert.ToInt32(txtAccNo.Text), Program.braCode);
                    if (dt2.Rows.Count > 0)
                    {
                        MessageBox.Show("لا يمكن حذف أو تعديل الحساب ", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        return;
                    }
                    else
                    {
                        int islock;
                        if (chkLock.Checked == true)
                        {
                            islock = 1;
                        }
                        else
                        {
                            islock = 0;
                        }
                        ca.updateAccount(Convert.ToInt32(txtAccNo.Text), Convert.ToInt32(txtAccParentNo.Text), txtAccName.Text, Convert.ToInt32(txtAccLevel.Text), Convert.ToInt32(cbAccTypes.SelectedValue), Convert.ToInt32(cbAccReport.SelectedValue), Convert.ToDouble(txtDebitor.Text), Convert.ToDouble(txtCreditor.Text), Convert.ToDouble(txtBalance.Text), islock, Program.braCode);
                        MessageBox.Show("تمت عملية التعديل بنجاح", "عملية تعديل", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        createNode();
                        resetData();

                    }
                }


            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnDelete_Click(object sender, EventArgs e)
        {
            try
            {
                DataTable dt1 = new DataTable();
                dt1.Clear();
                dt1 = ca.verifyAccountFoundInJournalBady(Convert.ToInt32(txtAccNo.Text));
                if (dt1.Rows.Count > 0)
                {
                    MessageBox.Show("لا يمكن حذف أو تعديل الحساب ", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    return;
                }
                else
                {
                    DataTable dt2 = new DataTable();
                    dt2.Clear();
                    dt2 = ca.verifyAccountHaveChildren(Convert.ToInt32(txtAccNo.Text), Program.braCode);
                    if (dt2.Rows.Count > 0)
                    {
                        MessageBox.Show("لا يمكن حذف أو تعديل الحساب ", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        return;
                    }
                    else
                    {
                        if (MessageBox.Show("هل أنت متأكد من انك تريد الحذف أم لا", "تبيه", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes)
                        {
                            ca.deleteAccount(Convert.ToInt32(txtAccNo.Text), Program.braCode);
                            MessageBox.Show("تمت عملية الحذف بنجاح", "عملية حذف", MessageBoxButtons.OK, MessageBoxIcon.Information);
                            createNode();
                            resetData();
                        }
                    }
                }



            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void txtAccNo_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsDigit(e.KeyChar) && e.KeyChar != (char)Keys.Back)
            {
                e.Handled = true;
            }
        }

        private void txtAccLevel_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsDigit(e.KeyChar) && e.KeyChar != (char)Keys.Back)
            {
                e.Handled = true;
            }
        }

        private void txtDebitor_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsDigit(e.KeyChar) && e.KeyChar != (char)Keys.Back && e.KeyChar != '.')
            {
                e.Handled = true;
            }

            if (e.KeyChar == '.' && (sender as TextBox).Text.Contains("."))
            {
                e.Handled = true;
            }
        }

        private void txtCreditor_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsDigit(e.KeyChar) && e.KeyChar != (char)Keys.Back && e.KeyChar != '.')
            {
                e.Handled = true;
            }

            if (e.KeyChar == '.' && (sender as TextBox).Text.Contains("."))
            {
                e.Handled = true;
            }
        }

        private void txtBalance_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsDigit(e.KeyChar) && e.KeyChar != (char)Keys.Back && e.KeyChar != '.')
            {
                e.Handled = true;
            }

            if (e.KeyChar == '.' && (sender as TextBox).Text.Contains("."))
            {
                e.Handled = true;
            }
        }

        private void frmChartOfAccounts_Load(object sender, EventArgs e)
        {
            BL.Users.ClsUsers cu = new BL.Users.ClsUsers();
            PrivilegeApplier.Apply(this, 14);
        }
    }
}
