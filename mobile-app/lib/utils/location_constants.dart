class DistrictInfo {
  final String name;
  final String nameSi;
  final double latitude;
  final double longitude;

  const DistrictInfo({
    required this.name,
    required this.nameSi,
    required this.latitude,
    required this.longitude,
  });
}

class LocationConstants {
  static const List<DistrictInfo> districts = [
    DistrictInfo(name: 'Ampara', nameSi: 'අම්පාර', latitude: 7.2842, longitude: 81.6747),
    DistrictInfo(name: 'Anuradhapura', nameSi: 'අනුරාධපුරය', latitude: 8.3114, longitude: 80.4037),
    DistrictInfo(name: 'Badulla', nameSi: 'බදුල්ල', latitude: 6.9934, longitude: 81.0550),
    DistrictInfo(name: 'Batticaloa', nameSi: 'මඩකලපුව', latitude: 7.7102, longitude: 81.6924),
    DistrictInfo(name: 'Colombo', nameSi: 'කොළඹ', latitude: 6.9271, longitude: 79.8612),
    DistrictInfo(name: 'Galle', nameSi: 'ගාල්ල', latitude: 6.0367, longitude: 80.2170),
    DistrictInfo(name: 'Gampaha', nameSi: 'ගම්පහ', latitude: 7.0873, longitude: 80.0144),
    DistrictInfo(name: 'Hambantota', nameSi: 'හම්බන්තොට', latitude: 6.1247, longitude: 81.1185),
    DistrictInfo(name: 'Jaffna', nameSi: 'යාපනය', latitude: 9.6615, longitude: 80.0255),
    DistrictInfo(name: 'Kalutara', nameSi: 'කළුතර', latitude: 6.5854, longitude: 79.9607),
    DistrictInfo(name: 'Kandy', nameSi: 'මහනුවර', latitude: 7.2906, longitude: 80.6337),
    DistrictInfo(name: 'Kegalle', nameSi: 'කෑගල්ල', latitude: 7.2513, longitude: 80.3464),
    DistrictInfo(name: 'Kilinochchi', nameSi: 'කිලිනොච්චිය', latitude: 9.3803, longitude: 80.3983),
    DistrictInfo(name: 'Kurunegala', nameSi: 'කුරුණෑගල', latitude: 7.4818, longitude: 80.3609),
    DistrictInfo(name: 'Mannar', nameSi: 'මන්නාරම', latitude: 8.9810, longitude: 79.9044),
    DistrictInfo(name: 'Matale', nameSi: 'මාතලේ', latitude: 7.4675, longitude: 80.6234),
    DistrictInfo(name: 'Matara', nameSi: 'මාතර', latitude: 5.9549, longitude: 80.5550),
    DistrictInfo(name: 'Moneragala', nameSi: 'මොනරාගල', latitude: 6.8700, longitude: 81.3500),
    DistrictInfo(name: 'Mullaitivu', nameSi: 'මුලතිව්', latitude: 9.2671, longitude: 80.8142),
    DistrictInfo(name: 'Nuwara Eliya', nameSi: 'නුවරඑළිය', latitude: 6.9497, longitude: 80.7891),
    DistrictInfo(name: 'Polonnaruwa', nameSi: 'පොළොන්නරුව', latitude: 7.9403, longitude: 81.0188),
    DistrictInfo(name: 'Puttalam', nameSi: 'පුත්තලම', latitude: 8.0330, longitude: 79.8250),
    DistrictInfo(name: 'Ratnapura', nameSi: 'රත්නපුරය', latitude: 6.6828, longitude: 80.3992),
    DistrictInfo(name: 'Trincomalee', nameSi: 'ත්‍රිකුණාමලය', latitude: 8.5711, longitude: 81.2335),
    DistrictInfo(name: 'Vavuniya', nameSi: 'වවුනියාව', latitude: 8.7542, longitude: 80.4982),
  ];
}
