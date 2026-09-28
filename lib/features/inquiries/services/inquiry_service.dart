import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inquiry_model.dart';

class InquiryService {
  final FirebaseFirestore? firestore;

  InquiryService({this.firestore});

  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _inquiriesRef =>
      _db.collection('inquiries');

  /// Saves a new inquiry to the 'inquiries' collection.
  Future<void> createInquiry({
    required String propertyId,
    required String propertyTitle,
    required String tenantId,
    required String tenantName,
    String? tenantEmail,
    required String sellerId,
    DateTime? scheduledDate,
    String? note,
  }) async {
    final docRef = _inquiriesRef.doc();
    final inquiry = InquiryModel(
      id: docRef.id,
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      tenantId: tenantId,
      tenantName: tenantName,
      tenantEmail: tenantEmail,
      sellerId: sellerId,
      status: 'pending',
      scheduledDate: scheduledDate,
      note: note,
      createdAt: DateTime.now(),
    );
    await docRef.set(inquiry.toMap());
  }

  /// Checks if the tenant has submitted fewer than 3 inquiries today.
  /// Strictly queries where createdAt >= startOfDay to avoid full-history reads (Fixes BUG-02).
  Future<bool> checkDailyLimit(String tenantId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final snapshot = await _inquiriesRef
        .where('tenantId', isEqualTo: tenantId)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();

    return snapshot.docs.length < 3;
  }

  /// Checks if the tenant has already submitted an inquiry for this property.
  Future<bool> hasInquired(String tenantId, String propertyId) async {
    if (tenantId.isEmpty || propertyId.isEmpty) return false;

    final snapshot = await _inquiriesRef
        .where('tenantId', isEqualTo: tenantId)
        .get();

    return snapshot.docs.any((doc) => doc.data()['propertyId'] == propertyId);
  }

  /// Returns a real-time Stream of inquiries for the seller,
  /// sorting locally in Dart by createdAt descending to avoid index errors.
  Stream<List<InquiryModel>> getSellerInquiries(String sellerId) {
    return _inquiriesRef
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return InquiryModel.fromMap(doc.data(), doc.id);
      }).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Returns a real-time Stream of inquiries created by a specific tenant,
  /// sorting locally in Dart by createdAt descending to avoid index errors.
  Stream<List<InquiryModel>> getTenantInquiries(String tenantId) {
    return _inquiriesRef
        .where('tenantId', isEqualTo: tenantId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return InquiryModel.fromMap(doc.data(), doc.id);
      }).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Updates the status of an inquiry ('pending', 'contacted', 'closed').
  Future<void> updateInquiryStatus(String id, String status) async {
    await _inquiriesRef.doc(id).update({
      'status': status,
    });
  }
}
