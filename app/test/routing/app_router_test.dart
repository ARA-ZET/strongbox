import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:strong_box/core/enums/app_enums.dart';
import 'package:strong_box/core/models/app_user.dart';
import 'package:strong_box/core/models/job.dart';
import 'package:strong_box/core/models/storage_unit.dart';
import 'package:strong_box/core/theme/app_theme.dart';
import 'package:strong_box/features/auth/providers/auth_provider.dart';
import 'package:strong_box/features/client/providers/client_providers.dart';
import 'package:strong_box/features/quote/providers/quote_providers.dart';
import 'package:strong_box/repositories/booking_repository.dart';
import 'package:strong_box/repositories/quote_draft_store.dart';
import 'package:strong_box/repositories/repository_providers.dart';
import 'package:strong_box/routing/app_router.dart';

class _FakeUser implements User {
  @override
  String get uid => 'client-user';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Device storage stand-in: starts empty, remembers saves.
class _MemoryStore implements QuoteDraftStore {
  SavedQuote? saved;

  @override
  Future<SavedQuote?> load() async => saved;

  @override
  Future<void> save(SavedQuote quote) async => saved = quote;
}

/// Booking functions stand-in: records cancellations.
class _RecordingBooking implements BookingRepository {
  final cancelled = <String, String?>{};

  @override
  Future<void> cancelOrder(String jobId, {String? reason}) async =>
      cancelled[jobId] = reason;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _client = AppUser(
  id: 'client-user',
  tenantId: 'strongbox-default',
  name: 'Thandi',
  role: UserRole.client,
  clientId: 'client-1',
);

/// Visitors can build a quote and see prices without an account; booking
/// and the portals need sign-in, and a quote handed over from the website
/// carries through sign-up into booking.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  late StreamController<User?> auth;
  late StreamController<AppUser?> user;
  late ProviderContainer container;

  String path() => container
      .read(appRouterProvider)
      .routerDelegate
      .currentConfiguration
      .uri
      .path;

