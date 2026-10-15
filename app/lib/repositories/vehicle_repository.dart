import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/enums/app_enums.dart';
import '../core/errors/app_exception.dart';
import '../core/models/vehicle.dart';
import 'repository_base.dart';

/// Fleet vehicles and trailers (`vehicles/{id}`). Admin-managed; every
/// write carries an audit event, and retiring is a soft delete.
abstract class VehicleRepository {
  /// Active (not retired) vehicles and trailers, by name.
  Stream<List<Vehicle>> watchAll(String tenantId);

  /// Adds [vehicle]; fails if its registration is already in the fleet.
  Future<String> create(Vehicle vehicle, {required String actorId});

  /// Saves edits to an existing vehicle.
  Future<void> update(Vehicle vehicle, {required String actorId});

  /// Takes a vehicle out of the fleet (soft delete).
  Future<void> retire(Vehicle vehicle, {required String actorId});
}

class FirestoreVehicleRepository
    with FirestoreRepository
    implements VehicleRepository {
  FirestoreVehicleRepository(this.db);

  @override
  final FirebaseFirestore db;

  CollectionReference<Map<String, dynamic>> get _vehicles =>
      col(Collections.vehicles);

  @override
  Stream<List<Vehicle>> watchAll(String tenantId) => _vehicles
      .where('tenantId', isEqualTo: tenantId)
      .where('isDeleted', isEqualTo: false)
      .snapshots()
      .map((snap) => snap.docs.map(Vehicle.fromFirestore).toList()
        ..sort((a, b) => a.displayName
            .toLowerCase()
            .compareTo(b.displayName.toLowerCase())));

  /// Firestore fields for [vehicle] (no id; registration normalised).
  Map<String, dynamic> _fields(Vehicle vehicle) => vehicle
      .copyWith(registration: normaliseRegistration(vehicle.registration))
      .toJson()
    ..remove('id')
    ..remove('createdAt')
    ..remove('deletedAt')
    ..['updatedAt'] = FieldValue.serverTimestamp();

  Future<void> _ensureUniqueRegistration(Vehicle vehicle) async {
    final registration = normaliseRegistration(vehicle.registration);
    final clash = await _vehicles
        .where('tenantId', isEqualTo: vehicle.tenantId)
        .where('registration', isEqualTo: registration)
        .where('isDeleted', isEqualTo: false)
        .get();
    if (clash.docs.any((doc) => doc.id != vehicle.id)) {
      throw AppException(
        code: 'already-exists',
        message: '$registration is already in the fleet.',
      );
    }
  }

  @override
  Future<String> create(Vehicle vehicle, {required String actorId}) =>
      guardRepo(() async {
        await _ensureUniqueRegistration(vehicle);
        final doc = _vehicles.doc();
        final batch = db.batch()
          ..set(doc, {
            ..._fields(vehicle),
            'createdAt': FieldValue.serverTimestamp(),
          })
          ..set(
            auditDoc(),
            auditEventData(
              tenantId: vehicle.tenantId,
              actorId: actorId,
              action: AuditAction.vehicleAdded,
              entityType: 'vehicle',
              entityId: doc.id,
              metadata: {
                'type': vehicle.type.name,
                'registration': normaliseRegistration(vehicle.registration),
              },
            ),
          );
        await batch.commit();
        return doc.id;
      });

  @override
  Future<void> update(Vehicle vehicle, {required String actorId}) =>
      guardRepo(() async {
        await _ensureUniqueRegistration(vehicle);
        final ref = _vehicles.doc(vehicle.id);
        await db.runTransaction((txn) async {
          final current = await txn.get(ref);
          final before = current.data()?['status'] as String?;
          txn.update(ref, _fields(vehicle));
          txn.set(
            auditDoc(),
            auditEventData(
              tenantId: vehicle.tenantId,
              actorId: actorId,
              action: AuditAction.vehicleUpdated,
              entityType: 'vehicle',
              entityId: vehicle.id,
              metadata: {
                if (before != vehicle.status.name) ...{
                  'fromStatus': before,
                  'toStatus': vehicle.status.name,
                },
              },
            ),
          );
        });
      });

  @override
  Future<void> retire(Vehicle vehicle, {required String actorId}) =>
      guardRepo(() async {
        final batch = db.batch()
          ..update(_vehicles.doc(vehicle.id), {
            'isDeleted': true,
            'deletedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          })
          ..set(
            auditDoc(),
            auditEventData(
              tenantId: vehicle.tenantId,
              actorId: actorId,
              action: AuditAction.vehicleRetired,
              entityType: 'vehicle',
              entityId: vehicle.id,
              metadata: {'registration': vehicle.registration},
            ),
          );
        await batch.commit();
      });
}
