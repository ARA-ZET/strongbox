# 09 — Repositories

Repositories are the single access point for all Firebase data. No provider or widget ever calls Firestore or Firebase Storage directly.

---

## Rules for All Repositories
- Every query includes `where('tenantId', isEqualTo: tenantId)`
- Every query includes `where('isDeleted', isEqualTo: false)` unless explicitly fetching deleted
- All multi-document writes use `WriteBatch` or `Transaction`
- Status changes always create an `AuditEvent` in the same transaction
- Never throw raw `FirebaseException` — wrap in `AppException` with a friendly code

---

## StorageUnitRepository

```dart
abstract class StorageUnitRepository {
  // Streams
  Stream<List<StorageUnit>> watchAll({
    required String tenantId,
    String? clientId,
    StorageStatus? status,
    UnitType? type,
    DocumentSnapshot? startAfter,
    int limit = 20,
  });

  Stream<StorageUnit> watchUnit(String id);

  // Reads
  Future<StorageUnit?> getUnit(String id);
  Future<List<StorageUnit>> getByIds(List<String> ids);

  // Writes
  Future<StorageUnit> create(StorageUnit unit, {required String actorId});
  Future<void> update(String id, Map<String, dynamic> fields, {required String actorId});
  Future<void> updateStatus(
    String id,
    StorageStatus newStatus, {
    required String actorId,
    String? jobId,
  });
  Future<void> softDelete(String id, {required String actorId});
  Future<void> linkQRCode(String unitId, String qrCodeId, {required String actorId});
  Future<void> addPhotoId(String unitId, String photoId);
}
```

**Implementation notes:**
- `updateStatus` uses a Firestore transaction to simultaneously update the unit status, write an `AuditEvent`, and update the job's unit scan status
- `create` generates a unique QR code ID if none provided, writes to both `storageUnits` and `qrCodes` collections atomically

---

## JobRepository

```dart
abstract class JobRepository {
  // Streams
  Stream<List<Job>> watchAll({
    required String tenantId,
    String? clientId,
    String? driverId,
    JobStatus? status,
    JobType? type,
    DateTime? date,
    DocumentSnapshot? startAfter,
    int limit = 20,
  });

  Stream<Job> watchJob(String id);

  // Reads
  Future<Job?> getJob(String id);
  Future<List<Job>> getTodaysJobs(String tenantId, String driverId);

  // Writes
  Future<Job> create(Job job, {required String actorId});
  Future<void> assignDriver(String jobId, String driverId, {required String actorId});
  Future<void> updateStatus(String jobId, JobStatus newStatus, {required String actorId});
  Future<void> addDriverPhoto(String jobId, String photoId);
  Future<void> completeSignOff(String jobId, String signatureUrl, {required String actorId});
  Future<void> cancel(String jobId, String reason, {required String actorId});
  Future<void> addJobEvent(String jobId, JobEvent event);

  // Unit scan tracking
  Future<void> markUnitScanned(String jobId, String unitId, {required String actorId});
}
```

**Implementation notes:**
- `updateStatus` is a transaction: update job, update all linked storage unit statuses, write audit event
- `completeSignOff` is a transaction: set signature URL, set status to completed, update all unit statuses, write audit event

---

## ClientRepository

```dart
abstract class ClientRepository {
  Stream<List<Client>> watchAll({required String tenantId, String? searchQuery});
  Stream<Client> watchClient(String id);
  Future<Client?> getClient(String id);
  Future<Client?> getClientByUserId(String userId);
  Future<Client> create(Client client, {required String actorId});
  Future<void> update(String id, Map<String, dynamic> fields, {required String actorId});
  Future<void> addMember(String clientId, String userId);
  Future<void> removeMember(String clientId, String userId);
  Future<void> softDelete(String id, {required String actorId});
}
```

---

## UserRepository

