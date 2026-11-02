import 'package:freezed_annotation/freezed_annotation.dart';

part 'value_objects.freezed.dart';
part 'value_objects.g.dart';

/// Embedded postal address (doc 03).
@freezed
class Address with _$Address {
  const factory Address({
    @Default('') String line1,
    String? line2,
    @Default('') String city,
    String? state,
    @Default('') String postCode,
    @Default('ZA') String country,
    double? lat,
    double? lng,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
}

/// One line of packing supplies on a job: what, how many, and the
/// once-off price each that was quoted (doc 03).
@freezed
class SupplyLine with _$SupplyLine {
  const factory SupplyLine({
    required String id,
    @Default('') String label,
    @Default(0) int qty,
    @Default(0) int unitZar,
  }) = _SupplyLine;

  factory SupplyLine.fromJson(Map<String, dynamic> json) =>
      _$SupplyLineFromJson(json);
}

/// Per-user notification delivery preferences (doc 03).
@freezed
class NotificationPrefs with _$NotificationPrefs {
  const factory NotificationPrefs({
    /// Booking received / confirmed / declined.
    @Default(true) bool bookingUpdatesEmail,
    @Default(true) bool pickupStartedEmail,
    @Default(false) bool pickupStartedSms,
    @Default(true) bool deliveryCompletedEmail,
    @Default(true) bool deliveryCompletedSms,
    @Default(true) bool invoiceReadyEmail,
    @Default(false) bool invoiceReadySms,
    @Default(true) bool storageThresholdEmail,
    @Default(false) bool storageThresholdSms,
  }) = _NotificationPrefs;

  factory NotificationPrefs.fromJson(Map<String, dynamic> json) =>
      _$NotificationPrefsFromJson(json);
}

/// A break within a driver shift (doc 03).
@freezed
class BreakPeriod with _$BreakPeriod {
  const factory BreakPeriod({
    required DateTime startedAt,
    DateTime? endedAt,
  }) = _BreakPeriod;

  factory BreakPeriod.fromJson(Map<String, dynamic> json) =>
      _$BreakPeriodFromJson(json);
}
