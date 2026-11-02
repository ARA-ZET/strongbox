// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jobs_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allJobsHash() => r'31d0fc6e9e8d3efde1b83b44a7bc131d0bb347d4';

/// All non-deleted jobs, newest scheduled first.
///
/// Copied from [allJobs].
@ProviderFor(allJobs)
final allJobsProvider = AutoDisposeStreamProvider<List<Job>>.internal(
  allJobs,
  name: r'allJobsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allJobsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllJobsRef = AutoDisposeStreamProviderRef<List<Job>>;
String _$todaysJobsHash() => r'45af57072b80fe737d1ff9ae918b1ff1cacf8f09';

/// Jobs scheduled for today.
///
/// Copied from [todaysJobs].
@ProviderFor(todaysJobs)
final todaysJobsProvider = AutoDisposeProvider<List<Job>>.internal(
  todaysJobs,
  name: r'todaysJobsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$todaysJobsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TodaysJobsRef = AutoDisposeProviderRef<List<Job>>;
String _$jobsToConfirmHash() => r'7e7cd776a81cc666f648deece66c266109b85388';

/// Client bookings and delivery requests waiting for an admin, oldest
/// first. A Path A supply drop-off is confirmed with its pickup, so only
/// the pickup is listed.
///
/// Copied from [jobsToConfirm].
@ProviderFor(jobsToConfirm)
final jobsToConfirmProvider = AutoDisposeProvider<List<Job>>.internal(
  jobsToConfirm,
  name: r'jobsToConfirmProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$jobsToConfirmHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef JobsToConfirmRef = AutoDisposeProviderRef<List<Job>>;
String _$jobsToReceiveHash() => r'4d4100c52ab2c3c03770bafcef1e13c093836b1f';

/// Pickups collected and on their way to (or at) the facility.
///
/// Copied from [jobsToReceive].
@ProviderFor(jobsToReceive)
final jobsToReceiveProvider = AutoDisposeProvider<List<Job>>.internal(
  jobsToReceive,
  name: r'jobsToReceiveProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$jobsToReceiveHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef JobsToReceiveRef = AutoDisposeProviderRef<List<Job>>;
String _$filteredJobsHash() => r'e6053a158e893b7aa81b2763656f75f881a87a7a';

/// Jobs after all filters (client-side).
///
/// Copied from [filteredJobs].
@ProviderFor(filteredJobs)
final filteredJobsProvider = AutoDisposeProvider<List<Job>>.internal(
  filteredJobs,
  name: r'filteredJobsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$filteredJobsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredJobsRef = AutoDisposeProviderRef<List<Job>>;
String _$jobsFilterStateHash() => r'e9eed055d0de98956bc2e899ec01f6e6c64501b4';

/// See also [JobsFilterState].
@ProviderFor(JobsFilterState)
final jobsFilterStateProvider =
    AutoDisposeNotifierProvider<JobsFilterState, JobsFilter>.internal(
  JobsFilterState.new,
  name: r'jobsFilterStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$jobsFilterStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$JobsFilterState = AutoDisposeNotifier<JobsFilter>;
String _$newJobDraftHash() => r'51f5d3364b791e65e795bbd088d6bf2a08c4664e';

/// See also [NewJobDraft].
@ProviderFor(NewJobDraft)
final newJobDraftProvider =
    AutoDisposeNotifierProvider<NewJobDraft, NewJobData>.internal(
  NewJobDraft.new,
  name: r'newJobDraftProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$newJobDraftHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NewJobDraft = AutoDisposeNotifier<NewJobData>;
String _$jobMutationsHash() => r'8695c94fe8675f2cb2db44bf59989b43f3d37ae2';

/// Firestore writes for jobs.
///
/// Copied from [JobMutations].
@ProviderFor(JobMutations)
final jobMutationsProvider = AsyncNotifierProvider<JobMutations, void>.internal(
  JobMutations.new,
  name: r'jobMutationsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$jobMutationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$JobMutations = AsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
