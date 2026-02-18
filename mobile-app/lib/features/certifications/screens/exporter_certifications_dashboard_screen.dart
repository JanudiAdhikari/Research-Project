import 'package:flutter/material.dart';
import '../../../config/api.dart';
import '../models/certification_model.dart';
import '../services/certification_api.dart';
import 'exporter_add_certifications_screen.dart';
import 'exporter_certification_details_screen.dart';

class ExporterCertificationsDashboardScreen extends StatefulWidget {
  const ExporterCertificationsDashboardScreen({super.key});

  @override
  State<ExporterCertificationsDashboardScreen> createState() =>
      _ExporterCertificationsDashboardScreenState();
}

class _ExporterCertificationsDashboardScreenState
    extends State<ExporterCertificationsDashboardScreen> {
  final _searchCtrl = TextEditingController();
  String _statusFilter = 'All'; // All, Pending, Verified, Rejected, Expired
  String _sortMode = 'Newest'; // Newest, Oldest, Expiry soon

  bool _loading = true;
  String? _error;
  List<CertificationModel> _items = [];

  late final CertificationApi _api;

  @override
  void initState() {
    super.initState();
    _api = CertificationApi(baseUrl: ApiConfig.baseUrl);
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  String _mapUiStatusToApiStatus(String ui) {
    final s = ui.toLowerCase();
    if (s == 'pending' || s == 'verified' || s == 'rejected') return s;
    return 'all'; // expired is UI-only
  }

  String _mapUiSortToApiSort(String ui) {
    final s = ui.toLowerCase();
    if (s.contains('oldest')) return 'oldest';
    if (s.contains('expiry')) return 'expiry';
    return 'newest';
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final apiStatus = _mapUiStatusToApiStatus(_statusFilter);
      final sort = _mapUiSortToApiSort(_sortMode);

      final list = await _api.getMyCertifications(
        status: apiStatus == 'all' ? null : apiStatus,
        q: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
        sort: sort,
      );

      // UI-side "Expired" filter
      List<CertificationModel> finalList = list;

      if (_statusFilter.toLowerCase() == 'expired') {
        finalList = list.where((e) => e.isExpired).toList();
      } else if (_statusFilter.toLowerCase() == 'all') {
        finalList = list;
      } else if (['pending', 'verified', 'rejected']
          .contains(_statusFilter.toLowerCase())) {
        // backend filtered by status already; remove expired just in case
        finalList = list.where((e) => !e.isExpired).toList();
      }

      setState(() {
        _items = finalList;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openAdd() async {
    final created = await Navigator.push<CertificationModel>(
      context,
      MaterialPageRoute(
        builder: (_) => ExporterAddCertificationScreen(api: _api),
      ),
    );

    if (created != null) {
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Certificate submitted'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openDetails(CertificationModel model) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExporterCertificationDetailsScreen(
          certId: model.id,
          api: _api,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Certifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text('Add New'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSearchAndFilters(),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _errorState()
                    : _items.isEmpty
                        ? _emptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final c = _items[index];
                              return _certCard(c, () => _openDetails(c));
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        TextField(
          controller: _searchCtrl,
          onSubmitted: (_) => _load(),
          decoration: InputDecoration(
            hintText: 'Search by type, number, issuing body...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.tune),
              onPressed: _load,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _dropdownBox(
                value: _statusFilter,
                items: const [
                  'All',
                  'Pending',
                  'Verified',
                  'Rejected',
                  'Expired'
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _statusFilter = v);
                  _load();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _dropdownBox(
                value: _sortMode,
                items: const ['Newest', 'Oldest', 'Expiry soon'],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _sortMode = v);
                  _load();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dropdownBox({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.shade100, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
            const SizedBox(height: 10),
            Text(
              'Failed to load',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_outlined, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(
              'No certifications found',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _openAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add New Certificate'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _certCard(CertificationModel c, VoidCallback onTap) {
    final displayStatus = c.effectiveStatus;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade100, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  Icon(Icons.verified_outlined, color: Colors.green.shade700),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.certificationType,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      _statusChip(displayStatus),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'No: ${c.certificateNumber}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    c.issuingBody,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _metaChip(
                        Icons.schedule_outlined,
                        'Submitted: ${_formatDate(c.createdAt)}',
                      ),
                      _metaChip(
                        Icons.event_available_outlined,
                        'Expiry: ${_formatDate(c.expiryDate)}',
                      ),
                      if (c.status == "rejected" &&
                          (c.rejectionReason ?? '').trim().isNotEmpty)
                        _metaChip(
                          Icons.info_outline,
                          'Reason: ${c.rejectionReason}',
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

  Widget _metaChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final s = status.toLowerCase();
    Color bg;
    Color fg;

    if (s.contains('pending')) {
      bg = Colors.orange.shade50;
      fg = Colors.orange.shade800;
    } else if (s.contains('verified')) {
      bg = Colors.green.shade50;
      fg = Colors.green.shade800;
    } else if (s.contains('expired')) {
      bg = Colors.grey.shade200;
      fg = Colors.grey.shade800;
    } else {
      bg = Colors.red.shade50;
      fg = Colors.red.shade800;
    }

    final label = status.isEmpty
        ? status
        : status[0].toUpperCase() + status.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w800, color: fg, fontSize: 12),
      ),
    );
  }
}
