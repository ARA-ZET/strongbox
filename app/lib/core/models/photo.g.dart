// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PhotoImpl _$$PhotoImplFromJson(Map<String, dynamic> json) => _$PhotoImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      storageUrl: json['storageUrl'] as String? ?? '',
      storagePath: json['storagePath'] as String? ?? '',
      type: $enumDecodeNullable(_$PhotoTypeEnumMap, json['type']) ??
          PhotoType.exterior,
      entityType: json['entityType'] as String? ?? '',
      entityId: json['entityId'] as String? ?? '',
      jobId: json['jobId'] as String?,
      uploadedBy: json['uploadedBy'] as String? ?? '',
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: const NullableTimestampConverter().fromJson(json['deletedAt']),
      createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$$PhotoImplToJson(_$PhotoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'storageUrl': instance.storageUrl,
      'storagePath': instance.storagePath,
      'type': _$PhotoTypeEnumMap[instance.type]!,
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'jobId': instance.jobId,
      'uploadedBy': instance.uploadedBy,
      'isDeleted': instance.isDeleted,
      'deletedAt':
          const NullableTimestampConverter().toJson(instance.deletedAt),
      'createdAt':
          const NullableTimestampConverter().toJson(instance.createdAt),
    };

const _$PhotoTypeEnumMap = {
  PhotoType.exterior: 'exterior',
  PhotoType.interior: 'interior',
  PhotoType.driverCapture: 'driverCapture',
  PhotoType.signature: 'signature',
};
