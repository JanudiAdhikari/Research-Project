const PastExportPrice = require("../../models/market_forecast/past_export_price.model");

// Helper to convert month input to standardized month name
const monthOrder = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
];

// Normalize month input
const normalizeMonthInput = (value) => {
  if (!value) return null;
  const trimmed = value.toString().trim();
  if (!trimmed) return null;

  const parsed = parseInt(trimmed, 10);
  if (!Number.isNaN(parsed) && parsed >= 1 && parsed <= 12) {
    return monthOrder[parsed - 1];
  }

  const index = monthOrder.findIndex(
    (month) => month.toLowerCase() === trimmed.toLowerCase(),
  );
  if (index >= 0) return monthOrder[index];
  return null;
};

// Get month index
const monthIndex = (monthName) =>
  monthOrder.findIndex(
    (month) => month.toLowerCase() === monthName.toLowerCase(),
  );

// Get past export prices with optional filters
const getPastExportPrices = async (req, res) => {
  try {
    const { year, month, month_from, month_to, country, pepper_type } =
      req.query;

    const filter = {};
    if (year) filter.year = parseInt(year, 10);
    if (country) filter.country = country;
    if (pepper_type) filter.pepper_type = pepper_type;

    const monthExact = normalizeMonthInput(month);
    const monthFrom = normalizeMonthInput(month_from);
    const monthTo = normalizeMonthInput(month_to);

    if (monthExact) {
      filter.month = monthExact;
    } else if (monthFrom || monthTo) {
      const startIndex = monthFrom ? monthIndex(monthFrom) : 0;
      const endIndex = monthTo ? monthIndex(monthTo) : 11;
      if (startIndex >= 0 && endIndex >= 0) {
        const range = monthOrder.slice(
          Math.min(startIndex, endIndex),
          Math.max(startIndex, endIndex) + 1,
        );
        filter.month = { $in: range };
      }
    }

    const prices = await PastExportPrice.find(filter).lean().exec();
    prices.sort((a, b) => {
      if (a.year !== b.year) return a.year - b.year;
      return monthIndex(a.month) - monthIndex(b.month);
    });

    return res.json(prices);
  } catch (err) {
    console.error("getPastExportPrices error:", err);
    return res
      .status(500)
      .json({ message: "Server error", error: err.message });
  }
};

// Get distinct list of years
const getPastExportPriceYears = async (req, res) => {
  try {
    const years = await PastExportPrice.distinct("year").exec();
    return res.json(years.sort((a, b) => a - b));
  } catch (err) {
    console.error("getPastExportPriceYears error:", err);
    return res
      .status(500)
      .json({ message: "Server error", error: err.message });
  }
};

module.exports = {
  getPastExportPrices,
  getPastExportPriceYears,
};
