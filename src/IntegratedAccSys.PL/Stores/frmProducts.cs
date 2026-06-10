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

namespace IntegratedAccSys.PL.Stores
{
    public partial class frmProducts : Form
    {
        BL.Stores.ClsInventory ci = new BL.Stores.ClsInventory();
        public frmProducts()
        {
            InitializeComponent();
            getData();
        }

        void getData()
        {
            cbStores.DataSource = ci.getAllStroes();
            cbStores.ValueMember = "الرقم";
            cbStores.DisplayMember = "إسم المخزن";


            cbCategories.DataSource = ci.getAllCategories();
            cbCategories.ValueMember = "رقم المجموعة";
            cbCategories.DisplayMember = "أسم المجموعة";

            cbUnits.DataSource = ci.getAllUnits();
            cbUnits.ValueMember = "رقم الوحدة";
            cbUnits.DisplayMember = "إسم الوحدة";
        }
        void getAllProducts()
        {
            dgvData.DataSource = ci.getAllProducts();
            dgvData.Columns[2].Visible = false;
            dgvData.Columns[3].Visible = false;
            dgvData.Columns[4].Visible = false;
            dgvData.Columns[7].Visible = false;
        }
        void dgvProperties()
        {
            // تنسيق رؤوس الأعمدة
            dgvData.ColumnHeadersDefaultCellStyle.ForeColor = Color.Black;
            dgvData.ColumnHeadersDefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter;
            dgvData.ColumnHeadersDefaultCellStyle.Font = new Font("Times New Roman", 10.75F, FontStyle.Bold);

            // تنسيق الصفوف المتبادلة
            dgvData.AlternatingRowsDefaultCellStyle.ForeColor = Color.Red;
            dgvData.AlternatingRowsDefaultCellStyle.BackColor = Color.SkyBlue;
            dgvData.AlternatingRowsDefaultCellStyle.Font = new Font("Times New Roman", 10.75F, FontStyle.Bold);
            dgvData.AlternatingRowsDefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter;

            // تنسيق خلايا البيانات
            dgvData.DefaultCellStyle.BackColor = Color.White;
            dgvData.DefaultCellStyle.ForeColor = Color.Blue;
            dgvData.DefaultCellStyle.Font = new Font("Times New Roman", 10.75F, FontStyle.Bold);
            dgvData.DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter;
        }
        private void btnExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void frmProducts_Load(object sender, EventArgs e)
        {
            BL.Users.ClsUsers cu = new BL.Users.ClsUsers();
            PrivilegeApplier.Apply(this, 25);
            dgvProperties();
            getAllProducts();
        }

        private void dgvData_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            txtProdNo.Text = dgvData.CurrentRow.Cells[0].Value.ToString();
            txtProdName.Text = dgvData.CurrentRow.Cells[1].Value.ToString();
            cbStores.SelectedValue = dgvData.CurrentRow.Cells[2].Value;
            cbCategories.SelectedValue = dgvData.CurrentRow.Cells[3].Value;
            cbUnits.SelectedValue = dgvData.CurrentRow.Cells[4].Value;
            txtQty.Text = dgvData.CurrentRow.Cells[5].Value.ToString();
            txtPrice.Text = dgvData.CurrentRow.Cells[6].Value.ToString();
            if (dgvData.CurrentRow.Cells[7].Value == DBNull.Value)
            {
                pbImg.Image = null;
            }
            else
            {
                byte[] bImg = (byte[])dgvData.CurrentRow.Cells[7].Value;
                MemoryStream ms = new MemoryStream(bImg);
                pbImg.Image = Image.FromStream(ms);
            }

        }

        private void btnNew_Click(object sender, EventArgs e)
        {
            try
            {
                txtProdNo.Text = string.Empty;
                txtProdName.Text = string.Empty;
                txtQty.Text = string.Empty;
                txtPrice.Text = string.Empty;
                getData();
                pbImg.Image = null;
                txtProdNo.Focus();

            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }



        private void btnAdd_Click(object sender, EventArgs e)
        {
            try
            {
                byte[] bImg;
                if (pbImg.Image == null)
                {
                    bImg = new byte[0];
                    ci.addProduct(Convert.ToInt32(txtProdNo.Text), txtProdName.Text, Convert.ToInt32(cbStores.SelectedValue), Convert.ToInt32(cbCategories.SelectedValue), Convert.ToInt32(cbUnits.SelectedValue), Convert.ToDecimal(txtQty.Text), Convert.ToDecimal(txtPrice.Text), bImg, "withoutImg");
                    MessageBox.Show("تمت عملية الحفظ بنجاح", "عملية الحفظ", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    getAllProducts();
                }
                else
                {
                    MemoryStream ms = new MemoryStream(); ;
                    pbImg.Image.Save(ms, pbImg.Image.RawFormat);
                    bImg = ms.ToArray();
                    ci.addProduct(Convert.ToInt32(txtProdNo.Text), txtProdName.Text, Convert.ToInt32(cbStores.SelectedValue), Convert.ToInt32(cbCategories.SelectedValue), Convert.ToInt32(cbUnits.SelectedValue), Convert.ToDecimal(txtQty.Text), Convert.ToDecimal(txtPrice.Text), bImg, "withImg");
                    MessageBox.Show("تمت عملية الحفظ بنجاح", "عملية الحفظ", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    getAllProducts();
                }

            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void btnEdit_Click(object sender, EventArgs e)
        {
            try
            {
                byte[] pImg;
                if (pbImg.Image == null)
                {
                    pImg = new byte[0];
                    ci.editProduct(Convert.ToInt32(txtProdNo.Text), txtProdName.Text, Convert.ToInt32(cbStores.SelectedValue), Convert.ToInt32(cbCategories.SelectedValue), Convert.ToInt32(cbUnits.SelectedValue), Convert.ToDecimal(txtQty.Text), Convert.ToDecimal(txtPrice.Text), pImg, "withoutImg");
                    MessageBox.Show("تمت عملية التعديل بنجاح", "عملية التعديل", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    getAllProducts();
                }
                else
                {
                    MemoryStream ms = new MemoryStream();
                    pbImg.Image.Save(ms, pbImg.Image.RawFormat);
                    pImg = ms.ToArray();
                    ci.editProduct(Convert.ToInt32(txtProdNo.Text), txtProdName.Text, Convert.ToInt32(cbStores.SelectedValue), Convert.ToInt32(cbCategories.SelectedValue), Convert.ToInt32(cbUnits.SelectedValue), Convert.ToDecimal(txtQty.Text), Convert.ToDecimal(txtPrice.Text), pImg, "withImg");
                    MessageBox.Show("تمت عملية التعديل بنجاح", "عملية التعديل", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    getAllProducts();
                }

            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }


        private void btnDel_Click(object sender, EventArgs e)
        {
            try
            {
                if (MessageBox.Show("هل تريد الحذف", "تنبيه", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes)
                {
                    ci.delProduct(Convert.ToInt32(txtProdNo.Text));
                    MessageBox.Show("تمت عملية الحذف بنجاح", "عملية الحذف", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    getAllProducts();
                }

            }
            catch (Exception ex)
            {
                MessageBox.Show("" + ex, "خطأ", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void btnBrowes_Click(object sender, EventArgs e)
        {
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.Filter = "Image Files|*.gif;*.jpg;*.png;*.bmp";
            if (ofd.ShowDialog() == DialogResult.OK)
            {
                pbImg.Image = Image.FromFile(ofd.FileName);
            }
        }

        private void btnClear_Click(object sender, EventArgs e)
        {
            pbImg.Image = null;
        }
    }





}
