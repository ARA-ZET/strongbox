// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_link_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scanLinkTargetHash() => r'f00d7904058ef6d6d9d105efda61108e2065f0ac';

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

/// Admins go to the unit; clients to the unit only when it's theirs;
/// drivers to the active job carrying it, only when the job is theirs.
///
/// Copied from [scanLinkTarget].
@ProviderFor(scanLinkTarget)
const scanLinkTargetProvider = ScanLinkTargetFamily();

/// Admins go to the unit; clients to the unit only when it's theirs;
/// drivers to the active job carrying it, only when the job is theirs.
///
/// Copied from [scanLinkTarget].
class ScanLinkTargetFamily extends Family<AsyncValue<ScanLinkTarget>> {
  /// Admins go to the unit; clients to the unit only when it's theirs;
  /// drivers to the active job carrying it, only when the job is theirs.
  ///
  /// Copied from [scanLinkTarget].
  const ScanLinkTargetFamily();

  /// Admins go to the unit; clients to the unit only when it's theirs;
  /// drivers to the active job carrying it, only when the job is theirs.
  ///
  /// Copied from [scanLinkTarget].
  ScanLinkTargetProvider call(
    String code,
  ) {
    return ScanLinkTargetProvider(
      code,
    );
  }

  @override
  ScanLinkTargetProvider getProviderOverride(
    covariant ScanLinkTargetProvider provider,
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
  String? get name => r'scanLinkTargetProvider';
}

/// Admins go to the unit; clients to the unit only when it's theirs;
/// drivers to the active job carrying it, only when the job is theirs.
///
/// Copied from [scanLinkTarget].
class ScanLinkTargetProvider extends AutoDisposeFutureProvider<ScanLinkTarget> {
  /// Admins go to the unit; clients to the unit only when it's theirs;
  /// drivers to the active job carrying it, only when the job is theirs.
  ///
  /// Copied from [scanLinkTarget].
  ScanLinkTargetProvider(
    String code,
  ) : this._internal(
          (ref) => scanLinkTarget(
            ref as ScanLinkTargetRef,
            code,
          ),
          from: scanLinkTargetProvider,
          name: r'scanLinkTargetProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$scanLinkTargetHash,
          dependencies: ScanLinkTargetFamily._dependencies,
          allTransitiveDependencies:
              ScanLinkTargetFamily._allTransitiveDependencies,
          code: code,
        );

  ScanLinkTargetProvider._internal(
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
    FutureOr<ScanLinkTarget> Function(ScanLinkTargetRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ScanLinkTargetProvider._internal(
        (ref) => create(ref as ScanLinkTargetRef),
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
  AutoDisposeFutureProviderElement<ScanLinkTarget> createElement() {
    return _ScanLinkTargetProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ScanLinkTargetProvider && other.code == code;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, code.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ScanLinkTargetRef on AutoDisposeFutureProviderRef<ScanLinkTarget> {
  /// The parameter `code` of this provider.
  String get code;
}

class _ScanLinkTargetProviderElement
    extends AutoDisposeFutureProviderElement<ScanLinkTarget>
    with ScanLinkTargetRef {
  _ScanLinkTargetProviderElement(super.provider);

  @override
  String get code => (origin as ScanLinkTargetProvider).code;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
