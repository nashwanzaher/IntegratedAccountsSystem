using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace IntegratedAccSys.PL.Journal
{
    public partial class frmPostingUnPosting : Form
    {


        BL.Journal.ClsJournal cj = new BL.Journal.ClsJournal();
        BL.Users.ClsUsers cu = new BL.Users.ClsUsers();

        DataTable? dt;
        public string userName = Program.userName;
        public Boolean IsHeaderCheckBoxClicked = true;

        int opType = 0;


        // ADD HEADER CHECH BOX
        CheckBox HeaderCheckBox = null;
        public frmPostingUnPosting()
        {
            InitializeComponent();
            dgvProperties();
            dgvData.Columns[0].Width = 40;
            dgvData.Columns[1].Width = 120;
            dgvData.Columns[2].Width = 120;
            dgvData.Columns[3].Width = 220;
            dgvData.Columns[4].Width = 400;
        }

        // يقوم بتنسيق DataGridView
        void dgvProperties()
        {
            // تنسيق رؤوس الأعمدة
            dgvData.ColumnHeadersDefaultCellStyle.ForeColor = Color.Red;
            dgvData.ColumnHeadersDefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter;
            dgvData.ColumnHeadersDefaultCellStyle.Font = new Font("Times New Roman", 10.75F, FontStyle.Bold);

            // تنسيق الصفوف المتبادلة
            dgvData.AlternatingRowsDefaultCellStyle.ForeColor = Color.Red;
            dgvData.AlternatingRowsDefaultCellStyle.BackColor = Color.SkyBlue;
            dgvData.AlternatingRowsDefaultCellStyle.Font = new Font("Times New Roman", 10.75F, FontStyle.Bold);

            // تنسيق خلايا البيانات
            dgvData.DefaultCellStyle.BackColor = Color.White;
            dgvData.DefaultCellStyle.ForeColor = Color.Blue;
            dgvData.DefaultCellStyle.Font = new Font("Times New Roman", 10.75F, FontStyle.Bold);
        }

        void getOpType()
        {
            if (rbJurnalEntry.Checked) opType = 1;
            if (rbMoneyPayBond.Checked) opType = 2;
            if (rbMoneyRecieveBond.Checked) opType = 3;
            if (rbSaleBill.Checked) opType = 4;
            if (rbPurBill.Checked) opType = 5;
            if (rbPurReturnBill.Checked) opType = 8;
            if (rbSaleReturnBill.Checked) opType = 7;


        }
        private bool IsAnyRadioButtonChecked()
        {
            // Array of radio buttons
            RadioButton[] radioButtons = {
            rbJurnalEntry, rbMoneyPayBond, rbMoneyRecieveBond, rbSaleBill,  rbPurBill
            };

            // Check if any radio button is checked
            foreach (RadioButton rb in radioButtons)
            {
                if (rb.Checked)
                {
                    return true; // At least one radio button is checked
                }
            }
            return false; // No radio buttons are checked
        }

        private void AddHeaderCheckBox()
        {

            Rectangle rectangle = dgvData.GetCellDisplayRectangle(0, -1, true);
            rectangle.Y = 3;
            rectangle.X = rectangle.Location.X + (rectangle.Width / 4);
            HeaderCheckBox = new CheckBox();
            HeaderCheckBox.Name = "CHK";
            HeaderCheckBox.BackColor = Color.Transparent;
            HeaderCheckBox.ForeColor = Color.Red;
            HeaderCheckBox.Size = new Size(18, 18);
            HeaderCheckBox.Location = rectangle.Location;
            HeaderCheckBox.CheckAlign = ContentAlignment.MiddleRight;

            // ADD THE CHECKBOX  INTO TH E DATAGRIDVIEW
            this.dgvData.Controls.Add(HeaderCheckBox);

        }

        //HEADER CHECHBOX EVENT CLICK
        private void HeaderCheckBoxClick(CheckBox HCheckBox)
        {

            IsHeaderCheckBoxClicked = true;
            foreach (DataGridViewRow Row in dgvData.Rows)
            {
                ((DataGridViewCheckBoxCell)Row.Cells[0]).Value = HCheckBox.Checked;
            }
            dgvData.RefreshEdit();

            IsHeaderCheckBoxClicked = false;
        }
        // MOUSECLICK EVENT
        private void HeaderCheckBox_MouseClick(Object Sender, MouseEventArgs e)
        {
            HeaderCheckBoxClick((CheckBox)Sender);
        }

        private void frmPostingUnPosting_Load(object sender, EventArgs e)
        {
            dtpRptFromDate.Value = DateTime.Today;
            dtpRptToDate.Value = DateTime.Today;
            AddHeaderCheckBox();
            HeaderCheckBox.MouseClick += new MouseEventHandler(HeaderCheckBox_MouseClick);
        }


        void FillDgvData()
        {
            int i = 0;

            dgvData.RowCount = dt.Rows.Count;
            if (dt.Rows.Count > 0)
            {
                for (int j = 0; j <= dt.Rows.Count - 1; j++)
                {
                    dgvData.Rows[i].Cells[1].Value = dt.Rows[j][0];
                    dgvData.Rows[i].Cells[2].Value = dt.Rows[j][1];
                    dgvData.Rows[i].Cells[3].Value = dt.Rows[j][2];
                    dgvData.Rows[i].Cells[4].Value = dt.Rows[j][3];
                    i++;
                }
                AddHeaderCheckBox();
            }
        }

        void Search()
        {
            try
            {

                int jPost;
                DateTime fromDate = Convert.ToDateTime(dtpRptFromDate.Value.ToShortDateString());
                DateTime toDate = Convert.ToDateTime(dtpRptToDate.Value.ToShortDateString());
                getOpType();
                jPost = Convert.ToInt32(txtPostStatus.Text);

                dt = new DataTable();
                dt.Clear();
                dt = cj.getPostingBonds(fromDate, toDate, opType, jPost, Program.braCode);


                if (jPost == 1)
                {
                    if (dt.Rows.Count > 0)
                    {
                        FillDgvData();
                        btnPosing.Visible = true;
                        btnUndoPosting.Visible = false;
                    }
                    else
                    {
                        MessageBox.Show("لا توجد سندات أو قيودإو فواتير لترحيلها", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                }
                if (jPost == 2)
                {
                    if (dt.Rows.Count > 0)
                    {
                        FillDgvData();
                        btnPosing.Visible = false;
                        btnUndoPosting.Visible = true;
                    }
                    else
                    {
                        MessageBox.Show("لا توجد سندات أو قيودإو فواتير مرحلة", "تنبيه", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                }
            }
            catch
            {
                return;
            }
        }

        private void btnSearch_Click(object sender, EventArgs e)
        {
            if (!IsAnyRadioButtonChecked())
            {
                MessageBox.Show("إختار العملية التي تريد أولاً");
                return;
            }

            dgvData.Rows.Clear();
            Search();
        }

        private void dgvData_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            Boolean CHK = Convert.ToBoolean(dgvData.CurrentRow.Cells[0].Value);

            if (CHK == false)
            {
                dgvData.CurrentRow.Cells[0].Value = true;
            }
            else
            {
                dgvData.CurrentRow.Cells[0].Value = false;
            }
        }

        void isPost()
        {
            try
            {
                getOpType(); // Ensure this method sets the opType correctly

                // Retrieve the user ID
                int addPostUser = Convert.ToInt32(cu.getUserNo(userName).Rows[0][0].ToString());
                DateTime postingDate = DateTime.Now;
                int post = Convert.ToInt32(txtPostStatus.Text);
                int bondCount = dgvData.Rows.Count;

                if (bondCount > 0)
                {
                    for (int i = 0; i < bondCount; i++)
                    {
                        if (Convert.ToBoolean(dgvData.Rows[i].Cells[0].Value) == true)
                        {
                            int jNo = Convert.ToInt32(dgvData.Rows[i].Cells[1].Value);


                            // Perform the bond posting
                            cj.doBondPosting(jNo, post, opType, Program.braCode);

                        }
                    }
                    MessageBox.Show("تم عملية الترحيل بنجاح", "عملية الترحيل", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    dgvData.Rows.Clear();
                    Search(); // Ensure Search() method is defined and works correctly
                }
                else
                {
                    MessageBox.Show("لا توجد سندات لترحيلها", "عملية الترحيل", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error during posting: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnUndoPosting_Click(object sender, EventArgs e)
        {
            isPost();
        }

        private void btnPosing_Click(object sender, EventArgs e)
        {
            isPost();
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}
