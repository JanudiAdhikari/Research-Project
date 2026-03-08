const FarmDiary = require('../models/farm_diary.model');
const cloudinary = require('cloudinary').v2;

// GET all diary entries for a user's farm plot
const getDiaryEntries = async (req, res) => {
  try {
    const uid = req.user?.uid;
    if (!uid) return res.status(401).json({ message: 'Unauthorized' });

    const { farmPlotId, startDate, endDate, activityType } = req.query;
    let query = { ownerUid: uid };

    if (farmPlotId) {
      query.farmPlotId = farmPlotId;
    }

    if (startDate || endDate) {
      query.diaryDate = {};
      if (startDate) query.diaryDate.$gte = new Date(startDate);
      if (endDate) query.diaryDate.$lte = new Date(endDate);
    }

    if (activityType) {
      query.activityType = activityType;
    }

    const entries = await FarmDiary.find(query)
      .populate('farmPlotId', 'name crop area')
      .sort({ diaryDate: -1 })
      .lean()
      .exec();

    return res.json(entries);
  } catch (err) {
    console.error('getDiaryEntries error:', err);
    return res.status(500).json({ message: 'Server error', error: err.message });
  }
};

// GET single diary entry
const getDiaryEntry = async (req, res) => {
  try {
    const uid = req.user?.uid;
    if (!uid) return res.status(401).json({ message: 'Unauthorized' });

    const { id } = req.params;
    const entry = await FarmDiary.findById(id)
      .populate('farmPlotId', 'name crop area')
      .exec();

    if (!entry) return res.status(404).json({ message: 'Diary entry not found' });
    if (entry.ownerUid !== uid) return res.status(403).json({ message: 'Forbidden' });

    return res.json(entry);
  } catch (err) {
    console.error('getDiaryEntry error:', err);
    return res.status(500).json({ message: 'Server error', error: err.message });
  }
};

// CREATE new diary entry
const createDiaryEntry = async (req, res) => {
  try {
    const uid = req.user?.uid;
    if (!uid) return res.status(401).json({ message: 'Unauthorized' });

    const {
      farmPlotId,
      title,
      description,
      activityType,
      diaryDate,
      weather,
      observations,
      actions,
      inputs,
      location,
      notes,
      tags,
      images = []
    } = req.body;

    // Validation
    if (!farmPlotId || !title || !activityType || !diaryDate) {
      return res.status(400).json({
        message: 'farmPlotId, title, activityType, and diaryDate are required'
      });
    }

    const entry = new FarmDiary({
      ownerUid: uid,
      farmPlotId,
      title,
      description: description || '',
      activityType,
      diaryDate: new Date(diaryDate),
      weather: weather || {},
      observations: observations || {},
      actions: actions || '',
      inputs: inputs || {},
      location: location || {},
      notes: notes || '',
      tags: tags || [],
      images: images,
      syncStatus: 'synced'
    });

    await entry.save();
    await entry.populate('farmPlotId', 'name crop area');

    return res.status(201).json(entry);
  } catch (err) {
    console.error('createDiaryEntry error:', err);
    return res.status(500).json({ message: 'Server error', error: err.message });
  }
};

// UPDATE diary entry
const updateDiaryEntry = async (req, res) => {
  try {
    const uid = req.user?.uid;
    if (!uid) return res.status(401).json({ message: 'Unauthorized' });

    const { id } = req.params;
    const {
      title,
      description,
      activityType,
      diaryDate,
      weather,
      observations,
      actions,
      inputs,
      location,
      notes,
      tags,
      images
    } = req.body;

    const entry = await FarmDiary.findById(id).exec();
    if (!entry) return res.status(404).json({ message: 'Diary entry not found' });
    if (entry.ownerUid !== uid) return res.status(403).json({ message: 'Forbidden' });

    // Update fields
    if (title !== undefined) entry.title = title;
    if (description !== undefined) entry.description = description;
    if (activityType !== undefined) entry.activityType = activityType;
    if (diaryDate !== undefined) entry.diaryDate = new Date(diaryDate);
    if (weather !== undefined) entry.weather = { ...entry.weather, ...weather };
    if (observations !== undefined) entry.observations = { ...entry.observations, ...observations };
    if (actions !== undefined) entry.actions = actions;
    if (inputs !== undefined) entry.inputs = { ...entry.inputs, ...inputs };
    if (location !== undefined) entry.location = { ...entry.location, ...location };
    if (notes !== undefined) entry.notes = notes;
    if (tags !== undefined) entry.tags = tags;
    if (images !== undefined) entry.images = images;

    await entry.save();
    await entry.populate('farmPlotId', 'name crop area');

    return res.json(entry);
  } catch (err) {
    console.error('updateDiaryEntry error:', err);
    return res.status(500).json({ message: 'Server error', error: err.message });
  }
};

