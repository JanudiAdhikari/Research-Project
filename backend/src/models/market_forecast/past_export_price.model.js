const mongoose = require("mongoose");

const pastExportPriceSchema = new mongoose.Schema(
  {
    year: { type: Number, required: true, index: true },
    month: { type: String, required: true, index: true },
    export_volume_kg: { type: Number, required: true },
    export_price_per_kg_lkr: { type: Number, required: true },
  },
  { timestamps: true },
);

module.exports = mongoose.model(
  "PastExportPrice",
  pastExportPriceSchema,
  "past_export_prices",
);
