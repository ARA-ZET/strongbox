import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/models/job.dart';
import '../../../core/providers/tenant_provider.dart';
import '../../../repositories/repository_providers.dart';
import '../../auth/providers/auth_provider.dart';

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
    if (query.isNotEmpty && !job.id.toLowerCase().contains(query)) {
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
  });

  final JobType? type;
  final String? clientId;
  final Set<String> unitIds;
  final DateTime? scheduledDate;
  final TimeWindow timeWindow;
  final String? driverId;
  final String notes;

  static const _unset = Object();

  NewJobData copyWith({
    JobType? type,
    Object? clientId = _unset,
    Set<String>? unitIds,
    Object? scheduledDate = _unset,
    TimeWindow? timeWindow,
    Object? driverId = _unset,
    String? notes,
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
      );

  @override
  List<Object?> get props =>
      [type, clientId, unitIds, scheduledDate, timeWindow, driverId, notes];
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

  void reset() => state = const NewJobData();
}

/// Firestore writes for jobs.
@riverpod
class JobMutations extends _$JobMutations {
  @override
  FutureOr<void> build() {}

  Future<void> submit(NewJobData data, {bool asDraft = false}) async {
    final tenantId = ref.read(currentTenantIdProvider);
    final actorId = ref.read(currentActorIdProvider);
    final job = Job(
      id: '',
      tenantId: tenantId,
      type: data.type ?? JobType.pickup,
      clientId: data.clientId ?? '',
      driverId: data.driverId,
      status: data.driverId != null ? JobStatus.assigned : JobStatus.scheduled,
      scheduledDate: data.scheduledDate ?? DateTime.now(),
      timeWindow: data.timeWindow,
      storageUnitIds: data.unitIds.toList(),
      notes: data.notes,
    );
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(jobRepositoryProvider)
        .create(job, actorId: actorId, moveUnits: !asDraft));
  }
}
