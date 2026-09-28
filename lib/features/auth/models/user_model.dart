import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'tenant' or 'seller'
  final bool isVerified;
  final int inquiryCountToday;
  final int activeListingCount;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.isVerified = false,
    this.inquiryCountToday = 0,
    this.activeListingCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parsedCreatedAt;
    if (map['createdAt'] is Timestamp) {
      parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      parsedCreatedAt = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return UserModel(
      uid: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'tenant',
      isVerified: map['isVerified'] ?? false,
      inquiryCountToday: map['inquiryCountToday']?.toInt() ?? 0,
      activeListingCount: map['activeListingCount']?.toInt() ?? 0,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'isVerified': isVerified,
      'inquiryCountToday': inquiryCountToday,
      'activeListingCount': activeListingCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}