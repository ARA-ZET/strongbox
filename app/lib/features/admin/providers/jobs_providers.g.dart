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
String _$filteredJobsHash() => r'5c8c4a92ade2329c3c4f79a819f08f03b7f97936';

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
String _$newJobDraftHash() => r'f4845db9dadc1eec689893fe2a1bbbad9e86c35f';

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
String _$jobMutationsHash() => r'3c4687ae16a4a307e79992a1b3c65c82583f4718';

/// Firestore writes for jobs.
///
/// Copied from [JobMutations].
@ProviderFor(JobMutations)
final jobMutationsProvider =
    AutoDisposeAsyncNotifierProvider<JobMutations, void>.internal(
  JobMutations.new,
  name: r'jobMutationsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$jobMutationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$JobMutations = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
