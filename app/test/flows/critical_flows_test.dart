/// The three critical user flows (Stage 7.7), driven through the real
/// providers and the real Firestore repositories on an in-memory Firestore,
/// so batches, transactions, unit status changes and audit events are all
/// exercised. Push, email and invoices happen server-side and are covered by
/// functions/test-emulator.
library;

import 'dart:typed_data';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strong_box/core/enums/app_enums.dart';
import 'package:strong_box/core/models/job.dart';
import 'package:strong_box/core/models/photo.dart';
import 'package:strong_box/features/admin/providers/jobs_providers.dart';
import 'package:strong_box/features/auth/providers/auth_provider.dart';
import 'package:strong_box/features/client/providers/client_providers.dart';
import 'package:strong_box/features/driver/providers/driver_jobs_providers.dart';
import 'package:strong_box/repositories/photo_repository.dart';
import 'package:strong_box/repositories/repository_providers.dart';

const _tenant = 'strongbox-default';

class _FakeUser implements User {
  _FakeUser(this.uid);

  @override
  final String uid;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Storage stand-in: records the signature path and hands back a URL.
class _FakePhotoRepository implements PhotoRepository {
  final signatures = <String>[];

  @override
  Future<String> uploadSignature(
      {required Uint8List png, required String storagePath}) async {
    signatures.add(storagePath);
    return 'https://storage.test/$storagePath';
  }

  @override
  Future<List<Photo>> getForEntity(String entityId) async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeFirebaseFirestore db;
  late _FakePhotoRepository photos;

  setUp(() async {
    db = FakeFirebaseFirestore();
    photos = _FakePhotoRepository();
    await db.collection('clients').doc('client-1').set({
      'tenantId': _tenant,
      'primaryUserId': 'client-user',
      'displayName': 'Thandi Nkosi',
      'address': {'line1': '12 Long St', 'city': 'Cape Town'},
      'isDeleted': false,
    });
  });

  ProviderContainer containerFor(String uid) {
    final container = ProviderContainer(overrides: [
      firestoreProvider.overrideWithValue(db),
      photoRepositoryProvider.overrideWithValue(photos),
      authStateProvider.overrideWith((ref) => Stream.value(_FakeUser(uid))),
      currentActorIdProvider.overrideWithValue(uid),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  Future<void> seedUnits(StorageStatus status, {String? jobId}) async {
    for (final id in ['u1', 'u2']) {
      await db.collection('storageUnits').doc(id).set({
        'tenantId': _tenant,
        'clientId': 'client-1',
        'qrCodeId': 'SBX-000${id.substring(1)}-A1',
        'label': 'Box $id',
        'priceKey': 'small',
        'monthlyRateZar': 195,
        'status': status.name,
        'jobId': jobId,
        'isDeleted': false,
      });
    }
  }

  Future<Map<String, String>> unitStatuses() async {
    final snap = await db.collection('storageUnits').get();
    return {for (final d in snap.docs) d.id: d['status'] as String};
  }

  Future<List<String>> auditActions() async {
    final snap = await db.collection('auditEvents').get();
    return snap.docs.map((d) => d['action'] as String).toList();
  }

  /// The admin Jobs list, as the Jobs screen reads it.
  Future<List<Job>> adminJobsList() async {
    final admin = containerFor('admin-1');
    final sub = admin.listen(allJobsProvider, (_, _) {});
    addTearDown(sub.close);
    return admin.read(allJobsProvider.future);
  }

  test('1. an admin creates a delivery and it appears in the Jobs list',
      () async {
    await seedUnits(StorageStatus.inStorage);
    final admin = containerFor('admin-1');

    await admin.read(jobMutationsProvider.notifier).submit(NewJobData(
          type: JobType.delivery,
          clientId: 'client-1',
          unitIds: const {'u1', 'u2'},
          scheduledDate: DateTime(2026, 11, 3),
          timeWindow: TimeWindow.afternoon,
          driverId: 'driver-1',
        ));

    final jobs = await adminJobsList();
    expect(jobs, hasLength(1));
    final job = jobs.single;
    expect(job.type, JobType.delivery);
    expect(job.status, JobStatus.assigned); // driver chosen in the wizard
    expect(job.driverId, 'driver-1');
    expect(job.storageUnitIds, unorderedEquals(['u1', 'u2']));
    expect(await unitStatuses(),
        {'u1': 'pendingDelivery', 'u2': 'pendingDelivery'});
    expect(await auditActions(), ['jobCreated']);
  });

  test('2. a driver completes a pickup: start, scan every box, sign off',
      () async {
    await db.collection('jobs').doc('job-1').set({
      'tenantId': _tenant,
      'type': 'pickup',
      'clientId': 'client-1',
      'driverId': 'driver-1',
      'status': 'assigned',
      'storageUnitIds': ['u1', 'u2'],
      'scannedUnitIds': <String>[],
      'isDeleted': false,
    });
    await seedUnits(StorageStatus.pendingPickup, jobId: 'job-1');
    final driver = containerFor('driver-1');
    final actions = driver.read(driverJobActionsProvider.notifier);
    final jobs = driver.read(jobRepositoryProvider);

    await actions.startJob((await jobs.getJob('job-1'))!);
    expect((await jobs.getJob('job-1'))!.status, JobStatus.inProgress);
    expect(await unitStatuses(), {'u1': 'inTransit', 'u2': 'inTransit'});

    // Scan each label as the scanner screen does.
    for (final code in ['SBX-0001-A1', 'SBX-0002-A1']) {
      final unit = await driver.read(unitByScanProvider(code).future);
      expect(unit, isNotNull, reason: code);
      await actions.confirmUnit('job-1', unit!.id);
    }
    final scanned = (await jobs.getJob('job-1'))!;
    expect(scanned.allUnitsScanned, isTrue);

    await actions.completeJob(scanned, Uint8List.fromList([1, 2, 3]));
    final done = (await jobs.getJob('job-1'))!;
    expect(done.status, JobStatus.completed);
    expect(done.clientSignatureUrl,
        'https://storage.test/$_tenant/jobs/job-1/signature.png');
    expect(await unitStatuses(), {'u1': 'inStorage', 'u2': 'inStorage'});
    expect(await auditActions(), containsAll(
        ['jobStarted', 'qrScanned', 'qrScanned', 'clientSignOff']));
  });

  test('3. a client requests a delivery and admins see it to dispatch',
      () async {
    await seedUnits(StorageStatus.inStorage);
    final client = containerFor('client-user');
    final sub = client.listen(currentClientProvider, (_, _) {});
    addTearDown(sub.close);
    expect((await client.read(currentClientProvider.future))!.id, 'client-1');

    final request = client.read(deliveryRequestProvider.notifier)
      ..toggleUnit('u1')
      ..setSchedule(date: DateTime(2026, 11, 5), timeWindow: TimeWindow.morning)
      ..setInstructions('Ring the gate bell');
    await request.submit();

    final jobs = await adminJobsList();
    expect(jobs, hasLength(1));
    final job = jobs.single;
    expect(job.type, JobType.delivery);
    expect(job.status, JobStatus.scheduled);
    expect(job.driverId, isNull); // waits for dispatch
    expect(job.clientId, 'client-1');
    expect(job.storageUnitIds, ['u1']);
    expect(job.address.line1, '12 Long St'); // saved address by default
    expect(job.notes, 'Ring the gate bell');
    expect(await unitStatuses(), {'u1': 'pendingDelivery', 'u2': 'inStorage'});
  });
}
