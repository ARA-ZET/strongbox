// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appRouterHash() => r'306b32a716850b27177b6554dcd6a0658e05d738';

/// App router. The app is for account holders — marketing, pricing and
/// quotes live on the website (web/). Redirect rules:
/// - Unauthenticated → /login (or /register, which the site links to)
/// - Authenticated → role home (/admin/dashboard, /driver/jobs,
///   /client/dashboard); each portal is guarded by role.
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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
