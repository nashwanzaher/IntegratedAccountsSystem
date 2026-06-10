# IntegratedAccountsSystem Architecture Documentation

# Content Script for Visual Generation

---

## Page 1: Cover Page

### Slide Title

نظام الحسابات المتكامل - Integrated Accounts System
Architecture Documentation | وثائق البناء الفني

### Sub-Topics

#### 1.1 Project Identity

- **Project Name**: IntegratedAccountsSystem (نظام الحسابات المتكامل)
- **Project Type**: Arabic Desktop Accounting Application
- **Architecture Pattern**: WinForms 3-Tier Architecture
- **Database**: SQL Server - accountSysDB
- **Language**: C# WinForms with Arabic UI

#### 1.2 Technical Stack Overview

- **Presentation Layer**: 74 WinForms (frmLogin, frmMainWindow, frmJournal, frmSalesBill, frmBonds, frmChartOfAccounts, etc.)
- **Business Layer**: Class Library (clsUsers, clsBonds, clsAccounts, clsJournal, clsSysFormat, clsProducts, clsStores)
- **Data Access Layer**: clsCN.cs with SQL connection management
- **Security**: PBKDF2-SHA256 password hashing (100,000 iterations)

#### 1.3 Documentation Purpose

- Architecture visualization for team understanding
- System design reference for new developers
- Security model documentation
- Data flow documentation for maintenance

---

## Page 2: Solution Structure

### Slide Title

Solution Structure | هيكل الحل البرمجي

### Sub-Topics

#### 2.1 Project Root Structure

- IntegratedAccountsSystem/ (Main Project Folder)
  - PL/ (Presentation Layer - 74 Forms)
  - BL/ (Business Logic Layer - Class Library)
  - DAL/ (Data Access Layer)
  - Properties/ (Application Settings)
  - Reports/ (Report Viewer Forms)
  - IntegratedAccSys.csproj (Project File)

#### 2.2 Presentation Layer (PL) Folder Structure

- PL/Accounts/ (Chart of Accounts, Trail Balance, Final Accounts, Account Sheets)
  - 9 forms: frmChartOfAccounts, frmAccSheet, frmTrailBalance, frmFinalAccounts, etc.
- PL/Journal/ (Journal Entry Forms)
  - 3 forms: frmJournal, frmPostingUnPosting
- PL/Sales/ (Sales Bills, Returns, Customer Management)
  - 4 forms: frmSalesBill, frmSaleReturnBill, frmCustomers, frmSelectCusromer
- PL/Purchases/ (Purchase Bills, Returns, Supplier Management)
  - 5 forms: frmPurchasesBill, frmPurReturnBill, frmSuppleirs, etc.
- PL/Inventory/ (Products, Categories, Units, Stores)
  - 8 forms: frmProducts, frmCategories, frmUnits, frmStores, frmInvventroy
- PL/Bonds/ (Receipt and Payment Bonds)
  - 1 main form: frmBonds
- PL/Users/ (User Management, Privileges, Login)
  - 4 forms: frmLogin, frmUsers, frmPrivillages
- PL/SysFormat/ (System Configuration Forms)
  - 9 forms: frmCompanies, frmBanks, frmCurrencies, frmFunds, frmVATSettings, etc.
- PL/Reports/ (Report Viewing)
  - ReportViewer form

#### 2.3 Business Layer (BL) Folder Structure

- BL/Users/ - clsUsers.cs (User authentication, privileges management)
- BL/Accounts/ - clsAccounts.cs (Chart of accounts operations)
- BL/Journal/ - clsjournal.cs (Journal entry management)
- BL/Sales/ - clsSales.cs (Sales operations)
- BL/Purchases/ - clsPurchases.cs (Purchase operations)
- BL/Stores/ - clsInventory.cs (Inventory, products, categories management)
- BL/Bonds/ - clsBonds.cs (Bond/receipt management)
- BL/SysFormat/ - clsSysFormat.cs (System settings, currencies, funds)
- BL/Security/ - SessionContext, PasswordHelper, AuditHelper, PrivilegeHelper

#### 2.4 Data Access Layer (DAL)

