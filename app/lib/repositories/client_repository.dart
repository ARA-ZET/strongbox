import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/models/client.dart';
import 'repository_base.dart';

/// Data access for clients (doc 09).
abstract class ClientRepository {
  Stream<List<Client>> watchAll({required String tenantId});
  Stream<Client?> watchClient(String id);
  Stream<Client?> watchByUserId(String tenantId, String userId);
  Future<Client?> getClient(String id);
  Future<Client?> getClientByUserId(String tenantId, String userId);
  Future<String> create(Client client, {required String actorId});
  Future<void> update(String id, Map<String, dynamic> fields,
      {required String actorId});
  Future<void> softDelete(Client client, {required String actorId});
}

class FirestoreClientRepository
    with FirestoreRepository
    implements ClientRepository {
  FirestoreClientRepository(this.db);

  @override
  final FirebaseFirestore db;

  CollectionReference<Map<String, dynamic>> get _clients =>
      col(Collections.clients);

  @override
  Stream<List<Client>> watchAll({required String tenantId}) => _clients
      .where('tenantId', isEqualTo: tenantId)
      .where('isDeleted', isEqualTo: false)
      .snapshots()
      .map((snap) {
        final list = snap.docs.map(Client.fromFirestore).toList()
          ..sort((a, b) => a.displayName
              .toLowerCase()
              .compareTo(b.displayName.toLowerCase()));
        return list;
      });

  @override
  Stream<Client?> watchClient(String id) => _clients
      .doc(id)
      .snapshots()
      .map((doc) => doc.exists ? Client.fromFirestore(doc) : null);

  @override
  Stream<Client?> watchByUserId(String tenantId, String userId) => _clients
      .where('tenantId', isEqualTo: tenantId)
      .where('primaryUserId', isEqualTo: userId)
      .where('isDeleted', isEqualTo: false)
      .limit(1)
      .snapshots()
      .map((snap) =>
          snap.docs.isEmpty ? null : Client.fromFirestore(snap.docs.first));

  @override
  Future<Client?> getClient(String id) => guardRepo(() async {
        final doc = await _clients.doc(id).get();
        return doc.exists ? Client.fromFirestore(doc) : null;
      });

  @override
  Future<Client?> getClientByUserId(String tenantId, String userId) =>
      guardRepo(() async {
        final snap = await _clients
            .where('tenantId', isEqualTo: tenantId)
            .where('primaryUserId', isEqualTo: userId)
            .where('isDeleted', isEqualTo: false)
            .limit(1)
            .get();
        return snap.docs.isEmpty
            ? null
            : Client.fromFirestore(snap.docs.first);
      });

  @override
  Future<String> create(Client client, {required String actorId}) =>
      guardRepo(() async {
        final doc = _clients.doc();
        await doc.set(client.toJson()
          ..remove('id')
          ..['createdAt'] = FieldValue.serverTimestamp());
        return doc.id;
      });

  @override
  Future<void> update(String id, Map<String, dynamic> fields,
          {required String actorId}) =>
      guardRepo(() => _clients.doc(id).update(fields));

  @override
  Future<void> softDelete(Client client, {required String actorId}) =>
      guardRepo(() => _clients.doc(client.id).update({
            'isActive': false,
            'isDeleted': true,
            'deletedAt': FieldValue.serverTimestamp(),
          }));
}
