import 'package:flutter/material.dart';
import '../../../utils/responsive.dart';

class ResultSummaryScreen extends StatefulWidget {
  const ResultSummaryScreen({super.key});

  @override
  State<ResultSummaryScreen> createState() => _ResultSummaryScreenState();
}

class _ResultSummaryScreenState extends State<ResultSummaryScreen>
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

    return WillPopScope(
      onWillPop: () async {
        return false;
      },

      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: primary,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Quality Report',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_rounded, color: Colors.white),
              tooltip: 'Share report',
              onPressed: () {
                // TODO: Share functionality
              },
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                ResponsiveSpacing(mobile: 24, tablet: 28, desktop: 32),

                // Main Content
                SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.pagePadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Grade Card
                        Container(
                          width: double.infinity,
                          padding: responsive.padding(
                            mobile: const EdgeInsets.all(24),
                            tablet: const EdgeInsets.all(28),
                            desktop: const EdgeInsets.all(32),
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade50,
                                Colors.green.shade100.withOpacity(0.5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.green.shade300,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: responsive.padding(
                                  mobile: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  tablet: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 10,
                                  ),
                                  desktop: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                    vertical: 12,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade700,
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.shade700.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "Premium",
                                  style: TextStyle(
                                    fontSize: responsive.fontSize(
                                      mobile: 20,
                                      tablet: 22,
                                      desktop: 24,
                                    ),
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              ResponsiveSpacing(mobile: 20, tablet: 24, desktop: 28),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    "92",
                                    style: TextStyle(
                                      fontSize: responsive.fontSize(
                                        mobile: 56,
                                        tablet: 64,
                                        desktop: 72,
                                      ),
                                      fontWeight: FontWeight.w800,
                                      color: Colors.green.shade700,
                                      height: 1,
                                    ),
                                  ),
                                  Text(
                                    " / 100",
                                    style: TextStyle(
                                      fontSize: responsive.fontSize(
                                        mobile: 24,
                                        tablet: 26,
                                        desktop: 28,
                                      ),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              ResponsiveSpacing(mobile: 8, tablet: 10, desktop: 12),
                              Text(
                                "Overall Quality Score",
                                style: TextStyle(
                                  fontSize: responsive.bodyFontSize,
                                  color: Colors.green.shade900,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        ResponsiveSpacing(mobile: 28, tablet: 32, desktop: 36),

                        // Batch Information Section
                        _buildSectionHeader(
                          responsive,
                          primary,
                          'Batch Information',
                          Icons.info_rounded,
                        ),

                        ResponsiveSpacing(mobile: 16, tablet: 18, desktop: 20),

                        Container(
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
                          child: Column(
                            children: [
                              _buildInfoRow(responsive, 'Pepper Type', 'Black Pepper', Icons.grass_rounded),
                              _buildDivider(responsive),
                              _buildInfoRow(responsive, 'Pepper Variety', 'Ceylon Pepper', Icons.local_florist_rounded),
                              _buildDivider(responsive),
                              _buildInfoRow(responsive, 'Drying Method', 'Sun Dried', Icons.wb_sunny_rounded),
                              _buildDivider(responsive),
                              _buildInfoRow(responsive, 'Harvest Date', '12 Aug 2025', Icons.calendar_today_rounded),
                              _buildDivider(responsive),
                              _buildInfoRow(responsive, 'Batch Weight', '25 kg', Icons.scale_rounded),
                              _buildDivider(responsive),
                              _buildInfoRow(responsive, 'Bulk Density', '540 g/L', Icons.science_rounded),
                              _buildDivider(responsive),
                              _buildInfoRow(responsive, 'Certificates', 'GAP, Quality Certificate', Icons.verified_rounded, isLast: true),
                            ],
                          ),
                        ),

                        ResponsiveSpacing(mobile: 28, tablet: 32, desktop: 36),

                        // Quality Breakdown Section
                        _buildSectionHeader(
                          responsive,
                          primary,
                          'Quality Breakdown',
                          Icons.analytics_rounded,
                        ),

                        ResponsiveSpacing(mobile: 16, tablet: 18, desktop: 20),

                        Container(
                          padding: responsive.padding(
                            mobile: const EdgeInsets.all(20),
                            tablet: const EdgeInsets.all(24),
                            desktop: const EdgeInsets.all(28),
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
                          child: Column(
                            children: [
                              _buildScoreBar(responsive, 'Size / Pinheads', 92, Colors.green),
                              _buildScoreBar(responsive, 'Color Uniformity', 88, Colors.blue),
                              _buildScoreBar(responsive, 'Surface Defects', 94, Colors.purple),
                              _buildScoreBar(responsive, 'Extraneous Matter', 98, Colors.orange),
                              _buildScoreBar(responsive, 'Adulteration', 100, Colors.teal),
                              _buildScoreBar(responsive, 'Uniformity', 90, Colors.indigo, isLast: true),
                            ],
                          ),
                        ),

                        ResponsiveSpacing(mobile: 28, tablet: 32, desktop: 36),

                        // Improvement Suggestions Section
                        _buildSectionHeader(
                          responsive,
                          primary,
                          'Improvement Suggestions',
                          Icons.lightbulb_rounded,
                        ),

                        ResponsiveSpacing(mobile: 16, tablet: 18, desktop: 20),

                        Container(
                          padding: responsive.padding(
                            mobile: const EdgeInsets.all(20),
                            tablet: const EdgeInsets.all(24),
                            desktop: const EdgeInsets.all(28),
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade50,
                                Colors.blue.shade100.withOpacity(0.5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildSuggestionItem(
                                responsive,
                                'Ensure uniform drying to improve color score',
                                Icons.wb_sunny_rounded,
                              ),
                              ResponsiveSpacing(mobile: 16, tablet: 18, desktop: 20),
                              _buildSuggestionItem(
                                responsive,
                                'Remove broken berries before packing',
                                Icons.cleaning_services_rounded,
                              ),
                            ],
                          ),
                        ),

                        ResponsiveSpacing(mobile: 32, tablet: 40, desktop: 48),

                        // Action Buttons
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
                            onPressed: () {
                              // TODO: Download PDF
                            },
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
                                  Icons.download_rounded,
                                  size: responsive.smallIconSize,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Download Report (PDF)",
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

                        ResponsiveSpacing(mobile: 16, tablet: 18, desktop: 20),

                        Container(
                          width: double.infinity,
                          height: responsive.buttonHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: primary, width: 2),
                          ),
                          child: OutlinedButton(
                            onPressed: () {
                              // TODO: View grading algorithm
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primary,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: responsive.smallIconSize,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "View Grading Algorithm",
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
      ),
    );
  }

  Widget _buildSectionHeader(
      Responsive responsive,
      Color primary,
      String title,
      IconData icon,
      ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(
            responsive.value(mobile: 8, tablet: 9, desktop: 10),
          ),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: primary,
            size: responsive.value(mobile: 20, tablet: 22, desktop: 24),
          ),
        ),
        ResponsiveSpacing.horizontal(mobile: 12, tablet: 14, desktop: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: responsive.headingFontSize - 2,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
      Responsive responsive,
      String label,
      String value,
      IconData icon, {
        bool isLast = false,
      }) {
    return Padding(
      padding: responsive.padding(
        mobile: EdgeInsets.fromLTRB(16, 14, 16, isLast ? 14 : 0),
        tablet: EdgeInsets.fromLTRB(18, 16, 18, isLast ? 16 : 0),
        desktop: EdgeInsets.fromLTRB(20, 18, 20, isLast ? 18 : 0),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: responsive.smallIconSize,
            color: Colors.grey[600],
          ),
          ResponsiveSpacing.horizontal(mobile: 12, tablet: 14, desktop: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: responsive.bodyFontSize,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: responsive.bodyFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Responsive responsive) {
    return Divider(
      height: 1,
      indent: responsive.value(mobile: 16, tablet: 18, desktop: 20),
      endIndent: responsive.value(mobile: 16, tablet: 18, desktop: 20),
    );
  }

  Widget _buildScoreBar(
      Responsive responsive,
      String label,
      int score,
      Color color, {
        bool isLast = false,
      }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : responsive.value(mobile: 20, tablet: 22, desktop: 24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: responsive.bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.value(mobile: 10, tablet: 11, desktop: 12),
                  vertical: responsive.value(mobile: 4, tablet: 5, desktop: 6),
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$score',
                  style: TextStyle(
                    fontSize: responsive.bodyFontSize,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          ResponsiveSpacing(mobile: 8, tablet: 10, desktop: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: responsive.value(mobile: 8, tablet: 9, desktop: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(Responsive responsive, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: responsive.value(mobile: 6, tablet: 7, desktop: 8),
          height: responsive.value(mobile: 6, tablet: 7, desktop: 8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        ResponsiveSpacing.horizontal(mobile: 12, tablet: 14, desktop: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: responsive.bodyFontSize,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionItem(
      Responsive responsive,
      String text,
      IconData icon,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(
            responsive.value(mobile: 8, tablet: 9, desktop: 10),
          ),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.blue.shade700,
            size: responsive.value(mobile: 18, tablet: 20, desktop: 22),
          ),
        ),
        ResponsiveSpacing.horizontal(mobile: 12, tablet: 14, desktop: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: responsive.bodyFontSize,
              color: Colors.blue.shade900,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}