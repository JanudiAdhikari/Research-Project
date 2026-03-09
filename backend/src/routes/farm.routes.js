const express = require('express');
const { getPlots, createPlot, updatePlot, deletePlot } = require('../controllers/farm.controller');
const verifyToken = require('../middleware/auth.middleware');

const router = express.Router();

router.get('/plots', verifyToken, getPlots);
router.post('/plots', verifyToken, createPlot);
router.put('/plots/:id', verifyToken, updatePlot);
router.delete('/plots/:id', verifyToken, deletePlot);

module.exports = router;
