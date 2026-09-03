import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/enums/app_enums.dart';
import '../core/models/issue_report.dart';
import 'repository_base.dart';

/// Driver-submitted maintenance/support reports (doc 09).
abstract class IssueRepository {
  Future<String> create({
    required String tenantId,
    required String driverId,
    required IssueType issueType,
    required String description,
    required List<String> photoIds,
    required bool isUrgent,
    String? jobId,
  });
  Stream<List<IssueReport>> watchAll(String tenantId);
}

class FirestoreIssueRepository
    with FirestoreRepository
    implements IssueRepository {
  FirestoreIssueRepository(this.db);

  @override
  final FirebaseFirestore db;

  CollectionReference<Map<String, dynamic>> get _issues =>
      col(Collections.issueReports);

  @override
  Future<String> create({
    required String tenantId,
    required String driverId,
    required IssueType issueType,
    required String description,
    required List<String> photoIds,
    required bool isUrgent,
    String? jobId,
  }) =>
      guardRepo(() async {
        final doc = _issues.doc();
        await doc.set({
          'tenantId': tenantId,
          'driverId': driverId,
          'jobId': jobId,
          'issueType': issueType.name,
          'description': description,
          'photoIds': photoIds,
          'isUrgent': isUrgent,
          'status': IssueStatus.open.name,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await col(Collections.auditEvents).add(auditEventData(
          tenantId: tenantId,
          actorId: driverId,
          actorRole: UserRole.driver,
          action: AuditAction.issueReported,
          entityType: 'issueReport',
          entityId: doc.id,
          metadata: {'issueType': issueType.name, 'isUrgent': isUrgent},
        ));
        return doc.id;
      });

  @override
  Stream<List<IssueReport>> watchAll(String tenantId) => _issues
      .where('tenantId', isEqualTo: tenantId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(IssueReport.fromFirestore).toList());
}
