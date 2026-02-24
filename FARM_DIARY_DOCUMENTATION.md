# Smart Farm Diary Feature Documentation

## Overview

The Smart Farm Diary is a comprehensive farming management feature that allows farmers to maintain detailed records of their farming activities, observations, and inputs. It includes full CRUD operations with data synchronization between the Flutter mobile app and MongoDB backend.

## Features

### Core Functionality
- **Create Diary Entries**: Record farming activities with rich details
- **View & Search Entries**: Browse past entries with search and filter capabilities
- **Update Entries**: Edit existing diary entries
- **Delete Entries**: Remove entries when needed
- **Offline Support**: Create and edit entries offline with automatic sync
- **Data Sync**: Seamless synchronization of offline entries to the backend

### Diary Entry Data
Each diary entry captures:
- **Basic Info**: Title, description, activity type, date/time
- **Activity Types**: Watering, Fertilizing, Pest Control, Harvesting, Pruning, Weeding, Inspection, Disease Treatment, Other
- **Weather Data**: Condition, temperature, humidity, rainfall
- **Observations**: Plant health status, disease symptoms, pest presence, yield estimates
- **Inputs Used**: Fertilizer type, pesticide type, water quantity
- **Media**: Support for multiple images
- **Location**: GPS coordinates (latitude, longitude, altitude)
- **Tags & Notes**: Custom tagging and additional notes
- **Sync Status**: Tracking offline/synced status

### Statistics & Analytics
- Total entry count by date range
- Activity type distribution
- Weather statistics (average temperature, humidity, total rainfall)
- Plant health distribution

## Backend API Endpoints

### Base URL
```
/api/farm-diary
```

### Endpoints

#### 1. Get Diary Entries
```
GET /api/farm-diary/entries
Query Parameters:
  - farmPlotId (optional): Filter by farm plot
  - startDate (optional): ISO8601 date string
  - endDate (optional): ISO8601 date string
  - activityType (optional): Filter by activity type

Response: Array of FarmDiary objects
```

#### 2. Get Single Entry
```
GET /api/farm-diary/entries/:id

Response: FarmDiary object
```

#### 3. Create Entry
```
POST /api/farm-diary/entries
Content-Type: application/json

Body:
{
  "farmPlotId": "string",
  "title": "string",
  "description": "string",
  "activityType": "string",
  "diaryDate": "ISO8601 datetime",
  "weather": {
    "condition": "string",
    "temperature": "number",
    "humidity": "number",
    "rainfall": "number"
  },
  "observations": {
    "plantHealth": "string",
    "diseaseSymptoms": "string",
    "pestPresence": "string"
  },
  "actions": "string",
  "inputs": {
    "fertilizer": "string",
    "pesticide": "string",
    "waterQuantity": "number"
  },
  "location": {
    "latitude": "number",
    "longitude": "number",
    "altitude": "number"
  },
  "notes": "string",
  "tags": ["string"],
  "images": []
}

Response: Created FarmDiary object (201)
```

#### 4. Update Entry
```
PUT /api/farm-diary/entries/:id
Content-Type: application/json

Body: Same as Create (partial updates supported)

Response: Updated FarmDiary object
```

#### 5. Delete Entry
```
DELETE /api/farm-diary/entries/:id

Response: { message: "Diary entry deleted successfully" }
```

#### 6. Sync Offline Entries
```
POST /api/farm-diary/sync
Content-Type: application/json

Body:
{
  "entries": [
    {
      ...diary entry data,
      "offlineSyncId": "string"
    }
  ]
}

Response:
{
  "message": "Sync completed",
  "results": [
    {
      "offlineSyncId": "string",
      "_id": "string",
      "status": "created|updated|failed"
    }
  ]
}
```

#### 7. Get Diary Statistics
```
GET /api/farm-diary/stats
Query Parameters:
  - farmPlotId (required)
  - startDate (optional): ISO8601 date string
  - endDate (optional): ISO8601 date string

Response:
{
  "totalEntries": "number",
  "activityStats": [
    {
      "_id": "activityType",
      "count": "number"
    }
  ],
  "avgWeather": {
    "avgTemp": "number",
    "avgHumidity": "number",
    "totalRainfall": "number"
  },
  "plantHealthStats": [
    {
      "_id": "healthStatus",
      "count": "number"
    }
  ]
}
```

## Flutter Implementation

### Models
- **FarmDiary**: Main diary entry model with nested objects
- **Weather**: Weather information
- **Observations**: Plant and pest observations
- **Inputs**: Agricultural inputs used
- **Location**: GPS location data
- **DiaryImage**: Image metadata

### Services
- **FarmDiaryService**: Handles API calls and offline storage
  - Methods: `getDiaryEntries()`, `createDiaryEntry()`, `updateDiaryEntry()`, `deleteDiaryEntry()`, `syncOfflineEntries()`, `getDiaryStats()`
  - Offline storage using SharedPreferences
  - Automatic fallback to offline data on network errors

### Provider (State Management)
- **FarmDiaryProvider**: ChangeNotifier for state management
  - Manages diary entries list
  - Handles loading states and error messages
  - Provides filtering and search functionality
  - Tracks pending offline entries

