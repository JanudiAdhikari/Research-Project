# 📊 API Integration Data Flow & Examples

## Complete Request/Response Cycle

### 1. Mobile App Sends Prediction Request

```
User Action: Taps "Predict Yield" Button
     ↓
App Receives:
- Image file: /path/to/plant_image.jpg
- Soil Moisture: 45.0 (%)
- Temperature: 28.5 (°C)
- Plant Age: "6-8 months"
     ↓
Builds HTTP Request:
```

**HTTP Request:**
```
POST http://127.0.0.1:8000/predict HTTP/1.1
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary

------WebKitFormBoundary
Content-Disposition: form-data; name="image"; filename="plant.jpg"
Content-Type: image/jpeg

[Binary image data...]

------WebKitFormBoundary
Content-Disposition: form-data; name="soil_moisture"

45.0
------WebKitFormBoundary
Content-Disposition: form-data; name="temperature"

28.5
------WebKitFormBoundary
Content-Disposition: form-data; name="plant_age"

6-8 months
------WebKitFormBoundary--
```

---

### 2. FastAPI Server Processes Request

```python
@app.post("/predict")
async def predict_yield(
    image: UploadFile = File(...),
    soil_moisture: float = Form(...),
    temperature: float = Form(...),
    rainfall: Optional[float] = Form(None),
    plant_age: Optional[str] = Form(None),
):
    # Step 1: Load and preprocess image
    image_data = await image.read()
    img = Image.open(io.BytesIO(image_data))
    img_resized = img.resize((224, 224))
    img_normalized = np.array(img_resized) / 255.0
    
    # Step 2: Load your trained model
    model = your_trained_model()
    
    # Step 3: Make prediction
    image_features = extract_features(img_normalized)
    environmental_features = [soil_moisture, temperature]
    prediction = model.predict([image_features, environmental_features])
    
    # Step 4: Return response
    return {
        "predicted_yield": float(prediction[0]),
        "confidence": 0.85,
        "message": "Prediction successful"
    }
```

---

### 3. API Server Returns Response

**HTTP Response (200 OK):**
```json
{
  "predicted_yield": 42.5,
  "confidence": 0.85,
  "message": "Prediction successful"
}
```

---

### 4. Mobile App Displays Results

```
Loading Dialog Closes
     ↓
PredictionResultScreen Displays:
┌─────────────────────────────────────┐
│  HARVEST PREDICTION RESULT          │
├─────────────────────────────────────┤
│                                     │
│  📊 Predicted Yield: 42.5 units    │
│  🎯 Confidence: 85%                │
│                                     │
│  📈 Environmental Factors:         │
│     • Soil Moisture: 45%           │
│     • Temperature: 28.5°C          │
│     • Plant Age: 6-8 months        │
│                                     │
│  [Save] [Share] [Close]            │
│                                     │
└─────────────────────────────────────┘
```

---

## 🔄 Complete Code Flow

### Step 1: User Interaction (new_prediction_screen.dart)
```dart
ElevatedButton(
  onPressed: () async {
    // Step 1: Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Step 2: Get provider and call prediction
    final provider = context.read<YieldPredictionProvider>();
    final success = await provider.performPrediction(
      imageFile: selectedImage!,
      soilMoisture: soilMoisture,
      temperature: temperature,
      plantAge: plantAge,
    );

    // Step 3: Close loading and handle result
    Navigator.pop(context);
    
    if (success) {
      // Navigate to results with predicted value
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PredictionResultScreen(
            predictedYield: provider.predictedYield,  // 42.5
            soilMoisture: soilMoisture,               // 45.0
            temperature: temperature,                  // 28.5
            imageFile: selectedImage!,
          ),
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? "Prediction failed")),
      );
    }
  },
  child: Text("Predict Yield"),
)
```

### Step 2: Provider Handles State (yield_prediction_provider.dart)
```dart
class YieldPredictionProvider extends ChangeNotifier {
  final YieldPredictionService _service = YieldPredictionService();

  Future<bool> performPrediction({
    required File imageFile,
    required double soilMoisture,
    required double temperature,
    String? plantAge,
  }) async {
    _isLoading = true;      // Show loading spinner
    _error = null;
    notifyListeners();

    try {
      // Call the service (which makes HTTP request)
      _predictedYield = await _service.predictYield(
        imageFile: imageFile,
        soilMoisture: soilMoisture,
        temperature: temperature,
        plantAge: plantAge,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;  // Success
      
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;  // Failed
    }
  }
}
```

### Step 3: Service Makes HTTP Request (yield_prediction_service.dart)
```dart
class YieldPredictionService {
  static const String _baseUrl = 'http://127.0.0.1:8000';

  Future<double> predictYield({
    required File imageFile,
    required double soilMoisture,
    required double temperature,
    String? plantAge,
  }) async {
    try {
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/predict'),
      );

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      // Add form fields
      request.fields['soil_moisture'] = soilMoisture.toString();
      request.fields['temperature'] = temperature.toString();
      if (plantAge != null) request.fields['plant_age'] = plantAge;

      // Send request (with 30-second timeout)
      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Request timed out'),
      );

      // Parse response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(
          await response.stream.bytesToString()
        );
        return (responseData['predicted_yield'] ?? 0.0).toDouble();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
      
    } on SocketException {
      throw Exception('Cannot connect to server at $_baseUrl');
    } catch (e) {
      throw Exception('Prediction error: $e');
    }
  }
}
```

