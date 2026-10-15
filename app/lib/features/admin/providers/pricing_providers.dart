import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/pricing.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/providers/price_catalog_provider.dart';
import '../../../core/providers/tenant_provider.dart';
import '../../../repositories/repository_providers.dart';
import '../../auth/providers/auth_provider.dart';

part 'pricing_providers.g.dart';

/// Highest price the editor accepts, in Rand — a typo guard, not policy.
const maxPriceZar = 100000;

/// Edits to the shared price list. Each call saves straight to Firestore —
/// there is no draft to lose — so the app updates at once and the website
/// within about five minutes. The change is applied to the latest stored
/// list inside a transaction, then validated; a problem throws
/// [StateError] with the reason and nothing is written.
@Riverpod(keepAlive: true)
class PricingEditor extends _$PricingEditor {
  @override
  void build() {}

  // ---- boxes

  /// Adds [box], or replaces the entry whose id is [box.id].
  Future<void> upsertBox(BoxPrice box) => _save((c) {
    final list = [...c.boxes];
    final i = list.indexWhere((b) => b.id == box.id);
    i == -1 ? list.add(box) : list[i] = box;
    return c.copyWith(boxes: list);
  });

  // ---- loose items

  Future<void> upsertLooseItem(LooseItemPrice item) => _save((c) {
    final list = [...c.looseItems];
    final i = list.indexWhere((x) => x.id == item.id);
    i == -1 ? list.add(item) : list[i] = item;
    return c.copyWith(looseItems: list);
  });

  // ---- vehicles

  /// Adds or replaces [vehicle]. Marking one recommended un-marks the rest —
  /// the website highlights a single vehicle.
  Future<void> upsertVehicle(VehiclePrice vehicle) => _save((c) {
    var list = [...c.vehicles];
    final i = list.indexWhere((v) => v.id == vehicle.id);
    i == -1 ? list.add(vehicle) : list[i] = vehicle;
    if (vehicle.recommended) {
      list = [
        for (final v in list)
          v.id == vehicle.id ? v : v.copyWith(recommended: false),
      ];
    }
    return c.copyWith(vehicles: list);
  });

  Future<void> _save(PriceCatalog Function(PriceCatalog) change) async {
    try {
      await ref
          .read(priceListRepositoryProvider)
          .update(
            ref.read(currentTenantIdProvider),
            (current) {
              final next = change(current);
              final problems = validatePriceCatalog(next);
              if (problems.isNotEmpty) throw StateError(problems.first);
              return next;
            },
            defaults: PriceList.catalog,
            actorId: ref.read(currentActorIdProvider),
          );
    } on AppException catch (error) {
      // Surface our own validation message, not the repository's wrapper.
      final original = error.original;
      if (original is StateError) throw original;
      rethrow;
    }
    // A listener that failed earlier (e.g. before the rules allowed reads)
    // stays failed; resubscribe so the screen shows what was just saved.
    if (ref.read(livePriceCatalogProvider).hasError) {
      ref.invalidate(livePriceCatalogProvider);
    }
  }
}

/// Ids already in the live list — used to keep a new entry's id unique.
@riverpod
Set<String> savedPriceIds(Ref ref) {
  final live = ref.watch(priceCatalogProvider);
  return {
    ...live.boxes.map((b) => b.id),
    ...live.looseItems.map((i) => i.id),
    ...live.vehicles.map((v) => v.id),
  };
}

/// Everything that would make [catalog] unsafe to publish, worst first.
List<String> validatePriceCatalog(PriceCatalog catalog) {
  final problems = <String>[];
  if (catalog.activeBoxes.isEmpty) {
    problems.add('Keep at least one box size on sale.');
  }
  if (catalog.activeVehicles.isEmpty) {
    problems.add('Keep at least one pickup vehicle on offer.');
  }

  // Units store a box or loose-item id as their priceKey, so the two
  // lists share one namespace.
  final unitIds = [
    ...catalog.boxes.map((b) => b.id),
    ...catalog.looseItems.map((i) => i.id),
  ];
  if (unitIds.toSet().length != unitIds.length) {
    problems.add('Two boxes or items share an id.');
  }

  void checkPrice(String name, int price) {
    if (price <= 0 || price > maxPriceZar) {
      problems.add('$name needs a price between R1 and R$maxPriceZar.');
    }
  }

  for (final b in catalog.boxes) {
    if (b.label.trim().isEmpty) problems.add('Every box needs a name.');
    checkPrice(b.label, b.monthlyZar);
  }
  for (final i in catalog.looseItems) {
    if (i.name.trim().isEmpty) problems.add('Every item needs a name.');
    checkPrice(i.name, i.monthlyZar);
    if (!catalog.looseItemCategories.contains(i.category)) {
      problems.add('${i.name} has an unknown category.');
    }
  }
  for (final v in catalog.vehicles) {
    if (v.label.trim().isEmpty) problems.add('Every vehicle needs a name.');
    checkPrice(v.label, v.onceOffZar);
  }
  return problems;
}

/// A stable id for a new entry, from its name — `Bunk Bed` → `bunk-bed`,
/// suffixed when [taken] already has it. Never changes once saved.
String priceIdFor(String name, Set<String> taken) {
  final base = name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  final stem = base.isEmpty ? 'item' : base;
  var id = stem;
  for (var n = 2; taken.contains(id); n++) {
    id = '$stem-$n';
  }
  return id;
}
