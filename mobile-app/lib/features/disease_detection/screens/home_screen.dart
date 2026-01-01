import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'image_picker_screen.dart';
import 'posts_view_screen.dart';
import 'complaint_screen.dart';
import 'complaint_list_screen.dart';
import 'analyze_plants_screen.dart';

class HomeScreen extends StatefulWidget {
  final User? user;
  const HomeScreen({super.key, this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _openCamera(BuildContext context) async {
    final image = await Navigator.push<File>(
      context,
      MaterialPageRoute(builder: (context) => const ImagePickerScreen()),
    );

    if (image != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo captured!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToPosts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PostsViewScreen()),
    );
  }

  void _navigateToComplaint(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ComplaintScreen()),
    );
  }

  void _navigateToComplaintManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ComplaintListScreen()),
    );
  }

  void _navigateToAnalyzePlants(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AnalyzePlantsScreen()),
    );
  }

  String _getUserDisplayName() {
    return 'Farmer';
  }

  String _getUserEmail() {
    return widget.user?.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- HEADER ----------------
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top + 20, 0, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, ${_getUserDisplayName()} 👋",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Disease Detection",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (_getUserEmail().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _getUserEmail(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ---------------- FEATURES LIST ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // View Posts
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: _boxDecoration(),
                    child: _buildListTile(
                      title: "View Posts",
                      subtitle: "Create and view social posts",
                      icon: Icons.dynamic_feed,
                      iconColor: const Color(0xFF2196F3),
                      onTap: () => _navigateToPosts(context),
                    ),
                  ),

                  // Make a Complaint
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: _boxDecoration(),
                    child: _buildListTile(
                      title: "Make a Complaint",
                      subtitle: "Submit your complaints or issues",
                      icon: Icons.report_problem,
                      iconColor: const Color(0xFFFF9800),
                      onTap: () => _navigateToComplaint(context),
                    ),
                  ),

                  // Manage Complaints
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: _boxDecoration(),
                    child: _buildListTile(
                      title: "Manage Complaints",
                      subtitle: "View and manage all complaints",
                      icon: Icons.admin_panel_settings,
                      iconColor: const Color(0xFF9C27B0),
                      onTap: () => _navigateToComplaintManagement(context),
                    ),
                  ),

                  // Analyze Plants
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: _boxDecoration(),
                    child: _buildListTile(
                      title: "Analyze Plants",
                      subtitle: "Detect plant diseases with AI",
                      icon: Icons.eco,
                      iconColor: const Color(0xFF009688),
                      onTap: () => _navigateToAnalyzePlants(context),
                    ),
                  ),

                  // Open Camera
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: _boxDecoration(),
                    child: _buildListTile(
                      title: "Disease Detection Camera",
                      subtitle: "Scan Disease photos using camera",
                      icon: Icons.camera_alt,
                      iconColor: const Color(0xFF4CAF50),
                      onTap: () => _openCamera(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          spreadRadius: 1,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

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
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
    );
  }
}

