import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:estarko_app/features/auth/models/user_model.dart';
import 'package:estarko_app/features/auth/providers/auth_provider.dart';
import 'package:estarko_app/features/auth/services/auth_service.dart';
import 'package:estarko_app/features/auth/views/login_screen.dart';

void main() {
  group('Task 5: Strict Routing Rules Unit Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider(autoCheckCurrentUser: false);
    });

    test('Tenant routes to MapDashboardScreen', () {
      final tenantUser = UserModel(
        uid: 'user_1',
        name: 'Jane Tenant',
        email: 'tenant@example.com',
        role: 'tenant',
        isVerified: false,
      );

      final screen = authProvider.getDestinationScreen(tenantUser);
      expect(screen, isA<MapDashboardScreen>());
    });

    test('Verified Landlord routes to LandlordDashboardScreen', () {
      final verifiedLandlord = UserModel(
        uid: 'user_2',
        name: 'John Landlord',
        email: 'landlord@example.com',
        role: 'landlord',
        isVerified: true,
      );

      final screen = authProvider.getDestinationScreen(verifiedLandlord);
      expect(screen, isA<LandlordDashboardScreen>());
    });

    test('Unverified Landlord routes to AccountVerificationScreen', () {
      final unverifiedLandlord = UserModel(
        uid: 'user_3',
        name: 'Bob Landlord',
        email: 'unverified@example.com',
        role: 'landlord',
        isVerified: false,
      );

      final screen = authProvider.getDestinationScreen(unverifiedLandlord);
      expect(screen, isA<AccountVerificationScreen>());
    });

    test('Admin routes to AdminReviewDashboardScreen', () {
      final adminUser = UserModel(
        uid: 'admin_1',
        name: 'Admin User',
        email: 'admin@estarko.com',
        role: 'admin',
        isVerified: true,
      );

      final screen = authProvider.getDestinationScreen(adminUser);
      expect(screen, isA<AdminReviewDashboardScreen>());
    });
  });

  group('Task 3: RoleSelectionDialog Widget Tests', () {
    testWidgets('Displays options for Tenant and Landlord', (tester) async {
      String? resultRole;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  resultRole = await RoleSelectionDialog.show(context);
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify header and question
      expect(find.text('Are you a Tenant or a Landlord?'), findsOneWidget);
      expect(find.text('Tenant'), findsOneWidget);
      expect(find.text('Landlord'), findsOneWidget);
      expect(find.text('Continue as Tenant'), findsOneWidget);

      // Tap Landlord option
      await tester.tap(find.text('Landlord'));
      await tester.pumpAndSettle();

      expect(find.text('Continue as Landlord'), findsOneWidget);

      // Tap continue button
      await tester.tap(find.text('Continue as Landlord'));
      await tester.pumpAndSettle();

      // Dialog dismissed with landlord role
      expect(resultRole, equals('landlord'));
    });

    testWidgets('Dismissing dialog returns null for edge-case protection',
        (tester) async {
      String? resultRole = 'non_null_initial';

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  resultRole = await RoleSelectionDialog.show(context);
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Tap Cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(resultRole, isNull);
    });

    testWidgets('Tapping outside barrier does not dismiss when barrierDismissible is false',
        (tester) async {
      String? resultRole = 'non_null_initial';

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  resultRole = await RoleSelectionDialog.show(
                    context,
                    barrierDismissible: false,
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Tap on the modal barrier (top-left outside the dialog box)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Dialog is still visible and not dismissed
      expect(find.text('Are you a Tenant or a Landlord?'), findsOneWidget);
      expect(resultRole, equals('non_null_initial'));

      // Cleanly tap Cancel to close
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(resultRole, isNull);
    });
  });

  group('Google Sign-In UserModel Schema & Role Assignment Tests', () {
    test('UserModel.fromMap deserializes displayName fallback properly', () {
      final googleUserMap = {
        'uid': 'google_123',
        'displayName': 'Google User',
        'email': 'user@gmail.com',
        'role': 'tenant',
        'isVerified': true,
      };

      final user = UserModel.fromMap(googleUserMap, 'google_123');
      expect(user.uid, equals('google_123'));
      expect(user.name, equals('Google User'));
      expect(user.email, equals('user@gmail.com'));
      expect(user.role, equals('tenant'));
      expect(user.isVerified, isTrue);
    });

    test('UserModel.fromMap deserializes legacy name attribute properly', () {
      final legacyUserMap = {
        'uid': 'legacy_123',
        'name': 'Legacy Name',
        'email': 'legacy@estarko.com',
        'role': 'landlord',
        'isVerified': false,
      };

      final user = UserModel.fromMap(legacyUserMap, 'legacy_123');
      expect(user.name, equals('Legacy Name'));
      expect(user.role, equals('landlord'));
      expect(user.isVerified, isFalse);
    });

    test('New Google Tenant routes to MapDashboardScreen with isVerified true', () {
      final authProvider = AuthProvider(autoCheckCurrentUser: false);
      final newGoogleTenant = UserModel(
        uid: 'g_tenant_1',
        name: 'New Google Tenant',
        email: 'tenant@gmail.com',
        role: 'tenant',
        isVerified: true,
      );

      final screen = authProvider.getDestinationScreen(newGoogleTenant);
      expect(screen, isA<MapDashboardScreen>());
    });

    test('New Google Landlord routes to AccountVerificationScreen with isVerified false', () {
      final authProvider = AuthProvider(autoCheckCurrentUser: false);
      final newGoogleLandlord = UserModel(
        uid: 'g_landlord_1',
        name: 'New Google Landlord',
        email: 'landlord@gmail.com',
        role: 'landlord',
        isVerified: false,
      );

      final screen = authProvider.getDestinationScreen(newGoogleLandlord);
      expect(screen, isA<AccountVerificationScreen>());
    });

    test('Returning Verified Landlord routes to LandlordDashboardScreen', () {
      final authProvider = AuthProvider(autoCheckCurrentUser: false);
      final verifiedLandlord = UserModel(
        uid: 'g_landlord_2',
        name: 'Verified Landlord',
        email: 'v_landlord@gmail.com',
        role: 'landlord',
        isVerified: true,
      );

      final screen = authProvider.getDestinationScreen(verifiedLandlord);
      expect(screen, isA<LandlordDashboardScreen>());
    });
  });

  group('AccountVerificationScreen & Logout Navigation Tests', () {
    testWidgets('Tapping back button on AccountVerificationScreen logs out and navigates to LoginScreen',
        (tester) async {
      final unverifiedLandlord = UserModel(
        uid: 'unverified_landlord_99',
        name: 'Landlord Candidate',
        email: 'landlord.candidate@gmail.com',
        role: 'landlord',
        isVerified: false,
      );

      final authProvider = AuthProvider(
        autoCheckCurrentUser: false,
        initialUser: unverifiedLandlord,
        authService: _FakeAuthService(),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const MaterialApp(
            home: AccountVerificationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify we are on AccountVerificationScreen
      expect(find.text('Submit for Verification'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_outlined), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_outlined));
      await tester.pumpAndSettle();

      // Verify that user session is cleared
      expect(authProvider.currentUser, isNull);

      // Verify that user is navigated back to LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Welcome to EstarKo'), findsOneWidget);
    });

    testWidgets('PopScope handles back gesture and logs out cleanly to LoginScreen',
        (tester) async {
      final unverifiedLandlord = UserModel(
        uid: 'unverified_landlord_100',
        name: 'Back Gesture Test',
        email: 'gesture@gmail.com',
        role: 'landlord',
        isVerified: false,
      );

      final authProvider = AuthProvider(
        autoCheckCurrentUser: false,
        initialUser: unverifiedLandlord,
        authService: _FakeAuthService(),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const MaterialApp(
            home: AccountVerificationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify PopScope exists and canPop is false
      final popScopeFinder = find.byWidgetPredicate((w) => w is PopScope);
      expect(popScopeFinder, findsOneWidget);

      final PopScope popScopeWidget =
          tester.widget<PopScope>(popScopeFinder);
      expect(popScopeWidget.canPop, isFalse);

      // Simulate back gesture invocation
      popScopeWidget.onPopInvokedWithResult?.call(false, null);
      await tester.pumpAndSettle();

      // Verify that user session is cleared
      expect(authProvider.currentUser, isNull);

      // Verify redirected to LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}

class _FakeAuthService extends AuthService {
  @override
  Future<void> signOut() async {}
}
