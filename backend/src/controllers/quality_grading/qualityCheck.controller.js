const QualityCheck = require("../../models/quality_grading/qualityCheck.model");
const User = require("../../models/user.models"); // adjust path if different

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
