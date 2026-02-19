import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/responsive.dart';
import 'past_price_reports.dart';
import '../../../services/market_forecast/actual_price_data_service.dart';
import '../../../services/market_service.dart';
import '../../../models/market_product.dart';
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

  // Form controllers
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

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

  // Dropdown options
  final List<String> _varieties = ['Black Pepper', 'White Pepper'];

  final List<String> _grades = ['Grade 1', 'Grade 2', 'Grade 3'];

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
  final String _requiredSuffix = 'is required';
  final Color _errorColor = Colors.red.shade400;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  String _requiredMessageFor(String label) => '$label $_requiredSuffix';

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  // Load existing report data into form fields if in edit mode
  void _loadReportData() {
    if (widget.reportData != null) {
      final report = widget.reportData!;
      _reportId = report['_id'] as String? ?? report['id'] as String?;
      _priceController.text = (report['pricePerKg'] as num?)?.toString() ?? '';
      _quantityController.text = (report['quantity'] as num?)?.toString() ?? '';
      _notesController.text = report['notes'] as String? ?? '';
      _selectedVariety = report['pepperType'] as String?;
      _selectedGrade = report['grade'] as String?;
      _selectedDistrict = report['district'] as String?;

      final saleDateStr = report['saleDate'] as String?;
      if (saleDateStr != null && saleDateStr.isNotEmpty) {
        try {
          _selectedDate = DateTime.parse(saleDateStr);
        } catch (e) {
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
                description:
                    'Enter the actual price details of your pepper batch',
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

  // Button to navigate to the Past Sales Reports
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
          'View My Past Sales Details',
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

  // Main form section with all input fields and dropdowns
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

          // Date Picker
          DatePickerField(
            label: 'Sale Date',
            selectedDate: _selectedDate,
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          SizedBox(height: responsive.mediumSpacing),

          // Variety Dropdown
          _buildDropdownField(
            responsive,
            label: 'Pepper Variety',
            icon: Icons.grain_rounded,
            value: _selectedVariety,
            items: _varieties,
            hint: 'Select pepper variety',
            onChanged: (value) {
              setState(() {
                _selectedVariety = value;
              });
            },
          ),
          SizedBox(height: responsive.mediumSpacing),

          // Grade Dropdown
          _buildDropdownField(
            responsive,
            label: 'Grade',
            icon: Icons.star_rounded,
            value: _selectedGrade,
            items: _grades,
            hint: 'Select grade',
            onChanged: (value) {
              setState(() {
                _selectedGrade = value;
              });
            },
          ),
          SizedBox(height: responsive.mediumSpacing),

          // Price Input
          CustomTextField(
            controller: _priceController,
            label: 'Price per kg (LKR)',
            hint: 'Enter price per kg',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            showErrors: showErrors,
            errorColor: _errorColor,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return _requiredMessageFor('Price per kg (LKR)');
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          SizedBox(height: responsive.mediumSpacing),

          // Quantity Input (in kg)
          CustomTextField(
            controller: _quantityController,
            label: 'Quantity (kg)',
            hint: 'Enter quantity in kg',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            showErrors: showErrors,
            errorColor: _errorColor,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return _requiredMessageFor('Quantity (kg)');
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          SizedBox(height: responsive.mediumSpacing),

          // District Dropdown
          _buildCustomDropdownField(
            responsive,
            title: 'District',
            value: _selectedDistrict,
            items: _districts,
          ),
          SizedBox(height: responsive.mediumSpacing),

          // Notes Input (Optional)
          CustomTextField(
            controller: _notesController,
            label: 'Additional Notes (Optional)',
            hint: 'Any additional information...',
            keyboardType: TextInputType.multiline,
            showErrors: showErrors,
            errorColor: _errorColor,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  // Dropdown field builder
  Widget _buildDropdownField(
    Responsive responsive, {
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
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
            onTap: () => _toggleDropdown(key, items, value, onChanged),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (showErrors && value == null)
                      ? _errorColor
                      : Colors.grey.shade300,
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
        if (showErrors && value == null)
          Padding(
            padding: EdgeInsets.only(top: 6, left: horizontalPadding),
            child: Text(
              _requiredMessageFor(label),
              style: TextStyle(color: _errorColor, fontSize: 12),
            ),
          ),
      ],
    );
  }

  // Custom dropdown field builder
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
                  color: (showErrors && value == null)
                      ? _errorColor
                      : Colors.grey.shade300,
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
        if (showErrors && value == null)
          Padding(
            padding: EdgeInsets.only(top: 6, left: horizontalPadding),
            child: Text(
              _requiredMessageFor(title),
              style: TextStyle(color: _errorColor, fontSize: 12),
            ),
          ),
      ],
    );
  }

  // Toggle dropdown overlay
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

    // Height of a single item
    const double itemHeight = 48.0;
    // Show max 3 items; scroll if more
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

  // Submit button with loading state and success feedback
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
            ? SizedBox(
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
                  Icon(
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

  // Handle form submission
  void _handleSubmit() async {
    setState(() {
      showErrors = true;
    });
    // Validate form
    final isFormValid = _formKey.currentState?.validate() ?? false;
    final hasDropdowns =
        _selectedVariety != null &&
        _selectedGrade != null &&
        _selectedDistrict != null;

    if (isFormValid && hasDropdowns) {
      setState(() {
        _isSubmitting = true;
      });
      final notes = _notesController.text.trim();
      final payload = <String, dynamic>{
        'saleDate': _selectedDate.toIso8601String(),
        'pepperType': _selectedVariety,
        'grade': _selectedGrade,
        'district': _selectedDistrict,
        'pricePerKg': double.parse(_priceController.text.trim()),
        'quantity': double.parse(_quantityController.text.trim()),
        if (notes.isNotEmpty) 'notes': notes,
      };

      try {
        if (_isEditMode && _reportId != null) {
          await _actualPriceDataService.updateActualPriceData(
            _reportId!,
            payload,
          );
          // Store submitted data for marketplace sync
          _lastSubmittedData = Map<String, dynamic>.from(payload);
          // Sync marketplace product with updated details
          await _syncMarketplaceOnUpdate();
        } else {
          final createdReport = await _actualPriceDataService
              .createActualPriceData(payload);
          // Capture the newly created report ID for marketplace linking
          _newlyCreatedReportId =
              createdReport['_id'] as String? ?? createdReport['id'] as String?;
          // Store submitted data for marketplace addition
          _lastSubmittedData = Map<String, dynamic>.from(payload);
        }
        if (!mounted) return;

        if (_isEditMode) {
          // Simple success dialog for updates
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
                  Text(
                    'Success',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              content: Text('Record updated successfully.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true); // Return to previous screen
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Marketplace prompt for new submissions
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
  }

  // Syncs marketplace products with updated price details
  Future<void> _syncMarketplaceOnUpdate() async {
    try {
      if (_lastSubmittedData == null || _selectedVariety == null) {
        return; // No data to sync
      }

      // Fetch all marketplace products
      final products = await _marketService.fetchProducts();

      // Find product with matching pepper variety name
      MarketProduct? marketProduct;
      try {
        marketProduct = products.firstWhere(
          (p) => p.name.toLowerCase() == _selectedVariety?.toLowerCase(),
        );
      } catch (e) {
        // Product not found in marketplace, which is fine
        marketProduct = null;
      }

      if (marketProduct != null && marketProduct.id.isNotEmpty) {
        // Update the marketplace product with new price and details
        final updatedData = <String, dynamic>{
          'name': _lastSubmittedData!['pepperType'],
          'price': _lastSubmittedData!['pricePerKg'],
          'unit': 'kg',
          // Include additional details
          'quantity': _lastSubmittedData!['quantity'],
          'grade': _lastSubmittedData!['grade'],
          'district': _lastSubmittedData!['district'],
        };

        await _marketService.updateProduct(marketProduct.id, updatedData);
      }
    } catch (e) {
      // Log error without blocking the update process
      print('Marketplace sync error: $e');
    }
  }

  // Show marketplace prompt after successful submission
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

  // Handle adding product to marketplace
  Future<void> _handleAddToMarketplace() async {
    if (_lastSubmittedData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('No data available to add to marketplace')),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      _resetForm();
      return;
    }

    // Show loading indicator
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
              // Animated loading icon
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
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Main text
              Text(
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

              // Subtitle
              Text(
                'Your product is being processed...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Progress steps
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

              // Hint text
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
      // Prepare marketplace product data
      final productData = <String, dynamic>{
        'name': _lastSubmittedData!['pepperType'],
        'price': _lastSubmittedData!['pricePerKg'],
        'unit': 'kg',
      };

      // Create product in marketplace
      final createdProduct = await _marketService.createProduct(productData);

      // Update report with marketplace product ID (use either existing report ID or newly created one)
      final reportIdToUpdate = _isEditMode ? _reportId : _newlyCreatedReportId;
      if (reportIdToUpdate != null && createdProduct.id.isNotEmpty) {
        await _actualPriceDataService.updateActualPriceData(reportIdToUpdate, {
          'marketplaceProductId': createdProduct.id,
        });
      }

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (!mounted) return;

      // Show success dialog
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
                Text(
                  'Successfully Added!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your product has been added to the marketplace.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the success dialog
                      _resetForm(); // Reset form to allow new entry
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
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
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (!mounted) return;

      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
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

  // Reset form
  void _resetForm() {
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
      _newlyCreatedReportId = null;
      _lastSubmittedData = null;
    });
  }

  // Build progress step
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
          Icon(Icons.done, size: 18, color: const Color(0xFF2E7D32))
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
