import 'package:flutter/material.dart';
import '../../../utils/responsive.dart';
import '../../../../widgets/bottom_navigation.dart';
import '../../../utils/language_prefs.dart';
import '../../../utils/market forecast/navigation_si.dart';
import 'weekly_price_forecast.dart';
import 'export_price_trends.dart';
import 'export_details_by_country.dart';
import 'actual_price_data.dart';

class PriceNavigation extends StatefulWidget {
  const PriceNavigation({Key? key}) : super(key: key);

  @override
  State<PriceNavigation> createState() => _PriceNavigationState();
}

class _PriceNavigationState extends State<PriceNavigation>
    with SingleTickerProviderStateMixin {
  // Animation controller for fade-in effect on screen load
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller with 800ms duration
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    // Create fade animation from 0.0 to 1.0 opacity
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    // Start the animation
    _animationController.forward();
    // Load saved language preference
    LanguagePrefs.getLanguage().then((lang) {
      if (mounted) {
        setState(() {
          _currentLanguage = lang;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final Color primary = const Color(0xFF2E7D32);
  String _currentLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _currentLanguage == 'si'
              ? NavigationSi.marketForecast
              : 'Market Forecast',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      // Main body with fade transition animation
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: responsive.mediumSpacing),

                // Top description card explaining the feature
                _buildDescriptionCard(responsive),

                SizedBox(height: responsive.largeSpacing),

                // Section title for navigation options
                Text(
                  _currentLanguage == 'si'
                      ? NavigationSi.exploreMarketData
                      : 'Explore Market Data',
                  style: TextStyle(
                    fontSize: responsive.titleFontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(
                  height: responsive.value(mobile: 10, tablet: 12, desktop: 16),
                ),

                _buildNavigationCardsGrid(responsive),

                SizedBox(height: responsive.largeSpacing),
              ],
            ),
          ),
        ),
      ),
      // Bottom navigation bar for navigating between app sections
      bottomNavigationBar: BottomNavigation(
        currentIndex: 0,
        onTabSelected: (index) {
          // Handle navigation based on index
          if (index != 1) {
            // If not already on Market Forecast tab
            Navigator.pop(
              context,
            ); // Go back and let NavigationWrapper handle it
          }
        },
      ),
    );
  }

  Widget _buildNavigationCardsGrid(Responsive responsive) {
    final cards = [
      _buildNavigationCard(
        responsive,
        title: _currentLanguage == 'si'
            ? NavigationSi.weeklyLocalPriceForecast
            : 'Weekly Local Price Forecast',
        subtitle: _currentLanguage == 'si'
            ? NavigationSi.viewWeeklyPredictions
            : 'View weekly predictions',
        icon: Icons.trending_up_rounded,
        iconColor: Colors.deepOrange,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WeeklyPriceForecast()),
        ),
      ),
      _buildNavigationCard(
        responsive,
        title: _currentLanguage == 'si'
            ? NavigationSi.pastExportPriceTrends
            : 'Past Export Price Trends',
        subtitle: _currentLanguage == 'si'
            ? NavigationSi.analyzeTrends
            : 'Analyze trends',
        icon: Icons.assessment_rounded,
        iconColor: Colors.indigo,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExportPriceTrends()),
        ),
      ),
      _buildNavigationCard(
        responsive,
        title: _currentLanguage == 'si'
            ? NavigationSi.exportDetailsByCountry
            : 'Export Details by Country',
        subtitle: _currentLanguage == 'si'
            ? NavigationSi.trackGlobalExports
            : 'Track global exports',
        icon: Icons.public_rounded,
        iconColor: Colors.blue,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ExportDetailsByCountry(),
          ),
        ),
      ),
      _buildNavigationCard(
        responsive,
        title: _currentLanguage == 'si'
            ? NavigationSi.realMarketPrices
            : 'Create the Pepper Batch',
        subtitle: _currentLanguage == 'si'
            ? NavigationSi.enterPriceDetails
            : 'Enter the details',
        icon: Icons.receipt_long_rounded,
        iconColor: Colors.amber,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ActualPriceData()),
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = responsive.value(
          mobile: 12.0,
          tablet: 16.0,
          desktop: 20.0,
        );
        final itemWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map(
                (card) => SizedBox(
                  width: itemWidth,
                  height: responsive.value(
                    mobile: 170,
                    tablet: 200,
                    desktop: 220,
                  ),
                  child: card,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildNavigationCard(
    Responsive responsive, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          responsive.value(mobile: 16, tablet: 18, desktop: 20),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFF7F7F8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(
              responsive.value(mobile: 16, tablet: 18, desktop: 20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(
              responsive.value(mobile: 14, tablet: 16, desktop: 18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon box
                Container(
                  padding: EdgeInsets.all(
                    responsive.value(mobile: 8, tablet: 10, desktop: 12),
                  ),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: responsive.value(mobile: 26, tablet: 30, desktop: 34),
                    color: iconColor,
                  ),
                ),

                SizedBox(
                  height: responsive.value(mobile: 10, tablet: 12, desktop: 14),
                ),

                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: responsive.value(
                      mobile: 13,
                      tablet: 15,
                      desktop: 16,
                    ),
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(
                  height: responsive.value(mobile: 4, tablet: 5, desktop: 6),
                ),

                // Subtitle + arrow
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: responsive.value(
                            mobile: 11,
                            tablet: 13,
                            desktop: 14,
                          ),
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.grey[600],
                      size: responsive.value(
                        mobile: 14,
                        tablet: 16,
                        desktop: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
        border: Border.all(color: Colors.white, width: 2),
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
              Icons.analytics_rounded,
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
                  _currentLanguage == 'si'
                      ? NavigationSi.descriptionTitle
                      : 'Market Forecast',
                  style: TextStyle(
                    fontSize: responsive.bodyFontSize + 2,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentLanguage == 'si'
                      ? NavigationSi.descriptionBody
                      : 'Explore weekly predictions, historical trends, and global export data to make informed trading decisions.',
                  style: TextStyle(
                    fontSize: responsive.bodyFontSize - 1,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