- DAL/clsCN.cs - Central database connection class
  - IDisposable pattern for proper resource management
  - SelectData() and ExecuteCmd() methods
  - SQL injection prevention via regex validation
  - Supports both SQL Authentication and Windows Authentication

---

## Page 3: Architecture Diagram

### Slide Title

3-Tier Architecture | البنية ثلاثية الطبقات

### Sub-Topics

#### 3.1 Layer Overview

- **Layer 1 - Presentation Layer (PL)**: WinForms User Interface
  - 74 forms handling user interactions
  - Direct reference to BL classes
  - Privilege validation on form load
- **Layer 2 - Business Layer (BL)**: Class Library
  - Business logic and validation
  - Data transformation between PL and DAL
  - Direct reference to DAL classes
- **Layer 3 - Data Access Layer (DAL)**: clsCN.cs
  - SQL connection management
  - Stored procedure execution
  - Result set transformation to DataTable

#### 3.2 Data Flow Direction

- User Request → PL (Form) → BL (Class) → DAL (clsCN) → Stored Procedure → SQL Server
- Response: SQL Server → Stored Procedure Result → DataTable → BL → PL → User Display

#### 3.3 Key Component Responsibilities

- **PL Responsibilities**: UI rendering, user input capture, privilege enforcement, form navigation
- **BL Responsibilities**: Business rules, data validation, transaction coordination, audit logging
- **DAL Responsibilities**: Connection lifecycle, SQL command execution, result parsing, injection prevention

---

## Page 4: Authentication Flow

### Slide Title

Authentication Flow | مسار المصادقة

### Sub-Topics

#### 4.1 Login Initiation

- User enters credentials (userID, password, braCode)
- frmLogin.btnLogin_Click() triggers authentication
- BL.Users.clsUsers.Login() called with credentials

#### 4.2 3-Tier Password Verification

- **Tier 1 - PBKDF2-SHA256 (Current Standard)**
  - PasswordHelper.Verify() with 100,000 iterations
  - Salt + Hash comparison with constant-time evaluation
  - Used for newly created or migrated users
- **Tier 2 - Legacy SHA-256**
  - Format: SHA256(password + salt + braCode + userCode)
  - Automatic upgrade to Tier 1 on successful login
- **Tier 3 - Plaintext (Pre-migration)**
  - Direct string comparison
  - Security warning logged
  - Automatic upgrade to Tier 1

#### 4.3 Session Creation on Success

- SessionContext.Create() called with userCode, userID, braCode
- createSession stored procedure executes
- NEWID() generated as sessionToken
- tblSessions INSERT with 1-hour expiry
- AuditHelper.LogLoginSuccess() records event
- frmMainWindow.Load() triggers session validation

#### 4.4 Failure Handling

- Invalid credentials → AuditHelper.LogLoginFailure()
- User not found → immediate rejection
- Password mismatch → tier-by-tier fallback attempt

---

## Page 5: Session Management

### Slide Title

Session Management | إدارة الجلسات

### Sub-Topics

#### 5.1 Session Lifecycle States

- **NEW**: Token generated, inserted to tblSessions
- **ACTIVE**: Validated, sliding expiry reset
- **EXPIRED**: exceeds expiresAt, isActive=0
- **ENDED**: Manual logout or app exit

#### 5.2 Token-Based Session Architecture

- Static fields in SessionContext (app-domain lifetime)
  - _sessionToken: Guid (nullable)
  - _sessionUserCode: int
  - _sessionUserID: string
  - _sessionBraCode: int
- Token stored in tblSessions with:
  - userCode, machineName, createdAt
  - lastActivityAt, expiresAt (DATEADD(HOUR, 1))
  - isActive flag

#### 5.3 Session Operations

- **Create**: createSession SP → NEWID token → INSERT tblSessions → return token
- **Validate**: validateSession SP → Check isActive=1 AND expiresAt > GETDATE() → UpdateActivity
- **Refresh**: updateSessionActivity SP → Reset expiresAt = DATEADD(HOUR, 1) from current time
- **End**: endSession SP → Set isActive=0 → Clear static fields
- **Cleanup**: expireOldSessions SP → Set isActive=0 for expired sessions

#### 5.4 Sliding Expiration Pattern

- On every Validate() call, expiresAt extended by 1 hour
- Prevents session timeout during active use
- 1-hour absolute timeout for idle sessions

