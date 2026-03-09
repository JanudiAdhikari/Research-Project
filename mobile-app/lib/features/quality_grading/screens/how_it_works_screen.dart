import 'package:flutter/material.dart';
import '../../../utils/language_prefs.dart';

class HowItWorksScreen extends StatefulWidget {
  const HowItWorksScreen({super.key});

  @override
  State<HowItWorksScreen> createState() => _HowItWorksScreenState();
}

class _HowItWorksScreenState extends State<HowItWorksScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _currentLanguage = 'en';

  bool get _isSinhala => _currentLanguage == 'si';

  @override
  void initState() {
    super.initState();
    LanguagePrefs.getLanguage().then((lang) {
      if (mounted) setState(() => _currentLanguage = lang);
    });
  }

  List<HowItWorksPage> get _pages => [
    HowItWorksPage(
      title: _isSinhala
          ? "ගම්මිරිස් ගුණාත්මක ශ්‍රේණීකරණයට සාදරයෙන් පිළිගනිමු"
          : "Welcome to Pepper Quality Grading",
      description: _isSinhala
          ? "මෙම පද්ධතිය ඔබේ කළු ගම්මිරිස් නියදිවල ගුණාත්මකභාවය ඡායාරූප විශ්ලේෂණය සහ ගුණාත්මක ලකුණු ගණනය කිරීම හරහා සරලව පරීක්ෂා කිරීමට ඔබට උදවු කරයි."
          : "This system helps you check the quality of your black pepper sample using photo analysis and quality scoring in a simple and easy way.",
      icon: Icons.auto_awesome,
      color: Colors.purple,
      details: _isSinhala
          ? [
              "සරල පියවරෙන් පියවර ක්‍රියාවලිය",
              "ඡායාරූප මත පදනම් වූ ගුණාත්මක පරීක්ෂාව",
              "පහසු ගුණාත්මක ලකුණු ගණනය කිරීම",
              "ගොවීන් සහ ගැනුම්කරුවන් සඳහා පැහැදිලි වාර්තාව",
            ]
          : [
              "Simple step-by-step process",
              "Photo-based quality checking",
              "Easy quality score calculation",
              "Clear report for farmers and buyers",
            ],
    ),
    HowItWorksPage(
      title: _isSinhala
          ? "පියවර 1: තොග ඝනත්වය මනිනු"
          : "Step 1: Measure Bulk Density",
      description: _isSinhala
          ? "1 ලීටර් කෝප්පයක් ගෙන ගම්මිරිස් පුරවා, බර මැනගෙන, යෙදුමට ඇතුළු කරන්න."
          : "Take a 1 litre cup, fill it with pepper, measure the weight, and enter that value into the app.",
      icon: Icons.scale_rounded,
      color: Colors.blue,
      details: _isSinhala
          ? [
              "1L කෝප්පයක් හෝ බඳුනක් ගන්න",
              "ගම්මිරිස් නියදියෙන් පුරවන්න",
              "මුළු බර මනිනු",
              "යෙදුමට බර ඇතුළු කරන්න",
              "වැඩි බරක් සාමාන්‍යයෙන් වඩා හොඳ ඝනත්වයක් අදහස් කරයි",
              "හොඳ තොග ඝනත්වය අවසාන ශ්‍රේණිය වැඩිදියුණු කිරීමට උදවු කරයි",
            ]
          : [
              "Take a 1L cup or container",
              "Fill it with pepper sample",
              "Measure the total weight",
              "Enter the weight into the app",
              "Higher weight usually means better density",
              "Good bulk density helps improve the final grade",
            ],
    ),
    HowItWorksPage(
      title: _isSinhala
          ? "පියවර 2: නියදි ඡායාරූප ගන්න"
          : "Step 2: Take Sample Photos",
      description: _isSinhala
          ? "යෙදුමේ උපදෙස් අනුගමනය කරමින් ගම්මිරිස් නියදිවල පැහැදිලි ඡායාරූප 8ක් ගන්න."
          : "Take 8 clear photos of your pepper sample by following the instructions in the app.",
      icon: Icons.camera_alt_rounded,
      color: Colors.teal,
      details: _isSinhala
          ? [
              "සුදු A4 කඩදාසියක ගම්මිරිස් විසිරවන්න",
              "හොඳ ස්වාභාවික ආලෝකය භාවිතා කරන්න",
              "නියදිය ඉහළින් සෙ.මී. 20-30ක් කැමරාව රඳවන්න",
              "බොඳ නොවී පැහැදිලි ඡායාරූප ගන්න",
              "ඉහළ කෝණ ඡායාරූප 5ක් සහ ළඟිනි ඡායාරූප 3ක් ගන්න",
              "සෙවනැලි, ප්‍රතිබිම්බ සහ අඳුරු පසුබිම් වළකින්න",
            ]
          : [
              "Spread pepper on a white A4 sheet",
              "Use good natural light",
              "Hold the camera about 20-30 cm above the sample",
              "Take clear photos without blur",
              "Capture 5 top-view photos and 3 close-up photos",
              "Avoid shadows, reflections, and dark backgrounds",
            ],
    ),
    HowItWorksPage(
      title: _isSinhala
          ? "පියවර 3: ගම්මිරිස් වර්ගය තෝරන්න"
          : "Step 3: Select Pepper Variety",
      description: _isSinhala
          ? "ගම්මිරිස් වර්ගය තෝරන්න, එවිට යෙදුමට පිපෙරීන් මට්ටම තක්සේරු කර ගුණාත්මක ලකුණුවලට ඇතුළත් කළ හැක."
          : "Choose your pepper variety so the app can estimate piperine level and include it in the quality score.",
      icon: Icons.science_rounded,
      color: Colors.orange,
      details: _isSinhala
          ? [
              "නිවැරදි ගම්මිරිස් වර්ගය තෝරන්න",
              "ලංකා ගම්මිරිස් සාමාන්‍යයෙන් වැඩි ලකුණු ලබාගනී",
              "අනෙකුත් වර්ග පර්යේෂණ මත පදනම් අගයන් යොදා ශ්‍රේණිගත කෙරේ",
              "පිපෙරීන් තිත්තකම සහ ගුණාත්මකභාවය සමඟ සම්බන්ධ",
              "මෙය ප්‍රයෝගශාලා පරීක්ෂාවක් නොව, අනුමාන කළ අගයකි",
            ]
          : [
              "Select the correct pepper variety",
              "Ceylon Pepper usually gets a higher score",
              "Other varieties are scored using research-based values",
              "Piperine is linked with pungency and quality",
              "This is an estimated value, not a lab test",
            ],
    ),
    HowItWorksPage(
      title: _isSinhala ? "දෝෂ දෘශ්‍ය විශ්ලේෂණය" : "Visual Analysis of Defects",
      description: _isSinhala
          ? "යෙදුම ගම්මිරිස් නියදිවල දෘශ්‍ය ගුණාත්මක ගැටළු හඳුනාගැනීමට උඩුගත කළ ඡායාරූප පරීක්ෂා කරයි."
          : "The app checks the uploaded photos to identify visible quality problems in the pepper sample.",
      icon: Icons.bug_report_rounded,
      color: Colors.red,
      details: _isSinhala
          ? [
              "ගම්මිරිස් ඇටවල පීනස් හඳුනා ගනී",
              "පොල්පිත්ත ඇට වැනි සාවද්‍ය සෙවීම් හඳුනා ගනී",
              "කූරු සහ ගල් ආදී අනවශ්‍ය ද්‍රව්‍ය හඳුනා ගනී",
              "හානි වූ හෝ දුර්වල ගම්මිරිස් ඇට පරීක්ෂා කරයි",
              "දෝෂ වැඩිවීම අවසාන ලකුණු අඩු කරයි",
              "පිරිසිදු ගම්මිරිස් සාමාන්‍යයෙන් හොඳ ශ්‍රේණියක් ලබා ගනී",
            ]
          : [
              "Detects mold on pepper berries",
              "Detects adulteration such as papaya seeds",
              "Detects unwanted materials like sticks and stones",
              "Checks for damaged or poor-quality pepper berries",
              "More defects will reduce the final score",
              "Cleaner pepper usually gets a better grade",
            ],
    ),
    HowItWorksPage(
      title: _isSinhala ? "මතුපිට ගොඩනැගිලි පරීක්ෂාව" : "Surface Texture Check",
      description: _isSinhala
          ? "යෙදුම ගම්මිරිස් ඇටවල තත්ත්වය තේරුම් ගැනීමට ඒවායේ මතුපිට පෙනුම ද පරීක්ෂා කරයි."
          : "The app also checks the surface appearance of pepper berries to understand their condition.",
      icon: Icons.texture_rounded,
      color: Colors.brown,
      details: _isSinhala
          ? [
              "කළු ගම්මිරිස් සාමාන්‍යයෙන් හොඳින් වියළී රැලි ගැසී පෙනෙන්නට ඕනෑ",
              "අසාමාන්‍ය ගොඩනැගිලි ගුණාත්මක ගැටළු පෙන්නුම් කළ හැකිය",
              "බිඳුණු හෝ අසාමාන්‍ය ඇට ලකුණු අඩු කළ හැකිය",
              "හොඳ ගොඩනැගිලි සාමාන්‍යයෙන් හොඳ සකසුම් ගුණාත්මකභාවය අදහස් කරයි",
            ]
          : [
              "Black pepper should usually look well dried and wrinkled",
              "Unusual texture may indicate quality issues",
              "Broken or abnormal berries can reduce the score",
              "Better texture usually means better processing quality",
            ],
    ),
    HowItWorksPage(
      title: _isSinhala
          ? "ලකුණු ගණනය කරන ආකාරය"
          : "How the Score is Calculated",
      description: _isSinhala
          ? "අවසාන ලකුණු ගණනය කිරීම සඳහා කිහිපයක් වැදගත් ගුණාත්මක සාධක ඒකාබද්ධ කෙරේ."
          : "The final score is calculated by combining several important quality factors.",
      icon: Icons.calculate_rounded,
      color: Colors.green,
      details: _isSinhala
          ? [
              "තොග ඝනත්වය ලකුණුවලට ඇතුළත් කෙරේ",
              "සාවද්‍ය මට්ටම ලකුණු ශක්තිමත් ලෙස බලපායි",
              "පීනස් මට්ටම ලකුණු අඩු කරයි",
              "ආගන්තුක ද්‍රව්‍ය පිරිසිදු ලකුණු බලපායි",
              "ගොඩනැගිලි සහ දෘශ්‍ය සෞඛ්‍යසම්පන්න ඇටද සලකා බලනු ලැබේ",
              "අවසාන ලකුණු 100 න් ලබා දෙනු ලැබේ",
            ]
          : [
              "Bulk density is included in the score",
              "Adulteration level affects the score strongly",
              "Mold level reduces the score",
              "Extraneous matter affects cleanliness score",
              "Texture and visible healthy berries are also considered",
              "The final score is given out of 100",
            ],
    ),
    HowItWorksPage(
      title: _isSinhala ? "ගුණාත්මක ශ්‍රේණි" : "Quality Grades",
      description: _isSinhala
          ? "අවසාන ලකුණු මත පදනම්ව, ඔබේ ගම්මිරිස් නියදිය ගුණාත්මක ශ්‍රේණියකට ලැකෙනු ලැබේ."
          : "Based on the final score, your pepper sample is placed into a quality grade.",
      icon: Icons.workspace_premium_rounded,
      color: Colors.amber,
      details: _isSinhala
          ? [
              "ශ්‍රේණිය 1 - ප්‍රිමියම්: 90 සහ ඊට ඉහළ",
              "ශ්‍රේණිය 2 - රන්: 80 සිට 89 දක්වා",
              "ශ්‍රේණිය 3 - රිදී: 65 සිට 79 දක්වා",
              "ශ්‍රේණිය 4 - මූලික: 50 සිට 64 දක්වා",
              "ප්‍රතික්ෂේප: 50 ට අඩු",
              "සත්‍යාපිත සහතික කිරීම් කුඩා ප්‍රසාද ලකුණු ලබා දිය හැකිය",
            ]
          : [
              "Grade 1 - Premium: 90 and above",
              "Grade 2 - Gold: 80 to 89",
              "Grade 3 - Silver: 65 to 79",
              "Grade 4 - Basic: 50 to 64",
              "Reject: below 50",
              "Verified certifications can give a small bonus",
            ],
    ),
    HowItWorksPage(
      title: _isSinhala ? "ඔබේ අවසාන වාර්තාව" : "Your Final Report",
      description: _isSinhala
          ? "ශ්‍රේණිගත කිරීමෙන් පසු, ඔබේ ප්‍රතිඵල සහ වැඩිදියුණු කිරීම් සඳහා යෝජනා පෙන්වන පැහැදිලි වාර්තාවක් ලැබෙනු ඇත."
          : "After grading, you will receive a clear report showing your results and suggestions for improvement.",
      icon: Icons.description_rounded,
      color: Colors.deepPurple,
      details: _isSinhala
          ? [
              "සමස්ත ශ්‍රේණිය සහ මුළු ලකුණු",
              "සෑම ගුණාත්මක සාධකයකම විස්තරය",
              "නියදිවල හඳුනාගත් ගැටළු",
              "අනාගත ශ්‍රේණිය වැඩිදියුණු කිරීමට යෝජනා",
              "ගැනුම්කරුවන් සහ ගොවීන් සඳහා ප්‍රයෝජනවත් තොරතුරු",
              "පහසුවෙන් තේරුම්ගත හැකි ගුණාත්මක සාරාංශය",
            ]
          : [
              "Overall grade and total score",
              "Breakdown of each quality factor",
              "Detected problems in the sample",
              "Suggestions to improve future batches",
              "Useful information for buyers and farmers",
              "Easy-to-understand quality summary",
            ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isSinhala ? "ක්‍රියා කරන ආකාරය" : "How It Works",
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _buildPageContent(_pages[index]);
              },
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildPageContent(HowItWorksPage page) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;
    final hPad = isSmall ? 16.0 : 24.0;
    final iconSize = isSmall ? 60.0 : 80.0;
    final titleSize = isSmall ? 20.0 : 22.0;
    final descSize = isSmall ? 13.0 : 15.0;
    final detailSize = isSmall ? 13.0 : 14.0;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),

            Container(
              padding: EdgeInsets.all(isSmall ? 22 : 28),
              decoration: BoxDecoration(
                color: page.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(page.icon, size: iconSize, color: page.color),
            ),

            const SizedBox(height: 24),

            Text(
              page.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w800,
                color: Colors.grey[900],
                height: 1.3,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              page.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: descSize,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: page.details.map((detail) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: page.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: page.color,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            detail,
                            style: TextStyle(
                              fontSize: detailSize,
                              color: Colors.grey[800],
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final isSmall = MediaQuery.of(context).size.width < 360;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 16 : 24,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dot indicators — wrap so they never overflow
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: List.generate(_pages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 8,
                  width: _currentPage == index ? 28 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color(0xFF2E7D32)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: Text(
                        _isSinhala ? "පෙර" : "Previous",
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: const Color(0xFF2E7D32),
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                if (_currentPage > 0) const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    icon: Icon(
                      _currentPage < _pages.length - 1
                          ? Icons.arrow_forward_rounded
                          : Icons.check_rounded,
                      size: 18,
                    ),
                    label: Text(
                      _currentPage < _pages.length - 1
                          ? (_isSinhala ? "ඊළඟ" : "Next")
                          : (_isSinhala ? "හරි" : "Got It"),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
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
    );
  }
}

class HowItWorksPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> details;

  HowItWorksPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.details,
  });
}
