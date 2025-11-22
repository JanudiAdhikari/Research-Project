import 'package:camera/camera.dart';

class CameraService {
  static List<CameraDescription>? _cameras;
  static bool _isInitialized = false;
  static String? _initializationError;

  /// Initialize camera
  static Future<void> initializeCameras() async {
    try {
      print("🔄 Starting camera initialization...");
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception("No cameras found on this device");
      }

      _isInitialized = true;
      _initializationError = null;
      print("✅ Cameras initialized successfully: ${_cameras!.length} cameras found");

      for (var camera in _cameras!) {
        print("📷 Camera: ${camera.name}, Lens: ${camera.lensDirection}");
      }
    } catch (e) {
      print("❌ Error initializing cameras: $e");
      _isInitialized = false;
      _initializationError = e.toString();
      // Don't rethrow, just log the error
    }
  }

  /// Get available cameras
  static List<CameraDescription> get cameras {
    if (!_isInitialized || _cameras == null) {
      throw Exception("Cameras not initialized. Error: $_initializationError");
    }
    return _cameras!;
  }

  /// Get front camera (returns null if not found)
  static CameraDescription? get frontCamera {
    try {
      final availableCameras = cameras;
      return availableCameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    } catch (e) {
      print("Front camera not found: $e");
      return null;
    }
  }

  /// Get back camera (returns null if not found)
  static CameraDescription? get backCamera {
    try {
      final availableCameras = cameras;
      return availableCameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
      );
    } catch (e) {
      print("Back camera not found: $e");
      return null;
    }
  }

  /// Check if cameras are initialized
  static bool get isInitialized => _isInitialized && _cameras != null && _cameras!.isNotEmpty;

  /// Get initialization error message
  static String? get errorMessage => _initializationError;
}