---

## Page 6: Data Flow - Sales Bill

### Slide Title

Sales Bill Data Flow | مسار بيانات فاتورة المبيعات

### Sub-Topics

#### 6.1 Sales Bill Operation Sequence

- frmSalesBill.btnAdd_Click() triggers complete save sequence
- addOperationHeader() - Saves bill header to tblOperationHeader
- addOperationBody() - Saves each line item to tblOperationBody
- addProductMovement() - Records inventory movement to tblProductMovement
- updateProductData() - Adjusts product quantities in tblProducts
- addJournalHeader() - Creates journal entry header in tblJournalHeader
- addJournalBody() - Creates journal lines grouped by category in tblJournalBody

#### 6.2 Journal Entry Generation

- For opType=4 (Sales Bill) only
- Group items by category (CatNo) for consolidated journal lines
- Payment method determines debit account:
  - Cash ("نقداً") → Fund account as debit
  - Credit ("آجل") → Customer account as debit
- Credit accounts by category:
  - Inventory account (from category settings)
  - Sales revenue account
  - Sales VAT account
  - Discount allowed account
  - Cost of goods sold account

#### 6.3 Inventory Update Flow

- Category lookup provides account codes:
  - inventoryCode, saleAccCode, saleReturnAccCode
  - saleDiscAccCode, saleQtyFreeAccCode, saleVatAccCode
  - saleCostAccCode, saleRevenuseAccCode
- Conversion factor applied for unit calculations
- BaseQty = Qty × conversionFactor

#### 6.4 Transaction Validation

- Journal balance verification: totalDebitSum == totalCreditSum
- Quantity availability check before insert
- Duplicate product prevention in same bill

---

## Page 7: Data Flow - Journal Entry

### Slide Title

Journal Entry Data Flow | مسار بيانات القيد المحاسبي

### Sub-Topics

#### 7.1 Journal Structure

- **tblJournalHeader**: jNo, jDate, jNote, jType, jPost, totalDebit, totalCredit, userCode, braCode, opType
- **tblJournalBody**: jNo, accCode, currID, currVal, debit, credit, note

#### 7.2 Journal Creation Flow

- getNewJournalNo() - Generate next journal number per branch
- addJournalHeader() - Insert header with initial totals
- addJournalBody() - Insert line items with account codes
- Grouping logic: Items with same CatNo grouped for consolidated posting

#### 7.3 Posting Mechanism

- frmJournal contains posting/unposting functionality
- jPost flag: 0=unposted, 1=posted
- Posted entries cannot be modified (business rule)
- frmPostingUnPosting form handles batch posting operations

#### 7.4 Journal-Operation Relationship

- Sales bills auto-create journal entries (opType mapping)
- Purchase bills auto-create journal entries
- Manual journal entries via frmJournal
- Journal number stored in operation header for reference

---

## Page 8: Privilege System

### Slide Title

Privilege System | نظام الصلاحيات

### Sub-Topics

#### 8.1 Permission Model

- 6 permissions per screen/window:
  - privNew: Create new records
  - privAdd: Save/add operations
  - privEdit: Modify existing records
  - privDel: Delete operations
  - privPrint: Print reports
  - privDisplay: View/access screen
- Per-user, per-screen permissions stored in tblPermissions
- windowID identifies each form/screen in the system

#### 8.2 Privilege Application Flow

- Form Load event triggers ApplyPrivileges()
- clsUsers.ApplyPrivileges(form, windowID) called
- getScreensPrivillages(userCode, windowID, braCode) SP called
- Returns single row with all 6 privilege flags
- Buttons disabled by default if no privilege row exists (default-deny)

#### 8.3 Privilege Management

- frmPrivillages form for admin privilege configuration
- addPrivillages() - Initialize default privileges for new user
- editPrivillages() - Update specific privilege flags
- getDisplayPrivillages() - Get all screens user can access
- delPrivellages() - Remove user privileges (on user deletion)

#### 8.4 Privilege Check Implementation

- Button naming convention: btnNew, btnAdd, btnEdit, btnDel, btnPrint
- Controls.Find() locates buttons by name
- Enabled property set based on privilege flag
- Disabled buttons grayed out but visible (UI feedback)

