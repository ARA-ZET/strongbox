import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:strong_box/core/constants/pricing.dart';
import 'package:strong_box/features/admin/providers/pricing_providers.dart';
import 'package:strong_box/features/admin/screens/admin_pricing_screen.dart';
import 'package:strong_box/features/auth/providers/auth_provider.dart';
import 'package:strong_box/repositories/price_list_repository.dart';
import 'package:strong_box/repositories/repository_providers.dart';

/// In-memory `priceLists/{tenantId}`: [update] behaves like the Firestore
/// transaction — change the stored list (or the defaults), then emit it.
class _FakePriceListRepository implements PriceListRepository {
  final _changes = StreamController<PriceCatalog?>.broadcast();
  PriceCatalog? stored;
  int writes = 0;

  @override
  Stream<PriceCatalog?> watch(String tenantId) async* {
    yield stored;
    yield* _changes.stream;
  }

  @override
  Future<PriceCatalog> update(
    String tenantId,
    PriceCatalog Function(PriceCatalog current) change, {
    required PriceCatalog defaults,
    required String actorId,
  }) async {
    final next = change(stored ?? defaults);
    stored = next.copyWith(itemIcons: const []);
    writes++;
    _changes.add(stored);
    return next;
  }
}

void main() {
  late _FakePriceListRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = _FakePriceListRepository();
    container = ProviderContainer(
      overrides: [
        priceListRepositoryProvider.overrideWithValue(repo),
        currentActorIdProvider.overrideWithValue('admin-1'),
      ],
    );
  });
  tearDown(() => container.dispose());

  BoxPrice small(PriceCatalog c) => c.boxes.firstWhere((b) => b.id == 'small');

  test('first save writes the whole default list with the edit', () async {
    final editor = container.read(pricingEditorProvider.notifier);
    await editor.upsertBox(small(PriceList.catalog).copyWith(monthlyZar: 205));

    expect(small(repo.stored!).monthlyZar, 205);
    expect(
      repo.stored!.looseItems,
      hasLength(PriceList.catalog.looseItems.length),
    );
    expect(
      repo.stored!.looseItemCategories,
      PriceList.catalog.looseItemCategories,
    );
    expect(repo.stored!.vehicles, hasLength(PriceList.catalog.vehicles.length));
  });

  test('later saves build on what is stored, not on the defaults', () async {
    final editor = container.read(pricingEditorProvider.notifier);
    await editor.upsertBox(small(PriceList.catalog).copyWith(monthlyZar: 205));
    final desk = PriceList.catalog.looseItems.firstWhere((i) => i.id == 'desk');
    await editor.upsertLooseItem(desk.copyWith(monthlyZar: 120));

    expect(small(repo.stored!).monthlyZar, 205);
    expect(
      repo.stored!.looseItems.firstWhere((i) => i.id == 'desk').monthlyZar,
      120,
    );
  });

  test('an invalid list is refused with the reason and not written', () async {
    final editor = container.read(pricingEditorProvider.notifier);
    final retireAll = PriceList.catalog.boxes.map(
      (b) => b.copyWith(active: false),
    );
    for (final box in retireAll.take(retireAll.length - 1)) {
      await editor.upsertBox(box);
    }
    final writes = repo.writes;

    await expectLater(
      editor.upsertBox(retireAll.last),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('at least one box'),
        ),
      ),
    );
    expect(repo.writes, writes);
  });

  testWidgets(
    'editing a price in the dialog saves it and keeps every section',
    (tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      tester.view.physicalSize = const Size(1400, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: AdminPricingScreen())),
        ),
      );
      await tester.pumpAndSettle();
      tester.takeException(); // Inter isn't bundled in tests.

      await tester.tap(find.text('Small Box (45L)'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Price per month'),
        '205',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(small(repo.stored!).monthlyZar, 205);
      expect(find.text('R205/mo'), findsOneWidget);
      expect(find.textContaining('Storage boxes'), findsOneWidget);
      expect(find.textContaining('Loose items'), findsOneWidget);
      expect(find.textContaining('Pickup vehicles'), findsOneWidget);
      expect(find.text('Dining Table'), findsOneWidget);
    },
  );
}
