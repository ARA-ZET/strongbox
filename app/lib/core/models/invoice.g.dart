// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvoiceImpl _$$InvoiceImplFromJson(Map<String, dynamic> json) =>
    _$InvoiceImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      clientId: json['clientId'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'zar',
      status: $enumDecodeNullable(_$PaymentStatusEnumMap, json['status']) ??
          PaymentStatus.open,
      description: json['description'] as String?,
      pdfUrl: json['pdfUrl'] as String?,
      periodStart:
          const NullableTimestampConverter().fromJson(json['periodStart']),
      periodEnd: const NullableTimestampConverter().fromJson(json['periodEnd']),
      createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$$InvoiceImplToJson(_$InvoiceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'clientId': instance.clientId,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': _$PaymentStatusEnumMap[instance.status]!,
      'description': instance.description,
      'pdfUrl': instance.pdfUrl,
      'periodStart':
          const NullableTimestampConverter().toJson(instance.periodStart),
      'periodEnd':
          const NullableTimestampConverter().toJson(instance.periodEnd),
      'createdAt':
          const NullableTimestampConverter().toJson(instance.createdAt),
    };

const _$PaymentStatusEnumMap = {
  PaymentStatus.paid: 'paid',
  PaymentStatus.open: 'open',
  PaymentStatus.voided: 'voided',
  PaymentStatus.uncollectible: 'uncollectible',
};
