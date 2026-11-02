import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strong_box/core/enums/app_enums.dart';
import 'package:strong_box/core/models/quote.dart';
import 'package:strong_box/core/models/value_objects.dart';
import 'package:strong_box/features/quote/providers/quote_providers.dart';
import 'package:strong_box/repositories/booking_repository.dart';
import 'package:strong_box/repositories/quote_draft_store.dart';
import 'package:strong_box/repositories/repository_providers.dart';

/// The bookPickup callable stand-in: answers after a network-ish pause.
class _SlowBooking implements BookingRepository {
  @override
  Future<BookedPickup> bookPickup({
    required QuoteDraft quote,
    required String vehicleId,
    required DateTime date,
    required TimeWindow timeWindow,
    required Address address,
    String? notes,
    String? accessNotes,
    SupplyDropSlot? suppliesFirst,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return (
      jobId: 'job-1',
      supplyJobId: null,
      unitCount: quote.itemCount,
      monthlyZar: 0,
      pickupZar: 0,
      onceOffZar: 0,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MemoryStore implements QuoteDraftStore {
  @override
  Future<SavedQuote?> load() async => null;

  @override
  Future<void> save(SavedQuote quote) async {}
}

void main() {
  // The booking screen only calls `.notifier.book()` — nothing listens to
  // the provider while the callable runs.
  test('a booking completes though nothing listens while it runs', () async {
    final container = ProviderContainer(overrides: [
      bookingRepositoryProvider.overrideWithValue(_SlowBooking()),
      quoteDraftStoreProvider.overrideWithValue(_MemoryStore()),
    ]);
    addTearDown(container.dispose);
    container.read(quoteControllerProvider.notifier).setBox('small', 2);

    final booked = await container.read(pickupBookingProvider.notifier).book(
          date: DateTime(2026, 11, 2),
          timeWindow: TimeWindow.morning,
          address: const Address(line1: '1 Main Rd', city: 'Cape Town'),
        );

    expect(booked.unitCount, 2);
    expect(container.read(quoteControllerProvider).draft.isEmpty, isTrue);
  });
}
