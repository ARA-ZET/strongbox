import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/enums/app_enums.dart';
import '../core/models/qr_code.dart';
import '../core/utils/qr_generator.dart';
import 'repository_base.dart';

/// QR code generation and linking (doc 09). A code, once linked, is
/// permanent (rule #20).
abstract class QRRepository {
  Future<QRBatch> generateBatch({
    required String tenantId,
    required int count,
    required String resolution,
    required String createdBy,
  });
  Stream<List<QRBatch>> watchBatches(String tenantId);
  Stream<int> watchUnlinkedCount(String tenantId);
  Future<QRCode?> resolveCode(String scannedValue);
  Future<bool> isLinked(String tenantId, String codeValue);
  Future<void> linkToUnit(String codeId, String unitId,
      {required String tenantId, required String actorId});
}

class FirestoreQRRepository with FirestoreRepository implements QRRepository {
  FirestoreQRRepository(this.db);

  @override
  final FirebaseFirestore db;

  @override
  Future<QRBatch> generateBatch({
    required String tenantId,
    required int count,
    required String resolution,
    required String createdBy,
  }) =>
      guardRepo(() async {
        final codes = generateBoxQrBatch(count);
        final batchRef = col(Collections.qrBatches).doc();
        final writer = db.batch();

        for (final code in codes) {
          writer.set(col(Collections.qrCodes).doc(code), {
            'tenantId': tenantId,
            'batchId': batchRef.id,
            'storageUnitId': null,
            'isLinked': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        writer.set(batchRef, {
          'tenantId': tenantId,
          'count': count,
          'codeIds': codes,
          'linkedCount': 0,
          'printResolution': resolution,
          'createdBy': createdBy,
          'createdAt': FieldValue.serverTimestamp(),
        });
        writer.set(
          auditDoc(),
          auditEventData(
            tenantId: tenantId,
            actorId: createdBy,
            action: AuditAction.qrGenerated,
            entityType: 'qrBatch',
            entityId: batchRef.id,
            metadata: {'count': count},
          ),
        );
        await writer.commit();

        return QRBatch(
          id: batchRef.id,
          tenantId: tenantId,
          count: count,
          codeIds: codes,
          printResolution: resolution,
          createdBy: createdBy,
        );
      });

  @override
  Stream<List<QRBatch>> watchBatches(String tenantId) =>
      col(Collections.qrBatches)
          .where('tenantId', isEqualTo: tenantId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(QRBatch.fromFirestore).toList());

  @override
  Stream<int> watchUnlinkedCount(String tenantId) => col(Collections.qrBatches)
      .where('tenantId', isEqualTo: tenantId)
      .snapshots()
      .map((snap) => snap.docs.fold<int>(0,
          (acc, doc) => acc + unlinkedCountOf(QRBatch.fromFirestore(doc))));

  @override
  Future<QRCode?> resolveCode(String scannedValue) => guardRepo(() async {
        final doc = await col(Collections.qrCodes).doc(scannedValue).get();
        return doc.exists ? QRCode.fromFirestore(doc) : null;
      });

  @override
  Future<bool> isLinked(String tenantId, String codeValue) =>
      guardRepo(() async {
        final doc = await col(Collections.qrCodes).doc(codeValue).get();
        return doc.exists && (doc.data()?['isLinked'] as bool? ?? false);
      });

  @override
  Future<void> linkToUnit(String codeId, String unitId,
          {required String tenantId, required String actorId}) =>
      guardRepo(() async {
        await db.runTransaction((txn) async {
          final codeRef = col(Collections.qrCodes).doc(codeId);
          final codeSnap = await txn.get(codeRef);
          final batchId = codeSnap.data()?['batchId'] as String?;

          txn.set(codeRef, {
            'tenantId': tenantId,
            'storageUnitId': unitId,
            'isLinked': true,
            'linkedAt': FieldValue.serverTimestamp(),
            'linkedBy': actorId,
          }, SetOptions(merge: true));
          txn.update(col(Collections.storageUnits).doc(unitId), {
            'qrCodeId': codeId,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          if (batchId != null) {
            txn.update(col(Collections.qrBatches).doc(batchId),
                {'linkedCount': FieldValue.increment(1)});
          }
          txn.set(
            auditDoc(),
            auditEventData(
              tenantId: tenantId,
              actorId: actorId,
              action: AuditAction.qrLinked,
              entityType: 'qrCode',
              entityId: codeId,
              metadata: {'unitId': unitId},
            ),
          );
        });
      });
}
