import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/app_enums.dart';
import '../utils/timestamp_converter.dart';
import 'value_objects.dart';

part 'driver_shift.freezed.dart';
part 'driver_shift.g.dart';

/// Tracks a driver's active work session (doc 03).
@freezed
class DriverShift with _$DriverShift {
  const DriverShift._();

  const factory DriverShift({
    required String id,
    required String tenantId,
    required String driverId,
    @NullableTimestampConverter() DateTime? startedAt,
    @NullableTimestampConverter() DateTime? endedAt,
    @Default([]) List<BreakPeriod> breakPeriods,
    String? vehicleId,
    @Default('') String eIdQrCode,
    @Default([]) List<String> jobIds,
    @Default(ShiftStatus.active) ShiftStatus status,
  }) = _DriverShift;

  factory DriverShift.fromJson(Map<String, dynamic> json) =>
      _$DriverShiftFromJson(json);

  factory DriverShift.fromFirestore(DocumentSnapshot doc) =>
      DriverShift.fromJson(
          {...doc.data()! as Map<String, dynamic>, 'id': doc.id});

  bool get isOpen => status != ShiftStatus.ended;
  bool get onBreak => status == ShiftStatus.onBreak;
}
