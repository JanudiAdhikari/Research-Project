import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api.dart';

class PastExportPriceService {
  // Fetch available years for past export prices
  Future<List<int>> fetchYears() async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/market-forecast/past-export-prices/years',
      );
      final res = await http
          .get(
            uri,
            headers: <String, String>{'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body is List) {
          return body
              .map((e) => int.tryParse(e.toString()) ?? 0)
              .where((year) => year > 0)
              .toList();
        }
      }

      throw Exception('Failed to load years: ${res.statusCode}');
    } catch (e) {
      throw Exception('Error fetching years: $e');
    }
  }

  // Fetch past export prices with optional filters
  Future<List<Map<String, dynamic>>> fetchPastExportPrices({
    required int year,
    String? monthFrom,
    String? monthTo,
  }) async {
    try {
      final queryParams = <String, String>{'year': year.toString()};
      if (monthFrom != null) queryParams['month_from'] = monthFrom;
      if (monthTo != null) queryParams['month_to'] = monthTo;

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/market-forecast/past-export-prices',
      ).replace(queryParameters: queryParams);

      final res = await http
          .get(
            uri,
            headers: <String, String>{'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body is List) {
          return body
              .whereType<Map<String, dynamic>>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }

      throw Exception('Failed to load prices: ${res.statusCode}');
    } catch (e) {
      throw Exception('Error fetching prices: $e');
    }
  }
}
