const mongoose = require("mongoose");

const actualPriceDataSchema = new mongoose.Schema(
  {
    saleDate: { type: Date, required: true, index: true },
    pepperType: { type: String, required: true, index: true },
    grade: { type: String, required: true, index: true },
    district: { type: String, required: true, index: true },
    pricePerKg: { type: Number, required: true },
    quantity: { type: Number, required: true },
    notes: { type: String },
  },
  { timestamps: true },
);

module.exports = mongoose.model(
  "ActualPriceData",
  actualPriceDataSchema,
  "actual_price_data",
);
