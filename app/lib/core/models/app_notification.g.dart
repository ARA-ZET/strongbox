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
      type: $enumDecodeNullable(_$NotificationTypeEnumMap, json['type'],
              unknownValue: NotificationType.systemAlert) ??
          NotificationType.systemAlert,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      entityType: json['entityType'] as String?,
      entityId: json['entityId'] as String?,
      userId: json['userId'] as String?,
      route: json['route'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
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
      'route': instance.route,
      'isRead': instance.isRead,
      'isDeleted': instance.isDeleted,
      'createdAt':
          const NullableTimestampConverter().toJson(instance.createdAt),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.jobScheduled: 'jobScheduled',
  NotificationType.jobAssigned: 'jobAssigned',
  NotificationType.jobStarted: 'jobStarted',
  NotificationType.jobCompleted: 'jobCompleted',
  NotificationType.jobCancelled: 'jobCancelled',
  NotificationType.pickupConfirmed: 'pickupConfirmed',
  NotificationType.deliveryCompleted: 'deliveryCompleted',
  NotificationType.deliveryRequested: 'deliveryRequested',
  NotificationType.invoiceReady: 'invoiceReady',
  NotificationType.invoicePaid: 'invoicePaid',
  NotificationType.storageThreshold: 'storageThreshold',
  NotificationType.qrUnlinkedAlert: 'qrUnlinkedAlert',
  NotificationType.issueReported: 'issueReported',
  NotificationType.directMessage: 'directMessage',
  NotificationType.systemAlert: 'systemAlert',
};
