// ignore_for_file: use_null_aware_elements
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/enums/app_enums.dart';
import '../core/models/job.dart';
import 'repository_base.dart';

/// Data access for jobs (doc 09). Status changes cascade to the job's
/// storage units and write an AuditEvent, all in one transaction.
abstract class JobRepository {
  Stream<List<Job>> watchAll({
    required String tenantId,
    String? clientId,
    String? driverId,
    JobStatus? status,
    JobType? type,
  });
  Stream<Job?> watchJob(String id);
  Future<Job?> getJob(String id);
  Future<String> create(Job job,
      {required String actorId, bool moveUnits = true});
  Future<void> updateStatus(Job job, JobStatus newStatus,
      {required String actorId});
  Future<void> assignDriver(Job job, String driverId,
      {required String actorId});
  Future<void> cancel(Job job, {required String actorId, String? reason});
  Future<void> markUnitScanned(String jobId, String unitId,
      {required String actorId});
  Future<void> addDriverPhoto(String jobId, String photoUrl);
  Future<void> completeSignOff(Job job, String signatureUrl,
      {required String actorId});
  Future<void> addNote(String jobId, String note);
}

class FirestoreJobRepository
    with FirestoreRepository
    implements JobRepository {
  FirestoreJobRepository(this.db);

  @override
  final FirebaseFirestore db;

  CollectionReference<Map<String, dynamic>> get _jobs =>
      col(Collections.jobs);

  @override
  Stream<List<Job>> watchAll({
    required String tenantId,
    String? clientId,
    String? driverId,
    JobStatus? status,
    JobType? type,
  }) {
    Query<Map<String, dynamic>> query = _jobs
        .where('tenantId', isEqualTo: tenantId)
        .where('isDeleted', isEqualTo: false);
    if (clientId != null) query = query.where('clientId', isEqualTo: clientId);
    if (driverId != null) query = query.where('driverId', isEqualTo: driverId);
    if (status != null) query = query.where('status', isEqualTo: status.name);
    if (type != null) query = query.where('type', isEqualTo: type.name);

    return query.snapshots().map((snap) {
      final jobs = snap.docs.map(Job.fromFirestore).toList()
        ..sort((a, b) => (b.scheduledDate ?? DateTime(0))
            .compareTo(a.scheduledDate ?? DateTime(0)));
      return jobs;
    });
  }

  @override
  Stream<Job?> watchJob(String id) => _jobs
      .doc(id)
      .snapshots()
      .map((doc) => doc.exists ? Job.fromFirestore(doc) : null);

  @override
  Future<Job?> getJob(String id) => guardRepo(() async {
        final doc = await _jobs.doc(id).get();
        return doc.exists ? Job.fromFirestore(doc) : null;
      });

  @override
  Future<String> create(Job job,
          {required String actorId, bool moveUnits = true}) =>
      guardRepo(() async {
        final doc = _jobs.doc();
        final data = job.toJson()
          ..remove('id')
          ..['createdAt'] = FieldValue.serverTimestamp()
          ..['updatedAt'] = FieldValue.serverTimestamp();

        final batch = db.batch();
        batch.set(doc, data);

        // Drafts leave units untouched; dispatched jobs flip them to pending.
        if (moveUnits) {
          final unitStatus = job.type == JobType.pickup
              ? StorageStatus.pendingPickup
              : StorageStatus.pendingDelivery;
          for (final unitId in job.storageUnitIds) {
            batch.update(col(Collections.storageUnits).doc(unitId), {
              'status': unitStatus.name,
              'jobId': doc.id,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
        batch.set(
          auditDoc(),
          auditEventData(
            tenantId: job.tenantId,
            actorId: actorId,
            action: AuditAction.jobCreated,
            entityType: 'job',
            entityId: doc.id,
            metadata: {'type': job.type.name, 'units': job.storageUnitIds.length},
          ),
        );
        await batch.commit();
        return doc.id;
      });

  @override
  Future<void> updateStatus(Job job, JobStatus newStatus,
          {required String actorId}) =>
      guardRepo(() async {
        await db.runTransaction((txn) async {
          txn.update(_jobs.doc(job.id), {
            'status': newStatus.name,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          // Starting a job puts its units in transit.
          if (newStatus == JobStatus.inProgress) {
            for (final unitId in job.storageUnitIds) {
              txn.update(col(Collections.storageUnits).doc(unitId), {
                'status': StorageStatus.inTransit.name,
                'updatedAt': FieldValue.serverTimestamp(),
              });
            }
          }
          txn.set(
            auditDoc(),
            auditEventData(
              tenantId: job.tenantId,
              actorId: actorId,
              action: _actionForStatus(newStatus),
              entityType: 'job',
              entityId: job.id,
              metadata: {'toStatus': newStatus.name},
            ),
          );
        });
      });

  /// Dispatches [job] to [driverId]. Also claims its units, which a draft
  /// (saved without moving them) has not done yet.
  @override
  Future<void> assignDriver(Job job, String driverId,
          {required String actorId}) =>
      guardRepo(() async {
        await db.runTransaction((txn) async {
          txn.update(_jobs.doc(job.id), {
            'driverId': driverId,
            'status': JobStatus.assigned.name,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          final pending = job.type == JobType.pickup
              ? StorageStatus.pendingPickup
              : StorageStatus.pendingDelivery;
          for (final unitId in job.storageUnitIds) {
            txn.update(col(Collections.storageUnits).doc(unitId), {
              'status': pending.name,
              'jobId': job.id,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
          txn.set(
            auditDoc(),
            auditEventData(
              tenantId: job.tenantId,
              actorId: actorId,
              action: AuditAction.jobAssigned,
              entityType: 'job',
              entityId: job.id,
              metadata: {'driverId': driverId},
            ),
          );
        });
      });

  /// Cancels a job that hasn't started and releases its units: a delivery's
  /// units go back to storage; a pickup's stay pending pickup. Units that
  /// have since moved to another job are left alone.
  @override
  Future<void> cancel(Job job, {required String actorId, String? reason}) =>
      guardRepo(() async {
        await db.runTransaction((txn) async {
          final unitRefs = job.storageUnitIds
              .map((id) => col(Collections.storageUnits).doc(id))
              .toList();
          final snaps = [for (final ref in unitRefs) await txn.get(ref)];

          txn.update(_jobs.doc(job.id), {
            'status': JobStatus.cancelled.name,
            'cancelledAt': FieldValue.serverTimestamp(),
            if (reason != null) 'cancelReason': reason,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          for (final snap in snaps) {
            if (!snap.exists || snap.data()?['jobId'] != job.id) continue;
            txn.update(snap.reference, {
              if (job.type == JobType.delivery)
                'status': StorageStatus.inStorage.name,
              'jobId': null,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
          txn.set(
            auditDoc(),
            auditEventData(
              tenantId: job.tenantId,
              actorId: actorId,
              action: AuditAction.jobCancelled,
              entityType: 'job',
              entityId: job.id,
              metadata: {if (reason != null) 'reason': reason},
            ),
          );
        });
      });

  @override
  Future<void> markUnitScanned(String jobId, String unitId,
          {required String actorId}) =>
      guardRepo(() async {
        final job = await getJob(jobId);
        final batch = db.batch();
        batch.update(_jobs.doc(jobId), {
          'scannedUnitIds': FieldValue.arrayUnion([unitId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        batch.set(
          auditDoc(),
          auditEventData(
            tenantId: job?.tenantId ?? '',
            actorId: actorId,
            actorRole: UserRole.driver,
            action: AuditAction.qrScanned,
            entityType: 'storageUnit',
            entityId: unitId,
            metadata: {'jobId': jobId},
          ),
        );
        await batch.commit();
      });

  @override
  Future<void> addDriverPhoto(String jobId, String photoUrl) =>
      guardRepo(() => _jobs.doc(jobId).update({
            'photoIds': FieldValue.arrayUnion([photoUrl]),
            'updatedAt': FieldValue.serverTimestamp(),
          }));

  @override
  Future<void> completeSignOff(Job job, String signatureUrl,
          {required String actorId}) =>
      guardRepo(() async {
        await db.runTransaction((txn) async {
          txn.update(_jobs.doc(job.id), {
            'status': JobStatus.completed.name,
            'clientSignatureUrl': signatureUrl,
            'clientConfirmMethod': 'signature',
            'completedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          final settled = job.type == JobType.delivery
              ? StorageStatus.delivered
              : StorageStatus.inStorage;
          for (final unitId in job.storageUnitIds) {
            txn.update(col(Collections.storageUnits).doc(unitId), {
              'status': settled.name,
              if (job.type == JobType.delivery) 'jobId': null,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
          txn.set(
            auditDoc(),
            auditEventData(
              tenantId: job.tenantId,
              actorId: actorId,
              actorRole: UserRole.driver,
              action: AuditAction.clientSignOff,
              entityType: 'job',
              entityId: job.id,
            ),
          );
        });
      });

  @override
  Future<void> addNote(String jobId, String note) =>
      guardRepo(() => _jobs.doc(jobId).update({
            'driverNotes': note,
            'updatedAt': FieldValue.serverTimestamp(),
          }));

  AuditAction _actionForStatus(JobStatus status) => switch (status) {
        JobStatus.assigned => AuditAction.jobAssigned,
        JobStatus.inProgress => AuditAction.jobStarted,
        JobStatus.completed => AuditAction.jobCompleted,
        JobStatus.cancelled => AuditAction.jobCancelled,
        JobStatus.scheduled => AuditAction.jobCreated,
      };
}
