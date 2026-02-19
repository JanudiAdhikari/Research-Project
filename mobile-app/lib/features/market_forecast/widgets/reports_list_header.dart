import 'package:flutter/material.dart';
import '../../../utils/responsive.dart';

class ReportsListHeader extends StatelessWidget {
  final int reportCount;

  const ReportsListHeader({super.key, required this.reportCount});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Sales',
          style: TextStyle(
            fontSize: responsive.bodyFontSize + 2,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        Text(
          '$reportCount entries',
          style: TextStyle(
            fontSize: responsive.smallFontSize + 1,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
