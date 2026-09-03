import 'package:flutter_test/flutter_test.dart';
import 'package:strong_box/core/constants/app_constants.dart';
import 'package:strong_box/core/constants/quote_pricing.dart';
import 'package:strong_box/core/enums/app_enums.dart';
import 'package:strong_box/core/models/quote.dart';

/// The worked example the designs are drawn against
/// (`quick_storage_calculator`): 2 small + 1 medium boxes, a medium van and
/// 2 packers for 3 hours.
Quote _designExample() => const Quote(
      tenantId: AppConstants.defaultTenantId,
      boxes: [
        QuoteBoxLine(size: BoxSize.small, quantity: 2),
        QuoteBoxLine(size: BoxSize.medium, quantity: 1),
      ],
      vehicle: VehicleSize.mediumVan,
      packingRequired: true,
      packers: 2,
      packingHours: 3,
    );

void main() {
  group('Quote totals', () {
    test('matches the figures on the calculator design', () {
      final quote = _designExample();

      expect(quote.boxCount, 3);
      expect(quote.monthlyTotalZar, 685); // 2×195 + 295
      expect(quote.collectionFeeZar, 550);
      expect(quote.packingFeeZar, 900); // 2 packers × 3h × R150
      // Storage starts in month two, so only the once-off services are due.
      expect(quote.dueTodayTotalZar, 1450);
    });

    test('packing costs nothing when the client packs themselves', () {
      final quote = _designExample().copyWith(packingRequired: false);

      expect(quote.packingFeeZar, 0);
      expect(quote.dueTodayTotalZar, 550);
    });

    test('loose items add to the monthly total and the volume', () {
      final preset = QuotePricing.presetFor('diningTable')!;
      final quote = _designExample().copyWith(
        looseItems: [QuoteLooseItem.fromPreset(preset, id: 'a', quantity: 2)],
      );

      expect(quote.looseItemsMonthlyZar, preset.monthlyZar * 2);
      expect(quote.monthlyTotalZar, 685 + preset.monthlyZar * 2);
      expect(quote.volumeM3, closeTo(0.168 + preset.volumeM3 * 2, 0.001));
    });

    test('recommends the smallest vehicle that fits the load', () {
      final small = _designExample();
      expect(small.recommendedVehicle, VehicleSize.smallVan);
      expect(small.vehicleUndersized, isFalse);

      final huge = small.copyWith(
        boxes: const [QuoteBoxLine(size: BoxSize.xl, quantity: 30)],
        vehicle: VehicleSize.smallVan,
      );
      expect(huge.volumeM3, closeTo(10.8, 0.001));
      expect(huge.recommendedVehicle, VehicleSize.largeTruck);
      expect(huge.vehicleUndersized, isTrue);
    });

    test('isEmpty gates the flow until something is added', () {
      const blank = Quote(tenantId: AppConstants.defaultTenantId);
      expect(blank.isEmpty, isTrue);
      expect(_designExample().isEmpty, isFalse);
    });

    test('withSnapshottedTotals freezes the figures onto the document', () {
      final snapshot = _designExample().withSnapshottedTotals();

      expect(snapshot.monthlyStorageZar, 685);
      expect(snapshot.collectionZar, 550);
      expect(snapshot.packingZar, 900);
      expect(snapshot.dueTodayZar, 1450);
      expect(snapshot.estimatedVolumeM3, closeTo(0.168, 0.001));
    });

    test('round-trips through JSON, which the local draft relies on', () {
      final original = _designExample();
      final restored = Quote.fromJson(original.toJson());

      expect(restored, original);
    });
  });

  group('QuotePricing', () {
    test('prices loose items by volume above a handling floor', () {
      // 0.1 m³ × R135 = R13.50, below the floor.
      expect(QuotePricing.looseItemMonthly(0.1),
          QuotePricing.looseItemMinMonthlyZar);
      // 1.08 m³ × R135 = R145.80, rounded to the nearest R5.
      expect(QuotePricing.looseItemMonthly(1.08), 145);
    });

    test('every enum value has exactly one tier', () {
      for (final size in BoxSize.values) {
        expect(QuotePricing.boxTier(size).size, size);
      }
      for (final size in VehicleSize.values) {
        expect(QuotePricing.vehicleTier(size).size, size);
      }
    });
  });
}
