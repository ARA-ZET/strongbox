// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$clientInvoicesHash() => r'4c2c0b79ef55300c4f2ad0172c45c04e4d1355c2';

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

/// A client's monthly invoices, newest first.
///
/// Copied from [clientInvoices].
@ProviderFor(clientInvoices)
const clientInvoicesProvider = ClientInvoicesFamily();

/// A client's monthly invoices, newest first.
///
/// Copied from [clientInvoices].
class ClientInvoicesFamily extends Family<AsyncValue<List<Invoice>>> {
  /// A client's monthly invoices, newest first.
  ///
  /// Copied from [clientInvoices].
  const ClientInvoicesFamily();

  /// A client's monthly invoices, newest first.
  ///
  /// Copied from [clientInvoices].
  ClientInvoicesProvider call(
    String clientId,
  ) {
    return ClientInvoicesProvider(
      clientId,
    );
  }

  @override
  ClientInvoicesProvider getProviderOverride(
    covariant ClientInvoicesProvider provider,
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
  String? get name => r'clientInvoicesProvider';
}

/// A client's monthly invoices, newest first.
///
/// Copied from [clientInvoices].
class ClientInvoicesProvider extends AutoDisposeStreamProvider<List<Invoice>> {
  /// A client's monthly invoices, newest first.
  ///
  /// Copied from [clientInvoices].
  ClientInvoicesProvider(
    String clientId,
  ) : this._internal(
          (ref) => clientInvoices(
            ref as ClientInvoicesRef,
            clientId,
          ),
          from: clientInvoicesProvider,
          name: r'clientInvoicesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$clientInvoicesHash,
          dependencies: ClientInvoicesFamily._dependencies,
          allTransitiveDependencies:
              ClientInvoicesFamily._allTransitiveDependencies,
          clientId: clientId,
        );

  ClientInvoicesProvider._internal(
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
    Stream<List<Invoice>> Function(ClientInvoicesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ClientInvoicesProvider._internal(
        (ref) => create(ref as ClientInvoicesRef),
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
  AutoDisposeStreamProviderElement<List<Invoice>> createElement() {
    return _ClientInvoicesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClientInvoicesProvider && other.clientId == clientId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, clientId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ClientInvoicesRef on AutoDisposeStreamProviderRef<List<Invoice>> {
  /// The parameter `clientId` of this provider.
  String get clientId;
}

class _ClientInvoicesProviderElement
    extends AutoDisposeStreamProviderElement<List<Invoice>>
    with ClientInvoicesRef {
  _ClientInvoicesProviderElement(super.provider);

  @override
  String get clientId => (origin as ClientInvoicesProvider).clientId;
}

String _$invoiceActionsHash() => r'fa73c37db5f60cd926136d12bf5396624b89cd78';

/// Settles invoices: clients pay by EFT, an admin records it here. The
/// client's billing status follows via the onInvoiceUpdated function.
///
/// Copied from [InvoiceActions].
@ProviderFor(InvoiceActions)
final invoiceActionsProvider =
    AutoDisposeAsyncNotifierProvider<InvoiceActions, void>.internal(
  InvoiceActions.new,
  name: r'invoiceActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$invoiceActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InvoiceActions = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
