// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_shift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DriverShiftImpl _$$DriverShiftImplFromJson(Map<String, dynamic> json) =>
    _$DriverShiftImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      driverId: json['driverId'] as String,
      startedAt: const NullableTimestampConverter().fromJson(json['startedAt']),
      endedAt: const NullableTimestampConverter().fromJson(json['endedAt']),
      breakPeriods: (json['breakPeriods'] as List<dynamic>?)
              ?.map((e) => BreakPeriod.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      vehicleId: json['vehicleId'] as String?,
      eIdQrCode: json['eIdQrCode'] as String? ?? '',
      jobIds: (json['jobIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      status: $enumDecodeNullable(_$ShiftStatusEnumMap, json['status']) ??
          ShiftStatus.active,
    );

Map<String, dynamic> _$$DriverShiftImplToJson(_$DriverShiftImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'driverId': instance.driverId,
      'startedAt':
          const NullableTimestampConverter().toJson(instance.startedAt),
      'endedAt': const NullableTimestampConverter().toJson(instance.endedAt),
      'breakPeriods': instance.breakPeriods.map((e) => e.toJson()).toList(),
      'vehicleId': instance.vehicleId,
      'eIdQrCode': instance.eIdQrCode,
      'jobIds': instance.jobIds,
      'status': _$ShiftStatusEnumMap[instance.status]!,
    };

const _$ShiftStatusEnumMap = {
  ShiftStatus.active: 'active',
  ShiftStatus.onBreak: 'onBreak',
  ShiftStatus.ended: 'ended',
};
