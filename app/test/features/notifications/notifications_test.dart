import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:strong_box/core/enums/app_enums.dart';
import 'package:strong_box/core/models/app_notification.dart';
import 'package:strong_box/core/models/audit_event.dart';
import 'package:strong_box/features/auth/providers/auth_provider.dart';
import 'package:strong_box/features/notifications/providers/notification_providers.dart';
import 'package:strong_box/features/notifications/widgets/notification_inbox.dart';
import 'package:strong_box/repositories/notification_repository.dart';
import 'package:strong_box/repositories/push_repository.dart';
import 'package:strong_box/repositories/repository_providers.dart';
import 'package:strong_box/repositories/user_repository.dart';

class _FakeUser implements User {
  _FakeUser(this.uid);

  @override
  final String uid;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNotificationRepository implements NotificationRepository {
  _FakeNotificationRepository(this.items);

  final List<AppNotification> items;
  final read = <String>[];
  var allRead = 0;

  @override
  Stream<List<AppNotification>> watchForUser(String tenantId, String userId) =>
      Stream.value(items);

  @override
  Future<void> markRead(String notificationId) async =>
      read.add(notificationId);

  @override
  Future<void> markAllRead(String tenantId, String userId) async => allRead++;

  @override
  Stream<List<AppNotification>> watchAdminAlerts(String tenantId) =>
      Stream.value(const []);

  @override
  Stream<List<AuditEvent>> watchFeed(String tenantId, {int limit = 50}) =>
      Stream.value(const []);

  @override
  Future<void> create({
    required String tenantId,
    required NotificationType type,
    required String title,
    required String body,
    String? userId,
    String? entityType,
    String? entityId,
  }) async {}
}

class _FakePushRepository implements PushRepository {
  _FakePushRepository(this.status);

  PushPermission status;
  final refresh = StreamController<String>.broadcast();
  var prompts = 0;

  @override
  Future<PushPermission> permission() async => status;

  @override
  Future<PushPermission> requestPermission() async {
    prompts++;
    return status = PushPermission.granted;
  }

  @override
  Future<String?> token() async => 'token-1';

  @override
  Stream<String> get onTokenRefresh => refresh.stream;

  @override
  Stream<PushMessage> get onForegroundMessage => const Stream.empty();

  @override
  Stream<PushMessage> get onMessageOpened => const Stream.empty();

  @override
  Future<PushMessage?> initialMessage() async => null;
}

class _FakeUserRepository implements UserRepository {
  final tokens = <String>{};

  @override
  Future<void> addFcmToken(String uid, String token) async => tokens.add(token);

  @override
  Future<void> removeFcmToken(String uid, String token) async =>
      tokens.remove(token);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AppNotification _n(String id,
        {bool read = false, String? route, String title = 'Title'}) =>
    AppNotification(
      id: id,
      tenantId: 'strongbox-default',
      type: NotificationType.jobAssigned,
      title: title,
      body: 'Body',
      userId: 'driver-1',
      route: route,
      isRead: read,
      createdAt: DateTime.now(),
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('a notification type this build does not know still parses', () {
    final n = AppNotification.fromJson({
      'id': 'n1',
      'tenantId': 'strongbox-default',
      'type': 'somethingNewer',
      'title': 'Hi',
      'route': '/driver/jobs/j1',
    });
    expect(n.type, NotificationType.systemAlert);
    expect(n.route, '/driver/jobs/j1');
  });

  group('NotificationInbox', () {
    late _FakeNotificationRepository repo;

    Future<void> pump(WidgetTester tester) async {
      final router = GoRouter(routes: [
        GoRoute(
          path: '/',
          builder: (_, _) =>
              const Scaffold(body: SingleChildScrollView(child: NotificationInbox())),
        ),
        GoRoute(
          path: '/driver/jobs/:id',
          builder: (_, state) =>
              Text('job ${state.pathParameters['id']}'),
        ),
      ]);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(repo),
          authStateProvider
              .overrideWith((ref) => Stream.value(_FakeUser('driver-1'))),
          currentActorIdProvider.overrideWithValue('driver-1'),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('counts unread and marks all read', (tester) async {
      repo = _FakeNotificationRepository(
          [_n('a'), _n('b'), _n('c', read: true)]);
      await pump(tester);
      expect(find.text('2 unread'), findsOneWidget);
      await tester.tap(find.text('Mark all read'));
      await tester.pump();
      expect(repo.allRead, 1);
    });

    testWidgets('tapping marks read and opens the route', (tester) async {
      repo = _FakeNotificationRepository(
          [_n('a', route: '/driver/jobs/j1', title: 'New pickup assigned')]);
      await pump(tester);
      await tester.tap(find.text('New pickup assigned'));
      await tester.pumpAndSettle();
      expect(repo.read, ['a']);
      expect(find.text('job j1'), findsOneWidget);
    });

    testWidgets('empty inbox explains what will appear', (tester) async {
      repo = _FakeNotificationRepository(const []);
      await pump(tester);
      expect(find.text('All caught up'), findsOneWidget);
      expect(find.text('No notifications yet'), findsOneWidget);
    });
  });

  group('PushNotifications', () {
    late _FakePushRepository push;
    late _FakeUserRepository users;
    late StreamController<User?> auth;
    late ProviderContainer container;

    setUp(() {
      users = _FakeUserRepository();
      auth = StreamController<User?>.broadcast();
    });
    tearDown(() {
      container.dispose();
      auth.close();
    });

    ProviderContainer make(PushPermission status) {
      push = _FakePushRepository(status);
      return container = ProviderContainer(overrides: [
        pushRepositoryProvider.overrideWithValue(push),
        userRepositoryProvider.overrideWithValue(users),
        authStateProvider.overrideWith((ref) => auth.stream),
      ]);
    }

    Future<PushPermission> signIn(String uid) async {
      final sub = container.listen(pushNotificationsProvider, (_, _) {});
      addTearDown(sub.close);
      auth.add(_FakeUser(uid));
      await Future<void>.delayed(Duration.zero);
      return container.read(pushNotificationsProvider.future);
    }

    test('saves the device token once permission is granted', () async {
      make(PushPermission.granted);
      expect(await signIn('u1'), PushPermission.granted);
      expect(users.tokens, {'token-1'});

      push.refresh.add('token-2');
      await Future<void>.delayed(Duration.zero);
      expect(users.tokens, {'token-1', 'token-2'});
    });

    test('phones ask for permission at sign-in', () async {
      make(PushPermission.notDetermined);
      expect(await signIn('u1'), PushPermission.granted);
      expect(push.prompts, 1);
      expect(users.tokens, {'token-1'});
    });

    test('a refused device is left alone', () async {
      make(PushPermission.denied);
      expect(await signIn('u1'), PushPermission.denied);
      expect(users.tokens, isEmpty);
    });

    test('signing out forgets this device', () async {
      make(PushPermission.granted);
      await signIn('u1');
      await container.read(pushNotificationsProvider.notifier).unregister();
      expect(users.tokens, isEmpty);
    });
  });
}
