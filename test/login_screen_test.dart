import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:estarko_app/features/auth/providers/auth_provider.dart';
import 'package:estarko_app/features/auth/views/login_screen.dart';

void main() {
  group('Task 4: LoginScreen UI Tests', () {
    testWidgets('Renders Email/Password fields, Sign In button, OR divider, and Continue with Google button',
        (tester) async {
      final authProvider = AuthProvider(autoCheckCurrentUser: false);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header & Subtitle
      expect(find.text('Welcome to EstarKo'), findsOneWidget);
      expect(find.text('Find verified, safe housing near your campus or workplace.'), findsOneWidget);

      // Verify Email and Password labels & fields
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Verify Sign In Button
      expect(find.text('Sign In'), findsOneWidget);

      // Verify OR Divider
      expect(find.text('OR'), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2));

      // Verify Continue with Google Outlined Button
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.byIcon(Icons.g_mobiledata), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });
  });
}
