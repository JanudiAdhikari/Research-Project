# CNN Disease Detection - Architecture & Data Flow

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        FLUTTER MOBILE APP                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────┐    ┌──────────────┐    ┌──────────────────┐   │
│  │   Camera    │    │   Gallery    │    │  Home Screen     │   │
│  │   Screen    │    │   Picker     │    │  (Disease Card)  │   │
│  └──────┬──────┘    └──────┬───────┘    └────────┬─────────┘   │
│         │                  │                      │              │
│         └──────────────────┴──────────────────────┘              │
│                            │                                     │
│                            ▼                                     │
│         ┌──────────────────────────────────┐                    │
│         │   DiseaseDetectionService        │                    │
│         │   (Backend API Client)           │                    │
│         │   - HTTP request handling        │                    │
│         │   - Image upload (multipart)     │                    │
│         │   - JSON response parsing        │                    │
│         └──────────────┬───────────────────┘                    │
│                        │                                         │
│         ┌──────────────────────────────────┐                    │
│         │  DiseaseDetectionResult Model    │                    │
│         │  - disease name                  │                    │
│         │  - confidence %                  │                    │
│         │  - severity level                │                    │
│         │  - all predictions               │                    │
│         └──────────────┬───────────────────┘                    │
│                        │                                         │
│                        ▼                                         │
│         ┌──────────────────────────────────┐                    │
│         │   DiseaseResultScreen            │                    │
│         │   Beautiful Results Display      │                    │
│         │   - Image preview                │                    │
│         │   - Disease info                 │                    │
│         │   - Treatment & prevention       │                    │
│         │   - Confidence meter             │                    │
│         │   - All predictions chart        │                    │
│         └──────────────┬───────────────────┘                    │
│                        │                                         │
│                        ▼                                         │
│              [Analyze Another / Go Back]                        │
│                                                                   │
└─────────────────┬───────────────────────────────────────────────┘
                  │ (HTTP POST with image)
                  │
                  ▼
      ┌───────────────────────────┐
      │   FLASK BACKEND API       │  (Port 5001)
      │   disease_detection/app.py│
      ├───────────────────────────┤
      │ Routes:                   │
      │ GET  /health              │
      │ POST /api/detect-disease  │
      │ GET  /api/disease-info/*  │
      └───────────┬───────────────┘
                  │
                  ▼
      ┌───────────────────────────┐
      │   IMAGE PREPROCESSING     │
      │   - Decode from bytes     │
      │   - Resize to 224x224     │
      │   - Normalize (0-1)       │
      │   - Add batch dimension   │
      └───────────┬───────────────┘
                  │
                  ▼
      ┌───────────────────────────────────────┐
      │   CNN MODEL INFERENCE                 │
      │   TensorFlow/Keras                    │
      │   pepper_disease_classifier_final     │
      │                                       │
      │   Input:  (1, 224, 224, 3)           │
      │   Output: (1, 4) - 4 disease classes │
      └───────────┬───────────────────────────┘
                  │
                  ▼
      ┌──────────────────────────────┐
      │   RESULT PREPARATION         │
      │   - Find argmax              │
      │   - Get confidence           │
      │   - Map to disease class     │
      │   - Add treatment info       │
      │   - Format JSON response     │
      └───────────┬──────────────────┘
                  │
                  ▼ (JSON Response)
      ┌──────────────────────────────────────────┐
      │ {                                        │
      │   "success": true,                       │
      │   "disease": "Bacterial Spot",           │
      │   "confidence": 92.45,                   │
      │   "description": "...",                  │
      │   "treatment": "...",                    │
      │   "severity": "High",                    │
      │   "prevention": "...",                   │
      │   "all_predictions": {                   │
      │     "Healthy": 0.023,                    │
      │     "Bacterial Spot": 0.924,             │
      │     "Bell Pepper Blight": 0.042,         │
      │     "Target Spot": 0.011                 │
      │   }                                      │
      │ }                                        │
      └──────────────────────────────────────────┘
```

---

## Data Flow Diagram

```
START: User Opens App
    │
    ├─────────────────────────────────────┐
    │                                     │
    ▼                                     ▼
Take Photo                    Select from Gallery
    │                                     │
    └─────────────────────────────────────┘
                    │
                    ▼
    ┌───────────────────────────────┐
    │  Image File (File Object)     │
    │  - path: /storage/.../img.jpg │
    │  - size: variable             │
    └───────────────┬───────────────┘
                    │
                    ▼
    ┌───────────────────────────────────────┐
    │  Create HTTP Multipart Request        │
    │  - Content-Type: multipart/form-data  │
    │  - Field name: "image"                │
    │  - Field value: image file bytes      │
    └───────────────┬───────────────────────┘
                    │
                    ▼
    ┌───────────────────────────────────────┐
    │  POST to Backend                      │
    │  http://192.168.X.X:5001/api/...      │
    │  Timeout: 30 seconds                  │
    └───────────────┬───────────────────────┘
                    │
                    ▼
    ┌───────────────────────────────────────┐
    │  Backend Processes Image              │
    │  1. Receive file                      │
    │  2. Decode image                      │
    │  3. Resize to 224x224                 │
    │  4. Normalize pixel values            │
    │  5. Add batch dimension               │
    └───────────────┬───────────────────────┘
                    │
                    ▼
    ┌───────────────────────────────────────┐
    │  CNN Model Inference                  │
    │  Input shape: (1, 224, 224, 3)        │
    │  Output: [0.023, 0.924, 0.042, 0.011] │
    └───────────────┬───────────────────────┘
                    │
                    ▼
    ┌───────────────────────────────────────┐
    │  Find Best Match                      │
    │  argmax([0.023, 0.924, 0.042, 0.011]) │
    │  = index 1 (Bacterial Spot)           │
    │  = confidence 0.924 (92.4%)           │
    └───────────────┬───────────────────────┘
                    │
                    ▼
    ┌───────────────────────────────────────┐
    │  Get Disease Information              │
    │  DISEASE_CLASSES[1]                   │
    │  {                                    │
    │    name: "Bacterial Spot",            │
    │    description: "...",                │
    │    treatment: "...",                  │
    │    severity: "High",                  │
    │    prevention: "..."                  │
    │  }                                    │
    └───────────────┬───────────────────────┘
                    │
                    ▼
    ┌───────────────────────────────────────┐
    │  Format JSON Response                 │
    │  {                                    │
    │    "success": true,                   │
    │    "disease": "Bacterial Spot",       │
    │    "confidence": 92.4,                │
    │    "description": "...",              │
    │    "treatment": "...",                │
    │    "severity": "High",                │
    │    "prevention": "...",               │
    │    "all_predictions": {...}           │
    │  }                                    │
    └───────────────┬───────────────────────┘
                    │
                    ▼
    ┌───────────────────────────────────────┐
    │  Send Response to Mobile App          │
    │  Status Code: 200 OK                  │
    │  Content-Type: application/json       │
    └───────────────┬───────────────────────┘
                    │
                    ▼
    ┌───────────────────────────────────────┐
    │  Mobile App Receives Response         │
    │  Parse JSON                           │
    │  Create DiseaseDetectionResult object │
    └───────────────┬───────────────────────┘
                    │
                    ▼
    ┌───────────────────────────────────────┐
    │  Display DiseaseResultScreen          │
    │  Show:                                │
    │  - Image preview                      │
    │  - Disease name                       │
    │  - Severity badge                     │
    │  - Confidence meter                   │
    │  - Description                        │
    │  - Treatment steps                    │
    │  - Prevention tips                    │
    │  - All predictions chart              │
    └───────────────┬───────────────────────┘
                    │
            ┌───────┴───────┐
            │               │
            ▼               ▼
    Analyze Another    Go Back
    Image Button       Button
            │               │
            └───────┬───────┘
                    │
                    ▼
                 END
```

---

## File Communication Flow

```
User Interaction
        │
        ▼
┌─────────────────────────────────────┐
│ camera_screen.dart or              │
│ image_picker_screen.dart           │
│ (Capture/Select Image)             │
└────────────┬────────────────────────┘
             │ File imageFile
             ▼
┌─────────────────────────────────────┐
│ disease_detection_service.dart      │
│ .detectDisease(imageFile)           │
│                                     │
│ - Create HTTP request               │
│ - Add image as multipart            │
│ - Send to backend                   │
│ - Parse response                    │
│ - Return DiseaseDetectionResult     │
└────────────┬────────────────────────┘
             │ DiseaseDetectionResult
             ▼
┌─────────────────────────────────────┐
│ disease_result_screen.dart          │
│ Display Results                     │
│                                     │
│ - Show image                        │
│ - Disease name                      │
│ - Confidence                        │
│ - Description                       │
│ - Treatment                         │
│ - Prevention                        │
│ - Predictions chart                 │
└─────────────────────────────────────┘
```

---

## Component Dependencies

```
disease_result_screen.dart
├── imports: disease_detection_service.dart
├── uses: DiseaseDetectionResult
├── uses: DiseaseInfo
└── displays: Results from service

disease_detection_service.dart
├── imports: dart:io (File)
├── imports: package:http
├── models: DiseaseDetectionResult
├── models: DiseaseInfo
├── models: TimeoutException
└── connects to: Flask API

camera_screen.dart
├── imports: disease_result_screen.dart
├── uses: CameraController
├── navigates to: DiseaseResultScreen
└── captures: Image file

image_picker_screen.dart
├── imports: disease_result_screen.dart
├── uses: ImagePicker
├── navigates to: DiseaseResultScreen
└── selects: Image file from gallery
```

---

## Error Handling Flow

```
┌─────────────────────────────┐
│  Attempt Disease Detection  │
└────────────┬────────────────┘
             │
    ┌────────┴────────┐
    │                 │
    ▼                 ▼
  SUCCESS          ERROR
    │                 │
    │        ┌────────┴────────────┐
    │        │                     │
    │        ▼                     ▼
    │   SocketException      TimeoutException
    │        │                     │
    │        ▼                     ▼
    │   Network error         Request timed out
    │   (No connection)        (>30 seconds)
    │                          
    │   Show error screen with Retry button
    │        │
    │        └─────────────┐
    │                      │
    ▼                      ▼
Parse Response      User Retries
    │                      │
    │                      └─────────────┐
    │                                    │
    ▼                                    ▼
Create Result              Attempt Again
    │
    ▼
Display Screen
```

---

## Model Output to UI Flow

```
Raw Model Output (Softmax):
[0.023, 0.924, 0.042, 0.011]
     │
     ▼
Identify Classes:
Healthy: 2.3%
Bacterial Spot: 92.4% ← HIGHEST
Bell Pepper Blight: 4.2%
Target Spot: 1.1%
     │
     ▼
Get Predicted Class:
Index: 1
Disease: "Bacterial Spot"
Confidence: 92.4%
     │
     ▼
Get Disease Info:
Description: "Dark, greasy spots..."
Treatment: "Remove infected leaves..."
Severity: "High"
Prevention: "Avoid overhead watering..."
     │
     ▼
Map to UI Elements:
┌─────────────────────────┐
│ DISEASE NAME (Bold)     │ ← "Bacterial Spot"
│ [HIGH] severity badge   │ ← Severity with color
│                         │
│ Confidence: 92.4% ███░ │ ← Progress bar
│                         │
│ Description: ...        │ ← From disease_info
│ Treatment: ...          │ ← From disease_info
│ Prevention: ...         │ ← From disease_info
│                         │
│ All Predictions:        │
│ Healthy: 2.3% █░        │
│ Bacterial Spot: 92.4%███│ ← Highlighted
│ Bell Pepper Blight:4.2%░│
│ Target Spot: 1.1% ░     │
└─────────────────────────┘
```

---

## Deployment Architecture

### Backend API (Option 1)

```
Internet
    │
    ▼
┌──────────────────────────────┐
│     Your Computer/Server     │
│     192.168.X.X:5001         │
│                              │
│  ┌────────────────────────┐  │
│  │ Flask App (app.py)     │  │
│  │ - Receives requests    │  │
│  │ - Processes images     │  │
│  │ - Runs inference       │  │
│  │ - Returns results      │  │
│  └────────────┬───────────┘  │
│               │              │
│  ┌────────────▼───────────┐  │
│  │ CNN Model (Keras)      ���  │
│  │ pepper_disease...      │  │
│  │                        │  │
│  │ Input: 224x224 image   │  │
│  │ Output: 4 classes      │  │
│  └────────────────────────┘  │
│                              │
└──────────────────────────────┘
    ▲
    │ HTTP POST
    │ (WiFi/USB)
    │
┌───┴─────────────────────────┐
│  Mobile Phone               │
│  Flutter App                │
│  - Camera/Gallery           │
│  - Disease Detection Screen │
└─────────────────────────────┘
```

### Local Inference (Option 2)

```
┌──────────────────────────────┐
│     Mobile Phone             │
│     Flutter App              │
│                              │
│  ┌────────────────────────┐  │
│  │ Camera/Gallery Screen  │  │
│  └────────────┬───────────┘  │
│               │              │
│  ┌────────────▼───────────┐  │
│  │ Image Processing       │  │
│  │ - Resize to 224x224    │  │
│  │ - Normalize pixels     │  │
│  └────────────┬───────────┘  │
│               │              │
│  ┌────────────▼───────────┐  │
│  │ TFLite Model           │  │
│  │ On-device inference    │  │
│  │ pepper_disease...tflite│  │
│  └────────────┬───────────┘  │
│               │              │
│  ┌────────────▼───────────┐  │
│  │ Result Screen          │  │
│  │ - Display results      │  │
│  │ - Show predictions     │  │
│  └────────────────────────┘  │
│                              │
│ No network needed! ✅        │
└──────────────────────────────┘
```

---

## Summary

The disease detection system works as a seamless integration between:
1. **Mobile UI** - Captures/selects images
2. **Service Layer** - Handles API communication
3. **Backend API** - Processes images with CNN
4. **Result Display** - Shows comprehensive disease information

Choose Option 1 (Backend) for:
- More accurate results with larger models
- Easier model updates
- Better for older devices

Choose Option 2 (Local) for:
- Offline capability
- Faster inference (no network latency)
- Better privacy
- Works anywhere

Both options use the same `DiseaseResultScreen` for displaying results!

