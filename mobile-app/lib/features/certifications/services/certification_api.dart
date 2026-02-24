import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/certification_model.dart';

class CertificationApi {
  CertificationApi({required this.baseUrl});

  final String baseUrl;

  Future<String> _token() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Not logged in");
    }

    final token = await user.getIdToken(true);
    if (token == null || token.isEmpty) {
      throw Exception("Failed to get auth token");
    }

    return token;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse("$baseUrl$path").replace(queryParameters: query);
  }

  Map<String, String> _authHeader(String token) {
    return {"Authorization": "Bearer $token"};
  }

  Map<String, String> _jsonHeaders(String token) {
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<List<CertificationModel>> getMyCertifications({
    String? status, // pending|verified|rejected (do not pass expired)
    String? q,
    String? type,
    String? issuingBody,
    String? sort, // newest|oldest|expiry
  }) async {
    final token = await _token();

    final query = <String, String>{};
    if (status != null && status.isNotEmpty && status != "all")
      query["status"] = status;
    if (q != null && q.isNotEmpty) query["q"] = q;
    if (type != null && type.isNotEmpty) query["type"] = type;
    if (issuingBody != null && issuingBody.isNotEmpty)
      query["issuingBody"] = issuingBody;
    if (sort != null && sort.isNotEmpty) query["sort"] = sort;

    final res = await http.get(
      _uri("/api/certifications/me", query),
      headers: _jsonHeaders(token),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load certifications: ${res.body}");
    }

    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => CertificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CertificationModel> getById(String id) async {
    final token = await _token();
    final res = await http.get(
      _uri("/api/certifications/$id"),
      headers: _jsonHeaders(token),
    );

    if (res.statusCode != 200) {
      throw Exception("Load failed: ${res.body}");
    }

    return CertificationModel.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
  }

  Future<CertificationModel> createCertification({
    required String certificationType,
    required String certificateNumber,
    required String issuingBody,
    required DateTime issueDate,
    required DateTime expiryDate,
    File? attachmentFile, // optional
  }) async {
    final token = await _token();

    final req = http.MultipartRequest("POST", _uri("/api/certifications"));
    req.headers.addAll(_authHeader(token));

    req.fields["certificationType"] = certificationType;
    req.fields["certificateNumber"] = certificateNumber;
    req.fields["issuingBody"] = issuingBody;
    req.fields["issueDate"] = issueDate.toIso8601String();
    req.fields["expiryDate"] = expiryDate.toIso8601String();

    if (attachmentFile != null) {
      req.files.add(
        await http.MultipartFile.fromPath("attachment", attachmentFile.path),
      );
    }

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode != 201) {
      throw Exception("Create failed: ${res.body}");
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return CertificationModel.fromJson(json["cert"] as Map<String, dynamic>);
  }

  Future<CertificationModel> updateCertification(
    String id, {
    String? certificationType,
    String? certificateNumber,
    String? issuingBody,
    DateTime? issueDate,
    DateTime? expiryDate,
    bool removeAttachment = false,
    File? newAttachmentFile,
  }) async {
    final token = await _token();

    final req = http.MultipartRequest("PATCH", _uri("/api/certifications/$id"));
    req.headers.addAll(_authHeader(token));

    if (certificationType != null)
      req.fields["certificationType"] = certificationType;
    if (certificateNumber != null)
      req.fields["certificateNumber"] = certificateNumber;
    if (issuingBody != null) req.fields["issuingBody"] = issuingBody;
    if (issueDate != null)
      req.fields["issueDate"] = issueDate.toIso8601String();
    if (expiryDate != null)
      req.fields["expiryDate"] = expiryDate.toIso8601String();

    if (removeAttachment) {
      req.fields["removeAttachment"] = "true";
    }

    if (newAttachmentFile != null) {
      req.files.add(
        await http.MultipartFile.fromPath("attachment", newAttachmentFile.path),
      );
    }

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode != 200) {
      throw Exception("Update failed: ${res.body}");
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return CertificationModel.fromJson(json["cert"] as Map<String, dynamic>);
  }

  Future<void> deleteCertification(String id) async {
    final token = await _token();
    final res = await http.delete(
      _uri("/api/certifications/$id"),
      headers: _jsonHeaders(token),
    );

    if (res.statusCode != 200) {
      throw Exception("Delete failed: ${res.body}");
    }
  }
}
