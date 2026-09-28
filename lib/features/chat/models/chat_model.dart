import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String inquiryId;
  final String senderId;
  final String text;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.inquiryId,
    required this.senderId,
    required this.text,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ChatMessageModel.fromMap(
    Map<String, dynamic> map, [
    String? documentId,
  ]) {
    DateTime parsedCreatedAt;
    final dynamic rawCreatedAt = map['createdAt'] ?? map['timestamp'];
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return ChatMessageModel(
      id: documentId ?? map['id'] ?? '',
      inquiryId: map['inquiryId'] ?? '',
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      createdAt: parsedCreatedAt,
    );
  }

  factory ChatMessageModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChatMessageModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'inquiryId': inquiryId,
      'senderId': senderId,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
