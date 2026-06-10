using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Npgsql;
using NpgsqlTypes;

namespace IntegratedAccSys.BL.Stores
{
    public class ClsInventory
    {
        #region Stores
        public DataTable getAllStroes()
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            return cn.SelectData("getAllStores", null);
        }

        public void addStore(string storeName, string storeTel)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@storeName",storeName),
                new NpgsqlParameter ("@storeTel",storeTel)
            };
            cn.ExecuteCmd("addStore", para);
        }

        public void editStore(string storeName, string storeTel, int ID)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@storeName",storeName),
                new NpgsqlParameter ("@storeTel",storeTel),
                new NpgsqlParameter ("@ID",ID)
            };
            cn.ExecuteCmd("editStore", para);
        }

        public void delStore(int ID)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@ID",ID)
            };
            cn.ExecuteCmd("delStore", para);
        }
        #endregion

        #region categories

        public DataTable getAllCategories()
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            return cn.SelectData("getAllCutegories", null);
        }

        // to save a new category
        public void addCategories(string catName, int storeID, int inventoryAccCode, int saleNo, int saleReturnNo, int saleVatNo, int saleDiscNo, int saleQtyFreeNo, int saleCostNo, int saleRevenuseNo, int purAccNo, int purReturnNo, int purVatNo, int purDiscNo, int purQtyFreeNo)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                    new NpgsqlParameter("@catName",catName),
                    new NpgsqlParameter("@storeID",storeID ),
                    new NpgsqlParameter("@inventoryCode",inventoryAccCode ),
                    new NpgsqlParameter("@saleNo",saleNo ),
                    new NpgsqlParameter("@saleReturnNo", saleReturnNo ),
                    new NpgsqlParameter("@saleVatAccNo",saleVatNo),
                    new NpgsqlParameter("@saleDiscAccNo", saleDiscNo ),
                    new NpgsqlParameter("@saleQtyFreeAccNo", saleQtyFreeNo ),
                    new NpgsqlParameter("@saleCostAccNo", saleCostNo),
                    new NpgsqlParameter("@saleRevenuseAccNo", saleRevenuseNo ),
                    new NpgsqlParameter("@purAccNo", purAccNo ),
                    new NpgsqlParameter("@purReturnAccNo",purReturnNo ),
                    new NpgsqlParameter("@purVatAccNo",purVatNo ),
                    new NpgsqlParameter("@purDiscAccNo",purDiscNo),
                    new NpgsqlParameter("@purQtyFreeAccNo",purQtyFreeNo ),

            };
            cn.ExecuteCmd("addCategories", para);

        }

        // to edit  acategory Data
        public void editCategories(int ID, string catName, int storeID, int inventoryAccCode, int saleNo, int saleReturnNo, int saleVatNo, int saleDiscNo, int saleQtyFreeNo, int saleCostNo, int saleRevenuseNo, int purAccNo, int purReturnNo, int purVatNo, int purDiscNo, int purQtyFreeNo)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                    new NpgsqlParameter("@ID",ID),
                    new NpgsqlParameter("@catName",catName),
                    new NpgsqlParameter("@storeID",storeID ),
                    new NpgsqlParameter("@inventoryCode",inventoryAccCode ),
                    new NpgsqlParameter("@saleNo",saleNo ),
                    new NpgsqlParameter("@saleReturnNo", saleReturnNo ),
                    new NpgsqlParameter("@saleVatAccNo",saleVatNo),
                    new NpgsqlParameter("@saleDiscAccNo", saleDiscNo ),
                    new NpgsqlParameter("@saleQtyFreeAccNo", saleQtyFreeNo ),
                    new NpgsqlParameter("@saleCostAccNo", saleCostNo),
                    new NpgsqlParameter("@saleRevenuseAccNo", saleRevenuseNo ),
                    new NpgsqlParameter("@purAccNo", purAccNo ),
                    new NpgsqlParameter("@purReturnAccNo",purReturnNo ),
                    new NpgsqlParameter("@purVatAccNo",purVatNo ),
                    new NpgsqlParameter("@purDiscAccNo",purDiscNo),
                    new NpgsqlParameter("@purQtyFreeAccNo",purQtyFreeNo ),

            };
            cn.ExecuteCmd("editCategories", para);

        }

        // to delete a category
        public void delCategories(int catCode, int braCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter("@catCode",catCode ),
                new NpgsqlParameter("@braCode", braCode)
                };
            cn.ExecuteCmd("delCategories", para);
        }

        public DataTable getCategoryData(int CatID)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter("@CatID",CatID )

                };
            return cn.SelectData("getCategoryData", para);
        }

        #endregion

        #region Categories


        #endregion

        #region Units
        public DataTable getAllUnits()
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            return cn.SelectData("getAllUnits", null);

        }

        public void addUnit(string unitName, decimal conversionFactor)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@unitName",unitName),
                new NpgsqlParameter ("@conversionFactor",conversionFactor)
            };
            cn.ExecuteCmd("addUnit", para);
        }

        public void editUnit(int ID, string unitName, decimal conversionFactor)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@ID",ID),
                new NpgsqlParameter ("@unitName",unitName),
                new NpgsqlParameter ("@conversionFactor",conversionFactor)
            };
            cn.ExecuteCmd("editUnit", para);
        }

        public void delUnit(int ID)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@ID",ID),

            };
            cn.ExecuteCmd("delUnite", para);
        }

        public DataTable getConversionFactor(string unitName)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
              new NpgsqlParameter ("@unitName",unitName)
            };
            return cn.SelectData("getConversionFactor", para);
        }
        #endregion

        #region Products
        public DataTable getAllProducts()
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            return cn.SelectData("getAllProducts", null);
        }

        public void addProduct(int prodCode, string prodName, int stroreID, int catID, int unitID, decimal Qty, decimal Price, byte[] prodImg, string ImgTest)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@prodCode",prodCode),
                new NpgsqlParameter ("@prodName",prodName),
                new NpgsqlParameter ("@stroreID",stroreID),
                new NpgsqlParameter ("@catID",catID),
                new NpgsqlParameter ("@unitID",unitID),
                new NpgsqlParameter ("@Qty",Qty),
                new NpgsqlParameter ("@Price",Price),
                new NpgsqlParameter ("@prodImg",prodImg),
                new NpgsqlParameter ("@ImagTest",ImgTest)
            };
            cn.ExecuteCmd("addProduct", para);
        }

        public void editProduct(int prodCode, string prodName, int stroreID, int catID, int unitID, decimal Qty, decimal Price, byte[] prodImg, string ImgTest)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@prodCode",prodCode),
                new NpgsqlParameter ("@prodName",prodName),
                new NpgsqlParameter ("@stroreID",stroreID),
                new NpgsqlParameter ("@catID",catID),
                new NpgsqlParameter ("@unitID",unitID),
                new NpgsqlParameter ("@Qty",Qty),
                new NpgsqlParameter ("@Price",Price),
                new NpgsqlParameter ("@prodImg",prodImg),
                new NpgsqlParameter ("@ImagTest",ImgTest)
            };
            cn.ExecuteCmd("editProduct", para);
        }

        public void delProduct(int prodCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@prodCode",prodCode)
            };
            cn.ExecuteCmd("delProduct", para);
        }

        public DataTable getProductData(string searchText)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
               new NpgsqlParameter ("@searchText",searchText)
            };
            return cn.SelectData("getProductData", para);
        }
        #endregion

        #region general
        public DataTable getBillOrBondNewNo(int opType, int braCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@opType",opType),
                new NpgsqlParameter ("@braCode",braCode)
            };
            return cn.SelectData("getBillOrBondNewNo", para);
        }

        public void addOperationHdr(int No, DateTime opDate, int opType, int Post, string Note, int CustNo, int SaleRepNo, int SuppNo, int userAdd, DateTime addDate, int braCode, int paymentMethodID, int fundCode, decimal alltotal, decimal discount, decimal VAT, decimal NetTotal, int jNo, double saleCost)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                 new NpgsqlParameter ("@No",No),
                 new NpgsqlParameter ("@Date",opDate),
                 new NpgsqlParameter ("@Type",opType),
                 new NpgsqlParameter ("@Post",Post),
                 new NpgsqlParameter ("@Note",Note),
                 new NpgsqlParameter ("@CustNo",CustNo),
                 new NpgsqlParameter ("@SaleRepNo",SaleRepNo),
                 new NpgsqlParameter ("@SuppNo",SuppNo),
                 new NpgsqlParameter ("@userAdd",userAdd),
                 new NpgsqlParameter ("@addDate",addDate),
                 new NpgsqlParameter ("@braCode",braCode),
                 new NpgsqlParameter ("@paymentMethodID",paymentMethodID),
                 new NpgsqlParameter ("@fundCode",fundCode),
                 new NpgsqlParameter ("@alltotal",alltotal),
                 new NpgsqlParameter ("@discount",discount),
                 new NpgsqlParameter ("@VAT",VAT),
                 new NpgsqlParameter ("@NetTotal",NetTotal),
                 new NpgsqlParameter ("@jNo",jNo),
                 new NpgsqlParameter ("@saleCost",saleCost)
            };
            cn.ExecuteCmd("addOperationHdr", para);
        }

        public void addOperationBody(int prodCode, int currID, int unitID, decimal Qty, decimal price, decimal discount, decimal VAT, int No, decimal currVal, decimal conversionFactor, int opType)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@prodCode",prodCode),
                new NpgsqlParameter ("@currID",currID),
                new NpgsqlParameter ("@unitID",unitID),
                new NpgsqlParameter ("@Qty",Qty),
                new NpgsqlParameter ("@price",price),
                new NpgsqlParameter ("@discount",discount),
                new NpgsqlParameter ("@VAT",VAT),
                new NpgsqlParameter ("@No",No),
                new NpgsqlParameter ("@currVal",currVal),
                new NpgsqlParameter ("@conversionFactor",conversionFactor),
                new NpgsqlParameter ("@opType",opType)

            };
            cn.ExecuteCmd("addOperationBody", para);
        }

        public void addProductMovement(int prodCode, decimal Qty, decimal price, int unitID, int storeID, int catID, DateTime moveDate, int No, decimal conversionFactor, int opType)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter("@prodCode",prodCode),
                new NpgsqlParameter("@Qty",Qty),
                new NpgsqlParameter("@price",price),
                new NpgsqlParameter("@unitID",unitID),
                new NpgsqlParameter("@storeID",storeID),
                new NpgsqlParameter("@catID",catID),
                new NpgsqlParameter("@moveDate",moveDate),
                new NpgsqlParameter("@No",No),
                new NpgsqlParameter("@conversionFactor",conversionFactor),
                new NpgsqlParameter("@opType",opType),
            };
            cn.ExecuteCmd("addProductMovement", para);
        }

        public void updateProductData(int prodCode, decimal Qty, int opType)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@prodCode",prodCode),
                new NpgsqlParameter ("@Qty",Qty),
                new NpgsqlParameter ("@opType",opType)
            };
            cn.ExecuteCmd("updateProductData", para);
        }

        public DataTable showBillBondHeader(int No, int opType)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@No",No),
                new NpgsqlParameter ("@opType",opType)
            };
            return cn.SelectData("showBillBondHeader", para);
        }

        public DataTable showBillBondBody(int No, int opType)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@No",No),
                new NpgsqlParameter ("@opType",opType)
            };
            return cn.SelectData("showBillBondBody", para);
        }

        public DataTable getMaximumBillBondNo(int opType)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@opTypeNo",opType)
            };
            return cn.SelectData("getMaximumBillBondNo", para);
        }

        public DataTable getMinimumBillBondNo(int opType)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@opTypeNo",opType)
            };
            return cn.SelectData("getMinimumBillBondNo", para);
        }

        public void editBillBondHeader(int No, DateTime opDate, int opType, int Post, string Note, int CustNo, int SaleRepNo, int SuppNo, int userEdit, DateTime editDate, int braCode, int paymentMethodID, int fundCode, decimal alltotal, decimal discount, decimal VAT, decimal NetTotal, int jNo, double saleCost)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                 new NpgsqlParameter ("@No",No),
                 new NpgsqlParameter ("@Date",opDate),
                 new NpgsqlParameter ("@Type",opType),
                 new NpgsqlParameter ("@Post",Post),
                 new NpgsqlParameter ("@Note",Note),
                 new NpgsqlParameter ("@CustNo",CustNo),
                 new NpgsqlParameter ("@SaleRepNo",SaleRepNo),
                 new NpgsqlParameter ("@SuppNo",SuppNo),
                 new NpgsqlParameter ("@userEdit",userEdit),
                 new NpgsqlParameter ("@editDate",editDate),
                 new NpgsqlParameter ("@braCode",braCode),
                 new NpgsqlParameter ("@paymentMethodID",paymentMethodID),
                 new NpgsqlParameter ("@fundCode",fundCode),
                 new NpgsqlParameter ("@alltotal",alltotal),
                 new NpgsqlParameter ("@discount",discount),
                 new NpgsqlParameter ("@VAT",VAT),
                 new NpgsqlParameter ("@NetTotal",NetTotal),
                 new NpgsqlParameter ("@jNo",jNo),
                 new NpgsqlParameter ("@saleCost",saleCost)
            };
            cn.ExecuteCmd("editBillBondHeader", para);
        }

        public void deleteBillbondbody(int No, int opTypeNo, int prodCode, decimal Qty, decimal price, int unitID, int storeID, int catID, DateTime moveDate, decimal conversionFactor)
        {

            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@No",No),
                new NpgsqlParameter ("@opTypeNo",opTypeNo),
                new NpgsqlParameter ("@prodCode",prodCode),
                new NpgsqlParameter ("@Qty",Qty),
                new NpgsqlParameter ("@price",price),
                new NpgsqlParameter ("@unitID",unitID),
                new NpgsqlParameter ("@storeID",storeID),
                new NpgsqlParameter ("@catID",catID),
                new NpgsqlParameter ("@moveDate",moveDate),
                new NpgsqlParameter ("@conversionFactor",conversionFactor),
            };
            cn.ExecuteCmd("deleteBillbondbody", para);

        }

        public void deleteBillbondHeader(int No, int opTypeNo, int prodCode, decimal Qty, decimal price, int unitID, int storeID, int catID, DateTime moveDate, decimal conversionFactor)
        {

            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@No",No),
                new NpgsqlParameter ("@opTypeNo",opTypeNo),
                new NpgsqlParameter ("@prodCode",prodCode),
                new NpgsqlParameter ("@Qty",Qty),
                new NpgsqlParameter ("@price",price),
                new NpgsqlParameter ("@unitID",unitID),
                new NpgsqlParameter ("@storeID",storeID),
                new NpgsqlParameter ("@catID",catID),
                new NpgsqlParameter ("@moveDate",moveDate),
                new NpgsqlParameter ("@conversionFactor",conversionFactor),
            };
            cn.ExecuteCmd("deleteBillbondHeader", para);

        }

        #endregion

        #region Inventory
        public DataTable getProductsInventory(int braCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter("@braCode", braCode)
            };
            return cn.SelectData("getProductsInventory", para);
        }

        public DataTable getInventoryMovement(DateTime fromDate, DateTime toDate, int braCode)
        {
            DAL.ClsCN cn = new DAL.ClsCN();
            NpgsqlParameter[] para = new NpgsqlParameter[]
            {
                new NpgsqlParameter ("@fromDate",fromDate),
                new NpgsqlParameter ("@toDate",toDate),
                new NpgsqlParameter ("@braCode",braCode)
            };
            return cn.SelectData("getInventoryMovement", para);
        }
        #endregion
    }
}
