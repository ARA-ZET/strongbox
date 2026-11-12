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
      driverName: json['driverName'] as String?,
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
      pickupVehicleId: json['pickupVehicleId'] as String?,
      source: json['source'] as String?,
      fleetVehicleId: json['fleetVehicleId'] as String?,
      helperHours: (json['helperHours'] as num?)?.toInt() ?? 0,
      accessNotes: json['accessNotes'] as String?,
      supplies: (json['supplies'] as List<dynamic>?)
              ?.map((e) => SupplyLine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      emptyBoxes: (json['emptyBoxes'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      suppliesFirst: json['suppliesFirst'] as bool? ?? false,
      linkedJobId: json['linkedJobId'] as String?,
      onceOffZar: (json['onceOffZar'] as num?)?.toInt() ?? 0,
      invoicedIn: json['invoicedIn'] as String?,
      confirmedAt:
          const NullableTimestampConverter().fromJson(json['confirmedAt']),
      confirmedBy: json['confirmedBy'] as String?,
      departedAt:
          const NullableTimestampConverter().fromJson(json['departedAt']),
      arrivedAt: const NullableTimestampConverter().fromJson(json['arrivedAt']),
      collectedAt:
          const NullableTimestampConverter().fromJson(json['collectedAt']),
      receivedUnitIds: (json['receivedUnitIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      handedOverUnitIds: (json['handedOverUnitIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      recipientName: json['recipientName'] as String?,
      isRushJob: json['isRushJob'] as bool? ?? false,
      completedAt:
          const NullableTimestampConverter().fromJson(json['completedAt']),
      cancelledAt:
          const NullableTimestampConverter().fromJson(json['cancelledAt']),
      cancelReason: json['cancelReason'] as String?,
      cancelledBy: json['cancelledBy'] as String?,
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
      'driverName': instance.driverName,
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
      'pickupVehicleId': instance.pickupVehicleId,
      'source': instance.source,
      'fleetVehicleId': instance.fleetVehicleId,
      'helperHours': instance.helperHours,
      'accessNotes': instance.accessNotes,
      'supplies': instance.supplies.map((e) => e.toJson()).toList(),
      'emptyBoxes': instance.emptyBoxes,
      'suppliesFirst': instance.suppliesFirst,
      'linkedJobId': instance.linkedJobId,
      'onceOffZar': instance.onceOffZar,
      'invoicedIn': instance.invoicedIn,
      'confirmedAt':
          const NullableTimestampConverter().toJson(instance.confirmedAt),
      'confirmedBy': instance.confirmedBy,
      'departedAt':
          const NullableTimestampConverter().toJson(instance.departedAt),
      'arrivedAt':
          const NullableTimestampConverter().toJson(instance.arrivedAt),
      'collectedAt':
          const NullableTimestampConverter().toJson(instance.collectedAt),
      'receivedUnitIds': instance.receivedUnitIds,
      'handedOverUnitIds': instance.handedOverUnitIds,
      'recipientName': instance.recipientName,
      'isRushJob': instance.isRushJob,
      'completedAt':
          const NullableTimestampConverter().toJson(instance.completedAt),
      'cancelledAt':
          const NullableTimestampConverter().toJson(instance.cancelledAt),
      'cancelReason': instance.cancelReason,
      'cancelledBy': instance.cancelledBy,
      'isDeleted': instance.isDeleted,
      'createdAt':
          const NullableTimestampConverter().toJson(instance.createdAt),
      'updatedAt':
          const NullableTimestampConverter().toJson(instance.updatedAt),
    };

const _$JobTypeEnumMap = {
  JobType.pickup: 'pickup',
  JobType.delivery: 'delivery',
  JobType.supplyDrop: 'supplyDrop',
};

const _$JobStatusEnumMap = {
  JobStatus.pendingConfirmation: 'pendingConfirmation',
  JobStatus.scheduled: 'scheduled',
  JobStatus.assigned: 'assigned',
  JobStatus.inProgress: 'inProgress',
  JobStatus.collected: 'collected',
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
