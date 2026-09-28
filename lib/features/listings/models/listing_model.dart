import 'package:cloud_firestore/cloud_firestore.dart';

class ListingModel {
  final String id;
  final String sellerId;
  final String title;
  final String description;
  final double monthlyRate;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;
  final List<String> amenities;
  final bool isAvailable;
  final DateTime createdAt;

  ListingModel({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.monthlyRate,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    required this.amenities,
    this.isAvailable = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ListingModel.fromMap(
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

    return ListingModel(
      id: documentId ?? map['id'] ?? '',
      sellerId: map['sellerId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      monthlyRate: (map['monthlyRate'] is num)
          ? (map['monthlyRate'] as num).toDouble()
          : double.tryParse(map['monthlyRate']?.toString() ?? '') ?? 0.0,
      address: map['address'] ?? '',
      latitude: (map['latitude'] is num)
          ? (map['latitude'] as num).toDouble()
          : double.tryParse(map['latitude']?.toString() ?? '') ?? 0.0,
      longitude: (map['longitude'] is num)
          ? (map['longitude'] as num).toDouble()
          : double.tryParse(map['longitude']?.toString() ?? '') ?? 0.0,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      amenities: List<String>.from(map['amenities'] ?? []),
      isAvailable: map['isAvailable'] ?? true,
      createdAt: parsedCreatedAt,
    );
  }

  factory ListingModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ListingModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'title': title,
      'description': description,
      'monthlyRate': monthlyRate,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
      'amenities': amenities,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ListingModel copyWith({
    String? id,
    String? sellerId,
    String? title,
    String? description,
    double? monthlyRate,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
    List<String>? amenities,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return ListingModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      title: title ?? this.title,
      description: description ?? this.description,
      monthlyRate: monthlyRate ?? this.monthlyRate,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrls: imageUrls ?? this.imageUrls,
      amenities: amenities ?? this.amenities,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
