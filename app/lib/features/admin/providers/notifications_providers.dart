import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/models/app_notification.dart';
import '../../../core/models/audit_event.dart';
import '../../../core/providers/tenant_provider.dart';
import '../../../repositories/repository_providers.dart';

part 'notifications_providers.g.dart';

/// Alert-centre category derived from an audit action.
String categoryOf(AuditEvent event) => switch (event.action) {
      AuditAction.jobCancelled ||
      AuditAction.issueReported =>
        'critical',
      AuditAction.subscriptionCreated ||
      AuditAction.subscriptionUpdated ||
      AuditAction.subscriptionCancelled ||
      AuditAction.adminImpersonated ||
      AuditAction.priceListUpdated ||
      AuditAction.userRoleChanged ||
      AuditAction.settingsUpdated ||
      AuditAction.qrGenerated ||
      AuditAction.invoiceIssued ||
      AuditAction.invoicePaid ||
      AuditAction.invoiceVoided =>
        'system',
      _ => 'operational',
    };

/// Human-readable title for an audit event.
String auditTitle(AuditEvent event) => switch (event.action) {
      AuditAction.unitCreated => 'New unit registered',
      AuditAction.unitStatusChanged => 'Unit status changed',
      AuditAction.unitArchived => 'Unit archived',
      AuditAction.jobCreated => 'New job created',
      AuditAction.jobAssigned => 'Job assigned to driver',
      AuditAction.jobStarted => 'Job started',
      AuditAction.jobCompleted => 'Job completed',
      AuditAction.jobCancelled => 'Job cancelled',
      AuditAction.clientSignOff => 'Client sign-off received',
      AuditAction.qrGenerated => 'QR batch generated',
      AuditAction.qrLinked => 'QR code linked',
      AuditAction.qrScanned => 'QR code scanned',
      AuditAction.issueReported => 'Issue reported',
      AuditAction.shiftStarted => 'Driver shift started',
      AuditAction.shiftEnded => 'Driver shift ended',
      AuditAction.priceListUpdated => 'Price list updated',
      AuditAction.userRoleChanged => 'Team role changed',
      AuditAction.settingsUpdated => 'Business settings updated',
      AuditAction.invoiceIssued => 'Invoice issued',
      AuditAction.invoicePaid => 'Invoice marked paid',
      AuditAction.invoiceVoided => 'Invoice voided',
      AuditAction.subscriptionUpdated => 'Billing status changed',
      AuditAction.vehicleAdded => 'Vehicle added to fleet',
      AuditAction.vehicleUpdated => 'Vehicle updated',
      AuditAction.vehicleRetired => 'Vehicle retired',
      _ => 'System event',
    };

/// Read-only alert feed (audit events; see NotificationRepository note).
@riverpod
Stream<List<AuditEvent>> notificationFeed(Ref ref) {
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref.watch(notificationRepositoryProvider).watchFeed(tenantId);
}

/// Unread alerts for all admins — delivery requests awaiting a driver,
/// invoice runs, unused QR labels (written by Cloud Functions).
@riverpod
Stream<List<AppNotification>> adminAlerts(Ref ref) {
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref.watch(notificationRepositoryProvider).watchAdminAlerts(tenantId);
}

/// Selected category: all | critical | operational | system.
@riverpod
class NotificationCategoryFilter extends _$NotificationCategoryFilter {
  @override
  String build() => 'all';
  void set(String value) => state = value;
}

/// Oldest-first toggle.
@riverpod
class NotificationOldestFirst extends _$NotificationOldestFirst {
  @override
  bool build() => false;
  void toggle(bool oldest) => state = oldest;
}
