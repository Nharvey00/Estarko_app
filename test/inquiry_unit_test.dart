import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:estarko_app/features/inquiries/models/inquiry_model.dart';
import 'package:estarko_app/features/inquiries/providers/inquiry_provider.dart';

void main() {
  group('Phase 6 - Inquiry Model & Provider Unit Tests', () {
    test('InquiryModel serializes toMap and deserializes fromMap accurately', () {
      final now = DateTime.now();
      final model = InquiryModel(
        id: 'inq_123',
        propertyId: 'prop_456',
        propertyTitle: 'Sunset Studio in Davao',
        tenantId: 'tenant_789',
        tenantName: 'Juan Dela Cruz',
        sellerId: 'seller_101',
        status: 'pending',
        createdAt: now,
      );

      expect(model.id, 'inq_123');
      expect(model.propertyId, 'prop_456');
      expect(model.propertyTitle, 'Sunset Studio in Davao');
      expect(model.tenantId, 'tenant_789');
      expect(model.tenantName, 'Juan Dela Cruz');
      expect(model.sellerId, 'seller_101');
      expect(model.status, 'pending');
      expect(model.createdAt, now);

      final map = model.toMap();
      expect(map['id'], 'inq_123');
      expect(map['propertyId'], 'prop_456');
      expect(map['propertyTitle'], 'Sunset Studio in Davao');
      expect(map['tenantId'], 'tenant_789');
      expect(map['tenantName'], 'Juan Dela Cruz');
      expect(map['sellerId'], 'seller_101');
      expect(map['status'], 'pending');
      expect(map['createdAt'], isA<Timestamp>());

      final fromMapModel = InquiryModel.fromMap(map, 'doc_xyz');
      expect(fromMapModel.id, 'doc_xyz');
      expect(fromMapModel.propertyId, 'prop_456');
      expect(fromMapModel.propertyTitle, 'Sunset Studio in Davao');
      expect(fromMapModel.tenantId, 'tenant_789');
      expect(fromMapModel.tenantName, 'Juan Dela Cruz');
      expect(fromMapModel.sellerId, 'seller_101');
      expect(fromMapModel.status, 'pending');
    });

    test('InquiryModel defaults status to pending and provides valid fallback values', () {
      final model = InquiryModel(
        id: 'inq_default',
        propertyId: 'prop_001',
        propertyTitle: 'Test Property',
        tenantId: 'tenant_001',
        tenantName: 'Maria Santos',
        sellerId: 'seller_001',
      );

      expect(model.status, 'pending');
      expect(model.createdAt, isNotNull);

      // Deserialization with missing keys
      final emptyMapModel = InquiryModel.fromMap({}, 'inq_empty');
      expect(emptyMapModel.id, 'inq_empty');
      expect(emptyMapModel.propertyId, '');
      expect(emptyMapModel.propertyTitle, '');
      expect(emptyMapModel.tenantId, '');
      expect(emptyMapModel.tenantName, '');
      expect(emptyMapModel.sellerId, '');
      expect(emptyMapModel.status, 'pending');
    });

    test('InquiryModel copyWith works correctly for status transitions', () {
      final initial = InquiryModel(
        id: 'inq_trans',
        propertyId: 'prop_1',
        propertyTitle: 'Urban Loft',
        tenantId: 'tenant_1',
        tenantName: 'Alex',
        sellerId: 'seller_1',
        status: 'pending',
      );

      final contacted = initial.copyWith(status: 'contacted');
      expect(contacted.status, 'contacted');
      expect(contacted.id, 'inq_trans');
      expect(contacted.propertyTitle, 'Urban Loft');

      final closed = contacted.copyWith(status: 'closed');
      expect(closed.status, 'closed');
    });

    test('Inquiries list sorts locally by createdAt descending to bypass index errors', () {
      final base = DateTime(2026, 9, 27, 10, 0, 0);
      final inq1 = InquiryModel(
        id: '1',
        propertyId: 'p1',
        propertyTitle: 'P1',
        tenantId: 't1',
        tenantName: 'T1',
        sellerId: 's1',
        createdAt: base.subtract(const Duration(hours: 2)),
      );
      final inq2 = InquiryModel(
        id: '2',
        propertyId: 'p2',
        propertyTitle: 'P2',
        tenantId: 't2',
        tenantName: 'T2',
        sellerId: 's1',
        createdAt: base,
      );
      final inq3 = InquiryModel(
        id: '3',
        propertyId: 'p3',
        propertyTitle: 'P3',
        tenantId: 't3',
        tenantName: 'T3',
        sellerId: 's1',
        createdAt: base.subtract(const Duration(minutes: 30)),
      );

      final list = [inq1, inq2, inq3];
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      expect(list[0].id, '2');
      expect(list[1].id, '3');
      expect(list[2].id, '1');
    });

    test('InquiryProvider initializes with default state', () {
      final provider = InquiryProvider();
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });
  });
}
