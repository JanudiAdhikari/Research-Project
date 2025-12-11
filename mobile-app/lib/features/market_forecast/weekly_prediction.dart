import 'package:CeylonPepper/features/market_forecast/recommendations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Weekly pepper price prediction chart view
class WeeklyPrediction extends StatelessWidget {
  final String? year;
  final String? month;
  final String? week;

  WeeklyPrediction({
    super.key,
    required this.year,
    required this.month,
    required this.week,
  });

  final List<double> blackPepperPriceData = <double>[
    1500,
    1600,
    1750,
    2000,
    1800,
    1950,
    2100,
    2200,
    2300,
    2400,
  ];

  final List<double> whitePepperPriceData = <double>[
    1800,
    1750,
    1900,
    2100,
    2000,
    2200,
    2300,
    2400,
    2500,
    2600,
  ];

  final Color blackPepperColor = Colors.orange;
  final Color whitePepperColor = Colors.blue;

  /// Get the Monday date of a given week number in a month
  DateTime getWeekStartDate(int year, int month, int weekNumber) {
    final firstDay = DateTime(year, month, 1);
    final dayOfWeek = firstDay.weekday; // Monday=1
    final offset = (dayOfWeek == 1) ? 0 : (8 - dayOfWeek);
    final firstMonday = firstDay.add(Duration(days: offset));
    return firstMonday.add(Duration(days: 7 * (weekNumber - 1)));
  }

  /// Generate previous 6 weeks in chronological order (oldest first)
  List<Map<String, int>> generatePreviousWeeks(
    int year,
    int month,
    int weekNumber,
  ) {
    List<Map<String, int>> weeks = [];
    int y = year;
    int m = month;
    int w = weekNumber;

    while (weeks.length < 6) {
      weeks.insert(0, {
        "year": y,
        "month": m,
        "week": w,
      }); // insert at start to keep chronological

      w--; // previous week
      if (w == 0) {
        m--; // previous month
        if (m == 0) {
          m = 12;
          y--;
        }
        // Calculate number of weeks in previous month
        final firstDay = DateTime(y, m, 1);
        final lastDay = DateTime(y, m + 1, 0);
        int totalWeeks =
            ((lastDay.day - (7 - firstDay.weekday + 1)) / 7).ceil() + 1;
        w = totalWeeks;
      }
    }
    return weeks;
  }

  /// Format week labels as "MMM wn"
  List<String> formatWeekLabels(List<Map<String, int>> weeks) {
    final List<String> labels = [];
    final monthNames = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    for (var week in weeks) {
      labels.add("${monthNames[week['month']!]} w${week['week']}");
    }
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    final y = int.tryParse(year ?? '') ?? 2024;
    final m = int.tryParse(month ?? '') ?? 1;
    final w = int.tryParse(week ?? '') ?? 1;

    final previousWeeks = generatePreviousWeeks(y, m, w);
    final weekLabels = formatWeekLabels(previousWeeks);
    final dataLength = previousWeeks.length;

    // Generate dynamic data for each week (need to replace with real data)
    List<double> blackData = [];
    List<double> whiteData = [];
    for (int i = 0; i < dataLength; i++) {
      int priceIndex = i % blackPepperPriceData.length;
      blackData.add(blackPepperPriceData[priceIndex]);
      whiteData.add(whitePepperPriceData[priceIndex]);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 5),
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${month ?? 'Month'} - ${week ?? 'Week'} (${year ?? 'Year'})',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Predicted Price:\nRs.1890 /kg',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Past Price Trend',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 15),
              _buildLegend(),
              const SizedBox(height: 15),

              // Centered and widened chart container
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 260,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: (dataLength - 0.2).toDouble(),
                      minY: 1000,
                      maxY: 2700,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 500,
                        getDrawingHorizontalLine: (value) => FlLine(
                          strokeWidth: 0.5,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 500,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value ~/ 1}',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= weekLabels.length)
                                return const SizedBox.shrink();
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 10,
                                angle: 0.785,
                                child: Text(
                                  weekLabels[value.toInt()],
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          barWidth: 3,
                          color: blackPepperColor,
                          dotData: FlDotData(show: true),
                          spots: List.generate(
                            dataLength,
                            (i) => FlSpot(i.toDouble(), blackData[i]),
                          ),
                        ),
                        LineChartBarData(
                          isCurved: true,
                          barWidth: 3,
                          color: whitePepperColor,
                          dotData: FlDotData(show: true),
                          spots: List.generate(
                            dataLength,
                            (i) => FlSpot(i.toDouble(), whiteData[i]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Recommendations button
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6, // 60% width
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Recommendations',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Recommendations(),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(color: blackPepperColor, label: 'Black Pepper'),
        const SizedBox(width: 20),
        _legendItem(color: whitePepperColor, label: 'White Pepper'),
      ],
    );
  }

  Widget _legendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}

// Extension to safely take last n elements from a list
extension TakeLast<T> on List<T> {
  List<T> takeLast(int n) => skip(length - n).toList();
}
