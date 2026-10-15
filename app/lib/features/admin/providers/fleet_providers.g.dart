// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fleet_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$driverByIdHash() => r'adc5360fa748655ae9b0fc89fd203d1d3444e412';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// One driver's user doc, live.
///
/// Copied from [driverById].
@ProviderFor(driverById)
const driverByIdProvider = DriverByIdFamily();

/// One driver's user doc, live.
///
/// Copied from [driverById].
class DriverByIdFamily extends Family<AsyncValue<AppUser?>> {
  /// One driver's user doc, live.
  ///
  /// Copied from [driverById].
  const DriverByIdFamily();

  /// One driver's user doc, live.
  ///
  /// Copied from [driverById].
  DriverByIdProvider call(
    String driverId,
  ) {
    return DriverByIdProvider(
      driverId,
    );
  }

  @override
  DriverByIdProvider getProviderOverride(
    covariant DriverByIdProvider provider,
  ) {
    return call(
      provider.driverId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'driverByIdProvider';
}

/// One driver's user doc, live.
///
/// Copied from [driverById].
class DriverByIdProvider extends AutoDisposeStreamProvider<AppUser?> {
  /// One driver's user doc, live.
  ///
  /// Copied from [driverById].
  DriverByIdProvider(
    String driverId,
  ) : this._internal(
          (ref) => driverById(
            ref as DriverByIdRef,
            driverId,
          ),
          from: driverByIdProvider,
          name: r'driverByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$driverByIdHash,
          dependencies: DriverByIdFamily._dependencies,
          allTransitiveDependencies:
              DriverByIdFamily._allTransitiveDependencies,
          driverId: driverId,
        );

  DriverByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.driverId,
  }) : super.internal();

  final String driverId;

