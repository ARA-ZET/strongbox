// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentClientHash() => r'4357da6cfd373b61c78b2cc5c7ab77ee3ef67871';

/// The current user's client record, resolved by primaryUserId.
///
/// Copied from [currentClient].
@ProviderFor(currentClient)
final currentClientProvider = AutoDisposeStreamProvider<Client?>.internal(
  currentClient,
  name: r'currentClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentClientRef = AutoDisposeStreamProviderRef<Client?>;
String _$myUnitsHash() => r'c17e55491d9ddf734da06aa03cc0b36a8a560d64';

/// The client's storage units (non-deleted, newest first).
///
/// Copied from [myUnits].
@ProviderFor(myUnits)
final myUnitsProvider = AutoDisposeStreamProvider<List<StorageUnit>>.internal(
  myUnits,
  name: r'myUnitsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myUnitsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MyUnitsRef = AutoDisposeStreamProviderRef<List<StorageUnit>>;
String _$myStorageBillHash() => r'd2cf58b53ab3ad7de1eeb4ca7b243c5285a56139';

/// What the client pays for storage each month: per-unit rates from the
/// shared price list (same numbers as the website).
///
/// Copied from [myStorageBill].
@ProviderFor(myStorageBill)
final myStorageBillProvider = AutoDisposeProvider<StorageBill>.internal(
  myStorageBill,
  name: r'myStorageBillProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myStorageBillHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MyStorageBillRef = AutoDisposeProviderRef<StorageBill>;
String _$myItemsHash() => r'09534f8650a72db60c4d79e27ace5fbffbf42c5a';

/// The client's individually catalogued items (across all open units).
///
/// Copied from [myItems].
@ProviderFor(myItems)
final myItemsProvider = AutoDisposeStreamProvider<List<Item>>.internal(
  myItems,
  name: r'myItemsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MyItemsRef = AutoDisposeStreamProviderRef<List<Item>>;
String _$myJobsHash() => r'7bca92c06fd7503a23ff55767f95725e6ae0bff0';

/// The client's jobs, newest first.
///
/// Copied from [myJobs].
@ProviderFor(myJobs)
final myJobsProvider = AutoDisposeStreamProvider<List<Job>>.internal(
  myJobs,
  name: r'myJobsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myJobsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MyJobsRef = AutoDisposeStreamProviderRef<List<Job>>;
String _$myOrderHash() => r'83de276fa68e1de0515a5ef8f429c362b8ad8c89';

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

/// One of the client's orders (jobs), live; null until loaded or if it
/// isn't theirs.
///
/// Copied from [myOrder].
@ProviderFor(myOrder)
const myOrderProvider = MyOrderFamily();

/// One of the client's orders (jobs), live; null until loaded or if it
/// isn't theirs.
///
/// Copied from [myOrder].
class MyOrderFamily extends Family<Job?> {
  /// One of the client's orders (jobs), live; null until loaded or if it
  /// isn't theirs.
  ///
  /// Copied from [myOrder].
  const MyOrderFamily();

  /// One of the client's orders (jobs), live; null until loaded or if it
  /// isn't theirs.
  ///
  /// Copied from [myOrder].
  MyOrderProvider call(
    String jobId,
  ) {
    return MyOrderProvider(
      jobId,
    );
  }

  @override
  MyOrderProvider getProviderOverride(
    covariant MyOrderProvider provider,
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
  String? get name => r'myOrderProvider';
}

/// One of the client's orders (jobs), live; null until loaded or if it
/// isn't theirs.
///
/// Copied from [myOrder].
class MyOrderProvider extends AutoDisposeProvider<Job?> {
  /// One of the client's orders (jobs), live; null until loaded or if it
  /// isn't theirs.
  ///
  /// Copied from [myOrder].
  MyOrderProvider(
    String jobId,
  ) : this._internal(
          (ref) => myOrder(
            ref as MyOrderRef,
            jobId,
          ),
          from: myOrderProvider,
          name: r'myOrderProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$myOrderHash,
          dependencies: MyOrderFamily._dependencies,
          allTransitiveDependencies: MyOrderFamily._allTransitiveDependencies,
          jobId: jobId,
        );

  MyOrderProvider._internal(
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
    Job? Function(MyOrderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MyOrderProvider._internal(
        (ref) => create(ref as MyOrderRef),
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
  AutoDisposeProviderElement<Job?> createElement() {
    return _MyOrderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MyOrderProvider && other.jobId == jobId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, jobId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MyOrderRef on AutoDisposeProviderRef<Job?> {
  /// The parameter `jobId` of this provider.
  String get jobId;
}

class _MyOrderProviderElement extends AutoDisposeProviderElement<Job?>
    with MyOrderRef {
  _MyOrderProviderElement(super.provider);

  @override
  String get jobId => (origin as MyOrderProvider).jobId;
}

String _$myTodosHash() => r'99f318440cbefda9e7c46ee7165b21d6e2968698';

/// Dashboard "To do": driver at the door, invoices to pay, boxes to pack.
///
/// Copied from [myTodos].
@ProviderFor(myTodos)
final myTodosProvider = AutoDisposeProvider<List<ClientTodo>>.internal(
  myTodos,
  name: r'myTodosProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myTodosHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MyTodosRef = AutoDisposeProviderRef<List<ClientTodo>>;
String _$filteredMyUnitsHash() => r'bf78172633dbf560c2970081cf94b61c8959ae76';

/// Units after search + status filter. [status] is a [StorageStatus] name
/// or 'all' — it comes from the URL (/client/storage?status=inStorage) so
/// the dashboard can link straight to a filtered view.
///
/// Copied from [filteredMyUnits].
@ProviderFor(filteredMyUnits)
const filteredMyUnitsProvider = FilteredMyUnitsFamily();

/// Units after search + status filter. [status] is a [StorageStatus] name
/// or 'all' — it comes from the URL (/client/storage?status=inStorage) so
/// the dashboard can link straight to a filtered view.
///
/// Copied from [filteredMyUnits].
class FilteredMyUnitsFamily extends Family<List<StorageUnit>> {
  /// Units after search + status filter. [status] is a [StorageStatus] name
  /// or 'all' — it comes from the URL (/client/storage?status=inStorage) so
  /// the dashboard can link straight to a filtered view.
  ///
  /// Copied from [filteredMyUnits].
  const FilteredMyUnitsFamily();

  /// Units after search + status filter. [status] is a [StorageStatus] name
  /// or 'all' — it comes from the URL (/client/storage?status=inStorage) so
  /// the dashboard can link straight to a filtered view.
  ///
  /// Copied from [filteredMyUnits].
  FilteredMyUnitsProvider call(
    String status,
  ) {
    return FilteredMyUnitsProvider(
      status,
    );
  }

  @override
  FilteredMyUnitsProvider getProviderOverride(
    covariant FilteredMyUnitsProvider provider,
  ) {
    return call(
      provider.status,
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
  String? get name => r'filteredMyUnitsProvider';
}

/// Units after search + status filter. [status] is a [StorageStatus] name
/// or 'all' — it comes from the URL (/client/storage?status=inStorage) so
/// the dashboard can link straight to a filtered view.
///
/// Copied from [filteredMyUnits].
class FilteredMyUnitsProvider extends AutoDisposeProvider<List<StorageUnit>> {
  /// Units after search + status filter. [status] is a [StorageStatus] name
  /// or 'all' — it comes from the URL (/client/storage?status=inStorage) so
  /// the dashboard can link straight to a filtered view.
  ///
  /// Copied from [filteredMyUnits].
  FilteredMyUnitsProvider(
    String status,
  ) : this._internal(
          (ref) => filteredMyUnits(
            ref as FilteredMyUnitsRef,
            status,
          ),
          from: filteredMyUnitsProvider,
          name: r'filteredMyUnitsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$filteredMyUnitsHash,
          dependencies: FilteredMyUnitsFamily._dependencies,
          allTransitiveDependencies:
              FilteredMyUnitsFamily._allTransitiveDependencies,
          status: status,
        );

  FilteredMyUnitsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final String status;

  @override
  Override overrideWith(
    List<StorageUnit> Function(FilteredMyUnitsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredMyUnitsProvider._internal(
        (ref) => create(ref as FilteredMyUnitsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<StorageUnit>> createElement() {
    return _FilteredMyUnitsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredMyUnitsProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FilteredMyUnitsRef on AutoDisposeProviderRef<List<StorageUnit>> {
  /// The parameter `status` of this provider.
  String get status;
}

class _FilteredMyUnitsProviderElement
    extends AutoDisposeProviderElement<List<StorageUnit>>
    with FilteredMyUnitsRef {
  _FilteredMyUnitsProviderElement(super.provider);

  @override
  String get status => (origin as FilteredMyUnitsProvider).status;
}

String _$clientUnitDetailHash() => r'42ad62811f1a9f6173a076e48e2fbed6315deb28';

/// One unit, live (client detail view).
///
/// Copied from [clientUnitDetail].
@ProviderFor(clientUnitDetail)
const clientUnitDetailProvider = ClientUnitDetailFamily();

/// One unit, live (client detail view).
///
/// Copied from [clientUnitDetail].
class ClientUnitDetailFamily extends Family<AsyncValue<StorageUnit?>> {
  /// One unit, live (client detail view).
  ///
  /// Copied from [clientUnitDetail].
  const ClientUnitDetailFamily();

  /// One unit, live (client detail view).
  ///
  /// Copied from [clientUnitDetail].
  ClientUnitDetailProvider call(
    String unitId,
  ) {
    return ClientUnitDetailProvider(
      unitId,
    );
  }

  @override
  ClientUnitDetailProvider getProviderOverride(
    covariant ClientUnitDetailProvider provider,
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
  String? get name => r'clientUnitDetailProvider';
}

/// One unit, live (client detail view).
///
/// Copied from [clientUnitDetail].
class ClientUnitDetailProvider extends AutoDisposeStreamProvider<StorageUnit?> {
  /// One unit, live (client detail view).
  ///
  /// Copied from [clientUnitDetail].
  ClientUnitDetailProvider(
    String unitId,
  ) : this._internal(
          (ref) => clientUnitDetail(
            ref as ClientUnitDetailRef,
            unitId,
          ),
          from: clientUnitDetailProvider,
          name: r'clientUnitDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$clientUnitDetailHash,
          dependencies: ClientUnitDetailFamily._dependencies,
          allTransitiveDependencies:
              ClientUnitDetailFamily._allTransitiveDependencies,
          unitId: unitId,
        );

  ClientUnitDetailProvider._internal(
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
    Stream<StorageUnit?> Function(ClientUnitDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ClientUnitDetailProvider._internal(
        (ref) => create(ref as ClientUnitDetailRef),
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
    return _ClientUnitDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClientUnitDetailProvider && other.unitId == unitId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, unitId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ClientUnitDetailRef on AutoDisposeStreamProviderRef<StorageUnit?> {
  /// The parameter `unitId` of this provider.
  String get unitId;
}

class _ClientUnitDetailProviderElement
    extends AutoDisposeStreamProviderElement<StorageUnit?>
    with ClientUnitDetailRef {
  _ClientUnitDetailProviderElement(super.provider);

  @override
  String get unitId => (origin as ClientUnitDetailProvider).unitId;
}

String _$clientUnitPhotosHash() => r'5dbfe40c5929e14314fb868b07874772988b06f8';

/// Photos for a unit, live.
///
/// Copied from [clientUnitPhotos].
@ProviderFor(clientUnitPhotos)
const clientUnitPhotosProvider = ClientUnitPhotosFamily();

/// Photos for a unit, live.
///
/// Copied from [clientUnitPhotos].
class ClientUnitPhotosFamily extends Family<AsyncValue<List<Photo>>> {
  /// Photos for a unit, live.
  ///
  /// Copied from [clientUnitPhotos].
  const ClientUnitPhotosFamily();

  /// Photos for a unit, live.
  ///
  /// Copied from [clientUnitPhotos].
  ClientUnitPhotosProvider call(
    String unitId,
  ) {
    return ClientUnitPhotosProvider(
      unitId,
    );
  }

  @override
  ClientUnitPhotosProvider getProviderOverride(
    covariant ClientUnitPhotosProvider provider,
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
  String? get name => r'clientUnitPhotosProvider';
}

/// Photos for a unit, live.
///
/// Copied from [clientUnitPhotos].
class ClientUnitPhotosProvider extends AutoDisposeStreamProvider<List<Photo>> {
  /// Photos for a unit, live.
  ///
  /// Copied from [clientUnitPhotos].
  ClientUnitPhotosProvider(
    String unitId,
  ) : this._internal(
          (ref) => clientUnitPhotos(
            ref as ClientUnitPhotosRef,
            unitId,
          ),
          from: clientUnitPhotosProvider,
          name: r'clientUnitPhotosProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$clientUnitPhotosHash,
          dependencies: ClientUnitPhotosFamily._dependencies,
          allTransitiveDependencies:
              ClientUnitPhotosFamily._allTransitiveDependencies,
          unitId: unitId,
        );

  ClientUnitPhotosProvider._internal(
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
    Stream<List<Photo>> Function(ClientUnitPhotosRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ClientUnitPhotosProvider._internal(
        (ref) => create(ref as ClientUnitPhotosRef),
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
  AutoDisposeStreamProviderElement<List<Photo>> createElement() {
    return _ClientUnitPhotosProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClientUnitPhotosProvider && other.unitId == unitId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, unitId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ClientUnitPhotosRef on AutoDisposeStreamProviderRef<List<Photo>> {
  /// The parameter `unitId` of this provider.
  String get unitId;
}

class _ClientUnitPhotosProviderElement
    extends AutoDisposeStreamProviderElement<List<Photo>>
    with ClientUnitPhotosRef {
  _ClientUnitPhotosProviderElement(super.provider);

  @override
  String get unitId => (origin as ClientUnitPhotosProvider).unitId;
}

String _$clientUnitItemsHash() => r'a1d0847eda9bd9b6b288378ebe5d61f534c5d7b1';

/// Items inside an open unit, live. Queried by client (not unit) so the
/// query stays within what the rules let a client read.
///
/// Copied from [clientUnitItems].
@ProviderFor(clientUnitItems)
const clientUnitItemsProvider = ClientUnitItemsFamily();

/// Items inside an open unit, live. Queried by client (not unit) so the
/// query stays within what the rules let a client read.
///
/// Copied from [clientUnitItems].
class ClientUnitItemsFamily extends Family<AsyncValue<List<Item>>> {
  /// Items inside an open unit, live. Queried by client (not unit) so the
  /// query stays within what the rules let a client read.
  ///
  /// Copied from [clientUnitItems].
  const ClientUnitItemsFamily();

  /// Items inside an open unit, live. Queried by client (not unit) so the
  /// query stays within what the rules let a client read.
  ///
  /// Copied from [clientUnitItems].
  ClientUnitItemsProvider call(
    String unitId,
  ) {
    return ClientUnitItemsProvider(
      unitId,
    );
  }

  @override
  ClientUnitItemsProvider getProviderOverride(
    covariant ClientUnitItemsProvider provider,
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
  String? get name => r'clientUnitItemsProvider';
}

/// Items inside an open unit, live. Queried by client (not unit) so the
/// query stays within what the rules let a client read.
///
/// Copied from [clientUnitItems].
class ClientUnitItemsProvider extends AutoDisposeStreamProvider<List<Item>> {
  /// Items inside an open unit, live. Queried by client (not unit) so the
  /// query stays within what the rules let a client read.
  ///
  /// Copied from [clientUnitItems].
  ClientUnitItemsProvider(
    String unitId,
  ) : this._internal(
          (ref) => clientUnitItems(
            ref as ClientUnitItemsRef,
            unitId,
          ),
          from: clientUnitItemsProvider,
          name: r'clientUnitItemsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$clientUnitItemsHash,
          dependencies: ClientUnitItemsFamily._dependencies,
          allTransitiveDependencies:
              ClientUnitItemsFamily._allTransitiveDependencies,
          unitId: unitId,
        );

  ClientUnitItemsProvider._internal(
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
    Stream<List<Item>> Function(ClientUnitItemsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ClientUnitItemsProvider._internal(
        (ref) => create(ref as ClientUnitItemsRef),
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
    return _ClientUnitItemsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClientUnitItemsProvider && other.unitId == unitId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, unitId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ClientUnitItemsRef on AutoDisposeStreamProviderRef<List<Item>> {
  /// The parameter `unitId` of this provider.
  String get unitId;
}

class _ClientUnitItemsProviderElement
    extends AutoDisposeStreamProviderElement<List<Item>>
    with ClientUnitItemsRef {
  _ClientUnitItemsProviderElement(super.provider);

  @override
  String get unitId => (origin as ClientUnitItemsProvider).unitId;
}

String _$clientUnitAuditHash() => r'4ca4859378c5add499856e7cec87fa78c9b9f754';

/// Last audit events for a unit — the Security & Activity rail.
///
/// Copied from [clientUnitAudit].
@ProviderFor(clientUnitAudit)
const clientUnitAuditProvider = ClientUnitAuditFamily();

/// Last audit events for a unit — the Security & Activity rail.
///
/// Copied from [clientUnitAudit].
class ClientUnitAuditFamily extends Family<AsyncValue<List<AuditEvent>>> {
  /// Last audit events for a unit — the Security & Activity rail.
  ///
  /// Copied from [clientUnitAudit].
  const ClientUnitAuditFamily();

  /// Last audit events for a unit — the Security & Activity rail.
  ///
  /// Copied from [clientUnitAudit].
  ClientUnitAuditProvider call(
    String unitId,
  ) {
    return ClientUnitAuditProvider(
      unitId,
    );
  }

  @override
  ClientUnitAuditProvider getProviderOverride(
    covariant ClientUnitAuditProvider provider,
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
  String? get name => r'clientUnitAuditProvider';
}

/// Last audit events for a unit — the Security & Activity rail.
///
/// Copied from [clientUnitAudit].
class ClientUnitAuditProvider
    extends AutoDisposeStreamProvider<List<AuditEvent>> {
  /// Last audit events for a unit — the Security & Activity rail.
  ///
  /// Copied from [clientUnitAudit].
  ClientUnitAuditProvider(
    String unitId,
  ) : this._internal(
          (ref) => clientUnitAudit(
            ref as ClientUnitAuditRef,
            unitId,
          ),
          from: clientUnitAuditProvider,
          name: r'clientUnitAuditProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$clientUnitAuditHash,
          dependencies: ClientUnitAuditFamily._dependencies,
          allTransitiveDependencies:
              ClientUnitAuditFamily._allTransitiveDependencies,
          unitId: unitId,
        );

  ClientUnitAuditProvider._internal(
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
    Stream<List<AuditEvent>> Function(ClientUnitAuditRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ClientUnitAuditProvider._internal(
        (ref) => create(ref as ClientUnitAuditRef),
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
  AutoDisposeStreamProviderElement<List<AuditEvent>> createElement() {
    return _ClientUnitAuditProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClientUnitAuditProvider && other.unitId == unitId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, unitId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ClientUnitAuditRef on AutoDisposeStreamProviderRef<List<AuditEvent>> {
  /// The parameter `unitId` of this provider.
  String get unitId;
}

class _ClientUnitAuditProviderElement
    extends AutoDisposeStreamProviderElement<List<AuditEvent>>
    with ClientUnitAuditRef {
  _ClientUnitAuditProviderElement(super.provider);

  @override
  String get unitId => (origin as ClientUnitAuditProvider).unitId;
}

String _$myInvoicesHash() => r'40c94beb2d8f4b41e32aa573a7094a9cce806fb0';

/// The client's monthly invoices (issued by the monthlyInvoices function).
///
/// Copied from [myInvoices].
@ProviderFor(myInvoices)
final myInvoicesProvider = AutoDisposeStreamProvider<List<Invoice>>.internal(
  myInvoices,
  name: r'myInvoicesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myInvoicesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MyInvoicesRef = AutoDisposeStreamProviderRef<List<Invoice>>;
String _$myPackingPhotosHash() => r'c74650c2ceda257dd0e61329b08b54250c6b6e0e';

/// Photos the signed-in client took of [unitId] while packing.
///
/// Copied from [myPackingPhotos].
@ProviderFor(myPackingPhotos)
const myPackingPhotosProvider = MyPackingPhotosFamily();

/// Photos the signed-in client took of [unitId] while packing.
///
/// Copied from [myPackingPhotos].
class MyPackingPhotosFamily extends Family<List<Photo>> {
  /// Photos the signed-in client took of [unitId] while packing.
  ///
  /// Copied from [myPackingPhotos].
  const MyPackingPhotosFamily();

  /// Photos the signed-in client took of [unitId] while packing.
  ///
  /// Copied from [myPackingPhotos].
  MyPackingPhotosProvider call(
    String unitId,
  ) {
    return MyPackingPhotosProvider(
      unitId,
    );
  }

  @override
  MyPackingPhotosProvider getProviderOverride(
    covariant MyPackingPhotosProvider provider,
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
  String? get name => r'myPackingPhotosProvider';
}

/// Photos the signed-in client took of [unitId] while packing.
///
/// Copied from [myPackingPhotos].
class MyPackingPhotosProvider extends AutoDisposeProvider<List<Photo>> {
  /// Photos the signed-in client took of [unitId] while packing.
  ///
  /// Copied from [myPackingPhotos].
  MyPackingPhotosProvider(
    String unitId,
  ) : this._internal(
          (ref) => myPackingPhotos(
            ref as MyPackingPhotosRef,
            unitId,
          ),
          from: myPackingPhotosProvider,
          name: r'myPackingPhotosProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$myPackingPhotosHash,
          dependencies: MyPackingPhotosFamily._dependencies,
          allTransitiveDependencies:
              MyPackingPhotosFamily._allTransitiveDependencies,
          unitId: unitId,
        );

  MyPackingPhotosProvider._internal(
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
    List<Photo> Function(MyPackingPhotosRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MyPackingPhotosProvider._internal(
        (ref) => create(ref as MyPackingPhotosRef),
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
  AutoDisposeProviderElement<List<Photo>> createElement() {
    return _MyPackingPhotosProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MyPackingPhotosProvider && other.unitId == unitId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, unitId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MyPackingPhotosRef on AutoDisposeProviderRef<List<Photo>> {
  /// The parameter `unitId` of this provider.
  String get unitId;
}

class _MyPackingPhotosProviderElement
    extends AutoDisposeProviderElement<List<Photo>> with MyPackingPhotosRef {
  _MyPackingPhotosProviderElement(super.provider);

  @override
  String get unitId => (origin as MyPackingPhotosProvider).unitId;
}

String _$storageSearchQueryHash() =>
    r'3673d098bdc1678f78884f7c035738984168e103';

/// Storage search text.
///
/// Copied from [StorageSearchQuery].
@ProviderFor(StorageSearchQuery)
final storageSearchQueryProvider =
    AutoDisposeNotifierProvider<StorageSearchQuery, String>.internal(
  StorageSearchQuery.new,
  name: r'storageSearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$storageSearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StorageSearchQuery = AutoDisposeNotifier<String>;
String _$packingActionsHash() => r'e90dd0a4a5a7facfff77c8314c520df741756d4c';

/// The client photographing and describing boxes while packing — the
/// contents before sealing, the sealed box with its label. Drivers and ops
/// see the same photos on the unit.
///
/// Copied from [PackingActions].
@ProviderFor(PackingActions)
final packingActionsProvider =
    AsyncNotifierProvider<PackingActions, void>.internal(
  PackingActions.new,
  name: r'packingActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$packingActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PackingActions = AsyncNotifier<void>;
String _$deliveryRequestHash() => r'ce9894d221c39a44ee405153343179b5308e22ea';

/// See also [DeliveryRequest].
@ProviderFor(DeliveryRequest)
final deliveryRequestProvider =
    AutoDisposeNotifierProvider<DeliveryRequest, DeliveryRequestData>.internal(
  DeliveryRequest.new,
  name: r'deliveryRequestProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deliveryRequestHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DeliveryRequest = AutoDisposeNotifier<DeliveryRequestData>;
String _$accountActionsHash() => r'791d27cb5799c20ce73642a0733a6834e66a2899';

/// Profile, address, prefs and account-deletion writes for the client.
///
/// Copied from [AccountActions].
@ProviderFor(AccountActions)
final accountActionsProvider =
    AsyncNotifierProvider<AccountActions, void>.internal(
  AccountActions.new,
  name: r'accountActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$accountActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AccountActions = AsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
