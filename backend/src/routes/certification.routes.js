const express = require("express");
const verifyToken = require("../middleware/auth.middleware");
const authorizedRoles = require("../middleware/role.middleware");
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

// USER
router.post("/", verifyToken, createCertification);
router.get("/me", verifyToken, getMyCertifications);

// ADMIN
router.get(
  "/admin/all",
  verifyToken,
  authorizedRoles("admin"),
  adminListCertifications,
);

router.patch(
  "/admin/:id/verify",
  verifyToken,
  authorizedRoles("admin"),
  adminVerifyCertification,
);

// USER single + update + delete
router.get("/:id", verifyToken, getCertificationById);
router.patch("/:id", verifyToken, updateMyCertification);
router.delete("/:id", verifyToken, deleteMyCertification);

module.exports = router;
