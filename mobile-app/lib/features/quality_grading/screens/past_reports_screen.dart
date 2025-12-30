import 'package:flutter/material.dart';
import '../../../utils/responsive.dart';
import 'detailed_report_screen.dart';

class PastReportsScreen extends StatelessWidget {
  const PastReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    const primary = Color(0xFF2E7D32);

    // Mock data for now
    final reports = [
      {
        'date': '2025-01-12',
        'grade': 'A',
        'score': 92,
      },
      {
        'date': '2024-12-28',
        'grade': 'B',
        'score': 78,
      },
      {
        'date': '2024-12-10',
        'grade': 'A',
        'score': 88,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          'My Quality Reports',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: reports.isEmpty
          ? _emptyState(responsive)
          : ListView.builder(
        padding: EdgeInsets.all(responsive.pagePadding),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return _reportCard(
            responsive: responsive,
            primary: primary,
            date: report['date'] as String,
            grade: report['grade'] as String,
            score: report['score'] as int,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DetailedReportScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _reportCard({
    required Responsive responsive,
    required Color primary,
    required String date,
    required String grade,
    required int score,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: responsive.padding(
          mobile: const EdgeInsets.all(16),
          tablet: const EdgeInsets.all(18),
          desktop: const EdgeInsets.all(20),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Grade badge
            Container(
              width: responsive.value(mobile: 48, tablet: 52, desktop: 56),
              height: responsive.value(mobile: 48, tablet: 52, desktop: 56),
              decoration: BoxDecoration(
                color: _gradeColor(grade).withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  grade,
                  style: TextStyle(
                    fontSize: responsive.value(
                      mobile: 22,
                      tablet: 24,
                      desktop: 26,
                    ),
                    fontWeight: FontWeight.w700,
                    color: _gradeColor(grade),
                  ),
                ),
              ),
            ),
            ResponsiveSpacing.horizontal(
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date: $date',
                    style: TextStyle(
                      fontSize: responsive.bodyFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Score: $score / 100',
                    style: TextStyle(
                      fontSize: responsive.bodyFontSize - 1,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: responsive.smallIconSize,
              color: Colors.grey[500],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(Responsive responsive) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.pagePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_drive_file_outlined,
              size: responsive.value(mobile: 64, tablet: 72, desktop: 80),
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No reports yet',
              style: TextStyle(
                fontSize: responsive.titleFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your quality grading reports will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: responsive.bodyFontSize,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.orange;
      case 'C':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
