import 'package:flutter/material.dart';
import '../../../utils/responsive.dart';
import '../../../services/market_forecast/export_details_by_country_service.dart';

class ExportCountryDetailScreen extends StatefulWidget {
  final String country;
  final int? initialYear;

  const ExportCountryDetailScreen({
    super.key,
    required this.country,
    this.initialYear,
  });

  @override
  State<ExportCountryDetailScreen> createState() =>
      _ExportCountryDetailScreenState();
}

class _ExportCountryDetailScreenState extends State<ExportCountryDetailScreen> {
  // Currently selected year for the detail view
  int? selectedYear;
  List<int> years = [];
  List<Map<String, dynamic>> yearDetails = [];
  bool isLoadingYears = true;
  bool isLoadingDetails = false;
  String? errorMessage;

  final ExportDetailsByCountryService _service =
      ExportDetailsByCountryService();

  @override
  void initState() {
    super.initState();
    _loadYearsAndInit(); // Load available years and initial details on screen
  }

  // Load available years for the country and then load details for the selected year
  Future<void> _loadYearsAndInit() async {
    try {
      if (!mounted) return;
      setState(() {
        isLoadingYears = true;
        errorMessage = null;
      });
      // Fetch available years for the selected country
      final loadedYears = await _service.fetchYearsForCountry(widget.country);
      if (!mounted) return;
      setState(() {
        years = loadedYears;
        if (years.isNotEmpty) {
          selectedYear = widget.initialYear ?? years.last;
        }
        isLoadingYears = false;
      });

      if (selectedYear != null) {
        await _loadDetailsForYear(selectedYear!);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingYears = false;
        errorMessage = e.toString();
      });
    }
  }

  // Load export details for the selected year
  Future<void> _loadDetailsForYear(int year) async {
    try {
      if (!mounted) return;
      setState(() {
        isLoadingDetails = true;
        errorMessage = null;
      });

      final details = await _service.fetchExportDetails(
        country: widget.country,
        year: year,
      );

      if (!mounted) return;
      setState(() {
        yearDetails = details
            .whereType<Map<String, dynamic>>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        isLoadingDetails = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingDetails = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    if (isLoadingYears) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(widget.country),
          backgroundColor: const Color(0xFF2E7D32),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(widget.country),
          backgroundColor: const Color(0xFF2E7D32),
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(responsive.mediumSpacing),
            child: Text('Error loading details: $errorMessage'),
          ),
        ),
      );
    }

    if (years.isEmpty || selectedYear == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(widget.country),
          backgroundColor: const Color(0xFF2E7D32),
          elevation: 0,
        ),
        body: const Center(child: Text('No data available for this country')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        // Show the selected country name in the app bar
        title: Text(widget.country),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(responsive.mediumSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Country header card with flag and year info
                _buildHeaderCard(responsive),
                SizedBox(height: responsive.mediumSpacing),
                // Year selector
                _buildYearFilter(responsive),
                SizedBox(height: responsive.mediumSpacing),
                // Product breakdown grid 
                if (!isLoadingDetails)
                  _buildProductBreakdown(yearDetails, responsive),
              ],
            ),
          ),
          if (isLoadingDetails)
            const Positioned.fill(
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // Get flag emoji for country
  String _getFlagForCountry(String country) {
    final flags = {
      'India': '🇮🇳',
      'Germany': '🇩🇪',
      'Spain': '🇪🇸',
      'UAE': '🇦🇪',
      'Japan': '🇯🇵',
      'UK': '🇬🇧',
      'USA': '🇺🇸',
      'Canada': '🇨🇦',
    };
    return flags[country] ?? '🌍';
  }

  // Header card showing flag, country name, and current year
  Widget _buildHeaderCard(Responsive responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.mediumSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Flag block
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              _getFlagForCountry(widget.country),
              style: const TextStyle(fontSize: 42),
            ),
          ),
          SizedBox(width: responsive.mediumSpacing),
          // Country name and year
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.country,
                  style: TextStyle(
                    fontSize: responsive.bodyFontSize + 6,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: responsive.smallSpacing),
                Text(
                  'Year: $selectedYear',
                  style: TextStyle(
                    fontSize: responsive.bodyFontSize + 1,
                    color: const Color.fromARGB(137, 0, 0, 0),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: responsive.smallSpacing),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Year selector
  Widget _buildYearFilter(Responsive responsive) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.mediumSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: responsive.smallSpacing,
        runSpacing: responsive.smallSpacing,
        children: years
            .map(
              (year) => ChoiceChip(
                label: Text(
                  year.toString(),
                  style: TextStyle(
                    fontSize: responsive.bodyFontSize,
                    fontWeight: FontWeight.w700,
                    color: selectedYear == year
                        ? Colors.white
                        : Colors.green.shade900,
                  ),
                ),
                selected: selectedYear == year,
                selectedColor: const Color(0xFF2E7D32),
                backgroundColor: Colors.grey[100],
                onSelected: (_) {
                  // Update selected year and rebuild
                  setState(() {
                    selectedYear = year;
                  });
                  _loadDetailsForYear(year);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  // Build 4 sections of product breakdown
  Widget _buildProductBreakdown(
    List<Map<String, dynamic>> details,
    Responsive responsive,
  ) {
    const expectedTypes = [
      'Ground Pepper',
      'Whole Pepper',
      'Pepper Oil',
      'Pepper Oleoresin',
    ];

    const normalizedToExpected = {
      'ground pepper': 'Ground Pepper',
      'whole pepper': 'Whole Pepper',
      'pepper oil': 'Pepper Oil',
      'pepper oleoresin': 'Pepper Oleoresin',
    };

    final byType = <String, Map<String, dynamic>>{};
    for (final item in details) {
      final rawType = (item['pepper_type'] ?? '').toString();
      final normalizedType = rawType.trim().toLowerCase();
      final expectedType = normalizedToExpected[normalizedType];
      if (expectedType != null) {
        byType[expectedType] = item;
      }
    }

    final palette = [
      const Color(0xFFBBDEFB),
      const Color(0xFFA5D6A7),
      const Color(0xFFFFE082),
      const Color(0xFFD1C4E9),
    ];

    return Column(
      children: expectedTypes.asMap().entries.map((entry) {
        final index = entry.key;
        final type = entry.value;
        final item = byType[type];
        final exportVolume = (item?['export_volume'] as num?) ?? 0;
        final exportValue = (item?['export_value'] as num?) ?? 0;
        return Padding(
          padding: EdgeInsets.only(bottom: responsive.smallSpacing),
          child: _buildProductCard(
            type,
            exportVolume,
            exportValue,
            palette[index % palette.length],
            responsive,
          ),
        );
      }).toList(),
    );
  }

  // Single product card showing volume and value
  Widget _buildProductCard(
    String title,
    num volumeMt,
    num exportValue,
    Color bgColor,
    Responsive responsive,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.smallSpacing),
      padding: EdgeInsets.all(responsive.mediumSpacing),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name
          Text(
            title,
            style: TextStyle(
              fontSize: responsive.bodyFontSize + 2,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: responsive.smallSpacing),
          // Export volume label/value
          Text(
            'Export Volume',
            style: TextStyle(
              fontSize: responsive.smallFontSize + 1,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${volumeMt.toStringAsFixed(0)} MT',
            style: TextStyle(
              fontSize: responsive.bodyFontSize + 2,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: responsive.smallSpacing),
          // Export value label/value
          Text(
            'Export Value',
            style: TextStyle(
              fontSize: responsive.smallFontSize + 1,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '\$${exportValue.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: responsive.bodyFontSize + 1,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
