// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_jobs_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$driverAllJobsHash() => r'c1e4b43b9c1d7fa057d29466be97b98b9923c420';

/// The signed-in driver's jobs. Day-split is done client-side so the query
/// stays on a single-field index (no composite index needed).
///
/// Copied from [driverAllJobs].
@ProviderFor(driverAllJobs)
final driverAllJobsProvider = AutoDisposeStreamProvider<List<Job>>.internal(
  driverAllJobs,
  name: r'driverAllJobsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$driverAllJobsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DriverAllJobsRef = AutoDisposeStreamProviderRef<List<Job>>;
String _$driverTodayJobsHash() => r'916c278624de9cae78d0eb09d028e6d94430a1a9';

/// See also [driverTodayJobs].
@ProviderFor(driverTodayJobs)
final driverTodayJobsProvider = AutoDisposeProvider<List<Job>>.internal(
  driverTodayJobs,
  name: r'driverTodayJobsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$driverTodayJobsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DriverTodayJobsRef = AutoDisposeProviderRef<List<Job>>;
String _$driverUpcomingJobsHash() =>
    r'c7a3513bb883e4535bf7d8e6f47c2e03575404ad';

/// See also [driverUpcomingJobs].
@ProviderFor(driverUpcomingJobs)
final driverUpcomingJobsProvider = AutoDisposeProvider<List<Job>>.internal(
  driverUpcomingJobs,
  name: r'driverUpcomingJobsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$driverUpcomingJobsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DriverUpcomingJobsRef = AutoDisposeProviderRef<List<Job>>;
String _$driverJobHash() => r'f2106432a529060231ee3012104b05523e218ead';

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

/// One job, live.
///
/// Copied from [driverJob].
@ProviderFor(driverJob)
const driverJobProvider = DriverJobFamily();

/// One job, live.
///
/// Copied from [driverJob].
class DriverJobFamily extends Family<AsyncValue<Job?>> {
  /// One job, live.
  ///
  /// Copied from [driverJob].
  const DriverJobFamily();

  /// One job, live.
  ///
  /// Copied from [driverJob].
  DriverJobProvider call(
    String jobId,
  ) {
    return DriverJobProvider(
      jobId,
    );
  }

  @override
  DriverJobProvider getProviderOverride(
    covariant DriverJobProvider provider,
  ) {
    return call(
      provider.jobId,
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
  String? get name => r'driverJobProvider';
}

/// One job, live.
///
/// Copied from [driverJob].
class DriverJobProvider extends AutoDisposeStreamProvider<Job?> {
  /// One job, live.
  ///
  /// Copied from [driverJob].
  DriverJobProvider(
    String jobId,
  ) : this._internal(
          (ref) => driverJob(
            ref as DriverJobRef,
            jobId,
          ),
          from: driverJobProvider,
          name: r'driverJobProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$driverJobHash,
          dependencies: DriverJobFamily._dependencies,
          allTransitiveDependencies: DriverJobFamily._allTransitiveDependencies,
          jobId: jobId,
        );

  DriverJobProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.jobId,
  }) : super.internal();

  final String jobId;

  @override
  Override overrideWith(
    Stream<Job?> Function(DriverJobRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DriverJobProvider._internal(
        (ref) => create(ref as DriverJobRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        jobId: jobId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Job?> createElement() {
    return _DriverJobProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DriverJobProvider && other.jobId == jobId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, jobId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DriverJobRef on AutoDisposeStreamProviderRef<Job?> {
  /// The parameter `jobId` of this provider.
  String get jobId;
}

class _DriverJobProviderElement extends AutoDisposeStreamProviderElement<Job?>
    with DriverJobRef {
  _DriverJobProviderElement(super.provider);

  @override
  String get jobId => (origin as DriverJobProvider).jobId;
}

String _$jobManifestHash() => r'5e67cf7c2d6087b82b9c7c13315dea47ab65810d';

/// The units on a job's manifest.
///
/// Copied from [jobManifest].
@ProviderFor(jobManifest)
const jobManifestProvider = JobManifestFamily();

/// The units on a job's manifest.
///
/// Copied from [jobManifest].
class JobManifestFamily extends Family<AsyncValue<List<StorageUnit>>> {
  /// The units on a job's manifest.
  ///
  /// Copied from [jobManifest].
  const JobManifestFamily();

  /// The units on a job's manifest.
  ///
  /// Copied from [jobManifest].
  JobManifestProvider call(
    String jobId,
  ) {
    return JobManifestProvider(
      jobId,
    );
  }

  @override
  JobManifestProvider getProviderOverride(
    covariant JobManifestProvider provider,
  ) {
    return call(
      provider.jobId,
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
  String? get name => r'jobManifestProvider';
}

/// The units on a job's manifest.
///
/// Copied from [jobManifest].
class JobManifestProvider extends AutoDisposeFutureProvider<List<StorageUnit>> {
  /// The units on a job's manifest.
  ///
  /// Copied from [jobManifest].
  JobManifestProvider(
    String jobId,
  ) : this._internal(
          (ref) => jobManifest(
            ref as JobManifestRef,
            jobId,
          ),
          from: jobManifestProvider,
          name: r'jobManifestProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$jobManifestHash,
          dependencies: JobManifestFamily._dependencies,
          allTransitiveDependencies:
              JobManifestFamily._allTransitiveDependencies,
          jobId: jobId,
        );

  JobManifestProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.jobId,
  }) : super.internal();

  final String jobId;

  @override
  Override overrideWith(
    FutureOr<List<StorageUnit>> Function(JobManifestRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: JobManifestProvider._internal(
        (ref) => create(ref as JobManifestRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        jobId: jobId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<StorageUnit>> createElement() {
    return _JobManifestProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is JobManifestProvider && other.jobId == jobId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, jobId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin JobManifestRef on AutoDisposeFutureProviderRef<List<StorageUnit>> {
  /// The parameter `jobId` of this provider.
  String get jobId;
}

class _JobManifestProviderElement
    extends AutoDisposeFutureProviderElement<List<StorageUnit>>
    with JobManifestRef {
  _JobManifestProviderElement(super.provider);

  @override
  String get jobId => (origin as JobManifestProvider).jobId;
}

String _$unitByScanHash() => r'b0a50981d081691f01046e4d5528761dc3be5af9';

/// Look up a unit by scanned QR value.
///
/// Copied from [unitByScan].
@ProviderFor(unitByScan)
const unitByScanProvider = UnitByScanFamily();

/// Look up a unit by scanned QR value.
///
/// Copied from [unitByScan].
class UnitByScanFamily extends Family<AsyncValue<StorageUnit?>> {
  /// Look up a unit by scanned QR value.
  ///
  /// Copied from [unitByScan].
  const UnitByScanFamily();

  /// Look up a unit by scanned QR value.
  ///
  /// Copied from [unitByScan].
  UnitByScanProvider call(
    String code,
  ) {
    return UnitByScanProvider(
      code,
    );
  }

  @override
  UnitByScanProvider getProviderOverride(
    covariant UnitByScanProvider provider,
  ) {
    return call(
      provider.code,
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
  String? get name => r'unitByScanProvider';
}

/// Look up a unit by scanned QR value.
///
/// Copied from [unitByScan].
class UnitByScanProvider extends AutoDisposeFutureProvider<StorageUnit?> {
  /// Look up a unit by scanned QR value.
  ///
  /// Copied from [unitByScan].
  UnitByScanProvider(
    String code,
  ) : this._internal(
          (ref) => unitByScan(
            ref as UnitByScanRef,
            code,
          ),
          from: unitByScanProvider,
          name: r'unitByScanProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$unitByScanHash,
          dependencies: UnitByScanFamily._dependencies,
          allTransitiveDependencies:
              UnitByScanFamily._allTransitiveDependencies,
          code: code,
        );

  UnitByScanProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.code,
  }) : super.internal();

  final String code;

  @override
  Override overrideWith(
    FutureOr<StorageUnit?> Function(UnitByScanRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UnitByScanProvider._internal(
        (ref) => create(ref as UnitByScanRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        code: code,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<StorageUnit?> createElement() {
    return _UnitByScanProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnitByScanProvider && other.code == code;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, code.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UnitByScanRef on AutoDisposeFutureProviderRef<StorageUnit?> {
  /// The parameter `code` of this provider.
  String get code;
}

class _UnitByScanProviderElement
    extends AutoDisposeFutureProviderElement<StorageUnit?> with UnitByScanRef {
  _UnitByScanProviderElement(super.provider);

  @override
  String get code => (origin as UnitByScanProvider).code;
}

String _$driverBoxesHandledTodayHash() =>
    r'1be46beac18d51d5da5139b47e048e398c00dedc';

/// Units the driver has scanned today across today's jobs.
///
/// Copied from [driverBoxesHandledToday].
@ProviderFor(driverBoxesHandledToday)
final driverBoxesHandledTodayProvider = AutoDisposeProvider<int>.internal(
  driverBoxesHandledToday,
  name: r'driverBoxesHandledTodayProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$driverBoxesHandledTodayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DriverBoxesHandledTodayRef = AutoDisposeProviderRef<int>;
String _$driverJobsCompletedTodayHash() =>
    r'28328238f23c883fcd3a592e86d0e5a9efd7326c';

/// Jobs the driver completed today.
///
/// Copied from [driverJobsCompletedToday].
@ProviderFor(driverJobsCompletedToday)
final driverJobsCompletedTodayProvider = AutoDisposeProvider<int>.internal(
  driverJobsCompletedToday,
  name: r'driverJobsCompletedTodayProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$driverJobsCompletedTodayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DriverJobsCompletedTodayRef = AutoDisposeProviderRef<int>;
String _$driverJobActionsHash() => r'd7fff7c870d63d4d066225230080e8b13d327f92';

/// Driver-side writes: start job, confirm unit, capture photo, sign off.
///
/// Copied from [DriverJobActions].
@ProviderFor(DriverJobActions)
final driverJobActionsProvider =
    AutoDisposeAsyncNotifierProvider<DriverJobActions, void>.internal(
  DriverJobActions.new,
  name: r'driverJobActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$driverJobActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DriverJobActions = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
