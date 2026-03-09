import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';
import '../models/prediction_history.dart';

class PredictionHistoryService {
  // History service should use the main backend baseUrl
  static String get _baseUrl => ApiConfig.baseUrl;
  static const String _storageKey = 'prediction_history';

  /// Save a new prediction to local storage and backend
  Future<bool> savePrediction({
    required String timestamp,
    required double predictedYieldKgPerPlant,
    required double confidencePercent,
    required String cropCondition,
    required double soilMoisture,
    required double temperature,
    required List<String> recommendations,
    required double soilMoistureImpact,
    required double temperatureImpact,
  }) async {
    try {
      final prediction = PredictionHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: timestamp,
        predictedYieldKgPerPlant: predictedYieldKgPerPlant,
        confidencePercent: confidencePercent,
        cropCondition: cropCondition,
        soilMoisture: soilMoisture,
        temperature: temperature,
        recommendations: recommendations,
        soilMoistureImpact: soilMoistureImpact,
        temperatureImpact: temperatureImpact,
      );

      // Save to local storage
      await _savePredictionLocal(prediction);

      // Try to save to backend
      await _savePredictionBackend(prediction);

      return true;
    } catch (e) {
      print('[PredictionHistory] Error saving prediction: $e');
      return false;
    }
  }

  /// Save prediction to local storage
  Future<bool> _savePredictionLocal(PredictionHistory prediction) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_storageKey) ?? [];

      history.insert(0, jsonEncode(prediction.toJson()));

      // Keep only last 50 predictions locally
      if (history.length > 50) {
        history.removeRange(50, history.length);
      }

      return await prefs.setStringList(_storageKey, history);
    } catch (e) {
      print('[PredictionHistory] Error saving to local storage: $e');
      return false;
    }
  }

  /// Save prediction to backend
  Future<bool> _savePredictionBackend(PredictionHistory prediction) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/save_prediction'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(prediction.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('[PredictionHistory] Error saving to backend: $e');
      return false;
    }
  }

  /// Get prediction history from local storage
  Future<List<PredictionHistory>> getPredictionHistoryLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_storageKey) ?? [];

      return history
          .map((item) => PredictionHistory.fromJson(jsonDecode(item)))
          .toList();
    } catch (e) {
      print('[PredictionHistory] Error reading local history: $e');
      return [];
    }
  }

  /// Get prediction history from backend
  Future<List<PredictionHistory>> getPredictionHistoryBackend() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/history'))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => PredictionHistory.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('[PredictionHistory] Error fetching from backend: $e');
      return [];
    }
  }

  /// Get combined history (try backend first, fallback to local)
  Future<List<PredictionHistory>> getPredictionHistory() async {
    try {
      // Try to get from backend first
      final backendHistory = await getPredictionHistoryBackend();
      if (backendHistory.isNotEmpty) {
        // Update local storage with backend data
        await _updateLocalHistory(backendHistory);
        return backendHistory;
      }
    } catch (e) {
      print('[PredictionHistory] Backend unavailable, using local data: $e');
    }

    // Fallback to local storage
    return await getPredictionHistoryLocal();
  }

  /// Update local storage with backend data
  Future<void> _updateLocalHistory(List<PredictionHistory> predictions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = predictions.map((p) => jsonEncode(p.toJson())).toList();
      await prefs.setStringList(_storageKey, history);
    } catch (e) {
      print('[PredictionHistory] Error updating local history: $e');
    }
  }

  /// Delete a prediction from history
  Future<bool> deletePrediction(String predictionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_storageKey) ?? [];

      history.removeWhere((item) {
        final prediction = PredictionHistory.fromJson(jsonDecode(item));
        return prediction.id == predictionId;
      });

      return await prefs.setStringList(_storageKey, history);
    } catch (e) {
      print('[PredictionHistory] Error deleting prediction: $e');
      return false;
    }
  }

  /// Clear all history
  Future<bool> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_storageKey);
    } catch (e) {
      print('[PredictionHistory] Error clearing history: $e');
      return false;
    }
  }
}
