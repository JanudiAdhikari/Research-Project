import 'package:flutter/material.dart';
import '../../../utils/responsive.dart';

class SummaryStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const SummaryStatItem({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Container(
      padding: EdgeInsets.all(responsive.smallSpacing + 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
          SizedBox(height: responsive.smallSpacing / 2),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.bodyFontSize + 1,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: responsive.smallFontSize - 1,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
