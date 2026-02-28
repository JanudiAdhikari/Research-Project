# ✅ Yield Prediction API Integration - Setup Checklist

## Phase 1: Verify Your API (5 minutes)

- [ ] **API is running**
  ```bash
  cd e:\yield_api
  .\venv\Scripts\activate
  uvicorn app:app --reload
  ```
  Terminal should show:
  ```
  INFO:     Uvicorn running on http://127.0.0.1:8000
  ```

- [ ] **Check Swagger Documentation**
  Open: http://127.0.0.1:8000/docs
  - [ ] See Swagger UI interface
  - [ ] See `/health` endpoint listed
  - [ ] See `/predict` endpoint listed
  
- [ ] **Test Health Endpoint**
  In browser: http://127.0.0.1:8000/health
  Should return: `{"status":"ok"}` or similar

---

## Phase 2: Choose Your Environment (2 minutes)

### If Using Android Emulator:
- [ ] Edit: `mobile-app/lib/services/yield_prediction_service.dart`
- [ ] Find: `static const String _baseUrl = '...';`
- [ ] Change to: `static const String _baseUrl = 'http://10.0.2.2:8000';`

### If Using Physical Device:
- [ ] Open PowerShell and run:
  ```powershell
  ipconfig
  ```
- [ ] Find your IPv4 Address (e.g., 192.168.1.100)
- [ ] Edit: `mobile-app/lib/services/yield_prediction_service.dart`
- [ ] Find: `static const String _baseUrl = '...';`
- [ ] Change to: `static const String _baseUrl = 'http://192.168.1.100:8000';`
  (Replace with YOUR IPv4 address)
- [ ] Verify phone is on SAME WiFi as your PC

---

## Phase 3: Verify Integration Files (1 minute)

Check these files were created/modified:

- [ ] `lib/services/yield_prediction_service.dart` (NEW)
- [ ] `lib/providers/yield_prediction_provider.dart` (NEW)
- [ ] `lib/features/yield_prediction/screens/new_prediction_screen.dart` (MODIFIED)
- [ ] `lib/config/api.dart` (MODIFIED)

---

## Phase 4: Run Flutter App (5 minutes)

- [ ] Open Terminal
- [ ] Navigate to project:
  ```bash
  cd e:\Research-Project\mobile-app
  ```

- [ ] Get dependencies:
  ```bash
  flutter pub get
  ```

- [ ] Run app:
  ```bash
  flutter run
  ```

- [ ] Wait for app to load on emulator/device

---

## Phase 5: Test Prediction (3 minutes)

### In the Flutter App:

1. [ ] Launch app
2. [ ] Navigate to **"Yield Prediction"** or **"New Harvest Prediction"** screen
3. [ ] Upload a plant image:
   - [ ] Tap image upload area
   - [ ] Select image from gallery or take photo
   - [ ] Image displays in preview
4. [ ] Set Soil Moisture:
   - [ ] Adjust slider (e.g., 45%)
5. [ ] Set Temperature:
   - [ ] Adjust slider (e.g., 28°C)
6. [ ] Optional: Set Plant Age:
   - [ ] Select from dropdown if available
7. [ ] Tap **"Predict Yield"** button
8. [ ] Wait 2-5 seconds (shows loading spinner)
9. [ ] See prediction result screen with:
   - [ ] Predicted yield value (e.g., "42.5")
   - [ ] Confidence percentage
   - [ ] Your input parameters displayed

---

## Phase 6: Troubleshooting (If Issues)

### Issue: "Cannot connect to prediction server"

- [ ] Check API is running:
  ```bash
  Terminal should show: INFO:     Uvicorn running on http://127.0.0.1:8000
  ```

- [ ] Check correct URL in code:
  ```dart
  // For emulator:
  static const String _baseUrl = 'http://10.0.2.2:8000';
  
  // For physical device:
  static const String _baseUrl = 'http://YOUR.IP.HERE:8000';
  ```

- [ ] Check network connectivity:
  - [ ] Phone on same WiFi as PC (physical device)
  - [ ] Emulator network enabled

### Issue: Timeout Error

- [ ] API taking too long
- [ ] Check `yield_api` terminal for processing messages
- [ ] May need to wait for model to load first time
- [ ] Increase timeout from 30 to 60 seconds if needed:
  ```dart
  const Duration(seconds: 60) // instead of 30
  ```

### Issue: 404 Not Found

