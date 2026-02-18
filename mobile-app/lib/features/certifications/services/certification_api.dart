import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/certification_model.dart';

class CertificationApi {
  CertificationApi({required this.baseUrl});

  final String baseUrl;

  Future<Map<String, String>> _headers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Not logged in");
    }
    final token = await user.getIdToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse("$baseUrl$path").replace(queryParameters: query);
  }

  Future<List<CertificationModel>> getMyCertifications({
    String? status, // pending|verified|rejected (do not pass expired)
    String? q,
    String? type,
    String? issuingBody,
    String? sort, // newest|oldest|expiry
  }) async {
    final headers = await _headers();

    final query = <String, String>{};
    if (status != null && status.isNotEmpty && status != "all") query["status"] = status;
    if (q != null && q.isNotEmpty) query["q"] = q;
    if (type != null && type.isNotEmpty) query["type"] = type;
    if (issuingBody != null && issuingBody.isNotEmpty) query["issuingBody"] = issuingBody;
    if (sort != null && sort.isNotEmpty) query["sort"] = sort;

    final res = await http.get(_uri("/api/certifications/me", query), headers: headers);

    if (res.statusCode != 200) {
      throw Exception("Failed to load certifications: ${res.body}");
    }

    final list = jsonDecode(res.body) as List;
    return list.map((e) => CertificationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CertificationModel> createCertification({
    required String certificationType,
    required String certificateNumber,
    required String issuingBody,
    required DateTime issueDate,
    required DateTime expiryDate,
  }) async {
    final headers = await _headers();
    final body = jsonEncode({
      "certificationType": certificationType,
      "certificateNumber": certificateNumber,
      "issuingBody": issuingBody,
      "issueDate": issueDate.toIso8601String(),
      "expiryDate": expiryDate.toIso8601String(),
    });

    final res = await http.post(
      _uri("/api/certifications"),
      headers: headers,
      body: body,
    );

    if (res.statusCode != 201) {
      throw Exception("Create failed: ${res.body}");
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return CertificationModel.fromJson(json["cert"] as Map<String, dynamic>);
  }

  Future<CertificationModel> getById(String id) async {
    final headers = await _headers();
    final res = await http.get(_uri("/api/certifications/$id"), headers: headers);

    if (res.statusCode != 200) {
      throw Exception("Load failed: ${res.body}");
    }

    return CertificationModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<CertificationModel> updateCertification(
    String id, {
    String? certificationType,
    String? certificateNumber,
    String? issuingBody,
    DateTime? issueDate,
    DateTime? expiryDate,
  }) async {
    final headers = await _headers();

    final payload = <String, dynamic>{};
    if (certificationType != null) payload["certificationType"] = certificationType;
    if (certificateNumber != null) payload["certificateNumber"] = certificateNumber;
    if (issuingBody != null) payload["issuingBody"] = issuingBody;
    if (issueDate != null) payload["issueDate"] = issueDate.toIso8601String();
    if (expiryDate != null) payload["expiryDate"] = expiryDate.toIso8601String();

    final res = await http.patch(
      _uri("/api/certifications/$id"),
      headers: headers,
      body: jsonEncode(payload),
    );

    if (res.statusCode != 200) {
      throw Exception("Update failed: ${res.body}");
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return CertificationModel.fromJson(json["cert"] as Map<String, dynamic>);
  }

  Future<void> deleteCertification(String id) async {
    final headers = await _headers();
    final res = await http.delete(_uri("/api/certifications/$id"), headers: headers);

    if (res.statusCode != 200) {
      throw Exception("Delete failed: ${res.body}");
    }
  }
}
