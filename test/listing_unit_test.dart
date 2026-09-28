import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:estarko_app/core/services/location_service.dart';
import 'package:estarko_app/features/listings/models/listing_model.dart';
import 'package:estarko_app/features/listings/providers/listing_provider.dart';

void main() {
  group('Phase 4 - Listings & Seller Property Management Unit Tests', () {
    test('LocationService geocodes address properly with User-Agent header', () async {
      final mockClient = MockClient((request) async {
        expect(request.headers['User-Agent'], 'EstarKoApp/1.0');
        expect(request.url.queryParameters['format'], 'json');
        expect(request.url.queryParameters['limit'], '1');

        const jsonResponse = '''
        [
          {
            "lat": "14.5995124",
            "lon": "120.9842195",
            "display_name": "Manila, Metro Manila, Philippines"
          }
        ]
        ''';

        return http.Response(jsonResponse, 200, headers: {'content-type': 'application/json'});
      });

      final service = LocationService(client: mockClient);
      final coords = await service.getCoordinatesFromAddress('Manila, Philippines');

      expect(coords, isNotNull);
      expect(coords!['latitude'], 14.5995124);
      expect(coords['longitude'], 120.9842195);
    });

    test('LocationService returns null on empty result or network failure', () async {
      final mockEmptyClient = MockClient((request) async {
        return http.Response('[]', 200, headers: {'content-type': 'application/json'});
      });

      final service = LocationService(client: mockEmptyClient);
      final coords = await service.getCoordinatesFromAddress('NonExistentAddress123');
      expect(coords, isNull);

      final emptyInputCoords = await service.getCoordinatesFromAddress('   ');
      expect(emptyInputCoords, isNull);
    });

    test('ListingModel serialization and deserialization', () {
      final now = DateTime.now();
      final model = ListingModel(
        id: 'list_101',
        sellerId: 'seller_202',
        title: 'Modern 1BR Loft',
        description: 'Near University and LRT',
        monthlyRate: 18500.0,
        address: '2401 Taft Ave, Manila',
        latitude: 14.5648,
        longitude: 120.9932,
        imageUrls: ['https://example.com/photo1.jpg', 'https://example.com/photo2.jpg'],
        amenities: ['WiFi', 'Air Conditioning', 'Gym'],
        isAvailable: true,
        createdAt: now,
      );

      final map = model.toMap();
      expect(map['id'], 'list_101');
      expect(map['sellerId'], 'seller_202');
      expect(map['title'], 'Modern 1BR Loft');
      expect(map['monthlyRate'], 18500.0);
      expect(map['latitude'], 14.5648);
      expect(map['longitude'], 120.9932);
      expect(map['imageUrls'], hasLength(2));
      expect(map['amenities'], hasLength(3));
      expect(map['isAvailable'], true);
      expect(map['createdAt'], isA<Timestamp>());

      final deserialized = ListingModel.fromMap(map, 'list_doc_id');
      expect(deserialized.id, 'list_doc_id');
      expect(deserialized.sellerId, 'seller_202');
      expect(deserialized.title, 'Modern 1BR Loft');
      expect(deserialized.monthlyRate, 18500.0);
      expect(deserialized.latitude, 14.5648);
      expect(deserialized.longitude, 120.9932);
      expect(deserialized.imageUrls.length, 2);
      expect(deserialized.amenities.length, 3);
      expect(deserialized.isAvailable, true);
    });

    test('ListingProvider initial state is empty and not loading', () {
      final provider = ListingProvider();
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
      expect(provider.selectedImages.length, 3);
      expect(provider.selectedImages.every((img) => img == null), true);
    });
  });
}
