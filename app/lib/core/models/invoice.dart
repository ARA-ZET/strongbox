import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/app_enums.dart';
import '../utils/timestamp_converter.dart';

part 'invoice.freezed.dart';
part 'invoice.g.dart';

/// One client's monthly storage invoice (doc 03, doc 23).
///
/// Issued on the 1st of each month by the `monthlyInvoices` Cloud Function —
/// one line per billable unit at its recorded rate. Clients pay by EFT
/// quoting [reference]; an admin then marks it [PaymentStatus.paid]. The app
/// never creates invoices or changes amounts.
@freezed
class Invoice with _$Invoice {
  const Invoice._();

  const factory Invoice({
    required String id,
    required String tenantId,
    required String clientId,

    /// EFT reference, e.g. `INV-202611-AB12CD`.
    @Default('') String reference,

    /// Rand, VAT inclusive.
    @Default(0) double amount,
    @Default('zar') String currency,
    @Default(PaymentStatus.open) PaymentStatus status,
    String? description,
    @Default([]) List<InvoiceLine> lines,
    @Default(0) int unitCount,

    /// Billable units with no size — not on this invoice.
    @Default(0) int unpricedUnitCount,
    String? pdfUrl,
    @NullableTimestampConverter() DateTime? periodStart,
    @NullableTimestampConverter() DateTime? periodEnd,
    @NullableTimestampConverter() DateTime? dueAt,
    @NullableTimestampConverter() DateTime? paidAt,
    String? paidBy,

    /// How it was paid, e.g. "EFT 12 Nov, FNB ref 8841".
    String? paymentNote,
    String? voidReason,
    @Default(false) bool isDeleted,
    @NullableTimestampConverter() DateTime? createdAt,
    @NullableTimestampConverter() DateTime? updatedAt,
  }) = _Invoice;

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);

  factory Invoice.fromFirestore(DocumentSnapshot doc) =>
      Invoice.fromJson({...doc.data()! as Map<String, dynamic>, 'id': doc.id});

  bool get isOpen => status == PaymentStatus.open;

  /// Open and past its due date.
  bool isOverdue(DateTime now) =>
      isOpen && dueAt != null && dueAt!.isBefore(now);
}

/// One storage unit on an [Invoice].
@freezed
class InvoiceLine with _$InvoiceLine {
  const factory InvoiceLine({
    required String unitId,
    @Default('') String qrCodeId,
    @Default('') String label,
    String? priceKey,
    @Default(0) int rateZar,
  }) = _InvoiceLine;

  factory InvoiceLine.fromJson(Map<String, dynamic> json) =>
      _$InvoiceLineFromJson(json);
}
