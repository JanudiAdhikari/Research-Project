import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Check and request camera permission
  static Future<bool> requestCameraPermission() async {
    try {
      // Check if we have camera permission
      var status = await Permission.camera.status;

      if (status.isGranted) {
        print("✅ Camera permission already granted");
        return true;
      } else if (status.isDenied) {
        // Request camera permission
        status = await Permission.camera.request();

        if (status.isGranted) {
          print("✅ Camera permission granted");
          return true;
        } else if (status.isPermanentlyDenied) {
          print("❌ Camera permission permanently denied");
          return false;
        } else {
          print("❌ Camera permission denied");
          return false;
        }
      } else if (status.isPermanentlyDenied) {
        print("❌ Camera permission permanently denied");
        // User permanently denied, should show app settings
        return false;
      } else if (status.isRestricted) {
        print("❌ Camera permission restricted");
        return false;
      }

      return false;
    } catch (e) {
      print("❌ Error checking camera permission: $e");
      return false;
    }
  }

  /// Check and request storage permission (for gallery)
  static Future<bool> requestStoragePermission() async {
    try {
      Permission permission;

      // Use the appropriate permission based on Android version
      if (await Permission.storage.isRestricted) {
        permission = Permission.photos;
      } else {
        permission = Permission.storage;
      }

      var status = await permission.status;

      if (status.isGranted) {
        print("✅ Storage permission already granted");
        return true;
      } else if (status.isDenied) {
        status = await permission.request();

        if (status.isGranted) {
          print("✅ Storage permission granted");
          return true;
        } else {
          print("❌ Storage permission denied");
          return false;
        }
      } else if (status.isPermanentlyDenied) {
        print("❌ Storage permission permanently denied");
        return false;
      }

      return false;
    } catch (e) {
      print("❌ Error checking storage permission: $e");
      return false;
    }
  }
}