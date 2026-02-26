const mongoose = require("mongoose");

const QUALITY_STATUSES = [
  "waiting_density",
  "waiting_images",
  "processing",
  "completed",
  "failed",
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
    batchId: { type: String, required: true, unique: true, index: true },

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

    density: {
      value: { type: Number, default: null }, // g/L
      source: { type: String, default: "bluetooth" },
      measuredAt: { type: Date, default: null },
    },

    certificatesSnapshot: {
      items: [
        {
          certId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Certification",
          },
          certificationType: { type: String, default: null },
          certificateNumber: { type: String, default: null },
          issuingBody: { type: String, default: null },
          issueDate: { type: Date, default: null },
          expiryDate: { type: Date, default: null },
          attachmentUrl: { type: String, default: null },
        },
      ],
      count: { type: Number, default: 0 },
      capturedAt: { type: Date, default: null },
    },

    results: {
      overallScore: { type: Number, default: null },
      grade: { type: String, default: null },

      factorScores: {
        density: { type: Number, default: null },
        adulteration: { type: Number, default: null },
        mold: { type: Number, default: null },
        extraneous: { type: Number, default: null },
        broken: { type: Number, default: null },
        varietyPiperine: { type: Number, default: null },
        healthyVisual: { type: Number, default: null },
        certBonus: { type: Number, default: null },
      },

      hardReject: { type: Boolean, default: false },
      hardRejectReasons: { type: [String], default: [] },

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
