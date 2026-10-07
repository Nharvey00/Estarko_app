import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:estarko_app/features/auth/providers/auth_provider.dart';
import 'package:estarko_app/features/verification/models/verification_model.dart';
import 'package:estarko_app/features/verification/services/verification_service.dart';
import 'package:estarko_app/features/verification/views/admin_dashboard.dart';

class MockVerificationService extends Fake implements VerificationService {
  final List<VerificationModel> mockVerifications;

  MockVerificationService(this.mockVerifications);

  @override
  Stream<List<VerificationModel>> getPendingVerifications() {
    return Stream.value(mockVerifications);
  }

  @override
  Future<void> updateVerificationStatus(
      String id, String sellerId, String status) async {}
}

void main() {
  group('AdminDashboard UI & Layout Tests', () {
    testWidgets('Renders empty state when queue is clear', (tester) async {
      final mockService = MockVerificationService([]);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => AuthProvider(autoCheckCurrentUser: false),
              ),
            ],
            child: AdminDashboard(verificationService: mockService),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('INTERNAL CRM'), findsOneWidget);
      expect(find.text('Queue is Clear'), findsOneWidget);
    });

    testWidgets('Renders pending verification card with responsive layout and no overflow',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockVerifications = [
        VerificationModel(
          id: 'ver_doc_123',
          sellerId: 'user_seller_789',
          sellerName: 'Juan Dela Cruz',
          idImageUrl: 'https://example.com/id.jpg',
          status: 'pending',
          submittedAt: DateTime(2026, 10, 5),
        ),
      ];

      final mockService = MockVerificationService(mockVerifications);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => AuthProvider(autoCheckCurrentUser: false),
              ),
            ],
            child: AdminDashboard(verificationService: mockService),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('REALTIME CRM'), findsOneWidget);
      expect(find.text('1 PENDING'), findsOneWidget);
      expect(find.text('Juan Dela Cruz'), findsOneWidget);
      expect(find.text('#USER_SEL'), findsOneWidget);
      expect(find.text('Oct 5, 2026'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('View ID'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
      expect(find.text('Approve'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders properly without overflow on ultra narrow 320px screen',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockVerifications = [
        VerificationModel(
          id: 'ver_doc_999',
          sellerId: 'very_long_seller_identifier_123456789',
          sellerName: 'Alexander Bartholomew Montgomery-Smith III',
          idImageUrl: 'https://example.com/id.jpg',
          status: 'pending',
          submittedAt: DateTime(2026, 12, 31),
        ),
      ];

      final mockService = MockVerificationService(mockVerifications);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => AuthProvider(autoCheckCurrentUser: false),
              ),
            ],
            child: AdminDashboard(verificationService: mockService),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('1 PENDING'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
      expect(find.text('Approve'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });
}
