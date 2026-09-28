import 'package:cloud_firestore/cloud_firestore.dart';

class InquiryModel {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String tenantId;
  final String tenantName;
  final String? tenantEmail;
  final String sellerId;
  final String status;
  final DateTime? scheduledDate;
  final String? note;
  final DateTime createdAt;

  InquiryModel({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.tenantId,
    required this.tenantName,
    this.tenantEmail,
    required this.sellerId,
    this.status = 'pending',
    this.scheduledDate,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory InquiryModel.fromMap(
    Map<String, dynamic> map, [
    String? documentId,
  ]) {
    DateTime parsedCreatedAt;
    final dynamic rawCreatedAt = map['createdAt'];
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    DateTime? parsedScheduledDate;
    final dynamic rawScheduled = map['scheduledDate'];
    if (rawScheduled is Timestamp) {
      parsedScheduledDate = rawScheduled.toDate();
    } else if (rawScheduled is String) {
      parsedScheduledDate = DateTime.tryParse(rawScheduled);
    }

    return InquiryModel(
      id: documentId ?? map['id'] ?? '',
      propertyId: map['propertyId'] ?? '',
      propertyTitle: map['propertyTitle'] ?? '',
      tenantId: map['tenantId'] ?? '',
      tenantName: map['tenantName'] ?? '',
      tenantEmail: map['tenantEmail'] as String?,
      sellerId: map['sellerId'] ?? '',
      status: map['status'] ?? 'pending',
      scheduledDate: parsedScheduledDate,
      note: map['note'] as String?,
      createdAt: parsedCreatedAt,
    );
  }

  factory InquiryModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return InquiryModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'propertyId': propertyId,
      'propertyTitle': propertyTitle,
      'tenantId': tenantId,
      'tenantName': tenantName,
      'tenantEmail': tenantEmail,
      'sellerId': sellerId,
      'status': status,
      'scheduledDate': scheduledDate != null
          ? Timestamp.fromDate(scheduledDate!)
          : null,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  InquiryModel copyWith({
    String? id,
    String? propertyId,
    String? propertyTitle,
    String? tenantId,
    String? tenantName,
    String? tenantEmail,
    String? sellerId,
    String? status,
    DateTime? scheduledDate,
    String? note,
    DateTime? createdAt,
  }) {
    return InquiryModel(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      propertyTitle: propertyTitle ?? this.propertyTitle,
      tenantId: tenantId ?? this.tenantId,
      tenantName: tenantName ?? this.tenantName,
      tenantEmail: tenantEmail ?? this.tenantEmail,
      sellerId: sellerId ?? this.sellerId,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
