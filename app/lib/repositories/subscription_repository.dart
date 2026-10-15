import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/enums/app_enums.dart';
import '../core/errors/app_exception.dart';
import '../core/models/invoice.dart';
import 'repository_base.dart';

/// Monthly storage invoices (doc 09, doc 23).
///
/// Invoices are issued by the `monthlyInvoices` Cloud Function. Clients pay
/// by EFT; an admin records the payment here. Settling an invoice moves the
/// client's billing status — the `onInvoiceUpdated` function does that, so
/// the app never writes `subscriptionStatus` itself (rule 25).
abstract class SubscriptionRepository {
  /// A client's invoices, newest first.
  Stream<List<Invoice>> watchInvoices(String tenantId, String clientId);

  /// Records that an open invoice was paid.
  Future<void> markPaid(Invoice invoice,
      {required String actorId, String? note});

  /// Cancels an open invoice that should not be paid (billed in error).
  Future<void> voidInvoice(Invoice invoice,
      {required String actorId, required String reason});
}

class FirestoreSubscriptionRepository
    with FirestoreRepository
    implements SubscriptionRepository {
  FirestoreSubscriptionRepository(this.db);

  @override
  final FirebaseFirestore db;

  @override
  Stream<List<Invoice>> watchInvoices(String tenantId, String clientId) =>
      col(Collections.invoices)
          .where('tenantId', isEqualTo: tenantId)
          .where('clientId', isEqualTo: clientId)
          .snapshots()
          .map((snap) {
        final invoices = snap.docs
            .map(Invoice.fromFirestore)
            .where((invoice) => !invoice.isDeleted)
            .toList()
          ..sort((a, b) => (b.periodStart ?? b.createdAt ?? DateTime(0))
              .compareTo(a.periodStart ?? a.createdAt ?? DateTime(0)));
        return invoices;
      });

  @override
  Future<void> markPaid(Invoice invoice,
          {required String actorId, String? note}) =>
      _settle(invoice, PaymentStatus.paid,
          actorId: actorId,
          action: AuditAction.invoicePaid,
          fields: {
            'paidAt': FieldValue.serverTimestamp(),
            'paidBy': actorId,
            if (note != null && note.trim().isNotEmpty)
              'paymentNote': note.trim(),
          });

  @override
  Future<void> voidInvoice(Invoice invoice,
          {required String actorId, required String reason}) =>
      _settle(invoice, PaymentStatus.voided,
          actorId: actorId,
          action: AuditAction.invoiceVoided,
          fields: {'voidReason': reason.trim()});

  /// Moves an open invoice to [status] with its audit event, in one
  /// transaction that re-checks it is still open (rules 6, 7).
  Future<void> _settle(
    Invoice invoice,
    PaymentStatus status, {
    required String actorId,
    required AuditAction action,
    required Map<String, dynamic> fields,
  }) =>
      guardRepo(() => db.runTransaction((tx) async {
            final ref = col(Collections.invoices).doc(invoice.id);
            final current = await tx.get(ref);
            if (current.data()?['status'] != PaymentStatus.open.name) {
              throw const AppException(
                code: 'failed-precondition',
                message: 'This invoice is no longer open.',
              );
            }
            tx.update(ref, {
              ...fields,
              'status': status.name,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            tx.set(
              auditDoc(),
              auditEventData(
                tenantId: invoice.tenantId,
                actorId: actorId,
                action: action,
                entityType: 'client',
                entityId: invoice.clientId,
                metadata: {
                  'invoiceId': invoice.id,
                  'reference': invoice.reference,
                  'amount': invoice.amount,
                },
              ),
            );
          }));
}
