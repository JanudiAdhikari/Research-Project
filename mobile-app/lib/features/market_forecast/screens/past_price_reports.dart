import 'package:flutter/material.dart';
import '../../../utils/responsive.dart';
import '../../../services/market_forecast/actual_price_data_service.dart';
import '../widgets/summary_statistics_card.dart';
import '../widgets/reports_list_header.dart';
import '../widgets/price_report_card.dart';
import '../widgets/empty_reports_view.dart';
import '../widgets/error_view.dart';
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

  // Load past sales reports
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

  // Delete a report with confirmation prompt
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

    // If user confirms deletion, proceed to delete the report
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

  // Navigate to update report screen
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
        title: const Text('Past Price Details'),
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
          ? ErrorView(errorMessage: _errorMessage!, onRetry: _loadReports)
          : pastReports.isEmpty
          ? const EmptyReportsView()
          : SingleChildScrollView(
              padding: EdgeInsets.all(responsive.mediumSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SummaryStatisticsCard(reports: pastReports),
                  SizedBox(height: responsive.largeSpacing),
                  ReportsListHeader(reportCount: pastReports.length),
                  SizedBox(height: responsive.smallSpacing + 4),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pastReports.length,
                    itemBuilder: (context, index) {
                      return PriceReportCard(
                        report: pastReports[index],
                        onUpdate: () =>
                            _navigateToUpdateReport(pastReports[index]),
                        onDelete: () {
                          final id =
                              pastReports[index]['_id'] as String? ??
                              pastReports[index]['id'] as String? ??
                              '';
                          if (id.isNotEmpty) {
                            _deleteReport(id);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Cannot delete: Report ID not found',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
