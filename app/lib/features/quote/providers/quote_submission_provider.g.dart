// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_submission_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$quoteReturnPathHash() => r'e70d6c72e9cef6e4d3a21b93ad031f6d8940129d';

/// Where to send the visitor once they finish signing in or registering.
///
/// Set when a guest accepts a quote, read by the router's redirect. It has
/// to be a provider rather than a `returnTo` query parameter because the
/// router bounces through the splash screen while `users/{uid}` loads,
/// which would drop the parameter.
///
/// Copied from [QuoteReturnPath].
@ProviderFor(QuoteReturnPath)
final quoteReturnPathProvider =
    NotifierProvider<QuoteReturnPath, String?>.internal(
  QuoteReturnPath.new,
  name: r'quoteReturnPathProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$quoteReturnPathHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$QuoteReturnPath = Notifier<String?>;
String _$quoteSubmissionHash() => r'96fdb2169ab4629c2ee3c50e87dbc69041dd8e90';

/// Accepts the drafted quote on behalf of the signed-in client.
///
/// Holds the accepted [Quote] as its state so the confirmation screen can
/// render the reference and totals after the draft has been cleared.
///
/// Copied from [QuoteSubmission].
@ProviderFor(QuoteSubmission)
final quoteSubmissionProvider =
    AsyncNotifierProvider<QuoteSubmission, Quote?>.internal(
  QuoteSubmission.new,
  name: r'quoteSubmissionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$quoteSubmissionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$QuoteSubmission = AsyncNotifier<Quote?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
