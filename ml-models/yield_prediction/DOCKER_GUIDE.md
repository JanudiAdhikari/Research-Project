# Yield Prediction Docker Container Guide

## 🎉 Image Successfully Built!

**Image Details:**
- Name: `yield-prediction:latest`
- Size: 4.23 GB
- Built: Multi-stage optimized build
- Base: Python 3.11-slim
- Status: ✅ Ready to run

---

## 🚀 Run the Container

### Option 1: Using Docker Compose (Recommended)
```bash
cd c:\Research-Project\ml-models\yield_prediction
docker-compose up -d
```

### Option 2: Using Docker Run
```bash
docker run -d \
  -p 8000:8000 \
  --name yield-api \
  --restart unless-stopped \
  yield-prediction:latest
```

### Option 3: Using Docker Run (Windows)
```powershell
docker run -d `
  -p 8000:8000 `
  --name yield-api `
  --restart unless-stopped `
  yield-prediction:latest
```

---

## ✅ Health Check

```bash
# Check if container is healthy
curl http://localhost:8000/health
```

Expected response:
```json
{
  "status": "healthy",
  "service": "yield-prediction-api",
  "version": "1.0.0"
}
```

---

## 📊 API Endpoints

### Predict Yield
```
POST http://localhost:8000/predict
```

**Request** (multipart/form-data):
- `files`: Image file (JPEG/PNG)
- `soil`: Soil moisture percentage (0-100)
- `temp`: Temperature in °C

**Example (cURL):**
```bash
curl -X POST "http://localhost:8000/predict" \
  -F "files=@plant_image.jpg" \
  -F "soil=52" \
  -F "temp=28"
```

**Response:**
```json
{
  "timestamp": "2026-03-08T10:30:45.123456",
  "predicted_yield_kg_per_plant": 2.45,
  "confidence_percent": 87.5,
  "crop_condition": "Healthy crop condition",
  "recommendations": ["Soil moisture is within optimal range..."],
  "xai_top_factors": {
    "soil_moisture_impact": 0.34,
    "temperature_impact": 0.28
  }
}
```

### Health Check
```
GET http://localhost:8000/health
```

---

## 📦 Container Management

### View Logs
```bash
docker logs -f yield-api
```

### Stop Container
```bash
docker stop yield-api
```

### Remove Container
```bash
docker rm yield-api
```

### Inspect Container
```bash
docker inspect yield-api
```

---

## 🔧 Optimization Details

### Multi-Stage Build Benefits:
✅ Separate builder and runtime stages
✅ Reduces final image size
✅ Removes build tools from final image
✅ Faster container startup

### Base Image:
✅ Python 3.11-slim (much smaller than full python:3.11)
✅ Minimal system dependencies included
✅ Only runtime libs installed in final stage

### Security:
✅ Non-root user (appuser:1000)
✅ Minimal attack surface
✅ Health check enabled

### Performance:
✅ Pinned dependency versions for reproducibility
✅ Caching optimized for faster rebuilds
✅ Read-only filesystem supported

---

## 📋 Troubleshooting

### Port Already in Use
```bash
# Change port mapping
docker run -p 9000:8000 yield-prediction:latest
# Then access at http://localhost:9000
```

### Out of Memory
```bash
# Run with memory limit
docker run -m 4g yield-prediction:latest
```

### Rebuild Image
```bash
cd c:\Research-Project\ml-models\yield_prediction
docker build -t yield-prediction:latest .
```

---

## 📝 Files Created

1. **Dockerfile** - Multi-stage optimized container config
2. **docker-compose.yml** - Container orchestration config
3. **.dockerignore** - Excludes unnecessary files
4. **requirements.txt** - Python dependencies (pinned versions)
5. **app.py** - Added `/health` endpoint

---

## 🌐 Accessing from Mobile App

Update your mobile app API base URL to:
```
http://host-ip:8000
```

Where `host-ip` is:
- Local: `http://10.0.2.2:8000` (Android emulator)
- Network: `http://192.168.x.x:8000` (real device)
- Production: `http://your-server-ip:8000`

---

## 📊 Performance Metrics

- Build time: ~5-10 minutes (first build, longer due to TensorFlow)
- Container size: 4.23 GB (TensorFlow + XGBoost intensive)
- Startup time: ~30-40 seconds
- Memory usage: ~2-3 GB when running
- CPU: Single-threaded inference ~2-5 seconds per image

