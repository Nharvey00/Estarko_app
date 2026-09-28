import 'package:cloud_firestore/cloud_firestore.dart';

class VerificationModel {
  final String id;
  final String sellerId;
  final String sellerName;
  final String idImageUrl;
  final String status;
  final DateTime submittedAt;

  VerificationModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.idImageUrl,
    this.status = 'pending',
    DateTime? submittedAt,
  }) : submittedAt = submittedAt ?? DateTime.now();

  factory VerificationModel.fromMap(
    Map<String, dynamic> map, [
    String? documentId,
  ]) {
    DateTime parsedSubmittedAt;
    final dynamic rawSubmittedAt = map['submittedAt'];
    if (rawSubmittedAt is Timestamp) {
      parsedSubmittedAt = rawSubmittedAt.toDate();
    } else if (rawSubmittedAt is String) {
      parsedSubmittedAt =
          DateTime.tryParse(rawSubmittedAt) ?? DateTime.now();
    } else {
      parsedSubmittedAt = DateTime.now();
    }

    return VerificationModel(
      id: documentId ?? map['id'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      idImageUrl: map['idImageUrl'] ?? '',
      status: map['status'] ?? 'pending',
      submittedAt: parsedSubmittedAt,
    );
  }

  factory VerificationModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return VerificationModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'idImageUrl': idImageUrl,
      'status': status,
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }

  VerificationModel copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    String? idImageUrl,
    String? status,
    DateTime? submittedAt,
  }) {
    return VerificationModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      idImageUrl: idImageUrl ?? this.idImageUrl,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}