import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// All domain enums (doc 04). Never use raw strings where an enum exists.
///
/// Enum values serialise to their Dart name via json_serializable
/// (e.g. `StorageStatus.inStorage` → `"inStorage"`), matching the schema.

enum UserRole { admin, driver, client }

enum StorageStatus {
  pendingPickup,
  inTransit,
  inStorage,
  pendingDelivery,
  delivered,
  cancelled,
  archived,
}

/// Job lifecycle. Client bookings and delivery requests start in
/// [pendingConfirmation] until an admin confirms them. A pickup is
/// [collected] once the client signs at the door, and [completed] when the
/// driver has scanned every unit in at the facility.
enum JobStatus {
  pendingConfirmation,
  scheduled,
  assigned,
  inProgress,
  collected,
  completed,
  cancelled,
}

/// [supplyDrop] brings empty boxes and packing supplies before a pickup
/// (journey Path A); it carries no storage units.
enum JobType { pickup, delivery, supplyDrop }

/// Condition a driver records for a unit at collection.
enum UnitCondition { good, damaged }

enum UnitType { closed, open }

enum SubscriptionStatus {
  active,
  trialing,
  pastDue,
  cancelled,
  incomplete,
  unpaid,
}


enum ClientType { personal, business }

enum TimeWindow { morning, afternoon, evening }

enum PhotoType { exterior, interior, driverCapture, signature }

enum AuditAction {
  qrScanned,
  qrLinked,
  qrGenerated,
  unitCreated,
  unitUpdated,
  unitStatusChanged,
  unitArchived,
  photoUploaded,
  jobCreated,
  jobConfirmed,
  jobDeclined,
  jobAssigned,
  jobStarted,
  driverEnRoute,
  driverArrived,
  jobCollected,
  jobCompleted,
  jobCancelled,
  clientSignOff,
  unitReceived,
  subscriptionCreated,
  subscriptionUpdated,
  subscriptionCancelled,
  adminImpersonated,
  issueReported,
  issueUpdated,
  shiftStarted,
  shiftEnded,
  quoteAccepted,
  priceListUpdated,
  userRoleChanged,
  settingsUpdated,
  invoiceIssued,
  invoicePaid,
  invoiceVoided,
  vehicleAdded,
  vehicleUpdated,
  vehicleRetired,
  accountClosureRequested,
  accountClosureCancelled,
  accountClosed,
  accountRecordsPurged,
}

enum PaymentStatus { paid, open, voided, uncollectible }

/// Also written by Cloud Functions (functions/src/constants.js — keep the
/// names in sync).
enum NotificationType {
  bookingReceived,
  bookingConfirmed,
  bookingDeclined,
  jobScheduled,
  jobAssigned,
  jobStarted,
  driverEnRoute,
  driverArrived,
  jobCompleted,
  jobCancelled,
  pickupConfirmed,
  unitsReceived,
  suppliesDelivered,
  deliveryCompleted,
  deliveryRequested,
  invoiceReady,
  invoicePaid,
  storageThreshold,
  qrUnlinkedAlert,
  issueReported,
  directMessage,
  systemAlert,
}

enum IssueType {
  vehicleBreakdown,
  cargoDamage,
  deliveryFailed,
  safetyConcern,
  wrongAddress,
  clientUnavailable,
  other,
}

enum IssueStatus { open, inReview, resolved }

enum ShiftStatus { active, onBreak, ended }

enum ScanType { pickup, delivery, audit, lookup }

/// Outcome of a `mail` doc (written by the onMailCreated function).
enum EmailDeliveryState { sending, sent, failed }

/// Where a client's account closure is (functions/src/closure.js):
/// requested → closed (login and contact details gone, records kept) →
/// purged (records removed after the retention period).
enum ClosureStatus { requested, closed, purged }

/// What stops an account closing — mirrors closureBlockers() in
/// functions/src/closure.js.
enum ClosureBlockerKind { itemsHeld, openOrders, unpaidInvoices, unbilledCharges }

/// What a fleet asset is. Trailers carry load but are towed, so they have
/// no driver of their own.
enum VehicleType { car, bakkie, van, truck, trailer }

/// Whether a vehicle or trailer can be dispatched.
enum VehicleStatus { available, maintenance, outOfService }


// ---------------------------------------------------------------- helpers

String _title(String camel) {
  final spaced = camel.replaceAllMapped(
      RegExp('([A-Z])'), (m) => ' ${m[1]}');
  final trimmed = spaced.trim();
  return trimmed.isEmpty
      ? trimmed
      : '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
}

extension UserRoleX on UserRole {
  String get label => _title(name);
}

extension StorageStatusX on StorageStatus {
  String get label => _title(name);

  /// Whether a unit in this status is charged for. Billing runs from
  /// collection until it is back with the client: anything we are holding
  /// or moving on the client's behalf.
  bool get isBillable => switch (this) {
        StorageStatus.inTransit ||
        StorageStatus.inStorage ||
        StorageStatus.pendingDelivery =>
          true,
        _ => false,
      };

