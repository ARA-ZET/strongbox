// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clients_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$clientsHash() => r'9690c81ec3c56594a603da0729cb4bfc0a6b803f';

/// All clients for the tenant, ordered by name.
///
/// Copied from [clients].
@ProviderFor(clients)
final clientsProvider = AutoDisposeStreamProvider<List<Client>>.internal(
  clients,
  name: r'clientsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$clientsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ClientsRef = AutoDisposeStreamProviderRef<List<Client>>;
String _$clientNamesHash() => r'fda99d05489920bf93efb94c462e06c86f598d6f';

/// clientId → display name lookup used by job/unit tables.
///
/// Copied from [clientNames].
@ProviderFor(clientNames)
final clientNamesProvider = AutoDisposeProvider<Map<String, String>>.internal(
  clientNames,
  name: r'clientNamesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$clientNamesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ClientNamesRef = AutoDisposeProviderRef<Map<String, String>>;
String _$driverUsersHash() => r'4be8ba9af625eff9079bcd45b75f572efbe78e80';

/// All driver users for the tenant.
///
/// Copied from [driverUsers].
@ProviderFor(driverUsers)
final driverUsersProvider = AutoDisposeStreamProvider<List<AppUser>>.internal(
  driverUsers,
  name: r'driverUsersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$driverUsersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DriverUsersRef = AutoDisposeStreamProviderRef<List<AppUser>>;
String _$driverNamesHash() => r'642edf539dab5384948f7440104df287e35ac2d8';

/// driverId → name lookup used by job tables.
///
/// Copied from [driverNames].
@ProviderFor(driverNames)
final driverNamesProvider = AutoDisposeProvider<Map<String, String>>.internal(
  driverNames,
  name: r'driverNamesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$driverNamesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DriverNamesRef = AutoDisposeProviderRef<Map<String, String>>;
String _$filteredClientsHash() => r'6df4e3715c91d8eb22896e81cb7d0eade839c64c';

/// Directory rows after search + status filter.
///
/// Copied from [filteredClients].
@ProviderFor(filteredClients)
final filteredClientsProvider = AutoDisposeProvider<List<Client>>.internal(
  filteredClients,
  name: r'filteredClientsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredClientsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredClientsRef = AutoDisposeProviderRef<List<Client>>;
String _$clientByIdHash() => r'dd274bbde2ed340b1426d1626601895f6858eb29';

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

/// One client, live.
///
/// Copied from [clientById].
@ProviderFor(clientById)
const clientByIdProvider = ClientByIdFamily();

/// One client, live.
///
/// Copied from [clientById].
class ClientByIdFamily extends Family<AsyncValue<Client?>> {
  /// One client, live.
  ///
  /// Copied from [clientById].
  const ClientByIdFamily();

  /// One client, live.
  ///
  /// Copied from [clientById].
  ClientByIdProvider call(
    String clientId,
  ) {
    return ClientByIdProvider(
      clientId,
    );
  }

  @override
  ClientByIdProvider getProviderOverride(
    covariant ClientByIdProvider provider,
  ) {
    return call(
      provider.clientId,
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
  String? get name => r'clientByIdProvider';
}

/// One client, live.
///
/// Copied from [clientById].
class ClientByIdProvider extends AutoDisposeStreamProvider<Client?> {
  /// One client, live.
  ///
  /// Copied from [clientById].
  ClientByIdProvider(
    String clientId,
  ) : this._internal(
          (ref) => clientById(
            ref as ClientByIdRef,
            clientId,
          ),
          from: clientByIdProvider,
          name: r'clientByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$clientByIdHash,
          dependencies: ClientByIdFamily._dependencies,
          allTransitiveDependencies:
              ClientByIdFamily._allTransitiveDependencies,
          clientId: clientId,
        );

  ClientByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.clientId,
  }) : super.internal();

  final String clientId;

  @override
  Override overrideWith(
    Stream<Client?> Function(ClientByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ClientByIdProvider._internal(
        (ref) => create(ref as ClientByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        clientId: clientId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Client?> createElement() {
    return _ClientByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClientByIdProvider && other.clientId == clientId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, clientId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ClientByIdRef on AutoDisposeStreamProviderRef<Client?> {
  /// The parameter `clientId` of this provider.
  String get clientId;
}

class _ClientByIdProviderElement
    extends AutoDisposeStreamProviderElement<Client?> with ClientByIdRef {
  _ClientByIdProviderElement(super.provider);

  @override
  String get clientId => (origin as ClientByIdProvider).clientId;
}

String _$clientUnitsHash() => r'277be61f5e9f45abfb817a799cbcb3237d7958a1';

/// Units under custody for one client.
///
/// Copied from [clientUnits].
@ProviderFor(clientUnits)
const clientUnitsProvider = ClientUnitsFamily();

/// Units under custody for one client.
///
/// Copied from [clientUnits].
class ClientUnitsFamily extends Family<AsyncValue<List<StorageUnit>>> {
  /// Units under custody for one client.
  ///
  /// Copied from [clientUnits].
  const ClientUnitsFamily();

  /// Units under custody for one client.
  ///
  /// Copied from [clientUnits].
  ClientUnitsProvider call(
    String clientId,
  ) {
    return ClientUnitsProvider(
      clientId,
    );
  }

  @override
  ClientUnitsProvider getProviderOverride(
    covariant ClientUnitsProvider provider,
  ) {
    return call(
      provider.clientId,
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
  String? get name => r'clientUnitsProvider';
}

/// Units under custody for one client.
///
/// Copied from [clientUnits].
class ClientUnitsProvider extends AutoDisposeStreamProvider<List<StorageUnit>> {
  /// Units under custody for one client.
  ///
  /// Copied from [clientUnits].
  ClientUnitsProvider(
    String clientId,
  ) : this._internal(
          (ref) => clientUnits(
            ref as ClientUnitsRef,
            clientId,
          ),
          from: clientUnitsProvider,
          name: r'clientUnitsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$clientUnitsHash,
          dependencies: ClientUnitsFamily._dependencies,
          allTransitiveDependencies:
              ClientUnitsFamily._allTransitiveDependencies,
          clientId: clientId,
        );

  ClientUnitsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.clientId,
  }) : super.internal();

  final String clientId;

  @override
  Override overrideWith(
    Stream<List<StorageUnit>> Function(ClientUnitsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ClientUnitsProvider._internal(
        (ref) => create(ref as ClientUnitsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        clientId: clientId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<StorageUnit>> createElement() {
    return _ClientUnitsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClientUnitsProvider && other.clientId == clientId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, clientId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ClientUnitsRef on AutoDisposeStreamProviderRef<List<StorageUnit>> {
  /// The parameter `clientId` of this provider.
  String get clientId;
}

class _ClientUnitsProviderElement
    extends AutoDisposeStreamProviderElement<List<StorageUnit>>
    with ClientUnitsRef {
  _ClientUnitsProviderElement(super.provider);

  @override
  String get clientId => (origin as ClientUnitsProvider).clientId;
}

String _$clientJobsHash() => r'b53ea3074a7ae51544fab88e3daba47d5723b185';

/// Recent jobs for one client.
///
/// Copied from [clientJobs].
@ProviderFor(clientJobs)
const clientJobsProvider = ClientJobsFamily();

/// Recent jobs for one client.
///
/// Copied from [clientJobs].
class ClientJobsFamily extends Family<AsyncValue<List<Job>>> {
  /// Recent jobs for one client.
  ///
  /// Copied from [clientJobs].
  const ClientJobsFamily();

  /// Recent jobs for one client.
  ///
  /// Copied from [clientJobs].
  ClientJobsProvider call(
    String clientId,
  ) {
    return ClientJobsProvider(
      clientId,
    );
  }

  @override
  ClientJobsProvider getProviderOverride(
    covariant ClientJobsProvider provider,
  ) {
    return call(
      provider.clientId,
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
  String? get name => r'clientJobsProvider';
}

/// Recent jobs for one client.
///
/// Copied from [clientJobs].
class ClientJobsProvider extends AutoDisposeStreamProvider<List<Job>> {
  /// Recent jobs for one client.
  ///
  /// Copied from [clientJobs].
  ClientJobsProvider(
    String clientId,
  ) : this._internal(
          (ref) => clientJobs(
            ref as ClientJobsRef,
            clientId,
          ),
          from: clientJobsProvider,
          name: r'clientJobsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$clientJobsHash,
          dependencies: ClientJobsFamily._dependencies,
          allTransitiveDependencies:
              ClientJobsFamily._allTransitiveDependencies,
          clientId: clientId,
        );

  ClientJobsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.clientId,
  }) : super.internal();

  final String clientId;

  @override
  Override overrideWith(
    Stream<List<Job>> Function(ClientJobsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ClientJobsProvider._internal(
        (ref) => create(ref as ClientJobsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        clientId: clientId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Job>> createElement() {
    return _ClientJobsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClientJobsProvider && other.clientId == clientId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, clientId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ClientJobsRef on AutoDisposeStreamProviderRef<List<Job>> {
  /// The parameter `clientId` of this provider.
  String get clientId;
}

class _ClientJobsProviderElement
    extends AutoDisposeStreamProviderElement<List<Job>> with ClientJobsRef {
  _ClientJobsProviderElement(super.provider);

  @override
  String get clientId => (origin as ClientJobsProvider).clientId;
}

String _$clientSearchQueryHash() => r'9a5ddf792d856fd498ae8e61f5efc67c4988b518';

/// Directory search text.
///
/// Copied from [ClientSearchQuery].
@ProviderFor(ClientSearchQuery)
final clientSearchQueryProvider =
    AutoDisposeNotifierProvider<ClientSearchQuery, String>.internal(
  ClientSearchQuery.new,
  name: r'clientSearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$clientSearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ClientSearchQuery = AutoDisposeNotifier<String>;
String _$clientStatusFilterHash() =>
    r'f238f0fd4e3069e57cc1a54a146ba7a7f0d2939b';

/// Directory status filter: all | active | pastDue | cancelled.
///
/// Copied from [ClientStatusFilter].
@ProviderFor(ClientStatusFilter)
final clientStatusFilterProvider =
    AutoDisposeNotifierProvider<ClientStatusFilter, String>.internal(
  ClientStatusFilter.new,
  name: r'clientStatusFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$clientStatusFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ClientStatusFilter = AutoDisposeNotifier<String>;
String _$clientMutationsHash() => r'ddaddedbcb6f099ddf6b38823ee14a666c75c737';

/// Create/update actions on client documents.
///
/// Copied from [ClientMutations].
@ProviderFor(ClientMutations)
final clientMutationsProvider =
    AutoDisposeAsyncNotifierProvider<ClientMutations, void>.internal(
  ClientMutations.new,
  name: r'clientMutationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$clientMutationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ClientMutations = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
