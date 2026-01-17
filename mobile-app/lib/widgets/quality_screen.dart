import 'package:flutter/material.dart';

class QualityScreen extends StatelessWidget {
  const QualityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quality")),
      body: const Center(
        child: Text(
          "Quality Page",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
