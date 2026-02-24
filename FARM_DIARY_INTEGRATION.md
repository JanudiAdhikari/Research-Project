# Farm Diary Integration Guide

## Quick Start

### 1. Backend Setup

#### Install Dependencies
The backend already has all required packages. Ensure your `.env` file has:
```
MONGO_URI=your_mongodb_connection_string
```

#### Test the API
```bash
cd backend
npm run dev
```

Test endpoints with curl:
```bash
# Get entries
curl -X GET http://localhost:5000/api/farm-diary/entries \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"

# Create entry
curl -X POST http://localhost:5000/api/farm-diary/entries \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "farmPlotId": "plot_id",
    "title": "Watering Session",
    "description": "Morning watering",
    "activityType": "watering",
    "diaryDate": "2024-02-24T10:00:00Z"
  }'
```

### 2. Flutter Setup

#### Add to pubspec.yaml
```yaml
dependencies:
  intl: ^0.19.0  # Already included
  shared_preferences: ^2.5.3  # Already included
  flutter_secure_storage: ^9.2.4  # Already included
  http: 1.6.0  # Already included
```

All dependencies are already in your pubspec.yaml!

#### Update API Configuration
In `lib/config/api.dart`, ensure the base URL is correct:
```dart
class ApiConfig {
  static const String baseUrl = "http://10.0.2.2:5000"; // Android emulator
  // For physical device:
  // static const String baseUrl = "http://YOUR_DEVICE_IP:5000";
}
```

#### Initialize in main.dart
```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'providers/farm_diary_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final prefs = await SharedPreferences.getInstance();
  final secureStorage = const FlutterSecureStorage();
  
  // Initialize Firebase and other services
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}
```

#### Add to Navigation
In your main navigation or dashboard:
```dart
import 'features/farm_diary/screens/farm_diary_list_screen.dart';

// In your navigation:
FarmDiaryListScreen(farmPlotId: selectedFarmPlotId)
```

### 3. Provider Setup  

Create a provider wrapper in your app to avoid initialization issues:

```dart
// Create: lib/providers/app_providers.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'farm_diary_provider.dart';

class AppProviders {
  static late SharedPreferences _prefs;
  static late FlutterSecureStorage _secureStorage;
  static late FarmDiaryProvider _farmDiaryProvider;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _secureStorage = const FlutterSecureStorage();
    _farmDiaryProvider = FarmDiaryProvider(
      secureStorage: _secureStorage,
      prefs: _prefs,
    );
  }

  static FarmDiaryProvider get farmDiary => _farmDiaryProvider;
}

// In main.dart:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await AppProviders.initialize();
  
  runApp(const MyApp());
}

// In screens:
void navigateToFarmDiary(BuildContext context, String farmPlotId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChangeNotifierProvider.value(
        value: AppProviders.farmDiary,
        child: FarmDiaryListScreen(farmPlotId: farmPlotId),
      ),
    ),
  );
}
```

### 4. Update Flutter Screens

Fix the provider initialization in the three diary screens:

#### In farm_diary_list_screen.dart
```dart
@override
void initState() {
  super.initState();
  _provider = AppProviders.farmDiary; // Use global provider
  _loadEntries();
}
```

#### Similar updates for farm_diary_detail_screen.dart and farm_diary_form_screen.dart

### 5. Test the Integration

#### Create Test Entry
```bash
# 1. Get auth token from Firebase
# 2. Create entry
curl -X POST http://localhost:5000/api/farm-diary/entries \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "farmPlotId": "your_plot_id",
    "title": "Test Entry",
    "description": "Testing farm diary",
    "activityType": "inspection",
    "diaryDate": "2024-02-24T14:00:00Z",
    "weather": {
      "condition": "sunny",
      "temperature": 28.5,
      "humidity": 65,
      "rainfall": 0
    },
    "observations": {
      "plantHealth": "good"
    }
  }'
```

#### Test Offline Sync
1. Create entry while offline
2. Entry stored locally with "pending" status
3. Reconnect internet
4. Click cloud icon to sync
5. Entry updates to "synced" status

### 6. Add to Navigation Menu

```dart
// In your navigation wrapper or dashboard:
ListTile(
  leading: const Icon(Icons.book),
  title: const Text('Farm Diary'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: AppProviders.farmDiary,
          child: FarmDiaryListScreen(farmPlotId: selectedFarmPlotId),
        ),
      ),
    );
  },
),
```

