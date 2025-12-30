import 'package:flutter/material.dart';
import '../../../utils/responsive.dart';

class BulkDensityInstructionsScreen extends StatefulWidget {
  const BulkDensityInstructionsScreen({super.key});

  @override
  State<BulkDensityInstructionsScreen> createState() =>
      _BulkDensityInstructionsScreenState();
}

class _BulkDensityInstructionsScreenState
    extends State<BulkDensityInstructionsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
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
    const primary = Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Measurement Guide',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ResponsiveSpacing(mobile: 24, tablet: 28, desktop: 32),

              // Instructions Content
              SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.pagePadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Header
                      Row(
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
                            "Measurement Steps",
                            style: TextStyle(
                              fontSize: responsive.headingFontSize,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),

                      ResponsiveSpacing(mobile: 20, tablet: 24, desktop: 28),

                      // Step Cards
                      _buildStepCard(
                        responsive,
                        primary,
                        stepNumber: 1,
                        title: "Prepare the Container",
                        description: "Fill the measuring container with dried pepper samples",
                        icon: Icons.inbox_rounded,
                        iconColor: Colors.blue,
                      ),

                      _buildStepCard(
                        responsive,
                        primary,
                        stepNumber: 2,
                        title: "Level the Surface",
                        description: "Level the surface without compressing the pepper",
                        icon: Icons.straighten_rounded,
                        iconColor: Colors.orange,
                      ),

                      _buildStepCard(
                        responsive,
                        primary,
                        stepNumber: 3,
                        title: "Place on Device",
                        description: "Place the container on the IoT weighing device",
                        icon: Icons.sensors_rounded,
                        iconColor: Colors.purple,
                      ),

                      _buildStepCard(
                        responsive,
                        primary,
                        stepNumber: 4,
                        title: "Wait for Stability",
                        description: "Wait until the measurement value stabilizes",
                        icon: Icons.hourglass_empty_rounded,
                        iconColor: Colors.teal,
                      ),

                      _buildStepCard(
                        responsive,
                        primary,
                        stepNumber: 5,
                        title: "Record the Value",
                        description: "Record the bulk density value shown on the display",
                        icon: Icons.check_circle_rounded,
                        iconColor: Colors.green,
                      ),

                      ResponsiveSpacing(mobile: 28, tablet: 32, desktop: 36),

                      // Pro Tip Card
                      Container(
                        padding: responsive.padding(
                          mobile: const EdgeInsets.all(20),
                          tablet: const EdgeInsets.all(24),
                          desktop: const EdgeInsets.all(28),
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade50,
                              Colors.amber.shade100.withOpacity(0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.amber.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(
                                    responsive.value(
                                      mobile: 10,
                                      tablet: 11,
                                      desktop: 12,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.lightbulb_rounded,
                                    color: Colors.amber.shade700,
                                    size: responsive.mediumIconSize,
                                  ),
                                ),
                                ResponsiveSpacing.horizontal(
                                  mobile: 12,
                                  tablet: 14,
                                  desktop: 16,
                                ),
                                Text(
                                  "Pro Tip",
                                  style: TextStyle(
                                    fontSize: responsive.titleFontSize,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ],
                            ),
                            ResponsiveSpacing(mobile: 12, tablet: 14, desktop: 16),
                            Text(
                              "Higher bulk density generally indicates better pepper quality. Quality pepper typically ranges between 550-700 g/L.",
                              style: TextStyle(
                                fontSize: responsive.bodyFontSize,
                                color: Colors.amber.shade900,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      ResponsiveSpacing(mobile: 24, tablet: 28, desktop: 32),

                      // Coming Soon Card
                      Container(
                        padding: responsive.padding(
                          mobile: const EdgeInsets.all(20),
                          tablet: const EdgeInsets.all(24),
                          desktop: const EdgeInsets.all(28),
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade50,
                              Colors.purple.shade100.withOpacity(0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.purple.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(
                                responsive.value(
                                  mobile: 10,
                                  tablet: 11,
                                  desktop: 12,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.video_library_rounded,
                                color: Colors.purple.shade700,
                                size: responsive.mediumIconSize,
                              ),
                            ),
                            ResponsiveSpacing.horizontal(
                              mobile: 12,
                              tablet: 14,
                              desktop: 16,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Coming Soon",
                                    style: TextStyle(
                                      fontSize: responsive.titleFontSize,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.purple.shade900,
                                    ),
                                  ),
                                  ResponsiveSpacing(
                                    mobile: 4,
                                    tablet: 6,
                                    desktop: 8,
                                  ),
                                  Text(
                                    "Video demonstration will be available in future updates",
                                    style: TextStyle(
                                      fontSize: responsive.bodyFontSize - 1,
                                      color: Colors.purple.shade800,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      ResponsiveSpacing(mobile: 32, tablet: 40, desktop: 48),

                      // Got It Button
                      Container(
                        width: double.infinity,
                        height: responsive.buttonHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: responsive.smallIconSize,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Got It",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: responsive.titleFontSize,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      ResponsiveSpacing(mobile: 32, tablet: 40, desktop: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(
      Responsive responsive,
      Color primary, {
        required int stepNumber,
        required String title,
        required String description,
        required IconData icon,
        required Color iconColor,
      }) {
    return Container(
      margin: EdgeInsets.only(
        bottom: responsive.value(mobile: 16, tablet: 18, desktop: 20),
      ),
      padding: responsive.padding(
        mobile: const EdgeInsets.all(18),
        tablet: const EdgeInsets.all(20),
        desktop: const EdgeInsets.all(24),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Number Badge
          Container(
            width: responsive.value(mobile: 40, tablet: 44, desktop: 48),
            height: responsive.value(mobile: 40, tablet: 44, desktop: 48),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                "$stepNumber",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsive.titleFontSize + 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          ResponsiveSpacing.horizontal(mobile: 16, tablet: 18, desktop: 20),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        responsive.value(mobile: 6, tablet: 7, desktop: 8),
                      ),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: responsive.smallIconSize,
                      ),
                    ),
                    ResponsiveSpacing.horizontal(
                      mobile: 10,
                      tablet: 12,
                      desktop: 14,
                    ),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: responsive.titleFontSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                ResponsiveSpacing(mobile: 8, tablet: 10, desktop: 12),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: responsive.bodyFontSize,
                    color: Colors.grey[700],
                    height: 1.5,
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