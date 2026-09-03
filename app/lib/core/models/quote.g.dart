// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuoteBoxLineImpl _$$QuoteBoxLineImplFromJson(Map<String, dynamic> json) =>
    _$QuoteBoxLineImpl(
      size: $enumDecode(_$BoxSizeEnumMap, json['size']),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$QuoteBoxLineImplToJson(_$QuoteBoxLineImpl instance) =>
    <String, dynamic>{
      'size': _$BoxSizeEnumMap[instance.size]!,
      'quantity': instance.quantity,
    };

const _$BoxSizeEnumMap = {
  BoxSize.small: 'small',
  BoxSize.medium: 'medium',
  BoxSize.large: 'large',
  BoxSize.xl: 'xl',
};

_$QuoteLooseItemImpl _$$QuoteLooseItemImplFromJson(Map<String, dynamic> json) =>
    _$QuoteLooseItemImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      presetKey: json['presetKey'] as String? ?? '',
      description: json['description'] as String? ?? '',
      lengthM: (json['lengthM'] as num?)?.toDouble() ?? 0,
      widthM: (json['widthM'] as num?)?.toDouble() ?? 0,
      heightM: (json['heightM'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      monthlyZar: (json['monthlyZar'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$QuoteLooseItemImplToJson(
        _$QuoteLooseItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'presetKey': instance.presetKey,
      'description': instance.description,
      'lengthM': instance.lengthM,
      'widthM': instance.widthM,
      'heightM': instance.heightM,
      'quantity': instance.quantity,
      'monthlyZar': instance.monthlyZar,
    };

_$QuoteImpl _$$QuoteImplFromJson(Map<String, dynamic> json) => _$QuoteImpl(
      id: json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String,
      reference: json['reference'] as String? ?? '',
      clientId: json['clientId'] as String?,
      userId: json['userId'] as String?,
      status: $enumDecodeNullable(_$QuoteStatusEnumMap, json['status']) ??
          QuoteStatus.draft,
      boxes: (json['boxes'] as List<dynamic>?)
              ?.map((e) => QuoteBoxLine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      looseItems: (json['looseItems'] as List<dynamic>?)
              ?.map((e) => QuoteLooseItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      packingRequired: json['packingRequired'] as bool? ?? false,
      packers:
          (json['packers'] as num?)?.toInt() ?? QuotePricing.defaultPackers,
      packingHours: (json['packingHours'] as num?)?.toInt() ??
          QuotePricing.minPackingHours,
      vehicle: $enumDecodeNullable(_$VehicleSizeEnumMap, json['vehicle']) ??
          VehicleSize.mediumVan,
      contactName: json['contactName'] as String? ?? '',
      contactEmail: json['contactEmail'] as String? ?? '',
      contactPhone: json['contactPhone'] as String? ?? '',
      collectionAddress: json['collectionAddress'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      monthlyStorageZar: (json['monthlyStorageZar'] as num?)?.toInt() ?? 0,
      collectionZar: (json['collectionZar'] as num?)?.toInt() ?? 0,
      packingZar: (json['packingZar'] as num?)?.toInt() ?? 0,
      dueTodayZar: (json['dueTodayZar'] as num?)?.toInt() ?? 0,
      estimatedVolumeM3: (json['estimatedVolumeM3'] as num?)?.toDouble() ?? 0,
      jobId: json['jobId'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: const NullableTimestampConverter().fromJson(json['deletedAt']),
      acceptedAt:
          const NullableTimestampConverter().fromJson(json['acceptedAt']),
      createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
      updatedAt: const NullableTimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$QuoteImplToJson(_$QuoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'reference': instance.reference,
      'clientId': instance.clientId,
      'userId': instance.userId,
      'status': _$QuoteStatusEnumMap[instance.status]!,
      'boxes': instance.boxes.map((e) => e.toJson()).toList(),
      'looseItems': instance.looseItems.map((e) => e.toJson()).toList(),
      'packingRequired': instance.packingRequired,
      'packers': instance.packers,
      'packingHours': instance.packingHours,
      'vehicle': _$VehicleSizeEnumMap[instance.vehicle]!,
      'contactName': instance.contactName,
      'contactEmail': instance.contactEmail,
      'contactPhone': instance.contactPhone,
      'collectionAddress': instance.collectionAddress,
      'notes': instance.notes,
      'monthlyStorageZar': instance.monthlyStorageZar,
      'collectionZar': instance.collectionZar,
      'packingZar': instance.packingZar,
      'dueTodayZar': instance.dueTodayZar,
      'estimatedVolumeM3': instance.estimatedVolumeM3,
      'jobId': instance.jobId,
      'isDeleted': instance.isDeleted,
      'deletedAt':
          const NullableTimestampConverter().toJson(instance.deletedAt),
      'acceptedAt':
          const NullableTimestampConverter().toJson(instance.acceptedAt),
      'createdAt':
          const NullableTimestampConverter().toJson(instance.createdAt),
      'updatedAt':
          const NullableTimestampConverter().toJson(instance.updatedAt),
    };

const _$QuoteStatusEnumMap = {
  QuoteStatus.draft: 'draft',
  QuoteStatus.accepted: 'accepted',
  QuoteStatus.expired: 'expired',
  QuoteStatus.converted: 'converted',
  QuoteStatus.cancelled: 'cancelled',
};

const _$VehicleSizeEnumMap = {
  VehicleSize.smallVan: 'smallVan',
  VehicleSize.mediumVan: 'mediumVan',
  VehicleSize.largeTruck: 'largeTruck',
};
