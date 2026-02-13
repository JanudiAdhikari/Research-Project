# 🚀 IMMEDIATE ACTION - Fix Timeout Error

## The Issue
App timeout when detecting disease, but Flask is running ✓

## The Solution
**Service file is pre-configured for Android Emulator with `10.0.2.2`**

---

## What You Need To Do Now

### If Using Android Emulator
✅ **Already Fixed!**

```powershell
cd "F:\madara new\mobile-app"
flutter run
```

Test disease detection now!

---

### If Using Physical Android Phone
⏳ **Need 1 change:**

1. Open: `lib/features/disease_detection/services/disease_detection_service.dart`

2. **Find this (Line 10):**
```dart
static const String baseUrl = 'http://10.0.2.2:5001/api';
```

3. **Add `//` before it to comment:**
```dart
// static const String baseUrl = 'http://10.0.2.2:5001/api';
```

4. **Find this (Line 12) and remove `//`:**
```dart
// static const String baseUrl = 'http://192.168.75.1:5001/api';
```

5. **Make it active:**
```dart
static const String baseUrl = 'http://192.168.75.1:5001/api';
```

6. **Save file**

7. **Run app:**
```powershell
flutter run
```

---

## Verify It Works

1. Open app
2. Go to: Disease Detection
3. Take photo or select from gallery
4. Should analyze image (no timeout!)
5. Should show disease results
6. ✅ Success!

---

## If Still Timeout

**Verify 3 things:**

1. **Flask running?**
   ```powershell
   # Should show: TCP 0.0.0.0:5001 ... LISTENING
   netstat -ano | findstr :5001
   ```

2. **Phone on same WiFi?**
   - Check phone WiFi name
   - Compare with computer WiFi

3. **Firewall allows port 5001?** (Physical phone only)
   - Settings → Windows Defender Firewall
   - Allow an app through firewall
   - Find Python → Check both boxes

---

## Summary

| Setup | Action | Status |
|-------|--------|--------|
| Emulator | Just run app | ✅ Ready |
| Physical Phone | Uncomment IP | ⏳ Do this |

---

## One Minute Summary

1. **Emulator users:** Just run `flutter run`
2. **Phone users:** Swap the IP addresses (comment one, uncomment other)
3. **Then:** Test disease detection
4. **Result:** No more timeout! ✅

---

**Go!** Try it now and let me know if it works!

