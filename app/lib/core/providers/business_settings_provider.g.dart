// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$liveBusinessSettingsHash() =>
    r'364106160c23c372fdab1965d1a923c7f151c8a2';

/// The admin-saved business settings, live; null until an admin first saves.
///
/// Copied from [liveBusinessSettings].
@ProviderFor(liveBusinessSettings)
final liveBusinessSettingsProvider = StreamProvider<BusinessSettings?>.internal(
  liveBusinessSettings,
  name: r'liveBusinessSettingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$liveBusinessSettingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LiveBusinessSettingsRef = StreamProviderRef<BusinessSettings?>;
String _$businessSettingsHash() => r'4a328b8b1fb9556a8ffa51b93ee1f6e8dacb8ead';

/// Business details and operations defaults every screen reads — contact
/// details, time-window hours, service area. Falls back to
/// [BusinessSettings.defaults] while loading, before the first admin save,
/// or if the document can't be read.
///
/// Copied from [businessSettings].
@ProviderFor(businessSettings)
final businessSettingsProvider = Provider<BusinessSettings>.internal(
  businessSettings,
  name: r'businessSettingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessSettingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BusinessSettingsRef = ProviderRef<BusinessSettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