---

## 📱 Example: Real Data Trace

### Input Data
```
Image: plant_photo.jpg (2.5 MB) → Compressed during upload
Soil Moisture: 45.0 %
Temperature: 28.5 °C
Plant Age: "6-8 months"
```

### Network Request (Simplified)
```
POST /predict HTTP/1.1
Host: 127.0.0.1:8000

[Multipart form data with image + parameters]

Duration: ~2-5 seconds (depending on model)
```

### API Processing
```
1. Receive multipart request
2. Extract image (plant_photo.jpg)
3. Resize to 224x224 pixels
4. Normalize pixel values (0-1)
5. Load trained model
6. Forward image + params through model
7. Get output: [42.5] (yield units)
8. Calculate confidence: 85%
9. Format JSON response
10. Return to mobile app
```

### Network Response
```
HTTP/1.1 200 OK
Content-Type: application/json

{
  "predicted_yield": 42.5,
  "confidence": 0.85,
  "message": "Prediction successful"
}

Duration: ~100ms for response
```

### Display on Mobile
```
App receives JSON
Parses: predicted_yield = 42.5
Closes loading dialog
Navigates to PredictionResultScreen
Shows: 
  - Predicted Yield: 42.5 units
  - Confidence: 85%
  - All input parameters
  - Plant image
  - Save/Share options
```

---

## 🔍 Debugging: View Actual Requests/Responses

### In Flutter Console
```
I: HTTP POST to http://127.0.0.1:8000/predict
I: Headers: Content-Type: multipart/form-data
I: Sending image file: plant.jpg (2.5 MB)
I: Form fields: soil_moisture=45.0, temperature=28.5
I: Waiting for response...
I: Response received (status 200)
I: Body: {"predicted_yield": 42.5, "confidence": 0.85, ...}
I: Parsing complete
```

### In FastAPI Logs
```
INFO:     127.0.0.1:62797 - "POST /predict HTTP/1.1" 200 OK
Loading image...
Image shape: (224, 224, 3)
Running model inference...
Prediction: [42.5]
Confidence: 0.85
Response sent successfully
```

---

## ⚡ Performance Timeline

```
Timeline:
┌──────────────────────────────────────────────────────┐
│  0ms    → User taps "Predict Yield"                  │
│  10ms   → Loading dialog shown                       │
│  50ms   → Image file opened & prepared               │
│  100ms  → HTTP request created                       │
│  150ms  → Request sent to API                        │
│          ↓ Network latency (50-200ms)               │
│  300ms  → API receives request                       │
│          ↓ Image preprocessing (100-300ms)          │
│  500ms  → Model inference starts (500-2000ms)       │
│  2500ms → API sends response                        │
│          ↓ Network latency (50-200ms)               │
│  2650ms → App receives response                     │
│  2660ms → Response parsed                           │
│  2670ms → Loading dialog closes                     │
│  2680ms → Results screen displays                   │
│  2690ms → User sees: "Predicted Yield: 42.5"        │
└──────────────────────────────────────────────────────┘

Total Duration: ~2.7 seconds
(Most time is model inference, not network)
```

---

## 🧪 Test Endpoints with cURL

### Health Check
```bash
curl -X GET "http://127.0.0.1:8000/health"

Response:
{
  "status": "ok"
}
```

### Prediction (Windows PowerShell)
```powershell
$image = Get-Item "C:\path\to\image.jpg"
$form = @{
    image = $image
    soil_moisture = "45.0"
    temperature = "28.5"
    plant_age = "6-8 months"
}

Invoke-WebRequest -Uri "http://127.0.0.1:8000/predict" `
    -Method Post `
    -Form $form

Response:
{
  "predicted_yield": 42.5,
  "confidence": 0.85,
  "message": "Prediction successful"
}
```

---

## 📋 Error Response Examples

### Invalid Image
```json
{
  "error": "Invalid image file",
  "message": "Prediction failed",
  "status": "error"
}
```

### Missing Parameters
```json
{
  "error": "soil_moisture is required",
  "message": "Prediction failed",
  "status": "error"
}
```

### Model Error
```json
{
  "error": "Model inference failed: shape mismatch",
  "message": "Prediction failed",
  "status": "error"
}
```

### Server Error
```json
{
  "error": "Internal server error",
  "message": "Prediction failed",
  "status": "error"
}
(HTTP 500)
```

---

## 🎯 Success Criteria

✅ Request sent with all required fields
✅ Image successfully transmitted  
✅ API returns 200 status code
✅ Response contains "predicted_yield" field
✅ Value is within expected range (e.g., 0-100)
✅ Confidence score is between 0-1
✅ UI updates with actual prediction value

---

This flow ensures reliable, error-handled communication between your Flutter app and Python FastAPI server!
