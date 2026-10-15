// ignore_for_file: use_null_aware_elements
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/enums/app_enums.dart';
import '../core/models/storage_unit.dart';
import 'repository_base.dart';

/// Data access for storage units (doc 09). Every query is tenant- and
/// isDeleted-scoped; status changes commit an AuditEvent in the same txn.
abstract class StorageUnitRepository {
  Stream<List<StorageUnit>> watchAll({
    required String tenantId,
    String? clientId,
    StorageStatus? status,
    UnitType? type,
  });
  Stream<StorageUnit?> watchUnit(String id);
  Future<StorageUnit?> getUnit(String id);
  Future<List<StorageUnit>> getByIds(List<String> ids);
  Future<StorageUnit?> getByQrCode(String tenantId, String qrCodeId);
  Future<String> create(StorageUnit unit, {required String actorId});
  Future<void> update(String id, Map<String, dynamic> fields,
      {required String actorId});
  Future<void> updateStatus(String id, StorageStatus newStatus,
      {required String actorId, String? jobId});
  Future<void> softDelete(StorageUnit unit, {required String actorId});
  Future<void> addPhotoId(String unitId, String photoId);
}

class FirestoreStorageUnitRepository
    with FirestoreRepository
    implements StorageUnitRepository {
  FirestoreStorageUnitRepository(this.db);

  @override
  final FirebaseFirestore db;

  CollectionReference<Map<String, dynamic>> get _units =>
      col(Collections.storageUnits);

  @override
  Stream<List<StorageUnit>> watchAll({
    required String tenantId,
    String? clientId,
    StorageStatus? status,
    UnitType? type,
  }) {
    Query<Map<String, dynamic>> query = _units
        .where('tenantId', isEqualTo: tenantId)
        .where('isDeleted', isEqualTo: false);
    if (clientId != null) {
      query = query.where('clientId', isEqualTo: clientId);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }
    return query.snapshots().map((snap) {
      final units = snap.docs.map(StorageUnit.fromFirestore).toList()
        ..sort((a, b) => (b.updatedAt ?? DateTime(0))
            .compareTo(a.updatedAt ?? DateTime(0)));
      return units;
    });
  }

  @override
  Stream<StorageUnit?> watchUnit(String id) => _units
      .doc(id)
      .snapshots()
      .map((doc) => doc.exists ? StorageUnit.fromFirestore(doc) : null);

  @override
  Future<StorageUnit?> getUnit(String id) => guardRepo(() async {
        final doc = await _units.doc(id).get();
        return doc.exists ? StorageUnit.fromFirestore(doc) : null;
      });

  @override
  Future<List<StorageUnit>> getByIds(List<String> ids) => guardRepo(() async {
        if (ids.isEmpty) return <StorageUnit>[];
        final snaps = await Future.wait(ids.map((id) => _units.doc(id).get()));
        return snaps
            .where((doc) => doc.exists)
            .map(StorageUnit.fromFirestore)
            .toList();
      });

  @override
  Future<StorageUnit?> getByQrCode(String tenantId, String qrCodeId) =>
      guardRepo(() async {
        final snap = await _units
            .where('tenantId', isEqualTo: tenantId)
            .where('isDeleted', isEqualTo: false)
            .where('qrCodeId', isEqualTo: qrCodeId)
            .limit(1)
            .get();
        return snap.docs.isEmpty
            ? null
            : StorageUnit.fromFirestore(snap.docs.first);
      });

  @override
  Future<String> create(StorageUnit unit, {required String actorId}) =>
      guardRepo(() async {
        final doc = _units.doc();
        final data = unit.toJson()
          ..remove('id')
          ..['createdAt'] = FieldValue.serverTimestamp()
          ..['updatedAt'] = FieldValue.serverTimestamp();

        final batch = db.batch();
        batch.set(doc, data);
        // Register the label so scanners can resolve it. Merge keeps a
        // pre-printed code's batchId.
        batch.set(
          col(Collections.qrCodes).doc(unit.qrCodeId),
          {
            'tenantId': unit.tenantId,
            'storageUnitId': doc.id,
            'isLinked': true,
            'linkedAt': FieldValue.serverTimestamp(),
            'linkedBy': actorId,
          },
          SetOptions(merge: true),
        );
        batch.set(
          auditDoc(),
          auditEventData(
            tenantId: unit.tenantId,
            actorId: actorId,
            action: AuditAction.unitCreated,
            entityType: 'storageUnit',
            entityId: doc.id,
            metadata: {'qrCodeId': unit.qrCodeId},
          ),
        );
        if (unit.clientId.isNotEmpty) {
          batch.update(col(Collections.clients).doc(unit.clientId),
              {'storageUnitCount': FieldValue.increment(1)});
        }
        await batch.commit();
        return doc.id;
      });

  @override
  Future<void> update(String id, Map<String, dynamic> fields,
          {required String actorId}) =>
      guardRepo(() async {
        final unit = await getUnit(id);
        await _units.doc(id).update({
          ...fields,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        await col(Collections.auditEvents).add(auditEventData(
          tenantId: unit?.tenantId ?? '',
          actorId: actorId,
          action: AuditAction.unitUpdated,
          entityType: 'storageUnit',
          entityId: id,
          metadata: {'fields': fields.keys.toList()},
        ));
      });

  @override
  Future<void> updateStatus(String id, StorageStatus newStatus,
          {required String actorId, String? jobId}) =>
      guardRepo(() async {
        await db.runTransaction((txn) async {
          final ref = _units.doc(id);
          final snap = await txn.get(ref);
          if (!snap.exists) return;
          final unit = StorageUnit.fromFirestore(snap);

          txn.update(ref, {
            'status': newStatus.name,
            if (jobId != null) 'jobId': jobId,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          txn.set(
            auditDoc(),
            auditEventData(
              tenantId: unit.tenantId,
              actorId: actorId,
              action: AuditAction.unitStatusChanged,
              entityType: 'storageUnit',
              entityId: id,
              metadata: {
                'fromStatus': unit.status.name,
                'toStatus': newStatus.name,
                if (jobId != null) 'jobId': jobId,
              },
            ),
          );
        });
      });

  @override
  Future<void> softDelete(StorageUnit unit, {required String actorId}) =>
      guardRepo(() async {
        final batch = db.batch();
        batch.update(_units.doc(unit.id), {
          'status': StorageStatus.archived.name,
          'isDeleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        batch.set(
          auditDoc(),
          auditEventData(
            tenantId: unit.tenantId,
            actorId: actorId,
            action: AuditAction.unitArchived,
            entityType: 'storageUnit',
            entityId: unit.id,
          ),
        );
        if (unit.clientId.isNotEmpty) {
          batch.update(col(Collections.clients).doc(unit.clientId),
              {'storageUnitCount': FieldValue.increment(-1)});
        }
        await batch.commit();
      });

  @override
  Future<void> addPhotoId(String unitId, String photoId) =>
      guardRepo(() => _units.doc(unitId).update({
            'photoIds': FieldValue.arrayUnion([photoId]),
            'updatedAt': FieldValue.serverTimestamp(),
          }));
}
