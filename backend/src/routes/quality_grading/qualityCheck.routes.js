const router = require("express").Router();
const auth = require("../../middleware/auth.middleware");
const {
  createQualityCheck,
  updateDensity,
} = require("../../controllers/quality_grading/qualityCheck.controller");

// Step 1: create new quality check (batch details screen)
router.post("/", auth, createQualityCheck);

// Step 2: density update
router.put("/:id/density", auth, updateDensity);

module.exports = router;
