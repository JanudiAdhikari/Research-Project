@echo off
echo ============================================
echo Quick Git History Fix
echo ============================================
echo.

cd /d "F:\madara new"

echo Step 1: Staging only the essential security fixes...
git add mobile-app/lib/services/chatbot_service.dart
git add mobile-app/lib/config/api_keys.dart.example
git add mobile-app/GROQ_SETUP.md
git add .gitignore

echo.
echo Step 2: Creating security fix commit...
git commit -m "fix: Remove hardcoded API key and implement secure configuration

- Remove exposed Groq API key from chatbot_service.dart
- Implement secure api_keys.dart configuration (gitignored)
- Add api_keys.dart.example template for team
- Update GROQ_SETUP.md with secure setup instructions

Fixes GitHub push protection violation"

echo.
echo Step 3: Removing the bad commit from history...
git reset --soft HEAD~2

echo.
echo Step 4: Re-staging all necessary files...
git add mobile-app/lib/services/chatbot_service.dart
git add mobile-app/lib/config/api_keys.dart.example
git add mobile-app/GROQ_SETUP.md
git add .gitignore

echo.
echo Step 5: Creating clean commit...
git commit -m "feat: Add Groq AI chatbot with secure API key management

- Implement chatbot service using Groq API (LLaMA 3.3 70B)
- Use secure api_keys.dart configuration (gitignored)
- Provide api_keys.dart.example template
- Update documentation with secure setup instructions"

echo.
echo Step 6: Force pushing to GitHub...
echo This will replace the remote history...
pause

git push origin feature/induwara --force

echo.
echo ============================================
echo Done! Now rotate your API key:
echo 1. Go to https://console.groq.com/keys
echo 2. Delete the old key
echo 3. Create a new key
echo 4. Update mobile-app\lib\config\api_keys.dart
echo ============================================
pause

