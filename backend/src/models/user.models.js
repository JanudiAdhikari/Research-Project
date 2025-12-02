const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    firebaseUid: {
      type: String,
      required: true,
      unique: true,
    },
    email: {
      type: String,
      required: true,
    },
    firstName: String,
    lastName: String,
    contact: String,

    role: {
      type: String,
      enum: ["farmer", "exporter", "admin"],
      default: "farmer",
    },

    profileImageUrl: String,
  },
  { timestamps: true }
);

module.exports = mongoose.model("User", userSchema);
