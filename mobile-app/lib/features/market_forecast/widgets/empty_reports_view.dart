import 'package:flutter/material.dart';
import '../../../utils/responsive.dart';

class EmptyReportsView extends StatelessWidget {
  const EmptyReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.mediumSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade400),
            SizedBox(height: responsive.mediumSpacing),
            Text(
              'No reports found',
              style: TextStyle(
                fontSize: responsive.bodyFontSize + 2,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: responsive.smallSpacing),
            Text(
              'Submit your first price report to see it here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: responsive.bodyFontSize,
                color: Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
