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
String _$estimatedRevenueHash() => r'6259c47a3e34e94e608fa0a4869e1c6f10c55c67';

/// Estimated revenue from completed jobs.
///
/// Copied from [estimatedRevenue].
@ProviderFor(estimatedRevenue)
final estimatedRevenueProvider = AutoDisposeProvider<double>.internal(
  estimatedRevenue,
  name: r'estimatedRevenueProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$estimatedRevenueHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef EstimatedRevenueRef = AutoDisposeProviderRef<double>;
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
    r'd230a4b102b5a577b17f5c2e34884b600feff575';

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
