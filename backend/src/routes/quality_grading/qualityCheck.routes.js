const router = require("express").Router();
const auth = require("../../middleware/auth.middleware");
const { createQualityCheck } = require("../../controllers/quality_grading/qualityCheck.controller");

// Step 1: create new quality check (batch details screen)
router.post("/", auth, createQualityCheck);

module.exports = router;