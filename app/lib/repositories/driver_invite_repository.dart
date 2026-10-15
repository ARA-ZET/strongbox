import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../core/constants/firestore_collections.dart';
import '../core/enums/app_enums.dart';
import '../core/errors/app_exception.dart';

/// A sent invite: the password-setup [link] (to share directly) and the
/// `mail` doc carrying the invite email.
typedef DriverInvite = ({String uid, String link, String mailId});

/// Whether an email went out, and why not when it didn't.
typedef EmailStatus = ({EmailDeliveryState state, String? error});

/// Driver invites via the `inviteDriver` / `resendInvite` Cloud Functions.
///
/// The server creates the driver's login and profile and emails a
/// "set your password" link; the link is also returned so an admin can
/// share it directly. Only admins may call these.
abstract class DriverInviteRepository {
  /// Invites a new driver.
  Future<DriverInvite> invite({
    required String name,
    required String email,
    String? phone,
  });

  /// A fresh setup link (and email) for a driver who has not signed in.
  Future<DriverInvite> resend(String uid);

  /// Live delivery status of the invite email [mailId].
  Stream<EmailStatus> watchEmail(String mailId);
}

class FunctionsDriverInviteRepository implements DriverInviteRepository {
  FunctionsDriverInviteRepository(this.functions, this.db);

  final FirebaseFunctions functions;
  final FirebaseFirestore db;

  @override
  Future<DriverInvite> invite({
    required String name,
    required String email,
    String? phone,
  }) async {
    final data = await _call('inviteDriver', {
      'name': name,
      'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });
    return (
      uid: data['uid'] as String,
      link: data['link'] as String,
      mailId: data['mailId'] as String? ?? '',
    );
  }

  @override
  Future<DriverInvite> resend(String uid) async {
    final data = await _call('resendInvite', {'uid': uid});
    return (
      uid: uid,
      link: data['link'] as String,
      mailId: data['mailId'] as String? ?? '',
    );
  }

  @override
  Stream<EmailStatus> watchEmail(String mailId) => db
      .collection(Collections.mail)
      .doc(mailId)
      .snapshots()
      .map((doc) {
        final delivery = doc.data()?['delivery'] as Map<String, dynamic>?;
        return switch (delivery?['state']) {
          'SUCCESS' => (state: EmailDeliveryState.sent, error: null),
          'ERROR' => (
              state: EmailDeliveryState.failed,
              error: delivery?['error'] as String?,
            ),
          _ => (state: EmailDeliveryState.sending, error: null),
        };
      });

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
