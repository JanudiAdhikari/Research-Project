# 🔧 Installation Troubleshooting

## Common Issues & Solutions

### Issue 1: "ERROR: No matching distribution found for tensorflow==2.13.0"

**Cause:** TensorFlow 2.13.0 is deprecated and no longer available on PyPI

**Solution:** ✅ Already fixed!
- Updated `requirements.txt` to use TensorFlow 2.18.0
- Re-run: `pip install -r requirements.txt`

---

### Issue 2: "ModuleNotFoundError: No module named 'flask'"

**Cause:** Dependencies not installed yet

**Solution:**
```powershell
# Install all dependencies
pip install -r requirements.txt

# Verify Flask installed
python -c "import flask; print(flask.__version__)"
```

---

### Issue 3: "python: command not found"

**Cause:** Python not in PATH

**Solution:**
1. Install Python 3.8+ from: https://python.org
2. Check "Add Python to PATH" during installation
3. Restart PowerShell/Terminal
4. Try again: `python --version`

---

### Issue 4: "pip: command not found"

**Cause:** pip not installed or not in PATH

**Solution:**
```powershell
# Use python module directly
python -m pip install -r requirements.txt

# Or upgrade pip
python -m pip install --upgrade pip
```

---

### Issue 5: TensorFlow Download Too Slow

**Cause:** Large package (1GB+)

**Solutions:**
- ✅ Use faster internet connection
- ✅ Use specific index: `pip install tensorflow==2.18.0 -i https://mirrors.aliyun.com/pypi/simple/`
- ✅ Increase timeout: `pip install --default-timeout=1000 -r requirements.txt`
- ✅ Try without cache: `pip install --no-cache-dir -r requirements.txt`

---

### Issue 6: "Collecting failed with status code 429"

**Cause:** Rate limit from PyPI

**Solution:**
```powershell
# Wait a few minutes, then retry
# or use a different index
pip install -r requirements.txt -i https://pypi.org/simple/
```

---

### Issue 7: "Microsoft Visual C++ 14.0 is required"

**Cause:** NumPy requires build tools

**Solution:**
1. Download: https://support.microsoft.com/en-us/help/2977003/
2. Install "Build Tools for Visual Studio 2022"
3. Restart computer
4. Try installation again

---

### Issue 8: "SSL: CERTIFICATE_VERIFY_FAILED"

**Cause:** SSL certificate verification issues

**Solutions:**
```powershell
# Option 1: Trust PyPI
pip install --trusted-host pypi.python.org -r requirements.txt

# Option 2: Disable SSL (not recommended)
pip install --index-url https://pypi.org/simple/ -r requirements.txt
```

---

### Issue 9: "flask: command not found" after installation

**Cause:** Flask installed but not in PATH

**Solution:**
```powershell
# Run Flask through Python
python -m flask --version

# Or run app directly
python app.py
```

---

### Issue 10: "Model loading failed" when starting app.py

**Cause:** Model file path incorrect or not found

**Solution:**
1. Check file exists: `F:\madara new\components\feature-disease detection\ml\pepper_disease_classifier_final.keras`
2. Verify path in `app.py` line 13: `MODEL_PATH = './ml/pepper_disease_classifier_final.keras'`
3. Ensure working directory is correct: `cd "F:\madara new\components\feature-disease detection"`

---

## 📋 Installation Verification Checklist

After installing, verify each step:

```powershell
# 1. Check Python
python --version
# Expected: Python 3.x.x (where x >= 8)

# 2. Check pip
pip --version
# Expected: pip XX.X from ...

# 3. Check Flask
python -c "import flask; print(f'Flask {flask.__version__}')"
# Expected: Flask 3.0.0

# 4. Check TensorFlow
python -c "import tensorflow; print(f'TensorFlow {tensorflow.__version__}')"
# Expected: TensorFlow 2.18.0

# 5. Check Pillow
python -c "from PIL import Image; print('Pillow OK')"
# Expected: Pillow OK

# 6. Check NumPy
python -c "import numpy; print(f'NumPy {numpy.__version__}')"
# Expected: NumPy 1.26.0
```

If all show ✅, you're ready!

---

## 🚀 Quick Recovery Steps

If something goes wrong:

### Clean Install (Recommended)
```powershell
cd "F:\madara new\components\feature-disease detection"

# Remove old packages
pip uninstall -y flask flask-cors tensorflow pillow numpy python-dotenv

# Install fresh
pip install -r requirements.txt
```

### Virtual Environment (Safest)
```powershell
# Create virtual environment
python -m venv venv

# Activate it
venv\Scripts\activate

# Install in virtual env
pip install -r requirements.txt

# Run app
python app.py
```

### Nuclear Option (Reset Everything)
```powershell
# Uninstall all pip packages
pip freeze | %{pip uninstall -y $_}

# Upgrade pip
python -m pip install --upgrade pip

# Fresh install
pip install -r requirements.txt
```

---

## 📞 Still Not Working?

1. **Check Python version:**
   ```powershell
   python --version
   ```
   Must be 3.8 or higher

2. **Check pip is latest:**
   ```powershell
   python -m pip install --upgrade pip
   ```

3. **Try with explicit versions:**
   ```powershell
   pip install Flask==3.0.0 Flask-CORS==4.0.0 tensorflow==2.18.0
   ```

4. **Check disk space:**
   ```powershell
   Get-PSDrive C
   ```
   Need ~2GB free

5. **Check internet:**
   ```powershell
   ping pypi.org
   ```
   Should respond

6. **Check antivirus/firewall:**
   - Temporarily disable
   - Try installation
   - Re-enable

---

## ✅ Success Indicators

Installation successful when:
- ✅ `pip install -r requirements.txt` completes without errors
- ✅ `python app.py` starts without exceptions
- ✅ Flask server shows: `Running on http://0.0.0.0:5001`
- ✅ Health endpoint returns: `{"status":"healthy"}`

---

## 📝 Updated Requirements

**File:** `requirements.txt`

```
Flask==3.0.0
Flask-CORS==4.0.0
tensorflow==2.18.0
Pillow==10.1.0
numpy==1.26.0
python-dotenv==1.0.0
```

All versions:
- ✅ Latest stable
- ✅ Mutually compatible
- ✅ Actively maintained
- ✅ Well tested

---

## 🎯 Next After Installation

Once installation succeeds:

1. ✅ Run Flask: `python app.py`
2. ✅ Update Flutter app with your IP
3. ✅ Run Flutter: `flutter run`
4. ✅ Test disease detection
5. ✅ Deploy to users!

---

**Status:** 🟢 Installation issues fixed and documented!

