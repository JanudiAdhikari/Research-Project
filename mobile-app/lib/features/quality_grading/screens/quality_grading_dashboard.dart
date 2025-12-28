import 'package:flutter/material.dart';
import '../../../utils/responsive.dart';
import '../widgets/grading_action_card.dart';

class QualityGradingDashboard extends StatelessWidget {
  const QualityGradingDashboard({super.key});

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
          "Pepper Quality Grading",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(responsive.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro text
            Text(
              "Check the quality of your pepper batch using AI based grading.",
              style: TextStyle(
                fontSize: responsive.bodyFontSize,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: GridView.count(
                crossAxisCount: responsive.isMobile ? 2 : 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  GradingActionCard(
                    title: "New Quality Check",
                    icon: Icons.add_circle_outline,
                    color: Colors.green,
                    onTap: () {
                      // TODO: navigate to batch details
                    },
                  ),
                  GradingActionCard(
                    title: "My Past Reports",
                    icon: Icons.history,
                    color: Colors.blue,
                    onTap: () {
                      // TODO: navigate to past reports
                    },
                  ),
                  GradingActionCard(
                    title: "How Grading Works",
                    icon: Icons.info_outline,
                    color: Colors.orange,
                    onTap: () {
                      // TODO: navigate to grading info
                    },
                  ),
                  GradingActionCard(
                    title: "Tips to Improve Quality",
                    icon: Icons.lightbulb_outline,
                    color: Colors.purple,
                    onTap: () {
                      // TODO: navigate to tips screen
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
