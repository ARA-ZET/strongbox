import 'package:cloud_functions/cloud_functions.dart';

import '../core/errors/app_exception.dart';

/// Account closure via the `requestAccountClosure`, `cancelAccountClosure`
/// and `closeAccountNow` Cloud Functions (functions/src/closure.js).
///
/// The server checks who may act on which client, schedules the closure,
/// and does the erasing — the app never deletes anyone's details itself.
abstract class AccountClosureRepository {
  /// Schedules [clientId]'s account to close in 30 days; returns the date.
  /// A client may only pass their own id. [reason] is recorded (admins
  /// note how the client asked). Asking again keeps the original date.
  Future<DateTime> request(String clientId, {String? reason});

  /// Cancels a pending closure.
  Future<void> cancel(String clientId);

  /// Admin only: closes a pending account now instead of on its date.
  /// Fails with the reason while anything still blocks it.
  Future<void> closeNow(String clientId);
}

class FunctionsAccountClosureRepository implements AccountClosureRepository {
  FunctionsAccountClosureRepository(this.functions);

  final FirebaseFunctions functions;

  @override
  Future<DateTime> request(String clientId, {String? reason}) async {
    final data = await _call('requestAccountClosure', {
      'clientId': clientId,
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    });
    return DateTime.parse(data['scheduledFor'] as String).toLocal();
  }

  @override
  Future<void> cancel(String clientId) =>
      _call('cancelAccountClosure', {'clientId': clientId});

  @override
  Future<void> closeNow(String clientId) =>
      _call('closeAccountNow', {'clientId': clientId});

  /// Calls [name], surfacing the server's message (e.g. "Not yet: 2 items
  /// still in storage") as an [AppException].
  Future<Map<String, dynamic>> _call(
    String name,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await functions.httpsCallable(name).call(data);
      return Map<String, dynamic>.from(result.data as Map? ?? const {});
    } on FirebaseFunctionsException catch (error) {
      throw AppException(
        code: error.code,
        message: error.message ?? 'Could not reach the server. Try again.',
        original: error,
      );
    } catch (error) {
      throw AppException.from(error, 'Could not reach the server. Try again.');
    }
  }
}