---

## Page 9: Database Schema

### Slide Title

Database Schema | مخطط قاعدة البيانات

### Sub-Topics

#### 9.1 Core Tables

- **tblUsers**: userCode, userID, userFName, PWD, PWDHash, PasswordHash, PasswordSalt, PasswordIterations, PasswordAlgorithm, userMobile, userEmail, userImg, braCode, testImage
- **tblSessions**: sessionToken (PK), userCode, userID, braCode, machineName, createdAt, lastActivityAt, expiresAt, isActive
- **tblPermissions**: userCode, windowID, braCode, privNew, privAdd, privEdit, privDel, privPrint, privDisplay
- **tblBranches**: braCode, braName, braAddress, braPhone, etc.

#### 9.2 Account Tables

- **tblAccounts**: accCode, accName, accNameE, accNature, parentCode, level, accType, isActive
- Hierarchical structure with 7 levels
- Account nature: debit/credit
- Parent-child relationships for chart of accounts

#### 9.3 Transaction Tables

- **tblJournalHeader**: jNo, jDate, jNote, jType, jPost, totalDebit, totalCredit, userCode, braCode, opType
- **tblJournalBody**: jNo, accCode, currID, currVal, debit, credit, note
- **tblOperationHeader**: opNo, opDate, opType, isPost, note, accCode (customer/supplier), userCode, braCode, paymentMethod, fundCode, total, discount, vat, netTotal, jNo
- **tblOperationBody**: opNo, prodCode, currID, unitID, qty, price, discount, vat, currVal, conversionFactor, opType

#### 9.4 Inventory Tables

- **tblProducts**: prodCode, prodName, catID, unitID, buyPrice, sellPrice, qty, storeID
- **tblCategories**: catID, catName, inventoryCode, saleAccCode, saleReturnAccCode, saleDiscAccCode, saleVatAccCode, saleCostAccCode, saleRevenuseAccCode
- **tblStores**: storeID, storeName, storeLocation
- **tblProductMovement**: moveID, prodCode, qty, price, unitID, storeID, catID, moveDate, opNo, conversionFactor, opType

---

## Page 10: Class Relationships

### Slide Title

Class Relationships | علاقات الكلاسات

### Sub-Topics

#### 10.1 Business Layer Class Dependencies

- **clsUsers**: Uses DAL.clsCN, AuditHelper, PasswordHelper
  - Methods: Login(), getAllUsers(), addUser(), updateUser(), delUser()
  - Privileges: addPrivillages(), editPrivillages(), ApplyPrivileges()
- **clsInventory**: Uses DAL.clsCN
  - Operations: addOperationHdr(), addOperationBody(), addProductMovement(), updateProductData()
  - Queries: getAllStroes(), getAllUnits(), getCategoryData(), getProductData()
  - Bills: getBillOrBondNewNo(), showBillBondHeader(), showBillBondBody()
- **clsjournal**: Uses DAL.clsCN
  - Methods: addJournalHeader(), addJournalBody(), delJournalEntry(), getNewJournalNo()

#### 10.2 Presentation Layer Dependencies

- **frmSalesBill**: References clsSysFormat, frmSelectCusromer, clsInventory, clsjournal, clsUsers
- **frmLogin**: References clsUsers for authentication
- **frmMainWindow**: References SessionContext for validation

#### 10.3 Security Classes

- **SessionContext**: Static class, manages session token lifecycle
- **PasswordHelper**: Static class, PBKDF2 hashing and verification
- **AuditHelper**: Static class, async fire-and-forget audit logging
- **PrivilegeHelper**: Supports privilege validation

#### 10.4 System Format Classes

- **clsSysFormat**: Manages system-wide settings
  - Payment methods, currencies, exchange rates
  - Funds, banks, VAT settings
  - Branch data retrieval

---

## Page 11: Security Architecture

### Slide Title

Security Architecture | البنية الأمنية

### Sub-Topics

#### 11.1 Password Security

- **PBKDF2-SHA256 (Tier 1 - Current)**
  - 100,000 iterations (OWASP 2023 recommendation)
  - 32-byte salt (256 bits), base64 encoded
  - 32-byte hash (256 bits), base64 encoded
  - Constant-time verification via CryptographicOperations.FixedTimeEquals
