// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentTenantIdHash() => r'3edced73c340458c3499e8b8b1a07e68f17cc64b';

/// The active tenant id. v1 is single-tenant, so this is a constant; when
/// multi-tenancy lands it will read from the signed-in user's doc.
///
/// Every repository query scopes to this id (rule #5).
///
/// Copied from [currentTenantId].
@ProviderFor(currentTenantId)
final currentTenantIdProvider = Provider<String>.internal(
  currentTenantId,
  name: r'currentTenantIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentTenantIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentTenantIdRef = ProviderRef<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
