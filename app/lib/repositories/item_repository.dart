import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/enums/app_enums.dart';
import '../core/models/item.dart';
import 'repository_base.dart';

/// Data access for individual items inside open storage units (doc 03/05).
abstract class ItemRepository {
  Stream<List<Item>> watchForUnit(String unitId);
  Stream<List<Item>> watchForClient(String tenantId, String clientId);
  Future<String> create({
    required String tenantId,
    required String storageUnitId,
    required String clientId,
    required String qrCodeId,
    required String label,
    String? description,
    StorageStatus status,
    List<String> photoIds,
  });
}

class FirestoreItemRepository
    with FirestoreRepository
    implements ItemRepository {
  FirestoreItemRepository(this.db);

  @override
  final FirebaseFirestore db;

  CollectionReference<Map<String, dynamic>> get _items =>
      col(Collections.items);

  @override
  Stream<List<Item>> watchForUnit(String unitId) => _items
      .where('storageUnitId', isEqualTo: unitId)
      .where('isDeleted', isEqualTo: false)
      .snapshots()
      .map((snap) => snap.docs.map(Item.fromFirestore).toList());

  @override
  Stream<List<Item>> watchForClient(String tenantId, String clientId) =>
      _items
          .where('tenantId', isEqualTo: tenantId)
          .where('clientId', isEqualTo: clientId)
          .where('isDeleted', isEqualTo: false)
          .snapshots()
          .map((snap) => snap.docs.map(Item.fromFirestore).toList());

  @override
  Future<String> create({
    required String tenantId,
    required String storageUnitId,
    required String clientId,
    required String qrCodeId,
    required String label,
    String? description,
    StorageStatus status = StorageStatus.inStorage,
    List<String> photoIds = const [],
  }) =>
      guardRepo(() async {
        final doc = _items.doc();
        await doc.set({
          'tenantId': tenantId,
          'storageUnitId': storageUnitId,
          'clientId': clientId,
          'qrCodeId': qrCodeId,
          'label': label,
          'description': description,
          'photoIds': photoIds,
          'tags': <String>[],
          'status': status.name,
          'isDeleted': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return doc.id;
      });
}
