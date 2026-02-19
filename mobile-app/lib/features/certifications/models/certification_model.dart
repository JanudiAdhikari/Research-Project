class CertificationModel {
  final String id;
  final String certificationType;
  final String certificateNumber;
  final String issuingBody;
  final DateTime issueDate;
  final DateTime expiryDate;

  // backend fields
  final String status; // pending|verified|rejected
  final bool isExpired;
  final String effectiveStatus; // expired OR status
  final String? verifiedBy; // system|admin|null
  final DateTime? verificationDate;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  CertificationModel({
    required this.id,
    required this.certificationType,
    required this.certificateNumber,
    required this.issuingBody,
    required this.issueDate,
    required this.expiryDate,
    required this.status,
    required this.isExpired,
    required this.effectiveStatus,
    required this.verifiedBy,
    required this.verificationDate,
    required this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CertificationModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDt(dynamic v) => DateTime.parse(v as String);

    return CertificationModel(
      id: (json["_id"] ?? json["id"]).toString(),
      certificationType: (json["certificationType"] ?? "").toString(),
      certificateNumber: (json["certificateNumber"] ?? "").toString(),
      issuingBody: (json["issuingBody"] ?? "").toString(),
      issueDate: parseDt(json["issueDate"]),
      expiryDate: parseDt(json["expiryDate"]),
      status: (json["status"] ?? "pending").toString(),
      isExpired: (json["isExpired"] ?? false) as bool,
      effectiveStatus: (json["effectiveStatus"] ?? json["status"] ?? "pending").toString(),
      verifiedBy: json["verifiedBy"]?.toString(),
      verificationDate:
          json["verificationDate"] == null ? null : parseDt(json["verificationDate"]),
      rejectionReason: json["rejectionReason"]?.toString(),
      createdAt: parseDt(json["createdAt"]),
      updatedAt: parseDt(json["updatedAt"]),
    );
  }
}
