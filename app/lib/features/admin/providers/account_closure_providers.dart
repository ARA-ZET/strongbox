import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/account_closure.dart';
import '../../../repositories/repository_providers.dart';
import '../../billing/providers/billing_providers.dart';
import 'clients_providers.dart';

part 'account_closure_providers.g.dart';

/// What still stops [clientId]'s account closing, live (empty = nothing).
/// The server re-checks before it closes anything.
@riverpod
List<ClosureBlocker> clientClosureBlockers(Ref ref, String clientId) =>
    closureBlockers(
      units: ref.watch(clientUnitsProvider(clientId)).valueOrNull ?? const [],
      jobs: ref.watch(clientJobsProvider(clientId)).valueOrNull ?? const [],
      invoices:
          ref.watch(clientInvoicesProvider(clientId)).valueOrNull ?? const [],
    );

/// Admin actions on a client's account closure, via the account-closure
/// Cloud Functions. Errors (e.g. "Not yet: 2 items still in storage")
/// are rethrown for the screen to show.
@Riverpod(keepAlive: true)
class AccountClosureActions extends _$AccountClosureActions {
  @override
  void build() {}

  /// Starts closing [clientId]'s account (closes in 30 days). [reason]
  /// records how they asked, e.g. "Emailed support 12 Nov".
  Future<DateTime> start(String clientId, {String? reason}) => ref
      .read(accountClosureRepositoryProvider)
      .request(clientId, reason: reason);

  /// Keeps the account open.
  Future<void> cancel(String clientId) =>
      ref.read(accountClosureRepositoryProvider).cancel(clientId);

  /// Closes a pending account now instead of on its date.
  Future<void> closeNow(String clientId) =>
      ref.read(accountClosureRepositoryProvider).closeNow(clientId);
}