  Color get chipBgColour => switch (this) {
        StorageStatus.inStorage ||
        StorageStatus.delivered =>
          AppColors.statusSuccessBg,
        StorageStatus.inTransit ||
        StorageStatus.pendingDelivery =>
          AppColors.statusWarningBg,
        StorageStatus.pendingPickup => AppColors.statusPendingBg,
        StorageStatus.cancelled ||
        StorageStatus.archived =>
          AppColors.statusErrorBg,
      };

  Color get chipTextColour => switch (this) {
        StorageStatus.inStorage ||
        StorageStatus.delivered =>
          AppColors.statusSuccess,
        StorageStatus.inTransit ||
        StorageStatus.pendingDelivery =>
          AppColors.statusWarning,
        StorageStatus.pendingPickup => AppColors.statusPending,
        StorageStatus.cancelled ||
        StorageStatus.archived =>
          AppColors.statusError,
      };

  /// Whether [next] is a permitted transition from this status (doc 04).
  bool canTransitionTo(StorageStatus next) {
    if (next == StorageStatus.cancelled) return true; // admin only, any → cancelled
    if (next == StorageStatus.archived) {
      return this == StorageStatus.delivered || this == StorageStatus.cancelled;
    }
    return switch (this) {
      StorageStatus.pendingPickup => next == StorageStatus.inTransit,
      StorageStatus.inTransit =>
        next == StorageStatus.inStorage || next == StorageStatus.delivered,
      StorageStatus.inStorage => next == StorageStatus.pendingDelivery,
      StorageStatus.pendingDelivery => next == StorageStatus.inTransit,
      _ => false,
    };
  }
}

extension JobStatusX on JobStatus {
  String get label => switch (this) {
        JobStatus.pendingConfirmation => 'Awaiting Confirmation',
        JobStatus.collected => 'Collected',
        _ => _title(name),
      };

  /// Still to happen or happening — not yet finished or cancelled.
  bool get isOpen => this != JobStatus.completed && this != JobStatus.cancelled;

  /// Confirmed by ops but not started — can still be (re)assigned.
  bool get isDispatchable =>
      this == JobStatus.scheduled || this == JobStatus.assigned;

  Color get chipBgColour => switch (this) {
        JobStatus.completed => AppColors.statusSuccessBg,
        JobStatus.inProgress || JobStatus.collected => AppColors.statusWarningBg,
        JobStatus.pendingConfirmation => AppColors.statusPastDueBg,
        JobStatus.scheduled ||
        JobStatus.assigned =>
          AppColors.statusPendingBg,
        JobStatus.cancelled => AppColors.statusErrorBg,
      };

  Color get chipTextColour => switch (this) {
        JobStatus.completed => AppColors.statusSuccess,
        JobStatus.inProgress || JobStatus.collected => AppColors.statusWarning,
        JobStatus.pendingConfirmation => AppColors.statusPastDue,
        JobStatus.scheduled || JobStatus.assigned => AppColors.statusPending,
        JobStatus.cancelled => AppColors.statusError,
      };
}

extension JobTypeX on JobType {
  String get label => switch (this) {
        JobType.pickup => 'Pickup',
        JobType.delivery => 'Delivery',
        JobType.supplyDrop => 'Supply Drop-off',
      };
}

extension UnitConditionX on UnitCondition {
  String get label => switch (this) {
        UnitCondition.good => 'Good',
        UnitCondition.damaged => 'Damaged',
      };
}

extension UnitTypeX on UnitType {
  String get label => switch (this) {
        UnitType.closed => 'Closed Box',
        UnitType.open => 'Open Box',
      };
}

extension SubscriptionStatusX on SubscriptionStatus {
  String get label => _title(name);
}

/// The hours behind each window are an admin setting — show them with
/// `BusinessSettings.windowLabel` (via `businessSettingsProvider`).
extension VehicleTypeX on VehicleType {
  String get label => switch (this) {
        VehicleType.car => 'Car',
        VehicleType.bakkie => 'Bakkie',
        VehicleType.van => 'Van',
        VehicleType.truck => 'Truck',
        VehicleType.trailer => 'Trailer',
      };
}

extension VehicleStatusX on VehicleStatus {
  String get label => switch (this) {
        VehicleStatus.available => 'Available',
        VehicleStatus.maintenance => 'In maintenance',
        VehicleStatus.outOfService => 'Out of service',
      };
}

extension TimeWindowX on TimeWindow {
  String get title => _title(name);
}

extension IssueTypeX on IssueType {
  String get label => _title(name);
}

extension IssueStatusX on IssueStatus {
  String get label => switch (this) {
        IssueStatus.open => 'Open',
        IssueStatus.inReview => 'In Review',
        IssueStatus.resolved => 'Resolved',
      };
}





extension ShiftStatusX on ShiftStatus {
  String get label => switch (this) {
        ShiftStatus.active => 'Active',
        ShiftStatus.onBreak => 'On Break',
        ShiftStatus.ended => 'Ended',
      };
}
