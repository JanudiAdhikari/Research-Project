from fastapi import FastAPI
from price_prediction.local_price.router import router as price_router
from quality_grading.router import router as quality_router

app = FastAPI(title="Ceylon Pepper ML Models API")

app.include_router(price_router, tags=["Price Prediction"])
app.include_router(quality_router, tags=["Quality Grading"])

