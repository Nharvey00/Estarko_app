import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../listings/models/listing_model.dart';
import '../services/favorite_service.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteService _favoriteService;
  StreamSubscription<List<ListingModel>>? _subscription;
  final Set<String> _favoriteIds = {};
  String? _currentUserId;

  FavoriteProvider({FavoriteService? favoriteService})
      : _favoriteService = favoriteService ?? FavoriteService();

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  /// Checks if a property ID is currently favorited.
  bool isFavorite(String propertyId) {
    return _favoriteIds.contains(propertyId);
  }

  /// Initializes the provider for a specific user and listens to real-time favorites.
  void initForUser(String userId) {
    if (userId.isEmpty || _currentUserId == userId) return;

    _currentUserId = userId;
    _subscription?.cancel();

    _subscription = _favoriteService.getFavorites(userId).listen(
      (favorites) {
        _favoriteIds.clear();
        for (final item in favorites) {
          _favoriteIds.add(item.id);
        }
        notifyListeners();
      },
      onError: (_) {
        // Handle error silently or log
      },
    );
  }

  /// Clears in-memory favorites and cancels active subscription (Fixes BUG-04).
  void clearFavorites() {
    _subscription?.cancel();
    _subscription = null;
    _currentUserId = null;
    _favoriteIds.clear();
    notifyListeners();
  }

  /// Toggles favorite status with optimistic UI update.
  Future<bool> toggleFavorite(String userId, ListingModel property) async {
    final propertyId = property.id;
    final wasFavorited = _favoriteIds.contains(propertyId);

    // Optimistic update
    if (wasFavorited) {
      _favoriteIds.remove(propertyId);
    } else {
      _favoriteIds.add(propertyId);
    }
    notifyListeners();

    try {
      final isNowFavorited =
          await _favoriteService.toggleFavorite(userId, property);
      if (isNowFavorited) {
        _favoriteIds.add(propertyId);
      } else {
        _favoriteIds.remove(propertyId);
      }
      notifyListeners();
      return isNowFavorited;
    } catch (e) {
      // Rollback on failure
      if (wasFavorited) {
        _favoriteIds.add(propertyId);
      } else {
        _favoriteIds.remove(propertyId);
      }
      notifyListeners();
      rethrow;
    }
  }

  /// Stream of user favorites.
  Stream<List<ListingModel>> getFavorites(String userId) {
    return _favoriteService.getFavorites(userId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
