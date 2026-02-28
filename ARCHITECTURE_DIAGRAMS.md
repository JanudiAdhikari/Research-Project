# 🎨 Visual Architecture & Setup Diagrams

## System Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                         FLUTTER MOBILE APP                       │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │          new_prediction_screen.dart                        │ │
│  │                                                            │ │
│  │  User uploads image + sets parameters                     │ │
│  │  [Image] [Soil: 45%] [Temp: 28°C]                        │ │
│  │  [Predict Yield Button]                                   │ │
│  └────────────────────┬───────────────────────────────────────┘ │
│                       │ calls                                    │
│  ┌────────────────────▼───────────────────────────────────────┐ │
│  │      yield_prediction_provider.dart                        │ │
│  │                                                            │ │
│  │  • performPrediction()                                    │ │
│  │  • _isLoading (show spinner)                             │ │
│  │  • _predictedYield (42.5)                                │ │
│  │  • _error (network issues)                               │ │
│  │  • notifyListeners() (UI refresh)                        │ │
│  └────────────────────┬───────────────────────────────────────┘ │
│                       │ uses                                     │
│  ┌────────────────────▼───────────────────────────────────────┐ │
│  │      yield_prediction_service.dart                        │ │
│  │                                                            │ │
│  │  • predictYield() - Makes HTTP request                   │ │
│  │  • healthCheck() - Verifies API alive                    │ │
│  │  • Error handling & timeouts                             │ │
│  │  • Multipart image upload                                │ │
│  │  • JSON response parsing                                 │ │
│  └────────────────────┬───────────────────────────────────────┘ │
└───────────────────────┼─────────────────────────────────────────┘
                        │
                        │ HTTP POST
                        │ multipart/form-data
                        ▼
┌──────────────────────────────────────────────────────────────────┐
│                  FASTAPI SERVER (Your Computer)                  │
│                  http://127.0.0.1:8000                          │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │           FastAPI Application                             │ │
│  │                                                            │ │
│  │  @app.post("/predict")                                    │ │
│  │  async def predict_yield(...):                            │ │
│  │                                                            │ │
│  │    1. Receive multipart request                           │ │
│  │    2. Extract and load image                              │ │
│  │    3. Preprocess (resize, normalize)                      │ │
│  │    ├─ Load trained ML model                               │ │
│  │    ├─ Extract image features                              │ │
│  │    ├─ Prepare parameters                                  │ │
│  │    4. Run model inference                                 │ │
│  │    5. Get prediction: 42.5                                │ │
│  │    6. Calculate confidence: 0.85                          │ │
│  │    7. Return JSON response                                │ │
│  │                                                            │ │
│  └────────────────────┬───────────────────────────────────────┘ │
│                       │ uses                                     │
│  ┌────────────────────▼───────────────────────────────────────┐ │
│  │   Your Trained ML Model                                   │ │
│  │                                                            │ │
│  │   TensorFlow / PyTorch / Scikit-learn                     │ │
│  │   (Your yield prediction model)                           │ │
│  │                                                            │ │
│  │   Input: [image features, env params]                    │ │
│  │   Output: 42.5 (predicted yield)                          │ │
│  │                                                            │ │
│  └────────────────────────────────────────────────────────────┘ │
└──────────────────────┬──────────────────────────────────────────┘
                        │
                        │ HTTP Response (JSON)
                        │ {"predicted_yield": 42.5, "confidence": 0.85}
                        ▼
┌──────────────────────────────────────────────────────────────────┐
│                      FLUTTER MOBILE APP                          │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │      prediction_result_screen.dart                         │ │
│  │                                                            │ │
│  │  ╔════════════════════════════════════════════════════╗   │ │
│  │  ║    HARVEST PREDICTION RESULT                      ║   │ │
│  │  ╠════════════════════════════════════════════════════╣   │ │
│  │  ║                                                    ║   │ │
│  │  ║  📊 Predicted Yield: 42.5 units                  ║   │ │
│  │  ║  🎯 Confidence: 85%                              ║   │ │
│  │  ║                                                    ║   │ │
│  │  ║  📈 Input Parameters Used:                        ║   │ │
│  │  ║  • Soil Moisture: 45%                            ║   │ │
│  │  ║  • Temperature: 28.5°C                           ║   │ │
│  │  ║  • Plant Image: [✓ Uploaded]                     ║   │ │
│  │  ║                                                    ║   │ │
│  │  ║  [Save] [Share] [New Prediction]                ║   │ │
│  │  ║                                                    ║   │ │
│  │  ╚════════════════════════════════════════════════════╝   │ │
│  │                                                            │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Data Flow Timeline

