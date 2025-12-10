import 'package:flutter/material.dart';

class Recommendations extends StatelessWidget {
  const Recommendations({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recommendations"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Recommendations",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "Here you can display price predictions, suggestions, or any relevant recommendations for farmers based on the selected week and pepper type.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            // Add more widgets like lists, cards, etc.
          ],
        ),
      ),
    );
  }
}
