import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/models/app_user.dart';
import '../../../core/models/client.dart';
import '../../../repositories/repository_providers.dart';
import '../../notifications/providers/notification_providers.dart';

part 'auth_provider.g.dart';

/// Raw FirebaseAuth instance — the only place it is referenced directly.
@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

/// Emits the Firebase [User] on every sign-in/sign-out.
@Riverpod(keepAlive: true)
Stream<User?> authState(Ref ref) =>
    ref.watch(firebaseAuthProvider).authStateChanges();

/// The signed-in user's `users/{uid}` document as an [AppUser], or null.
@Riverpod(keepAlive: true)
Stream<AppUser?> currentUser(Ref ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watchUser(user.uid);
}

/// The signed-in user's uid, used as the `actorId` on repository writes.
@riverpod
String currentActorId(Ref ref) =>
    ref.watch(authStateProvider).valueOrNull?.uid ?? '';

/// Turns a Firebase Auth failure into a message a person can act on,
/// instead of Firebase's raw `[firebase_auth/…]` text.
///
/// With email-enumeration protection on (the Firebase default), a wrong
/// password, an unknown email and a Google-only account all come back as
/// the same `invalid-credential`, so that message has to cover all three.
AppException friendlyAuthError(FirebaseAuthException error) {
  final message = switch (error.code) {
    'invalid-credential' || 'wrong-password' || 'user-not-found' =>
      'That email and password don\'t match an account. Check your '
          'password, use "Forgot password?" to reset it — or, if you signed '
          'up with Google, use "Continue with Google".',
    'invalid-email' => 'That doesn\'t look like a valid email address.',
    'user-disabled' =>
      'This account has been disabled. Please contact us to restore it.',
    'too-many-requests' =>
      'Too many attempts. Wait a few minutes, or reset your password.',
    'network-request-failed' =>
      'Can\'t reach the server. Check your connection and try again.',
    'weak-password' => 'Choose a stronger password (at least 8 characters).',
    'popup-closed-by-user' || 'cancelled-popup-request' =>
      'Google sign-in was closed before it finished.',
    'popup-blocked' =>
      'Your browser blocked the Google sign-in window. Allow pop-ups for '
          'this site and try again.',
    _ => 'Sign-in failed (${error.code}). Please try again, or contact us '
        'if it keeps happening.',
  };
  return AppException(code: error.code, message: message, original: error);
}

/// Auth error codes the screens react to (surfaced via [AppException]).
abstract final class AuthErrorCodes {
  /// The email belongs to a Google-only account — use Google sign-in.
  static const useGoogle = 'use-google';

  /// The email is already registered (Google) — offer the link flow.
  static const linkGoogle = 'link-google';

  /// The email already has a password account — sign in instead.
  static const emailInUse = 'email-in-use';
}

