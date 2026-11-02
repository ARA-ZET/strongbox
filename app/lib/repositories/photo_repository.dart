import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../core/constants/firestore_collections.dart';
import '../core/enums/app_enums.dart';
import '../core/models/photo.dart';
import 'repository_base.dart';

/// Uploads photos to Storage and records a [Photo] doc in Firestore
/// (rule #24: only the URL lives in Firestore). Returns the new photo id.
abstract class PhotoRepository {
  Future<String> upload({
    required String tenantId,
    required Uint8List bytes,
    required PhotoType type,
    required String entityType,
    required String entityId,
    required String storagePath,
    String? jobId,
    required String uploadedBy,
  });

  /// Uploads a client sign-off signature (PNG) to [storagePath] and returns
  /// its download URL, which the job records as `clientSignatureUrl`.
  Future<String> uploadSignature(
      {required Uint8List png, required String storagePath});

  /// Uploads a photo of storage unit [unitId] and, in one batch, records
  /// the [Photo] doc and adds it to the unit's `photoIds`. Returns the id.
  Future<String> addUnitPhoto({
    required String tenantId,
    required String unitId,
    required Uint8List bytes,
    required PhotoType type,
    required String storagePath,
    required String uploadedBy,
  });

  /// Soft-deletes [photo] and takes it off unit [unitId], in one batch.
  /// The Storage file is kept (doc 06 deletion policy).
  Future<void> removeUnitPhoto(Photo photo, String unitId);

  Future<List<Photo>> getForEntity(String entityId);
  Stream<List<Photo>> watchForEntity(String entityId);
  Future<Map<String, String>> resolveUrls(List<String> photoIds);
}

class FirestorePhotoRepository
    with FirestoreRepository
    implements PhotoRepository {
  FirestorePhotoRepository(this.db, this.storage);

  @override
  final FirebaseFirestore db;
  final FirebaseStorage storage;

  CollectionReference<Map<String, dynamic>> get _photos =>
      col(Collections.photos);

  @override
  Future<String> uploadSignature(
          {required Uint8List png, required String storagePath}) =>
      guardRepo(() async {
        final upload = await storage.ref(storagePath).putData(
            png, SettableMetadata(contentType: 'image/png'));
        return upload.ref.getDownloadURL();
      });

  @override
  Future<String> upload({
    required String tenantId,
    required Uint8List bytes,
    required PhotoType type,
    required String entityType,
    required String entityId,
    required String storagePath,
    String? jobId,
    required String uploadedBy,
  }) =>
      guardRepo(() async {
        final task = await storage.ref(storagePath).putData(
              bytes,
              SettableMetadata(contentType: 'image/jpeg'),
            );
        final url = await task.ref.getDownloadURL();
        final doc = _photos.doc();
        await doc.set({
          'tenantId': tenantId,
          'storageUrl': url,
          'storagePath': storagePath,
          'type': type.name,
          'entityType': entityType,
          'entityId': entityId,
          'jobId': jobId,
          'uploadedBy': uploadedBy,
          'isDeleted': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return doc.id;
      });

  @override
  Future<String> addUnitPhoto({
    required String tenantId,
    required String unitId,
    required Uint8List bytes,
    required PhotoType type,
    required String storagePath,
    required String uploadedBy,
  }) =>
      guardRepo(() async {
        final task = await storage.ref(storagePath).putData(
              bytes,
              SettableMetadata(contentType: 'image/jpeg', customMetadata: {
                'uploadedBy': uploadedBy,
                'entityType': 'storageUnit',
                'entityId': unitId,
              }),
            );
        final url = await task.ref.getDownloadURL();
        final doc = _photos.doc();
        final batch = db.batch()
          ..set(doc, {
            'tenantId': tenantId,
            'storageUrl': url,
            'storagePath': storagePath,
            'type': type.name,
            'entityType': 'storageUnit',
            'entityId': unitId,
            'jobId': null,
            'uploadedBy': uploadedBy,
            'isDeleted': false,
            'createdAt': FieldValue.serverTimestamp(),
          })
          ..update(col(Collections.storageUnits).doc(unitId), {
            'photoIds': FieldValue.arrayUnion([doc.id]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        await batch.commit();
        return doc.id;
      });

  @override
  Future<void> removeUnitPhoto(Photo photo, String unitId) =>
      guardRepo(() async {
        final batch = db.batch()
          ..update(_photos.doc(photo.id), {
            'isDeleted': true,
            'deletedAt': FieldValue.serverTimestamp(),
          })
          ..update(col(Collections.storageUnits).doc(unitId), {
            'photoIds': FieldValue.arrayRemove([photo.id]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        await batch.commit();
      });

  @override
  Future<List<Photo>> getForEntity(String entityId) => guardRepo(() async {
        final snap = await _photos
            .where('entityId', isEqualTo: entityId)
            .where('isDeleted', isEqualTo: false)
            .get();
        return snap.docs.map(Photo.fromFirestore).toList();
      });

  @override
  Stream<List<Photo>> watchForEntity(String entityId) => _photos
      .where('entityId', isEqualTo: entityId)
      .where('isDeleted', isEqualTo: false)
      .snapshots()
      .map((snap) => snap.docs.map(Photo.fromFirestore).toList());

  @override
  Future<Map<String, String>> resolveUrls(List<String> photoIds) =>
      guardRepo(() async {
        if (photoIds.isEmpty) return <String, String>{};
        final snaps =
            await Future.wait(photoIds.map((id) => _photos.doc(id).get()));
        return {
          for (final doc in snaps)
            if (doc.exists)
              doc.id: (doc.data()?['storageUrl'] as String? ?? ''),
        };
      });
}
