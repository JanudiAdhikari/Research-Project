import 'package:flutter/material.dart';
import 'farmer_add_certifications_screen.dart';
import 'farmer_certification_details_screen.dart';

class ExporterCertificationsDashboardScreen extends StatefulWidget {
  const ExporterCertificationsDashboardScreen({super.key});

  @override
  State<ExporterCertificationsDashboardScreen> createState() =>
      _ExporterCertificationsDashboardScreenState();
}

class _ExporterCertificationsDashboardScreenState
    extends State<ExporterCertificationsDashboardScreen> {
  // Frontend only: dummy list
  final List<FarmerCertificationModel> _certs = [
    FarmerCertificationModel(
      certificationType: 'SL-GAP',
      certificateNumber: 'SLGAP-12345',
      issuingBody: 'Department of Agriculture Sri Lanka',
      issueDate: DateTime(2025, 1, 10),
      expiryDate: DateTime(2026, 1, 10),
      attachmentName: null,
      status: 'Pending',
    ),
  ];

  void _openAdd() async {
    // For now: navigate and get the created cert back
    final created = await Navigator.push<FarmerCertificationModel>(
      context,
      MaterialPageRoute(builder: (_) => const FarmerAddCertificationScreen()),
    );

    if (created != null) {
      setState(() => _certs.insert(0, created));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Certificate added'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openDetails(FarmerCertificationModel model) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FarmerCertificationDetailsScreen(model: model),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text('Add New'),
      ),
      body: _certs.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_outlined,
                        size: 60, color: Colors.grey.shade400),
                    const SizedBox(height: 10),
                    Text(
                      'No certifications added yet',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap "Add New" to submit your first certificate.',
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: _openAdd,
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Certificate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _certs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final c = _certs[index];
                return _certCard(c, () => _openDetails(c));
              },
            ),
    );
  }

  Widget _certCard(FarmerCertificationModel c, VoidCallback onTap) {
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
                  Text(
                    c.certificationType,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
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
                ],
              ),
            ),
            const SizedBox(width: 10),
            _statusChip(c.status),
          ],
        ),
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
