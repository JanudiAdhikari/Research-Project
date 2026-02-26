const multer = require("multer");

const storage = multer.memoryStorage();

const upload = multer({
  storage,
  limits: {
    fileSize: 8 * 1024 * 1024, // 8MB per image
  },
});

const fields = [
  { name: "bottom_full", maxCount: 1 },
  { name: "bottom_half", maxCount: 1 },
  { name: "bottom_close", maxCount: 1 },
  { name: "middle_full", maxCount: 1 },
  { name: "middle_half", maxCount: 1 },
  { name: "middle_close", maxCount: 1 },
  { name: "top_full", maxCount: 1 },
  { name: "top_half", maxCount: 1 },
  { name: "top_close", maxCount: 1 },
];

module.exports = {
  uploadQualityImages: upload.fields(fields),
  EXPECTED_FIELDS: fields.map((f) => f.name),
};