// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unlinkedQrCountHash() => r'4d941bb57322e906edae224596c6010d087f2c99';

/// Total unlinked QR codes across all batches (dashboard banner).
///
/// Copied from [unlinkedQrCount].
@ProviderFor(unlinkedQrCount)
final unlinkedQrCountProvider = AutoDisposeStreamProvider<int>.internal(
  unlinkedQrCount,
  name: r'unlinkedQrCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unlinkedQrCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UnlinkedQrCountRef = AutoDisposeStreamProviderRef<int>;
String _$unitsInStorageCountHash() =>
    r'a86cf246e747ab690379db33210ee6d72690c843';

/// Live count of units currently in storage.
///
/// Copied from [unitsInStorageCount].
@ProviderFor(unitsInStorageCount)
final unitsInStorageCountProvider = AutoDisposeProvider<int>.internal(
  unitsInStorageCount,
  name: r'unitsInStorageCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unitsInStorageCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UnitsInStorageCountRef = AutoDisposeProviderRef<int>;
String _$activeJobsTodayCountHash() =>
    r'c828b1b4d55e4c8fa02174ab901ab86860dcbe4f';

/// Today's jobs still in flight.
///
/// Copied from [activeJobsTodayCount].
@ProviderFor(activeJobsTodayCount)
final activeJobsTodayCountProvider = AutoDisposeProvider<int>.internal(
  activeJobsTodayCount,
  name: r'activeJobsTodayCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeJobsTodayCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ActiveJobsTodayCountRef = AutoDisposeProviderRef<int>;
String _$pendingPickupsCountHash() =>
    r'84e1566fb19a0adba2b825b77959a7049038d50c';

/// Scheduled pickups awaiting dispatch.
///
/// Copied from [pendingPickupsCount].
@ProviderFor(pendingPickupsCount)
final pendingPickupsCountProvider = AutoDisposeProvider<int>.internal(
  pendingPickupsCount,
  name: r'pendingPickupsCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingPickupsCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PendingPickupsCountRef = AutoDisposeProviderRef<int>;
String _$pendingDeliveriesCountHash() =>
    r'0f5ae7b020344b294016372907ebf3ff48b41a6d';

/// Scheduled deliveries awaiting dispatch.
///
/// Copied from [pendingDeliveriesCount].
@ProviderFor(pendingDeliveriesCount)
final pendingDeliveriesCountProvider = AutoDisposeProvider<int>.internal(
  pendingDeliveriesCount,
  name: r'pendingDeliveriesCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingDeliveriesCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PendingDeliveriesCountRef = AutoDisposeProviderRef<int>;
String _$recentActivityHash() => r'43ae7f757a34951c6f520b46a3fac61753abecc1';

/// Ten most recent audit-trail events.
///
/// Copied from [recentActivity].
@ProviderFor(recentActivity)
final recentActivityProvider =
    AutoDisposeStreamProvider<List<AuditEvent>>.internal(
  recentActivity,
  name: r'recentActivityProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentActivityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RecentActivityRef = AutoDisposeStreamProviderRef<List<AuditEvent>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
