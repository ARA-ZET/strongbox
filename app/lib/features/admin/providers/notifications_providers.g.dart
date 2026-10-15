// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationFeedHash() => r'1f4830925cb1223bcb936cf270906d201b4cd96c';

/// Read-only alert feed (audit events; see NotificationRepository note).
///
/// Copied from [notificationFeed].
@ProviderFor(notificationFeed)
final notificationFeedProvider =
    AutoDisposeStreamProvider<List<AuditEvent>>.internal(
  notificationFeed,
  name: r'notificationFeedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationFeedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NotificationFeedRef = AutoDisposeStreamProviderRef<List<AuditEvent>>;
String _$adminAlertsHash() => r'c52b56c781d11ddc87d80f0a9967d3d01a773dff';

/// Unread alerts for all admins — delivery requests awaiting a driver,
/// invoice runs, unused QR labels (written by Cloud Functions).
///
/// Copied from [adminAlerts].
@ProviderFor(adminAlerts)
final adminAlertsProvider =
    AutoDisposeStreamProvider<List<AppNotification>>.internal(
  adminAlerts,
  name: r'adminAlertsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$adminAlertsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AdminAlertsRef = AutoDisposeStreamProviderRef<List<AppNotification>>;
String _$notificationCategoryFilterHash() =>
    r'b2b4b2893f18c3d570e23eb5f53ffa17f42cdd11';

/// Selected category: all | critical | operational | system.
///
/// Copied from [NotificationCategoryFilter].
@ProviderFor(NotificationCategoryFilter)
final notificationCategoryFilterProvider =
    AutoDisposeNotifierProvider<NotificationCategoryFilter, String>.internal(
  NotificationCategoryFilter.new,
  name: r'notificationCategoryFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationCategoryFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationCategoryFilter = AutoDisposeNotifier<String>;
String _$notificationOldestFirstHash() =>
    r'e0dfe67afcb87ffc4447e4ec0ca3305b2b131937';

/// Oldest-first toggle.
///
/// Copied from [NotificationOldestFirst].
@ProviderFor(NotificationOldestFirst)
final notificationOldestFirstProvider =
    AutoDisposeNotifierProvider<NotificationOldestFirst, bool>.internal(
  NotificationOldestFirst.new,
  name: r'notificationOldestFirstProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationOldestFirstHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationOldestFirst = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
