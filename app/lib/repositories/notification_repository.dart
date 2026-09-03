import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/enums/app_enums.dart';
import '../core/models/app_notification.dart';
import '../core/models/audit_event.dart';
import 'repository_base.dart';

/// Alert-centre feed (doc 22). v1 sources the admin feed from the audit
/// trail; targeted notifications live in the `notifications` collection
/// (delivery via FCM lands in Stage 7).
abstract class NotificationRepository {
  Stream<List<AuditEvent>> watchFeed(String tenantId, {int limit = 50});
  Stream<List<AppNotification>> watchForUser(String tenantId, String userId);

  /// Writes a notification doc. [userId] null = broadcast to admins.
  Future<void> create({
    required String tenantId,
    required NotificationType type,
    required String title,
    required String body,
    String? userId,
    String? entityType,
    String? entityId,
  });
}

class FirestoreNotificationRepository
    with FirestoreRepository
    implements NotificationRepository {
  FirestoreNotificationRepository(this.db);

  @override
  final FirebaseFirestore db;

  @override
  Stream<List<AuditEvent>> watchFeed(String tenantId, {int limit = 50}) =>
      col(Collections.auditEvents)
          .where('tenantId', isEqualTo: tenantId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .snapshots()
          .map((snap) => snap.docs.map(AuditEvent.fromFirestore).toList());

  @override
  Stream<List<AppNotification>> watchForUser(
          String tenantId, String userId) =>
      col(Collections.notifications)
          .where('tenantId', isEqualTo: tenantId)
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snap) {
        final list = snap.docs.map(AppNotification.fromFirestore).toList()
          ..sort((a, b) => (b.createdAt ?? DateTime(0))
              .compareTo(a.createdAt ?? DateTime(0)));
        return list;
      });

  @override
  Future<void> create({
    required String tenantId,
    required NotificationType type,
    required String title,
    required String body,
    String? userId,
    String? entityType,
    String? entityId,
  }) =>
      guardRepo(() => col(Collections.notifications).add({
            'tenantId': tenantId,
            'type': type.name,
            'title': title,
            'body': body,
            'userId': userId,
            'entityType': entityType,
            'entityId': entityId,
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          }));
}
