const ExportDetailsByCountry = require("../../models/market_forecast/export_details_by_country.model");

// Get all details
const getExportDetailsByCountry = async (req, res) => {
  try {
    const { country, pepper_type, year } = req.query;
    const filter = {};
    // Build filter based on query parameters
    if (country) filter.country = country;
    if (pepper_type) filter.pepper_type = pepper_type;
    if (year) filter.year = parseInt(year);

    const exportDetails = await ExportDetailsByCountry.find(filter)
      .lean()
      .exec();
    return res.json(exportDetails);
  } catch (err) {
    console.error("getExportDetailsByCountry error:", err);
    return res
      .status(500)
      .json({ message: "Server error", error: err.message });
  }
};

// Get details by ID
const getExportDetailsByCountryById = async (req, res) => {
  try {
    const { id } = req.params;
    const exportDetail = await ExportDetailsByCountry.findById(id)
      .lean()
      .exec();

    if (!exportDetail) {
      return res.status(404).json({ message: "Export details not found" });
    }

    return res.json(exportDetail);
  } catch (err) {
    console.error("getExportDetailsByCountryById error:", err);
    return res
      .status(500)
      .json({ message: "Server error", error: err.message });
  }
};

// Get distinct list of countries
const getExportCountries = async (req, res) => {
  try {
    const countries = await ExportDetailsByCountry.distinct("country").exec();
    return res.json(countries.sort());
  } catch (err) {
    console.error("getExportCountries error:", err);
    return res
      .status(500)
      .json({ message: "Server error", error: err.message });
  }
};

module.exports = {
  getExportDetailsByCountry,
  getExportDetailsByCountryById,
  getExportCountries,
};
