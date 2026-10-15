// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fleetVehiclesHash() => r'8a13251d97aad2741dde5b23b65a29f5ef670d93';

/// The fleet's vehicles and trailers (not retired), by name.
///
/// Copied from [fleetVehicles].
@ProviderFor(fleetVehicles)
final fleetVehiclesProvider = AutoDisposeStreamProvider<List<Vehicle>>.internal(
  fleetVehicles,
  name: r'fleetVehiclesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fleetVehiclesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FleetVehiclesRef = AutoDisposeStreamProviderRef<List<Vehicle>>;
String _$vehicleMutationsHash() => r'a42d56c54ee02efb4fdb96feed75e9070329bd21';

/// Add / edit / retire vehicles and trailers.
///
/// Copied from [VehicleMutations].
@ProviderFor(VehicleMutations)
final vehicleMutationsProvider =
    AutoDisposeAsyncNotifierProvider<VehicleMutations, void>.internal(
  VehicleMutations.new,
  name: r'vehicleMutationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$vehicleMutationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$VehicleMutations = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
