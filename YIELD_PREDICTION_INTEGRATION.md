# Yield Prediction API Integration Guide

## Overview
This guide explains how to integrate your locally running yield prediction FastAPI with the Flutter mobile app.

## Current Setup
Your yield prediction API is running at:
```
http://127.0.0.1:8000
```

## Files Created/Modified

### 1. **Yield Prediction Service** (`lib/services/yield_prediction_service.dart`)
- Handles HTTP communication with the FastAPI backend
- Sends plant images and environmental parameters
- Returns predicted yield values
- Includes health check functionality

### 2. **Yield Prediction Provider** (`lib/providers/yield_prediction_provider.dart`)
- State management for yield predictions
- Handles loading states and error messages
- Manages API availability checks

### 3. **Updated New Prediction Screen** (`lib/features/yield_prediction/screens/new_prediction_screen.dart`)
- Integrated API calls from the provider
- Shows loading indicator during prediction
- Displays errors if prediction fails

## Configuration

### For Local Development (Emulator)
The service is pre-configured for local testing. The API will be called at:
```
http://127.0.0.1:8000
```

**Note:** Android emulator cannot reach localhost directly. Use one of these:

#### Option A: Emulator with Host Network Access
Edit `lib/services/yield_prediction_service.dart`:
```dart
static const String _baseUrl = 'http://10.0.2.2:8000'; // Special Android emulator IP for host
```

#### Option B: Physical Device on Same Network
1. Find your machine IP:
   ```bash
   ipconfig  # Windows
   ifconfig # Mac/Linux
   ```
   Look for "IPv4 Address" under your WiFi adapter (e.g., 192.168.1.100)

2. Edit `lib/services/yield_prediction_service.dart`:
   ```dart
   static const String _baseUrl = 'http://192.168.1.100:8000'; // Replace with your IP
   ```

3. Ensure both phone and API server are on the same WiFi network

### For Production Deployment
When deploying the API to a remote server, change the URL to your server's address.

## Expected API Endpoints

Your FastAPI server should have the following endpoints:

### 1. **POST /predict** - Yield Prediction
**Request:**
- `Content-Type: multipart/form-data`
- **Fields:**
  - `image` (file): Plant image
  - `soil_moisture` (float): 0-100
  - `temperature` (float): Temperature in °C
  - `rainfall` (float, optional): Rainfall in mm
  - `plant_age` (string, optional): e.g., "6-8 months"

**Response (200 OK):**
```json
{
  "predicted_yield": 42.5,
  "confidence": 0.85,
  "message": "Prediction successful"
}
```

### 2. **GET /health** - Health Check
**Response (200 OK):**
```json
{
  "status": "ok"
}
```

## Testing the Integration

### Step 1: Verify API is Running
Open the documentation at: `http://127.0.0.1:8000/docs`

### Step 2: Test with cURL (Windows PowerShell)
```powershell
$image = Get-Item "path\to\image.jpg"
$multipartContent = New-Object System.Net.Http.MultipartFormDataContent
$fileStream = [System.IO.File]::OpenRead($image.FullName)
$fileContent = New-Object System.Net.Http.StreamContent $fileStream
$fileContent.Headers.ContentType = "image/jpeg"
$multipartContent.Add($fileContent, "image", $image.Name)
$multipartContent.Add("50", "soil_moisture")
$multipartContent.Add("28", "temperature")

$httpClient = New-Object System.Net.Http.HttpClient
$response = $httpClient.PostAsync("http://127.0.0.1:8000/predict", $multipartContent).Result
Write-Output $response.Content.ReadAsStringAsync().Result
```

### Step 3: Run Flutter App
```bash
flutter run -v
```

In the app:
1. Go to "New Harvest Prediction"
2. Upload a plant image
3. Set soil moisture and temperature
4. Tap "Predict Yield"
5. Watch the logs for the API response

## Troubleshooting

### Connection Refused
- **Cause:** API not running or wrong URL
- **Solution:** 
  1. Verify API is running: `uvicorn app:app --reload` in your venv
  2. Check the URL in `yield_prediction_service.dart`

### 404 Not Found
- **Cause:** Wrong endpoint path
- **Solution:** Verify your API has `/predict` and `/health` endpoints

### Timeout Error
- **Cause:** API taking too long to respond
- **Solution:** Check API logs for processing delays; increase timeout from 30 seconds

### CORS Issues
- **Cause:** API doesn't allow requests from mobile app
- **Solution:** Add CORS middleware to your FastAPI app:
  ```python
  from fastapi.middleware.cors import CORSMiddleware
  
  app.add_middleware(
      CORSMiddleware,
      allow_origins=["*"],  # For development only
      allow_credentials=True,
      allow_methods=["*"],
      allow_headers=["*"],
  )
  ```

## Features

### Image Upload
- Automatically compresses and sends images
- Supports gallery and camera capture

### Error Handling
- Network errors display user-friendly messages
- Shows loading state during prediction
- Graceful timeout handling

### Health Checks
The app can verify API availability before attempting predictions. Call:
```dart
final provider = context.read<YieldPredictionProvider>();
await provider.checkApiAvailability();
if (provider.apiAvailable) {
  // Proceed with prediction
}
```

## Next Steps

1. **Verify API Endpoints:** Make sure your FastAPI app implements `/predict` and `/health`
2. **Test with Swagger:** Visit `http://127.0.0.1:8000/docs` to test endpoints manually
3. **Run Flutter App:** Follow the configuration steps based on your testing environment
4. **Monitor Logs:** Watch terminal logs for API responses and any errors

## Example FastAPI Endpoint

Here's what your endpoint should look like:

```python
from fastapi import FastAPI, UploadFile, File, Form
from fastapi.responses import JSONResponse

app = FastAPI()

@app.post("/predict")
async def predict_yield(
    image: UploadFile = File(...),
    soil_moisture: float = Form(...),
    temperature: float = Form(...),
    rainfall: float = Form(None),
    plant_age: str = Form(None)
):
    # Your prediction logic here
    predicted_yield = 42.5  # Replace with actual prediction
    
    return {
        "predicted_yield": predicted_yield,
        "confidence": 0.85,
        "message": "Prediction successful"
    }

@app.get("/health")
async def health_check():
    return {"status": "ok"}
```

## Support

For issues:
1. Check the Flutter console output for detailed error messages
2. Verify the API is accessible via browser at `http://127.0.0.1:8000/docs`
3. Ensure proper network connectivity between app and API
4. Check API logs for processing or model loading errors
