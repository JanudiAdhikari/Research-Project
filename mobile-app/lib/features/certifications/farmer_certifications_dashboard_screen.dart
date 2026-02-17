import 'package:flutter/material.dart';

import 'farmer_add_certifications_screen.dart';
import 'farmer_certification_details_screen.dart';

class FarmerCertificationsDashboardScreen extends StatefulWidget {
  const FarmerCertificationsDashboardScreen({super.key});

  @override
  State<FarmerCertificationsDashboardScreen> createState() =>
      _FarmerCertificationsDashboardScreenState();
}

class _FarmerCertificationsDashboardScreenState
    extends State<FarmerCertificationsDashboardScreen> {
  // Wrap model + submittedOn (frontend only)
  final List<CertificationItem> _items = [
    CertificationItem(
      model: FarmerCertificationModel(
        certificationType: 'SL-GAP',
        certificateNumber: 'SLGAP-12345',
        issuingBody: 'Department of Agriculture Sri Lanka',
        issueDate: DateTime(2025, 1, 10),
        expiryDate: DateTime(2026, 1, 10),
        attachmentName: null,
        status: 'Pending',
      ),
      submittedOn: DateTime(2026, 2, 1),
    ),
    CertificationItem(
      model: FarmerCertificationModel(
        certificationType: 'Organic',
        certificateNumber: 'ORG-88990',
        issuingBody: 'Control Union',
        issueDate: DateTime(2024, 10, 5),
        expiryDate: DateTime(2025, 10, 5),
        attachmentName: 'organic_cert.pdf',
        status: 'Verified',
      ),
      submittedOn: DateTime(2025, 11, 2),
    ),
  ];

  // Search + filter + sort
  final TextEditingController _searchCtrl = TextEditingController();
  String _statusFilter = 'All';
  String _sortMode = 'Newest';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openAdd() async {
    final created = await Navigator.push<FarmerCertificationModel>(
      context,
      MaterialPageRoute(builder: (_) => const FarmerAddCertificationScreen()),
    );

    if (created != null) {
      setState(() {
        _items.insert(
          0,
          CertificationItem(model: created, submittedOn: DateTime.now()),
        );
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Certificate added'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openDetails(CertificationItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FarmerCertificationDetailsScreen(model: item.model),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  bool _isExpired(DateTime expiry) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final exp = DateTime(expiry.year, expiry.month, expiry.day);
    return exp.isBefore(today);
  }

  bool _expiringSoon(DateTime expiry, {int days = 30}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final exp = DateTime(expiry.year, expiry.month, expiry.day);
    if (exp.isBefore(today)) return false;
    return exp.difference(today).inDays <= days;
  }

  List<CertificationItem> _filteredItems() {
    final q = _searchCtrl.text.trim().toLowerCase();

    List<CertificationItem> list = List.of(_items);

    // Derive status if expired
    String effectiveStatus(CertificationItem it) {
      if (_isExpired(it.model.expiryDate)) return 'Expired';
      return it.model.status;
    }

    // Filter by status
    if (_statusFilter != 'All') {
      list = list.where((it) {
        final s = effectiveStatus(it).toLowerCase();
        return s == _statusFilter.toLowerCase();
      }).toList();
    }

    // Search
    if (q.isNotEmpty) {
      list = list.where((it) {
        final m = it.model;
        final blob =
            '${m.certificationType} ${m.certificateNumber} ${m.issuingBody} ${m.status}'
                .toLowerCase();
        return blob.contains(q);
      }).toList();
    }

    // Sort
    if (_sortMode == 'Newest') {
      list.sort((a, b) => b.submittedOn.compareTo(a.submittedOn));
    } else if (_sortMode == 'Oldest') {
      list.sort((a, b) => a.submittedOn.compareTo(b.submittedOn));
    } else if (_sortMode == 'Expiry soon') {
      list.sort((a, b) => a.model.expiryDate.compareTo(b.model.expiryDate));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Certifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Add New',
            onPressed: _openAdd,
            icon: const Icon(Icons.add_circle_outline),
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
            child: filtered.isEmpty
                ? _emptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _certCard(item, () => _openDetails(item));
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
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search by type, number, issuing body...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchCtrl.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() {});
                    },
                  ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.green.shade100, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.green.shade100, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.green.shade300, width: 1.8),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _dropdownBox(
                label: 'Status',
                value: _statusFilter,
                items: const ['All', 'Pending', 'Verified', 'Rejected', 'Expired'],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _statusFilter = v);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _dropdownBox(
                label: 'Sort',
                value: _sortMode,
                items: const ['Newest', 'Oldest', 'Expiry soon'],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _sortMode = v);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dropdownBox({
    required String label,
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
          icon: const Icon(Icons.expand_more),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          hint: Text(label),
        ),
      ),
    );
  }

  Widget _emptyState() {
    // Empty can be because of filters or no items
    final hasAny = _items.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_outlined, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(
              hasAny ? 'No results found' : 'No certifications added yet',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasAny
                  ? 'Try changing your search or filters.'
                  : 'Tap "Add New" to submit your first certificate.',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: hasAny
                  ? () {
                      _searchCtrl.clear();
                      setState(() {
                        _statusFilter = 'All';
                        _sortMode = 'Newest';
                      });
                    }
                  : _openAdd,
              icon: Icon(hasAny ? Icons.refresh : Icons.add),
              label: Text(hasAny ? 'Reset Filters' : 'Add New Certificate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _certCard(CertificationItem item, VoidCallback onTap) {
    final c = item.model;

    final expired = _isExpired(c.expiryDate);
    final soon = _expiringSoon(c.expiryDate);

    final effectiveStatus = expired ? 'Expired' : c.status;

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
              child: Icon(Icons.verified_outlined, color: Colors.green.shade700),
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
                      _statusChip(effectiveStatus),
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
                        'Submitted: ${_formatDate(item.submittedOn)}',
                      ),
                      _metaChip(
                        Icons.event_available_outlined,
                        'Expiry: ${_formatDate(c.expiryDate)}',
                      ),
                      if (!expired && soon)
                        _metaChip(Icons.warning_amber_outlined, 'Expiring soon'),
                      if (c.attachmentName != null && c.attachmentName!.isNotEmpty)
                        _metaChip(Icons.attach_file_outlined, 'Attachment'),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(fontWeight: FontWeight.w800, color: fg, fontSize: 12),
      ),
    );
  }
}

/// Frontend wrapper: adds submittedOn without changing your model yet
class CertificationItem {
  final FarmerCertificationModel model;
  final DateTime submittedOn;

  CertificationItem({
    required this.model,
    required this.submittedOn,
  });
}
