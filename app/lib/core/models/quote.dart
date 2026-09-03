import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../constants/quote_pricing.dart';
import '../enums/app_enums.dart';
import '../utils/timestamp_converter.dart';

part 'quote.freezed.dart';
part 'quote.g.dart';

/// One box tier and how many of them the client wants stored.
@freezed
class QuoteBoxLine with _$QuoteBoxLine {
  const factory QuoteBoxLine({
    required BoxSize size,
    @Default(0) int quantity,
  }) = _QuoteBoxLine;

  const QuoteBoxLine._();

  factory QuoteBoxLine.fromJson(Map<String, dynamic> json) =>
      _$QuoteBoxLineFromJson(json);

  /// Monthly cost of this line at the tariff in [QuotePricing].
  int get monthlyZar => QuotePricing.boxTier(size).monthlyZar * quantity;

  /// Volume this line contributes to the vehicle recommendation.
  double get volumeM3 => QuotePricing.boxTier(size).volumeM3 * quantity;
}

/// A furniture or oversized item that will not fit in a standard box.
///
/// [monthlyZar] is snapshotted when the item is added so a later tariff
/// change never silently re-prices a quote the client has already seen.
@freezed
class QuoteLooseItem with _$QuoteLooseItem {
  const factory QuoteLooseItem({
    required String id,
    required String name,
    @Default('') String presetKey,
    @Default('') String description,
    @Default(0) double lengthM,
    @Default(0) double widthM,
    @Default(0) double heightM,
    @Default(1) int quantity,
    @Default(0) int monthlyZar,
  }) = _QuoteLooseItem;

  const QuoteLooseItem._();

  factory QuoteLooseItem.fromJson(Map<String, dynamic> json) =>
      _$QuoteLooseItemFromJson(json);

  /// Builds a line from a catalogue preset.
  factory QuoteLooseItem.fromPreset(
    LooseItemPreset preset, {
    required String id,
    int quantity = 1,
  }) =>
      QuoteLooseItem(
        id: id,
        name: preset.name,
        presetKey: preset.key,
        description: preset.defaultDescription,
        lengthM: preset.lengthM,
        widthM: preset.widthM,
        heightM: preset.heightM,
        quantity: quantity,
        monthlyZar: preset.monthlyZar,
      );

  /// True when the client typed their own dimensions.
  bool get isCustom => presetKey.isEmpty;

  /// Emoji for the catalogue preset, or a generic parcel for custom items.
  String get emoji => QuotePricing.presetFor(presetKey)?.emoji ?? '📦';

  /// Volume of a single unit of this item.
  double get unitVolumeM3 => lengthM * widthM * heightM;

  /// Volume across [quantity].
  double get volumeM3 => unitVolumeM3 * quantity;

  /// Monthly cost across [quantity].
  int get lineMonthlyZar => monthlyZar * quantity;

  /// `160 × 90 × 75 cm`, matching the box tier dimension format.
  String get dimensionsLabel => '${(lengthM * 100).round()} × '
      '${(widthM * 100).round()} × ${(heightM * 100).round()} cm';
}

/// A storage quote. Built anonymously in the public calculator and only
/// written to Firestore once the client has an account and accepts it.
@freezed
class Quote with _$Quote {
  const factory Quote({
    @Default('') String id,
    required String tenantId,
    @Default('') String reference,
    String? clientId,
    String? userId,
    @Default(QuoteStatus.draft) QuoteStatus status,
    @Default([]) List<QuoteBoxLine> boxes,
    @Default([]) List<QuoteLooseItem> looseItems,
    @Default(false) bool packingRequired,
    @Default(QuotePricing.defaultPackers) int packers,
    @Default(QuotePricing.minPackingHours) int packingHours,
    @Default(VehicleSize.mediumVan) VehicleSize vehicle,
    @Default('') String contactName,
    @Default('') String contactEmail,
    @Default('') String contactPhone,
    @Default('') String collectionAddress,
    @Default('') String notes,

    /// Totals snapshotted at acceptance, so the stored quote never drifts
    /// from the figures the client agreed to.
    @Default(0) int monthlyStorageZar,
    @Default(0) int collectionZar,
    @Default(0) int packingZar,
    @Default(0) int dueTodayZar,
    @Default(0) double estimatedVolumeM3,

    /// Pickup job created when the quote was accepted.
    String? jobId,
    @Default(false) bool isDeleted,
    @NullableTimestampConverter() DateTime? deletedAt,
    @NullableTimestampConverter() DateTime? acceptedAt,
    @NullableTimestampConverter() DateTime? createdAt,
    @NullableTimestampConverter() DateTime? updatedAt,
  }) = _Quote;

