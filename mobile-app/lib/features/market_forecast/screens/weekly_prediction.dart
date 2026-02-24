import 'package:CeylonPepper/features/market_forecast/screens/recommendations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../utils/responsive.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class PricePredictionService {
  final String apiUrl;
  PricePredictionService({required this.apiUrl});
  Future<double> fetchPredictedPrice({
    required String district,
    required String pepperType,
    required String grade,
    required int year,
    required int month,
    required int week, // ISO week number
  }) async {
    // Map grade values to API expected format
    String mappedGrade = grade;
    if (grade == 'Grade 1')
      mappedGrade = 'GR1';
    else if (grade == 'Grade 2')
      mappedGrade = 'GR2';

    // Construct the request body
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'district': district,
        'pepper_type': pepperType,
        'grade': mappedGrade,
        'year': year,
        'month': month,
        'week': week,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final price = data['predicted_price_LKR_per_kg'];
      if (price == null) {
        throw Exception(
          'Predicted price not found in response. Full response: ${response.body}',
        );
      }
      return (price is num)
          ? price.toDouble()
          : double.tryParse(price.toString()) ?? 0.0;
    } else {
      throw Exception(
        'Failed to fetch predicted price. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }
}

// Screen to display the predicted price
class WeeklyPrediction extends StatefulWidget {
  final String year;
  final String month;
  final String week;
  final String district;
  final String pepperType;
  final String grade;
  final int weekNumber;

  const WeeklyPrediction({
    Key? key,
    required this.year,
    required this.month,
    required this.week,
    required this.district,
    required this.pepperType,
    required this.grade,
    required this.weekNumber,
  }) : super(key: key);

  @override
  State<WeeklyPrediction> createState() => _WeeklyPredictionState();
}

class _WeeklyPredictionState extends State<WeeklyPrediction> {
  double? predictedPrice;
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    fetchPrediction();
  }

  Future<void> fetchPrediction() async {
    final service = PricePredictionService(
      apiUrl:
          'http://10.0.2.2:8000/predictlocalprice', // Using 10.0.2.2 for Android emulator
    );
    try {
      final price = await service.fetchPredictedPrice(
        district: widget.district,
        pepperType: widget.pepperType,
        grade: widget.grade,
        year: int.tryParse(widget.year) ?? 2025,
        month: int.tryParse(widget.month) ?? 1,
        week: widget.weekNumber,
      );
      setState(() {
        predictedPrice = price;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Forecast Analysis'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg != null
          ? Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Error: $errorMsg',
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Week label
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        '${widget.week}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF388E3C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Predicted price card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 28,
                        horizontal: 18,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFF81C784),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Predicted Price',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      'Rs. ${predictedPrice!.toStringAsFixed(0)} ',
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                TextSpan(
                                  text: '/kg',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Estimated average for the week',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Selected details (district, pepper type, grade)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.06),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // District row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Color(0xFF388E3C),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'District',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.district,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Divider(height: 1, color: Colors.grey.shade200),
                          const SizedBox(height: 10),

                          // Pepper type row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.local_florist,
                                  color: Colors.brown.shade700,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pepper Type',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.pepperType,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Divider(height: 1, color: Colors.grey.shade200),
                          const SizedBox(height: 10),

                          // Grade row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8E1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.grade,
                                  color: Colors.amber.shade700,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Grade',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.grade,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
