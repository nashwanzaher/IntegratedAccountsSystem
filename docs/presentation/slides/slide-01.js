const pptxgen = require("pptxgenjs");
const path = require("path");

module.exports = {
  createSlide: function (pres, theme) {
    const slide = pres.addSlide();
    slide.background = { color: theme.bg };

    // Title
    slide.addText("IntegratedAccountsSystem", {
      x: 0.5,
      y: 0.4,
      w: 9,
      h: 0.6,
      fontSize: 36,
      fontFace: "Arial",
      color: theme.primary,
      bold: true,
    });

    // Subtitle
    slide.addText("Architecture Documentation", {
      x: 0.5,
      y: 1.0,
      w: 9,
      h: 0.4,
      fontSize: 20,
      fontFace: "Arial",
      color: theme.secondary,
    });

    // Content box
    slide.addShape(pres.shapes.RECTANGLE, {
      x: 0.5,
      y: 1.6,
      w: 9,
      h: 3.5,
      fill: { color: theme.light },
      line: { color: theme.accent, width: 1 },
    });

    slide.addText(
      [
        { text: "Project: ", options: { bold: true } },
        { text: "IntegratedAccountsSystem - Arabic Accounting System\n" },
        { text: "Architecture: ", options: { bold: true } },
        { text: "WinForms 3-Tier (PL/BL/DAL)\n" },
        { text: "Database: ", options: { bold: true } },
        { text: "SQL Server - accountSysDB\n" },
        { text: "Forms: ", options: { bold: true } },
        { text: "74 WinForms\n" },
        { text: "Security: ", options: { bold: true } },
        { text: "PBKDF2-SHA256 (100,000 iterations)" },
      ],
      {
        x: 0.7,
        y: 1.8,
        w: 8.6,
        h: 3.1,
        fontSize: 16,
        fontFace: "Arial",
        color: theme.primary,
        valign: "top",
      },
    );

    // Page number
    slide.addText("1", {
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