```dart
abstract class UserRepository {
  Future<AppUser?> getUser(String uid);
  Stream<AppUser> watchUser(String uid);
  Future<void> createUser(AppUser user);
  Future<void> updateUser(String uid, Map<String, dynamic> fields);
  Future<void> updateFCMToken(String uid, String token);
  Future<void> softDelete(String uid, {required String actorId});
}
```

---

## QRRepository

```dart
abstract class QRRepository {
  // Batch operations
  Future<QRBatch> generateBatch({
    required String tenantId,
    required int count,
    required String resolution,
    required String createdBy,
  });

  Stream<List<QRBatch>> watchBatches(String tenantId);

  // Linking
  Future<void> linkToUnit(String codeId, String unitId, {required String actorId});
  Future<QRCode?> getCode(String codeId);
  Future<bool> isLinked(String codeId);

  // Lookup by scan
  Future<QRCode?> resolveCode(String scannedValue);
}
```

**Implementation notes:**
- `generateBatch` generates N unique IDs in `SBX-{4digits}-{letter}{digit}` format, verifies uniqueness against Firestore, writes batch and all codes atomically
- `linkToUnit` is a transaction: update `qrCodes` doc, update `storageUnits.qrCodeId`, increment `qrBatches.linkedCount`, write audit event

---

## PhotoRepository

```dart
abstract class PhotoRepository {
  // Upload
  Future<Photo> uploadPhoto({
    required String tenantId,
    required XFile file,
    required PhotoType type,
    required String entityType,
    required String entityId,
    String? jobId,
    required String uploadedBy,
  });

  // Read
  Future<List<Photo>> getPhotosForEntity(String entityId);
  Stream<List<Photo>> watchPhotosForEntity(String entityId);

  // Delete
  Future<void> softDelete(String photoId, {required String actorId});
}
```

**Implementation notes:**
- Compress image to max 1280px before upload using `image` package
- Upload to Firebase Storage, get download URL, write `Photo` document to Firestore
- Attach custom metadata to Storage file

---

## AuditRepository

```dart
abstract class AuditRepository {
  // Write (append-only)
  Future<void> log(AuditEvent event);

  // Read
  Stream<List<AuditEvent>> watchForEntity(String entityId, {int limit = 20});
  Stream<List<AuditEvent>> watchAll(String tenantId, {int limit = 50});
  Future<List<AuditEvent>> getForEntity(String entityId);
}
```

**Implementation notes:**
- No update or delete methods — intentional
- All writes set `timestamp: FieldValue.serverTimestamp()`

---

## SubscriptionRepository

```dart
abstract class SubscriptionRepository {
  Stream<Subscription?> watchSubscription(String clientId);
  Stream<List<Invoice>> watchInvoices(String clientId);
  Future<String> createCheckoutSession(String clientId, String priceId);
  Future<String> createPortalLink(String clientId);
}
```

**Implementation notes:**
- `createCheckoutSession` and `createPortalLink` call Firebase Cloud Functions (Stripe extension)
- Subscription and Invoice documents are written by the Stripe webhook Cloud Function, not by the app

---

## ShiftRepository

```dart
abstract class ShiftRepository {
  Stream<DriverShift?> watchActiveShift(String driverId);
  Future<DriverShift> startShift(String driverId, String tenantId);
  Future<void> endShift(String shiftId);
  Future<void> startBreak(String shiftId);
  Future<void> endBreak(String shiftId);
  Future<List<DriverShift>> getShiftHistory(String driverId);
}
```

---

## Dependency Injection

All repositories are provided via Riverpod providers:

```dart
@riverpod
StorageUnitRepository storageUnitRepository(StorageUnitRepositoryRef ref) =>
    FirestoreStorageUnitRepository(FirebaseFirestore.instance);

@riverpod
JobRepository jobRepository(JobRepositoryRef ref) =>
    FirestoreJobRepository(FirebaseFirestore.instance);

// etc.
```

This makes it easy to swap implementations (e.g. mock repositories for testing).
