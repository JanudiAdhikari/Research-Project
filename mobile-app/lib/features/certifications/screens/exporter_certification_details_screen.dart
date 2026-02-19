import 'package:flutter/material.dart';
import '../models/certification_model.dart';
import '../services/certification_api.dart';
import '../../../utils/responsive.dart';

// Helper to create a Color from an existing Color with a custom opacity (0.0-1.0)
Color colorWithOpacity(Color c, double opacity) {
  final alpha = (opacity * 255).round().clamp(0, 255);
  return c.withAlpha(alpha);
}

class ExporterCertificationDetailsScreen extends StatefulWidget {
  const ExporterCertificationDetailsScreen({
    super.key,
    required this.certId,
    required this.api,
  });

  final String certId;
  final CertificationApi api;

  @override
  State<ExporterCertificationDetailsScreen> createState() =>
      _ExporterCertificationDetailsScreenState();
}

class _ExporterCertificationDetailsScreenState
    extends State<ExporterCertificationDetailsScreen>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xFF2E7D32);

  bool _loading = true;
  String? _error;
  CertificationModel? _cert;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _load();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      final cert = await widget.api.getById(widget.certId);
      setState(() {
        _cert = cert;
        _loading = false;
      });
      _animationController.forward(from: 0);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header matching dashboard style
            _buildHeader(responsive),

            // Content area
            Expanded(
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_primary),
                      ),
                    )
                  : _error != null
                  ? _errorState(responsive)
                  : _cert == null
                  ? _notFoundState(responsive)
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(
                            responsive.value(
                                mobile: 16, tablet: 24, desktop: 32),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Main details card
                              _buildDetailsCard(responsive),

                              ResponsiveSpacing(
                                  mobile: 16, tablet: 20, desktop: 24),

                              // Extra info card (verification / rejection)
                              if (_hasExtraInfo()) ...[
                                _buildExtraInfoCard(responsive),
                                ResponsiveSpacing(
                                    mobile: 16, tablet: 20, desktop: 24),
                              ],

                              // Back button
                              _buildBackButton(responsive),

                              ResponsiveSpacing(
                                  mobile: 24, tablet: 32, desktop: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasExtraInfo() {
    final c = _cert;
    if (c == null) return false;
    return (c.verifiedBy != null && c.verifiedBy!.isNotEmpty) ||
        c.verificationDate != null ||
        (c.status == 'rejected' &&
            (c.rejectionReason ?? '').trim().isNotEmpty);
  }

  Widget _buildHeader(Responsive responsive) {
    return Container(
      padding: responsive.padding(
        mobile: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        tablet: const EdgeInsets.fromLTRB(32, 24, 32, 32),
        desktop: const EdgeInsets.fromLTRB(40, 28, 40, 36),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, colorWithOpacity(_primary, 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(
            responsive.value(mobile: 28, tablet: 36, desktop: 40),
          ),
          bottomRight: Radius.circular(
            responsive.value(mobile: 28, tablet: 36, desktop: 40),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: colorWithOpacity(_primary, 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(
                responsive.value(mobile: 8, tablet: 10, desktop: 12),
              ),
              decoration: BoxDecoration(
                color: colorWithOpacity(Colors.white, 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: responsive.value(mobile: 20, tablet: 22, desktop: 24),
              ),
            ),
          ),

          ResponsiveSpacing.horizontal(mobile: 14, tablet: 16, desktop: 18),

          // Title + cert type subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Certificate Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.fontSize(
                        mobile: 20, tablet: 24, desktop: 28),
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                if (_cert != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _cert!.certificationType,
                    style: TextStyle(
                      color: colorWithOpacity(Colors.white, 0.8),
                      fontSize: responsive.fontSize(
                          mobile: 12, tablet: 13, desktop: 14),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Refresh button
          GestureDetector(
            onTap: _load,
            child: Container(
              padding: EdgeInsets.all(
                responsive.value(mobile: 8, tablet: 10, desktop: 12),
              ),
              decoration: BoxDecoration(
                color: colorWithOpacity(Colors.white, 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: responsive.value(mobile: 20, tablet: 22, desktop: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(Responsive responsive) {
    final c = _cert!;

    return Container(
      width: double.infinity,
      padding: responsive.padding(
        mobile: const EdgeInsets.all(16),
        tablet: const EdgeInsets.all(20),
        desktop: const EdgeInsets.all(24),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsive.value(mobile: 16, tablet: 18, desktop: 20),
        ),
        border: Border.all(
          color: colorWithOpacity(_primary, 0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorWithOpacity(Colors.black, 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header: icon + cert type + status chip
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(
                  responsive.value(mobile: 10, tablet: 12, desktop: 14),
                ),
                decoration: BoxDecoration(
                  color: colorWithOpacity(_primary, 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.verified_outlined,
                  color: _primary,
                  size: responsive.value(mobile: 24, tablet: 26, desktop: 28),
                ),
              ),
              ResponsiveSpacing.horizontal(mobile: 12, tablet: 14, desktop: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.certificationType,
                      style: TextStyle(
                        fontSize: responsive.fontSize(
                            mobile: 17, tablet: 19, desktop: 21),
                        fontWeight: FontWeight.w800,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    _statusChip(c.effectiveStatus, responsive),
                  ],
                ),
              ),
            ],
          ),

          ResponsiveSpacing(mobile: 18, tablet: 20, desktop: 22),
          Divider(height: 1, color: colorWithOpacity(_primary, 0.08)),
          ResponsiveSpacing(mobile: 16, tablet: 18, desktop: 20),

          _buildSectionLabel(responsive, 'Certificate Information'),
          ResponsiveSpacing(mobile: 12, tablet: 14, desktop: 16),

          _infoRow(responsive, Icons.confirmation_number_outlined,
              'Certificate No.', c.certificateNumber),
          _infoRow(responsive, Icons.account_balance_outlined,
              'Issuing Body', c.issuingBody),
          _infoRow(responsive, Icons.event_outlined,
              'Issue Date', _formatDate(c.issueDate)),
          _infoRow(responsive, Icons.event_available_outlined,
              'Expiry Date', _formatDate(c.expiryDate)),

          ResponsiveSpacing(mobile: 14, tablet: 16, desktop: 18),
          Divider(height: 1, color: colorWithOpacity(_primary, 0.08)),
          ResponsiveSpacing(mobile: 14, tablet: 16, desktop: 18),

          _buildSectionLabel(responsive, 'Submission Timeline'),
          ResponsiveSpacing(mobile: 12, tablet: 14, desktop: 16),

          _infoRow(responsive, Icons.schedule_outlined,
              'Submitted On', _formatDate(c.createdAt)),
          _infoRow(responsive, Icons.update_outlined,
              'Last Updated', _formatDate(c.updatedAt), isLast: true),
        ],
      ),
    );
  }

  Widget _buildExtraInfoCard(Responsive responsive) {
    final c = _cert!;
    final isRejected = c.status == 'rejected';

    return Container(
      width: double.infinity,
      padding: responsive.padding(
        mobile: const EdgeInsets.all(16),
        tablet: const EdgeInsets.all(20),
        desktop: const EdgeInsets.all(24),
      ),
      decoration: BoxDecoration(
        color: isRejected
            ? Colors.red.shade50
            : colorWithOpacity(_primary, 0.04),
        borderRadius: BorderRadius.circular(
          responsive.value(mobile: 16, tablet: 18, desktop: 20),
        ),
        border: Border.all(
          color: isRejected
              ? colorWithOpacity(Colors.red, 0.2)
              : colorWithOpacity(_primary, 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isRejected
                    ? Icons.cancel_outlined
                    : Icons.verified_user_outlined,
                color: isRejected ? Colors.red.shade600 : _primary,
                size: responsive.value(mobile: 18, tablet: 20, desktop: 22),
              ),
              const SizedBox(width: 8),
              Text(
                isRejected ? 'Rejection Details' : 'Verification Details',
                style: TextStyle(
                  fontSize: responsive.fontSize(
                      mobile: 14, tablet: 15, desktop: 16),
                  fontWeight: FontWeight.w700,
                  color: isRejected ? Colors.red.shade700 : _primary,
                ),
              ),
            ],
          ),

          ResponsiveSpacing(mobile: 12, tablet: 14, desktop: 16),

          if (c.verifiedBy != null && c.verifiedBy!.isNotEmpty)
            _infoRow(responsive, Icons.person_outline, 'Verified By',
                c.verifiedBy!.toUpperCase()),
          if (c.verificationDate != null)
            _infoRow(responsive, Icons.event_outlined, 'Verification Date',
                _formatDate(c.verificationDate!)),
          if (isRejected && (c.rejectionReason ?? '').trim().isNotEmpty)
            _infoRow(responsive, Icons.info_outline, 'Rejection Reason',
                c.rejectionReason!, isLast: true),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(Responsive responsive, String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: responsive.fontSize(mobile: 12, tablet: 13, desktop: 14),
        fontWeight: FontWeight.w700,
        color: colorWithOpacity(_primary, 0.7),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _infoRow(
    Responsive responsive,
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast
            ? 0
            : responsive.value(mobile: 12, tablet: 14, desktop: 16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: responsive.value(mobile: 16, tablet: 17, desktop: 18),
            color: colorWithOpacity(_primary, 0.6),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: responsive.value(mobile: 120, tablet: 140, desktop: 160),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize:
                    responsive.fontSize(mobile: 13, tablet: 14, desktop: 15),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize:
                    responsive.fontSize(mobile: 13, tablet: 14, desktop: 15),
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(Responsive responsive) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(
            responsive.value(mobile: 14, tablet: 16, desktop: 18),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: responsive.value(mobile: 15, tablet: 17, desktop: 19),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                responsive.value(mobile: 14, tablet: 16, desktop: 18),
              ),
              border: Border.all(
                color: colorWithOpacity(_primary, 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorWithOpacity(Colors.black, 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_back_rounded,
                  color: _primary,
                  size: responsive.value(mobile: 18, tablet: 20, desktop: 22),
                ),
                const SizedBox(width: 8),
                Text(
                  'Back',
                  style: TextStyle(
                    color: _primary,
                    fontSize: responsive.fontSize(
                        mobile: 14, tablet: 15, desktop: 16),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _errorState(Responsive responsive) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(
          responsive.value(mobile: 24, tablet: 32, desktop: 40),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(
                responsive.value(mobile: 20, tablet: 24, desktop: 28),
              ),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: responsive.value(mobile: 48, tablet: 56, desktop: 64),
                color: Colors.red.shade400,
              ),
            ),
            ResponsiveSpacing(mobile: 16, tablet: 20, desktop: 24),
            Text(
              'Failed to load',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize:
                    responsive.fontSize(mobile: 18, tablet: 20, desktop: 22),
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize:
                    responsive.fontSize(mobile: 13, tablet: 14, desktop: 15),
              ),
            ),
            ResponsiveSpacing(mobile: 20, tablet: 24, desktop: 28),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal:
                      responsive.value(mobile: 24, tablet: 28, desktop: 32),
                  vertical:
                      responsive.value(mobile: 14, tablet: 16, desktop: 18),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notFoundState(Responsive responsive) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(
              responsive.value(mobile: 20, tablet: 24, desktop: 28),
            ),
            decoration: BoxDecoration(
              color: colorWithOpacity(_primary, 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: responsive.value(mobile: 48, tablet: 56, desktop: 64),
              color: colorWithOpacity(_primary, 0.4),
            ),
          ),
          ResponsiveSpacing(mobile: 16, tablet: 20, desktop: 24),
          Text(
            'Certificate not found',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize:
                  responsive.fontSize(mobile: 17, tablet: 19, desktop: 21),
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status, Responsive responsive) {
    final s = status.toLowerCase();
    Color bg;
    Color fg;

    if (s.contains('pending')) {
      bg = Colors.orange.shade50;
      fg = Colors.orange.shade800;
    } else if (s.contains('verified')) {
      bg = colorWithOpacity(_primary, 0.08);
      fg = _primary;
    } else if (s.contains('expired')) {
      bg = Colors.grey.shade100;
      fg = Colors.grey.shade700;
    } else {
      bg = Colors.red.shade50;
      fg = Colors.red.shade700;
    }

    final label = status.isEmpty
        ? status
        : status[0].toUpperCase() + status.substring(1);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.value(mobile: 10, tablet: 12, desktop: 14),
        vertical: responsive.value(mobile: 4, tablet: 5, desktop: 6),
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorWithOpacity(fg, 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: fg,
          fontSize: responsive.fontSize(mobile: 11, tablet: 12, desktop: 13),
        ),
      ),
    );
  }
}