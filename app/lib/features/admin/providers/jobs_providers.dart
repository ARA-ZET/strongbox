import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/async_value_ext.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/models/job.dart';
import '../../../core/models/value_objects.dart';
import '../../../core/providers/tenant_provider.dart';
import '../../../repositories/repository_providers.dart';
import '../../auth/providers/auth_provider.dart';
import 'clients_providers.dart';
import '../../../core/utils/public_ref.dart';

part 'jobs_providers.g.dart';

/// All non-deleted jobs, newest scheduled first.
@riverpod
Stream<List<Job>> allJobs(Ref ref) {
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref.watch(jobRepositoryProvider).watchAll(tenantId: tenantId);
}

/// Jobs scheduled for today.
@riverpod
List<Job> todaysJobs(Ref ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 1));
  final jobs = ref.watch(allJobsProvider).valueOrNull ?? const [];
  return jobs.where((j) {
    final d = j.scheduledDate;
    return d != null && !d.isBefore(start) && d.isBefore(end);
  }).toList()
    ..sort((a, b) => (a.scheduledDate ?? DateTime(0))
        .compareTo(b.scheduledDate ?? DateTime(0)));
}

/// Client bookings and delivery requests waiting for an admin, oldest
/// first. A Path A supply drop-off is confirmed with its pickup, so only
/// the pickup is listed.
@riverpod
List<Job> jobsToConfirm(Ref ref) {
  final jobs = ref.watch(allJobsProvider).valueOrNull ?? const [];
  return jobs
      .where((j) =>
          j.status == JobStatus.pendingConfirmation &&
          !(j.type == JobType.supplyDrop && j.linkedJobId != null))
      .toList()
    ..sort((a, b) => (a.createdAt ?? DateTime(0))
        .compareTo(b.createdAt ?? DateTime(0)));
}

/// Pickups collected and on their way to (or at) the facility.
@riverpod
List<Job> jobsToReceive(Ref ref) {
  final jobs = ref.watch(allJobsProvider).valueOrNull ?? const [];
  return jobs.where((j) => j.status == JobStatus.collected).toList();
}

/// Jobs-list filter state.
class JobsFilter extends Equatable {
  const JobsFilter({
    this.type = 'all',
    this.status = 'all',
    this.driverId = 'all',
    this.query = '',
    this.dateRange,
  });

  final String type;
  final String status;
  final String driverId;
  final String query;
  final DateTimeRange? dateRange;

  static const _unset = Object();

  JobsFilter copyWith({
    String? type,
    String? status,
    String? driverId,
    String? query,
    Object? dateRange = _unset,
  }) =>
      JobsFilter(
        type: type ?? this.type,
        status: status ?? this.status,
        driverId: driverId ?? this.driverId,
        query: query ?? this.query,
        dateRange: identical(dateRange, _unset)
            ? this.dateRange
            : dateRange as DateTimeRange?,
      );

  @override
  List<Object?> get props => [type, status, driverId, query, dateRange];
}

@riverpod
class JobsFilterState extends _$JobsFilterState {
  @override
  JobsFilter build() => const JobsFilter();
  void update(JobsFilter filter) => state = filter;
}

/// Jobs after all filters (client-side).
@riverpod
List<Job> filteredJobs(Ref ref) {
  final filter = ref.watch(jobsFilterStateProvider);
  final query = filter.query.trim().toLowerCase();
  final jobs = ref.watch(allJobsProvider).valueOrNull ?? const [];

  return jobs.where((job) {
    if (filter.type != 'all' && job.type.name != filter.type) return false;
    if (filter.status != 'all' && job.status.name != filter.status) {
      return false;
    }
    if (filter.driverId != 'all' && job.driverId != filter.driverId) {
      return false;
    }
    final range = filter.dateRange;
    final scheduled = job.scheduledDate;
    if (range != null && scheduled != null) {
      final day = DateTime(scheduled.year, scheduled.month, scheduled.day);
      if (day.isBefore(range.start) || day.isAfter(range.end)) return false;
    }
    if (query.isNotEmpty && !jobRef(job).toLowerCase().contains(query)) {
      return false;
    }
    return true;
  }).toList();
}

/// Draft state for the 4-step Create New Job wizard.
class NewJobData extends Equatable {
  const NewJobData({
    this.type,
    this.clientId,
    this.unitIds = const {},
    this.scheduledDate,
    this.timeWindow = TimeWindow.morning,
    this.driverId,
    this.notes = '',
    this.accessNotes = '',
  });

  final JobType? type;
  final String? clientId;
  final Set<String> unitIds;
  final DateTime? scheduledDate;
  final TimeWindow timeWindow;
  final String? driverId;
  final String notes;
  final String accessNotes;

  static const _unset = Object();

