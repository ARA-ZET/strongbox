// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentClientHash() => r'e8926e31ef23756793c53872627dedd70b680a53';

/// The signed-in user's client record, resolved by primaryUserId.
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
String _$activeDeliveryHash() => r'bb6e93bbff1350ee82fe0b398da4640816331e36';

/// The delivery currently on the road (if any) — dashboard banner.
///
/// Copied from [activeDelivery].
@ProviderFor(activeDelivery)
final activeDeliveryProvider = AutoDisposeProvider<Job?>.internal(
  activeDelivery,
  name: r'activeDeliveryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeDeliveryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ActiveDeliveryRef = AutoDisposeProviderRef<Job?>;
String _$filteredMyUnitsHash() => r'493a2087426f540a7693022e68f1734c7a54930f';

/// Units after search + status filter.
///
/// Copied from [filteredMyUnits].
@ProviderFor(filteredMyUnits)
final filteredMyUnitsProvider = AutoDisposeProvider<List<StorageUnit>>.internal(
  filteredMyUnits,
  name: r'filteredMyUnitsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredMyUnitsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredMyUnitsRef = AutoDisposeProviderRef<List<StorageUnit>>;
String _$clientUnitDetailHash() => r'42ad62811f1a9f6173a076e48e2fbed6315deb28';

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
String _$storageStatusFilterHash() =>
    r'ec1ca558d9a188b443701be5a1b185ede407cd2b';

/// Storage filter chip: all | inStorage | inTransit | pendingPickup | delivered.
///
/// Copied from [StorageStatusFilter].
@ProviderFor(StorageStatusFilter)
final storageStatusFilterProvider =
    AutoDisposeNotifierProvider<StorageStatusFilter, String>.internal(
  StorageStatusFilter.new,
  name: r'storageStatusFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$storageStatusFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StorageStatusFilter = AutoDisposeNotifier<String>;
String _$deliveryRequestHash() => r'2b0e2bbbb92c9ca51aacecf65262e8e111d907cb';

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
String _$accountActionsHash() => r'ff555412bd03dd39a4dceefac20e75dfb782c856';

/// Profile, address, prefs and account-deletion writes for the client.
///
/// Copied from [AccountActions].
@ProviderFor(AccountActions)
final accountActionsProvider =
    AutoDisposeAsyncNotifierProvider<AccountActions, void>.internal(
  AccountActions.new,
  name: r'accountActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$accountActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AccountActions = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
