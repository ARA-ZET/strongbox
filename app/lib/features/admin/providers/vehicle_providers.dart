import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/vehicle.dart';
import '../../../core/providers/tenant_provider.dart';
import '../../../core/utils/async_value_ext.dart';
import '../../../repositories/repository_providers.dart';
import '../../auth/providers/auth_provider.dart';

part 'vehicle_providers.g.dart';

/// The fleet's vehicles and trailers (not retired), by name.
@riverpod
Stream<List<Vehicle>> fleetVehicles(Ref ref) {
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref.watch(vehicleRepositoryProvider).watchAll(tenantId);
}

/// Add / edit / retire vehicles and trailers.
@riverpod
class VehicleMutations extends _$VehicleMutations {
  @override
  FutureOr<void> build() {}

  /// Saves [vehicle] — creates it when its id is empty.
  Future<void> save(Vehicle vehicle) async {
    final actorId = ref.read(currentActorIdProvider);
    final repo = ref.read(vehicleRepositoryProvider);
    final draft = vehicle.copyWith(
      tenantId: ref.read(currentTenantIdProvider),
      // A trailer has no driver of its own.
      assignedDriverId: vehicle.isTrailer ? null : vehicle.assignedDriverId,
    );
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => draft.id.isEmpty
        ? repo.create(draft, actorId: actorId)
        : repo.update(draft, actorId: actorId));
    state.throwIfError();
  }

  /// Takes [vehicle] out of the fleet.
  Future<void> retire(Vehicle vehicle) async {
    final actorId = ref.read(currentActorIdProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(vehicleRepositoryProvider).retire(vehicle, actorId: actorId));
    state.throwIfError();
  }
}
