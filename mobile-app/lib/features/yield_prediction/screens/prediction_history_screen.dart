import 'package:flutter/material.dart';

class PredictionHistoryScreen extends StatelessWidget {
  const PredictionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prediction History")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.analytics_rounded),
              title: const Text("Predicted Yield: 820 kg"),
              subtitle: const Text("Soil Moisture: 42% • 12 Jan 2025"),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ),
          );
        },
      ),
    );
  }
}

