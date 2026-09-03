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
  Future<String> createInvited(AppUser user);
  Future<void> updateUser(String uid, Map<String, dynamic> fields);
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
  Future<String> createInvited(AppUser user) => guardRepo(() async {
        final doc = _users.doc();
        await doc.set(user.toJson()
          ..remove('id')
          ..['invited'] = true
          ..['createdAt'] = FieldValue.serverTimestamp());
        return doc.id;
      });

  @override
  Future<void> updateUser(String uid, Map<String, dynamic> fields) =>
      guardRepo(() => _users.doc(uid).update(fields));
}
