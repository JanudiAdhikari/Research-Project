import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_page.dart';
import '../../utils/responsive.dart';

class OnboardingScreenFour extends StatefulWidget {
  const OnboardingScreenFour({super.key});

  @override
  State<OnboardingScreenFour> createState() => _OnboardingScreenFourState();
}

class _OnboardingScreenFourState extends State<OnboardingScreenFour>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final primary = const Color(0xFF2E7D32);
    final lightGreen = const Color(0xFFE8F5E9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.pagePadding,
                  ),
                  child: Column(
                    children: [
                      ResponsiveSpacing(
                        mobile: 12,
                        tablet: 16,
                        desktop: 20,
                      ),

                      // Back button only (no skip on last screen)
                      Align(
                        alignment: Alignment.topLeft,
                        child: SizedBox(
                          width: responsive.value(
                            mobile: 44,
                            tablet: 48,
                            desktop: 52,
                          ),
                          height: responsive.value(
                            mobile: 44,
                            tablet: 48,
                            desktop: 52,
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back_ios_rounded,
                              color: primary,
                              size: responsive.value(
                                mobile: 20,
                                tablet: 22,
                                desktop: 24,
                              ),
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: lightGreen,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),

                      ResponsiveSpacing(
                        mobile: 5,
                        tablet: 10,
                        desktop: 15,
                      ),

                      // Animated content
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              // Title
                              Text(
                                "Market Prices &",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: responsive.fontSize(
                                    mobile: 26,
                                    tablet: 32,
                                    desktop: 42,
                                  ),
                                  fontWeight: FontWeight.w300,
                                  color: Colors.black87,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [primary, primary.withOpacity(0.7)],
                                ).createShader(bounds),
                                child: Text(
                                  "Traceability",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: responsive.fontSize(
                                      mobile: 30,
                                      tablet: 36,
                                      desktop: 48,
                                    ),
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),

                              ResponsiveSpacing(
                                mobile: 30,
                                tablet: 50,
                                desktop: 70,
                              ),

                              // Illustration with decorative circle
                              ScaleTransition(
                                scale: _scaleAnimation,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: responsive.value(
                                        mobile: 220,
                                        tablet: 280,
                                        desktop: 360,
                                      ),
                                      height: responsive.value(
                                        mobile: 220,
                                        tablet: 280,
                                        desktop: 360,
                                      ),
                                      decoration: BoxDecoration(
                                        color: lightGreen,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Image.asset(
                                      "assets/images/onboarding/onboard4.png",
                                      height: responsive.value(
                                        mobile: 180,
                                        tablet: 240,
                                        desktop: 310,
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                ),
                              ),

                              ResponsiveSpacing(
                                mobile: 30,
                                tablet: 50,
                                desktop: 70,
                              ),

                              // Subtitle
                              Padding(
                                padding: responsive.padding(
                                  mobile: const EdgeInsets.symmetric(horizontal: 10),
                                  tablet: const EdgeInsets.symmetric(horizontal: 20),
                                  desktop: const EdgeInsets.symmetric(horizontal: 40),
                                ),
                                child: Text(
                                  "Get weekly pepper prices, forecast market trends, and analyze blockchain to gain trust",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: responsive.fontSize(
                                      mobile: 14,
                                      tablet: 16,
                                      desktop: 20,
                                    ),
                                    height: 1.6,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      ResponsiveSpacing(
                        mobile: 30,
                        tablet: 40,
                        desktop: 50,
                      ),

                      // Bottom section
                      Column(
                        children: [
                          // Dot indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildDot(false, primary, responsive),
                              ResponsiveSpacing.horizontal(
                                mobile: 6,
                                tablet: 8,
                                desktop: 10,
                              ),
                              _buildDot(false, primary, responsive),
                              ResponsiveSpacing.horizontal(
                                mobile: 6,
                                tablet: 8,
                                desktop: 10,
                              ),
                              _buildDot(false, primary, responsive),
                              ResponsiveSpacing.horizontal(
                                mobile: 6,
                                tablet: 8,
                                desktop: 10,
                              ),
                              _buildDot(true, primary, responsive),
                            ],
                          ),

                          ResponsiveSpacing(
                            mobile: 30,
                            tablet: 40,
                            desktop: 50,
                          ),

                          // Get Started button with enhanced styling
                          Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              maxWidth: responsive.maxContentWidth,
                            ),
                            height: responsive.buttonHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                responsive.buttonHeight / 2,
                              ),
                              gradient: LinearGradient(
                                colors: [primary, primary.withOpacity(0.8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withOpacity(0.4),
                                  blurRadius: responsive.value(
                                    mobile: 20,
                                    tablet: 25,
                                    desktop: 30,
                                  ),
                                  offset: Offset(
                                    0,
                                    responsive.value(
                                      mobile: 10,
                                      tablet: 12,
                                      desktop: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setBool("seenOnboarding", true);

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginPage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    responsive.buttonHeight / 2,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Get Started",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: responsive.fontSize(
                                        mobile: 16,
                                        tablet: 17,
                                        desktop: 19,
                                      ),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  ResponsiveSpacing.horizontal(
                                    mobile: 6,
                                    tablet: 8,
                                    desktop: 10,
                                  ),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: responsive.iconSize(
                                      mobile: 18,
                                      tablet: 20,
                                      desktop: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          ResponsiveSpacing(
                            mobile: 30,
                            tablet: 40,
                            desktop: 50,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDot(bool active, Color primary, Responsive responsive) {
    final activeWidth = responsive.value(mobile: 20, tablet: 24, desktop: 32);
    final inactiveWidth = responsive.value(mobile: 7, tablet: 8, desktop: 10);
    final height = responsive.value(mobile: 7, tablet: 8, desktop: 10);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? activeWidth : inactiveWidth,
      height: height,
      decoration: BoxDecoration(
        color: active ? primary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}