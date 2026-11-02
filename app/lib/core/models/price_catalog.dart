// ignore_for_file: invalid_annotation_target
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/timestamp_converter.dart';

part 'price_catalog.freezed.dart';
part 'price_catalog.g.dart';

/// A storage box size, charged per box per month.
///
/// JSON keys (`desc`, `price`) match packages/pricing/pricing.json and the
/// Firestore `priceLists` document, which the website reads too.
@freezed
class BoxPrice with _$BoxPrice {
  const factory BoxPrice({
    required String id,
    required String label,
    @JsonKey(name: 'desc') @Default('') String description,
    @JsonKey(name: 'price') required int monthlyZar,

    /// False once retired: hidden from the website and from new units, but
    /// still names the units already stored under it.
    @Default(true) bool active,
  }) = _BoxPrice;

  factory BoxPrice.fromJson(Map<String, dynamic> json) =>
      _$BoxPriceFromJson(json);
}

/// A loose (unboxed) item, charged per item per month.
@freezed
class LooseItemPrice with _$LooseItemPrice {
  const factory LooseItemPrice({
    required String id,
    required String name,
    required String category,

    /// Material Symbols name used by the website — one of
    /// [PriceCatalog.itemIcons].
    @Default('inventory_2') String icon,
    @JsonKey(name: 'price') required int monthlyZar,
    @Default(true) bool active,
  }) = _LooseItemPrice;

  factory LooseItemPrice.fromJson(Map<String, dynamic> json) =>
      _$LooseItemPriceFromJson(json);
}

/// A pickup vehicle, charged once per collection.
@freezed
class VehiclePrice with _$VehiclePrice {
  const factory VehiclePrice({
    required String id,
    required String label,
    @JsonKey(name: 'desc') @Default('') String description,
    @Default(0.0) double capacityM3,
    @JsonKey(name: 'price') required int onceOffZar,
    @Default(false) bool recommended,

    /// Material Symbols name the website's calculator shows.
    @Default('local_shipping') String icon,
    @Default(true) bool active,
  }) = _VehiclePrice;

  factory VehiclePrice.fromJson(Map<String, dynamic> json) =>
      _$VehiclePriceFromJson(json);
}

/// A packing supply (wrapping, paper, tape), charged once per unit sold.
/// Delivered before the pickup (supply drop-off) or brought on the day.
@freezed
class SupplyPrice with _$SupplyPrice {
  const factory SupplyPrice({
    required String id,
    required String label,
    @JsonKey(name: 'desc') @Default('') String description,
    @JsonKey(name: 'price') required int onceOffZar,
    @Default(true) bool active,
  }) = _SupplyPrice;

  factory SupplyPrice.fromJson(Map<String, dynamic> json) =>
      _$SupplyPriceFromJson(json);
}

/// A professional packer on pickup day, charged per hour with a minimum.
@freezed
class PackingHelperPrice with _$PackingHelperPrice {
  const factory PackingHelperPrice({
    @Default('Packing helper') String label,
    @JsonKey(name: 'desc') @Default('') String description,
    @JsonKey(name: 'price') @Default(0) int hourlyZar,
    @Default(2) int minHours,
    @Default(true) bool active,
  }) = _PackingHelperPrice;

  factory PackingHelperPrice.fromJson(Map<String, dynamic> json) =>
      _$PackingHelperPriceFromJson(json);
}

/// The live price list — `priceLists/{tenantId}`, edited by admins and read
/// by the app and the website. Until an admin first saves, everyone uses
/// the defaults in packages/pricing/pricing.json (`PriceList.catalog`).
@freezed
class PriceCatalog with _$PriceCatalog {
  const PriceCatalog._();

  const factory PriceCatalog({
    @Default([]) List<BoxPrice> boxes,
    @Default([]) List<String> looseItemCategories,
    @Default([]) List<LooseItemPrice> looseItems,
    @Default([]) List<String> itemIcons,
    @Default([]) List<VehiclePrice> vehicles,
    @Default([]) List<SupplyPrice> supplies,
    @Default(PackingHelperPrice()) PackingHelperPrice packingHelper,
    @NullableTimestampConverter() DateTime? updatedAt,
    String? updatedBy,
  }) = _PriceCatalog;

  factory PriceCatalog.fromJson(Map<String, dynamic> json) =>
      _$PriceCatalogFromJson(json);

  factory PriceCatalog.fromFirestore(DocumentSnapshot doc) =>
      PriceCatalog.fromJson(doc.data()! as Map<String, dynamic>);

  /// Box size for [key], retired or not; null when [key] is not a box.
  BoxPrice? box(String? key) {
    for (final box in boxes) {
      if (box.id == key) return box;
    }
    return null;
  }

  /// Loose item for [key], retired or not; null when it is not one.
  LooseItemPrice? looseItem(String? key) {
    for (final item in looseItems) {
      if (item.id == key) return item;
    }
    return null;
  }

  /// Current list price per month for a box or loose-item [key].
  int? monthlyFor(String? key) =>
      box(key)?.monthlyZar ?? looseItem(key)?.monthlyZar;

  /// Display name for a box or loose-item [key].
  String? labelFor(String? key) => box(key)?.label ?? looseItem(key)?.name;

  List<BoxPrice> get activeBoxes => boxes.where((b) => b.active).toList();
  List<LooseItemPrice> get activeLooseItems =>
      looseItems.where((i) => i.active).toList();
  List<VehiclePrice> get activeVehicles =>
      vehicles.where((v) => v.active).toList();
  List<SupplyPrice> get activeSupplies =>
      supplies.where((s) => s.active).toList();

  /// Supply for [id], retired or not.
  SupplyPrice? supply(String? id) {
    for (final s in supplies) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Whether a packing helper can be booked.
  bool get offersHelper => packingHelper.active && packingHelper.hourlyZar > 0;

  int get boxFrom => _min(activeBoxes.map((b) => b.monthlyZar));
  int get looseItemFrom => _min(activeLooseItems.map((i) => i.monthlyZar));
  int get pickupFrom => _min(activeVehicles.map((v) => v.onceOffZar));

  static int _min(Iterable<int> prices) =>
      prices.isEmpty ? 0 : prices.reduce((a, b) => a < b ? a : b);
}
