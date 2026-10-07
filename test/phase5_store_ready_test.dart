import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:estarko_app/core/constants.dart';
import 'package:estarko_app/core/services/cloudinary_service.dart';
import 'package:estarko_app/features/auth/models/user_model.dart';
import 'package:estarko_app/features/auth/providers/auth_provider.dart';
import 'package:estarko_app/features/favorites/providers/favorite_provider.dart';
import 'package:estarko_app/features/profile/views/profile_screen.dart';

void main() {
  setUp(() {
    dotenv.testLoad(fileInput: '''
CLOUDINARY_CLOUD_NAME=test_cloud_env
CLOUDINARY_UPLOAD_PRESET=test_preset_env
MAPBOX_ACCESS_TOKEN=test_mapbox_token_123
''');
  });

  group('Phase 5: Store-Ready Finalization - Environment & Dotenv', () {
    test('AppConstants and CloudinaryService read configuration from .env', () {
      expect(AppConstants.cloudinaryCloudName, 'test_cloud_env');
      expect(AppConstants.mapboxAccessToken, 'test_mapbox_token_123');

      final cloudinary = CloudinaryService();
      expect(cloudinary.cloudName, 'test_cloud_env');
      expect(cloudinary.uploadPreset, 'test_preset_env');
    });
  });

  group('Phase 5: Store-Ready Finalization - ProfileScreen Compliance UI', () {
    final testUser = UserModel(
      uid: 'user_store_test_01',
      email: 'alex.tenant@test.com',
      name: 'Alex Cruz',
      role: 'tenant',
      isVerified: true,
      createdAt: DateTime(2026, 3, 15),
    );

    Widget createProfileTestWidget({UserModel? user}) {
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
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      );
    }

    testWidgets('Renders profile header, user details, role badge, and legal section',
        (tester) async {
      await tester.pumpWidget(createProfileTestWidget(user: testUser));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));

      // Header & Subtitle
      expect(find.text('Your Profile'), findsOneWidget);
      expect(find.text('Alex Cruz'), findsNWidgets(2)); // in avatar card & info tile
      expect(find.text('alex.tenant@test.com'), findsNWidgets(2)); // in avatar card & info tile
      expect(find.text('TENANT'), findsNWidgets(2)); // role badge & info tile

      // Legal & Store Compliance section
      expect(find.text('Legal & Information'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.text('App Version'), findsOneWidget);

      // Sign Out and Delete Account buttons
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.text('Delete Account'), findsOneWidget);

      // Verify Delete Account button has red text
      final deleteText = tester.widget<Text>(find.text('Delete Account'));
      expect(deleteText.style?.color, const Color(0xFFE11D48));
    });

    testWidgets('Tapping Privacy Policy opens store-ready Privacy Policy modal',
        (tester) async {
      await tester.pumpWidget(createProfileTestWidget(user: testUser));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));

      // Scroll to Privacy Policy and tap
      final privacyPolicyLink = find.text('Privacy Policy');
      expect(privacyPolicyLink, findsOneWidget);
      await tester.ensureVisible(privacyPolicyLink);
      await tester.pumpAndSettle();

      await tester.tap(privacyPolicyLink);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify Modal Content
      expect(find.text('1. Information We Collect'), findsOneWidget);
      expect(find.text('4. Account Deletion & User Rights'), findsOneWidget);
    });

    testWidgets('Tapping Delete Account opens confirmation dialog',
        (tester) async {
      await tester.pumpWidget(createProfileTestWidget(user: testUser));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));

      // Scroll to Delete Account and tap
      final deleteButton = find.text('Delete Account');
      expect(deleteButton, findsOneWidget);
      await tester.ensureVisible(deleteButton);
      await tester.pumpAndSettle();

      await tester.tap(deleteButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify Confirmation Dialog
      expect(find.text('Delete Account?'), findsOneWidget);
      expect(find.text('Keep Account'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Tap Keep Account to dismiss dialog safely
      await tester.tap(find.text('Keep Account'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Account?'), findsNothing);
    });
  });
}
