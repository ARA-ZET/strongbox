// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeShiftHash() => r'3055b768f8939355ba9b287d89683c83c04f96b6';

/// The current driver's open shift, if any.
///
/// Copied from [activeShift].
@ProviderFor(activeShift)
final activeShiftProvider = AutoDisposeStreamProvider<DriverShift?>.internal(
  activeShift,
  name: r'activeShiftProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$activeShiftHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ActiveShiftRef = AutoDisposeStreamProviderRef<DriverShift?>;
String _$shiftActionsHash() => r'7a8d771d5b310b8124bbdbee26d7fc4cbb208f75';

/// Start / break / resume / end actions on the driver's shift.
///
/// Copied from [ShiftActions].
@ProviderFor(ShiftActions)
final shiftActionsProvider = AsyncNotifierProvider<ShiftActions, void>.internal(
  ShiftActions.new,
  name: r'shiftActionsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$shiftActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShiftActions = AsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
