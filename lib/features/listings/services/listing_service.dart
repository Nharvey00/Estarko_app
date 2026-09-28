import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';

class ListingService {
  final FirebaseFirestore? firestore;

  ListingService({this.firestore});

  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _listingsRef =>
      _db.collection('listings');

  /// Saves a new or existing listing to the 'listings' Firestore collection.
  Future<void> createListing(ListingModel listing) async {
    final docRef = listing.id.isNotEmpty
        ? _listingsRef.doc(listing.id)
        : _listingsRef.doc();

    final toSave = listing.id.isEmpty
        ? listing.copyWith(id: docRef.id)
        : listing;

    await docRef.set(toSave.toMap());
  }

  /// Returns a real-time Stream of listings created by the specified seller.
  /// Bypasses the Firestore composite index requirement by sorting locally in Dart.
  Stream<List<ListingModel>> getSellerListings(String sellerId) {
    return _listingsRef
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return ListingModel.fromMap(doc.data(), doc.id);
      }).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Returns a real-time Stream of all available listings.
  /// Bypasses the Firestore composite index requirement by sorting locally in Dart by createdAt descending.
  Stream<List<ListingModel>> getAllAvailableListings() {
    return _listingsRef
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return ListingModel.fromMap(doc.data(), doc.id);
      }).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Updates listing availability (active/inactive toggle).
  Future<void> updateListingAvailability(String id, bool isAvailable) async {
    await _listingsRef.doc(id).update({
      'isAvailable': isAvailable,
    });
  }

  /// Deletes a listing from the Firestore collection.
  Future<void> deleteListing(String id) async {
    await _listingsRef.doc(id).delete();
  }
}
