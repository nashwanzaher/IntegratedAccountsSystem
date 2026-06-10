const pptxgen = require("pptxgenjs");

module.exports = {
  createSlide: function (pres, theme) {
    const slide = pres.addSlide();
    slide.background = { color: theme.bg };

    slide.addText("Class Relationships | علاقات الكلاسات", {
      x: 0.5,
      y: 0.3,
      w: 9,
      h: 0.5,
      fontSize: 28,
      fontFace: "Arial",
      color: theme.primary,
      bold: true,
    });

    // BL Classes
    const classes = [
      {
        name: "clsUsers",
        methods: "Login(), getAllUsers(), addUser(), ApplyPrivileges()",
      },
      {
        name: "clsInventory",
        methods:
          "addOperationHdr(), addProductMovement(), getBillOrBondNewNo()",
      },
      {
        name: "clsjournal",
        methods: "addJournalHeader(), addJournalBody(), delJournalEntry()",
      },
      {
        name: "clsSysFormat",
        methods: "getAllCurrencies(), getAllFunds(), getExchangeCurrency()",
      },
    ];

    let y = 0.85;
    classes.forEach((cls, i) => {
      slide.addShape(pres.shapes.RECTANGLE, {
        x: 0.5,
        y: y,
        w: 4.4,
        h: 0.95,
        fill: { color: theme.light },
        line: { color: theme.accent, width: 1 },
      });
      slide.addText(cls.name, {
        x: 0.6,
        y: y + 0.08,
        w: 4.2,
        h: 0.35,
        fontSize: 14,
        fontFace: "Arial",
        color: theme.accent,
        bold: true,
      });
      slide.addText(cls.methods, {
        x: 0.6,
        y: y + 0.45,
        w: 4.2,
        h: 0.45,
        fontSize: 10,
        fontFace: "Arial",
        color: theme.secondary,
      });
      y += 1.05;
    });

    // Security Classes
    slide.addText("Security Classes:", {
      x: 5.1,
      y: 0.85,
      w: 4.4,
      h: 0.35,
      fontSize: 14,
      fontFace: "Arial",
      color: theme.primary,
      bold: true,
    });

    const secClasses = [
      {
        name: "SessionContext",
        methods: "Create(), Validate(), UpdateActivity(), End()",
      },
      {
        name: "PasswordHelper",
        methods: "Verify(), ComputeHash(), CreatePasswordRecord()",
      },
      {
        name: "AuditHelper",
        methods: "LogLoginSuccess(), LogLoginFailure(), LogSessionCreated()",
      },
    ];

    y = 1.25;
    secClasses.forEach((cls, i) => {
      slide.addShape(pres.shapes.RECTANGLE, {
        x: 5.1,
        y: y,
        w: 4.4,
        h: 0.85,
        fill: { color: theme.light },
        line: { color: theme.primary, width: 1 },
      });
      slide.addText(cls.name, {
        x: 5.2,
        y: y + 0.08,
        w: 4.2,
        h: 0.3,
        fontSize: 13,
        fontFace: "Arial",
        color: theme.primary,
        bold: true,
      });
      slide.addText(cls.methods, {
        x: 5.2,
        y: y + 0.4,
        w: 4.2,
        h: 0.4,
        fontSize: 10,
        fontFace: "Arial",
        color: theme.secondary,
      });
      y += 0.95;
    });

    // DAL
    slide.addShape(pres.shapes.RECTANGLE, {
      x: 5.1,
      y: 4.1,
      w: 4.4,
      h: 0.8,
      fill: { color: theme.light },
      line: { color: theme.secondary, width: 2 },
    });
    slide.addText("DAL: clsCN.cs", {
      x: 5.1,
      y: 4.15,
      w: 4.4,
      h: 0.35,
      fontSize: 13,
      fontFace: "Arial",
      color: theme.secondary,
      bold: true,
      align: "center",
    });
    slide.addText("SelectData(), ExecuteCmd(), IDisposable", {
      x: 5.2,
      y: 4.5,
      w: 4.2,
      h: 0.35,
      fontSize: 10,
      fontFace: "Arial",
      color: theme.primary,
      align: "center",
    });

    // Dependencies note
    slide.addText("PL Forms → BL Classes → DAL + Security Classes", {
      x: 0.5,
      y: 5.1,
      w: 9,
      h: 0.3,
      fontSize: 11,
      fontFace: "Arial",
      color: theme.secondary,
      italic: true,
    });

    slide.addText("10", {
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
