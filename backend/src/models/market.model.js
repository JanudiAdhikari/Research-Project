const mongoose = require('mongoose');

const marketProductSchema = new mongoose.Schema({
  name: { type: String, required: true },
  price: { type: Number, default: 0 },
  unit: { type: String, default: 'unit' },
  vendorUid: { type: String },
}, { timestamps: true });

module.exports = mongoose.model('MarketProduct', marketProductSchema);
