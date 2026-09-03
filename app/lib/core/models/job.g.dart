// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$JobImpl _$$JobImplFromJson(Map<String, dynamic> json) => _$JobImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      type:
          $enumDecodeNullable(_$JobTypeEnumMap, json['type']) ?? JobType.pickup,
      clientId: json['clientId'] as String,
      driverId: json['driverId'] as String?,
      status: $enumDecodeNullable(_$JobStatusEnumMap, json['status']) ??
          JobStatus.scheduled,
      scheduledDate:
          const NullableTimestampConverter().fromJson(json['scheduledDate']),
      timeWindow:
          $enumDecodeNullable(_$TimeWindowEnumMap, json['timeWindow']) ??
              TimeWindow.morning,
      address: json['address'] == null
          ? const Address()
          : Address.fromJson(json['address'] as Map<String, dynamic>),
      storageUnitIds: (json['storageUnitIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      scannedUnitIds: (json['scannedUnitIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      itemIds: (json['itemIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      notes: json['notes'] as String?,
      driverNotes: json['driverNotes'] as String?,
      photoIds: (json['photoIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      clientSignatureUrl: json['clientSignatureUrl'] as String?,
      clientConfirmMethod: json['clientConfirmMethod'] as String?,
      estimatedFee: (json['estimatedFee'] as num?)?.toDouble(),
      isRushJob: json['isRushJob'] as bool? ?? false,
      completedAt:
          const NullableTimestampConverter().fromJson(json['completedAt']),
      cancelledAt:
          const NullableTimestampConverter().fromJson(json['cancelledAt']),
      cancelReason: json['cancelReason'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
      updatedAt: const NullableTimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$JobImplToJson(_$JobImpl instance) => <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'type': _$JobTypeEnumMap[instance.type]!,
      'clientId': instance.clientId,
      'driverId': instance.driverId,
      'status': _$JobStatusEnumMap[instance.status]!,
      'scheduledDate':
          const NullableTimestampConverter().toJson(instance.scheduledDate),
      'timeWindow': _$TimeWindowEnumMap[instance.timeWindow]!,
      'address': instance.address.toJson(),
      'storageUnitIds': instance.storageUnitIds,
      'scannedUnitIds': instance.scannedUnitIds,
      'itemIds': instance.itemIds,
      'notes': instance.notes,
      'driverNotes': instance.driverNotes,
      'photoIds': instance.photoIds,
      'clientSignatureUrl': instance.clientSignatureUrl,
      'clientConfirmMethod': instance.clientConfirmMethod,
      'estimatedFee': instance.estimatedFee,
      'isRushJob': instance.isRushJob,
      'completedAt':
          const NullableTimestampConverter().toJson(instance.completedAt),
      'cancelledAt':
          const NullableTimestampConverter().toJson(instance.cancelledAt),
      'cancelReason': instance.cancelReason,
      'isDeleted': instance.isDeleted,
      'createdAt':
          const NullableTimestampConverter().toJson(instance.createdAt),
      'updatedAt':
          const NullableTimestampConverter().toJson(instance.updatedAt),
    };

const _$JobTypeEnumMap = {
  JobType.pickup: 'pickup',
  JobType.delivery: 'delivery',
};

const _$JobStatusEnumMap = {
  JobStatus.scheduled: 'scheduled',
  JobStatus.assigned: 'assigned',
  JobStatus.inProgress: 'inProgress',
  JobStatus.completed: 'completed',
  JobStatus.cancelled: 'cancelled',
};

const _$TimeWindowEnumMap = {
  TimeWindow.morning: 'morning',
  TimeWindow.afternoon: 'afternoon',
  TimeWindow.evening: 'evening',
};

_$JobEventImpl _$$JobEventImplFromJson(Map<String, dynamic> json) =>
    _$JobEventImpl(
      id: json['id'] as String,
      type: json['type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      actorId: json['actorId'] as String? ?? '',
      actorName: json['actorName'] as String? ?? '',
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      timestamp: const NullableTimestampConverter().fromJson(json['timestamp']),
    );

Map<String, dynamic> _$$JobEventImplToJson(_$JobEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'description': instance.description,
      'actorId': instance.actorId,
      'actorName': instance.actorName,
      'metadata': instance.metadata,
      'timestamp':
          const NullableTimestampConverter().toJson(instance.timestamp),
    };
