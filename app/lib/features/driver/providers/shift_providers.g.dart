// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeShiftHash() => r'4551290fdfaef8de5677133fa5073dae110548ac';

/// The signed-in driver's currently open shift, if any.
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
String _$shiftActionsHash() => r'e4e65eb4e45a636e4df5813fbb9a9e207bb6135a';

/// Start / break / resume / end actions on the driver's shift.
///
/// Copied from [ShiftActions].
@ProviderFor(ShiftActions)
final shiftActionsProvider =
    AutoDisposeAsyncNotifierProvider<ShiftActions, void>.internal(
  ShiftActions.new,
  name: r'shiftActionsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$shiftActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShiftActions = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
