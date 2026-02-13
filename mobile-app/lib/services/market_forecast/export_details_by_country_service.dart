import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api.dart';

class ExportDetailsByCountryService {
  // Fetch all unique countries from the database
  Future<List<String>> fetchCountries() async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/market-forecast/export-details-by-country',
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
          // Extract unique countries from the response
          final countries = <String>{};
          for (var item in body) {
            if (item is Map<String, dynamic> && item.containsKey('country')) {
              countries.add(item['country'] as String);
            }
          }
          return countries.toList()..sort();
        }
      }

      throw Exception('Failed to load countries: ${res.statusCode}');
    } catch (e) {
      throw Exception('Error fetching countries: $e');
    }
  }

  // Fetch export details with optional filters
  Future<List<dynamic>> fetchExportDetails({
    String? country,
    String? pepperType,
    int? year,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (country != null) queryParams['country'] = country;
      if (pepperType != null) queryParams['pepper_type'] = pepperType;
      if (year != null) queryParams['year'] = year.toString();

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/market-forecast/export-details-by-country',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final res = await http
          .get(
            uri,
            headers: <String, String>{'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body is List) {
          return body;
        }
      }

      throw Exception('Failed to load export details: ${res.statusCode}');
    } catch (e) {
      throw Exception('Error fetching export details: $e');
    }
  }

  // Fetch available years for a specific country
  Future<List<int>> fetchYearsForCountry(String country) async {
    try {
      final details = await fetchExportDetails(country: country);
      final years = <int>{};
      for (var item in details) {
        if (item is Map<String, dynamic> && item.containsKey('year')) {
          years.add(item['year'] as int);
        }
      }
      return years.toList()..sort();
    } catch (e) {
      throw Exception('Error fetching years: $e');
    }
  }

  // Fetch details for a specific country and year
  Future<Map<String, dynamic>?> fetchDetailsByCountryAndYear(
    String country,
    int year,
  ) async {
    try {
      final details = await fetchExportDetails(country: country, year: year);
      if (details.isNotEmpty) {
        return details.first as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching details: $e');
    }
  }
}
