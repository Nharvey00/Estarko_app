import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/verification_model.dart';

class VerificationService {
  final FirebaseFirestore? firestore;

  VerificationService({this.firestore});

  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _verificationsRef =>
      _db.collection('verifications');

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _db.collection('users');

  /// Creates a document in the verifications collection.
  Future<void> submitVerification({
    required String sellerId,
    required String sellerName,
    required String idImageUrl,
    String? id,
  }) async {
    final docRef = (id != null && id.isNotEmpty)
        ? _verificationsRef.doc(id)
        : _verificationsRef.doc();

    final verification = VerificationModel(
      id: docRef.id,
      sellerId: sellerId,
      sellerName: sellerName,
      idImageUrl: idImageUrl,
      status: 'pending',
      submittedAt: DateTime.now(),
    );

    await docRef.set(verification.toMap());
  }

  /// Convenience method for submitting a VerificationModel directly.
  Future<void> submitVerificationModel(VerificationModel verification) async {
    final docRef = verification.id.isNotEmpty
        ? _verificationsRef.doc(verification.id)
        : _verificationsRef.doc();
    final toSave = verification.id.isEmpty
        ? verification.copyWith(id: docRef.id)
        : verification;
    await docRef.set(toSave.toMap());
  }

  /// Returns a Stream of pending verifications sorted by submittedAt descending in Dart.
  /// Bypasses the need for a Firestore composite index.
  Stream<List<VerificationModel>> getPendingVerifications() {
    return _verificationsRef
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return VerificationModel.fromMap(doc.data(), doc.id);
      }).toList();
      list.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      return list;
    });
  }

  /// Returns a Stream of the latest verification for a seller.
  Stream<VerificationModel?> getSellerVerification(String sellerId) {
    return _verificationsRef
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final list = snapshot.docs
          .map((doc) => VerificationModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      return list.first;
    });
  }

  /// Updates the verification document status.
  /// If status is 'approved', it also updates the user document to set isVerified: true.
  Future<void> updateVerificationStatus(
    String id,
    String sellerId,
    String status,
  ) async {
    final batch = _db.batch();
    final verificationDoc = _verificationsRef.doc(id);
    final userDoc = _usersRef.doc(sellerId);

    batch.update(verificationDoc, {
      'status': status,
    });

    if (status.toLowerCase() == 'approved') {
      batch.update(userDoc, {
        'isVerified': true,
      });
    }

    await batch.commit();
  }
}
