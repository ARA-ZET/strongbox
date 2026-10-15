// ignore_for_file: use_null_aware_elements
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/async_value_ext.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/models/app_user.dart';
import '../../../core/models/job.dart';
import '../../../core/providers/tenant_provider.dart';
import '../../../repositories/repository_providers.dart';
import 'jobs_providers.dart';

part 'fleet_providers.g.dart';

/// One driver's user doc, live.
@riverpod
Stream<AppUser?> driverById(Ref ref, String driverId) =>
    ref.watch(userRepositoryProvider).watchUser(driverId);

/// driverId → their current in-flight job (assigned or inProgress).
@riverpod
Map<String, Job> activeJobsByDriver(Ref ref) {
  final jobs = ref.watch(allJobsProvider).valueOrNull ?? const [];
  final map = <String, Job>{};
  for (final job in jobs) {
    final driverId = job.driverId;
    if (driverId == null) continue;
    if (job.status == JobStatus.assigned ||
        job.status == JobStatus.inProgress) {
      map.putIfAbsent(driverId, () => job);
    }
  }
  return map;
}

/// A driver's most recent jobs for the detail history table.
@riverpod
List<Job> driverRecentJobs(Ref ref, String driverId) {
  final jobs = ref.watch(allJobsProvider).valueOrNull ?? const [];
  return jobs.where((j) => j.driverId == driverId).take(5).toList();
}

/// Count of jobs this driver has completed.
@riverpod
int driverCompletedCount(Ref ref, String driverId) {
  final jobs = ref.watch(allJobsProvider).valueOrNull ?? const [];
  return jobs
      .where((j) => j.driverId == driverId && j.status == JobStatus.completed)
      .length;
}

/// Create/update actions on driver records.
@riverpod
class DriverMutations extends _$DriverMutations {
  @override
  FutureOr<void> build() {}

  /// Invites a driver: creates their login and profile and emails a
  /// password-setup link, which is also returned to share directly.
  Future<({String uid, String link})> addDriver({
    required String name,
    required String email,
    required String phone,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => ref
        .read(driverInviteRepositoryProvider)
        .invite(name: name, email: email, phone: phone));
    state = result;
    return result.requireValue;
  }

  /// A fresh setup link for a driver who has not signed in yet.
  Future<String> resendInvite(String driverId) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
        () => ref.read(driverInviteRepositoryProvider).resend(driverId));
    state = result;
    return result.requireValue;
  }

  Future<void> updateDriver(String driverId,
      {String? name, String? phone}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(userRepositoryProvider).updateUser(driverId, {
              if (name != null) 'name': name,
              if (phone != null) 'phone': phone,
            }));
    state.throwIfError();
  }

  /// Sends [driver] a message from dispatch — shown in their inbox and
  /// pushed to their phone by the `onNotificationCreated` Cloud Function.
  Future<void> sendMessage(AppUser driver, String message) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(notificationRepositoryProvider).create(
              tenantId: ref.read(currentTenantIdProvider),
              type: NotificationType.directMessage,
              title: 'Message from dispatch',
              body: message.trim(),
              userId: driver.id,
            ));
    state.throwIfError();
  }
}
