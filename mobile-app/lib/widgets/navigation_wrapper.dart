import 'package:flutter/material.dart';
import 'bottom_navigation.dart';

class NavigationWrapper extends StatefulWidget {
  final Widget child;
  final int initialIndex;
  final bool showBottomNavigation;
  final List<Widget> Function(int)? tabScreens;

  const NavigationWrapper({
    Key? key,
    required this.child,
    this.initialIndex = 0,
    this.showBottomNavigation = true,
    this.tabScreens,
  }) : super(key: key);

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    // If tabScreens are provided, handle navigation differently
    if (widget.tabScreens != null) {
      // You might want to use Navigator to push screens
      // or manage with a PageController for tab navigation
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: widget.showBottomNavigation
          ? BottomNavigation(
              currentIndex: _currentIndex,
              onTabSelected: _onTabSelected,
            )
          : null,
    );
  }
}
