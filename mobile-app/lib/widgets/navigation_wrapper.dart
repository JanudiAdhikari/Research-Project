import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'bottom_navigation.dart';
import '../features/dashboard/farmer_dashboard.dart';
import '../features/auth/login_page.dart';
import 'my_farm_screen.dart';
import 'quality_screen.dart';
import 'market_screen.dart';
import 'profile_screen.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({Key? key}) : super(key: key);

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _currentIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final storage = const FlutterSecureStorage();
  late Future<bool> _isUserLoggedIn;

  @override
  void initState() {
    super.initState();
    _isUserLoggedIn = _checkUserLogin();
  }

  Future<bool> _checkUserLogin() async {
    try {
      String? token = await storage.read(key: "token");
      User? currentUser = _auth.currentUser;
      
      return token != null && currentUser != null;
    } catch (e) {
      print("Auth check error: $e");
      return false;
    }
  }

  final List<Widget> _pages = const [
    FarmerDashboard(),
    MarketScreen(),
    MyFarmScreen(),
    ProfileScreen(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isUserLoggedIn,
      builder: (context, snapshot) {
        // While checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If not logged in, show login page
        if (snapshot.data == false) {
          return const LoginPage();
        }

        // If logged in, show dashboard with navigation
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigation(
            currentIndex: _currentIndex,
            onTabSelected: _onTabSelected,
          ),
        );
      },
    );
  }
}
