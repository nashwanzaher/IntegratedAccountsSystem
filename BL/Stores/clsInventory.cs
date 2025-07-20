using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.JavaScript;
using System.Text;
using System.Threading.Tasks;
using static System.Runtime.CompilerServices.RuntimeHelpers;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace IntegratedAccSys.BL.Stores
{
    internal class clsInventory
    {
        #region Stores
        public DataTable getAllStroes()
        {
            DAL.clsCN cn = new DAL.clsCN();
            return cn.SelectData("getAllStores", null);
        }

        public void addStore(string storeName, string storeTel)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter ("@storeName",storeName),
                new SqlParameter ("@storeTel",storeTel)
            };
            cn.ExecuteCmd("addStore", para);
        }

        public void editStore(string storeName, string storeTel, int ID)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter ("@storeName",storeName),
                new SqlParameter ("@storeTel",storeTel),
                new SqlParameter ("@ID",ID)
            };
            cn.ExecuteCmd("editStore", para);
        }

        public void delStore(int ID)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter ("@ID",ID)
            };
            cn.ExecuteCmd("delStore", para);
        }
        #endregion

        #region categories

        public DataTable getAllCategories()
        {
            DAL.clsCN cn = new DAL.clsCN();
            return cn.SelectData("getAllCutegories", null);
        }

        // to save a new category
        public void addCategories( string catName,int storeID, int inventoryAccCode, int saleNo, int saleReturnNo, int saleVatNo, int saleDiscNo, int saleQtyFreeNo,int saleCostNo,int saleRevenuseNo, int purAccNo, int purReturnNo, int purVatNo, int purDiscNo, int purQtyFreeNo)
        {
                DAL.clsCN cn = new DAL.clsCN();
                SqlParameter[] para = new SqlParameter[]
                {
                    new SqlParameter("@catName",catName),
                    new SqlParameter("@storeID",storeID ),
                    new SqlParameter("@inventoryCode",inventoryAccCode ),
                    new SqlParameter("@saleNo",saleNo ),
                    new SqlParameter("@saleReturnNo", saleReturnNo ),
                    new SqlParameter("@saleVatAccNo",saleVatNo),
                    new SqlParameter("@saleDiscAccNo", saleDiscNo ),
                    new SqlParameter("@saleQtyFreeAccNo", saleQtyFreeNo ),
                    new SqlParameter("@saleCostAccNo", saleCostNo),
                    new SqlParameter("@saleRevenuseAccNo", saleRevenuseNo ),
                    new SqlParameter("@purAccNo", purAccNo ),
                    new SqlParameter("@purReturnAccNo",purReturnNo ),
                    new SqlParameter("@purVatAccNo",purVatNo ),
                    new SqlParameter("@purDiscAccNo",purDiscNo),
                    new SqlParameter("@purQtyFreeAccNo",purQtyFreeNo ),
                   
                };
                cn.ExecuteCmd("addCategories", para);
                 
        }

        // to edit  acategory Data
        public void editCategories(int ID,string catName, int storeID, int inventoryAccCode, int saleNo, int saleReturnNo, int saleVatNo, int saleDiscNo, int saleQtyFreeNo, int saleCostNo, int saleRevenuseNo, int purAccNo, int purReturnNo, int purVatNo, int purDiscNo, int purQtyFreeNo)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                    new SqlParameter("@ID",ID),
                    new SqlParameter("@catName",catName),
                    new SqlParameter("@storeID",storeID ),
                    new SqlParameter("@inventoryCode",inventoryAccCode ),
                    new SqlParameter("@saleNo",saleNo ),
                    new SqlParameter("@saleReturnNo", saleReturnNo ),
                    new SqlParameter("@saleVatAccNo",saleVatNo),
                    new SqlParameter("@saleDiscAccNo", saleDiscNo ),
                    new SqlParameter("@saleQtyFreeAccNo", saleQtyFreeNo ),
                    new SqlParameter("@saleCostAccNo", saleCostNo),
                    new SqlParameter("@saleRevenuseAccNo", saleRevenuseNo ),
                    new SqlParameter("@purAccNo", purAccNo ),
                    new SqlParameter("@purReturnAccNo",purReturnNo ),
                    new SqlParameter("@purVatAccNo",purVatNo ),
                    new SqlParameter("@purDiscAccNo",purDiscNo),
                    new SqlParameter("@purQtyFreeAccNo",purQtyFreeNo ),

            };
            cn.ExecuteCmd("editCategories", para);

        }

        // to delete a category
        public void delCategories(int catCode, int braCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter("@catCode",catCode ),
                new SqlParameter("@braCode", braCode)
                };
            cn.ExecuteCmd("delCategories", para);
        }
        
        public DataTable getCategoryData(int CatID)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter("@CatID",CatID )
               
                };
           return cn.SelectData("getCategoryData", para);
        }

        #endregion

        #region Categories


        #endregion

        #region Units
        public DataTable getAllUnits()
        {
            DAL.clsCN cn=new DAL.clsCN();
            return cn.SelectData("getAllUnits", null);

        }
       
        public void addUnit(string unitName,decimal conversionFactor)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[] 
            { 
                new SqlParameter ("@unitName",unitName),
                new SqlParameter ("@conversionFactor",conversionFactor)
            };
            cn.ExecuteCmd("addUnit",para);
        }

        public void editUnit(int ID,string unitName, decimal conversionFactor)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter ("@ID",ID),
                new SqlParameter ("@unitName",unitName),
                new SqlParameter ("@conversionFactor",conversionFactor)
            };
            cn.ExecuteCmd("editUnit", para);
        }

        public void delUnit(int ID) 
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter ("@ID",ID),
                
            };
            cn.ExecuteCmd("delUnite",para);
        }

        public DataTable getConversionFactor(string unitName)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[] 
            { 
              new SqlParameter ("@unitName",unitName)
            };
            return cn.SelectData("getConversionFactor",para);
        }
        #endregion

        #region Products
        public DataTable getAllProducts()
        {
            DAL.clsCN cn=new DAL.clsCN();
            return cn.SelectData("getAllProducts",null);
        }
        
        public void addProduct(int  prodCode,string  prodName,int  stroreID,int  catID,int  unitID,decimal Qty,decimal Price,byte[] prodImg,string ImgTest)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[] 
            {
                new SqlParameter ("@prodCode",prodCode),
                new SqlParameter ("@prodName",prodName),
                new SqlParameter ("@stroreID",stroreID),
                new SqlParameter ("@catID",catID),
                new SqlParameter ("@unitID",unitID),
                new SqlParameter ("@Qty",Qty),
                new SqlParameter ("@Price",Price),
                new SqlParameter ("@prodImg",prodImg),
                new SqlParameter ("@ImagTest",ImgTest)
            };
            cn.ExecuteCmd("addProduct",para);
        }

        public void editProduct(int prodCode, string prodName, int stroreID, int catID, int unitID, decimal Qty, decimal Price, byte[] prodImg, string ImgTest)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter ("@prodCode",prodCode),
                new SqlParameter ("@prodName",prodName),
                new SqlParameter ("@stroreID",stroreID),
                new SqlParameter ("@catID",catID),
                new SqlParameter ("@unitID",unitID),
                new SqlParameter ("@Qty",Qty),
                new SqlParameter ("@Price",Price),
                new SqlParameter ("@prodImg",prodImg),
                new SqlParameter ("@ImagTest",ImgTest)
            };
            cn.ExecuteCmd("editProduct", para);
        }

        public void delProduct(int prodCode)
        {
            DAL.clsCN cn=new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[] 
            { 
                new SqlParameter ("@prodCode",prodCode)
            };
            cn.ExecuteCmd("delProduct",para);
        }

        public DataTable getProductData(string searchText)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[] 
            {
               new SqlParameter ("@searchText",searchText)
            };
           return cn.SelectData("getProductData",para);
        }
        #endregion

        #region general
        public DataTable getBillOrBondNewNo(int opType, int braCode)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter ("@opType",opType),
                new SqlParameter ("@braCode",braCode)
            };
            return cn.SelectData("getBillOrBondNewNo", para);
        }

        public void addOperationHdr(int No,DateTime  opDate, int opType, int Post, string Note, int CustNo, int SaleRepNo, int SuppNo, int userAdd,DateTime  addDate, int braCode, int paymentMethodID, int fundCode,decimal alltotal, decimal discount, decimal VAT, decimal NetTotal, int jNo,double saleCost)
        {
            DAL.clsCN cn=new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                 new SqlParameter ("@No",No),
                 new SqlParameter ("@Date",opDate),
                 new SqlParameter ("@Type",opType),
                 new SqlParameter ("@Post",Post),
                 new SqlParameter ("@Note",Note),
                 new SqlParameter ("@CustNo",CustNo),
                 new SqlParameter ("@SaleRepNo",SaleRepNo),
                 new SqlParameter ("@SuppNo",SuppNo),
                 new SqlParameter ("@userAdd",userAdd),
                 new SqlParameter ("@addDate",addDate),
                 new SqlParameter ("@braCode",braCode),
                 new SqlParameter ("@paymentMethodID",paymentMethodID),
                 new SqlParameter ("@fundCode",fundCode),
                 new SqlParameter ("@alltotal",alltotal),
                 new SqlParameter ("@discount",discount),
                 new SqlParameter ("@VAT",VAT),
                 new SqlParameter ("@NetTotal",NetTotal),
                 new SqlParameter ("@jNo",jNo),
                 new SqlParameter ("@saleCost",saleCost)
            };
            cn.ExecuteCmd("addOperationHdr", para);
        }

        public void addOperationBody(int prodCode, int currID, int unitID, decimal Qty, decimal price, decimal discount, decimal VAT, int No, decimal currVal, decimal conversionFactor,int opType)
        {
            DAL.clsCN cn =new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter ("@prodCode",prodCode),
                new SqlParameter ("@currID",currID),
                new SqlParameter ("@unitID",unitID),
                new SqlParameter ("@Qty",Qty),
                new SqlParameter ("@price",price),
                new SqlParameter ("@discount",discount),
                new SqlParameter ("@VAT",VAT),
                new SqlParameter ("@No",No),
                new SqlParameter ("@currVal",currVal),
                new SqlParameter ("@conversionFactor",conversionFactor),
                new SqlParameter ("@opType",opType)

            };
            cn.ExecuteCmd("addOperationBody",para);
        }

        public void addProductMovement(int prodCode,decimal Qty,decimal price, int unitID, int storeID, int catID,DateTime moveDate,int No,decimal conversionFactor,int opType)
        {
            DAL.clsCN cn=new DAL.clsCN ();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter("@prodCode",prodCode),
                new SqlParameter("@Qty",Qty),
                new SqlParameter("@price",price),
                new SqlParameter("@unitID",unitID),
                new SqlParameter("@storeID",storeID),
                new SqlParameter("@catID",catID),
                new SqlParameter("@moveDate",moveDate),
                new SqlParameter("@No",No),
                new SqlParameter("@conversionFactor",conversionFactor),
                new SqlParameter("@opType",opType),
            };
            cn.ExecuteCmd("addProductMovement",para);
        }

        public void updateProductData(int prodCode,decimal Qty,int opType)
        {
            DAL.clsCN cn=new DAL.clsCN ();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter ("@prodCode",prodCode),
                new SqlParameter ("@Qty",Qty),
                new SqlParameter ("@opType",opType)
            };
            cn.ExecuteCmd("updateProductData",para);
        }

        public DataTable showBillBondHeader(int No,int opType)
        {
            DAL.clsCN cn=new DAL.clsCN ();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter ("@No",No),
                new SqlParameter ("@opType",opType)
            };
            return cn.SelectData("showBillBondHeader",para);
        }

        public DataTable showBillBondBody(int No, int opType)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter ("@No",No),
                new SqlParameter ("@opType",opType)
            };
            return cn.SelectData("showBillBondBody", para);
        }

        public DataTable getMaximumBillBondNo(int opType)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter ("@opTypeNo",opType)
            };
            return cn.SelectData("getMaximumBillBondNo",para);
        }

        public DataTable getMinimumBillBondNo(int opType)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter ("@opTypeNo",opType)
            };
            return cn.SelectData("getMinimumBillBondNo", para);
        }

        public void editBillBondHeader(int No, DateTime opDate, int opType, int Post, string Note, int CustNo, int SaleRepNo, int SuppNo, int userEdit, DateTime editDate, int braCode, int paymentMethodID, int fundCode, decimal alltotal, decimal discount, decimal VAT, decimal NetTotal, int jNo, double saleCost)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                 new SqlParameter ("@No",No),
                 new SqlParameter ("@Date",opDate),
                 new SqlParameter ("@Type",opType),
                 new SqlParameter ("@Post",Post),
                 new SqlParameter ("@Note",Note),
                 new SqlParameter ("@CustNo",CustNo),
                 new SqlParameter ("@SaleRepNo",SaleRepNo),
                 new SqlParameter ("@SuppNo",SuppNo),
                 new SqlParameter ("@userEdit",userEdit),
                 new SqlParameter ("@editDate",editDate),
                 new SqlParameter ("@braCode",braCode),
                 new SqlParameter ("@paymentMethodID",paymentMethodID),
                 new SqlParameter ("@fundCode",fundCode),
                 new SqlParameter ("@alltotal",alltotal),
                 new SqlParameter ("@discount",discount),
                 new SqlParameter ("@VAT",VAT),
                 new SqlParameter ("@NetTotal",NetTotal),
                 new SqlParameter ("@jNo",jNo),
                 new SqlParameter ("@saleCost",saleCost)
            };
            cn.ExecuteCmd("editBillBondHeader", para);
        }

        public void deleteBillbondbody(int No,int opTypeNo,int prodCode,decimal Qty,decimal price,int unitID,int storeID,int catID,DateTime moveDate,decimal conversionFactor)
        {
            
            DAL.clsCN cn=new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter ("@No",No),
                new SqlParameter ("@opTypeNo",opTypeNo),
                new SqlParameter ("@prodCode",prodCode),
                new SqlParameter ("@Qty",Qty),
                new SqlParameter ("@price",price),
                new SqlParameter ("@unitID",unitID),
                new SqlParameter ("@storeID",storeID),
                new SqlParameter ("@catID",catID),
                new SqlParameter ("@moveDate",moveDate),
                new SqlParameter ("@conversionFactor",conversionFactor),
            };
            cn.ExecuteCmd("deleteBillbondbody",para);
             
        }

        public void deleteBillbondHeader(int No, int opTypeNo, int prodCode, decimal Qty, decimal price, int unitID, int storeID, int catID, DateTime moveDate, decimal conversionFactor)
        {

            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter ("@No",No),
                new SqlParameter ("@opTypeNo",opTypeNo),
                new SqlParameter ("@prodCode",prodCode),
                new SqlParameter ("@Qty",Qty),
                new SqlParameter ("@price",price),
                new SqlParameter ("@unitID",unitID),
                new SqlParameter ("@storeID",storeID),
                new SqlParameter ("@catID",catID),
                new SqlParameter ("@moveDate",moveDate),
                new SqlParameter ("@conversionFactor",conversionFactor),
            };
            cn.ExecuteCmd("deleteBillbondHeader", para);

        }

        #endregion

        #region Inventory
        public DataTable getProductsInventory()
        {
            DAL.clsCN cn=new DAL.clsCN();
            return cn.SelectData("getProductsInventory", null);
        }

        public DataTable getInventoryMovement(DateTime fromDate,DateTime toDate)
        {
            DAL.clsCN cn = new DAL.clsCN();
            SqlParameter[] para = new SqlParameter[]
            {
                new SqlParameter ("@fromDate",fromDate),
                new SqlParameter ("@toDate",toDate)
            };
            return cn.SelectData("getInventoryMovement",para);
        }
        #endregion
    }
}
