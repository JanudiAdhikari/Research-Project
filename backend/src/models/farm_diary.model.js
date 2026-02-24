const mongoose = require('mongoose');

const farmDiarySchema = new mongoose.Schema({
  ownerUid: { 
    type: String, 
    required: true, 
    index: true 
  },
  farmPlotId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'FarmPlot',
    required: true,
    index: true
  },
  title: { 
    type: String, 
    required: true 
  },
  description: { 
    type: String,
    default: ''
  },
  activityType: {
    type: String,
    enum: ['watering', 'fertilizing', 'pest_control', 'harvesting', 'pruning', 'weeding', 'inspection', 'disease_treatment', 'other'],
    required: true
  },
  diaryDate: {
    type: Date,
    required: true,
    index: true
  },
  weather: {
    condition: {
      type: String,
      enum: ['sunny', 'cloudy', 'rainy', 'windy', 'stormy', 'unknown'],
      default: 'unknown'
    },
    temperature: Number, // in Celsius
    humidity: Number, // percentage
    rainfall: Number // in mm
  },
  observations: {
    plantHealth: {
      type: String,
      enum: ['excellent', 'good', 'fair', 'poor'],
      default: 'good'
    },
    diseaseSymptoms: String,
    pestPresence: String,
    yieldEstimate: String
  },
  actions: {
    type: String,
    default: ''
  },
  inputs: {
    fertilizer: String,
    pesticide: String,
    waterQuantity: Number, // in liters
    otherInputs: String
  },
  images: [{
    url: String,
    cloudinaryId: String,
    uploadedAt: Date,
    caption: String
  }],
  location: {
    latitude: Number,
    longitude: Number,
    altitude: Number
  },
  notes: {
    type: String,
    default: ''
  },
  tags: [String],
  syncStatus: {
    type: String,
    enum: ['synced', 'pending', 'failed'],
    default: 'synced'
  },
  offlineSyncId: String, // For tracking offline entries
}, { 
  timestamps: true,
  indexes: [
    { ownerUid: 1, diaryDate: -1 },
    { farmPlotId: 1, diaryDate: -1 }
  ]
});

module.exports = mongoose.model('FarmDiary', farmDiarySchema);
