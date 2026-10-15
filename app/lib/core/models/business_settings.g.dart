// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WindowHoursImpl _$$WindowHoursImplFromJson(Map<String, dynamic> json) =>
    _$WindowHoursImpl(
      start: json['start'] as String,
      end: json['end'] as String,
    );

Map<String, dynamic> _$$WindowHoursImplToJson(_$WindowHoursImpl instance) =>
    <String, dynamic>{
      'start': instance.start,
      'end': instance.end,
    };

_$BusinessSettingsImpl _$$BusinessSettingsImplFromJson(
        Map<String, dynamic> json) =>
    _$BusinessSettingsImpl(
      name: json['name'] as String? ?? 'StrongBox Logistics',
      contactPhone: json['contactPhone'] as String? ?? ContactInfo.phoneDisplay,
      contactEmail: json['contactEmail'] as String? ?? ContactInfo.email,
      address: json['address'] == null
          ? const Address()
          : Address.fromJson(json['address'] as Map<String, dynamic>),
      serviceArea: json['serviceArea'] as String? ?? 'Cape Town and surrounds',
      morning: json['morning'] == null
          ? const WindowHours(start: '08:00', end: '12:00')
          : WindowHours.fromJson(json['morning'] as Map<String, dynamic>),
      afternoon: json['afternoon'] == null
          ? const WindowHours(start: '12:00', end: '16:00')
          : WindowHours.fromJson(json['afternoon'] as Map<String, dynamic>),
      evening: json['evening'] == null
          ? const WindowHours(start: '16:00', end: '20:00')
          : WindowHours.fromJson(json['evening'] as Map<String, dynamic>),
      paymentInstructions: json['paymentInstructions'] as String? ?? '',
      updatedAt: const NullableTimestampConverter().fromJson(json['updatedAt']),
      updatedBy: json['updatedBy'] as String?,
    );

Map<String, dynamic> _$$BusinessSettingsImplToJson(
        _$BusinessSettingsImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'contactPhone': instance.contactPhone,
      'contactEmail': instance.contactEmail,
      'address': instance.address.toJson(),
      'serviceArea': instance.serviceArea,
      'morning': instance.morning.toJson(),
      'afternoon': instance.afternoon.toJson(),
      'evening': instance.evening.toJson(),
      'paymentInstructions': instance.paymentInstructions,
      'updatedAt':
          const NullableTimestampConverter().toJson(instance.updatedAt),
      'updatedBy': instance.updatedBy,
    };
