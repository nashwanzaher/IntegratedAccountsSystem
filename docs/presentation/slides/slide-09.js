const pptxgen = require("pptxgenjs");

module.exports = {
  createSlide: function (pres, theme) {
    const slide = pres.addSlide();
    slide.background = { color: theme.bg };

    slide.addText("Database Schema | مخطط قاعدة البيانات", {
      x: 0.5,
      y: 0.3,
      w: 9,
      h: 0.5,
      fontSize: 28,
      fontFace: "Arial",
      color: theme.primary,
      bold: true,
    });

    // Core tables
    const coreTables = [
      {
        name: "tblUsers",
        cols: "userCode(PK), userID, PasswordHash, PasswordSalt, braCode(FK)",
      },
      {
        name: "tblSessions",
        cols: "sessionToken(PK), userCode(FK), expiresAt, isActive",
      },
      {
        name: "tblPermissions",
        cols: "userCode(FK), windowID, privNew, privAdd, privEdit, privDel",
      },
    ];

    let y = 0.9;
    coreTables.forEach((table, i) => {
      slide.addShape(pres.shapes.RECTANGLE, {
        x: 0.5,
        y: y,
        w: 4.4,
        h: 0.75,
        fill: { color: theme.light },
        line: { color: theme.accent, width: 1 },
      });
      slide.addText(table.name, {
        x: 0.6,
        y: y + 0.05,
        w: 4.2,
        h: 0.3,
        fontSize: 12,
        fontFace: "Arial",
        color: theme.accent,
        bold: true,
      });
      slide.addText(table.cols, {
        x: 0.6,
        y: y + 0.35,
        w: 4.2,
        h: 0.35,
        fontSize: 9,
        fontFace: "Arial",
        color: theme.secondary,
      });
      y += 0.85;
    });

    // Transaction tables
    const txTables = [
      {
        name: "tblJournalHeader",
        cols: "jNo(PK), jDate, jPost, totalDebit, totalCredit",
      },
      { name: "tblJournalBody", cols: "jNo(FK), accCode(FK), debit, credit" },
      {
        name: "tblOperationHeader",
        cols: "opNo(PK), opType, accCode, jNo, netTotal",
      },
      {
        name: "tblOperationBody",
        cols: "opNo(FK), prodCode(FK), qty, price, vat",
      },
    ];

    y = 0.9;
    txTables.forEach((table, i) => {
      slide.addShape(pres.shapes.RECTANGLE, {
        x: 5.1,
        y: y,
        w: 4.4,
        h: 0.75,
        fill: { color: theme.light },
        line: { color: theme.primary, width: 1 },
      });
      slide.addText(table.name, {
        x: 5.2,
        y: y + 0.05,
        w: 4.2,
        h: 0.3,
        fontSize: 12,
        fontFace: "Arial",
        color: theme.primary,
        bold: true,
      });
      slide.addText(table.cols, {
        x: 5.2,
        y: y + 0.35,
        w: 4.2,
        h: 0.35,
        fontSize: 9,
        fontFace: "Arial",
        color: theme.secondary,
      });
      y += 0.85;
    });

    // Inventory tables
    slide.addText(
      "Inventory: tblProducts, tblCategories, tblStores, tblProductMovement",
      {
        x: 0.5,
        y: 3.6,
        w: 9,
        h: 0.35,
        fontSize: 12,
        fontFace: "Arial",
        color: theme.accent,
        bold: true,
      },
    );

    const invTables = [
      { name: "tblProducts", cols: "prodCode(PK), prodName, catID(FK), qty" },
      { name: "tblCategories", cols: "catID(PK), catName, saleAccCode" },
      { name: "tblStores", cols: "storeID(PK), storeName" },
      { name: "tblProductMovement", cols: "moveID(PK), prodCode(FK), qty" },
    ];

    y = 4.0;
    let x = 0.5;
    invTables.forEach((table, i) => {
      slide.addShape(pres.shapes.RECTANGLE, {
        x: x,
        y: y,
        w: 2.25,
        h: 0.85,
        fill: { color: theme.light },
        line: { color: theme.secondary, width: 1 },
      });
      slide.addText(table.name, {
        x: x,
        y: y + 0.05,
        w: 2.25,
        h: 0.3,
        fontSize: 10,
        fontFace: "Arial",
        color: theme.secondary,
        bold: true,
        align: "center",
      });
      slide.addText(table.cols, {
        x: x + 0.05,
        y: y + 0.35,
        w: 2.15,
        h: 0.45,
        fontSize: 8,
        fontFace: "Arial",
        color: theme.primary,
      });
      x += 2.35;
    });

    slide.addText("9", {
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
