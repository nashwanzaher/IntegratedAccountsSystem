const pptxgen = require("pptxgenjs");

module.exports = {
  createSlide: function (pres, theme) {
    const slide = pres.addSlide();
    slide.background = { color: theme.bg };

    slide.addText("Journal Entry Data Flow | مسار بيانات القيد المحاسبي", {
      x: 0.5,
      y: 0.3,
      w: 9,
      h: 0.5,
      fontSize: 26,
      fontFace: "Arial",
      color: theme.primary,
      bold: true,
    });

    // Journal structure
    slide.addText("Journal Structure:", {
      x: 0.5,
      y: 0.85,
      w: 9,
      h: 0.35,
      fontSize: 14,
      fontFace: "Arial",
      color: theme.accent,
      bold: true,
    });

    // tblJournalHeader
    slide.addShape(pres.shapes.RECTANGLE, {
      x: 0.5,
      y: 1.25,
      w: 4.4,
      h: 1.6,
      fill: { color: theme.light },
      line: { color: theme.accent, width: 1 },
    });
    slide.addText("tblJournalHeader", {
      x: 0.5,
      y: 1.3,
      w: 4.4,
      h: 0.35,
      fontSize: 12,
      fontFace: "Arial",
      color: theme.accent,
      bold: true,
      align: "center",
    });
    slide.addText(
      "jNo, jDate, jNote, jType, jPost\ntotalDebit, totalCredit, userCode, braCode, opType",
      {
        x: 0.6,
        y: 1.7,
        w: 4.2,
        h: 1.0,
        fontSize: 11,
        fontFace: "Arial",
        color: theme.primary,
      },
    );

    // tblJournalBody
    slide.addShape(pres.shapes.RECTANGLE, {
      x: 5.1,
      y: 1.25,
      w: 4.4,
      h: 1.6,
      fill: { color: theme.light },
      line: { color: theme.accent, width: 1 },
    });
    slide.addText("tblJournalBody", {
      x: 5.1,
      y: 1.3,
      w: 4.4,
      h: 0.35,
      fontSize: 12,
      fontFace: "Arial",
      color: theme.accent,
      bold: true,
      align: "center",
    });
    slide.addText("jNo, accCode, currID, currVal\ndebit, credit, note", {
      x: 5.2,
      y: 1.7,
      w: 4.2,
      h: 1.0,
      fontSize: 11,
      fontFace: "Arial",
      color: theme.primary,
    });

    // Journal flow
    slide.addText("Journal Creation Flow:", {
      x: 0.5,
      y: 3.0,
      w: 9,
      h: 0.35,
      fontSize: 14,
      fontFace: "Arial",
      color: theme.accent,
      bold: true,
    });

    const flow = [
      "getNewJournalNo() → Generate next jNo per branch",
      "addJournalHeader() → Insert header with initial totals",
      "addJournalBody() → Insert line items with account codes",
      "Grouping by CatNo → Consolidated posting for same category",
    ];

    let y = 3.4;
    flow.forEach((item, i) => {
      slide.addShape(pres.shapes.OVAL, {
        x: 0.5,
        y: y,
        w: 0.25,
        h: 0.25,
        fill: { color: theme.accent },
      });
      slide.addText(item, {
        x: 0.85,
        y: y,
        w: 8.6,
        h: 0.35,
        fontSize: 12,
        fontFace: "Arial",
        color: theme.primary,
      });
      y += 0.45;
    });

    // Operation-Journal relationship
    slide.addText(
      "Operation-Journal: Sales Bill (opType=4) → Auto-creates Journal | jNo stored in operation header",
      {
        x: 0.5,
        y: 5.0,
        w: 9,
        h: 0.3,
        fontSize: 11,
        fontFace: "Arial",
        color: theme.secondary,
      },
    );

    slide.addText("7", {
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
