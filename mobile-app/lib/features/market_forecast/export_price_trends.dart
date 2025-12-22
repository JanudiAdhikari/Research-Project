import 'package:flutter/material.dart';

class ExportPriceTrends extends StatefulWidget {
  const ExportPriceTrends({Key? key}) : super(key: key);

  @override
  State<ExportPriceTrends> createState() => _ExportPriceTrendsState();
}

class _ExportPriceTrendsState extends State<ExportPriceTrends> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Export Price Trends")),
      body: const Center(child: Text("Hello")),
    );
  }
}
