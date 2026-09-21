import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strong_box/core/theme/app_theme.dart';
import 'package:strong_box/features/auth/providers/auth_provider.dart';
import 'package:strong_box/routing/app_router.dart';

/// The app is for account holders: marketing, pricing and quotes live on
/// the website. A signed-out visitor always meets the sign-in form.
void main() {
  Future<String> pumpSignedOut(WidgetTester tester, String start) async {
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(overrides: [
      authStateProvider.overrideWith((ref) => Stream<User?>.value(null)),
      currentUserProvider.overrideWith((ref) => Stream.value(null)),
    ]);
    addTearDown(container.dispose);

    final router = container.read(appRouterProvider);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await tester.pumpAndSettle();
    router.go(start);
    await tester.pumpAndSettle();
    return router.routerDelegate.currentConfiguration.uri.path;
  }

  testWidgets('a cold start lands a visitor on sign-in', (tester) async {
    expect(await pumpSignedOut(tester, '/'), '/login');
  });

  testWidgets('portal pages still require sign-in', (tester) async {
    expect(await pumpSignedOut(tester, '/client/storage'), '/login');
  });

  testWidgets('sign-up stays open for the website\'s "Get Started" links',
      (tester) async {
    expect(await pumpSignedOut(tester, '/register'), '/register');
  });

  testWidgets('old /quote links go to sign-up', (tester) async {
    expect(await pumpSignedOut(tester, '/quote'), '/register');
  });
}
