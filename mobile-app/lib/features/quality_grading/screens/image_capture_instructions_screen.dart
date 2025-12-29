import 'package:flutter/material.dart';
import '../../../utils/responsive.dart';

class InstructionsScreen extends StatefulWidget {
  const InstructionsScreen({super.key});

  @override
  State<InstructionsScreen> createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends State<InstructionsScreen>
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
          'Capture Guide',
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
              // Header Section
              Container(
                width: double.infinity,
                padding: responsive.padding(
                  mobile: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  tablet: const EdgeInsets.fromLTRB(32, 28, 32, 36),
                  desktop: const EdgeInsets.fromLTRB(40, 32, 40, 40),
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
                  children: [
                    Container(
                      padding: responsive.padding(
                        mobile: const EdgeInsets.all(16),
                        tablet: const EdgeInsets.all(18),
                        desktop: const EdgeInsets.all(20),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.photo_camera_rounded,
                        color: Colors.white,
                        size: responsive.value(
                          mobile: 48,
                          tablet: 56,
                          desktop: 64,
                        ),
                      ),
                    ),
                    ResponsiveSpacing(mobile: 16, tablet: 18, desktop: 20),
                    Text(
                      "Perfect Photo Tips",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive.fontSize(
                          mobile: 24,
                          tablet: 26,
                          desktop: 28,
                        ),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    ResponsiveSpacing(mobile: 8, tablet: 10, desktop: 12),
                    Text(
                      "Follow these guidelines for accurate quality analysis",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: responsive.bodyFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              ResponsiveSpacing(mobile: 24, tablet: 28, desktop: 32),

              // Content
              SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.pagePadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Essential Guidelines Section
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
                            "Essential Guidelines",
                            style: TextStyle(
                              fontSize: responsive.headingFontSize,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),

                      ResponsiveSpacing(mobile: 20, tablet: 24, desktop: 28),

                      // Guideline Cards
                      _buildGuidelineCard(
                        responsive,
                        icon: Icons.image_outlined,
                        title: "Plain Background",
                        description: "Use a solid, contrasting background (white or light-colored works best)",
                        color: Colors.blue,
                      ),

                      _buildGuidelineCard(
                        responsive,
                        icon: Icons.wb_sunny_rounded,
                        title: "Good Lighting",
                        description: "Ensure bright, even lighting from multiple angles to capture true colors",
                        color: Colors.orange,
                      ),

                      _buildGuidelineCard(
                        responsive,
                        icon: Icons.block_rounded,
                        title: "Avoid Shadows",
                        description: "Position lighting to minimize shadows on the pepper samples",
                        color: Colors.red,
                      ),

                      _buildGuidelineCard(
                        responsive,
                        icon: Icons.videocam_rounded,
                        title: "Keep Camera Steady",
                        description: "Hold your device steady or use a stand to avoid blurry images",
                        color: Colors.purple,
                      ),

                      _buildGuidelineCard(
                        responsive,
                        icon: Icons.zoom_out_map_rounded,
                        title: "Three View Types",
                        description: "Capture Full view, Half view, and Close-up for each layer",
                        color: Colors.teal,
                      ),

                      ResponsiveSpacing(mobile: 28, tablet: 32, desktop: 36),

                      // View Types Section
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
                            "View Types Explained",
                            style: TextStyle(
                              fontSize: responsive.headingFontSize,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),

                      ResponsiveSpacing(mobile: 16, tablet: 18, desktop: 20),

                      // View Type Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildViewTypeCard(
                              responsive,
                              icon: Icons.crop_free_rounded,
                              title: "Full View",
                              description: "Capture entire sample spread",
                              color: Colors.green,
                            ),
                          ),
                          ResponsiveSpacing.horizontal(
                            mobile: 12,
                            tablet: 14,
                            desktop: 16,
                          ),
                          Expanded(
                            child: _buildViewTypeCard(
                              responsive,
                              icon: Icons.crop_square_rounded,
                              title: "Half View",
                              description: "Focus on half portion",
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),

                      ResponsiveSpacing(mobile: 12, tablet: 14, desktop: 16),

                      _buildViewTypeCard(
                        responsive,
                        icon: Icons.zoom_in_rounded,
                        title: "Close-up",
                        description: "Detailed view of individual pepper corns",
                        color: Colors.purple,
                      ),

                      ResponsiveSpacing(mobile: 28, tablet: 32, desktop: 36),

                      // Pro Tips Card
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
                                    Icons.tips_and_updates_rounded,
                                    color: Colors.amber.shade700,
                                    size: responsive.mediumIconSize,
                                  ),
                                ),
                                ResponsiveSpacing.horizontal(
                                  mobile: 12,
                                  tablet: 14,
                                  desktop: 16,
                                ),
                                Expanded(
                                  child: Text(
                                    "Quick Tips",
                                    style: TextStyle(
                                      fontSize: responsive.titleFontSize,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ResponsiveSpacing(mobile: 16, tablet: 18, desktop: 20),
                            _buildTipItem(
                              responsive,
                              "Natural daylight works best",
                            ),
                            _buildTipItem(
                              responsive,
                              "Clean lens before capturing",
                            ),
                            _buildTipItem(
                              responsive,
                              "Spread pepper evenly on surface",
                            ),
                            _buildTipItem(
                              responsive,
                              "Take multiple shots if unsure",
                            ),
                          ],
                        ),
                      ),

                      ResponsiveSpacing(mobile: 24, tablet: 28, desktop: 32),

                      // Demo Video Card
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
                                  mobile: 12,
                                  tablet: 14,
                                  desktop: 16,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.play_circle_outline_rounded,
                                color: Colors.purple.shade700,
                                size: responsive.value(
                                  mobile: 32,
                                  tablet: 36,
                                  desktop: 40,
                                ),
                              ),
                            ),
                            ResponsiveSpacing.horizontal(
                              mobile: 16,
                              tablet: 18,
                              desktop: 20,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Video Tutorial",
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
                                    "Watch a demo video when internet is available (Coming soon)",
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
                                "Got It, Let's Capture",
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

  Widget _buildGuidelineCard(
      Responsive responsive, {
        required IconData icon,
        required String title,
        required String description,
        required Color color,
      }) {
    return Container(
      margin: EdgeInsets.only(
        bottom: responsive.value(mobile: 16, tablet: 18, desktop: 20),
      ),
      padding: responsive.padding(
        mobile: const EdgeInsets.all(16),
        tablet: const EdgeInsets.all(18),
        desktop: const EdgeInsets.all(20),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            padding: EdgeInsets.all(
              responsive.value(mobile: 10, tablet: 11, desktop: 12),
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: responsive.mediumIconSize,
            ),
          ),
          ResponsiveSpacing.horizontal(mobile: 14, tablet: 16, desktop: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: responsive.titleFontSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                ResponsiveSpacing(mobile: 6, tablet: 7, desktop: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: responsive.bodyFontSize - 1,
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

  Widget _buildViewTypeCard(
      Responsive responsive, {
        required IconData icon,
        required String title,
        required String description,
        required Color color,
      }) {
    return Container(
      padding: responsive.padding(
        mobile: const EdgeInsets.all(16),
        tablet: const EdgeInsets.all(18),
        desktop: const EdgeInsets.all(20),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(
              responsive.value(mobile: 10, tablet: 11, desktop: 12),
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: responsive.mediumIconSize,
            ),
          ),
          ResponsiveSpacing(mobile: 12, tablet: 14, desktop: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: responsive.titleFontSize - 1,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          ResponsiveSpacing(mobile: 6, tablet: 7, desktop: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: responsive.bodyFontSize - 2,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(Responsive responsive, String text) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: responsive.value(mobile: 8, tablet: 9, desktop: 10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Colors.amber.shade700,
            size: responsive.value(mobile: 16, tablet: 17, desktop: 18),
          ),
          ResponsiveSpacing.horizontal(mobile: 10, tablet: 11, desktop: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: responsive.bodyFontSize - 1,
                color: Colors.amber.shade900,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}