  NewJobData copyWith({
    JobType? type,
    Object? clientId = _unset,
    Set<String>? unitIds,
    Object? scheduledDate = _unset,
    TimeWindow? timeWindow,
    Object? driverId = _unset,
    String? notes,
    String? accessNotes,
  }) =>
      NewJobData(
        type: type ?? this.type,
        clientId:
            identical(clientId, _unset) ? this.clientId : clientId as String?,
        unitIds: unitIds ?? this.unitIds,
        scheduledDate: identical(scheduledDate, _unset)
            ? this.scheduledDate
            : scheduledDate as DateTime?,
        timeWindow: timeWindow ?? this.timeWindow,
        driverId:
            identical(driverId, _unset) ? this.driverId : driverId as String?,
        notes: notes ?? this.notes,
        accessNotes: accessNotes ?? this.accessNotes,
      );

  @override
  List<Object?> get props => [
        type,
        clientId,
        unitIds,
        scheduledDate,
        timeWindow,
        driverId,
        notes,
        accessNotes,
      ];
}

@riverpod
class NewJobDraft extends _$NewJobDraft {
  @override
  NewJobData build() => const NewJobData();

  void setType(JobType type) => state = state.copyWith(type: type);

  void setClient(String? clientId) {
    if (clientId != state.clientId) {
      state = state.copyWith(clientId: clientId, unitIds: {});
    }
  }

  void toggleUnit(String unitId) {
    final next = <String>{...state.unitIds};
    next.contains(unitId) ? next.remove(unitId) : next.add(unitId);
    state = state.copyWith(unitIds: next);
  }

  void setUnits(Set<String> unitIds) =>
      state = state.copyWith(unitIds: unitIds);

  void setSchedule({DateTime? date, TimeWindow? timeWindow, String? driverId}) =>
      state = state.copyWith(
        scheduledDate: date ?? state.scheduledDate,
        timeWindow: timeWindow,
        driverId: driverId ?? state.driverId,
      );

  void setNotes(String notes) => state = state.copyWith(notes: notes);

  void setAccessNotes(String value) =>
      state = state.copyWith(accessNotes: value);

  void reset() => state = const NewJobData();
}

/// Firestore writes for jobs.
@Riverpod(keepAlive: true)
class JobMutations extends _$JobMutations {
  @override
  FutureOr<void> build() {}

  /// Creates an ops job — confirmed already, so it skips
  /// pendingConfirmation — at the client's saved address.
  Future<void> submit(NewJobData data) async {
    final tenantId = ref.read(currentTenantIdProvider);
    final actorId = ref.read(currentActorIdProvider);
    final client = (ref.read(clientsProvider).valueOrNull ?? const [])
        .where((c) => c.id == data.clientId)
        .firstOrNull;
    final job = Job(
      id: '',
      tenantId: tenantId,
      type: data.type ?? JobType.pickup,
      clientId: data.clientId ?? '',
      driverId: data.driverId,
      driverName: _driverName(data.driverId),
      status: data.driverId != null ? JobStatus.assigned : JobStatus.scheduled,
      scheduledDate: data.scheduledDate ?? DateTime.now(),
      timeWindow: data.timeWindow,
      address: client?.address ?? const Address(),
      storageUnitIds: data.unitIds.toList(),
      notes: data.notes,
      accessNotes: data.accessNotes.trim().isEmpty ? null : data.accessNotes,
    );
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(jobRepositoryProvider).create(job, actorId: actorId));
    state.throwIfError();
  }

  Future<void> _run(Future<void> Function() op) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(op);
    state.throwIfError();
  }

  String get _actorId => ref.read(currentActorIdProvider);

  Future<void> assignDriver(Job job, String driverId,
          {String? fleetVehicleId}) =>
      _run(() => ref.read(jobRepositoryProvider).assignDriver(job, driverId,
          actorId: _actorId,
          driverName: _driverName(driverId),
          fleetVehicleId: fleetVehicleId));

  String? _driverName(String? driverId) =>
      driverId == null ? null : ref.read(driverNamesProvider)[driverId];

  /// Accepts a client booking / request (and its paired supply drop-off),
  /// optionally moving it and dispatching a driver and vehicle.
  Future<void> confirm(
    Job job, {
    DateTime? scheduledDate,
    TimeWindow? timeWindow,
    String? driverId,
    String? fleetVehicleId,
  }) =>
      _run(() => ref.read(jobRepositoryProvider).confirm(job,
          actorId: _actorId,
          scheduledDate: scheduledDate,
          timeWindow: timeWindow,
          driverId: driverId,
          driverName: _driverName(driverId),
          fleetVehicleId: fleetVehicleId));

  Future<void> decline(Job job, String reason) => _run(() => ref
      .read(jobRepositoryProvider)
      .decline(job, actorId: _actorId, reason: reason));

  Future<void> cancelJob(Job job, {String? reason}) => _run(() => ref
      .read(jobRepositoryProvider)
      .cancel(job, actorId: _actorId, reason: reason));

  /// Fallback receiving: ops scans or ticks units into storage at [bay]
  /// when the driver couldn't.
  Future<void> receiveUnits(Job job, List<String> unitIds, {String? bay}) =>
      _run(() async {
        final repo = ref.read(jobRepositoryProvider);
        for (final id in unitIds) {
          final current = await repo.getJob(job.id) ?? job;
          await repo.receiveUnit(current, id,
              actorId: _actorId, bay: bay, role: UserRole.admin);
        }
      });
}
