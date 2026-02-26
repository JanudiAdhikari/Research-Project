const router = require("express").Router();
const auth = require("../../middleware/auth.middleware");
const { uploadQualityImages } = require("../../middleware/quality_grading/qualityUpload.middleware");
const {
  createQualityCheck,
  updateDensity,
  analyzeQualityImages,
  getMyQualityChecks,
} = require("../../controllers/quality_grading/qualityCheck.controller");

// Step 1: create new quality check (batch details screen)
router.post("/", auth, createQualityCheck);

// Step 2: density update
router.put("/:id/density", auth, updateDensity);

// Step 3: upload 9 images + run FastAPI + save final result only
router.post("/:id/analyze", auth, uploadQualityImages, analyzeQualityImages);

// Get quality checks for current user - Added by Ashika
router.get("/batchdetails", auth, getMyQualityChecks);

module.exports = router;
