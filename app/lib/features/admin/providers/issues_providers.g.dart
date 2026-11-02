// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issues_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$issueReportsHash() => r'3492ce8ac9e8960653b2c10a2403a12af9e7adaa';

/// Every driver issue report, newest first.
///
/// Copied from [issueReports].
@ProviderFor(issueReports)
final issueReportsProvider =
    AutoDisposeStreamProvider<List<IssueReport>>.internal(
  issueReports,
  name: r'issueReportsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$issueReportsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IssueReportsRef = AutoDisposeStreamProviderRef<List<IssueReport>>;
String _$openIssueCountHash() => r'306b38cbd2620a4c93f0dbbe29e688b8de310dba';

/// Reports not resolved yet — the admin's to-do count.
///
/// Copied from [openIssueCount].
@ProviderFor(openIssueCount)
final openIssueCountProvider = AutoDisposeProvider<int>.internal(
  openIssueCount,
  name: r'openIssueCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$openIssueCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef OpenIssueCountRef = AutoDisposeProviderRef<int>;
String _$issueMutationsHash() => r'c5e6f28d58a033d11ebee44467b21d3d8523a6cb';

/// Ops moves reports through open → in review → resolved.
///
/// Copied from [IssueMutations].
@ProviderFor(IssueMutations)
final issueMutationsProvider =
    AsyncNotifierProvider<IssueMutations, void>.internal(
  IssueMutations.new,
  name: r'issueMutationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$issueMutationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$IssueMutations = AsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
