import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/models/audit_event.dart';
import '../../../core/providers/tenant_provider.dart';
import '../../../repositories/repository_providers.dart';
import 'inventory_providers.dart';
import 'jobs_providers.dart';

part 'dashboard_providers.g.dart';

/// Total unlinked QR codes across all batches (dashboard banner).
@riverpod
Stream<int> unlinkedQrCount(Ref ref) {
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref.watch(qrRepositoryProvider).watchUnlinkedCount(tenantId);
}

/// Live count of units currently in storage.
@riverpod
int unitsInStorageCount(Ref ref) {
  final units = ref.watch(allUnitsProvider).valueOrNull ?? const [];
  return units.where((u) => u.status == StorageStatus.inStorage).length;
}

/// Today's jobs still in flight.
@riverpod
int activeJobsTodayCount(Ref ref) => ref
    .watch(todaysJobsProvider)
    .where((j) =>
        j.status != JobStatus.completed && j.status != JobStatus.cancelled)
    .length;

/// Scheduled pickups awaiting dispatch.
@riverpod
int pendingPickupsCount(Ref ref) {
  final jobs = ref.watch(allJobsProvider).valueOrNull ?? const [];
  return jobs
      .where((j) => j.type == JobType.pickup && j.status == JobStatus.scheduled)
      .length;
}

/// Scheduled deliveries awaiting dispatch.
@riverpod
int pendingDeliveriesCount(Ref ref) {
  final jobs = ref.watch(allJobsProvider).valueOrNull ?? const [];
  return jobs
      .where(
          (j) => j.type == JobType.delivery && j.status == JobStatus.scheduled)
      .length;
}

/// Ten most recent audit-trail events.
@riverpod
Stream<List<AuditEvent>> recentActivity(Ref ref) {
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref.watch(auditRepositoryProvider).watchAll(tenantId, limit: 10);
}
