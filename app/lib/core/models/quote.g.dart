// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuoteDraftImpl _$$QuoteDraftImplFromJson(Map<String, dynamic> json) =>
    _$QuoteDraftImpl(
      boxes: (json['boxes'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      loose: (json['loose'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      vehicleId: json['vehicleId'] as String?,
      supplies: (json['supplies'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      helperHours: (json['helperHours'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$QuoteDraftImplToJson(_$QuoteDraftImpl instance) =>
    <String, dynamic>{
      'boxes': instance.boxes,
      'loose': instance.loose,
      'vehicleId': instance.vehicleId,
      'supplies': instance.supplies,
      'helperHours': instance.helperHours,
    };
