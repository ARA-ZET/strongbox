// ignore_for_file: use_null_aware_elements
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/models/app_notification.dart';
import '../../../core/models/audit_event.dart';
import '../../../core/models/client.dart';
import '../../../core/models/invoice.dart';
import '../../../core/models/item.dart';
import '../../../core/models/job.dart';
import '../../../core/models/photo.dart';
import '../../../core/models/storage_unit.dart';
import '../../../core/models/value_objects.dart';
import '../../../core/providers/tenant_provider.dart';
import '../../../repositories/repository_providers.dart';
import '../../auth/providers/auth_provider.dart';

part 'client_providers.g.dart';

/// The signed-in user's client record, resolved by primaryUserId.
@riverpod
Stream<Client?> currentClient(Ref ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(null);
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref.watch(clientRepositoryProvider).watchByUserId(tenantId, uid);
}

/// The client's storage units (non-deleted, newest first).
@riverpod
Stream<List<StorageUnit>> myUnits(Ref ref) {
  final client = ref.watch(currentClientProvider).valueOrNull;
  if (client == null) return Stream.value(const []);
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref
      .watch(storageUnitRepositoryProvider)
      .watchAll(tenantId: tenantId, clientId: client.id);
}

/// The client's individually catalogued items (across all open units).
@riverpod
Stream<List<Item>> myItems(Ref ref) {
  final client = ref.watch(currentClientProvider).valueOrNull;
  if (client == null) return Stream.value(const []);
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref
      .watch(itemRepositoryProvider)
      .watchForClient(tenantId, client.id);
}

/// The client's jobs, newest first.
@riverpod
Stream<List<Job>> myJobs(Ref ref) {
  final client = ref.watch(currentClientProvider).valueOrNull;
  if (client == null) return Stream.value(const []);
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref
      .watch(jobRepositoryProvider)
      .watchAll(tenantId: tenantId, clientId: client.id);
}

/// The delivery currently on the road (if any) — dashboard banner.
@riverpod
Job? activeDelivery(Ref ref) {
  final jobs = ref.watch(myJobsProvider).valueOrNull ?? const [];
  for (final job in jobs) {
    if (job.type == JobType.delivery &&
        (job.status == JobStatus.inProgress ||
            job.status == JobStatus.assigned)) {
      return job;
    }
  }
  return null;
}

/// Storage search text.
@riverpod
class StorageSearchQuery extends _$StorageSearchQuery {
  @override
  String build() => '';
  void set(String value) => state = value;
}

/// Storage filter chip: all | inStorage | inTransit | pendingPickup | delivered.
@riverpod
class StorageStatusFilter extends _$StorageStatusFilter {
  @override
  String build() => 'all';
  void set(String value) => state = value;
}

/// Units after search + status filter.
@riverpod
List<StorageUnit> filteredMyUnits(Ref ref) {
  final query = ref.watch(storageSearchQueryProvider).trim().toLowerCase();
  final status = ref.watch(storageStatusFilterProvider);
  final units = ref.watch(myUnitsProvider).valueOrNull ?? const [];

  return units.where((unit) {
    if (unit.status == StorageStatus.archived) return false;
    if (status != 'all' && unit.status.name != status) return false;
    if (query.isEmpty) return true;
    return unit.label.toLowerCase().contains(query) ||
        unit.qrCodeId.toLowerCase().contains(query) ||
        (unit.category ?? '').toLowerCase().contains(query);
  }).toList();
}

/// One unit, live (client detail view).
@riverpod
Stream<StorageUnit?> clientUnitDetail(Ref ref, String unitId) =>
    ref.watch(storageUnitRepositoryProvider).watchUnit(unitId);

/// Photos for a unit, live.
@riverpod
Stream<List<Photo>> clientUnitPhotos(Ref ref, String unitId) =>
    ref.watch(photoRepositoryProvider).watchForEntity(unitId);

/// Items inside an open unit, live.
@riverpod
Stream<List<Item>> clientUnitItems(Ref ref, String unitId) =>
    ref.watch(itemRepositoryProvider).watchForUnit(unitId);

/// Last audit events for a unit — the Security & Activity rail.
@riverpod
Stream<List<AuditEvent>> clientUnitAudit(Ref ref, String unitId) =>
    ref.watch(auditRepositoryProvider).watchForEntity(unitId, limit: 10);

/// The client's invoices (written by Stripe in Stage 7).
@riverpod
Stream<List<Invoice>> myInvoices(Ref ref) {
  final client = ref.watch(currentClientProvider).valueOrNull;
  if (client == null) return Stream.value(const []);
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref
      .watch(subscriptionRepositoryProvider)
      .watchInvoices(tenantId, client.id);
}

/// Targeted notifications for the signed-in user.
@riverpod
Stream<List<AppNotification>> myNotifications(Ref ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(const []);
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref
      .watch(notificationRepositoryProvider)
      .watchForUser(tenantId, uid);
}

