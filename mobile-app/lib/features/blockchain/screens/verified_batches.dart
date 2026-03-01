import 'package:flutter/material.dart';
import '../../../utils/responsive.dart';
import '../../../services/market_forecast/actual_price_data_service.dart';
import 'view_blockchain.dart';

class VerifiedBatchesScreen extends StatefulWidget {
  const VerifiedBatchesScreen({super.key});

  @override
  State<VerifiedBatchesScreen> createState() => _VerifiedBatchesScreenState();
}

class _VerifiedBatchesScreenState extends State<VerifiedBatchesScreen> {
  final ActualPriceDataService _service = ActualPriceDataService();
  List<Map<String, dynamic>> _batches = [];
  bool _loading = true;
  String? _error;

  static const Color _green = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    _fetchBatches();
  }

  String _normalizeStatus(dynamic s) {
    if (s == null) return '';
    return s
        .toString()
        .trim()
        .replaceAll(' ', '_')
        .replaceAll('-', '_')
        .toUpperCase();
  }

  // Fetch batches with status QR_GENERATED
  Future<void> _fetchBatches() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final all = await _service.fetchActualPriceData(limit: 300);

      final filtered = all.where((r) {
        final raw = r['currentStatus'] ?? r['status'] ?? '';
        return _normalizeStatus(raw) == 'QR_GENERATED';
      }).toList();

      setState(() {
        _batches = filtered;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // Utility to display batch ID or fallback
  String _displayId(Map<String, dynamic> r) {
    return (r['batchId'] ??
            r['batchNo'] ??
            r['batch'] ??
            r['id'] ??
            r['_id'] ??
            r['recordId'] ??
            'Unknown')
        .toString();
  }

  // Utility to safely display text fields with fallback
  String _safeText(dynamic v, [String fallback = '-']) {
    if (v == null) return fallback;
    final s = v.toString().trim();
    return s.isEmpty ? fallback : s;
  }

  // Widget for displaying a label + value pair with optional icon
  Widget _statusChip(Responsive responsive) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.smallSpacing + 6,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _green.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _green.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code_2_rounded, size: 14, color: _green),
          const SizedBox(width: 6),
          Text(
            'QR Generated',
            style: TextStyle(
              color: _green,
              fontWeight: FontWeight.w800,
              fontSize: responsive.smallFontSize,
            ),
          ),
        ],
      ),
    );
  }

  // Widget for displaying a batch card in the list
  Widget _batchCard(Responsive responsive, Map<String, dynamic> r) {
    final batchId = _displayId(r);
    final pepperType = _safeText(r['pepperType']);
    final qty = r['quantity'];

    String qtyText() {
      if (qty == null) return '-';
      if (qty is num) {
        final val = qty.toDouble();
        if (val == val.toInt()) return '${val.toInt()} kg';
        return '${val.toStringAsFixed(2)} kg';
      }
      return '${qty.toString()} kg';
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewBlockchainScreen(record: r),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(responsive.mediumSpacing),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left accent bar
            Container(
              width: 6,
              height: 64,
              decoration: BoxDecoration(
                color: _green,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            SizedBox(width: responsive.mediumSpacing),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Batch + Chip
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Batch: $batchId',
                          style: TextStyle(
                            fontSize: responsive.bodyFontSize + 1,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      _statusChip(responsive),
                    ],
                  ),
                  SizedBox(height: responsive.smallSpacing),

                  // Pepper type
                  Row(
                    children: [
                      const Icon(
                        Icons.grass_rounded,
                        size: 16,
                        color: Colors.black45,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          pepperType,
                          style: TextStyle(
                            fontSize: responsive.smallFontSize + 1,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.smallSpacing),

                  // Quantity
                  Row(
                    children: [
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          qtyText(),
                          style: TextStyle(
                            fontSize: responsive.smallFontSize + 1,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Select Batch'),
        backgroundColor: _green,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchBatches,
          child: Padding(
            padding: EdgeInsets.all(responsive.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: responsive.mediumSpacing),

                Text(
                  'Select a Batch to continue',
                  style: TextStyle(
                    fontSize: responsive.headingFontSize,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: responsive.smallSpacing),

                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(child: Text('Error: $_error'))
                      : _batches.isEmpty
                      ? const Center(child: Text('No Batches found.'))
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _batches.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: responsive.smallSpacing),
                          itemBuilder: (context, index) {
                            final r = _batches[index];
                            return _batchCard(responsive, r);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
