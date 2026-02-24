const ActualPriceData = require("../../models/market_forecast/actual_price_data.model");

// Get all records
const getActualPriceData = async (req, res) => {
  try {
    const { pepperType, grade, district, limit } = req.query;
    const filter = { userId: req.user?.uid };

    if (!filter.userId) {
      return res.status(401).json({ message: "No user id" });
    }

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
    if (!req.user?.uid) {
      return res.status(401).json({ message: "No user id" });
    }

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
      userId: req.user?.uid,
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

// Update an existing record
const updateActualPriceData = async (req, res) => {
  try {
    if (!req.user?.uid) {
      return res.status(401).json({ message: "No user id" });
    }

    const { id } = req.params;
    const {
      saleDate,
      pepperType,
      grade,
      district,
      pricePerKg,
      quantity,
      notes,
      marketplaceProductId,
    } = req.body;

    // Find the record and verify ownership
    const record = await ActualPriceData.findById(id);
    if (!record) {
      return res.status(404).json({ message: "Record not found" });
    }

    if (record.userId !== req.user?.uid) {
      return res
        .status(403)
        .json({ message: "Not authorized to update this record" });
    }

    // Validate and update fields
    if (saleDate) {
      const parsedDate = new Date(saleDate);
      if (Number.isNaN(parsedDate.getTime())) {
        return res.status(400).json({ message: "Invalid saleDate" });
      }
      record.saleDate = parsedDate;
    }

    if (pepperType) record.pepperType = pepperType;
    if (grade) record.grade = grade;
    if (district) record.district = district;

    if (pricePerKg !== undefined) {
      const parsedPrice = Number(pricePerKg);
      if (!Number.isFinite(parsedPrice)) {
        return res.status(400).json({ message: "Invalid price" });
      }
      record.pricePerKg = parsedPrice;
    }

    if (quantity !== undefined) {
      const parsedQuantity = Number(quantity);
      if (!Number.isFinite(parsedQuantity)) {
        return res.status(400).json({ message: "Invalid quantity" });
      }
      record.quantity = parsedQuantity;
    }

    if (notes !== undefined) record.notes = notes;

    if (marketplaceProductId !== undefined) {
      record.marketplaceProductId = marketplaceProductId;
    }

    await record.save();
    return res.json(record);
  } catch (err) {
    console.error("updateActualPriceData error:", err);
    return res
      .status(500)
      .json({ message: "Server error", error: err.message });
  }
};

// Delete a record
const deleteActualPriceData = async (req, res) => {
  try {
    if (!req.user?.uid) {
      return res.status(401).json({ message: "No user id" });
    }

    const { id } = req.params;

    // Find the record and verify ownership
    const record = await ActualPriceData.findById(id);
    if (!record) {
      return res.status(404).json({ message: "Record not found" });
    }

    if (record.userId !== req.user?.uid) {
      return res
        .status(403)
        .json({ message: "Not authorized to delete this record" });
    }

    await ActualPriceData.findByIdAndDelete(id);
    return res.json({ message: "Record deleted successfully" });
  } catch (err) {
    console.error("deleteActualPriceData error:", err);
    return res
      .status(500)
      .json({ message: "Server error", error: err.message });
  }
};

module.exports = {
  getActualPriceData,
  createActualPriceData,
  updateActualPriceData,
  deleteActualPriceData,
};
