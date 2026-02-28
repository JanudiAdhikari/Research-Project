class ApiConfig {
  // emulator
  //static const String baseUrl = "http://10.0.2.2:5000";

  // For physical device:
  // cmd -> ipconfig -> IPv4 Address (Wi-Fi adapter)
  // static const String baseUrl = "http://IPv4 Address:5000";
  static const String baseUrl = "http://192.168.1.5:5000";
  static const String fastApiBaseUrl =
      "http://10.245.15.36:8000"; // inference server

  // Yield Prediction API - Change this to your running FastAPI server
  // For local development: http://127.0.0.1:8000
  // For physical device: http://<your-machine-ip>:8000
  static const String yieldPredictionApiUrl = "http://127.0.0.1:8000";
}
