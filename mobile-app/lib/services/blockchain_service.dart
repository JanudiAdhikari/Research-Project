import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api.dart';

class BlockchainService {
  // Fetch quality checks for a given batchId
  static Future<List<Map<String, dynamic>>> getQualityChecksByBatch(
    String batchId,
  ) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/quality-checks/batch/$batchId',
    );

    final res = await http.get(uri).timeout(const Duration(seconds: 15));

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);

      if (decoded is List) {
        return decoded
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
      } else if (decoded is Map && decoded['data'] is List) {
        return (decoded['data'] as List)
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
      } else {
        return [];
      }
    }

    throw Exception('Failed to load quality checks (${res.statusCode})');
  }

  // Verify a record by its ID, updating its status to "VERIFIED"
  static Future<Map<String, dynamic>> verifyRecord(String recordId) async {
    final storage = const FlutterSecureStorage();

    final token = await storage.read(key: 'token');

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/market-forecast/actual-price-data/$recordId',
    );

    final res = await http
        .put(
          uri,
          headers: headers,
          body: jsonEncode({'currentStatus': 'VERIFIED'}),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return Map<String, dynamic>.from(decoded as Map);
    }

    throw Exception('Failed to verify record (${res.statusCode}): ${res.body}');
  }
}
