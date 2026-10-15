// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuditEventImpl _$$AuditEventImplFromJson(Map<String, dynamic> json) =>
    _$AuditEventImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      actorId: json['actorId'] as String? ?? '',
      actorRole: $enumDecodeNullable(_$UserRoleEnumMap, json['actorRole']) ??
          UserRole.admin,
      action: $enumDecode(_$AuditActionEnumMap, json['action']),
      entityType: json['entityType'] as String? ?? '',
      entityId: json['entityId'] as String? ?? '',
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      timestamp: const NullableTimestampConverter().fromJson(json['timestamp']),
    );

Map<String, dynamic> _$$AuditEventImplToJson(_$AuditEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'actorId': instance.actorId,
      'actorRole': _$UserRoleEnumMap[instance.actorRole]!,
      'action': _$AuditActionEnumMap[instance.action]!,
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'metadata': instance.metadata,
      'timestamp':
          const NullableTimestampConverter().toJson(instance.timestamp),
    };

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.driver: 'driver',
  UserRole.client: 'client',
};

const _$AuditActionEnumMap = {
  AuditAction.qrScanned: 'qrScanned',
  AuditAction.qrLinked: 'qrLinked',
  AuditAction.qrGenerated: 'qrGenerated',
  AuditAction.unitCreated: 'unitCreated',
  AuditAction.unitUpdated: 'unitUpdated',
  AuditAction.unitStatusChanged: 'unitStatusChanged',
  AuditAction.unitArchived: 'unitArchived',
  AuditAction.photoUploaded: 'photoUploaded',
  AuditAction.jobCreated: 'jobCreated',
  AuditAction.jobAssigned: 'jobAssigned',
  AuditAction.jobStarted: 'jobStarted',
  AuditAction.jobCompleted: 'jobCompleted',
  AuditAction.jobCancelled: 'jobCancelled',
  AuditAction.clientSignOff: 'clientSignOff',
  AuditAction.subscriptionCreated: 'subscriptionCreated',
  AuditAction.subscriptionUpdated: 'subscriptionUpdated',
  AuditAction.subscriptionCancelled: 'subscriptionCancelled',
  AuditAction.adminImpersonated: 'adminImpersonated',
  AuditAction.issueReported: 'issueReported',
  AuditAction.shiftStarted: 'shiftStarted',
  AuditAction.shiftEnded: 'shiftEnded',
  AuditAction.quoteAccepted: 'quoteAccepted',
  AuditAction.priceListUpdated: 'priceListUpdated',
  AuditAction.userRoleChanged: 'userRoleChanged',
  AuditAction.settingsUpdated: 'settingsUpdated',
  AuditAction.invoiceIssued: 'invoiceIssued',
  AuditAction.invoicePaid: 'invoicePaid',
  AuditAction.invoiceVoided: 'invoiceVoided',
  AuditAction.vehicleAdded: 'vehicleAdded',
  AuditAction.vehicleUpdated: 'vehicleUpdated',
  AuditAction.vehicleRetired: 'vehicleRetired',
};
