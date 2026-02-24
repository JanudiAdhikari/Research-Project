import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/farm_diary.dart';
import '../services/farm_diary_service.dart';

class FarmDiaryProvider extends ChangeNotifier {
  late FarmDiaryService _service;
  List<FarmDiary> _diaryEntries = [];
  FarmDiary? _selectedEntry;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _stats = {};

  // Getters
  List<FarmDiary> get diaryEntries => _diaryEntries;
  FarmDiary? get selectedEntry => _selectedEntry;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get stats => _stats;
  bool get hasPendingEntries => _service.hasPendingEntries();
  int get pendingEntriesCount => _service.getPendingEntriesCount();

  FarmDiaryProvider({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
  }) {
    _service = FarmDiaryService(secureStorage: secureStorage, prefs: prefs);
  }

  // Load diary entries
  Future<void> loadDiaryEntries({
    String? farmPlotId,
    DateTime? startDate,
    DateTime? endDate,
    String? activityType,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _diaryEntries = await _service.getDiaryEntries(
        farmPlotId: farmPlotId,
        startDate: startDate,
        endDate: endDate,
        activityType: activityType,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load single entry
  Future<void> loadDiaryEntry(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedEntry = await _service.getDiaryEntry(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create entry
  Future<FarmDiary?> createDiaryEntry(FarmDiary entry) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final savedEntry = await _service.createDiaryEntry(entry);
      if (savedEntry != null) {
        _diaryEntries.insert(0, savedEntry);
        _error = null;
      }
      notifyListeners();
      return savedEntry;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
    }
  }

  // Update entry
  Future<FarmDiary?> updateDiaryEntry(String id, FarmDiary entry) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedEntry = await _service.updateDiaryEntry(id, entry);
      if (updatedEntry != null) {
        final index = _diaryEntries.indexWhere((e) => e.id == id);
        if (index != -1) {
          _diaryEntries[index] = updatedEntry;
        }
        _selectedEntry = updatedEntry;
        _error = null;
      }
      notifyListeners();
      return updatedEntry;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
    }
  }

  // Delete entry
  Future<bool> deleteDiaryEntry(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.deleteDiaryEntry(id);
      if (success) {
        _diaryEntries.removeWhere((e) => e.id == id);
        if (_selectedEntry?.id == id) {
          _selectedEntry = null;
        }
        _error = null;
      }
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Load stats
  Future<void> loadDiaryStats({
    required String farmPlotId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await _service.getDiaryStats(
        farmPlotId: farmPlotId,
        startDate: startDate,
        endDate: endDate,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sync offline entries
  Future<bool> syncOfflineEntries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _service.syncOfflineEntries();
      if (success) {
        _error = null;
      } else {
        _error = 'Sync failed';
      }
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Clear selected entry
  void clearSelectedEntry() {
    _selectedEntry = null;
    _error = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Filter entries by date range
  List<FarmDiary> filterByDateRange(DateTime start, DateTime end) {
    return _diaryEntries
        .where(
          (entry) =>
              entry.diaryDate.isAfter(start) && entry.diaryDate.isBefore(end),
        )
        .toList();
  }

  // Filter entries by activity type
  List<FarmDiary> filterByActivityType(String activityType) {
    return _diaryEntries
        .where((entry) => entry.activityType == activityType)
        .toList();
  }

  // Search entries
  List<FarmDiary> searchEntries(String query) {
    final lowerQuery = query.toLowerCase();
    return _diaryEntries
        .where(
          (entry) =>
              entry.title.toLowerCase().contains(lowerQuery) ||
              entry.description.toLowerCase().contains(lowerQuery) ||
              entry.notes.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }
}
