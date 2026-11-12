// ignore_for_file: use_null_aware_elements
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/enums/app_enums.dart';
import '../core/errors/app_exception.dart';
import '../core/models/job.dart';
import 'repository_base.dart';

/// Data access for jobs (doc 09). Status changes cascade to the job's
/// storage units and write an AuditEvent, all in one transaction.
///
/// Lifecycle (docs 20, 21):
/// - client bookings and delivery requests arrive `pendingConfirmation`
///   (written by the `bookPickup` / `requestDelivery` functions); an admin
///   [confirm]s or [decline]s them.
/// - pickup: start → arrived → [collectUnit] each (unit → inTransit) →
///   [signOff] (job → collected) → [receiveUnit] each at the facility
///   (unit → inStorage; the last one completes the job).
/// - delivery: start → [loadUnit] each at the facility (unit → inTransit)
///   → [markDeparted] → arrived → [handOverUnit] each → [signOff]
///   (job → completed, units → delivered).
/// - supply drop-off: start → arrived → [signOff] (job → completed).
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

  /// Accepts a client booking or delivery request, optionally rescheduling
  /// it and dispatching a driver / vehicle. A Path A pickup's linked
  /// supply drop-off is confirmed with it.
  Future<void> confirm(
    Job job, {
    required String actorId,
    DateTime? scheduledDate,
    TimeWindow? timeWindow,
    String? driverId,
    String? driverName,
    String? fleetVehicleId,
  });

  /// Turns down a client booking or request, releasing its units.
  Future<void> decline(Job job,
      {required String actorId, required String reason});
  Future<void> assignDriver(Job job, String driverId,
      {required String actorId, String? driverName, String? fleetVehicleId});
  Future<void> cancel(Job job, {required String actorId, String? reason});

  Future<void> startJob(Job job, {required String actorId});
  Future<void> markDeparted(Job job, {required String actorId});
  Future<void> markArrived(Job job, {required String actorId});

  /// Pickup, at the client: unit scanned onto the truck.
  Future<void> collectUnit(Job job, String unitId,
      {required String actorId, UnitCondition? condition});

  /// Pickup, at the facility: unit scanned into storage at [bay].
  Future<void> receiveUnit(Job job, String unitId,
      {required String actorId, String? bay, UserRole role = UserRole.driver});

  /// Delivery, at the facility: unit scanned out onto the truck.
  Future<void> loadUnit(Job job, String unitId, {required String actorId});

  /// Delivery, at the door: unit scanned and handed to the client.
  Future<void> handOverUnit(Job job, String unitId,
      {required String actorId});
  Future<void> setUnitCondition(String unitId, UnitCondition condition);
  Future<void> addDriverPhoto(String jobId, String photoUrl);

  /// Client signs on the driver's device: a pickup becomes `collected`
  /// (its units stay in transit until received); a delivery or supply
  /// drop-off is `completed`.
  Future<void> signOff(Job job, String signatureUrl,
      {required String actorId, String? recipientName});
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

  DocumentReference<Map<String, dynamic>> _unit(String id) =>
      col(Collections.storageUnits).doc(id);

  static final _now = FieldValue.serverTimestamp;

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
          ..['createdAt'] = _now()
          ..['updatedAt'] = _now();

        final batch = db.batch();
        batch.set(doc, data);

        if (moveUnits && job.type != JobType.supplyDrop) {
          final unitStatus = job.type == JobType.pickup
              ? StorageStatus.pendingPickup
              : StorageStatus.pendingDelivery;
          for (final unitId in job.storageUnitIds) {
            batch.update(_unit(unitId), {
              'status': unitStatus.name,
              'jobId': doc.id,
              'updatedAt': _now(),
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

  // ------------------------------------------------------------ ops

  @override
  Future<void> confirm(
    Job job, {
    required String actorId,
    DateTime? scheduledDate,
    TimeWindow? timeWindow,
    String? driverId,
    String? driverName,
    String? fleetVehicleId,
  }) =>
      guardRepo(() async {
        await db.runTransaction((txn) async {
          final linked = await _linked(txn, job, _awaitingConfirmation);
          final current = await txn.get(_jobs.doc(job.id));
          if (current.data()?['status'] != JobStatus.pendingConfirmation.name) {
            throw const AppException(
                code: 'failed-precondition',
                message: 'This booking was already confirmed or closed.');
          }
          final dispatched =
              driverId != null ? JobStatus.assigned : JobStatus.scheduled;
          final fields = {
            'status': dispatched.name,
            'confirmedAt': _now(),
            'confirmedBy': actorId,
            if (driverId != null) 'driverId': driverId,
            if (driverId != null) 'driverName': driverName,
            if (fleetVehicleId != null) 'fleetVehicleId': fleetVehicleId,
            'updatedAt': _now(),
          };
          txn.update(_jobs.doc(job.id), {
            ...fields,
            if (scheduledDate != null)
              'scheduledDate': Timestamp.fromDate(scheduledDate),
            if (timeWindow != null) 'timeWindow': timeWindow.name,
          });
          if (linked != null) txn.update(linked.reference, fields);
          txn.set(
            auditDoc(),
            auditEventData(
              tenantId: job.tenantId,
              actorId: actorId,
              action: AuditAction.jobConfirmed,
              entityType: 'job',
              entityId: job.id,
              metadata: {
                if (driverId != null) 'driverId': driverId,
                if (linked != null) 'linkedJobId': linked.id,
              },
            ),
          );
        });
      });

  @override
  Future<void> decline(Job job,
          {required String actorId, required String reason}) =>
      guardRepo(() async {
        await db.runTransaction((txn) async {
          final linked = await _linked(txn, job, _awaitingConfirmation);
          // Declined from its supply drop-off, a Path A pickup's units are
          // released too.
          final linkedJob = linked == null ? null : Job.fromFirestore(linked);
          final snaps = await _ownUnits(txn, job);
          final linkedSnaps =
              linkedJob == null ? null : await _ownUnits(txn, linkedJob);
          final fields = {
            'status': JobStatus.cancelled.name,
            'cancelledAt': _now(),
            'cancelReason': reason,
            'updatedAt': _now(),
          };
          txn.update(_jobs.doc(job.id), fields);
          if (linked != null) txn.update(linked.reference, fields);
          _releaseUnits(txn, job, snaps);
          if (linkedJob != null) _releaseUnits(txn, linkedJob, linkedSnaps!);
          txn.set(
            auditDoc(),
            auditEventData(
              tenantId: job.tenantId,
              actorId: actorId,
              action: AuditAction.jobDeclined,
              entityType: 'job',
              entityId: job.id,
              metadata: {
                'reason': reason,
                if (linked != null) 'linkedJobId': linked.id,
              },
            ),
          );
        });
      });

  /// Dispatches [job] to [driverId]. Also claims its units, which a job
  /// created without moving them has not done yet.
  @override
  Future<void> assignDriver(Job job, String driverId,
          {required String actorId,
          String? driverName,
          String? fleetVehicleId}) =>
      guardRepo(() async {
        await db.runTransaction((txn) async {
          txn.update(_jobs.doc(job.id), {
            'driverId': driverId,
            'driverName': driverName,
            if (fleetVehicleId != null) 'fleetVehicleId': fleetVehicleId,
            // Assigning a booking nobody confirmed yet confirms it.
            if (job.status == JobStatus.pendingConfirmation) ...{
              'confirmedAt': _now(),
              'confirmedBy': actorId,
            },
            // Reassigning a job already under way keeps its status.
            if (job.status.index <= JobStatus.assigned.index)
              'status': JobStatus.assigned.name,
            'updatedAt': _now(),
          });
          if (job.type != JobType.supplyDrop &&
              job.status.index <= JobStatus.assigned.index) {
            final pending = job.type == JobType.pickup
                ? StorageStatus.pendingPickup
                : StorageStatus.pendingDelivery;
            for (final unitId in job.storageUnitIds) {
              txn.update(_unit(unitId), {
                'status': pending.name,
                'jobId': job.id,
                'updatedAt': _now(),
              });
            }
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
  /// units go back to storage; a booked pickup's units are cancelled (they
  /// only existed for that booking); an ops pickup's stay pending pickup.
  /// Units that have since moved to another job are left alone. A Path A
  /// pickup takes its supply drop-off with it, unless the driver has
  /// already set off with the supplies.
  @override
  Future<void> cancel(Job job, {required String actorId, String? reason}) =>
      guardRepo(() async {
        await db.runTransaction((txn) async {
          final drop = job.type == JobType.pickup
              ? await _linked(txn, job, _notStarted)
              : null;
          final snaps = await _ownUnits(txn, job);
          final fields = {
            'status': JobStatus.cancelled.name,
            'cancelledAt': _now(),
            if (reason != null) 'cancelReason': reason,
            'updatedAt': _now(),
          };
          txn.update(_jobs.doc(job.id), fields);
          if (drop != null) txn.update(drop.reference, fields);
          _releaseUnits(txn, job, snaps);
          txn.set(
            auditDoc(),
            auditEventData(
              tenantId: job.tenantId,
              actorId: actorId,
              action: AuditAction.jobCancelled,
              entityType: 'job',
              entityId: job.id,
              metadata: {
                if (reason != null) 'reason': reason,
                if (drop != null) 'linkedJobId': drop.id,
              },
            ),
          );
        });
      });

  // --------------------------------------------------------- driver

  @override
  Future<void> startJob(Job job, {required String actorId}) =>
      guardRepo(() async {
        if (!job.status.isDispatchable) {
          throw const AppException(
              code: 'failed-precondition',
              message: 'This job is not confirmed for dispatch.');
        }
        // A pickup or supply run leaves for the client straight away; a
        // delivery loads at the facility first and departs after.
        final leaving = job.type != JobType.delivery;
        await db.runTransaction((txn) async {
          // Re-read: the client can cancel right up until this moment.
          final snap = await txn.get(_jobs.doc(job.id));
          final status = JobStatus.values.asNameMap()[snap.data()?['status']];
          if (status == JobStatus.cancelled) {
            throw const AppException(
                code: 'failed-precondition',
                message: 'This job was cancelled — check your job list.');
          }
          if (status == null || !status.isDispatchable) {
            throw const AppException(
                code: 'failed-precondition',
                message: 'This job is not confirmed for dispatch.');
          }
          txn.update(_jobs.doc(job.id), {
            'status': JobStatus.inProgress.name,
            if (leaving) 'departedAt': _now(),
            'updatedAt': _now(),
          });
          txn.set(
            auditDoc(),
            auditEventData(
              tenantId: job.tenantId,
              actorId: actorId,
              actorRole: UserRole.driver,
              action: AuditAction.jobStarted,
              entityType: 'job',
              entityId: job.id,
              metadata: {'jobId': job.id},
            ),
          );
        });
      });

  @override
  Future<void> markDeparted(Job job, {required String actorId}) =>
      guardRepo(() async {
        if (job.type == JobType.delivery && !job.allUnitsScanned) {
          throw const AppException(
              code: 'failed-precondition',
              message: 'Scan every unit onto the truck before leaving.');
        }
        await _update(
            job, actorId, AuditAction.driverEnRoute, {'departedAt': _now()});
      });

  @override
  Future<void> markArrived(Job job, {required String actorId}) => guardRepo(
      () => _update(
          job, actorId, AuditAction.driverArrived, {'arrivedAt': _now()}));

  @override
  Future<void> collectUnit(Job job, String unitId,
          {required String actorId, UnitCondition? condition}) =>
      _scan(job, unitId, actorId,
          to: StorageStatus.inTransit,
          jobList: 'scannedUnitIds',
          extra: {if (condition != null) 'condition': condition.name});

  @override
  Future<void> receiveUnit(Job job, String unitId,
          {required String actorId,
          String? bay,
          UserRole role = UserRole.driver}) =>
      guardRepo(() async {
        if (job.type != JobType.pickup ||
            (job.status != JobStatus.collected &&
                job.status != JobStatus.completed)) {
          throw const AppException(
              code: 'failed-precondition',
              message: 'Units are received once the client has signed.');
        }
        await db.runTransaction((txn) async {
          final jobSnap = await txn.get(_jobs.doc(job.id));
          final unitSnap = await txn.get(_unit(unitId));
          _checkOnJob(job, unitId);
          final status = _statusOf(unitSnap);
          if (status == StorageStatus.inStorage) return; // already in
          _checkTransition(status, StorageStatus.inStorage);

          final received = {
            ...List<String>.from(jobSnap.data()?['receivedUnitIds'] ?? []),
            unitId,
          };
          final done = received.containsAll(job.storageUnitIds);
          txn.update(unitSnap.reference, {
            'status': StorageStatus.inStorage.name,
            if (bay != null && bay.trim().isNotEmpty)
              'warehouseLocationId': bay.trim(),
            'receivedAt': _now(),
            'jobId': null,
            'updatedAt': _now(),
          });
          txn.update(_jobs.doc(job.id), {
            'receivedUnitIds': FieldValue.arrayUnion([unitId]),
            if (done) 'status': JobStatus.completed.name,
            if (done) 'completedAt': _now(),
            'updatedAt': _now(),
          });
          txn.set(
            auditDoc(),
            auditEventData(
              tenantId: job.tenantId,
              actorId: actorId,
              actorRole: role,
              action: AuditAction.unitReceived,
              entityType: 'storageUnit',
              entityId: unitId,
              metadata: {'jobId': job.id, if (bay != null) 'bay': bay},
            ),
          );
        });
      });

  @override
  Future<void> loadUnit(Job job, String unitId, {required String actorId}) =>
      _scan(job, unitId, actorId,
          to: StorageStatus.inTransit,
          jobList: 'scannedUnitIds');

  @override
  Future<void> handOverUnit(Job job, String unitId,
          {required String actorId}) =>
      guardRepo(() async {
        if (job.arrivedAt == null) {
          throw const AppException(
              code: 'failed-precondition',
              message: 'Check in as arrived before handing over.');
        }
        _checkOnJob(job, unitId);
        await _update(job, actorId, AuditAction.qrScanned, {
          'handedOverUnitIds': FieldValue.arrayUnion([unitId]),
        }, entityType: 'storageUnit', entityId: unitId);
      });

  @override
  Future<void> setUnitCondition(String unitId, UnitCondition condition) =>
      guardRepo(() => _unit(unitId).update({
            'condition': condition.name,
            'updatedAt': _now(),
          }));

  @override
  Future<void> addDriverPhoto(String jobId, String photoUrl) =>
      guardRepo(() => _jobs.doc(jobId).update({
            'photoIds': FieldValue.arrayUnion([photoUrl]),
            'updatedAt': _now(),
          }));

  @override
  Future<void> signOff(Job job, String signatureUrl,
          {required String actorId, String? recipientName}) =>
      guardRepo(() async {
        final ready = switch (job.type) {
          JobType.pickup => job.allUnitsScanned,
          JobType.delivery => job.allUnitsHandedOver,
          JobType.supplyDrop => true,
        };
        if (job.status != JobStatus.inProgress || !ready) {
          throw const AppException(
              code: 'failed-precondition',
              message: 'Scan every unit before the client signs.');
        }
        await db.runTransaction((txn) async {
          final pickup = job.type == JobType.pickup;
          txn.update(_jobs.doc(job.id), {
            'status':
                (pickup ? JobStatus.collected : JobStatus.completed).name,
            'clientSignatureUrl': signatureUrl,
            'clientConfirmMethod': 'signature',
            if (recipientName != null && recipientName.trim().isNotEmpty)
              'recipientName': recipientName.trim(),
            if (pickup) 'collectedAt': _now() else 'completedAt': _now(),
            'updatedAt': _now(),
          });
          if (job.type == JobType.delivery) {
            for (final unitId in job.storageUnitIds) {
              txn.update(_unit(unitId), {
                'status': StorageStatus.delivered.name,
                'jobId': null,
                'updatedAt': _now(),
              });
            }
          }
          txn.set(
            auditDoc(),
            auditEventData(
              tenantId: job.tenantId,
              actorId: actorId,
              actorRole: UserRole.driver,
              action: pickup ? AuditAction.jobCollected : AuditAction.clientSignOff,
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
            'updatedAt': _now(),
          }));

  // --------------------------------------------------------- helpers

  /// One job field update plus its audit event.
  Future<void> _update(
    Job job,
    String actorId,
    AuditAction action,
    Map<String, dynamic> fields, {
    String entityType = 'job',
    String? entityId,
  }) async {
    final batch = db.batch()
      ..update(_jobs.doc(job.id), {...fields, 'updatedAt': _now()})
      ..set(
        auditDoc(),
        auditEventData(
          tenantId: job.tenantId,
          actorId: actorId,
          actorRole: UserRole.driver,
          action: action,
          entityType: entityType,
          entityId: entityId ?? job.id,
          metadata: {'jobId': job.id},
        ),
      );
    await batch.commit();
  }

  /// A scan that moves a unit to [to] (a permitted transition, or already
  /// there) and records it on the job.
  Future<void> _scan(
    Job job,
    String unitId,
    String actorId, {
    required StorageStatus to,
    required String jobList,
    Map<String, dynamic> extra = const {},
  }) =>
      guardRepo(() async {
        if (job.status != JobStatus.inProgress) {
          throw const AppException(
              code: 'failed-precondition',
              message: 'Start the job before scanning.');
        }
        _checkOnJob(job, unitId);
        await db.runTransaction((txn) async {
          final unitSnap = await txn.get(_unit(unitId));
          final status = _statusOf(unitSnap);
          if (status != to) {
            _checkTransition(status, to);
            txn.update(unitSnap.reference, {
              'status': to.name,
              ...extra,
              'updatedAt': _now(),
            });
          }
          txn.update(_jobs.doc(job.id), {
            jobList: FieldValue.arrayUnion([unitId]),
            'updatedAt': _now(),
          });
          txn.set(
            auditDoc(),
            auditEventData(
              tenantId: job.tenantId,
              actorId: actorId,
              actorRole: UserRole.driver,
              action: AuditAction.qrScanned,
              entityType: 'storageUnit',
              entityId: unitId,
              metadata: {'jobId': job.id, 'toStatus': to.name},
            ),
          );
        });
      });

  void _checkOnJob(Job job, String unitId) {
    if (!job.storageUnitIds.contains(unitId)) {
      throw const AppException(
          code: 'failed-precondition',
          message: "That unit isn't on this job's manifest.");
    }
  }

  StorageStatus _statusOf(DocumentSnapshot<Map<String, dynamic>> snap) {
    if (!snap.exists) {
      throw const AppException(
          code: 'not-found', message: 'That unit no longer exists.');
    }
    return StorageStatus.values.asNameMap()[snap.data()?['status']] ??
        StorageStatus.pendingPickup;
  }

  void _checkTransition(StorageStatus from, StorageStatus to) {
    if (!from.canTransitionTo(to)) {
      throw AppException(
          code: 'failed-precondition',
          message: "A unit that's ${from.label.toLowerCase()} can't move to "
              '${to.label.toLowerCase()}.');
    }
  }

  static final _awaitingConfirmation = {JobStatus.pendingConfirmation.name};
  static final _notStarted = {
    JobStatus.pendingConfirmation.name,
    JobStatus.scheduled.name,
    JobStatus.assigned.name,
  };

  /// The other half of a Path A pickup ↔ supply drop-off pair, while its
  /// status is one of [statuses].
  Future<DocumentSnapshot<Map<String, dynamic>>?> _linked(
      Transaction txn, Job job, Set<String> statuses) async {
    final id = job.linkedJobId;
    if (id == null || id.isEmpty) return null;
    final snap = await txn.get(_jobs.doc(id));
    final open = snap.exists && statuses.contains(snap.data()?['status']);
    return open ? snap : null;
  }

  /// The job's unit docs that still belong to it (all reads, before any
  /// transaction write).
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> _ownUnits(
      Transaction txn, Job job) async {
    final snaps = [
      for (final id in job.storageUnitIds) await txn.get(_unit(id)),
    ];
    return snaps
        .where((s) => s.exists && s.data()?['jobId'] == job.id)
        .toList();
  }

  void _releaseUnits(Transaction txn, Job job,
      List<DocumentSnapshot<Map<String, dynamic>>> snaps) {
    for (final snap in snaps) {
      final status = snap.data()?['status'];
      txn.update(snap.reference, {
        if (job.type == JobType.delivery &&
            status == StorageStatus.pendingDelivery.name)
          'status': StorageStatus.inStorage.name,
        if (job.type == JobType.pickup &&
            job.source == 'quote' &&
            status == StorageStatus.pendingPickup.name)
          'status': StorageStatus.cancelled.name,
        'jobId': null,
        'updatedAt': _now(),
      });
    }
  }
}
