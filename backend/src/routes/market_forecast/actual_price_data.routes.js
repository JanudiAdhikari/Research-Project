const express = require("express");
const verifyToken = require("../../middleware/auth.middleware");
const {
  getActualPriceData,
  createActualPriceData,
} = require("../../controllers/market_forecast/actual_price_data.controller");

const router = express.Router();

router.get("/", verifyToken, getActualPriceData);
router.post("/", verifyToken, createActualPriceData);

module.exports = router;