## Project File Structure

### Backend
```
backend/
├── src/
│   ├── models/
│   │   └── farm_diary.model.js     ✅ Created
│   ├── controllers/
│   │   └── farm_diary.controller.js ✅ Created
│   ├── routes/
│   │   └── farm_diary.routes.js     ✅ Created
│   └── index.js                      ✅ Updated
└── package.json                      ✅ Ready
```

### Mobile App (Flutter)
```
mobile-app/lib/
├── models/
│   └── farm_diary.dart              ✅ Created
├── services/
│   └── farm_diary_service.dart      ✅ Created
├── providers/
│   └── farm_diary_provider.dart     ✅ Created
├── features/
│   └── farm_diary/
│       └── screens/
│           ├── farm_diary_list_screen.dart    ✅ Created
│           ├── farm_diary_detail_screen.dart  ✅ Created
│           └── farm_diary_form_screen.dart    ✅ Created
└── config/
    └── api.dart                      ✅ Ready
```

## Common Issues & Solutions

### Issue: Provider not initialized
**Solution**: Use the AppProviders.initialize() pattern shown above

### Issue: CORS errors from API
**Solution**: Backend already has CORS configured. Check API base URL in config/api.dart

### Issue: Token not sending with requests
**Solution**: Check that FlutterSecureStorage has auth_token saved:
```dart
final token = await secureStorage.read(key: 'auth_token');
print('Token: $token'); // Debug
```

### Issue: Offline entries not syncing
**Solution**: 
1. Verify internet connection
2. Check that user is authenticated
3. Review console logs for error messages
4. Manually trigger sync via cloud icon

### Issue: Images not displaying
**Solution**:
1. Verify image URLs are valid
2. Check Cloudinary configuration
3. CORS must be enabled for image server

## Environment Variables

### Backend .env
```
MONGO_URI=mongodb+srv://user:password@cluster.mongodb.net/dbname
PORT=5000
NODE_ENV=development
```

### Flutter config/api.dart
```dart
// For emulator:
static const String baseUrl = "http://10.0.2.2:5000";

// For physical device (update with your IP):
static const String baseUrl = "http://192.168.1.5:5000";
```

## Performance Tips

1. **Pagination** (Future Enhancement)
   - Implement pagination for large datasets
   - Add page size parameter

2. **Caching**
   - Cache frequently accessed farm plots
   - Cache user preferences locally

3. **Image Optimization**
   - Compress images before upload
   - Use thumbnail previews

4. **Background Sync**
   - Implement background sync every 5 minutes
   - Use WorkManager plugin

## Next Steps

1. ✅ Backend API is fully functional
2. ✅ Flutter models and services are ready
3. ✅ Screens are created but need provider integration
4. ⏳ Add to main navigation menu
5. ⏳ Test with real data
6. ⏳ Implement image upload (optional)
7. ⏳ Add background sync (optional)
8. ⏳ Analytics dashboard (future)

## Support Files
- Full API documentation: [FARM_DIARY_DOCUMENTATION.md](./FARM_DIARY_DOCUMENTATION.md)
- Source files location: Check directory structure above

## Additional Resources
- Flutter Provider Pattern: https://pub.dev/packages/provider
- SharedPreferences: https://pub.dev/packages/shared_preferences
- FlutterSecureStorage: https://pub.dev/packages/flutter_secure_storage
- HTTP package: https://pub.dev/packages/http

## Testing Checklist

- [ ] Backend API running on http://localhost:5000
- [ ] Create test farm plot first
- [ ] Create diary entry via API
- [ ] Retrieve entries via API
- [ ] Update entry via API
- [ ] Delete entry via API
- [ ] Test offline creation (disconnect internet)
- [ ] Test offline sync (reconnect internet)
- [ ] Verify Flutter screens display data
- [ ] Test filter and search functionality
- [ ] Verify sync status indicators
- [ ] Check error handling

## Deployment Checklist

- [ ] Update API base URL for production
- [ ] Enable HTTPS for all API calls
- [ ] Configure secure token storage
- [ ] Set up image upload to Cloudinary
- [ ] Enable database backups
- [ ] Configure rate limiting
- [ ] Set up error logging/monitoring
- [ ] Test on physical device
- [ ] Performance testing complete
- [ ] Security review complete
