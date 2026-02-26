// Sinhala translations for Export Price Trends screen
class ExportPriceTrendsSi {
  static const String pageTitle = 'පසුගිය අපනයන මිල ප්‍රවණතා';
  static const String headerTitle = 'පසුගිය අපනයන මිල විශ්ලේෂණය';
  static const String headerBody =
      'ශ්‍රී ලංකාවේ ගම්මිරිස්වල පසුගිය අපනයන මිල බලන්න. ප්‍රවණතා විශ්ලේෂණය කර නිසි තීරණ ගන්න.';

  static const String exportDetailsByCountry = 'රට අනුව අපනයන විස්තර';
  static const String exportDetailsBody =
      'රට අනුව පරිමාවන්, මිල සහ ප්‍රවණතා බලන්න.';
  static const String view = 'බලන්න';

  static const String filterData = 'දත්ත තෝරන්න';
  static const String year = 'වර්ෂය';
  static const String from = 'සිට';
  static const String to = 'දක්වා';

  static const String globalTrends = 'ගම්මිරිස්වල මිල ප්‍රවණතා';
  static const String noData = 'තෝරාගත් පරාසයට දත්ත නොමැත';

  static const String peakPrice = 'ඉහළම මිල';
  static const String lowestPrice = 'අඩුම මිල';
  static const String average = 'සාමාන්‍යය';
  static const String currency = 'රු.';

  static const String keyInsights = 'ප්‍රධාන කරුණු';
  static const String bullish = 'මිල ඉහළට යන ප්‍රවණතාවයක් ඇත';
  static const String bearish = 'මිල පහළට යන ප්‍රවණතාවයක් ඇත';
  static const String bullishDetail =
      'ඉදිරි මාසවල ඉල්ලුම ඉහළ යාම හේතුවෙන් මිල ඉහළ යාමේ ප්‍රවණතාවයක් දක්නට ලැබේ.';
  static const String bearishDetail =
      'ඉදිරි මාසවල සැපයුම වැඩි වීම හේතුවෙන් මිල අඩු වීමේ ප්‍රවණතාවයක් දක්නට ලැබේ.';

  static const String peakVsAverage = 'ඉහළම සහ සාමාන්‍ය';
  static const String peakVsAverageDetail =
      'අපනයන මිල සමහර අවස්ථාවල ඉහළම මට්ටමට ළඟා විය හැක. සැලසුම් සඳහා සාමාන්‍ය මිල පදනමක් ලෙස භාවිතා කරන්න.';

  static const String momentumStability = 'වෙනස්වීම් සහ ස්ථාවරත්වය';
  static const String momentumStabilityDetail =
      'මාසික මිල නිරීක්ෂණය කර, තොග නැව්ගත කිරීම් සඳහා ස්ථාවර කාලයන්ට ප්‍රමුඛත්වය දෙන්න.';

  static const String recommendation = 'නිර්දේශය';
  static const String recommendationBullish =
      'මිල ඉහළ යාමේ ප්‍රවණතාවක් පවතින විට, තොග නැව්ගත කිරීම ක්‍රමානුකූලව සිදු කරන්න.';
  static const String recommendationBearish =
      'මිල පහළ යාමේ ප්‍රවණතාවක් පවතින විට, අවදානම් පාලනය කර ලාභය ආරක්ෂා කරගන්න.';

  // Month translations 
  static const Map<String, String> _monthMap = {
    'jan': 'ජන',
    'feb': 'පෙබ',
    'mar': 'මාර්තු',
    'apr': 'අප්‍රේල්',
    'may': 'මැයි',
    'jun': 'ජූනි',
    'jul': 'ජූලි',
    'aug': 'අගෝ',
    'sep': 'සැප්',
    'oct': 'ඔක්',
    'nov': 'නොවැ',
    'dec': 'දෙසැ',
    'january': 'ජනවාරි',
    'february': 'පෙබරවාරි',
    'march': 'මාර්තු',
    'april': 'අප්‍රේල්',
    'mayfull': 'මැයි',
    'june': 'ජූනි',
    'july': 'ජූලි',
    'august': 'අගෝස්තු',
    'september': 'සැප්තැම්බර්',
    'october': 'ඔක්තෝබර්',
    'november': 'නොවැම්බර්',
    'december': 'දෙසැම්බර්',
  };

  static String translateMonth(String? month) {
    if (month == null) return '';
    final key = month.trim().toLowerCase();
    // handle short names like 'Jan' and full names
    if (_monthMap.containsKey(key)) return _monthMap[key]!;
    // try first 3 letters
    if (key.length >= 3) {
      final short = key.substring(0, 3);
      if (_monthMap.containsKey(short)) return _monthMap[short]!;
    }
    return month;
  }
}
