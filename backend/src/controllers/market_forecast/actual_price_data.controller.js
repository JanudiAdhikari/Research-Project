const ActualPriceData = require("../../models/market_forecast/actual_price_data.model");

// Get all records
const getActualPriceData = async (req, res) => {
  try {
    const { pepperType, grade, district, limit } = req.query;
    const filter = {};

    if (pepperType) filter.pepperType = pepperType;
    if (grade) filter.grade = grade;
    if (district) filter.district = district;

    const query = ActualPriceData.find(filter).sort({ saleDate: -1 }).lean();

    if (limit) {
      const parsedLimit = parseInt(limit, 10);
      if (parsedLimit > 0) query.limit(parsedLimit);
    }

    const records = await query.exec();
    return res.json(records);
  } catch (err) {
    console.error("getActualPriceData error:", err);
    return res
      .status(500)
      .json({ message: "Server error", error: err.message });
  }
};

// Create a new record
const createActualPriceData = async (req, res) => {
  try {
    const {
      saleDate,
      pepperType,
      grade,
      district,
      pricePerKg,
      quantity,
      notes,
    } = req.body;

    if (!saleDate || !pepperType || !grade || !district) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    const parsedDate = new Date(saleDate);
    if (Number.isNaN(parsedDate.getTime())) {
      return res.status(400).json({ message: "Invalid saleDate" });
    }

    const parsedPrice = Number(pricePerKg);
    const parsedQuantity = Number(quantity);
    if (!Number.isFinite(parsedPrice) || !Number.isFinite(parsedQuantity)) {
      return res.status(400).json({ message: "Invalid price or quantity" });
    }

    const record = new ActualPriceData({
      saleDate: parsedDate,
      pepperType,
      grade,
      district,
      pricePerKg: parsedPrice,
      quantity: parsedQuantity,
      notes: notes || undefined,
    });

    await record.save();
    return res.status(201).json(record);
  } catch (err) {
    console.error("createActualPriceData error:", err);
    return res
      .status(500)
      .json({ message: "Server error", error: err.message });
  }
};

module.exports = { getActualPriceData, createActualPriceData };
