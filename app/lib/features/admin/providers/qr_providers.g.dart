// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$qrBatchesHash() => r'64813edab1612f7c49441180221cec593ff6ee5e';

/// All generated batches, newest first.
///
/// Copied from [qrBatches].
@ProviderFor(qrBatches)
final qrBatchesProvider = AutoDisposeStreamProvider<List<QRBatch>>.internal(
  qrBatches,
  name: r'qrBatchesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$qrBatchesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef QrBatchesRef = AutoDisposeStreamProviderRef<List<QRBatch>>;
String _$batchPreviewHash() => r'10c663adc945da95649c5a44020976cb13908e36';

/// Codes shown in the batch preview grid (illustrative — the persisted
/// batch is generated server-side on commit).
///
/// Copied from [BatchPreview].
@ProviderFor(BatchPreview)
final batchPreviewProvider =
    AutoDisposeNotifierProvider<BatchPreview, List<String>>.internal(
  BatchPreview.new,
  name: r'batchPreviewProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$batchPreviewHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BatchPreview = AutoDisposeNotifier<List<String>>;
String _$qrMutationsHash() => r'04ec7f7928900fba841fd8a27c1c9e14ab0e4e51';

/// Firestore writes for the QR module.
///
/// Copied from [QrMutations].
@ProviderFor(QrMutations)
final qrMutationsProvider =
    AutoDisposeAsyncNotifierProvider<QrMutations, void>.internal(
  QrMutations.new,
  name: r'qrMutationsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$qrMutationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$QrMutations = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
