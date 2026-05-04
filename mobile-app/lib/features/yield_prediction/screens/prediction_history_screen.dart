import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/yield_prediction/yield_prediction_si.dart';
import '../../../providers/prediction_history_provider.dart';

class PredictionHistoryScreen extends StatefulWidget {
  final String language;

  const PredictionHistoryScreen({super.key, this.language = 'en'});

  @override
  State<PredictionHistoryScreen> createState() =>
      _PredictionHistoryScreenState();
}

class _PredictionHistoryScreenState extends State<PredictionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load history when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PredictionHistoryProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSi = widget.language == 'si';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isSi
              ? YieldPredictionSi.predictionHistory
              : "Prediction History",
        ),
        actions: [
          Consumer<PredictionHistoryProvider>(
            builder: (context, provider, _) {
              return provider.isEmpty
                  ? SizedBox.shrink()
                  : PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Row(
                            children: [
                              const Icon(Icons.refresh_rounded,
                                  color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(isSi ? "නැවුම් කරන්න" : "Refresh"),
                            ],
                          ),
                          onTap: () {
                            provider.refreshHistory();
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline_rounded,
                                  color: Colors.red),
                              const SizedBox(width: 8),
                              Text(isSi
                                  ? "සම්පුර්ණයෙන් පරිපූර්ණ කරන්න"
                                  : "Clear All"),
                            ],
                          ),
                          onTap: () {
                            _showClearConfirmation(context, provider, isSi);
                          },
                        ),
                      ],
                    );
            },
          ),
        ],
      ),
      body: Consumer<PredictionHistoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isSi
                        ? "ඉතිහාසයක් වගේ සිටුවා ඇත"
                        : "No predictions yet",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSi
                        ? "ඔබන්ගේ පළමු අනුමාන ගිණුම් ක්‍රমයෙන් පෙනී ඇත"
                        : "Your predictions will appear here",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshHistory(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.predictions.length,
              itemBuilder: (context, index) {
                final prediction = provider.predictions[index];
                return _predictionCard(context, prediction, isSi, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _predictionCard(
    BuildContext context,
    dynamic prediction,
    bool isSi,
    PredictionHistoryProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with yield and confidence
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.trending_up_rounded,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${prediction.predictedYieldKgPerPlant.toStringAsFixed(2)} kg/plant",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prediction.getFormattedDate(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Confidence badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${prediction.confidencePercent.toStringAsFixed(1)}%",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              // Crop condition
              Row(
                children: [
                  const Icon(Icons.spa_rounded,
                      color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      prediction.cropCondition,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Environmental conditions
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.water_drop_rounded,
                            color: Colors.blue, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "${prediction.soilMoisture.round()}%",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.thermostat_rounded,
                            color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "${prediction.temperature.round()}°C",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Delete button
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.red, size: 20),
                  onPressed: () {
                    _showDeleteConfirmation(
                        context, prediction.id, provider, isSi);
                  },
                  constraints:
                      const BoxConstraints(minWidth: 40, minHeight: 40),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String predictionId,
    PredictionHistoryProvider provider,
    bool isSi,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isSi ? "එම මතුවුමින් ඉවත්කරන්න?" : "Delete Prediction?"),
        content: Text(
          isSi
              ? "ඔබ මේ අනුමාන ඉවත්කරා ඇත"
              : "This prediction will be permanently deleted.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isSi ? "අවලංගු" : "Cancel"),
          ),
          TextButton(
            onPressed: () {
              provider.deletePrediction(predictionId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isSi ? "ඉවත් කරනලද" : "Prediction deleted",
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              isSi ? "ඉවත්කරන්න" : "Delete",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(
    BuildContext context,
    PredictionHistoryProvider provider,
    bool isSi,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isSi
              ? "සම්පුර්ණයෙන් පරිපූර්ණ අතීතය?"
              : "Clear All History?",
        ),
        content: Text(
          isSi
              ? "සෙම්සල අනුමාන ඉවත් කරනු ලබයි"
              : "All predictions will be permanently deleted.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isSi ? "අවලංගු" : "Cancel"),
          ),
          TextButton(
            onPressed: () {
              provider.clearAllHistory();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isSi ? "ඉතිහාසය පවිතුරු කරන ලද" : "History cleared",
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              isSi ? "පැහැදිලි" : "Clear",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