### Screens
1. **FarmDiaryListScreen**: Display all diary entries with filters and search
2. **FarmDiaryDetailScreen**: View full entry details with options to edit/delete
3. **FarmDiaryFormScreen**: Create/edit diary entries with comprehensive form

### Features
- Real-time search and filtering
- Date range filtering
- Activity type filtering
- Weather condition tracking
- Plant health observations
- Input tracking
- Offline support with sync indicator
- Responsive UI with Material Design

## Database Schema

### MongoDB Document Structure
```javascript
{
  _id: ObjectId,
  ownerUid: String (indexed),
  farmPlotId: ObjectId (referenced, indexed),
  title: String,
  description: String,
  activityType: String (enum),
  diaryDate: Date (indexed),
  weather: {
    condition: String,
    temperature: Number,
    humidity: Number,
    rainfall: Number
  },
  observations: {
    plantHealth: String,
    diseaseSymptoms: String,
    pestPresence: String,
    yieldEstimate: String
  },
  actions: String,
  inputs: {
    fertilizer: String,
    pesticide: String,
    waterQuantity: Number,
    otherInputs: String
  },
  images: [{
    url: String,
    cloudinaryId: String,
    uploadedAt: Date,
    caption: String
  }],
  location: {
    latitude: Number,
    longitude: Number,
    altitude: Number
  },
  notes: String,
  tags: [String],
  syncStatus: String (enum: synced, pending, failed),
  offlineSyncId: String,
  createdAt: Date,
  updatedAt: Date
}
```

### Indexes
- `(ownerUid, diaryDate)`: Fast retrieval of user entries by date
- `(farmPlotId, diaryDate)`: Fast retrieval of plot entries by date
- `ownerUid`: User filtering
- `farmPlotId`: Plot filtering
- `diaryDate`: Date filtering

## Authentication
All endpoints require JWT authentication via `Authorization: Bearer {token}` header.
Token should be obtained from Firebase Authentication or your auth system and stored securely.

## Error Handling
- **400**: Bad Request (missing required fields)
- **401**: Unauthorized (invalid/missing token)
- **403**: Forbidden (accessing other user's data)
- **404**: Not Found (entry doesn't exist)
- **500**: Server Error

## Offline Sync Strategy
1. When creating/updating entries offline:
   - Generate unique `offlineSyncId`
   - Set `syncStatus` to 'pending'
   - Store in local SharedPreferences

2. When connection is restored:
   - Retrieve pending entries
   - Send to `/api/farm-diary/sync` endpoint
   - Update local entries with server-assigned IDs
   - Clear offline storage

3. Manual sync trigger:
   - Cloud icon with badge in app header
   - Badge shows count of pending entries
   - User can manually trigger sync

## Integration Steps

### Backend Setup
1. Ensure MongoDB is connected
2. Verify auth middleware is in place
3. Test all endpoints with Postman/Thunder Client
4. Configure Cloudinary for image uploads

### Flutter Integration
1. Initialize FarmDiaryService in your app
2. Add FarmDiaryProvider to your state management
3. Use screens in navigation
4. Set up offline sync on app startup
5. Configure API base URL in [config/api.dart]

### Usage Example
```dart
// In your navigation or dashboard
FarmDiaryListScreen(farmPlotId: selectedPlotId)

// Or with provider
final provider = FarmDiaryProvider(
  secureStorage: secureStorage,
  prefs: sharedPreferences,
);

await provider.loadDiaryEntries(farmPlotId: farmPlotId);
```

## Best Practices

### Mobile App
- Always call `syncOfflineEntries()` on app startup if connected
- Show sync status to user with visual indicators
- Implement periodic background sync
- Handle network errors gracefully
- Validate form data before submission

### Backend
- Always validate user ownership before returning/modifying entries
- Use transactions for critical operations
- Implement proper pagination for large datasets
- Log all critical operations
- Regular database backups

## Performance Considerations
- Entries are retrieved with `.lean()` for better performance
- Cumulative indices on common query patterns
- Pagination recommended for large datasets (future enhancement)
- Consider implementing caching for frequency-accessed stats

## Future Enhancements
- Image upload to Cloudinary
- Background sync scheduling
- Offline data encryption
- Export diary as PDF/CSV
- Voice recording for notes
- Integration with weather APIs
- Predictive analytics for yield
- Mobile app notifications
- Social sharing of insights
- Multi-language support

## Troubleshooting

### Sync Not Working
- Check network connectivity
- Verify auth token is valid
- Check firestore/database permissions
- Review server logs for errors

### Data Not Saving
- Validate form inputs
- Check local storage permissions
- Verify API endpoint is correct
- Check auth token expiration

### Missing Data
- Clear cache and reload
- Check date range filters
- Verify farm plot ID is correct
- Check sync status of entries

## API Rate Limiting
- 100 requests per minute per user
- Implement exponential backoff for retries
- Cache responses where possible

## Security
- All endpoints require authentication
- User can only access their own data
- Images stored securely on Cloudinary
- Sensitive data validated server-side
- HTTPS/TLS for all communications

## Support
For issues or questions, contact the development team or check the main project README.
