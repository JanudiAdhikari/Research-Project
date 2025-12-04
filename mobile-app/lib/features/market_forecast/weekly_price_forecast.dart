import 'package:flutter/material.dart';
import '../../utils/responsive.dart';
import 'weekly_prediction.dart';

class WeeklyPriceForecast extends StatefulWidget {
  const WeeklyPriceForecast({Key? key}) : super(key: key);

  @override
  State<WeeklyPriceForecast> createState() => _WeeklyPriceForecastState();
}

class _WeeklyPriceForecastState extends State<WeeklyPriceForecast>
    with SingleTickerProviderStateMixin {
  final Color primary = const Color(0xFF2E7D32);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Dropdown values
  String? selectedDistrict;
  String? selectedPepperType;
  String? selectedGrade;
  String? selectedYear;
  String? selectedMonth;
  String? selectedWeek;

  // Sample dropdown options
  final List<String> districts = [
    'Badulla',
    'Colombo',
    'Galle',
    'Gampaha',
    'Hambantota',
    'Kalutara',
    'Kandy',
    'Kegalle',
    'Kurunegala',
    'Matale',
    'Matara',
    'Monaragala',
    'Nuwara Eliya',
    'Ratnapura',
  ];
  final List<String> pepperTypes = ['Black', 'White'];
  final List<String> grades = ['Grade 1', 'Grade 2', 'Grade 3'];
  final List<String> years = ['2025', '2026', '2027'];
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final List<String> weeks = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- HEADER ----------
                  Container(
                    padding: responsive.padding(
                      mobile: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                      tablet: const EdgeInsets.fromLTRB(32, 24, 32, 36),
                      desktop: const EdgeInsets.fromLTRB(40, 28, 40, 42),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primary, primary.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(
                          responsive.value(mobile: 32, tablet: 36, desktop: 40),
                        ),
                        bottomRight: Radius.circular(
                          responsive.value(mobile: 32, tablet: 36, desktop: 40),
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hello, Farmer 👋",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: responsive.bodyFontSize,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Weekly Pepper Price Forecast",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: responsive.fontSize(
                                      mobile: 24,
                                      tablet: 28,
                                      desktop: 32,
                                    ),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  "Discover how prices may change next week...",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: responsive.fontSize(
                                      mobile: 15,
                                      tablet: 22,
                                      desktop: 24,
                                    ),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: responsive.value(
                                  mobile: 26,
                                  tablet: 28,
                                  desktop: 32,
                                ),
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person_rounded,
                                  color: primary,
                                  size: responsive.value(
                                    mobile: 26,
                                    tablet: 28,
                                    desktop: 32,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        ResponsiveSpacing(mobile: 20, tablet: 24, desktop: 28),

                        Container(
                          padding: responsive.padding(
                            mobile: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            tablet: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            desktop: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(
                              responsive.value(
                                mobile: 16,
                                tablet: 18,
                                desktop: 20,
                              ),
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: Colors.white.withOpacity(0.9),
                                size: responsive.smallIconSize,
                              ),
                              ResponsiveSpacing.horizontal(
                                mobile: 8,
                                tablet: 10,
                                desktop: 12,
                              ),
                              Text(
                                "Colombo",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: responsive.bodyFontSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.wb_sunny_rounded,
                                color: Colors.amber[300],
                                size: responsive.smallIconSize,
                              ),
                              ResponsiveSpacing.horizontal(
                                mobile: 8,
                                tablet: 10,
                                desktop: 12,
                              ),
                              Text(
                                "29°C",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: responsive.bodyFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  ResponsiveSpacing(mobile: 24, tablet: 28, desktop: 32),

                  // ---------- DROPDOWNS ----------
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.pagePadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDropdownField(
                          "District",
                          selectedDistrict,
                          districts,
                          (val) => setState(() => selectedDistrict = val),
                        ),
                        ResponsiveSpacing(mobile: 16, tablet: 18, desktop: 20),
                        _buildDropdownField(
                          "Pepper Type",
                          selectedPepperType,
                          pepperTypes,
                          (val) => setState(() => selectedPepperType = val),
                        ),
                        ResponsiveSpacing(mobile: 16, tablet: 18, desktop: 20),
                        _buildDropdownField(
                          "Grade",
                          selectedGrade,
                          grades,
                          (val) => setState(() => selectedGrade = val),
                        ),
                        ResponsiveSpacing(mobile: 16, tablet: 18, desktop: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownField(
                                "Year",
                                selectedYear,
                                years,
                                (val) => setState(() => selectedYear = val),
                              ),
                            ),
                            ResponsiveSpacing.horizontal(
                              mobile: 16,
                              tablet: 18,
                              desktop: 20,
                            ),
                            Expanded(
                              child: _buildDropdownField(
                                "Month",
                                selectedMonth,
                                months,
                                (val) => setState(() => selectedMonth = val),
                              ),
                            ),
                          ],
                        ),
                        ResponsiveSpacing(mobile: 16, tablet: 18, desktop: 20),
                        _buildDropdownField(
                          "Week",
                          selectedWeek,
                          weeks,
                          (val) => setState(() => selectedWeek = val),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            "Weather Details",
                            style: TextStyle(
                              fontSize: responsive.bodyFontSize - 0.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        ResponsiveSpacing(mobile: 16, tablet: 18, desktop: 20),

                        Wrap(
                          spacing: responsive.value(
                            mobile: 12,
                            tablet: 16,
                            desktop: 20,
                          ),
                          runSpacing: responsive.value(
                            mobile: 12,
                            tablet: 16,
                            desktop: 20,
                          ),
                          children: [
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  // Sample data added for weather details. Need to connect the API
                                  children: [
                                    _buildWeatherCard(
                                      imagePath:
                                          "assets/images/market_forecast/rainfall.png",
                                      label: "Rainfall",
                                      value: "120 mm",
                                      responsive: responsive,
                                    ),
                                    _buildWeatherCard(
                                      imagePath:
                                          "assets/images/market_forecast/temperature.png",
                                      label: "Temperature",
                                      value: "29°C",
                                      responsive: responsive,
                                    ),
                                    _buildWeatherCard(
                                      imagePath:
                                          "assets/images/market_forecast/humidity.png",
                                      label: "Humidity",
                                      value: "78%",
                                      responsive: responsive,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: responsive.value(
                                    mobile: 16,
                                    tablet: 18,
                                    desktop: 20,
                                  ),
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildWeatherCard(
                                      imagePath:
                                          "assets/images/market_forecast/wind_speed.png",
                                      label: "Wind Speed",
                                      value: "12 km/h",
                                      responsive: responsive,
                                    ),
                                    _buildWeatherCard(
                                      imagePath:
                                          "assets/images/market_forecast/soil_temperature.png",
                                      label: "Soil Temp",
                                      value: "23°C",
                                      responsive: responsive,
                                    ),
                                    SizedBox(
                                      width: _buildWeatherCardWidth(responsive),
                                    ),
                                  ],
                                ),

                                SizedBox(
                                  height: responsive.value(
                                    mobile: 24,
                                    tablet: 28,
                                    desktop: 32,
                                  ),
                                ), // space before the button
                              ],
                            ),
                          ],
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              padding: EdgeInsets.symmetric(
                                vertical: responsive.value(
                                  mobile: 14,
                                  tablet: 16,
                                  desktop: 18,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const WeeklyPrediction(),
                                ),
                              );
                            },
                            child: Text(
                              "Predict the Price",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: responsive.bodyFontSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  ResponsiveSpacing(mobile: 32, tablet: 36, desktop: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String title,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    final key = GlobalKey();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            key: key,
            onTap: () => _toggleDropdown(key, items, value, onChanged),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                  Text(
                    value ?? 'Select $title',
                    style: TextStyle(
                      color: value == null
                          ? Colors.grey.shade600
                          : Colors.black87,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down_rounded),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherCard({
    required String imagePath,
    required String label,
    required String value,
    required Responsive responsive,
  }) {
    return Container(
      width: responsive.value(mobile: 120, tablet: 160, desktop: 180),
      padding: EdgeInsets.all(
        responsive.value(mobile: 16, tablet: 18, desktop: 20),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsive.value(mobile: 16, tablet: 18, desktop: 20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            width: responsive.value(mobile: 36, tablet: 40, desktop: 44),
            height: responsive.value(mobile: 36, tablet: 40, desktop: 44),
          ),
          ResponsiveSpacing(mobile: 8, tablet: 10, desktop: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.bodyFontSize + 1,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: responsive.bodyFontSize - 2,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  double _buildWeatherCardWidth(Responsive responsive) {
    return responsive.value(mobile: 120, tablet: 160, desktop: 180);
  }

  void _toggleDropdown(
    GlobalKey key,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      return;
    }

    // Height of a single item
    const double itemHeight = 48.0;
    // Show max 3 items; scroll if more
    final double dropdownHeight = items.length > 3
        ? itemHeight * 3
        : itemHeight * items.length;

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
}
