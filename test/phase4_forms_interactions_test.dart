import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:estarko_app/features/auth/models/user_model.dart';
import 'package:estarko_app/features/auth/providers/auth_provider.dart';
import 'package:estarko_app/features/favorites/providers/favorite_provider.dart';
import 'package:estarko_app/features/inquiries/services/inquiry_service.dart';
import 'package:estarko_app/features/listings/models/listing_model.dart';
import 'package:estarko_app/features/tenant/views/property_detail_screen.dart';
import 'package:estarko_app/shared/widgets/custom_button.dart';
import 'package:estarko_app/shared/widgets/custom_text_field.dart';
import 'package:estarko_app/shared/widgets/estar_friendly_error.dart';
import 'package:estarko_app/shared/widgets/estar_sticky_bottom_bar.dart';

class FakeInquiryService extends InquiryService {
  final bool hasInquiredResult;
  bool createInquiryCalled = false;

  FakeInquiryService({this.hasInquiredResult = false});

  @override
  Future<bool> hasInquired(String tenantId, String propertyId) async {
    return hasInquiredResult;
  }

  @override
  Future<bool> checkDailyLimit(String tenantId) async {
    return true;
  }

  @override
  Future<void> createInquiry({
    required String propertyId,
    required String propertyTitle,
    required String tenantId,
    required String tenantName,
    String? tenantEmail,
    required String sellerId,
    DateTime? scheduledDate,
    String? note,
  }) async {
    createInquiryCalled = true;
  }
}

void main() {
  final testListing = ListingModel(
    id: 'prop_test_01',
    sellerId: 'landlord_123',
    title: 'Studio Oasis near Ateneo',
    description: 'A cozy, fully furnished studio with fast internet.',
    monthlyRate: 14500.0,
    address: 'Katipunan Ave, Quezon City',
    latitude: 14.64,
    longitude: 121.07,
    imageUrls: [],
    amenities: ['WiFi', 'Air Conditioning', 'Study Desk'],
    isAvailable: true,
    createdAt: DateTime(2026, 1, 1),
  );

  Widget createDetailTestWidget({
    required ListingModel listing,
    required InquiryService inquiryService,
    UserModel? user,
  }) {
    final authProvider = AuthProvider(
      autoCheckCurrentUser: false,
      initialUser: user,
    );
    final favoriteProvider = FavoriteProvider();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<FavoriteProvider>.value(value: favoriteProvider),
      ],
      child: MaterialApp(
        home: PropertyDetailScreen(
          listing: listing,
          inquiryService: inquiryService,
        ),
      ),
    );
  }

  group('Phase 4: Forms & Interactions - PropertyDetailScreen', () {
    testWidgets('Renders property details, pricing, amenities, and sticky bottom bar',
        (tester) async {
      final fakeInquiry = FakeInquiryService(hasInquiredResult: false);

      await tester.pumpWidget(
        createDetailTestWidget(
          listing: testListing,
          inquiryService: fakeInquiry,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));

      // Verify Title, Price, Address, Amenities
      expect(find.text('Studio Oasis near Ateneo'), findsOneWidget);
      expect(find.text('₱14500'), findsNWidgets(2)); // in body & sticky bottom bar
      expect(find.text('Katipunan Ave, Quezon City'), findsOneWidget);
      expect(find.text('WiFi'), findsOneWidget);
      expect(find.text('Air Conditioning'), findsOneWidget);
      expect(find.text('Study Desk'), findsOneWidget);

      // Verify Sticky Bottom Bar and Request Viewing CTA
      expect(find.byType(EstarStickyBottomBar), findsOneWidget);
      expect(find.text('Request Viewing'), findsOneWidget);
    });

    testWidgets('Tapping Request Viewing opens the viewing inquiry modal bottom sheet',
        (tester) async {
      final fakeInquiry = FakeInquiryService(hasInquiredResult: false);

      await tester.pumpWidget(
        createDetailTestWidget(
          listing: testListing,
          inquiryService: fakeInquiry,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));

      // Tap Request Viewing
      final requestButton = find.text('Request Viewing');
      expect(requestButton, findsOneWidget);
      await tester.tap(requestButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));

      // Verify Bottom Sheet Header and Components
      expect(find.text('Request a Viewing'), findsOneWidget);
      expect(find.text('SCHEDULE VISIT'), findsOneWidget);
      expect(find.text('Preferred Date & Time'), findsOneWidget);
      expect(find.text('Select date & time (Optional)'), findsOneWidget);
      expect(find.text('Message for Landlord (Optional)'), findsOneWidget);
      expect(find.text('Confirm Viewing Request'), findsOneWidget);
    });

    testWidgets(
        'Writing message in viewing modal with active keyboard does not cause RenderFlex overflow',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);

      final fakeInquiry = FakeInquiryService(hasInquiredResult: false);

      await tester.pumpWidget(
        createDetailTestWidget(
          listing: testListing,
          inquiryService: fakeInquiry,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));

      // Open bottom sheet
      await tester.tap(find.text('Request Viewing'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));

      expect(find.text('Message for Landlord (Optional)'), findsOneWidget);

      // Simulate keyboard opening (height 340px)
      tester.view.viewInsets = const FakeViewPadding(bottom: 340);
      await tester.pump();

      // Enter text into the message field
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(
          textField, 'Hi landlord! When is the soonest viewing available?');
      await tester.pump();

      // Verify no exceptions or overflow occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('Displays Requested when user has already inquired',
        (tester) async {
      final fakeInquiry = FakeInquiryService(hasInquiredResult: true);
      final loggedInTenant = UserModel(
        uid: 'tenant_test_123',
        email: 'tenant@test.com',
        name: 'Maria Santos',
        role: 'tenant',
        isVerified: true,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        createDetailTestWidget(
          listing: testListing,
          inquiryService: fakeInquiry,
          user: loggedInTenant,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));

      // Verify the button text says Requested and is disabled
      expect(find.text('Requested'), findsOneWidget);
      final estarButton = tester.widget<EstarButton>(
        find.widgetWithText(EstarButton, 'Requested'),
      );
      expect(estarButton.onPressed, isNull);
    });
  });

  group('Phase 4: Component Enhancements', () {
    testWidgets('EstarTextField supports maxLines, prefixIcon, and disabled state',
        (tester) async {
      final controller = TextEditingController(text: 'Initial text');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EstarTextField(
              controller: controller,
              hintText: 'Enter description...',
              maxLines: 4,
              prefixIcon: const Icon(Icons.description),
              enabled: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.description), findsOneWidget);
      expect(find.text('Initial text'), findsOneWidget);
      final estarField = tester.widget<EstarTextField>(find.byType(EstarTextField));
      expect(estarField.enabled, false);
      expect(estarField.maxLines, 4);
    });

    testWidgets('EstarFriendlyError showSuccessSnackBar displays message with green check',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  EstarFriendlyError.showSuccessSnackBar(
                    context,
                    'Listing published successfully!',
                  );
                },
                child: const Text('Show Success'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Success'));
      await tester.pump();

      expect(find.text('Listing published successfully!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });
  });
}
