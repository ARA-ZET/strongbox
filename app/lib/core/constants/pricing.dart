import '../enums/app_enums.dart';
import '../models/storage_unit.dart';
import 'price_list.g.dart';

export 'price_list.g.dart';

/// Lookups and arithmetic over the shared [PriceList] — the same numbers
/// and rules the marketing site's calculators use (web/lib/constants.ts).
class Pricing {
  Pricing._();

  /// Box size for [key], or null when [key] is not a box.
  static BoxPrice? box(String? key) {
    for (final box in PriceList.boxes) {
      if (box.id == key) return box;
    }
    return null;
  }

  /// Loose item for [key], or null when [key] is not a loose item.
  static LooseItemPrice? looseItem(String? key) {
    for (final item in PriceList.looseItems) {
      if (item.id == key) return item;
    }
    return null;
  }

  /// Current list price per month for a box or loose-item [key].
  static int? monthlyFor(String? key) =>
      box(key)?.monthlyZar ?? looseItem(key)?.monthlyZar;

  /// Display name for a box or loose-item [key].
  static String? labelFor(String? key) => box(key)?.label ?? looseItem(key)?.name;

  static int get boxFrom =>
      PriceList.boxes.map((b) => b.monthlyZar).reduce((a, b) => a < b ? a : b);

  static int get looseItemFrom => PriceList.looseItems
      .map((i) => i.monthlyZar)
      .reduce((a, b) => a < b ? a : b);

  static int get pickupFrom => PriceList.vehicles
      .map((v) => v.onceOffZar)
      .reduce((a, b) => a < b ? a : b);
}

/// What a client owes for storage each month, worked out from their units.
/// Storage is billed monthly per unit; there are no term discounts.
class StorageBill {
  const StorageBill({
    required this.billableUnits,
    required this.unpricedUnits,
    required this.monthlyZar,
  });

  /// Sums the monthly rate of every billable unit. A unit's rate is the one
  /// recorded when it was registered, so a later price change never
  /// re-prices goods already in storage; units registered before pricing
  /// existed fall back to today's list price, and are counted in
  /// [unpricedUnits] when they have no size at all.
  factory StorageBill.fromUnits(Iterable<StorageUnit> units) {
    final billable = units
        .where((unit) => !unit.isDeleted && unit.status.isBillable)
        .toList();
    var total = 0;
    var unpriced = 0;
    for (final unit in billable) {
      final rate = unit.monthlyRateZar > 0
          ? unit.monthlyRateZar
          : Pricing.monthlyFor(unit.priceKey);
      if (rate == null || rate == 0) {
        unpriced++;
      } else {
        total += rate;
      }
    }
    return StorageBill(
      billableUnits: billable,
      unpricedUnits: unpriced,
      monthlyZar: total,
    );
  }

  final List<StorageUnit> billableUnits;

  /// Billable units with no size recorded — an admin needs to set one.
  final int unpricedUnits;

  /// Monthly storage total.
  final int monthlyZar;
}
