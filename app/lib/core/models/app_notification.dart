// ignore_for_file: invalid_annotation_target
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
    // Types added after this build still parse rather than break the feed.
    @JsonKey(unknownEnumValue: NotificationType.systemAlert)
    @Default(NotificationType.systemAlert)
    NotificationType type,
    @Default('') String title,
    @Default('') String body,
    String? entityType,
    String? entityId,
    /// Target user; null = broadcast to all admins.
    String? userId,
    /// Where tapping it goes — set by Cloud Functions for the recipient's
    /// role; null for alerts with nowhere to open.
    String? route,
    @Default(false) bool isRead,
    @Default(false) bool isDeleted,
    @NullableTimestampConverter() DateTime? createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);

  factory AppNotification.fromFirestore(DocumentSnapshot doc) =>
      AppNotification.fromJson(
          {...doc.data()! as Map<String, dynamic>, 'id': doc.id});
}
