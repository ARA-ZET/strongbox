import 'package:cloud_functions/cloud_functions.dart';

import '../core/errors/app_exception.dart';

/// Driver invites via the `inviteDriver` / `resendInvite` Cloud Functions.
///
/// The server creates the driver's login and profile and emails a
/// "set your password" link; the link is also returned so an admin can
/// share it directly. Only admins may call these.
abstract class DriverInviteRepository {
  /// Invites a new driver; returns their uid and the setup link.
  Future<({String uid, String link})> invite({
    required String name,
    required String email,
    String? phone,
  });

  /// A fresh setup link (and email) for a driver who has not signed in.
  Future<String> resend(String uid);
}

class FunctionsDriverInviteRepository implements DriverInviteRepository {
  FunctionsDriverInviteRepository(this.functions);

  final FirebaseFunctions functions;

  @override
  Future<({String uid, String link})> invite({
    required String name,
    required String email,
    String? phone,
  }) async {
    final data = await _call('inviteDriver', {
      'name': name,
      'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });
    return (uid: data['uid'] as String, link: data['link'] as String);
  }

  @override
  Future<String> resend(String uid) async =>
      (await _call('resendInvite', {'uid': uid}))['link'] as String;

  /// Calls [name], surfacing the server's message (e.g. "already has an
  /// account") as an [AppException].
  Future<Map<String, dynamic>> _call(
      String name, Map<String, dynamic> data) async {
    try {
      final result = await functions.httpsCallable(name).call(data);
      return Map<String, dynamic>.from(result.data as Map);
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
