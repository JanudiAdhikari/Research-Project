import 'package:flutter/material.dart';
import '../../../utils/yield_prediction/yield_prediction_si.dart';

class YieldTipsScreen extends StatelessWidget {
  final String language;

  const YieldTipsScreen({super.key, this.language = 'en'});

  @override
  Widget build(BuildContext context) {
    final isSi = language == 'si';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isSi ? YieldPredictionSi.yieldTips : "Yield Tips"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(
            icon: Icons.lightbulb_outline_rounded,
            title: isSi
                ? YieldPredictionSi.improvePepperYield
                : "Improve Pepper Yield",
            subtitle: isSi
                ? YieldPredictionSi.practicalTipsForBetterHarvest
                : "Practical tips for better harvest",
            color: Colors.purple,
          ),

          const SizedBox(height: 20),

          _stepCard(
  Icons.water_rounded,
  isSi
      ? YieldPredictionSi.maintainProperIrrigation
      : "Maintain Proper Irrigation",
  isSi
      ? YieldPredictionSi.avoidWaterStress
      : "Avoid both water stress and waterlogging.",
),

_stepCard(
  Icons.grass_rounded,
  isSi
      ? YieldPredictionSi.healthySoil
      : "Healthy Soil",
  isSi
      ? YieldPredictionSi.ensureGoodDrainage
      : "Ensure good drainage and organic matter content.",
),

_stepCard(
  Icons.science_rounded,
  isSi
      ? YieldPredictionSi.balancedFertilization
      : "Balanced Fertilization",
  isSi
      ? YieldPredictionSi.applyNutrientsBasedOnSoil
      : "Apply nutrients based on soil condition.",
),

_stepCard(
  Icons.visibility_rounded,
  isSi
      ? YieldPredictionSi.regularMonitoring
      : "Regular Monitoring",
  isSi
      ? YieldPredictionSi.monitorPestsAndDiseases
      : "Monitor pests, diseases, and plant health.",
),

          const SizedBox(height: 16),

          _tipBox(
  Icons.check_circle_rounded,
  isSi
      ? YieldPredictionSi.monitoringImprovesAccuracy
      : "Consistent monitoring improves yield prediction accuracy.",
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
