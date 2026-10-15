import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:strong_box/core/enums/app_enums.dart';
import 'package:strong_box/core/errors/app_exception.dart';
import 'package:strong_box/core/models/app_user.dart';
import 'package:strong_box/core/models/job.dart';
import 'package:strong_box/core/models/vehicle.dart';
import 'package:strong_box/core/theme/app_theme.dart';
import 'package:strong_box/features/admin/providers/clients_providers.dart';
import 'package:strong_box/features/admin/providers/fleet_providers.dart';
import 'package:strong_box/features/admin/screens/admin_fleet_screen.dart';
import 'package:strong_box/features/auth/providers/auth_provider.dart';
import 'package:strong_box/repositories/repository_providers.dart';
import 'package:strong_box/repositories/vehicle_repository.dart';

const _tenant = 'strongbox-default';
const _dee = AppUser(
    id: 'drv-1', tenantId: _tenant, name: 'Dee Driver', role: UserRole.driver);

void main() {
  group('Vehicle', () {
    final now = DateTime(2026, 10, 15);

    test('registrations are stored upper-case with single spaces', () {
      expect(normaliseRegistration('  ca 123-456 '), 'CA 123-456');
      expect(normaliseRegistration('nd   55 21'), 'ND 55 21');
    });

    test('names fall back to make and model, then the type', () {
      const base = Vehicle(id: 'v', tenantId: _tenant);
      expect(base.copyWith(name: 'Bakkie 2').displayName, 'Bakkie 2');
      expect(base.copyWith(make: 'Toyota', model: 'Hilux').displayName,
          'Toyota Hilux');
      expect(base.copyWith(type: VehicleType.trailer).displayName, 'Trailer');
    });

    test('flags licence discs that expired or expire within 30 days', () {
      const base = Vehicle(id: 'v', tenantId: _tenant);
      final expired = base.copyWith(licenceExpiresAt: DateTime(2026, 10, 1));
      final soon = base.copyWith(licenceExpiresAt: DateTime(2026, 11, 1));
      final fine = base.copyWith(licenceExpiresAt: DateTime(2027, 3, 1));
      expect(expired.licenceExpired(now), isTrue);
      expect(expired.licenceDueSoon(now), isFalse);
      expect(soon.licenceDueSoon(now), isTrue);
      expect(fine.licenceExpired(now) || fine.licenceDueSoon(now), isFalse);
      expect(base.licenceDueSoon(now), isFalse); // not set
    });
  });

  group('FirestoreVehicleRepository', () {
    late FakeFirebaseFirestore db;
    late VehicleRepository repo;

    setUp(() {
      db = FakeFirebaseFirestore();
      repo = FirestoreVehicleRepository(db);
    });

    Future<List<String>> audit() async => (await db.collection('auditEvents')
            .get())
        .docs
        .map((d) => d['action'] as String)
        .toList();

    test('adds a vehicle with an audit event', () async {
      final id = await repo.create(
          const Vehicle(id: '', tenantId: _tenant, registration: 'ca 1-2',
              name: 'Bakkie 1'),
          actorId: 'admin-1');
      final doc = await db.collection('vehicles').doc(id).get();
      expect(doc['registration'], 'CA 1-2');
      expect(doc['isDeleted'], isFalse);
      expect(doc['type'], 'bakkie');
      expect(await audit(), ['vehicleAdded']);
    });

    test('refuses a registration already in the fleet', () async {
      await repo.create(
          const Vehicle(id: '', tenantId: _tenant, registration: 'CA 1-2'),
          actorId: 'admin-1');
      await expectLater(
        repo.create(
            const Vehicle(
                id: '', tenantId: _tenant, registration: ' ca  1-2'),
            actorId: 'admin-1'),
        throwsA(isA<AppException>()
            .having((e) => e.message, 'message', contains('CA 1-2'))),
      );
    });

    test('status changes are audited; retiring is a soft delete', () async {
      final id = await repo.create(
          const Vehicle(id: '', tenantId: _tenant, registration: 'CA 9'),
          actorId: 'admin-1');
      final vehicle = (await repo.watchAll(_tenant).first).single;
      await repo.update(vehicle.copyWith(status: VehicleStatus.maintenance),
          actorId: 'admin-1');
      final events = await db.collection('auditEvents').get();
      final updated = events.docs
          .firstWhere((d) => d['action'] == 'vehicleUpdated')
          .data();
      expect(updated['metadata'],
          {'fromStatus': 'available', 'toStatus': 'maintenance'});

      await repo.retire(vehicle, actorId: 'admin-1');
      expect(await repo.watchAll(_tenant).first, isEmpty);
      final doc = await db.collection('vehicles').doc(id).get();
      expect(doc.exists, isTrue); // never hard-deleted
      expect(doc['isDeleted'], isTrue);
      // The registration is free again once retired.
      await repo.create(
          const Vehicle(id: '', tenantId: _tenant, registration: 'CA 9'),
          actorId: 'admin-1');
    });
  });

  group('Fleet → Vehicles & trailers', () {
    setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

    late FakeFirebaseFirestore db;

    Future<void> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          firestoreProvider.overrideWithValue(db),
          currentActorIdProvider.overrideWithValue('admin-1'),
          driverUsersProvider.overrideWith((ref) => Stream.value([_dee])),
          activeJobsByDriverProvider.overrideWithValue(const <String, Job>{}),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: AdminFleetScreen()),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vehicles & trailers'));
      await tester.pumpAndSettle();
    }

    setUp(() => db = FakeFirebaseFirestore());

    testWidgets('adds a bakkie with its driver', (tester) async {
      await pump(tester);
      expect(find.text('No vehicles or trailers yet'), findsOneWidget);

      await tester.tap(find.text('Add vehicle or trailer'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Name (optional)'), 'Bakkie 1');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Registration'), 'ca 123-456');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Make'), 'Toyota');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Load space (m³)'), '3,5');
      await tester.tap(find.text('Unassigned'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dee Driver').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add to fleet').last);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Bakkie 1 added to the fleet'), findsOneWidget);
      expect(find.text('CA 123-456'), findsOneWidget);
      expect(find.text('Dee Driver'), findsOneWidget);
      expect(find.text('3.5 m³'), findsOneWidget);
      final doc = (await db.collection('vehicles').get()).docs.single;
      expect(doc['assignedDriverId'], 'drv-1');
      expect(doc['capacityM3'], 3.5);
    });

    testWidgets('trailers have no driver and filter separately',
        (tester) async {
      await db.collection('vehicles').add({
        'tenantId': _tenant, 'type': 'trailer', 'name': 'Trailer 1',
        'registration': 'CA 77', 'status': 'available', 'isDeleted': false,
      });
      await db.collection('vehicles').add({
        'tenantId': _tenant, 'type': 'van', 'name': 'Van 1',
        'registration': 'CA 88', 'status': 'maintenance', 'isDeleted': false,
        'licenceExpiresAt': DateTime(2020, 1, 1),
      });
      await pump(tester);
      expect(find.text('Towed'), findsOneWidget);
      expect(find.text('In maintenance'), findsOneWidget);
      expect(find.textContaining('Expired'), findsOneWidget);

      // The summary card is also labelled "Trailers"; the filter comes last.
      await tester.tap(find.text('Trailers').last);
      await tester.pumpAndSettle();
      expect(find.text('Trailer 1'), findsOneWidget);
      expect(find.text('Van 1'), findsNothing);

      await tester.tap(find.byTooltip('Edit Trailer 1'));
      await tester.pumpAndSettle();
      expect(find.text('Usual driver'), findsNothing);
      expect(find.text('Retire'), findsOneWidget);
    });
  });
}
