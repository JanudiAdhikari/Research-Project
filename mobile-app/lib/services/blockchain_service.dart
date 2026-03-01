import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api.dart';

class BlockchainService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: 'token');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

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
      }

      if (decoded is Map && decoded['data'] is List) {
        return (decoded['data'] as List)
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
      }

      return [];
    }

    throw Exception(
      'Failed to load quality checks (${res.statusCode}): ${res.body}',
    );
  }

  // Verify a record by its ID, updating status -> VERIFIED
  static Future<Map<String, dynamic>> verifyRecord(String recordId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/market-forecast/actual-price-data/$recordId',
    );

    final res = await http
        .put(
          uri,
          headers: await _headers(),
          body: jsonEncode({'currentStatus': 'VERIFIED'}),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      return Map<String, dynamic>.from(decoded as Map);
    }

    throw Exception('Failed to verify record (${res.statusCode}): ${res.body}');
  }

  // Mark QR generated for a VERIFIED record (status -> QR_GENERATED)
  static Future<Map<String, dynamic>> generateQr(String recordId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/market-forecast/actual-price-data/$recordId',
    );

    final res = await http
        .put(
          uri,
          headers: await _headers(),
          body: jsonEncode({'currentStatus': 'QR_GENERATED'}),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      return Map<String, dynamic>.from(decoded as Map);
    }

    throw Exception('Failed to generate QR (${res.statusCode}): ${res.body}');
  }

  // Exporter scans QR token and fetches batch/record details
  static Future<Map<String, dynamic>> getRecordByQrToken(String qrToken) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/market-forecast/actual-price-data/qr/$qrToken',
    );

    final res = await http
        .get(uri, headers: await _headers())
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      return Map<String, dynamic>.from(decoded as Map);
    }

    throw Exception(
      'Failed to fetch record by QR (${res.statusCode}): ${res.body}',
    );
  }
}
