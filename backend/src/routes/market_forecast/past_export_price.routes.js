const express = require("express");
const {
  getPastExportPrices,
  getPastExportPriceYears,
} = require("../../controllers/market_forecast/past_export_price.controller");

const router = express.Router();

// Get all past export prices (optional filters)
router.get("/", getPastExportPrices);

// Get distinct list of years
router.get("/years", getPastExportPriceYears);

module.exports = router;
