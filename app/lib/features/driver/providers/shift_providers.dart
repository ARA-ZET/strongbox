import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/async_value_ext.dart';
import '../../../core/models/driver_shift.dart';
import '../../../core/providers/tenant_provider.dart';
import '../../../repositories/repository_providers.dart';
import '../../auth/providers/auth_provider.dart';

part 'shift_providers.g.dart';

/// The signed-in driver's currently open shift, if any.
@riverpod
Stream<DriverShift?> activeShift(Ref ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(null);
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref.watch(shiftRepositoryProvider).watchActiveShift(tenantId, uid);
}

/// Start / break / resume / end actions on the driver's shift.
@riverpod
class ShiftActions extends _$ShiftActions {
  @override
  FutureOr<void> build() {}

  Future<void> startShift() async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    final tenantId = ref.read(currentTenantIdProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(shiftRepositoryProvider).startShift(uid, tenantId));
    state.throwIfError();
  }

  Future<void> setBreak(String shiftId, {required bool onBreak}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(shiftRepositoryProvider).setBreak(shiftId, onBreak: onBreak));
    state.throwIfError();
  }

  Future<void> endShift(String shiftId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(shiftRepositoryProvider).endShift(shiftId));
    state.throwIfError();
  }
}
