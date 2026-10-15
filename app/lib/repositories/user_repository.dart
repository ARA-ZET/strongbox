import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/enums/app_enums.dart';
import '../core/models/app_user.dart';
import 'repository_base.dart';

/// Data access for users (doc 09).
abstract class UserRepository {
  Future<AppUser?> getUser(String uid);
  Stream<AppUser?> watchUser(String uid);
  Stream<List<AppUser>> watchByRole(String tenantId, UserRole role);
  Future<void> createUser(AppUser user);
  Future<void> updateUser(String uid, Map<String, dynamic> fields);

  /// Registers a device for push notifications.
  Future<void> addFcmToken(String uid, String token);

  /// Forgets a device, e.g. on sign-out.
  Future<void> removeFcmToken(String uid, String token);

  /// The signed-up account for [email] (matched as typed or lower-cased),
  /// or null when nobody has registered with it.
  Future<AppUser?> findByEmail(String tenantId, String email);

  /// Sets [user]'s role and logs it in one transaction. Their client record,
  /// if any, is left alone, so moving someone back to client restores it.
  Future<void> changeRole(AppUser user, UserRole role,
      {required String actorId});
}

class FirestoreUserRepository
    with FirestoreRepository
    implements UserRepository {
  FirestoreUserRepository(this.db);

  @override
  final FirebaseFirestore db;

  CollectionReference<Map<String, dynamic>> get _users =>
      col(Collections.users);

  @override
  Future<AppUser?> getUser(String uid) => guardRepo(() async {
        final doc = await _users.doc(uid).get();
        return doc.exists ? AppUser.fromFirestore(doc) : null;
      });

  @override
  Stream<AppUser?> watchUser(String uid) => _users
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? AppUser.fromFirestore(doc) : null);

  @override
  Stream<List<AppUser>> watchByRole(String tenantId, UserRole role) => _users
      .where('tenantId', isEqualTo: tenantId)
      .where('role', isEqualTo: role.name)
      .where('isDeleted', isEqualTo: false)
      .snapshots()
      .map((snap) => snap.docs.map(AppUser.fromFirestore).toList());

  @override
  Future<void> createUser(AppUser user) => guardRepo(() => _users
      .doc(user.id)
      .set(user.toJson()..['createdAt'] = FieldValue.serverTimestamp()));

  @override
  Future<void> updateUser(String uid, Map<String, dynamic> fields) =>
      guardRepo(() => _users.doc(uid).update(fields));

  @override
  Future<void> addFcmToken(String uid, String token) =>
      guardRepo(() => _users.doc(uid).update({
            'fcmTokens': FieldValue.arrayUnion([token]),
          }));

  @override
  Future<void> removeFcmToken(String uid, String token) =>
      guardRepo(() => _users.doc(uid).update({
            'fcmTokens': FieldValue.arrayRemove([token]),
          }));

  @override
  Future<AppUser?> findByEmail(String tenantId, String email) =>
      guardRepo(() async {
        final typed = email.trim();
        final snap = await _users
            .where('tenantId', isEqualTo: tenantId)
            .where('isDeleted', isEqualTo: false)
            .where('email', whereIn: {typed, typed.toLowerCase()}.toList())
            .limit(1)
            .get();
        return snap.docs.isEmpty ? null : AppUser.fromFirestore(snap.docs.first);
      });

  @override
  Future<void> changeRole(AppUser user, UserRole role,
          {required String actorId}) =>
      guardRepo(() => db.runTransaction((tx) async {
            tx.update(_users.doc(user.id), {'role': role.name});
            tx.set(
              auditDoc(),
              auditEventData(
                tenantId: user.tenantId,
                actorId: actorId,
                action: AuditAction.userRoleChanged,
                entityType: 'user',
                entityId: user.id,
                metadata: {'from': user.role.name, 'to': role.name},
              ),
            );
          }));
}
