// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$monthlyJobVolumeHash() => r'f7acd301a44558aef1e4ddd4c01e10dd21059824';

/// Jobs per month for the last six months.
///
/// Copied from [monthlyJobVolume].
@ProviderFor(monthlyJobVolume)
final monthlyJobVolumeProvider =
    AutoDisposeProvider<List<MonthVolume>>.internal(
  monthlyJobVolume,
  name: r'monthlyJobVolumeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monthlyJobVolumeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MonthlyJobVolumeRef = AutoDisposeProviderRef<List<MonthVolume>>;
String _$monthlyStorageByClientHash() =>
    r'599c67b524f8f8877dfb0d44c30367652292c345';

/// Monthly storage billed per client: every billable unit at its recorded
/// rate — what next month's invoice run will charge (StorageBill).
///
/// Copied from [monthlyStorageByClient].
@ProviderFor(monthlyStorageByClient)
final monthlyStorageByClientProvider =
    AutoDisposeProvider<Map<String, int>>.internal(
  monthlyStorageByClient,
  name: r'monthlyStorageByClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monthlyStorageByClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MonthlyStorageByClientRef = AutoDisposeProviderRef<Map<String, int>>;
String _$monthlyStorageRevenueHash() =>
    r'd70023ac15d5fd1dba2c6085835df182f02bf919';

/// Monthly recurring storage revenue across all clients.
///
/// Copied from [monthlyStorageRevenue].
@ProviderFor(monthlyStorageRevenue)
final monthlyStorageRevenueProvider = AutoDisposeProvider<int>.internal(
  monthlyStorageRevenue,
  name: r'monthlyStorageRevenueProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monthlyStorageRevenueHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MonthlyStorageRevenueRef = AutoDisposeProviderRef<int>;
String _$fleetUtilisationHash() => r'b55916646cd0089d918216770fb0e02be324c032';

/// Fleet utilisation: drivers on a job / total drivers.
///
/// Copied from [fleetUtilisation].
@ProviderFor(fleetUtilisation)
final fleetUtilisationProvider =
    AutoDisposeProvider<({int total, int onJob})>.internal(
  fleetUtilisation,
  name: r'fleetUtilisationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fleetUtilisationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FleetUtilisationRef = AutoDisposeProviderRef<({int total, int onJob})>;
String _$topClientsByVolumeHash() =>
    r'53623a13553fb73cd75a98ec24ba10a6ec238113';

/// Clients ranked by units stored, with month-to-date job counts.
///
/// Copied from [topClientsByVolume].
@ProviderFor(topClientsByVolume)
final topClientsByVolumeProvider =
    AutoDisposeProvider<List<ClientVolumeRow>>.internal(
  topClientsByVolume,
  name: r'topClientsByVolumeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$topClientsByVolumeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TopClientsByVolumeRef = AutoDisposeProviderRef<List<ClientVolumeRow>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
