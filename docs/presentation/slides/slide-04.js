const pptxgen = require("pptxgenjs");

module.exports = {
  createSlide: function (pres, theme) {
    const slide = pres.addSlide();
    slide.background = { color: theme.bg };

    slide.addText("Authentication Flow | مسار المصادقة", {
      x: 0.5,
      y: 0.3,
      w: 9,
      h: 0.5,
      fontSize: 28,
      fontFace: "Arial",
      color: theme.primary,
      bold: true,
    });

    // Flow steps
    const steps = [
      { num: "1", text: "User enters credentials (userID, password, braCode)" },
      { num: "2", text: "frmLogin.btnLogin_Click() triggers clsUsers.Login()" },
      { num: "3", text: "3-Tier Password Verification:" },
      { num: "4", text: "  Tier 1: PBKDF2-SHA256 (100,000 iterations)" },
      { num: "5", text: "  Tier 2: Legacy SHA-256 (auto-upgrade on login)" },
      { num: "6", text: "  Tier 3: Plaintext (security warning logged)" },
      { num: "7", text: "SessionContext.Create() → createSession SP" },
      { num: "8", text: "NEWID() token generated, stored in tblSessions" },
      {
        num: "9",
        text: "AuditHelper.LogLoginSuccess() → frmMainWindow.Show()",
      },
    ];

    let y = 0.9;
    steps.forEach((step, i) => {
      slide.addShape(pres.shapes.OVAL, {
        x: 0.5,
        y: y,
        w: 0.35,
        h: 0.35,
        fill: { color: theme.accent },
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
        h: 0.35,
        fontSize: 13,
        fontFace: "Arial",
        color: theme.primary,
        valign: "middle",
      });
      y += 0.5;
    });

    slide.addText("4", {
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
