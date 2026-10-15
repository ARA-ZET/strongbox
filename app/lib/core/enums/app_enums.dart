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

enum JobStatus { scheduled, assigned, inProgress, completed, cancelled }

enum JobType { pickup, delivery }

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
  jobAssigned,
  jobStarted,
  jobCompleted,
  jobCancelled,
  clientSignOff,
  subscriptionCreated,
  subscriptionUpdated,
  subscriptionCancelled,
  adminImpersonated,
  issueReported,
  shiftStarted,
  shiftEnded,
  quoteAccepted,
  priceListUpdated,
  userRoleChanged,
  settingsUpdated,
  invoiceIssued,
  invoicePaid,
  invoiceVoided,
}

enum PaymentStatus { paid, open, voided, uncollectible }

/// Also written by Cloud Functions (functions/src/constants.js — keep the
/// names in sync).
enum NotificationType {
  jobScheduled,
  jobAssigned,
  jobStarted,
  jobCompleted,
  jobCancelled,
  pickupConfirmed,
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
  String get label => _title(name);

  Color get chipBgColour => switch (this) {
        JobStatus.completed => AppColors.statusSuccessBg,
        JobStatus.inProgress => AppColors.statusWarningBg,
        JobStatus.scheduled ||
        JobStatus.assigned =>
          AppColors.statusPendingBg,
        JobStatus.cancelled => AppColors.statusErrorBg,
      };

  Color get chipTextColour => switch (this) {
        JobStatus.completed => AppColors.statusSuccess,
        JobStatus.inProgress => AppColors.statusWarning,
        JobStatus.scheduled || JobStatus.assigned => AppColors.statusPending,
        JobStatus.cancelled => AppColors.statusError,
      };
}

extension JobTypeX on JobType {
  String get label => _title(name);
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
extension TimeWindowX on TimeWindow {
  String get title => _title(name);
}

extension IssueTypeX on IssueType {
  String get label => _title(name);
}





extension ShiftStatusX on ShiftStatus {
  String get label => switch (this) {
        ShiftStatus.active => 'Active',
        ShiftStatus.onBreak => 'On Break',
        ShiftStatus.ended => 'Ended',
      };
}