// DELETE diary entry
const deleteDiaryEntry = async (req, res) => {
  try {
    const uid = req.user?.uid;
    if (!uid) return res.status(401).json({ message: 'Unauthorized' });

    const { id } = req.params;
    const entry = await FarmDiary.findById(id).exec();
    if (!entry) return res.status(404).json({ message: 'Diary entry not found' });
    if (entry.ownerUid !== uid) return res.status(403).json({ message: 'Forbidden' });

    // Delete images from Cloudinary if they exist
    if (entry.images && entry.images.length > 0) {
      for (const image of entry.images) {
        if (image.cloudinaryId) {
          try {
            await cloudinary.uploader.destroy(image.cloudinaryId);
          } catch (err) {
            console.error('Error deleting image from Cloudinary:', err);
          }
        }
      }
    }

    await FarmDiary.deleteOne({ _id: id });
    return res.json({ message: 'Diary entry deleted successfully' });
  } catch (err) {
    console.error('deleteDiaryEntry error:', err);
    return res.status(500).json({ message: 'Server error', error: err.message });
  }
};

// SYNC offline entries
const syncOfflineEntries = async (req, res) => {
  try {
    const uid = req.user?.uid;
    if (!uid) return res.status(401).json({ message: 'Unauthorized' });

    const { entries } = req.body;
    if (!Array.isArray(entries)) {
      return res.status(400).json({ message: 'entries must be an array' });
    }

    const results = [];
    for (const entry of entries) {
      try {
        const { offlineSyncId, ...entryData } = entry;
        
        // Check if entry with this offlineSyncId already exists
        let existingEntry = await FarmDiary.findOne({ 
          ownerUid: uid,
          offlineSyncId: offlineSyncId 
        });

        if (existingEntry) {
          // Update existing entry
          Object.assign(existingEntry, entryData);
          existingEntry.syncStatus = 'synced';
          await existingEntry.save();
          results.push({ offlineSyncId, _id: existingEntry._id, status: 'updated' });
        } else {
          // Create new entry
          const newEntry = new FarmDiary({
            ...entryData,
            ownerUid: uid,
            offlineSyncId: offlineSyncId,
            syncStatus: 'synced'
          });
          await newEntry.save();
          results.push({ offlineSyncId, _id: newEntry._id, status: 'created' });
        }
      } catch (err) {
        console.error('Error syncing entry:', err);
        results.push({ status: 'failed', error: err.message });
      }
    }

    return res.json({
      message: 'Sync completed',
      results: results
    });
  } catch (err) {
    console.error('syncOfflineEntries error:', err);
    return res.status(500).json({ message: 'Server error', error: err.message });
  }
};

// GET diary statistics for a farm plot
const getDiaryStats = async (req, res) => {
  try {
    const uid = req.user?.uid;
    if (!uid) return res.status(401).json({ message: 'Unauthorized' });

    const { farmPlotId, startDate, endDate } = req.query;
    if (!farmPlotId) {
      return res.status(400).json({ message: 'farmPlotId is required' });
    }

    let query = { ownerUid: uid, farmPlotId };
    if (startDate || endDate) {
      query.diaryDate = {};
      if (startDate) query.diaryDate.$gte = new Date(startDate);
      if (endDate) query.diaryDate.$lte = new Date(endDate);
    }

    const totalEntries = await FarmDiary.countDocuments(query);
    
    const activityStats = await FarmDiary.aggregate([
      { $match: query },
      { $group: { _id: '$activityType', count: { $sum: 1 } } }
    ]);

    const avgWeather = await FarmDiary.aggregate([
      { $match: { ...query, 'weather.temperature': { $exists: true } } },
      {
        $group: {
          _id: null,
          avgTemp: { $avg: '$weather.temperature' },
          avgHumidity: { $avg: '$weather.humidity' },
          totalRainfall: { $sum: '$weather.rainfall' }
        }
      }
    ]);

    const plantHealthStats = await FarmDiary.aggregate([
      { $match: query },
      { $group: { _id: '$observations.plantHealth', count: { $sum: 1 } } }
    ]);

    return res.json({
      totalEntries,
      activityStats,
      avgWeather: avgWeather[0] || {},
      plantHealthStats
    });
  } catch (err) {
    console.error('getDiaryStats error:', err);
    return res.status(500).json({ message: 'Server error', error: err.message });
  }
};

module.exports = {
  getDiaryEntries,
  getDiaryEntry,
  createDiaryEntry,
  updateDiaryEntry,
  deleteDiaryEntry,
  syncOfflineEntries,
  getDiaryStats
};
