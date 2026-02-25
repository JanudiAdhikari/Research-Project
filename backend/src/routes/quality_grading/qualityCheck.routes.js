const router = require("express").Router();
const auth = require("../../middleware/auth.middleware");
const { uploadQualityImages } = require("../../middleware/quality_grading/qualityUpload.middleware");
const {
  createQualityCheck,
  updateDensity,
  analyzeQualityImages,
} = require("../../controllers/quality_grading/qualityCheck.controller");

// Step 1: create new quality check (batch details screen)
router.post("/", auth, createQualityCheck);

// Step 2: density update
router.put("/:id/density", auth, updateDensity);

// Step 3: upload 9 images + run FastAPI + save final result only
router.post("/:id/analyze", auth, uploadQualityImages, analyzeQualityImages);

module.exports = router;
