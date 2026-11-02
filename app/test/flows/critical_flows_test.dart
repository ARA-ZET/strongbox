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
import 'package:strong_box/core/errors/app_exception.dart';
import 'package:strong_box/core/models/value_objects.dart';
import 'package:strong_box/core/models/job.dart';
import 'package:strong_box/core/models/photo.dart';
import 'package:strong_box/features/admin/providers/jobs_providers.dart';
import 'package:strong_box/features/auth/providers/auth_provider.dart';
import 'package:strong_box/features/client/providers/client_providers.dart';
import 'package:strong_box/features/driver/providers/driver_jobs_providers.dart';
import 'package:strong_box/repositories/booking_repository.dart';
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
  final unitPhotos = <String>[];

  @override
  Future<String> addUnitPhoto({
    required String tenantId,
    required String unitId,
    required Uint8List bytes,
    required PhotoType type,
    required String storagePath,
    required String uploadedBy,
  }) async {
    unitPhotos.add('$unitId $type $storagePath $uploadedBy');
    return 'photo-${unitPhotos.length}';
  }

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

  ProviderContainer containerFor(String uid,
      {List<Override> extra = const []}) {
    final container = ProviderContainer(overrides: [
      ...extra,
      firestoreProvider.overrideWithValue(db),
      photoRepositoryProvider.overrideWithValue(photos),
      authStateProvider.overrideWith((ref) => Stream.value(_FakeUser(uid))),
      currentActorIdProvider.overrideWithValue(uid),
      currentUserIdProvider.overrideWithValue(uid),
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

  /// A job doc as the bookPickup / requestDelivery functions write it.
  Future<void> seedJob(String id, Map<String, dynamic> fields) =>
      db.collection('jobs').doc(id).set({
        'tenantId': _tenant,
        'clientId': 'client-1',
        'driverId': null,
        'status': 'pendingConfirmation',
        'timeWindow': 'morning',
        'storageUnitIds': ['u1', 'u2'],
        'scannedUnitIds': <String>[],
        'receivedUnitIds': <String>[],
        'handedOverUnitIds': <String>[],
        'isDeleted': false,
        ...fields,
      });

  Future<Map<String, dynamic>> unitData(String id) async =>
      (await db.collection('storageUnits').doc(id).get()).data()!;

  test('2. a booked pickup: confirm, collect at the door, receive at the '
      'facility', () async {
    await seedJob('job-1', {'type': 'pickup', 'source': 'quote'});
    await seedUnits(StorageStatus.pendingPickup, jobId: 'job-1');
    final admin = containerFor('admin-1');
    final driver = containerFor('driver-1');
    final actions = driver.read(driverJobActionsProvider.notifier);
    final jobs = driver.read(jobRepositoryProvider);
    Future<Job> job() async => (await jobs.getJob('job-1'))!;

    // Ops confirms and dispatches in one go.
    await admin
        .read(jobMutationsProvider.notifier)
        .confirm(await job(), driverId: 'driver-1');
    expect((await job()).status, JobStatus.assigned);
    expect((await job()).confirmedBy, 'admin-1');

    // Starting a pickup means leaving for the client; units stay put.
    await actions.startJob(await job());
    expect((await job()).status, JobStatus.inProgress);
    expect((await job()).departedAt, isNotNull);
    expect(scanStepFor(await job()), isNull); // not there yet
    await actions.markArrived(await job());
    expect(scanStepFor(await job()), ScanStep.collect);
    expect(await unitStatuses(), {'u1': 'pendingPickup', 'u2': 'pendingPickup'});

    // Scan each label as the scanner screen does.
    for (final code in ['SBX-0001-A1', 'SBX-0002-A1']) {
      final unit = await driver.read(unitByScanProvider(code).future);
      expect(unit, isNotNull, reason: code);
      await actions.confirmUnit('job-1', unit!.id, step: ScanStep.collect);
    }
    expect((await job()).allUnitsScanned, isTrue);
    expect(await unitStatuses(), {'u1': 'inTransit', 'u2': 'inTransit'});

    await actions.completeJob(await job(), Uint8List.fromList([1, 2, 3]),
        recipientName: 'Thandi');
    final collected = await job();
    expect(collected.status, JobStatus.collected); // not stored yet
    expect(collected.recipientName, 'Thandi');
    expect(collected.clientSignatureUrl,
        'https://storage.test/$_tenant/jobs/job-1/signature.png');
    expect(await unitStatuses(), {'u1': 'inTransit', 'u2': 'inTransit'});
    expect(scanStepFor(collected), ScanStep.receive);

    // At the facility each scan puts a unit in storage at a bay.
    await actions.confirmUnit('job-1', 'u1', step: ScanStep.receive, bay: 'B-12');
    expect((await job()).status, JobStatus.collected);
    await actions.confirmUnit('job-1', 'u2', step: ScanStep.receive);
    final done = await job();
    expect(done.status, JobStatus.completed);
    expect(await unitStatuses(), {'u1': 'inStorage', 'u2': 'inStorage'});
    expect((await unitData('u1'))['warehouseLocationId'], 'B-12');
    expect(await auditActions(), containsAll([
      'jobConfirmed', 'jobStarted', 'driverArrived', 'qrScanned',
      'jobCollected', 'unitReceived',
    ]));
  });

  test('3. a client requests a delivery; ops confirms; the driver loads, '
      'hands over and the client signs', () async {
    await seedUnits(StorageStatus.inStorage);
    final booking = _FakeBooking();
    final client = containerFor('client-user',
        extra: [bookingRepositoryProvider.overrideWithValue(booking)]);
    final sub = client.listen(currentClientProvider, (_, _) {});
    addTearDown(sub.close);
    expect((await client.read(currentClientProvider.future))!.id, 'client-1');

    client.read(deliveryRequestProvider.notifier)
      ..toggleUnit('u1')
      ..setSchedule(date: DateTime(2026, 11, 5), timeWindow: TimeWindow.morning)
      ..setInstructions('Ring the gate bell');
    expect(await client.read(deliveryRequestProvider.notifier).submit(),
        'delivery-1');
    expect(booking.requested, {
      'unitIds': ['u1'],
      'address': '12 Long St', // saved address by default
      'notes': 'Ring the gate bell',
    });

    // What requestDelivery writes server-side.
    await seedJob('delivery-1',
        {'type': 'delivery', 'source': 'request', 'storageUnitIds': ['u1']});
    await db.collection('storageUnits').doc('u1').update(
        {'status': 'pendingDelivery', 'jobId': 'delivery-1'});

    final admin = containerFor('admin-1');
    final jobs = admin.read(jobRepositoryProvider);
    Future<Job> job() async => (await jobs.getJob('delivery-1'))!;
    await admin.read(jobMutationsProvider.notifier)
        .confirm(await job(), driverId: 'driver-1');

    final driver = containerFor('driver-1');
    final actions = driver.read(driverJobActionsProvider.notifier);
    await actions.startJob(await job());
    expect((await job()).departedAt, isNull); // loading at the facility
    expect(scanStepFor(await job()), ScanStep.load);
    await actions.confirmUnit('delivery-1', 'u1', step: ScanStep.load);
    expect(await unitStatuses(), {'u1': 'inTransit', 'u2': 'inStorage'});
    await actions.markDeparted(await job());
    await actions.markArrived(await job());
    expect(scanStepFor(await job()), ScanStep.handOver);
    await actions.confirmUnit('delivery-1', 'u1', step: ScanStep.handOver);
    await actions.completeJob(await job(), Uint8List.fromList([1]));

    expect((await job()).status, JobStatus.completed);
    expect(await unitStatuses(), {'u1': 'delivered', 'u2': 'inStorage'});
  });

  test('4. supplies first: confirming the pickup confirms its drop-off, '
      'which the client signs for', () async {
    await seedJob('pickup-1', {'type': 'pickup', 'source': 'quote',
      'suppliesFirst': true, 'linkedJobId': 'drop-1'});
    await seedJob('drop-1', {'type': 'supplyDrop', 'source': 'quote',
      'suppliesFirst': true, 'linkedJobId': 'pickup-1',
      'storageUnitIds': <String>[], 'emptyBoxes': {'small': 2},
      'supplies': [
        {'id': 'bubble-wrap', 'label': 'Bubble wrap', 'qty': 1, 'unitZar': 50},
      ]});
    final admin = containerFor('admin-1');
    expect(admin.read(jobsToConfirmProvider), isEmpty); // not loaded yet
    final jobs = admin.read(jobRepositoryProvider);

    await admin.read(jobMutationsProvider.notifier)
        .confirm((await jobs.getJob('pickup-1'))!, driverId: 'driver-1');
    final drop = (await jobs.getJob('drop-1'))!;
    expect(drop.status, JobStatus.assigned);
    expect(drop.driverId, 'driver-1');
    expect(drop.supplyItemCount, 3);

    final actions =
        containerFor('driver-1').read(driverJobActionsProvider.notifier);
    await actions.startJob(drop);
    await actions.markArrived((await jobs.getJob('drop-1'))!);
    await actions.completeJob(
        (await jobs.getJob('drop-1'))!, Uint8List.fromList([1]));
    expect((await jobs.getJob('drop-1'))!.status, JobStatus.completed);
    expect((await jobs.getJob('pickup-1'))!.status, JobStatus.assigned);
  });

  test('5. declining a booking cancels it and the items it created',
      () async {
    await seedJob('job-1', {'type': 'pickup', 'source': 'quote'});
    await seedUnits(StorageStatus.pendingPickup, jobId: 'job-1');
    final admin = containerFor('admin-1');
    final job = (await admin.read(jobRepositoryProvider).getJob('job-1'))!;

    await admin
        .read(jobMutationsProvider.notifier)
        .decline(job, "We don't collect there yet.");

    final declined = (await admin.read(jobRepositoryProvider).getJob('job-1'))!;
    expect(declined.status, JobStatus.cancelled);
    expect(declined.cancelReason, "We don't collect there yet.");
    expect(await unitStatuses(), {'u1': 'cancelled', 'u2': 'cancelled'});
    expect(await auditActions(), ['jobDeclined']);
  });

  test('a client photographs and describes a box while packing it',
      () async {
    await seedUnits(StorageStatus.pendingPickup);
    await db.collection('storageUnits').doc('u2').update({'status': 'inStorage'});
    final client = containerFor('client-user');
    final units = client.read(storageUnitRepositoryProvider);
    final packing = client.read(packingActionsProvider.notifier);
    final u1 = (await units.getUnit('u1'))!;
    expect(canPack(u1), isTrue);

    await packing.addPhoto(u1, Uint8List.fromList([1, 2]));
    await packing.addPhoto(u1, Uint8List.fromList([3]),
        type: PhotoType.exterior);
    expect(photos.unitPhotos, [
      allOf(startsWith('u1 PhotoType.interior $_tenant/storageUnits/u1/client/'),
          endsWith(' client-user')),
      startsWith('u1 PhotoType.exterior'),
    ]);

    await packing.saveNotes(u1, '  Winter clothes, boots  ');
    expect((await unitData('u1'))['description'], 'Winter clothes, boots');
    expect(await auditActions(), ['unitUpdated']);

    // Once it's with us, the box is read-only for the client.
    final u2 = (await units.getUnit('u2'))!;
    expect(canPack(u2), isFalse);
    expect(() => packing.addPhoto(u2, Uint8List.fromList([1])),
        throwsStateError);
  });

  test('a driver can\'t scan a unit off the manifest or skip a step',
      () async {
    await seedJob('job-1', {'type': 'pickup', 'status': 'inProgress',
      'driverId': 'driver-1', 'storageUnitIds': ['u1']});
    await seedUnits(StorageStatus.inStorage, jobId: 'job-1');
    final jobs = containerFor('driver-1').read(jobRepositoryProvider);
    final job = (await jobs.getJob('job-1'))!;
    await expectLater(jobs.collectUnit(job, 'u2', actorId: 'driver-1'),
        throwsA(isA<AppException>()));
    // u1 is already in storage — a pickup can't move it.
    await expectLater(jobs.collectUnit(job, 'u1', actorId: 'driver-1'),
        throwsA(isA<AppException>()));
    // Nobody signs before every unit is scanned.
    await expectLater(jobs.signOff(job, 'sig', actorId: 'driver-1'),
        throwsA(isA<AppException>()));
  });
}

/// The requestDelivery callable stand-in: records what the client sent.
class _FakeBooking implements BookingRepository {
  Map<String, Object?>? requested;

  @override
  Future<String> requestDelivery({
    required List<String> unitIds,
    required DateTime date,
    required TimeWindow timeWindow,
    required Address address,
    String? notes,
  }) async {
    requested = {'unitIds': unitIds, 'address': address.line1, 'notes': notes};
    return 'delivery-1';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
