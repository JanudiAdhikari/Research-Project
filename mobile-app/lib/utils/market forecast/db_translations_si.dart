class MarketForecastSi {
  static const Map<String, String> countries = {
    'india': 'ඉන්දියාව',
    'germany': 'ජර්මනිය',
    'spain': 'ස්පාඤ්ඤය',
    'uae': 'එක්සත් අරාබි එමීර් රාජ්‍යය',
    'japan': 'ජපානය',
    'uk': 'එක්සත් රාජධානිය',
    'usa': 'එක්සත් ජනපදය',
    'canada': 'කැනඩාව',
  };

  static const Map<String, String> districts = {
    'badulla': 'බදුල්ල',
    'colombo': 'කොළඹ',
    'galle': 'ගාල්ල',
    'gampaha': 'ගම්පහ',
    'hambantota': 'හම්බන්තොට',
    'kalutara': 'කළුතර',
    'kandy': 'මහනුවර',
    'kegalle': 'කෑගල්ල',
    'kurunegala': 'කුරුණෑගල',
    'matale': 'මාතලේ',
    'matara': 'මාතර',
    'monaragala': 'මොණරාගල',
    'nuwara eliya': 'නුවර එළිය',
    'ratnapura': 'රත්නපුර',
  };

  static const Map<String, String> pepperTypes = {
    'ground pepper': 'ගම්මිරිස් කුඩු (Ground Pepper)',
    'whole pepper': 'පූර්ණ ගම්මිරිස් (Whole Pepper)',
    'pepper oil': 'ගම්මිරිස් තෙල් (Pepper Oil)',
    'pepper oleoresin': 'ගම්මිරිස් ඔලියෝරෙසින් (Pepper Oleoresin)',
    'black': 'කළු ගම්මිරිස්',
    'white': 'සුදු ගම්මිරිස්',
  };

  static const Map<String, String> grades = {
    'grade 1': 'Grade 1',
    'grade 2': 'Grade 2',
  };

  static String translateCountry(String? country) {
    if (country == null) return '';
    final key = country.trim().toLowerCase();
    // try direct match
    if (countries.containsKey(key)) return countries[key]!;
    // try first token (e.g., 'united states' -> 'united')
    final short = key.split(' ').first;
    return countries[short] ?? country;
  }

  static String translatePepperType(String? type) {
    if (type == null) return '';
    final key = type.trim().toLowerCase();
    if (pepperTypes.containsKey(key)) return pepperTypes[key]!;
    // fuzzy matches
    if (key.contains('ground') || key.contains('powder'))
      return pepperTypes['ground pepper']!;
    if (key.contains('whole')) return pepperTypes['whole pepper']!;
    if (key.contains('oleo') || key.contains('oleoresin'))
      return pepperTypes['pepper oleoresin']!;
    if (key.contains('oil')) return pepperTypes['pepper oil']!;
    return type;
  }

  static String translateGrade(String? grade) {
    if (grade == null) return '';
    final key = grade.trim().toLowerCase();
    return grades[key] ?? grade;
  }

  static String translateDistrict(String? district) {
    if (district == null) return '';
    final key = district.trim().toLowerCase();
    return districts[key] ?? district;
  }
}