/// Auth actions. keepAlive: registration routes away mid-write, and
/// auto-dispose would tear the notifier down before the user doc lands.
///
/// Account merging: Firebase's "one account per email" (console default,
/// keep it ON) preserves the uid when a password user later signs in with
/// Google. The reverse — registering a password on a Google-first account —
/// throws `email-already-in-use`, which [register] converts into
/// [AuthErrorCodes.linkGoogle] so the UI can run
/// [linkPasswordWithGoogle] and attach both providers to ONE uid.
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<void> build() {}

  FirebaseAuth get _auth => ref.read(firebaseAuthProvider);

  /// Which sign-in providers exist for [email]. Returns an empty list when
  /// unknown (e.g. email-enumeration protection is enabled).
  Future<List<String>> _providersFor(String email) async {
    try {
      // Still authoritative while enumeration protection is off; callers
      // treat [] as "unknown" so nothing depends on it being available.
      // ignore: deprecated_member_use
      return await _auth.fetchSignInMethodsForEmail(email);
    } catch (_) {
      return const [];
    }
  }

  /// Idempotent account provisioning: every sign-in path converges here so
  /// merged logins always share ONE users doc and ONE client record.
  Future<void> _ensureProvisioned(User user,
      {String? name, String? phone}) async {
    final userRepo = ref.read(userRepositoryProvider);
    final clientRepo = ref.read(clientRepositoryProvider);

    var appUser = await userRepo.getUser(user.uid);
    if (appUser == null) {
      appUser = AppUser(
        id: user.uid,
        tenantId: AppConstants.defaultTenantId,
        name: name ?? user.displayName ?? '',
        email: user.email ?? '',
        phone: phone ?? user.phoneNumber,
      );
      await userRepo.createUser(appUser);
    }

    // First sign-in after an admin invite (they set a password or used
    // Google with the invited email) — the invite is now used.
    if (appUser.invited) {
      await userRepo.updateUser(user.uid, {'invited': false});
    }

    // Only clients get a client record; admins/drivers are provisioned by ops.
    if (appUser.role != UserRole.client) return;

    // Already linked?
    if (appUser.clientId != null && appUser.clientId!.isNotEmpty) return;

    // A client record may exist from a previous provider sign-in — reuse it.
    final existing = await clientRepo.getClientByUserId(
        AppConstants.defaultTenantId, user.uid);
    final clientId = existing?.id ??
        await clientRepo.create(
          Client(
            id: '',
            tenantId: AppConstants.defaultTenantId,
            primaryUserId: user.uid,
            displayName: name ?? user.displayName ?? '',
            email: user.email ?? '',
            phone: phone ?? user.phoneNumber ?? '',
          ),
          actorId: user.uid,
        );
    await userRepo.updateUser(user.uid, {'clientId': clientId});
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        final credential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        final user = credential.user;
        if (user != null) await _ensureProvisioned(user);
      } on FirebaseAuthException catch (error) {
        // Password rejected — if this email is Google-only, guide the user
        // to the Google button instead of a dead-end "wrong password".
        if (error.code == 'user-not-found' ||
            error.code == 'wrong-password' ||
            error.code == 'invalid-credential') {
          final providers = await _providersFor(email);
          if (providers.contains('google.com') &&
              !providers.contains('password')) {
            throw const AppException(
              code: AuthErrorCodes.useGoogle,
              message:
                  'This email is registered with Google. Use "Continue '
                  'with Google" — you can add a password afterwards.',
            );
          }
        }
        throw friendlyAuthError(error);
      }
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        final credential = await _auth.signInWithPopup(GoogleAuthProvider());
        final user = credential.user;
        if (user == null) return;
        // Idempotent: a password-first account keeps its uid here, so no
        // duplicate users/client docs are ever created.
        await _ensureProvisioned(user);
      } on FirebaseAuthException catch (error) {
        if (error.code == 'account-exists-with-different-credential') {
          throw const AppException(
            code: AuthErrorCodes.emailInUse,
            message:
                'An account already exists for this email with a different '
                'sign-in method. Sign in with your original method first.',
          );
        }
        throw friendlyAuthError(error);
      }
    });
  }

  /// Creates the Firebase Auth account and its `users/{uid}` doc. When the
  /// email already belongs to a Google account, surfaces
  /// [AuthErrorCodes.linkGoogle] so the UI can offer the merge flow.
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    UserRole role = UserRole.client,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = credential.user;
        if (user == null) throw Exception('Registration failed');
        await user.updateDisplayName(name);
        await _ensureProvisioned(user, name: name, phone: phone);
      } on FirebaseAuthException catch (error) {
        if (error.code == 'email-already-in-use') {
          final providers = await _providersFor(email);
          if (providers.contains('password')) {
            throw const AppException(
              code: AuthErrorCodes.emailInUse,
              message:
                  'This email is already registered. Sign in instead — or '
                  'use "Forgot password" to recover access.',
            );
          }
          // Google-only, or unknown (enumeration protection): offer to
          // link a password onto the existing account via Google.
          throw const AppException(
            code: AuthErrorCodes.linkGoogle,
            message:
                'This email is already registered with Google. Continue '
                'with Google to link a password to the same account.',
          );
        }
        throw friendlyAuthError(error);
      }
    });
  }

  /// Merge flow: signs in with Google, verifies the email matches, then
  /// links the email/password credential onto the SAME account (one uid,
  /// both providers). Provisioning stays idempotent.
  Future<void> linkPasswordWithGoogle({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final credential = await _auth.signInWithPopup(GoogleAuthProvider());
      final user = credential.user;
      if (user == null) return;

      final googleEmail = user.email?.toLowerCase() ?? '';
      if (googleEmail != email.toLowerCase()) {
        await _auth.signOut();
        throw AppException(
          code: 'email-mismatch',
          message:
              'The Google account you chose ($googleEmail) does not match '
              '$email. Please use the matching Google account.',
        );
      }

      try {
        await user.linkWithCredential(
          EmailAuthProvider.credential(email: email, password: password),
        );
      } on FirebaseAuthException catch (error) {
        // Already linked (e.g. retry) is fine; anything else bubbles up.
        if (error.code != 'provider-already-linked') rethrow;
      }

      if ((user.displayName ?? '').isEmpty && (name ?? '').isNotEmpty) {
        await user.updateDisplayName(name);
      }
      await _ensureProvisioned(user, name: name, phone: phone);
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    // While still signed in — the rules only let a user edit their own doc.
    await ref.read(pushNotificationsProvider.notifier).unregister();
    state = await AsyncValue.guard(_auth.signOut);
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        await _auth.sendPasswordResetEmail(email: email);
      } on FirebaseAuthException catch (error) {
        throw friendlyAuthError(error);
      }
    });
  }
}
