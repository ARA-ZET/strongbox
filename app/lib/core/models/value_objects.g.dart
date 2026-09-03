// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'value_objects.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AddressImpl _$$AddressImplFromJson(Map<String, dynamic> json) =>
    _$AddressImpl(
      line1: json['line1'] as String? ?? '',
      line2: json['line2'] as String?,
      city: json['city'] as String? ?? '',
      state: json['state'] as String?,
      postCode: json['postCode'] as String? ?? '',
      country: json['country'] as String? ?? 'ZA',
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$AddressImplToJson(_$AddressImpl instance) =>
    <String, dynamic>{
      'line1': instance.line1,
      'line2': instance.line2,
      'city': instance.city,
      'state': instance.state,
      'postCode': instance.postCode,
      'country': instance.country,
      'lat': instance.lat,
      'lng': instance.lng,
    };

_$NotificationPrefsImpl _$$NotificationPrefsImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationPrefsImpl(
      pickupStartedEmail: json['pickupStartedEmail'] as bool? ?? true,
      pickupStartedSms: json['pickupStartedSms'] as bool? ?? false,
      deliveryCompletedEmail: json['deliveryCompletedEmail'] as bool? ?? true,
      deliveryCompletedSms: json['deliveryCompletedSms'] as bool? ?? true,
      invoiceReadyEmail: json['invoiceReadyEmail'] as bool? ?? true,
      invoiceReadySms: json['invoiceReadySms'] as bool? ?? false,
      storageThresholdEmail: json['storageThresholdEmail'] as bool? ?? true,
      storageThresholdSms: json['storageThresholdSms'] as bool? ?? false,
    );

Map<String, dynamic> _$$NotificationPrefsImplToJson(
        _$NotificationPrefsImpl instance) =>
    <String, dynamic>{
      'pickupStartedEmail': instance.pickupStartedEmail,
      'pickupStartedSms': instance.pickupStartedSms,
      'deliveryCompletedEmail': instance.deliveryCompletedEmail,
      'deliveryCompletedSms': instance.deliveryCompletedSms,
      'invoiceReadyEmail': instance.invoiceReadyEmail,
      'invoiceReadySms': instance.invoiceReadySms,
      'storageThresholdEmail': instance.storageThresholdEmail,
      'storageThresholdSms': instance.storageThresholdSms,
    };

_$BreakPeriodImpl _$$BreakPeriodImplFromJson(Map<String, dynamic> json) =>
    _$BreakPeriodImpl(
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
    );

Map<String, dynamic> _$$BreakPeriodImplToJson(_$BreakPeriodImpl instance) =>
    <String, dynamic>{
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
    };
