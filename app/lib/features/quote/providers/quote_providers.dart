import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/models/quote.dart';
import '../../../core/models/value_objects.dart';
import '../../../core/providers/price_catalog_provider.dart';
import '../../../core/utils/async_value_ext.dart';
import '../../../repositories/booking_repository.dart';
import '../../../repositories/quote_draft_store.dart';
import '../../../repositories/repository_providers.dart';

part 'quote_providers.g.dart';

/// The quote being built, plus whether to open booking after sign-in.
/// Open to everyone — no account needed until booking. Saved on the device
/// on every change, so it survives a reload and the trip through sign-up.
@Riverpod(keepAlive: true)
class QuoteController extends _$QuoteController {
  @override
  SavedQuote build() {
    unawaited(_restore());
    return (draft: const QuoteDraft(), bookAfterSignIn: false);
  }

  Future<void> _restore() async {
    final saved = await ref.read(quoteDraftStoreProvider).load();
    if (saved == null) return;
    // Anything built (or imported from a link) since launch wins.
    state = (
      draft: state.draft.isEmpty ? saved.draft : state.draft,
      bookAfterSignIn: state.bookAfterSignIn || saved.bookAfterSignIn,
    );
  }

  void _set(SavedQuote next) {
    state = next;
    unawaited(ref.read(quoteDraftStoreProvider).save(next));
  }

  void setBox(String id, int count) => _set((
    draft: state.draft.withBox(id, count),
    bookAfterSignIn: state.bookAfterSignIn,
  ));

  void setLoose(String id, int count) => _set((
    draft: state.draft.withLoose(id, count),
    bookAfterSignIn: state.bookAfterSignIn,
  ));

  void setSupply(String id, int count) => _set((
    draft: state.draft.withSupply(id, count),
    bookAfterSignIn: state.bookAfterSignIn,
  ));

  void setHelperHours(int hours) => _set((
    draft: state.draft.withHelperHours(hours),
    bookAfterSignIn: state.bookAfterSignIn,
  ));

  void setVehicle(String id) => _set((
    draft: state.draft.copyWith(vehicleId: id),
    bookAfterSignIn: state.bookAfterSignIn,
  ));

  /// Loads a quote handed over in a link (the website's URL form),
  /// replacing the current one. [book] opens booking after sign-in.
  void importQuery(Map<String, String> params, {bool book = false}) => _set((
    draft: QuoteDraft.fromQuery(params),
    bookAfterSignIn: book || state.bookAfterSignIn,
  ));

  /// The visitor tapped "Book pickup" while signed out.
  void requestBooking() => _set((draft: state.draft, bookAfterSignIn: true));

  /// Booking opened — don't send them there again.
  void bookingOpened() {
    if (state.bookAfterSignIn) {
      _set((draft: state.draft, bookAfterSignIn: false));
    }
  }

  void clear() => _set((draft: const QuoteDraft(), bookAfterSignIn: false));
}

/// The quote priced against the live price list.
@riverpod
QuoteTotals quoteTotals(Ref ref) => QuoteTotals(
  ref.watch(quoteControllerProvider.select((q) => q.draft)),
  ref.watch(priceCatalogProvider),
);

/// Books the pickup for the current quote; clears the quote on success.
/// keepAlive: the screen only calls [book], so nothing listens while the
/// callable runs — auto-dispose would tear the notifier down mid-call and
/// the result would land as "Bad state: Future already completed" after
/// the server had already booked.
@Riverpod(keepAlive: true)
class PickupBooking extends _$PickupBooking {
  @override
  FutureOr<BookedPickup?> build() => null;

  Future<BookedPickup> book({
    required DateTime date,
    required TimeWindow timeWindow,
    required Address address,
    String? notes,
    String? accessNotes,
    SupplyDropSlot? suppliesFirst,
  }) async {
    final draft = ref.read(quoteControllerProvider).draft;
    final totals = ref.read(quoteTotalsProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(bookingRepositoryProvider)
          .bookPickup(
            quote: draft,
            vehicleId: totals.vehicle?.id ?? '',
            date: date,
            timeWindow: timeWindow,
            address: address,
            notes: notes,
            accessNotes: accessNotes,
            suppliesFirst: suppliesFirst,
          ),
    );
    state.throwIfError();
    ref.read(quoteControllerProvider.notifier).clear();
    return state.requireValue!;
  }
}
