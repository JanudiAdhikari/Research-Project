from fastapi import FastAPI, File, UploadFile
import numpy as np
import joblib
import cv2
import shap
from xgboost import XGBRegressor
from tensorflow.keras.applications import EfficientNetB0
from tensorflow.keras.applications.efficientnet import preprocess_input
from typing import List
from datetime import datetime

metrics = joblib.load("metrics.pkl")

MODEL_RMSE = metrics["rmse"]
MEAN_YIELD = metrics["mean_yield"]

app = FastAPI()

xgb_model = XGBRegressor()
xgb_model.load_model("xgb_model.json")

pca = joblib.load("pca.pkl")
scaler = joblib.load("scaler.pkl")

effnet = EfficientNetB0(
    weights="imagenet",
    include_top=False,
    input_shape=(224, 224, 3),
    pooling="avg"
)

explainer = shap.Explainer(xgb_model)

feature_names = (
    [f"pca_{i}" for i in range(pca.n_components_)]
    + [
        "soil_moisture",
        "temperature",
        "moisture_temp_ratio",
        "moisture_squared",
        "temp_squared",
    ]
)

def get_shap_values(X):

    shap_values = explainer(X)
    values = shap_values.values[0]

    explanation = {}

    for name, val in zip(feature_names, values):
        explanation[name] = float(val)

    return explanation

def generate_farmer_insights(shap_values, soil, temp):

    insights = []

    soil_impact = shap_values.get("soil_moisture", 0)
    temp_impact = shap_values.get("temperature", 0)

    # -------------------------
    # Soil moisture analysis
    # -------------------------
    if soil < 35:
        insights.append(
            "Soil moisture is below optimal range (35–65%). Pepper requires consistent soil moisture for fruit development."
        )

    elif 35 <= soil <= 65:
        insights.append(
            "Soil moisture level is within the optimal range for pepper growth."
        )

    else:
        insights.append(
            "Soil moisture is high. Excess moisture may cause root diseases in pepper plants."
        )

    # -------------------------
    # Temperature analysis
    # -------------------------
    if temp < 20:
        insights.append(
            "Temperature is below optimal growth range (20–30°C). Pepper growth may slow."
        )

    elif 20 <= temp <= 30:
        insights.append(
            "Temperature is within optimal range for pepper growth."
        )

    elif 30 < temp <= 35:
        insights.append(
            "Temperature slightly above optimal range. Monitor plant stress."
        )

    else:
        insights.append(
            "High temperature may cause heat stress and reduce pepper yield."
        )

    # -------------------------
    # SHAP based explanation
    # -------------------------
    if soil_impact < -0.05:
        insights.append(
            "Model detected that low soil moisture significantly reduced predicted yield."
        )

    if temp_impact < -0.05:
        insights.append(
            "Model detected temperature conditions negatively affecting yield prediction."
        )

    return insights


@app.post("/predict")
async def predict(files: List[UploadFile] = File(...), soil: float = 0, temp: float = 0):

    if len(files) > 4:
        return {"error": "Maximum 4 images allowed"}

    # validate inputs
    if soil < 0 or soil > 100:
        return {"error": "Soil moisture must be between 0 and 100"}

    if temp < -10 or temp > 60:
        return {"error": "Temperature value unrealistic"}

    images = []

    for file in files:

        contents = await file.read()
        nparr = np.frombuffer(contents, np.uint8)

        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        if img is None:
            continue

        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        img = cv2.resize(img, (224, 224))
        img = preprocess_input(img)

        images.append(img)

    if len(images) == 0:
        return {"error": "No valid images provided"}

    images = np.array(images)
    features = effnet.predict(images, verbose=0)

    weights = np.linspace(1, 2, len(features))
    weights = weights / np.sum(weights)

    img_feat = np.average(features, axis=0, weights=weights)
    img_feat = img_feat.reshape(1, -1)
    img_feat_reduced = pca.transform(img_feat)

    moisture_temp_ratio = soil / (temp + 1)
    moisture_squared = soil ** 2
    temp_squared = temp ** 2

    tab = np.array(
        [[
            soil,
            temp,
            moisture_temp_ratio,
            moisture_squared,
            temp_squared,
        ]]
    )

    tab_scaled = scaler.transform(tab)
    X = np.concatenate([img_feat_reduced, tab_scaled], axis=1)
    prediction = xgb_model.predict(X)[0]
    confidence = max(0, 1 - (MODEL_RMSE / MEAN_YIELD))
    confidence = round(confidence * 100, 2)
    shap_values = get_shap_values(X)
    insights = generate_farmer_insights(shap_values, soil, temp)
    timestamp = datetime.utcnow().isoformat()

    # classify crop condition
    if prediction > 1.5:
        condition = "Healthy crop condition"
    elif prediction > 1.0:
        condition = "Moderate crop condition"
    else:
        condition = "Low productivity risk"

    return {
    "timestamp": timestamp,
    "predicted_yield_kg_per_plant": float(prediction),
    "confidence_percent": confidence,
    "crop_condition": condition,
    "recommendations": insights,
    "xai_top_factors": {
        "soil_moisture_impact": shap_values.get("soil_moisture", 0),
        "temperature_impact": shap_values.get("temperature", 0),
    },
}


@app.get("/health")
async def health():
    """Health check endpoint for container orchestration"""
    return {
        "status": "healthy",
        "service": "yield-prediction-api",
        "version": "1.0.0"
    }