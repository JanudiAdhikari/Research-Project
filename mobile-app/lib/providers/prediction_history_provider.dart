import 'package:flutter/material.dart';
import '../models/prediction_history.dart';
import '../services/prediction_history_service.dart';

class PredictionHistoryProvider extends ChangeNotifier {
  final PredictionHistoryService _service = PredictionHistoryService();

  List<PredictionHistory> _predictions = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<PredictionHistory> get predictions => _predictions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _predictions.isEmpty;

  /// Load prediction history
  Future<void> loadHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _predictions = await _service.getPredictionHistory();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save a new prediction to history
  Future<bool> addPrediction({
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
      final success = await _service.savePrediction(
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

      if (success) {
        // Reload history to get the new prediction
        await loadHistory();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete a prediction
  Future<bool> deletePrediction(String predictionId) async {
    try {
      final success = await _service.deletePrediction(predictionId);
      if (success) {
        _predictions.removeWhere((p) => p.id == predictionId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Clear all history
  Future<bool> clearAllHistory() async {
    try {
      final success = await _service.clearHistory();
      if (success) {
        _predictions = [];
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Refresh history
  Future<void> refreshHistory() async {
    await loadHistory();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
