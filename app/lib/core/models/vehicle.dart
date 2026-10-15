import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/app_enums.dart';
import '../utils/timestamp_converter.dart';

part 'vehicle.freezed.dart';
part 'vehicle.g.dart';

/// A fleet asset — car, bakkie, van, truck or trailer (`vehicles/{id}`).
@freezed
class Vehicle with _$Vehicle {
  const Vehicle._();

  const factory Vehicle({
    required String id,
    required String tenantId,
    @Default(VehicleType.bakkie) VehicleType type,

    /// What the team calls it, e.g. "Bakkie 2".
    @Default('') String name,

    /// Number plate, stored upper-case without extra spaces.
    @Default('') String registration,
    String? make,
    String? model,
    int? year,

    /// Load volume, for matching jobs to vehicles.
    double? capacityM3,
    int? payloadKg,
    @Default(VehicleStatus.available) VehicleStatus status,

    /// The driver who usually drives it (not for trailers).
    String? assignedDriverId,

    /// Licence disc expiry — renewed every year.
    @NullableTimestampConverter() DateTime? licenceExpiresAt,
    String? notes,
    @Default(false) bool isDeleted,
    @NullableTimestampConverter() DateTime? deletedAt,
    @NullableTimestampConverter() DateTime? createdAt,
    @NullableTimestampConverter() DateTime? updatedAt,
  }) = _Vehicle;

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);

  factory Vehicle.fromFirestore(DocumentSnapshot doc) => Vehicle.fromJson(
      {...doc.data()! as Map<String, dynamic>, 'id': doc.id});

  bool get isTrailer => type == VehicleType.trailer;

  /// "Bakkie 2" or, without a name, the make and model.
  String get displayName {
    if (name.trim().isNotEmpty) return name.trim();
    final makeModel = [make, model]
        .whereType<String>()
        .where((part) => part.trim().isNotEmpty)
        .join(' ');
    return makeModel.isEmpty ? type.label : makeModel;
  }

  /// The licence disc has expired.
  bool licenceExpired(DateTime now) =>
      licenceExpiresAt != null && licenceExpiresAt!.isBefore(now);

  /// The licence disc expires within the next 30 days.
  bool licenceDueSoon(DateTime now) =>
      licenceExpiresAt != null &&
      !licenceExpired(now) &&
      licenceExpiresAt!.isBefore(now.add(const Duration(days: 30)));
}

/// "ca 123-456 " → "CA 123-456": upper-case, single spaces.
String normaliseRegistration(String raw) =>
    raw.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
