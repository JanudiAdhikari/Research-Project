const multer = require("multer");
const path = require("path");

const storage = multer.memoryStorage();

const allowedMime = new Set([
  "image/jpeg",
  "image/jpg",
  "image/png",
  "image/webp",
  "application/pdf",
]);

const allowedExt = new Set([".jpg", ".jpeg", ".png", ".webp", ".pdf"]);

const fileFilter = (req, file, cb) => {
  const mime = (file.mimetype || "").toLowerCase();
  const ext = path.extname(file.originalname || "").toLowerCase();

  // accept if mimetype matches
  if (allowedMime.has(mime)) return cb(null, true);

  // fallback for clients sending application/octet-stream
  if (allowedExt.has(ext)) return cb(null, true);

  return cb(
    new Error("Only JPEG, JPG, PNG, WEBP images or PDF allowed"),
    false,
  );
};

const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB
});

module.exports = upload;