// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_code.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QRCodeImpl _$$QRCodeImplFromJson(Map<String, dynamic> json) => _$QRCodeImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      batchId: json['batchId'] as String? ?? '',
      storageUnitId: json['storageUnitId'] as String?,
      isLinked: json['isLinked'] as bool? ?? false,
      linkedAt: const NullableTimestampConverter().fromJson(json['linkedAt']),
      linkedBy: json['linkedBy'] as String?,
      createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$$QRCodeImplToJson(_$QRCodeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'batchId': instance.batchId,
      'storageUnitId': instance.storageUnitId,
      'isLinked': instance.isLinked,
      'linkedAt': const NullableTimestampConverter().toJson(instance.linkedAt),
      'linkedBy': instance.linkedBy,
      'createdAt':
          const NullableTimestampConverter().toJson(instance.createdAt),
    };

_$QRBatchImpl _$$QRBatchImplFromJson(Map<String, dynamic> json) =>
    _$QRBatchImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      count: (json['count'] as num?)?.toInt() ?? 0,
      codeIds: (json['codeIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      linkedCount: (json['linkedCount'] as num?)?.toInt() ?? 0,
      printResolution: json['printResolution'] as String? ?? '300dpi',
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$$QRBatchImplToJson(_$QRBatchImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'count': instance.count,
      'codeIds': instance.codeIds,
      'linkedCount': instance.linkedCount,
      'printResolution': instance.printResolution,
      'createdBy': instance.createdBy,
      'createdAt':
          const NullableTimestampConverter().toJson(instance.createdAt),
    };
