import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/responsive.dart';
import 'past_price_reports.dart';
import '../../../services/market_forecast/actual_price_data_service.dart';
import '../../../services/market_service.dart';
import '../../../services/market_forecast/quality_check_service.dart';
import '../widgets/description_info_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/date_picker_field.dart';
import '../widgets/marketplace_prompt_dialog.dart';

class ActualPriceData extends StatefulWidget {
  final Map<String, dynamic>? reportData;

  const ActualPriceData({super.key, this.reportData});

  @override
  State<ActualPriceData> createState() => _ActualPriceDataState();
}

class _ActualPriceDataState extends State<ActualPriceData> {
  final _formKey = GlobalKey<FormState>();
  final ActualPriceDataService _actualPriceDataService =
      ActualPriceDataService();
  final MarketService _marketService = MarketService();
  final QualityCheckService _qualityCheckService = QualityCheckService();

  // Form controllers
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _varietyController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();

  // Edit mode
  String? _reportId;
  String?
  _newlyCreatedReportId; // Store ID of newly created report for marketplace linking
  bool get _isEditMode => _reportId != null;

  // Store submitted data for marketplace addition
  Map<String, dynamic>? _lastSubmittedData;

  // Dropdown values
  String? _selectedVariety;
  String? _selectedGrade;
  String? _selectedDistrict;
  DateTime _selectedDate = DateTime.now();

  final List<String> _districts = [
    'Badulla',
    'Colombo',
    'Galle',
    'Gampaha',
    'Hambantota',
    'Kalutara',
    'Kandy',
    'Kegalle',
    'Kurunegala',
    'Matale',
    'Matara',
    'Monaragala',
    'Nuwara Eliya',
    'Ratnapura',
  ];

  bool _isSubmitting = false;

  bool showErrors = false;
  final Color _errorColor = Colors.grey.shade300;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  // Quality check batches
  List<Map<String, dynamic>> _batches = [];
  String? _selectedBatchId;

  @override
  void initState() {
    super.initState();
    _loadReportData();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    try {
      final items = await _qualityCheckService.fetchMyQualityChecks();
      if (!mounted) return;
      setState(() {
        _batches = items;
      });
    } catch (e) {
      debugPrint('Failed to load batches: $e');
    }
  }

