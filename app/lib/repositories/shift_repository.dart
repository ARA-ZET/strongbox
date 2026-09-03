import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/enums/app_enums.dart';
import '../core/models/driver_shift.dart';
import '../core/utils/qr_generator.dart';
import 'repository_base.dart';

/// Driver work-session tracking (doc 09).
abstract class ShiftRepository {
  Stream<DriverShift?> watchActiveShift(String tenantId, String driverId);
  Future<void> startShift(String tenantId, String driverId);
  Future<void> setBreak(String shiftId, {required bool onBreak});
  Future<void> endShift(String shiftId);
}

class FirestoreShiftRepository
    with FirestoreRepository
    implements ShiftRepository {
  FirestoreShiftRepository(this.db);

  @override
  final FirebaseFirestore db;

  CollectionReference<Map<String, dynamic>> get _shifts =>
      col(Collections.driverShifts);

  @override
  Stream<DriverShift?> watchActiveShift(String tenantId, String driverId) =>
      _shifts
          .where('tenantId', isEqualTo: tenantId)
          .where('driverId', isEqualTo: driverId)
          .where('status', whereIn: [
            ShiftStatus.active.name,
            ShiftStatus.onBreak.name,
          ])
          .limit(1)
          .snapshots()
          .map((snap) => snap.docs.isEmpty
              ? null
              : DriverShift.fromFirestore(snap.docs.first));

  @override
  Future<void> startShift(String tenantId, String driverId) =>
      guardRepo(() async {
        await _shifts.add({
          'tenantId': tenantId,
          'driverId': driverId,
          'startedAt': FieldValue.serverTimestamp(),
          'breakPeriods': <Map<String, dynamic>>[],
          'eIdQrCode': generateDriverEId(driverId),
          'jobIds': <String>[],
          'status': ShiftStatus.active.name,
        });
        await col(Collections.auditEvents).add(auditEventData(
          tenantId: tenantId,
          actorId: driverId,
          actorRole: UserRole.driver,
          action: AuditAction.shiftStarted,
          entityType: 'driverShift',
          entityId: driverId,
        ));
      });

  @override
  Future<void> setBreak(String shiftId, {required bool onBreak}) =>
      guardRepo(() => _shifts.doc(shiftId).update({
            'status':
                onBreak ? ShiftStatus.onBreak.name : ShiftStatus.active.name,
          }));

  @override
  Future<void> endShift(String shiftId) => guardRepo(() => _shifts
      .doc(shiftId)
      .update({
        'status': ShiftStatus.ended.name,
        'endedAt': FieldValue.serverTimestamp(),
      }));
}
