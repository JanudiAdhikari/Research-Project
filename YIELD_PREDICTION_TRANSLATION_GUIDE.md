# Yield Prediction Sinhala Translation Implementation Guide

## ✅ Completed Steps

1. **Created Translation File**: `lib/utils/yield_prediction/yield_prediction_si.dart`
   - Contains all Sinhala translations for yield prediction screens
   - Follows the same pattern as `market_forecast` translations

2. **Updated Key Screens with Language Support**:
   - ✅ `NewPredictionScreen` - Accepts `language` parameter
   - ✅ `PredictionResultScreen` - Accepts `language` parameter
   - ✅ `PredictionHistoryScreen` - Accepts `language` parameter
   - ✅ `HarvestPredictionDashboard` - Accepts `language` parameter and passes to child screens

## 📝 Remaining Steps (Quick Updates)

### 1. Update Other Yield Prediction Screens
The following screens need to be updated similarly to accept a `language` parameter:

- `WeatherImpactScreen`
- `YieldTipsScreen`
- `HowPredictionWorksScreen`
- `ImageCaptureGuideScreen`
- `IotSensorSetupScreen`
- `XaiInsightsScreen`

**Pattern to follow** (for each screen):

```dart
import '../../../utils/yield_prediction/yield_prediction_si.dart';

class YourScreen extends StatelessWidget {
  final String language;  // ADD THIS
  
  const YourScreen({super.key, this.language = 'en'});  // ADD THIS
  
  @override
  Widget build(BuildContext context) {
    final isSi = language == 'si';  // ADD THIS
    
    // Then use: isSi ? YieldPredictionSi.translationKey : "English text"
  }
}
```

### 2. Pass Language Parameter from Main Dashboard
When navigating to other screens, pass the language:

```dart
// Example for WeatherImpactScreen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => WeatherImpactScreen(language: widget.language),
  ),
);
```

### 3. Set Default Language at App Entry Point
In your main dashboard module or entry point, set the language based on user preferences:

```dart
// Example usage in your dashboard
final userLanguage = await getLanguagePreference(); // 'en' or 'si'
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => HarvestPredictionDashboard(language: userLanguage),
  ),
);
```

## 🔄 How Language Selection Works

1. **User selects Sinhala language icon** → Your app sets language to `'si'`
2. **Language is passed through navigation** → Each screen receives the language parameter
3. **Screens display translations** → Based on `isSi` boolean check
   ```dart
   final isSi = language == 'si';
   Text(isSi ? YieldPredictionSi.keyName : 'English Text')
   ```

## 📦 Translation File Structure

The translation file uses a simple approach similar to market forecast:

```dart
class YieldPredictionSi {
  static const String harvestPrediction = 'අස්වැන්න අනුමාන කිරීම';
  static const String newHarvestPrediction = 'නව අස්වැන්න අනුමාන';
  // ... more translations
}
```

## 🎯 Example - Complete Screen Update

Here's a complete example for `WeatherImpactScreen`:

```dart
import 'package:flutter/material.dart';
import '../../../utils/yield_prediction/yield_prediction_si.dart';

class WeatherImpactScreen extends StatelessWidget {
  final String language;

  const WeatherImpactScreen({super.key, this.language = 'en'});

  @override
  Widget build(BuildContext context) {
    final isSi = language == 'si';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isSi ? YieldPredictionSi.weatherImpact : 'Weather Impact'
        ),
      ),
      body: ListView(
        // ... rest of your code using isSi for translations
      ),
    );
  }
}
```

## 🚀 Quick Checklist

- [ ] Update `WeatherImpactScreen` with language support
- [ ] Update `YieldTipsScreen` with language support
- [ ] Update `HowPredictionWorksScreen` with language support
- [ ] Update `ImageCaptureGuideScreen` with language support
- [ ] Update `IotSensorSetupScreen` with language support
- [ ] Update `XaiInsightsScreen` with language support
- [ ] Pass language parameter in all Navigator.push calls
- [ ] Test Sinhala translation in app

## 💡 Tips

- All translations are already in `YieldPredictionSi` class
- Use the same pattern as `EmptyReportsView` in market forecast
- Default language is always English (`'en'`)
- Sinhala is enabled when language is `'si'`

