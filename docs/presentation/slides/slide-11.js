const pptxgen = require("pptxgenjs");

module.exports = {
  createSlide: function (pres, theme) {
    const slide = pres.addSlide();
    slide.background = { color: theme.bg };

    slide.addText("Security Architecture | البنية الأمنية", {
      x: 0.5,
      y: 0.3,
      w: 9,
      h: 0.5,
      fontSize: 28,
      fontFace: "Arial",
      color: theme.primary,
      bold: true,
    });

    // Password tiers
    slide.addText("Password Security - 3 Tiers:", {
      x: 0.5,
      y: 0.85,
      w: 9,
      h: 0.35,
      fontSize: 14,
      fontFace: "Arial",
      color: theme.accent,
      bold: true,
    });

    const tiers = [
      {
        tier: "Tier 1",
        name: "PBKDF2-SHA256",
        desc: "100,000 iterations, 32-byte salt, constant-time verify",
        color: "10B981",
      },
      {
        tier: "Tier 2",
        name: "SHA-256 Legacy",
        desc: "Auto-upgrade on successful login",
        color: "F59E0B",
      },
      {
        tier: "Tier 3",
        name: "Plaintext",
        desc: "Security warning logged, auto-upgrade",
        color: "EF4444",
      },
    ];

    let x = 0.5;
    tiers.forEach((t, i) => {
      slide.addShape(pres.shapes.RECTANGLE, {
        x: x,
        y: 1.25,
        w: 3.0,
        h: 1.1,
        fill: { color: theme.light },
        line: { color: t.color, width: 2 },
      });
      slide.addText(t.tier + ": " + t.name, {
        x: x,
        y: 1.3,
        w: 3.0,
        h: 0.4,
        fontSize: 12,
        fontFace: "Arial",
        color: t.color,
        bold: true,
        align: "center",
      });
      slide.addText(t.desc, {
        x: x + 0.1,
        y: 1.7,
        w: 2.8,
        h: 0.6,
        fontSize: 10,
        fontFace: "Arial",
        color: theme.secondary,
        align: "center",
      });
      x += 3.15;
    });

    // SQL Injection Prevention
    slide.addText("SQL Injection Prevention:", {
      x: 0.5,
      y: 2.5,
      w: 4.5,
      h: 0.35,
      fontSize: 14,
      fontFace: "Arial",
      color: theme.accent,
      bold: true,
    });

    slide.addShape(pres.shapes.RECTANGLE, {
      x: 0.5,
      y: 2.9,
      w: 4.5,
      h: 2.0,
      fill: { color: theme.light },
      line: { color: theme.accent, width: 1 },
    });
    slide.addText(
      [
        { text: "clsCN.ValidateStoredProcedureCall()\n\n" },
        { text: "1. IsNullOrWhiteSpace check\n" },
        { text: "2. Length <= 128 check\n" },
        { text: "3. Regex: ^[a-zA-Z_][a-zA-Z0-9_]*$\n" },
        { text: "4. Blocked: SELECT, INSERT, UPDATE,\n" },
        { text: "   DELETE, DROP, UNION, xp_, sp_\n\n" },
        { text: "All input via SqlParameter[] arrays" },
      ],
      {
        x: 0.6,
        y: 3.0,
        w: 4.3,
        h: 1.8,
        fontSize: 10,
        fontFace: "Arial",
        color: theme.primary,
      },
    );

    // Session Security
    slide.addText("Session Security:", {
      x: 5.2,
      y: 2.5,
      w: 4.5,
      h: 0.35,
      fontSize: 14,
      fontFace: "Arial",
      color: theme.accent,
      bold: true,
    });

    slide.addShape(pres.shapes.RECTANGLE, {
      x: 5.2,
      y: 2.9,
      w: 4.3,
      h: 2.0,
      fill: { color: theme.light },
      line: { color: theme.primary, width: 1 },
    });
    slide.addText(
      [
        { text: "Token Security:\n", options: { bold: true } },
        { text: "  NEWID() for unpredictable tokens\n\n" },
        { text: "Sliding Expiration:\n", options: { bold: true } },
        { text: "  1-hour sliding window\n" },
        { text: "  DATEADD(HOUR, 1) on Validate()\n\n" },
        { text: "Audit Trail:\n", options: { bold: true } },
        { text: "  Async fire-and-forget logging" },
      ],
      {
        x: 5.3,
        y: 3.0,
        w: 4.1,
        h: 1.8,
        fontSize: 10,
        fontFace: "Arial",
        color: theme.primary,
      },
    );

    slide.addText(
      "Defense in Depth: Multiple security layers protect the system",
      {
        x: 0.5,
        y: 5.1,
        w: 9,
        h: 0.3,
        fontSize: 11,
        fontFace: "Arial",
        color: theme.secondary,
        italic: true,
      },
    );

    slide.addText("11", {
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
