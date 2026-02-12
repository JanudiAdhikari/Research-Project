# CNN Disease Detection Implementation Guide

## Overview
Your Flutter app now includes CNN-based disease detection with two implementation options:
1. **Backend API (Recommended for production)** - Process on Flask server
2. **Local Inference (Experimental)** - Process on device using TensorFlow Lite

## Files Created

### Backend API
- `components/feature-disease detection/app.py` - Flask API server
- `components/feature-disease detection/requirements.txt` - Python dependencies

### Flutter Services
- `lib/features/disease_detection/services/disease_detection_service.dart` - Backend API client
- `lib/features/disease_detection/services/local_disease_detection_service.dart` - Local inference (optional)

### UI Screens
- `lib/features/disease_detection/screens/disease_result_screen.dart` - NEW results display screen
- Updated `lib/features/disease_detection/screens/camera_screen.dart` - Camera integration
- Updated `lib/features/disease_detection/screens/image_picker_screen.dart` - Gallery integration

## Implementation Option 1: Backend API (RECOMMENDED)

### Setup Steps

**Step 1: Install Backend Dependencies**
```bash
cd components/feature-disease detection
pip install -r requirements.txt
```

**Step 2: Configure IP Address**
Edit `lib/features/disease_detection/services/disease_detection_service.dart`:
```dart
static const String baseUrl = 'http://192.168.X.X:5001/api';
```
Replace `192.168.X.X` with your backend server's IP address.

**Step 3: Start Flask Server**
```bash
cd components/feature-disease detection
python app.py
```
Server will run on: `http://0.0.0.0:5001`

**Step 4: Verify Connection**
```bash
curl http://192.168.X.X:5001/health
```

### Usage Flow
1. User captures photo or selects from gallery
2. Image sent to Flask backend
3. CNN model processes image
4. Results returned and displayed in `DiseaseResultScreen`

### Pros & Cons
✅ Pros:
- Offloads processing from device
- Can use larger, more accurate models
- Easy to update model without app update
- Better for older devices

❌ Cons:
- Requires internet connection
- Network latency
- Server infrastructure needed

---

## Implementation Option 2: Local Inference (TensorFlow Lite)

### Setup Steps

**Step 1: Add Dependencies to pubspec.yaml**
```yaml
dependencies:
  tflite_flutter: ^0.10.0
  image: ^4.0.0
```

**Step 2: Convert Model to TFLite**
```python
# Run in Python
import tensorflow as tf

# Load Keras model
model = tf.keras.models.load_model('pepper_disease_classifier_final.keras')

# Convert to TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Save
with open('pepper_disease_classifier.tflite', 'wb') as f:
    f.write(tflite_model)
```

**Step 3: Add Model to Assets**
```
mobile-app/assets/models/pepper_disease_classifier.tflite
```

**Step 4: Update pubspec.yaml**
```yaml
flutter:
  assets:
    - assets/models/pepper_disease_classifier.tflite
```

**Step 5: Update Result Screen to Use Local Service**
In `disease_result_screen.dart`, modify `_detectDisease()`:
```dart
Future<void> _detectDisease() async {
  try {
    setState(() => _isLoading = true);
    
    // Use local service instead
    final result = await LocalDiseaseDetectionService.detectDiseaseLocally(
      widget.imageFile,
    );
    
    if (mounted) {
      setState(() {
        _result = result as DiseaseDetectionResult?;
        _isLoading = false;
      });
    }
  } catch (e) {
    // Handle error
  }
}
```

### Pros & Cons
✅ Pros:
- No internet required
- Faster response (no network delay)
- Better privacy
- Works offline

❌ Cons:
- Device processing overhead
- Larger app size
- May be slower on older devices
- Model updates require app update

---

## API Endpoints (Backend Only)

### 1. Health Check
```
GET /health

Response:
{
    "status": "healthy",
    "message": "Disease Detection API is running"
}
```

### 2. Detect Disease
```
POST /api/detect-disease
Content-Type: multipart/form-data

Form Data:
- image: (File) The leaf image to analyze

Response:
{
    "success": true,
    "disease": "Bacterial Spot",
    "confidence": 94.23,
    "description": "Dark, greasy spots on leaves caused by bacterial infection.",
    "treatment": "Remove infected leaves, apply copper-based fungicides, ensure good air circulation.",
    "severity": "High",
    "prevention": "Avoid overhead watering, practice crop rotation.",
    "all_predictions": {
        "Healthy": 0.0234,
        "Bacterial Spot": 0.9423,
        "Bell Pepper Blight": 0.0298,
        "Target Spot": 0.0045
    }
}
```

