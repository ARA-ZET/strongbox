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
