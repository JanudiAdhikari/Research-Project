import 'package:flutter/material.dart';

class WeeklyPriceForecast extends StatefulWidget {
  const WeeklyPriceForecast({Key? key}) : super(key: key);

  @override
  State<WeeklyPriceForecast> createState() => _WeeklyPriceForecastState();
}

class _WeeklyPriceForecastState extends State<WeeklyPriceForecast> {
  final Color primary = const Color(0xFF2E7D32);

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- HEADER ----------
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
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
                        children: const [
                          Text(
                            "Hello, Farmer 👋",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Weekly Pepper Price Forecast",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Discover how prices may change next week...",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              height: 1.3,
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
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Location
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.location_on_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Colombo",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.wb_sunny_rounded,
                          color: Colors.amber,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "29°C",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ---------- DROPDOWNS ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdownField(
                    "District",
                    selectedDistrict,
                    districts,
                    (val) => setState(() => selectedDistrict = val),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    "Pepper Type",
                    selectedPepperType,
                    pepperTypes,
                    (val) => setState(() => selectedPepperType = val),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    "Grade",
                    selectedGrade,
                    grades,
                    (val) => setState(() => selectedGrade = val),
                  ),
                  const SizedBox(height: 16),
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
                      const SizedBox(width: 16),
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
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    "Week",
                    selectedWeek,
                    weeks,
                    (val) => setState(() => selectedWeek = val),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        // Fetch price prediction
                      },
                      child: const Text(
                        "Predict the Price",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
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
    (context) => Positioned(
      left: offset.dx,
      top: offset.dy + size.height,
      width: size.width,
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: items
                .map(
                  (item) => ListTile(
                    title: Text(item),
                    onTap: () {
                      onChanged(item);
                      _overlayEntry!.remove();
                      _overlayEntry = null;
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }
}
