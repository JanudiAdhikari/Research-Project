const mongoose = require("mongoose");

const QUALITY_STATUSES = [
  "waiting_density", // after step 1
  "waiting_images", // after density step
  "processing", // AI running
  "completed", // report ready
  "failed", // AI failed
];

const PEPPER_TYPES = ["black", "white"];

const PEPPER_VARIETIES = [
  "ceylon_pepper",
  "panniyur_1",
  "kuching",
  "dingi_rala",
  "kohukumbure_rala",
  "bootawe_rala",
  "malabar",
  "unknown",
];

const DRYING_METHODS = ["sun_dried", "machine_dried", "unknown"];

const qualityCheckSchema = new mongoose.Schema(
  {
    batchId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },

    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },
    firebaseUid: { type: String, required: true, index: true },

    status: {
      type: String,
      enum: QUALITY_STATUSES,
      default: "waiting_density",
    },

    batch: {
      pepperType: { type: String, enum: PEPPER_TYPES, required: true },
      pepperVariety: { type: String, enum: PEPPER_VARIETIES, required: true },
      harvestDate: { type: Date, required: true },
      dryingMethod: { type: String, enum: DRYING_METHODS, required: true },
      batchWeightGrams: { type: Number, required: true, min: 1 },
    },

    // Step 2 will update this (bluetooth only, but we keep the field now)
    density: {
      value: { type: Number, default: null }, // g/L
      source: { type: String, default: "bluetooth" },
      measuredAt: { type: Date, default: null },
    },

    // Later you will store only final results (not per image)
    results: {
      overallScore: { type: Number, default: null },
      grade: { type: String, default: null }, // PREMIUM / A / B / C later
      factors: {
        moldPct: { type: Number, default: null },
        abnormalTexturePct: { type: Number, default: null },
        extraneousPct: { type: Number, default: null },
        adulterantPct: { type: Number, default: null },
        healthyVisualPct: { type: Number, default: null },
      },
      improvements: { type: [String], default: [] },
      processedAt: { type: Date, default: null },
    },
  },
  { timestamps: true },
);

module.exports = mongoose.model("QualityCheck", qualityCheckSchema);
