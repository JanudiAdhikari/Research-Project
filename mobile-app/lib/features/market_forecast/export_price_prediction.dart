import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/responsive.dart';
import 'export_price_trends.dart';

class ExportPricePrediction extends StatefulWidget {
  const ExportPricePrediction({super.key});

  @override
  State<ExportPricePrediction> createState() => _ExportPricePredictionState();
}

class _ExportPricePredictionState extends State<ExportPricePrediction> {
  final List<String> pepperTypes = ['Black', 'White'];
  final List<String> years = ['2026', '2027'];
  final List<String> months = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String? selectedPepperType = 'Black';
  String? selectedYear;
  String? selectedMonth;
  final TextEditingController _volumeController = TextEditingController();

  bool showErrors = false;
  bool showResult = false;
  double? predictedPricePerKg;
  double? predictedMonthlyTotal;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _overlayEntry?.remove();
    _volumeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final responsive = context.responsive;
    final buttonWidth = responsive.value(
      mobile: MediaQuery.of(context).size.width * 0.65,
      tablet: MediaQuery.of(context).size.width * 0.45,
      desktop: 360,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Export Price Prediction'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _resetForm,
                  borderRadius: BorderRadius.circular(10),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            _overlayEntry?.remove();
            _overlayEntry = null;
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              responsive.pagePadding,
              0,
              responsive.pagePadding,
              responsive.largeSpacing,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: responsive.mediumSpacing),
                    Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    responsive.largeSpacing,
                    responsive.largeSpacing,
                    responsive.largeSpacing,
                    responsive.xlargeSpacing,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFC8E6C9),
                        const Color(0xFFA5D6A7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.black.withOpacity(0.08),
                              ),
                            ),
                            child: const Icon(
                              Icons.trending_up_rounded,
                              color: Colors.black87,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Export Price Prediction',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Forecast export pepper prices monthly with your current shipment details.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: responsive.mediumSpacing),
                      Row(
                        children: [
                          _buildChip('Fast 2-step setup'),
                          SizedBox(width: responsive.smallSpacing),
                          _buildChip('Realistic outlook'),
                        ],
                      ),
                      SizedBox(height: responsive.mediumSpacing),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_rounded,
                              color: Colors.black87,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Get accurate monthly export price forecasts to plan your shipments better',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                    SizedBox(height: responsive.largeSpacing),

                    Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pepper Type',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Black',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                    SizedBox(height: responsive.mediumSpacing),

                    _buildNumberField(),
                    SizedBox(height: responsive.mediumSpacing),

                    Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        'Year',
                        selectedYear,
                        years,
                        (val) => setState(() => selectedYear = val),
                        required: true,
                      ),
                    ),
                        SizedBox(width: responsive.mediumSpacing),
                    Expanded(
                      child: _buildDropdownField(
                        'Month',
                        selectedMonth,
                        months,
                        (val) => setState(() => selectedMonth = val),
                        required: true,
                      ),
                    ),
                  ],
                ),

                    SizedBox(height: responsive.largeSpacing),

                    Center(
                      child: SizedBox(
                    width: buttonWidth,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _onSubmit,
                      child: const Text(
                        'Predict the Export Price',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                    SizedBox(height: responsive.mediumSpacing),

                    AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: showResult
                      ? _buildResultCard(context)
                      : const SizedBox(),
                ),

                    AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: showResult
                      ? Column(
                          children: [
                            SizedBox(height: responsive.mediumSpacing),
                            Center(
                              child: SizedBox(
                                width: buttonWidth,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 20,
                                    ),
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ExportPriceTrends(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'View More Details',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
                ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context) {
    final theme = Theme.of(context);
    final volumeKg = double.tryParse(_volumeController.text) ?? 0;

    return Container(
      key: const ValueKey('result-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFFF9C4), const Color(0xFFFFE082)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFE082).withOpacity(0.2),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Monthly Export Price Forecast',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResultRow('Pepper', selectedPepperType ?? '-'),
                _buildResultRow('Month', selectedMonth ?? '-'),
                _buildResultRow('Year', selectedYear ?? '-'),
                _buildResultRow('Volume', '${volumeKg.toStringAsFixed(0)} kg'),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estimated price per kg',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      predictedPricePerKg != null
                          ? _formatCurrency(predictedPricePerKg!)
                          : '—',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Monthly total',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    predictedMonthlyTotal != null
                        ? _formatCurrency(predictedMonthlyTotal!)
                        : '—',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String title,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged, {
    bool required = false,
  }) {
    final key = GlobalKey();

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
            onTap: () => _toggleDropdown(key, items, value, onChanged),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (showErrors && required && value == null)
                      ? Colors.red
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
                  const Icon(Icons.arrow_drop_down_rounded),
                ],
              ),
            ),
          ),
        ),
        if (showErrors && required && value == null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '$title is required',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildNumberField() {
    final hasError = showErrors && _volumeController.text.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Export Volume (kg)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? Colors.red : Colors.grey.shade300,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _volumeController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              hintText: 'Enter volume in kg',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
            ),
          ),
        ),
        if (showErrors && _volumeController.text.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'Export volume is required',
              style: TextStyle(color: Colors.red, fontSize: 12),
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

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _onSubmit() {
    setState(() {
      showErrors = true;
    });

    if (selectedPepperType == null ||
        selectedYear == null ||
        selectedMonth == null ||
        _volumeController.text.isEmpty) {
      return;
    }

    final pricePerKg = _estimateUnitPrice();
    final volume = double.tryParse(_volumeController.text) ?? 0;
    final total = pricePerKg * volume;

    setState(() {
      predictedPricePerKg = pricePerKg;
      predictedMonthlyTotal = total;
      showResult = true;
    });
  }

  void _resetForm() {
    setState(() {
      _volumeController.clear();
      selectedYear = null;
      selectedMonth = null;
      showErrors = false;
      showResult = false;
      predictedPricePerKg = null;
      predictedMonthlyTotal = null;
    });
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  double _estimateUnitPrice() {
    final base = selectedPepperType == 'White' ? 1120.0 : 980.0;
    final seasonalBump = (months.indexOf(selectedMonth!) % 4) * 22.5;
    final yearlyTrend = selectedYear == '2027' ? 45.0 : 0.0;
    return base + seasonalBump + yearlyTrend;
  }

  String _formatCurrency(double value) {
    final rounded = value.round();
    final chars = rounded.toString().split('').reversed.toList();
    final buffer = StringBuffer();
    for (int i = 0; i < chars.length; i++) {
      if (i != 0 && i % 3 == 0) buffer.write(',');
      buffer.write(chars[i]);
    }
    final formatted = buffer.toString().split('').reversed.join();
    return 'LKR $formatted';
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
