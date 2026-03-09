import 'package:flutter/material.dart';

Widget pillWidget({
  required String text,
  required Color color,
  IconData? icon,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
        ],
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: color == Colors.grey ? Colors.grey.shade800 : color,
          ),
        ),
      ],
    ),
  );
}

Widget sectionHeaderWidget(String title, {IconData? icon, Widget? trailing}) {
  return Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 10),
    child: Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: Colors.grey.shade800),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: Colors.grey.shade900,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    ),
  );
}

Widget infoRowWidget({
  required String label,
  required String value,
  IconData? icon,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 10),
        ],
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade900,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget appCard({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 14,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: child,
  );
}

Widget batchStatusHeaderWidget({
  required String batchId,
  required String statusPretty,
  required Color statusColor,
  required IconData statusIcon,
  required bool isMarketplaceListed,
}) {
  return Row(
    children: [
      Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(statusIcon, color: statusColor, size: 28),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Batch: $batchId',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                pillWidget(text: statusPretty, color: statusColor),
                if (isMarketplaceListed)
                  pillWidget(
                    text: 'Also in Marketplace ✅',
                    color: Colors.deepPurple,
                  ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

Widget qualityGradeBannerWidget({
  required String qcGrade,
  required String qcScore,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF2E7D32).withOpacity(0.06),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.18)),
    ),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.workspace_premium_rounded,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Grade',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              Text(
                qcGrade,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withOpacity(0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Score: $qcScore',
            style: const TextStyle(
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget factorScoreItemWidget({
  required String label,
  required double score,
  required Color color,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.grey.shade900,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                score % 1 == 0
                    ? score.toInt().toString()
                    : score.toStringAsFixed(1),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: color,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 10,
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    ),
  );
}

Widget timelineItemWidget({
  required bool isLast,
  required String title,
  required String date,
  required String role,
  required IconData icon,
  required Color iconColor,
}) {
  const green = Color(0xFF2E7D32);

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 34,
        child: Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: green,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 70,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: green.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
          ],
        ),
      ),
      Expanded(
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'On: $date',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      role,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget pdfSuccessBannerWidget() {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.all(12),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F5E9),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.25)),
    ),
    child: const Row(
      children: [
        Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32)),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'PDF generated successfully. You can view in here.',
            style: TextStyle(
              color: Color(0xFF1B5E20),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    ),
  );
}
