// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppNotificationImpl _$$AppNotificationImplFromJson(
        Map<String, dynamic> json) =>
    _$AppNotificationImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      type: $enumDecodeNullable(_$NotificationTypeEnumMap, json['type']) ??
          NotificationType.systemAlert,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      entityType: json['entityType'] as String?,
      entityId: json['entityId'] as String?,
      userId: json['userId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$$AppNotificationImplToJson(
        _$AppNotificationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'body': instance.body,
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'userId': instance.userId,
      'isRead': instance.isRead,
      'createdAt':
          const NullableTimestampConverter().toJson(instance.createdAt),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.jobScheduled: 'jobScheduled',
  NotificationType.jobStarted: 'jobStarted',
  NotificationType.jobCompleted: 'jobCompleted',
  NotificationType.pickupConfirmed: 'pickupConfirmed',
  NotificationType.deliveryCompleted: 'deliveryCompleted',
  NotificationType.invoiceReady: 'invoiceReady',
  NotificationType.storageThreshold: 'storageThreshold',
  NotificationType.qrUnlinkedAlert: 'qrUnlinkedAlert',
  NotificationType.issueReported: 'issueReported',
  NotificationType.systemAlert: 'systemAlert',
};
