// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StorageUnitImpl _$$StorageUnitImplFromJson(Map<String, dynamic> json) =>
    _$StorageUnitImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      clientId: json['clientId'] as String,
      qrCodeId: json['qrCodeId'] as String? ?? '',
      parentId: json['parentId'] as String?,
      type: $enumDecodeNullable(_$UnitTypeEnumMap, json['type']) ??
          UnitType.closed,
      label: json['label'] as String? ?? '',
      description: json['description'] as String?,
      status: $enumDecodeNullable(_$StorageStatusEnumMap, json['status']) ??
          StorageStatus.pendingPickup,
      photoIds: (json['photoIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      category: json['category'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      jobId: json['jobId'] as String?,
      warehouseLocationId: json['warehouseLocationId'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: const NullableTimestampConverter().fromJson(json['deletedAt']),
      createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
      updatedAt: const NullableTimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$StorageUnitImplToJson(_$StorageUnitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'clientId': instance.clientId,
      'qrCodeId': instance.qrCodeId,
      'parentId': instance.parentId,
      'type': _$UnitTypeEnumMap[instance.type]!,
      'label': instance.label,
      'description': instance.description,
      'status': _$StorageStatusEnumMap[instance.status]!,
      'photoIds': instance.photoIds,
      'tags': instance.tags,
      'category': instance.category,
      'weight': instance.weight,
      'jobId': instance.jobId,
      'warehouseLocationId': instance.warehouseLocationId,
      'isDeleted': instance.isDeleted,
      'deletedAt':
          const NullableTimestampConverter().toJson(instance.deletedAt),
      'createdAt':
          const NullableTimestampConverter().toJson(instance.createdAt),
      'updatedAt':
          const NullableTimestampConverter().toJson(instance.updatedAt),
    };

const _$UnitTypeEnumMap = {
  UnitType.closed: 'closed',
  UnitType.open: 'open',
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
