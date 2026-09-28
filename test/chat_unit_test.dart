import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:estarko_app/features/chat/models/chat_model.dart';
import 'package:estarko_app/features/inquiries/models/inquiry_model.dart';

void main() {
  group('Module 2 & 4 - 4-Stage Booking & Scoped Chat Unit Tests', () {
    test('ChatMessageModel serialization and deserialization works correctly', () {
      final now = DateTime.now();
      final message = ChatMessageModel(
        id: 'msg_001',
        inquiryId: 'inq_999',
        senderId: 'user_123',
        text: 'Hello, is the property available this weekend?',
        createdAt: now,
      );

      expect(message.id, 'msg_001');
      expect(message.inquiryId, 'inq_999');
      expect(message.senderId, 'user_123');
      expect(message.text, 'Hello, is the property available this weekend?');
      expect(message.createdAt, now);

      final map = message.toMap();
      expect(map['inquiryId'], 'inq_999');
      expect(map['senderId'], 'user_123');
      expect(map['text'], 'Hello, is the property available this weekend?');
      expect(map['createdAt'], isA<Timestamp>());

      final fromMapModel = ChatMessageModel.fromMap(map, 'doc_001');
      expect(fromMapModel.id, 'doc_001');
      expect(fromMapModel.inquiryId, 'inq_999');
      expect(fromMapModel.senderId, 'user_123');
      expect(fromMapModel.text, 'Hello, is the property available this weekend?');
    });

    test('InquiryModel handles scheduledDate, note, and tenantEmail serialization', () {
      final scheduled = DateTime(2026, 10, 1, 14, 30);
      final model = InquiryModel(
        id: 'inq_booking',
        propertyId: 'prop_01',
        propertyTitle: 'Modern Condo in Matina',
        tenantId: 'tenant_01',
        tenantName: 'Juan Dela Cruz',
        tenantEmail: 'juan@example.com',
        sellerId: 'seller_01',
        status: 'pending',
        scheduledDate: scheduled,
        note: 'Prefer afternoon viewing.',
      );

      expect(model.tenantEmail, 'juan@example.com');
      expect(model.scheduledDate, scheduled);
      expect(model.note, 'Prefer afternoon viewing.');

      final map = model.toMap();
      expect(map['tenantEmail'], 'juan@example.com');
      expect(map['scheduledDate'], isA<Timestamp>());
      expect(map['note'], 'Prefer afternoon viewing.');

      final deserialized = InquiryModel.fromMap(map, 'inq_booking');
      expect(deserialized.tenantEmail, 'juan@example.com');
      expect(deserialized.note, 'Prefer afternoon viewing.');
      expect(deserialized.scheduledDate?.year, 2026);
      expect(deserialized.scheduledDate?.month, 10);
      expect(deserialized.scheduledDate?.day, 1);
    });

    test('InquiryModel copyWith retains or updates scheduledDate, note, and tenantEmail', () {
      final initial = InquiryModel(
        id: 'inq_init',
        propertyId: 'prop_1',
        propertyTitle: 'Title',
        tenantId: 't1',
        tenantName: 'Name',
        sellerId: 's1',
      );

      final updated = initial.copyWith(
        status: 'contacted',
        note: 'Updated note',
        tenantEmail: 'tenant@test.com',
      );

      expect(updated.status, 'contacted');
      expect(updated.note, 'Updated note');
      expect(updated.tenantEmail, 'tenant@test.com');
    });
  });
}
