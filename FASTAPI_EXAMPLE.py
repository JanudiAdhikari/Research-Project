"""
Minimal FastAPI Example for Yield Prediction

This is a reference implementation showing the expected API structure
for the mobile app integration. Replace with your actual model inference.
"""

from fastapi import FastAPI, UploadFile, File, Form
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import io
from PIL import Image
import numpy as np
from typing import Optional

app = FastAPI(title="Yield Prediction API", version="1.0.0")

# Add CORS middleware for mobile app requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load your trained model here
# model = load_model("path/to/your/model.h5")
# scaler = load_scaler("path/to/your/scaler.pkl")


@app.get("/health")
def health_check():
    """Health check endpoint"""
    return {
        "status": "ok",
        "message": "Yield prediction API is running"
    }


@app.post("/predict")
async def predict_yield(
    image: UploadFile = File(...),
    soil_moisture: float = Form(...),
    temperature: float = Form(...),
    rainfall: Optional[float] = Form(None),
    plant_age: Optional[str] = Form(None),
):
    """
    Predict crop yield from image and environmental data.
    
    Args:
        image: Plant/crop image file
        soil_moisture: Soil moisture percentage (0-100)
        temperature: Environmental temperature in °C
        rainfall: (Optional) Rainfall in mm
        plant_age: (Optional) Plant age category (e.g., "6-8 months")
    
    Returns:
        JSON with predicted yield and confidence
    """
    
    try:
        # Read image
        image_data = await image.read()
        img = Image.open(io.BytesIO(image_data))
        
        # Preprocess image (resize, normalize, etc.)
        img_array = np.array(img.resize((224, 224)))  # Adjust size for your model
        img_normalized = img_array / 255.0
        img_batch = np.expand_dims(img_normalized, axis=0)
        
        # Prepare features
        features = np.array([
            soil_moisture / 100.0,  # Normalize
            temperature / 50.0,      # Normalize
            rainfall / 500.0 if rainfall else 0.0  # Normalize
        ]).reshape(1, -1)
        
        # ============ YOUR MODEL INFERENCE HERE ============
        # Example: Make prediction with your model
        # predicted_yield = model.predict([img_batch, features])[0][0]
        # For this example, returning a dummy prediction
        predicted_yield = float(soil_moisture * 0.5 + temperature * 1.5 + (rainfall or 0) * 0.1)
        confidence = 0.75 + (soil_moisture / 100.0) * 0.20
        # ==================================================
        
        return {
            "predicted_yield": round(predicted_yield, 2),
            "confidence": round(min(confidence, 0.99), 2),
            "soil_moisture_received": soil_moisture,
            "temperature_received": temperature,
            "message": "Prediction successful",
            "status": "success"
        }
    
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={
                "error": str(e),
                "message": "Prediction failed",
                "status": "error"
            }
        )


@app.get("/")
def root():
    """Root endpoint with API info"""
    return {
        "name": "Yield Prediction API",
        "version": "1.0.0",
        "endpoints": {
            "health": "/health",
            "predict": "/predict",
            "docs": "/docs"
        },
        "message": "Use /docs for interactive API documentation"
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
