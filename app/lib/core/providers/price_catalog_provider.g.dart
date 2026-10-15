// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_catalog_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$livePriceCatalogHash() => r'c43e49d2ee5f08fec55cbb15579ee1282c6eeaa4';

/// The admin-saved price list, live; null until an admin first saves.
///
/// Copied from [livePriceCatalog].
@ProviderFor(livePriceCatalog)
final livePriceCatalogProvider = StreamProvider<PriceCatalog?>.internal(
  livePriceCatalog,
  name: r'livePriceCatalogProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$livePriceCatalogHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LivePriceCatalogRef = StreamProviderRef<PriceCatalog?>;
String _$priceCatalogHash() => r'475c9c5ca8e7703e2ede8c836b1545f6b6f40690';

/// The price list every screen reads — the same one the website shows.
/// Falls back to the packaged defaults while loading, before the first
/// admin save, or if the document can't be read.
///
/// The icon set always comes from the defaults: the website bundles only
/// those glyphs, so it is fixed at build time rather than admin-editable.
///
/// Copied from [priceCatalog].
@ProviderFor(priceCatalog)
final priceCatalogProvider = Provider<PriceCatalog>.internal(
  priceCatalog,
  name: r'priceCatalogProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$priceCatalogHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PriceCatalogRef = ProviderRef<PriceCatalog>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