  // Load existing report data into form fields if in edit mode
  void _loadReportData() {
    if (widget.reportData != null) {
      final report = widget.reportData!;
      _reportId = report['_id'] as String? ?? report['id'] as String?;
      _selectedBatchId = report['batchId'] as String?;
      _priceController.text = (report['pricePerKg'] as num?)?.toString() ?? '';
      _quantityController.text = (report['quantity'] as num?)?.toString() ?? '';
      _notesController.text = report['notes'] as String? ?? '';
      _selectedVariety = report['pepperType'] as String?;
      _selectedGrade = report['grade'] as String?;
      _varietyController.text = _selectedVariety ?? '';
      _gradeController.text = _selectedGrade ?? '';
      _selectedDistrict = report['district'] as String?;

      final saleDateStr = report['saleDate'] as String?;
      if (saleDateStr != null && saleDateStr.isNotEmpty) {
        try {
          _selectedDate = DateTime.parse(saleDateStr);
        } catch (_) {
          _selectedDate = DateTime.now();
        }
      }
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _priceController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _varietyController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Update Price Details' : 'Real Price Details',
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Reset',
            onPressed: _resetForm,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(responsive.mediumSpacing),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DescriptionInfoCard(
                title: 'Market Price Details',
                description: 'Enter the price details of your pepper batch',
                icon: Icons.edit_note_rounded,
              ),
              SizedBox(height: responsive.mediumSpacing),
              _buildViewPastReportsButton(responsive),
              SizedBox(height: responsive.largeSpacing),
              _buildFormSection(responsive),
              SizedBox(height: responsive.largeSpacing),
              _buildSubmitButton(responsive),
              SizedBox(height: responsive.mediumSpacing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewPastReportsButton(Responsive responsive) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PastPriceReportsScreen(),
            ),
          );
        },
        icon: const Icon(Icons.history_rounded, size: 20),
        label: Text(
          'View My Past Records',
          style: TextStyle(
            fontSize: responsive.bodyFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF2E7D32),
          side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
          padding: EdgeInsets.symmetric(vertical: responsive.smallSpacing + 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection(Responsive responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.mediumSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Details',
            style: TextStyle(
              fontSize: responsive.bodyFontSize + 3,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: responsive.mediumSpacing),

          if (_batches.isNotEmpty) ...[
            SizedBox(height: responsive.smallSpacing),
            _buildDropdownField(
              responsive,
              label: 'Batch ID',
              icon: Icons.inventory_2_rounded,
              value: _selectedBatchId,
              items: _batches.map((b) => b['batchId'] as String).toList(),
              hint: 'Select Batch ID',
              readOnly: _isEditMode,
              onChanged: (value) {
                setState(() {
                  _selectedBatchId = value;
                  if (value == null) {
                    _selectedVariety = null;
                    _selectedGrade = null;
                    _varietyController.text = '';
                    _gradeController.text = '';
                    _quantityController.text = '';
                  } else {
                    final batch = _batches.firstWhere(
                      (b) => b['batchId'] == value,
                    );
                    final batchInfo = batch['batch'] ?? {};
                    final pepperType =
                        (batchInfo['pepperType'] as String?) ?? '';

                    _selectedVariety = pepperType.isNotEmpty
                        ? (pepperType.toLowerCase() == 'black'
                              ? 'Black Pepper'
                              : 'White Pepper')
                        : null;

                    _varietyController.text = _selectedVariety ?? '';

                    final gradeVal = batch['grade'] as String?;
                    _selectedGrade = gradeVal;
                    _gradeController.text = _selectedGrade ?? '';

                    final weightGrams = (batchInfo['batchWeightGrams'] as num?)
                        ?.toDouble();
                    if (weightGrams != null) {
                      final kg = weightGrams / 1000.0;
                      _quantityController.text = kg.toStringAsFixed(2);
                    }
                  }
                });
              },
            ),
            SizedBox(height: responsive.mediumSpacing),
          ],

          DatePickerField(
            label: 'Sale Date',
            selectedDate: _selectedDate,
            onDateChanged: (date) => setState(() => _selectedDate = date),
          ),
          SizedBox(height: responsive.mediumSpacing),

          CustomTextField(
            controller: _varietyController,
            label: 'Pepper Variety',
            hint: '',
            keyboardType: TextInputType.text,
            readOnly: true,
          ),
          SizedBox(height: responsive.mediumSpacing),

          CustomTextField(
            controller: _gradeController,
            label: 'Grade',
            hint: '',
            keyboardType: TextInputType.text,
            readOnly: true,
          ),
          SizedBox(height: responsive.mediumSpacing),

          CustomTextField(
            controller: _priceController,
            label: 'Price per kg (LKR)',
            hint: 'Enter price per kg',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (_) => null,
          ),
          SizedBox(height: responsive.mediumSpacing),

          CustomTextField(
            controller: _quantityController,
            label: 'Quantity (kg)',
            hint: '',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            readOnly: true,
            validator: (_) => null,
          ),
          SizedBox(height: responsive.mediumSpacing),

          _buildCustomDropdownField(
            responsive,
            title: 'District',
            value: _selectedDistrict,
            items: _districts,
          ),
          SizedBox(height: responsive.mediumSpacing),

          CustomTextField(
            controller: _notesController,
            label: 'Additional Notes (Optional)',
            hint: 'Any additional information...',
            keyboardType: TextInputType.multiline,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    Responsive responsive, {
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
    bool readOnly = false,
  }) {
    final key = GlobalKey();
    final double horizontalPadding = responsive.smallSpacing + 8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            key: key,
            onTap: readOnly
                ? null
                : () => _toggleDropdown(key, items, value, onChanged),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (value == null) ? _errorColor : Colors.grey.shade300,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value ?? hint,
                    style: TextStyle(
                      fontSize: responsive.bodyFontSize,
                      fontWeight: FontWeight.w600,
                      color: value == null
                          ? Colors.grey.shade600
                          : Colors.black87,
                    ),
                  ),
                  readOnly
                      ? const Icon(Icons.lock_outline, color: Colors.grey)
                      : const Icon(
                          Icons.arrow_drop_down_rounded,
                          color: Colors.black87,
                        ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomDropdownField(
    Responsive responsive, {
    required String title,
    required String? value,
    required List<String> items,
  }) {
    final key = GlobalKey();
    final double horizontalPadding = responsive.smallSpacing + 8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            key: key,
            onTap: () => _toggleDropdown(key, items, value, (newValue) {
              setState(() {
                _selectedDistrict = newValue;
              });
            }),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (value == null) ? _errorColor : Colors.grey.shade300,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value ?? 'Select $title',
                    style: TextStyle(
                      fontSize: responsive.bodyFontSize,
                      fontWeight: FontWeight.w600,
                      color: value == null
                          ? Colors.grey.shade600
                          : Colors.black87,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleDropdown(
    GlobalKey key,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      return;
    }

    const double itemHeight = 48.0;
    final double dropdownHeight = items.length > 3
        ? itemHeight * 3
        : itemHeight * items.length;

    final renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: size.width,
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: dropdownHeight),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: items
                  .map(
                    (item) => SizedBox(
                      height: itemHeight,
                      child: ListTile(
                        title: Text(item),
                        onTap: () {
                          onChanged(item);
                          _overlayEntry!.remove();
                          _overlayEntry = null;
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildSubmitButton(Responsive responsive) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          padding: EdgeInsets.symmetric(vertical: responsive.mediumSpacing),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isEditMode ? 'Update Price Data' : 'Submit Price Data',
                    style: TextStyle(
                      fontSize: responsive.bodyFontSize + 1,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Simple validation — show friendly message if the user submits an empty form
  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    // Check whether relevant inputs are empty / unset
    final bool priceEmpty = _priceController.text.trim().isEmpty;
    final bool quantityEmpty = _quantityController.text.trim().isEmpty;
    final bool notesEmpty = _notesController.text.trim().isEmpty;
    final bool varietyEmpty =
        (_selectedVariety == null || _selectedVariety!.trim().isEmpty) &&
        _varietyController.text.trim().isEmpty;
    final bool gradeEmpty =
        (_selectedGrade == null || _selectedGrade!.trim().isEmpty) &&
        _gradeController.text.trim().isEmpty;
    final bool districtEmpty =
        _selectedDistrict == null || _selectedDistrict!.trim().isEmpty;
    final bool batchEmpty =
        _selectedBatchId == null || _selectedBatchId!.trim().isEmpty;

    if (priceEmpty &&
        quantityEmpty &&
        notesEmpty &&
        varietyEmpty &&
        gradeEmpty &&
        districtEmpty &&
        batchEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('please fill the form')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Determine final values for variety and grade
    final gradeValue = (_selectedGrade != null && _selectedGrade!.isNotEmpty)
        ? _selectedGrade
        : (_gradeController.text.trim().isNotEmpty
              ? _gradeController.text.trim()
              : null);

    final pepperValue =
        (_selectedVariety != null && _selectedVariety!.isNotEmpty)
        ? _selectedVariety
        : (_varietyController.text.trim().isNotEmpty
              ? _varietyController.text.trim()
              : null);

    //  Parse price and quantity to double
    final parsedPrice = double.tryParse(_priceController.text.trim());
    final parsedQuantity = double.tryParse(_quantityController.text.trim());

    final notes = _notesController.text.trim();
    final districtValue =
        (_selectedDistrict != null && _selectedDistrict!.trim().isNotEmpty)
        ? _selectedDistrict!.trim()
        : null;

    // Payload to sent to backend
    final payload = <String, dynamic>{
      'saleDate': _selectedDate.toIso8601String(),
      'pepperType': pepperValue,
      'grade': gradeValue,
      'district': districtValue,
      'batchId': _selectedBatchId,
      'pricePerKg': parsedPrice,
      'quantity': parsedQuantity,
      'notes': notes.isNotEmpty ? notes : null,
    };

    try {
      if (_isEditMode && _reportId != null) {
        final updatedReport = await _actualPriceDataService
            .updateActualPriceData(_reportId!, payload);

        _lastSubmittedData = Map<String, dynamic>.from(payload);

        // If the record is already linked to a marketplace product, update it too
        final marketplaceProductId =
            updatedReport['marketplaceProductId'] ??
            (widget.reportData != null
                ? widget.reportData!['marketplaceProductId']
                : null);

        if (marketplaceProductId != null && parsedPrice != null) {
          try {
            await _marketService
                .updateProduct(marketplaceProductId.toString(), {
                  'price': parsedPrice,
                  'name': pepperValue ?? _lastSubmittedData!['pepperType'],
                  'unit': 'kg',
                });
          } catch (e) {
            debugPrint('Failed to update marketplace product: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Marketplace update failed: $e')),
              );
            }
          }
        }
      } else {
        final createdReport = await _actualPriceDataService
            .createActualPriceData(payload);

        _newlyCreatedReportId =
            createdReport['_id'] as String? ?? createdReport['id'] as String?;
        _lastSubmittedData = Map<String, dynamic>.from(payload);
      }

      _clearFormFieldsPreserveSubmission();

      if (!mounted) return;

      if (_isEditMode) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green.shade600,
                  size: 28,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Success',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            content: const Text('Record updated successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        _showMarketplacePrompt();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode ? 'Update failed: $e' : 'Create failed: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMarketplacePrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MarketplacePromptDialog(
        onNoThanks: () {
          Navigator.pop(context);
          _resetForm();
        },
        onYesAdd: () {
          Navigator.pop(context);
          _handleAddToMarketplace();
        },
      ),
    );
  }

  Future<void> _handleAddToMarketplace() async {
    if (_lastSubmittedData == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('No data available to add to marketplace')),
            ],
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      _resetForm();
      return;
    }

    // loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 8,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey.shade50],
            ),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2E7D32).withOpacity(0.1),
                      const Color(0xFF2E7D32).withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF2E7D32).withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Adding to Marketplace',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your product is being processed...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                  ),
                ),
                child: Column(
                  children: [
                    _buildProgressStep(
                      'Validating Information',
                      true,
                      Icons.check_circle,
                    ),
                    const SizedBox(height: 12),
                    _buildProgressStep(
                      'Adding the Product',
                      false,
                      Icons.publish,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Please wait while we upload your product',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final productData = <String, dynamic>{
        'name': _lastSubmittedData!['pepperType'],
        'price': _lastSubmittedData!['pricePerKg'],
        'unit': 'kg',
      };

      final createdProduct = await _marketService.createProduct(productData);

      final reportIdToUpdate = _isEditMode ? _reportId : _newlyCreatedReportId;
      if (reportIdToUpdate != null && createdProduct.id.isNotEmpty) {
        await _actualPriceDataService.updateActualPriceData(reportIdToUpdate, {
          'marketplaceProductId': createdProduct.id,
        });
      }

      if (mounted) Navigator.pop(context);
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green.shade600,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Successfully Added!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your product has been added to the marketplace.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _resetForm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Failed to add to marketplace: $e')),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      _resetForm();
    }
  }

  void _clearFormFieldsPreserveSubmission() {
    _formKey.currentState?.reset();
    _priceController.clear();
    _quantityController.clear();
    _notesController.clear();
    setState(() {
      _selectedVariety = null;
      _selectedGrade = null;
      _selectedDistrict = null;
      _selectedDate = DateTime.now();
      showErrors = false;
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _priceController.clear();
    _quantityController.clear();
    _notesController.clear();
    _varietyController.clear();
    _gradeController.clear();
    setState(() {
      _selectedBatchId = null;
      _varietyController.clear();
      _gradeController.clear();
      _selectedVariety = null;
      _selectedGrade = null;
      _selectedDistrict = null;
      _selectedDate = DateTime.now();
      _newlyCreatedReportId = null;
      _lastSubmittedData = null;
    });
  }

  // Build progress steps
  Widget _buildProgressStep(String label, bool isCompleted, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFF2E7D32).withOpacity(0.15)
                : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isCompleted ? const Color(0xFF2E7D32) : Colors.grey.shade400,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isCompleted ? Colors.black87 : Colors.grey[600],
            ),
          ),
        ),
        if (isCompleted)
          const Icon(Icons.done, size: 18, color: Color(0xFF2E7D32))
        else
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
            ),
          ),
      ],
    );
  }
}
