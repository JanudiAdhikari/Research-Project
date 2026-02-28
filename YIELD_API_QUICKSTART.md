# ⚡ Quick Start: Yield Prediction API Integration

## 1️⃣ API Running (What You Have)
```
(venv) PS E:\yield_api> uvicorn app:app --reload
INFO: Uvicorn running on http://127.0.0.1:8000
```
✅ Good! Your API is ready.

---

## 2️⃣ Check API is Working
Open in browser: **http://127.0.0.1:8000/docs**
- See Swagger UI? ✅ API is working
- No response? ❌ API may have stopped

---

## 3️⃣ Configure Mobile App (Choose One)

### **Option A: Android Emulator** 
Edit: `mobile-app/lib/services/yield_prediction_service.dart`
```dart
static const String _baseUrl = 'http://10.0.2.2:8000';
```

### **Option B: Physical Device (Same WiFi)**
1. Find your PC's IP:
   ```powershell
   ipconfig
   ```
   Find: `IPv4 Address` (e.g., `192.168.1.100`)

2. Edit: `mobile-app/lib/services/yield_prediction_service.dart`
   ```dart
   static const String _baseUrl = 'http://192.168.1.100:8000';
   ```

3. Ensure phone is on same WiFi as PC

---

## 4️⃣ Run Flutter App
```bash
cd mobile-app
flutter pub get
flutter run
```

---

## 5️⃣ Test in App
1. Open "New Harvest Prediction" screen
2. Upload a plant image
3. Set soil moisture (20-80%)
4. Set temperature (15-40°C)
5. Tap "Predict Yield"
6. See result! 🎉

---

## ❌ Troubleshooting

| Issue | Fix |
|-------|-----|
| "Cannot connect to prediction server" | Check URL in `yield_prediction_service.dart` |
| Timeout error | API slow? Check logs in command window |
| 404 Not Found | API missing `/predict` endpoint |
| Connection Refused | API not running → Start it again |

---

## 📁 Files Modified
- ✅ `lib/services/yield_prediction_service.dart` (NEW)
- ✅ `lib/providers/yield_prediction_provider.dart` (NEW)
- ✅ `lib/features/yield_prediction/screens/new_prediction_screen.dart` (UPDATED)
- ✅ `lib/config/api.dart` (UPDATED)

---

## 📝 Expected API Response
```json
{
  "predicted_yield": 42.5,
  "confidence": 0.85,
  "message": "Prediction successful"
}
```

For more details, see: **YIELD_PREDICTION_INTEGRATION.md**
