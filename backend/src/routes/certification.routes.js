const express = require("express");
const verifyToken = require("../middleware/auth.middleware");
const authorizedRoles = require("../middleware/role.middleware");
const upload = require("../middleware/upload.middleware");
const {
  createCertification,
  getMyCertifications,
  getCertificationById,
  updateMyCertification,
  deleteMyCertification,
  adminListCertifications,
  adminVerifyCertification,
} = require("../controllers/certification.controller");

const router = express.Router();

// USER (multipart because optional file)
router.post("/", verifyToken, upload.single("attachment"), createCertification);
router.get("/me", verifyToken, getMyCertifications);

// ADMIN
router.get("/admin/all", verifyToken, authorizedRoles("admin"), adminListCertifications);
router.patch("/admin/:id/verify", verifyToken, authorizedRoles("admin"), adminVerifyCertification);

// USER single + update + delete (update may include new attachment)
router.get("/:id", verifyToken, getCertificationById);
router.patch("/:id", verifyToken, upload.single("attachment"), updateMyCertification);
router.delete("/:id", verifyToken, deleteMyCertification);

module.exports = router;