  Future<String> start(
    WidgetTester tester,
    String location, {
    List<Override> overrides = const [],
  }) async {
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    auth = StreamController<User?>.broadcast();
    user = StreamController<AppUser?>.broadcast();
    container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith((ref) async* {
          yield null;
          yield* auth.stream;
        }),
        currentUserProvider.overrideWith((ref) async* {
          yield null;
          yield* user.stream;
        }),
        quoteDraftStoreProvider.overrideWithValue(_MemoryStore()),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(appRouterProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    router.go(location);
    await tester.pumpAndSettle();
    return path();
  }

  Future<void> signInAsClient(WidgetTester tester) async {
    auth.add(_FakeUser());
    user.add(_client);
    await tester.pumpAndSettle();
  }

  testWidgets('a visitor lands on sign-in', (tester) async {
    expect(await start(tester, '/'), '/login');
    expect(find.text('Our website'), findsOneWidget);
  });

  testWidgets('prices are open to everyone', (tester) async {
    expect(await start(tester, '/prices'), '/prices');
  });

  testWidgets('portal pages still require sign-in', (tester) async {
    expect(await start(tester, '/client/storage'), '/login');
  });

  testWidgets('sign-up stays open for the website\'s "Get Started" links', (
    tester,
  ) async {
    expect(await start(tester, '/register'), '/register');
  });

  testWidgets('booking asks a visitor to sign up first', (tester) async {
    expect(await start(tester, '/book'), '/register');
    expect(container.read(quoteControllerProvider).bookAfterSignIn, isTrue);
  });

  testWidgets('a website quote carries through sign-up into booking', (
    tester,
  ) async {
    expect(
      await start(
        tester,
        '/register?boxes=small:2,medium:1&loose=bicycle:1&vehicle=small-van',
      ),
      '/register',
    );
    final quote = container.read(quoteControllerProvider);
    expect(quote.draft.boxes, {'small': 2, 'medium': 1});
    expect(quote.draft.loose, {'bicycle': 1});
    expect(quote.draft.vehicleId, 'small-van');
    expect(quote.bookAfterSignIn, isTrue);

    await signInAsClient(tester);
    expect(path(), '/client/order/book');
    expect(find.text('Book your pickup'), findsOneWidget);
    expect(find.text('2 × Small Box (45L)'), findsWidgets); // list + summary
    // The hop is used once — the next visit home goes to the dashboard.
    expect(container.read(quoteControllerProvider).bookAfterSignIn, isFalse);
  });

  testWidgets('a new client is led from home into building a quote', (
    tester,
  ) async {
    await start(tester, '/login');
    await signInAsClient(tester);
    expect(path(), '/client/dashboard');
    expect(find.text('Start your first order'), findsOneWidget);

    await tester.tap(find.text('Build your quote'));
    await tester.pumpAndSettle();
    expect(path(), '/client/order');
    expect(find.text('Furniture & loose items'), findsOneWidget);
  });

  testWidgets('signed-in clients build and book inside their portal', (
    tester,
  ) async {
    await start(tester, '/login');
    await signInAsClient(tester);
    container.read(appRouterProvider).go('/quote');
    await tester.pumpAndSettle();
    expect(path(), '/client/order');
    container.read(appRouterProvider).go('/book');
    await tester.pumpAndSettle();
    expect(path(), '/client/order/book');
  });

  // A label scanned with a phone's own camera opens the item — after
  // sign-in when needed — and only the owner's.
  final labelled = myUnitsProvider.overrideWith(
    (ref) => Stream.value(const [
      StorageUnit(
        id: 'unit-1',
        tenantId: 'strongbox-default',
        clientId: 'client-1',
        qrCodeId: 'SBX-1000-A0',
        label: 'Small Box 1',
      ),
    ]),
  );

  testWidgets('a label link opens the client\'s item after sign-in', (
    tester,
  ) async {
    expect(
      await start(tester, '/s/SBX-1000-A0', overrides: [labelled]),
      '/login',
    );
    await signInAsClient(tester);
    expect(path(), '/client/storage/unit-1');
  });

  testWidgets('a label that isn\'t the client\'s says so', (tester) async {
    await start(tester, '/login', overrides: [labelled]);
    await signInAsClient(tester);
    container.read(appRouterProvider).go('/s/sbx-2000-b1');
    await tester.pumpAndSettle();
    expect(path(), '/s/sbx-2000-b1');
    expect(find.text('This label isn\'t on your account.'), findsOneWidget);
  });

  testWidgets('a quote link on the builder loads it without booking', (
    tester,
  ) async {
    expect(await start(tester, '/quote?boxes=large:3'), '/quote');
    final quote = container.read(quoteControllerProvider);
    expect(quote.draft.boxes, {'large': 3});
    expect(quote.bookAfterSignIn, isFalse);
  });
  // A returning client with a pickup to pack: two boxes, one in storage.
  final portal = [
    myUnitsProvider.overrideWith(
      (ref) => Stream.value(const [
        StorageUnit(
          id: 'unit-1',
          tenantId: 'strongbox-default',
          clientId: 'client-1',
          qrCodeId: 'SBX-1000-A0',
          label: 'Kitchen box',
          jobId: 'job-1',
        ),
        StorageUnit(
          id: 'unit-2',
          tenantId: 'strongbox-default',
          clientId: 'client-1',
          label: 'Books',
          status: StorageStatus.inStorage,
        ),
      ]),
    ),
    myJobsProvider.overrideWith(
      (ref) => Stream.value([
        Job(
          id: 'job-1',
          tenantId: 'strongbox-default',
          clientId: 'client-1',
          status: JobStatus.scheduled,
          storageUnitIds: const ['unit-1'],
          scheduledDate: DateTime(2026, 11, 12),
        ),
      ]),
    ),
  ];

  testWidgets('old Deliveries links open Orders', (tester) async {
    await start(tester, '/login', overrides: portal);
    await signInAsClient(tester);
    container.read(appRouterProvider).go('/client/deliveries');
    await tester.pumpAndSettle();
    expect(path(), '/client/orders');
    expect(find.text('Active (1)'), findsOneWidget);
  });

  testWidgets('the dashboard leads to the order and on to the item', (
    tester,
  ) async {
    await start(tester, '/login', overrides: portal);
    await signInAsClient(tester);
    expect(path(), '/client/dashboard');
    expect(find.text('To do'), findsOneWidget);

    // To do → the pickup to pack for.
    await tester.tap(find.text('Get 1 item ready for Thu 12 Nov'));
    await tester.pumpAndSettle();
    expect(path(), '/client/orders/job-1');
    expect(find.text('Items in this order (1)'), findsOneWidget);
    expect(find.text('0 of 1 photographed'), findsOneWidget);

    // Order → the box itself.
    await tester.tap(find.text('Kitchen box'));
    await tester.pumpAndSettle();
    expect(path(), '/client/storage/unit-1');
  });

  testWidgets("a client cancels a pickup the driver hasn't started", (
    tester,
  ) async {
    final booking = _RecordingBooking();
    await start(
      tester,
      '/login',
      overrides: [
        ...portal,
        bookingRepositoryProvider.overrideWithValue(booking),
      ],
    );
    await signInAsClient(tester);
    container.read(appRouterProvider).go('/client/orders/job-1');
    await tester.pumpAndSettle();
    expect(find.text('Change of plans?'), findsOneWidget);

    await tester.ensureVisible(find.text('Cancel pickup'));
    await tester.tap(find.text('Cancel pickup'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel this pickup?'), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'Moving next month',
    );
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Cancel pickup'),
      ),
    );
    await tester.pumpAndSettle();
    expect(booking.cancelled, {'job-1': 'Moving next month'});
    expect(find.textContaining('cancelled.'), findsOneWidget); // snackbar
  });

