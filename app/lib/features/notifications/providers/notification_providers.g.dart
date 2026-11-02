// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myNotificationsHash() => r'a573054e2044eeed599cc156037df62400e2b721';

/// The current user's notifications, newest first (doc 22). Written by
/// Cloud Functions on job and billing events, and by admins' messages.
///
/// Copied from [myNotifications].
@ProviderFor(myNotifications)
final myNotificationsProvider =
    AutoDisposeStreamProvider<List<AppNotification>>.internal(
  myNotifications,
  name: r'myNotificationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myNotificationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MyNotificationsRef
    = AutoDisposeStreamProviderRef<List<AppNotification>>;
String _$unreadNotificationCountHash() =>
    r'9fda74d18b226751cd998c1f3a8cc997607ce974';

/// Unread count for the bell badge.
///
/// Copied from [unreadNotificationCount].
@ProviderFor(unreadNotificationCount)
final unreadNotificationCountProvider = AutoDisposeProvider<int>.internal(
  unreadNotificationCount,
  name: r'unreadNotificationCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadNotificationCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UnreadNotificationCountRef = AutoDisposeProviderRef<int>;
String _$notificationActionsHash() =>
    r'203499bd51663c022eefa96957f3669cd40dd85a';

/// Mark-read actions for the inbox.
///
/// Copied from [NotificationActions].
@ProviderFor(NotificationActions)
final notificationActionsProvider =
    AsyncNotifierProvider<NotificationActions, void>.internal(
  NotificationActions.new,
  name: r'notificationActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationActions = AsyncNotifier<void>;
String _$pushNotificationsHash() => r'55398617423213d808033fec94456e7e383c767d';

/// Registers this device for push while someone is signed in (doc 22).
///
/// Phones ask for permission at sign-in. Browsers only prompt reliably from
/// a click, so on web [PushPermissionBanner] calls [enable] instead.
///
/// Copied from [PushNotifications].
@ProviderFor(PushNotifications)
final pushNotificationsProvider =
    AsyncNotifierProvider<PushNotifications, PushPermission>.internal(
  PushNotifications.new,
  name: r'pushNotificationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pushNotificationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PushNotifications = AsyncNotifier<PushPermission>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
