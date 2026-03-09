import 'package:flutter/material.dart';
import '../../../utils/responsive.dart';
import '../../../utils/language_prefs.dart';
import '../../../utils/quality_grading/quality_tip_detail_screen_si.dart';

class QualityTipDetailScreen extends StatefulWidget {
  final String category;

  const QualityTipDetailScreen({super.key, required this.category});

  @override
  State<QualityTipDetailScreen> createState() => _QualityTipDetailScreenState();
}

class _QualityTipDetailScreenState extends State<QualityTipDetailScreen> {
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    // Load saved language preference
    LanguagePrefs.getLanguage().then((lang) {
      if (mounted) setState(() => _currentLanguage = lang);
    });
  }

  bool get _isSinhala => _currentLanguage == 'si';

  String _t(String english, String sinhala) => _isSinhala ? sinhala : english;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final content = _getContentForCategory(widget.category);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: content['color'] as Color,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          content['title'] as String,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Content Section
            Padding(
              padding: EdgeInsets.all(responsive.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Why It Matters
                  _buildSectionCard(
                    responsive,
                    title: _t(
                      "Why It Matters",
                      QualityTipDetailScreenSi.whyItMatters,
                    ),
                    icon: Icons.info_rounded,
                    color: content['color'] as Color,
                    content: content['whyMatters'] as String,
                  ),

                  SizedBox(
                    height: responsive.value(
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    ),
                  ),

                  // Tips List
                  _buildTipsCard(
                    responsive,
                    color: content['color'] as Color,
                    tips: content['tips'] as List<String>,
                  ),

                  SizedBox(
                    height: responsive.value(
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    ),
                  ),

                  // Common Mistakes
                  _buildMistakesCard(
                    responsive,
                    color: content['color'] as Color,
                    mistakes: content['mistakes'] as List<String>,
                  ),

                  SizedBox(
                    height: responsive.value(
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    ),
                  ),

                  // Impact on Grade
                  _buildImpactCard(
                    responsive,
                    color: content['color'] as Color,
                    impact: content['impact'] as String,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    Responsive responsive, {
    required String title,
    required IconData icon,
    required Color color,
    required String content,
  }) {
    return Container(
      padding: EdgeInsets.all(
        responsive.value(mobile: 18, tablet: 20, desktop: 22),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: responsive.value(
                    mobile: 18,
                    tablet: 20,
                    desktop: 22,
                  ),
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(
            height: responsive.value(mobile: 12, tablet: 14, desktop: 16),
          ),
          Text(
            content,
            style: TextStyle(
              fontSize: responsive.value(mobile: 14, tablet: 15, desktop: 16),
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard(
    Responsive responsive, {
    required Color color,
    required List<String> tips,
  }) {
    return Container(
      padding: EdgeInsets.all(
        responsive.value(mobile: 18, tablet: 20, desktop: 22),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.checklist_rounded, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                _t("Best Practices", QualityTipDetailScreenSi.bestPractices),
                style: TextStyle(
                  fontSize: responsive.value(
                    mobile: 18,
                    tablet: 20,
                    desktop: 22,
                  ),
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(
            height: responsive.value(mobile: 14, tablet: 16, desktop: 18),
          ),
          ...tips.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "${entry.key + 1}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: responsive.value(
                          mobile: 14,
                          tablet: 15,
                          desktop: 16,
                        ),
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMistakesCard(
    Responsive responsive, {
    required Color color,
    required List<String> mistakes,
  }) {
    return Container(
      padding: EdgeInsets.all(
        responsive.value(mobile: 18, tablet: 20, desktop: 22),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.05),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _t(
                  "Avoid These Mistakes",
                  QualityTipDetailScreenSi.avoidMistakes,
                ),
                style: TextStyle(
                  fontSize: responsive.value(
                    mobile: 18,
                    tablet: 20,
                    desktop: 22,
                  ),
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(
            height: responsive.value(mobile: 14, tablet: 16, desktop: 18),
          ),
          ...mistakes.map((mistake) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.close_rounded, color: Colors.red, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      mistake,
                      style: TextStyle(
                        fontSize: responsive.value(
                          mobile: 14,
                          tablet: 15,
                          desktop: 16,
                        ),
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildImpactCard(
    Responsive responsive, {
    required Color color,
    required String impact,
  }) {
    return Container(
      padding: EdgeInsets.all(
        responsive.value(mobile: 18, tablet: 20, desktop: 22),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.trending_up_rounded, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                _t(
                  "Impact on Your Grade",
                  QualityTipDetailScreenSi.impactOnGrade,
                ),
                style: TextStyle(
                  fontSize: responsive.value(
                    mobile: 18,
                    tablet: 20,
                    desktop: 22,
                  ),
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(
            height: responsive.value(mobile: 12, tablet: 14, desktop: 16),
          ),
          Text(
            impact,
            style: TextStyle(
              fontSize: responsive.value(mobile: 14, tablet: 15, desktop: 16),
              color: Colors.grey[700],
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getContentForCategory(String category) {
    final contentMap = {
      'variety': {
        'title': _t(
          'Variety & Piperine',
          QualityTipDetailScreenSi.varietyTitle,
        ),
        'color': const Color(0xFF2E7D32),
        'whyMatters': _t(
          'Piperine content determines the pungency and market value of your pepper. Ceylon pepper varieties typically contain 7-15% piperine, significantly higher than imported varieties (2-7%), making them more valuable in international markets.',
          QualityTipDetailScreenSi.varietyWhyMatters,
        ),
        'tips': _isSinhala
            ? QualityTipDetailScreenSi.varietyTips
            : [
                'Prioritize Ceylon pepper varieties for highest piperine content (10-15%)',
                'Consider hybrid varieties like Bootawe Rala (6.3%) or Kohukumbure Rala (6.0%) for good balance',
                'Avoid mixing different varieties during cultivation and processing',
                'Maintain pure seed stock to preserve variety characteristics',
                'Keep records of variety performance for future planning',
              ],
        'mistakes': _isSinhala
            ? QualityTipDetailScreenSi.varietyMistakes
            : [
                'Mixing different pepper varieties in the same batch',
                'Using imported varieties with lower piperine content',
                'Not knowing which variety you\'re growing',
                'Cross-pollination between different varieties',
              ],
        'impact': _t(
          'Choosing Ceylon pepper varieties can increase your grade by up to 100 points in piperine scoring, directly affecting your final market price and grade classification.',
          QualityTipDetailScreenSi.varietyImpact,
        ),
      },
      'mold': {
        'title': _t('Mold Prevention', QualityTipDetailScreenSi.moldTitle),
        'color': const Color(0xFF2E7D32),
        'whyMatters': _t(
          'Mold presence affects food safety, flavor, and export compliance. IPC Grade I allows maximum 1% moldy berries. Mold indicates improper drying, storage, or high moisture content.',
          QualityTipDetailScreenSi.moldWhyMatters,
        ),
        'tips': _isSinhala
            ? QualityTipDetailScreenSi.moldTips
            : [
                'Ensure thorough sun drying (3-4 days) to reduce moisture below 12%',
                'Store in cool, dry, well-ventilated areas',
                'Use moisture-proof containers or bags for storage',
                'Inspect batches regularly for early mold detection',
                'Avoid stacking wet or damp pepper bags',
                'Keep storage areas clean and pest-free',
              ],
        'mistakes': _isSinhala
            ? QualityTipDetailScreenSi.moldMistakes
            : [
                'Insufficient drying time leading to high moisture',
                'Storing pepper in humid or poorly ventilated areas',
                'Mixing fresh and dried batches',
                'Not inspecting for early mold signs',
              ],
        'impact': _t(
          'Mold presence triggers steep penalties. Even 1% mold reduces score by 50 points. Above 2% mold results in automatic rejection. Zero tolerance for food safety.',
          QualityTipDetailScreenSi.moldImpact,
        ),
      },
      'drying': {
        'title': _t('Drying Process', QualityTipDetailScreenSi.dryingTitle),
        'color': const Color(0xFF2E7D32),
        'whyMatters': _t(
          'Proper drying is critical for developing characteristic wrinkled texture in black pepper, preventing mold growth, and achieving target bulk density. It affects color, aroma, piperine concentration, and storage stability.',
          QualityTipDetailScreenSi.dryingWhyMatters,
        ),
        'tips': _isSinhala
            ? QualityTipDetailScreenSi.dryingTips
            : [
                'Spread berries in single layer on clean, dry surface',
                'Dry for 3-4 days under direct sunlight',
                'Turn/rotate berries 2-3 times daily for even drying',
                'Protect from rain and evening dew (cover or move indoors)',
                'Target final moisture content: 10-12% for black pepper',
                'Use concrete or tarpaulin drying floors, not bare soil',
                'Test dryness: properly dried berries should rattle when shaken',
              ],
        'mistakes': _isSinhala
            ? QualityTipDetailScreenSi.dryingMistakes
            : [
                'Drying on soil (introduces contamination)',
                'Not protecting from rain (causes re-wetting and mold)',
                'Insufficient turning (uneven drying)',
                'Over-drying (causes brittleness and losses)',
                'Mixing fresh and partially dried batches',
              ],
        'impact': _t(
          'Proper drying affects multiple factors: bulk density (18% weight), color uniformity (10%), texture (8%), and mold prevention (10%). Poor drying can reduce final grade by 30-40 points.',
          QualityTipDetailScreenSi.dryingImpact,
        ),
      },
      'storage': {
        'title': _t('Storage Tips', QualityTipDetailScreenSi.storageTitle),
        'color': const Color(0xFF2E7D32),
        'whyMatters': _t(
          'Even well-processed pepper can degrade during storage. Proper storage prevents moisture absorption, mold growth, insect infestation, and loss of volatile oils and piperine content.',
          QualityTipDetailScreenSi.storageWhyMatters,
        ),
        'tips': _isSinhala
            ? QualityTipDetailScreenSi.storageTips
            : [
                'Use clean, dry, food-grade storage containers or bags',
                'Store in cool (below 25°C), dry location',
                'Ensure good air circulation in storage area',
                'Keep away from strong-smelling substances (pepper absorbs odors)',
                'Stack bags on wooden pallets, not directly on floor',
                'Maintain records: date, variety, batch number, moisture %',
                'Inspect monthly for signs of moisture, mold, or pests',
                'Use FIFO (First In, First Out) rotation system',
              ],
        'mistakes': _isSinhala
            ? QualityTipDetailScreenSi.storageMistakes
            : [
                'Storing in damp or humid areas',
                'Poor ventilation causing moisture buildup',
                'Direct contact with concrete floors',
                'Mixing old and new batches',
                'Not monitoring storage conditions regularly',
              ],
        'impact': _t(
          'Good storage preserves all quality factors. Poor storage can lead to mold (automatic rejection if >2%), moisture increase (affecting density score), and color degradation (reducing grade by 20-30 points).',
          QualityTipDetailScreenSi.storageImpact,
        ),
      },
    };

    return contentMap[category] ?? contentMap['variety']!;
  }
}
