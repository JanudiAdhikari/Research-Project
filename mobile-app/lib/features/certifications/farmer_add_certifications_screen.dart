import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'farmer_certification_details_screen.dart';

class FarmerAddCertificationScreen extends StatefulWidget {
  const FarmerAddCertificationScreen({super.key});

  @override
  State<FarmerAddCertificationScreen> createState() =>
      _FarmerAddCertificationScreenState();
}

class _FarmerAddCertificationScreenState extends State<FarmerAddCertificationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Field 1: Certification Type
  static const _certTypeOptions = <String>['SL-GAP', 'Other'];
  String? _certificationType; // holds selected / custom final value

  // Field 3: Issuing Body
  static const _issuingBodyOptions = <String>[
    'Department of Agriculture Sri Lanka',
    'Other'
  ];
  String? _issuingBody; // holds selected / custom final value

  // Field 2: Certificate Number
  final _certNumberCtrl = TextEditingController();

  // Field 4/5: Dates
  DateTime? _issueDate;
  DateTime? _expiryDate;

  // Field 6: Attachment
  File? _attachmentFile;
  String? _attachmentName;

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

  Future<void> _pickDate({
    required bool isIssueDate,
  }) async {
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

        // If expiry is set but now before issue date, clear expiry
        if (_expiryDate != null && _expiryDate!.isBefore(_issueDate!)) {
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

  Future<void> _pickAttachment() async {
    // Let user choose PDF via FilePicker, or image via ImagePicker
    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('Pick PDF'),
              onTap: () => Navigator.pop(ctx, 'pdf'),
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Pick Image'),
              onTap: () => Navigator.pop(ctx, 'image'),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(ctx, null),
            ),
          ],
        ),
      ),
    );

    if (choice == null) return;

    try {
      if (choice == 'pdf') {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: const ['pdf'],
        );
        if (result == null || result.files.single.path == null) return;

        setState(() {
          _attachmentFile = File(result.files.single.path!);
          _attachmentName = result.files.single.name;
        });
      } else if (choice == 'image') {
        final picker = ImagePicker();
        final XFile? img = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        if (img == null) return;

        setState(() {
          _attachmentFile = File(img.path);
          _attachmentName = img.name;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attachment failed: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _removeAttachment() {
    setState(() {
      _attachmentFile = null;
      _attachmentName = null;
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;

    if (_issueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select issue date'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select expiry date'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_issueDate != null && _expiryDate != null && _expiryDate!.isBefore(_issueDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expiry date cannot be before issue date'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    // Frontend only: simulate small delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final data = FarmerCertificationModel(
      certificationType: _certificationType!,
      certificateNumber: _certNumberCtrl.text.trim(),
      issuingBody: _issuingBody!,
      issueDate: _issueDate!,
      expiryDate: _expiryDate!,
      attachmentName: _attachmentName,
      status: 'Pending',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Submitted successfully'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() => _submitting = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FarmerCertificationDetailsScreen(model: data),
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
                    Text('Certification Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: 14),

                    // 1) Certification Type dropdown
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
                      validator: (v) {
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
                          if (custom == null) {
                            // if user cancels, keep current
                            setState(() {});
                            return;
                          }
                          setState(() => _certificationType = custom);
                        } else {
                          setState(() => _certificationType = val);
                        }
                      },
                    ),
                    if (_certificationType != null &&
                        !_certTypeOptions.contains(_certificationType))
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 18, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Selected: $_certificationType',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 14),

                    // 2) Certificate Number
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

                    // 3) Issuing Body dropdown
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
                      validator: (v) {
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
                          if (custom == null) {
                            setState(() {});
                            return;
                          }
                          setState(() => _issuingBody = custom);
                        } else {
                          setState(() => _issuingBody = val);
                        }
                      },
                    ),
                    if (_issuingBody != null &&
                        !_issuingBodyOptions.contains(_issuingBody))
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 18, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Selected: $_issuingBody',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 14),

                    // 4) Issue Date
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

                    // 5) Expiry Date
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
                          _expiryDate == null ? 'Select date' : _formatDate(_expiryDate),
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

              const SizedBox(height: 14),

              // 6) Attachment (optional)
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Attachment (Optional)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: 10),

                    if (_attachmentFile == null)
                      OutlinedButton.icon(
                        onPressed: _pickAttachment,
                        icon: const Icon(Icons.upload_file_outlined),
                        label: const Text('Upload PDF or Image'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green.shade700,
                          side: BorderSide(color: Colors.green.shade200, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade100),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.insert_drive_file_outlined),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _attachmentName ?? 'Attachment selected',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            IconButton(
                              onPressed: _removeAttachment,
                              icon: const Icon(Icons.close),
                              tooltip: 'Remove',
                            )
                          ],
                        ),
                      ),

                    const SizedBox(height: 8),
                    Text(
                      'You can attach a photo or PDF for manual verification later.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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

/// Simple frontend model (for now)
class FarmerCertificationModel {
  final String certificationType;
  final String certificateNumber;
  final String issuingBody;
  final DateTime issueDate;
  final DateTime expiryDate;
  final String? attachmentName;
  final String status;

  FarmerCertificationModel({
    required this.certificationType,
    required this.certificateNumber,
    required this.issuingBody,
    required this.issueDate,
    required this.expiryDate,
    required this.attachmentName,
    required this.status,
  });
}
