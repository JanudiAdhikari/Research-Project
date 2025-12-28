import 'package:flutter/material.dart';
import '../../../utils/responsive.dart';
import '../widgets/grading_action_card.dart';
import 'batch_details_screen.dart';

class QualityGradingDashboard extends StatefulWidget {
  const QualityGradingDashboard({super.key});

  @override
  State<QualityGradingDashboard> createState() => _QualityGradingDashboardState();
}

class _QualityGradingDashboardState extends State<QualityGradingDashboard>
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
          "Quality Grading",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white),
            onPressed: () {
              // Quick access to past reports
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Header Section
              Container(
                width: double.infinity,
                padding: responsive.padding(
                  mobile: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                  tablet: const EdgeInsets.fromLTRB(32, 40, 32, 40),
                  desktop: const EdgeInsets.fromLTRB(40, 48, 40, 48),
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
                      children: [
                        Container(
                          padding: responsive.padding(
                            mobile: const EdgeInsets.all(12),
                            tablet: const EdgeInsets.all(14),
                            desktop: const EdgeInsets.all(16),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.verified_rounded,
                            color: Colors.white,
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
                                "AI-Powered Quality",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: responsive.bodyFontSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              ResponsiveSpacing(mobile: 4, tablet: 6, desktop: 8),
                              Text(
                                "Grade Your Pepper",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: responsive.fontSize(
                                    mobile: 22,
                                    tablet: 24,
                                    desktop: 26,
                                  ),
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
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
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.amber[300],
                            size: responsive.smallIconSize,
                          ),
                          ResponsiveSpacing.horizontal(
                            mobile: 10,
                            tablet: 12,
                            desktop: 14,
                          ),
                          Expanded(
                            child: Text(
                              "Get instant quality analysis with our AI",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: responsive.bodyFontSize - 1,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              ResponsiveSpacing(mobile: 28, tablet: 32, desktop: 36),

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

              // Enhanced Action Grid
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
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.95,
                      children: _buildActionCards(context, responsive, primary),
                    ),
                    tablet: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.1,
                      children: _buildActionCards(context, responsive, primary),
                    ),
                    desktop: GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 0.95,
                      children: _buildActionCards(context, responsive, primary),
                    ),
                  ),
                ),
              ),

              ResponsiveSpacing(mobile: 32, tablet: 40, desktop: 48),

              // Info Section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.pagePadding,
                ),
                child: Container(
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
                    border: Border.all(
                      color: Colors.blue.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.tips_and_updates_rounded,
                          color: Colors.blue.shade700,
                          size: responsive.mediumIconSize,
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
                              "Pro Tip",
                              style: TextStyle(
                                fontSize: responsive.bodyFontSize,
                                fontWeight: FontWeight.w700,
                                color: Colors.blue.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Ensure good lighting and clear images for accurate AI grading results.",
                              style: TextStyle(
                                fontSize: responsive.bodyFontSize - 1,
                                color: Colors.blue.shade800,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              ResponsiveSpacing(mobile: 24, tablet: 32, desktop: 40),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActionCards(
      BuildContext context,
      Responsive responsive,
      Color primary,
      ) {
    return [
      _actionCard(
        context,
        responsive,
        title: "New Quality\nCheck",
        subtitle: "Start grading",
        icon: Icons.add_circle_outline,
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const BatchDetailsScreen(),
            ),
          );
        },
      ),
      _actionCard(
        context,
        responsive,
        title: "Past\nReports",
        subtitle: "View history",
        icon: Icons.history_rounded,
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        onTap: () {
          // TODO: navigate to past reports
        },
      ),
      _actionCard(
        context,
        responsive,
        title: "How It\nWorks",
        subtitle: "Learn more",
        icon: Icons.info_outline_rounded,
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
        ),
        onTap: () {
          // TODO: navigate to grading info
        },
      ),
      _actionCard(
        context,
        responsive,
        title: "Quality\nTips",
        subtitle: "Improve grade",
        icon: Icons.lightbulb_outline_rounded,
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.purple.shade600],
        ),
        onTap: () {
          // TODO: navigate to tips screen
        },
      ),
    ];
  }

  Widget _actionCard(
      BuildContext context,
      Responsive responsive, {
        required String title,
        required String subtitle,
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
                    Row(
                      children: [
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: responsive.bodyFontSize - 2,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white.withOpacity(0.9),
                          size: responsive.smallIconSize - 2,
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
}