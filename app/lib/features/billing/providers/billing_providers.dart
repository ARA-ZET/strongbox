import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/invoice.dart';
import '../../../core/providers/tenant_provider.dart';
import '../../../core/utils/async_value_ext.dart';
import '../../../repositories/repository_providers.dart';
import '../../auth/providers/auth_provider.dart';

part 'billing_providers.g.dart';

/// A client's monthly invoices, newest first.
@riverpod
Stream<List<Invoice>> clientInvoices(Ref ref, String clientId) {
  final tenantId = ref.watch(currentTenantIdProvider);
  return ref
      .watch(subscriptionRepositoryProvider)
      .watchInvoices(tenantId, clientId);
}

/// Settles invoices: clients pay by EFT, an admin records it here. The
/// client's billing status follows via the onInvoiceUpdated function.
@riverpod
class InvoiceActions extends _$InvoiceActions {
  @override
  FutureOr<void> build() {}

  /// Records that [invoice] was paid; [note] says how (bank, date, ref).
  Future<void> markPaid(Invoice invoice, {String? note}) async {
    final actorId = ref.read(currentActorIdProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(subscriptionRepositoryProvider)
        .markPaid(invoice, actorId: actorId, note: note));
    state.throwIfError();
  }

  /// Cancels [invoice] — billed in error, or written off.
  Future<void> voidInvoice(Invoice invoice, String reason) async {
    final actorId = ref.read(currentActorIdProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref
        .read(subscriptionRepositoryProvider)
        .voidInvoice(invoice, actorId: actorId, reason: reason));
    state.throwIfError();
  }
}
