const pptxgen = require("pptxgenjs");

module.exports = {
  createSlide: function (pres, theme) {
    const slide = pres.addSlide();
    slide.background = { color: theme.bg };

    slide.addText("End-to-End Transaction Flow | مسار المعاملة", {
      x: 0.5,
      y: 0.3,
      w: 9,
      h: 0.5,
      fontSize: 26,
      fontFace: "Arial",
      color: theme.primary,
      bold: true,
    });

    // Timeline steps
    const steps = [
      {
        num: "1",
        text: "LOGIN: frmLogin → clsUsers.Login() → SessionContext.Create() → createSession SP",
      },
      {
        num: "2",
        text: "MAIN WINDOW: frmMainWindow.Load() → SessionContext.Validate() → validateSession SP",
      },
      {
        num: "3",
        text: "NAVIGATION: frmSalesBill.Load() → ApplyPrivileges() → getAllData()",
      },
      {
        num: "4",
        text: "NEW BILL: btnNew_Click() → getBillOrBondNewNo() → bill number generated",
      },
      {
        num: "5",
        text: "SELECTIONS: Customer & Product selection via frmSelectCusromer, frmSelectItem",
      },
      {
        num: "6",
        text: "ITEM ADD: btnInsert_Click() → getTotal() → dgvData.Rows.Add() → Total()",
      },
      {
        num: "7",
        text: "BILL SAVE: btnAdd_Click() → 6-step sequence → tblOperations + tblJournal",
      },
      {
        num: "8",
        text: "COMPLETION: MessageBox 'تمت عملية الحفظ بنجاح' → success",
      },
    ];

    let y = 0.85;
    steps.forEach((step, i) => {
      slide.addShape(pres.shapes.OVAL, {
        x: 0.5,
        y: y,
        w: 0.35,
        h: 0.35,
        fill: { color: i === 7 ? "10B981" : theme.accent },
      });
      slide.addText(step.num, {
        x: 0.5,
        y: y,
        w: 0.35,
        h: 0.35,
        fontSize: 12,
        fontFace: "Arial",
        color: "FFFFFF",
        align: "center",
        valign: "middle",
      });
      slide.addText(step.text, {
        x: 1.0,
        y: y,
        w: 8.5,
        h: 0.4,
        fontSize: 11,
        fontFace: "Arial",
        color: theme.primary,
        valign: "middle",
      });
      y += 0.5;
    });

    // Data consistency
    slide.addShape(pres.shapes.RECTANGLE, {
      x: 0.5,
      y: 4.85,
      w: 9,
      h: 0.55,
      fill: { color: theme.light },
      line: { color: theme.secondary, width: 1 },
    });
    slide.addText(
      "Data Consistency: Journal balance verification (debit == credit) | Quantity checks | Duplicate prevention | Try-catch error handling",
      {
        x: 0.6,
        y: 4.9,
        w: 8.8,
        h: 0.45,
        fontSize: 10,
        fontFace: "Arial",
        color: theme.secondary,
      },
    );

    slide.addText("12", {
      x: 9.3,
      y: 5.1,
      w: 0.4,
      h: 0.3,
      fontSize: 12,
      fontFace: "Arial",
      color: theme.accent,
      align: "center",
    });

    return slide;
  },
};
