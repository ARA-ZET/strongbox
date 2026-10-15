import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'audit_repository.dart';
import 'client_repository.dart';
import 'item_repository.dart';
import 'issue_repository.dart';
import 'job_repository.dart';
import 'notification_repository.dart';
import 'photo_repository.dart';
import 'price_list_repository.dart';
import 'push_repository.dart';
import 'qr_repository.dart';
import 'shift_repository.dart';
import 'storage_unit_repository.dart';
import 'subscription_repository.dart';
import 'tenant_repository.dart';
import 'user_repository.dart';

part 'repository_providers.g.dart';

/// Raw Firebase handles — referenced only here and inside repositories.
@Riverpod(keepAlive: true)
FirebaseFirestore firestore(Ref ref) => FirebaseFirestore.instance;

@Riverpod(keepAlive: true)
FirebaseStorage firebaseStorage(Ref ref) => FirebaseStorage.instance;

@Riverpod(keepAlive: true)
StorageUnitRepository storageUnitRepository(Ref ref) =>
    FirestoreStorageUnitRepository(ref.watch(firestoreProvider));

@Riverpod(keepAlive: true)
JobRepository jobRepository(Ref ref) =>
    FirestoreJobRepository(ref.watch(firestoreProvider));

@Riverpod(keepAlive: true)
ClientRepository clientRepository(Ref ref) =>
    FirestoreClientRepository(ref.watch(firestoreProvider));

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) =>
    FirestoreUserRepository(ref.watch(firestoreProvider));

@Riverpod(keepAlive: true)
QRRepository qrRepository(Ref ref) =>
    FirestoreQRRepository(ref.watch(firestoreProvider));

@Riverpod(keepAlive: true)
PhotoRepository photoRepository(Ref ref) => FirestorePhotoRepository(
      ref.watch(firestoreProvider),
      ref.watch(firebaseStorageProvider),
    );

@Riverpod(keepAlive: true)
AuditRepository auditRepository(Ref ref) =>
    FirestoreAuditRepository(ref.watch(firestoreProvider));

@Riverpod(keepAlive: true)
NotificationRepository notificationRepository(Ref ref) =>
    FirestoreNotificationRepository(ref.watch(firestoreProvider));

@Riverpod(keepAlive: true)
ShiftRepository shiftRepository(Ref ref) =>
    FirestoreShiftRepository(ref.watch(firestoreProvider));

@Riverpod(keepAlive: true)
IssueRepository issueRepository(Ref ref) =>
    FirestoreIssueRepository(ref.watch(firestoreProvider));

@Riverpod(keepAlive: true)
ItemRepository itemRepository(Ref ref) =>
    FirestoreItemRepository(ref.watch(firestoreProvider));

@Riverpod(keepAlive: true)
SubscriptionRepository subscriptionRepository(Ref ref) =>
    FirestoreSubscriptionRepository(ref.watch(firestoreProvider));

@Riverpod(keepAlive: true)
PriceListRepository priceListRepository(Ref ref) =>
    FirestorePriceListRepository(ref.watch(firestoreProvider));

@Riverpod(keepAlive: true)
TenantRepository tenantRepository(Ref ref) =>
    FirestoreTenantRepository(ref.watch(firestoreProvider));

@Riverpod(keepAlive: true)
PushRepository pushRepository(Ref ref) => FirebasePushRepository();
