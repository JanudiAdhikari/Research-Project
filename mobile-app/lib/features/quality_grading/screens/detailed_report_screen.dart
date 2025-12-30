import 'package:flutter/material.dart';
import '../../../utils/responsive.dart';

class DetailedReportScreen extends StatelessWidget {
  const DetailedReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    const primary = Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          'Quality Report',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(responsive.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _gradeHeader(responsive),
            ResponsiveSpacing(mobile: 24, tablet: 28, desktop: 32),

            _sectionTitle('Batch Summary'),
            _infoCard(responsive, [
              _infoRow('Pepper Type', 'Black Pepper'),
              _infoRow('Variety', 'Ceylon Pepper'),
              _infoRow('Drying Method', 'Sun Dried'),
              _infoRow('Batch Weight', '25 kg'),
              _infoRow('Certificates', 'GAP, Quality Certificate'),
            ]),

            ResponsiveSpacing(mobile: 24, tablet: 28, desktop: 32),

            _sectionTitle('Bulk Density Analysis'),
            _highlightCard(
              responsive,
              title: 'Measured Density',
              value: '640 g/L',
              subtitle: 'Excellent density for export quality',
              icon: Icons.science_rounded,
              color: Colors.green,
            ),

            ResponsiveSpacing(mobile: 24, tablet: 28, desktop: 32),

            _sectionTitle('AI Visual Inspection'),
            _infoCard(responsive, [
              _infoRow('Visual Quality', 'Excellent'),
              _infoRow('Defects Detected', 'Very Low'),
              _infoRow('Foreign Matter', 'None'),
              _infoRow('Model Confidence', '94%'),
            ]),

            ResponsiveSpacing(mobile: 24, tablet: 28, desktop: 32),

            _sectionTitle('Score Breakdown'),
            _scoreRow('Bulk Density Score', '30 / 30'),
            _scoreRow('Visual Quality Score', '35 / 40'),
            _scoreRow('Defect Penalty', '-3'),
            _scoreRow('Certification Bonus', '+5'),
            const Divider(),
            _scoreRow(
              'Final Score',
              '92 / 100',
              isBold: true,
            ),

            ResponsiveSpacing(mobile: 32, tablet: 40, desktop: 48),

            _actionButtons(context, responsive),
          ],
        ),
      ),
    );
  }

  // ---------------- UI Components ----------------

  Widget _gradeHeader(Responsive responsive) {
    return Container(
      width: double.infinity,
      padding: responsive.padding(
        mobile: const EdgeInsets.all(24),
        tablet: const EdgeInsets.all(28),
        desktop: const EdgeInsets.all(32),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade800],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            'Grade A',
            style: TextStyle(
              fontSize: responsive.fontSize(mobile: 28, tablet: 32, desktop: 36),
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Overall Score: 92 / 100',
            style: TextStyle(
              fontSize: responsive.bodyFontSize,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Excellent export-quality pepper batch',
            style: TextStyle(
              fontSize: responsive.bodyFontSize - 1,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _infoCard(Responsive responsive, List<Widget> children) {
    return Container(
      padding: responsive.padding(
        mobile: const EdgeInsets.all(16),
        tablet: const EdgeInsets.all(18),
        desktop: const EdgeInsets.all(20),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _highlightCard(
      Responsive responsive, {
        required String title,
        required String value,
        required String subtitle,
        required IconData icon,
        required Color color,
      }) {
    return Container(
      padding: responsive.padding(
        mobile: const EdgeInsets.all(20),
        tablet: const EdgeInsets.all(22),
        desktop: const EdgeInsets.all(24),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: responsive.mediumIconSize),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: responsive.titleFontSize,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons(BuildContext context, Responsive responsive) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: responsive.buttonHeight,
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: implement PDF download
            },
            icon: const Icon(Icons.download_rounded),
            label: const Text('Download Report'),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            // TODO: navigate to grading algorithm explanation
          },
          child: const Text('View grading algorithm'),
        ),
      ],
    );
  }
}
