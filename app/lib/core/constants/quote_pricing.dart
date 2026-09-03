import '../enums/app_enums.dart';

/// A storage box tier offered in the public quote calculator.
class BoxTier {
  const BoxTier({
    required this.size,
    required this.name,
    required this.monthlyZar,
    required this.dimensionsCm,
    required this.maxWeightKg,
    required this.volumeM3,
    required this.suits,
  });

  final BoxSize size;
  final String name;
  final int monthlyZar;

  /// Human-readable external dimensions, e.g. `40 × 30 × 30 cm`.
  final String dimensionsCm;
  final int maxWeightKg;

  /// Usable volume, used to drive the vehicle recommendation.
  final double volumeM3;

  /// Three example contents shown on the box card.
  final List<String> suits;
}

/// A pickup vehicle option. Priced once-off per collection.
class VehicleTier {
  const VehicleTier({
    required this.size,
    required this.name,
    required this.onceOffZar,
    required this.capacityM3,
  });

  final VehicleSize size;
  final String name;
  final int onceOffZar;
  final double capacityM3;
}

/// A pre-priced furniture / oversized item in the loose-items catalogue.
class LooseItemPreset {
  const LooseItemPreset({
    required this.key,
    required this.name,
    required this.category,
    required this.emoji,
    required this.defaultDescription,
    required this.lengthM,
    required this.widthM,
    required this.heightM,
  });

  final String key;
  final String name;
  final LooseItemCategory category;
  final String emoji;
  final String defaultDescription;
  final double lengthM;
  final double widthM;
  final double heightM;

  double get volumeM3 => lengthM * widthM * heightM;

  /// Monthly rate derived from volume, so custom items price consistently
  /// with catalogue items.
  int get monthlyZar => QuotePricing.looseItemMonthly(volumeM3);
}

/// Tariffs behind the public quote calculator. Single source of truth —
/// change a rate here and every screen, total and stored quote follows.
///
/// Rates are ZAR, exclusive of nothing (VAT-inclusive, matching the
/// "inc. VAT" labelling on the designs).
class QuotePricing {
  QuotePricing._();

  /// Monthly storage boxes.
  static const boxes = <BoxTier>[
    BoxTier(
      size: BoxSize.small,
      name: 'Small Box',
      monthlyZar: 195,
      dimensionsCm: '40 × 30 × 30 cm',
      maxWeightKg: 15,
      volumeM3: 0.036,
      suits: ['Books & documents', 'Shoes & accessories', 'Small electronics'],
    ),
    BoxTier(
      size: BoxSize.medium,
      name: 'Medium Box',
      monthlyZar: 295,
      dimensionsCm: '60 × 40 × 40 cm',
      maxWeightKg: 25,
      volumeM3: 0.096,
      suits: ['Folded clothing', 'Kitchenware', 'Toys & hobbies'],
    ),
    BoxTier(
      size: BoxSize.large,
      name: 'Large Box',
      monthlyZar: 395,
      dimensionsCm: '80 × 50 × 50 cm',
      maxWeightKg: 35,
      volumeM3: 0.2,
      suits: ['Bedding & linens', 'Bulky winter coats', 'Sporting equipment'],
    ),
    BoxTier(
      size: BoxSize.xl,
      name: 'XL Box',
      monthlyZar: 595,
      dimensionsCm: '100 × 60 × 60 cm',
      maxWeightKg: 45,
      volumeM3: 0.36,
      suits: ['Large appliances', 'Curtains & rugs', 'Dismantled furniture'],
    ),
  ];

  /// Once-off collection vehicles.
  static const vehicles = <VehicleTier>[
    VehicleTier(
      size: VehicleSize.smallVan,
      name: 'Small Van',
      onceOffZar: 350,
      capacityM3: 3,
    ),
    VehicleTier(
      size: VehicleSize.mediumVan,
      name: 'Medium Van',
      onceOffZar: 550,
      capacityM3: 6,
    ),
    VehicleTier(
      size: VehicleSize.largeTruck,
      name: 'Large Truck',
      onceOffZar: 850,
      capacityM3: 12,
    ),
  ];

  /// Packing assistance: per packer, per hour.
  static const packerHourlyZar = 150;

  /// Packing assistance is never booked for less than this.
  static const minPackingHours = 3;

  /// Sensible starting crew size when the client opts into packing.
  static const defaultPackers = 2;

  /// Loose items are priced on volume at this rate per cubic metre…
  static const looseItemRatePerM3 = 135;

  /// …but never below this floor, which covers handling and wrapping.
  static const looseItemMinMonthlyZar = 85;

  /// Insurance cover included in every quote.
  static const includedInsuranceZar = 50000;

  /// Free retrievals are included once every this many months.
  static const freeRetrievalEveryMonths = 3;

  /// Monthly rate for a loose item of [volumeM3], rounded to the nearest R5.
  static int looseItemMonthly(double volumeM3) {
    final raw = volumeM3 * looseItemRatePerM3;
    final rounded = (raw / 5).round() * 5;
    return rounded < looseItemMinMonthlyZar ? looseItemMinMonthlyZar : rounded;
  }

