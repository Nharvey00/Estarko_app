import 'package:cloud_firestore/cloud_firestore.dart';
import '../../listings/models/listing_model.dart';

class FavoriteService {
  final FirebaseFirestore? firestore;

  FavoriteService({this.firestore});

  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userFavoritesRef(String userId) {
    return _db.collection('users').doc(userId).collection('favorites');
  }

  /// Toggles favorite status: saves the listing if not already favorited,
  /// or removes it if already present in the user's favorites subcollection.
  Future<bool> toggleFavorite(String userId, ListingModel property) async {
    if (userId.isEmpty || property.id.isEmpty) return false;

    final docRef = _userFavoritesRef(userId).doc(property.id);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      await docRef.delete();
      return false; // Removed from favorites
    } else {
      await docRef.set(property.toMap());
      return true; // Added to favorites
    }
  }

  /// Checks if a property is in the user's favorites.
  Future<bool> isFavorite(String userId, String propertyId) async {
    if (userId.isEmpty || propertyId.isEmpty) return false;
    final doc = await _userFavoritesRef(userId).doc(propertyId).get();
    return doc.exists;
  }

  /// Returns a real-time Stream of the user's saved listings,
  /// sorted locally in Dart by createdAt descending to bypass index errors.
  Stream<List<ListingModel>> getFavorites(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    return _userFavoritesRef(userId).snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return ListingModel.fromMap(doc.data(), doc.id);
      }).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }
}
