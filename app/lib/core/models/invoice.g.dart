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
      reference: json['reference'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'zar',
      status: $enumDecodeNullable(_$PaymentStatusEnumMap, json['status']) ??
          PaymentStatus.open,
      description: json['description'] as String?,
      lines: (json['lines'] as List<dynamic>?)
              ?.map((e) => InvoiceLine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      unitCount: (json['unitCount'] as num?)?.toInt() ?? 0,
      unpricedUnitCount: (json['unpricedUnitCount'] as num?)?.toInt() ?? 0,
      pdfUrl: json['pdfUrl'] as String?,
      periodStart:
          const NullableTimestampConverter().fromJson(json['periodStart']),
      periodEnd: const NullableTimestampConverter().fromJson(json['periodEnd']),
      dueAt: const NullableTimestampConverter().fromJson(json['dueAt']),
      paidAt: const NullableTimestampConverter().fromJson(json['paidAt']),
      paidBy: json['paidBy'] as String?,
      paymentNote: json['paymentNote'] as String?,
      voidReason: json['voidReason'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
      updatedAt: const NullableTimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$InvoiceImplToJson(_$InvoiceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'clientId': instance.clientId,
      'reference': instance.reference,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': _$PaymentStatusEnumMap[instance.status]!,
      'description': instance.description,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
      'unitCount': instance.unitCount,
      'unpricedUnitCount': instance.unpricedUnitCount,
      'pdfUrl': instance.pdfUrl,
      'periodStart':
          const NullableTimestampConverter().toJson(instance.periodStart),
      'periodEnd':
          const NullableTimestampConverter().toJson(instance.periodEnd),
      'dueAt': const NullableTimestampConverter().toJson(instance.dueAt),
      'paidAt': const NullableTimestampConverter().toJson(instance.paidAt),
      'paidBy': instance.paidBy,
      'paymentNote': instance.paymentNote,
      'voidReason': instance.voidReason,
      'isDeleted': instance.isDeleted,
      'createdAt':
          const NullableTimestampConverter().toJson(instance.createdAt),
      'updatedAt':
          const NullableTimestampConverter().toJson(instance.updatedAt),
    };

const _$PaymentStatusEnumMap = {
  PaymentStatus.paid: 'paid',
  PaymentStatus.open: 'open',
  PaymentStatus.voided: 'voided',
  PaymentStatus.uncollectible: 'uncollectible',
};

_$InvoiceLineImpl _$$InvoiceLineImplFromJson(Map<String, dynamic> json) =>
    _$InvoiceLineImpl(
      unitId: json['unitId'] as String,
      qrCodeId: json['qrCodeId'] as String? ?? '',
      label: json['label'] as String? ?? '',
      priceKey: json['priceKey'] as String?,
      rateZar: (json['rateZar'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$InvoiceLineImplToJson(_$InvoiceLineImpl instance) =>
    <String, dynamic>{
      'unitId': instance.unitId,
      'qrCodeId': instance.qrCodeId,
      'label': instance.label,
      'priceKey': instance.priceKey,
      'rateZar': instance.rateZar,
    };
