import 'package:flutter/material.dart';
import '../screens/prediction_result_screen.dart';

class NewPredictionScreen extends StatefulWidget {
  const NewPredictionScreen({super.key});

  @override
  State<NewPredictionScreen> createState() => _NewPredictionScreenState();
}

class _NewPredictionScreenState extends State<NewPredictionScreen> {
  final _formKey = GlobalKey<FormState>();

  double soilMoisture = 40;
  double rainfall = 20;
  String plantAge = "6–8 months";
  bool useIoT = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("New Harvest Prediction"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _stepHeader(
              icon: Icons.eco_rounded,
              title: "Step 1: Plant Information",
              subtitle: "Basic crop maturity details",
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _dropdownField(),

            const SizedBox(height: 24),

            _stepHeader(
              icon: Icons.sensors_rounded,
              title: "Step 2: Soil Conditions",
              subtitle: "Critical for yield estimation",
              color: Colors.blue,
            ),

            const SizedBox(height: 8),

            _iotToggle(),

            const SizedBox(height: 12),

            _sliderField(
              label: "Soil Moisture (%)",
              value: soilMoisture,
              max: 100,
              onChanged: (v) => setState(() => soilMoisture = v),
            ),
            _infoText(
              "Optimal soil moisture improves nutrient absorption and yield accuracy.",
            ),

            const SizedBox(height: 24),

            _stepHeader(
              icon: Icons.cloud_rounded,
              title: "Step 3: Weather Factors",
              subtitle: "Environmental influence",
              color: Colors.orange,
            ),

            const SizedBox(height: 12),

            _sliderField(
              label: "Expected Rainfall (mm)",
              value: rainfall,
              max: 100,
              onChanged: (v) => setState(() => rainfall = v),
            ),
            _infoText(
              "Rainfall affects flowering, fruit set, and disease risk.",
            ),

            const SizedBox(height: 28),

            _confidencePreview(),

            const SizedBox(height: 20),

            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.analytics_rounded),
                label: const Text(
                  "Predict Yield",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PredictionResultScreen(
                        predictedYield: 850,
                        soilMoisture: soilMoisture,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _stepHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownField() {
    return DropdownButtonFormField<String>(
      value: plantAge,
      items: const [
        DropdownMenuItem(value: "3–5 months", child: Text("3–5 months")),
        DropdownMenuItem(value: "6–8 months", child: Text("6–8 months")),
        DropdownMenuItem(value: "9+ months", child: Text("9+ months")),
      ],
      onChanged: (v) => setState(() => plantAge = v!),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        labelText: "Plant Age",
        helperText: "Older plants usually produce higher yields",
      ),
    );
  }

  Widget _iotToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Use IoT Sensor Data",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        Switch(
          value: useIoT,
          activeColor: Colors.green,
          onChanged: (v) => setState(() => useIoT = v),
        ),
      ],
    );
  }

  Widget _sliderField({
    required String label,
    required double value,
    required double max,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label : ${value.round()}",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Slider(
          value: value,
          max: max,
          divisions: max.toInt(),
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _infoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  Widget _confidencePreview() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: const [
          Icon(Icons.insights_rounded, color: Colors.green),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Based on provided inputs, prediction confidence is expected to be high.",
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
