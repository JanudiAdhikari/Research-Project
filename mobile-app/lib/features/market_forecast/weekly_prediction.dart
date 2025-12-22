import 'package:CeylonPepper/features/market_forecast/recommendations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

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

  // Generate previous N weeks from selected year/month/week
  List<Map<String, dynamic>> generatePreviousWeeks(
    int year,
    int month,
    int weekNumber,
    int count,
  ) {
    List<Map<String, dynamic>> weeks = [];

    // First day of selected month
    DateTime firstDayOfMonth = DateTime(year, month, 1);

    // Calculate start date of the selected week
    int dayOfWeek = firstDayOfMonth.weekday; // Monday = 1
    int offset = (dayOfWeek == 1) ? 0 : (8 - dayOfWeek);
    DateTime firstMonday = firstDayOfMonth.add(Duration(days: offset));
    DateTime selectedWeekStart = firstMonday.add(
      Duration(days: (weekNumber - 1) * 7),
    );

    for (int i = count - 1; i >= 0; i--) {
      DateTime weekStart = selectedWeekStart.subtract(Duration(days: i * 7));
      int wYear = weekStart.year;
      int wMonth = weekStart.month;

      // Calculate week number in month
      DateTime firstOfMonth = DateTime(wYear, wMonth, 1);
      int firstWeekday = firstOfMonth.weekday;
      int firstMondayOffset = (firstWeekday == 1) ? 0 : (8 - firstWeekday);
      DateTime monthFirstMonday = firstOfMonth.add(
        Duration(days: firstMondayOffset),
      );

      int weekInMonth =
          ((weekStart.difference(monthFirstMonday).inDays) / 7).floor() + 1;
      if (weekStart.isBefore(monthFirstMonday)) weekInMonth = 1;

      weeks.add({
        'year': wYear,
        'month': wMonth,
        'week': weekInMonth,
        'startDate': weekStart,
      });
    }

    return weeks;
  }

  // Format labels like "Jan w2"
  List<String> formatWeekLabelsFromMap(List<Map<String, dynamic>> weeks) {
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
    return weeks.map((w) {
      return "${monthNames[w['month']!]} w${w['week']!}";
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final y = int.tryParse(year ?? '') ?? 2025;
    final m = int.tryParse(month ?? '') ?? 1;
    final w = int.tryParse(week ?? '') ?? 1;

    final previousWeeks = generatePreviousWeeks(y, m, w, 6);
    final weekLabels = formatWeekLabelsFromMap(previousWeeks);
    final dataLength = previousWeeks.length;

    // Assign prices for each week
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
          padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: responsive.smallIconSize,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                ],
              ),
              SizedBox(height: responsive.smallSpacing),
              Center(
                child: Column(
                  children: [
                    ResponsiveText(
                      'Overview',
                      mobileFontSize: responsive.headingFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: responsive.smallSpacing),
                    ResponsiveText(
                      '${month ?? 'Month'} - ${week ?? 'Week'} (${year ?? 'Year'})',
                      mobileFontSize: responsive.bodyFontSize,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              SizedBox(height: responsive.largeSpacing),
              Center(
                child: Container(
                  padding: EdgeInsets.all(responsive.mediumSpacing),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      responsive.largeSpacing / 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ResponsiveText(
                    'Predicted Price:\nRs.1890 /kg',
                    mobileFontSize: responsive.titleFontSize,
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: responsive.largeSpacing),
              ResponsiveText(
                'Past Price Trend',
                mobileFontSize: responsive.titleFontSize,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: responsive.mediumSpacing),
              _buildLegend(responsive),
              SizedBox(height: responsive.mediumSpacing),
              Center(
                child: Container(
                  width: responsive.maxContentWidth,
                  height: 260,
                  padding: EdgeInsets.all(responsive.smallSpacing),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      responsive.largeSpacing / 2,
                    ),
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
                                style: TextStyle(
                                  fontSize: responsive.smallFontSize,
                                ),
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
                                  style: TextStyle(
                                    fontSize: responsive.smallFontSize,
                                  ),
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
              SizedBox(height: responsive.largeSpacing),

              // Recommendations button
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
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

              SizedBox(height: responsive.largeSpacing),
            ],
          ),
        ),
      ),
    );
  }

  // Legend widget
  Widget _buildLegend(Responsive responsive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(
          color: blackPepperColor,
          label: 'Black Pepper',
          responsive: responsive,
        ),
        SizedBox(width: responsive.mediumSpacing),
        _legendItem(
          color: whitePepperColor,
          label: 'White Pepper',
          responsive: responsive,
        ),
      ],
    );
  }

  // Legend item widget
  Widget _legendItem({
    required Color color,
    required String label,
    required Responsive responsive,
  }) {
    return Row(
      children: [
        Container(
          width: responsive.smallSpacing,
          height: responsive.smallSpacing,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        SizedBox(width: responsive.smallSpacing / 2),
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.bodyFontSize,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

// Extension to safely take last n elements from a list
extension TakeLast<T> on List<T> {
  List<T> takeLast(int n) => skip(length - n).toList();
}
