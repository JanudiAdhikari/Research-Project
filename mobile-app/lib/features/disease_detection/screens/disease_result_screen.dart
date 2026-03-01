import 'dart:io';
import 'package:flutter/material.dart';
import '../services/disease_detection_service.dart';
import '../../../utils/localization.dart';
import '../../../utils/language_prefs.dart';

Color _withOpacity(Color c, double opacity) {
  final alpha = (opacity * 255).round().clamp(0, 255);
  return c.withAlpha(alpha);
}

class DiseaseResultScreen extends StatefulWidget {
  final File imageFile;
  final DiseaseDetectionResult? result;

  const DiseaseResultScreen({Key? key, required this.imageFile, this.result})
    : super(key: key);

  @override
  State<DiseaseResultScreen> createState() => _DiseaseResultScreenState();
}

class _DiseaseResultScreenState extends State<DiseaseResultScreen>
    with TickerProviderStateMixin {
  late DiseaseDetectionResult? _result;
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  String _currentLanguage = 'en';

  static const Color primary = Color(0xFF2E7D32);

  String _translate(String key) =>
      AppLocalizations.translate(_currentLanguage, key);

  @override
  void initState() {
    super.initState();
    _result = widget.result;

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    LanguagePrefs.getLanguage().then((lang) {
      if (mounted) setState(() => _currentLanguage = lang);
    });

    if (_result == null) {
      _detectDisease();
    } else {
      _isLoading = false;
      _slideController.forward();
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _detectDisease() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await DiseaseDetectionService.detectDisease(
        widget.imageFile,
      );

      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
        _slideController.forward();
        _fadeController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Color _getSeverityColor() {
    if (_result == null) return Colors.grey;
    switch (_result!.severity.toLowerCase()) {
      case 'high':
        return const Color(0xFFFF6B6B);
      case 'medium':
        return const Color(0xFFFFA500);
      case 'low':
        return const Color(0xFFFFD700);
      default:
        return primary;
    }
  }

  IconData _getSeverityIcon() {
    if (_result == null) return Icons.help;
    switch (_result!.severity.toLowerCase()) {
      case 'high':
        return Icons.error_rounded;
      case 'medium':
        return Icons.warning_rounded;
      case 'low':
        return Icons.info_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  // ── Slide animation helper ─────────────────────────────────────────────────

  Animation<Offset> get _slideAnim => Tween<Offset>(
    begin: const Offset(0, 0.2),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // ── AppBar: matches QualityGradingDashboard ──────────────────────────
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _translate('disease_detection_result'),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? _buildLoadingScreen()
          : _errorMessage != null
          ? _buildErrorScreen()
          : (_result == null ? _buildErrorScreen() : _buildResultScreen()),
    );
  }

  // ── Loading ────────────────────────────────────────────────────────────────

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _withOpacity(primary, 0.08),
            ),
            child: const SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(primary),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _translate('analyzing_image'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _translate('using_cnn_model'),
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // ── Error ──────────────────────────────────────────────────────────────────

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _withOpacity(Colors.red, 0.08),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _translate('detection_failed'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 32),
            // Retry button — pill style matching app
            Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: _withOpacity(primary, 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _detectDisease,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  _translate('retry'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Result ─────────────────────────────────────────────────────────────────

  Widget _buildResultScreen() {
    return FadeTransition(
      opacity: Tween(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SlideTransition(position: _slideAnim, child: _buildImagePreview()),
            const SizedBox(height: 20),

            SlideTransition(position: _slideAnim, child: _buildDiseaseCard()),
            const SizedBox(height: 16),

            SlideTransition(
              position: _slideAnim,
              child: _buildConfidenceMeter(),
            ),
            const SizedBox(height: 20),

            SlideTransition(position: _slideAnim, child: _buildInfoSection()),
            const SizedBox(height: 16),

            if (!_result!.isHealthy) ...[
              SlideTransition(
                position: _slideAnim,
                child: _buildTreatmentSection(),
              ),
              const SizedBox(height: 16),
            ],

            if (_result!.prevention.isNotEmpty) ...[
              SlideTransition(
                position: _slideAnim,
                child: _buildPreventionSection(),
              ),
              const SizedBox(height: 16),
            ],

            SlideTransition(
              position: _slideAnim,
              child: _buildPredictionsChart(),
            ),
            const SizedBox(height: 24),

            SlideTransition(position: _slideAnim, child: _buildActionButtons()),
          ],
        ),
      ),
    );
  }

  // ── Image preview ──────────────────────────────────────────────────────────

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _withOpacity(Colors.black, 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(widget.imageFile, fit: BoxFit.cover),
      ),
    );
  }

  // ── Disease card ───────────────────────────────────────────────────────────

  Widget _buildDiseaseCard() {
    final severityColor = _getSeverityColor();
    final severityIcon = _getSeverityIcon();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _withOpacity(severityColor, 0.14),
            _withOpacity(severityColor, 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _withOpacity(severityColor, 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _withOpacity(severityColor, 0.1),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _withOpacity(severityColor, 0.22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(severityIcon, color: severityColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _result!.disease,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: severityColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _result!.severity.isEmpty ? 'None' : _result!.severity,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Confidence meter ───────────────────────────────────────────────────────

  Widget _buildConfidenceMeter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _withOpacity(Colors.black, 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Section header style
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: _withOpacity(primary, 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.speed_rounded,
                      color: primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _translate('confidence_level'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _withOpacity(primary, 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_result!.confidence.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _result!.confidence / 100,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _translate('model_confidence'),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ── Info / description section ─────────────────────────────────────────────

  Widget _buildInfoSection() {
    return _buildDetailCard(
      title: _translate('description'),
      icon: Icons.info_outline_rounded,
      iconBgColor: const Color(0xFFE3F2FD),
      iconColor: const Color(0xFF1565C0),
      borderColor: const Color(0xFFBBDEFB),
      bgColor: const Color(0xFFF5FAFF),
      content: _result!.description,
    );
  }

  Widget _buildTreatmentSection() {
    return _buildDetailCard(
      title: _translate('treatment'),
      icon: Icons.medical_services_rounded,
      iconBgColor: const Color(0xFFFFEBEE),
      iconColor: Colors.red.shade600,
      borderColor: const Color(0xFFFFCDD2),
      bgColor: const Color(0xFFFFF8F8),
      content: _result!.treatment,
    );
  }

  Widget _buildPreventionSection() {
    return _buildDetailCard(
      title: _translate('prevention'),
      icon: Icons.shield_rounded,
      iconBgColor: const Color(0xFFFFF3E0),
      iconColor: Colors.orange.shade600,
      borderColor: const Color(0xFFFFE0B2),
      bgColor: const Color(0xFFFFFBF5),
      content: _result!.prevention,
    );
  }

  // Shared detail card — consistent with BatchDetailsScreen section style
  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required Color borderColor,
    required Color bgColor,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: _withOpacity(Colors.black, 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: borderColor),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Predictions chart ──────────────────────────────────────────────────────

  Widget _buildPredictionsChart() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _withOpacity(Colors.black, 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _withOpacity(const Color(0xFF6A1B9A), 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    color: Color(0xFF6A1B9A),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _translate('all_predictions'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[100]),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: _result!.allPredictions.entries.map((entry) {
                final disease = entry.key;
                final probability = (entry.value as num).toDouble() * 100;
                final isHighest = disease == _result!.disease;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              disease,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isHighest
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isHighest
                                    ? Colors.black87
                                    : Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isHighest
                                  ? _withOpacity(primary, 0.12)
                                  : _withOpacity(Colors.grey, 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${probability.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isHighest ? primary : Colors.grey[500],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: probability / 100,
                          minHeight: 6,
                          backgroundColor: Colors.grey[100],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isHighest ? primary : Colors.grey[300]!,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ─────────────────────────────────────────────────────────

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary — pill style matching app
        Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: _withOpacity(primary, 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.camera_alt_rounded, size: 18),
            label: Text(
              _translate('analyze_another_image'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary — outlined pill
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: Text(
              _translate('go_back'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: primary, width: 2),
              foregroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
