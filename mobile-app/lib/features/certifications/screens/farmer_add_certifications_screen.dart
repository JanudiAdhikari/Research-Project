import 'package:flutter/material.dart';
import '../models/certification_model.dart';
import '../services/certification_api.dart';

class FarmerAddCertificationScreen extends StatefulWidget {
  final CertificationApi api;

  const FarmerAddCertificationScreen({super.key, required this.api});

  @override
  State<FarmerAddCertificationScreen> createState() =>
      _FarmerAddCertificationScreenState();
}

class _FarmerAddCertificationScreenState extends State<FarmerAddCertificationScreen> {
  final _formKey = GlobalKey<FormState>();

  static const _certTypeOptions = <String>['SL-GAP', 'Other'];
  String? _certificationType;

  static const _issuingBodyOptions = <String>[
    'Department of Agriculture Sri Lanka',
    'Other'
  ];
  String? _issuingBody;

  final _certNumberCtrl = TextEditingController();

  DateTime? _issueDate;
  DateTime? _expiryDate;

  bool _submitting = false;

  @override
  void dispose() {
    _certNumberCtrl.dispose();
    super.dispose();
  }

  Future<String?> _showOtherInputDialog({
    required String title,
    required String hint,
  }) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => Navigator.pop(ctx, ctrl.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Enter'),
          ),
        ],
      ),
    );
    return (result == null || result.trim().isEmpty) ? null : result.trim();
  }

  Future<void> _pickDate({required bool isIssueDate}) async {
    final now = DateTime.now();
    final initial = isIssueDate
        ? (_issueDate ?? now)
        : (_expiryDate ?? (_issueDate ?? now));

    final firstDate = DateTime(now.year - 10);
    final lastDate = DateTime(now.year + 20);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        child: child!,
      ),
    );

    if (picked == null) return;

    setState(() {
      if (isIssueDate) {
        _issueDate = picked;
        if (_expiryDate != null && !_expiryDate!.isAfter(_issueDate!)) {
          _expiryDate = null;
        }
      } else {
        _expiryDate = picked;
      }
    });
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;

    if (_issueDate == null) {
      _toast('Please select issue date');
      return;
    }
    if (_expiryDate == null) {
      _toast('Please select expiry date');
      return;
    }
    if (!_expiryDate!.isAfter(_issueDate!)) {
      _toast('Expiry date must be after issue date');
      return;
    }

    setState(() => _submitting = true);

    try {
      final created = await widget.api.createCertification(
        certificationType: _certificationType!.trim(),
        certificateNumber: _certNumberCtrl.text.trim(),
        issuingBody: _issuingBody!.trim(),
        issueDate: _issueDate!,
        expiryDate: _expiryDate!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Submitted successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // return to dashboard with created item
      Navigator.pop<CertificationModel>(context, created);
    } catch (e) {
      if (!mounted) return;
      _toast(e.toString());
      setState(() => _submitting = false);
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
        title: const Text('Add Certification'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Certification Details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      value: (_certificationType == null ||
                              _certTypeOptions.contains(_certificationType))
                          ? _certificationType
                          : 'Other',
                      items: _certTypeOptions
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      decoration: InputDecoration(
                        labelText: 'Certification Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.verified_outlined),
                      ),
                      validator: (_) {
                        if (_certificationType == null ||
                            _certificationType!.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                      onChanged: (val) async {
                        if (val == null) return;

                        if (val == 'Other') {
                          final custom = await _showOtherInputDialog(
                            title: 'Other Certification Type',
                            hint: 'Type certification name',
                          );
                          if (custom == null) return;
                          setState(() => _certificationType = custom);
                        } else {
                          setState(() => _certificationType = val);
                        }
                      },
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _certNumberCtrl,
                      decoration: InputDecoration(
                        labelText: 'Certificate Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.confirmation_number_outlined),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),

                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      value: (_issuingBody == null ||
                              _issuingBodyOptions.contains(_issuingBody))
                          ? _issuingBody
                          : 'Other',
                      items: _issuingBodyOptions
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      decoration: InputDecoration(
                        labelText: 'Issuing Body',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.account_balance_outlined),
                      ),
                      validator: (_) {
                        if (_issuingBody == null || _issuingBody!.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                      onChanged: (val) async {
                        if (val == null) return;

                        if (val == 'Other') {
                          final custom = await _showOtherInputDialog(
                            title: 'Other Issuing Body',
                            hint: 'Type issuing organization',
                          );
                          if (custom == null) return;
                          setState(() => _issuingBody = custom);
                        } else {
                          setState(() => _issuingBody = val);
                        }
                      },
                    ),

                    const SizedBox(height: 14),

                    InkWell(
                      onTap: () => _pickDate(isIssueDate: true),
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Issue Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.event_outlined),
                        ),
                        child: Text(
                          _issueDate == null ? 'Select date' : _formatDate(_issueDate),
                          style: TextStyle(
                            color: _issueDate == null
                                ? Colors.grey.shade600
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    InkWell(
                      onTap: () => _pickDate(isIssueDate: false),
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Expiry Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.event_available_outlined),
                        ),
                        child: Text(
                          _expiryDate == null
                              ? 'Select date'
                              : _formatDate(_expiryDate),
                          style: TextStyle(
                            color: _expiryDate == null
                                ? Colors.grey.shade600
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(_submitting ? 'Submitting...' : 'Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }
}
