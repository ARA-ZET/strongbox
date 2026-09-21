import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strong_box/core/theme/app_theme.dart';
import 'package:strong_box/features/auth/screens/register_screen.dart';

/// Sign-up is one step: packages and pricing are chosen on the website, so
/// there is no billing or review step between the form and the portal.
void main() {
  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(theme: AppTheme.light, home: const RegisterScreen()),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('goes straight from the form to account creation',
      (tester) async {
    await pump(tester);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Continue to Billing'), findsNothing);
    expect(find.text('Billing'), findsNothing);
    expect(find.text('Review'), findsNothing);
  });

  testWidgets('validates the form before creating the account',
      (tester) async {
    await pump(tester);
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();
    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password must be at least 8 characters'),
        findsOneWidget);
  });
}
