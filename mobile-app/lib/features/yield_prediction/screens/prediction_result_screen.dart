import 'package:flutter/material.dart';

class PredictionResultScreen extends StatelessWidget {
  final double predictedYield;
  final double soilMoisture;

  const PredictionResultScreen({
    super.key,
    required this.predictedYield,
    required this.soilMoisture,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prediction Result"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _yieldHero(),
            const SizedBox(height: 24),
            _infoTile(
              Icons.water_drop_rounded,
              "Soil Moisture",
              "${soilMoisture.round()}%",
              Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              "Why this prediction?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "The model detected healthy pepper cones and optimal soil moisture conditions, leading to a higher yield estimate.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _yieldHero() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade400],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text("Predicted Yield",
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            "${predictedYield.round()} kg",
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(
      IconData icon, String title, String value, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(
        value,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
