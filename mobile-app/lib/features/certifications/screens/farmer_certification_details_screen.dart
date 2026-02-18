import 'package:flutter/material.dart';
import '../models/certification_model.dart';
import '../services/certification_api.dart';

class FarmerCertificationDetailsScreen extends StatefulWidget {
  final String certId;
  final CertificationApi api;

  const FarmerCertificationDetailsScreen({
    super.key,
    required this.certId,
    required this.api,
  });

  @override
  State<FarmerCertificationDetailsScreen> createState() =>
      _FarmerCertificationDetailsScreenState();
}

class _FarmerCertificationDetailsScreenState
    extends State<FarmerCertificationDetailsScreen> {
  bool _loading = true;
  String? _error;
  CertificationModel? _cert;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _formatDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final c = await widget.api.getById(widget.certId);
      setState(() {
        _cert = c;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deleteIfAllowed() async {
    final c = _cert;
    if (c == null) return;

    if (c.status != 'pending') {
      _toast('Only pending certifications can be deleted');
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete'),
        content: const Text('Are you sure you want to delete this certificate?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await widget.api.deleteCertification(c.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deleted'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true); // tell dashboard to refresh if you want
    } catch (e) {
      _toast(e.toString());
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Certification Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
                        const SizedBox(height: 10),
                        const Text('Failed to load', style: TextStyle(fontWeight: FontWeight.w800)),
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
                )
              : _cert == null
                  ? const Center(child: Text('Not found'))
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _cert!.certificationType,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                _statusChip(_cert!.effectiveStatus),
                              ],
                            ),
                            const SizedBox(height: 14),

                            _row('Certificate Number', _cert!.certificateNumber),
                            _row('Issuing Body', _cert!.issuingBody),
                            _row('Issue Date', _formatDate(_cert!.issueDate)),
                            _row('Expiry Date', _formatDate(_cert!.expiryDate)),
                            _row('Submitted On', _formatDate(_cert!.createdAt)),
                            _row('Last Updated', _formatDate(_cert!.updatedAt)),

                            const SizedBox(height: 8),

                            if (_cert!.verifiedBy != null)
                              _row('Verified By', _cert!.verifiedBy!.toUpperCase()),
                            if (_cert!.verificationDate != null)
                              _row('Verification Date', _formatDate(_cert!.verificationDate!)),
                            if (_cert!.status == 'rejected' &&
                                _cert!.rejectionReason != null &&
                                _cert!.rejectionReason!.isNotEmpty)
                              _row('Rejection Reason', _cert!.rejectionReason!),

                            const Spacer(),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.arrow_back),
                                    label: const Text('Back'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.green.shade700,
                                      side: BorderSide(color: Colors.green.shade200, width: 1.5),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _deleteIfAllowed,
                                    icon: const Icon(Icons.delete_outline),
                                    label: const Text('Delete'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
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

    final label = status[0].toUpperCase() + status.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w700, color: fg, fontSize: 12),
      ),
    );
  }
}