  @override
  Override overrideWith(
    Stream<AppUser?> Function(DriverByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DriverByIdProvider._internal(
        (ref) => create(ref as DriverByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        driverId: driverId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<AppUser?> createElement() {
    return _DriverByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DriverByIdProvider && other.driverId == driverId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, driverId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DriverByIdRef on AutoDisposeStreamProviderRef<AppUser?> {
  /// The parameter `driverId` of this provider.
  String get driverId;
}

class _DriverByIdProviderElement
    extends AutoDisposeStreamProviderElement<AppUser?> with DriverByIdRef {
  _DriverByIdProviderElement(super.provider);

  @override
  String get driverId => (origin as DriverByIdProvider).driverId;
}

String _$activeJobsByDriverHash() =>
    r'db7b77d0f3883044b6c03126117d05ddb28414b3';

/// driverId → their current in-flight job (assigned or inProgress).
///
/// Copied from [activeJobsByDriver].
@ProviderFor(activeJobsByDriver)
final activeJobsByDriverProvider =
    AutoDisposeProvider<Map<String, Job>>.internal(
  activeJobsByDriver,
  name: r'activeJobsByDriverProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeJobsByDriverHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ActiveJobsByDriverRef = AutoDisposeProviderRef<Map<String, Job>>;
String _$driverRecentJobsHash() => r'53e488884eb414f2cd8e31088469ff956ef40734';

/// A driver's most recent jobs for the detail history table.
///
/// Copied from [driverRecentJobs].
@ProviderFor(driverRecentJobs)
const driverRecentJobsProvider = DriverRecentJobsFamily();

/// A driver's most recent jobs for the detail history table.
///
/// Copied from [driverRecentJobs].
class DriverRecentJobsFamily extends Family<List<Job>> {
  /// A driver's most recent jobs for the detail history table.
  ///
  /// Copied from [driverRecentJobs].
  const DriverRecentJobsFamily();

  /// A driver's most recent jobs for the detail history table.
  ///
  /// Copied from [driverRecentJobs].
  DriverRecentJobsProvider call(
    String driverId,
  ) {
    return DriverRecentJobsProvider(
      driverId,
    );
  }

  @override
  DriverRecentJobsProvider getProviderOverride(
    covariant DriverRecentJobsProvider provider,
  ) {
    return call(
      provider.driverId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'driverRecentJobsProvider';
}

/// A driver's most recent jobs for the detail history table.
///
/// Copied from [driverRecentJobs].
class DriverRecentJobsProvider extends AutoDisposeProvider<List<Job>> {
  /// A driver's most recent jobs for the detail history table.
  ///
  /// Copied from [driverRecentJobs].
  DriverRecentJobsProvider(
    String driverId,
  ) : this._internal(
          (ref) => driverRecentJobs(
            ref as DriverRecentJobsRef,
            driverId,
          ),
          from: driverRecentJobsProvider,
          name: r'driverRecentJobsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$driverRecentJobsHash,
          dependencies: DriverRecentJobsFamily._dependencies,
          allTransitiveDependencies:
              DriverRecentJobsFamily._allTransitiveDependencies,
          driverId: driverId,
        );

  DriverRecentJobsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.driverId,
  }) : super.internal();

  final String driverId;

  @override
  Override overrideWith(
    List<Job> Function(DriverRecentJobsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DriverRecentJobsProvider._internal(
        (ref) => create(ref as DriverRecentJobsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        driverId: driverId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<Job>> createElement() {
    return _DriverRecentJobsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DriverRecentJobsProvider && other.driverId == driverId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, driverId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DriverRecentJobsRef on AutoDisposeProviderRef<List<Job>> {
  /// The parameter `driverId` of this provider.
  String get driverId;
}

class _DriverRecentJobsProviderElement
    extends AutoDisposeProviderElement<List<Job>> with DriverRecentJobsRef {
  _DriverRecentJobsProviderElement(super.provider);

  @override
  String get driverId => (origin as DriverRecentJobsProvider).driverId;
}

String _$driverCompletedCountHash() =>
    r'3b78b7df843b8c94c02e7406ca65ee5a0b401bc4';

/// Count of jobs this driver has completed.
///
/// Copied from [driverCompletedCount].
@ProviderFor(driverCompletedCount)
const driverCompletedCountProvider = DriverCompletedCountFamily();

/// Count of jobs this driver has completed.
///
/// Copied from [driverCompletedCount].
class DriverCompletedCountFamily extends Family<int> {
  /// Count of jobs this driver has completed.
  ///
  /// Copied from [driverCompletedCount].
  const DriverCompletedCountFamily();

  /// Count of jobs this driver has completed.
  ///
  /// Copied from [driverCompletedCount].
  DriverCompletedCountProvider call(
    String driverId,
  ) {
    return DriverCompletedCountProvider(
      driverId,
    );
  }

  @override
  DriverCompletedCountProvider getProviderOverride(
    covariant DriverCompletedCountProvider provider,
  ) {
    return call(
      provider.driverId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'driverCompletedCountProvider';
}

/// Count of jobs this driver has completed.
///
/// Copied from [driverCompletedCount].
class DriverCompletedCountProvider extends AutoDisposeProvider<int> {
  /// Count of jobs this driver has completed.
  ///
  /// Copied from [driverCompletedCount].
  DriverCompletedCountProvider(
    String driverId,
  ) : this._internal(
          (ref) => driverCompletedCount(
            ref as DriverCompletedCountRef,
            driverId,
          ),
          from: driverCompletedCountProvider,
          name: r'driverCompletedCountProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$driverCompletedCountHash,
          dependencies: DriverCompletedCountFamily._dependencies,
          allTransitiveDependencies:
              DriverCompletedCountFamily._allTransitiveDependencies,
          driverId: driverId,
        );

  DriverCompletedCountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.driverId,
  }) : super.internal();

  final String driverId;

  @override
  Override overrideWith(
    int Function(DriverCompletedCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DriverCompletedCountProvider._internal(
        (ref) => create(ref as DriverCompletedCountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        driverId: driverId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<int> createElement() {
    return _DriverCompletedCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DriverCompletedCountProvider && other.driverId == driverId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, driverId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DriverCompletedCountRef on AutoDisposeProviderRef<int> {
  /// The parameter `driverId` of this provider.
  String get driverId;
}

class _DriverCompletedCountProviderElement
    extends AutoDisposeProviderElement<int> with DriverCompletedCountRef {
  _DriverCompletedCountProviderElement(super.provider);

  @override
  String get driverId => (origin as DriverCompletedCountProvider).driverId;
}

String _$inviteEmailStatusHash() => r'd31c534fb0159ec9136ce79776de129261301eaf';

/// Delivery status of an invite email (`mail/{mailId}`).
///
/// Copied from [inviteEmailStatus].
@ProviderFor(inviteEmailStatus)
const inviteEmailStatusProvider = InviteEmailStatusFamily();

/// Delivery status of an invite email (`mail/{mailId}`).
///
/// Copied from [inviteEmailStatus].
class InviteEmailStatusFamily extends Family<AsyncValue<EmailStatus>> {
  /// Delivery status of an invite email (`mail/{mailId}`).
  ///
  /// Copied from [inviteEmailStatus].
  const InviteEmailStatusFamily();

  /// Delivery status of an invite email (`mail/{mailId}`).
  ///
  /// Copied from [inviteEmailStatus].
  InviteEmailStatusProvider call(
    String mailId,
  ) {
    return InviteEmailStatusProvider(
      mailId,
    );
  }

  @override
  InviteEmailStatusProvider getProviderOverride(
    covariant InviteEmailStatusProvider provider,
  ) {
    return call(
      provider.mailId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'inviteEmailStatusProvider';
}

/// Delivery status of an invite email (`mail/{mailId}`).
///
/// Copied from [inviteEmailStatus].
class InviteEmailStatusProvider extends AutoDisposeStreamProvider<EmailStatus> {
  /// Delivery status of an invite email (`mail/{mailId}`).
  ///
  /// Copied from [inviteEmailStatus].
  InviteEmailStatusProvider(
    String mailId,
  ) : this._internal(
          (ref) => inviteEmailStatus(
            ref as InviteEmailStatusRef,
            mailId,
          ),
          from: inviteEmailStatusProvider,
          name: r'inviteEmailStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$inviteEmailStatusHash,
          dependencies: InviteEmailStatusFamily._dependencies,
          allTransitiveDependencies:
              InviteEmailStatusFamily._allTransitiveDependencies,
          mailId: mailId,
        );

  InviteEmailStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mailId,
  }) : super.internal();

  final String mailId;

  @override
  Override overrideWith(
    Stream<EmailStatus> Function(InviteEmailStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InviteEmailStatusProvider._internal(
        (ref) => create(ref as InviteEmailStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mailId: mailId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<EmailStatus> createElement() {
    return _InviteEmailStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InviteEmailStatusProvider && other.mailId == mailId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mailId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin InviteEmailStatusRef on AutoDisposeStreamProviderRef<EmailStatus> {
  /// The parameter `mailId` of this provider.
  String get mailId;
}

class _InviteEmailStatusProviderElement
    extends AutoDisposeStreamProviderElement<EmailStatus>
    with InviteEmailStatusRef {
  _InviteEmailStatusProviderElement(super.provider);

  @override
  String get mailId => (origin as InviteEmailStatusProvider).mailId;
}

String _$driverMutationsHash() => r'8a7f4b5f56da8d970d3d70d8cf6fc4b03ffec945';

/// Create/update actions on driver records.
///
/// Copied from [DriverMutations].
@ProviderFor(DriverMutations)
final driverMutationsProvider =
    AutoDisposeAsyncNotifierProvider<DriverMutations, void>.internal(
  DriverMutations.new,
  name: r'driverMutationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$driverMutationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DriverMutations = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
