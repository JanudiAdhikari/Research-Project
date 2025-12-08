import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'image_picker_screen.dart';
import 'posts_view_screen.dart';
import 'complaint_screen.dart';
import 'complaint_list_screen.dart';

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

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getUserDisplayName() {
    if (widget.user == null) return 'Guest';
    return widget.user?.displayName ?? widget.user?.email?.split('@').first ?? 'User';
  }

  String _getUserEmail() {
    return widget.user?.email ?? 'No email';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Social App'),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          // User profile with logout option
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: PopupMenuButton<String>(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person, color: Colors.blue, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _getUserDisplayName(),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              onSelected: (value) {
                if (value == 'logout') {
                  _logout(context);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout, size: 20, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: Colors.blue, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome, ${_getUserDisplayName()}!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getUserEmail(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Features Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Posts Button Card
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.dynamic_feed, color: Colors.blue),
                      ),
                      title: const Text(
                        'View Posts',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      subtitle: const Text('Create and view social posts'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _navigateToPosts(context),
                    ),
                  ),

                  // Complaint Button Card
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.report_problem, color: Colors.orange),
                      ),
                      title: const Text(
                        'Make a Complaint',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      subtitle: const Text('Submit your complaints or issues'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _navigateToComplaint(context),
                    ),
                  ),

                  // Complaint Management Card
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.admin_panel_settings, color: Colors.purple),
                      ),
                      title: const Text(
                        'Manage Complaints',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      subtitle: const Text('View and manage all complaints'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _navigateToComplaintManagement(context),
                    ),
                  ),

                  // Camera Button Card
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.green),
                      ),
                      title: const Text(
                        'Open Camera',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      subtitle: const Text('Capture photos using camera'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
}