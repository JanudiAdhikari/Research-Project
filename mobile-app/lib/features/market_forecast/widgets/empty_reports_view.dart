import 'package:flutter/material.dart';
import '../../../utils/responsive.dart';
import '../../../utils/market forecast/actual_price_data_si.dart';

class EmptyReportsView extends StatelessWidget {
  final String language;

  const EmptyReportsView({super.key, this.language = 'en'});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    final isSi = language == 'si';
    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.mediumSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade400),
            SizedBox(height: responsive.mediumSpacing),
            Text(
              isSi ? ActualPriceDataSi.noReportsFound : 'No reports found',
              style: TextStyle(
                fontSize: responsive.bodyFontSize + 2,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: responsive.smallSpacing),
            Text(
              isSi
                  ? ActualPriceDataSi.submitFirstReport
                  : 'Submit your first price report to see it here',
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
