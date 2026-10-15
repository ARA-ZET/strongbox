// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VehicleImpl _$$VehicleImplFromJson(Map<String, dynamic> json) =>
    _$VehicleImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      type: $enumDecodeNullable(_$VehicleTypeEnumMap, json['type']) ??
          VehicleType.bakkie,
      name: json['name'] as String? ?? '',
      registration: json['registration'] as String? ?? '',
      make: json['make'] as String?,
      model: json['model'] as String?,
      year: (json['year'] as num?)?.toInt(),
      capacityM3: (json['capacityM3'] as num?)?.toDouble(),
      payloadKg: (json['payloadKg'] as num?)?.toInt(),
      status: $enumDecodeNullable(_$VehicleStatusEnumMap, json['status']) ??
          VehicleStatus.available,
      assignedDriverId: json['assignedDriverId'] as String?,
      licenceExpiresAt:
          const NullableTimestampConverter().fromJson(json['licenceExpiresAt']),
      notes: json['notes'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: const NullableTimestampConverter().fromJson(json['deletedAt']),
      createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
      updatedAt: const NullableTimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$VehicleImplToJson(_$VehicleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'type': _$VehicleTypeEnumMap[instance.type]!,
      'name': instance.name,
      'registration': instance.registration,
      'make': instance.make,
      'model': instance.model,
      'year': instance.year,
      'capacityM3': instance.capacityM3,
      'payloadKg': instance.payloadKg,
      'status': _$VehicleStatusEnumMap[instance.status]!,
      'assignedDriverId': instance.assignedDriverId,
      'licenceExpiresAt':
          const NullableTimestampConverter().toJson(instance.licenceExpiresAt),
      'notes': instance.notes,
      'isDeleted': instance.isDeleted,
      'deletedAt':
          const NullableTimestampConverter().toJson(instance.deletedAt),
      'createdAt':
          const NullableTimestampConverter().toJson(instance.createdAt),
      'updatedAt':
          const NullableTimestampConverter().toJson(instance.updatedAt),
    };

const _$VehicleTypeEnumMap = {
  VehicleType.car: 'car',
  VehicleType.bakkie: 'bakkie',
  VehicleType.van: 'van',
  VehicleType.truck: 'truck',
  VehicleType.trailer: 'trailer',
};

const _$VehicleStatusEnumMap = {
  VehicleStatus.available: 'available',
  VehicleStatus.maintenance: 'maintenance',
  VehicleStatus.outOfService: 'outOfService',
};
