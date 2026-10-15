import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:strong_box/core/errors/app_exception.dart';
import 'package:strong_box/core/models/app_user.dart';
import 'package:strong_box/core/models/job.dart';
import 'package:strong_box/features/admin/providers/clients_providers.dart';
import 'package:strong_box/features/admin/providers/fleet_providers.dart';
import 'package:strong_box/features/admin/screens/admin_fleet_screen.dart';
import 'package:strong_box/repositories/driver_invite_repository.dart';
import 'package:strong_box/repositories/repository_providers.dart';

class _FakeInvites implements DriverInviteRepository {
  final invited = <(String, String, String?)>[];
  AppException? failWith;

  @override
  Future<({String uid, String link})> invite({
    required String name,
    required String email,
    String? phone,
  }) async {
    if (failWith != null) throw failWith!;
    invited.add((name, email, phone));
    return (uid: 'drv-9', link: 'https://auth.test/reset?oobCode=abc');
  }

  @override
  Future<String> resend(String uid) async => 'https://auth.test/again';
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  late _FakeInvites invites;

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(initialLocation: '/admin/fleet', routes: [
      GoRoute(
          path: '/admin/fleet',
          builder: (_, _) => const Scaffold(body: AdminFleetScreen())),
      GoRoute(
          path: '/admin/fleet/:id',
          builder: (_, state) =>
              Scaffold(body: Text('driver ${state.pathParameters['id']}'))),
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        driverInviteRepositoryProvider.overrideWithValue(invites),
        driverUsersProvider
            .overrideWith((ref) => Stream.value(const <AppUser>[])),
        activeJobsByDriverProvider.overrideWithValue(const <String, Job>{}),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> fillInvite(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.person_add));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Dee Driver');
    await tester.enterText(fields.at(1), 'dee@x.co');
    await tester.enterText(fields.at(2), '0710000000');
    await tester.tap(find.text('Send Invite'));
    await tester.pumpAndSettle();
  }

  testWidgets('inviting opens the driver and shows the setup link',
      (tester) async {
    invites = _FakeInvites();
    await pump(tester);
    await fillInvite(tester);

    expect(invites.invited, [('Dee Driver', 'dee@x.co', '0710000000')]);
    expect(find.text('Invite sent'), findsOneWidget);
    expect(find.text('https://auth.test/reset?oobCode=abc'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('driver drv-9'), findsOneWidget);
  });

  testWidgets('the server explains why an email cannot be invited',
      (tester) async {
    invites = _FakeInvites()
      ..failWith = const AppException(
          code: 'already-exists',
          message: 'dee@x.co already has an account — make them a Driver '
              'in Settings → Team.');
    await pump(tester);
    await fillInvite(tester);

    expect(find.textContaining('Settings → Team'), findsOneWidget);
    expect(find.text('Invite sent'), findsNothing);
    expect(find.text('Invite Driver'), findsOneWidget); // dialog stays open
  });
}
