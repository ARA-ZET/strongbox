import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/quote_pricing.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/models/quote.dart';

part 'quote_draft_provider.g.dart';

/// Local key holding the in-progress quote so a guest can refresh the page,
/// or bounce through registration, without losing their basket.
const _draftStorageKey = 'strongbox.quote.draft.v1';

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) =>
    SharedPreferences.getInstance();

/// The quote the visitor is building right now.
///
/// keepAlive because the draft has to outlive every screen in the flow —
/// including the trip out to `/register` and back — and is mirrored to
/// local storage so a hard refresh does not lose it either.
@Riverpod(keepAlive: true)
class QuoteDraft extends _$QuoteDraft {
  static const _uuid = Uuid();

  @override
  Quote build() {
    // Hydration is async; until it lands the visitor sees an empty quote.
    // Any edit made in that window wins, since [_restore] bails once the
    // draft is no longer pristine.
    Future.microtask(_restore);
    return const Quote(tenantId: AppConstants.defaultTenantId);
  }

  // ------------------------------------------------------------ persistence

  Future<void> _restore() async {
    if (!state.isEmpty) return;
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final raw = prefs.getString(_draftStorageKey);
      if (raw == null || raw.isEmpty) return;
      if (!state.isEmpty) return;
      state = Quote.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // A malformed or stale draft is not worth surfacing — the visitor
      // simply starts from an empty calculator.
      await _clearStored();
    }
  }

  Future<void> _persist() async {
    final snapshot = state;
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      // Timestamps serialise to Firestore `Timestamp`s, which are not JSON
      // encodable — a draft never has them set, so drop them defensively.
      final json = snapshot.copyWith(
        createdAt: null,
        updatedAt: null,
        acceptedAt: null,
        deletedAt: null,
      ).toJson();
      await prefs.setString(_draftStorageKey, jsonEncode(json));
    } catch (_) {
      // Local storage being unavailable (private browsing, quota) must not
      // break the flow — the in-memory draft still works.
    }
  }

  Future<void> _clearStored() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.remove(_draftStorageKey);
    } catch (_) {
      // Nothing actionable.
    }
  }

  void _update(Quote next) {
    state = next;
    _persist();
  }

  // ----------------------------------------------------------------- boxes

  /// Sets how many [size] boxes are wanted. Zero removes the line.
  void setBoxQuantity(BoxSize size, int quantity) {
    final clamped = quantity.clamp(0, 99);
    final lines = [...state.boxes];
    final index = lines.indexWhere((line) => line.size == size);

    if (index == -1) {
      if (clamped == 0) return;
      lines.add(QuoteBoxLine(size: size, quantity: clamped));
    } else if (clamped == 0) {
      lines.removeAt(index);
    } else {
      lines[index] = lines[index].copyWith(quantity: clamped);
    }

    // Keep lines in tariff order so every screen lists them identically.
    lines.sort((a, b) => a.size.index.compareTo(b.size.index));
    _update(state.copyWith(boxes: lines));
  }

  /// Current quantity for [size], or zero when the tier is not in the quote.
  int boxQuantity(BoxSize size) => state.boxes
      .firstWhere(
        (line) => line.size == size,
        orElse: () => QuoteBoxLine(size: size),
      )
      .quantity;

  void incrementBox(BoxSize size) =>
      setBoxQuantity(size, boxQuantity(size) + 1);

  void decrementBox(BoxSize size) =>
      setBoxQuantity(size, boxQuantity(size) - 1);

  // ----------------------------------------------------------- loose items

  /// Adds a catalogue item. Adding the same preset twice bumps its quantity
  /// instead of creating a duplicate row.
  void addPreset(LooseItemPreset preset) {
    final existing =
        state.looseItems.indexWhere((item) => item.presetKey == preset.key);
    if (existing != -1) {
      setLooseItemQuantity(
        state.looseItems[existing].id,
        state.looseItems[existing].quantity + 1,
      );
      return;
    }
    _update(state.copyWith(looseItems: [
      ...state.looseItems,
      QuoteLooseItem.fromPreset(preset, id: _uuid.v4()),
    ]));
  }

  /// Adds a hand-measured item, pricing it off its volume.
  void addCustomItem({
    required String name,
    required double lengthM,
    required double widthM,
    required double heightM,
    String description = '',
    int quantity = 1,
  }) {
    final volume = lengthM * widthM * heightM;
    _update(state.copyWith(looseItems: [
      ...state.looseItems,
      QuoteLooseItem(
        id: _uuid.v4(),
        name: name,
        description: description,
        lengthM: lengthM,
        widthM: widthM,
        heightM: heightM,
        quantity: quantity.clamp(1, 99),
        monthlyZar: QuotePricing.looseItemMonthly(volume),
      ),
    ]));
  }

  /// Replaces the item with the same id, re-pricing it from its dimensions.
  void updateLooseItem(QuoteLooseItem item) {
    final priced = item.copyWith(
      monthlyZar: QuotePricing.looseItemMonthly(item.unitVolumeM3),
    );
    _update(state.copyWith(
      looseItems: [
        for (final existing in state.looseItems)
          existing.id == priced.id ? priced : existing,
      ],
    ));
  }

  void setLooseItemQuantity(String id, int quantity) {
    final clamped = quantity.clamp(0, 99);
    if (clamped == 0) {
      removeLooseItem(id);
      return;
    }
    _update(state.copyWith(
      looseItems: [
        for (final item in state.looseItems)
          item.id == id ? item.copyWith(quantity: clamped) : item,
      ],
    ));
  }

  void removeLooseItem(String id) => _update(state.copyWith(
        looseItems:
            state.looseItems.where((item) => item.id != id).toList(),
      ));

  // -------------------------------------------------------------- services

  void setPackingRequired(bool required) => _update(state.copyWith(
        packingRequired: required,
        // Re-entering the flow should never resume below the minimum.
        packingHours: state.packingHours < QuotePricing.minPackingHours
            ? QuotePricing.minPackingHours
            : state.packingHours,
      ));

  void setPackers(int packers) =>
      _update(state.copyWith(packers: packers.clamp(1, 6)));

  void setPackingHours(int hours) => _update(
      state.copyWith(packingHours: hours.clamp(QuotePricing.minPackingHours, 12)));

  void setVehicle(VehicleSize vehicle) =>
      _update(state.copyWith(vehicle: vehicle));

  /// Snaps the vehicle to the smallest one that fits what is in the quote.
  void applyRecommendedVehicle() =>
      setVehicle(QuotePricing.recommendedVehicle(state.volumeM3));

  // --------------------------------------------------------------- contact

  void setContact({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? notes,
  }) =>
      _update(state.copyWith(
        contactName: name ?? state.contactName,
        contactEmail: email ?? state.contactEmail,
        contactPhone: phone ?? state.contactPhone,
        collectionAddress: address ?? state.collectionAddress,
        notes: notes ?? state.notes,
      ));

  /// Attaches the now-signed-in client before the quote is written.
  void attachClient({required String clientId, required String userId}) =>
      _update(state.copyWith(clientId: clientId, userId: userId));

  // ----------------------------------------------------------------- reset

  /// Clears the draft in memory and on disk — used after a quote is
  /// accepted, and by the "start over" action.
  void reset() {
    state = const Quote(tenantId: AppConstants.defaultTenantId);
    _clearStored();
  }
}
