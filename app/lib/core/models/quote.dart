import 'package:freezed_annotation/freezed_annotation.dart';

import 'price_catalog.dart';

part 'quote.freezed.dart';
part 'quote.g.dart';

/// A quote being built: how many of each box size / loose item, the
/// pickup vehicle, and optional packing supplies and packing-helper hours. Ids are price-list ids — the same `priceKey` each
/// StorageUnit records — and the same URL form the website uses
/// (web/lib/quote.ts), so a quote handed over from the site needs no
/// translation:
///
///   ?boxes=small:2,medium:1&loose=bicycle:1&vehicle=small-van
///    &supplies=bubble-wrap:2&helper=3
@freezed
class QuoteDraft with _$QuoteDraft {
  const QuoteDraft._();

  const factory QuoteDraft({
    @Default({}) Map<String, int> boxes,
    @Default({}) Map<String, int> loose,
    String? vehicleId,

    /// Packing supplies by price-list id (once-off each).
    @Default({}) Map<String, int> supplies,

    /// Packing-helper hours on pickup day (0 = none).
    @Default(0) int helperHours,
  }) = _QuoteDraft;

  factory QuoteDraft.fromJson(Map<String, dynamic> json) =>
      _$QuoteDraftFromJson(json);

  static const maxPerItem = 99;
  static const maxHelperHours = 12;

  /// Whether [params] carry a quote (any of boxes / loose / vehicle /
  /// supplies / helper).
  static bool inQuery(Map<String, String> params) =>
      params.containsKey('boxes') ||
      params.containsKey('loose') ||
      params.containsKey('vehicle') ||
      params.containsKey('supplies') ||
      params.containsKey('helper');

  /// Reads the website's URL form. Unknown ids are kept here and dropped
  /// when priced against a catalog ([QuoteTotals]); the server re-checks.
  factory QuoteDraft.fromQuery(Map<String, String> params) => QuoteDraft(
        boxes: _decode(params['boxes']),
        loose: _decode(params['loose']),
        vehicleId: (params['vehicle'] ?? '').trim().isEmpty
            ? null
            : params['vehicle']!.trim(),
        supplies: _decode(params['supplies']),
        helperHours: (int.tryParse(params['helper'] ?? '') ?? 0)
            .clamp(0, maxHelperHours),
      );

  static Map<String, int> _decode(String? raw) {
    final out = <String, int>{};
    for (final part in (raw ?? '').split(',')) {
      final pieces = part.split(':');
      final id = pieces.first.trim();
      if (id.isEmpty) continue;
      final count = (pieces.length > 1 ? int.tryParse(pieces[1]) : 1) ?? 0;
      if (count <= 0) continue;
      out[id] = ((out[id] ?? 0) + count).clamp(0, maxPerItem);
    }
    return out;
  }

  /// The website's URL form, e.g. `boxes=small:2&vehicle=small-van`.
  Map<String, String> toQuery() => {
        if (boxes.isNotEmpty) 'boxes': _encode(boxes),
        if (loose.isNotEmpty) 'loose': _encode(loose),
        // ignore: use_null_aware_elements — build_runner can't parse `?x` yet.
        if (vehicleId != null) 'vehicle': vehicleId!,
        if (supplies.isNotEmpty) 'supplies': _encode(supplies),
        if (helperHours > 0) 'helper': '$helperHours',
      };

  static String _encode(Map<String, int> counts) => counts.entries
      .where((e) => e.value > 0)
      .map((e) => '${e.key}:${e.value}')
      .join(',');

  int get itemCount =>
      [...boxes.values, ...loose.values].fold(0, (sum, n) => sum + n);

  bool get isEmpty => itemCount == 0;

  /// [count] of box size [id] (0 removes it).
  QuoteDraft withBox(String id, int count) =>
      copyWith(boxes: _set(boxes, id, count));

