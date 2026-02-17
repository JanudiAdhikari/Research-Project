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

// Prevent duplicates per user
certificationSchema.index(
  { firebaseUid: 1, certificateNumber: 1 },
  { unique: true }
);

module.exports = mongoose.model("Certification", certificationSchema);
