import 'package:flutter_test/flutter_test.dart';
import 'package:estarko_app/features/favorites/providers/favorite_provider.dart';
import 'package:estarko_app/features/listings/models/listing_model.dart';

void main() {
  group('Phase 7 - Retention & Favorites Unit Tests', () {
    test('FavoriteProvider initial state has empty favoriteIds', () {
      final provider = FavoriteProvider();
      expect(provider.favoriteIds, isEmpty);
      expect(provider.isFavorite('non_existent_id'), isFalse);
    });

    test('Local descending sort sorts saved properties by createdAt', () {
      final base = DateTime(2026, 9, 27, 12, 0, 0);
      final list = [
        ListingModel(
          id: '1',
          sellerId: 's1',
          title: 'Older Listing',
          description: 'Desc',
          monthlyRate: 15000,
          address: 'Address 1',
          latitude: 7.0,
          longitude: 125.0,
          imageUrls: [],
          amenities: [],
          createdAt: base.subtract(const Duration(days: 2)),
        ),
        ListingModel(
          id: '2',
          sellerId: 's2',
          title: 'Newest Listing',
          description: 'Desc',
          monthlyRate: 20000,
          address: 'Address 2',
          latitude: 7.1,
          longitude: 125.1,
          imageUrls: [],
          amenities: [],
          createdAt: base,
        ),
        ListingModel(
          id: '3',
          sellerId: 's3',
          title: 'Yesterday Listing',
          description: 'Desc',
          monthlyRate: 18000,
          address: 'Address 3',
          latitude: 7.2,
          longitude: 125.2,
          imageUrls: [],
          amenities: [],
          createdAt: base.subtract(const Duration(days: 1)),
        ),
      ];

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      expect(list[0].id, '2');
      expect(list[1].id, '3');
      expect(list[2].id, '1');
    });

    test('ListingModel serialization preserves all required fields for favorites storage', () {
      final now = DateTime.now();
      final listing = ListingModel(
        id: 'fav_listing_1',
        sellerId: 'seller_10',
        title: 'Modern Studio Near IT Park',
        description: 'Cozy and furnished',
        monthlyRate: 16500.0,
        address: 'Bajada, Davao City',
        latitude: 7.0900,
        longitude: 125.6150,
        imageUrls: ['https://example.com/fav.jpg'],
        amenities: ['Aircon', 'WiFi', 'Balcony'],
        isAvailable: true,
        createdAt: now,
      );

      final map = listing.toMap();
      expect(map['id'], 'fav_listing_1');
      expect(map['sellerId'], 'seller_10');
      expect(map['title'], 'Modern Studio Near IT Park');
      expect(map['monthlyRate'], 16500.0);
      expect(map['address'], 'Bajada, Davao City');
      expect(map['imageUrls'], ['https://example.com/fav.jpg']);
      expect(map['amenities'], ['Aircon', 'WiFi', 'Balcony']);

      final restored = ListingModel.fromMap(map, 'fav_listing_1');
      expect(restored.id, 'fav_listing_1');
      expect(restored.sellerId, 'seller_10');
      expect(restored.title, 'Modern Studio Near IT Park');
      expect(restored.monthlyRate, 16500.0);
      expect(restored.imageUrls.length, 1);
      expect(restored.amenities.length, 3);
    });
  });
}
