// "View as": an admin previews the app as another account without
// changing anyone's role. Only admins can, writes stay attributed to the
// admin, and signing out ends it.
import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strong_box/core/models/app_user.dart';
import 'package:strong_box/features/auth/providers/auth_provider.dart';
import 'package:strong_box/repositories/repository_providers.dart';

const _tenant = 'strongbox-default';

class _FakeUser implements User {
  _FakeUser(this.uid);

  @override
  final String uid;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeFirebaseFirestore db;
  late StreamController<User?> auth;

  setUp(() async {
    db = FakeFirebaseFirestore();
    auth = StreamController<User?>.broadcast();
    addTearDown(auth.close);
    for (final (id, role) in [
      ('admin-1', 'admin'),
      ('driver-1', 'driver'),
      ('client-1', 'client'),
    ]) {
      await db.collection('users').doc(id).set({
        'tenantId': _tenant,
        'name': id,
        'email': '$id@example.com',
        'role': role,
        'isDeleted': false,
      });
    }
  });

  ProviderContainer signedInAs(String uid) {
    final container = ProviderContainer(overrides: [
      firestoreProvider.overrideWithValue(db),
      authStateProvider.overrideWith((ref) async* {
        yield _FakeUser(uid);
        yield* auth.stream;
      }),
    ]);
    addTearDown(container.dispose);
    // Keep the auto-dispose providers alive between reads.
    container.listen(isViewingAsProvider, (_, _) {});
    container.listen(currentUserIdProvider, (_, _) {});
    return container;
  }

  Future<AppUser?> shown(ProviderContainer c) async {
    await pumpEventQueue();
    return c.read(currentUserProvider).valueOrNull;
  }

  AppUser user(String id) => AppUser(id: id, tenantId: _tenant);

  test('an admin sees another account and comes back', () async {
    final c = signedInAs('admin-1');
    expect((await shown(c))?.id, 'admin-1');

    c.read(viewAsProvider.notifier).start(user('driver-1'));
    final viewed = await shown(c);
    expect(viewed?.id, 'driver-1');
    expect(viewed?.isDriver, isTrue);
    expect(c.read(isViewingAsProvider), isTrue);
    expect(c.read(currentUserIdProvider), 'driver-1');
    // Writes are still logged under the admin.
    expect(c.read(currentActorIdProvider), 'admin-1');
    expect(c.read(signedInUserProvider).valueOrNull?.id, 'admin-1');

    c.read(viewAsProvider.notifier).stop();
    expect((await shown(c))?.id, 'admin-1');
    expect(c.read(isViewingAsProvider), isFalse);
  });

  test('a non-admin cannot view as someone else', () async {
    final c = signedInAs('client-1');
    await shown(c);

    c.read(viewAsProvider.notifier).start(user('driver-1'));
    expect((await shown(c))?.id, 'client-1');
    expect(c.read(isViewingAsProvider), isFalse);
  });

  test('signing out ends view-as', () async {
    final c = signedInAs('admin-1');
    await shown(c);
    c.read(viewAsProvider.notifier).start(user('client-1'));
    expect((await shown(c))?.id, 'client-1');

    auth.add(null);
    await pumpEventQueue();
    expect(c.read(viewAsProvider), isNull);
    expect(await shown(c), isNull);
  });
}
