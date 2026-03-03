from fastapi import FastAPI
from pydantic import BaseModel, Field
import joblib
import pandas as pd
import numpy as np
from pathlib import Path
from datetime import datetime

# Paths
BASE_DIR = Path(__file__).resolve().parent

# Local price model files (local_price/)
LOCAL_MODEL_PATH = BASE_DIR / "pepper_price_model.pkl"
DISTRICT_ENCODER_PATH = BASE_DIR / "district_encoder.pkl"
TYPE_ENCODER_PATH = BASE_DIR / "type_encoder.pkl"
GRADE_ENCODER_PATH = BASE_DIR / "grade_encoder.pkl"

# Export price model files (export_price/)
EXPORT_DIR = BASE_DIR.parent / "export_price"
EXPORT_MODEL_PATH = EXPORT_DIR / "lgbm_usd_recent.pkl"
EXPORT_META_PATH = EXPORT_DIR / "model_metadata.pkl"
EXPORT_HISTORY_PATH = EXPORT_DIR / "history_usd.pkl"

# Load models once at startup
# Local price assets
local_model = joblib.load(LOCAL_MODEL_PATH)
le_district = joblib.load(DISTRICT_ENCODER_PATH)
le_type = joblib.load(TYPE_ENCODER_PATH)
le_grade = joblib.load(GRADE_ENCODER_PATH)

# Export price assets
export_model = joblib.load(EXPORT_MODEL_PATH)
export_meta = joblib.load(EXPORT_META_PATH)
export_history = joblib.load(EXPORT_HISTORY_PATH)

# Prepare export history DataFrame (robust)
# history has: year, month_num, lkr_per_kg, export_volume_kg
if isinstance(export_history, pd.DataFrame):
    hist_df = export_history.copy()
else:
    hist_df = pd.DataFrame(export_history)

hist_df.columns = [str(c).strip() for c in hist_df.columns]

required_cols = {"year", "month_num", "lkr_per_kg"}
missing = required_cols - set(hist_df.columns)
if missing:
    raise ValueError(
        f"history_usd.pkl is missing columns: {missing}. Found: {hist_df.columns.tolist()}"
    )

hist_df["date"] = pd.to_datetime(
    hist_df["year"].astype(str) + "-" + hist_df["month_num"].astype(str) + "-01",
    errors="coerce",
)
hist_df = hist_df.dropna(subset=["date"]).sort_values("date").reset_index(drop=True)

print("Export history columns:", hist_df.columns.tolist())
print("Export model features:", export_meta.get("features"))

# FastAPI app
app = FastAPI(title="Pepper Price Prediction API")


# Request Schemas
class LocalPredictionRequest(BaseModel):
    district: str
    pepper_type: str
    grade: str
    year: int
    month: int
    week: int


class ExportPredictionRequest(BaseModel):
    quantity_kg: float = Field(..., gt=0, description="Export volume (kg)")


# Endpoint: Local price prediction
@app.post("/predictlocalprice")
def predict_local_price(data: LocalPredictionRequest):
    try:
        district_encoded = le_district.transform([data.district])[0]
        type_encoded = le_type.transform([data.pepper_type])[0]
        grade_encoded = le_grade.transform([data.grade])[0]

        input_df = pd.DataFrame(
            [
                [
                    district_encoded,
                    type_encoded,
                    grade_encoded,
                    data.year,
                    data.month,
                    data.week,
                ]
            ],
            columns=["district", "pepper_type", "grade", "year", "month", "week"],
        )

        prediction = local_model.predict(input_df)[0]

        return {"predicted_price_LKR_per_kg": round(float(prediction), 2)}

    except Exception as e:
        return {"error": str(e)}


# Helpers for Export endpoint
def get_next_year_month(now: datetime) -> tuple[int, int]:
    """Return upcoming (year, month) based on server date."""
    y, m = now.year, now.month
    if m == 12:
        return y + 1, 1
    return y, m + 1


def _get_lag_value(feature_name: str, history: pd.DataFrame) -> float:
    """
    Compute lag values for features the export model expects.
    We ONLY have lkr_per_kg history (not usd_per_kg).
    """
    if history.empty:
        raise ValueError("Export history is empty. Cannot compute lag features.")

    # LKR price lags
    if feature_name == "lag_lkr_1":
        return float(history.iloc[-1]["lkr_per_kg"])
    if feature_name == "lag_lkr_3_mean":
        return float(history.tail(3)["lkr_per_kg"].mean())
    if feature_name == "lag_lkr_6_mean":
        return float(history.tail(6)["lkr_per_kg"].mean())

    # Volume lags (optional)
    if feature_name == "lag_vol_1":
        if "export_volume_kg" not in history.columns:
            raise ValueError("history_usd.pkl missing 'export_volume_kg' for lag_vol_1")
        return float(history.iloc[-1]["export_volume_kg"])
    if feature_name == "lag_vol_3_mean":
        if "export_volume_kg" not in history.columns:
            raise ValueError(
                "history_usd.pkl missing 'export_volume_kg' for lag_vol_3_mean"
            )
        return float(history.tail(3)["export_volume_kg"].mean())

    raise ValueError(
        f"Unsupported lag feature in export model metadata: {feature_name}"
    )


def build_export_features(year: int, month: int, quantity_kg: float) -> pd.DataFrame:
    """
    Build features based on metadata.
    Expecting features like:
      ["month_num", "export_volume_kg", "lag_lkr_1"]
    """
    features = export_meta.get("features") or [
        "month_num",
        "export_volume_kg",
        "lag_lkr_1",
    ]

    row = {}
    for f in features:
        if f == "month_num":
            row[f] = int(month)
        elif f == "export_volume_kg":
            row[f] = float(quantity_kg)
        elif f.startswith("lag_"):
            row[f] = _get_lag_value(f, hist_df)
        else:
            raise ValueError(f"Unknown feature in export model metadata: {f}")

    return pd.DataFrame([[row[f] for f in features]], columns=features)


# Endpoint: Export price prediction
@app.post("/predictexportprice")
def predict_export_price(data: ExportPredictionRequest):
    try:
        next_year, next_month = get_next_year_month(datetime.now())

        X_one = build_export_features(next_year, next_month, data.quantity_kg)

        # Your export model likely predicts log1p(price)
        pred_log = float(export_model.predict(X_one)[0])
        pred_lkr_per_kg = float(np.expm1(pred_log))

        return {
            "year": next_year,
            "month": next_month,
            "predicted_export_price_lkr_per_kg": round(pred_lkr_per_kg, 2),
        }

    except Exception as e:
        return {"error": str(e)}
