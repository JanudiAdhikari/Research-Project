//v2
import 'package:flutter/material.dart';
import 'package:CeylonPepper/utils/responsive.dart';

class BottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final bool showBottomNavigation;

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTabSelected,
    this.showBottomNavigation = true,
  }) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    if (!widget.showBottomNavigation) {
      return const SizedBox.shrink();
    }

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
        top: false,
        child: Container(
          height: responsive.value(mobile: 70, tablet: 75, desktop: 80),
          padding: EdgeInsets.symmetric(
            horizontal: responsive.value(mobile: 8, tablet: 16, desktop: 24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.dashboard_rounded,
                label: "Dashboard",
                isActive: widget.currentIndex == 0,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.agriculture_rounded,
                label: "My Farm",
                isActive: widget.currentIndex == 1,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.verified_rounded,
                label: "Quality",
                isActive: widget.currentIndex == 2,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.store_rounded,
                label: "Market",
                isActive: widget.currentIndex == 3,
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.person_rounded,
                label: "Profile",
                isActive: widget.currentIndex == 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    final responsive = context.responsive;
    final primaryColor = const Color(0xFF2E7D32);

    return GestureDetector(
      onTap: () => widget.onTabSelected(index),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.value(mobile: 8, tablet: 12, desktop: 16),
          vertical: responsive.value(mobile: 6, tablet: 8, desktop: 10),
        ),
        decoration: BoxDecoration(
          color: isActive ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(
            responsive.value(mobile: 12, tablet: 14, desktop: 16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive
                  ? primaryColor
                  : Colors.grey[600],
              size: responsive.value(mobile: 24, tablet: 26, desktop: 28),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: responsive.value(mobile: 9, tablet: 10, desktop: 11),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? primaryColor : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:CeylonPepper/utils/responsive.dart';
//
// class BottomNavigation extends StatefulWidget {
//   final int currentIndex;
//   final Function(int) onTabSelected;
//   final bool showBottomNavigation;
//
//   const BottomNavigation({
//     Key? key,
//     required this.currentIndex,
//     required this.onTabSelected,
//     this.showBottomNavigation = true,
//   }) : super(key: key);
//
//   @override
//   State<BottomNavigation> createState() => _BottomNavigationState();
// }
//
// class _BottomNavigationState extends State<BottomNavigation> {
//   @override
//   Widget build(BuildContext context) {
//     final responsive = context.responsive;
//
//     if (!widget.showBottomNavigation) {
//       return const SizedBox.shrink();
//     }
//
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       child: SafeArea(
//         top: false,
//         child: Container(
//           height: responsive.value(mobile: 70, tablet: 75, desktop: 80),
//           padding: EdgeInsets.symmetric(
//             horizontal: responsive.value(mobile: 16, tablet: 24, desktop: 32),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildNavItem(
//                 index: 0,
//                 icon: Icons.home_rounded,
//                 label: "Home",
//                 isActive: widget.currentIndex == 0,
//               ),
//               _buildNavItem(
//                 index: 1,
//                 icon: Icons.store_rounded,
//                 label: "Market Place",
//                 isActive: widget.currentIndex == 1,
//               ),
//               _buildNavItem(
//                 index: 2,
//                 icon: Icons.insights_rounded,
//                 label: "Insights",
//                 isActive: widget.currentIndex == 2,
//               ),
//               _buildNavItem(
//                 index: 3,
//                 icon: Icons.settings_rounded,
//                 label: "Settings",
//                 isActive: widget.currentIndex == 3,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNavItem({
//     required int index,
//     required IconData icon,
//     required String label,
//     required bool isActive,
//   }) {
//     final responsive = context.responsive;
//     final primaryColor = const Color(0xFF2E7D32);
//
//     return GestureDetector(
//       onTap: () => widget.onTabSelected(index),
//       child: Container(
//         padding: EdgeInsets.symmetric(
//           horizontal: responsive.value(mobile: 12, tablet: 16, desktop: 20),
//           vertical: responsive.value(mobile: 8, tablet: 10, desktop: 12),
//         ),
//         decoration: BoxDecoration(
//           color: isActive ? primaryColor.withOpacity(0.1) : Colors.transparent,
//           borderRadius: BorderRadius.circular(
//             responsive.value(mobile: 16, tablet: 18, desktop: 20),
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               color: isActive
//                   ? primaryColor
//                   : const Color.fromARGB(255, 0, 0, 0),
//               size: responsive.value(mobile: 24, tablet: 26, desktop: 28),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: responsive.value(mobile: 10, tablet: 11, desktop: 12),
//                 fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
//                 color: isActive ? primaryColor : Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }