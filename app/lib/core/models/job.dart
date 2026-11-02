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

    /// The driver's name, saved at dispatch so the client can see who is
    /// coming (clients can't read staff profiles).
    String? driverName,
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
    /// Pickup fee (once-off, by vehicle) quoted when booked.
    double? estimatedFee,

    /// Price-list vehicle chosen when a client booked from a quote.
    String? pickupVehicleId,

    /// `quote` when a client booked it from the app, `request` for a
    /// client delivery request; null for ops-created.
    String? source,

    /// Fleet vehicle (vehicles/{id}) dispatched for the job.
    String? fleetVehicleId,

    /// Packing-helper hours booked for pickup day (0 = none).
    @Default(0) int helperHours,

    /// Gate codes, parking, stairs — shown to the driver.
    String? accessNotes,

    /// Packing supplies: what a supply drop-off delivers, or what the
    /// driver brings on a same-day pickup.
    @Default([]) List<SupplyLine> supplies,

    /// Empty boxes per size a supply drop-off delivers (price-list box id
    /// → count). Free — the boxes are charged monthly once stored.
    @Default({}) Map<String, int> emptyBoxes,

    /// Pickup booked with supplies delivered first (journey Path A).
    @Default(false) bool suppliesFirst,

    /// The pickup ↔ supply drop-off pair of a Path A booking.
    String? linkedJobId,

    /// Once-off charges for the job (vehicle + supplies + helper), billed
    /// on the client's next monthly invoice.
    @Default(0) int onceOffZar,

    /// Invoice id (`{clientId}_{YYYY-MM}`) that billed [onceOffZar].
    String? invoicedIn,
    @NullableTimestampConverter() DateTime? confirmedAt,
    String? confirmedBy,

    /// Driver checked in "on my way" / "arrived".
    @NullableTimestampConverter() DateTime? departedAt,
    @NullableTimestampConverter() DateTime? arrivedAt,

    /// Pickup signed for at the client's door.
    @NullableTimestampConverter() DateTime? collectedAt,

    /// Units scanned in at the facility (pickup) or handed over at the
    /// door (delivery).
    @Default([]) List<String> receivedUnitIds,
    @Default([]) List<String> handedOverUnitIds,

    /// Who signed for the job.
    String? recipientName,
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

  bool get allUnitsScanned =>
      storageUnitIds.isNotEmpty &&
      scannedUnitIds.toSet().containsAll(storageUnitIds);

  bool get allUnitsReceived =>
      storageUnitIds.isNotEmpty &&
      receivedUnitIds.toSet().containsAll(storageUnitIds);

  bool get allUnitsHandedOver =>
      storageUnitIds.isNotEmpty &&
      handedOverUnitIds.toSet().containsAll(storageUnitIds);

  /// Empty boxes plus supply units a supply drop-off carries.
  int get supplyItemCount =>
      supplies.fold(0, (total, s) => total + s.qty) +
      emptyBoxes.values.fold(0, (total, n) => total + n);
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
