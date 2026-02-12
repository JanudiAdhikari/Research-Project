# Disease Detection Integration Setup Guide

## Overview
This guide explains how to set up the CNN-based disease detection system for your Flutter mobile app.

## Components

### 1. Backend API (Flask)
Located in: `components/feature-disease detection/app.py`

**Features:**
- Disease detection using CNN model
- Image preprocessing
- Disease information endpoint
- Health check endpoint

**Requirements:**
- Python 3.8+
- TensorFlow 2.13.0
- Flask 2.3.2
- Pillow 10.0.0

### 2. Flutter Services
Located in: `lib/features/disease_detection/services/disease_detection_service.dart`

**Classes:**
- `DiseaseDetectionService` - Main service for API communication
- `DiseaseDetectionResult` - Result model from detection
- `DiseaseInfo` - Disease information model

### 3. UI Screens

#### disease_result_screen.dart
Displays:
- Captured/selected image
- Disease name and severity
- Confidence percentage with progress bar
- Description, treatment, and prevention info
- All prediction probabilities
- Action buttons

## Installation Steps

### Backend Setup

1. **Install Python dependencies:**
```bash
cd components/feature-disease detection
pip install -r requirements.txt
```

2. **Ensure model file exists:**
```
components/feature-disease detection/ml/pepper_disease_classifier_final.keras
```

3. **Run the Flask server:**
```bash
python app.py
```

The server will start on `http://0.0.0.0:5001`

### Flutter Setup

1. **Update dependency in pubspec.yaml:**
```yaml
dependencies:
  http: ^1.1.0
  camera: ^0.10.5
  image_picker: ^1.0.0
  firebase_auth: ^4.7.0
  firebase_storage: ^11.2.0
```

2. **Update API URL in service:**
In `disease_detection_service.dart`, update the `baseUrl`:
```dart
static const String baseUrl = 'http://YOUR_SERVER_IP:5001/api';
```

Replace `YOUR_SERVER_IP` with your actual backend server IP address.

3. **Run Flutter app:**
```bash
flutter pub get
flutter run
```

## Configuration

### Model Classes Mapping
Update the `DISEASE_CLASSES` dictionary in `app.py` to match your model's output classes:

```python
DISEASE_CLASSES = {
    0: {
        'name': 'Healthy',
        'description': 'The leaf appears healthy...',
        'treatment': 'Continue monitoring...',
        'severity': 'None'
    },
    1: {
        'name': 'Bacterial Spot',
        'description': 'Dark, greasy spots...',
        'treatment': 'Remove infected leaves...',
        'severity': 'High',
        'prevention': 'Avoid overhead watering...'
    },
    # Add more classes as per your model
}
```

### Image Preprocessing
The service expects images to be preprocessed to:
- Size: 224x224 pixels
- Normalized: 0-1 range
- Format: RGB

Adjust in `preprocess_image()` function if your model requires different dimensions.

## API Endpoints

### 1. Health Check
```
GET /health
Response: { status: 'healthy', message: '...' }
```

### 2. Disease Detection
```
POST /api/detect-disease
Content-Type: multipart/form-data
Parameter: image (File)

Response:
{
    'success': true,
    'disease': 'Bacterial Spot',
    'confidence': 92.45,
    'description': 'Dark, greasy spots on leaves...',
    'treatment': 'Remove infected leaves...',
    'severity': 'High',
    'prevention': 'Avoid overhead watering...',
    'all_predictions': {
        'Healthy': 0.023,
        'Bacterial Spot': 0.924,
        'Bell Pepper Blight': 0.042,
        'Target Spot': 0.011
    }
}
```

### 3. Disease Information
```
GET /api/disease-info/{disease_name}
Response: Disease details object
```

## Usage Flow

1. User selects or captures an image
2. Image is sent to Flask backend
3. CNN model processes the image
4. Results are returned to Flutter
5. `DiseaseResultScreen` displays:
   - Image preview
   - Disease name and severity
   - Confidence score
   - Description
   - Treatment recommendations
   - Prevention tips
   - All prediction probabilities

## Error Handling

The service handles:
- Network errors (no connection)
- Timeout errors (30 second timeout)
- Invalid image format
- API errors with descriptive messages

## Testing

### Backend Testing
```bash
# Test health check
curl http://localhost:5001/health

# Test disease detection (with image file)
curl -X POST -F "image=@test_image.jpg" http://localhost:5001/api/detect-disease
```

### Flutter Testing
The `DiseaseResultScreen` can be tested by:
1. Navigating to disease detection feature
2. Selecting an image from gallery or camera
3. Verifying results display correctly

## Troubleshooting

### Issue: "Network error: Unable to connect"
- **Solution:** Check if Flask server is running and accessible
- Ensure firewall allows port 5001
- Verify correct IP address in `baseUrl`

### Issue: "Request timed out"
- **Solution:** Increase timeout value in service
- Check network connectivity
- Verify image file size (large images may take longer)

### Issue: "Image preprocessing failed"
- **Solution:** Verify image format (JPG, PNG)
- Check image dimensions
- Ensure image is not corrupted

### Issue: "Model loading failed"
- **Solution:** Verify model file exists at correct path
- Check model file is not corrupted
- Ensure TensorFlow is properly installed

## Performance Optimization

1. **Image Compression:**
   - Already set to 90% quality in image picker
   - Reduces upload time and processing

2. **Caching:**
   - Consider caching disease information
   - Implement local storage for results

3. **Batch Processing:**
   - For multiple images, process sequentially
   - Implement queue system if needed

## Future Enhancements

1. Add local model inference (TensorFlow Lite for Flutter)
2. Implement result history/caching
3. Add confidence filtering
4. Implement user feedback system
5. Add image annotation features
6. Multi-language support for disease information

## Support
For issues or questions, check the Flutter console logs and Flask server logs for detailed error messages.

