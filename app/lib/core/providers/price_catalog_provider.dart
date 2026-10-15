import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../repositories/repository_providers.dart';
import '../constants/pricing.dart';
import 'tenant_provider.dart';

part 'price_catalog_provider.g.dart';

/// The admin-saved price list, live; null until an admin first saves.
@Riverpod(keepAlive: true)
Stream<PriceCatalog?> livePriceCatalog(Ref ref) {
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref.watch(priceListRepositoryProvider).watch(tenantId);
}

/// The price list every screen reads — the same one the website shows.
/// Falls back to the packaged defaults while loading, before the first
/// admin save, or if the document can't be read.
///
/// The icon set always comes from the defaults: the website bundles only
/// those glyphs, so it is fixed at build time rather than admin-editable.
@Riverpod(keepAlive: true)
PriceCatalog priceCatalog(Ref ref) {
  final live = ref.watch(livePriceCatalogProvider).valueOrNull;
  if (live == null) return PriceList.catalog;
  return live.copyWith(itemIcons: PriceList.catalog.itemIcons);
}
