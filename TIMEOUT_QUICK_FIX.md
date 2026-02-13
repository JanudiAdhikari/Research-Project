# 🚀 QUICK FIX - Connection Timeout

## Most Likely Issue: Android Emulator

If you're running Flutter on **Android Emulator** (not physical phone), the IP should be:

### Change This ❌
```dart
static const String baseUrl = 'http://192.168.75.1:5001/api';
```

### To This ✅
```dart
static const String baseUrl = 'http://10.0.2.2:5001/api';
```

**Why?** Android Emulator has special IP `10.0.2.2` to reach the host computer's localhost!

---

## If Physical Phone

Keep:
```dart
static const String baseUrl = 'http://192.168.75.1:5001/api';
```

But ensure:
1. ✅ Phone is on **same WiFi** as computer
2. ✅ Windows Firewall allows port 5001
3. ✅ Flask is running: `python app.py`

---

## Test Your Setup

### For Emulator:
Open browser on emulator → Go to: `http://10.0.2.2:5001/health`

### For Physical Phone:
Open browser on phone → Go to: `http://192.168.75.1:5001/health`

Should show:
```json
{"status":"healthy","message":"Disease Detection API is running"}
```

---

## The Fix (Choose One)

### Option 1: Using Android Emulator ⭐
```dart
// File: disease_detection_service.dart
// Line 6: Change to

static const String baseUrl = 'http://10.0.2.2:5001/api';
```

### Option 2: Using Physical Phone + Windows Firewall
1. Allow Python through firewall (see below)
2. Keep: `http://192.168.75.1:5001/api`

### Option 3: Using Physical Phone + No Firewall Issues
1. Verify same WiFi
2. Verify IP is still 192.168.75.1 (`ipconfig`)
3. Keep current settings

---

## Allow Firewall (If Physical Phone)

**Windows Defender Firewall:**
1. Settings → Privacy & Security → Windows Defender Firewall
2. "Allow an app through firewall"
3. "Change settings"
4. Scroll to "Python" → Check both boxes
5. Click OK

---

## After Fix

1. Update the IP in `disease_detection_service.dart`
2. Save file
3. Run: `flutter run`
4. Try detecting disease again
5. Should work! ✅

---

## Tell Me Your Setup

Are you using:
- [ ] Android Emulator (Google Play emulator)
- [ ] Physical Android Phone
- [ ] iOS Simulator

Based on your answer:
- **Emulator** → Use `10.0.2.2`
- **Physical Phone** → Use `192.168.75.1` + firewall allow

