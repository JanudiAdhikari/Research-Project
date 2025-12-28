import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/responsive.dart';

class ExportPriceTrends extends StatefulWidget {
  const ExportPriceTrends({super.key});

  @override
  State<ExportPriceTrends> createState() => _ExportPriceTrendsState();
}

class _ExportPriceTrendsState extends State<ExportPriceTrends> {
  String selectedYear = '2025';
  int selectedMonthFrom = 0; // January
  int selectedMonthTo = 6; // July

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  final List<String> years = ['2022', '2023', '2024', '2025'];
  final List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  // Sample data for different years and months
  final Map<String, List<double>> priceData = {
    '2023': [
      1200,
      1250,
      1300,
      1350,
      1400,
      1450,
      1500,
      1550,
      1600,
      1650,
      1700,
      1750,
    ],
    '2024': [
      1300,
      1320,
      1340,
      1360,
      1400,
      1500,
      1600,
      1650,
      1700,
      1750,
      1800,
      1850,
    ],
    '2025': [
      1500,
      1450,
      1400,
      1500,
      1700,
      1900,
      2100,
      2200,
      2300,
      2400,
      2500,
      2600,
    ],
  };

  List<FlSpot> getChartData() {
    final data = priceData[selectedYear] ?? [];
    List<FlSpot> spots = [];
    for (
      int i = selectedMonthFrom;
      i <= selectedMonthTo && i < data.length;
      i++
    ) {
      spots.add(FlSpot((i - selectedMonthFrom).toDouble(), data[i]));
    }
    return spots;
  }

  String getDateRangeLabel() {
    return '${months[selectedMonthFrom]} - ${months[selectedMonthTo]}';
  }

  Map<String, double> calculateStats() {
    final spots = getChartData();
    if (spots.isEmpty) {
      return {'peak': 0, 'lowest': 0, 'average': 0};
    }

    final values = spots.map((spot) => spot.y).toList();
    final peak = values.reduce((a, b) => a > b ? a : b);
    final lowest = values.reduce((a, b) => a < b ? a : b);
    final average = values.fold(0.0, (sum, val) => sum + val) / values.length;

    return {'peak': peak, 'lowest': lowest, 'average': average};
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Past Export Price Trends'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(responsive.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _filtersSection(),
            SizedBox(height: responsive.mediumSpacing),
            _chartCard(),
            SizedBox(height: responsive.mediumSpacing),
            _priceStats(),
            SizedBox(height: responsive.mediumSpacing),
            _insightsCard(),
          ],
        ),
      ),
    );
  }

  // Filters
  Widget _filtersSection() {
    final responsive = context.responsive;
    return Row(
      children: [
        Expanded(
          child: _customDropdown('Year', selectedYear, years, (value) {
            setState(() => selectedYear = value);
          }),
        ),
        SizedBox(width: responsive.smallSpacing),
        Expanded(
          child: _customDropdown('From', months[selectedMonthFrom], months, (
            value,
          ) {
            final index = months.indexOf(value);
            if (index != -1 && index <= selectedMonthTo) {
              setState(() => selectedMonthFrom = index);
            }
          }),
        ),
        SizedBox(width: responsive.smallSpacing),
        Expanded(
          child: _customDropdown('To', months[selectedMonthTo], months, (
            value,
          ) {
            final index = months.indexOf(value);
            if (index != -1 && index >= selectedMonthFrom) {
              setState(() => selectedMonthTo = index);
            }
          }),
        ),
      ],
    );
  }

  Widget _customDropdown(
    String title,
    String value,
    List<String> items,
    ValueChanged<String> onChanged,
  ) {
    final key = GlobalKey();
    final responsive = context.responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: responsive.smallFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: responsive.smallSpacing / 2),
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            key: key,
            onTap: () => _toggleDropdown(key, items, value, onChanged),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.smallSpacing + 4,
                vertical: responsive.smallSpacing + 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  responsive.value(mobile: 10, tablet: 12, desktop: 14),
                ),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: responsive.bodyFontSize,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: responsive.mediumIconSize,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleDropdown(
    GlobalKey key,
    List<String> items,
    String value,
    ValueChanged<String> onChanged,
  ) {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      return;
    }

    const double itemHeight = 48.0;
    final double dropdownHeight = itemHeight * items.length;

    final renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: size.width,
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: dropdownHeight),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: items
                  .map(
                    (item) => SizedBox(
                      height: itemHeight,
                      child: ListTile(
                        title: Text(item),
                        onTap: () {
                          onChanged(item);
                          _overlayEntry!.remove();
                          _overlayEntry = null;
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  // Chart
  Widget _chartCard() {
    final chartData = getChartData();
    final dateRange = getDateRangeLabel();
    final responsive = context.responsive;

    return Container(
      padding: EdgeInsets.all(responsive.mediumSpacing),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Global Black Pepper Price Trends',
            style: TextStyle(
              fontSize: responsive.titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.smallSpacing / 2),
          Text(
            dateRange,
            style: TextStyle(
              color: Colors.grey,
              fontSize: responsive.bodyFontSize,
            ),
          ),
          SizedBox(height: responsive.mediumSpacing),
          SizedBox(
            height: responsive.value(mobile: 220, tablet: 260, desktop: 300),
            child: LineChart(
              LineChartData(
                minY: 1000,
                maxY: 3000,
                gridData: FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.blueAccent,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        final monthIndex = spot.x.toInt() + selectedMonthFrom;
                        final monthName = monthIndex < months.length
                            ? months[monthIndex]
                            : '';
                        return LineTooltipItem(
                          '$monthName\nRs.${spot.y.toInt()}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
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
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          'Rs.${value.toInt()}',
                          style: TextStyle(
                            fontSize: responsive.smallFontSize - 1,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt() + selectedMonthFrom;
                        if (index < months.length) {
                          return Text(
                            months[index],
                            style: TextStyle(
                              fontSize: responsive.smallFontSize,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    dotData: FlDotData(show: true),
                    color: Colors.blue,
                    barWidth: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Stats
  Widget _priceStats() {
    final stats = calculateStats();
    final responsive = context.responsive;
    return Row(
      children: [
        Expanded(
          child: _statCard('Peak Price', 'Rs.${stats['peak']!.toInt()} /kg'),
        ),
        SizedBox(width: responsive.smallSpacing),
        Expanded(
          child: _statCard(
            'Lowest Price',
            'Rs.${stats['lowest']!.toInt()} /kg',
          ),
        ),
        SizedBox(width: responsive.smallSpacing),
        Expanded(
          child: _statCard('Average', 'Rs.${stats['average']!.toInt()} /kg'),
        ),
      ],
    );
  }

  Widget _statCard(String title, String value) {
    final responsive = context.responsive;
    return Container(
      padding: EdgeInsets.all(responsive.smallSpacing + 4),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: responsive.smallFontSize)),
          SizedBox(height: responsive.smallSpacing / 2),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.bodyFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  // Insights
  Widget _insightsCard() {
    final responsive = context.responsive;
    return Container(
      padding: EdgeInsets.all(responsive.mediumSpacing),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Insights',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: responsive.titleFontSize,
            ),
          ),
          SizedBox(height: responsive.smallSpacing),
          Text(
            'Global pepper prices increased by 23% over the selected period, '
            'mainly driven by strong demand from major importing countries.',
            style: TextStyle(fontSize: responsive.bodyFontSize),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    final responsive = context.responsive;
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(
        responsive.value(mobile: 12, tablet: 14, desktop: 16),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
