import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../core/enums/app_enums.dart';
import '../core/errors/app_exception.dart';

/// Wraps a data-layer operation, converting Firebase errors into
/// [AppException] (rule #27).
Future<T> guardRepo<T>(Future<T> Function() op) async {
  try {
    return await op();
  } on AppException {
    rethrow;
  } on FirebaseException catch (error) {
    throw AppException(
      code: error.code,
      message: _friendlyMessage(error.code),
      original: error,
    );
  } catch (error) {
    throw AppException.from(error);
  }
}

String _friendlyMessage(String code) => switch (code) {
      'permission-denied' => 'You do not have access to this data.',
      'not-found' => 'The requested record was not found.',
      'unavailable' => 'Service is temporarily unavailable. Try again.',
      _ => 'Something went wrong. Please try again.',
    };

/// Builds an `auditEvents` document payload. Used inside repository
/// transactions so a status change and its audit log commit atomically
/// (rules #7, #23).
Map<String, dynamic> auditEventData({
  required String tenantId,
  required String actorId,
  required AuditAction action,
  required String entityType,
  required String entityId,
  UserRole actorRole = UserRole.admin,
  Map<String, dynamic> metadata = const {},
}) {
  return {
    'tenantId': tenantId,
    'actorId': actorId,
    'actorRole': actorRole.name,
    'action': action.name,
    'entityType': entityType,
    'entityId': entityId,
    'metadata': metadata,
    'timestamp': FieldValue.serverTimestamp(),
  };
}

/// Shared helpers for Firestore repositories.
mixin FirestoreRepository {
  FirebaseFirestore get db;

  CollectionReference<Map<String, dynamic>> col(String name) =>
      db.collection(name);

  DocumentReference<Map<String, dynamic>> auditDoc() =>
      db.collection(Collections.auditEvents).doc();
}
