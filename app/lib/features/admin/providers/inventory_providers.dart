import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/storage_paths.dart';
import '../../../core/constants/pricing.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/models/job.dart';
import '../../../core/models/item.dart';
import '../../../core/models/photo.dart';
import '../../../core/models/storage_unit.dart';
import '../../../core/providers/tenant_provider.dart';
import '../../../core/utils/qr_generator.dart';
import '../../../repositories/repository_providers.dart';
import '../../auth/providers/auth_provider.dart';

part 'inventory_providers.g.dart';

/// All non-deleted units for the tenant, newest first.
@riverpod
Stream<List<StorageUnit>> allUnits(Ref ref) {
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref.watch(storageUnitRepositoryProvider).watchAll(tenantId: tenantId);
}

@riverpod
class InventoryClientFilter extends _$InventoryClientFilter {
  @override
  String build() => 'all';
  void set(String value) => state = value;
}

/// all | inStorage | inTransit | pending (matches pending* statuses).
@riverpod
class InventoryStatusFilter extends _$InventoryStatusFilter {
  @override
  String build() => 'all';
  void set(String value) => state = value;
}

/// all | closed | open.
@riverpod
class InventoryTypeFilter extends _$InventoryTypeFilter {
  @override
  String build() => 'all';
  void set(String value) => state = value;
}

/// Grid rows after the three filters (client-side).
@riverpod
List<StorageUnit> filteredUnits(Ref ref) {
  final client = ref.watch(inventoryClientFilterProvider);
  final status = ref.watch(inventoryStatusFilterProvider);
  final type = ref.watch(inventoryTypeFilterProvider);
  final list = ref.watch(allUnitsProvider).valueOrNull ?? const [];

  return list.where((unit) {
    if (client != 'all' && unit.clientId != client) return false;
    if (type != 'all' && unit.type.name != type) return false;
    if (status == 'pending') return unit.status.name.startsWith('pending');
    if (status != 'all' && unit.status.name != status) return false;
    return true;
  }).toList();
}

/// One unit, live.
@riverpod
Stream<StorageUnit?> unitById(Ref ref, String unitId) =>
    ref.watch(storageUnitRepositoryProvider).watchUnit(unitId);

/// Photos for any entity (unit, item, job), live.
@riverpod
Stream<List<Photo>> entityPhotos(Ref ref, String entityId) =>
    ref.watch(photoRepositoryProvider).watchForEntity(entityId);

/// Items catalogued inside an open unit, live.
@riverpod
Stream<List<Item>> unitItems(Ref ref, String unitId) =>
    ref.watch(itemRepositoryProvider).watchForUnit(unitId);

/// Jobs that ever touched a unit — the detail-page timeline.
@riverpod
Stream<List<Job>> unitJobs(Ref ref, String unitId) {
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref.watch(jobRepositoryProvider).watchAll(tenantId: tenantId).map(
      (jobs) =>
          jobs.where((j) => j.storageUnitIds.contains(unitId)).toList());
}

/// Look up a unit by scanned QR code value.
@riverpod
Future<StorageUnit?> unitByQrCode(Ref ref, String code) async {
  final qr = await ref.read(qrRepositoryProvider).resolveCode(code);
  final unitId = qr?.storageUnitId;
  if (unitId == null) return null;
  return ref.read(storageUnitRepositoryProvider).getUnit(unitId);
}

/// Create/update actions on units and their items.
@riverpod
class UnitMutations extends _$UnitMutations {
  @override
  FutureOr<void> build() {}

  String get _tenantId => ref.read(currentTenantIdProvider);
  String get _actorId => ref.read(currentActorIdProvider);

  Future<List<String>> _uploadUnitPhotos(
      String unitId, List<Uint8List> photos) async {
    final repo = ref.read(photoRepositoryProvider);
    final ids = <String>[];
    for (final bytes in photos) {
      final name = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      ids.add(await repo.upload(
        tenantId: _tenantId,
        bytes: bytes,
        type: PhotoType.exterior,
        entityType: 'storageUnit',
        entityId: unitId,
        storagePath: StoragePaths.unitPhoto(_tenantId, unitId, name),
        uploadedBy: _actorId,
      ));
    }
    return ids;
  }

  /// Registers a unit and returns its id. [qrCodeId] defaults to a fresh
  /// generated code (the Link-QR flow passes a pre-printed one).
  Future<String> addUnit({
    required String clientId,
    required UnitType type,
    required String label,
    required String priceKey,
    List<Uint8List> photos = const [],
    String? qrCodeId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final repo = ref.read(storageUnitRepositoryProvider);
      final unit = StorageUnit(
        id: '',
        tenantId: _tenantId,
        clientId: clientId,
        qrCodeId: qrCodeId ?? generateBoxQrCode(),
        type: type,
        label: label,
        priceKey: priceKey,
        monthlyRateZar: Pricing.monthlyFor(priceKey) ?? 0,
      );
      final id = await repo.create(unit, actorId: _actorId);
      if (photos.isNotEmpty) {
        final photoIds = await _uploadUnitPhotos(id, photos);
        await repo.update(id, {'photoIds': photoIds}, actorId: _actorId);
      }
      return id;
    });
    state = result;
    return result.requireValue;
  }

  /// Sets a unit's size from the price list and records today's rate —
  /// used to price units registered before sizes existed, or to correct one.
  Future<void> updatePriceKey(String unitId, String priceKey) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(storageUnitRepositoryProvider)
        .update(unitId, {
          'priceKey': priceKey,
          'monthlyRateZar': Pricing.monthlyFor(priceKey) ?? 0,
        }, actorId: _actorId));
  }

  Future<void> updateLabel(String unitId, String label) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(storageUnitRepositoryProvider)
        .update(unitId, {'label': label}, actorId: _actorId));
  }

  Future<void> addPhotos(String unitId, List<Uint8List> photos) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final ids = await _uploadUnitPhotos(unitId, photos);
      final repo = ref.read(storageUnitRepositoryProvider);
      for (final id in ids) {
        await repo.addPhotoId(unitId, id);
      }
    });
  }

  Future<void> archiveUnit(StorageUnit unit) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(storageUnitRepositoryProvider)
        .softDelete(unit, actorId: _actorId));
  }

  Future<void> addItem({
    required StorageUnit unit,
    required String description,
    required StorageStatus status,
    List<Uint8List> photos = const [],
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(itemRepositoryProvider).create(
            tenantId: _tenantId,
            storageUnitId: unit.id,
            clientId: unit.clientId,
            qrCodeId: generateItemQrCode(),
            label: description,
            status: status,
          );
    });
  }
}
