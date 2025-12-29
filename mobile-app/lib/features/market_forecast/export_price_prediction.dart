import 'package:flutter/material.dart';

class ExportPricePrediction extends StatelessWidget {
  const ExportPricePrediction({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Price Prediction'),
      ),
      body: const Center(
        child: Text(
          'Export price prediction data will be shown here',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