```
┌────────────────────────────────────────────────────────────────────┐
│                        USER INTERACTION FLOW                        │
└────────────────────────────────────────────────────────────────────┘

TIME    EVENT                    WHAT'S HAPPENING
────────────────────────────────────────────────────────────────────

 0ms →  Tap "Predict Yield"      User presses button
        
10ms →  Show Dialog              Loading spinner appears
        "Predicting..."          Dialog box with progress indicator
        
50ms →  Validate Input           Check image selected
        
100ms → Create Request            Prepare HTTP multipart request
        Pack image file          Add form fields (soil, temp, etc)
        
150ms → Send HTTP POST           Network transmission begins
        to http://127.0.0.1:8000/predict
        
200ms → Network Travel           Request traveling over network
   ▼
   ▼ (Emulator: ~50-100ms, Physical Device: ~100-300ms depending on WiFi)
   ▼
        
300ms → API Receives Request     FastAPI server gets data
        
350ms → Load Image               Read binary image file
        
400ms → Preprocess Image         Resize 224x224, normalize pixels
        
500ms → Load Model               TensorFlow/PyTorch loads model
        
600ms → Feature Extraction       Extract image features
        
700ms → Prepare Parameters       Format environmental data
        
800ms → Model Inference          Run through neural network
 ↓
 ↓ (Model processing: 500-2000ms depending on model size)
 ↓
 
2000ms→ Get Results              Model outputs: 42.5
        
2050ms→ Format Response          Create JSON response
        {"predicted_yield": 42.5, "confidence": 0.85}
        
2100ms→ Send Response            Network transmission to app
        
2200ms→ Network Travel           Response traveling back to phone
        
2300ms→ App Receives             JSON arrives at app
        
2310ms→ Parse JSON               Extract predicted_yield: 42.5
        
2320ms→ Update State             notifyListeners()
        
2330ms→ Close Dialog             Remove loading spinner
        
2340ms→ Navigate                 Go to results screen
        
2350ms→ Display Results          Show "Predicted Yield: 42.5"
        
2360ms→ ✅ USER SEES RESULT      "Done! Yield is 42.5"

────────────────────────────────────────────────────────────────────
TOTAL TIME: ~2.4 seconds (mostly model inference, not network)
```

---

## Environment Configuration Decision Tree

```
                    ┌─ Are you testing? ─┐
                    │                     │
                 YES│                     │NO
                    │                     │
          ┌─────────▼──────────┐    ┌────▼─────────────┐
          │  Using Emulator?   │    │  Using real      │
          │  or Physical Phone?│    │  device/phone?   │
          └─────────┬──────────┘    └────┬─────────────┘
                    │                    │
         ┌──YES─────┴──NO───┐            │
         │                  │            │
    ┌────▼──────┐    ┌──────▼──────┐    │
    │ EMULATOR  │    │  PHYSICAL   │    │
    │           │    │   DEVICE    │    │
    └────┬──────┘    └──────┬──────┘    │
         │                  │            │
    ┌────▼──────────┐  ┌────▼──────────┐│
    │ Use This URL: │  │ Use This URL: ││
    │ http://10.0.2│  │ http://YOUR-  ││
    │    .2:8000   │  │ PC-IP:8000    ││
    │              │  │ e.g. 192.168. ││
    │ Edit File:   │  │ 1.100:8000    ││
    │ lib/services/│  │               ││
    │ yield_      │  │ Steps:         ││
    │ prediction_ │  │ 1. ipconfig    ││
    │ service.    │  │ 2. Get IPv4    ││
    │ dart        │  │ 3. Use in URL  ││
    │              │  │ 4. Same WiFi  ││
    │ Line:        │  │                │
    │ static      │  │ Edit File:     │
    │ const       │  │ lib/services/  │
    │ String      │  │ yieldprediction│
    │ _baseUrl    │  │ service.dart   │
    │ = ...       │  │                │
    └────────────┘  │ Line:          │
                    │ static        │
                    │ const         │
                    │ String        │
                    │ _baseUrl      │
                    │ = ...         │
                    └────────────────┘
```

---

## Integration Checklist (Visual)