  const Quote._();

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);

  factory Quote.fromFirestore(DocumentSnapshot doc) =>
      Quote.fromJson({...doc.data()! as Map<String, dynamic>, 'id': doc.id});

  // ---------------------------------------------------------- derived totals
  // Computed from the line items rather than the snapshotted fields, so the
  // live calculator and the stored quote share one implementation (rule 29).

  /// Box lines with a quantity above zero, in tariff order.
  List<QuoteBoxLine> get activeBoxes =>
      boxes.where((line) => line.quantity > 0).toList();

  /// Total number of boxes across all tiers.
  int get boxCount =>
      boxes.fold(0, (total, line) => total + line.quantity);

  /// Combined monthly cost of every box line.
  int get boxesMonthlyZar =>
      boxes.fold(0, (total, line) => total + line.monthlyZar);

  /// Combined monthly cost of every loose item.
  int get looseItemsMonthlyZar =>
      looseItems.fold(0, (total, item) => total + item.lineMonthlyZar);

  /// What the client pays every month for storage.
  int get monthlyTotalZar => boxesMonthlyZar + looseItemsMonthlyZar;

  /// Once-off collection fee for the selected vehicle.
  int get collectionFeeZar => QuotePricing.vehicleTier(vehicle).onceOffZar;

  /// Once-off packing fee, or zero when the client packs themselves.
  int get packingFeeZar => packingRequired
      ? QuotePricing.packerHourlyZar * packers * packingHours
      : 0;

  /// First payment: the once-off services only. Storage is billed from
  /// month two, which is why the panels read "monthly from month 2".
  int get dueTodayTotalZar => collectionFeeZar + packingFeeZar;

  /// Total volume, used for the capacity meter and vehicle recommendation.
  double get volumeM3 {
    final boxVolume =
        boxes.fold(0.0, (total, line) => total + line.volumeM3);
    final looseVolume =
        looseItems.fold(0.0, (total, item) => total + item.volumeM3);
    return boxVolume + looseVolume;
  }

  /// Smallest vehicle that fits [volumeM3].
  VehicleSize get recommendedVehicle =>
      QuotePricing.recommendedVehicle(volumeM3);

  /// True when the selected vehicle cannot carry everything in one trip.
  bool get vehicleUndersized =>
      volumeM3 > QuotePricing.vehicleTier(vehicle).capacityM3;

  /// How full the selected vehicle is, clamped to 0–1 for the meter.
  double get capacityUtilisation {
    final capacity = QuotePricing.vehicleTier(vehicle).capacityM3;
    if (capacity <= 0) return 0;
    return (volumeM3 / capacity).clamp(0.0, 1.0);
  }

  /// Nothing has been added yet — blocks progressing past the boxes step.
  bool get isEmpty => boxCount == 0 && looseItems.isEmpty;

  /// Copy with every total snapshotted from the current line items.
  Quote withSnapshottedTotals() => copyWith(
        monthlyStorageZar: monthlyTotalZar,
        collectionZar: collectionFeeZar,
        packingZar: packingFeeZar,
        dueTodayZar: dueTodayTotalZar,
        estimatedVolumeM3: volumeM3,
      );
}
