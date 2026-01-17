import 'package:flutter/material.dart';

class MyFarmScreen extends StatelessWidget {
  const MyFarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Farm")),
      body: const Center(
        child: Text(
          "My Farm Page",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
