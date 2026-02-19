import 'package:flutter/material.dart';
import '../../../utils/responsive.dart';

class PriceReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const PriceReportCard({
    super.key,
    required this.report,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final pricePerKg = (report['pricePerKg'] as num?)?.toDouble() ?? 0.0;
    final priceColor = const Color(0xFF2E7D32);
    final quantity = (report['quantity'] as num?)?.toDouble() ?? 0.0;
    final variety = report['pepperType'] as String? ?? 'N/A';
    final grade = report['grade'] as String? ?? 'N/A';
    final gradeColor = _gradeColor(grade);
    final district = report['district'] as String? ?? 'N/A';
    final notes = report['notes'] as String? ?? '';
    final saleDate = report['saleDate'] as String? ?? '';
    final marketplaceProductId = report['marketplaceProductId'] as String?;
    final isInMarketplace =
        marketplaceProductId != null && marketplaceProductId.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: responsive.smallSpacing + 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(responsive.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(
              responsive,
              saleDate,
              pricePerKg,
              priceColor,
              isInMarketplace,
            ),
            SizedBox(height: responsive.smallSpacing + 4),
            _buildContent(
              responsive,
              variety,
              grade,
              gradeColor,
              quantity,
              district,
            ),
            if (notes.isNotEmpty) ...[
              SizedBox(height: responsive.smallSpacing),
              _buildNotesSection(responsive, notes),
            ],
            SizedBox(height: responsive.smallSpacing + 4),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    Responsive responsive,
    String saleDate,
    double pricePerKg,
    Color priceColor,
    bool isInMarketplace,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 14, color: Colors.black54),
            const SizedBox(width: 6),
            Text(
              _formatDate(saleDate),
              style: TextStyle(
                fontSize: responsive.smallFontSize + 1,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isInMarketplace) ...[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.smallSpacing + 4,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'In Marketplace',
                      style: TextStyle(
                        fontSize: responsive.smallFontSize - 1,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
            ],
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.smallSpacing + 4,
                vertical: responsive.smallSpacing,
              ),
              decoration: BoxDecoration(
                color: priceColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: priceColor.withOpacity(0.3)),
              ),
              child: Text(
                'LKR ${pricePerKg.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: responsive.bodyFontSize,
                  fontWeight: FontWeight.w800,
                  color: priceColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent(
    Responsive responsive,
    String variety,
    String grade,
    Color gradeColor,
    double quantity,
    String district,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                variety,
                style: TextStyle(
                  fontSize: responsive.bodyFontSize + 2,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.smallSpacing + 4,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [gradeColor, gradeColor.withOpacity(0.85)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: gradeColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          grade,
                          style: TextStyle(
                            fontSize: responsive.smallFontSize + 1,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatDecimal(quantity)} kg',
                    style: TextStyle(
                      fontSize: responsive.smallFontSize + 1,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.smallSpacing),
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: Colors.black45,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    district,
                    style: TextStyle(
                      fontSize: responsive.smallFontSize,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(Responsive responsive, String notes) {
    return Container(
      padding: EdgeInsets.all(responsive.smallSpacing),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.note_rounded, size: 14, color: Colors.black45),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              notes,
              style: TextStyle(
                fontSize: responsive.smallFontSize,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: onUpdate,
          icon: const Icon(Icons.edit_rounded, size: 16),
          label: const Text('Update'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF2E7D32),
            side: const BorderSide(color: Color(0xFF2E7D32)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_rounded, size: 16),
          label: const Text('Delete'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'Grade 1':
        return const Color(0xFF1B5E20);
      case 'Grade 2':
        return const Color(0xFF0277BD);
      case 'Grade 3':
        return const Color(0xFFF57C00);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  String _formatDecimal(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }
}
