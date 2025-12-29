import 'package:CeylonPepper/features/market_forecast/navigation.dart';
import 'package:flutter/material.dart';
import '../disease_detection/screens/home_screen.dart';
import '../disease_detection/services/weather_service.dart';
import '../disease_detection/services/location_service.dart';
import '../../services/auth_service.dart';
import '../../utils/responsive.dart';
import '../auth/login_page.dart';
import '../chatbot/chatbot_screen.dart';

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

  @override
  void initState() {
    super.initState();

    print('🚀 FarmerDashboard initState called');
    print('Initial state: loading=$_isLoadingWeather, location=$_locationName, temp=$_temperature');

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

    print('⏰ Scheduling _fetchWeatherData() to run after build');
    // Delay weather fetch to ensure widget is built
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        print('✅ Widget is mounted, calling _fetchWeatherData()');
        _fetchWeatherData();
      } else {
        print('❌ Widget not mounted, skipping weather fetch');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeatherData() async {
    print('🌤️ Starting weather fetch...');
    print('Current state BEFORE: loading=$_isLoadingWeather, location=$_locationName');

    // Force update to show we're loading
    setState(() {
      _isLoadingWeather = true;
      _locationName = 'Loading...';
      _temperature = '--°C';
    });
    print('State set to loading=true');

    try {
      print('📍 Getting location... (30 second timeout)');
      final locationData = await _locationService.getCurrentLocation()
          .timeout(const Duration(seconds: 30), onTimeout: () {
        print('⏱️ Location fetch timeout after 30 seconds');
        return null;
      });

      if (locationData == null) {
        print('❌ Location is null - Using fallback location (Colombo)');
        // Use Colombo, Sri Lanka as fallback
        final fallbackLat = 6.9271;
        final fallbackLon = 79.8612;

        if (!mounted) return;

        print('🌐 Fetching weather data for fallback location...');
        final weatherData = await _weatherService.getWeatherData(
          fallbackLat,
          fallbackLon,
        ).timeout(const Duration(seconds: 15), onTimeout: () {
          print('⏱️ Weather API timeout');
          return null;
        });

        if (weatherData != null) {
          final parsedData = _weatherService.parseWeatherData(weatherData);
          if (parsedData != null && mounted) {
            setState(() {
              _locationName = '${parsedData['location']} (Default)';
              _temperature = '${parsedData['temperature']}°C';
              _isLoadingWeather = false;
            });
            print('✅ Using fallback weather data');
            return;
          }
        }

        // If fallback also fails
        if (!mounted) return;
        setState(() {
          _isLoadingWeather = false;
          _locationName = 'Enable GPS';
          _temperature = '--°C';
        });
        print('State updated: Enable GPS');
        return;
      }

      print('✅ Location received: ${locationData.latitude}, ${locationData.longitude}');
      print('🌐 Fetching weather data...');

      final weatherData = await _weatherService.getWeatherData(
        locationData.latitude,
        locationData.longitude,
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        print('⏱️ Weather API timeout');
        return null;
      });

      print('Weather data received: $weatherData');

      if (weatherData != null) {
        print('✅ Weather data is not null');
        final parsedData = _weatherService.parseWeatherData(weatherData);
        print('Parsed data: $parsedData');

        if (!mounted) return;
        if (parsedData != null) {
          print('✅ Setting state with location: ${parsedData['location']}, temp: ${parsedData['temperature']}');
          setState(() {
            _locationName = parsedData['location'] ?? 'Unknown';
            _temperature = '${parsedData['temperature']}°C';
            _isLoadingWeather = false;
          });
          print('✅ State updated successfully - location=$_locationName, temp=$_temperature, loading=$_isLoadingWeather');
        } else {
          print('❌ Parsed data is null');
          setState(() {
            _isLoadingWeather = false;
            _locationName = 'Parse Error';
            _temperature = '--°C';
          });
        }
      } else {
        print('❌ Weather data is null');
        if (!mounted) return;
        setState(() {
          _isLoadingWeather = false;
          _locationName = 'API Error';
          _temperature = '--°C';
        });
        print('State updated: API Error');
      }
    } catch (e, stackTrace) {
      print('❌ Weather fetch error: $e');
      print('Stack trace: $stackTrace');
      if (!mounted) return;
      setState(() {
        _isLoadingWeather = false;
        _locationName = 'Error: ${e.toString().substring(0, 20)}';
        _temperature = '--°C';
      });
      print('State updated: Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final primary = const Color(0xFF2E7D32);

    print('📱 Building FarmerDashboard content - Weather loading: $_isLoadingWeather, Location: $_locationName, Temp: $_temperature');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced Header
                Container(
                  padding: EdgeInsets.fromLTRB(
                    responsive.value(mobile: 24, tablet: 32, desktop: 40),
                    MediaQuery.of(context).padding.top + responsive.value(mobile: 20, tablet: 24, desktop: 28),
                    responsive.value(mobile: 24, tablet: 32, desktop: 40),
                    responsive.value(mobile: 30, tablet: 36, desktop: 42),
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
                              ResponsiveSpacing(
                                mobile: 4,
                                tablet: 6,
                                desktop: 8,
                              ),
                              Text(
                                "Welcome Back",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: responsive.fontSize(
                                    mobile: 26,
                                    tablet: 28,
                                    desktop: 32,
                                  ),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          PopupMenuButton<String>(
                            icon: CircleAvatar(
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
                            onSelected: (value) async {
                              if (value == 'logout') {
                                await _authService.logout();

                                if (!mounted) return;

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    Icon(Icons.logout, color: Colors.red),
                                    const SizedBox(width: 10),
                                    const Text("Logout"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ResponsiveSpacing(mobile: 20, tablet: 24, desktop: 28),
                      GestureDetector(
                        onTap: () {
                          print('🔄 Manual weather refresh triggered');
                          _fetchWeatherData();
                        },
                        child: Container(
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
                                _isLoadingWeather ? 'Loading... ⏳' : _locationName,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: responsive.bodyFontSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              if (_isLoadingWeather)
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              else
                                Icon(
                                  Icons.cloud_outlined,
                                  color: Colors.white,
                                  size: responsive.smallIconSize,
                                ),
                              ResponsiveSpacing.horizontal(
                                mobile: 8,
                                tablet: 10,
                                desktop: 12,
                              ),
                              Text(
                                _isLoadingWeather ? '--°C' : _temperature,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: responsive.bodyFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                ResponsiveSpacing(mobile: 24, tablet: 28, desktop: 32),

                // Section Title
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.pagePadding,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: responsive.value(
                          mobile: 4,
                          tablet: 5,
                          desktop: 6,
                        ),
                        height: responsive.value(
                          mobile: 22,
                          tablet: 24,
                          desktop: 26,
                        ),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      ResponsiveSpacing.horizontal(
                        mobile: 12,
                        tablet: 14,
                        desktop: 16,
                      ),
                      Text(
                        "Quick Actions",
                        style: TextStyle(
                          fontSize: responsive.headingFontSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                ResponsiveSpacing(mobile: 16, tablet: 20, desktop: 24),

                // Enhanced Quick Action Grid
                SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.pagePadding,
                    ),
                    child: ResponsiveBuilder(
                      mobile: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.95,
                        physics: const NeverScrollableScrollPhysics(),
                        children: _buildFeatureCards(
                          context,
                          responsive,
                          primary,
                        ),
                      ),
                      tablet: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1.0,
                        physics: const NeverScrollableScrollPhysics(),
                        children: _buildFeatureCards(
                          context,
                          responsive,
                          primary,
                        ),
                      ),
                      desktop: GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        childAspectRatio: 0.95,
                        physics: const NeverScrollableScrollPhysics(),
                        children: _buildFeatureCards(
                          context,
                          responsive,
                          primary,
                        ),
                      ),
                    ),
                  ),
                ),

                ResponsiveSpacing(
                  mobile: 32,
                  tablet: 40,
                  desktop: 48,
                ), // Tips Section Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.pagePadding,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: responsive.value(
                          mobile: 4,
                          tablet: 5,
                          desktop: 6,
                        ),
                        height: responsive.value(
                          mobile: 22,
                          tablet: 24,
                          desktop: 26,
                        ),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      ResponsiveSpacing.horizontal(
                        mobile: 12,
                        tablet: 14,
                        desktop: 16,
                      ),
                      Text(
                        "Recommended Tips",
                        style: TextStyle(
                          fontSize: responsive.headingFontSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.lightbulb_rounded,
                        color: Colors.amber[700],
                        size: responsive.mediumIconSize,
                      ),
                    ],
                  ),
                ),

                ResponsiveSpacing(mobile: 16, tablet: 20, desktop: 24),

                // Enhanced Tips Cards
                SizedBox(
                  height: responsive.value(
                    mobile: 140,
                    tablet: 160,
                    desktop: 180,
                  ),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.pagePadding,
                    ),
                    children: [
                      _aiAssistantCard(
                        responsive,
                        primary,
                      ),
                      _tipCard(
                        "Improve drying process",
                        Icons.wb_sunny_rounded,
                        Colors.orange.shade50,
                        Colors.orange.shade700,
                        responsive,
                      ),
                      _tipCard(
                        "Prevent fungal infection",
                        Icons.shield_rounded,
                        Colors.red.shade50,
                        Colors.red.shade700,
                        responsive,
                      ),
                      _tipCard(
                        "Enhance soil nutrients",
                        Icons.eco_rounded,
                        Colors.green.shade50,
                        Colors.green.shade700,
                        responsive,
                      ),
                      _tipCard(
                        "Optimize irrigation",
                        Icons.water_drop_rounded,
                        Colors.blue.shade50,
                        Colors.blue.shade700,
                        responsive,
                      ),
                    ],
                  ),
                ),

                ResponsiveSpacing(mobile: 24, tablet: 32, desktop: 40),
              ],
            ),
          ),
        ),
      );
  }

  List<Widget> _buildFeatureCards(
    BuildContext context,
    Responsive responsive,
    Color primary,
  ) {
    return [
      _featureCard(
        context,
        responsive,
        title: "Predict\nHarvest",
        icon: Icons.analytics_rounded,
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
        ),
        onTap: () {
          // TODO: Navigate to harvest prediction
        },
      ),
      _featureCard(
        context,
        responsive,
        title: "Disease\nDetection",
        icon: Icons.biotech_rounded,
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        },
      ),
      _featureCard(
        context,
        responsive,
        title: "Quality\nGrading",
        icon: Icons.verified_rounded,
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        onTap: () {
          // TODO: Navigate to quality grading
        },
      ),
      _featureCard(
        context,
        responsive,
        title: "Market\nPrices",
        icon: Icons.trending_up_rounded,
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.purple.shade600],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PriceNavigation()),
          );
        },
      ),
    ];
  }

  Widget _featureCard(
    BuildContext context,
    Responsive responsive, {
    required String title,
    required IconData icon,
    required Gradient gradient,
    required Function onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(),
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
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: -10,
                bottom: -10,
                child: Icon(
                  icon,
                  size: responsive.value(mobile: 70, tablet: 80, desktop: 90),
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              // Content
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
                        size: responsive.value(
                          mobile: 28,
                          tablet: 32,
                          desktop: 36,
                        ),
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
                    ResponsiveSpacing(mobile: 4, tablet: 6, desktop: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white.withOpacity(0.8),
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

  Widget _tipCard(
    String text,
    IconData icon,
    Color bgColor,
    Color iconColor,
    Responsive responsive,
  ) {
    return Container(
      margin: EdgeInsets.only(
        right: responsive.value(mobile: 16, tablet: 18, desktop: 20),
      ),
      padding: responsive.padding(
        mobile: const EdgeInsets.all(18),
        tablet: const EdgeInsets.all(20),
        desktop: const EdgeInsets.all(24),
      ),
      width: responsive.value(mobile: 200, tablet: 220, desktop: 240),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(
          responsive.value(mobile: 20, tablet: 22, desktop: 24),
        ),
        border: Border.all(color: iconColor.withOpacity(0.2), width: 1),
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
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiAssistantCard(
    Responsive responsive,
    Color primary,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatbotScreen()),
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          right: responsive.value(mobile: 16, tablet: 18, desktop: 20),
        ),
        padding: responsive.padding(
          mobile: const EdgeInsets.all(14),
          tablet: const EdgeInsets.all(16),
          desktop: const EdgeInsets.all(20),
        ),
        width: responsive.value(mobile: 200, tablet: 220, desktop: 240),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1E88E5), // DeepSeek blue
              const Color(0xFF1565C0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(
            responsive.value(mobile: 20, tablet: 22, desktop: 24),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E88E5).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: responsive.padding(
                    mobile: const EdgeInsets.all(8),
                    tablet: const EdgeInsets.all(9),
                    desktop: const EdgeInsets.all(10),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.psychology_rounded,
                    color: Colors.white,
                    size: responsive.value(mobile: 20, tablet: 22, desktop: 24),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.amber[300],
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      const Text(
                        'AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ResponsiveSpacing(mobile: 8, tablet: 10, desktop: 12),
            Text(
              'Ask AI Assistant',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: responsive.value(mobile: 15, tablet: 16, desktop: 17),
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 3),
            Flexible(
              child: Text(
                'Get instant farming advice - 100% FREE!',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: responsive.value(mobile: 10, tablet: 11, desktop: 12),
                  color: Colors.white.withOpacity(0.9),
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
