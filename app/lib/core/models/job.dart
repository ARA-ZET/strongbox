import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/app_enums.dart';
import '../utils/timestamp_converter.dart';
import 'value_objects.dart';

part 'job.freezed.dart';
part 'job.g.dart';

/// A scheduled pickup or delivery task (doc 03).
@freezed
class Job with _$Job {
  const Job._();

  const factory Job({
    required String id,
    required String tenantId,
    @Default(JobType.pickup) JobType type,
    required String clientId,
    String? driverId,
    @Default(JobStatus.scheduled) JobStatus status,
    @NullableTimestampConverter() DateTime? scheduledDate,
    @Default(TimeWindow.morning) TimeWindow timeWindow,
    @Default(Address()) Address address,
    @Default([]) List<String> storageUnitIds,
    @Default([]) List<String> scannedUnitIds,
    @Default([]) List<String> itemIds,
    String? notes,
    String? driverNotes,
    @Default([]) List<String> photoIds,
    String? clientSignatureUrl,
    String? clientConfirmMethod,
    double? estimatedFee,
    @Default(false) bool isRushJob,
    @NullableTimestampConverter() DateTime? completedAt,
    @NullableTimestampConverter() DateTime? cancelledAt,
    String? cancelReason,
    @Default(false) bool isDeleted,
    @NullableTimestampConverter() DateTime? createdAt,
    @NullableTimestampConverter() DateTime? updatedAt,
  }) = _Job;

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);

  factory Job.fromFirestore(DocumentSnapshot doc) =>
      Job.fromJson({...doc.data()! as Map<String, dynamic>, 'id': doc.id});

  /// Short reference shown in the UI, e.g. `#JB-9042`.
  String get reference =>
      '#JB-${id.substring(0, id.length.clamp(0, 4)).toUpperCase()}';

  bool get allUnitsScanned =>
      storageUnitIds.isNotEmpty &&
      scannedUnitIds.toSet().containsAll(storageUnitIds);
}

/// A timeline event on a job (jobs/{id}/events subcollection, doc 05).
@freezed
class JobEvent with _$JobEvent {
  const factory JobEvent({
    required String id,
    @Default('') String type,
    @Default('') String description,
    @Default('') String actorId,
    @Default('') String actorName,
    @Default({}) Map<String, dynamic> metadata,
    @NullableTimestampConverter() DateTime? timestamp,
  }) = _JobEvent;

  factory JobEvent.fromJson(Map<String, dynamic> json) =>
      _$JobEventFromJson(json);
}
