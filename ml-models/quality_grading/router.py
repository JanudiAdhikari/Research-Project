from fastapi import APIRouter, UploadFile, File, HTTPException
import numpy as np
import cv2
import os
from pathlib import Path

# Temporarily switch working directory so inference.py can find models
OLD_CWD = os.getcwd()
QUALITY_DIR = Path(__file__).resolve().parent
os.chdir(QUALITY_DIR)

from .inference import run_9_images

os.chdir(OLD_CWD)

router = APIRouter()

EXPECTED = [
    "bottom_full",
    "bottom_half",
    "bottom_close",
    "middle_full",
    "middle_half",
    "middle_close",
    "top_full",
    "top_half",
    "top_close",
]


def read_imagefile_to_bgr(file_bytes: bytes):
    nparr = np.frombuffer(file_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    return img


@router.get("/quality")
def quality_home():
    return {"message": "Pepper Quality API Running"}


@router.post("/infer/quality")
async def infer_quality(
    bottom_full: UploadFile = File(...),
    bottom_half: UploadFile = File(...),
    bottom_close: UploadFile = File(...),
    middle_full: UploadFile = File(...),
    middle_half: UploadFile = File(...),
    middle_close: UploadFile = File(...),
    top_full: UploadFile = File(...),
    top_half: UploadFile = File(...),
    top_close: UploadFile = File(...),
    texture_first: bool = True,
):
    files = {
        "bottom_full": bottom_full,
        "bottom_half": bottom_half,
        "bottom_close": bottom_close,
        "middle_full": middle_full,
        "middle_half": middle_half,
        "middle_close": middle_close,
        "top_full": top_full,
        "top_half": top_half,
        "top_close": top_close,
    }

    images = {}
    for k, f in files.items():
        data = await f.read()
        img = read_imagefile_to_bgr(data)
        if img is None:
            raise HTTPException(status_code=400, detail=f"Invalid image for {k}")
        images[k] = img

    result = run_9_images(images, texture_first=texture_first)
    return result
