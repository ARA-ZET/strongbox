import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/models/audit_event.dart';
import 'repository_base.dart';

/// Append-only audit trail (doc 09). No update or delete — by design.
abstract class AuditRepository {
  Future<void> log(Map<String, dynamic> eventData);
  Stream<List<AuditEvent>> watchAll(String tenantId, {int limit = 50});
  Stream<List<AuditEvent>> watchForEntity(String entityId, {int limit = 20});
}

class FirestoreAuditRepository
    with FirestoreRepository
    implements AuditRepository {
  FirestoreAuditRepository(this.db);

  @override
  final FirebaseFirestore db;

  @override
  Future<void> log(Map<String, dynamic> eventData) =>
      guardRepo(() => col(Collections.auditEvents).add(eventData));

  @override
  Stream<List<AuditEvent>> watchAll(String tenantId, {int limit = 50}) {
    return col(Collections.auditEvents)
        .where('tenantId', isEqualTo: tenantId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map(AuditEvent.fromFirestore).toList());
  }

  @override
  Stream<List<AuditEvent>> watchForEntity(String entityId, {int limit = 20}) {
    return col(Collections.auditEvents)
        .where('entityId', isEqualTo: entityId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map(AuditEvent.fromFirestore).toList());
  }
}
