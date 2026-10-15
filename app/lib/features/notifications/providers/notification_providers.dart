import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/app_notification.dart';
import '../../../core/providers/tenant_provider.dart';
import '../../../core/utils/async_value_ext.dart';
import '../../../repositories/push_repository.dart';
import '../../../repositories/repository_providers.dart';
import '../../auth/providers/auth_provider.dart';

part 'notification_providers.g.dart';

/// The signed-in user's notifications, newest first (doc 22). Written by
/// Cloud Functions on job and billing events, and by admins' messages.
@riverpod
Stream<List<AppNotification>> myNotifications(Ref ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(const []);
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref
      .watch(notificationRepositoryProvider)
      .watchForUser(tenantId, uid);
}

/// Unread count for the bell badge.
@riverpod
int unreadNotificationCount(Ref ref) =>
    (ref.watch(myNotificationsProvider).valueOrNull ?? const [])
        .where((n) => !n.isRead)
        .length;

/// Mark-read actions for the inbox.
@riverpod
class NotificationActions extends _$NotificationActions {
  @override
  FutureOr<void> build() {}

  /// Marks [notification] read (no-op when it already is).
  Future<void> markRead(AppNotification notification) async {
    if (notification.isRead) return;
    state = await AsyncValue.guard(() => ref
        .read(notificationRepositoryProvider)
        .markRead(notification.id));
    state.throwIfError();
  }

  /// Marks all of the signed-in user's notifications read.
  Future<void> markAllRead() async {
    final uid = ref.read(currentActorIdProvider);
    if (uid.isEmpty) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(notificationRepositoryProvider)
        .markAllRead(ref.read(currentTenantIdProvider), uid));
    state.throwIfError();
  }
}

/// Registers this device for push while someone is signed in (doc 22).
///
/// Phones ask for permission at sign-in. Browsers only prompt reliably from
/// a click, so on web [PushPermissionBanner] calls [enable] instead.
@Riverpod(keepAlive: true)
class PushNotifications extends _$PushNotifications {
  StreamSubscription<String>? _refresh;
  String? _uid;
  String? _token;

  @override
  Future<PushPermission> build() async {
    final uid =
        ref.watch(authStateProvider.select((auth) => auth.valueOrNull?.uid));
    ref.onDispose(() => _refresh?.cancel());
    _uid = uid;
    _token = null;
    if (uid == null) return PushPermission.unsupported;

    final push = ref.watch(pushRepositoryProvider);
    var status = await push.permission();
    if (status == PushPermission.notDetermined && !kIsWeb) {
      status = await push.requestPermission();
    }
    if (status == PushPermission.granted) await _register(uid);
    return status;
  }

  /// Asks for permission (call from a tap) and registers when granted.
  Future<void> enable() async {
    final uid = _uid;
    if (uid == null) return;
    final status = await ref.read(pushRepositoryProvider).requestPermission();
    if (status == PushPermission.granted) await _register(uid);
    state = AsyncData(status);
  }

  /// Forgets this device's token so the next person to sign in here does
  /// not receive the previous user's pushes. Never throws.
  Future<void> unregister() async {
    final uid = _uid;
    final token = _token;
    await _refresh?.cancel();
    _refresh = null;
    if (uid == null || token == null) return;
    try {
      await ref.read(userRepositoryProvider).removeFcmToken(uid, token);
    } catch (error) {
      debugPrint('Could not remove push token: $error');
    }
  }

  Future<void> _register(String uid) async {
    final push = ref.read(pushRepositoryProvider);
    final users = ref.read(userRepositoryProvider);

    Future<void> save(String token) async {
      _token = token;
      try {
        await users.addFcmToken(uid, token);
      } catch (error) {
        debugPrint('Could not save push token: $error');
      }
    }

    final token = await push.token();
    if (token != null) await save(token);
    await _refresh?.cancel();
    _refresh = push.onTokenRefresh.listen(save);
  }
}
