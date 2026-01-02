import 'package:flutter/material.dart';
import '../../../widgets/bottom_navigation.dart';
import 'weekly_price_forecast.dart';
import 'export_price_trends.dart';
import 'export_details_by_country.dart';

class PriceNavigation extends StatelessWidget {
  const PriceNavigation({Key? key}) : super(key: key);

  final Color primary = const Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Market Forecast",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ---------------- FIRST BOX ----------------
              Container(
                decoration: _boxDecoration(),
                child: _buildListTile(
                  title: "Weekly Local Price Forecast",
                  subtitle: "View weekly price predictions",
                  icon: Icons.trending_up,
                  iconColor: const Color(0xFF2E7D32),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WeeklyPriceForecast(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              // ---------------- SECOND BOX ----------------
              Container(
                decoration: _boxDecoration(),
                child: _buildListTile(
                  title: "Past Export Price Trends",
                  subtitle: "Analyze export market trends",
                  icon: Icons.assessment,
                  iconColor: const Color(0xFF1976D2),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExportPriceTrends(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              // ---------------- THIRD BOX ----------------
              Container(
                decoration: _boxDecoration(),
                child: _buildListTile(
                  title: "Export Details by Country of Destination",
                  subtitle: "Track export volumes and prices globally",
                  icon: Icons.public,
                  iconColor: const Color(0xFFFF6F00),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExportDetailsByCountry(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 26),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 0,
        onTabSelected: (index) {
          // Handle navigation based on index
          if (index != 1) {
            // If not already on Market Forecast tab
            Navigator.pop(
              context,
            ); // Go back and let NavigationWrapper handle it
          }
        },
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 14,
          spreadRadius: 0,
          offset: const Offset(0, 6),
        ),
      ],
      border: Border.all(color: Colors.grey.withOpacity(0.06)),
    );
  }

  // List tile with accent icon container and arrow
  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16.5),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: TextStyle(fontSize: 14.2, color: Colors.grey[600]),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey[500],
      ),
      onTap: onTap,
    );
  }
}
