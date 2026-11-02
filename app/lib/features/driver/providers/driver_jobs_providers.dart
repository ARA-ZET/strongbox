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

/// The current driver's jobs. Day-split is done client-side so the query
/// stays on a single-field index (no composite index needed).
@riverpod
Stream<List<Job>> driverAllJobs(Ref ref) {
  final uid = ref.watch(currentUserIdProvider);
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

/// Open jobs scheduled before today — still to finish.
@riverpod
List<Job> driverOverdueJobs(Ref ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final jobs = ref.watch(driverAllJobsProvider).valueOrNull ?? const [];
  return jobs.where((j) {
    final d = j.scheduledDate;
    return d != null && d.isBefore(start) && j.status.isOpen;
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

/// What a scan does at the job's current step (doc 20/21).
enum ScanStep {
  /// Pickup at the client: unit onto the truck.
  collect,

  /// Pickup at the facility: unit into storage at a bay.
  receive,

  /// Delivery at the facility: unit out of storage onto the truck.
  load,

  /// Delivery at the door: unit handed to the client.
  handOver;

  String get title => switch (this) {
        ScanStep.collect => 'Scan to collect',
        ScanStep.receive => 'Scan into storage',
        ScanStep.load => 'Scan out of storage',
        ScanStep.handOver => 'Scan at handover',
      };

  /// Units already done for this step.
  List<String> doneOn(Job job) => switch (this) {
        ScanStep.collect || ScanStep.load => job.scannedUnitIds,
        ScanStep.receive => job.receivedUnitIds,
        ScanStep.handOver => job.handedOverUnitIds,
      };
}

/// The scan step [job] is at, or null when nothing is to be scanned now.
ScanStep? scanStepFor(Job job) => switch ((job.type, job.status)) {
      (JobType.pickup, JobStatus.inProgress) =>
        job.arrivedAt != null && !job.allUnitsScanned ? ScanStep.collect : null,
      (JobType.pickup, JobStatus.collected) => ScanStep.receive,
      (JobType.delivery, JobStatus.inProgress) => job.departedAt == null
          ? (job.allUnitsScanned ? null : ScanStep.load)
          : (job.arrivedAt != null && !job.allUnitsHandedOver
              ? ScanStep.handOver
              : null),
      _ => null,
    };

/// Driver-side writes: start, check-ins, scans, photos, sign off.
@Riverpod(keepAlive: true)
class DriverJobActions extends _$DriverJobActions {
  @override
  FutureOr<void> build() {}

  String get _tenantId => ref.read(currentTenantIdProvider);
  String get _actorId => ref.read(currentActorIdProvider);

  Future<void> _run(Future<void> Function() op) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(op);
    state.throwIfError();
  }

  Future<void> startJob(Job job) => _run(() =>
      ref.read(jobRepositoryProvider).startJob(job, actorId: _actorId));

  Future<void> markDeparted(Job job) => _run(() =>
      ref.read(jobRepositoryProvider).markDeparted(job, actorId: _actorId));

  Future<void> markArrived(Job job) => _run(() =>
      ref.read(jobRepositoryProvider).markArrived(job, actorId: _actorId));

  /// Records a scanned [unitId] for [step] on [job] (re-read so the
  /// manifest and step are current).
  Future<void> confirmUnit(String jobId, String unitId,
      {required ScanStep step, String? bay}) async {
    final repo = ref.read(jobRepositoryProvider);
    final job = await repo.getJob(jobId);
    if (job == null) throw StateError('Job not found');
    await switch (step) {
      ScanStep.collect => repo.collectUnit(job, unitId, actorId: _actorId),
      ScanStep.receive =>
        repo.receiveUnit(job, unitId, actorId: _actorId, bay: bay),
      ScanStep.load => repo.loadUnit(job, unitId, actorId: _actorId),
      ScanStep.handOver => repo.handOverUnit(job, unitId, actorId: _actorId),
    };
  }

  /// Uploads a capture photo for [jobId] — on the unit's record too when
  /// [unitId] is given, with the condition the driver noted.
  Future<void> uploadCapturePhoto(String jobId, String? unitId, Uint8List bytes,
      {UnitCondition? condition}) async {
    final name = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final onUnit = unitId != null && unitId.isNotEmpty;
    final photoId = await ref.read(photoRepositoryProvider).upload(
          tenantId: _tenantId,
          bytes: bytes,
          type: PhotoType.driverCapture,
          entityType: onUnit ? 'storageUnit' : 'job',
          entityId: onUnit ? unitId : jobId,
          jobId: jobId,
          storagePath: StoragePaths.jobPhoto(_tenantId, jobId, name),
          uploadedBy: _actorId,
        );
    final jobs = ref.read(jobRepositoryProvider);
    await jobs.addDriverPhoto(jobId, photoId);
    if (onUnit) {
      await ref.read(storageUnitRepositoryProvider).addPhotoId(unitId, photoId);
      if (condition != null) await jobs.setUnitCondition(unitId, condition);
    }
  }

  Future<void> completeJob(Job job, Uint8List signaturePng,
          {String? recipientName}) =>
      _run(() async {
        final url = await ref.read(photoRepositoryProvider).uploadSignature(
              png: signaturePng,
              storagePath: StoragePaths.jobSignature(_tenantId, job.id),
            );
        await ref.read(jobRepositoryProvider).signOff(job, url,
            actorId: _actorId, recipientName: recipientName);
      });
}
