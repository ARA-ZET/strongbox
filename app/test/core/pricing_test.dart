import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:strong_box/core/constants/pricing.dart';
import 'package:strong_box/core/enums/app_enums.dart';
import 'package:strong_box/core/models/storage_unit.dart';
import 'package:strong_box/features/admin/providers/pricing_providers.dart';

/// Guards the default price list: fails if `price_list.g.dart` drifted from
/// `packages/pricing/pricing.json` (run `node packages/pricing/build.mjs`) —
/// the same defaults the website falls back to — and pins the billing
/// arithmetic and the admin editor's validation.
void main() {
  final json = jsonDecode(
    File('../packages/pricing/pricing.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  List<Map<String, dynamic>> list(String key) =>
      (json[key] as List).cast<Map<String, dynamic>>();

  const defaults = PriceList.catalog;

  test('generated price list matches pricing.json', () {
    expect(
      defaults.boxes.map((b) => (b.id, b.monthlyZar)),
      list('boxes').map((b) => (b['id'], b['price'])),
    );
    expect(
      defaults.looseItems.map((i) => (i.id, i.monthlyZar)),
      list('looseItems').map((i) => (i['id'], i['price'])),
    );
    expect(
      defaults.vehicles.map((v) => (v.id, v.onceOffZar)),
      list('vehicles').map((v) => (v['id'], v['price'])),
    );
  });

  test('there are no term or prepay discounts in the price list', () {
    expect(json.containsKey('prepayTiers'), isFalse);
  });

  test('box and loose-item ids never collide', () {
    final ids = [
      ...defaults.boxes.map((b) => b.id),
      ...defaults.looseItems.map((i) => i.id),
    ];
    expect(ids.toSet().length, ids.length);
  });

  StorageUnit unit(StorageStatus status, {String? key, int rate = 0}) =>
      StorageUnit(
        id: 'u',
        tenantId: 't',
        clientId: 'c',
        status: status,
        priceKey: key,
        monthlyRateZar: rate,
      );

  group('StorageBill', () {
    test('bills only units we hold or are moving', () {
      final bill = StorageBill.fromUnits([
        unit(StorageStatus.inStorage, key: 'small', rate: 195),
        unit(StorageStatus.inTransit, key: 'medium', rate: 295),
        unit(StorageStatus.pendingDelivery, key: 'bicycle', rate: 110),
        unit(StorageStatus.pendingPickup, key: 'xl', rate: 595),
        unit(StorageStatus.delivered, key: 'xl', rate: 595),
        unit(StorageStatus.archived, key: 'xl', rate: 595),
      ], defaults);
      expect(bill.billableUnits, hasLength(3));
      expect(bill.monthlyZar, 195 + 295 + 110);
    });

    test('keeps the recorded rate over today\'s list price', () {
      final bill = StorageBill.fromUnits(
          [unit(StorageStatus.inStorage, key: 'small', rate: 150)], defaults);
      expect(bill.monthlyZar, 150);
    });

    test('falls back to the list price, and flags units with no size', () {
      final bill = StorageBill.fromUnits([
        unit(StorageStatus.inStorage, key: 'large'),
        unit(StorageStatus.inStorage),
      ], defaults);
      expect(bill.monthlyZar, 395);
      expect(bill.unpricedUnits, 1);
    });
  });

  test('the Firestore document shape round-trips through the model', () {
    final json = defaults.toJson();
    expect((json['boxes'] as List).first, containsPair('price', 195));
    expect(PriceCatalog.fromJson(json), defaults);
  });

  test('every default loose item uses a bundled icon', () {
    for (final item in defaults.looseItems) {
      expect(defaults.itemIcons, contains(item.icon), reason: item.id);
    }
  });

  group('admin price editor', () {
    test('the defaults pass validation', () {
      expect(validatePriceCatalog(defaults), isEmpty);
    });

    test('rejects a zero price and a clashing id', () {
      final broken = defaults.copyWith(boxes: [
        defaults.boxes.first.copyWith(monthlyZar: 0),
        defaults.boxes[1].copyWith(id: 'bicycle'),
      ]);
      final problems = validatePriceCatalog(broken);
      expect(problems, contains(startsWith('Small Box (45L) needs a price')));
      expect(problems, contains('Two boxes or items share an id.'));
    });

    test('needs something on sale', () {
      final retired = defaults.copyWith(boxes: [
        for (final b in defaults.boxes) b.copyWith(active: false),
      ]);
      expect(validatePriceCatalog(retired),
          contains('Keep at least one box size on sale.'));
      expect(retired.boxFrom, 0);
      expect(retired.labelFor('small'), 'Small Box (45L)');
    });

    test('ids come from the name and never collide', () {
      expect(priceIdFor('Bunk Bed!', {}), 'bunk-bed');
      expect(priceIdFor('Desk', {'desk', 'desk-2'}), 'desk-3');
    });
  });
}
