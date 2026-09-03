import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/enums/app_enums.dart';
import '../core/models/job.dart';
import '../core/models/quote.dart';
import '../core/models/value_objects.dart';
import 'repository_base.dart';

/// Data access for storage quotes (doc 20).
///
/// A quote is built anonymously in the public calculator and lives only in
/// the client's browser until they accept it. Acceptance requires an
/// account, and writes the quote, its pickup job and the audit event in a
/// single batch (rules #6, #7).
abstract class QuoteRepository {
  /// Every quote for [clientId], newest first.
  Stream<List<Quote>> watchAll({
    required String tenantId,
    String? clientId,
    QuoteStatus? status,
  });

  Stream<Quote?> watchQuote(String id);
  Future<Quote?> getQuote(String id);

  /// Accepts [quote] on behalf of the signed-in client: persists it with
  /// totals snapshotted, opens the pickup job, and logs the audit event.
  /// Returns the accepted quote, with its id, reference and job id filled in.
  Future<Quote> accept(
    Quote quote, {
    required String actorId,
    DateTime? collectionDate,
    TimeWindow timeWindow = TimeWindow.morning,
  });

  /// Marks a quote cancelled. Soft state change only — quotes are never
  /// deleted so the pricing the client saw stays auditable.
  Future<void> cancel(String id, {required String actorId});
}

class FirestoreQuoteRepository
    with FirestoreRepository
    implements QuoteRepository {
  FirestoreQuoteRepository(this.db);

  @override
  final FirebaseFirestore db;

  CollectionReference<Map<String, dynamic>> get _quotes =>
      col(Collections.quotes);

  @override
  Stream<List<Quote>> watchAll({
    required String tenantId,
    String? clientId,
    QuoteStatus? status,
  }) {
    Query<Map<String, dynamic>> query = _quotes
        .where('tenantId', isEqualTo: tenantId)
        .where('isDeleted', isEqualTo: false);
    if (clientId != null) query = query.where('clientId', isEqualTo: clientId);
    if (status != null) query = query.where('status', isEqualTo: status.name);

    return query.snapshots().map((snap) {
      final quotes = snap.docs.map(Quote.fromFirestore).toList()
        ..sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
      return quotes;
    });
  }

  @override
  Stream<Quote?> watchQuote(String id) => _quotes
      .doc(id)
      .snapshots()
      .map((doc) => doc.exists ? Quote.fromFirestore(doc) : null);

  @override
  Future<Quote?> getQuote(String id) => guardRepo(() async {
        final doc = await _quotes.doc(id).get();
        return doc.exists ? Quote.fromFirestore(doc) : null;
      });

  @override
  Future<Quote> accept(
    Quote quote, {
    required String actorId,
    DateTime? collectionDate,
    TimeWindow timeWindow = TimeWindow.morning,
  }) =>
      guardRepo(() async {
        final quoteDoc = _quotes.doc();
        final jobDoc = col(Collections.jobs).doc();
        final clientId = quote.clientId ?? '';
        final accepted = quote.withSnapshottedTotals().copyWith(
              id: quoteDoc.id,
              reference: buildQuoteReference(quoteDoc.id),
              status: QuoteStatus.accepted,
              userId: actorId,
              jobId: jobDoc.id,
            );

        // The pickup carries no unit ids: the physical boxes do not exist
        // until ops link QR codes to them at collection.
        final job = Job(
          id: jobDoc.id,
          tenantId: quote.tenantId,
          type: JobType.pickup,
          clientId: clientId,
          status: JobStatus.scheduled,
          scheduledDate: collectionDate,
          timeWindow: timeWindow,
          address: Address(line1: quote.collectionAddress),
          notes: _jobNotes(accepted),
          estimatedFee: accepted.dueTodayZar.toDouble(),
        );

        final batch = db.batch()
          ..set(
            quoteDoc,
            accepted.toJson()
              ..remove('id')
              ..['acceptedAt'] = FieldValue.serverTimestamp()
              ..['createdAt'] = FieldValue.serverTimestamp()
              ..['updatedAt'] = FieldValue.serverTimestamp(),
          )
          ..set(
            jobDoc,
            job.toJson()
              ..remove('id')
              ..['createdAt'] = FieldValue.serverTimestamp()
              ..['updatedAt'] = FieldValue.serverTimestamp(),
          )
          ..set(
            auditDoc(),
            auditEventData(
              tenantId: quote.tenantId,
              actorId: actorId,
              actorRole: UserRole.client,
              action: AuditAction.quoteAccepted,
              entityType: 'quote',
              entityId: quoteDoc.id,
              metadata: {
                'reference': accepted.reference,
                'jobId': jobDoc.id,
                'monthlyZar': accepted.monthlyStorageZar,
                'dueTodayZar': accepted.dueTodayZar,
                'boxCount': accepted.boxCount,
                'looseItemCount': accepted.looseItems.length,
              },
            ),
          );
        await batch.commit();
        return accepted;
      });

  @override
  Future<void> cancel(String id, {required String actorId}) =>
      guardRepo(() async {
        await _quotes.doc(id).update({
          'status': QuoteStatus.cancelled.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

  /// Human-readable summary of the quote, so a dispatcher opening the job
  /// sees what to collect without cross-referencing the quote document.
  String _jobNotes(Quote quote) {
    final lines = <String>['Collection from quote ${quote.reference}.'];
    for (final line in quote.activeBoxes) {
      lines.add('${line.quantity} × ${line.size.label} box');
    }
    for (final item in quote.looseItems) {
      lines.add('${item.quantity} × ${item.name} (${item.dimensionsLabel})');
    }
    if (quote.packingRequired) {
      lines.add('Packing: ${quote.packers} packers × ${quote.packingHours}h');
    }
    if (quote.notes.isNotEmpty) lines.add('Client notes: ${quote.notes}');
    return lines.join('\n');
  }
}

/// `SBQ-2026-0847` — the reference shown to the client and quoted back to
/// support. Derived from the document id so it is stable and needs no
/// counter document.
String buildQuoteReference(String docId, {DateTime? now}) {
  final year = (now ?? DateTime.now()).year;
  final serial = (docId.hashCode.abs() % 10000).toString().padLeft(4, '0');
  return 'SBQ-$year-$serial';
}
