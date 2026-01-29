const mongoose = require('mongoose');

const farmPlotSchema = new mongoose.Schema({
  ownerUid: { type: String, required: true, index: true },
  name: { type: String, required: true },
  crop: { type: String },
  area: { type: Number, default: 0 },
}, { timestamps: true });

module.exports = mongoose.model('FarmPlot', farmPlotSchema);
