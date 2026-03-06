require("dotenv").config();

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");
const morgan = require("morgan");

const app = express();

console.log("PORT =", process.env.PORT);
console.log("NODE_ENV =", process.env.NODE_ENV);
console.log("MONGO_URI exists =", !!process.env.MONGO_URI);

process.on("uncaughtException", (err) => {
  console.error("uncaughtException:", err);
});

process.on("unhandledRejection", (err) => {
  console.error("unhandledRejection:", err);
});

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(morgan("dev"));

const limiter = rateLimit({
  windowMs: 1 * 60 * 1000,
  max: 100,
});
app.use(limiter);

// Health routes
app.get("/", (req, res) => res.status(200).send("OK"));
app.get("/health", (req, res) => res.status(200).send("healthy"));

// Routes
const userRoutes = require("./routes/user.routes");
const farmRoutes = require("./routes/farm.routes");
const marketRoutes = require("./routes/market.routes");
const exportDetailsByCountryRoutes = require("./routes/market_forecast/export_details_by_country.routes");
const pastExportPriceRoutes = require("./routes/market_forecast/past_export_price.routes");
const actualPriceDataRoutes = require("./routes/market_forecast/actual_price_data.routes");
const certificationRoutes = require("./routes/certification.routes");
const qualityCheckRoutes = require("./routes/quality_grading/qualityCheck.routes");

app.use("/api/users", userRoutes);
app.use("/api/farm", farmRoutes);
app.use("/api/market", marketRoutes);
app.use("/api/certifications", certificationRoutes);
app.use(
  "/api/market-forecast/export-details-by-country",
  exportDetailsByCountryRoutes,
);
app.use("/api/market-forecast/past-export-prices", pastExportPriceRoutes);
app.use("/api/market-forecast/actual-price-data", actualPriceDataRoutes);
app.use("/api/quality-checks", qualityCheckRoutes);

// Start server first
const port = process.env.PORT || 8080;

app.listen(port, "0.0.0.0", async () => {
  console.log(`Server started on port ${port}`);

  try {
    const connectDB = require("./config/db");
    await connectDB();
    console.log("DB init done");
  } catch (err) {
    console.error("DB init failed:", err);
  }

  try {
    require("./config/firebaseAdmin");
    console.log("Firebase admin init done");
  } catch (err) {
    console.error("Firebase admin init failed:", err);
  }
});
