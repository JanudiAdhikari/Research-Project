const mongoose = require("mongoose");

const exportDetailsByCountrySchema = new mongoose.Schema(
  {
    country: { type: String, required: true, index: true },
    pepper_type: { type: String, required: true, index: true },
    year: { type: Number, required: true, index: true },
    export_volume: { type: Number, required: true },
    export_value: { type: Number, required: true },
  },
  { timestamps: true },
);

module.exports = mongoose.model(
  "ExportDetailsByCountry",
  exportDetailsByCountrySchema,
);