- **Legacy SHA-256 (Tier 2)**
  - Salt format: "IntegratedAccSysSalt_v1_{braCode}_{userCode}"
  - Hex output (64 characters)
  - Automatic upgrade to Tier 1 on login
- **Plaintext (Tier 3 - Pre-migration)**
  - Direct string comparison
- Security warning logged
  - Automatic upgrade to Tier 1

#### 11.2 SQL Injection Prevention

- ValidateStoredProcedureCall() in clsCN
- Regex pattern: ^[a-zA-Z_][a-zA-Z0-9_]*$
- Blocked patterns: SELECT, INSERT, UPDATE, DELETE, DROP, UNION, xp_, sp_, etc.
- Maximum 128 character limit for procedure names
- All user input passed via SqlParameter arrays

#### 11.3 Session Security

- NEWID() for unpredictable session tokens
- 1-hour sliding expiration
- Machine name recording for audit
- isActive flag for explicit session termination

#### 11.4 Audit Logging

- Async fire-and-forget logging via AuditHelper
- Events logged:
  - Login success/failure
  - Session creation/invalidation/termination
  - User creation/update/deletion
  - Security warnings (plaintext authentication)
- Best-effort approach (failures don't break business flow)

---

## Page 12: End-to-End Flow

### Slide Title

End-to-End Transaction Flow | مسار المعاملة من البداية للنهاية

### Sub-Topics

#### 12.1 Complete Sales Transaction Flow

1. **Login Phase**: frmLogin → clsUsers.Login() → 3-tier password verification → SessionContext.Create() → createSession SP
2. **Main Window**: frmMainWindow.Load() → SessionContext.Validate() → validateSession SP → UpdateActivity()
3. **Navigation**: User clicks Sales → frmSalesBill.Load() → ApplyPrivileges() → getAllData() populates dropdowns
4. **Bill Creation**: btnNew_Click() → getBillOrBondNewNo() → new bill number generated
5. **Customer Selection**: txtCustName_KeyDown() → frmSelectCusromer.ShowDialog() → customer code returned
6. **Product Selection**: txtProdCode_KeyDown() → frmSelectItem.ShowDialog() → product details returned
7. **Item Addition**: btnInsert_Click() → getTotal() → dgvData.Rows.Add() → Total() recalculates
8. **Bill Save**: btnAdd_Click() triggers sequence:
   - addOperationHeader() → tblOperationHeader INSERT
   - addOperationBody() → tblOperationBody INSERT (per row)
   - addProductMovement() → tblProductMovement INSERT
   - updateProductData() → tblProducts UPDATE
   - addJournalHeader() → tblJournalHeader INSERT
   - addJournalBody() → tblJournalBody INSERT (grouped by category)
9. **Completion**: MessageBox "تمت عملية الحفظ بنجاح"

#### 12.2 Data Consistency Guarantees

- All operations within same logical transaction
- Journal balance verification before commit
- Inventory quantity checks before bill save
- Duplicate product prevention at UI level

#### 12.3 Error Handling

- Try-catch blocks around save operations
- User-friendly Arabic error messages
- Transaction rollback on failure (exceptions propagate)
- Best-effort session management (failures logged, not thrown)

---

## Visual Design Guidelines

### Color Palette

- Primary: Deep Blue (#1a365d) - Professional, trustworthy
- Secondary: Teal (#0d9488) - Modern, clean
- Accent: Amber (#f59e0b) - Highlights, warnings
- Background: Light Gray (#f8fafc) - Clean, readable
- Text: Dark Slate (#1e293b) - High contrast
- Success: Green (#10b981)
- Error: Red (#ef4444)

### Typography

- Headings: Serif for Arabic (traditional feel), Sans-serif for English
- Body: Clear, readable at various sizes
- Code/Technical: Monospace for system names

### Layout Principles

- Asymmetric compositions for visual interest
- Information density appropriate for technical documentation
- Clear visual hierarchy (layer colors, box sizes)
- Arabic RTL support where needed

### Iconography

- Layer icons: Stack of layers for 3-tier
- Database: Cylinder for SQL Server
- Lock/key for security
- Flow arrows for processes
