import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/enums/app_enums.dart';
import '../core/models/business_settings.dart';
import 'repository_base.dart';

/// The tenant's business details and operations defaults —
/// `tenants/{tenantId}`, edited in Admin → Settings.
abstract class TenantRepository {
  /// Emits null until an admin first saves — callers fall back to
  /// [BusinessSettings.defaults].
  Stream<BusinessSettings?> watchSettings(String tenantId);

  /// Applies [change] to the stored settings (or the defaults before the
  /// first save) and writes the result with an audit event, in one
  /// transaction. [change] may throw to abort without writing.
  Future<BusinessSettings> updateSettings(
    String tenantId,
    BusinessSettings Function(BusinessSettings current) change, {
    required String actorId,
  });
}

class FirestoreTenantRepository
    with FirestoreRepository
    implements TenantRepository {
  FirestoreTenantRepository(this.db);

  @override
  final FirebaseFirestore db;

  DocumentReference<Map<String, dynamic>> _doc(String tenantId) =>
      col(Collections.tenants).doc(tenantId);

  @override
  Stream<BusinessSettings?> watchSettings(String tenantId) => _doc(tenantId)
      .snapshots()
      .map((doc) => doc.exists ? BusinessSettings.fromFirestore(doc) : null);

  @override
  Future<BusinessSettings> updateSettings(
    String tenantId,
    BusinessSettings Function(BusinessSettings current) change, {
    required String actorId,
  }) => guardRepo(
    () => db.runTransaction((tx) async {
      final snap = await tx.get(_doc(tenantId));
      final current = snap.exists
          ? BusinessSettings.fromFirestore(snap)
          : BusinessSettings.defaults;
      final next = change(current);
      tx.set(_doc(tenantId), {
        ...next.toJson(),
        'tenantId': tenantId,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': actorId,
      });
      tx.set(
        auditDoc(),
        auditEventData(
          tenantId: tenantId,
          actorId: actorId,
          action: AuditAction.settingsUpdated,
          entityType: 'tenant',
          entityId: tenantId,
        ),
      );
      return next;
    }),
  );
}
