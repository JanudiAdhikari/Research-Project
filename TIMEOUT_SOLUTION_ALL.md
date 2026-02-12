# ✅ TIMEOUT FIX - Three Solutions

## Problem
App says "Detection failed - Request timeout" even though Flask is running.

## Root Causes (& Solutions)

---

## Solution 1: Using Android Emulator ⭐ (Most Likely)

### The Issue
Android Emulator cannot reach `192.168.75.1` - it needs special IP `10.0.2.2`

### The Fix
File: `disease_detection_service.dart` - Line 6 is **already fixed**!

```dart
static const String baseUrl = 'http://10.0.2.2:5001/api';
```

### Test It
1. Save and rebuild: `flutter run`
2. Try detecting disease
3. Should work! ✅

---

## Solution 2: Using Physical Android Phone

### Prerequisites
- ✅ Flask running: `python app.py`
- ✅ Phone on **same WiFi** as computer
- ✅ IP is `192.168.75.1`

### The Fix
Uncomment line 12 in `disease_detection_service.dart`:

```dart
static const String baseUrl = 'http://192.168.75.1:5001/api';
```

### If Still Timeout

**Allow Firewall:**
1. Windows Settings
2. Privacy & Security
3. Windows Defender Firewall
4. "Allow an app through firewall"
5. Click "Change settings"
6. Find "Python" 
7. Check both boxes (Private & Public)
8. Click OK
9. Restart Flask
10. Try again

### Test Connection
On phone browser, open:
```
http://192.168.75.1:5001/health
```

Should show:
```json
{"status":"healthy","message":"Disease Detection API is running"}
```

---

## Solution 3: IP Address Changed

### Check Your Current IP
```powershell
ipconfig
```

Look for your active WiFi connection's "IPv4 Address"

### If Different
Update line 12 in `disease_detection_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_NEW_IP:5001/api';
```

---

## Complete Checklist

- [ ] Flask running (`python app.py`)
- [ ] Shows: `Running on http://0.0.0.0:5001`
- [ ] Choose device type:
  - [ ] Android Emulator → Use `10.0.2.2`
  - [ ] Physical Phone → Use `192.168.75.1` or current IP
- [ ] Verify correct IP in `disease_detection_service.dart`
- [ ] Phone on same WiFi (physical phone only)
- [ ] Firewall allows port 5001 (physical phone only)
- [ ] Run: `flutter run`
- [ ] Test disease detection

---

## Quick Action

### If Android Emulator:
✅ Already fixed to use `10.0.2.2`
1. Run: `flutter run`
2. Test it!

### If Physical Phone:
1. Uncomment line 12 (use `192.168.75.1`)
2. Allow Python through firewall (see above)
3. Run: `flutter run`
4. Test it!

---

## Testing Steps

### Step 1: Verify IP
```powershell
ipconfig
```
Note the IPv4 Address

### Step 2: Test from Device
- **Emulator:** Open browser → `http://10.0.2.2:5001/health`
- **Phone:** Open browser → `http://192.168.75.1:5001/health`

Should show:
```json
{"status":"healthy","message":"Disease Detection API is running"}
```

### Step 3: If Browser Works, App Should Work
```powershell
flutter run
```

---

## If Still Not Working

### Try These Commands

```powershell
# Verify Flask is actually listening
netstat -ano | findstr :5001
# Expected: TCP 0.0.0.0:5001 ... LISTENING

# Test health endpoint
curl http://localhost:5001/health
# Expected: {"status":"healthy"...}

# Clean Flutter cache
cd mobile-app
flutter clean
flutter pub get
flutter run
```

### Check Flask Logs
Look at Flask terminal window for any error messages

### Increase Timeout (Temporary Test)
In `disease_detection_service.dart` line 27:
```dart
const Duration(seconds: 60),  // Change from 30 to 60
```

### Restart Everything
1. Stop Flask: Press `Ctrl+C`
2. Stop app: Press `Ctrl+C`
3. Restart Flask: `python app.py`
4. Restart app: `flutter run`

---

## Summary Table

| Device | IP | Status |
|--------|-----|--------|
| Android Emulator | 10.0.2.2 | ✅ Pre-configured |
| Physical Phone | 192.168.75.1 | ⏳ Need to uncomment |
| Different Network | Custom IP | ⏳ Update line 12 |

---

## Next Steps

1. **Tell me:** Are you using emulator or physical phone?
2. **Run:** `flutter run`
3. **Test:** Try detecting disease
4. **Report:** Did it work?

---

**Status:** Ready to fix! Which device are you using?

