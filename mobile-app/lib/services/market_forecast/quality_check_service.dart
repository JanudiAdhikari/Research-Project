import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api.dart';
import '../auth_service.dart';

class QualityCheckService {
  final AuthService _auth = AuthService();

  // Fetch quality checks for the logged-in user
  Future<List<Map<String, dynamic>>> fetchMyQualityChecks() async {
    final token = await _auth.storage.read(key: 'token');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/quality-checks/batchdetails',
    );
    final res = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body is List) {
        return body
            .whereType<Map<String, dynamic>>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return <Map<String, dynamic>>[];
    }

    throw Exception(
      'Failed to fetch quality checks: ${res.statusCode} ${res.body}',
    );
  }
}
