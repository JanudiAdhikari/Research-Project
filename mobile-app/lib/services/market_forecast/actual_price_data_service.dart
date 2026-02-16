import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api.dart';
import '../auth_service.dart';

class ActualPriceDataService {
  final AuthService _auth = AuthService();

  Future<Map<String, dynamic>> createActualPriceData(
    Map<String, dynamic> body,
  ) async {
    final token = await _auth.storage.read(key: 'token');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/market-forecast/actual-price-data',
    );
    final res = await http
        .post(uri, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 201 || res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{};
    }

    throw Exception('Failed to create record: ${res.statusCode} ${res.body}');
  }
}
