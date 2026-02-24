import 'dart:convert';
import 'package:http/http.dart' as http;

class PricePredictionService {
  final String apiUrl;
  PricePredictionService({required this.apiUrl});

  Future<double?> fetchPredictedPrice({
    required String district,
    required String pepperType,
    required String grade,
    required int year,
    required int month,
    required int week,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'district': district,
          'pepper_type': pepperType,
          'grade': grade,
          'year': year,
          'month': month,
          'week': week,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['predicted_price_LKR_per_kg']?.toDouble();
      } else {
        print('Price prediction error: \\${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Price prediction exception: $e');
      return null;
    }
  }
}
