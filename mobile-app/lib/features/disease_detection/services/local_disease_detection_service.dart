import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class LocalDiseaseDetectionService {
  static Interpreter? _interpreter;

  /// Disease class mappings for local model
  static const Map<int, Map<String, String>> DISEASE_CLASSES = {
    0: {
      'name': 'Healthy',
      'description': 'The leaf appears healthy with no visible signs of disease.',
      'treatment': 'Continue with regular maintenance and monitoring.',
      'severity': 'None'
    },
    1: {
      'name': 'Bacterial Spot',
      'description': 'Dark, greasy spots on leaves caused by bacterial infection.',
      'treatment': 'Remove infected leaves, apply copper-based fungicides, ensure good air circulation.',
      'severity': 'High',
      'prevention': 'Avoid overhead watering, practice crop rotation.'
    },
    2: {
      'name': 'Bell Pepper Blight',
      'description': 'Fungal disease causing brown spots and leaf wilt.',
      'treatment': 'Remove affected plant parts, apply fungicide, improve drainage.',
      'severity': 'High',
      'prevention': 'Ensure proper spacing for air circulation, avoid wet leaves.'
    },
    3: {
      'name': 'Target Spot',
      'description': 'Circular spots with concentric rings on leaves.',
      'treatment': 'Apply fungicide, remove infected leaves, maintain proper humidity.',
      'severity': 'Medium',
      'prevention': 'Reduce humidity, avoid overhead irrigation.'
    }
  };

  /// Initialize the TensorFlow Lite interpreter
  static Future<void> loadModel() async {
    try {
      // Load model from assets or local path
      _interpreter = await Interpreter.fromAsset('models/pepper_disease_classifier.tflite');
      print('Model loaded successfully');
    } catch (e) {
      throw Exception('Failed to load model: $e');
    }
  }

  /// Preprocess image for TFLite model
  static List<List<List<List<double>>>> preprocessImage(File imageFile) {
    try {
      // Read image
      var imageData = imageFile.readAsBytesSync();
      var decodedImage = img.decodeImage(imageData);

      if (decodedImage == null) {
        throw Exception('Failed to decode image');
      }

      // Resize to 224x224 (adjust based on your model)
      var resizedImage = img.copyResize(decodedImage,
          width: 224, height: 224, interpolation: img.Interpolation.linear);

      // Normalize to float32 array
      List<List<List<List<double>>>> input = List.generate(
        1,
        (batch) => List.generate(
          224,
          (y) => List.generate(
            224,
            (x) => List.generate(
              3,
              (c) {
                var pixel = resizedImage.getPixelSafe(x, y);
                // Normalize to 0-1 range
                if (c == 0) return pixel.r.toDouble() / 255.0;
                if (c == 1) return pixel.g.toDouble() / 255.0;
                return pixel.b.toDouble() / 255.0;
              },
            ),
          ),
        ),
      );

      return input;
    } catch (e) {
      throw Exception('Image preprocessing failed: $e');
    }
  }

  /// Run inference on image
  static Future<LocalDiseaseDetectionResult> detectDiseaseLocally(
      File imageFile) async {
    try {
      if (_interpreter == null) {
        await loadModel();
      }

      // Preprocess image
      var input = preprocessImage(imageFile);

      // Run inference - create output tensor properly
      var output = List<List<double>>.generate(1, (i) => List<double>.filled(4, 0.0));
      _interpreter!.run(input, output);

      // Get predictions
      List<double> predictions = output[0];

      // Find argmax (highest confidence class)
      int predictedClass = 0;
      double maxConfidence = 0.0;
      for (int i = 0; i < predictions.length; i++) {
        if (predictions[i] > maxConfidence) {
          maxConfidence = predictions[i];
          predictedClass = i;
        }
      }

      // Get disease info
      var diseaseInfo = DISEASE_CLASSES[predictedClass] ?? {
        'name': 'Unknown',
        'description': 'Unable to classify the disease.',
        'treatment': 'Consult with a plant pathologist.',
        'severity': 'Unknown'
      };

      // Create all predictions map
      Map<String, double> allPredictions = {};
      for (int i = 0; i < DISEASE_CLASSES.length; i++) {
        var name = DISEASE_CLASSES[i]?['name'] ?? 'Unknown';
        allPredictions[name] = predictions[i];
      }

      return LocalDiseaseDetectionResult(
        disease: diseaseInfo['name'] ?? 'Unknown',
        confidence: maxConfidence * 100,
        description: diseaseInfo['description'] ?? '',
        treatment: diseaseInfo['treatment'] ?? '',
        severity: diseaseInfo['severity'] ?? '',
        prevention: diseaseInfo['prevention'] ?? '',
        allPredictions: allPredictions,
      );
    } catch (e) {
      throw Exception('Disease detection failed: $e');
    }
  }

  /// Cleanup resources
  static void dispose() {
    _interpreter?.close();
  }
}

class LocalDiseaseDetectionResult {
  final String disease;
  final double confidence;
  final String description;
  final String treatment;
  final String severity;
  final String prevention;
  final Map<String, double> allPredictions;

  LocalDiseaseDetectionResult({
    required this.disease,
    required this.confidence,
    required this.description,
    required this.treatment,
    required this.severity,
    required this.prevention,
    required this.allPredictions,
  });

  /// Check if the leaf is healthy
  bool get isHealthy => disease.toLowerCase() == 'healthy';

  /// Check if severity is high
  bool get isHighSeverity => severity.toLowerCase() == 'high';

  /// Get severity color for UI
  String getSeverityColor() {
    switch (severity.toLowerCase()) {
      case 'high':
        return '#FF6B6B'; // Red
      case 'medium':
        return '#FFA500'; // Orange
      case 'low':
        return '#FFD700'; // Yellow
      default:
        return '#4CAF50'; // Green (None/Healthy)
    }
  }
}