- [ ] Your API missing `/predict` endpoint
- [ ] Check `FASTAPI_EXAMPLE.py` for reference implementation
- [ ] Must have these endpoints:
  - [ ] `GET /health`
  - [ ] `POST /predict`

### Issue: Emulator Can't Connect

- [ ] Don't use `http://127.0.0.1:8000` (localhost)
- [ ] Use `http://10.0.2.2:8000` instead for emulator
- [ ] This is special Android emulator address for host machine

### Issue: Phone Can't Connect

- [ ] Must be on SAME WiFi network as API server
- [ ] Check firewall not blocking port 8000
- [ ] Use PC's actual IPv4 address, not localhost
- [ ] Verify with: `ipconfig`

---

## Phase 7: Verify API Endpoints (Optional)

### Manual Testing with cURL

**Health Check:**
```bash
curl http://127.0.0.1:8000/health
```
Should return: `{"status":"ok"}`

**Test Image Upload:**
```powershell
# PowerShell version
$image = Get-Item "C:\path\to\image.jpg"
$form = @{
    image = $image
    soil_moisture = "45.0"
    temperature = "28.5"
}
Invoke-WebRequest -Uri "http://127.0.0.1:8000/predict" -Method Post -Form $form
```

Should return: `{"predicted_yield": 42.5, ...}`

---

## Phase 8: Verify Integration Success

Check all these boxes:

- [ ] API running and accessible
- [ ] Flutter app launches without errors
- [ ] Can navigate to prediction screen
- [ ] Can upload image successfully
- [ ] Can set soil moisture & temperature
- [ ] "Predict Yield" button works
- [ ] Loading spinner appears (2-5 seconds)
- [ ] Results screen shows actual yield value
- [ ] No error messages in app
- [ ] Terminal shows successful API requests

---

## 🎯 Expected Result

When you tap "Predict Yield":

```
✅ Loading dialog appears
✅ 2-5 second wait while model processes
✅ Results screen shows:
   - Your uploaded image
   - Predicted yield value (not 0)
   - Confidence score
   - Your input parameters
✅ No error messages
```

---

## 📋 Documentation Reference

- **Quick Issues?** → `YIELD_API_QUICKSTART.md`
- **Need Help?** → `YIELD_PREDICTION_INTEGRATION.md`
- **Want Details?** → `API_DATA_FLOW.md`
- **See Code Example?** → `FASTAPI_EXAMPLE.py`
- **File Structure?** → `FILE_STRUCTURE.md`

---

## 💾 Important File Locations

### Your Modified Service
```
mobile-app/lib/services/yield_prediction_service.dart
```
🔑 Change `_baseUrl` here for different environments

### Your Modified Provider
```
mobile-app/lib/providers/yield_prediction_provider.dart
```
Used by screens for state management and loading

### Your Modified Screen
```
mobile-app/lib/features/yield_prediction/screens/new_prediction_screen.dart
```
Connected to provider, shows loading, displays results

---

## 🚀 One-Command Quick Test

After setting up:

```bash
# Terminal 1: Start API
cd e:\yield_api
.\venv\Scripts\activate
uvicorn app:app --reload

# Terminal 2: Start Flutter App
cd e:\Research-Project\mobile-app
flutter run
```

Then in app:
1. Go to Yield Prediction
2. Upload image
3. Set soil moisture to 45
4. Set temperature to 28
5. Tap "Predict Yield"
6. See result! 🎉

---

## ✨ Success Criteria

| Step | Done? | Signs of Success |
|------|-------|-----------------|
| Phase 1 | [ ] | API running, Swagger visible |
| Phase 2 | [ ] | Config file updated |
| Phase 3 | [ ] | All 4 files present |
| Phase 4 | [ ] | Flutter app launches |
| Phase 5 | [ ] | Yield value shows (not 0) |
| Phase 6 | [ ] | No errors in logs |
| Phase 7 | [ ] | API endpoints respond |
| Phase 8 | [ ] | Full integration working |

---

## 🎊 All Done!

When all checkboxes are ticked, your integration is complete! 

Your yield prediction model is now fully integrated with the Flutter mobile app.

**Users can now:**
- Upload plant images
- Get real yield predictions
- See confidence scores
- Understand their predictions

**Congratulations!** 🎉

---

## 📞 Still Need Help?

1. Check logs in both terminals for error messages
2. Verify API endpoint structure (POST /predict, GET /health)
3. Ensure image format is supported by your model
4. Test API directly in Swagger UI
5. Read YIELD_PREDICTION_INTEGRATION.md for detailed troubleshooting

**Everything you need is documented!**
