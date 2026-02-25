const axios = require("axios");
const FormData = require("form-data");

const QualityCheck = require("../../models/quality_grading/qualityCheck.model");
const User = require("../../models/user.models");
const {
  EXPECTED_FIELDS,
} = require("../../middleware/quality_grading/qualityUpload.middleware");

// Step 1: Batch Information
const toGrams = (kg, g) => {
  const kgNum = Number(kg || 0);
  const gNum = Number(g || 0);
  if (Number.isNaN(kgNum) || Number.isNaN(gNum)) return null;
  const total = Math.round(kgNum * 1000 + gNum);
  return total > 0 ? total : null;
};

exports.createQualityCheck = async (req, res) => {
  try {
    // Firebase decoded token
    const decoded = req.user;
    const firebaseUid = decoded?.uid; // THIS is the correct field from Firebase token

    if (!firebaseUid) {
      return res.status(401).json({ message: "Unauthorized (missing uid)" });
    }

    // Find your Mongo user by firebase uid
    // Use the correct field name from your User schema:
    // Common options: firebaseUid, uid, firebaseUID
    const dbUser =
      (await User.findOne({ firebaseUid })) ||
      (await User.findOne({ uid: firebaseUid }));

    if (!dbUser) {
      return res.status(404).json({
        message: "User not found in DB for this Firebase account",
      });
    }

    const {
      pepperType,
      pepperVariety,
      harvestDate,
      dryingMethod,
      batchWeightKg,
      batchWeightG,
    } = req.body;

    const batchWeightGrams = toGrams(batchWeightKg, batchWeightG);
    if (!batchWeightGrams) {
      return res.status(400).json({ message: "Invalid batch weight" });
    }

    const harvest = new Date(harvestDate);
    if (Number.isNaN(harvest.getTime())) {
      return res.status(400).json({ message: "Invalid harvest date" });
    }

    const qc = await QualityCheck.create({
      userId: dbUser._id,
      firebaseUid,
      status: "waiting_density",
      batch: {
        pepperType,
        pepperVariety,
        harvestDate: harvest,
        dryingMethod,
        batchWeightGrams,
      },
      density: {
        value: null,
        source: "bluetooth",
        measuredAt: null,
      },
    });

    return res.status(201).json({
      qualityCheckId: qc._id,
      status: qc.status,
    });
  } catch (err) {
    console.error("createQualityCheck error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

// Step 2: update density
exports.updateDensity = async (req, res) => {
  try {
    const firebaseUid = req.user?.uid;
    if (!firebaseUid) return res.status(401).json({ message: "Unauthorized" });

    // Find DB user
    const dbUser =
      (await User.findOne({ firebaseUid })) ||
      (await User.findOne({ uid: firebaseUid }));

    if (!dbUser) {
      return res.status(404).json({ message: "User not found in DB" });
    }

    const { id } = req.params;

    // For now accept the value from app (later your app will only send Bluetooth readings)
    const { value } = req.body;

    const densityValue = Number(value);
    if (Number.isNaN(densityValue) || densityValue <= 0) {
      return res.status(400).json({ message: "Invalid density value" });
    }

    const qc = await QualityCheck.findOneAndUpdate(
      { _id: id, userId: dbUser._id },
      {
        $set: {
          "density.value": densityValue,
          "density.source": "bluetooth",
          "density.measuredAt": new Date(),
          status: "waiting_images",
        },
      },
      { new: true },
    );

    if (!qc) {
      return res.status(404).json({ message: "Quality check not found" });
    }

    return res.status(200).json({
      qualityCheckId: qc._id,
      status: qc.status,
      density: qc.density,
    });
  } catch (err) {
    console.error("updateDensity error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

// Step 3
// POST /api/quality-checks/:id/analyze
exports.analyzeQualityImages = async (req, res) => {
  try {
    const firebaseUid = req.user?.uid;
    if (!firebaseUid) return res.status(401).json({ message: "Unauthorized" });

    const dbUser =
      (await User.findOne({ firebaseUid })) ||
      (await User.findOne({ uid: firebaseUid }));

    if (!dbUser)
      return res.status(404).json({ message: "User not found in DB" });

    const { id } = req.params;

    // Ensure quality check exists and belongs to user
    const qc = await QualityCheck.findOne({ _id: id, userId: dbUser._id });
    if (!qc)
      return res.status(404).json({ message: "Quality check not found" });

    // Ensure density exists before analyzing
    if (!qc.density?.value) {
      return res
        .status(400)
        .json({ message: "Density not found. Complete step 2 first." });
    }

    // Validate 9 images exist in request
    const files = req.files || {};
    const missing = EXPECTED_FIELDS.filter(
      (k) => !files[k] || files[k].length === 0,
    );

    if (missing.length > 0) {
      return res.status(400).json({
        message: "Missing required images",
        missing,
      });
    }

    // Update status -> processing
    qc.status = "processing";
    await qc.save();

    // Build form-data to send to FastAPI
    const form = new FormData();

    for (const field of EXPECTED_FIELDS) {
      const f = files[field][0];
      form.append(field, f.buffer, {
        filename: f.originalname || `${field}.jpg`,
        contentType: f.mimetype || "image/jpeg",
      });
    }

    // optional toggle
    form.append("texture_first", "true");

    const fastapiUrl = `${process.env.FASTAPI_BASE_URL}/infer/quality`;

    const response = await axios.post(fastapiUrl, form, {
      headers: {
        ...form.getHeaders(),
      },
      maxBodyLength: Infinity,
      maxContentLength: Infinity,
      timeout: 120000, // 120s
    });

    // FastAPI returns: { samples, final, details, meta }
    // You want only final avg to save
    const finalAvg = response.data?.final;

    if (!finalAvg) {
      qc.status = "failed";
      await qc.save();
      return res
        .status(502)
        .json({ message: "FastAPI response missing final results" });
    }

    // Map FastAPI fields -> Mongo fields
    const mappedFactors = {
      adulterantPct: Number(finalAvg.adulterant_seed_pct ?? 0),
      extraneousPct: Number(finalAvg.extraneous_matter_pct ?? 0),
      moldPct: Number(finalAvg.mold_pct ?? 0),
      abnormalTexturePct: Number(finalAvg.abnormal_texture_pct ?? 0),
      healthyVisualPct: Number(finalAvg.healthy_visual_pct ?? 0),
    };

    // Save only the final results (score/grade you will implement later)
    qc.results = {
      ...qc.results,
      factors: mappedFactors,
      processedAt: new Date(),
    };

    // For now keep grade/score empty until your ISO logic is ready
    qc.status = "completed";
    await qc.save();

    return res.status(200).json({
      qualityCheckId: qc._id,
      status: qc.status,
      factors: qc.results.factors,
    });
  } catch (err) {
    console.error(
      "analyzeQualityImages error:",
      err?.response?.data || err.message,
    );

    // Try to mark failed if we know the id
    try {
      if (req.params?.id) {
        await QualityCheck.findByIdAndUpdate(req.params.id, {
          status: "failed",
        });
      }
    } catch (err) {
      console.error("FASTAPI CALL FAILED");
      console.error("code:", err.code);
      console.error("message:", err.message);
      console.error("status:", err.response?.status);
      console.error("data:", err.response?.data);

      try {
        if (req.params?.id) {
          await QualityCheck.findByIdAndUpdate(req.params.id, {
            status: "failed",
          });
        }
      } catch (_) {}

      return res.status(500).json({
        message: "Server error during image analysis",
        error: err.message,
        fastapiStatus: err.response?.status,
        fastapiData: err.response?.data,
      });
    }
  }
};
