import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/responsive.dart';
import '../auth/login_page.dart';
import '../onboarding/onboarding_screen_two.dart';

class OnboardingScreenOne extends StatefulWidget {
  const OnboardingScreenOne({super.key});

  @override
  State<OnboardingScreenOne> createState() => _OnboardingScreenOneState();
}

class _OnboardingScreenOneState extends State<OnboardingScreenOne>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    // Responsive sizing
    final illustrationSize = responsive.value(mobile: 280, tablet: 340, desktop: 360);
    final imageSize = responsive.value(mobile: 240, tablet: 290, desktop: 310);

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
                  padding: responsive.padding(
                    mobile: EdgeInsets.symmetric(horizontal: 24),
                    tablet: EdgeInsets.symmetric(horizontal: 48),
                  ),
                  child: Column(
                    children: [
                      ResponsiveSpacing(mobile: 16, tablet: 16),

                      // Skip button
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool("seenOnboarding", true);

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: primary,
                            padding: EdgeInsets.symmetric(
                              horizontal: responsive.spacing(mobile: 20, tablet: 24),
                              vertical: responsive.smallSpacing,
                            ),
                          ),
                          child: Text(
                            "Skip",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: responsive.bodyFontSize + 1,
                            ),
                          ),
                        ),
                      ),

                      ResponsiveSpacing(mobile: 10, tablet: 10),

                      // Animated content
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              // Title with gradient accent
                              ResponsiveText(
                                "Predict Your",
                                mobileFontSize: 32,
                                tabletFontSize: 40,
                                desktopFontSize: 42,
                                fontWeight: FontWeight.w300,
                                color: Colors.black87,
                                textAlign: TextAlign.center,
                              ),
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [primary, primary.withOpacity(0.7)],
                                ).createShader(bounds),
                                child: ResponsiveText(
                                  "Harvest",
                                  mobileFontSize: 36,
                                  tabletFontSize: 46,
                                  desktopFontSize: 48,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              ResponsiveSpacing(mobile: 50, tablet: 70),

                              // Illustration with decorative circle
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: illustrationSize,
                                    height: illustrationSize,
                                    decoration: BoxDecoration(
                                      color: lightGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Image.asset(
                                    "assets/images/onboarding/onboard1.png",
                                    height: imageSize,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),

                              ResponsiveSpacing(mobile: 50, tablet: 70),

                              // Subtitle
                              Padding(
                                padding: responsive.padding(
                                  mobile: EdgeInsets.symmetric(horizontal: 20),
                                  tablet: EdgeInsets.symmetric(horizontal: 40),
                                ),
                                child: Text(
                                  "Get harvest estimation and identify factors affecting your yield",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: responsive.titleFontSize,
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

                      ResponsiveSpacing(mobile: 40, tablet: 50),

                      // Bottom section
                      Column(
                        children: [
                          // Dot indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildDot(responsive, true, primary),
                              SizedBox(width: responsive.smallSpacing / 2),
                              _buildDot(responsive, false, primary),
                              SizedBox(width: responsive.smallSpacing / 2),
                              _buildDot(responsive, false, primary),
                              SizedBox(width: responsive.smallSpacing / 2),
                              _buildDot(responsive, false, primary),
                            ],
                          ),

                          ResponsiveSpacing(mobile: 40, tablet: 50),

                          // Next button with shadow
                          Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              maxWidth: responsive.isTablet ? 500 : double.infinity,
                            ),
                            height: responsive.buttonHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(responsive.buttonHeight / 2),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withOpacity(0.3),
                                  blurRadius: responsive.value(mobile: 20, tablet: 25),
                                  offset: Offset(0, responsive.value(mobile: 10, tablet: 12)),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const OnboardingScreenTwo(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(responsive.buttonHeight / 2),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Next",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: responsive.titleFontSize + 1,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(width: responsive.smallSpacing),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: responsive.smallIconSize,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          ResponsiveSpacing(mobile: 40, tablet: 50),
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

  Widget _buildDot(Responsive responsive, bool active, Color primary) {
    final activeWidth = responsive.value(mobile: 24, tablet: 30, desktop: 32);
    final inactiveWidth = responsive.value(mobile: 8, tablet: 9, desktop: 10);
    final height = responsive.value(mobile: 8, tablet: 9, desktop: 10);

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