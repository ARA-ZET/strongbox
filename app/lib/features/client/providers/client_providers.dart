// ignore_for_file: use_null_aware_elements
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/storage_paths.dart';
import '../../../core/utils/account_closure.dart';
import '../../../core/utils/async_value_ext.dart';
import '../../../core/constants/pricing.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/models/audit_event.dart';
import '../../../core/models/client.dart';
import '../../../core/models/invoice.dart';
import '../../../core/models/item.dart';
import '../../../core/models/job.dart';
import '../../../core/models/photo.dart';
import '../../../core/models/storage_unit.dart';
import '../../../core/models/value_objects.dart';
import '../../../core/providers/price_catalog_provider.dart';
import '../../../core/providers/tenant_provider.dart';
import '../../../repositories/repository_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../utils/client_orders.dart';

part 'client_providers.g.dart';

/// The current user's client record, resolved by primaryUserId.
@riverpod
Stream<Client?> currentClient(Ref ref) {
  final uid = ref.watch(currentUserIdProvider);
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

/// What the client pays for storage each month: per-unit rates from the
/// shared price list (same numbers as the website).
@riverpod
StorageBill myStorageBill(Ref ref) {
  final units = ref.watch(myUnitsProvider).valueOrNull ?? const [];
  return StorageBill.fromUnits(units, ref.watch(priceCatalogProvider));
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

/// One of the client's orders (jobs), live; null until loaded or if it
/// isn't theirs.
@riverpod
Job? myOrder(Ref ref, String jobId) {
  final jobs = ref.watch(myJobsProvider).valueOrNull ?? const [];
  for (final job in jobs) {
    if (job.id == jobId) return job;
  }
  return null;
}

/// Dashboard "To do": driver at the door, invoices to pay, boxes to pack.
@riverpod
List<ClientTodo> myTodos(Ref ref) => clientTodos(
      jobs: ref.watch(myJobsProvider).valueOrNull ?? const [],
      units: ref.watch(myUnitsProvider).valueOrNull ?? const [],
      invoices: ref.watch(myInvoicesProvider).valueOrNull ?? const [],
      now: DateTime.now(),
    );

/// What still stops the client's account closing (empty = nothing).
@riverpod
List<ClosureBlocker> myClosureBlockers(Ref ref) => closureBlockers(
      units: ref.watch(myUnitsProvider).valueOrNull ?? const [],
      jobs: ref.watch(myJobsProvider).valueOrNull ?? const [],
      invoices: ref.watch(myInvoicesProvider).valueOrNull ?? const [],
    );

/// Storage search text.
@riverpod
class StorageSearchQuery extends _$StorageSearchQuery {
  @override
  String build() => '';
  void set(String value) => state = value;
}

/// Units after search + status filter. [status] is a [StorageStatus] name
/// or 'all' — it comes from the URL (/client/storage?status=inStorage) so
/// the dashboard can link straight to a filtered view.
@riverpod
List<StorageUnit> filteredMyUnits(Ref ref, String status) {
  final query = ref.watch(storageSearchQueryProvider).trim().toLowerCase();
  final units = ref.watch(myUnitsProvider).valueOrNull ?? const [];

  return units.where((unit) {
    if (!unit.status.isListedForClient) return false;
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

/// Items inside an open unit, live. Queried by client (not unit) so the
/// query stays within what the rules let a client read.
@riverpod
Stream<List<Item>> clientUnitItems(Ref ref, String unitId) {
  final client = ref.watch(currentClientProvider).valueOrNull;
  if (client == null) return Stream.value(const []);
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref
      .watch(itemRepositoryProvider)
      .watchForClient(tenantId, client.id)
      .map((items) =>
          items.where((item) => item.storageUnitId == unitId).toList());
}

/// Last audit events for a unit — the Security & Activity rail.
@riverpod
Stream<List<AuditEvent>> clientUnitAudit(Ref ref, String unitId) =>
    ref.watch(auditRepositoryProvider).watchForEntity(unitId, limit: 10);

/// The client's monthly invoices (issued by the monthlyInvoices function).
@riverpod
Stream<List<Invoice>> myInvoices(Ref ref) {
  final client = ref.watch(currentClientProvider).valueOrNull;
  if (client == null) return Stream.value(const []);
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref
      .watch(subscriptionRepositoryProvider)
      .watchInvoices(tenantId, client.id);
}

// ------------------------------------------------------- packing photos

/// Most photos a client can add to one unit while packing.
const maxPackingPhotos = 8;

/// Whether the client can still add packing photos and notes to [unit]:
/// only while it's with them, awaiting pickup.
bool canPack(StorageUnit unit) => unit.status == StorageStatus.pendingPickup;

/// Photos the signed-in client took of [unitId] while packing.
@riverpod
List<Photo> myPackingPhotos(Ref ref, String unitId) {
  final uid = ref.watch(currentUserIdProvider);
  final photos = ref.watch(clientUnitPhotosProvider(unitId)).valueOrNull ??
      const <Photo>[];
  return photos.where((p) => p.uploadedBy == uid).toList()
    ..sort((a, b) =>
        (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)));
}

/// The client photographing and describing boxes while packing — the
/// contents before sealing, the sealed box with its label. Drivers and ops
/// see the same photos on the unit.
@Riverpod(keepAlive: true)
class PackingActions extends _$PackingActions {
  @override
  FutureOr<void> build() {}

  Future<void> _run(Future<void> Function() op) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(op);
    state.throwIfError();
  }

  Future<void> addPhoto(StorageUnit unit, Uint8List bytes,
      {PhotoType type = PhotoType.interior}) {
    if (!canPack(unit)) {
      throw StateError('Photos can be added until the box is collected.');
    }
    final uid = ref.read(currentUserIdProvider) ?? '';
    final name = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    return _run(() async {
      await ref.read(photoRepositoryProvider).addUnitPhoto(
            tenantId: unit.tenantId,
            unitId: unit.id,
            bytes: bytes,
            type: type,
            storagePath:
                StoragePaths.clientPackingPhoto(unit.tenantId, unit.id, name),
            uploadedBy: uid,
          );
    });
  }

  Future<void> removePhoto(StorageUnit unit, Photo photo) => _run(() =>
      ref.read(photoRepositoryProvider).removeUnitPhoto(photo, unit.id));

  Future<void> saveNotes(StorageUnit unit, String notes) => _run(() => ref
      .read(storageUnitRepositoryProvider)
      .setPackingNotes(unit, notes, actorId: ref.read(currentActorIdProvider)));
}

// ------------------------------------------------------- order changes

/// The client cancelling their own pickup or delivery before the driver
/// starts it (the `cancelOrder` function checks again server-side).
@Riverpod(keepAlive: true)
class OrderCancellation extends _$OrderCancellation {
  @override
  FutureOr<void> build() {}

  Future<void> cancel(Job job, {String? reason}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(bookingRepositoryProvider)
        .cancelOrder(job.id, reason: reason));
    state.throwIfError();
  }
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

  /// Requests the delivery via the `requestDelivery` function, which
  /// checks the units and moves them to pendingDelivery with the new job
  /// (awaiting an admin's confirmation). Returns the job id.
  Future<String> submit() async {
    final client = ref.read(currentClientProvider).valueOrNull;
    if (client == null) throw Exception('No client record');
    final data = state;
    final date = data.date;
    if (date == null) throw Exception('Choose a delivery date');

    final jobId = await ref.read(bookingRepositoryProvider).requestDelivery(
          unitIds: data.selectedUnitIds.toList(),
          date: date,
          timeWindow: data.timeWindow,
          address: data.useSavedAddress ? client.address : data.address,
          notes: data.instructions,
        );
    reset();
    return jobId;
  }
}

// ------------------------------------------------------- account actions

/// Profile, address, prefs and account-deletion writes for the client.
@Riverpod(keepAlive: true)
class AccountActions extends _$AccountActions {
  @override
  FutureOr<void> build() {}

  Future<void> updateProfile({String? name, String? phone}) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    final actorId = ref.read(currentActorIdProvider);
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
        }, actorId: actorId);
      }
    });
    state.throwIfError();
  }

  Future<void> updateAddress(Address address) async {
    final actorId = ref.read(currentActorIdProvider);
    final client = ref.read(currentClientProvider).valueOrNull;
    if (client == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(clientRepositoryProvider)
        .update(client.id, {'address': address.toJson()}, actorId: actorId));
    state.throwIfError();
  }

  Future<void> savePrefs(NotificationPrefs prefs) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(userRepositoryProvider)
        .updateUser(uid, {'notificationPrefs': prefs.toJson()}));
    state.throwIfError();
  }

  /// Asks to close the client's account: it closes 30 days from now
  /// (functions/src/closure.js), once their items are back and invoices
  /// are settled. Returns the closing date.
  Future<DateTime?> requestAccountClosure() async {
    final client = ref.read(currentClientProvider).valueOrNull;
    if (client == null) return null;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() =>
        ref.read(accountClosureRepositoryProvider).request(client.id));
    state = result;
    state.throwIfError();
    return result.valueOrNull;
  }

  /// Keeps the account open: cancels a pending closure.
  Future<void> cancelAccountClosure() async {
    final client = ref.read(currentClientProvider).valueOrNull;
    if (client == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(accountClosureRepositoryProvider).cancel(client.id));
    state.throwIfError();
  }
}