```
┌─────────────────────────────────────────────────────────────────┐
│  PHASE 1: Verify Your API                                       │
├─────────────────────────────────────────────────────────────────┤
│  [ ] API running: uvicorn app:app --reload                      │
│  [ ] See: "INFO: Uvicorn running on http://127.0.0.1:8000"      │
│  [ ] Swagger docs: http://127.0.0.1:8000/docs                   │
│  ✅ DONE                                                         │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  PHASE 2: Choose Configuration                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  If EMULATOR:              If PHYSICAL DEVICE:                 │
│  ┌─────────────────────┐  ┌──────────────────────┐             │
│  │ Edit file:          │  │ Run: ipconfig        │             │
│  │ yield_prediction... │  │ Copy: IPv4 Address   │             │
│  │ service.dart        │  │ (e.g. 192.168.1.100)│             │
│  │                     │  │                      │             │
│  │ Change to:          │  │ Edit file:           │             │
│  │ http://10.0.2.2     │  │ yield_prediction...  │             │
│  │ :8000               │  │ service.dart         │             │
│  │                     │  │                      │             │
│  │ [ ] DONE            │  │ Change to:           │             │
│  │                     │  │ http://IP:8000       │             │
│  │                     │  │                      │             │
│  │                     │  │ [ ] Same WiFi?       │             │
│  │                     │  │ [ ] DONE             │             │
│  └─────────────────────┘  └──────────────────────┘             │
│                                                                 │
│  ✅ Configuration selected & file updated                       │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  PHASE 3: Run Flutter App                                       │
├─────────────────────────────────────────────────────────────────┤
│  [ ] Terminal: cd mobile-app                                    │
│  [ ] flutter pub get                                            │
│  [ ] flutter run                                                │
│  [ ] Emulator/Device starts                                     │
│  [ ] App loads without errors                                   │
│  ✅ DONE                                                         │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  PHASE 4: Test Prediction                                       │
├─────────────────────────────────────────────────────────────────┤
│  [ ] Navigate to "Yield Prediction"                             │
│  [ ] Upload plant image                                         │
│  [ ] Set soil moisture slider (e.g., 45%)                       │
│  [ ] Set temperature slider (e.g., 28°C)                        │
│  [ ] Tap "Predict Yield" button                                 │
│  [ ] See loading spinner (2-5 seconds)                          │
│  [ ] Results screen shows ACTUAL yield value                    │
│  [ ] No error messages                                          │
│  ✅ SUCCESS! 🎉                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Request/Response Cycle (Detailed)

```
┌─────────────────────────────────────────────────────────────────┐
│                    1. CLIENT REQUEST                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  POST /predict HTTP/1.1                                        │
│  Host: 127.0.0.1:8000                                          │
│  Content-Type: multipart/form-data;                            │
│                boundary=----WebKitFormBoundary7MA4YWxk...      │
│  Content-Length: 2500000                                       │
│                                                                 │
│  ------WebKitFormBoundary7MA4YWxk                              │
│  Content-Disposition: form-data; name="image"; filename="..."  │
│  Content-Type: image/jpeg                                      │
│                                                                 │
│  [BINARY IMAGE DATA - 2.5 MB]                                 │
│                                                                 │
│  ------WebKitFormBoundary7MA4YWxk                              │
│  Content-Disposition: form-data; name="soil_moisture"          │
│                                                                 │
│  45.0                                                          │
│                                                                 │
│  ------WebKitFormBoundary7MA4YWxk                              │
│  Content-Disposition: form-data; name="temperature"            │
│                                                                 │
│  28.5                                                          │
│                                                                 │
│  ------WebKitFormBoundary7MA4YWxk                              │
│  Content-Disposition: form-data; name="plant_age"              │
│                                                                 │
│  6-8 months                                                    │
│                                                                 │
│  ------WebKitFormBoundary7MA4YWxk--                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│              2. SERVER PROCESSING (Inside FastAPI)              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ✓ Receive request                                            │
│  ✓ Parse multipart form-data                                  │
│  ✓ Extract image file                                         │
│  ✓ Load image: shape=(2448, 3264, 3)                          │
│  ✓ Resize to: (224, 224, 3)                                   │
│  ✓ Normalize: values to [0, 1] range                          │
│  ✓ Load model: tensorflow/model.h5                            │
│  ✓ Extract image features: shape=(1, 128)                     │
│  ✓ Prepare inputs: [img_features, env_params]                 │
│  ✓ Model inference: model.predict(inputs)                     │
│  ✓ Result: 42.5 (float)                                       │
│  ✓ Confidence: 0.85 (0-1 range)                               │
│  ✓ Format response JSON                                       │
│                                                                 │
│  TOTAL TIME: ~2 seconds                                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   3. SERVER RESPONSE                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  HTTP/1.1 200 OK                                              │
│  Content-Type: application/json                               │
│  Content-Length: 156                                          │
│  Server: Uvicorn                                              │
│                                                                 │
│  {                                                            │
│    "predicted_yield": 42.5,                                   │
│    "confidence": 0.85,                                        │
│    "message": "Prediction successful"                         │
│  }                                                            │
│                                                                 │
│  TIME TO SEND: ~100ms                                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│              4. CLIENT RECEIVES & PROCESSES                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ✓ Receive JSON response                                      │
│  ✓ Parse JSON                                                 │
│  ✓ Extract: predicted_yield = 42.5                            │
│  ✓ Extract: confidence = 0.85                                 │
│  ✓ Update provider state                                      │
│  ✓ Notify listeners (refresh UI)                              │
│  ✓ Close loading dialog                                       │
│  ✓ Navigate to results screen                                 │
│  ✓ Display: "Predicted Yield: 42.5"                           │
│  ✓ Display: "Confidence: 85%"                                 │
│                                                                 │
│  USER SEES RESULT: ✅                                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Error Handling Flow

