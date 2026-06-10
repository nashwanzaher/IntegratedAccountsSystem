const pptxgen = require("pptxgenjs");

module.exports = {
  createSlide: function (pres, theme) {
    const slide = pres.addSlide();
    slide.background = { color: theme.bg };

    // Title
    slide.addText("Solution Structure | هيكل الحل البرمجي", {
      x: 0.5,
      y: 0.3,
      w: 9,
      h: 0.5,
      fontSize: 28,
      fontFace: "Arial",
      color: theme.primary,
      bold: true,
    });

    // Three columns
    // PL Column
    slide.addShape(pres.shapes.RECTANGLE, {
      x: 0.3,
      y: 1.0,
      w: 3.0,
      h: 4.2,
      fill: { color: theme.light },
      line: { color: theme.accent, width: 1 },
    });
    slide.addText("PL - Presentation Layer", {
      x: 0.3,
      y: 1.0,
      w: 3.0,
      h: 0.4,
      fontSize: 14,
      fontFace: "Arial",
      color: theme.accent,
      bold: true,
      align: "center",
    });
    slide.addText(
      [
        { text: "Accounts/ (9 forms)\n" },
        { text: "Journal/ (3 forms)\n" },
        { text: "Sales/ (4 forms)\n" },
        { text: "Purchases/ (5 forms)\n" },
        { text: "Inventory/ (8 forms)\n" },
        { text: "Bonds/ (frmBonds)\n" },
        { text: "Users/ (4 forms)\n" },
        { text: "SysFormat/ (9 forms)\n" },
        { text: "Reports/" },
      ],
      {
        x: 0.4,
        y: 1.5,
        w: 2.8,
        h: 3.5,
        fontSize: 12,
        fontFace: "Arial",
        color: theme.primary,
        valign: "top",
      },
    );

    // BL Column
    slide.addShape(pres.shapes.RECTANGLE, {
      x: 3.5,
      y: 1.0,
      w: 3.0,
      h: 4.2,
      fill: { color: theme.light },
      line: { color: theme.accent, width: 1 },
    });
    slide.addText("BL - Business Layer", {
      x: 3.5,
      y: 1.0,
      w: 3.0,
      h: 0.4,
      fontSize: 14,
      fontFace: "Arial",
      color: theme.accent,
      bold: true,
      align: "center",
    });
    slide.addText(
      [
        { text: "Users/clsUsers.cs\n" },
        { text: "Accounts/clsAccounts.cs\n" },
        { text: "Journal/clsjournal.cs\n" },
        { text: "Sales/clsSales.cs\n" },
        { text: "Purchases/clsPurchases.cs\n" },
        { text: "Stores/clsInventory.cs\n" },
        { text: "Bonds/clsBonds.cs\n" },
        { text: "SysFormat/clsSysFormat.cs\n" },
        { text: "Security/" },
      ],
      {
        x: 3.6,
        y: 1.5,
        w: 2.8,
        h: 3.5,
        fontSize: 12,
        fontFace: "Arial",
        color: theme.primary,
        valign: "top",
      },
    );

    // DAL Column
    slide.addShape(pres.shapes.RECTANGLE, {
      x: 6.7,
      y: 1.0,
      w: 3.0,
      h: 4.2,
      fill: { color: theme.light },
      line: { color: theme.accent, width: 1 },
    });
    slide.addText("DAL - Data Access Layer", {
      x: 6.7,
      y: 1.0,
      w: 3.0,
      h: 0.4,
      fontSize: 14,
      fontFace: "Arial",
      color: theme.accent,
      bold: true,
      align: "center",
    });
    slide.addText(
      [
        { text: "clsCN.cs\n\n" },
        { text: "SQL Connection Manager\n" },
        { text: "SelectData()\n" },
        { text: "ExecuteCmd()\n" },
        { text: "IDisposable pattern\n\n" },
        { text: "SQL Injection Protection\n" },
        { text: "via Regex Validation" },
      ],
      {
        x: 6.8,
        y: 1.5,
        w: 2.8,
        h: 3.5,
        fontSize: 12,
        fontFace: "Arial",
        color: theme.primary,
        valign: "top",
      },
    );

    // Page number
    slide.addText("2", {
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
