import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/enums/app_enums.dart';
import '../core/models/app_notification.dart';
import '../core/models/audit_event.dart';
import 'repository_base.dart';

/// Alert-centre feed (doc 22). The admin feed is sourced from the audit
/// trail; targeted notifications live in the `notifications` collection,
/// and the `onNotificationCreated` Cloud Function pushes each one to the
/// recipient's devices (FCM) and, for clients, by email.
abstract class NotificationRepository {
  Stream<List<AuditEvent>> watchFeed(String tenantId, {int limit = 50});

  /// [userId]'s notifications, newest first.
  Stream<List<AppNotification>> watchForUser(String tenantId, String userId);

  /// Unread alerts addressed to every admin (`userId == null`).
  Stream<List<AppNotification>> watchAdminAlerts(String tenantId);

  /// Marks one notification read.
  Future<void> markRead(String notificationId);

  /// Marks every unread notification for [userId] read.
  Future<void> markAllRead(String tenantId, String userId);

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
        final list = snap.docs
            .map(AppNotification.fromFirestore)
            .where((n) => !n.isDeleted)
            .toList()
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
            'isDeleted': false,
            'createdAt': FieldValue.serverTimestamp(),
          }));

  @override
  Stream<List<AppNotification>> watchAdminAlerts(String tenantId) =>
      col(Collections.notifications)
          .where('tenantId', isEqualTo: tenantId)
          .where('userId', isNull: true)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((snap) {
        final list = snap.docs
            .map(AppNotification.fromFirestore)
            .where((n) => !n.isDeleted)
            .toList()
          ..sort((a, b) => (b.createdAt ?? DateTime(0))
              .compareTo(a.createdAt ?? DateTime(0)));
        return list;
      });

  @override
  Future<void> markRead(String notificationId) => guardRepo(() =>
      col(Collections.notifications).doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      }));

  @override
  Future<void> markAllRead(String tenantId, String userId) =>
      guardRepo(() async {
        final unread = await col(Collections.notifications)
            .where('tenantId', isEqualTo: tenantId)
            .where('userId', isEqualTo: userId)
            .where('isRead', isEqualTo: false)
            .get();
        // Batches cap at 500 writes.
        for (var i = 0; i < unread.docs.length; i += 500) {
          final batch = db.batch();
          for (final doc in unread.docs.skip(i).take(500)) {
            batch.update(doc.reference, {
              'isRead': true,
              'readAt': FieldValue.serverTimestamp(),
            });
          }
          await batch.commit();
        }
      });
}