  testWidgets("once the driver has set off, there's no cancel button", (
    tester,
  ) async {
    await start(
      tester,
      '/login',
      overrides: [
        portal.first,
        myJobsProvider.overrideWith(
          (ref) => Stream.value([
            Job(
              id: 'job-1',
              tenantId: 'strongbox-default',
              clientId: 'client-1',
              status: JobStatus.inProgress,
              storageUnitIds: const ['unit-1'],
              scheduledDate: DateTime(2026, 11, 12),
              departedAt: DateTime(2026, 11, 12, 8),
            ),
          ]),
        ),
      ],
    );
    await signInAsClient(tester);
    container.read(appRouterProvider).go('/client/orders/job-1');
    await tester.pumpAndSettle();
    expect(find.text('On the way'), findsOneWidget);
    expect(find.text('Change of plans?'), findsNothing);
    expect(find.text('Cancel pickup'), findsNothing);
  });

  testWidgets('dashboard stats open a filtered view', (tester) async {
    await start(tester, '/login', overrides: portal);
    await signInAsClient(tester);
    await tester.tap(find.text('In storage').first);
    await tester.pumpAndSettle();
    final uri = container
        .read(appRouterProvider)
        .routerDelegate
        .currentConfiguration
        .uri;
    expect(uri.toString(), '/client/storage?status=inStorage');
    expect(find.text('Books'), findsOneWidget);
    expect(find.text('Kitchen box'), findsNothing);
  });
  testWidgets('the portal fits a phone screen', (tester) async {
    await start(tester, '/login', overrides: portal);
    await signInAsClient(tester);
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    for (final page in [
      '/client/dashboard',
      '/client/orders',
      '/client/orders/job-1',
      '/client/storage?status=pendingPickup',
    ]) {
      container.read(appRouterProvider).go(page);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: page);
    }
    // The bottom bar names the new tab.
    expect(find.text('Orders'), findsWidgets);
  });
}
