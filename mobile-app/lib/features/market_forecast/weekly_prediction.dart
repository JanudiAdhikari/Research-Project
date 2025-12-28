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

  List<Map<String, dynamic>> generatePreviousWeeks(
    int year,
    int month,
    int weekNumber,
    int count,
  ) {
    List<Map<String, dynamic>> weeks = [];

    DateTime firstDayOfMonth = DateTime(year, month, 1);
    int dayOfWeek = firstDayOfMonth.weekday;
    int offset = (dayOfWeek == 1) ? 0 : (8 - dayOfWeek);
    DateTime firstMonday = firstDayOfMonth.add(Duration(days: offset));
    DateTime selectedWeekStart = firstMonday.add(
      Duration(days: (weekNumber - 1) * 7),
    );

    for (int i = count - 1; i >= 0; i--) {
      DateTime weekStart = selectedWeekStart.subtract(Duration(days: i * 7));
      int wYear = weekStart.year;
      int wMonth = weekStart.month;

      DateTime firstOfMonth = DateTime(wYear, wMonth, 1);
      int firstWeekday = firstOfMonth.weekday;
      int firstMondayOffset = (firstWeekday == 1) ? 0 : (8 - firstWeekday);
      DateTime monthFirstMonday = firstOfMonth.add(
        Duration(days: firstMondayOffset),
      );

      int weekInMonth =
          ((weekStart.difference(monthFirstMonday).inDays) / 7).floor() + 1;
      if (weekStart.isBefore(monthFirstMonday)) weekInMonth = 1;

      weeks.add({'year': wYear, 'month': wMonth, 'week': weekInMonth});
    }

    return weeks;
  }

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
    return weeks
        .map((w) => "${monthNames[w['month']!]} w${w['week']!}")
        .toList();
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

    List<double> blackData = [];
    List<double> whiteData = [];
    for (int i = 0; i < dataLength; i++) {
      int priceIndex = i % blackPepperPriceData.length;
      blackData.add(blackPepperPriceData[priceIndex]);
      whiteData.add(whitePepperPriceData[priceIndex]);
    }

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("Overview"),
        backgroundColor: Colors.green,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: responsive.smallSpacing),

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
                  child: Column(
                    children: [
                      ResponsiveText(
                        '${month ?? 'Month'} - ${week ?? 'Week'} (${year ?? 'Year'})',
                        mobileFontSize: responsive.bodyFontSize,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                      SizedBox(height: responsive.smallSpacing),
                      ResponsiveText(
                        'Predicted Price:\nRs.1890 /kg',
                        mobileFontSize: responsive.titleFontSize,
                        textAlign: TextAlign.center,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: responsive.largeSpacing * 4),

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
                      maxX: (dataLength - 1).toDouble(),
                      minY: 1000,
                      maxY: 2700,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 500,
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
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= weekLabels.length) {
                                return const SizedBox.shrink();
                              }
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
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

              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
