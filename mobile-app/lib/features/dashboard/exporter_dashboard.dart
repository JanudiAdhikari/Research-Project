import 'package:flutter/material.dart';

class ExporterDashboard extends StatelessWidget {
  const ExporterDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exporter Dashboard"),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text(
          "Welcome Exporter",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
