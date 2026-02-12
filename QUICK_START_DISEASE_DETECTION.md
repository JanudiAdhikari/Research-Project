# Quick Start Guide - Disease Detection

## For Developers: Get Started in 5 Minutes

### Option A: Backend API (Recommended)

#### Step 1: Start the Python backend
```bash
cd "F:\madara new\components\feature-disease detection"
pip install -r requirements.txt
python app.py
```
✅ Server running on http://0.0.0.0:5001

#### Step 2: Find your IP address
**On Windows:**
```powershell
ipconfig
```
Look for "IPv4 Address" (e.g., 192.168.X.X)

#### Step 3: Update Flutter code
Edit: `mobile-app/lib/features/disease_detection/services/disease_detection_service.dart`
```dart
static const String baseUrl = 'http://YOUR_IP_HERE:5001/api';
```

#### Step 4: Run Flutter app
```bash
cd "F:\madara new\mobile-app"
flutter pub get
flutter run
```

---

### Option B: Local Inference (No Backend Needed)

#### Step 1: Add dependencies
Edit `mobile-app/pubspec.yaml`:
```yaml
dependencies:
  tflite_flutter: ^0.10.0
  image: ^4.0.0
```

#### Step 2: Prepare model
- Convert `.keras` to `.tflite` format
- Place in `mobile-app/assets/models/`

#### Step 3: Update pubspec.yaml
```yaml
flutter:
  assets:
    - assets/models/
```

#### Step 4: Run app
```bash
cd "F:\madara new\mobile-app"
flutter pub get
flutter run
```

---

## How to Use in App

### From Camera
1. Open app → Disease Detection
2. Tap camera icon
3. Take photo of leaf
4. View results automatically

### From Gallery
1. Open app → Disease Detection
2. Tap gallery icon
3. Select image from phone
4. View results automatically

---

## What Results Show

✅ **Disease Name** - Type of disease detected
✅ **Confidence** - How certain (0-100%)
✅ **Severity** - High/Medium/Low/None
✅ **Description** - What the disease is
✅ **Treatment** - How to fix it
✅ **Prevention** - How to prevent it
✅ **All Predictions** - All disease probabilities

---

## Files Modified/Created

### New Files
- ✅ `components/feature-disease detection/app.py` - Flask API
- ✅ `components/feature-disease detection/requirements.txt` - Dependencies
- ✅ `mobile-app/lib/features/disease_detection/services/disease_detection_service.dart` - Backend client
- ✅ `mobile-app/lib/features/disease_detection/services/local_disease_detection_service.dart` - Local inference
- ✅ `mobile-app/lib/features/disease_detection/screens/disease_result_screen.dart` - Results UI

### Updated Files
- ✅ `mobile-app/lib/features/disease_detection/screens/camera_screen.dart` - Camera integration
- ✅ `mobile-app/lib/features/disease_detection/screens/image_picker_screen.dart` - Gallery integration

---

## Troubleshooting

### "Network error: Unable to connect"
- ✅ Is Flask server running? `python app.py`
- ✅ Correct IP address in code?
- ✅ Firewall allowing port 5001?

### "Request timed out"
- ✅ Check internet speed
- ✅ Image too large?
- ✅ Server responding slowly?

### "Image preprocessing failed"
- ✅ Image format is JPG/PNG?
- ✅ Image not corrupted?

### "Model loading failed"
- ✅ Model file exists?
- ✅ TensorFlow installed?

---

## Key Features

🎯 **Accuracy**
- Uses CNN model trained on pepper leaf diseases
- Shows confidence percentage
- Displays all prediction probabilities

📊 **Rich Information**
- Disease description
- Treatment recommendations
- Prevention tips
- Severity levels

🎨 **User-Friendly UI**
- Beautiful result screen
- Color-coded severity
- Progress indicators
- Actionable information

🔄 **Easy Integration**
- Works with camera or gallery
- Automatic flow
- Error handling built-in

---

## Next: Advanced Setup

For detailed setup instructions, see:
- 📖 `CNN_DISEASE_DETECTION_README.md` - Full guide
- 📖 `DISEASE_DETECTION_SETUP.md` - Technical details

---

## Support

If you have issues:
1. Check Flask server logs: `python app.py`
2. Check Flutter logs: Look for red errors
3. Verify network connection
4. Check file paths and permissions

Happy farming! 🌾