  /// [count] of loose item [id] (0 removes it).
  QuoteDraft withLoose(String id, int count) =>
      copyWith(loose: _set(loose, id, count));

  /// [count] of supply [id] (0 removes it).
  QuoteDraft withSupply(String id, int count) =>
      copyWith(supplies: _set(supplies, id, count));

  QuoteDraft withHelperHours(int hours) =>
      copyWith(helperHours: hours.clamp(0, maxHelperHours));

  static Map<String, int> _set(Map<String, int> counts, String id, int n) {
    final next = {...counts};
    final clamped = n.clamp(0, maxPerItem);
    if (clamped == 0) {
      next.remove(id);
    } else {
      next[id] = clamped;
    }
    return next;
  }
}

/// One priced line of a quote.
typedef QuoteLine = ({String id, String name, int quantity, int unitZar});

/// A [QuoteDraft] priced against the live [PriceCatalog]. Retired or
/// unknown ids are left out, exactly as the booking function would refuse
/// them.
class QuoteTotals {
  QuoteTotals(QuoteDraft draft, PriceCatalog catalog)
      : boxLines = [
          for (final box in catalog.activeBoxes)
            if ((draft.boxes[box.id] ?? 0) > 0)
              (
                id: box.id,
                name: box.label,
                quantity: draft.boxes[box.id]!,
                unitZar: box.monthlyZar,
              ),
        ],
        looseLines = [
          for (final item in catalog.activeLooseItems)
            if ((draft.loose[item.id] ?? 0) > 0)
              (
                id: item.id,
                name: item.name,
                quantity: draft.loose[item.id]!,
                unitZar: item.monthlyZar,
              ),
        ],
        supplyLines = [
          for (final supply in catalog.activeSupplies)
            if ((draft.supplies[supply.id] ?? 0) > 0)
              (
                id: supply.id,
                name: supply.label,
                quantity: draft.supplies[supply.id]!,
                unitZar: supply.onceOffZar,
              ),
        ],
        helperHours = catalog.offersHelper ? draft.helperHours : 0,
        helperHourlyZar = catalog.packingHelper.hourlyZar,
        helperMinHours = catalog.packingHelper.minHours,
        vehicle = _vehicleFor(draft, catalog);

  final List<QuoteLine> boxLines;
  final List<QuoteLine> looseLines;

  /// Packing supplies — once-off, not monthly.
  final List<QuoteLine> supplyLines;
  final int helperHours;
  final int helperHourlyZar;
  final int helperMinHours;

  /// The chosen pickup vehicle, else the recommended one.
  final VehiclePrice? vehicle;

  static VehiclePrice? _vehicleFor(QuoteDraft draft, PriceCatalog catalog) {
    final vehicles = catalog.activeVehicles;
    if (vehicles.isEmpty) return null;
    for (final v in vehicles) {
      if (v.id == draft.vehicleId) return v;
    }
    return vehicles.firstWhere((v) => v.recommended,
        orElse: () => vehicles.first);
  }

  List<QuoteLine> get lines => [...boxLines, ...looseLines];

  int get itemCount => lines.fold(0, (sum, l) => sum + l.quantity);

  /// Storage per month, from collection.
  int get monthlyZar =>
      lines.fold(0, (sum, l) => sum + l.quantity * l.unitZar);

  /// Once-off pickup fee for the chosen vehicle.
  int get pickupZar => vehicle?.onceOffZar ?? 0;

  int get suppliesZar =>
      supplyLines.fold(0, (sum, l) => sum + l.quantity * l.unitZar);

  int get helperZar => helperHours * helperHourlyZar;

  /// Below the helper minimum — the booking function would refuse it.
  bool get helperTooShort => helperHours > 0 && helperHours < helperMinHours;

  /// Everything once-off: vehicle, supplies and packing help — billed on
  /// the first invoice after collection.
  int get onceOffZar => pickupZar + suppliesZar + helperZar;

  bool get isEmpty => itemCount == 0;
}
