import 'package:flutter/material.dart';
import '../../../utils/yield_prediction/yield_prediction_si.dart';

class IotSensorSetupScreen extends StatelessWidget {
  final String language;

  const IotSensorSetupScreen({super.key, this.language = 'en'});

  @override
  Widget build(BuildContext context) {
    final isSi = language == 'si';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          isSi ? YieldPredictionSi.iotSensorSetup : "IoT Sensor Setup",
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(
            icon: Icons.sensors_rounded,
            title: isSi
                ? YieldPredictionSi.soilMoistureSensor
                : "Soil Moisture Sensor",
            subtitle: isSi
                ? YieldPredictionSi.connectAndCollectSoilData
                : "Connect and collect accurate soil data",
            color: Colors.deepPurple,
          ),

          const SizedBox(height: 20),

          _stepCard(
            isSi ? YieldPredictionSi.insertSensor : "Insert Sensor",
            isSi
                ? YieldPredictionSi.placeTheSensor
                : "Place the sensor near the plant root zone.",
            Icons.grass_rounded,
          ),
          _stepCard(
            isSi ? YieldPredictionSi.powerDevice : "Power Device",
            isSi ? YieldPredictionSi.turnOnEsp32 : "Turn on the ESP32 device.",
            Icons.power_settings_new_rounded,
          ),
          _stepCard(
            isSi ? YieldPredictionSi.waitForStability : "Wait for Stability",
            isSi
                ? YieldPredictionSi.allowReadingsToStabilize
                : "Allow readings to stabilize before submitting.",
            Icons.hourglass_bottom_rounded,
          ),
          _stepCard(
            isSi ? YieldPredictionSi.sendData : "Send Data",
            isSi
                ? YieldPredictionSi.transmitSoilMoistureValue
                : "Transmit soil moisture value to the mobile app.",
            Icons.send_rounded,
          ),

          const SizedBox(height: 16),

          _infoBox(
            Icons.check_circle_rounded,
            isSi
                ? YieldPredictionSi.soilMoistureInfluencesYield
                : "Soil moisture directly influences yield prediction.",
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

Widget _stepCard(String title, String desc, IconData icon) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    child: ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(desc),
    ),
  );
}

Widget _infoBox(IconData icon, String text, Color color) {
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
