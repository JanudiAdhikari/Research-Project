import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../services/blockchain_service.dart';
import '../../../services/market_forecast/actual_price_data_service.dart';

class QRGenerationScreen extends StatefulWidget {
  const QRGenerationScreen({super.key});

  @override
  State<QRGenerationScreen> createState() => _QRGenerationScreenState();
}

class _QRGenerationScreenState extends State<QRGenerationScreen> {
  final ActualPriceDataService _service = ActualPriceDataService();

  bool _loading = false; // page loading
  bool _actionLoading = false; // action overlay loading

  List<Map<String, dynamic>> _batches = [];
  List<Map<String, dynamic>> _filteredBatches = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _load(); // normal load shows page loader

    _searchController.addListener(() {
      if (!mounted) return;
      setState(() => _searchText = _searchController.text.trim());
      _applyFilter();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!mounted) return;
    if (!silent) setState(() => _loading = true);

    try {
      final all = await _service.fetchActualPriceData(limit: 300);

      final verified = all
          .where(
            (r) =>
                (r['currentStatus'] ?? '').toString().toUpperCase() ==
                'VERIFIED',
          )
          .toList();

      if (!mounted) return;
      setState(() {
        _batches = verified;
      });
      _applyFilter();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _batches = [];
        _filteredBatches = [];
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load batches: $e')));
    } finally {
      if (!mounted) return;
      if (!silent) setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    if (!mounted) return;

    final q = _searchText.toLowerCase();
    if (q.isEmpty) {
      setState(() {
        _filteredBatches = List<Map<String, dynamic>>.from(_batches);
      });
      return;
    }

    setState(() {
      _filteredBatches = _batches.where((b) {
        final batchId = _safeStr(b['batchId'], b['_id'] ?? '-').toLowerCase();
        return batchId.contains(q);
      }).toList();
    });
  }

  String _safeStr(dynamic v, [String fallback = '-']) {
    if (v == null) return fallback;
    final s = v.toString().trim();
    return s.isEmpty ? fallback : s;
  }

  String _formatDate(dynamic v) {
    if (v == null) return '-';
    final d = v is DateTime ? v : DateTime.tryParse(v.toString());
    if (d == null) return '-';
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  void _showPayload(Map<String, dynamic> batch) {
    final payload = jsonEncode({
      'batchId': batch['batchId'] ?? batch['_id'],
      'pepperType': batch['pepperType'] ?? '',
      'grade': batch['grade'] ?? '',
      'quantity': batch['quantity'] ?? '',
      'pricePerKg': batch['pricePerKg'] ?? '',
      'saleDate': batch['saleDate'] ?? '',
      'farmer': batch['farmerName'] ?? '',
    });

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('QR Payload'),
        content: SingleChildScrollView(child: SelectableText(payload)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmGenerateQr(String batchId) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Generate QR Code'),
        content: Text(
          'Are you sure you want to generate a QR code for batch $batchId?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _showSuccessPrompt(String batchId) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('QR Generated'),
        content: Text(
          'QR code for batch $batchId is ready. You can now share it with the exporter.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateQrForRecord(Map<String, dynamic> b) async {
    if (_actionLoading) return;

    final recordId = _safeStr(b['_id'], '');
    final batchId = _safeStr(b['batchId'], b['_id'] ?? '-');

    if (recordId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot generate QR: missing record id')),
      );
      return;
    }

    final ok = await _confirmGenerateQr(batchId);
    if (!ok) return;

    if (!mounted) return;
    setState(() => _actionLoading = true);

    try {
      await BlockchainService.generateQr(recordId);

      // remove instantly from the visible list
      if (mounted) {
        setState(() {
          _batches.removeWhere((x) => _safeStr(x['_id'], '') == recordId);
        });
        _applyFilter();
      }

      await _load(silent: true);

      // Success prompt
      await _showSuccessPrompt(batchId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to generate QR: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _actionLoading = false);
    }
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search by Batch No.',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _searchText.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  _searchController.clear();
                  FocusScope.of(context).unfocus();
                },
              ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFF2E7D32), width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _filteredBatches;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Generate QR'),
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _batches.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No verified batches found',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 12),
                      Expanded(
                        child: visible.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.search_off_rounded,
                                      size: 56,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'No batches match "$_searchText"',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () =>
                                          _searchController.clear(),
                                      child: const Text('Clear search'),
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _load,
                                child: ListView.separated(
                                  itemCount: visible.length + 1,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (ctx, idx) {
                                    if (idx == 0) {
                                      return Card(
                                        color: Colors.green.shade50,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: Color(0xFF2E7D32),
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  'Only verified batches are shown here. Tap a batch to generate its QR code.',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    final b = visible[idx - 1];
                                    final batchId = _safeStr(
                                      b['batchId'],
                                      b['_id'] ?? '-',
                                    );
                                    final date = _formatDate(b['saleDate']);

                                    return Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 2,
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                        leading: Container(
                                          width: 6,
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade400,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          batchId,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        subtitle: Text('Verified on: $date'),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.qr_code_2_rounded,
                                          ),
                                          onPressed: _actionLoading
                                              ? null
                                              : () => _showPayload(b),
                                        ),
                                        onTap: _actionLoading
                                            ? null
                                            : () => _generateQrForRecord(b),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
          ),
        ),

        if (_actionLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.12),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
