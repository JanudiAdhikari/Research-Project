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
  final List<String> years = ['2026', '2027'];
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

  bool showErrors = false; // To control error message visibility

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
    // Remove any open overlay to avoid leaking visual elements when disposed
    _overlayEntry?.remove();
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
                                  "Discover how prices may change in upcoming weeks...",
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
                          required: true,
                        ),
                        ResponsiveSpacing(mobile: 16, tablet: 18, desktop: 20),
                        _buildDropdownField(
                          "Pepper Type",
                          selectedPepperType,
                          pepperTypes,
                          (val) => setState(() => selectedPepperType = val),
                          required: true,
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
                                required: true,
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
                                required: true,
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
                          required: true,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            "Weather Conditions",
                            style: TextStyle(
                              fontSize: responsive.bodyFontSize - 0.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        ResponsiveSpacing(mobile: 16, tablet: 18, desktop: 20),

                        // WEATHER SECTION
                        Container(
                          padding: EdgeInsets.all(
                            responsive.value(
                              mobile: 20,
                              tablet: 24,
                              desktop: 28,
                            ),
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade50,
                                Colors.cyan.shade50,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                              responsive.value(
                                mobile: 20,
                                tablet: 24,
                                desktop: 28,
                              ),
                            ),
                            border: Border.all(
                              color: Colors.blue.shade200,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Weather Grid - 2x2
                              GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: responsive.value(
                                  mobile: 12,
                                  tablet: 14,
                                  desktop: 16,
                                ),
                                mainAxisSpacing: responsive.value(
                                  mobile: 12,
                                  tablet: 14,
                                  desktop: 16,
                                ),
                                childAspectRatio: 0.95,
                                children: [
                                  _buildEnhancedWeatherCard(
                                    icon: Icons.opacity,
                                    iconColor: Colors.blue,
                                    label: "Rainfall",
                                    value: "120",
                                    unit: "mm",
                                    responsive: responsive,
                                    description: "Moderate Rain",
                                  ),
                                  _buildEnhancedWeatherCard(
                                    icon: Icons.thermostat,
                                    iconColor: Colors.orange,
                                    label: "Temperature",
                                    value: "29",
                                    unit: "°C",
                                    responsive: responsive,
                                    description: "Warm",
                                  ),
                                  _buildEnhancedWeatherCard(
                                    icon: Icons.water_drop,
                                    iconColor: Colors.cyan,
                                    label: "Humidity",
                                    value: "78",
                                    unit: "%",
                                    responsive: responsive,
                                    description: "High Moisture",
                                  ),
                                  _buildEnhancedWeatherCard(
                                    icon: Icons.air,
                                    iconColor: Colors.teal,
                                    label: "Wind Speed",
                                    value: "12",
                                    unit: "km/h",
                                    responsive: responsive,
                                    description: "Light Breeze",
                                  ),
                                ],
                              ),

                              ResponsiveSpacing(
                                mobile: 16,
                                tablet: 18,
                                desktop: 20,
                              ),

                              // Weather Summary Card
                              Container(
                                padding: EdgeInsets.all(
                                  responsive.value(
                                    mobile: 14,
                                    tablet: 16,
                                    desktop: 18,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Good conditions for crop growth. Expect moderate rainfall with warm temperatures.",
                                        style: TextStyle(
                                          fontSize:
                                              responsive.bodyFontSize - 1.5,
                                          color: Colors.blue.shade800,
                                          fontWeight: FontWeight.w500,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        ResponsiveSpacing(mobile: 24, tablet: 28, desktop: 32),

                        Center(
                          child: SizedBox(
                            width:
                                MediaQuery.of(context).size.width *
                                0.6, // 60% width
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
                              onPressed: () {
                                setState(() {
                                  showErrors = true; // enable error messages
                                });

                                // Check required fields
                                if (selectedDistrict == null ||
                                    selectedPepperType == null ||
                                    selectedYear == null ||
                                    selectedMonth == null ||
                                    selectedWeek == null) {
                                  return; // stop navigation
                                }

                                // All good → navigate with animation
                                Navigator.push(
                                  context,
                                  _buildCustomPageRoute(
                                    WeeklyPrediction(
                                      year: selectedYear,
                                      month: selectedMonth,
                                      week: selectedWeek,
                                    ),
                                  ),
                                );
                              },

                              child: const Text(
                                'Predict the Price',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
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
    ValueChanged<String?> onChanged, {
    bool required = false,
  }) {
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
                border: Border.all(
                  color: (showErrors && required && value == null)
                      ? Colors.red
                      : Colors.grey.shade300,
                ),
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

        if (showErrors && required && value == null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              "$title is required",
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildEnhancedWeatherCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String unit,
    required Responsive responsive,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsive.value(mobile: 16, tablet: 18, desktop: 20),
        ),
        border: Border.all(color: iconColor.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(
          responsive.value(mobile: 14, tablet: 16, desktop: 18),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, iconColor.withOpacity(0.03)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(
            responsive.value(mobile: 16, tablet: 18, desktop: 20),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Badge
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: responsive.value(mobile: 24, tablet: 28, desktop: 32),
              ),
            ),

            // Value and Unit
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style: TextStyle(
                          fontSize: responsive.fontSize(
                            mobile: 24,
                            tablet: 28,
                            desktop: 32,
                          ),
                          fontWeight: FontWeight.w700,
                          color: iconColor,
                        ),
                      ),
                      TextSpan(
                        text: unit,
                        style: TextStyle(
                          fontSize: responsive.bodyFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: responsive.bodyFontSize - 1,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: responsive.bodyFontSize - 2,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

  PageRouteBuilder _buildCustomPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
    );
  }
}