// ------------------------------------------------------- delivery request

/// Draft state for the 4-step delivery request (doc 15).
class DeliveryRequestData extends Equatable {
  const DeliveryRequestData({
    this.selectedUnitIds = const {},
    this.date,
    this.timeWindow = TimeWindow.morning,
    this.instructions = '',
    this.useSavedAddress = true,
    this.address = const Address(),
  });

  final Set<String> selectedUnitIds;
  final DateTime? date;
  final TimeWindow timeWindow;
  final String instructions;
  final bool useSavedAddress;
  final Address address;

  static const _unset = Object();

  DeliveryRequestData copyWith({
    Set<String>? selectedUnitIds,
    Object? date = _unset,
    TimeWindow? timeWindow,
    String? instructions,
    bool? useSavedAddress,
    Address? address,
  }) =>
      DeliveryRequestData(
        selectedUnitIds: selectedUnitIds ?? this.selectedUnitIds,
        date: identical(date, _unset) ? this.date : date as DateTime?,
        timeWindow: timeWindow ?? this.timeWindow,
        instructions: instructions ?? this.instructions,
        useSavedAddress: useSavedAddress ?? this.useSavedAddress,
        address: address ?? this.address,
      );

  @override
  List<Object?> get props => [
        selectedUnitIds,
        date,
        timeWindow,
        instructions,
        useSavedAddress,
        address,
      ];
}

@riverpod
class DeliveryRequest extends _$DeliveryRequest {
  @override
  DeliveryRequestData build() => const DeliveryRequestData();

  void toggleUnit(String unitId) {
    final next = <String>{...state.selectedUnitIds};
    next.contains(unitId) ? next.remove(unitId) : next.add(unitId);
    state = state.copyWith(selectedUnitIds: next);
  }

  void clearSelection() => state = state.copyWith(selectedUnitIds: {});

  void setSchedule({DateTime? date, TimeWindow? timeWindow}) =>
      state = state.copyWith(date: date ?? state.date, timeWindow: timeWindow);

  void setInstructions(String value) =>
      state = state.copyWith(instructions: value);

  void setUseSavedAddress(bool value) =>
      state = state.copyWith(useSavedAddress: value);

  void setAddress(Address address) =>
      state = state.copyWith(address: address);

  void reset() => state = const DeliveryRequestData();

  /// Creates the delivery job; units move to pendingDelivery in the same
  /// batch (state machine: inStorage → pendingDelivery).
  Future<void> submit() async {
    final client = ref.read(currentClientProvider).valueOrNull;
    if (client == null) throw Exception('No client record');
    final actorId = ref.read(currentActorIdProvider);
    final data = state;

    final job = Job(
      id: '',
      tenantId: client.tenantId,
      type: JobType.delivery,
      clientId: client.id,
      status: JobStatus.scheduled,
      scheduledDate: data.date ?? DateTime.now(),
      timeWindow: data.timeWindow,
      address: data.useSavedAddress ? client.address : data.address,
      storageUnitIds: data.selectedUnitIds.toList(),
      notes: data.instructions,
    );
    await ref
        .read(jobRepositoryProvider)
        .create(job, actorId: actorId, moveUnits: true);
    reset();
  }
}

// ------------------------------------------------------- account actions

/// Profile, address, prefs and account-deletion writes for the client.
@riverpod
class AccountActions extends _$AccountActions {
  @override
  FutureOr<void> build() {}

  Future<void> updateProfile({String? name, String? phone}) async {
    final uid = ref.read(currentActorIdProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(userRepositoryProvider).updateUser(uid, {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
      });
      final client = ref.read(currentClientProvider).valueOrNull;
      if (client != null) {
        await ref.read(clientRepositoryProvider).update(client.id, {
          if (name != null) 'displayName': name,
          if (phone != null) 'phone': phone,
        }, actorId: uid);
      }
    });
  }

  Future<void> updateAddress(Address address) async {
    final uid = ref.read(currentActorIdProvider);
    final client = ref.read(currentClientProvider).valueOrNull;
    if (client == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(clientRepositoryProvider)
        .update(client.id, {'address': address.toJson()}, actorId: uid));
  }

  Future<void> savePrefs(NotificationPrefs prefs) async {
    final uid = ref.read(currentActorIdProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(userRepositoryProvider)
        .updateUser(uid, {'notificationPrefs': prefs.toJson()}));
  }

  /// Logs a deletion request for staff review (no immediate delete).
  Future<void> requestAccountDeletion() async {
    final client = ref.read(currentClientProvider).valueOrNull;
    final tenantId = ref.read(currentTenantIdProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(notificationRepositoryProvider).create(
              tenantId: tenantId,
              type: NotificationType.systemAlert,
              title: 'Account deletion requested',
              body:
                  'Client ${client?.displayName ?? ''} requested account deletion.',
              entityType: 'client',
              entityId: client?.id,
            ));
  }
}
