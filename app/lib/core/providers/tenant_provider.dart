import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/app_constants.dart';

part 'tenant_provider.g.dart';

/// The active tenant id. v1 is single-tenant, so this is a constant; when
/// multi-tenancy lands it will read from the signed-in user's doc.
///
/// Every repository query scopes to this id (rule #5).
@Riverpod(keepAlive: true)
String currentTenantId(Ref ref) => AppConstants.defaultTenantId;
