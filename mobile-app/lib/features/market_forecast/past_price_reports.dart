import 'package:flutter/material.dart';
import '../../utils/responsive.dart';
import '../../services/market_forecast/actual_price_data_service.dart';
import 'actual_price_data.dart';

class PastPriceReportsScreen extends StatefulWidget {
  const PastPriceReportsScreen({super.key});

  @override
  State<PastPriceReportsScreen> createState() => _PastPriceReportsScreenState();
}

class _PastPriceReportsScreenState extends State<PastPriceReportsScreen> {
  final ActualPriceDataService _service = ActualPriceDataService();
  List<Map<String, dynamic>> pastReports = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final records = await _service.fetchActualPriceData();
      if (mounted) {
        setState(() {
          pastReports = records;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load reports: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteReport(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('Are you sure you want to delete this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.deleteActualPriceData(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadReports();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete report: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _navigateToUpdateReport(Map<String, dynamic> report) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ActualPriceData(reportData: report),
      ),
    );

    // Reload reports if update was successful
    if (result == true && mounted) {
      _loadReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Past Price Reports'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadReports,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(responsive.mediumSpacing),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                    SizedBox(height: responsive.mediumSpacing),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: responsive.bodyFontSize,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: responsive.mediumSpacing),
                    ElevatedButton.icon(
                      onPressed: _loadReports,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : pastReports.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(responsive.mediumSpacing),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_rounded,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
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
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(responsive.mediumSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(responsive),
                  SizedBox(height: responsive.largeSpacing),
                  _buildReportsList(responsive),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(Responsive responsive) {
    final totalReports = pastReports.length;
    final avgPrice = pastReports.isEmpty
        ? 0.0
        : pastReports
                  .map((r) => (r['pricePerKg'] as num?)?.toDouble() ?? 0.0)
                  .reduce((a, b) => a + b) /
              totalReports;
    final totalQuantity = pastReports.isEmpty
        ? 0
        : pastReports
              .map((r) => (r['quantity'] as num?)?.toInt() ?? 0)
              .reduce((a, b) => a + b);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.mediumSpacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withOpacity(0.08)),
                ),
                child: const Icon(
                  Icons.assessment_rounded,
                  color: Colors.black87,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Submissions',
                      style: TextStyle(
                        fontSize: responsive.bodyFontSize + 2,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track the historical price submissions',
                      style: TextStyle(
                        fontSize: responsive.bodyFontSize - 1,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.mediumSpacing),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  responsive,
                  'Total Reports',
                  '$totalReports',
                  Icons.list_alt_rounded,
                ),
              ),
              SizedBox(width: responsive.smallSpacing),
              Expanded(
                child: _buildStatItem(
                  responsive,
                  'Avg Price',
                  'Rs. ${avgPrice.toStringAsFixed(0)}',
                  Icons.attach_money_rounded,
                ),
              ),
              SizedBox(width: responsive.smallSpacing),
              Expanded(
                child: _buildStatItem(
                  responsive,
                  'Total Qty',
                  '$totalQuantity kg',
                  Icons.scale_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    Responsive responsive,
    String label,
    String value,
    IconData icon,
  ) {
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
          SizedBox(height: 2),
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

  Widget _buildReportsList(Responsive responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Reports',
              style: TextStyle(
                fontSize: responsive.bodyFontSize + 2,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            Text(
              '${pastReports.length} entries',
              style: TextStyle(
                fontSize: responsive.smallFontSize + 1,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.smallSpacing + 4),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pastReports.length,
          itemBuilder: (context, index) {
            return _buildReportCard(responsive, pastReports[index]);
          },
        ),
      ],
    );
  }

  Widget _buildReportCard(Responsive responsive, Map<String, dynamic> report) {
    final pricePerKg = (report['pricePerKg'] as num?)?.toDouble() ?? 0.0;
    final priceColor = const Color(0xFF2E7D32);
    final quantity = (report['quantity'] as num?)?.toInt() ?? 0;
    final variety = report['pepperType'] as String? ?? 'N/A';
    final grade = report['grade'] as String? ?? 'N/A';
    final gradeColor = _gradeColor(grade);
    final district = report['district'] as String? ?? 'N/A';
    final notes = report['notes'] as String? ?? '';
    final saleDate = report['saleDate'] as String? ?? '';

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Colors.black54,
                    ),
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
            SizedBox(height: responsive.smallSpacing + 4),
            Row(
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
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: responsive.smallSpacing + 4,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  gradeColor,
                                  gradeColor.withOpacity(0.85),
                                ],
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
                                Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
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
                            '$quantity kg',
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
                      if (notes.isNotEmpty) ...[
                        SizedBox(height: responsive.smallSpacing),
                        Container(
                          padding: EdgeInsets.all(responsive.smallSpacing),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.note_rounded,
                                size: 14,
                                color: Colors.black45,
                              ),
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
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: responsive.smallSpacing + 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _navigateToUpdateReport(report),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Update'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2E7D32),
                    side: const BorderSide(color: Color(0xFF2E7D32)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    final id =
                        report['_id'] as String? ??
                        report['id'] as String? ??
                        '';
                    if (id.isNotEmpty) {
                      _deleteReport(id);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cannot delete: Report ID not found'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete_rounded, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
}
