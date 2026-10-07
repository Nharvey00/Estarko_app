import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:estarko_app/shared/widgets/custom_button.dart';
import 'package:estarko_app/shared/widgets/estar_sticky_bottom_bar.dart';
import 'package:estarko_app/shared/widgets/estar_friendly_error.dart';

void main() {
  group('Phase 1 Components Unit & Widget Tests', () {
    test('EstarFriendlyError masks network and firestore errors politely', () {
      final networkError = const SocketException('Failed host lookup');
      expect(
        EstarFriendlyError.mask(networkError),
        contains("We couldn't connect right now"),
      );

      final permissionError =
          Exception('[cloud_firestore/permission-denied] Missing or insufficient permissions.');
      expect(
        EstarFriendlyError.mask(permissionError),
        contains("You don't have permission"),
      );

      final authError =
          Exception('[firebase_auth/user-not-found] There is no user record.');
      expect(
        EstarFriendlyError.mask(authError),
        contains('Incorrect email or password'),
      );
    });

    testWidgets('EstarStickyBottomBar renders child within SafeArea and border',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: EstarStickyBottomBar(
              child: Text('Sticky Action'),
            ),
          ),
        ),
      );

      expect(find.text('Sticky Action'), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('EstarButton shows loading spinner instantly when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EstarButton(
              text: 'Submit Application',
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit Application'), findsNothing);
    });
  });
}