### 3. Get Disease Info
```
GET /api/disease-info/Bacterial_Spot

Response:
{
    "name": "Bacterial Spot",
    "description": "...",
    "treatment": "...",
    "severity": "High",
    "prevention": "..."
}
```

---

## Result Screen Features

The `DiseaseResultScreen` displays:

1. **Image Preview**
   - Original captured/selected image

2. **Disease Card**
   - Disease name
   - Severity level (color-coded)
   - Severity icon

3. **Confidence Meter**
   - Percentage with progress bar
   - Visual confidence indicator

4. **Information Sections**
   - Description: What the disease is
   - Treatment: How to treat it
   - Prevention: How to prevent it

5. **Predictions Chart**
   - All disease probabilities
   - Comparison visualization

6. **Action Buttons**
   - "Analyze Another Image" - Start new detection
   - "Go Back" - Return to main screen

---

## Disease Classes

Update `DISEASE_CLASSES` in `app.py` or services based on your actual model:

```python
DISEASE_CLASSES = {
    0: {
        'name': 'Healthy',
        'description': 'The leaf appears healthy with no visible signs of disease.',
        'treatment': 'Continue with regular maintenance and monitoring.',
        'severity': 'None'
    },
    1: {
        'name': 'Bacterial Spot',
        'description': 'Dark, greasy spots on leaves caused by bacterial infection.',
        'treatment': 'Remove infected leaves, apply copper-based fungicides.',
        'severity': 'High',
        'prevention': 'Avoid overhead watering, practice crop rotation.'
    },
    # Add more classes matching your model output
}
```

---

## Integration with Home Screen

Update `home_screen.dart` to include disease detection:

```dart
// Open Camera for disease detection
_buildNavigationCard(
  title: _translate('detection_camera'),
  subtitle: _translate('detection_camera_subtitle'),
  icon: Icons.camera_alt_rounded,
  gradient: const LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
  ),
  onTap: () => _openCamera(context),
),

// Add gallery selection
_buildNavigationCard(
  title: _translate('select_from_gallery'),
  subtitle: _translate('gallery_subtitle'),
  icon: Icons.image_rounded,
  gradient: const LinearGradient(
    colors: [Color(0xFF42A5F5), Color(0xFF2196F3)],
  ),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ImagePickerScreen(),
    ),
  ),
),
```

---

## Error Handling

### Backend Errors
```dart
try {
  final result = await DiseaseDetectionService.detectDisease(imageFile);
} catch (e) {
  // Handles:
  // - Network errors
  // - Timeout errors (30 seconds)
  // - Invalid image format
  // - Server errors
  print('Error: $e');
}
```

### Local Inference Errors
```dart
try {
  final result = await LocalDiseaseDetectionService.detectDiseaseLocally(imageFile);
} catch (e) {
  // Handles:
  // - Model loading errors
  // - Image preprocessing errors
  // - Inference errors
  print('Error: $e');
}
```

---

## Performance Tips

1. **Compress Images**
   - Already set to 90% quality in image picker
   - Reduces upload/processing time

2. **Optimize Model**
   - Use quantized models for faster inference
   - Consider model pruning

3. **Caching**
   - Cache disease information
   - Store recent results locally

4. **Network Optimization**
   - Use gzip compression
   - Implement retry logic

---

## Testing

### Backend Testing
```bash
# Test health
curl http://192.168.1.100:5001/health

# Test with image
curl -X POST -F "image=@leaf_image.jpg" \
  http://192.168.1.100:5001/api/detect-disease
```

### Flutter Testing
1. Navigate to disease detection
2. Capture or select image
3. Verify results display
4. Check error handling

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Network error" | Check Flask server is running, verify IP address |
| "Request timeout" | Check network speed, consider increasing timeout |
| "Image format error" | Ensure image is JPG or PNG, not corrupted |
| "Model not found" | Verify model file exists at correct path |
| "API returns 500 error" | Check Flask logs, verify model loading |

---

## Next Steps

1. ✅ Test with sample images
2. ✅ Verify disease detection accuracy
3. ✅ Adjust confidence thresholds if needed
4. ✅ Add user feedback system
5. ✅ Implement result caching/history
6. ✅ Add multi-language support for disease info

---

## Support Files

- `DISEASE_DETECTION_SETUP.md` - Detailed setup guide
- Logs in Flutter console and Flask output
- Check model accuracy with test images

