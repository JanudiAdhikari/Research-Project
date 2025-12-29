import 'package:flutter/material.dart';
import '../../../utils/responsive.dart';
import 'bulk_density_instructions_screen.dart';
import 'image_upload_screen.dart';

class BulkDensityScreen extends StatefulWidget {
  const BulkDensityScreen({super.key});

  @override
  State<BulkDensityScreen> createState() => _BulkDensityScreenState();
}

class _BulkDensityScreenState extends State<BulkDensityScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _densityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isIoTConnected = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _densityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    const primary = Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bulk Density',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
            tooltip: 'How to measure',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BulkDensityInstructionsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: responsive.padding(
                  mobile: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                  tablet: const EdgeInsets.fromLTRB(32, 28, 32, 32),
                  desktop: const EdgeInsets.fromLTRB(40, 32, 40, 36),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(
                      responsive.value(mobile: 32, tablet: 36, desktop: 40),
                    ),
                    bottomRight: Radius.circular(
                      responsive.value(mobile: 32, tablet: 36, desktop: 40),
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: responsive.padding(
                            mobile: const EdgeInsets.all(12),
                            tablet: const EdgeInsets.all(14),
                            desktop: const EdgeInsets.all(16),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.science_rounded,
                            color: Colors.white,
                            size: responsive.value(
                              mobile: 28,
                              tablet: 32,
                              desktop: 36,
                            ),
                          ),
                        ),
                        ResponsiveSpacing.horizontal(
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Step 2 of 3",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: responsive.bodyFontSize - 1,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              ResponsiveSpacing(mobile: 4, tablet: 6, desktop: 8),
                              Text(
                                "Density Measurement",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: responsive.fontSize(
                                    mobile: 20,
                                    tablet: 22,
                                    desktop: 24,
                                  ),
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ResponsiveSpacing(mobile: 16, tablet: 18, desktop: 20),
                    // IoT Connection Status
                    Container(
                      padding: responsive.padding(
                        mobile: const EdgeInsets.all(12),
                        tablet: const EdgeInsets.all(14),
                        desktop: const EdgeInsets.all(16),
                      ),
                      decoration: BoxDecoration(
                        color: _isIoTConnected
                            ? Colors.green.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isIoTConnected
                              ? Colors.green.withOpacity(0.3)
                              : Colors.orange.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isIoTConnected
                                ? Icons.sensors_rounded
                                : Icons.sensor_occupied_rounded,
                            color: Colors.white,
                            size: responsive.smallIconSize,
                          ),
                          ResponsiveSpacing.horizontal(
                            mobile: 10,
                            tablet: 12,
                            desktop: 14,
                          ),
                          Expanded(
                            child: Text(
                              _isIoTConnected
                                  ? 'IoT Device Connected'
                                  : 'Manual Entry Mode',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: responsive.bodyFontSize - 1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            width: responsive.value(
                              mobile: 8,
                              tablet: 9,
                              desktop: 10,
                            ),
                            height: responsive.value(
                              mobile: 8,
                              tablet: 9,
                              desktop: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _isIoTConnected ? Colors.green : Colors.orange,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (_isIoTConnected ? Colors.green : Colors.orange)
                                      .withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              ResponsiveSpacing(mobile: 24, tablet: 28, desktop: 32),

              // Form Content
              SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.pagePadding,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Instructions Card
                        Container(
                          padding: responsive.padding(
                            mobile: const EdgeInsets.all(20),
                            tablet: const EdgeInsets.all(24),
                            desktop: const EdgeInsets.all(28),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(
                                      responsive.value(
                                        mobile: 10,
                                        tablet: 11,
                                        desktop: 12,
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.info_outline_rounded,
                                      color: Colors.blue.shade700,
                                      size: responsive.mediumIconSize,
                                    ),
                                  ),
                                  ResponsiveSpacing.horizontal(
                                    mobile: 12,
                                    tablet: 14,
                                    desktop: 16,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Measurement Instructions',
                                      style: TextStyle(
                                        fontSize: responsive.titleFontSize,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              ResponsiveSpacing(mobile: 16, tablet: 18, desktop: 20),
                              Text(
                                'Use the bulk density measuring device to obtain the density value of your pepper sample.',
                                style: TextStyle(
                                  fontSize: responsive.bodyFontSize,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                              ResponsiveSpacing(mobile: 12, tablet: 14, desktop: 16),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const BulkDensityInstructionsScreen(),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: responsive.value(
                                      mobile: 12,
                                      tablet: 14,
                                      desktop: 16,
                                    ),
                                    vertical: responsive.value(
                                      mobile: 8,
                                      tablet: 9,
                                      desktop: 10,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.blue.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.help_outline_rounded,
                                        color: Colors.blue.shade700,
                                        size: responsive.smallIconSize,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'View detailed instructions',
                                        style: TextStyle(
                                          fontSize: responsive.bodyFontSize - 1,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        ResponsiveSpacing(mobile: 20, tablet: 24, desktop: 28),

                        // Info Note
                        Container(
                          padding: responsive.padding(
                            mobile: const EdgeInsets.all(16),
                            tablet: const EdgeInsets.all(18),
                            desktop: const EdgeInsets.all(20),
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade50,
                                Colors.green.shade100.withOpacity(0.5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                color: Colors.green.shade700,
                                size: responsive.mediumIconSize,
                              ),
                              ResponsiveSpacing.horizontal(
                                mobile: 12,
                                tablet: 14,
                                desktop: 16,
                              ),
                              Expanded(
                                child: Text(
                                  'If the IoT device is not connected, you may enter the measured value manually below.',
                                  style: TextStyle(
                                    fontSize: responsive.bodyFontSize - 1,
                                    color: Colors.green.shade900,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        ResponsiveSpacing(mobile: 24, tablet: 28, desktop: 32),

                        // Measurement Input Section
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(
                                responsive.value(mobile: 8, tablet: 9, desktop: 10),
                              ),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.straighten_rounded,
                                color: primary,
                                size: responsive.value(
                                  mobile: 20,
                                  tablet: 22,
                                  desktop: 24,
                                ),
                              ),
                            ),
                            ResponsiveSpacing.horizontal(
                              mobile: 12,
                              tablet: 14,
                              desktop: 16,
                            ),
                            Text(
                              'Enter Measurement',
                              style: TextStyle(
                                fontSize: responsive.headingFontSize - 2,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),

                        ResponsiveSpacing(mobile: 16, tablet: 18, desktop: 20),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Bulk Density Value',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: responsive.bodyFontSize,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  ' *',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: responsive.bodyFontSize,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _densityController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              style: TextStyle(
                                fontSize: responsive.bodyFontSize + 2,
                                fontWeight: FontWeight.w600,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter bulk density value';
                                }
                                final number = double.tryParse(value);
                                if (number == null) {
                                  return 'Please enter a valid number';
                                }
                                if (number <= 0) {
                                  return 'Value must be greater than 0';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'e.g., 650',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: responsive.bodyFontSize + 1,
                                  fontWeight: FontWeight.normal,
                                ),
                                suffixIcon: Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: responsive.value(
                                      mobile: 12,
                                      tablet: 14,
                                      desktop: 16,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'g/L',
                                      style: TextStyle(
                                        color: primary,
                                        fontSize: responsive.bodyFontSize,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(
                                  Icons.balance_rounded,
                                  color: Colors.grey[600],
                                  size: responsive.mediumIconSize,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: responsive.mediumSpacing,
                                  vertical: responsive.value(mobile: 18, tablet: 20),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: primary, width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.red.shade300),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.red, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),

                        ResponsiveSpacing(mobile: 12, tablet: 14, desktop: 16),

                        // Typical Range Info
                        Container(
                          padding: responsive.padding(
                            mobile: const EdgeInsets.all(12),
                            tablet: const EdgeInsets.all(14),
                            desktop: const EdgeInsets.all(16),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                color: Colors.amber.shade700,
                                size: responsive.smallIconSize,
                              ),
                              ResponsiveSpacing.horizontal(
                                mobile: 10,
                                tablet: 12,
                                desktop: 14,
                              ),
                              Expanded(
                                child: Text(
                                  'Typical range: 550-700 g/L for quality pepper',
                                  style: TextStyle(
                                    fontSize: responsive.bodyFontSize - 1,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        ResponsiveSpacing(mobile: 32, tablet: 40, desktop: 48),

                        // Continue Button
                        Container(
                          width: double.infinity,
                          height: responsive.buttonHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ImageUploadScreen(),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Continue to Image Upload",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: responsive.titleFontSize,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: responsive.smallIconSize,
                                ),
                              ],
                            ),
                          ),
                        ),

                        ResponsiveSpacing(mobile: 32, tablet: 40, desktop: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}