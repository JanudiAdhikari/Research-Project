import 'package:CeylonPepper/features/market_forecast/weekly_price_forecast.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/responsive.dart';
import '../auth/login_page.dart';

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final primary = const Color(0xFF2E7D32);
    final lightGreen = const Color(0xFFE8F5E9);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced Header
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
                                  MaterialPageRoute(builder: (_) => const LoginPage()),
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
          // TODO: Navigate to disease detection
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
            MaterialPageRoute(builder: (context) => WeeklyPriceForecast()),
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
}
