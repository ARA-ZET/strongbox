import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:strong_box/core/enums/app_enums.dart';
import 'package:strong_box/core/models/app_user.dart';
import 'package:strong_box/core/providers/business_settings_provider.dart';
import 'package:strong_box/features/admin/providers/settings_providers.dart';
import 'package:strong_box/features/admin/screens/admin_settings_screen.dart';
import 'package:strong_box/features/auth/providers/auth_provider.dart';
import 'package:strong_box/repositories/repository_providers.dart';
import 'package:strong_box/repositories/tenant_repository.dart';
import 'package:strong_box/repositories/user_repository.dart';

class _FakeTenantRepository implements TenantRepository {
  final _changes = StreamController<BusinessSettings?>.broadcast();
  BusinessSettings? stored;

  @override
  Stream<BusinessSettings?> watchSettings(String tenantId) async* {
    yield stored;
    yield* _changes.stream;
  }

  @override
  Future<BusinessSettings> updateSettings(
    String tenantId,
    BusinessSettings Function(BusinessSettings current) change, {
    required String actorId,
  }) async {
    stored = change(
      stored ?? BusinessSettings.defaults,
    ).copyWith(updatedAt: DateTime(2026, 10, 15), updatedBy: actorId);
    _changes.add(stored);
    return stored!;
  }
}

class _FakeUserRepository implements UserRepository {
  _FakeUserRepository(this.users);

  final List<AppUser> users;
  final roleChanges = <(String, UserRole)>[];

  @override
  Stream<List<AppUser>> watchByRole(String tenantId, UserRole role) =>
      Stream.value(users.where((u) => u.role == role).toList());

  @override
  Future<AppUser?> findByEmail(String tenantId, String email) async {
    for (final u in users) {
      if (u.email == email.trim().toLowerCase()) return u;
    }
    return null;
  }

  @override
  Future<void> changeRole(
    AppUser user,
    UserRole role, {
    required String actorId,
  }) async {
    roleChanges.add((user.id, role));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _me = AppUser(
  id: 'admin-1',
  tenantId: 'strongbox-default',
  name: 'Rich Z',
  email: 'rich@strongbox.co.za',
  role: UserRole.admin,
);
const _driver = AppUser(
  id: 'driver-1',
  tenantId: 'strongbox-default',
  name: 'Dee Driver',
  email: 'dee@x.com',
  role: UserRole.driver,
);
const _client = AppUser(
  id: 'client-1',
  tenantId: 'strongbox-default',
  name: 'Cee Client',
  email: 'cee@x.com',
);

void main() {
  group('BusinessSettings', () {
    test('defaults reproduce the hours and contact details the app used', () {
      const s = BusinessSettings.defaults;
      expect(s.windowLabel(TimeWindow.morning), 'Morning (08:00–12:00)');
      expect(s.windowRange(TimeWindow.evening), '16:00–20:00');
      expect(s.phoneUri, 'tel:+27719090839');
      expect(validateBusinessSettings(s), isEmpty);
    });

    test('phone links fold the South African trunk 0 into +27', () {
      String uri(String phone) =>
          BusinessSettings.defaults.copyWith(contactPhone: phone).phoneUri;
      expect(uri('071 909 0839'), 'tel:+27719090839');
      expect(uri('+27 71 909 0839'), 'tel:+27719090839');
    });

    test('rejects malformed or back-to-front time windows', () {
      final bad = BusinessSettings.defaults.copyWith(
        afternoon: const WindowHours(start: '16:00', end: '12:00'),
      );
      expect(
        validateBusinessSettings(bad).first,
        'Afternoon must end after it starts.',
      );
      final typo = BusinessSettings.defaults.copyWith(
        morning: const WindowHours(start: '8am', end: '12:00'),
      );
      expect(validateBusinessSettings(typo).first, contains('HH:mm'));
    });
  });

  group('Settings screen', () {
    late _FakeTenantRepository tenants;
    late _FakeUserRepository users;
    late ProviderContainer container;

    setUp(() {
      tenants = _FakeTenantRepository();
      users = _FakeUserRepository([_me, _driver, _client]);
      container = ProviderContainer(
        overrides: [
          tenantRepositoryProvider.overrideWithValue(tenants),
          userRepositoryProvider.overrideWithValue(users),
          currentActorIdProvider.overrideWithValue(_me.id),
          currentUserProvider.overrideWith((ref) => Stream.value(_me)),
        ],
      );
    });
    tearDown(() => container.dispose());

    Future<void> pump(WidgetTester tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      tester.view.physicalSize = const Size(1400, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: AdminSettingsScreen())),
        ),
      );
      await tester.pumpAndSettle();
      tester.takeException(); // Inter isn't bundled in tests.
    }

    testWidgets('shows profile, team, business and operations sections', (
      tester,
    ) async {
      await pump(tester);
      expect(find.text('My profile'), findsOneWidget);
      expect(find.text('Team & roles'), findsOneWidget);
      expect(find.text('Business details'), findsOneWidget);
      expect(find.text('Operations'), findsOneWidget);
      expect(find.text('Rich Z (you)'), findsOneWidget);
      expect(find.text('Dee Driver'), findsOneWidget);
      expect(find.text('Cee Client'), findsNothing);
    });

    testWidgets('saving business details stores them for the whole app', (
      tester,
    ) async {
      await pump(tester);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contact email'),
        'hi@sb.co.za',
      );
      await tester.tap(find.text('Save changes').at(1));
      await tester.pumpAndSettle();

      expect(tenants.stored!.contactEmail, 'hi@sb.co.za');
      expect(
        container.read(businessSettingsProvider).contactEmail,
        'hi@sb.co.za',
      );
      expect(find.text('Business details saved'), findsOneWidget);
    });

    testWidgets('adding a team member promotes their account after confirm', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(find.text('Add team member'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Their email'),
        'cee@x.com',
      );
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Make Cee Client a driver?'), findsOneWidget);
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(users.roleChanges, [('client-1', UserRole.driver)]);
    });

    testWidgets('an unknown email explains they must sign up first', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(find.text('Add team member'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Their email'),
        'nobody@x.com',
      );
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.textContaining('No account uses nobody@x.com'), findsOneWidget);
      expect(users.roleChanges, isEmpty);
    });
  });

  test('an admin cannot change their own role', () async {
    final users = _FakeUserRepository([_me]);
    final container = ProviderContainer(
      overrides: [
        userRepositoryProvider.overrideWithValue(users),
        currentActorIdProvider.overrideWithValue(_me.id),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container
          .read(teamEditorProvider.notifier)
          .changeRole(_me, UserRole.client),
      throwsA(isA<StateError>()),
    );
    expect(users.roleChanges, isEmpty);
  });
}
