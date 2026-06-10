const pptxgen = require("pptxgenjs");

module.exports = {
  createSlide: function (pres, theme) {
    const slide = pres.addSlide();
    slide.background = { color: theme.bg };

    slide.addText("3-Tier Architecture | البنية ثلاثية الطبقات", {
      x: 0.5,
      y: 0.3,
      w: 9,
      h: 0.5,
      fontSize: 28,
      fontFace: "Arial",
      color: theme.primary,
      bold: true,
    });

    // PL Layer
    slide.addShape(pres.shapes.RECTANGLE, {
      x: 0.5,
      y: 1.0,
      w: 9,
      h: 1.2,
      fill: { color: theme.light },
      line: { color: theme.accent, width: 2 },
    });
    slide.addText("Presentation Layer (PL) - WinForms C# | 74 Forms", {
      x: 0.6,
      y: 1.1,
      w: 8.8,
      h: 0.4,
      fontSize: 16,
      fontFace: "Arial",
      color: theme.accent,
      bold: true,
    });
    slide.addText(
      "User Interface - Form Load, Privilege Enforcement, UI Rendering",
      {
        x: 0.6,
        y: 1.5,
        w: 8.8,
        h: 0.5,
        fontSize: 12,
        fontFace: "Arial",
        color: theme.secondary,
      },
    );

    // Arrow down
    slide.addShape(pres.shapes.DOWN_ARROW, {
      x: 4.5,
      y: 2.3,
      w: 1,
      h: 0.4,
      fill: { color: theme.accent },
    });

    // BL Layer
    slide.addShape(pres.shapes.RECTANGLE, {
      x: 0.5,
      y: 2.8,
      w: 9,
      h: 1.2,
      fill: { color: theme.light },
      line: { color: theme.accent, width: 2 },
    });
    slide.addText("Business Layer (BL) - Class Library | 10 Modules", {
      x: 0.6,
      y: 2.9,
      w: 8.8,
      h: 0.4,
      fontSize: 16,
      fontFace: "Arial",
      color: theme.accent,
      bold: true,
    });
    slide.addText(
      "Business Logic - Validation, Data Transformation, Transaction Coordination",
      {
        x: 0.6,
        y: 3.3,
        w: 8.8,
        h: 0.5,
        fontSize: 12,
        fontFace: "Arial",
        color: theme.secondary,
      },
    );

    // Arrow down
    slide.addShape(pres.shapes.DOWN_ARROW, {
      x: 4.5,
      y: 4.1,
      w: 1,
      h: 0.4,
      fill: { color: theme.accent },
    });

    // DAL Layer
    slide.addShape(pres.shapes.RECTANGLE, {
      x: 0.5,
      y: 4.6,
      w: 9,
      h: 0.9,
      fill: { color: theme.light },
      line: { color: theme.primary, width: 2 },
    });
    slide.addText(
      "Data Access Layer (DAL) - clsCN.cs | SQL Connection Manager",
      {
        x: 0.6,
        y: 4.7,
        w: 8.8,
        h: 0.4,
        fontSize: 14,
        fontFace: "Arial",
        color: theme.primary,
        bold: true,
      },
    );
    slide.addText("Stored Procedures - accountSysDB", {
      x: 0.6,
      y: 5.05,
      w: 8.8,
      h: 0.3,
      fontSize: 11,
      fontFace: "Arial",
      color: theme.secondary,
    });

    slide.addText("3", {
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
