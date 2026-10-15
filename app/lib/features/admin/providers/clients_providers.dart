// ignore_for_file: use_null_aware_elements
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/async_value_ext.dart';
import '../../../core/enums/app_enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/models/app_user.dart';
import '../../../core/models/client.dart';
import '../../../core/models/job.dart';
import '../../../core/models/storage_unit.dart';
import '../../../core/providers/tenant_provider.dart';
import '../../../repositories/repository_providers.dart';

part 'clients_providers.g.dart';

/// All clients for the tenant, ordered by name.
@riverpod
Stream<List<Client>> clients(Ref ref) {
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref.watch(clientRepositoryProvider).watchAll(tenantId: tenantId);
}

/// clientId → display name lookup used by job/unit tables.
@riverpod
Map<String, String> clientNames(Ref ref) {
  final list = ref.watch(clientsProvider).valueOrNull ?? const [];
  return {for (final c in list) c.id: c.displayName};
}

/// All driver users for the tenant.
@riverpod
Stream<List<AppUser>> driverUsers(Ref ref) {
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref
      .watch(userRepositoryProvider)
      .watchByRole(tenantId, UserRole.driver);
}

/// driverId → name lookup used by job tables.
@riverpod
Map<String, String> driverNames(Ref ref) {
  final list = ref.watch(driverUsersProvider).valueOrNull ?? const [];
  return {for (final d in list) d.id: d.name};
}

/// Directory search text.
@riverpod
class ClientSearchQuery extends _$ClientSearchQuery {
  @override
  String build() => '';
  void set(String value) => state = value;
}

/// Directory status filter: all | active | pastDue | cancelled.
@riverpod
class ClientStatusFilter extends _$ClientStatusFilter {
  @override
  String build() => 'all';
  void set(String value) => state = value;
}

/// Directory rows after search + status filter.
@riverpod
List<Client> filteredClients(Ref ref) {
  final query = ref.watch(clientSearchQueryProvider).trim().toLowerCase();
  final status = ref.watch(clientStatusFilterProvider);
  final list = ref.watch(clientsProvider).valueOrNull ?? const [];

  return list.where((client) {
    if (status != 'all' && client.subscriptionStatus.name != status) {
      return false;
    }
    if (query.isEmpty) return true;
    return client.displayName.toLowerCase().contains(query) ||
        client.email.toLowerCase().contains(query) ||
        client.id.toLowerCase().contains(query);
  }).toList();
}

/// One client, live.
@riverpod
Stream<Client?> clientById(Ref ref, String clientId) =>
    ref.watch(clientRepositoryProvider).watchClient(clientId);

/// Units under custody for one client.
@riverpod
Stream<List<StorageUnit>> clientUnits(Ref ref, String clientId) {
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref
      .watch(storageUnitRepositoryProvider)
      .watchAll(tenantId: tenantId, clientId: clientId);
}

/// Recent jobs for one client.
@riverpod
Stream<List<Job>> clientJobs(Ref ref, String clientId) {
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref
      .watch(jobRepositoryProvider)
      .watchAll(tenantId: tenantId, clientId: clientId);
}

/// Create/update actions on client documents.
@riverpod
class ClientMutations extends _$ClientMutations {
  @override
  FutureOr<void> build() {}

  Future<String> addClient({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    final tenantId = ref.read(currentTenantIdProvider);
    final actorId = ref.read(currentActorIdProvider);
    final client = Client(
      id: '',
      tenantId: tenantId,
      displayName: name,
      email: email,
      phone: phone,
    );
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() =>
        ref.read(clientRepositoryProvider).create(client, actorId: actorId));
    state = result;
    return result.requireValue;
  }

  Future<void> updateClient(
    String clientId, {
    String? name,
    String? email,
    String? phone,
    String? address,
    SubscriptionStatus? status,
  }) async {
    final actorId = ref.read(currentActorIdProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(clientRepositoryProvider).update(clientId, {
          if (name != null) 'displayName': name,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
          if (status != null) 'subscriptionStatus': status.name,
        }, actorId: actorId));
    state.throwIfError();
  }
}
