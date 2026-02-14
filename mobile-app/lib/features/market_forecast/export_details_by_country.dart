import 'package:flutter/material.dart';
import '../../utils/responsive.dart';
import '../../services/market_forecast/export_details_by_country_service.dart';
import 'export_country_detail.dart';

class ExportDetailsByCountry extends StatefulWidget {
  const ExportDetailsByCountry({super.key});

  @override
  State<ExportDetailsByCountry> createState() => _ExportDetailsByCountryState();
}

class _ExportDetailsByCountryState extends State<ExportDetailsByCountry> {
  // Currently selected country (null means showing grid)
  String? selectedCountry;
  // Default selected year
  int selectedYear = 2025;

  // Dynamic data from backend
  List<String> countries = [];
  List<int> years = [];
  bool isLoading = true;
  String? errorMessage;

  final ExportDetailsByCountryService _service =
      ExportDetailsByCountryService();

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      setState(() => isLoading = true);
      final loadedCountries = await _service.fetchCountries();
      setState(() {
        countries = loadedCountries;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Export Details by Country'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Export Details by Country'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading countries: $errorMessage',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCountries,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Export Details by Country'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        // Hide back arrow while in grid view
        automaticallyImplyLeading: selectedCountry == null,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(responsive.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDescriptionCard(responsive),
            SizedBox(height: responsive.mediumSpacing),
            // Show grid until a country is picked; then show year + details
            if (selectedCountry == null)
              _buildCountrySelectorGrid(responsive)
            else
              Column(
                children: [
                  _buildYearFilter(responsive),
                  SizedBox(height: responsive.mediumSpacing),
                  _buildCountryDetails(responsive),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Intro card explaining the screen purpose
  Widget _buildDescriptionCard(Responsive responsive) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.mediumSpacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFC8E6C9), const Color(0xFFA5D6A7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withOpacity(0.08)),
            ),
            child: const Icon(
              Icons.public_rounded,
              color: Colors.black87,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sri Lanka\'s Major Export Markets',
                  style: TextStyle(
                    fontSize: responsive.bodyFontSize + 2,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track export volumes and pricing trends across key international markets',
                  style: TextStyle(
                    fontSize: responsive.bodyFontSize - 1,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
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
      'China': '🇨🇳',
      'France': '🇫🇷',
      'Netherlands': '🇳🇱',
      'Italy': '🇮🇹',
      'Belgium': '🇧🇪',
      'Poland': '🇵🇱',
      'Brazil': '🇧🇷',
      'Mexico': '🇲🇽',
      'Australia': '🇦🇺',
      'Thailand': '🇹🇭',
      'Vietnam': '🇻🇳',
      'Indonesia': '🇮🇩',
      'Malaysia': '🇲🇾',
      'Singapore': '🇸🇬',
    };
    return flags[country] ?? '🌍';
  }

  // Grid of country cards (2 columns)
  Widget _buildCountrySelectorGrid(Responsive responsive) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: responsive.mediumSpacing,
      mainAxisSpacing: responsive.mediumSpacing,
      childAspectRatio: 1.2,
      physics: const NeverScrollableScrollPhysics(),
      children: countries
          .map((country) => _buildCountrySelectionCard(country, responsive))
          .toList(),
    );
  }

  // Single country card in the grid
  Widget _buildCountrySelectionCard(String country, Responsive responsive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCountry = country;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getFlagForCountry(country),
              style: const TextStyle(fontSize: 48),
            ),
            SizedBox(height: responsive.smallSpacing),
            Text(
              country,
              style: TextStyle(
                fontSize: responsive.bodyFontSize + 1,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Country details section - fetch from backend
  Widget _buildCountryDetails(Responsive responsive) {
    final country = selectedCountry!;

    return FutureBuilder<Map<String, dynamic>?>(
      future: _service.fetchDetailsByCountryAndYear(country, selectedYear),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(responsive.mediumSpacing),
              child: const CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: EdgeInsets.all(responsive.mediumSpacing),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text('Error loading details: ${snapshot.error}'),
          );
        }

        final data = snapshot.data;
        if (data == null) {
          return Container(
            padding: EdgeInsets.all(responsive.mediumSpacing),
            decoration: BoxDecoration(
              color: Colors.yellow.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('No data available for this selection'),
          );
        }

        final exportVolume = data['export_volume'] ?? 0;
        final exportValue = data['export_value'] ?? 0;
        final pepperType = data['pepper_type'] ?? 'N/A';

        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(responsive.mediumSpacing),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        _getFlagForCountry(country),
                        style: const TextStyle(fontSize: 48),
                      ),
                      SizedBox(width: responsive.mediumSpacing),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              country,
                              style: TextStyle(
                                fontSize: responsive.bodyFontSize + 4,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: responsive.smallSpacing),
                            Text(
                              'Year: $selectedYear',
                              style: TextStyle(
                                fontSize: responsive.bodyFontSize,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.mediumSpacing),
                  _buildExportDetailsCard(
                    'Export Volume',
                    '$exportVolume MT',
                    Colors.blue,
                    responsive,
                  ),
                  SizedBox(height: responsive.smallSpacing),
                  _buildExportDetailsCard(
                    'Export Value',
                    '\$$exportValue',
                    Colors.green,
                    responsive,
                  ),
                  SizedBox(height: responsive.smallSpacing),
                  _buildExportDetailsCard(
                    'Pepper Type',
                    pepperType,
                    Colors.orange,
                    responsive,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Build export details card
  Widget _buildExportDetailsCard(
    String label,
    String value,
    Color color,
    Responsive responsive,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.smallSpacing + 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: responsive.bodyFontSize,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.bodyFontSize,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Year selector with “Back” to return to the grid
  Widget _buildYearFilter(Responsive responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.mediumSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Year',
                style: TextStyle(
                  fontSize: responsive.bodyFontSize + 2,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCountry = null;
                  });
                },
                child: Text(
                  'Back',
                  style: TextStyle(
                    color: const Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                    fontSize: responsive.bodyFontSize,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.mediumSpacing),
          Wrap(
            spacing: responsive.smallSpacing,
            runSpacing: responsive.smallSpacing,
            children: years
                .map(
                  (year) => GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedYear = year;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.mediumSpacing,
                        vertical: responsive.smallSpacing,
                      ),
                      decoration: BoxDecoration(
                        color: selectedYear == year
                            ? const Color(0xFF2E7D32)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedYear == year
                              ? const Color(0xFF2E7D32)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        year.toString(),
                        style: TextStyle(
                          fontSize: responsive.bodyFontSize,
                          fontWeight: FontWeight.w600,
                          color: selectedYear == year
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
