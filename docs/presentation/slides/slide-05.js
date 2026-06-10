const pptxgen = require("pptxgenjs");

module.exports = {
  createSlide: function (pres, theme) {
    const slide = pres.addSlide();
    slide.background = { color: theme.bg };

    slide.addText("Session Management | إدارة الجلسات", {
      x: 0.5,
      y: 0.3,
      w: 9,
      h: 0.5,
      fontSize: 28,
      fontFace: "Arial",
      color: theme.primary,
      bold: true,
    });

    // Session states
    const states = [
      { name: "NEW", desc: "Token generated via NEWID()", color: theme.accent },
      {
        name: "ACTIVE",
        desc: "Validated, sliding expiry reset",
        color: "10B981",
      },
      {
        name: "EXPIRED",
        desc: "expiresAt < GETDATE(), isActive=0",
        color: "6B7280",
      },
      {
        name: "ENDED",
        desc: "Logout or app exit, isActive=0",
        color: "EF4444",
      },
    ];

    let x = 0.5;
    states.forEach((state, i) => {
      slide.addShape(pres.shapes.RECTANGLE, {
        x: x,
        y: 1.0,
        w: 2.2,
        h: 1.8,
        fill: { color: theme.light },
        line: { color: state.color, width: 2 },
      });
      slide.addText(state.name, {
        x: x,
        y: 1.1,
        w: 2.2,
        h: 0.5,
        fontSize: 18,
        fontFace: "Arial",
        color: state.color,
        bold: true,
        align: "center",
      });
      slide.addText(state.desc, {
        x: x + 0.1,
        y: 1.6,
        w: 2.0,
        h: 1.0,
        fontSize: 11,
        fontFace: "Arial",
        color: theme.secondary,
        align: "center",
      });
      if (i < 3) {
        slide.addText("→", {
          x: x + 2.2,
          y: 1.5,
          w: 0.4,
          h: 0.5,
          fontSize: 24,
          fontFace: "Arial",
          color: theme.accent,
          align: "center",
        });
      }
      x += 2.6;
    });

    // Stored procedures
    slide.addText("SessionContext Static Fields:", {
      x: 0.5,
      y: 3.0,
      w: 4.5,
      h: 0.4,
      fontSize: 14,
      fontFace: "Arial",
      color: theme.accent,
      bold: true,
    });
    slide.addText(
      [
        { text: "_sessionToken: Guid?\n" },
        { text: "_sessionUserCode: int?\n" },
        { text: "_sessionUserID: string\n" },
        { text: "_sessionBraCode: int?" },
      ],
      {
        x: 0.5,
        y: 3.4,
        w: 4.5,
        h: 1.5,
        fontSize: 12,
        fontFace: "Arial",
        color: theme.primary,
      },
    );

    slide.addText("Stored Procedures:", {
      x: 5.2,
      y: 3.0,
      w: 4.5,
      h: 0.4,
      fontSize: 14,
      fontFace: "Arial",
      color: theme.accent,
      bold: true,
    });
    slide.addText(
      [
        { text: "createSession, validateSession\n" },
        { text: "updateSessionActivity, endSession\n" },
        { text: "expireOldSessions" },
      ],
      {
        x: 5.2,
        y: 3.4,
        w: 4.5,
        h: 1.5,
        fontSize: 12,
        fontFace: "Arial",
        color: theme.primary,
      },
    );

    slide.addText("5", {
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
