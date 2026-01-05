import 'package:flutter/material.dart';
import 'package:CeylonPepper/features/market_forecast/navigation.dart';
import '../../widgets/bottom_navigation.dart';
import '../disease_detection/screens/home_screen.dart';
import '../disease_detection/services/weather_service.dart';
import '../disease_detection/services/location_service.dart';
import '../../services/auth_service.dart';
import '../../utils/responsive.dart';
import '../auth/login_page.dart';
import '../marketplace/marketplace_screen.dart';
import '../quality_grading/screens/quality_grading_dashboard.dart';
import '../chatbot/chatbot_screen.dart';
import '../yield_prediction/screens/harvest_prediction_dashboard.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final AuthService _authService = AuthService();
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();

  bool _isLoadingWeather = true;
  String _locationName = 'Loading...';
  String _temperature = '--°C';
  String _weatherCondition = 'clear';

  // Mock data for dashboard statistics
  int _totalCrops = 0;
  int _activeAlerts = 0;
  double _avgQuality = 0.0;

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
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();

    // Load initial data
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _fetchWeatherData();
        _loadDashboardStats();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardStats() async {
    // Simulate loading dashboard statistics
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _totalCrops = 5; // Mock data - replace with actual data
        _activeAlerts = 2;
        _avgQuality = 87.5;
      });
    }
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoadingWeather = true;
      _locationName = 'Loading...';
      _temperature = '--°C';
    });

    try {
      final locationData = await _locationService.getCurrentLocation().timeout(
        const Duration(seconds: 30),
        onTimeout: () => null,
      );

      double lat = 6.9271; // Colombo fallback
      double lon = 79.8612;

      if (locationData != null) {
        lat = locationData.latitude;
        lon = locationData.longitude;
      }

      if (!mounted) return;

      final weatherData = await _weatherService
          .getWeatherData(lat, lon)
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () => null,
      );

      if (weatherData != null && mounted) {
        final parsedData = _weatherService.parseWeatherData(weatherData);
        if (parsedData != null) {
          setState(() {
            _locationName = locationData == null
                ? '${parsedData['location']} (Default)'
                : parsedData['location'] ?? 'Unknown';
            _temperature = '${parsedData['temperature']}°C';
            _weatherCondition = parsedData['condition']?.toLowerCase() ?? 'clear';
            _isLoadingWeather = false;
          });
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        _isLoadingWeather = false;
        _locationName = locationData == null ? 'Enable GPS' : 'Weather Error';
        _temperature = '--°C';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingWeather = false;
        _locationName = 'Error';
        _temperature = '--°C';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final primary = const Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: () async {
              await _fetchWeatherData();
              await _loadDashboardStats();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced Header with Weather
                  _buildHeader(responsive, primary),

                  ResponsiveSpacing(mobile: 20, tablet: 24, desktop: 28),

                  // Quick Stats Cards
                  _buildQuickStats(responsive, primary),

                  ResponsiveSpacing(mobile: 24, tablet: 28, desktop: 32),

                  // Section: Main Features
                  _buildSectionTitle(
                    responsive,
                    primary,
                    "Smart Farming Tools",
                    Icons.agriculture_rounded,
                  ),

                  ResponsiveSpacing(mobile: 16, tablet: 20, desktop: 24),

                  // Main Feature Grid
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildMainFeatureGrid(context, responsive, primary),
                  ),

                  ResponsiveSpacing(mobile: 32, tablet: 40, desktop: 48),

                  // Section: Additional Features
                  _buildSectionTitle(
                    responsive,
                    primary,
                    "More Services",
                    Icons.dashboard_customize_rounded,
                  ),

                  ResponsiveSpacing(mobile: 16, tablet: 20, desktop: 24),

                  // Additional Features
                  _buildAdditionalFeatures(context, responsive, primary),

                  ResponsiveSpacing(mobile: 32, tablet: 40, desktop: 48),

                  // Recommended Tips Section
                  _buildSectionTitle(
                    responsive,
                    primary,
                    "Farming Tips & Insights",
                    Icons.lightbulb_rounded,
                    iconColor: Colors.amber[700],
                  ),

                  ResponsiveSpacing(mobile: 16, tablet: 20, desktop: 24),

                  _buildTipsSection(responsive),

                  ResponsiveSpacing(mobile: 24, tablet: 32, desktop: 40),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 0,
        onTabSelected: (index) {
          if (index != 0) {
            // Handle navigation
          }
        },
      ),
    );
  }

  Widget _buildHeader(Responsive responsive, Color primary) {
    return Container(
      padding: responsive.padding(
        mobile: const EdgeInsets.fromLTRB(24, 20, 24, 30),
        tablet: const EdgeInsets.fromLTRB(32, 24, 32, 36),
        desktop: const EdgeInsets.fromLTRB(40, 28, 40, 42),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withOpacity(0.85)],
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, Farmer 👋",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: responsive.bodyFontSize,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    ResponsiveSpacing(mobile: 4, tablet: 6, desktop: 8),
                    Text(
                      "Ceylon Pepper",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive.fontSize(
                          mobile: 24,
                          tablet: 26,
                          desktop: 30,
                        ),
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Container(
                  padding: EdgeInsets.all(
                    responsive.value(mobile: 2, tablet: 3, desktop: 4),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: responsive.value(mobile: 22, tablet: 24, desktop: 28),
                    backgroundColor: primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person_rounded,
                      color: primary,
                      size: responsive.value(mobile: 24, tablet: 26, desktop: 30),
                    ),
                  ),
                ),
                onSelected: (value) async {
                  if (value == 'logout') {
                    await _authService.logout();
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, size: 20),
                        SizedBox(width: 12),
                        Text("Profile"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings_outlined, size: 20),
                        SizedBox(width: 12),
                        Text("Settings"),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red, size: 20),
                        SizedBox(width: 12),
                        Text("Logout", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          ResponsiveSpacing(mobile: 20, tablet: 24, desktop: 28),
          // Weather Widget
          GestureDetector(
            onTap: _fetchWeatherData,
            child: Container(
              padding: responsive.padding(
                mobile: const EdgeInsets.all(16),
                tablet: const EdgeInsets.all(18),
                desktop: const EdgeInsets.all(20),
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(
                  responsive.value(mobile: 16, tablet: 18, desktop: 20),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: Colors.white.withOpacity(0.95),
                    size: responsive.smallIconSize,
                  ),
                  ResponsiveSpacing.horizontal(mobile: 10, tablet: 12, desktop: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isLoadingWeather ? 'Fetching location...' : _locationName,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: responsive.bodyFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!_isLoadingWeather)
                          Text(
                            'Tap to refresh',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: responsive.fontSize(
                                mobile: 12,
                                tablet: 13,
                                desktop: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_isLoadingWeather)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          _getWeatherIcon(),
                          color: Colors.white,
                          size: responsive.mediumIconSize,
                        ),
                        ResponsiveSpacing.horizontal(
                          mobile: 8,
                          tablet: 10,
                          desktop: 12,
                        ),
                        Text(
                          _temperature,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: responsive.titleFontSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon() {
    if (_weatherCondition.contains('rain')) return Icons.water_drop_rounded;
    if (_weatherCondition.contains('cloud')) return Icons.cloud_rounded;
    if (_weatherCondition.contains('sun') || _weatherCondition.contains('clear')) {
      return Icons.wb_sunny_rounded;
    }
    return Icons.cloud_outlined;
  }

  Widget _buildQuickStats(Responsive responsive, Color primary) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
      child: ResponsiveBuilder(
        mobile: _buildStatsRow(responsive, primary),
        tablet: _buildStatsRow(responsive, primary),
        desktop: _buildStatsRow(responsive, primary),
      ),
    );
  }

  Widget _buildStatsRow(Responsive responsive, Color primary) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            responsive,
            "Total Crops",
            _totalCrops.toString(),
            Icons.grass_rounded,
            Color(0xFF43A047),
            Color(0xFFE8F5E9),
          ),
        ),
        ResponsiveSpacing.horizontal(mobile: 12, tablet: 16, desktop: 20),
        Expanded(
          child: _buildStatCard(
            responsive,
            "Active Alerts",
            _activeAlerts.toString(),
            Icons.notification_important_rounded,
            Color(0xFF2E7D32),
            Color(0xFFE8F5E9),
          ),
        ),
        ResponsiveSpacing.horizontal(mobile: 12, tablet: 16, desktop: 20),
        Expanded(
          child: _buildStatCard(
            responsive,
            "Avg Quality",
            "${_avgQuality.toStringAsFixed(1)}%",
            Icons.verified_rounded,
            Color(0xFF66BB6A),
            Color(0xFFE8F5E9),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      Responsive responsive,
      String label,
      String value,
      IconData icon,
      Color iconColor,
      Color bgColor,
      ) {
    return Container(
      padding: responsive.padding(
        mobile: const EdgeInsets.all(16),
        tablet: const EdgeInsets.all(18),
        desktop: const EdgeInsets.all(20),
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
        children: [
          Container(
            padding: EdgeInsets.all(
              responsive.value(mobile: 8, tablet: 10, desktop: 12),
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: responsive.mediumIconSize),
          ),
          ResponsiveSpacing(mobile: 8, tablet: 10, desktop: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.titleFontSize,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          ResponsiveSpacing(mobile: 2, tablet: 4, desktop: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: responsive.fontSize(mobile: 12, tablet: 13, desktop: 14),
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      Responsive responsive,
      Color primary,
      String title,
      IconData icon, {
        Color? iconColor,
      }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
      child: Row(
        children: [
          Container(
            width: responsive.value(mobile: 4, tablet: 5, desktop: 6),
            height: responsive.value(mobile: 22, tablet: 24, desktop: 26),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ResponsiveSpacing.horizontal(mobile: 12, tablet: 14, desktop: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: responsive.headingFontSize,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          Icon(
            icon,
            color: iconColor ?? primary,
            size: responsive.mediumIconSize,
          ),
        ],
      ),
    );
  }

  Widget _buildMainFeatureGrid(
      BuildContext context,
      Responsive responsive,
      Color primary,
      ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
      child: ResponsiveBuilder(
        mobile: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.95,
          physics: const NeverScrollableScrollPhysics(),
          children: _buildMainFeatureCards(context, responsive),
        ),
        tablet: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          childAspectRatio: 1.0,
          physics: const NeverScrollableScrollPhysics(),
          children: _buildMainFeatureCards(context, responsive),
        ),
        desktop: GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          crossAxisSpacing: 22,
          mainAxisSpacing: 22,
          childAspectRatio: 0.95,
          physics: const NeverScrollableScrollPhysics(),
          children: _buildMainFeatureCards(context, responsive),
        ),
      ),
    );
  }

  List<Widget> _buildMainFeatureCards(BuildContext context, Responsive responsive) {
    return [
       _featureCard(
        context,
        responsive,
        title: "Yield\nPrediction",
        subtitle: "Forecast harvest",
        icon: Icons.analytics_rounded,
        gradient: LinearGradient(
          colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HarvestPredictionDashboard(),
            ),
          );
        },
      ),
      _featureCard(
        context,
        responsive,
        title: "Disease\nDetection",
        subtitle: "AI diagnosis",
        icon: Icons.biotech_rounded,
        gradient: LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        },
      ),
      _featureCard(
        context,
        responsive,
        title: "Quality\nGrading",
        subtitle: "ISO standards",
        icon: Icons.verified_rounded,
        gradient: LinearGradient(
          colors: [Color(0xFF81C784), Color(0xFF66BB6A)],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const QualityGradingDashboard()),
          );
        },
      ),
      _featureCard(
        context,
        responsive,
        title: "Market\nForecast",
        subtitle: "Price trends",
        icon: Icons.trending_up_rounded,
        gradient: LinearGradient(
          colors: [Color(0xFF388E3C), Color(0xFF2E7D32)],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PriceNavigation()),
          );
        },
      ),
    ];
  }

  Widget _buildAdditionalFeatures(
      BuildContext context,
      Responsive responsive,
      Color primary,
      ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _secondaryFeatureCard(
                  context,
                  responsive,
                  "AI Assistant",
                  Icons.smart_toy_rounded,
                  Color(0xFF43A047),
                  Color(0xFFE8F5E9),
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatbotScreen()),
                    );
                  },
                ),
              ),
              ResponsiveSpacing.horizontal(mobile: 14, tablet: 18, desktop: 22),
              Expanded(
                child: _secondaryFeatureCard(
                  context,
                  responsive,
                  "Marketplace",
                  Icons.store_rounded,
                  Color(0xFF2E7D32),
                  Color(0xFFE8F5E9),
                   () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MarketplaceScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _secondaryFeatureCard(
      BuildContext context,
      Responsive responsive,
      String title,
      IconData icon,
      Color iconColor,
      Color bgColor,
      VoidCallback onTap,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          responsive.value(mobile: 16, tablet: 18, desktop: 20),
        ),
        child: Container(
          padding: responsive.padding(
            mobile: const EdgeInsets.all(20),
            tablet: const EdgeInsets.all(22),
            desktop: const EdgeInsets.all(24),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              responsive.value(mobile: 16, tablet: 18, desktop: 20),
            ),
            border: Border.all(color: bgColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  responsive.value(mobile: 12, tablet: 14, desktop: 16),
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: responsive.mediumIconSize,
                ),
              ),
              ResponsiveSpacing.horizontal(mobile: 12, tablet: 14, desktop: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: responsive.bodyFontSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                      ),
                    ),
                    ResponsiveSpacing(mobile: 2, tablet: 3, desktop: 4),
                    Row(
                      children: [
                        Text(
                          "Explore",
                          style: TextStyle(
                            fontSize: responsive.fontSize(
                              mobile: 12,
                              tablet: 13,
                              desktop: 14,
                            ),
                            color: iconColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ResponsiveSpacing.horizontal(
                          mobile: 4,
                          tablet: 5,
                          desktop: 6,
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: iconColor,
                          size: responsive.value(
                            mobile: 14,
                            tablet: 15,
                            desktop: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureCard(
      BuildContext context,
      Responsive responsive, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Gradient gradient,
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          responsive.value(mobile: 20, tablet: 22, desktop: 24),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(
              responsive.value(mobile: 20, tablet: 22, desktop: 24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -15,
                bottom: -15,
                child: Icon(
                  icon,
                  size: responsive.value(mobile: 80, tablet: 90, desktop: 100),
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
              Padding(
                padding: responsive.padding(
                  mobile: const EdgeInsets.all(18),
                  tablet: const EdgeInsets.all(20),
                  desktop: const EdgeInsets.all(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: responsive.padding(
                        mobile: const EdgeInsets.all(10),
                        tablet: const EdgeInsets.all(12),
                        desktop: const EdgeInsets.all(14),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: responsive.value(mobile: 28, tablet: 32, desktop: 36),
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: responsive.titleFontSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    ResponsiveSpacing(mobile: 4, tablet: 5, desktop: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: responsive.fontSize(
                          mobile: 12,
                          tablet: 13,
                          desktop: 14,
                        ),
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    ResponsiveSpacing(mobile: 8, tablet: 10, desktop: 12),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white.withOpacity(0.9),
                      size: responsive.smallIconSize,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipsSection(Responsive responsive) {
    return SizedBox(
      height: responsive.value(mobile: 145, tablet: 165, desktop: 185),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
        children: [
          _tipCard(
            "Monitor soil moisture regularly",
            Icons.water_drop_rounded,
            Colors.blue.shade50,
            Colors.blue.shade700,
            responsive,
          ),
          _tipCard(
            "Apply organic fertilizers monthly",
            Icons.eco_rounded,
            Colors.green.shade50,
            Colors.green.shade700,
            responsive,
          ),
          _tipCard(
            "Check for pest damage daily",
            Icons.bug_report_rounded,
            Colors.red.shade50,
            Colors.red.shade700,
            responsive,
          ),
          _tipCard(
            "Maintain proper plant spacing",
            Icons.space_dashboard_rounded,
            Colors.purple.shade50,
            Colors.purple.shade700,
            responsive,
          ),
          _tipCard(
            "Harvest at optimal maturity",
            Icons.calendar_today_rounded,
            Colors.orange.shade50,
            Colors.orange.shade700,
            responsive,
          ),
        ],
      ),
    );
  }

  Widget _tipCard(
      String text,
      IconData icon,
      Color bgColor,
      Color iconColor,
      Responsive responsive,
      ) {
    return Container(
      margin: EdgeInsets.only(
        right: responsive.value(mobile: 14, tablet: 16, desktop: 18),
      ),
      padding: responsive.padding(
        mobile: const EdgeInsets.all(18),
        tablet: const EdgeInsets.all(20),
        desktop: const EdgeInsets.all(24),
      ),
      width: responsive.value(mobile: 210, tablet: 230, desktop: 250),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(
          responsive.value(mobile: 18, tablet: 20, desktop: 22),
        ),
        border: Border.all(color: iconColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: responsive.padding(
              mobile: const EdgeInsets.all(10),
              tablet: const EdgeInsets.all(11),
              desktop: const EdgeInsets.all(12),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: responsive.mediumIconSize,
            ),
          ),
          ResponsiveSpacing(mobile: 12, tablet: 14, desktop: 16),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: responsive.bodyFontSize,
              color: Colors.grey[800],
              height: 1.35,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}