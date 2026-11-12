import 'package:cloud_functions/cloud_functions.dart';

import '../core/enums/app_enums.dart';
import '../core/errors/app_exception.dart';
import '../core/models/quote.dart';
import '../core/models/value_objects.dart';

/// A booked pickup: the new job (awaiting confirmation), its paired supply
/// drop-off when supplies come first, and its "awaiting pickup" units.
typedef BookedPickup = ({
  String jobId,
  String? supplyJobId,
  int unitCount,
  int monthlyZar,
  int pickupZar,
  int onceOffZar,
});

/// When supplies are delivered ahead of the pickup (journey Path A).
typedef SupplyDropSlot = ({DateTime date, TimeWindow timeWindow});

/// Client-side bookings, via Cloud Functions so every price, unit and date
/// is checked server-side:
/// - `bookPickup` prices every item from the live price list and creates
///   the pickup (plus a supply drop-off for Path A) and one storage unit per
///   item in one write.
/// - `requestDelivery` checks the units are the client's and in storage,
///   then creates the delivery job and moves them to pending delivery.
/// Both arrive `pendingConfirmation` for an admin to confirm.
/// - `cancelOrder` cancels the client's pickup or delivery until the
///   driver starts it, releasing its units.
abstract class BookingRepository {
  Future<BookedPickup> bookPickup({
    required QuoteDraft quote,
    required String vehicleId,
    required DateTime date,
    required TimeWindow timeWindow,
    required Address address,
    String? notes,
    String? accessNotes,
    SupplyDropSlot? suppliesFirst,
  });

  /// Returns the new delivery job's id.
  Future<String> requestDelivery({
    required List<String> unitIds,
    required DateTime date,
    required TimeWindow timeWindow,
    required Address address,
    String? notes,
  });

  /// Cancels the client's own order before the driver starts it. A
  /// supplies-first pickup's drop-off is cancelled with it.
  Future<void> cancelOrder(String jobId, {String? reason});
}

class FunctionsBookingRepository implements BookingRepository {
  FunctionsBookingRepository(this.functions);

  final FirebaseFunctions functions;

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
    try {
      final result = await functions.httpsCallable('bookPickup').call({
        'boxes': quote.boxes,
        'loose': quote.loose,
        'vehicle': vehicleId,
        'supplies': quote.supplies,
        'helperHours': quote.helperHours,
        // The chosen calendar day at local midnight, with its offset.
        'date': _day(date),
        'timeWindow': timeWindow.name,
        'address': _address(address),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        if (accessNotes != null && accessNotes.trim().isNotEmpty)
          'accessNotes': accessNotes.trim(),
        if (suppliesFirst != null) ...{
          'suppliesFirst': true,
          'supplyDate': _day(suppliesFirst.date),
          'supplyWindow': suppliesFirst.timeWindow.name,
        },
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      return (
        jobId: data['jobId'] as String,
        supplyJobId: data['supplyJobId'] as String?,
        unitCount: (data['unitIds'] as List).length,
        monthlyZar: (data['monthlyZar'] as num).toInt(),
        pickupZar: (data['pickupZar'] as num).toInt(),
        onceOffZar: (data['onceOffZar'] as num? ?? 0).toInt(),
      );
    } on FirebaseFunctionsException catch (error) {
      throw AppException(
        code: error.code,
        message: error.message ?? 'Could not book the pickup. Try again.',
        original: error,
      );
    } catch (error) {
      throw AppException.from(error, 'Could not book the pickup. Try again.');
    }
  }

  @override
  Future<String> requestDelivery({
    required List<String> unitIds,
    required DateTime date,
    required TimeWindow timeWindow,
    required Address address,
    String? notes,
  }) async {
    try {
      final result = await functions.httpsCallable('requestDelivery').call({
        'unitIds': unitIds,
        'date': _day(date),
        'timeWindow': timeWindow.name,
        'address': _address(address),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      });
      return Map<String, dynamic>.from(result.data as Map)['jobId'] as String;
    } on FirebaseFunctionsException catch (error) {
      throw AppException(
        code: error.code,
        message: error.message ?? 'Could not request the delivery. Try again.',
        original: error,
      );
    } catch (error) {
      throw AppException.from(
          error, 'Could not request the delivery. Try again.');
    }
  }

  @override
  Future<void> cancelOrder(String jobId, {String? reason}) async {
    try {
      await functions.httpsCallable('cancelOrder').call({
        'jobId': jobId,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      });
    } on FirebaseFunctionsException catch (error) {
      throw AppException(
        code: error.code,
        message: error.message ?? 'Could not cancel the order. Try again.',
        original: error,
      );
    } catch (error) {
      throw AppException.from(error, 'Could not cancel the order. Try again.');
    }
  }

  static Map<String, dynamic> _address(Address address) => {
        'line1': address.line1,
        'line2': address.line2,
        'city': address.city,
        'postCode': address.postCode,
      };

  static String _day(DateTime date) =>
      _isoWithOffset(DateTime(date.year, date.month, date.day));

  static String _isoWithOffset(DateTime local) {
    final offset = local.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final base = local.toIso8601String().split('.').first;
    return '$base$sign$hours:$minutes';
  }
}
