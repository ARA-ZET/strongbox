// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_closure_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$clientClosureBlockersHash() =>
    r'e5a7ff8b4efc5fc6daebcb6d7d1072ae8aacb9a7';

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

/// What still stops [clientId]'s account closing, live (empty = nothing).
/// The server re-checks before it closes anything.
///
/// Copied from [clientClosureBlockers].
@ProviderFor(clientClosureBlockers)
const clientClosureBlockersProvider = ClientClosureBlockersFamily();

/// What still stops [clientId]'s account closing, live (empty = nothing).
/// The server re-checks before it closes anything.
///
/// Copied from [clientClosureBlockers].
class ClientClosureBlockersFamily extends Family<List<ClosureBlocker>> {
  /// What still stops [clientId]'s account closing, live (empty = nothing).
  /// The server re-checks before it closes anything.
  ///
  /// Copied from [clientClosureBlockers].
  const ClientClosureBlockersFamily();

  /// What still stops [clientId]'s account closing, live (empty = nothing).
  /// The server re-checks before it closes anything.
  ///
  /// Copied from [clientClosureBlockers].
  ClientClosureBlockersProvider call(
    String clientId,
  ) {
    return ClientClosureBlockersProvider(
      clientId,
    );
  }

  @override
  ClientClosureBlockersProvider getProviderOverride(
    covariant ClientClosureBlockersProvider provider,
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
  String? get name => r'clientClosureBlockersProvider';
}

/// What still stops [clientId]'s account closing, live (empty = nothing).
/// The server re-checks before it closes anything.
///
/// Copied from [clientClosureBlockers].
class ClientClosureBlockersProvider
    extends AutoDisposeProvider<List<ClosureBlocker>> {
  /// What still stops [clientId]'s account closing, live (empty = nothing).
  /// The server re-checks before it closes anything.
  ///
  /// Copied from [clientClosureBlockers].
  ClientClosureBlockersProvider(
    String clientId,
  ) : this._internal(
          (ref) => clientClosureBlockers(
            ref as ClientClosureBlockersRef,
            clientId,
          ),
          from: clientClosureBlockersProvider,
          name: r'clientClosureBlockersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$clientClosureBlockersHash,
          dependencies: ClientClosureBlockersFamily._dependencies,
          allTransitiveDependencies:
              ClientClosureBlockersFamily._allTransitiveDependencies,
          clientId: clientId,
        );

  ClientClosureBlockersProvider._internal(
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
    List<ClosureBlocker> Function(ClientClosureBlockersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ClientClosureBlockersProvider._internal(
        (ref) => create(ref as ClientClosureBlockersRef),
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
  AutoDisposeProviderElement<List<ClosureBlocker>> createElement() {
    return _ClientClosureBlockersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClientClosureBlockersProvider && other.clientId == clientId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, clientId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ClientClosureBlockersRef on AutoDisposeProviderRef<List<ClosureBlocker>> {
  /// The parameter `clientId` of this provider.
  String get clientId;
}

class _ClientClosureBlockersProviderElement
    extends AutoDisposeProviderElement<List<ClosureBlocker>>
    with ClientClosureBlockersRef {
  _ClientClosureBlockersProviderElement(super.provider);

  @override
  String get clientId => (origin as ClientClosureBlockersProvider).clientId;
}

String _$accountClosureActionsHash() =>
    r'e60209c2b4df34bfec3602e2020036bb1f2a420e';

/// Admin actions on a client's account closure, via the account-closure
/// Cloud Functions. Errors (e.g. "Not yet: 2 items still in storage")
/// are rethrown for the screen to show.
///
/// Copied from [AccountClosureActions].
@ProviderFor(AccountClosureActions)
final accountClosureActionsProvider =
    NotifierProvider<AccountClosureActions, void>.internal(
  AccountClosureActions.new,
  name: r'accountClosureActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$accountClosureActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AccountClosureActions = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
