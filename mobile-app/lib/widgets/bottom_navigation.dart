import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final String userRole;

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTabSelected,
    this.userRole = 'farmer',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2E7D32);

    // Different navigation items for different roles
    final List<Map<String, dynamic>> navItems = userRole == 'exporter'
        ? [
            {'index': 0, 'icon': Icons.home, 'label': 'Home'},
            {'index': 1, 'icon': Icons.store_rounded, 'label': 'Market'},
            {'index': 2, 'icon': Icons.person_rounded, 'label': 'Profile'},
          ]
        : [
            {'index': 0, 'icon': Icons.home, 'label': 'Home'},
            {'index': 1, 'icon': Icons.store_rounded, 'label': 'Market'},
            {'index': 2, 'icon': Icons.agriculture_rounded, 'label': 'My Farm'},
            {'index': 3, 'icon': Icons.book, 'label': 'Diary'},
            {'index': 4, 'icon': Icons.person_rounded, 'label': 'Profile'},
          ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems
                .map(
                  (item) => _buildNavItem(
                    item['index'],
                    item['icon'],
                    item['label'],
                    primaryColor,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    Color primaryColor,
  ) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? primaryColor : Colors.grey, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? primaryColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
