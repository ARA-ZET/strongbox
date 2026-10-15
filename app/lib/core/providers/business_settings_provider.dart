import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../repositories/repository_providers.dart';
import '../models/business_settings.dart';
import 'tenant_provider.dart';

export '../models/business_settings.dart';

part 'business_settings_provider.g.dart';

/// The admin-saved business settings, live; null until an admin first saves.
@Riverpod(keepAlive: true)
Stream<BusinessSettings?> liveBusinessSettings(Ref ref) {
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref.watch(tenantRepositoryProvider).watchSettings(tenantId);
}

/// Business details and operations defaults every screen reads — contact
/// details, time-window hours, service area. Falls back to
/// [BusinessSettings.defaults] while loading, before the first admin save,
/// or if the document can't be read.
@Riverpod(keepAlive: true)
BusinessSettings businessSettings(Ref ref) =>
    ref.watch(liveBusinessSettingsProvider).valueOrNull ??
    BusinessSettings.defaults;