```
┌─────────────────────────────────────────────────┐
│          IS API REACHABLE?                       │
├─────────────────────────────────────────────────┤
│                                                 │
│     ┌─────── YES ─────┬──── NO ────┐            │
│     │                 │            │            │
│  ┌──▼──┐          ┌───▼──┐        │            │
│  │SEND │          │ERROR │        │            │
│  │REQ  │          │      │        │            │
│  └──┬──┘          │"Cant │        │            │
│     │             │connct│        │            │
│     │             │"      │        │            │
│  ┌──▼──────────────┴───┐  │        │            │
│  │ DID REQUEST TIMEOUT?│  │        │            │
│  └─┬──────────────┬────┘  │        │            │
│    │              │       │        │            │
│   YES            NO      │        │            │
│    │              │       │        │            │
│ ┌──▼──┐      ┌────▼──┐   │        │            │
│ │ERROR│      │SERVER?│   │        │            │
│ │     │      │ERROR? │   │        │            │
│ │"TIM│      └─┬──┬───┘   │        │            │
│ │OUT"│        │  │       │        │            │
│ └────┘     YES NO       │        │            │
│              │  │       │        │            │
│           ┌──▼──▼──┐    │        │            │
│           │ERROR   │    │        │            │
│           │"Server │   │        │            │
│           │Error"  │   │        │            │
│           └────────┘   │        │            │
│                        │        │            │
│            VALID RESPONSE      │            │
│                        │        │            │
│            ┌───────────▼────────▼────┐      │
│            │ PARSE YIELD VALUE       │      │
│            │ 42.5                    │      │
│            └───────────┬─────────────┘      │
│                        │                    │
│            ┌───────────▼─────────────────┐  │
│            │ SHOW RESULT SCREEN         │  │
│            │                            │  │
│            │ Predicted Yield: 42.5 ✅  │  │
│            │ Confidence: 85%            │  │
│            └────────────────────────────┘  │
│                                             │
└─────────────────────────────────────────────┘
```

---

## File Structure Tree

```
Research-Project/
│
├── 📖 YIELD_API_QUICKSTART.md ⭐ START HERE
├── 📖 SETUP_CHECKLIST.md
├── 📖 YIELD_PREDICTION_INTEGRATION.md
├── 📖 YIELD_PREDICTION_README.md
├── 📖 API_DATA_FLOW.md
├── 📖 INTEGRATION_SUMMARY.md
├── 📖 FILE_STRUCTURE.md
├── 📖 YIELD_PREDICTION_SETUP_COMPLETE.md
├── 📄 FASTAPI_EXAMPLE.py
│
└── mobile-app/
    └── lib/
        ├── config/
        │   └── api.dart (MODIFIED ✏️)
        │       └─ Added yieldPredictionApiUrl
        │
        ├── services/ (NEW 🆕)
        │   ├── yield_prediction_service.dart (NEW ⭐)
        │   │   ├─ predictYield()
        │   │   ├─ healthCheck()
        │   │   └─ Error & timeout handling
        │   │
        │   └── (other services)
        │
        ├── providers/ (NEW 🆕)
        │   ├── yield_prediction_provider.dart (NEW ⭐)
        │   │   ├─ performPrediction()
        │   │   ├─ State management
        │   │   └─ UI notifications
        │   │
        │   └── (other providers)
        │
        └── features/
            └── yield_prediction/
                └── screens/
                    ├── new_prediction_screen.dart (MODIFIED ✏️)
                    │   └─ Integrated API calls
                    │
                    └── (other screens)

Legend:
⭐ = Key files for this integration
🆕 = Newly created
✏️ = Modified
📖 = Documentation
📄 = Example code
```

---

This visual guide helps understand the complete integration at a glance!
