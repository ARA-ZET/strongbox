import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/errors/app_exception.dart';
import '../core/models/invoice.dart';
import 'repository_base.dart';

/// Billing reads for the client portal (doc 09). Subscription/invoice docs
/// are written by the Stripe webhook; checkout and the customer portal go
/// live with the Stripe extension in Stage 7.
abstract class SubscriptionRepository {
  Stream<List<Invoice>> watchInvoices(String tenantId, String clientId);
  Future<String> createCheckoutSession(String clientId, String priceId);
  Future<String> createPortalLink(String clientId);
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
        final invoices = snap.docs.map(Invoice.fromFirestore).toList()
          ..sort((a, b) => (b.createdAt ?? DateTime(0))
              .compareTo(a.createdAt ?? DateTime(0)));
        return invoices;
      });

  @override
  Future<String> createCheckoutSession(String clientId, String priceId) =>
      throw const AppException(
        code: 'not-available',
        message: 'Online checkout goes live with billing in Stage 7.',
      );

  @override
  Future<String> createPortalLink(String clientId) =>
      throw const AppException(
        code: 'not-available',
        message: 'The billing portal goes live with billing in Stage 7.',
      );
}
