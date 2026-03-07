import 'package:flutter/material.dart';
import '../../../utils/responsive.dart';
import '../../../utils/yield_prediction/yield_prediction_si.dart';
import '../screens/new_prediction_screen.dart';
import '../screens/prediction_history_screen.dart';
import '../screens/how_prediction_works_screen.dart';
import '../screens/image_capture_guide_screen.dart';
import '../screens/iot_sensor_setup_screen.dart';
import '../screens/weather_impact_screen.dart';
import '../screens/yield_tips_screen.dart';

class HarvestPredictionDashboard extends StatefulWidget {
  final String language;

  const HarvestPredictionDashboard({super.key, this.language = 'en'});

  @override
  State<HarvestPredictionDashboard> createState() =>
      _HarvestPredictionDashboardState();
}

class _HarvestPredictionDashboardState extends State<HarvestPredictionDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
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
    const primary = Color(0xFF2E7D32);
    final isSi = widget.language == 'si';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: Text(
          isSi ? YieldPredictionSi.harvestPrediction : "Harvest Prediction",
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PredictionHistoryScreen(language: widget.language),
                ),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(responsive, primary, isSi),
              const SizedBox(height: 16),
              _buildStatusBanner(responsive, isSi),
              const SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.pagePadding,
                ),
                child: _buildSummaryGrid(isSi),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.pagePadding,
                ),
                child: Text(
                  isSi
                      ? YieldPredictionSi.whatWouldYouLikeToDo
                      : "What would you like to do?",
                  style: TextStyle(
                    fontSize: responsive.headingFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildActions(responsive, isSi),
              const SizedBox(height: 28),
              _buildResources(responsive, isSi),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(Responsive responsive, Color primary, bool isSi) {
    return Container(
      width: double.infinity,
      padding: responsive.padding(
        mobile: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        tablet: const EdgeInsets.fromLTRB(32, 40, 32, 40),
        desktop: const EdgeInsets.fromLTRB(40, 48, 40, 48),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary, primary.withOpacity(0.85)]),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(
            responsive.value(mobile: 32, tablet: 36, desktop: 40),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSi
                    ? YieldPredictionSi.whatWouldYouLikeToDo
                    : "What would you like to do?",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: responsive.bodyFontSize,
                ),
              ),
              Text(
                isSi
                    ? YieldPredictionSi.predictYourHarvest
                    : "Predict Your Harvest",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsive.headingFontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= STATUS =================
  Widget _buildStatusBanner(Responsive responsive, bool isSi) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isSi
                    ? YieldPredictionSi.cropConditionHealthy
                    : "Crop condition looks healthy. No immediate action required.",
                style: TextStyle(
                  fontSize: responsive.bodyFontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.green.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SUMMARY =================
  Widget _buildSummaryGrid(bool isSi) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _summaryCard(
          isSi ? YieldPredictionSi.predictions : "Predictions",
          "5",
          Icons.analytics_rounded,
          Colors.blue,
        ),
        _summaryCard(
          isSi ? YieldPredictionSi.avgYield : "Avg Yield",
          "35 ${isSi ? YieldPredictionSi.kg : 'kg'}",
          Icons.trending_up_rounded,
          Colors.green,
        ),
        _summaryCard(
          isSi ? YieldPredictionSi.bestYield : "Best Yield",
          "41 ${isSi ? YieldPredictionSi.kg : 'kg'}",
          Icons.star_rounded,
          Colors.amber,
        ),
        _summaryCard(
          isSi ? YieldPredictionSi.lastRun : "Last Run",
          "Jan 6th",
          Icons.schedule_rounded,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // ================= ACTIONS =================
  Widget _buildActions(Responsive responsive, bool isSi) {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.95,
          children: [
            _actionCard(
              isSi ? YieldPredictionSi.newPrediction : "New\nPrediction",
              isSi ? YieldPredictionSi.estimateYield : "Estimate yield",
              Icons.add_chart_rounded,
              true,
              LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
              ),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      NewPredictionScreen(language: widget.language),
                ),
              ),
              isSi,
            ),
            _actionCard(
              isSi ? YieldPredictionSi.pastPredictions : "Past\nPredictions",
              isSi ? YieldPredictionSi.viewHistory : "View history",
              Icons.history_rounded,
              false,
              LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
              ),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PredictionHistoryScreen(language: widget.language),
                ),
              ),
              isSi,
            ),
            _actionCard(
              isSi ? YieldPredictionSi.weatherImpactCard : "Weather\nImpact",
              isSi ? YieldPredictionSi.viewFactors : "View factors",
              Icons.cloud_rounded,
              false,
              LinearGradient(
                colors: [Colors.orange.shade400, Colors.orange.shade600],
              ),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        WeatherImpactScreen(language: widget.language),
                  ),
                );
              },
              isSi,
            ),
            _actionCard(
              isSi ? YieldPredictionSi.yieldTipsCard : "Yield\nTips",
              isSi ? YieldPredictionSi.improveOutput : "Improve output",
              Icons.lightbulb_outline_rounded,
              false,
              LinearGradient(
                colors: [Colors.purple.shade400, Colors.purple.shade600],
              ),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => YieldTipsScreen(language: widget.language),
                  ),
                );
              },
              isSi,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(
    String title,
    String subtitle,
    IconData icon,
    bool badge,
    Gradient gradient,
    VoidCallback onTap,
    bool isSi,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            if (badge)
              Positioned(
                top: 12,
                right: 12,
                child: _badge(
                  isSi ? YieldPredictionSi.recommended : "Recommended",
                  isSi: isSi,
                ),
              ),
            Positioned(
              right: -12,
              bottom: -12,
              child: Icon(icon, size: 90, color: Colors.white24),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: Colors.white),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(subtitle, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= RESOURCES =================
  Widget _buildResources(Responsive responsive, bool isSi) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isSi ? YieldPredictionSi.resourcesSupport : "Resources & Support",
            style: TextStyle(
              fontSize: responsive.headingFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _resourceTile(
            isSi
                ? YieldPredictionSi.howYieldPredictionWorksTitle
                : "How Yield Prediction Works",
            isSi
                ? YieldPredictionSi.understandAiModel
                : "Understand the AI model",
            Icons.school_rounded,
            Colors.indigo,
            isSi ? YieldPredictionSi.recommended : "Recommended",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      HowPredictionWorksScreen(language: widget.language),
                ),
              );
            },
            isSi,
          ),
          _resourceTile(
            isSi
                ? YieldPredictionSi.imageCaptureGuideTitle
                : "Image Capture Guide",
            isSi
                ? YieldPredictionSi.improveImageQuality
                : "Improve image quality",
            Icons.camera_alt_rounded,
            Colors.teal,
            isSi ? YieldPredictionSi.improvesAccuracy : "Improves Accuracy",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ImageCaptureGuideScreen(language: widget.language),
                ),
              );
            },
            isSi,
          ),
          _resourceTile(
            isSi ? YieldPredictionSi.iotSensorSetupTitle : "IoT Sensor Setup",
            isSi ? YieldPredictionSi.connectSoilSensor : "Connect soil sensor",
            Icons.sensors_rounded,
            Colors.deepPurple,
            isSi ? YieldPredictionSi.required : "Required",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      IotSensorSetupScreen(language: widget.language),
                ),
              );
            },
            isSi,
          ),
        ],
      ),
    );
  }

  Widget _resourceTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String badge,
    VoidCallback onTap,
    bool isSi,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Row(
          children: [
            Expanded(child: Text(title)),
            _badge(badge, color: color, isSi: isSi),
          ],
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _badge(String text, {Color color = Colors.green, bool isSi = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
