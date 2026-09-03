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

enum SubscriptionPlan { starter, professional, enterprise }

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
}

enum PaymentStatus { paid, open, voided, uncollectible }

enum NotificationType {
  jobScheduled,
  jobStarted,
  jobCompleted,
  pickupConfirmed,
  deliveryCompleted,
  invoiceReady,
  storageThreshold,
  qrUnlinkedAlert,
  issueReported,
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

/// Storage box tiers offered in the public quote calculator.
enum BoxSize { small, medium, large, xl }

/// Collection vehicle options, priced once-off.
enum VehicleSize { smallVan, mediumVan, largeTruck }

/// Filter tabs on the loose-items step.
enum LooseItemCategory { beds, tables, office, appliances, outdoor, other }

/// Lifecycle of a quote (doc 20). A guest builds a `draft`; accepting it
/// requires an account, which is when it is first written to Firestore.
enum QuoteStatus { draft, accepted, expired, converted, cancelled }

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

extension SubscriptionPlanX on SubscriptionPlan {
  String get label => _title(name);
}

extension TimeWindowX on TimeWindow {
  String get label => switch (this) {
        TimeWindow.morning => 'Morning (08:00–12:00)',
        TimeWindow.afternoon => 'Afternoon (12:00–16:00)',
        TimeWindow.evening => 'Evening (16:00–20:00)',
      };
}

extension IssueTypeX on IssueType {
  String get label => _title(name);
}

extension BoxSizeX on BoxSize {
  String get label => switch (this) {
        BoxSize.small => 'Small',
        BoxSize.medium => 'Medium',
        BoxSize.large => 'Large',
        BoxSize.xl => 'XL',
      };
}

extension VehicleSizeX on VehicleSize {
  String get label => _title(name);
}

extension LooseItemCategoryX on LooseItemCategory {
  String get label => _title(name);
}

extension QuoteStatusX on QuoteStatus {
  String get label => _title(name);

  Color get chipBgColour => switch (this) {
        QuoteStatus.accepted ||
        QuoteStatus.converted =>
          AppColors.statusSuccessBg,
        QuoteStatus.draft => AppColors.statusPendingBg,
        QuoteStatus.expired => AppColors.statusWarningBg,
        QuoteStatus.cancelled => AppColors.statusErrorBg,
      };

  Color get chipTextColour => switch (this) {
        QuoteStatus.accepted || QuoteStatus.converted => AppColors.statusSuccess,
        QuoteStatus.draft => AppColors.statusPending,
        QuoteStatus.expired => AppColors.statusWarning,
        QuoteStatus.cancelled => AppColors.statusError,
      };
}

extension ShiftStatusX on ShiftStatus {
  String get label => switch (this) {
        ShiftStatus.active => 'Active',
        ShiftStatus.onBreak => 'On Break',
        ShiftStatus.ended => 'Ended',
      };
}
