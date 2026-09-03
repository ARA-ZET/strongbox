import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/models/quote.dart';
import '../../../core/providers/tenant_provider.dart';
import '../../../repositories/repository_providers.dart';
import '../../auth/providers/auth_provider.dart';
import 'quote_draft_provider.dart';

part 'quote_submission_provider.g.dart';

/// Where to send the visitor once they finish signing in or registering.
///
/// Set when a guest accepts a quote, read by the router's redirect. It has
/// to be a provider rather than a `returnTo` query parameter because the
/// router bounces through the splash screen while `users/{uid}` loads,
/// which would drop the parameter.
@Riverpod(keepAlive: true)
class QuoteReturnPath extends _$QuoteReturnPath {
  @override
  String? build() => null;

  /// Remembers [path] and arms the auto-accept on arrival.
  void arm(String path) => state = path;

  void clear() => state = null;
}

/// Accepts the drafted quote on behalf of the signed-in client.
///
/// Holds the accepted [Quote] as its state so the confirmation screen can
/// render the reference and totals after the draft has been cleared.
@Riverpod(keepAlive: true)
class QuoteSubmission extends _$QuoteSubmission {
  @override
  FutureOr<Quote?> build() => null;

  /// Writes the current draft as an accepted quote plus its pickup job.
  ///
  /// Throws [AppException] when called without a signed-in client, which
  /// the summary screen surfaces rather than silently dropping the quote.
  Future<Quote?> accept({
    DateTime? collectionDate,
    TimeWindow timeWindow = TimeWindow.morning,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) {
        throw const AppException(
          code: 'not-signed-in',
          message: 'Sign in to accept this quote.',
        );
      }
      if (user.role != UserRole.client) {
        throw const AppException(
          code: 'not-a-client',
          message: 'Quotes can only be accepted from a client account.',
        );
      }
      final clientId = user.clientId;
      if (clientId == null || clientId.isEmpty) {
        throw const AppException(
          code: 'no-client-record',
          message:
              'Your client record is still being set up. Try again shortly.',
        );
      }

      final draft = ref.read(quoteDraftProvider).copyWith(
            tenantId: ref.read(currentTenantIdProvider),
            clientId: clientId,
            userId: user.id,
            contactName:
                _fallback(ref.read(quoteDraftProvider).contactName, user.name),
            contactEmail: _fallback(
                ref.read(quoteDraftProvider).contactEmail, user.email),
            contactPhone: _fallback(
                ref.read(quoteDraftProvider).contactPhone, user.phone ?? ''),
          );

      final accepted = await ref.read(quoteRepositoryProvider).accept(
            draft,
            actorId: user.id,
            collectionDate: collectionDate,
            timeWindow: timeWindow,
          );

      // The basket has become a real quote — clear it so a return visit
      // starts clean.
      ref.read(quoteDraftProvider.notifier).reset();
      return accepted;
    });
    return state.valueOrNull;
  }

  /// Drops the accepted quote, e.g. when starting a fresh quote.
  void clear() => state = const AsyncData(null);
}

String _fallback(String value, String alternative) =>
    value.trim().isEmpty ? alternative : value;
