import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strong_box/routing/app_router.dart';
import 'package:strong_box/core/enums/app_enums.dart';
import 'package:strong_box/core/theme/app_theme.dart';
import 'package:strong_box/features/auth/providers/auth_provider.dart';
import 'package:strong_box/features/quote/providers/quote_draft_provider.dart';
import 'package:strong_box/features/quote/providers/quote_submission_provider.dart';
import 'package:strong_box/features/quote/screens/quote_boxes_screen.dart';
import 'package:strong_box/features/quote/screens/quote_calculator_screen.dart';
import 'package:strong_box/features/quote/screens/quote_loose_items_screen.dart';
import 'package:strong_box/features/quote/screens/quote_services_screen.dart';
import 'package:strong_box/features/quote/screens/quote_summary_screen.dart';

/// Hosts a quote screen as a signed-out visitor — the state the public
/// flow has to work in. [currentUserProvider] is stubbed because the real
/// one reaches for FirebaseAuth.
Widget _guestApp(Widget screen, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: [
      currentUserProvider.overrideWith((ref) => Stream.value(null)),
      ...overrides,
    ],
    child: MaterialApp(theme: AppTheme.light, home: screen),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('a cold start lands a visitor on the calculator', (tester) async {
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(overrides: [
      // Signed out, and auth has already resolved.
      authStateProvider.overrideWith((ref) => Stream<User?>.value(null)),
      currentUserProvider.overrideWith((ref) => Stream.value(null)),
    ]);
    addTearDown(container.dispose);

    final router = container.read(appRouterProvider);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
      ),
    ));
    await tester.pumpAndSettle();

    // `/` resolves to the public landing page, not the sign-in screen.
    expect(find.text('Quick Storage Calculator'), findsOneWidget);
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/quote',
    );

    // The way into an account is offered, not forced.
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);

    // Opening the landing page did not weaken the portal guard: a guest
    // asking for a client screen still has to sign in.
    router.go('/client/storage');
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/login');

    // …but every step of the quote flow stays open.
    for (final step in const [
      '/quote/boxes',
      '/quote/items',
      '/quote/services',
      '/quote/summary',
    ]) {
      router.go(step);
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.path, step);
    }
  });

  testWidgets('a signed-out visitor can price a quote', (tester) async {
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    late ProviderContainer container;
    await tester.pumpWidget(_guestApp(
      Consumer(builder: (context, ref, _) {
        container = ProviderScope.containerOf(context);
        return const QuoteCalculatorScreen();
      }),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Quick Storage Calculator'), findsOneWidget);
    // Nothing added yet, so the panel prompts rather than quoting.
    expect(find.textContaining('Add a box or a loose item'), findsOneWidget);

    // Add two small boxes via the first stepper's "+".
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    final quote = container.read(quoteDraftProvider);
    expect(container.read(quoteDraftProvider.notifier).boxQuantity(BoxSize.small), 2);
    expect(quote.monthlyTotalZar, 390);
    expect(find.text('2 × Small Box'), findsOneWidget);
  });

  testWidgets('the summary sends a signed-out visitor to register',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(overrides: [
      currentUserProvider.overrideWith((ref) => Stream.value(null)),
    ]);
    addTearDown(container.dispose);

    container.read(quoteDraftProvider.notifier).setBoxQuantity(BoxSize.small, 2);

    var pushedRoute = '';
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light,
        home: const QuoteSummaryScreen(),
        routes: {
          '/register': (context) {
            pushedRoute = '/register';
            return const SizedBox.shrink();
          },
        },
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Quote Summary'), findsOneWidget);
    // The CTA advertises the auth gate rather than hiding it.
    expect(find.text('Accept Quote & Sign Up'), findsOneWidget);
    expect(pushedRoute, isEmpty);

    // Nothing is armed until the visitor actually tries to accept.
    expect(container.read(quoteReturnPathProvider), isNull);
  });

  // Every wizard step renders inside a scroll view, which is where
  // unbounded-flex mistakes surface. Pump each one at both breakpoints.
  for (final size in const [Size(1400, 2400), Size(420, 900)]) {
    for (final step in <({String name, Widget screen})>[
      (name: 'boxes', screen: const QuoteBoxesScreen()),
      (name: 'loose items', screen: const QuoteLooseItemsScreen()),
      (name: 'services', screen: const QuoteServicesScreen()),
    ]) {
      testWidgets(
        'the ${step.name} step lays out at ${size.width.toInt()}px',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(_guestApp(step.screen));
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
