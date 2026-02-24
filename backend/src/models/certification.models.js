const mongoose = require("mongoose");

const certificationSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },
    firebaseUid: {
      type: String,
      required: true,
      index: true,
    },

    certificationType: { type: String, required: true, trim: true },
    certificateNumber: { type: String, required: true, trim: true },
    issuingBody: { type: String, required: true, trim: true },

    issueDate: { type: Date, required: true },
    expiryDate: { type: Date, required: true },

    // optional
    attachment: {
      url: { type: String, default: null },
      publicId: { type: String, default: null },
      resourceType: { type: String, default: null }, // "image" or "raw"
      originalName: { type: String, default: null },
    },

    status: {
      type: String,
      enum: ["pending", "verified", "rejected"],
      default: "pending",
      index: true,
    },

    verifiedBy: {
      type: String,
      enum: ["system", "admin", null],
      default: null,
    },
    verificationDate: {
      type: Date,
      default: null,
    },

    rejectionReason: {
      type: String,
      default: null,
      trim: true,
    },
  },
  { timestamps: true }
);

// Prevent duplicates per User
certificationSchema.index({ firebaseUid: 1, certificateNumber: 1 }, { unique: true });

module.exports = mongoose.model("Certification", certificationSchema);