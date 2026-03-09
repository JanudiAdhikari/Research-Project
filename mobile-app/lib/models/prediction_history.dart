class PredictionHistory {
  final String id;
  final String timestamp;
  final double predictedYieldKgPerPlant;
  final double confidencePercent;
  final String cropCondition;
  final double soilMoisture;
  final double temperature;
  final List<String> recommendations;
  final double soilMoistureImpact;
  final double temperatureImpact;

  PredictionHistory({
    required this.id,
    required this.timestamp,
    required this.predictedYieldKgPerPlant,
    required this.confidencePercent,
    required this.cropCondition,
    required this.soilMoisture,
    required this.temperature,
    required this.recommendations,
    required this.soilMoistureImpact,
    required this.temperatureImpact,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp,
      'predicted_yield_kg_per_plant': predictedYieldKgPerPlant,
      'confidence_percent': confidencePercent,
      'crop_condition': cropCondition,
      'soil_moisture': soilMoisture,
      'temperature': temperature,
      'recommendations': recommendations,
      'soil_moisture_impact': soilMoistureImpact,
      'temperature_impact': temperatureImpact,
    };
  }

  // Create from JSON
  factory PredictionHistory.fromJson(Map<String, dynamic> json) {
    return PredictionHistory(
      id: json['id'] ?? '',
      timestamp: json['timestamp'] ?? '',
      predictedYieldKgPerPlant: (json['predicted_yield_kg_per_plant'] ?? 0.0)
          .toDouble(),
      confidencePercent: (json['confidence_percent'] ?? 0.0).toDouble(),
      cropCondition: json['crop_condition'] ?? '',
      soilMoisture: (json['soil_moisture'] ?? 0.0).toDouble(),
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      soilMoistureImpact: (json['soil_moisture_impact'] ?? 0.0).toDouble(),
      temperatureImpact: (json['temperature_impact'] ?? 0.0).toDouble(),
    );
  }

  // Helper method to get formatted date
  String getFormattedDate() {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return 'Today • ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Yesterday • ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return timestamp;
    }
  }
}
