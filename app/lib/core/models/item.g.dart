// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ItemImpl _$$ItemImplFromJson(Map<String, dynamic> json) => _$ItemImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      storageUnitId: json['storageUnitId'] as String,
      clientId: json['clientId'] as String,
      qrCodeId: json['qrCodeId'] as String? ?? '',
      label: json['label'] as String? ?? '',
      description: json['description'] as String?,
      photoIds: (json['photoIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      status: $enumDecodeNullable(_$StorageStatusEnumMap, json['status']) ??
          StorageStatus.inStorage,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: const NullableTimestampConverter().fromJson(json['deletedAt']),
      createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
      updatedAt: const NullableTimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$ItemImplToJson(_$ItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'storageUnitId': instance.storageUnitId,
      'clientId': instance.clientId,
      'qrCodeId': instance.qrCodeId,
      'label': instance.label,
      'description': instance.description,
      'photoIds': instance.photoIds,
      'tags': instance.tags,
      'status': _$StorageStatusEnumMap[instance.status]!,
      'isDeleted': instance.isDeleted,
      'deletedAt':
          const NullableTimestampConverter().toJson(instance.deletedAt),
      'createdAt':
          const NullableTimestampConverter().toJson(instance.createdAt),
      'updatedAt':
          const NullableTimestampConverter().toJson(instance.updatedAt),
    };

const _$StorageStatusEnumMap = {
  StorageStatus.pendingPickup: 'pendingPickup',
  StorageStatus.inTransit: 'inTransit',
  StorageStatus.inStorage: 'inStorage',
  StorageStatus.pendingDelivery: 'pendingDelivery',
  StorageStatus.delivered: 'delivered',
  StorageStatus.cancelled: 'cancelled',
  StorageStatus.archived: 'archived',
};
