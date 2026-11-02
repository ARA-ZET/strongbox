// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricing_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$savedPriceIdsHash() => r'693984ce85324034380b180d49f6da885309a58e';

/// Ids already in the live list — used to keep a new entry's id unique.
///
/// Copied from [savedPriceIds].
@ProviderFor(savedPriceIds)
final savedPriceIdsProvider = AutoDisposeProvider<Set<String>>.internal(
  savedPriceIds,
  name: r'savedPriceIdsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$savedPriceIdsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SavedPriceIdsRef = AutoDisposeProviderRef<Set<String>>;
String _$pricingEditorHash() => r'4c823e9dbf42d958f2073ed99b942d0c783501b5';

/// Edits to the shared price list. Each call saves straight to Firestore —
/// there is no draft to lose — so the app updates at once and the website
/// within about five minutes. The change is applied to the latest stored
/// list inside a transaction, then validated; a problem throws
/// [StateError] with the reason and nothing is written.
///
/// Copied from [PricingEditor].
@ProviderFor(PricingEditor)
final pricingEditorProvider = NotifierProvider<PricingEditor, void>.internal(
  PricingEditor.new,
  name: r'pricingEditorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pricingEditorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PricingEditor = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
