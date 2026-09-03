import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/app_enums.dart';
import '../utils/timestamp_converter.dart';

part 'invoice.freezed.dart';
part 'invoice.g.dart';

/// A billing record (doc 03). Written by the Stripe webhook in Stage 7;
/// the client portal only ever reads these.
@freezed
class Invoice with _$Invoice {
  const factory Invoice({
    required String id,
    required String tenantId,
    required String clientId,
    @Default(0) double amount,
    @Default('zar') String currency,
    @Default(PaymentStatus.open) PaymentStatus status,
    String? description,
    String? pdfUrl,
    @NullableTimestampConverter() DateTime? periodStart,
    @NullableTimestampConverter() DateTime? periodEnd,
    @NullableTimestampConverter() DateTime? createdAt,
  }) = _Invoice;

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);

  factory Invoice.fromFirestore(DocumentSnapshot doc) =>
      Invoice.fromJson({...doc.data()! as Map<String, dynamic>, 'id': doc.id});
}
