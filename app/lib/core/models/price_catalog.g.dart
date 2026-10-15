// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_catalog.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BoxPriceImpl _$$BoxPriceImplFromJson(Map<String, dynamic> json) =>
    _$BoxPriceImpl(
      id: json['id'] as String,
      label: json['label'] as String,
      description: json['desc'] as String? ?? '',
      monthlyZar: (json['price'] as num).toInt(),
      active: json['active'] as bool? ?? true,
    );

Map<String, dynamic> _$$BoxPriceImplToJson(_$BoxPriceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'desc': instance.description,
      'price': instance.monthlyZar,
      'active': instance.active,
    };

_$LooseItemPriceImpl _$$LooseItemPriceImplFromJson(Map<String, dynamic> json) =>
    _$LooseItemPriceImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String? ?? 'inventory_2',
      monthlyZar: (json['price'] as num).toInt(),
      active: json['active'] as bool? ?? true,
    );

Map<String, dynamic> _$$LooseItemPriceImplToJson(
        _$LooseItemPriceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'icon': instance.icon,
      'price': instance.monthlyZar,
      'active': instance.active,
    };

_$VehiclePriceImpl _$$VehiclePriceImplFromJson(Map<String, dynamic> json) =>
    _$VehiclePriceImpl(
      id: json['id'] as String,
      label: json['label'] as String,
      description: json['desc'] as String? ?? '',
      capacityM3: (json['capacityM3'] as num?)?.toDouble() ?? 0.0,
      onceOffZar: (json['price'] as num).toInt(),
      recommended: json['recommended'] as bool? ?? false,
      icon: json['icon'] as String? ?? 'local_shipping',
      active: json['active'] as bool? ?? true,
    );

Map<String, dynamic> _$$VehiclePriceImplToJson(_$VehiclePriceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'desc': instance.description,
      'capacityM3': instance.capacityM3,
      'price': instance.onceOffZar,
      'recommended': instance.recommended,
      'icon': instance.icon,
      'active': instance.active,
    };

_$PriceCatalogImpl _$$PriceCatalogImplFromJson(Map<String, dynamic> json) =>
    _$PriceCatalogImpl(
      boxes: (json['boxes'] as List<dynamic>?)
              ?.map((e) => BoxPrice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      looseItemCategories: (json['looseItemCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      looseItems: (json['looseItems'] as List<dynamic>?)
              ?.map((e) => LooseItemPrice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      itemIcons: (json['itemIcons'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      vehicles: (json['vehicles'] as List<dynamic>?)
              ?.map((e) => VehiclePrice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      updatedAt: const NullableTimestampConverter().fromJson(json['updatedAt']),
      updatedBy: json['updatedBy'] as String?,
    );

Map<String, dynamic> _$$PriceCatalogImplToJson(_$PriceCatalogImpl instance) =>
    <String, dynamic>{
      'boxes': instance.boxes.map((e) => e.toJson()).toList(),
      'looseItemCategories': instance.looseItemCategories,
      'looseItems': instance.looseItems.map((e) => e.toJson()).toList(),
      'itemIcons': instance.itemIcons,
      'vehicles': instance.vehicles.map((e) => e.toJson()).toList(),
      'updatedAt':
          const NullableTimestampConverter().toJson(instance.updatedAt),
      'updatedBy': instance.updatedBy,
    };
