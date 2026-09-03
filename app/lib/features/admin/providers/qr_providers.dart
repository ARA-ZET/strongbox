import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/qr_code.dart';
import '../../../core/providers/tenant_provider.dart';
import '../../../core/utils/qr_generator.dart';
import '../../../repositories/repository_providers.dart';
import '../../auth/providers/auth_provider.dart';

part 'qr_providers.g.dart';

/// All generated batches, newest first.
@riverpod
Stream<List<QRBatch>> qrBatches(Ref ref) {
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref.watch(qrRepositoryProvider).watchBatches(tenantId);
}

/// Codes shown in the batch preview grid (illustrative — the persisted
/// batch is generated server-side on commit).
@riverpod
class BatchPreview extends _$BatchPreview {
  @override
  List<String> build() => generateBoxQrBatch(12);

  void setCount(int count) => state = generateBoxQrBatch(count);
  void regenerate() => state = generateBoxQrBatch(state.length);
}

/// Result of a Link-QR lookup.
enum QrLookupStatus { alreadyLinked, available, unknown }

/// Firestore writes for the QR module.
@riverpod
class QrMutations extends _$QrMutations {
  @override
  FutureOr<void> build() {}

  /// Persists a printed batch and returns its codes.
  Future<List<String>> createBatch(int count, String resolution) async {
    final tenantId = ref.read(currentTenantIdProvider);
    final actorId = ref.read(currentActorIdProvider);
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => ref
        .read(qrRepositoryProvider)
        .generateBatch(
          tenantId: tenantId,
          count: count,
          resolution: resolution,
          createdBy: actorId,
        ));
    state = result;
    return result.requireValue.codeIds;
  }

  /// Checks whether [code] is linkable.
  Future<QrLookupStatus> lookupCode(String code) async {
    final qr = await ref.read(qrRepositoryProvider).resolveCode(code);
    if (qr == null) return QrLookupStatus.unknown;
    return qr.isLinked
        ? QrLookupStatus.alreadyLinked
        : QrLookupStatus.available;
  }

  /// Links a pre-printed code to a unit (existing or freshly created).
  Future<void> linkToUnit(String code, String unitId) async {
    final tenantId = ref.read(currentTenantIdProvider);
    final actorId = ref.read(currentActorIdProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(qrRepositoryProvider)
        .linkToUnit(code, unitId, tenantId: tenantId, actorId: actorId));
  }
}
