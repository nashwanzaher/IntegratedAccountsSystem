const pptxgen = require("pptxgenjs");

module.exports = {
  createSlide: function (pres, theme) {
    const slide = pres.addSlide();
    slide.background = { color: theme.bg };

    slide.addText("Sales Bill Data Flow | مسار بيانات فاتورة المبيعات", {
      x: 0.5,
      y: 0.3,
      w: 9,
      h: 0.5,
      fontSize: 26,
      fontFace: "Arial",
      color: theme.primary,
      bold: true,
    });

    // Sequence boxes
    const steps = [
      {
        title: "1. addOperationHeader()",
        desc: "INSERT into tblOperationHeader",
      },
      {
        title: "2. addOperationBody()",
        desc: "INSERT into tblOperationBody (per row)",
      },
      {
        title: "3. addProductMovement()",
        desc: "INSERT into tblProductMovement",
      },
      { title: "4. updateProductData()", desc: "UPDATE tblProducts qty" },
      {
        title: "5. addJournalHeader()",
        desc: "INSERT into tblJournalHeader (opType=4)",
      },
      {
        title: "6. addJournalBody()",
        desc: "INSERT into tblJournalBody (grouped by CatNo)",
      },
    ];

    let y = 0.9;
    steps.forEach((step, i) => {
      slide.addShape(pres.shapes.RECTANGLE, {
        x: 0.5,
        y: y,
        w: 5.5,
        h: 0.65,
        fill: { color: theme.light },
        line: { color: theme.accent, width: 1 },
      });
      slide.addText(step.title, {
        x: 0.6,
        y: y + 0.05,
        w: 5.3,
        h: 0.3,
        fontSize: 13,
        fontFace: "Arial",
        color: theme.accent,
        bold: true,
      });
      slide.addText(step.desc, {
        x: 0.6,
        y: y + 0.35,
        w: 5.3,
        h: 0.25,
        fontSize: 11,
        fontFace: "Arial",
        color: theme.secondary,
      });
      if (i < steps.length - 1) {
        slide.addText("↓", {
          x: 3.0,
          y: y + 0.65,
          w: 0.5,
          h: 0.25,
          fontSize: 16,
          fontFace: "Arial",
          color: theme.accent,
          align: "center",
        });
      }
      y += 0.8;
    });

    // Right panel - journal accounts
    slide.addShape(pres.shapes.RECTANGLE, {
      x: 6.3,
      y: 0.9,
      w: 3.4,
      h: 4.3,
      fill: { color: theme.light },
      line: { color: theme.primary, width: 1 },
    });
    slide.addText("Journal Accounts Mapping", {
      x: 6.3,
      y: 0.95,
      w: 3.4,
      h: 0.4,
      fontSize: 13,
      fontFace: "Arial",
      color: theme.primary,
      bold: true,
      align: "center",
    });
    slide.addText(
      [
        { text: "Payment Method:\n", options: { bold: true } },
        { text: "  نقداً (Cash) → Fund debit\n" },
        { text: "  آجل (Credit) → Customer debit\n\n" },
        { text: "Credit Accounts:\n", options: { bold: true } },
        { text: "  - Inventory (inventoryCode)\n" },
        { text: "  - Sales Revenue\n" },
        { text: "  - VAT (saleVatAccCode)\n" },
        { text: "  - Discount (saleDiscAccCode)\n" },
        { text: "  - Cost of Sales (saleCostAccCode)" },
      ],
      {
        x: 6.4,
        y: 1.4,
        w: 3.2,
        h: 3.6,
        fontSize: 11,
        fontFace: "Arial",
        color: theme.primary,
        valign: "top",
      },
    );

    slide.addText("6", {
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
