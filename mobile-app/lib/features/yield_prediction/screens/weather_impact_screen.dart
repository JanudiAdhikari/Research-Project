import 'package:flutter/material.dart';
import '../../../utils/yield_prediction/yield_prediction_si.dart';

class WeatherImpactScreen extends StatelessWidget {
  final String language;

  const WeatherImpactScreen({super.key, this.language = 'en'});

  @override
  Widget build(BuildContext context) {
    final isSi = language == 'si';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isSi ? YieldPredictionSi.weatherImpact : "Weather Impact"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(
            icon: Icons.cloud_rounded,
            title: isSi
                ? YieldPredictionSi.weatherInfluenceOnYield
                : "Weather Influence on Yield",
            subtitle: isSi
                ? YieldPredictionSi.howClimateAffectsPepperProduction
                : "How climate affects pepper production",
            color: Colors.orange,
          ),

          const SizedBox(height: 20),

          _infoCard(
  Icons.thermostat_rounded,
  isSi
      ? YieldPredictionSi.temperatureTitle
      : "Temperature",
  isSi
      ? YieldPredictionSi.temperatureDesc
      : "Optimal range: 20°C – 30°C\nHigh temperatures may reduce flowering.",
),

_infoCard(
  Icons.water_drop_rounded,
  isSi
      ? YieldPredictionSi.rainfallTitle
      : "Rainfall",
  isSi
      ? YieldPredictionSi.rainfallDesc
      : "Moderate rainfall supports growth.\nExcess rain may cause root diseases.",
),

_infoCard(
  Icons.wb_sunny_rounded,
  isSi
      ? YieldPredictionSi.sunlightTitle
      : "Sunlight",
  isSi
      ? YieldPredictionSi.sunlightDesc
      : "Adequate sunlight improves photosynthesis and yield.",
),

          const SizedBox(height: 16),

          _tipBox(
  Icons.info_rounded,
  isSi
      ? YieldPredictionSi.weatherSuitableTip
      : "Current weather conditions are suitable for pepper cultivation.",
  Colors.green,
),
        ],
      ),
    );
  }
}

Widget _header({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _infoCard(IconData icon, String title, String desc) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    child: ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(desc),
    ),
  );
}

Widget _stepCard(IconData icon, String title, String desc) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    child: ListTile(
      leading: Icon(icon, color: Colors.purple),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(desc),
    ),
  );
}

Widget _tipBox(IconData icon, String text, Color color) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
