// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$quoteTotalsHash() => r'0954560b5e643233963eef1ff4df36a5db627b82';

/// The quote priced against the live price list.
///
/// Copied from [quoteTotals].
@ProviderFor(quoteTotals)
final quoteTotalsProvider = AutoDisposeProvider<QuoteTotals>.internal(
  quoteTotals,
  name: r'quoteTotalsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$quoteTotalsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef QuoteTotalsRef = AutoDisposeProviderRef<QuoteTotals>;
String _$quoteControllerHash() => r'8ebc4352788a038faa2bc2f0626f4e236abc15ec';

/// The quote being built, plus whether to open booking after sign-in.
/// Open to everyone — no account needed until booking. Saved on the device
/// on every change, so it survives a reload and the trip through sign-up.
///
/// Copied from [QuoteController].
@ProviderFor(QuoteController)
final quoteControllerProvider =
    NotifierProvider<QuoteController, SavedQuote>.internal(
  QuoteController.new,
  name: r'quoteControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$quoteControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$QuoteController = Notifier<SavedQuote>;
String _$pickupBookingHash() => r'5f07298deb0e1d3703a99784011da7c2abf12fe9';

/// Books the pickup for the current quote; clears the quote on success.
/// keepAlive: the screen only calls [book], so nothing listens while the
/// callable runs — auto-dispose would tear the notifier down mid-call and
/// the result would land as "Bad state: Future already completed" after
/// the server had already booked.
///
/// Copied from [PickupBooking].
@ProviderFor(PickupBooking)
final pickupBookingProvider =
    AsyncNotifierProvider<PickupBooking, BookedPickup?>.internal(
  PickupBooking.new,
  name: r'pickupBookingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pickupBookingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PickupBooking = AsyncNotifier<BookedPickup?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
