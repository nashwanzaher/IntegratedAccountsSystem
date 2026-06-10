const pptxgen = require("pptxgenjs");
const fs = require("fs");
const path = require("path");

const pres = new pptxgen();
pres.layout = "LAYOUT_16x9";
pres.title = "IntegratedAccountsSystem Architecture Documentation";
pres.author = "Matrix Agent";

const theme = {
  primary: "1a365d",
  secondary: "4a4e69",
  accent: "0d9488",
  light: "e0f2f1",
  bg: "ffffff",
};

const slidesDir = path.join(__dirname, "slides");
const slideFiles = fs
  .readdirSync(slidesDir)
  .filter((f) => f.match(/^slide-\d+\.js$/))
  .sort();

slideFiles.forEach((file) => {
  const slidePath = path.join(slidesDir, file);
  const slideModule = require(slidePath);
  slideModule.createSlide(pres, theme);
  console.log("Added: " + file);
});

const outputPath = path.join(
  __dirname,
  "output",
  "IntegratedAccountsSystem_Architecture.pptx",
);
fs.mkdirSync(path.dirname(outputPath), { recursive: true });
pres
  .writeFile({ fileName: outputPath })
  .then(() => console.log("Created: " + outputPath))
  .catch((err) => console.error("Error:", err));
