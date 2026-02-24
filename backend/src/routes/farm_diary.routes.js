const express = require('express');
const {
  getDiaryEntries,
  getDiaryEntry,
  createDiaryEntry,
  updateDiaryEntry,
  deleteDiaryEntry,
  syncOfflineEntries,
  getDiaryStats
} = require('../controllers/farm_diary.controller');
const verifyToken = require('../middleware/auth.middleware');

const router = express.Router();

// All routes require authentication
router.use(verifyToken);

// GET routes
router.get('/entries', getDiaryEntries);
router.get('/stats', getDiaryStats);
router.get('/entries/:id', getDiaryEntry);

// POST routes
router.post('/entries', createDiaryEntry);
router.post('/sync', syncOfflineEntries);

// PUT routes
router.put('/entries/:id', updateDiaryEntry);

// DELETE routes
router.delete('/entries/:id', deleteDiaryEntry);

module.exports = router;
