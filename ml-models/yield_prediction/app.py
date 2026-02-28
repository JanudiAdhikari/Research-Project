from fastapi import FastAPI, File, UploadFile
import numpy as np
import joblib
import cv2
from xgboost import XGBRegressor
from tensorflow.keras.applications import EfficientNetB0
from tensorflow.keras.applications.efficientnet import preprocess_input

app = FastAPI()

# Load saved models
xgb_model = XGBRegressor()
xgb_model.load_model("xgb_model.json")

pca = joblib.load("pca.pkl")
scaler = joblib.load("scaler.pkl")

effnet = EfficientNetB0(
    weights='imagenet',
    include_top=False,
    input_shape=(224, 224, 3),
    pooling='avg'
)

@app.post("/predict")
async def predict(file: UploadFile = File(...), soil: float = 0, temp: float = 0):

    contents = await file.read()
    nparr = np.frombuffer(contents, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    img = cv2.resize(img, (224, 224))
    img = preprocess_input(img)

    img_feat = effnet.predict(np.expand_dims(img, axis=0))
    img_feat_reduced = pca.transform(img_feat)

    moisture_temp_ratio = soil / (temp + 1)
    moisture_squared = soil ** 2
    temp_squared = temp ** 2

    tab = np.array([[soil, temp,
                     moisture_temp_ratio,
                     moisture_squared,
                     temp_squared]])

    tab_scaled = scaler.transform(tab)

    X = np.concatenate([img_feat_reduced, tab_scaled], axis=1)

    prediction = xgb_model.predict(X)

    return {"predicted_yield": float(prediction[0])}