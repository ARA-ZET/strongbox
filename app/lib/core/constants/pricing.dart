import '../enums/app_enums.dart';
import '../models/price_catalog.dart';
import '../models/storage_unit.dart';

export '../models/price_catalog.dart';
export 'price_list.g.dart';

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
  /// existed fall back to [catalog]'s current list price, and are counted in
  /// [unpricedUnits] when they have no size at all.
  factory StorageBill.fromUnits(
      Iterable<StorageUnit> units, PriceCatalog catalog) {
    final billable = units
        .where((unit) => !unit.isDeleted && unit.status.isBillable)
        .toList();
    var total = 0;
    var unpriced = 0;
    for (final unit in billable) {
      final rate = unit.monthlyRateZar > 0
          ? unit.monthlyRateZar
          : catalog.monthlyFor(unit.priceKey);
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
