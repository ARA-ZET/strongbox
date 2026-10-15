import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/enums/app_enums.dart';
import '../core/models/price_catalog.dart';
import 'repository_base.dart';

/// The admin-managed price list — one `priceLists/{tenantId}` document,
/// shared with the website. Prices are public, so the doc is world-readable;
/// only admins write it (firestore.rules).
abstract class PriceListRepository {
  /// Emits null until an admin first saves — callers fall back to the
  /// defaults in `PriceList.catalog`.
  Stream<PriceCatalog?> watch(String tenantId);

  /// Applies [change] to the stored list — or to [defaults] before the first
  /// save — and writes the result with an audit event, in one transaction.
  /// Reading inside the transaction means an edit always lands on the
  /// latest list, never on a stale copy the screen happened to hold.
  /// [change] may throw to abort without writing.
  Future<PriceCatalog> update(
    String tenantId,
    PriceCatalog Function(PriceCatalog current) change, {
    required PriceCatalog defaults,
    required String actorId,
  });
}

class FirestorePriceListRepository
    with FirestoreRepository
    implements PriceListRepository {
  FirestorePriceListRepository(this.db);

  @override
  final FirebaseFirestore db;

  DocumentReference<Map<String, dynamic>> _doc(String tenantId) =>
      col(Collections.priceLists).doc(tenantId);

  @override
  Stream<PriceCatalog?> watch(String tenantId) => _doc(tenantId)
      .snapshots()
      .map((doc) => doc.exists ? PriceCatalog.fromFirestore(doc) : null);

  @override
  Future<PriceCatalog> update(
    String tenantId,
    PriceCatalog Function(PriceCatalog current) change, {
    required PriceCatalog defaults,
    required String actorId,
  }) => guardRepo(
    () => db.runTransaction((tx) async {
      final snap = await tx.get(_doc(tenantId));
      final current = snap.exists ? PriceCatalog.fromFirestore(snap) : defaults;
      final next = change(current);
      tx.set(_doc(tenantId), {
        // The icon set is fixed by the website build, not stored.
        ...next.toJson()..remove('itemIcons'),
        'tenantId': tenantId,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': actorId,
      });
      tx.set(
        auditDoc(),
        auditEventData(
          tenantId: tenantId,
          actorId: actorId,
          action: AuditAction.priceListUpdated,
          entityType: 'priceList',
          entityId: tenantId,
          metadata: {
            'boxes': next.boxes.length,
            'looseItems': next.looseItems.length,
            'vehicles': next.vehicles.length,
          },
        ),
      );
      return next;
    }),
  );
}
