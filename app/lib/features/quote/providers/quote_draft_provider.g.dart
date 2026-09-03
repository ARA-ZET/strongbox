// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_draft_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'ad13470fe866595ad0f58a3e26f11048d94ef22e';

/// See also [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = FutureProvider<SharedPreferences>.internal(
  sharedPreferences,
  name: r'sharedPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SharedPreferencesRef = FutureProviderRef<SharedPreferences>;
String _$quoteDraftHash() => r'f52cb236a8886e90922f044cf0226df87d2cb81d';

/// The quote the visitor is building right now.
///
/// keepAlive because the draft has to outlive every screen in the flow —
/// including the trip out to `/register` and back — and is mirrored to
/// local storage so a hard refresh does not lose it either.
///
/// Copied from [QuoteDraft].
@ProviderFor(QuoteDraft)
final quoteDraftProvider = NotifierProvider<QuoteDraft, Quote>.internal(
  QuoteDraft.new,
  name: r'quoteDraftProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$quoteDraftHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$QuoteDraft = Notifier<Quote>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
