import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:strong_box/core/constants/pricing.dart';
import 'package:strong_box/core/enums/app_enums.dart';
import 'package:strong_box/core/models/storage_unit.dart';

/// Guards the shared price list: fails if `price_list.g.dart` drifted from
/// `packages/pricing/pricing.json` (run `node packages/pricing/build.mjs`) —
/// the same file the website's calculators read — and pins the billing
/// arithmetic to the site's rules.
void main() {
  final json = jsonDecode(
    File('../packages/pricing/pricing.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  List<Map<String, dynamic>> list(String key) =>
      (json[key] as List).cast<Map<String, dynamic>>();

  test('generated price list matches pricing.json', () {
    expect(
      PriceList.boxes.map((b) => (b.id, b.monthlyZar)),
      list('boxes').map((b) => (b['id'], b['price'])),
    );
    expect(
      PriceList.looseItems.map((i) => (i.id, i.monthlyZar)),
      list('looseItems').map((i) => (i['id'], i['price'])),
    );
    expect(
      PriceList.vehicles.map((v) => (v.id, v.onceOffZar)),
      list('vehicles').map((v) => (v['id'], v['price'])),
    );
  });

  test('there are no term or prepay discounts in the price list', () {
    expect(json.containsKey('prepayTiers'), isFalse);
  });

  test('box and loose-item ids never collide', () {
    final ids = [
      ...PriceList.boxes.map((b) => b.id),
      ...PriceList.looseItems.map((i) => i.id),
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
      ]);
      expect(bill.billableUnits, hasLength(3));
      expect(bill.monthlyZar, 195 + 295 + 110);
    });

    test('keeps the recorded rate over today\'s list price', () {
      final bill = StorageBill.fromUnits(
          [unit(StorageStatus.inStorage, key: 'small', rate: 150)]);
      expect(bill.monthlyZar, 150);
    });

    test('falls back to the list price, and flags units with no size', () {
      final bill = StorageBill.fromUnits([
        unit(StorageStatus.inStorage, key: 'large'),
        unit(StorageStatus.inStorage),
      ]);
      expect(bill.monthlyZar, 395);
      expect(bill.unpricedUnits, 1);
    });
  });
}
