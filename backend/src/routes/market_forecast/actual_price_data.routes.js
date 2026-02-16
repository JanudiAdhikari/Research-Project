const express = require("express");
const verifyToken = require("../../middleware/auth.middleware");
const {
  createActualPriceData,
} = require("../../controllers/market_forecast/actual_price_data.controller");

const router = express.Router();

router.post("/", verifyToken, createActualPriceData);

module.exports = router;
