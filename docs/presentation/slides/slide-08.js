const pptxgen = require("pptxgenjs");

module.exports = {
  createSlide: function (pres, theme) {
    const slide = pres.addSlide();
    slide.background = { color: theme.bg };

    slide.addText("Privilege System | نظام الصلاحيات", {
      x: 0.5,
      y: 0.3,
      w: 9,
      h: 0.5,
      fontSize: 28,
      fontFace: "Arial",
      color: theme.primary,
      bold: true,
    });

    // 6 permissions grid
    const perms = [
      { name: "privNew", desc: "Create new records" },
      { name: "privAdd", desc: "Save/add operations" },
      { name: "privEdit", desc: "Modify records" },
      { name: "privDel", desc: "Delete operations" },
      { name: "privPrint", desc: "Print reports" },
      { name: "privDisplay", desc: "View/access screen" },
    ];

    let x = 0.5;
    let y = 0.9;
    perms.forEach((perm, i) => {
      slide.addShape(pres.shapes.RECTANGLE, {
        x: x,
        y: y,
        w: 3.0,
        h: 0.8,
        fill: { color: theme.light },
        line: { color: theme.accent, width: 1 },
      });
      slide.addText(perm.name, {
        x: x,
        y: y + 0.1,
        w: 3.0,
        h: 0.35,
        fontSize: 14,
        fontFace: "Arial",
        color: theme.accent,
        bold: true,
        align: "center",
      });
      slide.addText(perm.desc, {
        x: x,
        y: y + 0.45,
        w: 3.0,
        h: 0.3,
        fontSize: 11,
        fontFace: "Arial",
        color: theme.secondary,
        align: "center",
      });
      x += 3.15;
      if ((i + 1) % 3 === 0) {
        x = 0.5;
        y += 0.9;
      }
    });

    // Application flow
    slide.addText("Privilege Application Flow:", {
      x: 0.5,
      y: 2.8,
      w: 9,
      h: 0.35,
      fontSize: 14,
      fontFace: "Arial",
      color: theme.accent,
      bold: true,
    });

    const steps = [
      "Form Load → ApplyPrivileges(form, windowID)",
      "getScreensPrivillages(userCode, windowID, braCode)",
      "Returns privilege row or empty",
      "Default-deny: if no row, disable all buttons",
      "Enable/disable by button name (btnNew, btnAdd, btnEdit, btnDel, btnPrint)",
    ];

    y = 3.2;
    steps.forEach((step, i) => {
      slide.addText(i + 1 + ". " + step, {
        x: 0.5,
        y: y,
        w: 9,
        h: 0.35,
        fontSize: 12,
        fontFace: "Arial",
        color: theme.primary,
      });
      y += 0.4;
    });

    slide.addText("Per-user, per-screen, per-branch privilege matrix", {
      x: 0.5,
      y: 5.1,
      w: 9,
      h: 0.3,
      fontSize: 11,
      fontFace: "Arial",
      color: theme.secondary,
      italic: true,
    });

    slide.addText("8", {
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
