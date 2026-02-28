import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../config/api.dart';

// Only import dart:io on non-web platforms
import 'dart:io' as io show SocketException;

class YieldPredictionService {
  // Your local FastAPI endpoints
  static const String _baseUrl = 'http://127.0.0.1:8000';

  // For production, use a remote server IP
  // static const String _baseUrl = 'http://192.168.x.x:8000';

  /// Predict yield from plant image and environmental data
  ///
  /// Parameters:
  /// - [imageFile]: Plant image file (XFile from image_picker, works on all platforms)
  /// - [soilMoisture]: Soil moisture percentage (0-100)
  /// - [temperature]: Environmental temperature in °C
  /// - [rainfall]: Optional rainfall in mm
  ///
  /// Returns: Predicted yield value
  Future<double> predictYield({
    required dynamic imageFile,
    required double soilMoisture,
    required double temperature,
    double? rainfall,
    String? plantAge,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/predict'),
      );

      // Handle image file - works on both mobile and web
      Uint8List imageBytes;
      String fileName;

      // Try to get bytes from the file object
      try {
        if (imageFile is XFile) {
          // XFile from image_picker - works on all platforms
          imageBytes = await imageFile.readAsBytes();
          fileName = imageFile.name;
        } else if (!kIsWeb &&
            imageFile.runtimeType.toString().contains('File')) {
          // Mobile platform - use dart:io.File
          imageBytes = await imageFile.readAsBytes();
          fileName = imageFile.path.split('/').last;
        } else if (imageFile.runtimeType.toString().contains('PlatformFile')) {
          // Web platform - PlatformFile from file_picker
          imageBytes = imageFile.bytes ?? Uint8List(0);
          fileName = imageFile.name ?? 'image.jpg';
        } else if (imageFile is Uint8List) {
          // Already bytes
          imageBytes = imageFile;
          fileName = 'image.jpg';
        } else {
          throw Exception(
            'Unsupported image type: ${imageFile.runtimeType}. Please use XFile from image_picker.',
          );
        }

        if (imageBytes.isEmpty) {
          throw Exception('Image file is empty. Please select a valid image.');
        }
      } catch (e) {
        throw Exception('Error reading image: $e');
      }

      // Add image file using fromBytes (works on both platforms)
      request.files.add(
        http.MultipartFile.fromBytes('image', imageBytes, filename: fileName),
      );

      // Add form fields
      request.fields['soil_moisture'] = soilMoisture.toString();
      request.fields['temperature'] = temperature.toString();

      if (rainfall != null) {
        request.fields['rainfall'] = rainfall.toString();
      }
      if (plantAge != null) {
        request.fields['plant_age'] = plantAge;
      }

      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException(
            'Prediction request timed out after 30 seconds',
          );
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(await response.stream.bytesToString());
        return (responseData['predicted_yield'] ?? responseData['yield'] ?? 0.0)
            .toDouble();
      } else {
        final errorBody = await response.stream.bytesToString();
        throw Exception(
          'Failed to predict yield: ${response.statusCode} - $errorBody',
        );
      }
    } on io.SocketException {
      throw Exception(
        'Cannot connect to prediction server. Ensure the API is running on $_baseUrl',
      );
    } catch (e) {
      throw Exception('Error predicting yield: $e');
    }
  }

  /// Get health status of the prediction API
  Future<bool> healthCheck() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Update the FastAPI server URL (e.g., when using remote server)
  static void setBaseUrl(String url) {
    // This would require making the const mutable
    // For now, edit this file directly based on your deployment
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
