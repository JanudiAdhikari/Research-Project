import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import 'auth_service.dart';
import '../models/market_product.dart';

class MarketService {
  final AuthService _auth = AuthService();

  Future<List<MarketProduct>> fetchProducts() async {
    final token = await _auth.storage.read(key: 'token');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/market/products');
    final res = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body is List) {
        return body
            .map((e) => MarketProduct.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      final list = body['data'] ?? body['products'] ?? [];
      if (list is List)
        return list
            .map((e) => MarketProduct.fromJson(e as Map<String, dynamic>))
            .toList();
    }

    throw Exception('Failed to load market products: ${res.statusCode}');
  }

  Future<T> _retry<T>(Future<T> Function() fn, {int attempts = 3}) async {
    int i = 0;
    while (true) {
      try {
        return await fn();
      } catch (e) {
        i++;
        if (i >= attempts) rethrow;
        await Future.delayed(Duration(milliseconds: 200 * (1 << i)));
      }
    }
  }

  Future<MarketProduct> createProduct(Map<String, dynamic> body) async {
    return _retry(() async {
      final token = await _auth.storage.read(key: 'token');
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/market/products');
      final res = await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 201 || res.statusCode == 200) {
        return MarketProduct.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>,
        );
      }
      throw Exception(
        'Failed to create product: ${res.statusCode} ${res.body}',
      );
    });
  }

  Future<MarketProduct> updateProduct(
    String id,
    Map<String, dynamic> body,
  ) async {
    return _retry(() async {
      final token = await _auth.storage.read(key: 'token');
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/market/products/$id');
      final res = await http
          .put(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        return MarketProduct.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>,
        );
      }
      throw Exception(
        'Failed to update product: ${res.statusCode} ${res.body}',
      );
    });
  }
}
