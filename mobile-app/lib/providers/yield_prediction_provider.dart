import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/yield_prediction_service.dart';
import '../services/prediction_history_service.dart';
import '../models/prediction_response.dart';
import 'package:flutter/material.dart';

class YieldPredictionProvider extends ChangeNotifier {
  final YieldPredictionService _service = YieldPredictionService();
  final PredictionHistoryService _historyService = PredictionHistoryService();

  double _predictedYieldKgPerPlant = 0;
  double _confidencePercent = 0;
  String _cropCondition = '';
  String _timestamp = '';
  List<String> _recommendations = [];
  TopFactors? _xaiTopFactors;
  bool _isLoading = false;
  String? _error;
  bool _apiAvailable = false;

  // Getters
  double get predictedYieldKgPerPlant => _predictedYieldKgPerPlant;
  double get confidencePercent => _confidencePercent;
  String get cropCondition => _cropCondition;
  String get timestamp => _timestamp;
  List<String> get recommendations => _recommendations;
  TopFactors? get xaiTopFactors => _xaiTopFactors;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get apiAvailable => _apiAvailable;

  /// Check if the prediction API is available
  Future<void> checkApiAvailability() async {
    _apiAvailable = await _service.healthCheck();
    notifyListeners();
  }

  /// Perform yield prediction
  Future<bool> performPrediction({
    required List<dynamic> imageFiles,
    required double soilMoisture,
    required double temperature,
    double? rainfall,
    String? plantAge,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.predictYield(
        imageFiles: imageFiles,
        soilMoisture: soilMoisture,
        temperature: temperature,
        rainfall: rainfall,
        plantAge: plantAge,
      );

      _predictedYieldKgPerPlant = response.predictedYieldKgPerPlant;
      _confidencePercent = response.confidencePercent;
      _cropCondition = response.cropCondition;
      _timestamp = response.timestamp;
      _recommendations = response.recommendations;
      _xaiTopFactors = response.xaiTopFactors;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Save current prediction to history
  Future<bool> savePredictionToHistory({
    required double soilMoisture,
    required double temperature,
  }) async {
    try {
      return await _historyService.savePrediction(
        timestamp: _timestamp,
        predictedYieldKgPerPlant: _predictedYieldKgPerPlant,
        confidencePercent: _confidencePercent,
        cropCondition: _cropCondition,
        soilMoisture: soilMoisture,
        temperature: temperature,
        recommendations: _recommendations,
        soilMoistureImpact: _xaiTopFactors?.soilMoistureImpact ?? 0.0,
        temperatureImpact: _xaiTopFactors?.temperatureImpact ?? 0.0,
      );
    } catch (e) {
      print('Error saving prediction to history: $e');
      return false;
    }
  }

  /// Clear error messages
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset prediction data
  void resetPrediction() {
    _predictedYieldKgPerPlant = 0;
    _confidencePercent = 0;
    _cropCondition = '';
    _timestamp = '';
    _recommendations = [];
    _xaiTopFactors = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
