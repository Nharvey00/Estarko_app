import 'package:flutter_test/flutter_test.dart';
import 'package:estarko_app/core/services/cloudinary_service.dart';
import 'package:estarko_app/features/verification/models/verification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Phase 3 - The Trust Layer Unit Tests', () {
    test('CloudinaryService instantiates and allows custom configuration', () {
      final service = CloudinaryService(cloudName: 'test_cloud', uploadPreset: 'test_preset');
      expect(service.cloudName, 'test_cloud');
      expect(service.uploadPreset, 'test_preset');
    });

    test('VerificationModel serialize and deserialize fromMap and toMap', () {
      final now = DateTime.now();
      final model = VerificationModel(
        id: 'ver_123',
        sellerId: 'user_456',
        sellerName: 'Jane Doe',
        idImageUrl: 'https://example.com/id.jpg',
        status: 'pending',
        submittedAt: now,
      );

      expect(model.id, 'ver_123');
      expect(model.sellerId, 'user_456');
      expect(model.sellerName, 'Jane Doe');
      expect(model.idImageUrl, 'https://example.com/id.jpg');
      expect(model.status, 'pending');

      final map = model.toMap();
      expect(map['id'], 'ver_123');
      expect(map['sellerId'], 'user_456');
      expect(map['sellerName'], 'Jane Doe');
      expect(map['idImageUrl'], 'https://example.com/id.jpg');
      expect(map['status'], 'pending');
      expect(map['submittedAt'], isA<Timestamp>());

      final fromMapModel = VerificationModel.fromMap(map, 'doc_abc');
      expect(fromMapModel.id, 'doc_abc');
      expect(fromMapModel.sellerId, 'user_456');
      expect(fromMapModel.sellerName, 'Jane Doe');
      expect(fromMapModel.idImageUrl, 'https://example.com/id.jpg');
      expect(fromMapModel.status, 'pending');
    });

    test('VerificationModel defaults status to pending', () {
      final model = VerificationModel(
        id: 'ver_789',
        sellerId: 'user_999',
        sellerName: 'John Smith',
        idImageUrl: 'https://example.com/id2.jpg',
      );
      expect(model.status, 'pending');
      expect(model.submittedAt, isNotNull);
    });

    test('VerificationModel in-memory sorting by submittedAt descending', () {
      final now = DateTime.now();
      final older = VerificationModel(
        id: '1',
        sellerId: 's1',
        sellerName: 'Older',
        idImageUrl: '',
        submittedAt: now.subtract(const Duration(hours: 2)),
      );
      final newer = VerificationModel(
        id: '2',
        sellerId: 's2',
        sellerName: 'Newer',
        idImageUrl: '',
        submittedAt: now,
      );

      final list = [older, newer];
      list.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

      expect(list.first.id, '2');
      expect(list.last.id, '1');
    });
  });
}
