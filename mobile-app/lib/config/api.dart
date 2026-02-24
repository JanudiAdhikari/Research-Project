class ApiConfig {
  // emulator
  static const String baseUrl = "http://10.0.2.2:5000";

  // For physical device:
  // cmd -> ipconfig -> IPv4 Address (Wi-Fi adapter)
  // static const String baseUrl = "http://IPv4 Address:5000";
  //  static const String baseUrl = "http://10.126.124.24:5000";
   static const String fastApiBaseUrl = "http://10.126.124.24:8000"; // inference server
}
