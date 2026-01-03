import 'package:flutter/material.dart';
import 'package:CeylonPepper/widgets/bottom_navigation.dart';

import '../features/quality_grading/screens/quality_grading_dashboard.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe navigation
        children: _buildPages(),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }

  List<Widget> _buildPages() {
    return [
      // Index 0 - Dashboard
      _buildPlaceholderPage("Dashboard", Icons.dashboard_rounded, Colors.blue),

      // Index 1 - My Farm
      _buildPlaceholderPage("My Farm", Icons.agriculture_rounded, Colors.green),

      // Index 2 - Quality (your existing page)
      const QualityGradingDashboard(),

      // Index 3 - Market
      _buildPlaceholderPage("Market", Icons.store_rounded, Colors.orange),

      // Index 4 - Profile
      _buildPlaceholderPage("Profile", Icons.person_rounded, Colors.purple),
    ];
  }

  // Placeholder widget for pages you haven't created yet
  Widget _buildPlaceholderPage(String title, IconData icon, Color color) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: color.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              "$title Page",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Coming soon...",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}