  /// Catalogue of common furniture and oversized items.
  static const looseItemPresets = <LooseItemPreset>[
    LooseItemPreset(
      key: 'diningTable',
      name: 'Dining Table',
      category: LooseItemCategory.tables,
      emoji: '🍽️',
      defaultDescription: 'Seats 6',
      lengthM: 1.6,
      widthM: 0.9,
      heightM: 0.75,
    ),
    LooseItemPreset(
      key: 'coffeeTable',
      name: 'Coffee Table',
      category: LooseItemCategory.tables,
      emoji: '☕',
      defaultDescription: 'Standard',
      lengthM: 1.1,
      widthM: 0.6,
      heightM: 0.45,
    ),
    LooseItemPreset(
      key: 'desk',
      name: 'Desk',
      category: LooseItemCategory.office,
      emoji: '🖥️',
      defaultDescription: 'Office desk',
      lengthM: 1.4,
      widthM: 0.7,
      heightM: 0.75,
    ),
    LooseItemPreset(
      key: 'tvStand',
      name: 'TV Stand',
      category: LooseItemCategory.other,
      emoji: '📺',
      defaultDescription: 'Media unit',
      lengthM: 1.4,
      widthM: 0.4,
      heightM: 0.5,
    ),
    LooseItemPreset(
      key: 'officeChair',
      name: 'Office Chair',
      category: LooseItemCategory.office,
      emoji: '💺',
      defaultDescription: 'Standard Ergonomic',
      lengthM: 0.65,
      widthM: 0.65,
      heightM: 1.15,
    ),
    LooseItemPreset(
      key: 'bookshelf',
      name: 'Bookshelf',
      category: LooseItemCategory.other,
      emoji: '📚',
      defaultDescription: '5 shelves',
      lengthM: 0.8,
      widthM: 0.35,
      heightM: 1.8,
    ),
    LooseItemPreset(
      key: 'doubleBed',
      name: 'Double Bed',
      category: LooseItemCategory.beds,
      emoji: '🛏️',
      defaultDescription: 'Base + mattress',
      lengthM: 1.9,
      widthM: 1.4,
      heightM: 0.6,
    ),
    LooseItemPreset(
      key: 'singleBed',
      name: 'Single Bed',
      category: LooseItemCategory.beds,
      emoji: '🛌',
      defaultDescription: 'Base + mattress',
      lengthM: 1.9,
      widthM: 0.9,
      heightM: 0.5,
    ),
    LooseItemPreset(
      key: 'fridge',
      name: 'Fridge',
      category: LooseItemCategory.appliances,
      emoji: '🧊',
      defaultDescription: 'Upright, defrosted',
      lengthM: 0.7,
      widthM: 0.7,
      heightM: 1.8,
    ),
    LooseItemPreset(
      key: 'washingMachine',
      name: 'Washing Machine',
      category: LooseItemCategory.appliances,
      emoji: '🌀',
      defaultDescription: 'Front loader',
      lengthM: 0.6,
      widthM: 0.6,
      heightM: 0.85,
    ),
    LooseItemPreset(
      key: 'bicycle',
      name: 'Bicycle',
      category: LooseItemCategory.outdoor,
      emoji: '🚲',
      defaultDescription: 'Mountain bike frame',
      lengthM: 1.8,
      widthM: 0.4,
      heightM: 1.1,
    ),
    LooseItemPreset(
      key: 'gardenSet',
      name: 'Garden Set',
      category: LooseItemCategory.outdoor,
      emoji: '🪴',
      defaultDescription: 'Table + 4 chairs',
      lengthM: 1.6,
      widthM: 1.0,
      heightM: 0.9,
    ),
    LooseItemPreset(
      key: 'mirror',
      name: 'Mirror',
      category: LooseItemCategory.other,
      emoji: '🪞',
      defaultDescription: 'Framed, wrapped',
      lengthM: 1.2,
      widthM: 0.1,
      heightM: 1.6,
    ),
    LooseItemPreset(
      key: 'cabinet',
      name: 'Cabinet',
      category: LooseItemCategory.other,
      emoji: '🗄️',
      defaultDescription: 'Two-door',
      lengthM: 1.0,
      widthM: 0.5,
      heightM: 1.6,
    ),
  ];

  /// Preset matching [key], or null when the item was entered by hand.
  static LooseItemPreset? presetFor(String key) {
    for (final preset in looseItemPresets) {
      if (preset.key == key) return preset;
    }
    return null;
  }

  /// Box tier for [size]. Every [BoxSize] has exactly one tier.
  static BoxTier boxTier(BoxSize size) =>
      boxes.firstWhere((tier) => tier.size == size);

  /// Vehicle tier for [size]. Every [VehicleSize] has exactly one tier.
  static VehicleTier vehicleTier(VehicleSize size) =>
      vehicles.firstWhere((tier) => tier.size == size);

  /// Smallest vehicle that fits [volumeM3], falling back to the largest.
  static VehicleSize recommendedVehicle(double volumeM3) {
    for (final tier in vehicles) {
      if (volumeM3 <= tier.capacityM3) return tier.size;
    }
    return vehicles.last.size;
  }

  /// Everyday comparison for a total volume, shown under the volume meter.
  static String volumeComparison(double volumeM3) {
    if (volumeM3 <= 0) return 'Nothing added yet.';
    if (volumeM3 < 1) return 'Equivalent to the boot of a hatchback.';
    if (volumeM3 < 3) return 'Equivalent to a standard single wardrobe.';
    if (volumeM3 < 6) return 'Equivalent to the space of a large walk-in wardrobe.';
    if (volumeM3 < 12) return 'Equivalent to a single garage bay.';
    return 'Equivalent to a double garage — our team will confirm on site.';
  }
}
