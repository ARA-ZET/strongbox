import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/async_value_ext.dart';
import '../../../core/constants/storage_paths.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/models/job.dart';
import '../../../core/models/storage_unit.dart';
import '../../../core/providers/tenant_provider.dart';
import '../../../repositories/repository_providers.dart';
import '../../auth/providers/auth_provider.dart';

part 'driver_jobs_providers.g.dart';

/// The signed-in driver's jobs. Day-split is done client-side so the query
/// stays on a single-field index (no composite index needed).
@riverpod
Stream<List<Job>> driverAllJobs(Ref ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(const []);
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref
      .watch(jobRepositoryProvider)
      .watchAll(tenantId: tenantId, driverId: uid);
}

@riverpod
List<Job> driverTodayJobs(Ref ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 1));
  final jobs = ref.watch(driverAllJobsProvider).valueOrNull ?? const [];
  return jobs.where((j) {
    final d = j.scheduledDate;
    return d != null && !d.isBefore(start) && d.isBefore(end);
  }).toList()
    ..sort((a, b) => (a.scheduledDate ?? DateTime(0))
        .compareTo(b.scheduledDate ?? DateTime(0)));
}

@riverpod
List<Job> driverUpcomingJobs(Ref ref) {
  final now = DateTime.now();
  final end = DateTime(now.year, now.month, now.day)
      .add(const Duration(days: 1));
  final jobs = ref.watch(driverAllJobsProvider).valueOrNull ?? const [];
  return jobs.where((j) {
    final d = j.scheduledDate;
    return d != null && !d.isBefore(end);
  }).toList()
    ..sort((a, b) => (a.scheduledDate ?? DateTime(0))
        .compareTo(b.scheduledDate ?? DateTime(0)));
}

/// One job, live.
@riverpod
Stream<Job?> driverJob(Ref ref, String jobId) =>
    ref.watch(jobRepositoryProvider).watchJob(jobId);

/// The units on a job's manifest.
@riverpod
Future<List<StorageUnit>> jobManifest(Ref ref, String jobId) async {
  final job = await ref.watch(driverJobProvider(jobId).future);
  if (job == null) return const [];
  return ref.read(storageUnitRepositoryProvider).getByIds(job.storageUnitIds);
}

/// Look up a unit by scanned QR value.
@riverpod
Future<StorageUnit?> unitByScan(Ref ref, String code) async {
  final qr = await ref.read(qrRepositoryProvider).resolveCode(code);
  final unitId = qr?.storageUnitId;
  final units = ref.read(storageUnitRepositoryProvider);
  if (unitId != null) return units.getUnit(unitId);
  // Units registered before their code was written to qrCodes.
  return units.getByQrCode(ref.read(currentTenantIdProvider), code);
}

/// Units the driver has scanned today across today's jobs.
@riverpod
int driverBoxesHandledToday(Ref ref) => ref
    .watch(driverTodayJobsProvider)
    .fold(0, (acc, j) => acc + j.scannedUnitIds.length);

/// Jobs the driver completed today.
@riverpod
int driverJobsCompletedToday(Ref ref) => ref
    .watch(driverTodayJobsProvider)
    .where((j) => j.status == JobStatus.completed)
    .length;

/// Driver-side writes: start job, confirm unit, capture photo, sign off.
@riverpod
class DriverJobActions extends _$DriverJobActions {
  @override
  FutureOr<void> build() {}

  String get _tenantId => ref.read(currentTenantIdProvider);
  String get _actorId => ref.read(currentActorIdProvider);

  Future<void> startJob(Job job) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(jobRepositoryProvider)
        .updateStatus(job, JobStatus.inProgress, actorId: _actorId));
    state.throwIfError();
  }

  Future<void> confirmUnit(String jobId, String unitId) async {
    await ref
        .read(jobRepositoryProvider)
        .markUnitScanned(jobId, unitId, actorId: _actorId);
  }

  Future<void> uploadCapturePhoto(
      String jobId, String unitId, Uint8List bytes) async {
    final name = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final photoId = await ref.read(photoRepositoryProvider).upload(
          tenantId: _tenantId,
          bytes: bytes,
          type: PhotoType.driverCapture,
          entityType: 'job',
          entityId: jobId,
          jobId: jobId,
          storagePath: StoragePaths.jobPhoto(_tenantId, jobId, name),
          uploadedBy: _actorId,
        );
    await ref.read(jobRepositoryProvider).addDriverPhoto(jobId, photoId);
  }

  Future<void> completeJob(Job job, Uint8List signaturePng) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final url = await ref.read(photoRepositoryProvider).uploadSignature(
            png: signaturePng,
            storagePath: StoragePaths.jobSignature(_tenantId, job.id),
          );
      await ref
          .read(jobRepositoryProvider)
          .completeSignOff(job, url, actorId: _actorId);
    });
    state.throwIfError();
  }
}
