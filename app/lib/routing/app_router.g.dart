// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appRouterHash() => r'2620214502a502c9342eb93bdcbbcec6a4188675';

/// App router. Redirect rules:
/// - Signed-out visitors land on /login, which links out to the website
///   for anyone exploring. /quote and /prices stay open to everyone for
///   links that point at them. Signed-in clients build and book inside
///   their portal instead (/client/order, /client/order/book).
/// - A quote in the URL (the website's `?boxes=…&loose=…&vehicle=…`) is
///   loaded into the quote on any route; on /register or /login it also
///   opens booking once they're signed in.
/// - /book needs a client account — signed-out visitors sign up first;
///   clients are sent on to /client/order/book.
/// - Other routes need sign-in → /login; signed-in users go to their role
///   home (/admin/dashboard, /driver/jobs, /client/dashboard), or booking
///   when it was started before signing in. Portals are role-guarded.
/// - A label link (/s/:code, from a phone's own camera) is open to every
///   signed-in role; anyone else signs in first and lands on it after.
/// - Role means [currentUserProvider]'s, so an admin using "View as" is
///   routed exactly like the account they're viewing.
///
/// Copied from [appRouter].
@ProviderFor(appRouter)
final appRouterProvider = Provider<GoRouter>.internal(
  appRouter,
  name: r'appRouterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appRouterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AppRouterRef = ProviderRef<GoRouter>;
String _$pendingLabelLinkHash() => r'33aad1046984ff699204891a742ec6b260e925eb';

/// A label link (/s/:code) opened before sign-in finished, to open after.
///
/// Copied from [PendingLabelLink].
@ProviderFor(PendingLabelLink)
final pendingLabelLinkProvider =
    NotifierProvider<PendingLabelLink, String?>.internal(
  PendingLabelLink.new,
  name: r'pendingLabelLinkProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingLabelLinkHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PendingLabelLink = Notifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
