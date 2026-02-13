const express = require("express");
const {
  getExportDetailsByCountry,
  getExportDetailsByCountryById,
} = require("../../controllers/market_forecast/export_details_by_country.controller");

const router = express.Router();

// Get all export details by country
router.get("/", getExportDetailsByCountry);

// Get export details by ID
router.get("/:id", getExportDetailsByCountryById);

module.exports = router;
