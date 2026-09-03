import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/app_enums.dart';
import '../utils/timestamp_converter.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

/// An in-app notification / alert-centre entry (doc 03, doc 22).
@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String tenantId,
    @Default(NotificationType.systemAlert) NotificationType type,
    @Default('') String title,
    @Default('') String body,
    String? entityType,
    String? entityId,
    /// Target user; null = broadcast to all admins.
    String? userId,
    @Default(false) bool isRead,
    @NullableTimestampConverter() DateTime? createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);

  factory AppNotification.fromFirestore(DocumentSnapshot doc) =>
      AppNotification.fromJson(
          {...doc.data()! as Map<String, dynamic>, 'id': doc.id});
}
