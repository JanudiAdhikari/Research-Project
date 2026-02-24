import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../features/farm_diary/screens/farm_diary_list_screen.dart';
import '../features/farm_diary/screens/farm_diary_form_screen.dart';
import '../features/farm_diary/screens/farm_diary_detail_screen.dart';
import '../models/farm_diary.dart';

import 'farm_diary_provider.dart';

/// Global provider instance accessor
/// Initialize this in main() before running the app
class AppProviders {
  static late SharedPreferences _prefs;
  static late FlutterSecureStorage _secureStorage;
  static late FarmDiaryProvider _farmDiaryProvider;
  static bool _initialized = false;

  /// Initialize all providers - MUST be called in main() before runApp()
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _secureStorage = const FlutterSecureStorage();
      
      _farmDiaryProvider = FarmDiaryProvider(
        secureStorage: _secureStorage,
        prefs: _prefs,
      );
      
      _initialized = true;
      print('✅ AppProviders initialized successfully');
    } catch (e) {
      print('❌ Error initializing AppProviders: $e');
      rethrow;
    }
  }

  /// Get FarmDiaryProvider instance
  static FarmDiaryProvider get farmDiary {
    if (!_initialized) {
      throw Exception(
        'AppProviders not initialized. Call AppProviders.initialize() in main() first.'
      );
    }
    return _farmDiaryProvider;
  }

  /// Get SharedPreferences instance
  static SharedPreferences get prefs {
    if (!_initialized) {
      throw Exception('AppProviders not initialized');
    }
    return _prefs;
  }

  /// Get FlutterSecureStorage instance
  static FlutterSecureStorage get secureStorage {
    if (!_initialized) {
      throw Exception('AppProviders not initialized');
    }
    return _secureStorage;
  }

  /// Check if providers are initialized
  static bool get isInitialized => _initialized;

  /// Reset all providers (useful for testing or logout)
  static Future<void> reset() async {
    _initialized = false;
    // Don't dispose here - just mark as uninitialized
  }
}

/// Widget wrapper to provide FarmDiaryProvider to child widgets
/// Usage:
/// FarmDiaryProviderWrapper(
///   child: YourScreen(),
/// )
class FarmDiaryProviderWrapper extends StatelessWidget {
  final Widget child;

  const FarmDiaryProviderWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: AppProviders.farmDiary,
      child: child,
    );
  }
}

/// Extension to safely navigate with provider
extension FarmDiaryNavigation on BuildContext {
  /// Navigate to Farm Diary list screen with provider
  void navigateToFarmDiary({required String farmPlotId}) {
    Navigator.push(
      this,
      MaterialPageRoute(
        builder: (context) => FarmDiaryProviderWrapper(
          child: FarmDiaryListScreen(farmPlotId: farmPlotId),
        ),
      ),
    );
  }

  /// Navigate to Farm Diary form screen with provider
  void navigateToFarmDiaryForm({
    String? farmPlotId,
    FarmDiary? entry,
  }) {
    Navigator.push(
      this,
      MaterialPageRoute(
        builder: (context) => FarmDiaryProviderWrapper(
          child: FarmDiaryFormScreen(
            farmPlotId: farmPlotId,
            entry: entry,
          ),
        ),
      ),
    );
  }

  /// Navigate to Farm Diary detail screen with provider
  void navigateToFarmDiaryDetail({required String entryId}) {
    Navigator.push(
      this,
      MaterialPageRoute(
        builder: (context) => FarmDiaryProviderWrapper(
          child: FarmDiaryDetailScreen(entryId: entryId),
        ),
      ),
    );
  }
}

