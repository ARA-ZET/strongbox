// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allUnitsHash() => r'e7c25354396844ec469b8408be0fc707c02e12f8';

/// All non-deleted units for the tenant, newest first.
///
/// Copied from [allUnits].
@ProviderFor(allUnits)
final allUnitsProvider = AutoDisposeStreamProvider<List<StorageUnit>>.internal(
  allUnits,
  name: r'allUnitsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allUnitsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllUnitsRef = AutoDisposeStreamProviderRef<List<StorageUnit>>;
String _$filteredUnitsHash() => r'6da281192ce4bd90ba5346142b7fd4a92824bed7';

/// Grid rows after the three filters (client-side).
///
/// Copied from [filteredUnits].
@ProviderFor(filteredUnits)
final filteredUnitsProvider = AutoDisposeProvider<List<StorageUnit>>.internal(
  filteredUnits,
  name: r'filteredUnitsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredUnitsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredUnitsRef = AutoDisposeProviderRef<List<StorageUnit>>;
String _$unitByIdHash() => r'b43b9bfb43dac58e3af8a2c819f787cb63a61cd5';

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

/// One unit, live.
///
/// Copied from [unitById].
@ProviderFor(unitById)
const unitByIdProvider = UnitByIdFamily();

/// One unit, live.
///
/// Copied from [unitById].
class UnitByIdFamily extends Family<AsyncValue<StorageUnit?>> {
  /// One unit, live.
  ///
  /// Copied from [unitById].
  const UnitByIdFamily();

  /// One unit, live.
  ///
  /// Copied from [unitById].
  UnitByIdProvider call(
    String unitId,
  ) {
    return UnitByIdProvider(
      unitId,
    );
  }

  @override
  UnitByIdProvider getProviderOverride(
    covariant UnitByIdProvider provider,
  ) {
    return call(
      provider.unitId,
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
  String? get name => r'unitByIdProvider';
}

/// One unit, live.
///
/// Copied from [unitById].
class UnitByIdProvider extends AutoDisposeStreamProvider<StorageUnit?> {
  /// One unit, live.
  ///
  /// Copied from [unitById].
  UnitByIdProvider(
    String unitId,
  ) : this._internal(
          (ref) => unitById(
            ref as UnitByIdRef,
            unitId,
          ),
          from: unitByIdProvider,
          name: r'unitByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$unitByIdHash,
          dependencies: UnitByIdFamily._dependencies,
          allTransitiveDependencies: UnitByIdFamily._allTransitiveDependencies,
          unitId: unitId,
        );

  UnitByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.unitId,
  }) : super.internal();

  final String unitId;

  @override
  Override overrideWith(
    Stream<StorageUnit?> Function(UnitByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UnitByIdProvider._internal(
        (ref) => create(ref as UnitByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        unitId: unitId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<StorageUnit?> createElement() {
    return _UnitByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnitByIdProvider && other.unitId == unitId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, unitId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UnitByIdRef on AutoDisposeStreamProviderRef<StorageUnit?> {
  /// The parameter `unitId` of this provider.
  String get unitId;
}

class _UnitByIdProviderElement
    extends AutoDisposeStreamProviderElement<StorageUnit?> with UnitByIdRef {
  _UnitByIdProviderElement(super.provider);

  @override
  String get unitId => (origin as UnitByIdProvider).unitId;
}

String _$entityPhotosHash() => r'ab43d49cdc310e7048db8bd6f32a8b15faea730d';

/// Photos for any entity (unit, item, job), live.
///
/// Copied from [entityPhotos].
@ProviderFor(entityPhotos)
const entityPhotosProvider = EntityPhotosFamily();

/// Photos for any entity (unit, item, job), live.
///
/// Copied from [entityPhotos].
class EntityPhotosFamily extends Family<AsyncValue<List<Photo>>> {
  /// Photos for any entity (unit, item, job), live.
  ///
  /// Copied from [entityPhotos].
  const EntityPhotosFamily();

  /// Photos for any entity (unit, item, job), live.
  ///
  /// Copied from [entityPhotos].
  EntityPhotosProvider call(
    String entityId,
  ) {
    return EntityPhotosProvider(
      entityId,
    );
  }

  @override
  EntityPhotosProvider getProviderOverride(
    covariant EntityPhotosProvider provider,
  ) {
    return call(
      provider.entityId,
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
  String? get name => r'entityPhotosProvider';
}

/// Photos for any entity (unit, item, job), live.
///
/// Copied from [entityPhotos].
class EntityPhotosProvider extends AutoDisposeStreamProvider<List<Photo>> {
  /// Photos for any entity (unit, item, job), live.
  ///
  /// Copied from [entityPhotos].
  EntityPhotosProvider(
    String entityId,
  ) : this._internal(
          (ref) => entityPhotos(
            ref as EntityPhotosRef,
            entityId,
          ),
          from: entityPhotosProvider,
          name: r'entityPhotosProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$entityPhotosHash,
          dependencies: EntityPhotosFamily._dependencies,
          allTransitiveDependencies:
              EntityPhotosFamily._allTransitiveDependencies,
          entityId: entityId,
        );

  EntityPhotosProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.entityId,
  }) : super.internal();

  final String entityId;

  @override
  Override overrideWith(
    Stream<List<Photo>> Function(EntityPhotosRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EntityPhotosProvider._internal(
        (ref) => create(ref as EntityPhotosRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        entityId: entityId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Photo>> createElement() {
    return _EntityPhotosProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EntityPhotosProvider && other.entityId == entityId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, entityId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin EntityPhotosRef on AutoDisposeStreamProviderRef<List<Photo>> {
  /// The parameter `entityId` of this provider.
  String get entityId;
}

class _EntityPhotosProviderElement
    extends AutoDisposeStreamProviderElement<List<Photo>> with EntityPhotosRef {
  _EntityPhotosProviderElement(super.provider);

  @override
  String get entityId => (origin as EntityPhotosProvider).entityId;
}

String _$unitItemsHash() => r'7a2617f74c8a584bd03f5f109fcdd3a3fa56b93d';

/// Items catalogued inside an open unit, live.
///
/// Copied from [unitItems].
@ProviderFor(unitItems)
const unitItemsProvider = UnitItemsFamily();

/// Items catalogued inside an open unit, live.
///
/// Copied from [unitItems].
class UnitItemsFamily extends Family<AsyncValue<List<Item>>> {
  /// Items catalogued inside an open unit, live.
  ///
  /// Copied from [unitItems].
  const UnitItemsFamily();

  /// Items catalogued inside an open unit, live.
  ///
  /// Copied from [unitItems].
  UnitItemsProvider call(
    String unitId,
  ) {
    return UnitItemsProvider(
      unitId,
    );
  }

  @override
  UnitItemsProvider getProviderOverride(
    covariant UnitItemsProvider provider,
  ) {
    return call(
      provider.unitId,
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
  String? get name => r'unitItemsProvider';
}

/// Items catalogued inside an open unit, live.
///
/// Copied from [unitItems].
class UnitItemsProvider extends AutoDisposeStreamProvider<List<Item>> {
  /// Items catalogued inside an open unit, live.
  ///
  /// Copied from [unitItems].
  UnitItemsProvider(
    String unitId,
  ) : this._internal(
          (ref) => unitItems(
            ref as UnitItemsRef,
            unitId,
          ),
          from: unitItemsProvider,
          name: r'unitItemsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$unitItemsHash,
          dependencies: UnitItemsFamily._dependencies,
          allTransitiveDependencies: UnitItemsFamily._allTransitiveDependencies,
          unitId: unitId,
        );

  UnitItemsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.unitId,
  }) : super.internal();

  final String unitId;

  @override
  Override overrideWith(
    Stream<List<Item>> Function(UnitItemsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UnitItemsProvider._internal(
        (ref) => create(ref as UnitItemsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        unitId: unitId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Item>> createElement() {
    return _UnitItemsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnitItemsProvider && other.unitId == unitId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, unitId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UnitItemsRef on AutoDisposeStreamProviderRef<List<Item>> {
  /// The parameter `unitId` of this provider.
  String get unitId;
}

class _UnitItemsProviderElement
    extends AutoDisposeStreamProviderElement<List<Item>> with UnitItemsRef {
  _UnitItemsProviderElement(super.provider);

  @override
  String get unitId => (origin as UnitItemsProvider).unitId;
}

String _$unitJobsHash() => r'57d0d35082db2cc18dcd4d8dda6477dfb918c36a';

/// Jobs that ever touched a unit — the detail-page timeline.
///
/// Copied from [unitJobs].
@ProviderFor(unitJobs)
const unitJobsProvider = UnitJobsFamily();

/// Jobs that ever touched a unit — the detail-page timeline.
///
/// Copied from [unitJobs].
class UnitJobsFamily extends Family<AsyncValue<List<Job>>> {
  /// Jobs that ever touched a unit — the detail-page timeline.
  ///
  /// Copied from [unitJobs].
  const UnitJobsFamily();

  /// Jobs that ever touched a unit — the detail-page timeline.
  ///
  /// Copied from [unitJobs].
  UnitJobsProvider call(
    String unitId,
  ) {
    return UnitJobsProvider(
      unitId,
    );
  }

  @override
  UnitJobsProvider getProviderOverride(
    covariant UnitJobsProvider provider,
  ) {
    return call(
      provider.unitId,
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
  String? get name => r'unitJobsProvider';
}

/// Jobs that ever touched a unit — the detail-page timeline.
///
/// Copied from [unitJobs].
class UnitJobsProvider extends AutoDisposeStreamProvider<List<Job>> {
  /// Jobs that ever touched a unit — the detail-page timeline.
  ///
  /// Copied from [unitJobs].
  UnitJobsProvider(
    String unitId,
  ) : this._internal(
          (ref) => unitJobs(
            ref as UnitJobsRef,
            unitId,
          ),
          from: unitJobsProvider,
          name: r'unitJobsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$unitJobsHash,
          dependencies: UnitJobsFamily._dependencies,
          allTransitiveDependencies: UnitJobsFamily._allTransitiveDependencies,
          unitId: unitId,
        );

  UnitJobsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.unitId,
  }) : super.internal();

  final String unitId;

  @override
  Override overrideWith(
    Stream<List<Job>> Function(UnitJobsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UnitJobsProvider._internal(
        (ref) => create(ref as UnitJobsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        unitId: unitId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Job>> createElement() {
    return _UnitJobsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnitJobsProvider && other.unitId == unitId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, unitId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UnitJobsRef on AutoDisposeStreamProviderRef<List<Job>> {
  /// The parameter `unitId` of this provider.
  String get unitId;
}

class _UnitJobsProviderElement
    extends AutoDisposeStreamProviderElement<List<Job>> with UnitJobsRef {
  _UnitJobsProviderElement(super.provider);

  @override
  String get unitId => (origin as UnitJobsProvider).unitId;
}

String _$unitByQrCodeHash() => r'56309a46a93039a891d26f762836bcdcd3c8ab6b';

/// Look up a unit by scanned QR code value.
///
/// Copied from [unitByQrCode].
@ProviderFor(unitByQrCode)
const unitByQrCodeProvider = UnitByQrCodeFamily();

/// Look up a unit by scanned QR code value.
///
/// Copied from [unitByQrCode].
class UnitByQrCodeFamily extends Family<AsyncValue<StorageUnit?>> {
  /// Look up a unit by scanned QR code value.
  ///
  /// Copied from [unitByQrCode].
  const UnitByQrCodeFamily();

  /// Look up a unit by scanned QR code value.
  ///
  /// Copied from [unitByQrCode].
  UnitByQrCodeProvider call(
    String code,
  ) {
    return UnitByQrCodeProvider(
      code,
    );
  }

  @override
  UnitByQrCodeProvider getProviderOverride(
    covariant UnitByQrCodeProvider provider,
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
  String? get name => r'unitByQrCodeProvider';
}

/// Look up a unit by scanned QR code value.
///
/// Copied from [unitByQrCode].
class UnitByQrCodeProvider extends AutoDisposeFutureProvider<StorageUnit?> {
  /// Look up a unit by scanned QR code value.
  ///
  /// Copied from [unitByQrCode].
  UnitByQrCodeProvider(
    String code,
  ) : this._internal(
          (ref) => unitByQrCode(
            ref as UnitByQrCodeRef,
            code,
          ),
          from: unitByQrCodeProvider,
          name: r'unitByQrCodeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$unitByQrCodeHash,
          dependencies: UnitByQrCodeFamily._dependencies,
          allTransitiveDependencies:
              UnitByQrCodeFamily._allTransitiveDependencies,
          code: code,
        );

  UnitByQrCodeProvider._internal(
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
    FutureOr<StorageUnit?> Function(UnitByQrCodeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UnitByQrCodeProvider._internal(
        (ref) => create(ref as UnitByQrCodeRef),
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
    return _UnitByQrCodeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnitByQrCodeProvider && other.code == code;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, code.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UnitByQrCodeRef on AutoDisposeFutureProviderRef<StorageUnit?> {
  /// The parameter `code` of this provider.
  String get code;
}

class _UnitByQrCodeProviderElement
    extends AutoDisposeFutureProviderElement<StorageUnit?>
    with UnitByQrCodeRef {
  _UnitByQrCodeProviderElement(super.provider);

  @override
  String get code => (origin as UnitByQrCodeProvider).code;
}

String _$inventoryClientFilterHash() =>
    r'92616f405c6285d6aebd01fdf650051226f1c15f';

/// See also [InventoryClientFilter].
@ProviderFor(InventoryClientFilter)
final inventoryClientFilterProvider =
    AutoDisposeNotifierProvider<InventoryClientFilter, String>.internal(
  InventoryClientFilter.new,
  name: r'inventoryClientFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventoryClientFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InventoryClientFilter = AutoDisposeNotifier<String>;
String _$inventoryStatusFilterHash() =>
    r'55608a7d9b123e0883b98356a1c39d519959f367';

/// all | inStorage | inTransit | pending (matches pending* statuses).
///
/// Copied from [InventoryStatusFilter].
@ProviderFor(InventoryStatusFilter)
final inventoryStatusFilterProvider =
    AutoDisposeNotifierProvider<InventoryStatusFilter, String>.internal(
  InventoryStatusFilter.new,
  name: r'inventoryStatusFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventoryStatusFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InventoryStatusFilter = AutoDisposeNotifier<String>;
String _$inventoryTypeFilterHash() =>
    r'3638f827b2b45b96dc4c1c08bf63c73fd5d81634';

/// all | closed | open.
///
/// Copied from [InventoryTypeFilter].
@ProviderFor(InventoryTypeFilter)
final inventoryTypeFilterProvider =
    AutoDisposeNotifierProvider<InventoryTypeFilter, String>.internal(
  InventoryTypeFilter.new,
  name: r'inventoryTypeFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inventoryTypeFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InventoryTypeFilter = AutoDisposeNotifier<String>;
String _$unitMutationsHash() => r'389ff3ba18ff0f67901e7eeff9193acbdf8270bd';

/// Create/update actions on units and their items.
///
/// Copied from [UnitMutations].
@ProviderFor(UnitMutations)
final unitMutationsProvider =
    AutoDisposeAsyncNotifierProvider<UnitMutations, void>.internal(
  UnitMutations.new,
  name: r'unitMutationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unitMutationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UnitMutations = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
