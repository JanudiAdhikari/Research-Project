class PredictionResponse {
  final String timestamp;
  final double predictedYieldKgPerPlant;
  final double confidencePercent;
  final String cropCondition;
  final List<String> recommendations;
  final TopFactors xaiTopFactors;

  PredictionResponse({
    required this.timestamp,
    required this.predictedYieldKgPerPlant,
    required this.confidencePercent,
    required this.cropCondition,
    required this.recommendations,
    required this.xaiTopFactors,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      timestamp: json['timestamp'] ?? '',
      predictedYieldKgPerPlant: (json['predicted_yield_kg_per_plant'] ?? 0.0)
          .toDouble(),
      confidencePercent: (json['confidence_percent'] ?? 0.0).toDouble(),
      cropCondition: json['crop_condition'] ?? '',
      recommendations: List<String>.from(json['recommendations'] ?? []),
      xaiTopFactors: TopFactors.fromJson(json['xai_top_factors'] ?? {}),
    );
  }
}

class TopFactors {
  final double soilMoistureImpact;
  final double temperatureImpact;

  TopFactors({
    required this.soilMoistureImpact,
    required this.temperatureImpact,
  });

  factory TopFactors.fromJson(Map<String, dynamic> json) {
    return TopFactors(
      soilMoistureImpact: (json['soil_moisture_impact'] ?? 0.0).toDouble(),
      temperatureImpact: (json['temperature_impact'] ?? 0.0).toDouble(),
    );
  }
}
