import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'xai_insights_screen.dart';
import 'prediction_history_screen.dart';
import '../../../utils/yield_prediction/yield_prediction_si.dart';
import '../../../providers/yield_prediction_provider.dart';
import '../../../models/prediction_response.dart';

class PredictionResultScreen extends StatefulWidget {
  final double predictedYieldKgPerPlant;
  final double confidencePercent;
  final String cropCondition;
  final String timestamp;
  final double soilMoisture;
  final double temperature;
  final dynamic imageFile; // XFile or File
  final String language;

  const PredictionResultScreen({
    super.key,
    required this.predictedYieldKgPerPlant,
    required this.confidencePercent,
    required this.cropCondition,
    required this.timestamp,
    required this.soilMoisture,
    required this.temperature,
    required this.imageFile,
    this.language = 'en',
  });

  @override
  State<PredictionResultScreen> createState() => _PredictionResultScreenState();
}

class _PredictionResultScreenState extends State<PredictionResultScreen> {
  @override
  void initState() {
    super.initState();
    // Save prediction to history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final yieldProvider = context.read<YieldPredictionProvider>();
      yieldProvider.savePredictionToHistory(
        soilMoisture: widget.soilMoisture,
        temperature: widget.temperature,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSi = widget.language == 'si';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isSi ? YieldPredictionSi.predictionResult : "Prediction Result",
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildImageWidget(),
          ),

          const SizedBox(height: 24),

          // YIELD HERO WITH CONFIDENCE
          _buildYieldHero(isSi),

          const SizedBox(height: 24),

          // CROP CONDITION
          _infoTile(
            Icons.spa_rounded,
            isSi ? "ගස්වල තත්ත්වය" : "Crop Condition",
            widget.cropCondition,
            Colors.green,
          ),

          // SOIL
          _infoTile(
            Icons.water_drop_rounded,
            isSi ? YieldPredictionSi.soilMoisture : "Soil Moisture",
            "${widget.soilMoisture.round()}%",
            Colors.blue,
          ),

          // TEMPERATURE
          _infoTile(
            Icons.thermostat_rounded,
            isSi ? YieldPredictionSi.temperature : "Temperature",
            "${widget.temperature.round()}°C",
            Colors.orange,
          ),

          const SizedBox(height: 24),

          // TIMESTAMP
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  color: Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isSi ? "ගණනය කිරීමේ කාලය: " : "Prediction made: ",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Expanded(
                  child: Text(
                    widget.timestamp,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // XAI BUTTON
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.psychology_rounded),
              label: Text(
                isSi ? YieldPredictionSi.viewAiInsights : "View AI Insights",
              ),
              onPressed: () {
                final provider = context.read<YieldPredictionProvider>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => XAIInsightsScreen(
                      imageFile: widget.imageFile,
                      soilMoisture: widget.soilMoisture,
                      temperature: widget.temperature,
                      confidencePercent: widget.confidencePercent,
                      recommendations: provider.recommendations,
                      xaiTopFactors: provider.xaiTopFactors,
                      language: widget.language,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // HISTORY BUTTON
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.history_rounded),
              label: Text(
                isSi ? YieldPredictionSi.predictionHistory : "View History",
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PredictionHistoryScreen(language: widget.language),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _buildImageWidget() {
    if (widget.imageFile is XFile) {
      return FutureBuilder<Uint8List>(
        future: (widget.imageFile as XFile).readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            );
          } else if (snapshot.hasError) {
            return Container(
              height: 200,
              color: Colors.grey[200],
              child: const Center(child: Text('Error loading image')),
            );
          }
          return Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    } else {
      // Handle dart:io.File
      return Image.file(
        widget.imageFile,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildYieldHero(bool isSi) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade400],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isSi ? YieldPredictionSi.estimatedYield : "Predicted Yield",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            "${widget.predictedYieldKgPerPlant.toStringAsFixed(2)} ${isSi ? YieldPredictionSi.kilogramPerPlant : "kg/plant"}",
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  "${widget.confidencePercent.toStringAsFixed(1)}% ${isSi ? " আত্মবিশ্বাসী" : "Confidence"}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
